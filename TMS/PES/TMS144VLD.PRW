#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TMS144VLD ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 31/07/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravações específicas para a Viagem.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TMS144VLD()

Local aArea     := GetArea()
Local nOpcX     := PARAMIXB[1]
Local nVPedg    := GetMv("MV_ZVLRPDG") // Valor unitário Pedágio
Local nVComb    := GetMv("MV_ZVLRCMB") // Valor unitário Combustível
Local nVDiar    := GetMv("MV_ZVLRDIA") // Valor unitário Diária
Local zCodPedg  := AllTrim(GetMv("MV_ZDSPPDG")) // Código da despesa de Pedágio
Local zCodComb  := AllTrim(GetMv("MV_ZDSPCMB")) // Código da despesa de Combustível
Local zCodAdto  := AllTrim(GetMv("MV_ZDSPADT")) // Código da despesa de Adiantamento
Local zCodDiar  := AllTrim(GetMv("MV_ZDSPDIA")) // Código da despesa de Diária
Local nDespPedg := 0
Local nDespComb := 0
Local nDespAdto := 0
Local nDespDiar := 0
Local zVeiculo  := ""
Local zCodRbq1  := ""
Local zCodRbq2  := ""
Local zNumDoc   := ""
Local lRetX     := .T.
Local _x

If nOpcX == 3 .Or. nOpcX == 4

	nDespAdto := M->DTQ_ZZADTO
	nDespDiar := M->DTQ_ZZQDIA * nVDiar

	If Len(aCompViag) > 0
		zVeiculo := aCompViag[2][1][aScan(aCompViag[1],{|x| x[2] == "DTR_CODVEI"})]
		zCodRbq1 := aCompViag[2][1][aScan(aCompViag[1],{|x| x[2] == "DTR_CODRB1"})]
		zCodRbq2 := aCompViag[2][1][aScan(aCompViag[1],{|x| x[2] == "DTR_CODRB2"})]
		nTotalKm := 0
		For _x := 1 to Len(aCols)
			zFilDoc := aCols[_x][GdFieldPos("DTA_FILDOC")]
			zDoc    := aCols[_x][GdFieldPos("DTA_DOC")]
			zSerie  := aCols[_x][GdFieldPos("DTA_SERIE")]
			If M->DTQ_SERTMS == "1" // Coleta
				DbSelectArea("DT5")
				DbSetOrder(4)
				If DbSeek( xFilial("DT5") + zFilDoc + zDoc + zSerie )
					nTotalKm += DT5->DT5_KM
				Endif
			ElseIf M->DTQ_SERTMS == "3" // Entrega
				DbSelectArea("DTC")
				DbSetOrder(16)
				If DbSeek( xFilial("DTC") + zDoc + zSerie + zFilDoc )
					nTotalKm += DTC->DTC_KM
				Endif
			Endif
		Next _x

		DbSelectArea("DA3")
		DbSetOrder(1)
		If DbSeek( xFilial("DA3") + zVeiculo )
			nDespPedg := (M->DTQ_ZZQPDG * (DA3->DA3_QTDEIX * nVPedg)) // Pedágio
			nDespComb := ((nTotalKm / DA3->DA3_ZZKMLT) * nVComb) // Combustível
		Endif

		DbSelectArea("DA3")
		DbSetOrder(1)
		If DbSeek( xFilial("DA3") + zCodRbq1 )
			nDespPedg += (M->DTQ_ZZQPDG * (DA3->DA3_QTDEIX * nVPedg)) // Pedágio Reboque 1
		Endif

		DbSelectArea("DA3")
		DbSetOrder(1)
		If DbSeek( xFilial("DA3") + zCodRbq2 )
			nDespPedg += (M->DTQ_ZZQPDG * (DA3->DA3_QTDEIX * nVPedg)) // Pedágio Reboque 2
		Endif

	Endif	

Endif

If (nDespPedg > 0 .Or. nDespComb > 0) .And. !Empty(zVeiculo)
	
	cQuery := " SELECT R_E_C_N_O_ AS RECSDG "
	cQuery += " FROM "+RetSqlName("SDG")
	cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
	cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
	cQuery += " AND DG_VIAGEM = '"+M->DTQ_VIAGEM+"' "
	cQuery += " AND DG_CODVEI = '"+zVeiculo+"' "
	cQuery += " AND DG_CODDES = '"+zCodPedg+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLG", .F., .T.)
	DbSelectArea("SQLG")
	SQLG->(DbGotop())
	If !Eof()
		DbSelectArea("SDG")
		SDG->(DbGoto(SQLG->RECSDG))
		If SDG->DG_TOTAL == SDG->DG_SALDO
			RecLock("SDG",.F.)
			SDG->DG_CODVEI  := zVeiculo
			SDG->DG_TOTAL   := nDespPedg
			SDG->DG_CUSTO1  := nDespPedg
			SDG->DG_VALCOB  := nDespPedg
			SDG->DG_SALDO   := nDespPedg
			MsUnLock()
		Else
			MsgInfo("A despesa de pedágio já foi movimentada e não será atualizada.")
		Endif	
	Endif
	SQLG->(DbCloseArea())	

	cQuery := " SELECT R_E_C_N_O_ AS RECSDG "
	cQuery += " FROM "+RetSqlName("SDG")
	cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
	cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
	cQuery += " AND DG_VIAGEM = '"+M->DTQ_VIAGEM+"' "
	cQuery += " AND DG_CODVEI = '"+zVeiculo+"' "
	cQuery += " AND DG_CODDES = '"+zCodComb+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLG", .F., .T.)
	DbSelectArea("SQLG")
	SQLG->(DbGotop())
	If !Eof()
		DbSelectArea("SDG")
		SDG->(DbGoto(SQLG->RECSDG))
		If SDG->DG_TOTAL == SDG->DG_SALDO
			RecLock("SDG",.F.)
			SDG->DG_CODVEI  := zVeiculo
			SDG->DG_TOTAL   := nDespComb
			SDG->DG_CUSTO1  := nDespComb
			SDG->DG_VALCOB  := nDespComb
			SDG->DG_SALDO   := nDespComb
			MsUnLock()
		Else
			MsgInfo("A despesa de combustível já foi movimentada e não será atualizada.")
		Endif	
	Endif
	SQLG->(DbCloseArea())	

Endif

zItemDg := "00"
DbSelectArea("SDG")
DbSetOrder(5)
If DbSeek( xFilial("SDG") + M->DTQ_FILORI + M->DTQ_VIAGEM )
	While !Eof() .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == xFilial("SDG") + M->DTQ_FILORI + M->DTQ_VIAGEM
		zItemDg := SDG->DG_ITEM
		SDG->(DbSkip())
	Enddo
Endif

If nDespAdto > 0 .And. !Empty(zVeiculo)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SDG")
	cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
	cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
	cQuery += " AND DG_VIAGEM = '"+M->DTQ_VIAGEM+"' "
	cQuery += " AND DG_CODVEI = '"+zVeiculo+"' "
	cQuery += " AND DG_CODDES = '"+zCodAdto+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLG", .F., .T.)
	lIncDesp := (SQLG->SOMA == 0)
	SQLG->(DbCloseArea())
	If lIncDesp
		cQuery := " SELECT MAX(DG_DOC) AS DG_DOC "
		cQuery += " FROM "+RetSqlName("SDG")
		cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
		cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB1", .F., .T.)
		zNumDoc := Soma1(TRB1->DG_DOC)
		TRB1->(DbCloseArea())
		//
		DbSelectArea("SDG")
		cNumSeq := ProxNum()
		zItemDg := Soma1(zItemDg)
		RecLock("SDG",.T.)
		SDG->DG_FILIAL  := xFilial("SDG")
		SDG->DG_ITEM    := zItemDg
		SDG->DG_DOC     := zNumDoc
		SDG->DG_EMISSAO := M->DTQ_DATGER
		SDG->DG_CODDES  := zCodAdto
		SDG->DG_CODVEI  := zVeiculo
		SDG->DG_FILORI  := M->DTQ_FILORI
		SDG->DG_VIAGEM  := M->DTQ_VIAGEM
		SDG->DG_TOTAL   := nDespAdto
		SDG->DG_CUSTO1  := nDespAdto
		SDG->DG_ORIGEM  := "SDG"
		SDG->DG_STATUS  := "1"
		SDG->DG_VALCOB  := nDespAdto
		SDG->DG_SALDO   := nDespAdto
		SDG->DG_DATVENC := M->DTQ_DATGER
		SDG->DG_NUMSEQ  := cNumSeq
		MsUnLock()
	Endif
Endif

If nDespDiar > 0 .And. !Empty(zVeiculo)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SDG")
	cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
	cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
	cQuery += " AND DG_VIAGEM = '"+M->DTQ_VIAGEM+"' "
	cQuery += " AND DG_CODVEI = '"+zVeiculo+"' "
	cQuery += " AND DG_CODDES = '"+zCodDiar+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLG", .F., .T.)
	lIncDesp := (SQLG->SOMA == 0)
	SQLG->(DbCloseArea())
	If lIncDesp
		cQuery := " SELECT MAX(DG_DOC) AS DG_DOC "
		cQuery += " FROM "+RetSqlName("SDG")
		cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
		cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB1", .F., .T.)
		zNumDoc := Soma1(TRB1->DG_DOC)
		TRB1->(DbCloseArea())
		//
		DbSelectArea("SDG")
		cNumSeq := ProxNum()
		zItemDg := Soma1(zItemDg)
		RecLock("SDG",.T.)
		SDG->DG_FILIAL  := xFilial("SDG")
		SDG->DG_ITEM    := zItemDg
		SDG->DG_DOC     := zNumDoc
		SDG->DG_EMISSAO := M->DTQ_DATGER
		SDG->DG_CODDES  := zCodDiar
		SDG->DG_CODVEI  := zVeiculo
		SDG->DG_FILORI  := M->DTQ_FILORI
		SDG->DG_VIAGEM  := M->DTQ_VIAGEM
		SDG->DG_TOTAL   := nDespDiar
		SDG->DG_CUSTO1  := nDespDiar
		SDG->DG_ORIGEM  := "SDG"
		SDG->DG_STATUS  := "1"
		SDG->DG_VALCOB  := nDespDiar
		SDG->DG_SALDO   := nDespDiar
		SDG->DG_DATVENC := M->DTQ_DATGER
		SDG->DG_NUMSEQ  := cNumSeq
		MsUnLock()
	Endif
Endif

If nDespPedg > 0 .And. !Empty(zVeiculo)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SDG")
	cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
	cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
	cQuery += " AND DG_VIAGEM = '"+M->DTQ_VIAGEM+"' "
	cQuery += " AND DG_CODVEI = '"+zVeiculo+"' "
	cQuery += " AND DG_CODDES = '"+zCodPedg+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLG", .F., .T.)
	lIncDesp := (SQLG->SOMA == 0)
	SQLG->(DbCloseArea())
	If lIncDesp
		cQuery := " SELECT MAX(DG_DOC) AS DG_DOC "
		cQuery += " FROM "+RetSqlName("SDG")
		cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
		cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB1", .F., .T.)
		zNumDoc := Soma1(TRB1->DG_DOC)
		TRB1->(DbCloseArea())
		//
		DbSelectArea("SDG")
		cNumSeq := ProxNum()
		zItemDg := Soma1(zItemDg)
		RecLock("SDG",.T.)
		SDG->DG_FILIAL  := xFilial("SDG")
		SDG->DG_ITEM    := zItemDg
		SDG->DG_DOC     := zNumDoc
		SDG->DG_EMISSAO := M->DTQ_DATGER
		SDG->DG_CODDES  := zCodPedg
		SDG->DG_CODVEI  := zVeiculo
		SDG->DG_FILORI  := M->DTQ_FILORI
		SDG->DG_VIAGEM  := M->DTQ_VIAGEM
		SDG->DG_TOTAL   := nDespPedg
		SDG->DG_CUSTO1  := nDespPedg
		SDG->DG_ORIGEM  := "SDG"
		SDG->DG_STATUS  := "1"
		SDG->DG_VALCOB  := nDespPedg
		SDG->DG_SALDO   := nDespPedg
		SDG->DG_DATVENC := M->DTQ_DATGER
		SDG->DG_NUMSEQ  := cNumSeq
		MsUnLock()
	Endif
Endif

If nDespComb > 0 .And. !Empty(zVeiculo)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SDG")
	cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
	cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
	cQuery += " AND DG_VIAGEM = '"+M->DTQ_VIAGEM+"' "
	cQuery += " AND DG_CODVEI = '"+zVeiculo+"' "
	cQuery += " AND DG_CODDES = '"+zCodComb+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLG", .F., .T.)
	lIncDesp := (SQLG->SOMA == 0)
	SQLG->(DbCloseArea())
	If lIncDesp
		cQuery := " SELECT MAX(DG_DOC) AS DG_DOC "
		cQuery += " FROM "+RetSqlName("SDG")
		cQuery += " WHERE DG_FILIAL = '"+xFilial("SDG")+"' "
		cQuery += " AND DG_FILORI = '"+M->DTQ_FILORI+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB1", .F., .T.)
		zNumDoc := Soma1(TRB1->DG_DOC)
		TRB1->(DbCloseArea())
		//
		DbSelectArea("SDG")
		cNumSeq := ProxNum()
		zItemDg := Soma1(zItemDg)
		RecLock("SDG",.T.)
		SDG->DG_FILIAL  := xFilial("SDG")
		SDG->DG_ITEM    := zItemDg
		SDG->DG_DOC     := zNumDoc
		SDG->DG_EMISSAO := M->DTQ_DATGER
		SDG->DG_CODDES  := zCodComb
		SDG->DG_CODVEI  := zVeiculo
		SDG->DG_FILORI  := M->DTQ_FILORI
		SDG->DG_VIAGEM  := M->DTQ_VIAGEM
		SDG->DG_TOTAL   := nDespComb
		SDG->DG_CUSTO1  := nDespComb
		SDG->DG_ORIGEM  := "SDG"
		SDG->DG_STATUS  := "1"
		SDG->DG_VALCOB  := nDespComb
		SDG->DG_SALDO   := nDespComb
		SDG->DG_DATVENC := M->DTQ_DATGER
		SDG->DG_NUMSEQ  := cNumSeq
		MsUnLock()
	Endif
Endif

RestArea(aArea)

Return(lRetX)
