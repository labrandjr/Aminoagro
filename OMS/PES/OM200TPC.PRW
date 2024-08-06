#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ OM200TPC  ¦ Autor ¦ Fábrica ERP.BR   ¦  Data  ¦ 20/03/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Botões adicionais para funções de usuário.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function OM200TPC()

Local aArea    := GetArea()
Local zTesHide := AllTrim(GetMv("MV_ZTESHID"))
Local lRetCarg := .T.

DbSelectArea("SC6")
DbSetOrder(1)
If DbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM )
	If SC6->C6_TES $(zTesHide)
		lRetCarg := PedVenBlq(SC9->C9_CLIENTE) // Não exibe se houver pedido de venda bloqueado por crédito
	Endif
Endif

RestArea(aArea)

Return(lRetCarg)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PedVenBlq ¦ Autor ¦ Fábrica ERP.BR   ¦  Data  ¦ 24/03/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checagem se o cliente possui pedido de venda bloqueado.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function PedVenBlq(zCliente)

Local aArea := GetArea()
Local lBloq := .F.

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SC9")+" SC9, "
cQuery += RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND C9_FILIAL = C5_FILIAL "
cQuery += " AND C9_PEDIDO = C5_NUM "
cQuery += " AND C9_FILIAL = C6_FILIAL "
cQuery += " AND C9_PEDIDO = C6_NUM "
cQuery += " AND C9_ITEM = C6_ITEM "
cQuery += " AND C6_FILIAL = F4_FILIAL "
cQuery += " AND C6_TES = F4_CODIGO "
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C9_BLCRED <> ' ' AND C9_BLCRED <> '10' "
cQuery += " AND F4_DUPLIC = 'S' AND F4_ESTOQUE = 'S' "
cQuery += " AND C9_CLIENTE = '"+zCliente+"' "
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL9", .F., .T.)
lBloq := (SQL9->SOMA == 0)
SQL9->(DbCloseArea())

RestArea(aArea)

Return(lBloq)
