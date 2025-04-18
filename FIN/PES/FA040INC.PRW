#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � FA040INC � Autor � Luis Brandini   �   Data  � 16/02/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Valida inclus�o do t�tulo a receber.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function FA040INC ()

Local lRetorno := .T.

If (FunName() == "FINA040" .Or. FunName() == "FINA740") .And. AllTrim(M->E1_PREFIXO) == "ACO"
	MsgAlert("Prefixo 'ACO' reservado para Gest�o de Acordos.")
	lRetorno := .F.
ElseIf FunName() == "BRWACOR" // Gest�o de Acordos
	lRetorno := .T.
Endif

Return(lRetorno)
