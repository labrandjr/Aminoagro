#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"
#INCLUDE "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldGZ4

Valida a manutenção do cadastro MVC SZ4.

@author 	Augusto Krejci Bem-Haja
@since 		19/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------
User Function VldGZ4(oObj)
	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cUF		:= oObj:GetValue("SZ4MASTER","Z4_ESTADO")
	Local cUndNeg	:= oObj:GetValue("SZ4MASTER","Z4_ITEMCTB")
	Local cAtivo	:= oObj:GetValue("SZ4MASTER","Z4_ATIVO")
	Local cMens		:= ""
	Local cAlias	:= ""
	Local nOperacao	:= oObj:GetOperation()

	If (nOperacao == 3 .OR. nOperacao == 4) .AND. cAtivo <> 'N'
		QryRgs(cUF,cUndNeg,@cAlias)
		(cAlias)->(dbGoTop())
		
		If !((cAlias)->(Eof()))
			lRetorno := .F.
			cMens += "Atenção, já existe faixa ativa cadastrada para este Estado e Unidade de Negócio." + chr(10) + chr(13)			  
			Help( ,, 'Restrição de Manutenção',,cMens, 1, 0 )
		Endif
		(cAlias)->(DbCloseArea())

		RestArea(aArea)
	Endif
Return (lRetorno)

Static Function QryRgs(cUF,cUndNeg,cAlias) 
	Local cQuery := ""
	Local cEol   := chr(10) + chr(13)
	
	cAlias := GetNextAlias()
	
	cQuery := " SELECT * FROM " +RetSqlName("SZ4") +" SZ4 "+ cEol	
	cQuery += " WHERE Z4_ESTADO = '" + cUF + "'"+ cEol
	cQuery += " AND Z4_ATIVO = 'S'" + cEol
	cQuery += " AND Z4_ITEMCTB = '"+ cUndNeg +"'"+ cEol 
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return
