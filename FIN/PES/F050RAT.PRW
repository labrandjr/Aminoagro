#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F050RAT  ¦ Autor ¦  Luis Brandini   ¦   Data  ¦ 12/01/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações na inclusão do rateio a pagar.		 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F050RAT()

Local aArea  := GetArea()
Local lRetOk := .T.
Local lExist := .F.
Local nTtRat := 0

DbSelectArea("TMP")
TMP->(DbGotop())
While !Eof()
	If !TMP->CTJ_FLAG
		lExist  := .T.
		If TMP->CTJ_PERCEN == 100
			MsgInfo("Rateio 100% em única linha não permitido.")
			lRetOk := .F.
			Exit
		ElseIf TMP->CTJ_VALOR < 0
			MsgInfo("Valor negativo não permitido.")
			lRetOk := .F.
			Exit
		Else
			nTtRat += TMP->CTJ_VALOR
		Endif		
	Endif
	DbSelectArea("TMP")
	TMP->(DbSkip())
Enddo

If !lExist
	MsgInfo("Rateio não informado!")
	lRetOk := .F.
Endif

If lRetOk
	If nTtRat > 0
		If nTtRat != M->E2_VALOR
			MsgInfo("'Valor Título' diferente do 'Valor Rateio'.")
			lRetOk := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
