#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F010CQFT  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 25/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteracao da cQuery na consulta de Faturamento.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F010CQFT()
 
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

	zQuery := "SELECT SF2.F2_FILIAL,SF2.F2_DOC F2_DOC,"
	zQuery += 		"  SF2.F2_SERIE F2_SERIE,"
	zQuery += 		"  SF2.F2_EMISSAO F2_EMISSAO,"
	zQuery +=		"  SF2.F2_DUPL F2_DUPL,"
	zQuery +=		"  SF2.F2_NFELETR F2_NFELETR,"	
	zQuery += 		"  SF2.F2_VALFAT F2_VALFAT, "
	zQuery += 		"  SF2.F2_FRETE F2_FRETE, "
	zQuery += 		"  SF2.F2_HORA F2_HORA, "
	zQuery += 		"  SF2.F2_TRANSP F2_TRANSP, "
	zQuery += 		"  SF2.R_E_C_N_O_ SF2RECNO "

	zQuery += "FROM "+RetSqlName("SF2")+" SF2, "
	zQuery +=         RetSqlName("SA1")+" SA1  "

	nPosAlias := FC010QFil(1,"SF2")
	zQuery += " WHERE SF2.F2_FILIAL " + aTmpFil[nPosAlias,2] + " AND "

	zQuery += "SF2.F2_CLIENTE = SA1.A1_COD AND "
	zQuery += "SF2.F2_LOJA = SA1.A1_LOJA AND "
	zQuery += "SA1.D_E_L_E_T_<> '*' AND "

	If lAgrpCrd
		zQuery += "((SA1.A1_COD = '"+cAgrupCr+"') OR (SA1.A1_ZZAGCRD = '"+cAgrupCr+"')) AND "
	ElseIf lAgrpCgc
		zQuery += "SUBSTR(SA1.A1_CGC,1,8) = '"+cCgcCli+"' AND "
	Else
		zQuery += "SA1.A1_COD = '"+SA1->A1_COD+"' AND SA1.A1_LOJA = '"+SA1->A1_LOJA+"' AND "
	Endif	
	//cQuery += " SF2.F2_CLIENTE='"+SA1->A1_COD+"' AND "

	zQuery += " SF2.F2_TIPO NOT IN('D','B') AND "
	zQuery += " SF2.F2_EMISSAO>='"+DTOS(mv_par01)+"' AND "
	zQuery += " SF2.F2_EMISSAO<='"+DTOS(mv_par02)+"' AND "

	If mv_par14 == 3 // TES Duplic = N
		zQuery += " SF2.F2_VALFAT = 0 AND "					
	ElseIf mv_par14 == 2  // TES Duplic = S
		zQuery += " SF2.F2_VALFAT > 0 AND "					
	Endif												
											
	zQuery += " SF2.D_E_L_E_T_ = ' '"

Endif

RestArea(aArea)

Return(zQuery)
