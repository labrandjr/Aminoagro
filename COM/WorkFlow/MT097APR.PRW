#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT097APR  ¦ Autor ¦ ERPBR		    ¦   Data  ¦ Fev/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processo complementar após Liberação do Documento.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT097APR()

Local aArea := GetArea()
Local lWfPc := ( AllTrim(GetMv("MV_WFPCINT")) == "S" )
Local lWfNf := ( AllTrim(GetMv("MV_WFNFINT")) == "S" )
Local _x

ConOut(FunName()+": MT097APR - "+AllTrim(SCR->CR_TIPO)+" "+AllTrim(SCR->CR_NUM))
	
If lWfPc .And. FunName() == "MATA094" .And. SCR->CR_TIPO == "PC" .And. SCR->CR_ENVMAIL != "4"

	_aMsg   := {}
 	cPedido := AllTrim(SC7->C7_NUM)
	zNomFil := FWFilialName(cEmpAnt,SC7->C7_FILIAL,1)
	zMensag := "Pedido de Compra: "+cPedido+" | Filial: "+SC7->C7_FILIAL+"-"+AllTrim(zNomFil)+" | A P R O V A D O |"
		
	AAdd(_aMsg, "")
	AAdd(_aMsg, zMensag)
	AAdd(_aMsg, "STATUS: APROVADO PELO GRUPO DE APROVAÇÃO")

	cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SC7->C7_USER) )
	U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

	cObs := "Aprovado por " + AllTrim(cUserName) + " via Módulo Compras em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5)
	Reclock("SCR",.F.)
	SCR->CR_ENVMAIL	:= "4"
	SCR->CR_OBS	    := cObs
	MsUnLock()

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
			cEmailWf := UsrRetMail(aUsrMail[_x])
			If !Empty(cEmailWf)
				nPosic := AT("@",cEmailWf)
				If nPosic > 0
					U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)
				Endif
			Endif
		Next _x	
	Endif

ElseIf lWfNf .And. FunName() == "MATA094" .And. SCR->CR_TIPO == "NF" .And. SCR->CR_ENVMAIL != "4"

	_aMsg   := {}
 	cDocume := AllTrim(SF1->F1_SERIE)+"-"+AllTrim(SF1->F1_DOC)
	zNomFil := FWFilialName(cEmpAnt,SF1->F1_FILIAL,1)
	zMensag := "Documento: "+cDocume+" | Filial: "+SF1->F1_FILIAL+"-"+AllTrim(zNomFil)+" | A P R O V A D O |"
		
	AAdd(_aMsg, "")
	AAdd(_aMsg, zMensag)
	AAdd(_aMsg, "STATUS: APROVADO PELO GRUPO DE APROVAÇÃO")

	cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SF1->F1_ZZUSER) )
	U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

	cObs := "Aprovado por " + AllTrim(cUserName) + " via Módulo Compras em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5)
	Reclock("SCR",.F.)
	SCR->CR_ENVMAIL	:= "4"
	SCR->CR_OBS	    := cObs
	MsUnLock()

Endif

RestArea(aArea)

Return
