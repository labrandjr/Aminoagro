#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função GerPV

Chama a função GeraVal.

@author 	Augusto Krejci Bem-Haja
@since 		11/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------

User Function GerPV()
	Local aArea			:= GetArea()
	Local nPrcVen		:= aCols[n,GdFieldPos("C6_PRCVEN")]

	U_GeraVal(n)
	U_ZerEBIT()
	
	RestArea(aArea)
Return nPrcVen

