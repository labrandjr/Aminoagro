#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR011  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 09/06/2021      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório da polícia federal.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR011()

Local cPerg := "AMNR11"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR11()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR11   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 09/06/2021     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR11()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local lExport  := .F.
Local nForFilial
Local _it
Local _est

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

// Internacionais
ProcRegua(2)
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SF1")+" SF1, "
cQuery += RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
cQuery += " AND F1_FILIAL = D1_FILIAL "
cQuery += " AND F1_DOC = D1_DOC "
cQuery += " AND F1_SERIE = D1_SERIE "
cQuery += " AND F1_FORNECE = D1_FORNECE "
cQuery += " AND F1_LOJA = D1_LOJA "
cQuery += " AND D1_COD = B1_COD "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par04)
	cQuery += " AND F1_FORNECE = '"+mv_par04+"' "
Endif
cQuery += " AND F1_TIPO = 'N' "
cQuery += " AND F1_EST = 'EX' "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_ESTOQUE = 'S' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT F1_FILIAL FILIAL, F1_DOC DOC, F1_SERIE SERIE, F1_FORNECE FORNECE, F1_LOJA LOJA, D1_COD COD, D1_ITEM ITEM "
cQuery += " FROM "+RetSqlName("SF1")+" SF1, "
cQuery += RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
cQuery += " AND F1_FILIAL = D1_FILIAL "
cQuery += " AND F1_DOC = D1_DOC "
cQuery += " AND F1_SERIE = D1_SERIE "
cQuery += " AND F1_FORNECE = D1_FORNECE "
cQuery += " AND F1_LOJA = D1_LOJA "
cQuery += " AND D1_COD = B1_COD "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par04)
	cQuery += " AND F1_FORNECE = '"+mv_par04+"' "
Endif
cQuery += " AND F1_TIPO = 'N' "
cQuery += " AND F1_EST = 'EX' "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_ESTOQUE = 'S' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, DOC, SERIE, FORNECE, LOJA, COD, ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "Internacionais"
	cNomeTable := "Internacionais"
	cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Código",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"País",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número LI",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Restrição",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Conhecim.",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número DI",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data DI",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nf Transporte",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cnpj Transp.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão Transp.",1,1)

	DbSelectArea("SQL")
	While !Eof()
	
		IncProc("Internacionais...")

		lExport := .T.

		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL + DOC + SERIE + FORNECE + LOJA) )
		cNumLI := SF1->F1_ZZLI // Número LI
		dDtRes := SF1->F1_ZZDREMB // Data restrição do embarque
		dDtCon := SF1->F1_ZZDCEMB // Data do conhecimento

		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL + DOC + SERIE + FORNECE + LOJA + COD + ITEM) )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SD1->D1_COD )

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SD1->(D1_FORNECE + D1_LOJA) )

		DbSelectArea("SYA")
		DbSetOrder(1)
		DbSeek( xFilial("SYA") + SA2->A2_PAIS )

		cNumDI := "" // Número DI
		dDatDI := CtoD("") // Data DI
		DbSelectArea("CD5")
		DbSetOrder(4)
		If DbSeek( SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM) )
			cNumDI := CD5->CD5_NDI // Número DI
			dDatDI := CD5->CD5_DTDI // Data DI
		Endif

		aItTran := {}
		cNfeTra := "SEMTRANSP"
		dEmiTra := CtoD("")
		nQtdTra := SD1->D1_QUANT
		cCgcTra := ""
		cNomTra := ""
		DbSelectArea("SD7")
		DbSetOrder(4)
		If DbSeek( SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_COD) )
			While !Eof() .And. SD7->(D7_FILIAL+D7_DOC+D7_SERIE+D7_PRODUTO) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_COD)
				If SD7->D7_TIPO == 1 .And. Empty(SD7->D7_ESTORNO) .And. !Empty(SD7->D7_XNF)
					cNfeTra := SD7->D7_XNF
					nQtdTra := SD7->D7_QTDE
					DbSelectArea("SF1")
					DbSetOrder(1)
					If DbSeek( SQL->FILIAL + cNfeTra + SQL->SERIE + SQL->FORNECE + SQL->LOJA )
						dEmiTra := SF1->F1_EMISSAO
						cTransp := SF1->F1_TRANSP
						cCgcTra := ""
						cNomTra := ""
						If !Empty(cTransp)
							DbSelectArea("SA4")
							DbSetOrder(1)
							DbSeek( xFilial("SA4") + cTransp )
							cCgcTra := SA4->A4_CGC
							cNomTra := SA4->A4_NOME
						Endif
						AAdd(aItTran,{cNfeTra, dEmiTra, nQtdTra, cCgcTra, cNomTra})
					Endif	
				Endif
				DbSelectArea("SD7")
				SD7->(DbSkip())
			Enddo
		Endif
		If Len(aItTran) == 0
			AAdd(aItTran,{cNfeTra, dEmiTra, nQtdTra, cCgcTra, cNomTra})
		Endif

		For _it := 1 to Len(aItTran)
			cNfeTra := aItTran[_it][1]
			dEmiTra := aItTran[_it][2]
			nQtdTra := aItTran[_it][3]
			cCgcTra := aItTran[_it][4]
			cNomTra := aItTran[_it][5]
			//
			oExcel:AddRow(cNomePlan, cNomeTable, {SD1->D1_FILIAL, SB1->B1_COD, SB1->B1_DESC, SA2->A2_NOME, SYA->YA_DESCR,;
													cNumLI, dDtRes, dDtCon, cNumDI, dDatDI,;
													cNfeTra, dEmiTra, nQtdTra, cCgcTra, cNomTra })
		Next _it

		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo

Endif
SQL->(DbCloseArea())

// Nacionais
IncProc("Selecionando registros...")
cQuery := " SELECT '1COMPRA' OPERACAO, D1_FILIAL FILIAL, B1_COD COD, B1_DESC DESCR, D1_DOC DOC, D1_EMISSAO EMISSAO, A2_CGC CGC, A2_NOME NOME, D1_QUANT QUANT, F1_TRANSP TRANSP "
cQuery += " FROM "+RetSqlName("SF1")+" SF1, "
cQuery += RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA2")+" SA2 "
cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
cQuery += " AND F1_FILIAL = D1_FILIAL "
cQuery += " AND F1_DOC = D1_DOC "
cQuery += " AND F1_SERIE = D1_SERIE "
cQuery += " AND F1_FORNECE = D1_FORNECE "
cQuery += " AND F1_LOJA = D1_LOJA "
cQuery += " AND D1_COD = B1_COD "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND D1_FORNECE = A2_COD "
cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par04)
	cQuery += " AND F1_FORNECE = '"+mv_par04+"' "
Endif
cQuery += " AND F1_TIPO = 'N' "
cQuery += " AND F1_EST <> 'EX' "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_ESTOQUE = 'S' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND F4_PODER3 = 'N' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery += " SELECT '2VENDA' OPERACAO, D2_FILIAL FILIAL, B1_COD COD, B1_DESC DESCR, D2_DOC DOC, D2_EMISSAO EMISSAO, A1_CGC CGC, A1_NOME NOME, D2_QUANT QUANT, F2_TRANSP TRANSP "
cQuery += " FROM "+RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE F2_FILIAL IN("+zFiliais+") "
cQuery += " AND F2_FILIAL = D2_FILIAL "
cQuery += " AND F2_DOC = D2_DOC "
cQuery += " AND F2_SERIE = D2_SERIE "
cQuery += " AND F2_CLIENTE = D2_CLIENTE "
cQuery += " AND F2_LOJA = D2_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND F2_CLIENTE = '"+mv_par03+"' "
Endif
cQuery += " AND F2_TIPO = 'N' "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_ESTOQUE = 'S' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND F4_PODER3 = 'N' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery += " SELECT '3TRFSAI' OPERACAO, D2_FILIAL FILIAL, B1_COD COD, B1_DESC DESCR, D2_DOC DOC, D2_EMISSAO EMISSAO, A1_CGC CGC, A1_NOME NOME, D2_QUANT QUANT, F2_TRANSP TRANSP "
cQuery += " FROM "+RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE F2_FILIAL IN("+zFiliais+") "
cQuery += " AND F2_FILIAL = D2_FILIAL "
cQuery += " AND F2_DOC = D2_DOC "
cQuery += " AND F2_SERIE = D2_SERIE "
cQuery += " AND F2_CLIENTE = D2_CLIENTE "
cQuery += " AND F2_LOJA = D2_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND F2_CLIENTE = '"+mv_par03+"' "
Endif
cQuery += " AND F2_TIPO = 'N' "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_TRANFIL = '1' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery += " SELECT '4TRFENT' OPERACAO, D1_FILIAL FILIAL, B1_COD COD, B1_DESC DESCR, D1_DOC DOC, D1_DTDIGIT EMISSAO, A2_CGC CGC, A2_NOME NOME, D1_QUANT QUANT, F1_TRANSP TRANSP "
cQuery += " FROM "+RetSqlName("SF1")+" SF1, "
cQuery += RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA2")+" SA2 "
cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
cQuery += " AND F1_FILIAL = D1_FILIAL "
cQuery += " AND F1_DOC = D1_DOC "
cQuery += " AND F1_SERIE = D1_SERIE "
cQuery += " AND F1_FORNECE = D1_FORNECE "
cQuery += " AND F1_LOJA = D1_LOJA "
cQuery += " AND D1_COD = B1_COD "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND D1_FORNECE = A2_COD "
cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par04)
	cQuery += " AND F1_FORNECE = '"+mv_par04+"' "
Endif
cQuery += " AND F1_TIPO = 'N' "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_TRANFIL = '1' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery += " SELECT '5REMESSA' OPERACAO, D2_FILIAL FILIAL, B1_COD COD, B1_DESC DESCR, D2_DOC DOC, D2_EMISSAO EMISSAO, A1_CGC CGC, A1_NOME NOME, D2_QUANT QUANT, F2_TRANSP TRANSP "
cQuery += " FROM "+RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE F2_FILIAL IN("+zFiliais+") "
cQuery += " AND F2_FILIAL = D2_FILIAL "
cQuery += " AND F2_DOC = D2_DOC "
cQuery += " AND F2_SERIE = D2_SERIE "
cQuery += " AND F2_CLIENTE = D2_CLIENTE "
cQuery += " AND F2_LOJA = D2_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND F2_CLIENTE = '"+mv_par03+"' "
Endif
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_PODER3 = 'R' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery += " SELECT '6RETORNO' OPERACAO, D1_FILIAL FILIAL, B1_COD COD, B1_DESC DESCR, D1_DOC DOC, D1_DTDIGIT EMISSAO, A2_CGC CGC, A2_NOME NOME, D1_QUANT QUANT, F1_TRANSP TRANSP "
cQuery += " FROM "+RetSqlName("SF1")+" SF1, "
cQuery += RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA2")+" SA2 "
cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
cQuery += " AND F1_FILIAL = D1_FILIAL "
cQuery += " AND F1_DOC = D1_DOC "
cQuery += " AND F1_SERIE = D1_SERIE "
cQuery += " AND F1_FORNECE = D1_FORNECE "
cQuery += " AND F1_LOJA = D1_LOJA "
cQuery += " AND D1_COD = B1_COD "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND D1_FORNECE = A2_COD "
cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par04)
	cQuery += " AND F1_FORNECE = '"+mv_par04+"' "
Endif
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND F4_PODER3 = 'D' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY OPERACAO, FILIAL, COD, NOME, EMISSAO, DOC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "Nacionais"
	cNomeTable := "Nacionais"
	cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Operação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Código",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cnpj",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cnpj Transp.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão Transp.",1,1)

	While !Eof()
	
		IncProc("Nacionais...")

		lExport := .T.

		tCgcTransp := ""
		tNomTransp := ""
		DbSelectArea("SA4")
		DbSetOrder(1)
		If DbSeek( xFilial("SA4") + SQL->TRANSP )
			tCgcTransp := SA4->A4_CGC
			tNomTransp := SA4->A4_NOME
		Endif

		oExcel:AddRow(cNomePlan, cNomeTable, {SQL->OPERACAO, SQL->FILIAL, SQL->COD, SQL->DESCR, SQL->DOC, StoD(SQL->EMISSAO),;
											  SQL->CGC, SQL->NOME, SQL->QUANT, tCgcTransp, tNomTransp })

		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo

Endif
SQL->(DbCloseArea())

// Estoque
cFilBkp := cFilAnt
ProcRegua(4)

IncProc("Selecionando registros...") // Produtos
aEstoq := {}
cQuery := " SELECT B1_COD COD, B1_DESC DESCR "
cQuery += " FROM "+RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
While !Eof()
	AAdd(aEstoq,{SQL->COD, SQL->DESCR, 0, 0, 0})
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

cAnoIni := Substr(DtoS(mv_par01),1,4)
cMesIni := Substr(DtoS(mv_par01),5,2)
dDatIni := StoD(Substr(DtoS(mv_par01),1,6)+"01")-1
nPrxMes := Val(cMesIni)+1
If nPrxMes > 12
	dDatFim := StoD(AllTrim(STR(Val(cAnoIni)+1)) + "0101")-1
Else
	dDatFim := StoD(cAnoIni + StrZero(nPrxMes,2) + "01")-1
Endif
cArmNot := FormatIn(AllTrim(mv_par05),",")

IncProc("Selecionando registros...") // Saldo inicial
cQuery := " SELECT B2_FILIAL FILIAL, B2_COD COD, B2_LOCAL ARMAZ "
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE B2_FILIAL IN("+zFiliais+") "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND B2_LOCAL NOT IN"+cArmNot
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY B2_FILIAL, B2_COD, B2_LOCAL "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
While !Eof()

	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( SQL->(FILIAL + COD + ARMAZ) )
	cFilAnt := SQL->FILIAL

	nQIni := SaldoMov(.T., .F.,,.F., 0, 0, .F., dDatIni, .F.)
	/* Function SaldoMov(lNecessida, lEmpenho, dDataFim, lConsTerc, nQtdEmp, nQtdPrj, lSaldoSemR, dDtRefSld,lConsEmpSA)
	±±³Parametros³ ExpL1 = Flag  que  indica se chamada da funcao ‚ utilizada ³±±
	±±³          ³         para  calculo de Necessidade. Neste caso o Saldo a ³±±
	±±³          ³         Distribuir  serah somado ao Saldo a ser Retornado, ³±±
	±±³          ³         pois  esta  quantidade  jah consta em estoque, soh ³±±
	±±³          ³         nao pode ser utilizada porque ainda nao foi        ³±±
	±±³          ³         distribuida.                                       ³±±
	±±³          ³ ExpL2 = Subtrai o Empenho do Saldo a ser Retornado?        ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S".        ³±±
	±±³          ³ ExpD1 = Somente empenhos ateh esta data serao considerados ³±±
	±±³          ³         no  caso  de  leitura  do SD4 (que eh ativada pelo ³±±
	±±³          ³         parametro MV_CONDEMP na funcao SALDOSB2).          ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S".        ³±±
	±±³          ³ ExpL3 = Soma o [Saldo de Terceiros em nosso Poder] ao      ³±±
	±±³          ³         Saldo a ser Retornado?                             ³±±
	±±³          ³ ExpN1 = Quantidade Empenhada que NAO deve ser considerada  ³±±
	±±³          ³         no Saldo Empenhado a ser Retornado                 ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S" ou "C". ³±±
	±±³          ³ ExpN2 = Quantidade Empenhada de Projetos que NAO deve ser  ³±±
	±±³          ³         considerada no Saldo Empenhado a ser Retornado     ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S".        ³±±
	±±³          ³ ExpL4 = Subtrai a Reserva do Saldo a ser Retornado?        ³±±
	±±³          ³ ExpL5 = Subtrai a Quantidade Prevista no SA a ser Retornado³±±
	±±³          ³         Obs.: Somente funciona se o MV_TPSALDO for "C"     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	*/

	nQTer := SaldoTerc(SB2->B2_COD, SB2->B2_LOCAL,"T", dDatIni,,,,.F.,.F.,.F.,.F.,,.F.)[1]
	/* Function SaldoTerc(cCod,cLocal,cTipo,dDtFech,cLocalAte,lCliFor,cCodAte,lConsTesTerc,lCusFifo,lDocto,lTransito,aLocDeAte,lIdent)
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ SaldoTerc³ Autor ³ Cristina M. Ogura     ³ Data ³ 31.05.95 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Retorna o Saldo do Produto no arquivo SB6                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ ExpA1 := SaldoTerc(ExpC1,ExpC2,ExpC3,ExpD4,ExpC4)          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo da Produto                                  ³±±
	±±³          ³ ExpC2 = Local do Produto                                   ³±±
	±±³          ³ ExpC3 = Tipo de Poder de terceiros (D = De Terceiros,	  ³±±
	±±³          ³                                     T = Em Terceiros)	  ³±±
	±±³          ³ ExpD4 = Data de fechamento                                 ³±±
	±±³          ³ ExpC5 = Local limite do produto                            ³±±
	±±³          ³ ExpL6 = Indica se o saldo deve ser calculado por Cli/Forn. ³±±
	±±³          ³ ExpC7 = Codigo do Produto ate, utilizado para gerar a      ³±±
	±±³          ³         matriz aSaldoProd{}                                ³±±
	±±³          ³ ExpL1 = Indica se considera TES de poder de 3os que nao    ³±±
	±±³          ³ atualiza estoque                                           ³±±
	±±³          ³ ExpL2 = Indica se Custo FIFO                               ³±±
	±±³          ³ ExpL3 = Indica se o saldo deve ser calculado por Documento ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	nPos := aScan(aEstoq, {|x| x[1] == SQL->COD })
	If nPos > 0
		aEstoq[nPos][3] += (nQIni + nQTer)
	Endif

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

IncProc("Selecionando registros...") // Requisições p/ produção
cQuery := " SELECT D3_COD COD, SUM(D3_QUANT) QUANT "
cQuery += " FROM "+RetSqlName("SD3")+" SD3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_COD = B1_COD "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
cQuery += " AND D3_LOCAL NOT IN"+cArmNot
cQuery += " AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY D3_COD "
cQuery += " ORDER BY D3_COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
While !Eof()
	nPos := aScan(aEstoq, {|x| x[1] == SQL->COD })
	If nPos > 0
		aEstoq[nPos][4] := SQL->QUANT
	Endif
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

IncProc("Selecionando registros...") // Saldo final
cQuery := " SELECT B2_FILIAL FILIAL, B2_COD COD, B2_LOCAL ARMAZ "
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE B2_FILIAL IN("+zFiliais+") "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B1_ZPOLFED = 'S' "
cQuery += " AND B2_LOCAL NOT IN"+cArmNot
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY B2_FILIAL, B2_COD, B2_LOCAL "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
While !Eof()

	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( SQL->(FILIAL + COD + ARMAZ) )
	cFilAnt := SQL->FILIAL

	nQFim := SaldoMov(.T., .F.,,.F., 0, 0, .F., dDatFim, .F.)
	/* Function SaldoMov(lNecessida, lEmpenho, dDataFim, lConsTerc, nQtdEmp, nQtdPrj, lSaldoSemR, dDtRefSld,lConsEmpSA)
	±±³Parametros³ ExpL1 = Flag  que  indica se chamada da funcao ‚ utilizada ³±±
	±±³          ³         para  calculo de Necessidade. Neste caso o Saldo a ³±±
	±±³          ³         Distribuir  serah somado ao Saldo a ser Retornado, ³±±
	±±³          ³         pois  esta  quantidade  jah consta em estoque, soh ³±±
	±±³          ³         nao pode ser utilizada porque ainda nao foi        ³±±
	±±³          ³         distribuida.                                       ³±±
	±±³          ³ ExpL2 = Subtrai o Empenho do Saldo a ser Retornado?        ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S".        ³±±
	±±³          ³ ExpD1 = Somente empenhos ateh esta data serao considerados ³±±
	±±³          ³         no  caso  de  leitura  do SD4 (que eh ativada pelo ³±±
	±±³          ³         parametro MV_CONDEMP na funcao SALDOSB2).          ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S".        ³±±
	±±³          ³ ExpL3 = Soma o [Saldo de Terceiros em nosso Poder] ao      ³±±
	±±³          ³         Saldo a ser Retornado?                             ³±±
	±±³          ³ ExpN1 = Quantidade Empenhada que NAO deve ser considerada  ³±±
	±±³          ³         no Saldo Empenhado a ser Retornado                 ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S" ou "C". ³±±
	±±³          ³ ExpN2 = Quantidade Empenhada de Projetos que NAO deve ser  ³±±
	±±³          ³         considerada no Saldo Empenhado a ser Retornado     ³±±
	±±³          ³         Obs.: Soh funciona se o MV_TPSALDO for "S".        ³±±
	±±³          ³ ExpL4 = Subtrai a Reserva do Saldo a ser Retornado?        ³±±
	±±³          ³ ExpL5 = Subtrai a Quantidade Prevista no SA a ser Retornado³±±
	±±³          ³         Obs.: Somente funciona se o MV_TPSALDO for "C"     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	*/

	nQTer := SaldoTerc(SB2->B2_COD, SB2->B2_LOCAL,"T", dDatFim,,,,.F.,.F.,.F.,.F.,,.F.)[1]
	/* Function SaldoTerc(cCod,cLocal,cTipo,dDtFech,cLocalAte,lCliFor,cCodAte,lConsTesTerc,lCusFifo,lDocto,lTransito,aLocDeAte,lIdent)
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ SaldoTerc³ Autor ³ Cristina M. Ogura     ³ Data ³ 31.05.95 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Retorna o Saldo do Produto no arquivo SB6                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ ExpA1 := SaldoTerc(ExpC1,ExpC2,ExpC3,ExpD4,ExpC4)          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo da Produto                                  ³±±
	±±³          ³ ExpC2 = Local do Produto                                   ³±±
	±±³          ³ ExpC3 = Tipo de Poder de terceiros (D = De Terceiros,	  ³±±
	±±³          ³                                     T = Em Terceiros)	  ³±±
	±±³          ³ ExpD4 = Data de fechamento                                 ³±±
	±±³          ³ ExpC5 = Local limite do produto                            ³±±
	±±³          ³ ExpL6 = Indica se o saldo deve ser calculado por Cli/Forn. ³±±
	±±³          ³ ExpC7 = Codigo do Produto ate, utilizado para gerar a      ³±±
	±±³          ³         matriz aSaldoProd{}                                ³±±
	±±³          ³ ExpL1 = Indica se considera TES de poder de 3os que nao    ³±±
	±±³          ³ atualiza estoque                                           ³±±
	±±³          ³ ExpL2 = Indica se Custo FIFO                               ³±±
	±±³          ³ ExpL3 = Indica se o saldo deve ser calculado por Documento ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	nPos := aScan(aEstoq, {|x| x[1] == SQL->COD })
	If nPos > 0
		aEstoq[nPos][5] += (nQFim + nQTer)
	Endif

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())
cFilAnt := cFilBkp

cNomePlan  := "Estoque"
cNomeTable := "Estoque"
cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
oExcel:AddworkSheet(cNomePlan)
oExcel:AddTable(cNomePlan,cNomeTable)

oExcel:AddColumn(cNomePlan,cNomeTable,"Código",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Saldo Inicial",3,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Req.Produção",3,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Saldo Final",3,1)

ProcRegua(Len(aEstoq))
For _est := 1 to Len(aEstoq)
	IncProc("Estoque...")
	lExport := .T.
	oExcel:AddRow(cNomePlan, cNomeTable, { aEstoq[_est][1], aEstoq[_est][2], aEstoq[_est][3], aEstoq[_est][4], aEstoq[_est][5] })
Next _est

If lExport

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "Report_PF-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo.")

Endif
	
Return
