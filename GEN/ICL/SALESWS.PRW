#include "protheus.ch"
#include "restful.ch"

WSRESTFUL SALESWS DESCRIPTION "Webservice para consulta do faturamento"
 
 	WSDATA fdate AS STRING

	WSMETHOD GET invoices;
	DESCRIPTION "Retorna informações do faturamento.";
	WSSYNTAX "/invoices ";
	PATH 'invoices';
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / invoices
Retorna informações de faturamento.

@param 
fdate , caracter, data do faturamento no formato aaaammdd

@return 
cResponse , caracter, JSON contendo a lista de faturamento
/*/
//-------------------------------------------------------------------

WSMETHOD GET invoices WSRECEIVE fdate WSREST SALESWS
 
Local aListFat := {}
Local cJsonRet := ""
Local lRetJson := .T.
Local nAux     := 0
Local zCfAdmv  := FormatIn( AllTrim(GetMv("MV_XCFADMV")), ",")
Local oJsonFat := JsonObject():New() 

Default self:fdate := DtoS(Date())

//-------------------------------------------------------------------
// Query para selecionar faturamento
//-------------------------------------------------------------------
cQuery := " SELECT D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_ITEM, D2_COD, D2_EMISSAO, D2_QUANT, D2_UM, D2_TOTAL, F2_VEND1, D2_PEDIDO "
cQuery += " FROM "+RetSqlName("SD2")+" SD2 "
cQuery += " INNER JOIN "+ RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery += " INNER JOIN "+ RetSqlName("SA1")+" SA1 ON SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA "
cQuery += " INNER JOIN "+ RetSqlName("SB1")+" SB1 ON SB1.B1_COD = SD2.D2_COD "
cQuery += " INNER JOIN "+ RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = SD2.D2_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES "
cQuery += " AND SD2.D2_TIPO = 'N' "
cQuery += " AND SD2.D2_ORIGLAN = ' ' "
cQuery += " AND SD2.D2_EMISSAO = '"+Self:fDate+"' "
cQuery += " AND SF4.F4_DUPLIC = 'S' "
cQuery += " AND SB1.B1_TIPO <> 'SV' "
cQuery += " AND SD2.D2_CF IN"+zCfAdmv
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D2_FILIAL, D2_DOC, D2_SERIE, D2_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)

DbSelectArea("TRB")
If TRB->(!Eof())

	//-------------------------------------------------------------------
	// Identifica a quantidade de registro no alias temporário
	//-------------------------------------------------------------------
	COUNT TO nRecord

Else

	//-------------------------------------------------------------------
	// Nao encontrou registros
	//-------------------------------------------------------------------
	SetRestFault(404, "Dados não localizados.")
	Return .F.

EndIf

//-------------------------------------------------------------------
// Alimenta array de faturamento
//-------------------------------------------------------------------
DbSelectArea("TRB")
TRB->(DbGotop())
While !Eof()

	nAux++ 
	AAdd( aListFat, JsonObject():New() )

	aListFat[nAux]["source"]   := "FRQ"
	aListFat[nAux]["trdate"]   := TRB->D2_EMISSAO
	aListFat[nAux]["invoice"]  := AllTrim(TRB->D2_DOC)
	aListFat[nAux]["invline"]  := TRB->D2_ITEM
	aListFat[nAux]["company"]  := "CC0241"
	aListFat[nAux]["customer"] := AllTrim(TRB->D2_CLIENTE)
	aListFat[nAux]["sku"]      := AllTrim(TRB->D2_COD)
	aListFat[nAux]["quantity"] := TRB->D2_QUANT

	DbSelectArea("TRB")
	TRB->(DbSkip())
Enddo
TRB->(DbCloseArea())

oJsonFat["invoices"] := aListFat

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonRet := FwJsonSerialize(oJsonFat)

//-------------------------------------------------------------------
// Elimina objeto da memoria
//-------------------------------------------------------------------
FreeObj(oJsonFat)

Self:SetResponse(cJsonRet) //-- Seta resposta

Return(lRetJson)
