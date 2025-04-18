#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC060   � Autor �  F�brica ERP.BR   �   Data  � 08/01/20 ���
��+----------+------------------------------------------------------------���
���Descricao � Mbrowse - Fam�lia de Produtos.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC060()

Private cCadastro := "Fam�lia de Produtos"

Private aRotina   := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	      {"Visualizar" , "AxVisual" , 0 , 2 },;
            	      {"Incluir"    , "AxInclui" , 0 , 3 },;
            	      {"Alterar"    , "U_AMNC06A()" , 0 , 4 },;
            	      {"Excluir"    , "U_AMNC06E()" , 0 , 5 }}

DbSelectArea("SZO")
DbSetOrder(1)
MBrowse(6,1,22,75,"SZO",,,)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC06A   � Autor �  F�brica ERP.BR   �   Data  � 08/01/20 ���
��+----------+------------------------------------------------------------���
���Descricao � Altera��o - Fam�lia de Produtos.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC06A()

Local lRet := .T.

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND B1_ZFAMILI = '"+SZO->ZO_CODIGO+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZO", .F., .T.)
lRet := (TSZO->SOMA == 0)
TSZO->(DbCloseArea())

If !lRet
	MsgAlert("O c�digo da fam�lia est� sendo utilizado.")
	Return
Endif

Altera := .T.
nReg   := SZO->(Recno())
nOpc   := AxAltera("SZO",nReg,4)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC06E   � Autor �  F�brica ERP.BR   �   Data  � 08/01/20 ���
��+----------+------------------------------------------------------------���
���Descricao � Exclus�o - Fam�lia de Produtos.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC06E()

Local lRet := .T.

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND B1_ZFAMILI = '"+SZO->ZO_CODIGO+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZO", .F., .T.)
lRet := (TSZO->SOMA == 0)
TSZO->(DbCloseArea())

If !lRet
	MsgAlert("O c�digo da fam�lia est� sendo utilizado.")
	Return
Endif

Exclui := .T.
nReg   := SZO->(Recno())
nOpc   := AxDeleta("SZO",nReg,5)

Return
