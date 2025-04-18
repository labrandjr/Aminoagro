#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MT242TOK  � Autor �  F�brica ERP.BR   �   Data  � 19/01/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��es na rotina de Desmontagem = 100%.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT242TOK()

Local lRetOk   := .T.
Local nTotRat  := 0
Local lDesmAut := ( AllTrim(GetMv("MV_DESMAUT")) == "S" )
Local nI

For nI := 1 to Len(aCols)
	If !(aCols[nI][Len(aHeader)+1])
		nTotRat += aCols[nI][GdFieldPos("D3_RATEIO")]
	Endif	
Next nI
If nTotRat != 100
	MsgAlert("Aten��o, total do rateio n�o atingiu 100%.")
	lRetOk := .F.
Endif

Return(lRetOk)
