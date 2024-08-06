#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "xmlxfun.ch"
#include "apwebsrv.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MS520VLD ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 08/05/2019 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações preliminares antes da exclusão da nota fiscal.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MS520VLD()

Local lRetorno := .T.
/*
Local cEOL := CHR(13)+CHR(10)

If !MsgYesNo("Considere ter checado as seguintes instruções preliminares para a Nota Fiscal "+SF2->F2_DOC+":"+cEOL+cEOL+;
			"1. Prazo de Cancelamento."+cEOL+;
			"2. Emissão de Ct-e."+cEOL+;
			"3. DANFE em Trânsito."+cEOL+cEOL+;
			"Em caso de qualquer divergência acima, não prossiga com a exclusão e consulte o Depto.Fiscal."+cEOL+cEOL+;
			"Deseja prosseguir ?","Aviso","INFO")
	lRetorno := .F.	
Endif
*/                                                                             
Return(lRetorno)
