#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função M460FIM

.

@author 	Augusto Krejci Bem-Haja
@since 		15/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------

User Function M460FIM()
	
	U_PutDesc()
	U_PutD2UN()
	If SF2->F2_SERIE != "002" .And. SF2->F2_SERIE != "099" .And. SF2->F2_SERIE != "009" // Séries de Ct-e
		U_MsgNf("SAIDA")
	Endif	

Return
