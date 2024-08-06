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
¦¦¦Programa  ¦ QEMLDEV ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/04/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mails - Devolução de Vendas.		  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLDEV()

//FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QEMLDEV Devolução de Vendas < Início "+cFilAnt+" >", 0, /*(nStart - Seconds())*/10, {"Início"})
ConOut("Função QEMLDEV: Devolução de Vendas < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

cQuery := " SELECT F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA "
cQuery += " FROM "+RetSqlName("SF1")
cQuery += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' "
cQuery += " AND F1_TIPO = 'D' "
cQuery += " AND F1_XEMLDEV = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY F1_FILIAL, F1_DTDIGIT "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
While !Eof()
	//
	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek( xFilial("SF1") + SQL1->F1_DOC + SQL1->F1_SERIE + SQL1->F1_FORNECE + SQL1->F1_LOJA )

	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek( xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )

	zRecSD1 := SD1->(Recno())
	aNfOrig := {}
	zDocOri := ""

	While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

		If Len(aNfOrig) == 0
			AAdd(aNfOrig,{ AllTrim(SD1->D1_NFORI), AllTrim(SD1->D1_SERIORI) })
			zDocOri += AllTrim(SD1->D1_NFORI)
		Else
			nPos := aScan(aNfOrig, {|x| x[1] == AllTrim(SD1->D1_NFORI) .And. x[2] == AllTrim(SD1->D1_SERIORI) })
			If nPos == 0
				AAdd(aNfOrig,{ AllTrim(SD1->D1_NFORI), AllTrim(SD1->D1_SERIORI) })
				zDocOri += IIf(!Empty(zDocOri),", ","")+AllTrim(SD1->D1_NFORI)
			Endif 
		Endif	

		DbSelectArea("SD1")
		SD1->(DbSkip())
	Enddo
	SD1->(DbGoto(zRecSD1))
		
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA )

	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + SD1->D1_TES )

	lDuplic := (SF4->F4_DUPLIC == "S")
	zTotDev := 0
	zMotDev := "NAO INFORMADO"
	zUnidNg := SC5->C5_ZZITCTB

	If lDuplic

		cQuery := " SELECT SUM(D1_TOTAL) AS VLRDEV "
		cQuery += " FROM "+RetSqlName("SD1")
		cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
		cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' "
		cQuery += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
		cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
		cQuery += " AND D1_LOJA = '"+SF1->F1_LOJA+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQD1",.T.,.T.)
		zTotDev := SQD1->VLRDEV
		SQD1->(DbCloseArea())

		If !Empty(SF1->F1_MOTRET)
			DbSelectArea("DHI")
			DbSetOrder(1)
			If DbSeek( xFilial("DHI") + SF1->F1_MOTRET )
				zMotDev := AllTrim(DHI->DHI_DESCRI)
			Endif
		Endif

		u_MMess103D(zTotDev,zMotDev,zUnidNg,zDocOri)

	Endif

	RecLock("SF1",.F.)
	SF1->F1_XEMLDEV := "S"
	MsUnLock()

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo	
SQL1->(DbCloseArea())

//FwLogMsg("INFO", /*cTransactionId*/"LAST", "REST", FunName(), "", "02", "QEMLDEV Devolução de Vendas < Fim "+cFilAnt+" >", 0, /*(nStart - Seconds())*/20, {"Fim"})
ConOut("Função QEMLDEV: Devolução de Vendas < Fim > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess103D ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 19/04/18   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger Devolução de Vendas.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMess103D(zTotDev,zMotDev,zBU,zDocOri)

Local aArea    := GetArea()
Local zUsrParm := AllTrim(GetMv("MV_XEMLDEV"))
Local zUsrMail := ""
Local aUsrMail := {}
Local _x

If !Empty(zUsrParm) // Se o parâmetro estiver preenchido, assume a preferência. Ambiente de Testes.
	zUsrMail := zUsrParm
Else
	If !Empty(zBU)
		aUsrMail := FWGetSx5("WC", PadR(zBU,6))
		zUsrMail := ""
		If Len(aUsrMail) > 0
			zUsrMail := AllTrim(aUsrMail[1][4])
			zUsrMail += ","+AllTrim(GetMv("MV_XEMLDE2")) // Acrescenta usuários do Financeiro
		Else
			zUsrMail := AllTrim(GetMv("MV_XEMLDE2")) // BU´s não cadastradas na tabela WC envia somente aos usuários do Financeiro
		Endif
	Else
		zUsrMail := AllTrim(GetMv("MV_XEMLDE2")) // BU´s em branco envia somente aos usuários do Financeiro
	Endif	
Endif

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

For _x := 1 to Len(aUsrMail)
	zEmail := UsrRetMail(aUsrMail[_x])
	If !Empty(zEmail)
		nPosic := AT("@",zEmail)
		If nPosic > 0
			
			cAssunto := "Devolucao de Vendas - Documento "+xFilial("SF1")+"-"+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" |"+zBU+"|"
			//
			aMensage := {}
			AAdd(aMensage, "Evento X07 - A nota fiscal abaixo foi devolvida.")
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial...: "+xFilial("SD1"))
			AAdd(aMensage, ">> Documento: "+AllTrim(zDocOri))
			AAdd(aMensage, ">> Cliente..: "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NOME))
			AAdd(aMensage, ">> Valor R$.: "+AllTrim(Transform(zTotDev,"@E 9,999,999.99")))
			AAdd(aMensage, ">> Motivo...: "+zMotDev)
            //
			U_MailNotify(zEmail, cAssunto, aMensage, .F.)
		Endif
	Endif
Next _x	
	
RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 18/04/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLD01()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QEMLDEV()
Return

User Function QEMLD02()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_QEMLDEV()
Return

User Function QEMLD03()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_QEMLDEV()
Return

User Function QEMLD04()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_QEMLDEV()
Return

User Function QEMLD06()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_QEMLDEV()
Return

User Function QEMLD07()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_QEMLDEV()
Return

User Function QEMLD08()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_QEMLDEV()
Return

User Function QEMLD09()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_QEMLDEV()
Return

User Function QEMLD10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_QEMLDEV()
Return
