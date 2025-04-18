#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC020   � Autor �  F�brica ERP.BR   �   Data  � 14/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Visualiza calculo da Forma��o de Pre�os.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC020()

Private cCadastro := "Forma��o de Pre�os"

Private aRotina   := {{"Pesquisar"  , "AxPesqui"    , 0 , 1 },;
            	      {"Visualizar" , "AxVisual"    , 0 , 2 },;
            	      {"Incluir"    , "U_AMNC02I()" , 0 , 3 },;
            	      {"Alterar"    , "U_AMNC02A()" , 0 , 4 },;
            	      {"Excluir"    , "U_AMNC02E()" , 0 , 5 }}

If !(__cUserId $ ( AllTrim(GetMv("MV_XGEREST")) )) // Administrador, Jefferson Costa, Paul Bergman
	MsgAlert("Usu�rio n�o autorizado. Contate o Administrador.")
	Return
Endif

DbSelectArea("SZA")
DbSetOrder(1)
MBrowse(6,1,22,75,"SZA",,,)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC02I   � Autor �  F�brica ERP.BR   �   Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Inclus�o - Forma��o de Pre�os.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC02I()
MsgInfo("Aviso, a��o n�o permitida.")
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC02A   � Autor �  F�brica ERP.BR   �   Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Altera��o - Forma��o de Pre�os.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC02A()
MsgInfo("Aviso, a��o n�o permitida.")
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC02E   � Autor �  F�brica ERP.BR   �   Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Exclus�o - Forma��o de Pre�os.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC02E()
MsgInfo("Aviso, a��o n�o permitida.")
Return
