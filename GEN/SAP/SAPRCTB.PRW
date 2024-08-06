#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SAPRCTB  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/06/2023      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exportação de Dados - Contabilidade Gerencial.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SAPRCTB()

Local cPerg := "SAPRCTB"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pSapRctb()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pSapRctb  ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 19/06/2023     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pSapRctb()

Local oExcel := FwMsExcel():New()

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("CT1")
cQuery += " WHERE CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery += " AND CT1_BLOQ <> '1' "
cQuery += " AND CT1_CLASSE = '2' "
If !Empty(mv_par01)
	cQuery += " AND SUBSTR(CT1_CONTA,1,1) = '"+mv_par01+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECCT1 "
cQuery += " FROM "+RetSqlName("CT1")
cQuery += " WHERE CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery += " AND CT1_BLOQ <> '1' "
cQuery += " AND CT1_CLASSE = '2' "
If !Empty(mv_par01)
	cQuery += " AND SUBSTR(CT1_CONTA,1,1) = '"+mv_par01+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY CT1_FILIAL, CT1_CONTA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
ProcRegua(nTotSql)
SQL1->(DbGotop())
If !Eof()

	cNomePlan  := "exp_saldoctb"
	cNomeTable := "exp_saldoctb"

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"BUDAT",1,4) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"BLART",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BUKRS",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BLDAT",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"MONAT",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"WAERS",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"XBLNR",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BKTXT",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"NEWBS",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Lançamento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Codigo Conta",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"NEWUM",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"WRBTR",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BUPLA",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"ZFBDT",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"PRCTR",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"ZUONR",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"SGTXT",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"KOSTL",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"NEWBS",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Rz.Especial2",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Conta Contabil Contrapartida",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("CT1")
		CT1->(DbGoto(SQL1->RECCT1))

		zCodFil := "0026" // "0001"
		If CT1->CT1_FILIAL == "0102"
			zCodFil := "0033" // "0002"
		ElseIf CT1->CT1_FILIAL == "0106"
			zCodFil := "0034" // "0004"
		ElseIf CT1->CT1_FILIAL == "0107"
			zCodFil := "0023" // "0003"
		ElseIf CT1->CT1_FILIAL == "0109"
			zCodFil := "0027" // "0005"
		ElseIf CT1->CT1_FILIAL == "0110"
			zCodFil := "0035" // "0006"
		Endif
		xSldAtu := SaldoCT7Fil(CT1->CT1_CONTA, dDatabase, "01", "1", "SAPRCTB")

		oExcel:AddRow(cNomePlan, cNomeTable, {dDatabase, "CS", "0100", dDatabase, Month(dDatabase), "BRL", "CARGA GL DMA",;
											"CARGA GL DMA", "40", "R", CT1->CT1_CONTA, "", xSldAtu[1], zCodFil, "", "999",;
											"CARGA GL DMA", "CARGA GL DMA", "", "50", "", "900000040" })
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "exp_saldoctb"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL1->(DbCloseArea())
	
Return
