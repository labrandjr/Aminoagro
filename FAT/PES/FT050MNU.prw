#Include 'Protheus.ch'

/*/{Protheus.doc} Fun��o FT050MNU

Ponto de entrada para incluir um bot�o no browse

@author 	Gustavo Luiz
@since 		10/05/2016
@return		Array
/*/
User Function FT050MNU()

Local aRotina := {}

//AAdd(aRotina,{'Importa��o metas de vendas','u_QQFAT02()' , 0 , 3,0,NIL})

AAdd(aRotina,{"Importa��o Metas de Vendas","U_IMPMETV()", 0, 3, 0, Nil})

Return aRotina

