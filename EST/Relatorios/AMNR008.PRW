#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR008  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 13/04/2020      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relação de Frete.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR008()

Local cPerg := "AMNR08"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR08()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR08   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 13/04/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR08()

Local oExcel := FwMsExcel():New()
Local cQuery
Local zFiliais := ""
Local zProdXml := AllTrim(GetMv("MV_XMLPFCT"))
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

	cNomePlan  := "SD1_AMNR08"
	cNomeTable := "Relação de Fretes - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
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

	While !Eof()

		IncProc("Gerando planilha...")

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
		zDocOrS := ""
		zOpeOri := ""
		zEmiOri := CtoD("")
		zCliOri := ""
		zRazOri := ""
		zGrpEco := ""
		zMunOri := ""
		zEstOri := ""
		lMonXml := .F.

		nRecSd1 := SD1->(Recno())
		nRecSb1 := SB1->(Recno())
		nRecSa2 := SA2->(Recno())

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
			Endif
		ElseIf AllTrim(SD1->D1_COD) == zProdXml
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
						d1VUnit := ZZO->ZZO_VRAT
						d1Total := ZZO->ZZO_VRAT
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
						d1VUnit := ZZO->ZZO_VRAT
						d1Total := ZZO->ZZO_VRAT
						d1VlIcm := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALICM),2)
						d1VlIm6 := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALIMP6),2)
						d1VlIm5 := Round(((ZZO->ZZO_VRAT / zTotRat) * SD1->D1_VALIMP5),2)
						zVlPedg := ((nPedag / zTotRat) * ZZO->ZZO_VRAT)
					Endif	
					AAdd(aDocXml,{zDocOrE, zDocOrS, zOpeOri, zEmiOri, zCliOri, zRazOri, zGrpEco, zMunOri, zEstOri, d1VUnit, d1Total, zVlPedg, d1VlIcm, d1VlIm6, d1VlIm5})
					DbSelectArea("ZZO")
					ZZO->(DbSkip())
				Enddo
			Endif

		Endif

		SD1->(DbGoto(nRecSd1))
		SB1->(DbGoto(nRecSb1))
		SA2->(DbGoto(nRecSa2))
		
		If !lMonXml
			zVlPedg := ((nPedag / nVMerc) * SD1->D1_TOTAL)
			oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SD1->D1_FILIAL, SD1->D1_FORNECE, SA2->A2_NOME, SD1->D1_DOC, SD1->D1_SERIE,;
												SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SB1->B1_COD, SB1->B1_DESC, SD1->D1_QUANT,;
												SD1->D1_VUNIT, SD1->D1_TOTAL, zVlPedg, SD1->D1_VALICM, SD1->D1_VALIMP6, SD1->D1_VALIMP5,;
												SD1->D1_TES, zOperac, SD1->D1_CF, AllTrim(SX5->X5_DESCRI),;
												SD1->D1_CONTA, CT1->CT1_DESC01, SD1->D1_CC, CTT->CTT_DESC01, SD1->D1_ITEMCTA, CTD->CTD_DESC01,;
												zDocOrE, zDocOrS, zOpeOri, zEmiOri, zCliOri, zRazOri, zGrpEco, zMunOri, zEstOri })
		Else
			For _xml := 1 to Len(aDocXml)
				oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SD1->D1_FILIAL, SD1->D1_FORNECE, SA2->A2_NOME, SD1->D1_DOC, SD1->D1_SERIE,;
													SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SB1->B1_COD, SB1->B1_DESC, SD1->D1_QUANT,;
													aDocXml[_xml][10], aDocXml[_xml][11], aDocXml[_xml][12], aDocXml[_xml][13], aDocXml[_xml][14], aDocXml[_xml][15],;
													SD1->D1_TES, zOperac, SD1->D1_CF, AllTrim(SX5->X5_DESCRI),;
													SD1->D1_CONTA, CT1->CT1_DESC01, SD1->D1_CC, CTT->CTT_DESC01, SD1->D1_ITEMCTA, CTD->CTD_DESC01,;
													aDocXml[_xml][1], aDocXml[_xml][2], aDocXml[_xml][3], aDocXml[_xml][4], aDocXml[_xml][5], aDocXml[_xml][6], aDocXml[_xml][7], aDocXml[_xml][8], aDocXml[_xml][9] })
			Next _xml
		Endif

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD1_AMNR08-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
