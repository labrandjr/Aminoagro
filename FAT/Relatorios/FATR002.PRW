#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR002  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 30/12/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Faturamento Aminoagro.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR002()

Local cPerg := "FATR02"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR02()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR02   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 30/12/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR02()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local zCfAdmv  := FormatIn( AllTrim(GetMv("MV_XCFADMV")), ",")
Local zUsAdmv  := "000000,"+AllTrim(GetMv("MV_ZUSADMV"))
Local lUsAdmv  := ( __cUserId $(zUsAdmv) )
Local nForFilial

aFilsCalc := MatFilCalc( mv_par11 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL IN("+zFiliais+") "
cQuery += " AND D2_FILIAL = F2_FILIAL "
cQuery += " AND D2_DOC = F2_DOC "
cQuery += " AND D2_SERIE = F2_SERIE "
cQuery += " AND D2_CLIENTE = F2_CLIENTE "
cQuery += " AND D2_LOJA = F2_LOJA "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+Substr(mv_par03,1,8)+"' "
Endif
If !Empty(mv_par04)
	cQuery += " AND ((A1_ZZAGCRD = '"+mv_par04+"') OR (A1_COD = '"+mv_par04+"')) "
Endif
If !Empty(mv_par05)
	cQuery += " AND F2_ZZREGVE = '"+mv_par05+"' "
Endif
If !Empty(mv_par06)
	cQuery += " AND D2_COD = '"+mv_par06+"' "
Endif
If !Empty(mv_par07)
	zUnNeg := AllTrim(mv_par07)
	cQuery += " AND D2_ITEMCC IN"+FormatIn(zUnNeg,",")
Endif
If mv_par08 == 1 // Gera duplicata = Sim
	cQuery += " AND F4_DUPLIC = 'S' "
ElseIf mv_par08 == 2 // Gera duplicata = Não
	cQuery += " AND F4_DUPLIC = 'N' "
Endif	
If mv_par09 == 2 // Serviços = Não
	cQuery += " AND B1_TIPO <> 'SV' "
ElseIf mv_par09 == 3 // Serviços = Somente
	cQuery += " AND B1_TIPO = 'SV' "
Endif
If mv_par10 == 1 // CFOP Adm.Vendas
	cQuery += " AND D2_CF IN"+zCfAdmv
Endif
If !Empty(mv_par13)
	cQuery += " AND F2_VEND1 = '"+mv_par13+"' "
Endif
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
nTotSql := SQL2->SOMA
SQL2->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT D2_ITEMCC ITEMCC, D2_FILIAL FILIAL, D2_DOC DOC, D2_SERIE SERIE, D2_COD COD, B1_DESC DESCRI, B1_ZZMARCA ZZMARCA, B1_ZZCATEG ZZCATEG, "
cQuery += " D2_QUANT QUANT, D2_PRCVEN PRCVEN, D2_TOTAL TOTAL, D2_VALICM VALICM, D2_CF CFOP, D2_PEDIDO PEDIDO, D2_ITEMPV ITEMPV, D2_LOTECTL LOTECTL, "
cQuery += " D2_CLIENTE CLIENTE, D2_LOJA LOJA, A1_NOME NOMCLI, A1_TIPO TIPCLI, A1_ZZGECON ZZGECON, D2_EMISSAO EMISSAO, A1_MUN MUN, A1_EST EST, "
cQuery += " F2_VEND1 VEND1, F2_ZZREGVE ZZREGVE, D2_CCUSTO CCUSTO, D2_SEGURO SEGURO, D2_VALFRE VALFRE "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL IN("+zFiliais+") "
cQuery += " AND D2_FILIAL = F2_FILIAL "
cQuery += " AND D2_DOC = F2_DOC "
cQuery += " AND D2_SERIE = F2_SERIE "
cQuery += " AND D2_CLIENTE = F2_CLIENTE "
cQuery += " AND D2_LOJA = F2_LOJA "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+Substr(mv_par03,1,8)+"' "
Endif
If !Empty(mv_par04)
	cQuery += " AND ((A1_ZZAGCRD = '"+mv_par04+"') OR (A1_COD = '"+mv_par04+"')) "
Endif
If !Empty(mv_par05)
	cQuery += " AND F2_ZZREGVE = '"+mv_par05+"' "
Endif
If !Empty(mv_par06)
	cQuery += " AND D2_COD = '"+mv_par06+"' "
Endif
If !Empty(mv_par07)
	zUnNeg := AllTrim(mv_par07)
	cQuery += " AND D2_ITEMCC IN"+FormatIn(zUnNeg,",")
Endif
If mv_par08 == 1 // Gera duplicada = Sim
	cQuery += " AND F4_DUPLIC = 'S' "
ElseIf mv_par08 == 2 // Gera duplicata = Não
	cQuery += " AND F4_DUPLIC = 'N' "
Endif	
If mv_par09 == 2 // Serviços = Não
	cQuery += " AND B1_TIPO <> 'SV' "
ElseIf mv_par09 == 3 // Serviços = Somente
	cQuery += " AND B1_TIPO = 'SV' "
Endif
If mv_par10 == 1 // CFOP Adm.Vendas
	cQuery += " AND D2_CF IN"+zCfAdmv
Endif
If !Empty(mv_par13)
	cQuery += " AND F2_VEND1 = '"+mv_par13+"' "
Endif
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY ITEMCC, FILIAL, DOC, SERIE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

DbSelectArea("SQL2")
ProcRegua(nTotSql)
SQL2->(DbGotop())
If !Eof()

	cNomePlan  := "SD2_FATR02"
	cNomeTable := "Faturamento x BU - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
	If mv_par12 == 1 .And. lUsAdmv // Uso Interno (Adm Vendas) Layout completo
		cNomeTable += " - Layout Adm Vendas"
	Else
		cNomeTable += " - Layout reduzido"
	Endif	

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	If mv_par12 == 1 .And. lUsAdmv // Uso Interno (Adm Vendas) Layout completo

		oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Neg.",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"CFOP",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"1o.Vencto.",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"No.Parcelas",3,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Projeto",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Gp.Econômico",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Estado",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Região",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Região",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"C.Custo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Faixa1",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Faixa2",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Marca",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Categoria",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde.",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prc.Unit.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Total",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Lote",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Icms",3,3)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Marg.Bruta",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Rentab.",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Pontualid.",3,2)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Unit.",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Frete",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Seguro",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Ebitda Real/Total",3,3)

		oExcel:AddColumn(cNomePlan,cNomeTable,"1o.Vencto.Real",1,4)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial Orig.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido Orig.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Família",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Vend2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"C.Custo",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Bonif.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Id My Way",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cultura",1,1)

	Else // Layout reduzido

		oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Neg.",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"CFOP",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"1o.Vencto.",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"No.Parcelas",3,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Projeto",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Gp.Econômico",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Estado",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Região",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Região",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Marca",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Categoria",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde.",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prc.Unit.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Total",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Lote",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Icms",3,3)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Frete",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Seguro",3,3)

		oExcel:AddColumn(cNomePlan,cNomeTable,"1o.Vencto.Real",1,4)	

		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial Orig.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido Orig.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Família",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Vend2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"C.Custo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Bonif.",1,1) 

		oExcel:AddColumn(cNomePlan,cNomeTable,"Id My Way",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cultura",1,1)

	Endif		

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( SQL2->(FILIAL+PEDIDO) )

		zCultu := RetField("SX5",1,xFilial("SX5")+"ZB"+PadR(SC5->C5_ZZCULT,6),"X5_DESCRI")
		zTpBon := ""
		If SC5->C5_ZZTPBON == "BC"
			zTpBon := "Comercial"
		ElseIf SC5->C5_ZZTPBON == "BS"
			zTpBon := "Simulador"
		ElseIf SC5->C5_ZZTPBON == "EX"
			zTpBon := "Experimento"
		ElseIf SC5->C5_ZZTPBON == "BQ"
			zTpBon := "Qualidade"
		ElseIf SC5->C5_ZZTPBON == "BP"
			zTpBon := "Pesquisa"
		ElseIf SC5->C5_ZZTPBON == "BM"
			zTpBon := "Marketing"
		ElseIf SC5->C5_ZZTPBON == "OT"
			zTpBon := "Outros"
		Endif

		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek( SQL2->(FILIAL+PEDIDO+ITEMPV) )

		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek( SQL2->(FILIAL+DOC+SERIE+CLIENTE+LOJA) )

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SF2->(F2_CLIENTE+F2_LOJA) )
		zIdCrm := AllTrim(STR(SA1->A1_ZZIDCRM))

		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + SF2->F2_VEND1 )
		zVend1 := SA3->A3_COD
		zNomV1 := SA3->A3_NOME
		zCCust := SA3->A3_ZZCC

		zVend2 := ""
		zNomV2 := ""
		zTipV2 := ""
		If !Empty(SF2->F2_VEND2)
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + SF2->F2_VEND2 )
			zVend2 := SA3->A3_COD
			zNomV2 := SA3->A3_NOME
			zTipV2 := IIf(SA3->A3_TIPVEND=="1","Cooperativa",IIf(SA3->A3_TIPVEND=="2","Funcionário",IIf(SA3->A3_TIPVEND=="3","Corretora","")))
		Endif	

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SQL2->COD )

		zLocal  := FWFilialName(cEmpAnt,SQL2->FILIAL,1)
		zEmissa := StoD(SQL2->EMISSAO)
		zTipCli := IIf(SQL2->TIPCLI=="F","Cons.Final",IIf(SQL2->TIPCLI=="L","Produtor Rural",IIf(SQL2->TIPCLI=="R","Revendedor",IIf(SQL2->TIPCLI=="S","Solidario",IIf(SQL2->TIPCLI=="X","Exportação","")))))
		zDesReg := RetField("SX5",1,xFilial("SX5")+"A2"+PadR(SQL2->ZZREGVE,6),"X5_DESCRI")
		zzMarca := RetField("SX5",1,xFilial("SX5")+"Z1"+PadR(SQL2->ZZMARCA,6),"X5_DESCRI")
		zzCateg := RetField("SX5",1,xFilial("SX5")+"Z2"+PadR(SQL2->ZZCATEG,6),"X5_DESCRI")
		
		zPrjAmi := "Não"
		If SC5->C5_XPRJAMI == "S"
			zPrjAmi := "Sementes de Verdade"
		ElseIf SC5->C5_XPRJAMI == "C"
			zPrjAmi := "Cond.Solo"
		ElseIf SC5->C5_XPRJAMI == "1"
			zPrjAmi := "CAM.F.30D 3%"
		ElseIf SC5->C5_XPRJAMI == "2"
			zPrjAmi := "CAM.F.30D 3,5%"
		ElseIf SC5->C5_XPRJAMI == "3"
			zPrjAmi := "CAM.F.60D 3%"
		ElseIf SC5->C5_XPRJAMI == "4"
			zPrjAmi := "CAM.F.90D 2,5%"
		ElseIf SC5->C5_XPRJAMI == "5"
			zPrjAmi := "CAM.F.30,60,90D 3%"
		Endif

		zFaixa1 := RetField("SZ2",1,xFilial("SZ2")+SC5->C5_ZZCDFXV,"Z2_COMIS")
		zFaixa2 := RetField("SZ3",1,xFilial("SZ3")+SC5->C5_ZZCDFXR,"Z3_COMIS")
		zFamili := Posicione("SZO",1,xFilial("SZO")+SB1->B1_ZFAMILI,"ZO_DESCRI")

		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( SQL2->(FILIAL+SERIE+DOC) )
		z1oVenc := SE1->E1_VENCTO
		z1oVenR := SE1->E1_VENCREA
		zNoParc := U_SE1PARC(SQL2->FILIAL, SQL2->SERIE, SQL2->DOC, SQL2->CLIENTE, SQL2->LOJA)

		If mv_par12 == 1 .And. lUsAdmv // Uso Interno (Adm Vendas) Layout completo

			oExcel:AddRow(cNomePlan, cNomeTable, {SQL2->ITEMCC, SQL2->FILIAL, zLocal, SQL2->DOC, zEmissa, SQL2->CFOP, z1oVenc, zNoParc, SQL2->PEDIDO, zPrjAmi,;
			   									  SQL2->CLIENTE, SQL2->NOMCLI, SQL2->ZZGECON, zTipCli, SQL2->MUN, SQL2->EST, SQL2->ZZREGVE, zDesReg, zVend1, zNomV1, SQL2->CCUSTO, zFaixa1,;
			   									  zVend2, zNomV2, zFaixa2, zzMarca, zzCateg, SQL2->COD, SQL2->DESCRI, SQL2->QUANT, SQL2->PRCVEN, SQL2->(TOTAL+VALFRE+SEGURO),;
			   									  SQL2->LOTECTL, SQL2->VALICM, SC6->C6_ZZPMBR, SC6->C6_ZZPRENT, SC6->C6_ZZPPONT,;
			   									  SC6->(C6_ZZVCUST/C6_QTDVEN), SQL2->VALFRE, SQL2->SEGURO, SC5->C5_ZEBTDIG, z1oVenR,;
			   									  SC5->C5_FILORIG, SC5->C5_PEDORIG, zFamili, zTipV2, zCCust, zTpBon, zIdCrm, zCultu })

		Else // Layout reduzido

			oExcel:AddRow(cNomePlan, cNomeTable, {SQL2->ITEMCC, SQL2->FILIAL, zLocal, SQL2->DOC, zEmissa, SQL2->CFOP, z1oVenc, zNoParc, SQL2->PEDIDO, zPrjAmi,;
			   									  SQL2->CLIENTE, SQL2->NOMCLI, SQL2->ZZGECON, zTipCli, SQL2->MUN, SQL2->EST, SQL2->ZZREGVE, zDesReg, zVend1, zNomV1,;
			   									  zVend2, zNomV2, zzMarca, zzCateg, SQL2->COD, SQL2->DESCRI, SQL2->QUANT, SQL2->PRCVEN, SQL2->(TOTAL+VALFRE+SEGURO),;
			   									  SQL2->LOTECTL, SQL2->VALICM, SQL2->VALFRE, SQL2->SEGURO, z1oVenR, SC5->C5_FILORIG, SC5->C5_PEDORIG, zFamili,;
												  zTipV2, zCCust, zTpBon, zIdCrm, zCultu })

		Endif			   									  

		DbSelectArea("SQL2")
		SQL2->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD2_FATR02-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL2->(DbCloseArea())
	
Return
