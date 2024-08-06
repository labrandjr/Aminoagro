#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FINR007  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 06/09/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Conferência dos flags de contabilização.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FINR007()

Local cPerg := "FINR07"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFinR07()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFinR07   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 06/09/2019     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFinR07()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local lExport  := .F.
Local nForFilial

aFilsCalc := MatFilCalc( mv_par08 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

If mv_par03 == 1 // Compras = Sim

	ProcRegua(2)
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SF1")+" SF1, "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SB1")+" SB1 "
	cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
	cQuery += " AND F1_FILIAL = D1_FILIAL "
	cQuery += " AND F1_DOC = D1_DOC "
	cQuery += " AND F1_SERIE = D1_SERIE "
	cQuery += " AND F1_FORNECE = D1_FORNECE "
	cQuery += " AND F1_LOJA = D1_LOJA "
	cQuery += " AND D1_COD = B1_COD "
	cQuery += " AND D1_FILIAL = F4_FILIAL "
	cQuery += " AND D1_TES = F4_CODIGO "
	cQuery += " AND F1_DTLANC = ' ' "
	cQuery += " AND D1_TES NOT IN('071','072','132','190','228','082','083','264','265','266','212','048') " // 071,072,132,190,228 (TES TROCA MV_XTESTRC) | 082,083,212,264,265,266 (DEV.BONIFICAÇÃO MV_XTESDVB) | 048 (RETORNO DE BEM OU MERCADORIA REMETIDO PARA FEIRA OU EXPOSIÇÃO SEM INCIDÊNCIA DE ICMS)
	cQuery += " AND F4_PODER3 <> 'D' "
	cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND ((F1_DUPL <> ' ') OR (F1_TIPO <> 'N')) "
	cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	nTotSql := SQL->SOMA
	SQL->(DbCloseArea())
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT F1_FILIAL FILIAL, F1_DTDIGIT DIGIT, F1_EMISSAO EMISSAO, F1_DOC DOC, F1_SERIE SERIE, F1_TIPO TIPO, F1_FORNECE FORNECE, "
	cQuery += " F1_LOJA LOJA, F1_DUPL DUPL, D1_ITEM ITEM, D1_COD PRODUTO, B1_DESC DESCRI, D1_QUANT QUANT, "
	cQuery += " D1_VUNIT VUNIT, D1_TOTAL TOTAL, D1_TES TES, D1_CUSTO CUS_CALC, D1_XCUSTO CUS_DIG, F4_ESTOQUE ESTOQUE, "
	cQuery += " F4_DUPLIC DUPLIC, F4_PODER3 PODER3, F4_TEXTO TEXTO, F4_FINALID FINALID "
	cQuery += " FROM "+RetSqlName("SF1")+" SF1, "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SB1")+" SB1 "
	cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
	cQuery += " AND F1_FILIAL = D1_FILIAL "
	cQuery += " AND F1_DOC = D1_DOC "
	cQuery += " AND F1_SERIE = D1_SERIE "
	cQuery += " AND F1_FORNECE = D1_FORNECE "
	cQuery += " AND F1_LOJA = D1_LOJA "
	cQuery += " AND D1_COD = B1_COD "
	cQuery += " AND D1_FILIAL = F4_FILIAL "
	cQuery += " AND D1_TES = F4_CODIGO "
	cQuery += " AND F1_DTLANC = ' ' "
	cQuery += " AND D1_TES NOT IN('071','072','132','190','228','082','083','264','265','266','212','048') " // 071,072,132,190,228 (TES TROCA MV_XTESTRC) | 082,083,212,264,265,266 (DEV.BONIFICAÇÃO MV_XTESDVB) | 048 (RETORNO DE BEM OU MERCADORIA REMETIDO PARA FEIRA OU EXPOSIÇÃO SEM INCIDÊNCIA DE ICMS)
	cQuery += " AND F4_PODER3 <> 'D' "
	cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND ((F1_DUPL <> ' ') OR (F1_TIPO <> 'N')) "
	cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY FILIAL, DIGIT, DOC, SERIE, ITEM "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	DbSelectArea("SQL")
	ProcRegua(nTotSql)
	SQL->(DbGotop())
	If !Eof()
	
		cNomePlan  := "Compras"
		cNomeTable := "Compras"
		cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Digitação",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Nf",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Título",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Item Nf",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Unitário",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Total",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Custo calculado",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Custo digitado",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"TES",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Estoque",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Duplicata",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Poder 3o.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Texto",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Finalidade",1,1)
	
		While !Eof()
		
			IncProc("Compras...")
	
			lExport := .T.
	
			If SQL->TIPO $("B,D")
				cRazao := Posicione("SA1",1,xFilial("SA1")+SQL->(FORNECE+LOJA),"A1_NOME")
			Else
				cRazao := Posicione("SA2",1,xFilial("SA2")+SQL->(FORNECE+LOJA),"A2_NOME")
			Endif
		
			oExcel:AddRow(cNomePlan, cNomeTable, {SQL->FILIAL, StoD(SQL->DIGIT), SQL->DOC, SQL->SERIE, SQL->TIPO, SQL->FORNECE, cRazao, StoD(SQL->EMISSAO),;
												  SQL->DUPL, SQL->ITEM, SQL->PRODUTO, SQL->DESCRI, SQL->QUANT, SQL->VUNIT, SQL->TOTAL, SQL->CUS_CALC,;
												  SQL->CUS_DIG, SQL->TES, SQL->ESTOQUE, SQL->DUPLIC, SQL->PODER3, SQL->TEXTO, SQL->FINALID })
	
			DbSelectArea("SQL")
			SQL->(DbSkip())
	
		Enddo
	
	Else
	
		MsgInfo("Compras: não há registros sem flag.")
	
	Endif
	SQL->(DbCloseArea())

Endif

If mv_par04 == 1 // Faturamento = Sim

	ProcRegua(2)
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SF2")
	cQuery += " WHERE F2_FILIAL IN("+zFiliais+") "
	cQuery += " AND F2_DTLANC = ' ' "
	cQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND F2_DUPL <> ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	nTotSql := SQL->SOMA
	SQL->(DbCloseArea())
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT F2_FILIAL FILIAL, F2_EMISSAO EMISSAO, F2_DOC DOC, F2_SERIE SERIE, F2_TIPO TIPO, F2_CLIENTE CLIENTE, "
	cQuery += " F2_LOJA LOJA, F2_DUPL DUPL, F2_VALFAT VALFAT "
	cQuery += " FROM "+RetSqlName("SF2")
	cQuery += " WHERE F2_FILIAL IN("+zFiliais+") "
	cQuery += " AND F2_DTLANC = ' ' "
	cQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND F2_DUPL <> ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY FILIAL, EMISSAO, DOC, SERIE "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	DbSelectArea("SQL")
	ProcRegua(nTotSql)
	SQL->(DbGotop())
	If !Eof()
	
		cNomePlan  := "Faturamento"
		cNomeTable := "Faturamento"
		cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Nf",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Título",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	
		While !Eof()
		
			IncProc("Faturamento...")
	
			lExport := .T.
	
			If SQL->TIPO $("B,D")
				cRazao := Posicione("SA2",1,xFilial("SA2")+SQL->(CLIENTE+LOJA),"A2_NOME")
			Else
				cRazao := Posicione("SA1",1,xFilial("SA1")+SQL->(CLIENTE+LOJA),"A1_NOME")
			Endif
		
			oExcel:AddRow(cNomePlan, cNomeTable, {SQL->FILIAL, StoD(SQL->EMISSAO), SQL->DOC, SQL->SERIE,;
												  SQL->TIPO, SQL->CLIENTE, cRazao, SQL->DUPL, SQL->VALFAT })
	
			DbSelectArea("SQL")
			SQL->(DbSkip())
	
		Enddo
	
	Else
	
		MsgInfo("Faturamento: não há registros sem flag.")
	
	Endif
	SQL->(DbCloseArea())

Endif

If mv_par05 == 1 // Contas a Receber = Sim

	ProcRegua(2)
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
	cQuery += " AND E1_LA = ' ' "
	cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND E1_FILIAL <> '0105' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	nTotSql := SQL->SOMA
	SQL->(DbCloseArea())
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT E1_FILIAL FILIAL, E1_EMISSAO EMISSAO, E1_CLIENTE CLIENTE, E1_LOJA LOJA, E1_PREFIXO PREFIXO, E1_NUM NUM, "
	cQuery += " E1_PARCELA PARCELA, E1_TIPO TIPO, E1_VENCTO VENCTO, E1_VENCREA VENCREA, E1_VALOR VALOR, E1_HIST HIST "
	cQuery += " FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
	cQuery += " AND E1_LA = ' ' "
	cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND E1_FILIAL <> '0105' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY FILIAL, EMISSAO, CLIENTE, PREFIXO, NUM, PARCELA "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	DbSelectArea("SQL")
	ProcRegua(nTotSql)
	SQL->(DbGotop())
	If !Eof()
	
		cNomePlan  := "Contas a Receber"
		cNomeTable := "Contas a Receber"
		cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.Real",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Histórico",1,1)
	
		While !Eof()
		
			IncProc("Contas a Receber...")
	
			lExport := .T.
	
			cRazao := Posicione("SA1",1,xFilial("SA1")+SQL->(CLIENTE+LOJA),"A1_NOME")
		
			oExcel:AddRow(cNomePlan, cNomeTable, {SQL->FILIAL, StoD(SQL->EMISSAO), SQL->CLIENTE, cRazao, SQL->PREFIXO, SQL->NUM,;
												  SQL->PARCELA, SQL->TIPO, StoD(SQL->VENCTO), StoD(SQL->VENCREA), SQL->VALOR, SQL->HIST })
	
			DbSelectArea("SQL")
			SQL->(DbSkip())
	
		Enddo
	
	Else
	
		MsgInfo("Contas a Receber: não há registros sem flag.")
	
	Endif
	SQL->(DbCloseArea())

Endif

If mv_par06 == 1 // Contas a Pagar = Sim

	ProcRegua(2)
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
	cQuery += " AND E2_EMIS1 BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND E2_TIPO NOT IN('PR','NDF') "
	cQuery += " AND E2_ORIGEM <> 'FINA290M' "
	cQuery += " AND E2_RATEIO <> 'S' "
	cQuery += " AND E2_FORNECE <> 'UNIAO' "
	cQuery += " AND E2_PREFIXO <> 'EMP' "
	cQuery += " AND E2_LA = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	nTotSql := SQL->SOMA
	SQL->(DbCloseArea())
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT E2_FILIAL FILIAL, E2_EMIS1 EMISSAO, E2_FORNECE FORNECE, E2_LOJA LOJA, E2_PREFIXO PREFIXO, E2_NUM NUM, "
	cQuery += " E2_PARCELA PARCELA, E2_TIPO TIPO, E2_VENCTO VENCTO, E2_VENCREA VENCREA, E2_VALOR VALOR, E2_HIST HIST "
	cQuery += " FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
	cQuery += " AND E2_EMIS1 BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND E2_TIPO NOT IN('PR','NDF') "
	cQuery += " AND E2_ORIGEM <> 'FINA290M' "
	cQuery += " AND E2_RATEIO <> 'S' "
	cQuery += " AND E2_FORNECE <> 'UNIAO' "
	cQuery += " AND E2_PREFIXO <> 'EMP' "
	cQuery += " AND E2_LA = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY FILIAL, EMISSAO, FORNECE, PREFIXO, NUM, PARCELA "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	DbSelectArea("SQL")
	ProcRegua(nTotSql)
	SQL->(DbGotop())
	If !Eof()
	
		cNomePlan  := "Contas a Pagar"
		cNomeTable := "Contas a Pagar"
		cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.Real",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Histórico",1,1)
	
		While !Eof()
		
			IncProc("Contas a Pagar...")
	
			lExport := .T.
	
			cRazao := Posicione("SA2",1,xFilial("SA2")+SQL->(FORNECE+LOJA),"A2_NOME")
		
			oExcel:AddRow(cNomePlan, cNomeTable, {SQL->FILIAL, StoD(SQL->EMISSAO), SQL->FORNECE, cRazao, SQL->PREFIXO, SQL->NUM,;
												  SQL->PARCELA, SQL->TIPO, StoD(SQL->VENCTO), StoD(SQL->VENCREA), SQL->VALOR, SQL->HIST })
	
			DbSelectArea("SQL")
			SQL->(DbSkip())
	
		Enddo
	
	Else
	
		MsgInfo("Contas a Pagar: não há registros sem flag.")
	
	Endif
	SQL->(DbCloseArea())

Endif

If mv_par07 == 1 // Mov.Bancária = Sim

	ProcRegua(2)
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL IN("+zFiliais+") "
	cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND E5_TIPODOC <> 'ES' "
	cQuery += " AND E5_SITUACA = ' ' "
	cQuery += " AND E5_FILIAL <> '0105' "
	cQuery += " AND E5_MOTBX NOT IN('LIQ','FAT') "
	cQuery += " AND E5_LA = ' ' "
	cQuery += " AND E5_TIPODOC NOT IN('JR','DC','MT') "
	cQuery += " AND (E5_TIPO||E5_RECPAG||E5_TIPODOC||E5_MOTBX) <> 'PA PPANOR' " // Inclusão de PA
	cQuery += " AND (E5_RECPAG||E5_TIPODOC||E5_MOTBX) <> 'PCPCMP' " // Compensação à Pagar - partida do PA
	cQuery += " AND (E5_RECPAG||E5_TIPODOC) <> 'PCM' " // Correção monetária à Pagar
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	nTotSql := SQL->SOMA
	SQL->(DbCloseArea())
	
	IncProc("Selecionando registros...")
	cQuery := " SELECT E5_FILIAL FILIAL, E5_DATA DATA, E5_BANCO BANCO, E5_AGENCIA AGENCIA, E5_CONTA CONTA, E5_VALOR VALOR, E5_BENEF BENEF, "
	cQuery += " E5_PREFIXO PREFIXO, E5_NUMERO NUMERO, E5_PARCELA PARCELA, E5_TIPO TIPO, E5_HISTOR HISTOR, E5_MOEDA MOEDA, E5_TIPODOC TIPODOC, "
	cQuery += " E5_MOTBX MOTBX, E5_RECPAG RECPAG, E5_CLIENTE CLIENTE, E5_FORNECE FORNECE, E5_LOJA LOJA, E5_DTDIGIT DTDIGIT, E5_SEQ SEQ, "
	cQuery += " E5_DTDISPO DTDISPO, E5_VLJUROS VLJUROS, E5_VLMULTA VLMULTA, E5_VLDESCO VLDESCO, E5_ARQCNAB ARQCNAB "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL IN("+zFiliais+") "
	cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND E5_TIPODOC <> 'ES' "
	cQuery += " AND E5_SITUACA = ' ' "
	cQuery += " AND E5_FILIAL <> '0105' "
	cQuery += " AND E5_MOTBX NOT IN('LIQ','FAT') "
	cQuery += " AND E5_LA = ' ' "
	cQuery += " AND E5_TIPODOC NOT IN('JR','DC','MT') "
	cQuery += " AND (E5_TIPO||E5_RECPAG||E5_TIPODOC||E5_MOTBX) <> 'PA PPANOR' " // Inclusão de PA
	cQuery += " AND (E5_RECPAG||E5_TIPODOC||E5_MOTBX) <> 'PCPCMP' " // Compensação à Pagar - partida do PA
	cQuery += " AND (E5_RECPAG||E5_TIPODOC) <> 'PCM' " // Correção monetária à Pagar
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY FILIAL, DATA, BANCO, AGENCIA, CONTA, BENEF, PREFIXO, NUMERO, PARCELA "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	DbSelectArea("SQL")
	ProcRegua(nTotSql)
	SQL->(DbGotop())
	If !Eof()
	
		cNomePlan  := "Mov.Bancária"
		cNomeTable := "Mov.Bancária"
		cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Data",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Banco",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Agência",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Conta",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Benef.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Histórico",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Moeda",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Doc.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Motivo Bx",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Rec|Pag",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Digitação",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Disponibilidade",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Seq.Bx.",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Juros",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Multa",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Desconto",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Arq.Cnab",1,1)
	
		While !Eof()
		
			IncProc("Mov.Bancária...")
	
			lExport := .T.
	
			oExcel:AddRow(cNomePlan, cNomeTable, {SQL->FILIAL, StoD(SQL->DATA), SQL->BANCO, SQL->AGENCIA, SQL->CONTA, SQL->VALOR,;
												  SQL->BENEF, SQL->PREFIXO, SQL->NUMERO, SQL->PARCELA, SQL->TIPO, SQL->HISTOR,;
												  SQL->MOEDA, SQL->TIPODOC, SQL->MOTBX, SQL->RECPAG, SQL->CLIENTE, SQL->FORNECE,;
												  StoD(SQL->DTDIGIT), StoD(SQL->DTDISPO), SQL->SEQ, SQL->VLJUROS, SQL->VLMULTA,;
												  SQL->VLDESCO, SQL->ARQCNAB })

			DbSelectArea("SQL")
			SQL->(DbSkip())
	
		Enddo
	
	Else
	
		MsgInfo("Mov.Bancária: não há registros sem flag.")
	
	Endif
	SQL->(DbCloseArea())

Endif

If lExport

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "Flag_Ctb-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo.")

Endif
	
Return
