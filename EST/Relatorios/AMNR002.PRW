#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR002  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/02/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Formação de Preços.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR002()

Local cPerg := "AMNR02"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR02()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR02   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 14/02/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR02()

Local oExcel := FwMsExcel():New()
Local aDados := {}
Local nTotal := 0
Local cQuery, nx

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SZA")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND ZA_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += " AND ZA_TIPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND ZA_GRUPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SZA")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND ZA_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += " AND ZA_TIPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND ZA_GRUPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
cQuery += " ORDER BY ZA_FILIAL, ZA_TIPO, ZA_PRODUTO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SZA_AMNR02"
	cNomeTable := "Formação de Preços"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Embalagem",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% Embalagem",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Solução",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% Solução",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"MOD",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% MOD",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"MOI",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% MOI",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Atualizado em",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Usuário",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		zLocal := FWFilialName(cEmpAnt,SQL->ZA_FILIAL,1)
		oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, SQL->ZA_FILIAL, SQL->ZA_PRODUTO, SQL->ZA_DESCRI, SQL->ZA_TIPO, SQL->ZA_GRUPO,;
											  SQL->ZA_CUSTOT, SQL->ZA_CUSEMB, SQL->ZA_PEREMB, SQL->ZA_CUSSOL, SQL->ZA_PERSOL,;
											  SQL->ZA_CUSMOD, SQL->ZA_PERMOD, SQL->ZA_CUSMOI, SQL->ZA_PERMOI,;
											  StoD(SQL->ZA_DATA), SQL->ZA_USER })
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SZA_AMNR02-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
