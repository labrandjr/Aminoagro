#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MT120ISC  � Autor � Luis Brandini    �   Data  � 28/10/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Complemento de dados na linha do pedido ap�s sele��o da SC.���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT120ISC()

Local aArea    := GetArea()
Local zPosUnid := aScan(aHeader,{|x|Alltrim(x[2])=="C7_ITEMCTA"})

aCols[n][zPosUnid] := Posicione("CTT",1,xFilial("CTT")+SC1->C1_CC,"CTT_ZZITCT")

RestArea(aArea)

Return
