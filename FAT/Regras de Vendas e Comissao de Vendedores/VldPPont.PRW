#include "Protheus.ch"
#include "TopConn.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldPPont

Retorna verdadeiro quando o desconto de pontualidade passado, existe na tabela SX5, X5_Tabela == ZZ.

@author 	Augusto Krejci Bem-Haja
@since 		04/01/2016
@return		Booleano
/*/
//-----------------

User Function VldPPont(cPPont)
	Local lRetorno := .T.
	Private cAlias	:= ""
	
	cAlias := QryRgs(cValtoChar(Val(cPPont)))
	(cAlias)->(dbGoTop())
	
	If (cAlias)->(Eof())
		MsgAlert("Atenção, percentual não cadastrado!")
		lRetorno := .F.
	Else
		M->C5_ZZPPONT := cValtoChar(Val(cPPont))+Replicate(" ",len(M->C5_ZZPPONT)-len(cValtoChar(Val(cPPont))))
		GetDRefresh()
	Endif
	(cAlias)->(DbCloseArea())
	
	U_ZerEBIT()
Return lRetorno

Static Function QryRgs(cPPont) 
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cEol   := chr(10) + chr(13)
	
	cQuery := " SELECT * FROM " +RetSqlName("SX5") +" SX5 "+ cEol	
	cQuery += " WHERE X5_TABELA = 'ZZ' " + cEol
	cQuery += " AND X5_DESCRI = '"+ cPPont +"'"+ cEol
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return cAlias
