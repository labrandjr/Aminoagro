#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F010CQTR  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 25/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteracao da cQuery na consulta de Titulos Recebidos.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F010CQTR()
 
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

	zQuery := " SELECT E1_FILORIG,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NFELETR,E1_MOEDA,E1_EMISSAO,E1_VENCTO,E1_VENCREA,E5_DATA,E5_DTDISPO,E1_VALOR,E1_VLCRUZ,E5_VLJUROS, "
	zQuery += " E5_VLMULTA,E5_VLCORRE,E5_VLDESCO,E5_VLACRES,E5_VLDECRE,E5_VALOR,E5_VLMOED2,E5_TXMOEDA,E1_NATUREZ,E1_NUMLIQ,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_HISTOR,E5_MOTBX, "
	zQuery += " E5_CNABOC,E5_TIPODOC,E1_VALJUR,E1_MULTA,E1_TXMOEDA,E1_ORIGEM,SE5.R_E_C_N_O_ SE5RECNO,SE5.E5_DOCUMEN E5_DOCUMEN, SE1.E1_CLIENTE E1_CLIENTE "

	zQuery += "FROM "+RetSqlName("SE1")+" SE1, "
	zQuery +=         RetSqlName("SE5")+" SE5, "
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
	EndIf					
	zQuery +=       "SE1.E1_PREFIXO>='"+mv_par06+"' AND "
	zQuery +=       "SE1.E1_PREFIXO<='"+mv_par07+"' AND "
    
	zQuery += "SE1.E1_ORIGEM <> 'FINA087A' AND "

	zQuery +=		"SE1.E1_TIPO NOT LIKE '__-' AND "
	zQuery +=		"SE1.E1_TIPO NOT IN ('RA ','PA ','"+MV_CRNEG+"','"+MV_CPNEG+"') AND "
	zQuery +=		"SE1.D_E_L_E_T_ = ' ' AND "

	nPosAlias := FC010QFil(1,"SE5")
	zQuery += "SE5.E5_FILIAL = SE1.E1_FILIAL AND "

	zQuery +=		"SE5.E5_NATUREZ=SE1.E1_NATUREZ AND "
	zQuery +=		"SE5.E5_PREFIXO=SE1.E1_PREFIXO AND "
	zQuery +=		"SE5.E5_NUMERO=SE1.E1_NUM AND "
	zQuery +=		"SE5.E5_PARCELA=SE1.E1_PARCELA AND "
	zQuery +=		"SE5.E5_TIPO=SE1.E1_TIPO AND "
	zQuery +=		"SE5.E5_CLIFOR=SE1.E1_CLIENTE AND "
	zQuery +=		"SE5.E5_LOJA=SE1.E1_LOJA AND "
	zQuery +=		"SE5.E5_RECPAG='R' AND "
	zQuery +=		"SE5.E5_SITUACA<>'C' AND "
	If mv_par08 == 2
		//Titulos baixados por geracao de fatura
		zQuery += " SE5.E5_MOTBX <> 'FAT' AND "
	Endif
	If mv_par09 == 2
		//Titulos baixados por liquidacao
		zQuery += " SE5.E5_MOTBX <> 'LIQ' AND "
	Endif
	zQuery +=		"SE5.D_E_L_E_T_ = ' ' AND NOT EXISTS ("
	zQuery += "SELECT A.E5_NUMERO "
	zQuery += "FROM "+RetSqlName("SE5")+" A "

	nPosAlias := FC010QFil(1,"SE5")
	zQuery += "WHERE A.E5_FILIAL " + aTmpFil[nPosAlias,2] + " AND "

	zQuery +=		"A.E5_NATUREZ=SE5.E5_NATUREZ AND "
	zQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
	zQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
	zQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
	zQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
	zQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
	zQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
	zQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
	zQuery +=		"A.E5_TIPODOC='ES' AND "
	zQuery +=		"A.E5_RECPAG<>'R' AND "
	zQuery +=		"A.D_E_L_E_T_= ' ')"

Endif

RestArea(aArea)

Return(zQuery)
