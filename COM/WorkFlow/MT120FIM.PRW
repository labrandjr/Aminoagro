#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT120FIM  ¦ Autor ¦ ERPBR            ¦   Data  ¦ Fev/17    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ponto de entrada após gravaçao do Pedido de Compra.     	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Pacotes   ¦ 28/09/2021 - Projeto Workflow versão 2.0 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT120FIM()

Local aArea    := GetArea()
Local aAreaSC7 := SC7->(GetArea())
Local nRotina  := PARAMIXB[1]   // 2=Visualização | 3=Inclusão | 4=Alteração | 5=Exclusão | 9=Cópia
Local cNumPC   := PARAMIXB[2]   // Numero do Pedido de Compras
Local nOpcao   := PARAMIXB[3]   // 0=Cancelar | 1=Salvar
Local lWfPc    := ( AllTrim(GetMv("MV_WFPCINT")) == "S" )
Local lWfV2    := GetMv("MV_ZWFVER2")

If nOpcao == 1 .And. (nRotina == 3 .Or. nRotina == 4 .Or. nRotina == 9) .And. cZZGoAlt == "Sim"
	zRecSC7 := SC7->(Recno())
	DbSelectArea("SC7")
	DbSetOrder(1)
	If DbSeek( xFilial("SC7") + cNumPC )
		While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7") + cNumPC
			RecLock("SC7",.F.)
			SC7->C7_ZZENVWF := IIf(cZZEnvWf=="Sim","S","N")
			SC7->C7_ZZCGC   := Posicione("SA2",1,xFilial("SA2") + SC7->(C7_FORNECE+C7_LOJA),"A2_CGC")
			MsUnLock()
			DbSelectArea("SC7")
			SC7->(DbSkip())
		Enddo
	Endif
	SC7->(DbGoto(zRecSC7))
Endif

lEnvWf := (cZZEnvWf=="Sim")

If lWfPc
	If nOpcao == 1 .And. (nRotina == 3 .Or. nRotina == 4 .Or. nRotina == 9)
		cModo := ""
		If lWfV2
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("ZZJ")
			cQuery += " WHERE ZZJ_FILIAL = '"+xFilial("SC7")+"' "
			cQuery += " AND ZZJ_PEDIDO = '"+cNumPC+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)
			cModo := IIf(SQL7->SOMA == 0, "Inclusão", "Alteração")
			SQL7->(DbCloseArea())
		Endif
		If lEnvWf
			cRotina := IIf(nRotina == 3,"Inclusão",IIf(nRotina == 4,"Alteração","Cópia"))
			DbSelectArea("SC7")
			DbSetOrder(1)
			DbSeek( xFilial("SC7") + cNumPC )
			U_WFPC01(.F.,Nil,.T.,.F.,cRotina,cModo) // WFPC01(lJob,cNumPed,lShow,lAsk,cRotina,cModo)
		Else
			If cZZGoAlt == "Sim"
				MsgInfo("Envio do workflow desligado para o Pedido "+SC7->C7_NUM+".")
			Endif	
		Endif
	Endif	
Endif

// Atualiza flag compra de MP
u_ChkPcMp()

// Capex
lTipoAI := .F.
zProjet := ""
zRevisa := ""
lProjOk := .F.
DbSelectArea("SC7")
DbSetOrder(1)
DbSeek( xFilial("SC7") + cNumPC )
While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == xFilial("SC7") + cNumPC
	lTipoAI := ( RetField("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TIPO") == "AI" )
	If lTipoAI
		zProjet := RetField("AJ7",2,xFilial("AJ7")+SC7->C7_NUM,"AJ7_PROJET")
		zRevisa := RetField("AJ7",2,xFilial("AJ7")+SC7->C7_NUM,"AJ7_REVISA")
		If !Empty(zProjet)
			lProjOk := .T.
			Exit
		Endif	
	Endif
	DbSelectArea("SC7")
	SC7->(DbSkip())	
Enddo

If lTipoAI .And. lProjOk
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( xFilial("SC7") + cNumPC )
	While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == xFilial("SC7") + cNumPC
		//
		DbSelectArea("AJ7")
		DbSetOrder(2)
		If !DbSeek( xFilial("AJ7") + SC7->C7_NUM + SC7->C7_ITEM )
			RecLock("AJ7",.T.)
			AJ7->AJ7_FILIAL := xFilial("AJ7")
			AJ7->AJ7_PROJET := zProjet
			AJ7->AJ7_TAREFA := "01"
			AJ7->AJ7_NUMPC  := SC7->C7_NUM
			AJ7->AJ7_ITEMPC := SC7->C7_ITEM
			AJ7->AJ7_COD    := SC7->C7_PRODUTO
			AJ7->AJ7_QUANT  := 1
			AJ7->AJ7_REVISA := zRevisa
			MsUnLock()
		Else
			RecLock("AJ7",.F.)
			AJ7->AJ7_PROJET := zProjet
			AJ7->AJ7_REVISA := zRevisa
			MsUnLock()
		Endif
		//
		DbSelectArea("SC7")
		SC7->(DbSkip())	
	Enddo
Endif

RestArea(aAreaSC7)
RestArea(aArea)

Return
