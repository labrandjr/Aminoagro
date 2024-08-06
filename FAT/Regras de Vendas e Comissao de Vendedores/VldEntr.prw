#include "protheus.ch"
#include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldEntr
Função que checa a data de entrega dos itens selecionados, e caso algum possua data de entrega superior a data base, retorna falso.
@author 	Augusto Krejci Bem-Haja
@since 		18/01/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VLDENTR   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 10/05/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Rotina original revisada e corrigida.					  ¦¦¦
¦¦¦          ¦ Implementação de validação para quantidade por embalagem.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function VldEntr(zModulo)

Local aArea    := GetArea()
Local lRetorno := .T. 	
	
lRetEntr := ChkItens(@lRetorno,zModulo)
	
RestArea(aArea)

Return(lRetEntr)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChkItens  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 10/05/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ChkItens(lRetorno,zModulo)

Local aArea := GetArea()
Local cMark := PARAMIXB[1]
Local lInvt := PARAMIXB[2]
Local cMens	 := ""	
Local cAlias := ""
Local aItEmb := {}
Local aCond9 := {}
Local lBlqVe := .F. 
Local _x

cAlias := QryRgs(cMark,lInvt,zModulo)
(cAlias)->(DbGotop())

While !(cAlias)->(Eof())
/*	If ((cAlias)->C6_ENTREG > DtoS(dDatabase)) // Desligado conforme chamado 001178 de 02/06/2021
		lRetorno := .F.
		Exit // <-- Abandona na 1a.ocorrência.
	Endif */
	//
	zCond := RetField("SC5",1,xFilial("SC5")+(cAlias)->C6_NUM,"C5_CONDPAG")
	zzSzg := .F.
	DbSelectArea("SZG")
	DbSetOrder(1)
	If DbSeek( xFilial("SZG") + (cAlias)->C6_NUM + Space(9) )
		zCond := SZG->ZG_CONDPAG
		zzSzg := .T.
	Endif	
	lTip9 := ( RetField("SE4",1,xFilial("SE4")+zCond,"E4_TIPO") == "9" )
	lVend := ( RetField("SC5",1,xFilial("SC5")+(cAlias)->C6_NUM,"C5_TIPO") == "N" )
	lEstq := ( RetField("SF4",1,xFilial("SF4")+(cAlias)->C6_TES,"F4_ESTOQUE") == "S" )
	zTipo := RetField("SB1",1,xFilial("SB1")+(cAlias)->C9_PRODUTO,"B1_TIPO")
	zBlqV := RetField("SB1",1,xFilial("SB1")+(cAlias)->C9_PRODUTO,"B1_ZBLQVEN")
	zProd := (cAlias)->C9_PRODUTO
	lAdd9 := .F.
	lAddP := .F.
	//
	If zBlqV == "1"
		lBlqVe := .T.
		Exit // <-- Abandona na 1a.ocorrência.
	Endif
	//
	If lTip9
		If Len(aCond9) == 0
			lAdd9 := .T.
		Else
			nPos := aScan(aCond9, {|x| x[1] == (cAlias)->C6_NUM })
			If nPos == 0
				lAdd9 := .T.
			Endif
		Endif
		If lAdd9
			If zzSzg
				zData1 := SZG->ZG_DATA1
				zData2 := SZG->ZG_DATA2
				zData3 := SZG->ZG_DATA3
				zData4 := SZG->ZG_DATA4
			Else
				zData1 := RetField("SC5",1,xFilial("SC5")+(cAlias)->C6_NUM,"C5_DATA1")
				zData2 := RetField("SC5",1,xFilial("SC5")+(cAlias)->C6_NUM,"C5_DATA2")
				zData3 := RetField("SC5",1,xFilial("SC5")+(cAlias)->C6_NUM,"C5_DATA3")
				zData4 := RetField("SC5",1,xFilial("SC5")+(cAlias)->C6_NUM,"C5_DATA4")
			Endif
			AAdd(aCond9,{(cAlias)->C6_NUM, zData1, zData2, zData3, zData4})
		Endif
	Endif
	//
	If lVend .And. lEstq
		If zTipo == "PA"
			DbSelectArea("SG1")
			DbSetOrder(1)
			If DbSeek( xFilial("SG1") + (cAlias)->C9_PRODUTO )
				lAddP := .T.
			Endif
		ElseIf zTipo == "PR"
			lAddP := .T.
		Endif	
	Endif
	If lAddP
		zPedi := (cAlias)->C9_PEDIDO
		zItem := (cAlias)->C9_ITEM
		zSequ := (cAlias)->C9_SEQUEN
		zProd := (cAlias)->C9_PRODUTO
		zQtde := (cAlias)->C9_QTDLIB
		AAdd(aItEmb,{zPedi, zItem, zSequ, zProd, zQtde, "LIB"})
	Endif
	(cAlias)->(DbSkip())
Enddo
(cAlias)->(DbCloseArea())
	
If !lRetorno
	cMens := "Existem itens com data de entrega superior a data de faturamento!"
	cMens += CHR(13)+CHR(10) + CHR(13)+CHR(10)
	cMens += "Documento de Saída não será gerado!"
	MsgAlert(cMens) 
Endif

If lRetorno
	If lBlqVe
		cMens := "Produto "+AllTrim(zProd)+" bloqueado p/ Vendas."
		cMens += CHR(13)+CHR(10) + CHR(13)+CHR(10)
		cMens += "Documento de Saída não será gerado!"
		MsgAlert(cMens)
		lRetorno := .F. 
	Endif
Endif

If lRetorno
	For _x := 1 to Len(aCond9)
		zPedido := AllTrim(aCond9[_x][1])
		//
		If !Empty(aCond9[_x][2])
			zDataT9 := aCond9[_x][2]
			If zDataT9 < Date()
				MsgAlert("Pedido "+zPedido+" possui condição de pagamento Tipo 9 com vencimento1 desatualizado: "+DtoC(zDataT9))
				lRetorno := .F.
			Endif
		Endif
		//
		If !Empty(aCond9[_x][3])
			zDataT9 := aCond9[_x][3]
			If zDataT9 < Date()
				MsgAlert("Pedido "+zPedido+" possui condição de pagamento Tipo 9 com vencimento2 desatualizado: "+DtoC(zDataT9))
				lRetorno := .F.
			Endif
		Endif
		//
		If !Empty(aCond9[_x][4])
			zDataT9 := aCond9[_x][4]
			If zDataT9 < Date()
				MsgAlert("Pedido "+zPedido+" possui condição de pagamento Tipo 9 com vencimento3 desatualizado: "+DtoC(zDataT9))
				lRetorno := .F.
			Endif
		Endif
		//
		If !Empty(aCond9[_x][5])
			zDataT9 := aCond9[_x][5]
			If zDataT9 < Date()
				MsgAlert("Pedido "+zPedido+" possui condição de pagamento Tipo 9 com vencimento4 desatualizado: "+DtoC(zDataT9))
				lRetorno := .F.
			Endif
		Endif
		//
	Next _x
Endif

// ************************************* //
// ** Avalia quantidade por Embalagem ** //
// ************************************* //
If lRetorno
	lVldEmb := ( AllTrim(GetMv("MV_XVLDEMB"))=="S" )
	If lVldEmb
		If Len(aItEmb) > 0
			lRetorno := u_VldEmblg(aItEmb)
		Endif
	Endif	
Endif

RestArea(aArea)

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QryRgs    ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 10/05/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtro de dados.											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function QryRgs(cMark,lInvt,zModulo)

Local cQuery := ""
Local cAlias := GetNextAlias()

If zModulo == "FAT"
	Pergunte("MT461A",.F.)
	cQuery := " SELECT * FROM " +RetSqlName("SC9") +" SC9 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC9.C9_FILIAL = SC6.C6_FILIAL AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_ITEM = SC6.C6_ITEM "
	cQuery += " AND SC6.C6_ENTREG BETWEEN '"+DtoS(mv_par14)+"' AND '"+DtoS(mv_par15)+"' "
	cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQuery += " AND SC9.C9_PEDIDO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
	cQuery += " AND SC9.C9_CLIENTE BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
	cQuery += " AND SC9.C9_LOJA BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' "
	cQuery += " AND SC9.C9_DATALIB BETWEEN '"+DtoS(mv_par11)+"' AND '"+DtoS(mv_par12)+"' "
	cQuery += " AND SC9.C9_BLCRED = ' ' "
	cQuery += " AND SC9.C9_BLEST = ' ' "
	If lInvt
		cQuery += " AND C9_OK <> '"+ cMark +"' "
	Else
		cQuery += " AND C9_OK = '"+ cMark +"' "
	Endif
	cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
	TCQUERY cQuery NEW ALIAS &cAlias	
	Pergunte("MT460A",.F.)
Else
	Pergunte("MT461B",.F.)
	cQuery := " SELECT * FROM " +RetSqlName("SC9") +" SC9 "
	cQuery += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC9.C9_FILIAL = SC6.C6_FILIAL AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_ITEM = SC6.C6_ITEM "
	cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DAK")+" DAK ON DAK.DAK_FILIAL = SC9.C9_FILIAL AND DAK.DAK_COD = SC9.C9_CARGA AND DAK.DAK_SEQCAR = SC9.C9_SEQCAR "
	cQuery += " AND DAK.DAK_COD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
	cQuery += " AND DAK_CAMINH BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
	cQuery += " AND DAK.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQuery += " AND SC9.C9_DATALIB BETWEEN '"+DtoS(mv_par07)+"' AND '"+DtoS(mv_par08)+"' "
	cQuery += " AND SC9.C9_BLCRED = ' ' "
	cQuery += " AND SC9.C9_BLEST = ' ' "
	If lInvt
		cQuery += " AND C9_OK <> '"+ cMark +"' "
	Else
		cQuery += " AND C9_OK = '"+ cMark +"' "
	Endif
	cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
	TCQUERY cQuery NEW ALIAS &cAlias
	Pergunte("MT460A",.F.)
Endif

Return(cAlias)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldEmblg  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 16/05/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtro de dados.											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function VldEmblg(aItEmb)

Local aArea  := GetArea()
Local lRetOk := .T.
Local _x

// ************************************************************************** //
// *** Array recebido via Parâmetro:									   ** //
// ************************************************************************** //
// [1] - Pedido															   ** //
// [2] - Item															   ** //
// [3] - Sequência 														   ** //
// [4] - Produto														   ** //
// [5] - Quantidade														   ** //
// [6] - Rotina (PED-Inclusão/Alteração do Pedido | LIB-Liberação do Pedido)
// ************************************************************************** //

For _x := 1 to Len(aItEmb)
	//
	zPedido := aItEmb[_x][1]
	zItemPv := aItEmb[_x][2]
	zSequen := aItEmb[_x][3]
	zCodPro := aItEmb[_x][4]
	zQtdVen := aItEmb[_x][5]
	zRotina := aItEmb[_x][6]
	zTipoPr := RetField("SB1",1,xFilial("SB1")+zCodPro,"B1_TIPO")
	//
	cMens := "Pedido: "+AllTrim(zPedido)
	cMens += CHR(13)+CHR(10)
	cMens += "Item: "+AllTrim(zItemPv)
	cMens += CHR(13)+CHR(10)
	If zRotina == "LIB"
		cMens += "Sequência: "+AllTrim(zSequen)
		cMens += CHR(13)+CHR(10)
	Endif	
	cMens += "Produto: "+AllTrim(zCodPro)+" - "+AllTrim(RetField("SB1",1,xFilial("SB1")+zCodPro,"B1_DESC"))
	cMens += CHR(13)+CHR(10)
	cMens += "Quantidade: "+AllTrim(STR(zQtdVen,17,5))
	cMens += CHR(13)+CHR(10)
	//
	zQtBase := RetField("SBZ",1,xFilial("SBZ")+zCodPro,"BZ_QB")
	bQtBase := RetField("SB1",1,xFilial("SB1")+zCodPro,"B1_QB")
	nQtBase := IIf(zQtBase > 0,zQtBase,bQtBase) // Prioriza Indicadores de Produtos (SBZ)
	If nQtBase == 0
		If zTipoPr == "PA"
			cMens += "A quantidade base da estrutura não foi cadastrada. "
			cMens += "Não será possível realizar a validação da quantidade por embalagem. "
			cMens += "Contate o responsável pelo cadastro."
			MsgAlert(cMens)
		Endif	
	ElseIf Mod(zQtdVen,nQtBase) > 0
		cMens += "Quantidade por embalagem inconsistente com o cadastro de estrutura. "
		cMens += "A quantidade base da estrutura é "+AllTrim(STR(nQtBase))+". "
		cMens += "Ajuste a quantidade vendida e/ou liberada."
		MsgAlert(cMens)
		//
		lRetOk := .F. // <-- Neste caso abandona o processo.
		Exit
	Endif
Next _x

RestArea(aArea)

Return(lRetOk)
