#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M440SC9I  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 14/09/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após liberação do pedido.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function M440SC9I()

Local aArea := GetArea()

// Registro de Log nas Liberações de Pedidos de Venda
DbSelectArea("ZZI")
RecLock("ZZI",.T.)
ZZI->ZZI_FILIAL := SC9->C9_FILIAL
ZZI->ZZI_PEDIDO := SC9->C9_PEDIDO
ZZI->ZZI_ITEM   := SC9->C9_ITEM
ZZI->ZZI_SEQUEN := SC9->C9_SEQUEN
ZZI->ZZI_DATALI := SC9->C9_DATALIB
ZZI->ZZI_QTDLIB := SC9->C9_QTDLIB
ZZI->ZZI_BLEST  := SC9->C9_BLEST
ZZI->ZZI_BLCRED := SC9->C9_BLCRED
ZZI->ZZI_LOCAL  := SC9->C9_LOCAL
ZZI->ZZI_LOTECT := SC9->C9_LOTECTL
ZZI->ZZI_CARGA  := SC9->C9_CARGA
ZZI->ZZI_MOTBLQ := SC9->C9_XMOTBLQ
ZZI->ZZI_USUARI := cUserName
ZZI->ZZI_DATA   := Date()
ZZI->ZZI_HORA   := Time()
ZZI->ZZI_ROTINA := FunName()
MsUnLock()

// Envio dos alertas apenas nas rotinas: Pedido de Venda, Liberação de Pedidos, Liberação Crédito Pedidos e Liberação Crédito Clientes.
// Despreza envio dos alertas para demais rotinas, pois o sc9 é recriado.
If !(FunName() $("MATA410,MATA440,MATA450,MATA450A"))
	Return
Endif

DbSelectArea("SC6")
DbSetOrder(1)
If DbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM )
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + SC6->C6_TES )
	If SF4->F4_DUPLIC <> "S"
		Return
	Endif
Endif

If !Empty(SC9->C9_BLCRED)
	If !Empty(zMotBlq)
		//
		RecLock("SC9",.F.)
		SC9->C9_XMOTBLQ := zMotBlq
		MsUnLock()
		//
		DbSelectArea("ZZA")
		DbSetOrder(1)
		If !DbSeek( xFilial("ZZA") + SC9->C9_PEDIDO + SC9->C9_ITEM )
			RecLock("ZZA",.T.)
			ZZA->ZZA_FILIAL := xFilial("ZZA")
			ZZA->ZZA_PEDIDO := SC9->C9_PEDIDO
			ZZA->ZZA_ITEM   := SC9->C9_ITEM
		Else
			RecLock("ZZA",.F.)
		Endif
		ZZA->ZZA_EMLSTT := "1" // Bloqueado
		ZZA->ZZA_TXTLIB := ""  // Zera o motivo da liberação
		ZZA->ZZA_TIPLIB := ""  // Zera o tipo da liberação
		MsUnLock()
		//
	Endif
Else
	zTes := RetField("SC6",1,xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM),"C6_TES")
	zDup := RetField("SF4",1,xFilial("SF4")+zTes,"F4_DUPLIC")
	lDup := (zDup == "S")
	If lDup
		DbSelectArea("ZZA")
		DbSetOrder(1)
		If DbSeek( xFilial("ZZA") + SC9->C9_PEDIDO + SC9->C9_ITEM )
			If ZZA->ZZA_EMLSTT == "1"
				RecLock("ZZA",.F.)
				ZZA->ZZA_EMLSTT := "2" // Aguardando envio do email
				If FunName() == "MATA450"
					ZZA->ZZA_TXTLIB := "Liberado por "+AllTrim(cUserName)+" em "+DtoC(Date())+" - Lib.Automática"  // Motivo da liberação
				ElseIf FunName() == "MATA450A"
					ZZA->ZZA_TXTLIB := "Liberado por "+AllTrim(cUserName)+" em "+DtoC(Date())+" - Lib.por Cliente"  // Motivo da liberação
				Else // Prever reavaliação em itens bloqueados anteriormente, através de alteração no pedido de venda, ou liberação de pedidos complementar.
					ZZA->ZZA_TXTLIB := "Liberado via Limite de Crédito em "+DtoC(Date()) // Motivo da liberação
				Endif	
				ZZA->ZZA_TIPLIB := "A" // Automática
				MsUnLock()
			ElseIf ZZA->ZZA_EMLSTT == "3"
				RecLock("ZZA",.F.)
				ZZA->ZZA_EMLSTT := "2" // Aguardando envio do email
				ZZA->ZZA_TXTLIB := "Liberado via Limite de Crédito em "+DtoC(Date()) // Motivo da liberação
				ZZA->ZZA_TIPLIB := "A" // Automática
				MsUnLock()
			Endif	
		Else	
			RecLock("ZZA",.T.)
			ZZA->ZZA_FILIAL := xFilial("ZZA")
			ZZA->ZZA_PEDIDO := SC9->C9_PEDIDO
			ZZA->ZZA_ITEM   := SC9->C9_ITEM
			ZZA->ZZA_EMLSTT := "2" // Aguardando envio do email
			ZZA->ZZA_TXTLIB := "Liberado via Limite de Crédito em "+DtoC(Date()) // Motivo da liberação
			ZZA->ZZA_TIPLIB := "A" // Automática
			MsUnLock()
		Endif
	Endif	
Endif

RestArea(aArea)

Return
