#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função A410CONS

Inclusão de botões na enchoicebar.

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

