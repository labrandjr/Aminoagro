#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função PutDesc

Função que grava o percetual do campo personalizado "Desc.Pontualidade", da tabela SC5, e grava nos títulos gerados na SE1.

@author 	Augusto Krejci Bem-Haja
@since 		15/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------

User Function PutDesc()
	Local aArea		:= GetArea()
	Local cFil		:= xFilial("SF2")
	Local cDocNum	:= SF2->F2_DOC
	Local cDocSerie	:= SF2->F2_SERIE
	Local cDocPref	:= SF2->F2_PREFIXO
	Local nDesc		:= 0
	Local cGeren1   := ""
	Local cSuper1   := ""
	Local cGeren2   := ""
	Local cSuper2   := ""
	Local cDesMer   := ""
	Local cDocTipo	:= "NF "
	Private cAlias	:= ""
	
	LerDesc(cFil,cDocNum,cDocSerie,@nDesc,@cGeren1,@cSuper1,@cGeren2,@cSuper2,@cDesMer)

	GrvFin(cFil,cDocPref,cDocNum,cDocTipo,nDesc,cGeren1,cSuper1,cGeren2,cSuper2,cDesMer)

	RestArea(aArea)
Return

Static Function LerDesc(cFil,cDocNum,cDocSerie,nDesc,cGeren1,cSuper1,cGeren2,cSuper2,cDesMer)
	cAlias := QryRgs(cFil,cDocNum,cDocSerie)
	(cAlias)->(dbGoTop())
	If !((cAlias)->(Eof()))
		nDesc   := Val((cAlias)->C5_ZZPPONT)
		cGeren1 := (cAlias)->C5_GEREN1
		cSuper1 := (cAlias)->C5_SUPER1
		cGeren2 := (cAlias)->C5_GEREN2
		cSuper2 := (cAlias)->C5_SUPER2
		cDesMer := (cAlias)->C5_ZZDM
	Endif
	(cAlias)->(DbCloseArea())
Return

Static Function QryRgs(cFil,cDocNum,cDocSerie)
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cEol   := chr(10) + chr(13)
	
	cQuery := " SELECT 	SF2.F2_DOC, "+ cEol
	cQuery += " 		SF2.F2_PREFIXO, "+ cEol
	cQuery += " 		SF2.F2_SERIE, "+ cEol
	cQuery += " 		SD2.D2_PEDIDO, "+ cEol
	cQuery += " 		SC5.C5_ZZPPONT,  "+ cEol
	cQuery += " 		SC5.C5_GEREN1,   "+ cEol
	cQuery += " 		SC5.C5_SUPER1,   "+ cEol
	cQuery += "		    SC5.C5_ZZDM,     "+ cEol	
	cQuery += " 		SC5.C5_GEREN2,   "+ cEol
	cQuery += " 		SC5.C5_SUPER2    "+ cEol
	cQuery += " FROM " +RetSqlName("SF2") +" SF2 "+ cEol
	cQuery += " 	INNER JOIN "+ RetSqlName("SD2") + " SD2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE " + cEol	
	cQuery += " 	INNER JOIN "+ RetSqlName("SC5") + " SC5 ON SD2.D2_FILIAL = SC5.C5_FILIAL AND SD2.D2_PEDIDO = SC5.C5_NUM " + cEol
	cQuery += " WHERE SF2.F2_FILIAL = '"+ cFil + "'" + cEol
	cQuery += " AND SF2.F2_DOC = '"+ cDocNum + "'" + cEol
	cQuery += " AND SF2.F2_SERIE = '"+ cDocSerie + "'" + cEol
	cQuery += " AND SF2.D_E_L_E_T_ <> '*' " + cEol
	cQuery += " AND SD2.D_E_L_E_T_ <> '*' " + cEol
	cQuery += " AND SC5.D_E_L_E_T_ <> '*' " + cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return cAlias

Static Function GrvFin(cFil,cDocPref,cDocNum,cDocTipo,nDesc,cGeren1,cSuper1,cGeren2,cSuper2,cDesMer)
	Local aAreaSE1	:= SE1->(GetArea()) 
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	
	If SE1->(DbSeek(cFil+cDocPref+cDocNum))
		While (SE1->E1_FILIAL == cFil ) .and. (SE1->E1_PREFIXO == cDocPref) .and. (SE1->E1_NUM == cDocNum) .and. (SE1->E1_TIPO == cDocTipo)
			RecLock("SE1",.F.)
			SE1->E1_DESCFIN := nDesc
			SE1->E1_GEREN1  := cGeren1
			SE1->E1_SUPER1  := cSuper1
			SE1->E1_GEREN2  := cGeren2
			SE1->E1_SUPER2  := cSuper2
			SE1->E1_ZZCNAB  := Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_ZZCNAB")
			SE1->E1_XTPDESC := IIf(nDesc > 0,"1","")
			SE1->E1_ZZDM := cDesMer
			SE1->(MsUnLock())
			SE1->(DbSkip())
		Enddo
	Endif
	
	RestArea(aAreaSE1)
Return
