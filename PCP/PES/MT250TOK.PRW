#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MT250TOK   � Autor � F�brica ERP.BR  �    Data  � 29/05/19 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��es no apontamento de produ��o.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT250TOK()

Local aArea    := GetArea()
Local lInteWms := GetMv("MV_INTWMS")
Local lRetX    := U_geraLoteAuto()
Local lPA      := ( Posicione("SB1",1,xFilial("SB1") + M->D3_COD,"B1_TIPO") == "PA" )

If lRetX .And. lInteWms .And. lPA .And. Empty(M->D3_SERVIC)
	MsgAlert("Informe o C�d.Servi�o WMS = 003")
	lRetX := .F.
Endif

RestArea(aArea)

Return(lRetX)
