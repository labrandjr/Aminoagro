#include "protheus.ch"
#include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função PutD2UN

Função que grava a unidade de negócio na tabela SD2, no campo D2_ITEMCC.
A função buscaCC(cVendedor) retorna o centro de custo definino no campo
A3_ZZCC. Este retorno é gravado no campo D2_CCUSTO.

@author 	Augusto Krejci Bem-Haja
@since 		15/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------

User Function PutD2UN()
Local aArea		:= GetArea()
Local cDocNum	:= SF2->F2_DOC
Local cDocSerie	:= SF2->F2_SERIE
Private cAlias	:= ""

Proc_D2(cDocNum,cDocSerie)

RestArea(aArea)
Return

Static Function Proc_D2(cDocNum,cDocSerie)
Local aAreaSD2 := SD2->(GetArea())
Local cTesRmb  := AllTrim(GetMv("MV_XTESRMB")) // TES para Remessa de Brindes

If Substr(FunName(),1,3) == "TMS"
	Return // Notas Fiscais geradas pelo Cálculo de Frete --> CTE
Endif

cAlias := QryRgs(cDocNum,cDocSerie)
(cAlias)->(DbGoTop())

DbSelectArea("SF2")
DbSetOrder(1)
If DbSeek(xFilial("SF2")+cDocNum+cDocSerie)
	RecLock("SF2",.F.)
	SF2->F2_ZZREGVE := (cAlias)->C5_ZZREGVE // Região do Vendedor. Alimentado via gatilho do C5_VEND1.
	// Luis Brandini - Comissões - Gravação das entidades GER e DIR na movimentação
	SF2->F2_GEREN1 := (cAlias)->C5_GEREN1
	SF2->F2_SUPER1 := (cAlias)->C5_SUPER1
	SF2->F2_GEREN2 := (cAlias)->C5_GEREN2
	SF2->F2_SUPER2 := (cAlias)->C5_SUPER2
	SF2->F2_ZZDM   := (cAlias)->C5_ZZDM
	//
	MsUnLock()
Endif

DbSelectArea("SD2")
SD2->(DbSetOrder(3))
If SD2->(DbSeek(xFilial("SD2")+cDocNum+cDocSerie))
	While !SD2->(EOF()) .And. (SD2->D2_FILIAL == xFilial("SD2")) .And. (SD2->D2_DOC == cDocNum) .And. (SD2->D2_SERIE == cDocSerie)
		//
		zzCCust := ""
		zzItCtb := ""
 		//
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek( xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV )
		//
		If SC6->C6_TES $(cTesRmb)
			zzCCust := SC6->C6_CCUSTO  // Centro de Custo informado manualmente em operações de Remessa de Brindes.
			zzItCtb := SC6->C6_ZZITCTB // BU do Centro de Custo informando manualmente em operações de Remessa de Brindes.
		Else
			zzCCust := (cAlias)->C6_CCUSTO  // Centro de Custo do Vendedor1. Alimentado via gatilho do C5_VEND1.
			zzItCtb := (cAlias)->C5_ZZITCTB // BU do Centro de Custo do Vendedor1. Alimentado via gatilho do C5_VEND1.
		Endif
		//
		RecLock("SD2",.F.)
		SD2->D2_CCUSTO  := zzCCust
		SD2->D2_ITEMCC  := zzItCtb
		SD2->D2_ZZTPBON := (cAlias)->C5_ZZTPBON
		SD2->D2_ZZPIMPO := (cAlias)->C6_ZZPIMPO
		SD2->D2_ZZVIMPO := (cAlias)->C6_ZZVIMPO
		SD2->D2_ZZPCUST := (cAlias)->C6_ZZPCUST
		SD2->D2_ZZVCUST := (cAlias)->C6_ZZVCUST
		SD2->D2_ZZVCOMV := (cAlias)->C6_ZZVCOMV
		SD2->D2_ZZVCOMR := (cAlias)->C6_ZZVCOMR
		SD2->D2_ZVCOMR3 := (cAlias)->C6_ZVCOMR3
		SD2->D2_ZVCOMR4 := (cAlias)->C6_ZVCOMR4
		SD2->D2_ZZPFRET := (cAlias)->C6_ZZPFRET
		SD2->D2_ZZVFRET := (cAlias)->C6_ZZVFRET
		SD2->D2_ZZPDPAD := (cAlias)->C6_ZZPDPAD
		SD2->D2_ZZVDPAD := (cAlias)->C6_ZZVDPAD
		SD2->D2_ZZPPDD  := (cAlias)->C6_ZZPPDD
		SD2->D2_ZZVPDD  := (cAlias)->C6_ZZVPDD
		SD2->D2_ZZPPONT := (cAlias)->C6_ZZPPONT
		SD2->D2_ZZVPONT := (cAlias)->C6_ZZVPONT
		SD2->D2_ZZPRENT := (cAlias)->C6_ZZPRENT
		SD2->D2_ZZVRENT := (cAlias)->C6_ZZVRENT
		SD2->D2_ZZPMBR  := (cAlias)->C6_ZZPMBR
		SD2->D2_ZZVMBR  := (cAlias)->C6_ZZVMBR
		SD2->(MsUnLock())
		//
		SD2->(DbSkip())
	Enddo
EndIf
(cAlias)->(DbCloseArea())

RestArea(aAreaSD2)
Return

Static Function QryRgs(cDocNum,cDocSerie)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local cEol   := chr(10) + chr(13)

cQuery := " SELECT 	SF2.F2_DOC, "+ cEol
cQuery += " 		SF2.F2_SERIE, "+ cEol
cQuery += " 		SD2.D2_PEDIDO, "+ cEol
cQuery += " 		SC5.C5_ZZREGVE, "+ cEol
cQuery += " 		SC5.C5_ZZITCTB, "+ cEol
cQuery += "			SC5.C5_ZZTPBON,	"+ cEol
cQuery += "			SC5.C5_VEND1,	"+ cEol
cQuery += "			SC5.C5_GEREN1,	"+ cEol
cQuery += "			SC5.C5_SUPER1,	"+ cEol
cQuery += "			SC5.C5_VEND2,	"+ cEol
cQuery += "			SC5.C5_GEREN2,	"+ cEol
cQuery += "			SC5.C5_SUPER2,	"+ cEol
cQuery += " 	    SC5.C5_ZZDM,	"+ cEol
cQuery += "			SC5.C5_VEND3,	"+ cEol
cQuery += "			SC5.C5_VEND4,	"+ cEol
cQuery += "			SC6.C6_ZZPIMPO,	"+ cEol
cQuery += "			SC6.C6_ZZVIMPO,	"+ cEol
cQuery += "			SC6.C6_ZZPCUST,	"+ cEol
cQuery += "			SC6.C6_ZZVCUST,	"+ cEol
cQuery += "			SC6.C6_ZZVCOMV,	"+ cEol
cQuery += "			SC6.C6_ZZVCOMR,	"+ cEol
cQuery += "			SC6.C6_ZVCOMR3,	"+ cEol
cQuery += "			SC6.C6_ZVCOMR4,	"+ cEol
cQuery += "			SC6.C6_ZZPFRET,	"+ cEol
cQuery += "			SC6.C6_ZZVFRET,	"+ cEol
cQuery += "			SC6.C6_ZZPDPAD,	"+ cEol
cQuery += "			SC6.C6_ZZVDPAD,	"+ cEol
cQuery += "			SC6.C6_ZZPPDD,	"+ cEol
cQuery += "			SC6.C6_ZZVPDD,	"+ cEol
cQuery += "			SC6.C6_ZZPPONT,	"+ cEol
cQuery += "			SC6.C6_ZZVPONT,	"+ cEol
cQuery += "			SC6.C6_ZZPRENT,	"+ cEol
cQuery += "			SC6.C6_ZZVRENT,	"+ cEol
cQuery += "			SC6.C6_ZZPMBR,	"+ cEol
cQuery += "			SC6.C6_ZZVMBR,	"+ cEol
cQuery += "			SC6.C6_CCUSTO,	"+ cEol
cQuery += "			SC6.C6_TES,	    "+ cEol
cQuery += "			SC6.C6_ZZITCTB	"+ cEol
cQuery += " FROM " +RetSqlName("SF2") +" SF2 "+ cEol
cQuery += " 	INNER JOIN "+ RetSqlName("SD2") + " SD2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE " + cEol
cQuery += " 	INNER JOIN "+ RetSqlName("SC5") + " SC5 ON SD2.D2_FILIAL = SC5.C5_FILIAL AND SD2.D2_PEDIDO = SC5.C5_NUM " + cEol
cQuery += " 	INNER JOIN "+ RetSqlName("SC6") + " SC6 ON SD2.D2_FILIAL = SC6.C6_FILIAL AND SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_ITEMPV = SC6.C6_ITEM " + cEol
cQuery += " WHERE F2_FILIAL = '"+ xFilial("SF2") +"' AND SF2.F2_DOC = '"+ cDocNum + "' AND SF2.F2_SERIE = '"+ cDocSerie +"'"+ cEol
cQuery += " AND SF2.D_E_L_E_T_ <> '*' " + cEol
cQuery += " AND SD2.D_E_L_E_T_ <> '*' " + cEol
cQuery += " AND SC5.D_E_L_E_T_ <> '*' " + cEol
cQuery += " AND SC6.D_E_L_E_T_ <> '*' " + cEol

TCQUERY cQuery NEW ALIAS &cAlias
Return cAlias
