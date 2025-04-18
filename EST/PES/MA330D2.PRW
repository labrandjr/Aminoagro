#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MA330D2  � Autor �  F�brica ERP.BR   �    Data  � 04/12/19 ���
��+----------+------------------------------------------------------------���
���Descricao � Atualiza custo da nota fiscal de sa�da.			          ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA330D2()

Local aArea   := GetArea()
Local lGrava  := .F.
Local nXCust  := 0

// Exce��es
lExcecao := .F.
If SD2->D2_FILIAL == "0102" .And. AllTrim(SD2->D2_DOC) == "000005116" .And. AllTrim(SD2->D2_SERIE) == "4" .And. AllTrim(SD2->D2_ITEM) == "01"
	// Exce��o fechamento de novembro/2019 - Jefferson
	lGrava := .T.
	nXCust := 20171.87
ElseIf SD2->D2_FILIAL == "0102" .And. AllTrim(SD2->D2_DOC) == "000005116" .And. AllTrim(SD2->D2_SERIE) == "4" .And. AllTrim(SD2->D2_ITEM) == "02"
	// Exce��o fechamento de novembro/2019 - Jefferson
	lGrava := .T.
	nXCust := 20171.87
ElseIf SD2->D2_FILIAL == "0102" .And. AllTrim(SD2->D2_DOC) == "000005116" .And. AllTrim(SD2->D2_SERIE) == "4" .And. AllTrim(SD2->D2_ITEM) == "03"
	// Exce��o fechamento de novembro/2019 - Jefferson
	lGrava := .T.
	nXCust := 20171.87
ElseIf SD2->D2_FILIAL == "0102" .And. AllTrim(SD2->D2_DOC) == "000005116" .And. AllTrim(SD2->D2_SERIE) == "4" .And. AllTrim(SD2->D2_ITEM) == "04"
	// Exce��o fechamento de novembro/2019 - Jefferson
	lGrava := .T.
	nXCust := 16137.50
ElseIf SD2->D2_FILIAL == "0102" .And. AllTrim(SD2->D2_DOC) == "000005116" .And. AllTrim(SD2->D2_SERIE) == "4" .And. AllTrim(SD2->D2_ITEM) == "05"
	// Exce��o fechamento de novembro/2019 - Jefferson
	lGrava := .T.
	nXCust := 20171.87
Endif
If lExcecao
	Return
Endif

If lGrava
	//
	nCustD2 := SD2->D2_CUSTO1
	//
	RecLock("SD2",.F.)
	SD2->D2_CUSTO1 := nXCust
	MsUnLock()
	//
	RecLock("SB2",.F.)
	SB2->B2_VFIM1 -= (nXCust - nCustD2)
	MsUnLock()
	//
Endif

RestArea(aArea)

Return
