#include "protheus.ch"
#include "topconn.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função RetCusto

Retorna o custo do produto, validando o status e vencimento.

@author 	Augusto Krejci Bem-Haja
@since 		22/01/2016
@return		Numérico
/*/
//-------------------------------------------------------------------

User Function RetCusto(cProduto)
Local aArea		:= GetArea()
Local nCusto 	:= 0
Local cUndNeg	:= M->C5_ZZITCTB
Local objQualy	:= LibQualyQuimica():New()
Private cAlias	:= ""

cAlias := QryRgs(cProduto,cUndNeg)
(cAlias)->(dbGoTop())

If objQualy:isSale()
	If (cAlias)->(Eof())
		If FunName() != "MATA311"
			zDescri := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
			MsgAlert("Atenção, custo do produto "+AllTrim(cProduto)+"-"+AllTrim(zDescri)+" não cadastrado ou inválido, para a filial "+ xFilial("SZ1") +"!")
		Endif	
	Else
		nCusto := (cAlias)->Z1_CUSTO
	Endif
Endif

(cAlias)->(DbCloseArea())

freeObj(objQualy)
RestArea(aArea)
Return (nCusto)

Static Function QryRgs(cProduto,cUndNeg)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local cEol   := chr(10) + chr(13)
Local cData  := DtoS(dDatabase)

cQuery := " SELECT Z1_CUSTO "
cQuery += " FROM " +RetSqlName("SZ1") +" SZ1 "
cQuery += " WHERE Z1_FILIAL = '"+ xFilial("SZ1") +"' "
cQuery += " AND Z1_CODIGO = '" + cProduto + "' "
cQuery += " AND Z1_ATIVO = 'S' "
cQuery += " AND Z1_VALID >= '"+ cData +"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY Z1_VALID DESC "

TCQUERY cQuery NEW ALIAS &cAlias
Return cAlias
