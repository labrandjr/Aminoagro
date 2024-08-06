#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SAPRPAG  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 09/06/2023      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exportação de Dados - Contas a Pagar.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SAPRPAG()

Local cPerg := "SAPRPAG"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pSapRpag()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pSapRpag  ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 09/06/2023     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pSapRpag()

Local oExcel := FwMsExcel():New()

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_SALDO > 0 "
If mv_par01 == 2
	cQuery += " AND E2_FILIAL = '"+xFilial("SE2")+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECSE2 "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_SALDO > 0 "
If mv_par01 == 2
	cQuery += " AND E2_FILIAL = '"+xFilial("SE2")+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
ProcRegua(nTotSql)
SQL1->(DbGotop())
If !Eof()

	cNomePlan  := "exp_pagar"
	cNomeTable := "exp_pagar"

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
	oExcel:AddColumn(cNomePlan,cNomeTable,"Codigo FORNECEDOR SAP",1,1)
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
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Fornecedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Conta Contábil",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SE2")
		SE2->(DbGoto(SQL1->RECSE2))

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA )

		zMoeTit := IIf(SE2->E2_MOEDA==2,"USD","BRL")
		zNumTit := SE2->(AllTrim(E2_PREFIXO)+"-"+AllTrim(E2_NUM)+"-"+AllTrim(E2_PARCELA))
		zTipTit := IIf(AllTrim(SE2->E2_TIPO)=="NDF","21",IIf(AllTrim(SE2->E2_TIPO)=="PA","29","31"))
		zAdiant := IIf(AllTrim(SE2->E2_TIPO)=="PA","A","")

		zCodFil := "0026" // "0001"
		If SE2->E2_FILIAL == "0102"
			zCodFil := "0033" // "0002"
		ElseIf SE2->E2_FILIAL == "0106"
			zCodFil := "0034" // "0004"
		ElseIf SE2->E2_FILIAL == "0107"
			zCodFil := "0023" // "0003"
		ElseIf SE2->E2_FILIAL == "0109"
			zCodFil := "0027" // "0005"
		ElseIf SE2->E2_FILIAL == "0110"
			zCodFil := "0035" // "0006"
		Endif

		zHisTit := IIf(!Empty(SE2->E2_HIST), SE2->E2_HIST, AllTrim(SE2->E2_NUM)+"-"+SA2->A2_NOME)
		zCodLan := IIf(AllTrim(SE2->E2_TIPO)=="NDF","50",IIf(AllTrim(SE2->E2_TIPO)=="PA","50","40"))
		
		oExcel:AddRow(cNomePlan, cNomeTable, {StoD("20230801"), "CS", "0100", SE2->E2_EMISSAO, Month(SE2->E2_EMISSAO), zMoeTit, zNumTit,;
											"CARGA DMA - CP", zTipTit, "F", SA2->A2_CGC, zAdiant, SE2->E2_SALDO, zCodFil, SE2->E2_VENCREA,;
											"999", "CARGA DMA - CP", zHisTit, "", zCodLan, "", "900000040", SA2->A2_COD, SA2->A2_NOME, SA2->A2_CONTA })
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "exp_pagar"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
