#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR018  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/07/2021      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Fretes Gerencial.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR018()

Local cPerg := "AMNR08"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR18()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR18   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 14/07/2021     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR18()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local zProdXml := AllTrim(GetMv("MV_XMLPFCT"))
Local lExport  := .F.
Local cQuery
Local nForFilial
Local _xml

aFilsCalc := MatFilCalc( mv_par03 == 1 )
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
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_COD IN('DESPFEL_0023','DESPESA_0055','"+zProdXml+"') "
cQuery += " AND D1_TES <> ' ' "
cQuery += " AND D1_TIPO = 'N' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECSD1 "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_COD IN('DESPFEL_0023','DESPESA_0055','"+zProdXml+"') "
cQuery += " AND D1_TES <> ' ' "
cQuery += " AND D1_TIPO = 'N' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D1_FILIAL, D1_FORNECE, D1_DOC, D1_SERIE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "Despesas"
	cNomeTable := "Despesas - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Digitação",1,4)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Unitário",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Pedágio",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Icms",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pis",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cofins",3,3)
	
	oExcel:AddColumn(cNomePlan,cNomeTable,"TES",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.TES",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CFOP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.CFOP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Conta Contábil",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Conta",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Centro Custo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.CC",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Negócio",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.BU",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Doc.Frete Entrada",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Doc.Frete Saída",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Operação Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão Origem",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cli/For Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grp.Ec.Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Munic Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UF Origem",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Operação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Líquido",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Frete",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Reclassificação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Destinação Frete",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"NF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Litragem",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Ano NF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Itens NF",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Total NF",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		lExport := .T.

		DbSelectArea("SD1")
		SD1->(DbGoto(SQL->RECSD1))	

		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
		nPedag := SF1->F1_VALPEDG
		nVMerc := SF1->F1_VALMERC

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SD1->(D1_FORNECE+D1_LOJA) )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SD1->D1_COD )

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_TES) )
		zOperac := SF4->F4_FINALID

		DbSelectArea("SX5")
		DbSetOrder(1)
		DbSeek( xFilial("SX5") + "13" + PadR(SD1->D1_CF,6) )

		DbSelectArea("CT1")
		DbSetOrder(1)
		DbSeek( xFilial("CT1") + SD1->D1_CONTA )
		zCtaOri := SD1->D1_CONTA

		DbSelectArea("CTT")
		DbSetOrder(1)
		DbSeek( xFilial("CTT") + SD1->D1_CC )

		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek( xFilial("CTD") + SD1->D1_ITEMCTA )

		zLocal  := FWFilialName(cEmpAnt,SD1->D1_FILIAL,1)
		zDocOrE := ""
		zDocOrS := ""
		zTesOri := ""
		zOpeOri := ""
		zEmiOri := CtoD("")
		zCliOri := ""
		zRazOri := ""
		zGrpEco := ""
		zMunOri := ""
		zEstOri := ""
		zTpFret := ""
		zReclas := ""
		zDestin := ""
		zDocume := ""
		zLitrag := 0
		zAnoEmi := ""
		zQtdIte := 0
		zVlrTot := 0
		lMonXml := .F.

		nRecSd1 := SD1->(Recno())
		nRecSb1 := SB1->(Recno())
		nRecSa2 := SA2->(Recno())
		nRecCt1 := CT1->(Recno())

		//MsgAlert("1 - "+SD1->D1_DOC )

		If !Empty(SD1->D1_XNFFRE)

			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek( SD1->D1_FILIAL + AllTrim(SD1->D1_XNFFRE) )
				zDocOrE := SF1->F1_DOC
				zTesOri := RetField("SD1",1,SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),"D1_TES")
				zFinali := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_FINALID")
				zOpeOri := zTesOri+" - "+AllTrim(zFinali)
				zEmiOri := SF1->F1_DTDIGIT
				zCliOri := SF1->F1_FORNECE
				zRazOri := IIf(SF1->F1_TIPO $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_NOME"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_NOME"))
				zGrpEco := IIf(SF1->F1_TIPO $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_ZZGECON"), zRazOri)
				zMunOri := IIf(SF1->F1_TIPO $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_MUN"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_MUN"))
				zEstOri := IIf(SF1->F1_TIPO $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_EST"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_EST"))
				zCtaFre := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_ZCTACTE")
				zTpFret := AllTrim(RetField("CT1",1,xFilial("CT1")+zCtaFre,"CT1_DESC01"))
				zReclas := IIf(zCtaFre == zCtaOri,"Ok","Reclassificar")
				zProdut := RetField("SD1",1,SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),"D1_COD")
				zTipoPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_TIPO")
				zDescPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_DESC")
				zDestin := GetDest("E",SF1->F1_FILIAL,zTesOri,zTipoPr,zDescPr)
				zDocume := SF1->F1_DOC
				zLitrag := GetLitr("E")
				zAnoEmi := Substr(DtoS(SF1->F1_EMISSAO),1,4)
				zQtdIte := GetQtIt("E")
				zVlrTot := u_GetVTot("E")
			Endif

		ElseIf !Empty(SD1->D1_XNFFRS)

			DbSelectArea("SF2")
			DbSetOrder(1)
			If DbSeek( SD1->D1_FILIAL + AllTrim(SD1->D1_XNFFRS) )
				zDocOrS := SF2->F2_DOC
				zTesOri := RetField("SD2",3,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),"D2_TES")
				zFinali := RetField("SF4",1,SF2->F2_FILIAL+zTesOri,"F4_FINALID")
				zOpeOri := zTesOri+" - "+AllTrim(zFinali)
				zEmiOri := SF2->F2_EMISSAO
				zCliOri := SF2->F2_CLIENTE
				zRazOri := IIf(SF2->F2_TIPO $("D,B"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_NOME"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_NOME")) 
				zGrpEco := IIf(SF2->F2_TIPO $("D,B"), zRazOri, RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_ZZGECON"))
				zMunOri := IIf(SF2->F2_TIPO $("D,B"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_MUN"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_MUN"))
				zEstOri := IIf(SF2->F2_TIPO $("D,B"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_EST"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_EST"))
				zCtaFre := RetField("SF4",1,SF2->F2_FILIAL+zTesOri,"F4_ZCTACTE")
				zTpFret := AllTrim(RetField("CT1",1,xFilial("CT1")+zCtaFre,"CT1_DESC01"))
				zReclas := IIf(zCtaFre == zCtaOri,"Ok","Reclassificar")
				zProdut := RetField("SD2",3,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),"D2_COD")
				zTipoPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_TIPO")
				zDescPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_DESC")
				zDestin := GetDest("S",SF2->F2_FILIAL,zTesOri,zTipoPr,zDescPr)
				zDocume := SF2->F2_DOC
				zLitrag := GetLitr("S")
				zAnoEmi := Substr(DtoS(SF2->F2_EMISSAO),1,4)
				zQtdIte := GetQtIt("S")
				zVlrTot := u_GetVTot("S")
			Endif

		ElseIf AllTrim(SD1->D1_COD) == zProdXml // MV_XMLPFCT = DESP_FRETE
			
			//MsgAlert("2 - "+SD1->D1_DOC )
			
			lMonXml := .T.
			aDocXml := {}
			zTotRat := 0
			DbSelectArea("ZZO")
			DbSetOrder(1)
			If DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
				While !Eof() .And. ZZO->(ZZO_FILIAL+ZZO_DOCCTE+ZZO_SERCTE+ZZO_FORCTE+ZZO_LOJCTE) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
					zTotRat += ZZO->ZZO_VRAT
					DbSelectArea("ZZO")
					ZZO->(DbSkip())
				Enddo
			Endif	
			DbSelectArea("ZZO")
			DbSetOrder(1)
			If DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
				While !Eof() .And. ZZO->(ZZO_FILIAL+ZZO_DOCCTE+ZZO_SERCTE+ZZO_FORCTE+ZZO_LOJCTE) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
					zDocOrE := IIf(ZZO->ZZO_TIPCHV=="E",ZZO->ZZO_DOCNFE,"")
					zDocOrS := IIf(ZZO->ZZO_TIPCHV=="S",ZZO->ZZO_DOCNFE,"")
					zTesOri := ZZO->ZZO_TESNFE
					zFinali := RetField("SF4",1,ZZO->ZZO_FILNFE+zTesOri,"F4_FINALID")
					zOpeOri := zTesOri+" - "+AllTrim(zFinali)
					If ZZO->ZZO_TIPCHV == "E"
						DbSelectArea("SF1")
						DbSetOrder(1)
						DbSeek( ZZO->(ZZO_FILNFE+ZZO_DOCNFE+ZZO_SERNFE+ZZO_CLIFOR+ZZO_LOJNFE) )
						zEmiOri := SF1->F1_DTDIGIT
						zCliOri := ZZO->ZZO_CLIFOR
						zRazOri := IIf(ZZO->ZZO_TIPNFE $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_NOME"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_NOME"))
						zGrpEco := IIf(ZZO->ZZO_TIPNFE $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_ZZGECON"), zRazOri)
						zMunOri := IIf(ZZO->ZZO_TIPNFE $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_MUN"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_MUN"))
						zEstOri := IIf(ZZO->ZZO_TIPNFE $("D,B"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_EST"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_EST"))
						zCtaFre := RetField("SF4",1,ZZO->ZZO_FILNFE+zTesOri,"F4_ZCTACTE")
						zTpFret := AllTrim(RetField("CT1",1,xFilial("CT1")+zCtaFre,"CT1_DESC01"))
						zReclas := IIf(zCtaFre == zCtaOri,"Ok","Reclassificar")
						zProdut := RetField("SD1",1,ZZO->(ZZO_FILNFE+ZZO_DOCNFE+ZZO_SERNFE+ZZO_CLIFOR+ZZO_LOJNFE),"D1_COD")
						zTipoPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_TIPO")
						zDescPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_DESC")
						zDestin := GetDest("E",ZZO->ZZO_FILNFE,zTesOri,zTipoPr,zDescPr)
						zDocume := ZZO->ZZO_DOCNFE
						zLitrag := GetLitr("E")
						zAnoEmi := Substr(DtoS(SF1->F1_EMISSAO),1,4)
						zQtdIte := GetQtIt("E")
						zVlrTot := u_GetVTot("E")
						d1VUnit := ZZO->ZZO_VRAT
						d1Total := ZZO->ZZO_VRAT

						SD1->(DbGoto(nRecSd1))
						//MsgAlert("3 - "+SD1->D1_DOC )
						//MsgAlert( AllTrim(STR(ZZO->ZZO_VRAT)) )
						//MsgAlert( AllTrim(STR(zTotRat)) )
						//MsgAlert( AllTrim(STR(SD1->D1_VALICM)) )

						d1VlIcm := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALICM),2)
						d1VlIm6 := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALIMP6),2)
						d1VlIm5 := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALIMP5),2)
						zVlPedg := ((nPedag / zTotRat) * ZZO->ZZO_VRAT)
					Else
						DbSelectArea("SF2")
						DbSetOrder(1)
						DbSeek( ZZO->(ZZO_FILNFE+ZZO_DOCNFE+ZZO_SERNFE+ZZO_CLIFOR+ZZO_LOJNFE) )
						zEmiOri := SF2->F2_EMISSAO
						zCliOri := ZZO->ZZO_CLIFOR
						zRazOri := IIf(ZZO->ZZO_TIPNFE $("D,B"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_NOME"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_NOME")) 
						zGrpEco := IIf(ZZO->ZZO_TIPNFE $("D,B"), zRazOri, RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_ZZGECON"))
						zMunOri := IIf(ZZO->ZZO_TIPNFE $("D,B"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_MUN"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_MUN"))
						zEstOri := IIf(ZZO->ZZO_TIPNFE $("D,B"), RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_EST"), RetField("SA1",1,xFilial("SA1")+zCliOri,"A1_EST"))
						zCtaFre := RetField("SF4",1,ZZO->ZZO_FILNFE+zTesOri,"F4_ZCTACTE")
						zTpFret := AllTrim(RetField("CT1",1,xFilial("CT1")+zCtaFre,"CT1_DESC01"))
						zReclas := IIf(zCtaFre == zCtaOri,"Ok","Reclassificar")
						zProdut := RetField("SD2",3,ZZO->(ZZO_FILNFE+ZZO_DOCNFE+ZZO_SERNFE+ZZO_CLIFOR+ZZO_LOJNFE),"D2_COD")
						zTipoPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_TIPO")
						zDescPr := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_DESC")
						zDestin := GetDest("S",ZZO->ZZO_FILIAL,zTesOri,zTipoPr,zDescPr)
						zDocume := ZZO->ZZO_DOCNFE
						zLitrag := GetLitr("S")
						zAnoEmi := Substr(DtoS(SF2->F2_EMISSAO),1,4)
						zQtdIte := GetQtIt("S")
						zVlrTot := u_GetVTot("S")
						d1VUnit := ZZO->ZZO_VRAT
						d1Total := ZZO->ZZO_VRAT
						d1VlIcm := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALICM),2)
						d1VlIm6 := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALIMP6),2)
						d1VlIm5 := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALIMP5),2)
						zVlPedg := ((nPedag / zTotRat) * ZZO->ZZO_VRAT)
					Endif	
					AAdd(aDocXml,{zDocOrE, zDocOrS, zOpeOri, zEmiOri, zCliOri, zRazOri, zGrpEco, zMunOri, zEstOri, zTesOri, zTpFret, zReclas, zDestin, zDocume, zLitrag, zAnoEmi, zQtdIte, zVlrTot, d1VUnit, d1Total, zVlPedg, d1VlIcm, d1VlIm6, d1VlIm5})
					DbSelectArea("ZZO")
					ZZO->(DbSkip())
				Enddo
			Endif	
		Endif

		SD1->(DbGoto(nRecSd1))
		SB1->(DbGoto(nRecSb1))
		SA2->(DbGoto(nRecSa2))
		CT1->(DbGoto(nRecCt1))

		If !lMonXml
			zVlPedg := ((nPedag / nVMerc) * SD1->D1_TOTAL)
			zValLiq := (SD1->D1_TOTAL + zVlPedg) - SD1->(D1_VALICM + D1_VALIMP6 + D1_VALIMP5)
			oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SD1->D1_FILIAL, SD1->D1_FORNECE, SA2->A2_NOME, SD1->D1_DOC, SD1->D1_SERIE,;
												SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SB1->B1_COD, SB1->B1_DESC, SD1->D1_QUANT,;
												SD1->D1_VUNIT, SD1->D1_TOTAL, zVlPedg, SD1->D1_VALICM, SD1->D1_VALIMP6, SD1->D1_VALIMP5,;
												SD1->D1_TES, zOperac, SD1->D1_CF, AllTrim(SX5->X5_DESCRI),;
												SD1->D1_CONTA, CT1->CT1_DESC01, SD1->D1_CC, CTT->CTT_DESC01, SD1->D1_ITEMCTA, CTD->CTD_DESC01,;
												zDocOrE, zDocOrS, zOpeOri, zEmiOri, zCliOri, zRazOri, zGrpEco, zMunOri, zEstOri,;
												zTesOri, zValLiq, zTpFret, zReclas, zDestin, zDocume, zLitrag, zAnoEmi, zQtdIte, zVlrTot })
		Else
			For _xml := 1 to Len(aDocXml)
				zValLiq := (aDocXml[_xml][20] + aDocXml[_xml][21]) - (aDocXml[_xml][22] + aDocXml[_xml][23] + aDocXml[_xml][24])
				oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SD1->D1_FILIAL, SD1->D1_FORNECE, SA2->A2_NOME, SD1->D1_DOC, SD1->D1_SERIE,;
													SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SB1->B1_COD, SB1->B1_DESC, SD1->D1_QUANT,;
													aDocXml[_xml][19], aDocXml[_xml][20], aDocXml[_xml][21], aDocXml[_xml][22], aDocXml[_xml][23], aDocXml[_xml][24],;
													SD1->D1_TES, zOperac, SD1->D1_CF, AllTrim(SX5->X5_DESCRI),;
													SD1->D1_CONTA, CT1->CT1_DESC01, SD1->D1_CC, CTT->CTT_DESC01, SD1->D1_ITEMCTA, CTD->CTD_DESC01,;
													aDocXml[_xml][1], aDocXml[_xml][2], aDocXml[_xml][3], aDocXml[_xml][4], aDocXml[_xml][5], aDocXml[_xml][6], aDocXml[_xml][7], aDocXml[_xml][8], aDocXml[_xml][9], aDocXml[_xml][10],;
													zValLiq, aDocXml[_xml][11], aDocXml[_xml][12], aDocXml[_xml][13], aDocXml[_xml][14], aDocXml[_xml][15], aDocXml[_xml][16], aDocXml[_xml][17], aDocXml[_xml][18] })
			Next _xml
		Endif

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

Endif
SQL->(DbCloseArea())

// 2. Fretes MP
ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TES <> ' ' "
cQuery += " AND D1_TP = 'MP' "
cQuery += " AND D1_TIPO = 'C' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECSD1 "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TES <> ' ' "
cQuery += " AND D1_TP = 'MP' "
cQuery += " AND D1_TIPO = 'C' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D1_FILIAL, D1_FORNECE, D1_DOC, D1_SERIE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "Matéria-Prima"
	cNomeTable := "Matéria-Prima - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Digitação",1,4)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pedágio",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Icms",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pis",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cofins",3,3)
	
	oExcel:AddColumn(cNomePlan,cNomeTable,"TES",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.TES",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CFOP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.CFOP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Conta Contábil",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Conta",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Centro Custo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.CC",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Negócio",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.BU",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Doc.Original",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Operação Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão Origem",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornec. Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grp.Ec.Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Munic Origem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UF Origem",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Operação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Líquido",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Frete",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Reclassificação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Destinação Frete",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"NF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"U.M.",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Ano NF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Itens NF",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Total NF",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		lExport := .T.

		DbSelectArea("SD1")
		SD1->(DbGoto(SQL->RECSD1))	

		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
		nPedag := SF1->F1_VALPEDG
		nVMerc := SF1->F1_VALMERC

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SD1->(D1_FORNECE+D1_LOJA) )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SD1->D1_COD )

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_TES) )
		zOperac := SF4->F4_FINALID

		DbSelectArea("SX5")
		DbSetOrder(1)
		DbSeek( xFilial("SX5") + "13" + PadR(SD1->D1_CF,6) )

		DbSelectArea("CT1")
		DbSetOrder(1)
		DbSeek( xFilial("CT1") + SD1->D1_CONTA )

		DbSelectArea("CTT")
		DbSetOrder(1)
		DbSeek( xFilial("CTT") + SD1->D1_CC )

		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek( xFilial("CTD") + SD1->D1_ITEMCTA )

		zLocal  := FWFilialName(cEmpAnt,SD1->D1_FILIAL,1)
		zDocOrE := ""
		zTesOri := ""
		zOpeOri := ""
		zEmiOri := CtoD("")
		zCliOri := ""
		zRazOri := ""
		zGrpEco := ""
		zMunOri := ""
		zEstOri := ""
		zTpFret := ""
		zReclas := ""
		zDestin := ""
		zDocume := ""
		zLitrag := 0
		zAnoEmi := ""
		zPrdOri := SD1->D1_COD
		zQtdIte := 0
		zVlrTot := 0

		nRecSd1 := SD1->(Recno())
		nRecSb1 := SB1->(Recno())
		nRecSa2 := SA2->(Recno())
		nRecCt1 := CT1->(Recno())

		If Empty(SD1->D1_NFORI)

			cQuery := " SELECT R_E_C_N_O_ AS RECSF8 "
			cQuery += " FROM "+RetSqlName("SF8")
			cQuery += " WHERE F8_FILIAL = '"+SD1->D1_FILIAL+"' "
			cQuery += " AND F8_NFDIFRE = '"+SD1->D1_DOC+"' "
			cQuery += " AND F8_SEDIFRE = '"+SD1->D1_SERIE+"' "
			cQuery += " AND F8_TRANSP = '"+SD1->D1_FORNECE+"' "
			cQuery += " ORDER BY F8_FILIAL, F8_NFDIFRE, F8_SEDIFRE, F8_TRANSP, F8_NFORIG, F8_SERORIG, F8_FORNECE "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL8", .F., .T.)

			DbSelectArea("SQL8")
			SQL8->(DbGotop())
			While !Eof()

				DbSelectArea("SF8")
				SF8->(DbGoto(SQL8->RECSF8))

				DbSelectArea("SD1")
				DbSetOrder(1)
				If DbSeek( SF8->(F8_FILIAL + F8_NFORIG + F8_SERORIG + F8_FORNECE + F8_LOJA) + zPrdOri )
				
					DbSelectArea("SF1")
					DbSetOrder(1)
					DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )

					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek( xFilial("SB1") + SD1->D1_COD )

					zDocOrE := SF1->F1_DOC
					zTesOri := SD1->D1_TES
					zFinali := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_FINALID")
					zOpeOri := zTesOri+" - "+AllTrim(zFinali)
					zEmiOri := SF1->F1_DTDIGIT
					zCliOri := SF1->F1_FORNECE
					zRazOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_NOME")
					zGrpEco := zRazOri
					zMunOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_MUN")
					zEstOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_EST")
					zCtaFre := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_ZCTACTE")
					zTpFret := AllTrim(RetField("CT1",1,xFilial("CT1")+zCtaFre,"CT1_DESC01"))
					zReclas := "Ok"
					zProdut := SD1->D1_COD
					zTipoPr := SD1->D1_TP
					zDescPr := SB1->B1_DESC
					zDestin := "Compra de MP"
					zDocume := SF1->F1_DOC
					z1aUnid := SB1->B1_UM
					zQuanti := SD1->D1_QUANT
					zAnoEmi := Substr(DtoS(SF1->F1_EMISSAO),1,4)
					zQtdIte := GetQtIt("E")
					zVlrTot := u_GetVTot("E")

					Exit

				Endif
				
				DbSelectArea("SQL8")
				SQL8->(DbSkip())
			Enddo
			SQL8->(DbCloseArea())

		Else

			DbSelectArea("SDT")
			DbSetOrder(3)
			If DbSeek( SD1->(D1_FILIAL+D1_FORNECE+D1_LOJA+D1_DOC+D1_SERIE+D1_COD) )
				cChvNfo := SDT->DT_CHVNFO
				//
				cQry := " SELECT F1_FORNECE, F1_LOJA "
				cQry += " FROM "+RetSqlName("SF1")
				cQry += " WHERE F1_CHVNFE = '"+cChvNfo+"' "
				cQry += " AND D_E_L_E_T_ <> '*' "
				cQry := ChangeQuery(cQry)
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"TRB1", .T., .T.)
				DbSelectArea("TRB1")
				TRB1->(DbGotop())
				If !Eof()
				
					zFilOri := SD1->D1_FILIAL
					zDocOri := SD1->D1_NFORI
					zSerOri := SD1->D1_SERIORI
					zForOri := TRB1->F1_FORNECE
					zLojOri := TRB1->F1_LOJA
					zCodOri := SD1->D1_COD

					DbSelectArea("SD1")
					DbSetOrder(1)
					If DbSeek( zFilori + zDocOri + zSerOri + zForOri + zLojOri + zPrdOri )
					
						DbSelectArea("SF1")
						DbSetOrder(1)
						DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )

						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek( xFilial("SB1") + SD1->D1_COD )

						zDocOrE := SF1->F1_DOC
						zTesOri := SD1->D1_TES
						zFinali := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_FINALID")
						zOpeOri := zTesOri+" - "+AllTrim(zFinali)
						zEmiOri := SF1->F1_DTDIGIT
						zCliOri := SF1->F1_FORNECE
						zRazOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_NOME")
						zGrpEco := zRazOri
						zMunOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_MUN")
						zEstOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_EST")
						zCtaFre := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_ZCTACTE")
						zTpFret := AllTrim(RetField("CT1",1,xFilial("CT1")+zCtaFre,"CT1_DESC01"))
						zReclas := "Ok"
						zProdut := SD1->D1_COD
						zTipoPr := SD1->D1_TP
						zDescPr := SB1->B1_DESC
						zDestin := "Compra de MP"
						zDocume := SF1->F1_DOC
						z1aUnid := SB1->B1_UM
						zQuanti := SD1->D1_QUANT
						zAnoEmi := Substr(DtoS(SF1->F1_EMISSAO),1,4)
						zQtdIte := GetQtIt("E")
						zVlrTot := u_GetVTot("E")

					Endif

				Endif
				TRB1->(DbCloseArea())

			Else

				zFilOri := SD1->D1_FILIAL
				zDocOri := SD1->D1_NFORI
				zSerOri := SD1->D1_SERIORI
				zForOri := SD1->D1_FORNECE
				zLojOri := SD1->D1_LOJA
				zCodOri := SD1->D1_COD

				DbSelectArea("SD1")
				DbSetOrder(1)
				If DbSeek( zFilori + zDocOri + zSerOri + zForOri + zLojOri + zPrdOri )
				
					DbSelectArea("SF1")
					DbSetOrder(1)
					DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )

					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek( xFilial("SB1") + SD1->D1_COD )

					zDocOrE := SF1->F1_DOC
					zTesOri := SD1->D1_TES
					zFinali := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_FINALID")
					zOpeOri := zTesOri+" - "+AllTrim(zFinali)
					zEmiOri := SF1->F1_DTDIGIT
					zCliOri := SF1->F1_FORNECE
					zRazOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_NOME")
					zGrpEco := zRazOri
					zMunOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_MUN")
					zEstOri := RetField("SA2",1,xFilial("SA2")+zCliOri,"A2_EST")
					zCtaFre := RetField("SF4",1,SF1->F1_FILIAL+zTesOri,"F4_ZCTACTE")
					zTpFret := AllTrim(RetField("CT1",1,xFilial("CT1")+zCtaFre,"CT1_DESC01"))
					zReclas := "Ok"
					zProdut := SD1->D1_COD
					zTipoPr := SD1->D1_TP
					zDescPr := SB1->B1_DESC
					zDestin := "Compra de MP"
					zDocume := SF1->F1_DOC
					z1aUnid := SB1->B1_UM
					zQuanti := SD1->D1_QUANT
					zAnoEmi := Substr(DtoS(SF1->F1_EMISSAO),1,4)
					zQtdIte := GetQtIt("E")
					zVlrTot := u_GetVTot("E")

				Endif

			Endif
				
		Endif

		SD1->(DbGoto(nRecSd1))
		SB1->(DbGoto(nRecSb1))
		SA2->(DbGoto(nRecSa2))
		CT1->(DbGoto(nRecCt1))

		zVlPedg := ((nPedag / nVMerc) * SD1->D1_TOTAL)
		zValLiq := (SD1->D1_TOTAL + zVlPedg) - SD1->(D1_VALICM + D1_VALIMP6 + D1_VALIMP5)

		oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SD1->D1_FILIAL, SD1->D1_FORNECE, SA2->A2_NOME, SD1->D1_DOC, SD1->D1_SERIE,;
					  						  SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SB1->B1_COD, SB1->B1_DESC,;
					  						  SD1->D1_TOTAL, zVlPedg, SD1->D1_VALICM, SD1->D1_VALIMP6, SD1->D1_VALIMP5,;
					  						  SD1->D1_TES, zOperac, SD1->D1_CF, AllTrim(SX5->X5_DESCRI),;
					  						  SD1->D1_CONTA, CT1->CT1_DESC01, SD1->D1_CC, CTT->CTT_DESC01, SD1->D1_ITEMCTA, CTD->CTD_DESC01,;
					  						  zDocOrE, zOpeOri, zEmiOri, zCliOri, zRazOri, zGrpEco, zMunOri, zEstOri,;
											  zTesOri, zValLiq, zTpFret, zReclas, zDestin, zDocume, zQuanti, z1aUnid, zAnoEmi, zQtdIte, zVlrTot })

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

Endif
SQL->(DbCloseArea())

If lExport

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD1_AMNR18-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetLitr   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 21/07/2021     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula a litragem da nota fiscal.				  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetLitr(yOpe)

Local aArea := GetArea()
Local nLitr := 0

If yOpe == "S"

	cQuery := " SELECT SUM(D2_QUANT) AS QUANT "
	cQuery += " FROM "+RetSqlName("SD2")
	cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' "
	cQuery += " AND D2_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
	nLitr := SQLT->QUANT
	SQLT->(DbCloseArea())

Else

	cQuery := " SELECT SUM(D1_QUANT) AS QUANT "
	cQuery += " FROM "+RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = '"+SF1->F1_FILIAL+"' "
	cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' "
	cQuery += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
	cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
	nLitr := SQLT->QUANT
	SQLT->(DbCloseArea())

Endif

RestArea(aArea)

Return(nLitr)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetQtIt   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 26/07/2021     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Conta quantidade de itens da nota fiscal.		  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetQtIt(yOpe)

Local aArea := GetArea()
Local nQtIt := 0

If yOpe == "S"

	cQuery := " SELECT COUNT( DISTINCT D2_COD ) AS SOMA  "
	cQuery += " FROM "+RetSqlName("SD2")
	cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' "
	cQuery += " AND D2_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
	nQtIt := SQLT->SOMA
	SQLT->(DbCloseArea())

Else

	cQuery := " SELECT COUNT( DISTINCT D1_COD ) AS SOMA  "
	cQuery += " FROM "+RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = '"+SF1->F1_FILIAL+"' "
	cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' "
	cQuery += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
	cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
	nQtIt := SQLT->SOMA
	SQLT->(DbCloseArea())

Endif

RestArea(aArea)

Return(nQtIt)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetVTot   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 26/07/2021     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valor total da nota fiscal.						  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GetVTot(yOpe)

Local aArea := GetArea()
Local nVTot := 0

If yOpe == "S"

	cQuery := " SELECT SUM( D2_TOTAL ) AS TOTAL  "
	cQuery += " FROM "+RetSqlName("SD2")
	cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' "
	cQuery += " AND D2_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
	nVTot := SQLT->TOTAL
	SQLT->(DbCloseArea())

Else

	cQuery := " SELECT SUM( D1_TOTAL ) AS TOTAL  "
	cQuery += " FROM "+RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = '"+SF1->F1_FILIAL+"' "
	cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' "
	cQuery += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
	cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
	nVTot := SQLT->TOTAL
	SQLT->(DbCloseArea())

Endif

RestArea(aArea)

Return(nVTot)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetDest   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 21/07/2021     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Classifica a operação.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetDest(yOpe,yFil,yTes,yTip,zDcr)

Local aArea   := GetArea()
Local cRetOp  := ""
Local cTesTrc := AllTrim(GetMv("MV_XTESTRC")) // TES para Troca
Local cTesBon := AllTrim(GetMv("MV_XTESBON")) // TES para Bonificação
Local cTesRTr := AllTrim(GetMv("MV_XTESRTR")) // TES para Remessa de Trocas

nRecSf4 := SF4->(Recno())
DbSelectArea("SF4")
DbSetOrder(1)
DbSeek( yFil + yTes )

lDuplic := ( SF4->F4_DUPLIC == "S" )
lEstoqu := ( SF4->F4_ESTOQUE == "S" )
lPoder3 := ( SF4->F4_PODER3 <> "N" )
lP3Reme := ( SF4->F4_PODER3 == "R" )
lP3Devo := ( SF4->F4_PODER3 == "D" )
lTraFil := ( SF4->F4_TRANFIL == "1" )
lAmostr := ( "AMOSTRA" $(Upper(AllTrim(zDcr))) .And. yTip $("MK,MC") )

If yOpe == "S"

	If lAmostr .And. !lEstoqu .And. !lDuplic
		cRetOp := "Envio de Amostra"
	ElseIf yTes $(cTesBon)
		cRetOp := "Envio de Bonificação"
	ElseIf yTip == "MP" .And. !lDuplic .And. !lEstoqu
		cRetOp := "Envio de Embalagem"
	ElseIf yTes $(cTesRTr)
		cRetOp := "Envio de Troca"
	ElseIf lTraFil .And. yTip == "MP"
		cRetOp := "Transferência Filiais MP"
	ElseIf lTraFil .And. yTip == "PA"
		cRetOp := "Transferência Filiais PA"
	ElseIf yTip == "PA" .And. SF2->F2_EST == "EX" .And. lEstoqu .And. lDuplic
		cRetOp := "Venda Exportação"
	ElseIf yTip == "PA" .And. SF2->F2_EST <> "EX" .And. lEstoqu .And. lDuplic
		cRetOp := "Venda PA"
	ElseIf SF2->F2_TIPO == "D"
		cRetOp := "Devolução de Compra"
	ElseIf lP3Reme
		cRetOp := "Remessa Terceiros"
	Else
		cRetOp := "N/I"
	Endif	

ElseIf yOpe == "E"

	If yTip == "MP" .And. SF1->F1_TIPO == "N" .And. !lPoder3
		cRetOp := "Compra MP"
	ElseIf SF1->F1_TIPO == "D"
		cRetOp := "Devolução Venda"
	ElseIf yTip <> "MP" .And. SF1->F1_TIPO == "N" .And. !lPoder3
		cRetOp := "Entrada de bens"	
	ElseIf yTes $(cTesTrc)
		cRetOp := "Recebimento de Troca"
	ElseIf lTraFil .And. yTip == "PA"
		cRetOp := "Transferência Filiais PA"
	ElseIf lTraFil .And. yTip == "MP"
		cRetOp := "Transferência Filiais MP"
	ElseIf lP3Devo
		cRetOp := "Retorno Terceiros"
	Else
		cRetOp := "N/I"
	Endif	

Endif

RestArea(aArea)
SF4->(DbGoto(nRecSf4))

Return(cRetOp)
