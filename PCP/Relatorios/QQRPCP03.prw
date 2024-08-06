#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} QQRPCP03

	Relatório de mapa - Produto Acabado, a granel e embalado

@author Maurício Urbinati de Pádua
@since	21/06/2016

/*/

User Function QQRPCP03()
	Local lRet				:= .T.
	Local aDadosCab			:= {}   
	Local cObjParambox		:= "ParamQQRPCP03"
	Local oParamBox 		:= IpParamBoxObject():newIpParamBoxObject(cObjParambox)
	
	addFilter(@oParamBox)
	If oParamBox:show()
		loadCab(@aDadosCab, oParamBox)
	Endif
	
	If lRet
		gerarReport(aDadosCab, oParamBox)
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
Return

Static Function loadCab(aDadosCab, oParamBox)
	dbSelectArea("SM0")  
	
	AADD(aDadosCab, ALLTRIM(SM0->M0_NOMECOM))						//ESTABELECIMENTO
	AADD(aDadosCab, ALLTRIM(SM0->M0_ENDCOB))						//ENDEREÇO
	AADD(aDadosCab, ALLTRIM(SM0->M0_CEPCOB))						//CEP
	AADD(aDadosCab, ALLTRIM(SM0->M0_CIDCOB))						//CIDADE
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_MAILEMP", .F., "")))		//EMAIL
	AADD(aDadosCab, ALLTRIM(SM0->M0_TEL))							//FONE
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_NOMCPFR", .F., "")))		//NOME DO RESPONSÁVEL
	AADD(aDadosCab, ALLTRIM(SM0->M0_CIDCOB) + ", " + cValToChar(Day(Date())) + " de " + cValToChar(MesExtenso(Month(Date()))) + " " + cValToChar(Year(Date())))		//LOCAL E DATA
	AADD(aDadosCab, ALLTRIM(SM0->M0_CGC))							//CNPJ
	AADD(aDadosCab, ALLTRIM(SM0->M0_ESTCOB))						//ESTADO
	AADD(aDadosCab, ALLTRIM(oParamBox:getValue("TRIMESTRE")))		//TRIMESTRE
	AADD(aDadosCab, ALLTRIM(oParamBox:getValue("ANO")))				//ANO
	AADD(aDadosCab, ALLTRIM(SUPERGETMV("ZZ_NUMREGI", .F., "")))		//REGISTRO NUMERO
Return 

Static Function createQuery(oParamBox)
	Local cQuery		:= ""
	Local lChangeQuery	:= .F.
	Local cDataInicio	:= ""
	Local cDataFim		:= ""
	
	If oParamBox:getValue("TRIMESTRE") == "I (Primeiro)"
		cDataInicio := oParamBox:getValue("ANO") + "0101"
		cDataFim 	:= oParamBox:getValue("ANO") + "0331"
	ElseIf oParamBox:getValue("TRIMESTRE") == "II (Segundo)"
		cDataInicio := oParamBox:getValue("ANO") + "0401"
		cDataFim 	:= oParamBox:getValue("ANO") + "0630"
	ElseIf oParamBox:getValue("TRIMESTRE") == "III (Terceiro)"
		cDataInicio := oParamBox:getValue("ANO") + "0701"
		cDataFim 	:= oParamBox:getValue("ANO") + "0930"
	ElseIf oParamBox:getValue("TRIMESTRE") == "IV (Quarto)"
		cDataInicio := oParamBox:getValue("ANO") + "1001"
		cDataFim 	:= oParamBox:getValue("ANO") + "1231"
	EndIf	
	
	cQuery += "SELECT" + CRLF
	cQuery += "     Trim(SB1.B1_DESC) AS B1_DESC, Trim(SBZ.BZ_ZZMAPA) AS BZ_ZZMAPA, Trim(SB1.B1_UM) AS B1_UM, " + CRLF
	cQuery += "     SUM(SBZ.BZ_ZZK20) AS BZ_ZZK20, SUM(SBZ.BZ_ZZCA) AS BZ_ZZCA, SUM(SBZ.BZ_ZZMG)    AS BZ_ZZMG," + CRLF
    cQuery += "     SUM(SBZ.BZ_ZZS)   AS BZ_ZZS,   SUM(SBZ.BZ_ZZB)  AS BZ_ZZB,  SUM(SBZ.BZ_ZZCI)    AS BZ_ZZCI," + CRLF
	cQuery += "     SUM(SBZ.BZ_ZZCO)  AS BZ_ZZCO,  SUM(SBZ.BZ_ZZCU) AS BZ_ZZCU, SUM(SBZ.BZ_ZZFE)    AS BZ_ZZFE," + CRLF
 	cQuery += "     SUM(SBZ.BZ_ZZMN)  AS BZ_ZZMN,  SUM(SBZ.BZ_ZZMO) AS BZ_ZZMO, SUM(SBZ.BZ_ZZNI)    AS BZ_ZZNI," + CRLF
    cQuery += "     SUM(SBZ.BZ_ZZSI)  AS BZ_ZZSI,  SUM(SBZ.BZ_ZZZN) AS BZ_ZZZN, SUM(SBZ.BZ_ZZTOTAL) AS BZ_ZZN," + CRLF
    cQuery += "     SUM(SB9.B9_VINI1) AS B9_VINI," + CRLF
	cQuery += "     (SELECT SUM(SD1.D1_QUANT) FROM " + RetSqlTab("SD1") + " LEFT JOIN " + RetSqlTab("SA2") + " ON SD1.D1_FORNECE = SA2.A2_COD WHERE SD1.D1_TIPO = 'N' AND  " + RetSqlDel("SD1") + " AND SA2.A2_EST <> 'EX' AND SD1.D1_COD IN (SELECT B1_COD FROM SB1G10 WHERE B1_DESC = SB1.B1_DESC )) AS D1_NACIONAL, " + CRLF
	cQuery += "     (SELECT SUM(SD1.D1_QUANT) FROM " + RetSqlTab("SD1") + " LEFT JOIN " + RetSqlTab("SA2") + " ON SD1.D1_FORNECE = SA2.A2_COD WHERE SD1.D1_TIPO = 'N' AND  " + RetSqlDel("SD1") + " AND SA2.A2_EST = 'EX' AND SD1.D1_COD IN (SELECT B1_COD FROM SB1G10 WHERE B1_DESC = SB1.B1_DESC )) AS D1_IMPORTADO, " + CRLF
	//cQuery += "     (SELECT SUM(SD3.D3_QUANT) FROM " + RetSqlTab("SD3") + " WHERE " + RetSqlDel("SD3") + " AND SD3.D3_CF = 'RE1' AND SD3.D3_EMISSAO >= '" + cDataInicio + "' AND SD3.D3_EMISSAO <= '" + cDataFim + "' AND SD3.D3_COD IN (SELECT B1_COD FROM SB1G10 WHERE B1_DESC = SB1.B1_DESC )) AS D3_QUANT " + CRLF
	cQuery += "     SUM(SD3.D3_QUANT) AS D3_QUANT" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "      " + RetSqlTab("SB1") + CRLF
	cQuery += "      LEFT JOIN " + RetSqlTab("SBZ") + " ON SB1.B1_COD = SBZ.BZ_COD" + CRLF
	cQuery += "      LEFT JOIN " + RetSqlTab("SB9") + " ON SB1.B1_COD = SB9.B9_COD" + CRLF
	cQuery += "      			AND SB9.B9_DATA <= '"+cDataInicio+" AND SB9.B9_DATA >= '"+dtos(stod(cDataFim)-30)+"'"
	cQuery += "      LEFT JOIN " + RetSqlTab("SD3") + " ON SB1.B1_COD = SD3.D3_COD" + CRLF
	cQuery += "       			AND SD3.D3_EMISSAO >= '" + cDataInicio + "' AND SD3.D3_EMISSAO <= '" + cDataFim + "'" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "       1 = 1" + CRLF
	cQuery += "       AND " + RetSqlDel("SB1") + CRLF
	cQuery += "       AND " + RetSqlDel("SBZ") + CRLF
	cQuery += "       AND " + RetSqlDel("SD3") + CRLF
	cQuery += "       AND SD3.D3_CF = 'PR0'" + CRLF
	cQuery += "       AND SD3.D3_EMISSAO >= '" + cDataInicio + "' AND SD3.D3_EMISSAO <= '" + cDataFim + "'" + CRLF	
	cQuery += "GROUP BY" + CRLF
	cQuery += "       SB1. B1_DESC, SBZ.BZ_ZZMAPA, SB1.B1_UM" + CRLF
	cQuery += "ORDER BY" + CRLF
	cQuery += "       SB1.B1_DESC"
	
	MemoWrite("\sql\QQRPCP03_getQryReport.sql",cQuery)
	
	If lChangeQuery
		cQuery := ChangeQuery(cQuery) 
	Endif
		
Return cQuery

Static Function gerarReport(aDadosCab, oParamBox)
	Local oExcel  			:= Nil
	
	oExcelXML := zExcelXML():New(.F.)								//Instância o Objeto
	oExcelXML:SetOrigem("\xmls\QQRPCP03.xml")						//Indica o caminho do arquivo Origem (que será aberto e clonado)
	oExcelXML:SetDestino(GetTempPath() + "RESULT_QQRPCP03.xml")				//Indica o caminho do arquivo Destino (que será gerado)
	//oExcelXML:SetDestino("T:\totvs\teste\protheus12_data\xmls\RESULT_QQRPCP03.xml")				//Indica o caminho do arquivo Destino (que será gerado)
	
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
Return