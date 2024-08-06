#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o A410CONS

Inclus�o de bot�es na enchoicebar.

@author 	Augusto Krejci Bem-Haja
@since 		11/01/2016
@return		Nil
/*/
//-----------------


User Function A410CONS()

Local aBotao := {}
	
If Inclui .Or. Altera
	Aadd(aBotao	, {'',{||U_ReCalc()},"Proc. Regras Vendas"})
Endif

Return(aBotao)

