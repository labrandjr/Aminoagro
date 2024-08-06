#include 'Protheus.ch'
#include 'TopConn.ch'

/*/{protheus.doc}QQFAT01
Função para gravar o conteúdo do campo A3_ZZCC para o campo C6_CCUSTO de acordo com o numero de itens do pedido de vendas
@author Gustavo Luiz
@since  16/03/2016
/*/
User Function QQFAT01()

Local aArea    := GetArea()
Local aAreaSC6 := SC6->(GetArea())

If (Inclui .Or. Altera)
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( xFilial("SC6") + M->C5_NUM )
	While !Eof() .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6") + M->C5_NUM
		If Empty(SC6->C6_ZZITCTB)
			RecLock("SC6",.F.)
			SC6->C6_ZZITCTB := RetField("CTT",1,xFilial("CTT")+SC6->C6_CCUSTO,"CTT_ZZITCT")
			MsUnLock()
		Endif	
		SC6->(DbSkip())
	Enddo
Endif

SC6->(RestArea(aAreaSC6))
RestArea(aArea)

Return

/*
Local aArea 		:= GetArea()
Local aAreaSC6 		:= SC6->(GetArea())
Local aAreaSA3 		:= SA3->(GetArea())
Local cCentroCusto 	:= Posicione("SA3", 1, xFilial("SA3") + M->C5_VEND1,"A3_ZZCC")

If (Inclui .Or. Altera) .And. !Empty(cCentroCusto)
	GetPedidos(M->C5_NUM)
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	While cAlias->(!Eof())
		If SC6->(DbSeek( xFilial("SC6") + cAlias->C6_NUM + cAlias->C6_ITEM + cAlias->C6_PRODUTO ))
			RecLock("SC6",.F.)
			SC6->C6_CCUSTO := cCentroCusto
			SC6->(MsUnLock())
		Endif
		cAlias->(DbSkip())
	EndDo
	cAlias->(DbCloseArea())
Endif

SA3->(RestArea(aAreaSA3))
SC6->(RestArea(aAreaSC6))
RestArea(aArea)

Return
*/

/**
* Obtém os itens do pedido de vendas de acordo com o numero do pedido de vendas
**/
Static Function GetPedidos(cNumPedido)
/*
Local cQuery	:=""
Local cAlias 	:= GetNextAlias()
Local nRegistos	:= 0

cQuery := " SELECT SC6.C6_FILIAL, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_NUM "	+ CRLF
cQuery += " FROM "+RetSqlName("SC6")+" SC6 "                                + CRLF
cQuery += " WHERE "                                                         + CRLF
cQuery += "  SC6.D_E_L_E_T_=' ' "                                           + CRLF
cQuery += "	 AND SC6.C6_FILIAL='"+xFilial("SC6")+"'"                        + CRLF
cQuery += "	 AND SC6.C6_NUM='"+cNumPedido+"'"                               + CRLF

MemoWrite("SQLQQFAT01.TXT",cQuery)
TCQUERY cQuery NEW ALIAS cAlias
Count To nRegistos
cAlias->(DbGoTop())
*/
Return
