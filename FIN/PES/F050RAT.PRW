#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � F050RAT  � Autor �  Luis Brandini   �   Data  � 12/01/17   ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��es na inclus�o do rateio a pagar.		 		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
			MsgInfo("Rateio 100% em �nica linha n�o permitido.")
			lRetOk := .F.
			Exit
		ElseIf TMP->CTJ_VALOR < 0
			MsgInfo("Valor negativo n�o permitido.")
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
	MsgInfo("Rateio n�o informado!")
	lRetOk := .F.
Endif

If lRetOk
	If nTtRat > 0
		If nTtRat != M->E2_VALOR
			MsgInfo("'Valor T�tulo' diferente do 'Valor Rateio'.")
			lRetOk := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
