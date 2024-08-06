#include "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldCusto

Valida o custo do produto, validando o status e vencimento.

@author 	Augusto Krejci Bem-Haja
@since 		22/01/2016
@return		Numérico
/*/
//-------------------------------------------------------------------

User Function VldCusto(lCopia,cProduto,zUniNeg)

Local aArea	   := GetArea()
Local lRetorno := .T.
Local cUndNeg  := IIf(lCopia, zUniNeg, M->C5_ZZITCTB)
Local lValida  := .F.
Local objQualy

If !lCopia
	objQualy := LibQualyQuimica():New()
	If objQualy:isSale()
		lValida := .T.
	Endif
Else
	lValida := .T.
Endif	

If lValida .And. FunName() != "MATA311"
	cAlias := QryRgs(lCopia,cProduto,cUndNeg)
	(cAlias)->(DbGotop())
	If (cAlias)->(Eof())
		MsgAlert("Atenção, custo do produto '"+AllTrim(cProduto)+"' não cadastrado ou inválido, para a filial "+ xFilial("SZ1") +"!")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif
	(cAlias)->(DbCloseArea())
Endif

If !lCopia
	freeObj(objQualy)
Endif	

RestArea(aArea)

Return(lRetorno)

Static Function QryRgs(lCopia,cProduto,cUndNeg)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local cEol   := chr(10) + chr(13)
Local cData  := DtoS(dDatabase)

cQuery := " SELECT Z1_CUSTO "
cQuery += " FROM " +RetSqlName("SZ1") +" SZ1 "
cQuery += " WHERE Z1_FILIAL = '"+ xFilial("SZ1")+"' "
cQuery += " AND Z1_CODIGO = '" + cProduto + "' "
cQuery += " AND Z1_ATIVO = 'S'"
cQuery += " AND Z1_VALID >= '"+ cData +"' "
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQUERY cQuery NEW ALIAS &cAlias
Return cAlias
