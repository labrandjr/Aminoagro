#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA440AC ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 30/09/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Habilita edição do Armazém na liberação do pedido.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA440AC()

Local aCpoAdd := {}

AAdd(aCpoAdd,"C6_LOCAL")
                                                                             
Return(aCpoAdd)


User Function A440Armz()

Local lRetOk := .T.

If FunName() == "MATA440"
	zItem   := aCols[n][GdFieldPos("C6_ITEM")]
	zProdut := aCols[n][GdFieldPos("C6_PRODUTO")]
	zQtdLib := aCols[n][GdFieldPos("C6_QTDLIB")]
	zTes    := aCols[n][GdFieldPos("C6_TES")]
	lEstoqu := (RetField("SF4",1,xFilial("SF4")+zTes,"F4_ESTOQUE") == "S")
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( xFilial("SC6") + SC5->C5_NUM + zItem )
	If M->C6_LOCAL != SC6->C6_LOCAL
		If !Empty(SC6->C6_BLQ)
			MsgInfo("Alteração não permitida. Item eliminado por resíduo.")
			lRetOk := .F.
		ElseIf zQtdLib == 0
			MsgInfo("Alteração não permitida. Qtd.Liberada não informada.")
			lRetOk := .F.
		ElseIf SC6->C6_QTDEMP > 0	
			MsgInfo("Alteração não permitida. Item já possui Qtd.Liberada.")
			lRetOk := .F.
		ElseIf SC6->(C6_QTDVEN-C6_QTDENT) == 0	
			MsgInfo("Alteração não permitida. Item totalmente faturado.")
			lRetOk := .F.
		ElseIf SC5->C5_TIPO != "N"
			MsgInfo("Alteração permitida somente para pedidos Tipo = 'Normal'.")
			lRetOk := .F.
		ElseIf !lEstoqu
			MsgInfo("Alteração não permitida. Tipo de Saída não atualiza estoque.")
			lRetOk := .F.
		Else
			DbSelectArea("SB2")
			DbSetOrder(1)
			//
			DbSeek( xFilial("SB2") + zProdut + SC6->C6_LOCAL )
			RecLock("SB2",.F.)
			SB2->B2_QPEDVEN -= SC6->(C6_QTDVEN-C6_QTDENT)
			MsUnLock()
			//
			DbSeek( xFilial("SB2") + zProdut + M->C6_LOCAL )
			RecLock("SB2",.F.)
			SB2->B2_QPEDVEN += SC6->(C6_QTDVEN-C6_QTDENT)
			MsUnLock()
			//
			RecLock("SC6",.F.)
			SC6->C6_LOCAL := M->C6_LOCAL
			MsUnLock()
			//
		Endif
	Endif	
Endif

Return(lRetOk)
