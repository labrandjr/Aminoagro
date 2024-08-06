#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 30/12/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pedidos em Carteira.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR001X()

Local cPerg := "FATR01"
Private cPath := "c:\report\"

ChkFile("DJI")
DbSelectArea("DJI")

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 30/12/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR01()

Local oExcel    := FwMsExcel():New()
Local zFiliais  := ""
Local zPedAnt   := ""
Local nItem     := 0
Local aImpostos := MaFisRelImp("MTR700",{"SC5","SC6"})
Local zUsAdmv   := "000000,"+AllTrim(GetMv("MV_ZUSADMV"))
Local lUsAdmv   := ( __cUserId $(zUsAdmv) )
Local nForFilial

aFilsCalc := MatFilCalc( mv_par05 == 1 )
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
cQuery += " FROM "+RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE C6_FILIAL IN("+zFiliais+") "
cQuery += " AND C6_FILIAL = C5_FILIAL "
cQuery += " AND C6_NUM = C5_NUM "
cQuery += " AND C5_CLIENTE = A1_COD "
cQuery += " AND C5_LOJACLI = A1_LOJA "
cQuery += " AND C6_TES = F4_CODIGO "
cQuery += " AND C6_FILIAL = F4_FILIAL "
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ <> 'R' "
cQuery += " AND (C6_QTDVEN-C6_QTDENT) > 0 "
If !Empty(mv_par01)
	cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+Substr(mv_par01,1,8)+"' "
Endif
If !Empty(mv_par02)
	cQuery += " AND ((A1_ZZAGCRD = '"+mv_par02+"') OR (A1_COD = '"+mv_par02+"')) "
Endif
If !Empty(mv_par03)
	cQuery += " AND C5_VEND1 = '"+mv_par03+"' "
Endif
If mv_par04 == 1 // Gera duplicada = sim
	cQuery += " AND F4_DUPLIC = 'S' "
ElseIf mv_par04 == 2 // Gera duplicata = não
	cQuery += " AND F4_DUPLIC = 'N' "
Endif	
If !Empty(mv_par06)
	cQuery += " AND C6_ZZITCTB = '"+mv_par06+"' "
Endif
If !Empty(mv_par08)
	cQuery += " AND C5_ZZREGVE = '"+mv_par08+"' "
Endif
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT C6_FILIAL FILIAL, C6_NUM PEDIDO, C6_ITEM ITEM, C6_PRODUTO PRODUTO, C6_TES TES, C6_CCUSTO CCUSTO, C6_QTDVEN QTDVEN, C6_QTDENT QTDENT, "
cQuery += " C6_QTDEMP QTDEMP, C6_PRCVEN PRCVEN, (C6_QTDVEN-C6_QTDENT)AS TOTPEN, C6_ENTREG ENTREG, C6_ZZPMBR ZZPMBR, C6_ZZPRENT ZZPRENT, C6_ZZPPONT ZZPPONT, C6_ZZVCUST ZZVCUST "
cQuery += " FROM "+RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE C6_FILIAL IN("+zFiliais+") "
cQuery += " AND C6_FILIAL = C5_FILIAL "
cQuery += " AND C6_NUM = C5_NUM "
cQuery += " AND C5_CLIENTE = A1_COD "
cQuery += " AND C5_LOJACLI = A1_LOJA "
cQuery += " AND C6_TES = F4_CODIGO "
cQuery += " AND C6_FILIAL = F4_FILIAL "
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ <> 'R' "
cQuery += " AND (C6_QTDVEN-C6_QTDENT) > 0 "
If !Empty(mv_par01)
	cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+Substr(mv_par01,1,8)+"' "
Endif
If !Empty(mv_par02)
	cQuery += " AND ((A1_ZZAGCRD = '"+mv_par02+"') OR (A1_COD = '"+mv_par02+"')) "
Endif
If !Empty(mv_par03)
	cQuery += " AND C5_VEND1 = '"+mv_par03+"' "
Endif
If mv_par04 == 1 // Gera duplicada = sim
	cQuery += " AND F4_DUPLIC = 'S' "
ElseIf mv_par04 == 2 // Gera duplicata = não
	cQuery += " AND F4_DUPLIC = 'N' "
Endif	
If !Empty(mv_par06)
	cQuery += " AND C6_ZZITCTB = '"+mv_par06+"' "
Endif
If !Empty(mv_par08)
	cQuery += " AND C5_ZZREGVE = '"+mv_par08+"' "
Endif
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, PEDIDO, ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SC6_FATR01"
	cNomeTable := "Pedidos em Carteira"
	If !Empty(mv_par01)
		cNomeTable += " - Base Cgc: "+Substr(mv_par01,1,8)
	Endif
	If !Empty(mv_par02)	
		cNomeTable += " - Grupo Créd.: "+mv_par02
	Endif
	If !Empty(mv_par03)
		cNomeTable += " - Vendedor1: "+mv_par03
	Endif
	cNomeTable += " - Gera Duplicata: "+IIf(mv_par04==1,"Sim",IIf(mv_par04==2,"Não","Todos"))
	If mv_par07 == 1 .And. lUsAdmv // Uso Interno (Adm Vendas) Layout completo
		cNomeTable += " - Layout Adm Vendas"
	Else
		cNomeTable += " - Layout reduzido"
	Endif	

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	If mv_par07 == 1 .And. lUsAdmv // Uso Interno (Adm Vendas) Layout completo

		oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Neg.",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Projeto",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Gp.Econômico",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"UF",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Região",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Região",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"C.C.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Faixa1",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Comiss1",3,3)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Faixa2",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Comiss2",3,3)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Pendente",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prc.Unitário",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cond.Pagto.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Icms",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Marg.Bruta",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Rentab.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Pontualid.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Unit.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Ebitda Real/Total",3,3)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor3",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome3",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Faixa3",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Comiss3",3,3)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor4",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome4",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Faixa4",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Comiss4",3,3)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Entrega",1,4)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Gerente",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Ger.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Marca",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Categoria",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Bonif.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Id My Way",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cultura",1,1)

	Else // Layout reduzido

		oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Neg.",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Projeto",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Gp.Econômico",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tp.Cliente",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"UF",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Região",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Região",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome1",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor2",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome2",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Pendente",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prc.Unitário",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cond.Pagto.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor3",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome3",1,1)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor4",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome4",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Entrega",1,4)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Gerente",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Ger.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Marca",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Categoria",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"C.Custo V1",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Bonif.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Id My Way",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cultura",1,1)

	Endif

	While !Eof()

		IncProc("Gerando planilha...")

		cFilAnt := SQL->FILIAL
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PEDIDO) )

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

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )

		zIdCrm := AllTrim(STR(SA1->A1_ZZIDCRM))
		zTpCli := ""
		If SA1->A1_TIPO == "F"
			zTpCli := "Cons.Final"
		ElseIf SA1->A1_TIPO == "L"
			zTpCli := "Produtor Rural"
		ElseIf SA1->A1_TIPO == "R"
			zTpCli := "Revendedor"
		ElseIf SA1->A1_TIPO == "S"
			zTpCli := "Solidario"
		ElseIf SA1->A1_TIPO == "X"
			zTpCli := "Exportação"
		Endif	

		zCondPag := SC5->C5_CONDPAG
		lCondSzg := .F.
		DbSelectArea("SZG")
		DbSetOrder(1)
		If DbSeek( SC5->C5_FILIAL + SC5->C5_NUM + Space(9) )
			zCondPag := SZG->ZG_CONDPAG
			lCondSzg := .T.
		Endif

		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + SC5->C5_VEND1 )
		zVend1 := SA3->A3_COD
		zNomV1 := SA3->A3_NOME
		zCCust := SA3->A3_ZZCC

		zVend2 := ""
		zNomV2 := ""
		If !Empty(SC5->C5_VEND2)
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + SC5->C5_VEND2 )
			zVend2 := SA3->A3_COD
			zNomV2 := SA3->A3_NOME
		Endif	

		zVend3 := ""
		zNomV3 := ""
		If !Empty(SC5->C5_VEND3)
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + SC5->C5_VEND3 )
			zVend3 := SA3->A3_COD
			zNomV3 := SA3->A3_NOME
		Endif	

		zVend4 := ""
		zNomV4 := ""
		If !Empty(SC5->C5_VEND4)
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + SC5->C5_VEND4 )
			zVend4 := SA3->A3_COD
			zNomV4 := SA3->A3_NOME
		Endif	

		zGeren := ""
		zNomGr := ""
		If !Empty(SC5->C5_GEREN1)
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + SC5->C5_GEREN1 )
			zGeren := SA3->A3_COD
			zNomGr := SA3->A3_NOME
		Endif	

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+TES) )

		zCondPv := ""
		If SF4->F4_DUPLIC == "S"
			DbSelectArea("SE4")
			DbSetOrder(1)
			DbSeek( xFilial("SE4") + zCondPag )
	    	If SE4->E4_TIPO == "9"
	    		If lCondSzg
		    		zCondPv += IIf( !Empty(SZG->ZG_DATA1), DtoC(SZG->ZG_DATA1), "" )
		    		zCondPv += IIf( !Empty(SZG->ZG_DATA2), " | "+DtoC(SZG->ZG_DATA2), "" )
		    		zCondPv += IIf( !Empty(SZG->ZG_DATA3), " | "+DtoC(SZG->ZG_DATA3), "" )
		    		zCondPv += IIf( !Empty(SZG->ZG_DATA4), " | "+DtoC(SZG->ZG_DATA4), "" )
		    	Else
		    		zCondPv += IIf( !Empty(SC5->C5_DATA1), DtoC(SC5->C5_DATA1), "" )
		    		zCondPv += IIf( !Empty(SC5->C5_DATA2), " | "+DtoC(SC5->C5_DATA2), "" )
		    		zCondPv += IIf( !Empty(SC5->C5_DATA3), " | "+DtoC(SC5->C5_DATA3), "" )
		    		zCondPv += IIf( !Empty(SC5->C5_DATA4), " | "+DtoC(SC5->C5_DATA4), "" )
		    	Endif	
	    	Else
	    		zCondPv := AllTrim(SE4->E4_DESCRI)
	    	Endif
	    Endif	

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SQL->PRODUTO )

		zzMarca := RetField("SX5",1,xFilial("SX5")+"Z1"+PadR(SB1->B1_ZZMARCA,6),"X5_DESCRI")
		zzCateg := RetField("SX5",1,xFilial("SX5")+"Z2"+PadR(SB1->B1_ZZCATEG,6),"X5_DESCRI")

		If zPedAnt != SQL->(FILIAL+PEDIDO)
			zPedAnt := SQL->(FILIAL+PEDIDO)
			MaFisIni(SC5->C5_CLIENTE, SC5->C5_LOJACLI, "C", SC5->C5_TIPO, SC5->C5_TIPOCLI, aImpostos,,,"SB1","MTR700")
		Endif	

		zLocal  := FWFilialName(cEmpAnt,SC5->C5_FILIAL,1)
		zTipo   := IIf(SF4->F4_DUPLIC=="S","VEN",IIf(!Empty(SC5->C5_ZZTPBON),"BON","OUT"))
		zDesReg := RetField("SX5",1,xFilial("SX5")+"A2"+PadR(SC5->C5_ZZREGVE,6),"X5_DESCRI")
		
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
		zFaixa3 := RetField("SZ2",1,xFilial("SZ2")+SC5->C5_ZCDFXR3,"Z2_COMIS")
		zFaixa4 := RetField("SZ3",1,xFilial("SZ3")+SC5->C5_ZCDFXR4,"Z3_COMIS")
		zEntreg := StoD(SQL->ENTREG)
		zQtdPen := SQL->TOTPEN
 		zQtdLib := 0
 		DbSelectArea("SC9")
 		DbSetOrder(1)
 		If DbSeek( SQL->(FILIAL+PEDIDO+ITEM) )
 			While !Eof() .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == SQL->(FILIAL+PEDIDO+ITEM)
 				If Empty(SC9->C9_BLCRED)
 					zQtdLib += SC9->C9_QTDLIB
 				Endif
 				SC9->(DbSkip())
 			Enddo
 		Endif
		zTotPen := zQtdPen - zQtdLib
		zVlrPen := zTotPen * SQL->PRCVEN
		zValDes := 0

		If zTotPen <= 0
			DbSelectArea("SQL")
			SQL->(DbSkip())
			Loop
		Endif

		MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, zTotPen, SQL->PRCVEN, zValDes,,,,0,0,0,0, zVlrPen, 0,0,0)
		nItem += 1

		zBasIcm := MaFisRet(nItem,"IT_BASEICM")
		zValIcm := MaFisRet(nItem,"IT_VALICM")

		zComis1 := (zVlrPen - zValIcm) * (zFaixa1/100)
		zComis2 := (zVlrPen - zValIcm) * (zFaixa2/100)
		zComis3 := (zVlrPen - zValIcm) * (zFaixa3/100)
		zComis4 := (zVlrPen - zValIcm) * (zFaixa4/100)

		If mv_par07 == 1 .And. lUsAdmv // Uso Interno (Adm Vendas) Layout completo		

			oExcel:AddRow(cNomePlan, cNomeTable, {SC5->C5_ZZITCTB, SC5->C5_FILIAL, zLocal, SC5->C5_NUM, zTipo, zPrjAmi, SC5->C5_EMISSAO, SA1->A1_COD, SA1->A1_NOME,;
			   									  SA1->A1_ZZGECON, SA1->A1_MUN, SA1->A1_EST, SC5->C5_ZZREGVE, zDesReg, zVend1, zNomV1, SQL->CCUSTO, zFaixa1, zComis1,;
			   									  zVend2, zNomV2, zFaixa2, zComis2, SB1->B1_COD, SB1->B1_DESC, zTotPen, SQL->PRCVEN, zVlrPen, zCondPv,;
			   									  zValIcm, SQL->ZZPMBR, SQL->ZZPRENT, SQL->ZZPPONT, SQL->(ZZVCUST/QTDVEN), SC5->C5_ZEBTDIG,;
												  zVend3, zNomV3, zFaixa3, zComis3, zVend4, zNomV4, zFaixa4, zComis4,;
												  zEntreg, zGeren, zNomGr, zzMarca, zzCateg, zTpBon, zIdCrm, zCultu })


		Else // Layout reduzido

			oExcel:AddRow(cNomePlan, cNomeTable, {SC5->C5_ZZITCTB, SC5->C5_FILIAL, zLocal, SC5->C5_NUM, zTipo, zPrjAmi, SC5->C5_EMISSAO, SA1->A1_COD, SA1->A1_NOME,;
			   									  SA1->A1_ZZGECON, zTpCli, SA1->A1_MUN, SA1->A1_EST, SC5->C5_ZZREGVE, zDesReg, zVend1, zNomV1,;
			   									  zVend2, zNomV2, SB1->B1_COD, SB1->B1_DESC, zTotPen, SQL->PRCVEN, zVlrPen, zCondPv,;
			   									  zVend3, zNomV3, zVend4, zNomV4, zEntreg, zGeren, zNomGr, zzMarca, zzCateg, zCCust, zTpBon, zIdCrm, zCultu })

		Endif
	
		DbSelectArea("SQL")
		SQL->(DbSkip())

		If zPedAnt != SQL->(FILIAL+PEDIDO)
			nItem := 0
			MaFisEnd()
		Endif	
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SC6_FATR01-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())
	
Return
