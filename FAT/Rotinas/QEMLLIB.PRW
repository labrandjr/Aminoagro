#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QEMLLIB ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mails - Liberação de crédito.		  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLLIB()

ConOut("Função QEMLLIB: Liberação de Crédito < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

cQuery := " SELECT DISTINCT(ZZA_PEDIDO) ZZA_PEDIDO, ZZA_TXTLIB, ZZA_TIPLIB "
cQuery += " FROM "+RetSqlName("ZZA")
cQuery += " WHERE ZZA_FILIAL = '"+xFilial("ZZA")+"' "
cQuery += " AND ZZA_EMLSTT = '2' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY ZZA_PEDIDO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
While !Eof()

	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek( xFilial("SC5") + SQL2->ZZA_PEDIDO )
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )

		lAgrpLim := (GetMv("MV_AGRPLIM") == "S")
		lAgrpCrd := .F.
		lAgrpCgc := .F.
		cCgcCli  := Substr(SA1->A1_CGC,1,8) // Base do Cgc da Matriz

		nRecSa1 := SA1->(Recno()) // Cliente+Loja do Pedido
		If lAgrpLim // Agrupamento de Crédito = Habilitado
			If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
				lAgrpCrd := .T.
			Else
				If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
					DbSelectArea("SA1")
					DbSetOrder(1)
					If DbSeek( xFilial("SA1") + SA1->A1_ZZAGCRD )
						lAgrpCrd := .T.
					Endif
				Else // Agrupamento de Crédito: verifica se código do cliente está sendo usado para agrupamento
					cQuery := " SELECT COUNT(*)AS SOMA "
					cQuery += " FROM "+RetSqlName("SA1")
					cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
					cQuery += " AND A1_ZZAGCRD = '"+SA1->A1_COD+"' "
					cQuery += " AND D_E_L_E_T_ <> '*' "
					DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLA",.T.,.T.)
					lAgrpCrd := (SQLA->SOMA > 0)
					SQLA->(DbCloseArea())
				Endif
			Endif
			// Se não for agrupamento de crédito, verifica se existe agrupamento pela Base do Cnpj
			If !lAgrpCrd
				DbSelectArea("SA1")
				DbSetOrder(3)
				If DbSeek( xFilial("SA1") + cCgcCli + "0001" )
					lAgrpCgc := .T.
				Endif
			Endif
		Endif
		SA1->(DbGoto(nRecSa1))

		cQuery := " SELECT SUM(C9_QTDLIB*C9_PRCVEN) AS VLRLIB "
		cQuery += " FROM "+RetSqlName("SC9")
		cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
		cQuery += " AND C9_PEDIDO = '"+SQL2->ZZA_PEDIDO+"' "
		cQuery += " AND C9_BLCRED <> '10' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQ9",.T.,.T.)
		zTotLib := SQ9->VLRLIB
		SQ9->(DbCloseArea())

		zCodCli := SA1->A1_COD
		zLojCli := SA1->A1_LOJA
		zAgrCrd := lAgrpCrd
		zAgrCgc := lAgrpCgc
		zCodigo := ""
		zMotLib := SQL2->ZZA_TXTLIB
		zUnidNg := SC5->C5_ZZITCTB
		lRejeit := ( Substr(SQL2->ZZA_TXTLIB,1,9)=="Rejeitado" )

		If zTotLib > 0 // Casos em que já ocorreu o faturamento
			u_MMess45L(zCodCli,zLojCli,zAgrCrd,zAgrCgc,zCodigo,zMotLib,zUnidNg,zTotLib,lRejeit)
		Endif	

	Endif

	cQuery := " UPDATE "+RetSqlName("ZZA")+" SET ZZA_EMLSTT = '3' "
	cQuery += " WHERE ZZA_FILIAL = '"+xFilial("ZZA")+"' "
	cQuery += " AND ZZA_PEDIDO = '"+SQL2->ZZA_PEDIDO+"' "
	cQuery += " AND ZZA_TXTLIB = '"+AllTrim(SQL2->ZZA_TXTLIB)+"' "
	cQuery += " AND ZZA_TIPLIB = '"+SQL2->ZZA_TIPLIB+"' "
	cQuery += " AND ZZA_EMLSTT = '2' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)	

	cQuery := " COMMIT "
	TCSQLEXEC(cQuery)	

	DbSelectArea("SQL2")
	SQL2->(DbSkip())
Enddo	
SQL2->(DbCloseArea())

ConOut("Função QEMLLIB: Liberação de Crédito < Fim > "+DtoC(Date())+" - "+Time())

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess45L ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 20/09/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger Liberação de Crédito.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMess45L(cCodCli,cLojCli,lAgrpCrd,lAgrpCgc,zCodigo,zMotLib,zBU,zTotLib,lRejeit)

Local aArea    := GetArea()
Local zUsrParm := AllTrim(GetMv("MV_XEMBLCR"))
Local zUsrMail := ""
Local aUsrMail := {}
Local _x

If !Empty(zUsrParm) // Se o parâmetro estiver preenchido, assume a preferência. Ambiente de Testes.
	zUsrMail := zUsrParm
Else
	DbSelectArea("SX5")
	DbSetOrder(1)
	If DbSeek( xFilial("SX5") + "WA" + PadR(zBU,6) )
		zUsrMail := AllTrim(SX5->X5_DESCRI)
	Endif
Endif

If !Empty(zUsrMail)
	nPosic  := 0
	aLinha  := {}
	cTxtLin := zUsrMail
	While (!Empty(cTxtLin))
		If (((nPosic := AT(",",cTxtLin)) > 0))
			zCpo := Val(Substr(cTxtLin,1,nPosic-1))
			zCpo := StrZero(zCpo,6)
			AAdd(aLinha,zCpo)
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			zCpo := Val(Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			zCpo := StrZero(zCpo,6)
			AAdd(aLinha,zCpo)
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo
	aUsrMail := aClone(aLinha)
Endif	

For _x := 1 to Len(aUsrMail)
	zEmail := UsrRetMail(aUsrMail[_x])
	If !Empty(zEmail)
		nPosic := AT("@",zEmail)
		If nPosic > 0
			If lRejeit
				cAssunto := "Rejeicao de Credito - Pedido "+xFilial("SC5")+"-"+AllTrim(SC5->C5_NUM)+" - "+zBU
			Else
				cAssunto := "Liberacao de Credito - Pedido "+xFilial("SC5")+"-"+AllTrim(SC5->C5_NUM)+" - "+zBU
			Endif	
			//
			aMensage := {}
			If lRejeit
				AAdd(aMensage, "Evento X06 - O pedido de venda abaixo teve o crédito rejeitado")
			Else
				AAdd(aMensage, "Evento X06 - O pedido de venda abaixo foi liberado por crédito")
			Endif	
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial.: "+xFilial("SC5"))
			AAdd(aMensage, ">> Pedido.: "+AllTrim(SC5->C5_NUM))
			AAdd(aMensage, ">> Vlr.R$.: "+AllTrim(Transform(zTotLib,"@E 9,999,999.99")))
			AAdd(aMensage, ">> Cliente: "+AllTrim(cCodCli)+" - "+AllTrim( RetField("SA1",1,xFilial("SA1") + cCodCli + cLojCli,"A1_NOME") ))
			AAdd(aMensage, ">> Agrupam: "+IIf(lAgrpCrd,"Grupo",IIf(lAgrpCgc,"Cnpj","Não")))
			AAdd(aMensage, ">> RTV....: "+AllTrim(SC5->C5_VEND1) +" - "+AllTrim( RetField("SA3",1,xFilial("SA3") + SC5->C5_VEND1 ,"A3_NOME") ))
			AAdd(aMensage, ">> Gerente: "+AllTrim(SC5->C5_GEREN1)+" - "+AllTrim( RetField("SA3",1,xFilial("SA3") + SC5->C5_GEREN1,"A3_NOME") ))
			AAdd(aMensage, ">> Obs....: "+zMotLib)
            //
			U_MailNotify(zEmail, cAssunto, aMensage, .F.)
		Endif
	Endif
Next _x	
	
RestArea(aArea)

Return


User Function CargaZZA()
cQuery := " SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_BLCRED, C9_XMOTBLQ "
cQuery += " FROM "+RetSqlName("SC9")
cQuery += " WHERE C9_BLCRED <> ' ' "
cQuery += " AND C9_BLCRED <> '10' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C9_FILIAL, C9_PEDIDO, C9_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL9", .F., .T.)
While !Eof()
	DbSelectArea("ZZA")
	DbSetOrder(1)
	If !DbSeek( SQL9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) )
		RecLock("ZZA",.T.)
		ZZA->ZZA_FILIAL := SQL9->C9_FILIAL
		ZZA->ZZA_PEDIDO := SQL9->C9_PEDIDO
		ZZA->ZZA_ITEM   := SQL9->C9_ITEM
		ZZA->ZZA_EMLSTT := "1" // Bloqueado
		ZZA->ZZA_TXTLIB := ""  // Zera o motivo da liberação
		ZZA->ZZA_TIPLIB := ""  // Zera o tipo da liberação
		MsUnLock()
	Endif	
	DbSelectArea("SQL9")
	SQL9->(DbSkip())
Enddo	
SQL9->(DbCloseArea())
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 26/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLL01()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QEMLLIB()
Return

User Function QEMLL02()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_QEMLLIB()
Return

User Function QEMLL03()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_QEMLLIB()
Return

User Function QEMLL04()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_QEMLLIB()
Return

User Function QEMLL06()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_QEMLLIB()
Return

User Function QEMLL07()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_QEMLLIB()
Return

User Function QEMLL08()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_QEMLLIB()
Return

User Function QEMLL09()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_QEMLLIB()
Return

User Function QEMLL10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_QEMLLIB()
Return
