#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função MTA010OK

Ponto de entrada que valida adicionais para a exclusão do produto

@author 	Augusto Krejci Bem-Haja
@since 		04/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function MTA010OK()
	Local lRetorno	:= .T. 	
	
	lRetorno := U_VldExB1()
	
Return lRetorno