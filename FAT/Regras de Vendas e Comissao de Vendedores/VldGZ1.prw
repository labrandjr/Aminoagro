#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"
#INCLUDE "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função VldGZ1

Valida a manutenção do cadastro MVC SZ1.

@author 	Augusto Krejci Bem-Haja
@since 		19/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------
User Function VldGZ1(oObj)
	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cProduto	:= oObj:GetValue("SZ1MASTER","Z1_CODIGO")
	Local cUndNeg	:= oObj:GetValue("SZ1MASTER","Z1_ITEMCTB")
	Local cAtivo	:= oObj:GetValue("SZ1MASTER","Z1_ATIVO")
	Local cMens		:= ""
	Local cAlias	:= ""
	Local nOperacao	:= oObj:GetOperation()

	If (nOperacao == 3 .OR. nOperacao == 4) .AND. cAtivo <> 'N'
		QryRgs(cProduto,cUndNeg,@cAlias)
		(cAlias)->(dbGoTop())
		
		If !((cAlias)->(Eof()))
			lRetorno := .F.
			cMens += "Atenção, já existe custo ativo cadastrado para este Produto e Filial." + chr(10) + chr(13)			  
			Help( ,, 'Restrição de Manutenção',,cMens, 1, 0 )	
		Endif
		(cAlias)->(DbCloseArea())

		RestArea(aArea)
	Endif
Return (lRetorno)

Static Function QryRgs(cProduto,cUndNeg,cAlias) 
	Local cQuery := ""
	Local cEol   := chr(10) + chr(13)
	
	cAlias := GetNextAlias()
	
	cQuery := " SELECT * FROM " +RetSqlName("SZ1") +" SZ1 "+ cEol	
	cQuery += " WHERE Z1_CODIGO = '" + cProduto + "'"+ cEol
	cQuery += " AND Z1_ATIVO = 'S'" + cEol 
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol
	cQuery += " AND Z1_FILIAL = '"+ xFilial("SZ1") +"'"+ cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return
