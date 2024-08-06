#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR008  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/07/2020      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lista pedidos de venda com %comissão divergente.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR008()

Local cPerg := "FATR08"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR08()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR08   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 30/12/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR08()

Local oExcel    := FwMsExcel():New()
Local zFiliais  := ""
Local nForFilial

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
cQuery := " SELECT COUNT(*)AS SOMA FROM "
cQuery += " ( "
cQuery += " SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO "
cQuery += " FROM "+RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SC6")+" SC6 "
cQuery += " WHERE C6_FILIAL IN("+zFiliais+") "
cQuery += " AND C5_FILIAL = C6_FILIAL "
cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND C5_FILIAL||C5_NUM IN (SELECT C5_FILORIG||C5_PEDORIG FROM SC5G10 WHERE C5_PEDORIG <> ' ' AND D_E_L_E_T_ <> '*') "
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ <> 'R' "
cQuery += " AND C5_ZZCDFXV <> ' ' "
cQuery += " AND C5_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery += " SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO "
cQuery += " FROM "+RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SC6")+" SC6 "
cQuery += " WHERE C6_FILIAL IN("+zFiliais+") "
cQuery += " AND C5_FILIAL = C6_FILIAL "
cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND C5_PEDORIG <> ' '
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ <> 'R' "
cQuery += " AND C5_ZZCDFXV <> ' ' "
cQuery += " AND C5_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " ) "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO "
cQuery += " FROM "+RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SC6")+" SC6 "
cQuery += " WHERE C6_FILIAL IN("+zFiliais+") "
cQuery += " AND C5_FILIAL = C6_FILIAL "
cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND C5_FILIAL||C5_NUM IN (SELECT C5_FILORIG||C5_PEDORIG FROM SC5G10 WHERE C5_PEDORIG <> ' ' AND D_E_L_E_T_ <> '*') "
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ <> 'R' "
cQuery += " AND C5_ZZCDFXV <> ' ' "
cQuery += " AND C5_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery := " SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO "
cQuery += " FROM "+RetSqlName("SC5")+" SC5, "
cQuery += RetSqlName("SC6")+" SC6 "
cQuery += " WHERE C6_FILIAL IN("+zFiliais+") "
cQuery += " AND C5_FILIAL = C6_FILIAL "
cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND C5_PEDORIG <> ' '
cQuery += " AND C5_TIPO = 'N' "
cQuery += " AND C6_BLQ <> 'R' "
cQuery += " AND C5_ZZCDFXV <> ' ' "
cQuery += " AND C5_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, PEDIDO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SC5_FATR08"
	cNomeTable := "Comissões sc5 x sc6"
	
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Faixa1",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"%Coms1",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"%Item",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fil.Orig",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Ped.Orig",1,1)
	
	While !Eof()

		IncProc("Gerando planilha...")

		cFilAnt := SQL->FILIAL
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PEDIDO) )

		cQuery := " SELECT Z2_COMIS COMIS1 "
		cQuery += " FROM "+RetSqlName("SZ2")
		cQuery += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' "
		cQuery += " AND Z2_CODIGO = '"+SC5->C5_ZZCDFXV+"' "
		cQuery += " AND Z2_GRUPO = '0001' "
		cQuery += " AND Z2_ATIVO = 'S' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ2", .F., .T.)
		nPerc := TRZ2->COMIS1
		TRZ2->(DbCloseArea())

		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PEDIDO) )

		If nPerc <> SC6->C6_COMIS1
			zLocal  := FWFilialName(cEmpAnt,SC5->C5_FILIAL,1)
			oExcel:AddRow(cNomePlan, cNomeTable, {SC5->C5_FILIAL, zLocal, SC5->C5_NUM, SC5->C5_ZZCDFXV, nPerc, SC6->C6_COMIS1, SC5->C5_FILORIG, SC5->C5_PEDORIG })
		Endif

		DbSelectArea("SQL")
		SQL->(DbSkip())

	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SC5_FATR08-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
