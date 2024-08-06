#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR003  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 02/04/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Sementes de Verdade.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR003()

Local cPerg := "FATR03"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR03()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR03   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 02/04/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR03()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local nForFilial

aFilsCalc := MatFilCalc( mv_par08 == 1 )
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
cQuery += " FROM "+RetSqlName("SCJ")+" SCJ, "
cQuery += RetSqlName("SCK")+" SCK, "
cQuery += RetSqlName("SUS")+" SUS, "
cQuery += RetSqlName("SA3")+" SA3, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("CTT")+" CTT, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE CJ_FILIAL IN("+zFiliais+") "
cQuery += " AND CJ_FILIAL = CK_FILIAL "
cQuery += " AND CJ_NUM = CK_NUM "
cQuery += " AND CJ_PROSPE = US_COD "
cQuery += " AND CJ_LOJPRO = US_LOJA "
cQuery += " AND CJ_CLIENTE = A1_COD "
cQuery += " AND CJ_LOJA = A1_LOJA "
cQuery += " AND US_VEND = A3_COD "
cQuery += " AND A3_ZZCC = CTT_CUSTO "
cQuery += " AND CK_PRODUTO = B1_COD "
cQuery += " AND CJ_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND CJ_PROSPE = '"+mv_par03+"' "
Endif
If !Empty(mv_par04)
	cQuery += " AND CJ_CLIENTE = '"+mv_par04+"' "
Endif
If !Empty(mv_par05)
	cQuery += " AND A3_REGIAO = '"+mv_par05+"' "
Endif
If !Empty(mv_par06)
	cQuery += " AND CK_PRODUTO = '"+mv_par06+"' "
Endif
If !Empty(mv_par07)
	zUnNeg := AllTrim(mv_par07)
	cQuery += " AND CTT_ZZITCT IN"+FormatIn(zUnNeg,",")
Endif
cQuery += " AND SCJ.D_E_L_E_T_ <> '*' "
cQuery += " AND SCK.D_E_L_E_T_ <> '*' "
cQuery += " AND SUS.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND CTT.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
nTotSql := SQL2->SOMA
SQL2->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT CJ_FILIAL FILIAL, CJ_NUM ORCAMENTO, CK_ITEM ITEM, US_VEND RTV, A3_GEREN GRV, CTT_ZZITCT BU, CJ_CLIENTE SEMENTEIRA, A1_NOME NOM_SEM, "
cQuery += " CK_PRODUTO CULTIVAR, B1_DESC DESCR_CULT, CK_ZPENEIR PENEIRA, CK_QTDVEN QTD1, B1_UM UM1, B1_SEGUM UM2, B1_CONV CONV, B1_TIPCONV TIPCONV, "
cQuery += " CK_PRCVEN PRECO, CK_VALOR TOTAL, CJ_XFRETE TPFRETE, CJ_DATA1 DT_PAGTO, CJ_PROSPE CLIENTE, US_NOME NOM_CLI, US_EST UF, US_ENDENT ENDENT, US_MUNENT MUNENT, "
cQuery += " US_END ENDFAT, US_MUN MUNFAT, US_CGC CGC, US_INSCR IE "
cQuery += " FROM "+RetSqlName("SCJ")+" SCJ, "
cQuery += RetSqlName("SCK")+" SCK, "
cQuery += RetSqlName("SUS")+" SUS, "
cQuery += RetSqlName("SA3")+" SA3, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("CTT")+" CTT, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE CJ_FILIAL IN("+zFiliais+") "
cQuery += " AND CJ_FILIAL = CK_FILIAL "
cQuery += " AND CJ_NUM = CK_NUM "
cQuery += " AND CJ_PROSPE = US_COD "
cQuery += " AND CJ_LOJPRO = US_LOJA "
cQuery += " AND CJ_CLIENTE = A1_COD "
cQuery += " AND CJ_LOJA = A1_LOJA "
cQuery += " AND US_VEND = A3_COD "
cQuery += " AND A3_ZZCC = CTT_CUSTO "
cQuery += " AND CK_PRODUTO = B1_COD "
cQuery += " AND CJ_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND CJ_PROSPE = '"+mv_par03+"' "
Endif
If !Empty(mv_par04)
	cQuery += " AND CJ_CLIENTE = '"+mv_par04+"' "
Endif
If !Empty(mv_par05)
	cQuery += " AND A3_REGIAO = '"+mv_par05+"' "
Endif
If !Empty(mv_par06)
	cQuery += " AND CK_PRODUTO = '"+mv_par06+"' "
Endif
If !Empty(mv_par07)
	zUnNeg := AllTrim(mv_par07)
	cQuery += " AND CTT_ZZITCT IN"+FormatIn(zUnNeg,",")
Endif
cQuery += " AND SCJ.D_E_L_E_T_ <> '*' "
cQuery += " AND SCK.D_E_L_E_T_ <> '*' "
cQuery += " AND SUS.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND CTT.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY CJ_FILIAL, CJ_NUM, CK_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

DbSelectArea("SQL2")
ProcRegua(nTotSql)
SQL2->(DbGotop())
If !Eof()

	cNomePlan  := "SCJ_FATR03"
	cNomeTable := "Sementes de Verdade - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"RTV",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"GRV",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BU",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Sementeira",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cultivar",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Peneira",3,2)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde.1a.UM",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"1a.UM",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde.2a.UM",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"2a.UM",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Preço Unitário",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,2)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Bag",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Palete",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Logística",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data Pagamento",1,4)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"UF",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"End.Entrega",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Mun.Entrega",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"End.Faturamento",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Mun.Faturamento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CPF/CNPJ",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"IE",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SCJ")
		DbSetOrder(1)
		DbSeek( SQL2->(FILIAL+ORCAMENTO) )

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SCJ->(CJ_CLIENTE+CJ_LOJA) )

		zLocal  := FWFilialName(cEmpAnt,SQL2->FILIAL,1)
		zRtv    := RetField("SA3",1,xFilial("SA3")+SQL2->RTV,"A3_NOME")
		zGrv    := RetField("SA3",1,xFilial("SA3")+SA3->A3_GEREN,"A3_NOME")
		zQtd2   := IIf(SQL2->TIPCONV=="M",(SQL2->QTD1*SQL2->CONV),(SQL2->QTD1/SQL2->CONV))
		zBag    := IIf(SQL2->UM1=="KG",(SQL2->QTD1/1000),(zQtd2/1000))
		zPalete := IIf(SQL2->UM1=="SC",(SQL2->QTD1/25),(zQtd2/25))
		zLogist := IIf(SQL2->TPFRETE=="C","CIF",IIf(SQL2->TPFRETE=="F","FOB",""))
		zDtPagt := StoD(SQL2->DT_PAGTO)
		zCgc    := IIf( Len(AllTrim(SQL2->CGC))>11, Transform(SQL2->CGC,"@R 99.999.999/9999-99") , Transform(SQL2->CGC,"@R 999.999.999-99") )

		oExcel:AddRow(cNomePlan, cNomeTable, {SQL2->FILIAL, zLocal, zRtv, zGrv, SQL2->BU, SQL2->NOM_SEM, SQL2->CULTIVAR, SQL2->DESCR_CULT, SQL2->PENEIRA,;
		   									  SQL2->QTD1, SQL2->UM1, zQtd2, SQL2->UM2, SQL2->PRECO, SQL2->TOTAL, zBag, zPalete, zLogist, zDtPagt,;
		   									  SQL2->NOM_CLI, SQL2->UF, SQL2->ENDENT, SQL2->MUNENT, SQL2->ENDFAT, SQL2->MUNFAT, zCgc, SQL2->IE })

		DbSelectArea("SQL2")
		SQL2->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SCJ_FATR03-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
