#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT240TOK  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 16/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do centro de custo para Produtos B1_TIPO = PV.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT240TOK()

Local aArea  := GetArea()
Local lRetOk := .T.

cTipo := Posicione("SB1",1,xFilial("SB1") + M->D3_COD,"B1_TIPO")
If AllTrim(cTipo) == "PV"
	If Empty(M->D3_CC)
		MsgInfo("Atenção, produto 'Tipo = PV' obrigatório informar o centro de custo.")
		lRetOk := .F.
	Endif
Endif

If lRetOk
	If !Empty(M->D3_OP)
		MsgInfo("Atenção, movimentação interna manual vinculada a OP não permitida.")
		lRetOk := .F.
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
