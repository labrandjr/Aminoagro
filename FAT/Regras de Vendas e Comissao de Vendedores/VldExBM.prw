#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"
#INCLUDE "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o VldExBM

Valida a utiliza��o do grupo de produtos a ser exclu�do na tabela de 
faixas de comiss�o SZ2 e SZ3.

@author 	Augusto Krejci Bem-Haja
@since 		04/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------
User Function VldExBM(oObj)
	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cGrupo	:= oObj:GetValue("MATA035_SBM","BM_GRUPO")
	Local cMens		:= ""
	Local cAlias	:= ""
	Local nOperacao	:= oObj:GetOperation()

	If nOperacao == 5
		QryRgs("SZ2",cGrupo,@cAlias)
		(cAlias)->(dbGoTop())
		
		If !((cAlias)->(Eof()))
			lRetorno := .F.
			cMens += "Aten��o, grupo utilizado no cadastro de Faixas de Premia��o do Vendedor." 
			Help( ,, 'Restri��o de Exclus�o',,cMens, 1, 0 )
			cMens := ""		
		Endif
		(cAlias)->(DbCloseArea())

		QryRgs("SZ3",cGrupo,@cAlias)
		(cAlias)->(dbGoTop())
		
		If !((cAlias)->(Eof()))
			lRetorno := .F.
			cMens += "Aten��o, grupo utilizado no cadastro de Faixas de Premia��o da Revenda." 	
			Help( ,, 'Restri��o de Exclus�o',,cMens, 1, 0 )		
		Endif
		(cAlias)->(DbCloseArea())
		
		RestArea(aArea)
	Endif
Return (lRetorno)

Static Function QryRgs(cAliasSZ,cGrupo,cAlias) 
	Local cQuery := ""
	Local cEol   := chr(10) + chr(13)
	Local cData  := DtoS(dDatabase)
	Local cPref	 	:= SubStr(cAliasSZ,2)
	
	cAlias := GetNextAlias()
	
	cQuery := " SELECT * FROM " +RetSqlName(cAliasSZ) + cEol	
	cQuery += " WHERE " +cPref+"_GRUPO = '" + cGrupo + "'"+ cEol
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return
