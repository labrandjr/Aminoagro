#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} QQREST02

	Relatório de mapa - Produto Acabado, a granel e embalado

@author Maurício Urbinati de Pádua
@since	21/06/2016

/*/

User Function QQREST02()
	Local lRet				:= .T.
	Local aDadosCab			:= {}   
	Local cObjParambox		:= "ParamQQREST02"
	Local oParamBox 		:= IpParamBoxObject():newIpParamBoxObject(cObjParambox)
	Private bLoadData 		:= { || CursorWait() , gerarReport(aDadosCab, oParamBox) , CursorArrow() }
	Private cCaminho        := Space(150)
	
	addFilter(@oParamBox)
	If oParamBox:show()
		loadCab(@aDadosCab, oParamBox)
	Else
		Return 
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
	
	oParam := IpParamObject():newIpParamObject("TIPO", "combo", "Tipo de Operação", "C", 60)
	oParam:setValues({	"1-Mineral",;
						"2-Organomineral"})
	oParam:setRequired(.f.)
	oParamBox:addParam(oParam)            	
	
	oParam := IpParamObject():newIpParamObject("DESTINO", "get", "Destino", "C", 100, 150)
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)	
	
Return

Static Function loadCab(aDadosCab, oParamBox)
	dbSelectArea("SM0")  
	
	AADD(aDadosCab, ALLTRIM(SM0->M0_NOMECOM))												//ESTABELECIMENTO
	AADD(aDadosCab, ALLTRIM(SM0->M0_ENDCOB))												//ENDEREÇO
	AADD(aDadosCab, TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999"))								//CEP
	AADD(aDadosCab, ALLTRIM(SM0->M0_CIDCOB))												//CIDADE
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_MAILEMP", .F., "")))								//EMAIL
	AADD(aDadosCab, "("+substr(SM0->M0_TEL,1,2)+")"+substr(SM0->M0_TEL,3,Len(SM0->M0_TEL)))	//FONE
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_NOMCPFR", .F., "")))								//NOME DO RESPONSÁVEL
	AADD(aDadosCab, ALLTRIM(SM0->M0_CIDCOB) + ", " + cValToChar(Day(Date())) + " de " + cValToChar(MesExtenso(Month(Date()))) + " " + cValToChar(Year(Date())))		//LOCAL E DATA
	AADD(aDadosCab, TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")) 						//CNPJ
	AADD(aDadosCab, ALLTRIM(SM0->M0_ESTCOB))												//ESTADO
	AADD(aDadosCab, ALLTRIM(oParamBox:getValue("TRIMESTRE")))								//TRIMESTRE
	AADD(aDadosCab, ALLTRIM(oParamBox:getValue("ANO")))										//ANO
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_NUMREGI", .F., "")))								//REGISTRO NUMERO
Return 

Static Function createQuery(oParamBox, cUfFilial)
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
	
	cTipo   := oParamBox:getValue("TIPO")
		
	If cTipo == "2-Organomineral"
		cDescricaoTipo:= "F. Organomineral A"
	Else
		cDescricaoTipo:= "Fertilizante Foliar"
	Endif
	
	cQuery := " SELECT '"+cDescricaoTipo+"' AS B1_TIPO " + CRLF
	cQuery += " ,BZ_ZZMAPA     	" + CRLF
	cQuery += " ,B1_UM 			" + CRLF
	cQuery += " ,BZ_ZZP2O5 	    " + CRLF
	cQuery += " ,BZ_ZZK20 		" + CRLF
	cQuery += " ,BZ_ZZCA 		" + CRLF
	cQuery += " ,BZ_ZZMG 		" + CRLF
	cQuery += " ,BZ_ZZS 		" + CRLF
	cQuery += " ,BZ_ZZB 		" + CRLF
	cQuery += " ,BZ_ZZCI 		" + CRLF
	cQuery += " ,BZ_ZZCO 		" + CRLF
	cQuery += " ,BZ_ZZCU 		" + CRLF
	cQuery += " ,BZ_ZZFE 		" + CRLF
	cQuery += " ,BZ_ZZMN 		" + CRLF
	cQuery += " ,BZ_ZZMO 		" + CRLF
	cQuery += " ,BZ_ZZNI 		" + CRLF
	cQuery += " ,BZ_ZZSI 		" + CRLF
	cQuery += " ,BZ_ZZZN 		" + CRLF
	cQuery += " ,BZ_ZZN 		" + CRLF
	cQuery += " ,BZ_ZZCAORG		" + CRLF
	cQuery += " ,B9_QINI 		" + CRLF
	cQuery += " ,(COALESCE(D3_MOV,0)+COALESCE(INVENT_SOMA,0))-(COALESCE(INVENT_SUBTRAI,0)) AS D3_QUANT " + CRLF
	cQuery += " ,D1_IMPORTADO 	" + CRLF
	cQuery += " ,A2_PAISES 		" + CRLF
	cQuery += " ,D2_EXPORTADOS  " + CRLF
	cQuery += " ,A1_PAISES 		" + CRLF
	cQuery += " ,D2_UF 			" + CRLF
	cQuery += " ,D2_OUTRASUF 	" + CRLF
	cQuery += " ,A1_UFS 		" + CRLF
	cQuery += " ,D1_CONDREVENDA " + CRLF
//	cQuery += " ,(COALESCE(B9_QINI,0)+COALESCE((COALESCE(D3_MOV,0)+COALESCE(INVENT_SOMA,0))-(COALESCE(INVENT_SUBTRAI,0)),0) + COALESCE(D1_IMPORTADO,0)) - (COALESCE(D2_EXPORTADOS,0) + COALESCE(D2_UF,0) + COALESCE(D2_OUTRASUF,0)) + COALESCE(D1_CONDREVENDA,0) + COALESCE(D3_TRFENT, 0) - COALESCE(D3_TRFSAI, 0) + COALESCE(D3_DESENT, 0) - COALESCE(D3_DESSAI, 0) AS D3_ESTOQUEFIM  " + CRLF // Alteração Projeto 2020
	cQuery += " ,(COALESCE(B9_QINI,0)+COALESCE((COALESCE(D3_MOV,0)+COALESCE(INVENT_SOMA,0))-(COALESCE(INVENT_SUBTRAI,0)),0) + COALESCE(D1_IMPORTADO,0)) - (COALESCE(D2_EXPORTADOS,0) + COALESCE(D2_UF,0) + COALESCE(D2_OUTRASUF,0)) + COALESCE(D1_CONDREVENDA,0) AS D3_ESTOQUEFIM  " + CRLF
	cQuery += " FROM (			" + CRLF
	cQuery += "		SELECT * 	" + CRLF
	cQuery += "			FROM (	" + CRLF
	cQuery += "					SELECT Trim(SB1.B1_TIPO) AS B1_TIPO 									" + CRLF
	cQuery += "						,Trim(SBZ.BZ_ZZMAPA) AS BZ_ZZMAPA									" + CRLF
	cQuery += "						,Trim(SB1.B1_UM) AS B1_UM											" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZK20										" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C01 "  								  + CRLF
	cQuery += "							WHERE C01.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C01.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C01.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C01.BZ_ZZK20 > 0										" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZK20													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZCA											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C02 "								  + CRLF
	cQuery += "							WHERE C02.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C02.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C02.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C02.BZ_ZZCA > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCA													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZMG											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C03 "								  + CRLF
	cQuery += "							WHERE C03.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C03.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C03.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C03.BZ_ZZMG > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZMG													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZS											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C04 "								  + CRLF
	cQuery += "							WHERE C04.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C04.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C04.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C04.BZ_ZZS > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZS														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZB											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C05 "								  + CRLF
	cQuery += "							WHERE C05.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C05.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C05.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C05.BZ_ZZB > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZB														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZCI											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C06 "								  + CRLF
	cQuery += "							WHERE C06.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C06.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C06.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C06.BZ_ZZCI > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCI													" + CRLF
	cQuery += "						,(																	" + CRLF	
	cQuery += "							SELECT DISTINCT BZ_ZZCO											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C07 "								  + CRLF
	cQuery += "							WHERE C07.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C07.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C07.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C07.BZ_ZZCO > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCO													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZCU											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C08 "								  + CRLF
	cQuery += "							WHERE C08.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C08.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C08.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C08.BZ_ZZCU > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCU													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZFE											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C09 "								  + CRLF
	cQuery += "							WHERE C09.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C09.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C09.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C09.BZ_ZZFE > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZFE													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZMN											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C10 "								  + CRLF
	cQuery += "							WHERE C10.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C10.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C10.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C10.BZ_ZZMN > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZMN													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZMO											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C11 "								  + CRLF
	cQuery += "							WHERE C11.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C11.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C11.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C11.BZ_ZZMO > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZMO													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZNI											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C12 "								  + CRLF
	cQuery += "							WHERE C12.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C12.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C12.D_E_L_E_T_ = ' '								    " + CRLF
	cQuery += "								AND C12.BZ_ZZNI > 0										    " + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZNI													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZSI											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C13 "								  + CRLF
	cQuery += "							WHERE C13.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C13.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C13.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C13.BZ_ZZSI > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZSI													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZZN											" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C14 "								  + CRLF
	cQuery += "							WHERE C14.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C14.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C14.D_E_L_E_T_ = ' '									" + CRLF
	cQuery += "								AND C14.BZ_ZZZN > 0											" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZZN													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZTOTAL										" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C15 "								  + CRLF
	cQuery += "							WHERE C15.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C15.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C15.D_E_L_E_T_ = ' '								    " + CRLF
	cQuery += "								AND C15.BZ_ZZTOTAL > 0										" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZN														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZCAORG										" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C16 "								  + CRLF
	cQuery += "							WHERE C16.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C16.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C16.D_E_L_E_T_ = ' '								    " + CRLF
	cQuery += "								AND C16.BZ_ZZCAORG > 0										" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF
	cQuery += "							) AS BZ_ZZCAORG													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT DISTINCT BZ_ZZP2O5										" + CRLF
	cQuery += "							FROM "+RetSqlName("SBZ")+" C17 "  								  + CRLF
	cQuery += "                         WHERE C17.BZ_FILIAL = '"+xFilial("SBZ")+"'"						  + CRLF
	cQuery += "								AND C17.BZ_ZZMAPA = SBZ.BZ_ZZMAPA							" + CRLF
	cQuery += "								AND C17.D_E_L_E_T_ = ' '								    " + CRLF
	cQuery += "								AND C17.BZ_ZZP2O5 > 0										" + CRLF
	cQuery += "								AND ROWNUM < 2												" + CRLF   
	cQuery += "							) AS BZ_ZZP2O5													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT SUM(B9_QINI)												" + CRLF
	cQuery += "							FROM "+RetSqlTab("SB9")											  + CRLF
	cQuery += "							WHERE "+RetSqlDel("SB9")										  + CRLF				
	cQuery += "								AND B9_FILIAL = '"+xFilial("SB9")+"'"					      + CRLF
	If cAno == "2016" .AND. cTrimestre == "II (Segundo)"
		cQuery += "								AND B9_DATA = ' '										" + CRLF
	Else
		cQuery += "								AND B9_DATA >= '"+cIniEstoque+"'						" + CRLF
		cQuery += "								AND B9_DATA <= '"+cFimEstoque+"'						" + CRLF
	Endif
	cQuery += "								AND B9_LOCAL NOT IN('02','06')								" + CRLF // Alteração Projeto 2020
	cQuery += "								AND B9_COD IN (												" + CRLF
	cQuery += "									SELECT B1_COD											" + CRLF
	cQuery += "									FROM "+RetSqlName("SB1")+" T1							" + CRLF
	cQuery += "									INNER JOIN "+RetSqlName("SBZG10")+" T2 					" + CRLF
	cQuery += "										ON T2.BZ_COD = T1.B1_COD							" + CRLF
	cQuery += "										AND BZ_FILIAL = '"+xFilial("SBZ")+"'"				  + CRLF
	cQuery += "										AND T2.D_E_L_E_T_ = ' '								" + CRLF
	cQuery += "									WHERE T1.B1_TIPO = SB1.B1_TIPO							" + CRLF	
	cQuery += "										AND T2.BZ_ZZMAPA = SBZ.BZ_ZZMAPA					" + CRLF
	cQuery += "										AND T1.D_E_L_E_T_ = ' '								" + CRLF
	cQuery += "									)														" + CRLF
	cQuery += "							) AS B9_QINI													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT SUM(SD1.D1_QUANT)										" + CRLF	
	cQuery += "							FROM "+RetSqlTab("SD1") 										  + CRLF
	cQuery += "							INNER JOIN "+RetSqlTab("SA2")+" ON SA2.A2_COD = SD1.D1_FORNECE  " + CRLF
	cQuery += "								AND SA2.A2_LOJA = SD1.D1_LOJA 								" + CRLF
	cQuery += "								AND "+RetSqlDel("SA2")										  + CRLF
	cQuery += "								AND SA2.A2_EST = 'EX'										" + CRLF
	cQuery += " 						INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES	" + CRLF 
	cQuery += " 							AND "+RetSqlDel("SF4") 	 									  + CRLF
	cQuery += "                 			AND SF4.F4_ESTOQUE = 'S'                                    " + CRLF
	cQuery += "                 			AND SF4.F4_PODER3 = 'N'                                     " + CRLF
	cQuery += "                 			AND SF4.F4_FILIAL = SD1.D1_FILIAL                           " + CRLF
	cQuery += "							WHERE SD1.D1_TIPO = 'N' 										" + CRLF
//	cQuery += "								AND SD1.D1_LOCAL >= '01'									" + CRLF // Alteração Projeto 2020
//	cQuery += "								AND SD1.D1_LOCAL <= '11'									" + CRLF // Alteração Projeto 2020
	cQuery += "								AND "+RetSqlDel("SD1")										  + CRLF
	cQuery += "								AND "+RetSqlFil("SD1")										  + CRLF
	cQuery += "                 			AND SD1.D1_DTDIGIT >= '"+cDataInicio+"'						" + CRLF 
	cQuery += "                 			AND SD1.D1_DTDIGIT <= '"+cDataFim+"'						" + CRLF
	cQuery += "								AND SD1.D1_COD IN (											" + CRLF
	cQuery += "									SELECT B1_COD											" + CRLF
	cQuery += "									FROM "+RetSqlName("SB1")+" T3 							" + CRLF
	cQuery += "									INNER JOIN "+RetSqlName("SBZ")+" T4						" + CRLF  
	cQuery += "										ON T3.B1_COD = T4.BZ_COD							" + CRLF
	cQuery += "										AND T4.D_E_L_E_T_ = ' '								" + CRLF
	cQuery += "										AND T4.BZ_FILIAL = '"+xFilial("SBZ")+"'" 			  + CRLF
	cQuery += "									WHERE T3.B1_TIPO = SB1.B1_TIPO 							" + CRLF
	cQuery += "										AND T4.BZ_ZZMAPA = SBZ.BZ_ZZMAPA 					" + CRLF
	cQuery += "										AND T3.D_E_L_E_T_ = ' ' 							" + CRLF
	cQuery += "									)														" + CRLF
	cQuery += "							) AS D1_IMPORTADO 												" + CRLF	
	cQuery += "						,( 																	" + CRLF
	cQuery += "							SELECT RTRIM(XMLAGG(XMLELEMENT(e, NOME_PAIS || ',')).EXTRACT('//text()'), ',') " + CRLF
	cQuery += "							FROM (															" + CRLF
	cQuery += "								SELECT RTRIM(SYA.YA_DESCR) NOME_PAIS						" + CRLF
	cQuery += "									,RTRIM(SB1.B1_TIPO) AS TIPO_PROD						" + CRLF
	cQuery += "									,RTRIM(SBZ.BZ_ZZMAPA) AS MAPA_PROD					    " + CRLF
	cQuery += "								FROM "+RetSqlTab("SD1")										  + CRLF	
	cQuery += "								INNER JOIN "+RetSqlTab("SA2")+" ON A2_COD = D1_FORNECE		" + CRLF
	cQuery += "									AND SA2.A2_LOJA = SD1.D1_LOJA							" + CRLF
	cQuery += "									AND "+RetSqlDel("SA2")									  + CRLF
	cQuery += "									AND SA2.A2_EST = 'EX' 									" + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SB1")+" ON SB1.B1_COD = SD1.D1_COD  " + CRLF
	cQuery += "									AND "+RetSqlDel("SB1")									  + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SBZ")+" ON SBZ.BZ_COD = SB1.B1_COD  " + CRLF
	cQuery += "									AND "+RetSqlDel("SBZ")									  + CRLF
	cQuery += "									AND SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'				" + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SYA")+" ON 							" + CRLF
	cQuery += "										SYA.YA_CODGI = SA2.A2_PAIS							" + CRLF
	cQuery += "									AND "+RetSqlDel("SYA")									  + CRLF
	cQuery += " 							INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES " + CRLF 
	cQuery += " 								AND "+RetSqlDel("SF4") 	 								  + CRLF
	cQuery += "                 				AND SF4.F4_ESTOQUE = 'S'                                " + CRLF
	cQuery += "                 				AND SF4.F4_PODER3 = 'N'                                 " + CRLF
	cQuery += "                 				AND SF4.F4_FILIAL = SD1.D1_FILIAL                       " + CRLF
	cQuery += "								WHERE 1 = 1													" + CRLF
	cQuery += "									AND SD1.D1_TIPO = 'N'									" + CRLF
	cQuery += "									AND "+RetSqlDel("SD1")									  + CRLF
	cQuery += "									AND SD1.D1_FILIAL = '"+xFilial("SD1")+"'"				  + CRLF
	cQuery += "                 				AND SD1.D1_DTDIGIT >= '"+cDataInicio+"'					" + CRLF 
	cQuery += "                 				AND SD1.D1_DTDIGIT <= '"+cDataFim+"'					" + CRLF
	cQuery += "								    AND SD1.D1_LOCAL >= '01'								" + CRLF
	cQuery += "								    AND SD1.D1_LOCAL <= '11'								" + CRLF
	cQuery += "								GROUP BY SYA.YA_DESCR										" + CRLF
	cQuery += "									,SB1.B1_TIPO											" + CRLF
	cQuery += "									,SBZ.BZ_ZZMAPA											" + CRLF
	cQuery += "								ORDER BY SYA.YA_DESCR										" + CRLF
	cQuery += "								)															" + CRLF
	cQuery += "							WHERE TIPO_PROD = RTRIM(SB1.B1_TIPO)							" + CRLF
	cQuery += "								AND MAPA_PROD = RTRIM(SBZ.BZ_ZZMAPA)						" + CRLF
	cQuery += "							) AS A2_PAISES													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT SUM(SD2.D2_QUANT)										" + CRLF
	cQuery += "							FROM "+RetSqlTab("SD2")											  + CRLF
	cQuery += "							INNER JOIN "+RetSqlTab("SA1")+" ON SA1.A1_COD = SD2.D2_CLIENTE	" + CRLF
	cQuery += "								AND SA1.A1_LOJA = SD2.D2_LOJA								" + CRLF
	cQuery += "								AND "+RetSqlDel("SA1")										  + CRLF
	cQuery += "								AND SA1.A1_EST = '"+cUfFilial+"'							" + CRLF
	cQuery += " 						INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD2.D2_TES	" + CRLF 
	cQuery += " 							AND "+RetSqlDel("SF4") 	 									  + CRLF
	cQuery += "                				AND SF4.F4_ESTOQUE = 'S'                                    " + CRLF
	cQuery += "                				AND SF4.F4_PODER3 = 'N'                                     " + CRLF
	cQuery += "                 			AND SF4.F4_FILIAL = SD2.D2_FILIAL                           " + CRLF
	cQuery += "							WHERE SD2.D2_TIPO = 'N'											" + CRLF
	cQuery += "								AND SD2.D2_ORIGLAN = ' '									" + CRLF
	cQuery += "								AND SD2.D2_LOCAL NOT IN('06')								" + CRLF // Alteração Projeto 2020
//	cQuery += "								AND SD2.D2_LOCAL >= '01'									" + CRLF // Alteração Projeto 2020
//	cQuery += "								AND SD2.D2_LOCAL <= '11'									" + CRLF // Alteração Projeto 2020
	cQuery += "								AND "+RetSqlDel("SD2")										  + CRLF
	cQuery += "								AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'					" + CRLF
	cQuery += "                 			AND SD2.D2_EMISSAO >= '"+cDataInicio+"'						" + CRLF 
	cQuery += "                 			AND SD2.D2_EMISSAO <= '"+cDataFim+"'						" + CRLF
	cQuery += "								AND SD2.D2_COD IN ( 										" + CRLF
	cQuery += "									SELECT B1_COD											" + CRLF
	cQuery += "									FROM "+RetSqlName("SB1")+" T5							" + CRLF
	cQuery += "									INNER JOIN "+RetSqlName("SBZ")+" T6 					" + CRLF
	cQuery += "										ON T6.BZ_COD = T5.B1_COD							" + CRLF
	cQuery += "										AND T6.D_E_L_E_T_ = ' ' 							" + CRLF
	cQuery += "									WHERE T5.B1_TIPO = SB1.B1_TIPO 							" + CRLF	
	cQuery += "										AND T6.BZ_ZZMAPA = SBZ.BZ_ZZMAPA 					" + CRLF
	cQuery += "										AND T5.D_E_L_E_T_ = ' ' 							" + CRLF
	cQuery += "									)													    " + CRLF
	cQuery += "							) AS D2_UF														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT SUM(SD2.D2_QUANT)										" + CRLF
	cQuery += "							FROM "+RetSqlTab("SD2")											  + CRLF
	cQuery += "							INNER JOIN "+RetSqlTab("SA1")+" ON SA1.A1_COD = SD2.D2_CLIENTE  " + CRLF
	cQuery += "								AND SA1.A1_LOJA = SD2.D2_LOJA								" + CRLF
	cQuery += "								AND SA1.A1_EST <> 'EX'										" + CRLF
	cQuery += "								AND SA1.A1_EST <> '"+cUfFilial+"'							" + CRLF
	cQuery += " 						INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD2.D2_TES	" + CRLF 
	cQuery += " 							AND "+RetSqlDel("SF4") 	 									  + CRLF
	cQuery += "                				AND SF4.F4_ESTOQUE = 'S'                                    " + CRLF
	cQuery += "                				AND SF4.F4_PODER3 = 'N'                                     " + CRLF
	cQuery += "                 			AND SF4.F4_FILIAL = SD2.D2_FILIAL                           " + CRLF
	cQuery += "							WHERE SD2.D2_TIPO = 'N'											" + CRLF
	cQuery += "								AND SD2.D2_ORIGLAN = ' '									" + CRLF
	cQuery += "								AND SD2.D2_LOCAL NOT IN('06')								" + CRLF // Alteração Projeto 2020
//	cQuery += "								AND SD2.D2_LOCAL >= '01'									" + CRLF // Alteração Projeto 2020
//	cQuery += "								AND SD2.D2_LOCAL <= '11'									" + CRLF // Alteração Projeto 2020
	cQuery += "								AND "+RetSqlDel("SD2")										  + CRLF
	cQuery += "								AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'					" + CRLF
	cQuery += "                 			AND SD2.D2_EMISSAO >= '"+cDataInicio+"'						" + CRLF 
	cQuery += "                 			AND SD2.D2_EMISSAO <= '"+cDataFim+"'						" + CRLF
	cQuery += "								AND SD2.D2_COD IN (											" + CRLF
	cQuery += "									SELECT B1_COD											" + CRLF
	cQuery += "									FROM "+RetSqlName("SB1")+" T7 							" + CRLF
	cQuery += "									INNER JOIN "+RetSqlName("SBZ")+" T8 					" + CRLF
	cQuery += "										ON T8.BZ_COD = T7.B1_COD 							" + CRLF
	cQuery += "										AND T8.D_E_L_E_T_ = ' '								" + CRLF
	cQuery += "									WHERE T7.B1_TIPO = SB1.B1_TIPO							" + CRLF
	cQuery += "										AND T8.BZ_ZZMAPA = SBZ.BZ_ZZMAPA					" + CRLF
	cQuery += "										AND T7.D_E_L_E_T_ = ' '								" + CRLF
	cQuery += "									)														" + CRLF
	cQuery += "							) AS D2_OUTRASUF												" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT RTRIM(XMLAGG(XMLELEMENT(e, ESTADOS || ',')).EXTRACT('//text()'), ',') " + CRLF
	cQuery += "							FROM (															" + CRLF
	cQuery += "								SELECT RTRIM(SA1.A1_EST) ESTADOS							" + CRLF
	cQuery += "									,RTRIM(SB1.B1_TIPO) AS TIPO_PROD						" + CRLF
	cQuery += "									,RTRIM(SBZ.BZ_ZZMAPA) AS MAPA_PROD						" + CRLF
	cQuery += "								FROM "+RetSqlTab("SD2")										 + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SA1")+" ON A1_COD = D2_CLIENTE 		" + CRLF
	cQuery += "									AND SA1.A1_LOJA = SD2.D2_LOJA							" + CRLF
	cQuery += "									AND SA1.A1_EST <> 'EX'									" + CRLF
	cQuery += "									AND SA1.A1_EST <> '"+cUfFilial+"'						" + CRLF
	cQuery += "									AND "+RetSqlDel("SA1")									  + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SB1")+" ON SB1.B1_COD = SD2.D2_COD 	" + CRLF
	cQuery += "									AND "+RetSqlDel("SB1")									  + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SBZ")+" ON SB1.B1_COD = SBZ.BZ_COD	" + CRLF
	cQuery += "									AND "+RetSqlDel("SBZ")									  + CRLF
	cQuery += "									AND SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'				" + CRLF
	cQuery += " 							INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD2.D2_TES " + CRLF 
	cQuery += " 								AND "+RetSqlDel("SF4") 	 								  + CRLF
	cQuery += "                				 	AND SF4.F4_ESTOQUE = 'S'                                " + CRLF
	cQuery += "                				 	AND SF4.F4_PODER3 = 'N'                                 " + CRLF
	cQuery += "                 				AND SF4.F4_FILIAL = SD2.D2_FILIAL                       " + CRLF
	cQuery += "								WHERE 1 = 1													" + CRLF
	cQuery += "									AND SD2.D2_TIPO = 'N'									" + CRLF
	cQuery += "									AND SD2.D2_ORIGLAN = ' '								" + CRLF
	cQuery += "								    AND SD2.D2_LOCAL NOT IN('06')							" + CRLF // Alteração Projeto 2020
//	cQuery += "								    AND SD2.D2_LOCAL >= '01'								" + CRLF // Alteração Projeto 2020
//	cQuery += "								    AND SD2.D2_LOCAL <= '11'								" + CRLF // Alteração Projeto 2020
	cQuery += "									AND "+RetSqlDel("SD2")									  + CRLF
	cQuery += "									AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'				" + CRLF
	cQuery += "                 				AND SD2.D2_EMISSAO >= '"+cDataInicio+"'					" + CRLF 
	cQuery += "                 				AND SD2.D2_EMISSAO <= '"+cDataFim+"'					" + CRLF
	cQuery += "								GROUP BY SA1.A1_EST 										" + CRLF
	cQuery += "									,SB1.B1_TIPO											" + CRLF
	cQuery += "									,SBZ.BZ_ZZMAPA											" + CRLF
	cQuery += "								ORDER BY SA1.A1_EST											" + CRLF
	cQuery += "								)															" + CRLF
	cQuery += "							WHERE TIPO_PROD = RTRIM(SB1.B1_TIPO)							" + CRLF
	cQuery += "								AND MAPA_PROD = RTRIM(SBZ.BZ_ZZMAPA)						" + CRLF
	cQuery += "							) AS A1_UFS														" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT SUM(SD2.D2_QUANT)										" + CRLF
	cQuery += "							FROM "+RetSqlTab("SD2")											  + CRLF
	cQuery += "							INNER JOIN "+RetSqlTab("SA1")+" ON SA1.A1_COD = SD2.D2_CLIENTE 	" + CRLF
	cQuery += "								AND SA1.A1_LOJA = SD2.D2_LOJA								" + CRLF
	cQuery += "								AND SA1.A1_EST = 'EX'										" + CRLF
	cQuery += " 						INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD2.D2_TES   " + CRLF 
	cQuery += " 							AND "+RetSqlDel("SF4") 	 								  	  + CRLF
	cQuery += "                			 	AND SF4.F4_ESTOQUE = 'S'                                	" + CRLF
	cQuery += "                			 	AND SF4.F4_PODER3 = 'N'                                 	" + CRLF
	cQuery += "                 			AND SF4.F4_FILIAL = SD2.D2_FILIAL                           " + CRLF
	cQuery += "							WHERE SD2.D2_TIPO = 'N'											" + CRLF
	cQuery += "								AND SD2.D2_ORIGLAN = ' '									" + CRLF
	cQuery += "								AND SD2.D2_LOCAL NOT IN('06')								" + CRLF // Alteração Projeto 2020
//	cQuery += "								AND SD2.D2_LOCAL >= '01'									" + CRLF // Alteração Projeto 2020
//	cQuery += "								AND SD2.D2_LOCAL <= '11'									" + CRLF // Alteração Projeto 2020
	cQuery += "								AND "+RetSqlDel("SD2")										  + CRLF
	cQuery += "								AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'					" + CRLF
	cQuery += "                 			AND SD2.D2_EMISSAO >= '"+cDataInicio+"'						" + CRLF 
	cQuery += "                 			AND SD2.D2_EMISSAO <= '"+cDataFim+"'						" + CRLF
	cQuery += "								AND SD2.D2_COD IN (											" + CRLF
	cQuery += "									SELECT B1_COD											" + CRLF
	cQuery += "									FROM "+RetSqlName("SB1")+" T9 							" + CRLF
	cQuery += "									INNER JOIN "+RetSqlName("SBZ")+" T10 					" + CRLF
	cQuery += "										ON T10.BZ_COD = T9.B1_COD 							" + CRLF
	cQuery += "										AND T10.D_E_L_E_T_ = ' '							" + CRLF
	cQuery += "									WHERE T9.B1_TIPO = SB1.B1_TIPO							" + CRLF
	cQuery += "										AND T10.BZ_ZZMAPA = SBZ.BZ_ZZMAPA					" + CRLF
	cQuery += "										AND T10.D_E_L_E_T_ = ' '							" + CRLF
	cQuery += "									)														" + CRLF
	cQuery += "							) AS D2_EXPORTADOS												" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT RTRIM(XMLAGG(XMLELEMENT(e, NOME_PAIS || ',')).EXTRACT('//text()'), ',')" + CRLF
	cQuery += "							FROM (															" + CRLF
	cQuery += "								SELECT RTRIM(SYA.YA_DESCR) NOME_PAIS						" + CRLF
	cQuery += "									,RTRIM(SB1.B1_TIPO) AS TIPO_PROD						" + CRLF
	cQuery += "									,RTRIM(SBZ.BZ_ZZMAPA) AS MAPA_PROD						" + CRLF
	cQuery += "								FROM "+RetSqlTab("SD2")										  + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SA1")+" ON A1_COD = D2_CLIENTE 		" + CRLF
	cQuery += "									AND SA1.A1_LOJA = SD2.D2_LOJA							" + CRLF
	cQuery += "									AND SA1.A1_EST = 'EX'									" + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SB1")+" ON SB1.B1_COD = SD2.D2_COD  " + CRLF
	cQuery += "									AND "+RetSqlDel("SB1")									  + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SBZ")+" ON SBZ.BZ_COD = SB1.B1_COD  " + CRLF
	cQuery += "									AND "+RetSqlDel("SBZ")									  + CRLF
	cQuery += "									AND SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'				" + CRLF
	cQuery += "								INNER JOIN "+RetSqlTab("SYA")+" ON SA1.A1_PAIS = SYA.YA_CODGI" + CRLF
	cQuery += "									AND "+RetSqlDel("SYA")									  + CRLF
	cQuery += " 							INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD2.D2_TES " + CRLF 
	cQuery += " 								AND "+RetSqlDel("SF4") 	 								  + CRLF
	cQuery += "                				 	AND SF4.F4_ESTOQUE = 'S'                                " + CRLF
	cQuery += "                				 	AND SF4.F4_PODER3 = 'N'                                 " + CRLF
	cQuery += "                 				AND SF4.F4_FILIAL = SD2.D2_FILIAL                       " + CRLF
	cQuery += "								WHERE 1 = 1 												" + CRLF
	cQuery += "									AND SD2.D2_TIPO = 'N' 									" + CRLF
	cQuery += "									AND SD2.D2_ORIGLAN = ' '								" + CRLF
	cQuery += "								    AND SD2.D2_LOCAL >= '01'								" + CRLF
	cQuery += "								    AND SD2.D2_LOCAL <= '11'								" + CRLF
	cQuery += "									AND "+RetSqlDel("SD2")									  + CRLF
	cQuery += "									AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'				" + CRLF
	cQuery += "                 				AND SD2.D2_EMISSAO >= '"+cDataInicio+"'					" + CRLF 
	cQuery += "                 				AND SD2.D2_EMISSAO <= '"+cDataFim+"'					" + CRLF
	cQuery += "								GROUP BY SYA.YA_DESCR 										" + CRLF
	cQuery += "									,SB1.B1_TIPO											" + CRLF
	cQuery += "									,SBZ.BZ_ZZMAPA											" + CRLF
	cQuery += "								ORDER BY SYA.YA_DESCR										" + CRLF
	cQuery += "								)															" + CRLF
	cQuery += "							WHERE TIPO_PROD = RTRIM(SB1.B1_TIPO)							" + CRLF
	cQuery += "								AND MAPA_PROD = RTRIM(SBZ.BZ_ZZMAPA)						" + CRLF
	cQuery += "							) AS A1_PAISES													" + CRLF
	cQuery += "						,(																	" + CRLF
	cQuery += "							SELECT SUM(SD1.D1_QUANT)										" + CRLF
	cQuery += "							    FROM "+RetSqlTab("SD1")										  + CRLF
	cQuery += " 							INNER JOIN "+RetSqlTab("SF4")+" ON SF4.F4_CODIGO = SD1.D1_TES " + CRLF 
	cQuery += " 								AND "+RetSqlDel("SF4") 	 								  + CRLF
	cQuery += "                				 	AND SF4.F4_ESTOQUE = 'S'                                " + CRLF
	cQuery += "                				 	AND SF4.F4_PODER3 = 'N'                                 " + CRLF
	cQuery += "                 				AND SF4.F4_FILIAL = SD1.D1_FILIAL                       " + CRLF
	cQuery += "							WHERE SD1.D1_TIPO IN('D','B')									" + CRLF
//	cQuery += "								AND SD1.D1_LOCAL = '05'										" + CRLF // Alteração Projeto 2020
	cQuery += "								AND "+RetSqlDel("SD1")										  + CRLF
	cQuery += "                 			AND SD1.D1_DTDIGIT >= '"+cDataInicio+"'						" + CRLF 
	cQuery += "                 			AND SD1.D1_DTDIGIT <= '"+cDataFim+"'						" + CRLF
	cQuery += "								AND SD1.D1_FILIAL = '"+xFilial("SD1")+"'					" + CRLF
	cQuery += "								AND SD1.D1_COD IN ( 										" + CRLF
	cQuery += "									SELECT B1_COD											" + CRLF
	cQuery += "									FROM "+RetSqlName("SB1")+" T11							" + CRLF
	cQuery += "									INNER JOIN "+RetSqlName("SBZ")+" T12 					" + CRLF
	cQuery += " 									ON T12.BZ_COD = T11.B1_COD							" + CRLF
	cQuery += "										AND T12.D_E_L_E_T_ = ' '							" + CRLF
	cQuery += "									WHERE T11.B1_TIPO = SB1.B1_TIPO							" + CRLF
	cQuery += "										AND T12.BZ_ZZMAPA = SBZ.BZ_ZZMAPA					" + CRLF
	cQuery += "									)														" + CRLF
	cQuery += "							) AS D1_CONDREVENDA												" + CRLF
	cQuery += "                      ,(																	" + CRLF
	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_CF = 'PR0'	 													" + CRLF															
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE T15.B1_TIPO = SB1.B1_TIPO									" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS D3_MOV 																" + CRLF
	cQuery += "                      ,(																	" + CRLF
	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_CF = 'DE4'	 													" + CRLF															
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE T15.B1_TIPO = SB1.B1_TIPO									" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
	cQuery += "		   		) AS D3_TRFENT 																" + CRLF
	cQuery += "                      ,(																	" + CRLF
	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_CF = 'RE4'	 													" + CRLF															
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE T15.B1_TIPO = SB1.B1_TIPO									" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS D3_TRFSAI 																" + CRLF
	cQuery += "                      ,(																	" + CRLF
	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_CF = 'DE7'	 													" + CRLF															
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE T15.B1_TIPO = SB1.B1_TIPO									" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS D3_DESENT 																" + CRLF
	cQuery += "                      ,(																	" + CRLF
	cQuery += "				SELECT SUM(D3_QUANT) FROM "+RetSqlTab("SD3") 								  + CRLF
 	cQuery += "				WHERE "+RetSqlDel("SD3") 													  + CRLF
 	cQuery += "				AND SD3.D3_EMISSAO >= '"+cDataInicio+"' 									" + CRLF	
 	cQuery += "				AND SD3.D3_EMISSAO <= '"+cDataFim+"'										" + CRLF									
 	cQuery += "				AND SD3.D3_CF = 'RE7'	 													" + CRLF															
 	cQuery += "				AND SD3.D3_FILIAL = '"+xFilial("SD3")+"'									" + CRLF
 	cQuery += "				AND SD3.D3_COD IN (															" + CRLF													
 	cQuery += "							SELECT B1_COD 													" + CRLF														
 	cQuery += "							FROM "+RetSqlName("SB1")+" T15 									" + CRLF 										
 	cQuery += "							INNER JOIN "+RetSqlName("SBZ")+" T16 ON T16.BZ_COD = T15.B1_COD	" + CRLF	
 	cQuery += "								AND T16.D_E_L_E_T_ = ' ' 									" + CRLF											
 	cQuery += "								AND T16.BZ_FILIAL = '"+xFilial("SBZ")+"'					" + CRLF							
 	cQuery += "							WHERE T15.B1_TIPO = SB1.B1_TIPO									" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS D3_DESSAI 																" + CRLF
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
 	cQuery += "							WHERE T15.B1_TIPO = SB1.B1_TIPO									" + CRLF								
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
 	cQuery += "							WHERE T15.B1_TIPO = SB1.B1_TIPO									" + CRLF								
 	cQuery += "							AND BZ_ZZMAPA = SBZ.BZ_ZZMAPA									" + CRLF					
 	cQuery += "							AND T15.D_E_L_E_T_ = ' '										" + CRLF							
 	cQuery += "					)																		" + CRLF																	
 	cQuery += "		   		) AS INVENT_SUBTRAI															" + CRLF															
	cQuery += "					FROM "+RetSqlTab("SB1")													  
	cQuery += "					INNER JOIN "+RetSqlTab("SBZ")+" ON SB1.B1_COD = SBZ.BZ_COD				" + CRLF
	cQuery += "						AND "+RetSqlDel("SBZ")												  + CRLF
	cQuery += "						AND "+RetSqlFil("SBZ")												  + CRLF
	If cTipo == "2-Organomineral"
		cQuery += "						AND BZ_ZZORGAN = 'S'											" + CRLF
	Else
		cQuery += "						AND BZ_ZZMINER = 'S'											" + CRLF
	Endif
	cQuery += "					WHERE 1 = 1																" + CRLF
	cQuery += "						AND "+RetSqlDel("SB1")												  + CRLF
	cQuery += "						AND B1_TIPO = 'PA'													" + CRLF
	cQuery += "					GROUP BY SB1.B1_TIPO													" + CRLF
	cQuery += "						,SBZ.BZ_ZZMAPA														" + CRLF
	cQuery += "						,SB1.B1_UM															" + CRLF
	cQuery += "					ORDER BY SB1.B1_TIPO													" + CRLF
	cQuery += "					) TAB1																	" + CRLF
	cQuery += "				) TAB2																		" + CRLF
	cQuery += "			WHERE TAB2.B9_QINI > 0															" + CRLF


	MemoWrite("\sql\QQREST02_getQryReport.sql",cQuery)
	
	If lChangeQuery
		cQuery := ChangeQuery(cQuery) 
	Endif
		
Return cQuery

Static Function gerarReport(aDadosCab, oParamBox)
	
	cCaminho := AllTrim(oParamBox:getValue("DESTINO"))
	If Substr(cCaminho,Len(cCaminho),1) != "\"
		cCaminho += "\"
	Endif
	oExcelXML := zExcelXML():New(.F.)								    //Instância o Objeto
	oExcelXML:SetOrigem("\xmls\QQREST02.xml")						    //Indica o caminho do arquivo Origem (que será aberto e clonado)
	oExcelXML:SetDestino(cCaminho+"RESULT_QQREST02.xml")				//Indica o caminho do arquivo Destino (que será gerado)
	
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
	
	TCQuery createQuery(oParamBox, aDadosCab[10]) New Alias "QRY_ITENS"
	
	oExcelXML:AddTabExcel("#TABELA_REPORT", "QRY_ITENS")			//Adiciona tabela dinâmica

	oExcelXML:MountFile()											//Monta o arquivo
	oExcelXML:ViewSO()
	
	oExcelXML:Destroy(.F.)

	QRY_ITENS->(DbCloseArea())
Return
