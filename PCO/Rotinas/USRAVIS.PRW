#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � USRAVIS   � Autor �  F�brica ERP.BR   �   Data  � 07/04/19 ���
��+----------+------------------------------------------------------------���
���Descricao � Cadastro de Usu�rios x Vis�es Gerenciais SIGAPCO.		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function USRAVIS()

Private cCadastro := "Usu�rios x Vis�es Gerenciais"

Private aRotina   := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	      {"Visualizar" , "AxVisual" , 0 , 2 },;
            	      {"Incluir"    , "AxInclui" , 0 , 3 },;
            	      {"Alterar"    , "AxAltera" , 0 , 4 },;
            	      {"Excluir"    , "AxDeleta" , 0 , 5 }}

DbSelectArea("SZK")
DbSetOrder(1)
MBrowse(6,1,22,75,"SZK",,,)

Return
