#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA450T   ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 14/09/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após análise de crédito automática.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA450T()

Local aArea := GetArea()

If !(FunName() $("MATA410,MATA440,MATA450,MATA450A")) // Despreza avaliação do estoque para envio dos alertas, pois o sc9 é recriado.
	Return
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
				ZZA->ZZA_TXTLIB := "Liberado por "+AllTrim(cUserName)+" em "+DtoC(Date())+" - Lib.Automática"  // Motivo da liberação
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
