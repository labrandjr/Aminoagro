#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � F050LRCT � Autor �  Luis Brandini   �   Data  � 09/08/17   ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��o na linha do rateio - CC Obrigat�rio.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function F050LRCT()

Local aArea  := GetArea()
Local lRetOk := .T.

If !Empty(TMP->CTJ_DEBITO)
	lCCObrg := ( RetField("CT1",1,xFilial("CT1")+TMP->CTJ_DEBITO,"CT1_CCOBRG") == "1" )
	If lCCObrg
		If Empty(TMP->CTJ_CCD)
			MsgInfo("Aten��o..., Centro de Custo D�BITO n�o informado (obrigat�rio para a Conta D�BITO).")
			lRetOk := .F.
		Endif
	Endif
Endif

If !Empty(TMP->CTJ_CREDIT)
	lCCObrg := ( RetField("CT1",1,xFilial("CT1")+TMP->CTJ_CREDIT,"CT1_CCOBRG") == "1" )
	If lCCObrg
		If Empty(TMP->CTJ_CCC)
			MsgInfo("Aten��o..., Centro de Custo CR�DITO n�o informado (obrigat�rio para a Conta CR�DITO).")
			lRetOk := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
