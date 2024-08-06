#Include 'Protheus.ch'
#include "TopConn.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldLin

Função que valida a linha...

@author 	Augusto Krejci Bem-Haja
@since 		25/01/2016
@return		Booleano
/*/
//-------------------------------------------------------------------
User Function VldLin(lCopia,zItemPv,zProduto,zQtdVen,zPrcVen,zCCVend,zUniNeg,lAltCp2)
Local aArea	   := GetArea()
Local lRetorno := .T.
Local lSale    := .F.
Local objQualy

If !lCopia
	objQualy := LibQualyQuimica():New()
	If objQualy:isSale()
		lSale := .T.
	Endif	
Else
	lSale := .T.
Endif	

If lSale .And. FunName() != "MATA311" .And. !lAltCp2
	lRetorno := Validacoes(lCopia,zItemPv,zProduto,zQtdVen,zPrcVen,zUniNeg)
Endif

// Luis Brandini - 10/01/2017
If lRetorno .And. FunName() != "MATA311" .And. !lAltCp2
	lRetorno := CCustoObr(lCopia,zCCVend)
Endif
// Luis Brandini - 10/01/2017

If !lCopia
	freeObj(objQualy)
Endif
	
RestArea(aArea)
Return lRetorno


Static Function Validacoes(lCopia,zItemPv,zProduto,zQtdVen,zPrcVen,zUniNeg)

Local lRetorno  := .T.
Local cItemPv   := IIf(lCopia, zItemPv, aCols[n,GdFieldPos("C6_ITEM")])
Local cProduto  := IIf(lCopia, zProduto, aCols[n,GdFieldPos("C6_PRODUTO")])
Local nQtdVen   := IIf(lCopia, zQtdVen, aCols[n,GdFieldPos("C6_QTDVEN")])
Local nPrcVen   := IIf(lCopia, zPrcVen, aCols[n,GdFieldPos("C6_PRCVEN")])
Local cClient   := IIf(lCopia, SC5->C5_CLIENTE, M->C5_CLIENTE)
Local cFaixaV   := IIf(lCopia, SC5->C5_ZZCDFXV, M->C5_ZZCDFXV)
Local cFaixaR	:= IIf(lCopia, SC5->C5_ZZCDFXR, M->C5_ZZCDFXR)
Local cTipoPed	:= IIf(lCopia, SC5->C5_TIPO, M->C5_TIPO)
Local cNumPed 	:= IIf(lCopia, SC5->C5_NUM, M->C5_NUM)
Local cCultura 	:= ""
Local lDeleted  := IIf(lCopia, .F., (aCols[n,Len(aHeader)+1]))
Local cDescric  := RetField("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
Local cTipoProd := RetField("SB1",1,xFilial("SB1")+cProduto,"B1_TIPO")
Local lBloqVend := ( RetField("SB1",1,xFilial("SB1")+cProduto,"B1_ZBLQVEN") == "1" )
Local cEOL      := CHR(13)+CHR(10)
Local lCultura  := GetMv("MV_ZZCULTU")

// Verifica se a Cultura foi informada
If lCultura
	cCultura := IIf(lCopia, SC5->C5_ZZCULT, M->C5_ZZCULT)
	If Empty(cCultura)
		MsgAlert("Informe a Cultura.")
		Return(.F.)
	Endif
Endif

If ((cTipoPed == "N") .And. (cTipoProd != "SV"))
	If !lDeleted
		If lBloqVend
			lExbMsg := .T.
			If Altera
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek( xFilial("SC6") + cNumPed + cItemPv )
				If nQtdVen <= SC6->C6_QTDENT
					lExbMsg := .F.
				Endif
			Endif
			If lExbMsg
				MsgAlert("Atenção, produto "+AllTrim(cProduto)+" bloqueado p/ Vendas.")
				lRetorno := .F.
			Endif			
		Endif
		aPrcHis := U_PrcHist(cClient,cProduto,cNumPed)
		If nPrcVen < aPrcHis[1]
			MsgAlert("O preço de venda do produto "+AllTrim(cProduto)+" - "+AllTrim(cDescric)+" é menor que "+;
					 "o praticado no histórico desse cliente."+cEOL+;
					 "Preço de Venda no Histórico: R$ "+AllTrim(STR(aPrcHis[1],9,2))+cEOL+;
					 IIf(aPrcHis[2]=="D","Documento: "+aPrcHis[3]+" - Emissão: "+aPrcHis[4] ,"Pedido: "+aPrcHis[3]+" - Emissão: "+aPrcHis[4]))
		Endif
		If !(U_VldCusto(lCopia,cProduto,zUniNeg))
			lRetorno := .F.
		Endif
		If !(U_VldCom("SZ2",cFaixaV,cProduto))
			lRetorno := .F.
		Endif
		If !(U_VldCom("SZ3",cFaixaR,cProduto))
			lRetorno := .F.
		Endif
	Else
		U_ZerEbit()
	Endif
Endif

Return(lRetorno)


// Luis Brandini - 10/01/2017
Static Function CCustoObr(lCopia,zCCVend)
Local lRetorno := .T.
Local cCCusto  := IIf(lCopia,zCCVend,aCols[n][GdFieldPos("C6_CCUSTO")])
Local lDeleted := IIf(lCopia,.F.,(aCols[n][Len(aHeader)+1]))

If !lDeleted
	If Empty(cCCusto)
		MsgAlert("Atenção, centro de custo não informado!"+CHR(13)+CHR(10)+"Verifique o 'Vendedor 1' ou informe manualmente.")
		lRetorno := .F.
	Else
		DbSelectArea("CTT")
		DbSetOrder(1)
		If !DbSeek( xFilial("CTT") + cCCusto )
			MsgAlert("Atenção, centro de custo não cadastrado!")
			lRetorno := .F.
		Else
			If CTT->CTT_CLASSE == "1"
				MsgAlert("Atenção, centro de custo 'sintético' não permitido!")
				lRetorno := .F.
			ElseIf CTT->CTT_BLOQ == "1"
				MsgAlert("Atenção, centro de custo 'bloqueado' não permitido!")
				lRetorno := .F.
			ElseIf Empty(CTT->CTT_ZZITCT)
				MsgAlert("Atenção, centro de custo sem 'Un Negocio' (BU) não permitido!")
				lRetorno := .F.
			Endif
		Endif
	Endif
Endif
Return lRetorno


User Function VldCom(cAliasSZ,cFaixa,cProduto)
Local aArea		:= GetArea()
Local cGrupo	:= RetField("SB1",1,xFilial("SB1")+AllTrim(cProduto),"B1_GRUPO")
Local lRetorno  := .T.
Local cPref	 	:= SubStr(cAliasSZ,2)
Private cAlias	:= ""

If !Empty(cGrupo)
	cAlias := QryRgs(cAliasSZ,cPref,cFaixa,cGrupo)
	(cAlias)->(dbGoTop())
	If cAliasSZ == "SZ2"
		If (cAlias)->(Eof())
			MsgAlert("Atenção, faixa de premiação do Vendedor não cadastrada ou inválida!")
			lRetorno := .F.
		Endif
	Else
		If !(AllTrim(cFaixa) == "") .AND. (cAlias)->(Eof())
			MsgAlert("Atenção, faixa de premiação da Revenda não cadastrada ou inválida!")
			lRetorno := .F.
		Endif
	Endif
	(cAlias)->(DbCloseArea())
Else
	MsgAlert("Atenção, produto não possui Grupo cadastrado.")
Endif

RestArea(aArea)
Return lRetorno

Static Function QryRgs(cAliasSZ,cPref,cFaixa,cGrupo)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local cData  := DtoS(dDatabase)

cQuery := " SELECT * FROM " +RetSqlName(cAliasSZ)
cQuery += " WHERE "+ cPref + "_CODIGO = '" + cFaixa + "' "
cQuery += " AND "+ cPref + "_GRUPO = '" + cGrupo + "' "
cQuery += " AND "+ cPref + "_ATIVO = 'S' "
cQuery += " AND "+ cPref + "_VALID >= '"+ cData +"' "
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQUERY cQuery NEW ALIAS &cAlias
Return cAlias

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PrcHist  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ 24/04/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Busca o menor preço do histórico do cliente.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PrcHist(cClient,cProduto,cNumPed)

Local aArea   := GetArea()
Local aPreco  := {}
Local cAnoAtu := Substr(DtoS(Date()),1,4) 
Local lBusca  := .T.

While lBusca

	aPreco  := {}
	cDatIni := cAnoAtu+"0101"
	cDatFim := cAnoAtu+"1231"

	AAdd(aPreco,0)  // Preço de Venda
	AAdd(aPreco,"") // Documento/Pedido
	AAdd(aPreco,"") // Documento
	AAdd(aPreco,"") // Emissão

	cQuery := " SELECT D2_PRCVEN PRCVEN, D2_EMISSAO EMISSAO, D2_DOC DOC "
	cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
	cQuery += RetSqlName("SF4")+" SF4 "
	cQuery += " WHERE D2_FILIAL = F4_FILIAL "
	cQuery += " AND D2_TES = F4_CODIGO "
	cQuery += " AND D2_COD = '"+cProduto+"' "
	cQuery += " AND D2_CLIENTE = '"+cClient+"' "
	cQuery += " AND D2_TIPO = 'N' "
	cQuery += " AND D2_EMISSAO BETWEEN '"+cDatIni+"' AND '"+cDatFim+"' "
	cQuery += " AND F4_DUPLIC = 'S' "
	cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
	cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY D2_PRCVEN, D2_EMISSAO DESC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
	
	SQL2->(DbGotop())
	If !Eof()
		aPreco[1] := SQL2->PRCVEN
		aPreco[2] := "D"
		aPreco[3] := SQL2->DOC
		aPreco[4] := DtoC(StoD(SQL2->EMISSAO))
	Endif
	SQL2->(DbCloseArea())

	If aPreco[1] > 0 .Or. cAnoAtu == "2016"

		lBusca := .F. // Se achou nota fiscal para o cliente x produto, é priorizada e não pesquiso pedidos.

	Else

		AAdd(aPreco,0)  // Preço de Venda
		AAdd(aPreco,"") // Documento/Pedido
		AAdd(aPreco,"") // Documento
		AAdd(aPreco,"") // Emissão
	
		cQuery := " SELECT C6_PRCVEN PRCVEN, C5_EMISSAO EMISSAO, C5_NUM NUM "
		cQuery += " FROM "+RetSqlName("SC6")+" SC6, "
		cQuery += RetSqlName("SC5")+" SC5, "
		cQuery += RetSqlName("SF4")+" SF4 "
		cQuery += " WHERE C6_FILIAL = C5_FILIAL "
		cQuery += " AND C6_NUM = C5_NUM "
		cQuery += " AND C6_FILIAL = F4_FILIAL "
		cQuery += " AND C6_TES = F4_CODIGO "
		cQuery += " AND C6_PRODUTO = '"+cProduto+"' "
		cQuery += " AND C6_CLI = '"+cClient+"' "
		cQuery += " AND C6_NUM <> '"+cNumPed+"' "
		cQuery += " AND C5_EMISSAO BETWEEN '"+cDatIni+"' AND '"+cDatFim+"' "
		cQuery += " AND F4_DUPLIC = 'S' "
		cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
		cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
		cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY C6_PRCVEN, C5_EMISSAO DESC "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL6", .F., .T.)
		
		SQL6->(DbGotop())
		If !Eof()
			aPreco[1] := SQL6->PRCVEN
			aPreco[2] := "P" 
			aPreco[3] := SQL6->NUM
			aPreco[4] := DtoC(StoD(SQL6->EMISSAO))
		Endif
		SQL6->(DbCloseArea())
	
		If aPreco[1] > 0 .Or. cAnoAtu == "2016"
			lBusca := .F.
		Else
			nPrxAno := Val(cAnoAtu)-1
			cAnoAtu := AllTrim(STR(nPrxAno)) 
		Endif

	Endif

Enddo 
  
RestArea(aArea)

Return(aPreco)
