#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função InfoNFe

Altera as informações enviadas ao arquivo XML, incluindo informações adicionais nos itens, e mensagens

@author 	Augusto Krejci Bem-Haja
@since 		09/03/2016
@return		Array
/*/
//-------------------------------------------------------------------

User Function InfoNFe(aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont,aProcRef)
	
	local aArea 	:= Lj7GetArea({"SC5","SC6","SF1","SF2","SD1","SD2","SA1","SA2","SB1","SB5","SF4","SA3","SBZ"})
	local cSerie	 := aNota[01]
	local cDoc		 := aNota[02]
	local cTipo		 := aNota[04]									//Tipo de Entrada/Saída - 0=Entrada / 1=Saída
	local cTipoNF	 := aNota[05]									//Tipo da NF - F2_TIPO / F1_TIPO
	local aRetorno	 := {}
	
	ConOut(cSerie+" | "+cDoc+" | "+cTipoNF)

	If cTipo == "1"//saida
		cMensCli := adicionaMensagens(cMensCli,cMensFis,aProd)
		aProd 	 := adicionaDadosProduto(aProd,@cMensCli)
	Endif
	
	GetMsgSZZ(@cMensCli,@cMensFis,cTipo)
	lastMsg(@cMensCli,aProd)
	aVeiculo := adicionaPlaca(cTipo)
	
	aRetorno := preencheRetorno(aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont,aProcRef)
	
	Lj7RestArea(aArea)
Return aRetorno

Static Function preencheRetorno(aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont,aProcRef)
	Local aRetorno := {}
	
	aadd(aRetorno,aProd)
	aadd(aRetorno,cMensCli)
	aadd(aRetorno,cMensFis)
	aadd(aRetorno,aDest)
	aadd(aRetorno,aNota)
	aadd(aRetorno,aInfoItem)
	aadd(aRetorno,aDupl)
	aadd(aRetorno,aTransp)
	aadd(aRetorno,aEntrega)
	aadd(aRetorno,aRetirada)
	aadd(aRetorno,aVeiculo)
	aadd(aRetorno,aReboque)
	aadd(aRetorno,aNfVincRur)
	aadd(aRetorno,aEspVol)
	aadd(aRetorno,aNfVinc)
	aadd(aRetorno,aDetPag)
	aadd(aRetorno,aObsCont)
	aadd(aRetorno,aProcRef)
Return aRetorno

static function adicionaPlaca(cTipo)
	
	local aRetorno := {}
	
	if cTipo == '1'
		if !empty(SF2->F2_ZZPLACA)
			aadd(aRetorno, SF2->F2_ZZPLACA)
			aadd(aRetorno, SF2->F2_ZZUFPLA)
			aadd(aRetorno, "")//RNTC
		endIf
	else
		if !empty(SF1->F1_PLACA)
			aadd(aRetorno, SF1->F1_PLACA)
			aadd(aRetorno, SF1->F1_ZZUFPLA)
			aadd(aRetorno, "") //RNTC
		endIf
	endIf
	
return (aRetorno)

Static Function adicionaDadosProduto(aProd,cMensCli)
	Local nI 		:= 1
	Local cInfo		:= ""
	Local cCodProd  := ""
	Local cAlias 	:= ""
	local cChave	:= SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
	Local aTES_CFOP := {}
	Local cAux		:= ""
	
	For nI := 1 To Len(aProd)

		cCodProd := aProd[nI][2]
		cAlias 	 := QryProd(cCodProd)
		cInfo    := ""
		cDescPro := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_DESC")
		
		cAux := InterfaceSB1SBZ("B1_ZGARANT","BZ_ZGARANT",cCodProd)
		If !Empty(cAux)
			cInfo += AllTrim(cAux)+" "
		Endif

		cAux := InterfaceSB1SBZ("B1_ZZNATUR","BZ_ZZNATUR",cCodProd)
		If !empty(cAux)
			If AllTrim(cAux) == "1"			
				cInfo+="Natureza=SUSP HETEROGENEA "
			ElseIf AllTrim(cAux)=="2"
				cInfo+="Natureza=SUSP HOMOGENEA "	
			ElseIf AllTrim(cAux)=="3"
				cInfo+="Natureza=SOLUCAO VERDADEIRA "
			Else 
				cInfo+=	cAux	
			EndIf
		EndIf
		
		cAux := InterfaceSB1SBZ("B1_ZZSOLUB","BZ_ZZSOLUB",cCodProd)
		If !Empty(cAux)
			cInfo += "Rel.Soluto/Solvente="+AllTrim(cAux)+" "
		Endif

		cAux := InterfaceSB1SBZ("B1_ZZIS","BZ_ZZIS",cCodProd)
		If !Empty(cAux)
			cInfo += "I.S.="+AllTrim(cAux)+" "
		Endif

		cAux := InterfaceSB1SBZ("B1_ZZCE","BZ_ZZCE",cCodProd)
		If !Empty(cAux)
			cInfo += "C.E.="+AllTrim(cAux)+" "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZTOTAL","BZ_ZZTOTAL",cCodProd)
		If !Empty(cAux)				
			cInfo += "N="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZP2O5","BZ_ZZP2O5",cCodProd)
		If !Empty(cAux)				
			cInfo += "P="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZK20","BZ_ZZK20",cCodProd)
		If !Empty(cAux)				
			cInfo += "K="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZCA","BZ_ZZCA",cCodProd)
		If !Empty(cAux)				
			cInfo += "Ca="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZMG","BZ_ZZMG",cCodProd)
		If !Empty(cAux)
			cInfo += "Mg="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZS","BZ_ZZS",cCodProd)
		If !Empty(cAux)
			cInfo += "S="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZB","BZ_ZZB",cCodProd)
		If !Empty(cAux)
			cInfo += "B="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZCI","BZ_ZZCI",cCodProd)
		If !Empty(cAux)
			cInfo += "Cl="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZCO","BZ_ZZCO",cCodProd)
		If !Empty(cAux)
			cInfo += "Co="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZCU","BZ_ZZCU",cCodProd)
		If !Empty(cAux)
			cInfo += "Cu="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZFE","BZ_ZZFE",cCodProd)
		If !Empty(cAux)
			cInfo += "Fe="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZMN","BZ_ZZMN",cCodProd)
		If !Empty(cAux)
			cInfo += "Mn="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZMO","BZ_ZZMO",cCodProd)
		If !Empty(cAux)
			cInfo += "Mo="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZNI","BZ_ZZNI",cCodProd)
		If !Empty(cAux)
			cInfo += "Ni="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZSI","BZ_ZZSI",cCodProd)
		If !Empty(cAux)
			cInfo += "Si="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZZN","BZ_ZZZN",cCodProd)
		If !Empty(cAux)
			cInfo += "Zn="+cValToChar(cAux)+"% "
		Endif		
		
		cAux := InterfaceSB1SBZ("B1_ZZCAORG","BZ_ZZCAORG",cCodProd)
		If !Empty(cAux)
			cInfo += "Carb.Org.="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZCTC","BZ_ZZCTC",cCodProd)
		If !Empty(cAux)
			cInfo += "CTC="+cValToChar(cAux)+"% "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZDENSI","BZ_ZZDENSI",cCodProd)
		If !Empty(cAux)
			cInfo += "Densidade="+cValToChar(cAux)+" "
		Endif
		
		cAux := InterfaceSB1SBZ("B1_ZZMAPA","BZ_ZZMAPA",cCodProd)
		If !Empty(cAux)
			cInfo += "Registro MAPA="+cValToChar(cAux)+" "
		Endif
		
		SBZ->(DbSetOrder(1))
		if SBZ->(MsSeek(xFilial("SBZ")+cCodProd))
			
			If !empty(SBZ->BZ_ZZPFCI)
				cInfo += "Resolução Senado Federal nr. 13/12. " 
				cInfo += "Número FCI = "+AllTrim(SBZ->BZ_ZZFCI)+ "  
				cInfo += "C.I. = "+AllTrim(cValToChar(SBZ->BZ_ZZPFCI))+"% "								
			EndIf
			
		EndIf
		
		If !Empty(aProd[nI][19])
			cInfo += "No. Lote: "+AllTrim(aProd[nI][19])
			cFami := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_ZFAMILI")
			pFami := AllTrim(GetMv("MV_ZFAMDLT"))
			If !Empty(pFami)
				If cFami $(pFami)
					cArmz := Posicione("SC6",1,xFilial("SC6")+aProd[nI][38]+aProd[nI][39],"C6_LOCAL")
					DbSelectArea("SB8")
					DbSetOrder(3)
					If DbSeek( xFilial("SB8") + cCodProd + cArmz + aProd[nI][19] )
						cInfo += " Valid.: "+DtoC(SB8->B8_DTVALID)
					Endif
				Endif
			Endif	
		Endif		

		// Preencho aProd[nI][25] com os campos personalizados da SB1 + o lote do item.
		aProd[nI][25] += cInfo			
			
		// Descrição do SB1
		aProd[nI][4] := cDescPro

		buscaMsgSZ6(cChave,@cMensCli,aProd[nI,1],aProd[nI,2],@aTES_CFOP)
		
	Next nI
Return aProd

static function buscaMsgSZ6(cChave,cMensCli,cItem,cProd,aTES_CFOP)
	
	Local cQuery 	:= ""
	Local cAlias 	:= GetNextAlias()
	Local nRegistros:= 0
	Local cNovaChave:= cChave+cProd+padl(cItem,tamsx3("D2_ITEM")[1],"0")	
	Local cTesCFOP	:= ""
	
	ConOut(cAlias)

	cQuery :=" SELECT " 									+ CRLF
	cQuery +=" SZ6.Z6_TES, SZ6.Z6_CFOP, SZ6.Z6_MENS" 		+ CRLF
	cQuery +=" FROM " 										+ CRLF
	cQuery +=" "+RetSqlName("SD2")+" SD2" 					+ CRLF
	cQuery +=" INNER JOIN "+RetSqlName("SZ6")+" SZ6 ON" 	+ CRLF
	cQuery +=" SZ6.Z6_FILIAL   = SD2.D2_FILIAL"         	+ CRLF
	cQuery +=" AND SZ6.Z6_TES  = SD2.D2_TES" 		        + CRLF
	cQuery +=" AND SZ6.Z6_CFOP = SD2.D2_CF"	 		        + CRLF
	cQuery +=" WHERE" 								        + CRLF
	cQuery +=" SD2.D_E_L_E_T_=' '" 					        + CRLF
	cQuery +=" AND SZ6.D_E_L_E_T_=' '" 				        + CRLF
	cQuery +=" AND SD2.D2_FILIAL='"+xFilial("SD2")+"'" 		+ CRLF
	cQuery +=" AND SD2.D2_DOC || " 							+ CRLF
	cQuery +=" SD2.D2_SERIE || " 							+ CRLF
	cQuery +=" SD2.D2_CLIENTE || " 							+ CRLF
	cQuery +=" SD2.D2_LOJA || " 							+ CRLF
	cQuery +=" SD2.D2_COD || " 								+ CRLF
	cQuery +=" SD2.D2_ITEM = '"+cNovaChave+"'"				+ CRLF
	
	MemoWrite("SQL2.TXT",cQuery)
	TcQuery cQuery New Alias cAlias
	Count To nRegistros
	cAlias->(DbGoTop())
	
	While cAlias->(!Eof())
	
			cTesCFOP := cAlias->(Z6_TES+Z6_CFOP)
			
			if asCan(aTES_CFOP,{ |x| Upper(AllTrim(x)) == AllTrim(cTesCFOP) }) == 0
				if ! AllTrim(cAlias->Z6_MENS)+"# " $ cMensCli
					cMensCli += AllTrim(cAlias->Z6_MENS)+"# "
				endIf
			endIf
			
			aadd(aTES_CFOP,cTesCFOP)
			
		cAlias->(dbskip())
	EndDo
	
	cAlias->(DbCloseArea())	
	
return

static function lastMsg(cMensCli,aProd)

Local cMVZZMSGNF := SuperGetMV("MV_ZZMSGNF",.T.,"")
Local nI
	
If !Empty(cMVZZMSGNF)
	cMensCli += AllTrim(cMVZZMSGNF) + "# "
Endif

lMsgPA := .F.
For nI := 1 To Len(aProd)
	If RetField("SB1",1,xFilial("SB1")+aProd[nI][2],"B1_TIPO") == "PA"
		lMsgPA := .T.
		Exit
	Endif
Next nI
If lMsgPA
	lExib := .T.
	cFami := RetField("SB1",1,xFilial("SB1")+aProd[1][2],"B1_ZFAMILI")
	pFami := AllTrim(GetMv("MV_ZFAMDLT"))
	If !Empty(pFami)
		If cFami $(pFami)
			lExib := .F.
		Endif
	Endif	
	If lExib
		cMensCli += "Os produtos descritos na nota referem-se a adubos e/ou fertilizantes.# "
	Endif
Endif

return

Static Function adicionaMensagens(cMensCli,cMensFis,aProd)
	Local cMVZZREGMP := SuperGetMV("MV_ZZREGMP",.T.,"")
	Local cZZPROCOM	 := SuperGetMV("ZZ_PROCOM",.F.,"")
	Local cZZCNDNUM	 := SuperGetMV("ZZ_CNDNUM",.F.,"")
	Local cZZCNDEMIS := SuperGetMV("ZZ_CNDEMIS",.F.,"")
	Local cZZCNDVALI := SuperGetMV("ZZ_CNDVALI",.F.,"")
	Local cZZCNDCODA := SuperGetMV("ZZ_CNDCODA",.F.,"")
	
	cMensCli += " "

	// Início - Add No.Carga - 20/11/2018
	aArea   := GetArea()
	aAreaC9 := SC9->(GetArea())
	nRecSC9 := SC9->(Recno())
	DbSelectArea("SC9")
	DbSetOrder(6)
	If DbSeek( xFilial("SC9") + SF2->F2_SERIE + SF2->F2_DOC )
		If !Empty(SC9->C9_CARGA)
			cMensCli += "Carga No.: "+AllTrim(SC9->C9_CARGA) + "# "
		Endif
	Endif
	SC9->(DbGoto(nRecSC9))
	RestArea(aAreaC9)
	RestArea(aArea)
	// Fim - Add No.Carga

	If !Empty(cZZCNDNUM)
		cMensCli += "Dados CND - Numero: "+AllTrim(cZZCNDNUM) + "# "
	Endif
	
	If !Empty(cZZCNDEMIS)
		cMensCli += "Emissao: "+AllTrim(DtoC(cZZCNDEMIS)) + "# "
	Endif
	
	If !Empty(cZZCNDVALI)
		cMensCli += "Validade: "+AllTrim(DtoC(cZZCNDVALI)) + "# "
	Endif
	
	If !Empty(cZZCNDCODA)
		cMensCli += "Cod. Autenticidade: "+AllTrim(cZZCNDCODA) + "# "
	Endif	
		
	If !Empty(cMVZZREGMP)
		lExib := .T.
		cFami := RetField("SB1",1,xFilial("SB1")+aProd[1][2],"B1_ZFAMILI")
		pFami := AllTrim(GetMv("MV_ZFAMDLT"))
		If !Empty(pFami)
			If cFami $(pFami)
				lExib := .F.
			Endif
		Endif	
		If lExib
			cMensCli += "Registro no MAPA: "+AllTrim(cMVZZREGMP) + "# "
		Endif
	Endif
	
	If !Empty(cZZPROCOM)
		cMensCli += AllTrim(cZZPROCOM) + "# "
	Endif
	
	cMensCli := adicEndEntrega(cMensCli)
	
Return cMensCli

Static Function adicEndEntrega(cMensCli)
	Local cCodCli	 := SF2->F2_CLIENTE
	Local cLojaCli 	 := SF2->F2_LOJA
	Local cAlias 	:= ""
	
	cAlias 	 := QryCli(cCodCli,cLojaCli)
	
	If !((cAlias)->(Eof()))
		If !Empty((cAlias)->A1_ENDENT)
			cMensCli += "Dados de Entrega - Endereço: "+AllTrim((cAlias)->A1_ENDENT)+" "
		Endif
		If !Empty((cAlias)->A1_BAIRROE)
			cMensCli += "Bairro: "+AllTrim((cAlias)->A1_BAIRROE)+" "
		Endif
		If !Empty((cAlias)->A1_MUNE)
			cMensCli += "Cidade: "+AllTrim((cAlias)->A1_MUNE)+" "
		Endif
		If !Empty((cAlias)->A1_ESTE)
			cMensCli += "UF: "+AllTrim((cAlias)->A1_ESTE)+" "
		Endif
	Endif
Return cMensCli

Static Function QryProd(cCodProd)
	Local cQuery := ""
	Local cEol   := chr(10) + chr(13)
	Local cAlias := ""
	Local nRegs	 := 0
	
	cAlias := GetNextAlias()
	
	cQuery := " SELECT * FROM " + RetSqlName("SB1") + cEol
	cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'" + cEol
	cQuery += " AND B1_COD = '" + cCodProd + "'"+ cEol
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
	
	TCQUERY cQuery NEW ALIAS &cAlias
	
	Count To nRegs
	(cAlias)->(DbGoTop())
	
Return cAlias

Static Function QryCli(cCodCli,cLojaCli)
	Local cQuery := ""
	Local cEol   := chr(10) + chr(13)
	Local cAlias := ""
	
	cAlias := GetNextAlias()
	
	cQuery := " SELECT * FROM " + RetSqlName("SA1") + cEol
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'" + cEol
	cQuery += " AND A1_COD = '" + cCodCli + "'"+ cEol
	cQuery += " AND A1_LOJA = '" + cLojaCli + "'"+ cEol
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
	
	TCQUERY cQuery NEW ALIAS &cAlias
Return cAlias

Static Function GetMsgSZZ(cMensCli,cMensFis,cTipo)
	Local cAlias := GetNextAlias()
	Local cTexto := ""
	Local cTipoDoc
	
	//Saida
	if cTipo == '1'
		cTipoDoc := 'S'
		BEGINSQL ALIAS cAlias
			SELECT * FROM %TABLE:SZZ% SZZ
			WHERE
			SZZ.%NOTDEL%
			AND SZZ.ZZ_FILIAL = %XFILIAL:SZZ%
			AND SZZ.ZZ_TIPODOC = %exp:cTipoDoc%
			AND SZZ.ZZ_DOC = %EXP:SF2->F2_DOC%
			AND SZZ.ZZ_SERIE = %EXP:SF2->F2_SERIE%
			ORDER BY SZZ.ZZ_SEQMENS
		ENDSQL
		//Nota de Entrada
	Else
		cTipoDoc := 'E'
		BEGINSQL ALIAS cAlias
			SELECT * FROM %TABLE:SZZ% SZZ
			WHERE
			SZZ.%NOTDEL%
			AND SZZ.ZZ_FILIAL = %XFILIAL:SZZ%
			AND SZZ.ZZ_TIPODOC = %exp:cTipoDoc%
			AND SZZ.ZZ_DOC = %EXP:SF1->F1_DOC%
			AND SZZ.ZZ_SERIE = %EXP:SF1->F1_SERIE%
			AND SZZ.ZZ_CLIFOR = %EXP:SF1->F1_FORNECE%
			AND SZZ.ZZ_LOJA = %EXP:SF1->F1_LOJA%
			ORDER BY SZZ.ZZ_SEQMENS
		ENDSQL
	EndIf
	
	(cAlias)->(dbGoTop())
	Do While (cAlias)->(!Eof())
		cTexto   := AllTrim((cAlias)->ZZ_TXTMENS)
		
		If !cTexto $ cMensCli .And. !cTexto $ cMensFis .and. ! empty(cTexto)
			cMensCli += IIf(Empty(cMensCli), "", "") + cTexto + "# " 	
		EndIf
		
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
Return

Static Function InterfaceSB1SBZ(nomCampSB1,nomCampSBZ,codigoProduto)
	
	Local objQualy:=LibQualyQuimica():New() 
	Local cRetorno := objQualy:GetSB1SBZ(nomCampSB1,nomCampSBZ,codigoProduto)

Return cRetorno
