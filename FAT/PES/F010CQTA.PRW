#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F010CQTA  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 25/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteracao da cQuery na consulta de Titulos em Aberto.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F010CQTA()
 
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
			SQL1->(DbCloseArea())
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

	zQuery := " SELECT E1_FILIAL,E1_LOJA,E1_FILORIG,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NFELETR,E1_CLIENTE,E1_EMISSAO,E1_VENCTO,E1_BAIXA,E1_VENCREA,E1_VALOR,E1_VLCRUZ,E1_SDACRES, "
	zQuery += " E1_SDDECRE,E1_VALJUR,E1_SALDO,E1_NATUREZ,E1_PORTADO,E1_NUMBCO,E1_NUMLIQ,E1_HIST,E1_CHQDEV,E1_SITUACA,E1_PORCJUR,E1_MOEDA,E1_VALOR,E1_TXMOEDA, "
	zQuery += " SE1.R_E_C_N_O_ SE1RECNO,FRV.FRV_DESCRI "

	zQuery += "FROM "+RetSqlName("SE1")+" SE1, "
	zQuery +=         RetSqlName("FRV")+" FRV, "
	zQuery +=         RetSqlName("SA1")+" SA1  "

	nPosAlias := FC010QFil(1,"SE1")
	zQuery += "WHERE SE1.E1_FILIAL " + aTmpFil[nPosAlias,2] + " AND "

	zQuery += "SE1.E1_CLIENTE = SA1.A1_COD AND "
	zQuery += "SE1.E1_LOJA = SA1.A1_LOJA AND "
	zQuery += "SA1.D_E_L_E_T_<> '*' AND "

	If lAgrpCrd
		zQuery += "((SA1.A1_COD = '"+cAgrupCr+"') OR (SA1.A1_ZZAGCRD = '"+cAgrupCr+"')) AND "
	ElseIf lAgrpCgc
		zQuery += "SUBSTR(SA1.A1_CGC,1,8) = '"+cCgcCli+"' AND "
	Else
		zQuery += "SA1.A1_COD = '"+SA1->A1_COD+"' AND SA1.A1_LOJA = '"+SA1->A1_LOJA+"' AND "
	Endif	
	//cQuery += "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "

	zQuery +=       "SE1.E1_EMISSAO>='"+Dtos(mv_par01)+"' AND "
	zQuery +=       "SE1.E1_EMISSAO<='"+Dtos(mv_par02)+"' AND "
	zQuery +=       "SE1.E1_VENCREA>='"+Dtos(mv_par03)+"' AND "
	zQuery +=       "SE1.E1_VENCREA<='"+Dtos(mv_par04)+"' AND "
	If ( mv_par05 == 2 )
		zQuery +=   "SE1.E1_TIPO<>'PR ' AND "
	EndIf					
	If ( mv_par15 == 2 )
		zQuery +=   "SE1.E1_TIPO<>'RA ' AND "	
	Endif
	zQuery += "SE1.E1_PREFIXO>='"+mv_par06+"' AND "
	zQuery += "SE1.E1_PREFIXO<='"+mv_par07+"' AND " 
	zQuery += "SE1.E1_SALDO > 0 AND "

	If mv_par11 == 2 // Se nao considera titulos gerados pela liquidacao
		If mv_par09 == 1 
			zQuery += "SE1.E1_NUMLIQ ='"+Space(Len(SE1->E1_NUMLIQ))+"' AND "
		Else  
		  zQuery += "SE1.E1_TIPOLIQ='"+Space(Len(SE1->E1_TIPOLIQ))+"' AND "						
		  zQuery += "SE1.E1_NUMLIQ ='"+Space(Len(SE1->E1_NUMLIQ))+"' AND "
		Endif	
	Else
		If mv_par09 == 2
			zQuery += "SE1.E1_TIPOLIQ='"+Space(Len(SE1->E1_TIPOLIQ))+"' AND "						
		Endif	
	Endif

	zQuery +=		"SE1.D_E_L_E_T_<> '*' AND "
	zQuery +=    	"FRV.FRV_FILIAL = '"+xFilial("FRV")+"' AND "
	zQuery +=		"FRV.FRV_CODIGO = SE1.E1_SITUACA AND "
	zQuery +=		"FRV.D_E_L_E_T_<> '*' "

	zQuery += "AND SE1.E1_TIPO NOT LIKE '__-' UNION ALL "+zQuery
	zQuery += "AND SE1.E1_TIPO LIKE '__-'"
	
	zQuery += " ORDER BY  " + SqlOrder("E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+SE1RECNO")

Endif

RestArea(aArea)

Return(zQuery)
