#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} QQREST01

	Relatório de mapa - Matéria prima

@author Maurício Urbinati de Pádua
@since	21/06/2016

/*/

User Function QQREST01()
	Local lRet				:= .T.
	Local aDadosCab			:= {}   
	Local cObjParambox		:= "ParamQQREST01"
	Local oParamBox 		:= IpParamBoxObject():newIpParamBoxObject(cObjParambox)
	Private bLoadData 		:= { || CursorWait() , gerarReport(aDadosCab, oParamBox) , CursorArrow() }
	Private cCaminho        := Space(150)
	
	addFilter(@oParamBox)
	If oParamBox:show()
		loadCab(@aDadosCab, oParamBox)
	Else
		return
	Endif
	
	If lRet
		//gerarReport(aDadosCab, oParamBox)
		MsgRun( "Carregando os dados do relatório. Por favor, aguarde..." , "" , bLoadData )
	EndIf

Return Nil

Static Function addFilter(oParamBox)
	Local oParam := Nil
    
	oParam := IpParamObject():newIpParamObject("TRIMESTRE", "combo", "Trimestre", "C", 50, 14)
	oParam:setValues({"I (Primeiro)", "II (Segundo)", "III (Terceiro)", "IV (Quarto)"})
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)  
	
	oParam := IpParamObject():newIpParamObject("ANO", "get", "Ano", "C", 50, 4)
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)	
	
	oParam := IpParamObject():newIpParamObject("DESTINO", "get", "Destino", "C", 100, 150)
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)	
Return
/*

*/
Static Function loadCab(aDadosCab, oParamBox)
	dbSelectArea("SM0")  
	
	AADD(aDadosCab, ALLTRIM(SM0->M0_NOMECOM))													//ESTABELECIMENTO
	AADD(aDadosCab, ALLTRIM(SM0->M0_ENDCOB))													//ENDEREÇO
	AADD(aDadosCab, TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999"))									//CEP
	AADD(aDadosCab, ALLTRIM(SM0->M0_CIDCOB))													//CIDADE
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_MAILEMP", .F., "")))									//EMAIL
	AADD(aDadosCab, "("+substr(SM0->M0_TEL,1,2)+")"+substr(SM0->M0_TEL,3,Len(SM0->M0_TEL)))		//FONE
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_NOMCPFR", .F., "")))		//NOME DO RESPONSÁVEL
	AADD(aDadosCab, ALLTRIM(SM0->M0_CIDCOB) + ", " + cValToChar(Day(Date())) + " de " + cValToChar(MesExtenso(Month(Date()))) + " " + cValToChar(Year(Date())))		//LOCAL E DATA
	AADD(aDadosCab, TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99"))								//CNPJ
	AADD(aDadosCab, ALLTRIM(SM0->M0_ESTCOB))													//ESTADO
	AADD(aDadosCab, ALLTRIM(oParamBox:getValue("TRIMESTRE")))									//TRIMESTRE
	AADD(aDadosCab, ALLTRIM(oParamBox:getValue("ANO")))											//ANO
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_NUMREGI", .F., "")))									//REGISTRO NUMERO
Return 

Static Function createQuery(oParamBox)
	Local cQuery		:= ""
	Local lChangeQuery	:= .T.
	Local cDataInicio	:= ""
	Local cDataFim		:= ""
	Local cIniEstoque   := ""
	Local cFimEstoque   := ""
	Local cAno          := ""
	Local cTrimestre    := ""
	
	If oParamBox:getValue("TRIMESTRE") == "I (Primeiro)"
		cDataInicio := oParamBox:getValue("ANO") + "0101"
		cDataFim 	:= oParamBox:getValue("ANO") + "0331"
		cIniEstoque := Alltrim(Str(Val(oParamBox:getValue("ANO")) - 1)) + "1201"
		cFimEstoque := Alltrim(Str(Val(oParamBox:getValue("ANO")) - 1)) + "1231"
		cAno        := oParamBox:getValue("ANO")
		cTrimestre  := oParamBox:getValue("TRIMESTRE")
	ElseIf oParamBox:getValue("TRIMESTRE") == "II (Segundo)"
		cDataInicio := oParamBox:getValue("ANO") + "0401"
		cDataFim 	:= oParamBox:getValue("ANO") + "0630"
		cIniEstoque := oParamBox:getValue("ANO") + "0301"
		cFimEstoque := oParamBox:getValue("ANO") + "0331"
		cAno        := oParamBox:getValue("ANO")
		cTrimestre  := oParamBox:getValue("TRIMESTRE")
	ElseIf oParamBox:getValue("TRIMESTRE") == "III (Terceiro)"
		cDataInicio := oParamBox:getValue("ANO") + "0701"
		cDataFim 	:= oParamBox:getValue("ANO") + "0930"
		cIniEstoque := oParamBox:getValue("ANO") + "0601"
		cFimEstoque := oParamBox:getValue("ANO") + "0630"
		cAno        := oParamBox:getValue("ANO")
		cTrimestre  := oParamBox:getValue("TRIMESTRE")
	ElseIf oParamBox:getValue("TRIMESTRE") == "IV (Quarto)"
		cDataInicio := oParamBox:getValue("ANO") + "1001"
		cDataFim 	:= oParamBox:getValue("ANO") + "1231"
		cIniEstoque := oParamBox:getValue("ANO") + "0901"
		cFimEstoque := oParamBox:getValue("ANO") + "0930"
		cAno        := oParamBox:getValue("ANO")
		cTrimestre  := oParamBox:getValue("TRIMESTRE")
	EndIf	
	
 	cQuery := " SELECT Trim(B1_DESC) AS B1_DESC 								" + CRLF
	cQuery += " ,Trim(BZ_ZZMAPA) AS BZ_ZZMAPA 									" + CRLF
	cQuery += " ,Trim(B1_UM) AS B1_UM	 										" + CRLF
	cQuery += " ,BZ_ZZP2O5 														" + CRLF
	cQuery += " ,BZ_ZZK20 														" + CRLF
	cQuery += " ,BZ_ZZCA 														" + CRLF
	cQuery += " ,BZ_ZZMG 														" + CRLF
	cQuery += " ,BZ_ZZS 														" + CRLF
	cQuery += " ,BZ_ZZB 														" + CRLF
	cQuery += " ,BZ_ZZCI 														" + CRLF
	cQuery += " ,BZ_ZZCO 														" + CRLF
	cQuery += " ,BZ_ZZCU 														" + CRLF
	cQuery += " ,BZ_ZZFE 														" + CRLF
	cQuery += " ,BZ_ZZMN 														" + CRLF
	cQuery += " ,BZ_ZZMO 														" + CRLF
	cQuery += " ,BZ_ZZNI 														" + CRLF
	cQuery += " ,A2_EMPRESAS 													" + CRLF
	cQuery += " ,A2_PAISES 														" + CRLF
	cQuery += " ,BZ_ZZSI 														" + CRLF
	cQuery += " ,BZ_ZZZN 														" + CRLF
	cQuery += " ,BZ_ZZN 														" + CRLF
	cQuery += " ,B9_QINI 														" + CRLF
	cQuery += " ,(COALESCE(D3_MOV,0)+COALESCE(INVENT_SUBTRAI,0))-(COALESCE(D3_DESMONTE,0)-COALESCE(INVENT_SOMA,0)) AS D3_QUANT " + CRLF
	cQuery += " ,D1_NACIONAL 													" + CRLF
	cQuery += " ,D1_IMPORTADO 													" + CRLF
	cQuery += " ,VENDAS		 													" + CRLF
	cQuery += " ,DEVOLUCAO	 													" + CRLF
	cQuery += " ,(COALESCE(B9_QINI, 0) + COALESCE(D1_NACIONAL, 0) + COALESCE(D1_IMPORTADO, 0)) - ABS(COALESCE((COALESCE(D3_MOV,0)+COALESCE(INVENT_SUBTRAI, 0))-(COALESCE(D3_DESMONTE,0)-COALESCE(INVENT_SOMA,0)), 0)) - COALESCE(VENDAS, 0) AS D3_ESTOQUEFIM " + CRLF
	cQuery += " FROM ( 																					" + CRLF
	cQuery += " 			SELECT * 																	" + CRLF
	cQuery += " 				FROM ( 																	" + CRLF
	cQuery += " 						SELECT Trim(SB1.B1_DESC) AS B1_DESC 							" + CRLF
	cQuery += " 						,Trim(SBZ.BZ_ZZMAPA) AS BZ_ZZMAPA 								" + CRLF
	cQuery += " 						,Trim(SB1.B1_UM) AS B1_UM										" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZK20										" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C01 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D01                        " + CRLF
	cQuery += "                             ON D01.BZ_COD = C01.B1_COD 									" + CRLF
	cQuery += "                             AND D01.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D01.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D01.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D01.BZ_ZZK20 > 0										" + CRLF
	cQuery += "							WHERE C01.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C01.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C01.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZK20													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZCA											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C02 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D02                        " + CRLF
	cQuery += "                             ON D02.BZ_COD = C02.B1_COD 									" + CRLF
	cQuery += "                             AND D02.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D02.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D02.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D02.BZ_ZZCA > 0											" + CRLF
	cQuery += "							WHERE C02.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C02.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C02.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCA													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZMG											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C03 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D03                        " + CRLF
	cQuery += "                             ON D03.BZ_COD = C03.B1_COD 									" + CRLF
	cQuery += "                             AND D03.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D03.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D03.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D03.BZ_ZZMG > 0											" + CRLF
	cQuery += "							WHERE C03.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C03.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C03.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZMG													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZS											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C04 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D04                        " + CRLF
	cQuery += "                             ON D04.BZ_COD = C04.B1_COD 									" + CRLF
	cQuery += "                             AND D04.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D04.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D04.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D04.BZ_ZZS > 0											" + CRLF
	cQuery += "							WHERE C04.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C04.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C04.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZS														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZB											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C05 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D05                        " + CRLF
	cQuery += "                             ON D05.BZ_COD = C05.B1_COD 									" + CRLF
	cQuery += "                             AND D05.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D05.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D05.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D05.BZ_ZZB > 0											" + CRLF
	cQuery += "							WHERE C05.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C05.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C05.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZB														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZCI											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C06 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D06                        " + CRLF
	cQuery += "                             ON D06.BZ_COD = C06.B1_COD 									" + CRLF
	cQuery += "                             AND D06.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D06.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D06.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D06.BZ_ZZCI > 0											" + CRLF
	cQuery += "							WHERE C06.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C06.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C06.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCI													" + CRLF
	cQuery += "						,(																	" + CRLF	
	cQuery += "							SELECT DISTINCT BZ_ZZCO											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C07 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D07                        " + CRLF
	cQuery += "                             ON D07.BZ_COD = C07.B1_COD 									" + CRLF
	cQuery += "                             AND D07.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D07.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D07.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D07.BZ_ZZCO > 0											" + CRLF
	cQuery += "							WHERE C07.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C07.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C07.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCO													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZCU											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C08 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D08                        " + CRLF
	cQuery += "                             ON D08.BZ_COD = C08.B1_COD 									" + CRLF
	cQuery += "                             AND D08.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D08.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D08.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D08.BZ_ZZCU > 0											" + CRLF
	cQuery += "							WHERE C08.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C08.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C08.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCU													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZFE											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C09 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D09                        " + CRLF
	cQuery += "                             ON D09.BZ_COD = C09.B1_COD 									" + CRLF
	cQuery += "                             AND D09.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D09.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D09.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D09.BZ_ZZFE > 0											" + CRLF
	cQuery += "							WHERE C09.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C09.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C09.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZFE													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZMN											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C10 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D10                        " + CRLF
	cQuery += "                             ON D10.BZ_COD = C10.B1_COD 									" + CRLF
	cQuery += "                             AND D10.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D10.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D10.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D10.BZ_ZZMN > 0											" + CRLF
	cQuery += "							WHERE C10.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C10.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C10.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZMN													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZMO											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C11 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D11                        " + CRLF
	cQuery += "                             ON D11.BZ_COD = C11.B1_COD 									" + CRLF
	cQuery += "                             AND D11.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D11.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D11.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D11.BZ_ZZMO > 0											" + CRLF
	cQuery += "							WHERE C11.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C11.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C11.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZMO													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZNI											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C12 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D12                        " + CRLF
	cQuery += "                             ON D12.BZ_COD = C12.B1_COD 									" + CRLF
	cQuery += "                             AND D12.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D12.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D12.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D12.BZ_ZZNI > 0											" + CRLF
	cQuery += "							WHERE C12.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C12.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C12.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZNI													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZSI											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C13 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D13                        " + CRLF
	cQuery += "                             ON D13.BZ_COD = C13.B1_COD 									" + CRLF
	cQuery += "                             AND D13.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D13.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D13.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D13.BZ_ZZSI > 0											" + CRLF
	cQuery += "							WHERE C13.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C13.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C13.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZSI													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZZN											" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C14 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D14                        " + CRLF
	cQuery += "                             ON D14.BZ_COD = C14.B1_COD 									" + CRLF
	cQuery += "                             AND D14.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D14.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D14.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D14.BZ_ZZZN > 0											" + CRLF
	cQuery += "							WHERE C14.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C14.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C14.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZZN													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZTOTAL										" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C15 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D15                        " + CRLF
	cQuery += "                             ON D15.BZ_COD = C15.B1_COD 									" + CRLF
	cQuery += "                             AND D15.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D15.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D15.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D15.BZ_ZZTOTAL > 0										" + CRLF
	cQuery += "							WHERE C15.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C15.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C15.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZN														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZP2O5										" + CRLF
	cQuery += "							FROM "+RetSqlName("SB1")+" C16 "  								  + CRLF
	cQuery += "                             INNER JOIN "+RetSqlName("SBZ")+" D16                        " + CRLF
	cQuery += "                             ON D16.BZ_COD = C16.B1_COD 									" + CRLF
	cQuery += "                             AND D16.BZ_FILIAL = '"+xFilial("SBZ")+"'                    " + CRLF
	cQuery += "                             AND D16.D_E_L_E_T_= ' '                                     " + CRLF
	cQuery += "                             AND D16.BZ_ZZMAPA = BZ_ZZMAPA                               " + CRLF
	cQuery += "								AND D16.BZ_ZZP2O5 > 0										" + CRLF
	cQuery += "							WHERE C16.B1_FILIAL = '"+xFilial("SB1")+"'"						  + CRLF
	cQuery += "								AND C16.B1_DESC = SB1.B1_DESC  							    " + CRLF
	cQuery += "								AND C16.D_E_L_E_T_ = ' '									" + CRLF	
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZP2O5													" + CRLF
	cQuery += " 					,(																	" + CRLF
	cQuery += " 						SELECT SUM(B9_QINI)												" + CRLF
	cQuery += " 						FROM "+RetSqlTab("SB9")	 										  + CRLF
	cQuery += " 						WHERE "+RetSqlDel("SB9")										  + CRLF
	cQuery += " 							AND B9_FILIAL = '"+xFilial("SB9")+"'						" + CRLF
	If cAno == "2016" .AND. cTrimestre == "II (Segundo)"
		cQuery += "								AND B9_DATA = ' '										" + CRLF
	Else
		cQuery += "								AND B9_DATA >= '"+cIniEstoque+"'						" + CRLF
		cQuery += "								AND B9_DATA <= '"+cFimEstoque+"'						" + CRLF
	Endif
	cQuery += "								AND B9_LOCAL NOT IN('02','06')								" + CRLF // Alteração Projeto 2020
	cQuery += " 							AND B9_COD IN ( 											" + CRLF
	cQuery += " 								SELECT B1_COD											" + CRLF
	cQuery += " 								FROM "+RetSqlName("SB1")+" T1							" + CRLF
	cQuery += " 								INNER JOIN "+RetSqlName("SBZ")+" T2 					" + CRLF
	cQuery += " 									ON T2.BZ_COD = T1.B1_COD 						    " + CRLF
	cQuery += " 									AND BZ_FILIAL = '"+xFilial("SBZ")+"'				" + CRLF
	cQuery += " 									AND T2.D_E_L_E_T_ = ' ' 							" + CRLF
	cQuery += " 								WHERE T1.B1_DESC = SB1.B1_DESC							" + CRLF
	cQuery += " 									AND T2.BZ_ZZMAPA = SBZ.BZ_ZZMAPA					" + CRLF
	cQuery += " 									AND T1.D_E_L_E_T_ = ' '								" + CRLF
	cQuery += " 					)																	" + CRLF
	cQuery += " 			) AS B9_QINI																" + CRLF
	cQuery += " 		,(																				" + CRLF

	cQuery += " 			SELECT SUM(SD1.D1_QUANT)													" + CRLF
	cQuery += " 			FROM "+RetSqlTab("SD1")														  + CRLF
	cQuery += " 			INNER JOIN "+RetSqlTab("SA2")+" ON SA2.A2_COD = SD1.D1_FORNECE 				" + CRLF
	cQuery += " 				AND SA2.A2_LOJA = SD1.D1_LOJA 											" + CRLF
	cQuery += " 				AND SA2.A2_EST <> 'EX' 													" + CRLF
	cQuery += " 				AND "+RetSqlDel("SA2") 													  + CRLF
	cQuery += " 			INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES  				" + CRLF 
	cQuery += " 				AND "+RetSqlDel("SF4") 	 												  + CRLF
	cQuery += "                 AND SF4.F4_ESTOQUE = 'S'                                                " + CRLF
	cQuery += "                 AND SF4.F4_PODER3 = 'N'                                                 " + CRLF
	cQuery += "                 AND SF4.F4_FILIAL = SD1.D1_FILIAL                                       " + CRLF
	cQuery += " 			WHERE SD1.D1_TIPO = 'N' 													" + CRLF
	cQuery += " 				AND SD1.D1_ORIGLAN <> 'LF'												" + CRLF
//	cQuery += " 				AND SD1.D1_LOCAL >= '01'												" + CRLF // Alteração Projeto 2020
//	cQuery += " 				AND SD1.D1_LOCAL <= '04'												" + CRLF // Alteração Projeto 2020
	cQuery += " 				AND "+RetSqlDel("SD1") 													  + CRLF
	cQuery += " 				AND SD1.D1_FILIAL = '"+xFilial("SD1")+"'								" + CRLF
	cQuery += "                 AND SD1.D1_DTDIGIT >= '"+cDataInicio+"'									" + CRLF 
	cQuery += "                 AND SD1.D1_DTDIGIT <= '"+cDataFim+"'									" + CRLF
	cQuery += " 				AND SD1.D1_COD IN (														" + CRLF
	cQuery += " 					SELECT B1_COD														" + CRLF
	cQuery += " 					FROM "+RetSqlName("SB1")+" T3 										" + CRLF
	cQuery += " 					INNER JOIN "+RetSqlName("SBZ")+" T4 ON T4.BZ_COD = T3.B1_COD 		" + CRLF
	cQuery += " 						AND T4.D_E_L_E_T_ = ' ' 										" + CRLF
	cQuery += " 						AND T4.BZ_FILIAL = '"+xFilial("SBZ")+"'							" + CRLF
	cQuery += " 					WHERE T3.B1_DESC = SB1.B1_DESC										" + CRLF
	cQuery += " 						AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF
	cQuery += " 						AND T3.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 					)																	" + CRLF
	cQuery += " 			) AS D1_NACIONAL															" + CRLF
	cQuery += " 		,(																				" + CRLF

	cQuery += " 			SELECT RTRIM(XMLAGG(XMLELEMENT(e, NOME_EMPRESA || ',')).EXTRACT('//text()'), ',')  " + CRLF
	cQuery += " 			FROM (																		" + CRLF
	cQuery += " 				SELECT RTRIM(A2_NOME) NOME_EMPRESA										" + CRLF
	cQuery += " 					,RTRIM(SB1.B1_DESC) AS DESC_PROD									" + CRLF
	cQuery += " 					,RTRIM(SBZ.BZ_ZZMAPA) AS MAPA_PROD									" + CRLF
	cQuery += " 				FROM "+RetSqlTab("SD1")													  + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SA2")+" ON SA2.A2_COD = SD1.D1_FORNECE 			" + CRLF
	cQuery += " 					AND SA2.A2_LOJA = SD1.D1_LOJA 										" + CRLF
	cQuery += " 					AND SA2.A2_EST <> 'EX'												" + CRLF
	cQuery += " 					AND "+RetSqlDel("SA2")												  + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SB1")+" ON SD1.D1_COD = SB1.B1_COD 				" + CRLF
	cQuery += " 					AND "+RetSqlDel("SB1")												  + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SBZ")+" ON SBZ.BZ_COD = SB1.B1_COD 				" + CRLF
	cQuery += " 					AND "+RetSqlDel("SBZ") 												  + CRLF
	cQuery += " 					AND SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'							" + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES  			" + CRLF 
	cQuery += " 					AND "+RetSqlDel("SF4") 	 											  + CRLF
	cQuery += "                 	AND SF4.F4_ESTOQUE = 'S'                                            " + CRLF
	cQuery += "                 	AND SF4.F4_PODER3 = 'N'                                             " + CRLF
	cQuery += "              		AND SF4.F4_FILIAL = SD1.D1_FILIAL			                        " + CRLF
	cQuery += " 				WHERE 1 = 1 															" + CRLF
	cQuery += " 					AND SD1.D1_TIPO = 'N' 												" + CRLF
	cQuery += " 					AND SD1.D1_ORIGLAN <> 'LF'											" + CRLF
	cQuery += " 					AND SD1.D1_FILIAL = '"+xFilial("SD1")+"'							" + CRLF
	cQuery += " 					AND "+RetSqlDel("SD1") 												  + CRLF
	cQuery += "                     AND SD1.D1_DTDIGIT >= '"+cDataInicio+"'								" + CRLF 
	cQuery += "                     AND SD1.D1_DTDIGIT <= '"+cDataFim+"'								" + CRLF
//	cQuery += " 				    AND SD1.D1_LOCAL >= '01'    										" + CRLF // Alteração Projeto 2020
//	cQuery += " 				    AND SD1.D1_LOCAL <= '04'											" + CRLF // Alteração Projeto 2020
	cQuery += " 				GROUP BY SA2.A2_NOME													" + CRLF
	cQuery += " 					,SB1.B1_DESC														" + CRLF
	cQuery += " 					,SBZ.BZ_ZZMAPA														" + CRLF
	cQuery += " 				ORDER BY SA2.A2_NOME													" + CRLF
	cQuery += " 				)																		" + CRLF
	cQuery += " 			WHERE DESC_PROD = RTRIM(SB1.B1_DESC)										" + CRLF
	cQuery += " 			) AS A2_EMPRESAS															" + CRLF
	cQuery += " 		,(																				" + CRLF

	cQuery += " 			SELECT SUM(SD1.D1_QUANT)													" + CRLF
	cQuery += " 			FROM "+RetSqlTab("SD1")														  + CRLF
	cQuery += " 			INNER JOIN "+RetSqlTab("SA2")+" ON SA2.A2_COD = SD1.D1_FORNECE 				" + CRLF
	cQuery += " 				AND SA2.A2_LOJA = SD1.D1_LOJA 											" + CRLF
	cQuery += " 				AND SA2.A2_EST = 'EX' 													" + CRLF 
	cQuery += " 				AND "+RetSqlDel("SA2") 	 												  + CRLF
	cQuery += " 			INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES  				" + CRLF 
	cQuery += " 				AND "+RetSqlDel("SF4") 	 												  + CRLF
	cQuery += "                 AND SF4.F4_ESTOQUE = 'S'                                                " + CRLF
	cQuery += "                 AND SF4.F4_PODER3 = 'N'                                                 " + CRLF
	cQuery += "                 AND SF4.F4_FILIAL = SD1.D1_FILIAL  				                        " + CRLF
	cQuery += " 			WHERE SD1.D1_TIPO = 'N' 													" + CRLF
	cQuery += " 				AND SD1.D1_ORIGLAN <> 'LF'												" + CRLF
	cQuery += " 				AND SD1.D1_LOCAL = '98'													" + CRLF
	cQuery += " 				AND "+RetSqlDel("SD1")													  + CRLF
	cQuery += " 				AND SD1.D1_FILIAL = '"+xFilial("SD1")+"'								" + CRLF
	cQuery += "                 AND SD1.D1_DTDIGIT >= '"+cDataInicio+"'									" + CRLF 
	cQuery += "                 AND SD1.D1_DTDIGIT <= '"+cDataFim+"'									" + CRLF
	cQuery += " 				AND SD1.D1_COD IN (														" + CRLF
	cQuery += " 					SELECT B1_COD														" + CRLF
	cQuery += " 					FROM "+RetSqlName("SB1")+" T5 										" + CRLF
	cQuery += " 					INNER JOIN "+RetSqlName("SBZ")+" T6 ON T6.BZ_COD = T5.B1_COD		" + CRLF
	cQuery += " 						AND T6.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 						AND T6.BZ_FILIAL = '"+xFilial("SBZ")+"'							" + CRLF
	cQuery += " 					WHERE B1_DESC = SB1.B1_DESC											" + CRLF
	cQuery += " 						AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF
	cQuery += " 						AND T5.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 					)																	" + CRLF
	cQuery += " 			) AS D1_IMPORTADO															" + CRLF

	cQuery += " 		,(																				" + CRLF
	cQuery += " 			SELECT RTRIM(XMLAGG(XMLELEMENT(e, NOME_PAIS || ',')).EXTRACT(' //text()'), ',')	" + CRLF
	cQuery += " 			FROM (																		" + CRLF
	cQuery += " 				SELECT RTRIM(SYA.YA_DESCR) NOME_PAIS									" + CRLF
	cQuery += " 					,RTRIM(SB1.B1_DESC) AS DESC_PROD									" + CRLF
	cQuery += " 					,RTRIM(SBZ.BZ_ZZMAPA) AS MAPA_PROD									" + CRLF
	cQuery += " 				FROM "+RetSqlTab("SD1")													  + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SA2")+" ON A2_COD = D1_FORNECE					" + CRLF
	cQuery += " 					AND SA2.A2_LOJA = SD1.D1_LOJA										" + CRLF
	cQuery += " 					AND "+RetSqlDel("SA2")												  + CRLF
	cQuery += " 					AND SA2.A2_EST = 'EX'												" + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SB1")+" ON SD1.D1_COD = SB1.B1_COD				" + CRLF
	cQuery += " 					AND "+RetSqlDel("SB1")												  + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SBZ")+" ON SB1.B1_COD = SBZ.BZ_COD				" + CRLF
	cQuery += " 					AND "+RetSqlDel("SBZ")												  + CRLF
	cQuery += " 					AND SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'							" + CRLF
	cQuery += " 				INNER JOIN "+RetSqlTab("SYA")+" ON SA2.A2_PAIS = SYA.YA_CODGI 			" + CRLF
	cQuery += " 					AND "+RetSqlDel("SYA")												  + CRLF
	cQuery += " 			    INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES  			" + CRLF 
	cQuery += " 				    AND "+RetSqlDel("SF4") 	 											  + CRLF
	cQuery += "                     AND SF4.F4_ESTOQUE = 'S'                                            " + CRLF
	cQuery += "                     AND SF4.F4_PODER3 = 'N'                                             " + CRLF
	cQuery += "              		AND SF4.F4_FILIAL = SD1.D1_FILIAL  			                        " + CRLF
	cQuery += " 				WHERE 1 = 1																" + CRLF
	cQuery += " 					AND SD1.D1_TIPO = 'N'												" + CRLF
	cQuery += " 					AND SD1.D1_ORIGLAN <> 'LF'											" + CRLF
	cQuery += " 					AND "+RetSqlDel("SD1")												  + CRLF
	cQuery += " 					AND D1_FILIAL = '"+xFilial("SD1")+"'								" + CRLF
	cQuery += "                     AND D1_DTDIGIT >= '"+cDataInicio+"'									" + CRLF 
	cQuery += "                     AND D1_DTDIGIT <= '"+cDataFim+"'									" + CRLF
//	cQuery += " 				    AND SD1.D1_LOCAL >= '01'    										" + CRLF // Alteração Projeto 2020
//	cQuery += " 				    AND SD1.D1_LOCAL <= '04'											" + CRLF // Alteração Projeto 2020
	cQuery += " 				GROUP BY SYA.YA_DESCR													" + CRLF
	cQuery += " 					,SB1.B1_DESC														" + CRLF
	cQuery += " 					,SBZ.BZ_ZZMAPA														" + CRLF
	cQuery += " 				ORDER BY SYA.YA_DESCR													" + CRLF
	cQuery += " 				)																		" + CRLF
	cQuery += " 			WHERE DESC_PROD = RTRIM(SB1.B1_DESC)										" + CRLF
	cQuery += " 			) AS A2_PAISES																" + CRLF	
	cQuery += " 		,(																				" + CRLF

	cQuery += " 			SELECT SUM(SD2.D2_QUANT)													" + CRLF
	cQuery += " 			FROM "+RetSqlTab("SD2")														  + CRLF
	cQuery += " 			INNER JOIN "+RetSqlTab("SA1")+" ON SA1.A1_COD = SD2.D2_CLIENTE 				" + CRLF
	cQuery += " 				AND SA1.A1_LOJA = SD2.D2_LOJA 											" + CRLF
	cQuery += " 				AND SA1.A1_EST <> 'EX' 													" + CRLF
	cQuery += " 				AND "+RetSqlDel("SA1") 													  + CRLF
	cQuery += " 			INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD2.D2_TES  				" + CRLF 
	cQuery += " 			    AND "+RetSqlDel("SF4") 	 											  	  + CRLF
	cQuery += "                 AND SF4.F4_ESTOQUE = 'S'                                            	" + CRLF
	cQuery += "                 AND SF4.F4_PODER3 = 'N'                                             	" + CRLF
	cQuery += "                 AND SF4.F4_FILIAL = SD2.D2_FILIAL				                        " + CRLF
	cQuery += " 			WHERE SD2.D2_TIPO = 'N' 													" + CRLF
	cQuery += " 				AND "+RetSqlDel("SD2") 													  + CRLF
	cQuery += " 				AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'								" + CRLF
	cQuery += "                 AND SD2.D2_EMISSAO >= '"+cDataInicio+"'									" + CRLF 
	cQuery += "                 AND SD2.D2_EMISSAO <= '"+cDataFim+"'									" + CRLF
	cQuery += "					AND SD2.D2_LOCAL NOT IN('06')						            		" + CRLF // Alteração Projeto 2020
//	cQuery += " 				AND SD2.D2_LOCAL >= '01'												" + CRLF // Alteração Projeto 2020
//	cQuery += " 				AND SD2.D2_LOCAL <= '11'												" + CRLF // Alteração Projeto 2020
	cQuery += " 				AND SD2.D2_ORIGLAN = ' '												" + CRLF
	cQuery += " 				AND SD2.D2_COD IN (														" + CRLF
	cQuery += " 					SELECT B1_COD														" + CRLF
	cQuery += " 					FROM "+RetSqlName("SB1")+" T3 										" + CRLF
	cQuery += " 					INNER JOIN "+RetSqlName("SBZ")+" T4 ON T4.BZ_COD = T3.B1_COD 		" + CRLF
	cQuery += " 						AND T4.D_E_L_E_T_ = ' ' 										" + CRLF
	cQuery += " 						AND T4.BZ_FILIAL = '"+xFilial("SBZ")+"'							" + CRLF
	cQuery += " 					WHERE T3.B1_DESC = SB1.B1_DESC										" + CRLF
	cQuery += " 						AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF
	cQuery += " 						AND T3.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 					)																	" + CRLF
	cQuery += " 			) AS VENDAS																	" + CRLF
	cQuery += " 		,(																				" + CRLF
/*
	cQuery += " 			SELECT SUM(SD3.D3_QUANT)													" + CRLF
	cQuery += " 			FROM "+RetSqlTab("SD3")														  + CRLF
	cQuery += " 			WHERE SD3.D3_ESTORNO = ' ' 													" + CRLF
	cQuery += " 				AND "+RetSqlDel("SD3")													  + CRLF
	cQuery += " 				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'								" + CRLF
	cQuery += "                 AND SD3.D3_EMISSAO >= '"+cDataInicio+"'									" + CRLF 
	cQuery += "                 AND SD3.D3_EMISSAO <= '"+cDataFim+"'									" + CRLF
//	cQuery += " 				AND SD3.D3_LOCAL >= '01'												" + CRLF
//	cQuery += " 				AND SD3.D3_LOCAL <= '05'												" + CRLF
	cQuery += " 				AND SD3.D3_CF = 'DE7'													" + CRLF
	cQuery += " 				AND SD3.D3_COD IN (														" + CRLF
	cQuery += " 					SELECT B1_COD														" + CRLF
	cQuery += " 					FROM "+RetSqlName("SB1")+" T5 										" + CRLF
	cQuery += " 					INNER JOIN "+RetSqlName("SBZ")+" T6 ON T6.BZ_COD = T5.B1_COD		" + CRLF
	cQuery += " 						AND T6.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 						AND T6.BZ_FILIAL = '"+xFilial("SBZ")+"'							" + CRLF
	cQuery += " 					WHERE B1_DESC = SB1.B1_DESC											" + CRLF
	cQuery += " 						AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF
	cQuery += " 						AND T5.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 					)																	" + CRLF
	cQuery += " 			) AS DEVOLUCAO																" + CRLF
*/

	cQuery += " 			SELECT SUM(SD1.D1_QUANT)													" + CRLF
	cQuery += " 			FROM "+RetSqlTab("SD1")														  + CRLF
	cQuery += " 			INNER JOIN "+RetSqlTab("SA1")+" ON SA1.A1_COD = SD1.D1_FORNECE 				" + CRLF
	cQuery += " 				AND SA1.A1_LOJA = SD1.D1_LOJA 											" + CRLF
	cQuery += " 				AND SA1.A1_EST <> 'EX' 													" + CRLF 
	cQuery += " 				AND "+RetSqlDel("SA1") 	 												  + CRLF
	cQuery += " 		    INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES  				" + CRLF 
	cQuery += " 			    AND "+RetSqlDel("SF4") 	 											  	  + CRLF
	cQuery += "                 AND SF4.F4_ESTOQUE = 'S'                                            	" + CRLF
	cQuery += "                 AND SF4.F4_PODER3 = 'N'                                             	" + CRLF
	cQuery += " 			WHERE SD1.D1_TIPO = 'D' 													" + CRLF
	cQuery += " 				AND "+RetSqlDel("SD1")													  + CRLF
	cQuery += " 				AND SD1.D1_FILIAL = '"+xFilial("SD1")+"'								" + CRLF
	cQuery += "                 AND SD1.D1_DTDIGIT >= '"+cDataInicio+"'									" + CRLF 
	cQuery += "                 AND SD1.D1_DTDIGIT <= '"+cDataFim+"'									" + CRLF
//	cQuery += " 				AND SD1.D1_LOCAL >= '01'												" + CRLF // Alteração Projeto 2020
//	cQuery += " 				AND SD1.D1_LOCAL <= '05'												" + CRLF // Alteração Projeto 2020
	cQuery += " 				AND SD1.D1_COD IN (														" + CRLF
	cQuery += " 					SELECT B1_COD														" + CRLF
	cQuery += " 					FROM "+RetSqlName("SB1")+" T5 										" + CRLF
	cQuery += " 					INNER JOIN "+RetSqlName("SBZ")+" T6 ON T6.BZ_COD = T5.B1_COD		" + CRLF
	cQuery += " 						AND T6.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 						AND T6.BZ_FILIAL = '"+xFilial("SBZ")+"'							" + CRLF
	cQuery += " 					WHERE B1_DESC = SB1.B1_DESC											" + CRLF
	cQuery += " 						AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF
	cQuery += " 						AND T5.D_E_L_E_T_ = ' '											" + CRLF
	cQuery += " 					)																	" + CRLF
	cQuery += " 			) AS DEVOLUCAO																" + CRLF

	cQuery += "			,(																				" + CRLF
 	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_CF = 'RE1'	 													" + CRLF															
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE B1_DESC = SB1.B1_DESC										" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS D3_MOV 																" + CRLF

 	cQuery += "			,(																				" + CRLF
 	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_DOC = 'INVENT'	 												" + CRLF
 	cQuery += "				AND SD3.D3_TM = '499'	 													" + CRLF
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE B1_DESC = SB1.B1_DESC										" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS INVENT_SOMA															" + CRLF

 	cQuery += "			,(																				" + CRLF
 	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_DOC = 'INVENT'	 												" + CRLF
 	cQuery += "				AND SD3.D3_TM = '999'	 													" + CRLF															
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE B1_DESC = SB1.B1_DESC										" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS INVENT_SUBTRAI															" + CRLF

 	cQuery += "			,( 																				" + CRLF
 	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF		
 	cQuery += "				AND SD3.D3_CF = 'DE7' 														" + CRLF												
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF												
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T17 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T18 ON T18.BZ_COD = T17.B1_COD	" + CRLF	
 	cQuery += "								AND T18.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T18.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE B1_DESC = SB1.B1_DESC										" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T17.D_E_L_E_T_ = ' '										" + CRLF											
 	cQuery += "					)																		" + CRLF
 	cQuery += "				) AS D3_DESMONTE															" + CRLF

	cQuery += " 	FROM "+RetSqlTab("SB1") 															  + CRLF
	cQuery += " 	INNER JOIN "+RetSqlTab("SBZ")+" ON SB1.B1_COD = SBZ.BZ_COD 							" + CRLF
	cQuery += " 		AND "+RetSqlDel("SBZ")	
	cQuery += " 		AND "+RetSqlFil("SBZ")															  + CRLF
	cQuery += " 	WHERE 1 = 1																			" + CRLF
	cQuery += " 		AND "+RetSqlDel("SB1")															  + CRLF
	cQuery += " 		AND B1_TIPO = 'MP'																" + CRLF
	cQuery += " 		AND B1_GRUPO NOT IN('0003','0004')												" + CRLF
	cQuery += " 	GROUP BY SB1.B1_DESC																" + CRLF
	cQuery += " 		,SBZ.BZ_ZZMAPA																	" + CRLF
	cQuery += " 		,SB1.B1_UM																		" + CRLF
	cQuery += " 	ORDER BY SB1.B1_DESC																" + CRLF
	cQuery += " 	) TAB1 																				" + CRLF
	cQuery += ") TAB2 																					" + CRLF
	cQuery += " WHERE TAB2.B9_QINI > 0 																	" + CRLF
 	
	MemoWrite("\sql\QQREST01_getQryReport.sql",cQuery)
	
	If lChangeQuery
		cQuery := ChangeQuery(cQuery) 
	Endif
		
Return cQuery

Static Function gerarReport(aDadosCab, oParamBox)
	
	cCaminho  := AllTrim(oParamBox:getValue("DESTINO"))
	If Substr(cCaminho,Len(cCaminho),1) != "\"
		cCaminho += "\"
	Endif
	oExcelXML := zExcelXML():New(.F.)								//Instância o Objeto
	oExcelXML:SetOrigem("\xmls\QQREST01.xml")						//Indica o caminho do arquivo Origem (que será aberto e clonado)
	oExcelXML:SetDestino(cCaminho+"RESULT_QQREST01.xml")			//Indica o caminho do arquivo Destino (que será gerado)
	
	
	oExcelXML:AddExpression("#ESTABELECIMENTO"	, aDadosCab[1])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#ENDERECO"			, aDadosCab[2])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#CEP"				, aDadosCab[3])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#CIDADE"			, aDadosCab[4])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#EMAIL"			, aDadosCab[5])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#FONE"				, aDadosCab[6])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#NOMECPF_REPONSA"	, aDadosCab[7])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#LOCAL_DATA"		, aDadosCab[8])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#CNPJ"				, aDadosCab[9])		//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#UF"				, aDadosCab[10])	//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#TRIMESTRE"		, aDadosCab[11])	//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#ANO"				, aDadosCab[12])	//Adiciona expressão que será substituída
	oExcelXML:AddExpression("#REGISTRO_NUMERO"	, aDadosCab[13])	//Adiciona expressão que será substituída
	
	TCQuery createQuery(oParamBox) New Alias "QRY_ITENS"
	
	oExcelXML:AddTabExcel("#TABELA_REPORT", "QRY_ITENS")			//Adiciona tabela dinâmica

	oExcelXML:MountFile()											//Monta o arquivo
	oExcelXML:ViewSO()
	
	oExcelXML:Destroy(.F.)

	QRY_ITENS->(DbCloseArea())
Return
