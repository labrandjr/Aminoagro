#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F010CQPE  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 25/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteracao da cQuery na consulta de Pedidos.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F010CQPE()
 
Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local zQuery   := PARAMIXB[1]
Local cAgrupCr := ""
Local cCgcCli  := Substr(SA1->A1_CGC,1,8) // Base do Cgc da Matriz
Local lAgrpCrd := .F.
Local lAgrpCgc := .F.
Local lAgrpLim := (GetMv("MV_AGRPLIM") == "S")

If mv_par13 == 2 .And. lAgrpLim // Considera Loja = Não | Agrupamento de Crédito = Habilitado

	If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
		lAgrpCrd := .T.
		cAgrupCr := SA1->A1_ZZAGCRD
	Else
		If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1")+SA1->A1_ZZAGCRD)
				lAgrpCrd := .T.
				cAgrupCr := SA1->A1_COD
			Endif
		Else // Agrupamento de Crédito: verifica se código do cliente está sendo usado para agrupamento
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SA1")
			cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
			cQuery += " AND A1_ZZAGCRD = '"+SA1->A1_COD+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL1",.T.,.T.)
			lAgrpCrd := (SQL1->SOMA > 0)
			SQL1->(DbCloseAreaAA())
			If lAgrpCrd
				cAgrupCr := SA1->A1_COD
			Endif	
		Endif
	Endif
	// Se não for agrupamento de crédito, verifica se existe agrupamento pela Base do Cnpj
	If !lAgrpCrd
		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbSeek(xFilial("SA1")+cCgcCli+"0001")
			lAgrpCgc := .T.
		Endif
	Endif

	RestArea(aAreaSA1)
	
	cCompSC5 := FWModeAccess("SC5",1) + FWModeAccess("SC5",2) + FWModeAccess("SC5",3)    
	lFilF4	 := .F.
	lFilF4C6 := .F.

	If FWModeAccess("SC6",3) == FWModeAccess("SF4",3) .And. FWModeAccess("SC6",2) ==  FWModeAccess("SF4",2) .And. FWModeAccess("SC6",1) ==  FWModeAccess("SF4",1)
		lFilF4C6 := .T.
	EndIf

	IF FWModeAccess("SF4",1) == "C"
		lFilF4 := .T.
	ElseIf FWModeAccess("SC6",3) == "E"
		lFilF4 := .T.
	ElseIf FWModeAccess("SC6",1) == "C" 
		lFilF4 := .F.
	ElseIf FWModeAccess("SF4",2) == "E" .AND. !(FWModeAccess("SF4",3) == "C" .AND. FWModeAccess("SC6",2) == "E")
		lFilF4 := .F.
	Else
		lFilF4 := .T.
	EndIf

	zQuery := " SELECT SC5.C5_FILIAL,SC5.C5_NUM PEDIDO,SC5.C5_EMISSAO EMISSAO,SC5.C5_MOEDA MOEDA,SC5.C5_FRETE FRETE,SC5.R_E_C_N_O_ SC5RECNO, "
	zQuery += " (C6_QTDVEN-C6_QTDEMP-C6_QTDENT) QTDVEN,C6_PRCVEN PRCVEN,1 TIPO,C5_EMISSAO DATALIB,C6_BLQ BLCRED "

	zQuery += "FROM "+RetSqlName("SC5")+" SC5, "
	zQuery +=         RetSqlName("SC6")+" SC6, "
	zQuery +=         RetSqlName("SF4")+" SF4, "
	zQuery +=         RetSqlName("SA1")+" SA1  "

	nPosAlias := FC010QFil(1,"SC5")
	zQuery += "WHERE SC5.C5_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	zQuery += "SC5.C5_CLIENTE = SA1.A1_COD AND "
	zQuery += "SC5.C5_LOJACLI = SA1.A1_LOJA AND "
	zQuery += "SA1.D_E_L_E_T_<> '*' AND "

	If lAgrpCrd
		zQuery += "((SA1.A1_COD = '"+cAgrupCr+"') OR (SA1.A1_ZZAGCRD = '"+cAgrupCr+"')) AND "
	ElseIf lAgrpCgc
		zQuery += "SUBSTR(SA1.A1_CGC,1,8) = '"+cCgcCli+"' AND "
	Else
		zQuery += "SA1.A1_COD = '"+SA1->A1_COD+"' AND SA1.A1_LOJA = '"+SA1->A1_LOJA+"' AND "
	Endif	
	//cQuery += "SC5.C5_CLIENTE='"+SA1->A1_COD+"' AND "

	zQuery +=		"SC5.C5_TIPO NOT IN('D','B') AND "
	zQuery +=		"SC5.C5_EMISSAO >='"+Dtos(mv_par01)+"' AND "
	zQuery +=		"SC5.C5_EMISSAO <='"+Dtos(mv_par02)+"' AND "	
	zQuery +=		"SC5.D_E_L_E_T_ = ' ' AND "

	If (FWModeAccess("SC6",1) + FWModeAccess("SC6",2) + FWModeAccess("SC6",3)) == cCompSC5
		zQuery += "SC6.C6_FILIAL = SC5.C5_FILIAL AND "
	Else
		nPosAlias := FC010QFil(1,"SC6")
		zQuery += "SC6.C6_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Endif

	zQuery +=		"SC6.C6_NUM=SC5.C5_NUM AND "
	zQuery +=		"SC6.C6_BLQ NOT IN('R ') AND "
	If mv_par10 == 2 // nao considera pedidos com bloqueio
		zQuery +=		"SC6.C6_BLQ NOT IN('S ') AND "
	Endif
	zQuery +=		"(SC6.C6_QTDVEN-SC6.C6_QTDEMP-SC6.C6_QTDENT)>0 AND "
	zQuery +=		"SC6.D_E_L_E_T_ = ' ' AND "

	If lFilF4C6
		zQuery +=		"SF4.F4_FILIAL=SC6.C6_FILIAL AND "
	Else
		If !lFilF4
			zQuery +=		"SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
		Else
			zQuery +=		"SF4.F4_FILIAL='"+xFilial("SF4",SC6->C6_FILIAL)+"' AND "
		EndIf
	EndIf

	zQuery += "SF4.F4_CODIGO=SC6.C6_TES AND "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera sim, não ou ambos os itens com TES gerando duplicata ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par14 == 2
		zQuery +=		"SF4.F4_DUPLIC='S' AND "
	ElseIf mv_par14 == 3                   
		zQuery +=		"SF4.F4_DUPLIC='N' AND "
	Endif
	zQuery +=		"SF4.D_E_L_E_T_ = ' ' "
	zQuery += "UNION ALL "
	zQuery += "SELECT C5_FILIAL,C5_NUM PEDIDO,"
	zQuery += 		  "C5_EMISSAO EMISSAO,"
	zQuery += 		  "C5_MOEDA MOEDA,"
	zQuery +=  		  "C5_FRETE FRETE,"
	zQuery += 		  "SC5.R_E_C_N_O_ SC5RECNO,"					
	zQuery += 		  "C9_QTDLIB QTDVEN,"
	zQuery +=		  "C9_PRCVEN PRCVEN, "
	zQuery +=         "2 TIPO,"										
	zQuery +=		  "C9_DATALIB DATALIB, "
	zQuery +=		  "C9_BLCRED BLCRED "

	zQuery += "FROM "+RetSqlName("SC5")+" SC5,"+RetSqlName("SC6")+" SC6, "
	zQuery +=         RetSqlName("SF4")+" SF4,"+RetSqlName("SC9")+" SC9, "
	zQuery +=         RetSqlName("SA1")+" SA1  "

	nPosAlias := FC010QFil(1,"SC5")
	zQuery += "WHERE SC5.C5_FILIAL " + aTmpFil[nPosAlias,2] + " AND "

	zQuery += "SC5.C5_CLIENTE = SA1.A1_COD AND "
	zQuery += "SC5.C5_LOJACLI = SA1.A1_LOJA AND "
	zQuery += "SA1.D_E_L_E_T_<> '*' AND "

	If lAgrpCrd
		zQuery += "((SA1.A1_COD = '"+cAgrupCr+"') OR (SA1.A1_ZZAGCRD = '"+cAgrupCr+"')) AND "
	ElseIf lAgrpCgc
		zQuery += "SUBSTR(SA1.A1_CGC,1,8) = '"+cCgcCli+"' AND "
	Else
		zQuery += "SA1.A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND "
	Endif	
	//cQuery += "SC5.C5_CLIENTE='"+SA1->A1_COD+"' AND "

	zQuery +=		"SC5.C5_TIPO NOT IN('D','B') AND "
	zQuery +=		"SC5.C5_EMISSAO >='"+Dtos(mv_par01)+"' AND "
	zQuery +=		"SC5.C5_EMISSAO <='"+Dtos(mv_par02)+"' AND "						
	zQuery +=		"SC5.D_E_L_E_T_ =  ' ' AND "

	If (FWModeAccess("SC6",1) + FWModeAccess("SC6",2) + FWModeAccess("SC6",3)) == cCompSC5
		zQuery += "SC6.C6_FILIAL = SC5.C5_FILIAL AND "
	Else
		nPosAlias := FC010QFil(1,"SC6")
		zQuery += "SC6.C6_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Endif

	zQuery +=		"SC6.C6_NUM=SC5.C5_NUM AND "
	zQuery +=		"SC6.D_E_L_E_T_ = ' ' AND "
	zQuery +=		"SC6.C6_BLQ NOT IN('R ') AND "
	If mv_par10 == 2 // nao considera pedidos com bloqueio
		zQuery +=		"SC6.C6_BLQ NOT IN('S ') AND "
	Endif

	nPosAlias := FC010QFil(1,"SF4")
	zQuery += "SF4.F4_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	zQuery += "SF4.F4_FILIAL=SC6.C6_FILIAL AND "
	zQuery += "SF4.F4_CODIGO=SC6.C6_TES AND "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera sim, não ou ambos os itens com TES gerando duplicata ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par14 == 2
		zQuery +=		"SF4.F4_DUPLIC='S' AND "
	ElseIf mv_par14 == 3                   
		zQuery +=		"SF4.F4_DUPLIC='N' AND "
	Endif
	zQuery +=		"SF4.D_E_L_E_T_ = ' ' AND "

	If (FWModeAccess("SC9",1) + FWModeAccess("SC9",2) + FWModeAccess("SC9",3)) == cCompSC5
		zQuery += "SC9.C9_FILIAL = SC5.C5_FILIAL AND "
	Else
		nPosAlias := FC010QFil(1,"SC9")
		zQuery += "SC9.C9_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Endif

	zQuery +=		"SC9.C9_PEDIDO=SC5.C5_NUM AND "
	zQuery +=		"SC9.C9_ITEM=SC6.C6_ITEM AND "
	zQuery +=		"SC9.C9_PRODUTO=SC6.C6_PRODUTO AND "		
	zQuery +=		"SC9.C9_NFISCAL='"+Space(Len(SC9->C9_NFISCAL))+"' AND "
	zQuery +=		"SC9.D_E_L_E_T_ = ' '"

Endif

RestArea(aArea)

Return(zQuery)
