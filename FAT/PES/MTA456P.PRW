#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MTA456P  � Autor � Luis Brandini    �   Data  � 05/07/17   ���
��+----------+------------------------------------------------------------���
���Descricao � N�o permite libera��o de estoque manual.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MTA456P()

Local aArea  := GetArea()
Local lRetOk := .T.

If PARAMIXB[1] != 0
	If __cUserId != "000000"
		MsgAlert("Aten��o, libera��o manual de cr�dito/estoque n�o permitida. Contate o Administrador.")
		lRetOk := .F.
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
