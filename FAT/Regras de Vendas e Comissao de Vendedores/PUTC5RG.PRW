#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � PutC5RG  � Autor �  F�brica ERP.BR   �    Data  � 21/03/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Atualiza regi�o do vendedor no Pedido de Venda.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function PutC5RG()

Local aArea   := GetArea()
Local cRegVen := RetField("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_REGIAO")

RestArea(aArea)

Return(cRegVen)
