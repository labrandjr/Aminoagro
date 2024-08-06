#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COMR004  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 23/04/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lista Necessidades do Mrp.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COMR004()

Local cPerg := "COMR04"
Private cPath := "c:\report\"
Private aColunas := {}
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab04()()})
		Processa({|| pAmnR04()})
		Processa({|| pImpR04()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab04   ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 23/04/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab04()

Local _aTmp := {}
Local zAlias := "TRB"
Local cQuery

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_PRODUTO" , "C", 015, 00} )
AAdd ( _aTmp, {"TF_DESCRI"  , "C", 040, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 002, 00} )
AAdd ( _aTmp, {"TF_CATEG"   , "C", 002, 00} ) 

cQuery := " SELECT DISTINCT(SUBSTR(HF_DATA,1,6))AS PERIODO "
cQuery += " FROM "+RetSqlName("SHF")
cQuery += " WHERE HF_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY PERIODO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSQL", .F., .T.)

DbSelectArea("TSQL")
TSQL->(DbGotop())
If Eof()
	MsgAlert("Atenção, período inválido. Verifique os parâmetros." )
Else
	While !Eof()
		AAdd ( _aTmp, {"TF_Q"+TSQL->PERIODO , "N", 017, 02} )
		AAdd(aColunas,{TSQL->PERIODO,Substr(TSQL->PERIODO,5,2)+"/"+Substr(TSQL->PERIODO,1,4)})
		TSQL->(DbSkip())
	Enddo
Endif
TSQL->(DbCloseArea())

AAdd ( _aTmp, {"TF_TOTAL"   , "N", 017, 02} ) 

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_PRODUTO", "TF_CATEG"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR04   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 23/04/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR04()

Local aDados   := {}
Local nTotal   := 0
Local zFiliais := ""
Local cQuery, nx
Local nForFilial

aFilsCalc := MatFilCalc( mv_par04 == 1 )
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
cQuery += " FROM "+RetSqlName("SHF")+" SHF, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE HF_FILNEC IN ("+zFiliais+") "
cQuery += " AND HF_PRODUTO = B1_COD "
cQuery += " AND HF_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND HF_PRODUTO = '"+mv_par03+"' "
Endif	
If mv_par05 == 1 // PA
	cQuery += " AND B1_TIPO = 'PA' "
ElseIf mv_par05 == 2 // MP
	cQuery += " AND B1_TIPO = 'MP' "
Endif
cQuery += " AND SHF.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")

cQuery := " SELECT HF_FILNEC FILIAL, HF_PRODUTO PRODUTO, B1_DESC DESCRI, B1_TIPO TIPO, HF_DATA DATA, HF_SALDO SALDO, HF_NECESSI NECESSI, SUBSTR(HF_DATA,1,6) PERIODO "
cQuery += " FROM "+RetSqlName("SHF")+" SHF, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE HF_FILNEC IN ("+zFiliais+") "
cQuery += " AND HF_PRODUTO = B1_COD "
cQuery += " AND HF_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND HF_PRODUTO = '"+mv_par03+"' "
Endif	
If mv_par05 == 1 // PA
	cQuery += " AND B1_TIPO = 'PA' "
ElseIf mv_par05 == 2 // MP
	cQuery += " AND B1_TIPO = 'MP' "
Endif
cQuery += " AND SHF.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, PRODUTO, DATA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	While !Eof()

		IncProc("Listando necessidades Mrp..")

		DbSelectArea("TRB")
		DbSetOrder(1)
		If !DbSeek( SQL->FILIAL + SQL->PRODUTO + "01" ) // Saldo
			RecLock("TRB",.T.)
			TRB->TF_FILIAL  := SQL->FILIAL
			TRB->TF_PRODUTO := SQL->PRODUTO
			TRB->TF_DESCRI  := SQL->DESCRI
			TRB->TF_TIPO    := SQL->TIPO
			TRB->TF_CATEG   := "01"
		Else
			RecLock("TRB",.F.)
		Endif
		&("TRB->TF_Q"+SQL->PERIODO) += SQL->SALDO
		TRB->TF_TOTAL := SQL->SALDO // Aqui o total deve ser igual ao saldo do último período.
		MsUnLock()

		DbSelectArea("TRB")
		DbSetOrder(1)
		If !DbSeek( SQL->FILIAL + SQL->PRODUTO + "02" ) // Necessidade
			RecLock("TRB",.T.)
			TRB->TF_FILIAL  := SQL->FILIAL
			TRB->TF_PRODUTO := SQL->PRODUTO
			TRB->TF_DESCRI  := SQL->DESCRI
			TRB->TF_TIPO    := SQL->TIPO
			TRB->TF_CATEG   := "02"
		Else
			RecLock("TRB",.F.)
		Endif
		&("TRB->TF_Q"+SQL->PERIODO) += SQL->NECESSI
		TRB->TF_TOTAL += SQL->NECESSI // Aqui o total deve ser a soma dos períodos.
		MsUnLock()

		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pImpR04   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 23/04/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR04()

Local oExcel := FwMsExcel():New()

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SHF_COMR04"
	cNomeTable := "Lista de Necessidades (MRP)"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Classif.",1,1)
	// Períodos
	For nx := 1 to Len(aColunas)
		oExcel:AddColumn(cNomePlan,cNomeTable,aColunas[nx][2],3,1)
	Next nx
	//
	oExcel:AddColumn(cNomePlan,cNomeTable,"Total",3,1)

	While !Eof()

		IncProc("Gerando planilha...")

        aArray := Array( 5 + Len(aColunas) + 1 )
		aArray[1] := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
		aArray[2] := TRB->TF_PRODUTO
		aArray[3] := TRB->TF_DESCRI
		aArray[4] := TRB->TF_TIPO
		aArray[5] := IIf(TRB->TF_CATEG=="01","Saldo","Necessidade")
		// Quantidade da Classificação
		For nx := 1 to Len(aColunas)
			aArray[nx+5] := &("TRB->TF_Q"+aColunas[nx][1])
		Next nx
		//
		aArray[5+Len(aColunas)+1] := TRB->TF_TOTAL

		oExcel:AddRow(cNomePlan, cNomeTable, aArray)
		//		
		DbSelectArea("TRB")
		TRB->(DbSkip())

	Enddo
	TRB->(DbCloseArea())
	oTempTable:Delete()

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SHF_COMR04-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return
