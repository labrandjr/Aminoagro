#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função ZerEBIT

Zera os campos personalizados da SC5, relacionados ao EBITDA.

@author 	Augusto Krejci Bem-Haja
@since 		18/01/2016
@return		Nil
/*/
//-----------------

User Function ZerEBIT()

M->C5_ZZVEBIT := 0
M->C5_ZZPEBIT := 0
M->C5_ZZVPONT := 0
M->C5_ZZVMBR  := 0
M->C5_ZZPMBR  := 0

GetDRefresh()

Return
