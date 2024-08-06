#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SF1100I   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 29/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Dados complementares após gravação da nota fiscal.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SF1100I()

Local aArea   := GetArea()
Local lImpXml := GetMv("MV_IMPXML")
Local lDv8045 := SuperGetMV("MV_ZDV8045",.F.,.F.)
Local _rat

If SF1->F1_TIPO == "F"
    //
	RecLock("SF1",.F.)
	SF1->F1_TIPO := "N"
	MsUnLock()
	//
	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
	While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		RecLock("SD1",.F.)
		SD1->D1_TIPO := "N"
		MsUnLock()
		SD1->(DbSkip())
	Enddo
	//
Endif

l8045 := .F.
DbSelectArea("SD1")
DbSetOrder(1)
DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	If SD1->D1_TP == "AI" .And. !Empty(SD1->D1_PEDIDO)
		u_ChkProj(SD1->D1_FILIAL, SD1->D1_PEDIDO, SD1->D1_ITEMPC, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM)
	Endif
	If lDv8045
		If AllTrim(SD1->D1_COD) == "DESPVND_0021" .And. !l8045
			l8045 := .T.
		Endif
	Endif
	DbSelectArea("SD1")
	SD1->(DbSkip())
Enddo

zParcIrr := ""
zParcPis := ""
zParcCof := ""
zParCsll := ""
DbSelectArea("SE2")
DbSetOrder(6)
If DbSeek( xFilial("SE2") + SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DOC) )
	While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == xFilial("SE2") + SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DOC)
		If !Empty(SE2->E2_PARCIR)
			zParcIrr := SE2->E2_PARCIR
		Endif
		If !Empty(SE2->E2_PARCPIS)
			zParcPis := SE2->E2_PARCPIS
		Endif
		If !Empty(SE2->E2_PARCCOF)
			zParcCof := SE2->E2_PARCCOF
		Endif
		If !Empty(SE2->E2_PARCSLL)
			zParCsll := SE2->E2_PARCSLL
		Endif
		SE2->(DbSkip())
	Enddo
Endif

If lDv8045
	If !Empty(zParcIrr)
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek( xFilial("SE2") + SF1->F1_PREFIXO + SF1->F1_DOC + zParcIrr + "TX " )
			If Empty(SE2->E2_CODRET) .Or. l8045
				RecLock("SE2",.F.)
				SE2->E2_CODRET := IIf(l8045,"8045","1708")
				MsUnLock()
			Endif
			If SE2->E2_DIRF != "1"
				RecLock("SE2",.F.)
				SE2->E2_DIRF := "1"
				MsUnLock()
			Endif
		Endif
	Endif
	If !Empty(zParcPis)
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek( xFilial("SE2") + SF1->F1_PREFIXO + SF1->F1_DOC + zParcPis + "TX " )
			If Empty(SE2->E2_CODRET) .Or. SE2->E2_DIRF != "1"
				RecLock("SE2",.F.)
				SE2->E2_DIRF   := "1"
				SE2->E2_CODRET := "5952"
				MsUnLock()
			Endif
		Endif
	Endif
	If !Empty(zParcCof)
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek( xFilial("SE2") + SF1->F1_PREFIXO + SF1->F1_DOC + zParcCof + "TX " )
			If Empty(SE2->E2_CODRET) .Or. SE2->E2_DIRF != "1"
				RecLock("SE2",.F.)
				SE2->E2_DIRF   := "1"
				SE2->E2_CODRET := "5952"
				MsUnLock()
			Endif
		Endif
	Endif
	If !Empty(zParCsll)
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek( xFilial("SE2") + SF1->F1_PREFIXO + SF1->F1_DOC + zParCsll + "TX " )
			If Empty(SE2->E2_CODRET) .Or. SE2->E2_DIRF != "1"
				RecLock("SE2",.F.)
				SE2->E2_DIRF   := "1"
				SE2->E2_CODRET := "5952"
				MsUnLock()
			Endif
		Endif
	Endif
Endif

If lImpXml
	If SF1->F1_TIPO == "N" .And. AllTrim(SF1->F1_ESPECIE) == "CTE" .And. AllTrim(SF1->F1_ORIGEM) == "COMXCOL" .And. SF1->F1_XIMPXML == "R"
		DbSelectArea("SD1")
		DbSetOrder(1)
		If DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
			If AllTrim(SD1->D1_COD) == AllTrim(GetMv("MV_XMLPFCT"))
				aRatCte := u_ChkRatCte()
				nVlrAcu := 0
				nPerAcu := 0
				For _rat := 1 to Len(aRatCte)
					If _rat == Len(aRatCte)
						nCust := SF1->(F1_VALMERC+F1_VALPEDG) - nVlrAcu
						nPerc := 100 - nPerAcu
					Else
						nCust := aRatCte[_rat][3]
						nPerc := Round(((nCust / SF1->(F1_VALMERC+F1_VALPEDG)) * 100),2)
					Endif	
					nVlrAcu += nCust
					nPerAcu += nPerc
					DbSelectArea("SDE")
					RecLock("SDE",.T.)
					SDE->DE_FILIAL  := SF1->F1_FILIAL
					SDE->DE_DOC     := SF1->F1_DOC
					SDE->DE_SERIE   := SF1->F1_SERIE
					SDE->DE_FORNECE := SF1->F1_FORNECE
					SDE->DE_LOJA    := SF1->F1_LOJA
					SDE->DE_ITEMNF  := SD1->D1_ITEM
					SDE->DE_ITEM    := StrZero(_rat,4)
					SDE->DE_PERC    := nPerc
					SDE->DE_CC      := aRatCte[_rat][2]
					SDE->DE_CONTA   := aRatCte[_rat][1]
					SDE->DE_ITEMCTA := Posicione("CTT",1,xFilial("CTT") + aRatCte[_rat][2],"CTT_ZZITCT")
					SDE->DE_CUSTO1  := nCust
					SDE->DE_SDOC    := SF1->F1_SERIE
					MsUnLock()
				Next _rat
				RecLock("SD1",.F.)
				SD1->D1_RATEIO := "1"
				MsUnLock()
			Endif	
		Endif
	Endif
Endif

RestArea(aArea)

Return
