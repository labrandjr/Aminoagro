#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SAPRREC  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 09/06/2023      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exportação de Dados - Contas a Receber.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SAPRREC()

Local cPerg := "SAPRREC"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pSapRrec()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pSapRrec  ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 09/06/2023     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pSapRrec()

Local oExcel := FwMsExcel():New()

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_SALDO > 0 "
If mv_par01 == 2
	cQuery += " AND E1_FILIAL = '"+xFilial("SE1")+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECSE1 "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_SALDO > 0 "
If mv_par01 == 2
	cQuery += " AND E1_FILIAL = '"+xFilial("SE1")+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
ProcRegua(nTotSql)
SQL1->(DbGotop())
If !Eof()

	cNomePlan  := "exp_receber"
	cNomeTable := "exp_receber"

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
	oExcel:AddColumn(cNomePlan,cNomeTable,"Codigo CLIENTE SAP",1,1)
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
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Conta Contábil",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Portador",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SE1")
		SE1->(DbGoto(SQL1->RECSE1))

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )

		zMoeTit := IIf(SE1->E1_MOEDA==2,"USD","BRL")
		zNumTit := SE1->(AllTrim(E1_PREFIXO)+"-"+AllTrim(E1_NUM)+"-"+AllTrim(E1_PARCELA))
		zTipTit := IIf(AllTrim(SE1->E1_TIPO)=="NCC","11",IIf(AllTrim(SE1->E1_TIPO)=="RA","19","01"))
		zAdiant := IIf(AllTrim(SE1->E1_TIPO)=="RA","A","")
		zSldTit := u_SalLiqSe1()

		zCodFil := "0026" // "0001"
		If SE1->E1_FILIAL == "0102"
			zCodFil := "0033" // "0002"
		ElseIf SE1->E1_FILIAL == "0106"
			zCodFil := "0034" // "0004"
		ElseIf SE1->E1_FILIAL == "0107"
			zCodFil := "0023" // "0003"
		ElseIf SE1->E1_FILIAL == "0109"
			zCodFil := "0027" // "0005"
		ElseIf SE1->E1_FILIAL == "0110"
			zCodFil := "0035" // "0006"
		Endif

		zHisTit := IIf(!Empty(SE1->E1_HIST), SE1->E1_HIST, AllTrim(SE1->E1_NUM)+"-"+SA1->A1_NOME)
		zCodLan := IIf(AllTrim(SE1->E1_TIPO)=="NCC","40",IIf(AllTrim(SE1->E1_TIPO)=="RA","40","50"))
		
		oExcel:AddRow(cNomePlan, cNomeTable, {StoD("20230801"), "CS", "0100", SE1->E1_EMISSAO, Month(SE1->E1_EMISSAO), zMoeTit, zNumTit,;
											"CARGA DMA - CR", zTipTit, "C", SA1->A1_CGC, zAdiant, zSldTit, zCodFil, SE1->E1_VENCREA,;
											"999", "CARGA DMA - CR", zHisTit, "", zCodLan, "", "900000040", SE1->E1_TIPO, SA1->A1_COD,;
											SA1->A1_NOME, SA1->A1_CONTA, SE1->E1_PORTADO })
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "exp_receber"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
