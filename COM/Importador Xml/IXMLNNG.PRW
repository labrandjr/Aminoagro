#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IXMLNNG  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 21/10/2021      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Listados dos documentos não gerados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IXMLNNG()

Local cPerg      := "COMR002"
Private cPath    := "c:\report\"
Private aColunas := {}
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab02()()})
		Processa({|| pAmnR02()})
		Processa({|| pImpR02()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab02   ¦ Autor ¦ Fábrica ERPBR  ¦ Data  ¦ 21/10/2021    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab02()

Local _aTmp  := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_TIPDOC"  , "C", 003, 00} )
AAdd ( _aTmp, {"TF_EMISSA"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_SERIE"   , "C", 003, 00} )
AAdd ( _aTmp, {"TF_DOC"     , "C", 009, 00} )
AAdd ( _aTmp, {"TF_MODELO"  , "C", 002, 00} )
AAdd ( _aTmp, {"TF_TOTAL"   , "N", 018, 02} )
AAdd ( _aTmp, {"TF_CHVNFE"  , "C", 044, 00} )
AAdd ( _aTmp, {"TF_CNPJ"    , "C", 014, 00} )
AAdd ( _aTmp, {"TF_FORNEC"  , "C", 050, 00} )
AAdd ( _aTmp, {"TF_CFOP"    , "C", 004, 00} )
AAdd ( _aTmp, {"TF_PRODUT"  , "C", 050, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 050, 00} )
AAdd ( _aTmp, {"TF_TELEF"   , "C", 020, 00} )
AAdd ( _aTmp, {"TF_INFO"    , "C", 200, 00} )
AAdd ( _aTmp, {"TF_INCON"   , "C", 200, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_EMISSA", "TF_SERIE", "TF_DOC"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR02   ¦ Autor ¦ Fábrica ERPBR  ¦ Data  ¦ 21/10/2021    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR02()

Local nRecSM0 := SM0->(Recno())
Local xFilOri := cFilAnt
Local lSelFil := (mv_par03 == 1)
Local nForFilial
Local aFilsCalc

aFilsCalc := MatFilCalc( lSelFil )
ProcRegua(Len(aFilsCalc))
For nForFilial := 1 To Len(aFilsCalc)

	IncProc("Extraindo dados...")

	If aFilsCalc[nForFilial][1]

		cFilAnt := aFilsCalc[nForFilial][2]

		// 1 - Xml não gerados
		cQuery := " SELECT DS_FILIAL FILIAL, DS_CHAVENF CHAVENF "
		cQuery += " FROM "+RetSqlName("SDS")
		cQuery += " WHERE DS_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND DS_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
		cQuery += " AND DS_STATUS <> 'P' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY DS_FILIAL, DS_DOC, DS_SERIE, DS_FORNEC "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()

			DbSelectArea("SDS")
			DbSetOrder(2)
			If DbSeek( SQL->FILIAL + SQL->CHAVENF )

				zCfop  := ""
				zProd  := ""
				zInfo  := ""
				cAviso := ""
				cErro  := ""
				zTipo  := ""

				If SDS->DS_TIPO == "T" .And. SDS->DS_ZCANC <> "S"
					zTipo := "Ct-e não cadastrado"
				ElseIf SDS->DS_ZCOMB <> "S" .And. SDS->DS_ZCANC <> "S"
					zTipo := "Nf-e não cadastrada"
				ElseIf SDS->DS_ZCOMB == "S" .And. SDS->DS_ZCANC <> "S"
					zTipo := "Nf-e Combustível não cadastrada"
				ElseIf SDS->DS_TIPO == "T" .And. SDS->DS_ZCANC == "S"
					zTipo := "Ct-e cancelado"
				ElseIf SDS->DS_ZCOMB <> "S" .And. SDS->DS_ZCANC == "S"
					zTipo := "Nf-e cancelada"
				ElseIf SDS->DS_ZCOMB == "S" .And. SDS->DS_ZCANC == "S"
					zTipo := "Nf-e Combustível cancelada"
				Endif

				DbSelectArea("SDT")
				DbSetOrder(1)
				If DbSeek( SDS->(DS_FILIAL+DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE) )

					zCfop := SDT->DT_CODCFOP
					zProd := Posicione("SB1",1,xFilial("SB1")+SDT->DT_COD,"B1_DESC")
					zArqu := PadR(AllTrim(SDS->DS_ARQUIVO),30)
					DbSelectArea("CKO")
					DbSetOrder(1)
					If DbSeek( zArqu )
						zXmlTx := AllTrim(CKO->CKO_XMLRET)
						oXml := XmlParser(zXmlTx, "_", @cAviso, @cErro)
						If Type("oXml:_NfeProc") == "O"
							zMode := oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_mod:TEXT
							zInfo := IIf(Type("oXml:_NfeProc:_Nfe:_InfNfe:_infAdic:_infCpl") == "U", "", oXml:_NfeProc:_Nfe:_InfNfe:_infAdic:_infCpl:TEXT)
							If SDS->DS_ZCOMB == "S"
								oDet := oXml:_NfeProc:_Nfe:_InfNfe:_Det
								oDet := IIf( ValType(oDet) == "O", {oDet}, oDet )
								If Len(oDet) > 0
									zProd := oDet[1]:_prod:_xProd:TEXT
								Endif	
							Endif
						Else
							If Type("oXml:_CteProc") == "O"
								zMode := oXml:_CteProc:_Cte:_InfCte:_Ide:_mod:TEXT
								zCfop := oXml:_CteProc:_Cte:_InfCte:_Ide:_CFOP:TEXT
							Endif
						Endif	
					Endif	

					zNome := ""
					zTele := ""
					If SDS->DS_TIPO $("D")
						zNome := Posicione("SA1",1,xFilial("SA1")+SDS->(DS_FORNEC+DS_LOJA),"A1_NOME")
						zTele := Posicione("SA1",1,xFilial("SA1")+SDS->(DS_FORNEC+DS_LOJA),"A1_TEL")
					Else
						zNome := Posicione("SA2",1,xFilial("SA2")+SDS->(DS_FORNEC+DS_LOJA),"A2_NOME")
						zTele := Posicione("SA2",1,xFilial("SA2")+SDS->(DS_FORNEC+DS_LOJA),"A2_TEL")
					Endif
					//					
					If !u_ChvExist(SDS->DS_CHAVENF)
						DbSelectArea("TRB")
						RecLock("TRB",.T.)
						TRB->TF_FILIAL := cFilAnt
						TRB->TF_TIPDOC := IIf(SDS->DS_TIPO=="T","CTE","NFE")
						TRB->TF_EMISSA := SDS->DS_EMISSA
						TRB->TF_SERIE  := SDS->DS_SERIE
						TRB->TF_DOC    := SDS->DS_DOC
						TRB->TF_MODELO := zMode
						TRB->TF_TOTAL  := SDS->DS_VALMERC
						TRB->TF_CHVNFE := SDS->DS_CHAVENF
						TRB->TF_CNPJ   := SDS->DS_CNPJ
						TRB->TF_FORNEC := zNome
						TRB->TF_CFOP   := zCfop
						TRB->TF_PRODUT := zProd
						TRB->TF_TIPO   := zTipo
						TRB->TF_TELEF  := zTele
						TRB->TF_INFO   := zInfo
						MsUnLock()
					Endif	
				Endif
				
			Endif	

			DbSelectArea("SQL")
			SQL->(DbSkip())
		Enddo
		SQL->(DbCloseArea())

		// 2 - Xmls inconsistentes
		cQuery := " SELECT CKO_ARQUIV ARQUIV "
		cQuery += " FROM "+RetSqlName("CKO")
		cQuery += " WHERE CKO_FILPRO = '"+cFilAnt+"' " 
		cQuery += " AND CKO_CODERR <> ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY CKO_ARQUIV "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()

			DbSelectArea("CKO")
			DbSetOrder(1)
			If DbSeek( SQL->ARQUIV )

				zCfop  := ""
				zProd  := ""
				zInfo  := ""
				cAviso := ""
				cErro  := ""
				zTipo  := ""
				zXmlTx := AllTrim(CKO->CKO_XMLRET)

				oXml := XmlParser(zXmlTx, "_", @cAviso, @cErro)
				If Type("oXml:_NfeProc") == "O"
					dDatEmi := Substring(Alltrim(oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_dhEmi:TEXT),1,10)
					dDatEmi	:= CtoD(Right(dDatEmi,2)+"/"+Substr(dDatEmi,6,2)+"/"+Left(dDatEmi,4))
					cChvNfe := oXml:_NfeProc:_ProtNFe:_InfProt:_chNFe:TEXT
					zTotal  := IIf(Type("oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vNF") == "U", 0, Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vNF:TEXT) )
					zCnpj   := IIf(Type("oXml:_NfeProc:_Nfe:_InfNfe:_Emit:_CNPJ:TEXT") == "U", "", oXml:_NfeProc:_Nfe:_InfNfe:_Emit:_CNPJ:TEXT )
					If Empty(zCnpj)
						zCnpj := IIf(Type("oXml:_NfeProc:_Nfe:_InfNfe:_Emit:_CPF:TEXT") == "U", "", oXml:_NfeProc:_Nfe:_InfNfe:_Emit:_CPF:TEXT )
					Endif
					zTipo   := "Nf-e Inconsistente"
					zMode   := oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_mod:TEXT
					zInfo   := IIf(Type("oXml:_NfeProc:_Nfe:_InfNfe:_infAdic:_infCpl") == "U", "", oXml:_NfeProc:_Nfe:_InfNfe:_infAdic:_infCpl:TEXT)
					zTele   := IIf(Type("oXml:_NfeProc:_Nfe:_InfNfe:_Emit:_enderEmit:_fone") == "U", "", oXml:_NfeProc:_Nfe:_InfNfe:_Emit:_enderEmit:_fone:TEXT)
					oDet    := oXml:_NfeProc:_Nfe:_InfNfe:_Det
					oDet    := IIf( ValType(oDet) == "O", {oDet}, oDet )
					If Len(oDet) > 0
						zCfop := oDet[1]:_prod:_CFOP:TEXT
						zProd := oDet[1]:_prod:_xProd:TEXT
					Endif	
				Else
					If Type("oXml:_CteProc") == "O"
						dDatEmi := Substring(Alltrim(oXml:_CteProc:_Cte:_InfCte:_Ide:_dhEmi:TEXT),1,10)
						dDatEmi	:= CtoD(Right(dDatEmi,2)+"/"+Substr(dDatEmi,6,2)+"/"+Left(dDatEmi,4))
						cChvNfe := oXml:_CteProc:_ProtCte:_InfProt:_chCte:TEXT
						zTotal  := IIf(Type("oXml:_CteProc:_Cte:_InfCte:_vPrest:_vtPrest") == "U", 0, Val(oXml:_CteProc:_Cte:_InfCte:_vPrest:_vtPrest:TEXT) )
						zCnpj   := oXml:_CteProc:_Cte:_InfCte:_Emit:_CNPJ:TEXT
						zTipo   := "Ct-e Inconsistente"
						zMode   := oXml:_CteProc:_Cte:_InfCte:_Ide:_mod:TEXT
						zInfo   := ""
						zTele   := IIf(Type("oXml:_CteProc:_Cte:_InfCte:_Emit:_enderEmit:_fone") == "U", "", oXml:_CteProc:_Cte:_InfCte:_Emit:_enderEmit:_fone:TEXT)
						zCfop   := oXml:_CteProc:_Cte:_InfCte:_Ide:_CFOP:TEXT
						zProd   := "FRETE"
					Endif
				Endif	
				zNome := CKO->CKO_NOMFOR

				If dDatEmi >= mv_par01 .And. dDatEmi <= mv_par02
					If !u_ChvExist(cChvNfe)
						DbSelectArea("TRB")
						RecLock("TRB",.T.)
						TRB->TF_FILIAL := cFilAnt
						TRB->TF_TIPDOC := Upper(Substr(CKO->CKO_ARQUIV,5,3))
						TRB->TF_EMISSA := dDatEmi
						TRB->TF_SERIE  := CKO->CKO_SERIE
						TRB->TF_DOC    := CKO->CKO_DOC
						TRB->TF_MODELO := zMode
						TRB->TF_TOTAL  := zTotal
						TRB->TF_CHVNFE := cChvNfe
						TRB->TF_CNPJ   := zCnpj
						TRB->TF_FORNEC := zNome
						TRB->TF_CFOP   := zCfop
						TRB->TF_PRODUT := zProd
						TRB->TF_TIPO   := zTipo
						TRB->TF_TELEF  := zTele
						TRB->TF_INFO   := zInfo
						TRB->TF_INCON  := AllTrim(CKO->CKO_MSGERR)
						MsUnLock()
					Endif	
				Endif	
				
			Endif	

			DbSelectArea("SQL")
			SQL->(DbSkip())
		Enddo
		SQL->(DbCloseArea())

	Endif	

Next nForFilial

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pImpR02   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 10/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR02()

Local oExcel := FwMsExcel():New()

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "CKO_XML"
	cNomeTable := "Xml não Cadastrado"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Doc.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Modelo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Chave",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cgc / Cpf",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cfop",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Telefone",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Informações",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Inconsistência",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		zInfor := AllTrim(TRB->TF_INFO)
		zInfor := StrTran(zInfor,",","")
		zInfor := StrTran(zInfor,";","")
		zInfor := StrTran(zInfor,"&","")
		zInfor := StrTran(zInfor,"|","")
		zInfor := StrTran(zInfor,":","")
		zInfor := StrTran(zInfor,"<","")
		zInfor := StrTran(zInfor,">","")
		zInfor := StrTran(zInfor,"{","")
		zInfor := StrTran(zInfor,"}","")
		zInfor := StrTran(zInfor,"=","")
		zInfor := StrTran(zInfor,"+","")
		
        aArray := Array(17)
		aArray[1]  := TRB->TF_FILIAL
		aArray[2]  := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
		aArray[3]  := TRB->TF_TIPDOC
		aArray[4]  := TRB->TF_EMISSA
		aArray[5]  := TRB->TF_SERIE
		aArray[6]  := TRB->TF_DOC
		aArray[7]  := TRB->TF_MODELO
		aArray[8]  := TRB->TF_TOTAL
		aArray[9]  := TRB->TF_CHVNFE
		aArray[10] := TRB->TF_CNPJ
		aArray[11] := TRB->TF_FORNEC
		aArray[12] := TRB->TF_CFOP
		aArray[13] := TRB->TF_PRODUT
		aArray[14] := TRB->TF_TIPO
		aArray[15] := TRB->TF_TELEF
		aArray[16] := zInfor
		aArray[17] := TRB->TF_INCON
		//
		oExcel:AddRow(cNomePlan, cNomeTable, aArray)
		//		
		DbSelectArea("TRB")
		TRB->(DbSkip())

	Enddo
	TRB->(DbCloseArea())
	oTempTable:Delete() 
	
	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "CKO_XML-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChvExist   ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 08/12/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verifica se a chave já foi cadastrada.		              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ChvExist(cChvNfe)

Local aArea := GetArea()
Local lRetX := .F.

cQry := " SELECT COUNT(*)AS SOMA "
cQry += " FROM "+RetSqlName("SF1")
cQry += " WHERE F1_CHVNFE = '"+cChvNfe+"' "
cQry += " AND D_E_L_E_T_ <> '*' "
cQry := ChangeQuery(cQry)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"TRB1", .T., .T.)
lRetX := (TRB1->SOMA > 0)
TRB1->(DbCloseArea())

RestArea(aArea)

Return(lRetX)
