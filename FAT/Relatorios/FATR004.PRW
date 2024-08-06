#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR004  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 09/05/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pedidos Liberados.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR004()

Local cPerg := "FATR04"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR04()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR04   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 09/05/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR04()

Local oExcel    := FwMsExcel():New()
Local zFiliais  := ""
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
cQuery += " FROM "+RetSqlName("SC9")+" SC9, "
cQuery += RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE C9_FILIAL IN("+zFiliais+") "
cQuery += " AND C9_FILIAL = C6_FILIAL "
cQuery += " AND C9_PEDIDO = C6_NUM "
cQuery += " AND C9_ITEM = C6_ITEM "
cQuery += " AND C6_FILIAL = C5_FILIAL "
cQuery += " AND C6_NUM = C5_NUM "
cQuery += " AND C6_FILIAL = F4_FILIAL "
cQuery += " AND C6_TES = F4_CODIGO "
cQuery += " AND C5_CLIENTE = A1_COD "
cQuery += " AND C5_LOJACLI = A1_LOJA "
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ = ' ' "
cQuery += " AND C9_BLCRED <> '10' "
cQuery += " AND C9_BLEST <> '10' "
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
If !Empty(mv_par08)
	cQuery += " AND C5_ZZITCTB = '"+mv_par08+"' "
Endif
If !Empty(mv_par09)
	cQuery += " AND C5_ZZREGVE = '"+mv_par09+"' "
Endif
cQuery += " AND C9_PEDIDO BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT C9_FILIAL FILIAL, C9_PEDIDO PEDIDO, C9_ITEM ITEM, C9_PRODUTO PRODUTO, C9_LOCAL ARMAZEM, C9_BLCRED BLCRED, C9_BLEST BLEST, "
cQuery += " SUM(C9_QTDLIB) QTDLIB, SUM(C9_QTDLIB*C9_PRCVEN)AS VLRLIB "
cQuery += " FROM "+RetSqlName("SC9")+" SC9, "
cQuery += RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE C9_FILIAL IN("+zFiliais+") "
cQuery += " AND C9_FILIAL = C6_FILIAL "
cQuery += " AND C9_PEDIDO = C6_NUM "
cQuery += " AND C9_ITEM = C6_ITEM "
cQuery += " AND C6_FILIAL = C5_FILIAL "
cQuery += " AND C6_NUM = C5_NUM "
cQuery += " AND C6_FILIAL = F4_FILIAL "
cQuery += " AND C6_TES = F4_CODIGO "
cQuery += " AND C5_CLIENTE = A1_COD "
cQuery += " AND C5_LOJACLI = A1_LOJA "
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ = ' ' "
cQuery += " AND C9_BLCRED <> '10' "
cQuery += " AND C9_BLEST <> '10' "
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
If !Empty(mv_par08)
	cQuery += " AND C5_ZZITCTB = '"+mv_par08+"' "
Endif
If !Empty(mv_par09)
	cQuery += " AND C5_ZZREGVE = '"+mv_par09+"' "
Endif
cQuery += " AND C9_PEDIDO BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_LOCAL, C9_BLCRED, C9_BLEST "
cQuery += " ORDER BY C9_FILIAL, C9_PEDIDO, C9_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SC9_FATR04"
	cNomeTable := "Pedidos Liberados"
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
	
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Condição",1,1)
	
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Estado",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Região",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Neg.",1,1) 

	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Armazém",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Liberada",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Bloqueada",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Situação",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido Incorp.",3,2)
		
	While !Eof()

		IncProc("Gerando planilha...")

		cFilAnt := SQL->FILIAL
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PEDIDO) )

		zCondPag := SC5->C5_CONDPAG
		zData1   := SC5->C5_DATA1
		zData2   := SC5->C5_DATA2
		zData3   := SC5->C5_DATA3
		zData4   := SC5->C5_DATA4

		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PEDIDO+ITEM) )

		DbSelectArea("SZG")
		DbSetOrder(1)
		If DbSeek( SC5->C5_FILIAL + SC5->C5_NUM + Space(9) )
			zCondPag := SZG->ZG_CONDPAG
			zData1   := SZG->ZG_DATA1
			zData2   := SZG->ZG_DATA2
			zData3   := SZG->ZG_DATA3
			zData4   := SZG->ZG_DATA4
		Endif

		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek( xFilial("SE4") + zCondPag )

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( SC6->(C6_FILIAL+C6_TES) )

		zCodCli := SC5->C5_CLIENTE
		zLojCli := SC5->C5_LOJACLI
		//zCodCli := IIf( !Empty(SC5->C5_CLIENT),  SC5->C5_CLIENT,  SC5->C5_CLIENTE)
		//zLojCli := IIf( !Empty(SC5->C5_LOJAENT), SC5->C5_LOJAENT, SC5->C5_LOJACLI)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + zCodCli + zLojCli )

		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + SC5->C5_VEND1 )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SQL->PRODUTO )

		zTipo   := IIf(SF4->F4_DUPLIC=="S","VEN",IIf(!Empty(SC5->C5_ZZTPBON),"BON","OUT"))
		zQtdLib := IIf( Empty(SQL->BLCRED) .And. Empty(SQL->BLEST), SQL->QTDLIB, 0 )
		zQtdBlq := IIf( !Empty(SQL->BLCRED) .Or. !Empty(SQL->BLEST), SQL->QTDLIB, 0 )
		zDesReg := RetField("SX5",1,xFilial("SX5")+"A2"+PadR(SC5->C5_ZZREGVE,6),"X5_DESCRI")
		zSituac := "Liberado"
		If !Empty(SQL->BLCRED) .Or. !Empty(SQL->BLEST)
			zSituac := IIf( !Empty(SQL->BLCRED), "Blq.Crédito", "Blq.Estoque" )
		Endif	

		If SE4->E4_TIPO == "9"
			zCondPg := DtoC(zData1)
			If !Empty(zData2)
				zCondPg += ", "+DtoC(zData2)
			Endif
			If !Empty(zData3)
				zCondPg += ", "+DtoC(zData3)
			Endif
			If !Empty(zData4)
				zCondPg += ", "+DtoC(zData4)
			Endif
		Else
			zCondPg := AllTrim(SE4->E4_DESCRI)
		Endif
			
		oExcel:AddRow(cNomePlan, cNomeTable, {SC5->C5_FILIAL, SC5->C5_NUM, zTipo, zCondPg, SA1->A1_NOME, SA1->A1_MUN, SA1->A1_EST, SA3->A3_NOME,;
		   									  zDesReg, SC5->C5_ZZITCTB, SB1->B1_COD, SB1->B1_DESC, SQL->ARMAZEM, zQtdLib, zQtdBlq, SQL->VLRLIB,;
		   									  zSituac, SC5->C5_ZNUMINC })

		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SC9_FATR04-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
