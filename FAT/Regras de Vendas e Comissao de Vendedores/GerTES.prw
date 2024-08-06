#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o GerTES

Chama a fun��o GeraVal.

@author 	Augusto Krejci Bem-Haja
@since 		11/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------
User Function GerTES()
	Local aArea			:= GetArea()
	Local cTES			:= aCols[n,GdFieldPos("C6_TES")]

	U_GeraVal(n)
	U_ZerEBIT()
	
	RestArea(aArea)
Return cTES

