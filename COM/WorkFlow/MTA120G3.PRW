#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MTA120G3  � Autor � ERPBR            �   Data  � Jun/18    ���
��+----------+------------------------------------------------------------���
���Descricao � Avalia se envia o pedido gera aprova��o.     	  		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MTA120G3()

Local lEnvApr := PARAMIXB[2]

Return(lEnvApr)
