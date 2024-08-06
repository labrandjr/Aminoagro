#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função GerQV

Chama a função GeraVal.

@author 	Augusto Krejci Bem-Haja
@since 		11/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------

User Function GerQV()
	Local aArea			:= GetArea()
	Local nQtdVen		:= aCols[n,GdFieldPos("C6_QTDVEN")]

	U_GeraVal(n)
	U_ZerEBIT()
	
	RestArea(aArea)
Return nQtdVen

