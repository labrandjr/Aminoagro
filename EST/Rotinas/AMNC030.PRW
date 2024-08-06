#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNC030   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 22/05/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula composição do custo de Produtos Intermediários.	  ¦¦¦
¦¦¦          ¦ Percentuais utilizados no relatório Composição de Custos.  ¦¦¦
¦¦¦          ¦ AMNR003 - Composição de Custos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNC030()

Local lOk    := .F.
Local lEnd	 := .F.
Local cPerg	 := Padr("AMNC030",10)
Local oFnt1  := TFont():New("Tahoma",,18,,.T.)
Local oFnt2  := TFont():New("Tahoma",,15,,.T.)
Local oFnt3  := TFont():New("Tahoma",,14,,.F.)
Private cEOL := CHR(13)+CHR(10)
Private oDlgUpd, oProcess

If !(__cUserId $ ( AllTrim(GetMv("MV_XGEREST")) )) // Administrador, Jefferson Costa, Paul Bergman
	MsgAlert("Usuário não autorizado. Contate o Administrador.")
	Return
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Composição dos Custos | Produtos Intermediários" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,080,{||"CALCULO DA COMPOSIÇÃO DOS CUSTOS (PI)"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo calcular a composição dos custos dos produtos intermediários"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"baseado nos apontamentos de produção, e classificá-los em Embalagem, Solução, MOD e MOI."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"O período desejado e filiais para processamento devem ser informados em 'Parâmetros'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"O resultado pode ser visualizado em 'Composição Custo PI'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  22/05/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento - COMPOSIÇÃO DOS CUSTOS (PI) ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := u_ProcCust() }, "Calculando composição dos custos (PI)", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcCust ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  22/05/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento do calculo.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcCust()

Local nRecSM0 := SM0->(Recno())
Local xFilOri := cFilAnt
Local cEOL    := CHR(13)+CHR(10)
Local nForFilial
Local aFilsCalc

// Inicializa variáveis
zMesPer   := Substr(mv_par01,1,2)
zAnoPer   := Substr(mv_par01,3,4)
zPeriod   := zAnoPer + zMesPer
aFilsCalc := MatFilCalc( mv_par02 == 1 )
zProdEx   := mv_par03

If Val(zMesPer) < 1 .Or. Val(zMesPer) > 12
	MsgInfo("Período inválido. Revise os parametros.")
	Return
Endif

If Val(zAnoPer) < 2016
	MsgInfo("Período inválido. Revise os parametros.")
	Return
Endif

oProcess:SetRegua1(Len(aFilsCalc))
For nForFilial := 1 To Len( aFilsCalc )

	lContin := .T.
	cFilAnt := AllTrim(aFilsCalc[nForFilial][2])
	cNomFil := AllTrim(aFilsCalc[nForFilial][3])
	oProcess:IncRegua1("Validando Filial "+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil))

	If aFilsCalc[nForFilial][1]

		// Último fechamento
		cQuery := " SELECT MAX(ZE_ANOMES) AS ANOMES "
		cQuery += " FROM "+RetSqlName("SZE")
		cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
		If !Empty(zProdEx)
			cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TZE", .F., .T.)
		TZE->(DbGotop())
		If Eof()
			MsgInfo("Atenção, fechamentos anteriores não localizados na Filial "+cFilAnt+".")
			lContin := .F.
		Endif
		TZE->(DbCloseArea())

		If lContin
			// Verifica fechamentos posteriores.
			cQuery := " SELECT COUNT(*) AS SOMA "
			cQuery += " FROM "+RetSqlName("SZE")
			cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
			cQuery += " AND ZE_ANOMES > '"+zPeriod+"' "
			If !Empty(zProdEx)
				cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
			Endif
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
			If SQL->SOMA > 0
				lContin := .F.
				If MsgYesNo("Filial: "+cFilAnt+cEOL+;
							IIf(!Empty(zProdEx),"Produto: "+AllTrim(zProdEx)+cEOL,"")+;
							"Fechamentos posteriores devem ser excluídos."+cEOL+"Deseja prosseguir ?","Aviso","INFO")
					If MsgYesNo("Os fechamentos posteriores a '"+zMesPer+"/"+zAnoPer+"' serão excluídos."+cEOL+;
								"Filial: "+cFilAnt+cEOL+;
								IIf(!Empty(zProdEx),"Produto: "+AllTrim(zProdEx)+cEOL,"")+;
								"Confirma processamento ?","Aviso","INFO")
						lContin := .T.
					Endif
				Endif
			Endif
			SQL->(DbCloseArea())
		Endif
		
		If lContin
			// Apaga fechamentos posteriores + período em processamento.
			//
			cQuery := " DELETE "+RetSqlName("SZD")
			cQuery += " WHERE ZD_FILIAL = '"+cFilAnt+"'
			cQuery += " AND ZD_EMISSAO >= '"+zPeriod+"01' "
			If !Empty(zProdEx)
				cQuery += " AND ZD_PRODUTO = '"+zProdEx+"' "
			Endif
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TCSQLEXEC(cQuery)
			//
			cQuery := " DELETE "+RetSqlName("SZE")
			cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
			cQuery += " AND ZE_ANOMES >= '"+zPeriod+"' "
			If !Empty(zProdEx)
				cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
			Endif
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TCSQLEXEC(cQuery)
			//
		Else
			Return
		Endif

	Endif	
	
Next nForFilial

oProcess:SetRegua1(Len(aFilsCalc))
For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[nForFilial][1]
	
		cFilAnt := AllTrim(aFilsCalc[nForFilial][2])
		cNomFil := AllTrim(aFilsCalc[nForFilial][3])
		oProcess:IncRegua1("Processando Filial "+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil))

		// Último fechamento
		cQuery := " SELECT MAX(ZE_ANOMES) AS ANOMES "
		cQuery += " FROM "+RetSqlName("SZE")
		cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
		If !Empty(zProdEx)
			cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TZE", .F., .T.)
		zUltfh := TZE->ANOMES
		TZE->(DbCloseArea())	

		// 1. Produções de PI no período.
		cQuery := " SELECT COUNT(*) AS SOMA "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+cFilAnt+"'
		cQuery += " AND D3_TIPO = 'PI' "
		cQuery += " AND D3_CF = 'PR0' "
		cQuery += " AND D3_EMISSAO BETWEEN '"+zPeriod+"01' AND '"+zPeriod+"31' "
		If !Empty(zProdEx)
			cQuery += " AND D3_COD = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nTotSql := SQL->SOMA
		SQL->(DbCloseArea())

		oProcess:SetRegua2(nTotSql)

		cQuery := " SELECT D3_COD, D3_OP, D3_EMISSAO, D3_CUSTO1 "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+cFilAnt+"'
		cQuery += " AND D3_TIPO = 'PI' "
		cQuery += " AND D3_CF = 'PR0' "
		cQuery += " AND D3_EMISSAO BETWEEN '"+zPeriod+"01' AND '"+zPeriod+"31' "
		If !Empty(zProdEx)
			cQuery += " AND D3_COD = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY D3_FILIAL, D3_OP, D3_COD "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()
		
			oProcess:IncRegua2("Processando Filial "+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil))

			pProd := SQL->D3_COD
			pOrdP := SQL->D3_OP  
			pEmis := StoD(SQL->D3_EMISSAO)
			pCust := SQL->D3_CUSTO1
			pcEmb := 0
			pcSol := 0
			pcMOD := 0
			pcMOI := 0
			piEmb := 0
			piSol := 0
			piMOD := 0
			piMOI := 0

			cQuery := " SELECT D3_FILIAL, D3_COD, D3_TIPO, D3_GRUPO, D3_CUSTO1 "
			cQuery += " FROM "+RetSqlName("SD3")
			cQuery += " WHERE D3_FILIAL = '"+cFilAnt+"'
			cQuery += " AND D3_OP = '"+pOrdP+"' "
			cQuery += " AND D3_CF <> 'PR0' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TD3", .F., .T.)
			
			DbSelectArea("TD3")
			TD3->(DbGotop())
			While !Eof()
				//
				If TD3->D3_TIPO == "PI" // Apenas PI requisitados.
					// Prioriza fechamento anterior.
					DbSelectArea("SZE")
					DbSetOrder(1)
					If DbSeek( cFilAnt + TD3->D3_COD + zUltfh )
						ziEmb := Round((TD3->D3_CUSTO1 * (SZE->ZE_PEREMB/100)),2)
						ziSol := Round((TD3->D3_CUSTO1 * (SZE->ZE_PERSOL/100)),2)
						ziMOD := Round((TD3->D3_CUSTO1 * (SZE->ZE_PERMOD/100)),2)
						ziMOI := Round((TD3->D3_CUSTO1 * (SZE->ZE_PERMOI/100)),2)
						//
						piEmb += ziEmb
						piSol += ziSol
						piMOD += ziMOD
						piMOI += (TD3->D3_CUSTO1 - (ziEmb + ziSol + ziMOD))
					Else
						// Inicializa condição.
						lPercOk := .F.
						//
						// Se não houver fechamento anterior, pesquisa se existe saldo inicial no período mensal corrente (SB9), considerando armazens 01 e 02.
						fUlMes := StoD(zPeriod+"01")-1
						cQuery := " SELECT SUM(B9_QINI) AS QINI "
						cQuery += " FROM "+RetSqlName("SB9")
						cQuery += " WHERE B9_FILIAL = '"+cFilAnt+"'
						cQuery += " AND B9_COD = '"+TD3->D3_COD+"' "
						cQuery += " AND B9_LOCAL IN('01','02') "
						cQuery += " AND B9_DATA = '"+DtoS(fUlMes)+"' "
						cQuery += " AND D_E_L_E_T_ <> '*' "
						DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TB9", .F., .T.)
						zSdoIni := TB9->QINI
						TB9->(DbCloseArea())
						// Caso afirmativo, avalia se já houve fechamento de PI anteriormente (em qualquer período).
						If zSdoIni > 0
							cQuery := " SELECT ZE_FILIAL, ZE_PRODUTO, ZE_PERIODO, ZE_ANOMES, ZE_PEREMB, ZE_PERSOL, ZE_PERMOD, ZE_PERMOI "
							cQuery += " FROM "+RetSqlName("SZE")
							cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
							cQuery += " AND ZE_PRODUTO = '"+TD3->D3_COD+"' "
							cQuery += " AND D_E_L_E_T_ <> '*' "
							cQuery += " ORDER BY ZE_ANOMES DESC "
							DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TZEU", .F., .T.)
							TZEU->(DbGotop())
							If !Eof()
								// Se sim, utiliza os percentuais localizados (percentuais do último fechamento encontrado).
								ziEmb := Round((TD3->D3_CUSTO1 * (TZEU->ZE_PEREMB/100)),2)
								ziSol := Round((TD3->D3_CUSTO1 * (TZEU->ZE_PERSOL/100)),2)
								ziMOD := Round((TD3->D3_CUSTO1 * (TZEU->ZE_PERMOD/100)),2)
								ziMOI := Round((TD3->D3_CUSTO1 * (TZEU->ZE_PERMOI/100)),2)
								//
								piEmb += ziEmb
								piSol += ziSol
								piMOD += ziMOD
								piMOI += (TD3->D3_CUSTO1 - (ziEmb + ziSol + ziMOD))
								//
								lPercOk := .T.
							Endif
							TZEU->(DbCloseArea())	
						Endif
						If !lPercOk
							// Se não atender nenhuma condição acima, utiliza percentuais conforme estrutura.
							DbSelectArea("SZA")
							DbSetOrder(1)
							If DbSeek( cFilAnt + TD3->D3_COD )
								ziEmb := Round((TD3->D3_CUSTO1 * (SZA->ZA_PEREMB/100)),2)
								ziSol := Round((TD3->D3_CUSTO1 * (SZA->ZA_PERSOL/100)),2)
								ziMOD := Round((TD3->D3_CUSTO1 * (SZA->ZA_PERMOD/100)),2)
								ziMOI := Round((TD3->D3_CUSTO1 * (SZA->ZA_PERMOI/100)),2)
								//
								piEmb += ziEmb
								piSol += ziSol
								piMOD += ziMOD
								piMOI += (TD3->D3_CUSTO1 - (ziEmb + ziSol + ziMOD))
							Else
								piSol += TD3->D3_CUSTO1 // Caso o produto não for submetido ao Calculo da Formação de Preços, atribui 100% para Solução.
							Endif
						Endif	
					Endif
			    ElseIf TD3->D3_TIPO == "MP" .And. TD3->D3_GRUPO $("0003,0004")
			    	pcEmb += TD3->D3_CUSTO1
			    ElseIf TD3->D3_TIPO == "MP" .And. TD3->D3_GRUPO $("0005,0006")
			    	pcSol += TD3->D3_CUSTO1
			    ElseIf TD3->D3_TIPO == "MO" .And. Substr(RetField("SB1",1,xFilial("SB1")+TD3->D3_COD,"B1_DESC"),1,3) != "CIF"
			    	pcMOD += TD3->D3_CUSTO1
			    ElseIf TD3->D3_TIPO == "MO" .And. Substr(RetField("SB1",1,xFilial("SB1")+TD3->D3_COD,"B1_DESC"),1,3) == "CIF"
			    	pcMOI += TD3->D3_CUSTO1
			    Endif
				//
				DbSelectArea("TD3")
				TD3->(DbSkip())
			Enddo
			TD3->(DbCloseArea())

			// Arredondamento
			nDif := (pcEmb + piEmb + pcSol + piSol + pcMOD + piMOD + pcMOI + piMOI) - pCust
			If nDif != 0
				If pcEmb > 0 .And. (pcEmb - nDif) > 0
					pcEmb -= nDif
				ElseIf pcSol > 0 .And. (pcSol - nDif) > 0
					pcSol -= nDif
				ElseIf pcMOD > 0 .And. (pcMOD - nDif) > 0
					pcMOD -= nDif
				ElseIf pcMOI > 0 .And. (pcMOI - nDif) > 0
					pcMOI -= nDif
				ElseIf piEmb > 0 .And. (piEmb - nDif) > 0
					piEmb -= nDif
				ElseIf piSol > 0 .And. (piSol - nDif) > 0
					piSol -= nDif
				ElseIf piMOD > 0 .And. (piMOD - nDif) > 0
					piMOD -= nDif
				ElseIf piMOI > 0 .And. (piMOI - nDif) > 0
					piMOI -= nDif
				Endif
			Endif
			
            DbSelectArea("SZD")
            RecLock("SZD",.T.)
            SZD->ZD_FILIAL  := cFilAnt
            SZD->ZD_PRODUTO := pProd
            SZD->ZD_OP      := pOrdP
            SZD->ZD_EMISSAO := pEmis
            SZD->ZD_CUSTO1  := pCust
            SZD->ZD_CUSEMB  := pcEmb
            SZD->ZD_CPIEMB  := piEmb
            SZD->ZD_CUSSOL  := pcSol
            SZD->ZD_CPISOL  := piSol
            SZD->ZD_CUSMOD  := pcMOD
            SZD->ZD_CPIMOD  := piMOD
            SZD->ZD_CUSMOI  := pcMOI
            SZD->ZD_CPIMOI  := piMOI
            MsUnLock()

			DbSelectArea("SQL")
			SQL->(DbSkip())

		Enddo
		SQL->(DbCloseArea())

		// 2. Totalizar valores das Op´s no período - por Produto.
		cQuery := " SELECT COUNT(*) AS SOMA "
		cQuery += " FROM "+RetSqlName("SZD")
		cQuery += " WHERE ZD_FILIAL = '"+cFilAnt+"'
		cQuery += " AND ZD_EMISSAO BETWEEN '"+zPeriod+"01' AND '"+zPeriod+"31' "
		If !Empty(zProdEx)
			cQuery += " AND ZD_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nTotSql := SQL->SOMA
		SQL->(DbCloseArea())

		oProcess:SetRegua2(nTotSql)

		cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName("SZD")
		cQuery += " WHERE ZD_FILIAL = '"+cFilAnt+"'
		cQuery += " AND ZD_EMISSAO BETWEEN '"+zPeriod+"01' AND '"+zPeriod+"31' "
		If !Empty(zProdEx)
			cQuery += " AND ZD_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY ZD_FILIAL, ZD_PRODUTO, ZD_OP "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()
		
			oProcess:IncRegua2("Totalizando Filial "+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil))

			DbSelectArea("SZE")
			DbSetOrder(1)
			If !DbSeek( cFilAnt + SQL->ZD_PRODUTO + zPeriod )
				RecLock("SZE",.T.)
				SZE->ZE_FILIAL  := cFilAnt
				SZE->ZE_PRODUTO := SQL->ZD_PRODUTO
				SZE->ZE_ANOMES  := zPeriod
				SZE->ZE_PERIODO := zMesPer + zAnoPer
			Else
			    RecLock("SZE",.F.)
			Endif
			SZE->ZE_CUSTO  += SQL->ZD_CUSTO1
			SZE->ZE_CUSEMB += SQL->(ZD_CUSEMB+ZD_CPIEMB)
			SZE->ZE_CUSSOL += SQL->(ZD_CUSSOL+ZD_CPISOL)
			SZE->ZE_CUSMOD += SQL->(ZD_CUSMOD+ZD_CPIMOD)
			SZE->ZE_CUSMOI += SQL->(ZD_CUSMOI+ZD_CPIMOI)
			MsUnLock()
			
			DbSelectArea("SQL")
			SQL->(DbSkip())

		Enddo
		SQL->(DbCloseArea())

		// 3. Gravar o total acumulado - 11 meses anteriores - no fechamento atual.
		zPerIni := ""
		zPerFim := ""
		nMesAnt := 0
		nAnoAnt := 0
		nMesIni := 0
		nAnoIni := 0
		//
		nMesAnt := Val(zMesPer)-1
		nAnoAnt := Val(zAnoPer)
		If nMesAnt == 0
			nMesAnt := 12
			nAnoAnt -= 1
		Endif
		zPerFim := AllTrim(STR(nAnoAnt)) + StrZero(nMesAnt,2) // <-- Mês anterior = Mês final.
		//
		nMesIni := nMesAnt
		nAnoIni := nAnoAnt
		For _x := 1 to 10 // Percorre mais 10 meses anteriores, totalizando 11 meses.
			nMesIni -= 1
			If nMesIni == 0
				nMesIni := 12
				nAnoIni -= 1
			Endif
		Next _x	
		zPerIni := AllTrim(STR(nAnoIni)) + StrZero(nMesIni,2) // <-- 11o.mês anterior = Mês inicial.
		//
		cQuery := " SELECT COUNT(DISTINCT(ZE_PRODUTO)) AS SOMA "
		cQuery += " FROM "+RetSqlName("SZE")
		cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
		cQuery += " AND ZE_ANOMES BETWEEN '"+zPerIni+"' AND '"+zPerFim+"' "
		If !Empty(zProdEx)
			cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nTotSql := SQL->SOMA
		SQL->(DbCloseArea())

		oProcess:SetRegua2(nTotSql)

		cQuery := " SELECT ZE_PRODUTO, SUM(ZE_CUSTO) CUSTO, SUM(ZE_CUSEMB) CUSEMB, SUM(ZE_CUSSOL) CUSSOL, SUM(ZE_CUSMOD) CUSMOD, SUM(ZE_CUSMOI) CUSMOI "
		cQuery += " FROM "+RetSqlName("SZE")
		cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
		cQuery += " AND ZE_ANOMES BETWEEN '"+zPerIni+"' AND '"+zPerFim+"' "
		If !Empty(zProdEx)
			cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY ZE_PRODUTO "
		cQuery += " ORDER BY ZE_PRODUTO "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()
		
			oProcess:IncRegua2("Acumulados Filial "+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil))

			DbSelectArea("SZE")
			DbSetOrder(1)
			If !DbSeek( cFilAnt + SQL->ZE_PRODUTO + zPeriod )
				RecLock("SZE",.T.)
				SZE->ZE_FILIAL  := cFilAnt
				SZE->ZE_PRODUTO := SQL->ZE_PRODUTO
				SZE->ZE_ANOMES  := zPeriod
				SZE->ZE_PERIODO := zMesPer + zAnoPer
			Else
			    RecLock("SZE",.F.)
			Endif
			SZE->ZE_ACMCUS := SQL->CUSTO
			SZE->ZE_ACMEMB := SQL->CUSEMB
			SZE->ZE_ACMSOL := SQL->CUSSOL
			SZE->ZE_ACMMOD := SQL->CUSMOD
			SZE->ZE_ACMMOI := SQL->CUSMOI
			MsUnLock()
			
			DbSelectArea("SQL")
			SQL->(DbSkip())

		Enddo
		SQL->(DbCloseArea())

		// 4. Calcula os percentuais e finaliza o processo.
		cQuery := " SELECT COUNT(*) AS SOMA "
		cQuery += " FROM "+RetSqlName("SZE")
		cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
		cQuery += " AND ZE_ANOMES = '"+zPeriod+"' "
		If !Empty(zProdEx)
			cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nTotSql := SQL->SOMA
		SQL->(DbCloseArea())

		oProcess:SetRegua2(nTotSql)

		cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName("SZE")
		cQuery += " WHERE ZE_FILIAL = '"+cFilAnt+"'
		cQuery += " AND ZE_ANOMES = '"+zPeriod+"' "
		If !Empty(zProdEx)
			cQuery += " AND ZE_PRODUTO = '"+zProdEx+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY ZE_FILIAL, ZE_PRODUTO, ZE_ANOMES "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()
		
			oProcess:IncRegua2("Calculando % Filial "+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil))

			DbSelectArea("SZE")
			DbSetOrder(1)
			If DbSeek( cFilAnt + SQL->ZE_PRODUTO + zPeriod )
				//
				nCusTot := SZE->(ZE_CUSTO+ZE_ACMCUS)
				nCusEmb := SZE->(ZE_CUSEMB+ZE_ACMEMB)
				nCusSol := SZE->(ZE_CUSSOL+ZE_ACMSOL)
				nCusMOD := SZE->(ZE_CUSMOD+ZE_ACMMOD)
				nCusMOI := SZE->(ZE_CUSMOI+ZE_ACMMOI)
				//
				RecLock("SZE",.F.)
				SZE->ZE_PEREMB := ((nCusEmb / nCusTot) * 100)
				SZE->ZE_PERSOL := ((nCusSol / nCusTot) * 100)
				SZE->ZE_PERMOD := ((nCusMOD / nCusTot) * 100)
				SZE->ZE_PERMOI := ((nCusMOI / nCusTot) * 100)
				// Acerta arredondamentos para bater 100%
				If SZE->(ZE_PEREMB+ZE_PERSOL+ZE_PERMOD+ZE_PERMOI) < 100
					zDif := 100 - SZE->(ZE_PEREMB+ZE_PERSOL+ZE_PERMOD+ZE_PERMOI)
					SZE->ZE_PERMOD += zDif
				ElseIf SZE->(ZE_PEREMB+ZE_PERSOL+ZE_PERMOD+ZE_PERMOI) > 100
					zDif := SZE->(ZE_PEREMB+ZE_PERSOL+ZE_PERMOD+ZE_PERMOI) - 100
					SZE->ZE_PERMOD -= zDif
				Endif
				MsUnLock()
				//
			Endif	
			
			DbSelectArea("SQL")
			SQL->(DbSkip())

		Enddo
		SQL->(DbCloseArea())

	Endif	
	
Next nForFilial

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

MsgInfo("Processamento concluído!","Calculo da Composição dos Custos (PI)")

Return
