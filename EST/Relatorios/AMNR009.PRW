#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR009  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 13/04/2020      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relação de Bonificações.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR009()

Local cPerg := "AMNR09"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR09()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR09   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 13/04/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR09()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local zTesBon  := FormatIn( AllTrim(GetMv("MV_XTESBON")), ",")
Local nForFilial
Local cQuery

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
cQuery += " FROM "+RetSqlName("SD2")
cQuery += " WHERE D2_FILIAL IN ("+zFiliais+") "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D2_TES IN"+zTesBon
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECSD2 "
cQuery += " FROM "+RetSqlName("SD2")
cQuery += " WHERE D2_FILIAL IN ("+zFiliais+") "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D2_TES IN"+zTesBon
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D2_FILIAL, D2_CLIENTE, D2_DOC, D2_SERIE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SD2_AMNR09"
	cNomeTable := "Relação de Bonificações - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grp Econ",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UF",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tp Bonif",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"TES",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Finalidade",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CFOP",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Família",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UM",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Preço Venda",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Icms",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Total",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Armazém",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Centro Custo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Negócio",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SD2")
		SD2->(DbGoto(SQL->RECSD2))	

		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek( SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) )

		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( SD2->(D2_FILIAL+D2_PEDIDO) )

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SD2->(D2_CLIENTE+D2_LOJA) )

		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + SF2->F2_VEND1 )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SD2->D2_COD )

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( SD2->(D2_FILIAL+D2_TES) )
		zFinalid := SF4->F4_FINALID

		DbSelectArea("CTT")
		DbSetOrder(1)
		DbSeek( xFilial("CTT") + SD2->D2_CCUSTO )

		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek( xFilial("CTD") + SD2->D2_ITEMCC )

		zLocal := FWFilialName(cEmpAnt,SD2->D2_FILIAL,1)
		zFamil := Posicione("SZO",1,xFilial("SZO")+SB1->B1_ZFAMILI,"ZO_DESCRI")
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
		
		oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SD2->D2_FILIAL, SD2->D2_CLIENTE, SA1->A1_NOME, SA1->A1_ZZGECON, SA1->A1_MUN, SA1->A1_EST,;
					  						  SD2->D2_DOC, SD2->D2_EMISSAO, SD2->D2_PEDIDO, zTpBon, SD2->D2_TES, zFinalid, SD2->D2_CF,;
					  						  SB1->B1_COD, SB1->B1_DESC, SB1->B1_TIPO, SB1->B1_GRUPO, zFamil,;
					  						  SD2->D2_QUANT, SB1->B1_UM, SD2->D2_PRCVEN, SD2->D2_TOTAL, SD2->D2_VALICM, SD2->D2_CUSTO1,;
					  						  SD2->D2_LOCAL, SD2->D2_CCUSTO, SD2->D2_ITEMCC, SA3->A3_COD, SA3->A3_NOME })
		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD2_AMNR09-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
