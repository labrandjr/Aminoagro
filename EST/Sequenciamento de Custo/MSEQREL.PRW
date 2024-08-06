#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MSEQREL  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 25/03/2020      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lista movimentos sem valorização do custo médio.		  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MSEQREL()

Local cPerg := "MSEQREL"
Private cPath := "c:\report\"
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pSeqCal()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pSeqCal   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 25/03/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pSeqCal()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
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
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_CUSTO1 = 0 "
cQuery += " AND SUBSTR(D3_COD,1,3) <> 'MOD' "
cQuery += " AND D3_COD <> 'MANUTENCAO' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT D3_FILIAL FILIAL, D3_COD PRODUTO, D3_LOCAL ARMAZEM, D3_NUMSEQ NUMSEQ, D3_TM TM, D3_QUANT QUANT, D3_UM UM, "
cQuery += " D3_CF CF, D3_OP OP, D3_DOC DOC, D3_EMISSAO EMISSAO, D3_TIPO TIPO, D3_LOTECTL LOTECTL, D3_RATEIO RATEIO, D3_USUARIO USUARIO "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_CUSTO1 = 0 "
cQuery += " AND SUBSTR(D3_COD,1,3) <> 'MOD' "
cQuery += " AND D3_COD <> 'MANUTENCAO' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, PRODUTO, NUMSEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "MOV_MSEQREL"
	cNomeTable := "Movimentos sem valorização"
	cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Sequência",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Mov.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UM",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Fiscal",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"OP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Lote",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Rateio",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Usuário",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SQL->PRODUTO )
		
		oExcel:AddRow(cNomePlan, cNomeTable, {SQL->FILIAL, SQL->PRODUTO, SB1->B1_DESC, SQL->ARMAZEM, SQL->NUMSEQ,;
											  SQL->TM, SQL->QUANT, SQL->UM, SQL->CF, SQL->OP, SQL->DOC, StoD(SQL->EMISSAO),;
											  SQL->TIPO, SQL->LOTECTL, SQL->RATEIO, SQL->USUARIO })

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "MOV_MSEQREL-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
