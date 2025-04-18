#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MT240TOK  � Autor �  F�brica ERP.BR   �   Data  � 16/03/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��o do centro de custo para Produtos B1_TIPO = PV.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT240TOK()

Local aArea  := GetArea()
Local lRetOk := .T.

cTipo := Posicione("SB1",1,xFilial("SB1") + M->D3_COD,"B1_TIPO")
If AllTrim(cTipo) == "PV"
	If Empty(M->D3_CC)
		MsgInfo("Aten��o, produto 'Tipo = PV' obrigat�rio informar o centro de custo.")
		lRetOk := .F.
	Endif
Endif

If lRetOk
	If !Empty(M->D3_OP)
		MsgInfo("Aten��o, movimenta��o interna manual vinculada a OP n�o permitida.")
		lRetOk := .F.
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
