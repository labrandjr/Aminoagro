#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COMR005  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 22/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Créditos Pis/Cofins.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COMR005()

Local cPerg := "COMR02"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pComR05()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pComR05   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 22/05/2019     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pComR05()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local nForFilial

aFilsCalc := MatFilCalc( mv_par06 == 1 )
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
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND D1_FORNECE = '"+mv_par03+"' "
Endif
If !Empty(mv_par04)
	cQuery += " AND D1_COD = '"+mv_par04+"' "
Endif
cQuery += " AND D1_BASIMP5 > 0 "
cQuery += " AND D1_BASIMP6 > 0 "
If mv_par05 == 1 // Alíquota Básica
	cQuery += " AND D1_VALIMP5 > 0 "
	cQuery += " AND D1_VALIMP6 > 0 "
ElseIf mv_par05 == 2 // Alíquota Zero
	cQuery += " AND D1_VALIMP5 = 0 "
	cQuery += " AND D1_VALIMP6 = 0 "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ RECSD1 "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND D1_FORNECE = '"+mv_par03+"' "
Endif
If !Empty(mv_par04)
	cQuery += " AND D1_COD = '"+mv_par04+"' "
Endif
cQuery += " AND D1_BASIMP5 > 0 "
cQuery += " AND D1_BASIMP6 > 0 "
If mv_par05 == 1 // Alíquota Básica
	cQuery += " AND D1_VALIMP5 > 0 "
	cQuery += " AND D1_VALIMP6 > 0 "
ElseIf mv_par05 == 2 // Alíquota Zero
	cQuery += " AND D1_VALIMP5 = 0 "
	cQuery += " AND D1_VALIMP6 = 0 "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D1_FILIAL, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
ProcRegua(nTotSql)
SQL1->(DbGotop())
If !Eof()

	cNomePlan  := "SD1_COMR05"
	cNomeTable := "Relação de Crédito Pis/Cofins - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Digitação",1,4)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1) 

	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"CFOP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"TES",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UM",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.BC Créd.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.BC Créd.",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"CST Pis",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Base Cálc.Pis",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Alíq.Pis",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Pis",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"CST Cofins",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Base Cálc.Cofins",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Alíq.Cofins",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Cofins",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SD1")
		SD1->(DbGoto(SQL1->RECSD1))
		
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SD1->D1_COD )

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( SD1->D1_FILIAL + SD1->D1_TES )

		zLocal   := FWFilialName(cEmpAnt,SD1->D1_FILIAL,1)
		aCodiBcc := FWGetSx5("MZ", PadR(SF4->F4_CODBCC,6) )
		zDescBcc := ""
		If Len(aCodiBcc) > 0
			zDescBcc := AllTrim(aCodiBcc[1][4])
		Endif

		oExcel:AddRow(cNomePlan, cNomeTable, {SD1->D1_FILIAL, zLocal, SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SD1->D1_DOC, SD1->D1_SERIE,;
											  SD1->D1_FORNECE, SA2->A2_NOME, SD1->D1_COD, SB1->B1_DESC, SD1->D1_CF, SD1->D1_TES,;
											  SD1->D1_QUANT, SD1->D1_UM, SD1->D1_TOTAL, SF4->F4_CODBCC, zDescBcc, SF4->F4_CSTPIS,;
											  SD1->D1_BASIMP6, SD1->D1_ALQIMP6, SD1->D1_VALIMP6, SF4->F4_CSTCOF, SD1->D1_BASIMP5,;
											  SD1->D1_ALQIMP5, SD1->D1_VALIMP5 })

		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD1_COMR05-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
