#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "xmlxfun.ch"
#include "apwebsrv.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNDIRF  � Autor �  F�brica ERP.BR   �    Data  � 08/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Manuten��o de dados no T�tulo a Pagar para DIRF.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNDIRF()

Private cCadastro := "Manuten��o para DIRF"

Private aRotina   := {{ "Pesquisar"  , "AxPesqui" , 0, 1},;
   					  { "Visualizar" , "AxVisual" , 0, 2},;
   					  { "Incluir"    , "U_AMND01I", 0, 3},;
   					  { "Alterar"    , "U_AMND01A", 0, 4},;
   					  { "Excluir"    , "U_AMND01E", 0, 5}}

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SE2" )			
oMBrowse:SetDescription( cCadastro )
oMBrowse:Activate()

DbSelectArea("SE2")
DbSetOrder(1)
DbClearFilter()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMND01A  � Autor �  F�brica ERP.BR   �    Data  � 08/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Altera��o do T�tulo a Pagar.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMND01A()

Local nOpcA    := 0
Private cAlias := "SE2"
Private nReg   := SE2->(Recno())
Private nOpc   := 3
Private aCpos  := {"E2_CODRET","E2_DIRF"}
Private aAcho	

nOpcA := AxAltera(cAlias,nReg,nOpc,aAcho,aCpos)

If nOpcA == 1
	MsgInfo("Altera��o conclu�da !!","Aviso")
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMND01I  � Autor �  F�brica ERP.BR   �    Data  � 08/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Inclus�o - Fun��o desabilitada.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMND01I()
MsgInfo("Aviso, a��o n�o permitida.")
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMND01E  � Autor �  F�brica ERP.BR   �    Data  � 08/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Exclus�o - Fun��o desabilitada.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMND01E()
MsgInfo("Aviso, a��o n�o permitida.")
Return
