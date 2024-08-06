#include "Protheus.ch"
#include "TopConn.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldFZ3

Retorna falso caso a faixa não exista, e chama a função ZerEbit(), para zerar campos personalizados de Ebitda.

@author 	Augusto Krejci Bem-Haja
@since 		18/01/2016
@return		Booleano
/*/
//-----------------

User Function VldFZ3(cFaixa)
	Local lRetorno := .T.
	Private cAlias	:= ""
	
	cAlias := QryRgs(cFaixa)
	(cAlias)->(dbGoTop())
	
	If (cAlias)->(Eof()) .And. !(Vazio())
		MsgAlert("Atenção, faixa de premiação revenda não cadastrada ou inválida!")
		lRetorno := .F.
	Endif
	(cAlias)->(DbCloseArea())
	
	U_ZerEBIT()
Return lRetorno

Static Function QryRgs(cFaixa) 
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cEol   := chr(10) + chr(13)
	Local cData  := DtoS(dDatabase)
	
	cQuery := " SELECT * FROM " +RetSqlName("SZ3") +" SZ3 "+ cEol	
	cQuery += " WHERE Z3_CODIGO = '" + cFaixa + "'"+ cEol
	cQuery += " AND Z3_ATIVO = 'S'" + cEol
	cQuery += " AND Z3_VALID >= '"+ cData +"'"+ cEol 
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return cAlias
