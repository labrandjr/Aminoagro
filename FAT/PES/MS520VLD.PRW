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
���Programa  � MS520VLD � Autor � Luis Brandini   �    Data  � 08/05/2019 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��es preliminares antes da exclus�o da nota fiscal.  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MS520VLD()

Local lRetorno := .T.
/*
Local cEOL := CHR(13)+CHR(10)

If !MsgYesNo("Considere ter checado as seguintes instru��es preliminares para a Nota Fiscal "+SF2->F2_DOC+":"+cEOL+cEOL+;
			"1. Prazo de Cancelamento."+cEOL+;
			"2. Emiss�o de Ct-e."+cEOL+;
			"3. DANFE em Tr�nsito."+cEOL+cEOL+;
			"Em caso de qualquer diverg�ncia acima, n�o prossiga com a exclus�o e consulte o Depto.Fiscal."+cEOL+cEOL+;
			"Deseja prosseguir ?","Aviso","INFO")
	lRetorno := .F.	
Endif
*/                                                                             
Return(lRetorno)
