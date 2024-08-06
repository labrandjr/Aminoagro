#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA330D1  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 24/11/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualiza custo de entrada para NF inserida em L.Fiscais.   ¦¦¦
¦¦¦          ¦ * Utilizado quando é devolver esta NF em Faturamento.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA330D1()

Local aArea   := GetArea()
Local lGrava  := .F.
Local nXCust  := 0
Local cTesTrc := AllTrim(GetMv("MV_XTESTRC")) // TES para Troca

// Exceções
lExcecao := .F.
If SD1->D1_FILIAL == "0102" .And. AllTrim(SD1->D1_DOC) == "8448" // Exceção fechamento de outubro/2018 - Jefferson
	lExcecao := .T.
ElseIf SD1->D1_FILIAL == "0102" .And. AllTrim(SD1->D1_DOC) == "8449" // Exceção fechamento de outubro/2018 - Jefferson
	lExcecao := .T.
ElseIf SD1->D1_FILIAL == "0102" .And. AllTrim(SD1->D1_DOC) == "8452" // Exceção fechamento de outubro/2018 - Jefferson
	lExcecao := .T.
ElseIf SD1->D1_FILIAL == "0103" .And. AllTrim(SD1->D1_DOC) == "102413" // Exceção fechamento de fevereiro/2019 - Jefferson
	lExcecao := .T.
ElseIf SD1->D1_FILIAL == "0102" .And. AllTrim(SD1->D1_DOC) == "000002852" // Exceção fechamento de maio/2019 - Jefferson
	lExcecao := .T.
ElseIf SD1->D1_FILIAL == "0102" .And. AllTrim(SD1->D1_DOC) == "000006258" // Exceção fechamento de fevereiro/2020 - Jefferson	
	lExcecao := .T.
Endif
If lExcecao
	Return
Endif

If SD1->D1_XCUSTO > 0 // Custo da NF Origem
	If SD1->D1_TIPO == "D" // Devoluções de Venda
		If !Empty(SD1->D1_NFORI)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If !DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )
				lGrava := .T. // Nota Fiscal de Saída Origem não encontrada no Protheus
				nXCust := SD1->D1_XCUSTO
			ElseIf SD1->D1_FILIAL == "0103" .And. AllTrim(SD1->D1_DOC) == "15894" .And. AllTrim(SD1->D1_SERIE) == "1" .And. AllTrim(SD1->D1_ITEM) == "0001"
				lGrava := .T. // Fecham.Set-2018 - Exceção 
				nXCust := 1952.45
			ElseIf SD1->D1_FILIAL == "0103" .And. AllTrim(SD1->D1_DOC) == "15894" .And. AllTrim(SD1->D1_SERIE) == "1" .And. AllTrim(SD1->D1_ITEM) == "0002"
				lGrava := .T. // Fecham.Set-2018 - Exceção 
				nXCust := 11475.00
			Endif
		Endif
	ElseIf SD1->D1_TES $("084,"+cTesTrc) // Armazen.Galpão | Dev.Troca/Bonificação
		lGrava := .T.
		DbSelectArea("SD2")
		DbSetOrder(3)
		If DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )
			nXCust := SD1->D1_QUANT * (SD2->(D2_CUSTO1/D2_QUANT)) // Custo da Nf origem
		Else
			nXCust := SD1->D1_XCUSTO // Custo digitado pelo usuário
		Endif
	Endif
Else
	// Transf.Filiais
	If SD1->D1_DOC == "000010605"
		lDebug := .T.
	Endif
	tFilOri := ""
	lTraFil := ( RetField("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_TRANFIL") == "1" )
	If lTraFil
		//
		cQuery := " SELECT NNT_FILORI FILORI "
		cQuery += " FROM "+RetSqlName("NNT")
		cQuery += " WHERE NNT_FILDES = '"+SD1->D1_FILIAL+"' "
		cQuery += " AND NNT_PRODD = '"+SD1->D1_COD+"' "
		cQuery += " AND NNT_DOC = '"+SD1->D1_DOC+"' "
		cQuery += " AND NNT_SERIE = '"+SD1->D1_SERIE+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLTRF", .F., .T.)
		SQLTRF->(DbGotop())
		If !Eof()
			tFilOri := SQLTRF->FILORI
		Endif	
		SQLTRF->(DbCloseArea())		
		//
		If !Empty(tFilOri)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( tFilOri + SD1->D1_DOC + SD1->D1_SERIE )
				While !Eof() .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == tFilOri + SD1->D1_DOC + SD1->D1_SERIE
					If SD2->D2_COD == SD1->D1_COD .And. SD2->D2_QUANT == SD1->D1_QUANT .And. SD2->D2_LOTECTL == SD1->D1_LOTECTL
						lGrava := .T.
						nXCust := SD2->D2_CUSTO1 //SD1->D1_QUANT * (SD2->(D2_CUSTO1/D2_QUANT)) // Custo da Nf origem
						Exit
					Endif
					SD2->(DbSkip())
				Enddo
			Endif
		Endif	
	Endif
Endif

If lGrava
	//
	nCustD1 := SD1->D1_CUSTO
	//
	RecLock("SD1",.F.)
	SD1->D1_CUSTO := nXCust
	MsUnLock()
	//
	RecLock("SB2",.F.)
	SB2->B2_VFIM1 += (nXCust - nCustD1)
	MsUnLock()
	//
Endif

RestArea(aArea)

Return
