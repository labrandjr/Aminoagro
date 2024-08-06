#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o MTA010OK

Ponto de entrada que valida adicionais para a exclus�o do produto

@author 	Augusto Krejci Bem-Haja
@since 		04/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function MTA010OK()
	Local lRetorno	:= .T. 	
	
	lRetorno := U_VldExB1()
	
Return lRetorno