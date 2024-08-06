#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"
#INCLUDE "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldExB1

Valida a utilização do produto a ser excluído na tabela de custo SZ1.

@author 	Augusto Krejci Bem-Haja
@since 		04/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function VldExB1()
	Local aArea		:= GetArea()
	Local lRetorno 	:= .F.
	Local cProduto	:= SB1->B1_COD
	Local cMens		:= ""
	Local cAlias	:= ""
	
	QryRgs(cProduto,@cAlias)
	(cAlias)->(dbGoTop())
	
	If (cAlias)->(Eof())
		lRetorno := .T.
	Else
		cMens += "Atenção, produto utilizado no cadastro de custo." 
		cMens += chr(10) + chr(13) 
		cMens += "Exclusão não permitida."	
		MsgAlert(cMens)		
	Endif
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
Return (lRetorno)

Static Function QryRgs(cProduto,cAlias) 
	Local cQuery := ""
	Local cEol   := chr(10) + chr(13)
	Local cData  := DtoS(dDatabase)
	
	cAlias := GetNextAlias()
	
	cQuery := " SELECT * FROM " +RetSqlName("SZ1") +" SZ1 "+ cEol	
	cQuery += " WHERE Z1_CODIGO = '" + cProduto + "'"+ cEol
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return
