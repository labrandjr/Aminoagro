#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTALCFIM  ¦ Autor ¦ ERPBR		    ¦   Data  ¦ Fev/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processo complementar após Liberação/Bloqueio do Documento.¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Pacotes   ¦ 28/09/2021 - Projeto Workflow versão 2.0 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTALCFIM()

Local aArea  := GetArea()
Local aDocto := PARAMIXB[1]
Local cDocto := aDocto[1]
Local cTipo  := aDocto[2]
Local dDtRef := PARAMIXB[2]
Local nOper  := PARAMIXB[3] // 1=Inclusão | 3=Alteração
Local cDocF1 := PARAMIXB[4]
Local lResid := PARAMIXB[5]
Local lPend  := .F.
Local lBloq  := .F.
Local lWfPc  := ( AllTrim(GetMv("MV_WFPCINT")) == "S" )
Local lWfNf  := ( AllTrim(GetMv("MV_WFNFINT")) == "S" )
Local lWfV2  := GetMv("MV_ZWFVER2")
Local _x

ConOut(FunName()+": MTALCFIM - "+AllTrim(cTipo)+" "+AllTrim(cDocto)+" "+DtoC(dDtRef)+" "+AllTrim(STR(nOper))+" "+cDocF1+" "+IIf(lResid,".T.",".F."))
	
If lWfPc .And. FunName() == "MATA094" .And. cTipo == "PC"

	cPedido := AllTrim(cDocto)
	cMotBlq := ""

	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek( xFilial("SCR") + cTipo + cDocto )
		While !Eof() .And. SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == xFilial("SCR") + cTipo + cDocto
			If SCR->CR_STATUS $("04,06")
				lBloq   := .T.
				cMotBlq := "Reprovado por " + AllTrim(UsrFullName(SCR->CR_USER)) + " via Módulo Compras em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5) + IIf(!Empty(SCR->CR_OBS)," | Motivo: " + AllTrim(SCR->CR_OBS),"")
				Reclock("SCR",.F.)
				SCR->CR_OBS := cMotBlq
				MsUnLock()
				Exit
			ElseIf SCR->CR_STATUS $("03")
				cMotBlq := "Aprovado por " + AllTrim(UsrFullName(SCR->CR_USER)) + " via Módulo Compras em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5)
				Reclock("SCR",.F.)
				SCR->CR_OBS := cMotBlq
				MsUnLock()
			ElseIf SCR->CR_STATUS == "02" .And. Empty(SCR->CR_DATALIB)
				lPend := .T.
				Exit
			Endif
			SCR->(DbSkip())
		Enddo
	Endif

	If lBloq

		// Notificação de Reprovação ------------------------------------------------
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( cFilAnt + cPedido )

		_aMsg   := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		zMensag := "Pedido de Compra: "+cPedido+" | Filial: "+cFilAnt+"-"+AllTrim(zNomFil)+" | R E P R O V A D O |"

		AAdd(_aMsg, "")
		AAdd(_aMsg, zMensag)
		AAdd(_aMsg, "STATUS: PEDIDO REPROVADO" )
		AAdd(_aMsg, cMotBlq )

		cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SC7->C7_USER) )
		U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

		// E-mails complementares
		If Empty(GetMv("MV_WFEMTST"))
			zUsrParm := AllTrim(GetMv("MV_XEMLAPC"))
			zUsrMail := ""
			aUsrMail := {}
			If !Empty(zUsrParm)
				zUsrMail := zUsrParm
			Endif
			//
			If !Empty(zUsrMail)
				nPosic  := 0
				aLinha  := {}
				cTxtLin := zUsrMail
				While (!Empty(cTxtLin))
					If (((nPosic := AT(",",cTxtLin)) > 0))
						AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
						cTxtLin := Stuff(cTxtLin,1,nPosic,"")
					Else
						AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
						cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
					Endif	
				Enddo
				aUsrMail := aClone(aLinha)
			Endif	
			//
			For _x := 1 to Len(aUsrMail)
				If aUsrMail[_x] != SC7->C7_USER
					cEmailWf := UsrRetMail(aUsrMail[_x])
					If !Empty(cEmailWf)
						nPosic := AT("@",cEmailWf)
						If nPosic > 0
							U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)
						Endif
					Endif
				Endif	
			Next _x	
		Endif

	ElseIf lPend

		// ********************************************************* //
		// ** Abre novo processo WorkFlow para demais aprovadores ** //
		// ********************************************************* //
		cModo := ""
		If lWfV2
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("ZZJ")
			cQuery += " WHERE ZZJ_FILIAL = '"+cFilAnt+"' "
			cQuery += " AND ZZJ_PEDIDO = '"+cPedido+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)
			cModo := IIf(SQL7->SOMA == 0, "Inclusão", "Alteração")
			SQL7->(DbCloseArea())
		Endif
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( cFilAnt + cPedido )
		U_WFPC01(.F.,Nil,.T.,.F.,"MTALCFIM",cModo) // WFPC01(lJob,cNumPed,lShow,lAsk,cRotina)

	Endif

ElseIf lWfNf .And. FunName() == "MATA094" .And. cTipo == "NF"

	cDocume := AllTrim(Substr(cDocto,1,9))+"-"+AllTrim(Substr(cDocto,10,3))
	cNFisca := Substr(cDocto,1,20)
	cMotBlq := ""

	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek( xFilial("SCR") + cTipo + cDocto )
		While !Eof() .And. SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == xFilial("SCR") + cTipo + cDocto
			If SCR->CR_STATUS $("04,06")
				lBloq   := .T.
				cMotBlq := "Reprovado por " + AllTrim(UsrFullName(SCR->CR_USER)) + " via Módulo Compras em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5) + IIf(!Empty(SCR->CR_OBS)," | Motivo: " + AllTrim(SCR->CR_OBS),"")
				Reclock("SCR",.F.)
				SCR->CR_OBS := cMotBlq
				MsUnLock()
				Exit
			ElseIf SCR->CR_STATUS $("03")
				cMotBlq := "Aprovado por " + AllTrim(UsrFullName(SCR->CR_USER)) + " via Módulo Compras em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5)
				Reclock("SCR",.F.)
				SCR->CR_OBS := cMotBlq
				MsUnLock()
			ElseIf SCR->CR_STATUS == "02" .And. Empty(SCR->CR_DATALIB)
				lPend := .T.
				Exit
			Endif
			SCR->(DbSkip())
		Enddo
	Endif

	If lBloq

		// Notificação de Reprovação ------------------------------------------------
		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( cFilAnt + cNFisca )

		_aMsg   := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		zMensag := "Documento: "+cDocume+" | Filial: "+cFilAnt+"-"+AllTrim(zNomFil)+" | R E P R O V A D O |"

		AAdd(_aMsg, "")
		AAdd(_aMsg, zMensag)
		AAdd(_aMsg, "STATUS: DOCUMENTO REPROVADO" )
		AAdd(_aMsg, cMotBlq )

		cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SF1->F1_ZZUSER) )
		U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

	ElseIf lPend

		// ********************************************************* //
		// ** Abre novo processo WorkFlow para demais aprovadores ** //
		// ********************************************************* //
		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( cFilAnt + cNFisca )
		U_WFNF01(.F.,Nil,.T.,.F.,"MTALCFIM") // WFNF01(lJob,cNumNfe,lShow,lAsk,cRotina)

	Endif
	
Endif

RestArea(aArea)

Return
