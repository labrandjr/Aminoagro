#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNF002   � Autor �  F�brica ERP.BR   �   Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Cadastro De-Para - Importa��o Cont�bil Folha de Pagamento. ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNF002()

Private cCadastro := "De-Para Importa��o Folha"

Private aRotina   := {{"Pesquisar"  , "AxPesqui"    , 0 , 1 },;
            	      {"Visualizar" , "AxVisual"    , 0 , 2 },;
            	      {"Incluir"    , "U_IMPF02I()" , 0 , 3 },;
            	      {"Alterar"    , "U_IMPF02A()" , 0 , 4 },;
            	      {"Excluir"    , "U_IMPF02E()" , 0 , 5 }}

DbSelectArea("SZ9")
DbSetOrder(1)
MBrowse(6,1,22,75,"SZ9",,,)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � IMPF02I   � Autor �  F�brica ERP.BR   �   Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Inclus�o - De-Para Importa��o Folha.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function IMPF02I()
MsgInfo("Aviso, a��o n�o permitida.")
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � IMPF02A   � Autor �  F�brica ERP.BR   �   Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Altera��o - De-Para Importa��o Folha.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function IMPF02A()
MsgInfo("Aviso, a��o n�o permitida.")
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � IMPF02E   � Autor �  F�brica ERP.BR   �   Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Exclus�o - De-Para Importa��o Folha.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function IMPF02E()
MsgInfo("Aviso, a��o n�o permitida.")
Return
