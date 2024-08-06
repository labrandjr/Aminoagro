#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 07/02/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Saldos Iniciais.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR001()

Local cPerg := "AMNR01"
Private cPath := "c:\report\"
Private dUlMes := GetMv("MV_ULMES")

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 07/02/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR01()

Local oExcel := FwMsExcel():New()
Local aDados := {}
Local nTotal := 0
Local cQuery, nx

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SB9")+" SB9, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SBM")+" SBM "
cQuery += " WHERE B9_COD = B1_COD "
cQuery += " AND B1_GRUPO = BM_GRUPO "
cQuery += " AND B9_DATA = '"+DtoS(mv_par01)+"' "
cQuery += " AND B9_FILIAL BETWEEN '"+mv_par02+"' AND '"+mv_par03+"' "
cQuery += " AND B1_TIPO BETWEEN '"+mv_par04+"' AND '"+mv_par05+"' "
cQuery += " AND B1_GRUPO BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
cQuery += " AND SB9.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SBM.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT B9_FILIAL FILIAL, B9_COD PRODUTO, B1_DESC DESCRI, B1_TIPO TIPO, B1_GRUPO GRUPO, BM_DESC DESC_GRP, B1_UM UM, B9_LOCAL ARMAZEM, "
cQuery += " B9_DATA DATFEC, B9_QINI QINI, B9_VINI1 VINI1 "
cQuery += " FROM "+RetSqlName("SB9")+" SB9, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SBM")+" SBM "
cQuery += " WHERE B9_COD = B1_COD "
cQuery += " AND B1_GRUPO = BM_GRUPO "
cQuery += " AND B9_DATA = '"+DtoS(mv_par01)+"' "
cQuery += " AND B9_FILIAL BETWEEN '"+mv_par02+"' AND '"+mv_par03+"' "
cQuery += " AND B1_TIPO BETWEEN '"+mv_par04+"' AND '"+mv_par05+"' "
cQuery += " AND B1_GRUPO BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
cQuery += " AND SB9.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SBM.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY B9_FILIAL, B9_COD, B9_LOCAL "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SB9_AMNR01"
	cNomeTable := "Saldos dos Estoques em "+DtoC(mv_par01)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descricao",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Desc Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unid",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Armazem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data Saldo",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd Inic Mes",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Medio",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Sld Ini.Mes",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Saída",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Entrada",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Sld.Ini.",1,4)

	While !Eof()

		IncProc("Gerando planilha...")

		zLocal := FWFilialName(cEmpAnt,SQL->FILIAL,1)
		zCmedi := IIf(SQL->VINI1 > 0, Round((SQL->VINI1 / SQL->QINI),2), 0)

		dtUltS := u__UltSaida(SQL->FILIAL,SQL->PRODUTO)
		dtUltE := u__UltEntr(SQL->FILIAL,SQL->PRODUTO)
		dtUltI := u__UltSaldo(SQL->FILIAL,SQL->PRODUTO)

		oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SQL->FILIAL, SQL->PRODUTO, SQL->DESCRI, SQL->TIPO, SQL->GRUPO, SQL->DESC_GRP, SQL->UM,;
					  						  SQL->ARMAZEM, StoD(SQL->DATFEC), SQL->QINI, zCmedi, SQL->VINI1, dtUltS, dtUltE, dtUltI })
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SB9_AMNR01-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
