#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função M410PVNF

Ponto de entrada para validação.Executado antes da rotina de geração de NF's (MA410PVNFS()).

@author 	Augusto Krejci Bem-Haja
@since 		14/01/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function M410PVNF()

Local lRetorno	:= .T. 	
	
lRetorno := U_ValEntr()
	
Return lRetorno
