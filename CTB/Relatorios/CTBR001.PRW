#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CTBR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 22/05/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lançamentos Contábeis.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CTBR001()

Local cPerg := "AMNCTBR01"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pCtbR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pCtbR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 22/05/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pCtbR01()

Local oExcel    := FwMsExcel():New()
Local zFiliais  := ""
Local nForFilial

aFilsCalc := MatFilCalc( mv_par03 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("CT2")
cQuery += " WHERE CT2_FILIAL IN("+zFiliais+") "
cQuery += " AND CT2_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND CT2_TPSALD = '"+mv_par04+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("CT2")
cQuery += " WHERE CT2_FILIAL IN("+zFiliais+") "
cQuery += " AND CT2_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND CT2_TPSALD = '"+mv_par04+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "CT2_CTBR01"
	cNomeTable := "Lançamentos Contábeis"
	
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Lote",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Linha",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CT Débito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CT Crédito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Histórico",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CC Débito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CC Crédito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BU Débito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BU Crédito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CV Débito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CV Crédito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Moeda",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Saldo",1,1)
//	oExcel:AddColumn(cNomePlan,cNomeTable,"Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Manual",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Usuário",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		zFilial := SQL->CT2_FILIAL
		zDataLc := StoD(SQL->CT2_DATA)		
		zLote   := SQL->CT2_LOTE
		zDocum  := SQL->CT2_DOC
		zLinha  := SQL->CT2_LINHA
		zDebito := SQL->CT2_DEBITO
		zCredit := SQL->CT2_CREDIT
		zValor  := SQL->CT2_VALOR
		zCCD    := SQL->CT2_CCD
		zCCC    := SQL->CT2_CCC
		zItemD  := SQL->CT2_ITEMD
		zItemC  := SQL->CT2_ITEMC
		zClVlD  := SQL->CT2_CLVLDB
		zClVlC  := SQL->CT2_CLVLCR
		zMoeda  := Posicione("CTO",1,SQL->(CT2_FILIAL+CT2_MOEDLC),"CTO_DESC")
		zTpSald := Posicione("SX5",1,xFilial("SX5")+"SL"+PadR(SQL->CT2_TPSALD,6),"X5_DESCRI")
//		zOrigem := SQL->CT2_ORIGEM
		zManual := IIf(SQL->CT2_MANUAL=="1","Sim","Não")
		zHistor := AllTrim(SQL->CT2_HIST)

		DbSelectArea("CT2")
		CT2->(DbGoto(SQL->R_E_C_N_O_))
		zUserLg := FWLeUserlg("CT2_USERGI")

		DbSelectArea("SQL")
		SQL->(DbSkip())

		While .T.
			If SQL->CT2_DC == "4"
				zHistor += " "+AllTrim(SQL->CT2_HIST)
				SQL->(DbSkip())
			Else
				Exit
			Endif
		Enddo

		oExcel:AddRow(cNomePlan, cNomeTable, {zFilial, zDataLc, zLote, zDocum, zLinha, zDebito, zCredit, zValor, zHistor, zCCD, zCCC,;
		   									  zItemD, zItemC, zClVlD, zClVlC, zMoeda, zTpSald, /*zOrigem,*/ zManual, zUserLg })

		DbSelectArea("SQL")
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "CT2_CTBR01-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())
	
Return
