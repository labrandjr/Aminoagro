#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR005  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/07/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Trocas/Devoluções.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR005()

Local cPerg := "FATR05"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR05()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR05   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 19/07/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR05()

Local oExcel    := FwMsExcel():New()
Local cTesTrc   := AllTrim(GetMv("MV_XTESTRC")) // TES para Troca
Local aNfSaid   := {}
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
cQuery += " FROM "+RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D1_FILIAL IN("+zFiliais+") "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_FORNECE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND D1_ORIGLAN <> 'LF' "
If mv_par06 == 1 // Devolução de Vendas
	cQuery += " AND D1_TIPO = 'D' "
	cQuery += " AND F4_DUPLIC = 'S' "
ElseIf mv_par06 == 2 // Trocas
	cQuery += " AND D1_TIPO = 'B' AND D1_TES IN"+FormatIn(cTesTrc,",")
Else // Outras Devoluções
	cQuery += " AND D1_TIPO = 'D' "
	cQuery += " AND F4_DUPLIC = 'N' "
Endif
If !Empty(mv_par07)
	cQuery += " AND D1_ITEMCTA = '"+mv_par07+"' "
Endif
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT SD1.R_E_C_N_O_ RECSD1 "
cQuery += " FROM "+RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D1_FILIAL IN("+zFiliais+") "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_FORNECE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND D1_ORIGLAN <> 'LF' "
If mv_par06 == 1 // Devolução de Vendas
	cQuery += " AND D1_TIPO = 'D' "
	cQuery += " AND F4_DUPLIC = 'S' "
ElseIf mv_par06 == 2 // Trocas
	cQuery += " AND D1_TIPO = 'B' AND D1_TES IN"+FormatIn(cTesTrc,",")
Else // Outras Devoluções
	cQuery += " AND D1_TIPO = 'D' "
	cQuery += " AND F4_DUPLIC = 'N' "
Endif
If !Empty(mv_par07)
	cQuery += " AND D1_ITEMCTA = '"+mv_par07+"' "
Endif
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SD1_FATR05"
	If mv_par06 == 1 // Devoluções
		cNomeTable := "Devoluções de Venda"
	ElseIf mv_par06 == 2 // Trocas
		cNomeTable := "Operações de Troca"
	Else // Outras Devoluções
		cNomeTable := "Outras Devoluções"
	Endif	
	cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Entrada",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Estado",1,1) 

	oExcel:AddColumn(cNomePlan,cNomeTable,"Item Nf",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Unit.",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Aliq.Icms",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"TES",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Fiscal",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Armazém",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Lote",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Docto.Orig",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série Orig",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Item Orig",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor Nf Saída",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Ven.Nf Saída",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BU Nf Saída",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Região Nf Saída",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"CC Nf Entrada",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor Nf Entrada",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Ven.Nf Entrada",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BU Nf Entrada",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Região Nf Entrada",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Motivo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Histórico",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cultura",1,1)

	If mv_par06 == 2 // Trocas
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde.Reenviada (em Litros)",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Saldo pendente (em Litros)",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Notas Fiscais",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",3,1)
	Endif

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SD1")
		DbGoto(SQL->RECSD1)
		cFilAnt := SD1->D1_FILIAL

		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SD1->D1_COD )

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_TES) )

		zTipoDo := IIf(SD1->D1_TIPO=="B","Troca",IIf(SF4->F4_DUPLIC=="S","Dev.Vendas","Outras Dev."))
		zRegVen := ""
		zCdVeNf := ""
		zNmVeNf := ""
		zCdVeCC := ""
		zNmVeCC := ""
		zReVeCC := ""
		zBuVend := ""
		zQtReen := 0
		zQtPend := 0
		zNfSaid := ""
		zEmisNf := ""
		zDesRet := Posicione("DHI",1,xFilial("DHI")+SF1->F1_MOTRET,"DHI_DESCRI")
		zHisRet := AllTrim(SF1->F1_HISTRET)
		zCultu  := ""

		If !Empty(SD1->D1_NFORI)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				zBuVend := SD2->D2_ITEMCC

				DbSelectArea("SC5")
				DbSetOrder(1)
				DbSeek( SD2->(D2_FILIAL+D2_PEDIDO) )
				zCultu := RetField("SX5",1,xFilial("SX5")+"ZB"+PadR(SC5->C5_ZZCULT,6),"X5_DESCRI")

				DbSelectArea("SF2")
				DbSetOrder(1)
				DbSeek( SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) )
				zCdVeNf := SF2->F2_VEND1
				zRegVen := AllTrim(Posicione("SX5",1,xFilial("SX5")+"A2"+PadR(SF2->F2_ZZREGVE,6),"X5_DESCRI"))

				If !Empty(SF2->F2_VEND1)
					DbSelectArea("SA3")
					DbSetOrder(1)
					DbSeek( xFilial("SA3") + SF2->F2_VEND1 )
					zNmVeNf := SA3->A3_NOME
				Endif
			Endif
		Endif

		If !Empty(SD1->D1_CC) .And. SD1->D1_TIPO == "D"
			DbSelectArea("SA3")
			DbSetOrder(9)
			If DbSeek( xFilial("SA3") + SD1->D1_CC )
				While !Eof() .And. SA3->(A3_FILIAL+A3_ZZCC) == xFilial("SA3") + SD1->D1_CC
					If Substr(SA3->A3_COD,1,1) $("V,G")
						zCdVeCC := SA3->A3_COD
						zNmVeCC := SA3->A3_NOME
						zReVeCC := AllTrim(Posicione("SX5",1,xFilial("SX5")+"A2"+PadR(SA3->A3_REGIAO,6),"X5_DESCRI"))
						Exit
					Endif
					SA3->(DbSkip())
				Enddo
			Endif
		Endif

		If !Empty(mv_par08) .And. !Empty(zReVeCC)
			If AllTrim(mv_par08) <> AllTrim(zReVeCC)
				DbSelectArea("SQL")
				SQL->(DbSkip())
				Loop
			Endif
		Endif

		nD1Base := 0
		DbSelectArea("SG1")
		DbSetOrder(1)
		If DbSeek( SD1->(D1_FILIAL+D1_COD) )
			zQtBase := Posicione("SBZ",1,SD1->(D1_FILIAL+D1_COD),"BZ_QB")
			bQtBase := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_QB")
			nD1Base := IIf(zQtBase > 0,zQtBase,bQtBase) // Prioriza Indicadores de Produtos (SBZ)
		Endif	
		nD1Base := IIf(nD1Base == 0,1,nD1Base)
		zQtPend := SD1->D1_QUANT

		DbSelectArea("SC6")
		DbSetOrder(16)
		If DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM) )
			While !Eof() .And. SC6->(C6_FILIAL+C6_ZZNFTRO) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM)
				DbSelectArea("SD2")
				DbSetOrder(8)
				If DbSeek( SC6->(C6_FILIAL+C6_NUM+C6_ITEM) )
					While !Eof() .And. SD2->(D2_FILIAL+D2_PEDIDO+D2_ITEMPV) == SC6->(C6_FILIAL+C6_NUM+C6_ITEM)
						zQtReen += SD2->D2_QUANT
						lNfSaid := .F.
						If Len(aNfSaid) == 0
							AAdd(aNfSaid,{SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM), SD2->D2_DOC})
							lNfSaid := .T.
						Else
							nPos := aScan(aNfSaid, {|x| x[1] == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM) .And. x[2] == SD2->D2_DOC})
							If nPos == 0
								AAdd(aNfSaid,{SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM), SD2->D2_DOC})
								lNfSaid := .T.
							Endif
						Endif	
						If lNfSaid						
							zNfSaid += IIf(!Empty(zNfSaid),", ","") + AllTrim(SD2->D2_DOC)
							zEmisNf += IIf(!Empty(zEmisNf),", ","") + DtoC(SD2->D2_EMISSAO)
						Endif	
						DbSelectArea("SD2")
						SD2->(DbSkip())
					Enddo
				Endif

				DbSelectArea("SC6")
				SC6->(DbSkip())
			Enddo
			//
			zQtPend -= zQtReen // Saldo pendente em Litros
			//
		Endif

        If mv_par06 == 2 // Trocas
	        aArray := Array(39)
		Else
	        aArray := Array(35)
		Endif

		aArray[1]  := SD1->D1_FILIAL
		aArray[2]  := SD1->D1_DOC
		aArray[3]  := SD1->D1_SERIE
		aArray[4]  := SD1->D1_DTDIGIT
		aArray[5]  := zTipoDo
		aArray[6]  := SA1->A1_NOME
		aArray[7]  := SA1->A1_MUN
		aArray[8]  := SA1->A1_EST
		aArray[9]  := SD1->D1_ITEM
		aArray[10] := SB1->B1_COD
		aArray[11] := SB1->B1_DESC
		aArray[12] := SD1->D1_QUANT
		aArray[13] := SD1->D1_VUNIT
		aArray[14] := SD1->D1_TOTAL
		aArray[15] := SD1->D1_PICM
		aArray[16] := SD1->D1_TES
		aArray[17] := SD1->D1_CF
		aArray[18] := SD1->D1_LOCAL
		aArray[19] := SD1->D1_TP
		aArray[20] := SD1->D1_LOTECTL
		aArray[21] := SD1->D1_NFORI
		aArray[22] := SD1->D1_SERIORI
		aArray[23] := SD1->D1_ITEMORI
		aArray[24] := zCdVeNf
		aArray[25] := zNmVeNf
		aArray[26] := zBuVend
		aArray[27] := zRegVen
		aArray[28] := SD1->D1_CC
		aArray[29] := zCdVeCC
		aArray[30] := zNmVeCC
		aArray[31] := SD1->D1_ITEMCTA
		aArray[32] := zReVeCC
		aArray[33] := zDesRet
		aArray[34] := zHisRet
		aArray[35] := zCultu

		If mv_par06 == 2 // Trocas
			aArray[36] := zQtReen
			aArray[37] := zQtPend
			aArray[38] := zNfSaid
			aArray[39] := zEmisNf
		Endif	
		
		oExcel:AddRow(cNomePlan, cNomeTable, aArray)
				
		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD1_FATR05-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
