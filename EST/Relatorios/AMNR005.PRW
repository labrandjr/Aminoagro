#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR005  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 02/08/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Preço x Custo x Margem - por Cliente.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR005()

Local cPerg := "AMNR05"
Private cPath := "c:\report\"
Private aColunas := {}
Private oTempTabl1
Private oTempTabl2

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	Endif

	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab05()()})
		Processa({|| pAmnR05()})
		Processa({|| pImpR05()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab05   ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 02/08/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab05()

Local _aTmp   := {}
Local _aTm2   := {}
Local zAlias1 := "TRB1"
Local zAlias2 := "TRB2"

oTempTabl1 := FWTemporaryTable():New( zAlias1 )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_ITEMCC"  , "C", 009, 00} )
AAdd ( _aTmp, {"TF_PRODUTO" , "C", 015, 00} )
AAdd ( _aTmp, {"TF_CLIENTE" , "C", 006, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 002, 00} )
AAdd ( _aTmp, {"TF_GRUPO"   , "C", 004, 00} )
AAdd ( _aTmp, {"TF_MARCA"   , "C", 004, 00} )
AAdd ( _aTmp, {"TF_CATEG"   , "C", 004, 00} )
AAdd ( _aTmp, {"TF_FAMILI"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_REGIAO"  , "C", 003, 00} )
AAdd ( _aTmp, {"TF_VEND1"   , "C", 006, 00} )

cQuery := " SELECT DISTINCT(SUBSTR(D2_EMISSAO,1,6))AS PERIODO "
cQuery += " FROM "+RetSqlName("SD2")
cQuery += " WHERE D2_EMISSAO BETWEEN '"+DtoS(mv_par05)+"' AND '"+DtoS(mv_par06)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY PERIODO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSQL", .F., .T.)

DbSelectArea("TSQL")
TSQL->(DbGotop())
If Eof()
	MsgAlert("Atenção, período inválido. Verifique os parâmetros." )
Else
	While !Eof()
		//
		AAdd ( _aTmp, {"TF_Q"+TSQL->PERIODO , "N", 017, 02} )
		AAdd ( _aTmp, {"TF_T"+TSQL->PERIODO , "N", 017, 02} )
		AAdd ( _aTmp, {"TF_P"+TSQL->PERIODO , "N", 017, 02} )
		//
		AAdd(aColunas,{TSQL->PERIODO,Substr(TSQL->PERIODO,5,2)+"/"+Substr(TSQL->PERIODO,1,4)})
		TSQL->(DbSkip())
	Enddo
Endif
TSQL->(DbCloseArea())

oTemptabl1:SetFields( _aTmp )
oTempTabl1:AddIndex("indice1", {"TF_FILIAL", "TF_ITEMCC", "TF_PRODUTO", "TF_CLIENTE", "TF_VEND1"})
oTempTabl1:Create()

oTempTabl2 := FWTemporaryTable():New( zAlias2 )

// Totais
AAdd ( _aTm2, {"TT_PERIODO" , "C", 006, 00} )
AAdd ( _aTm2, {"TT_QUANT"   , "N", 017, 02} )
AAdd ( _aTm2, {"TT_VALOR"   , "N", 017, 02} )

oTemptabl2:SetFields( _aTm2 )
oTempTabl2:AddIndex("indice1", {"TT_PERIODO"})
oTempTabl2:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR05   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 02/08/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR05()

Local aDados   := {}
Local nTotal   := 0
Local zFiliais := ""
Local cCnpjI   := AllTrim(GetMv("MV_CGCINTE")) // 08909993000201,06205334000188,90537416000136,09119013000159,08909993000120,08909993000392,08909993000473
Local zCfAdmv  := FormatIn( AllTrim(GetMv("MV_XCFADMV")), ",")
Local cQuery, nx
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
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE D2_FILIAL IN ("+zFiliais+") "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND B1_TIPO <> 'SV' "
cQuery += " AND D2_CF IN"+zCfAdmv
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND D2_FILIAL IN ("+zFiliais+") "
cQuery += " AND B1_TIPO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += " AND B1_GRUPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par05)+"' AND '"+DtoS(mv_par06)+"' "
If mv_par09 == 1 // Somente intercompany
	cQuery += " AND A1_CGC IN"+FormatIn(cCnpjI,",")
ElseIf mv_par09 == 2 // Despreza intercompany
	cQuery += " AND A1_CGC NOT IN"+FormatIn(cCnpjI,",")
Endif
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")

cQuery := " SELECT D2_FILIAL FILIAL, D2_DOC DOC, D2_SERIE SERIE, D2_ITEMCC ITEMCC, D2_COD PRODUTO, D2_CLIENTE CLIENTE, B1_DESC DESCRI, B1_TIPO TIPO, "
cQuery += " B1_GRUPO GRUPO, B1_ZFAMILI FAMILI, D2_EMISSAO EMISSAO, D2_QUANT QUANT, D2_PRCVEN PRCVEN, D2_TOTAL TOTAL, "
cQuery += " (D2_TOTAL-(D2_VALICM+D2_VALIPI+D2_VALIMP5+D2_VALIMP6+D2_VALPIS+D2_VALCOF+D2_VALCSL)) AS TOTLIQ, "
cQuery += " D2_CUSTO1 CUSTO, B1_ZZMARCA MARCA, B1_ZZCATEG CATEG, F4_TEXTO OPERACAO, SUBSTR(D2_EMISSAO,1,6) PERIODO "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE D2_FILIAL IN ("+zFiliais+") "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND B1_TIPO <> 'SV' "
cQuery += " AND D2_CF IN"+zCfAdmv
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND B1_TIPO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += " AND B1_GRUPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par05)+"' AND '"+DtoS(mv_par06)+"' "
If mv_par09 == 1 // Somente intercompany
	cQuery += " AND A1_CGC IN"+FormatIn(cCnpjI,",")
ElseIf mv_par09 == 2 // Despreza intercompany
	cQuery += " AND A1_CGC NOT IN"+FormatIn(cCnpjI,",")
Endif
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, ITEMCC, PRODUTO, CLIENTE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	While !Eof()

		IncProc("Processando preços x custos x margem")

		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+DOC+SERIE) )	

		DbSelectArea("TRB1")
		DbSetOrder(1)
		If !DbSeek( SQL->FILIAL + SQL->ITEMCC + SQL->PRODUTO + SQL->CLIENTE + SF2->F2_VEND1 )
			RecLock("TRB1",.T.)
			TRB1->TF_FILIAL  := SQL->FILIAL
			TRB1->TF_ITEMCC  := SQL->ITEMCC
			TRB1->TF_PRODUTO := SQL->PRODUTO
			TRB1->TF_CLIENTE := SQL->CLIENTE
			TRB1->TF_VEND1   := SF2->F2_VEND1
			TRB1->TF_TIPO    := SQL->TIPO
			TRB1->TF_GRUPO   := SQL->GRUPO
			TRB1->TF_MARCA   := SQL->MARCA
			TRB1->TF_CATEG   := SQL->CATEG
			TRB1->TF_FAMILI  := SQL->FAMILI
			TRB1->TF_REGIAO  := SF2->F2_ZZREGVE
		Else
			RecLock("TRB1",.F.)
		Endif
		&("TRB1->TF_Q"+SQL->PERIODO) += SQL->QUANT
		&("TRB1->TF_T"+SQL->PERIODO) += IIf(mv_par07==1,SQL->TOTAL,IIf(mv_par07==2,SQL->TOTLIQ,SQL->CUSTO))
		MsUnLock()

		// Totais
		DbSelectArea("TRB2")
		DbSetOrder(1)
		If !DbSeek( SQL->PERIODO )
			RecLock("TRB2",.T.)
			TRB2->TT_PERIODO := SQL->PERIODO
		Else
			RecLock("TRB2",.F.)
		Endif
		TRB2->TT_QUANT += SQL->QUANT
		TRB2->TT_VALOR += IIf(mv_par07==1,SQL->TOTAL,IIf(mv_par07==2,SQL->TOTLIQ,SQL->CUSTO))
		MsUnLock()	
		
		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())

// Calcula os percentuais
DbSelectArea("TRB1")
ProcRegua(RecCount())
TRB1->(DbGotop())
While !Eof()

	IncProc("Calculando % participação...")

	RecLock("TRB1",.F.)
	For nx := 1 to Len(aColunas)
		//
		DbSelectArea("TRB2")
		DbSetOrder(1)
		DbSeek( aColunas[nx][1] )
		//
		&("TRB1->TF_P"+aColunas[nx][1]) := Round((( &("TRB1->TF_T"+aColunas[nx][1]) / TRB2->TT_VALOR ) * 100),2)
	Next nx
	MsUnLock()

	DbSelectArea("TRB1")
	TRB1->(DbSkip())
Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pImpR05   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 02/08/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR05()

Local oExcel := FwMsExcel():New()

DbSelectArea("TRB1")
ProcRegua(RecCount())
TRB1->(DbGotop())
If !Eof()

	cNomePlan  := "SD2_AMNR05"
	cNomeTable := IIf(mv_par07==1,"Preço Bruto x Margem",IIf(mv_par07==2,"Preço Líq. x Margem","Custo x Margem"))+" - por Cliente"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Un Negócio",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Marca",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Categoria",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Região",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UF",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Família",1,1)
	
	// Média
	For nx := 1 to Len(aColunas)
		oExcel:AddColumn(cNomePlan,cNomeTable,IIf(mv_par07==1,"Pr.B.",IIf(mv_par07==2,"Pr.L.","Cm."))+aColunas[nx][2],3,3)
	Next nx

	// Quantidade
	For nx := 1 to Len(aColunas)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qt."+aColunas[nx][2],3,1)
	Next nx

	// Valor Total
	For nx := 1 to Len(aColunas)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vl."+aColunas[nx][2],3,3)
	Next nx

	// % Participação
	For nx := 1 to Len(aColunas)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%."+aColunas[nx][2],3,2)
	Next nx

	While !Eof()

		IncProc("Gerando planilha...")

        aArray := Array( 15 + (Len(aColunas)*4) )

		aArray[1] := TRB1->TF_FILIAL
		aArray[2] := TRB1->TF_ITEMCC
		aArray[3] := AllTrim(Posicione("SX5",1,xFilial("SX5") + "Z1" + PadR(TRB1->TF_MARCA,6),"X5_DESCRI"))
		aArray[4] := AllTrim(Posicione("SX5",1,xFilial("SX5") + "Z2" + PadR(TRB1->TF_CATEG,6),"X5_DESCRI"))
		aArray[5] := AllTrim(Posicione("SX5",1,xFilial("SX5") + "A2" + PadR(TRB1->TF_REGIAO,6),"X5_DESCRI"))
		//
		aArray[6] := TRB1->TF_VEND1
		aArray[7] := AllTrim(Posicione("SA3",1,xFilial("SA3") + TRB1->TF_VEND1,"A3_NOME"))
		//
		aArray[8] := TRB1->TF_PRODUTO
		aArray[9] := AllTrim(Posicione("SB1",1,xFilial("SB1") + TRB1->TF_PRODUTO,"B1_DESC"))
		//
		aArray[10] := TRB1->TF_CLIENTE
		aArray[11] := AllTrim(Posicione("SA1",1,xFilial("SA1") + TRB1->TF_CLIENTE,"A1_NOME"))
		aArray[12] := AllTrim(Posicione("SA1",1,xFilial("SA1") + TRB1->TF_CLIENTE,"A1_EST"))
		//
		aArray[13] := TRB1->TF_TIPO
		aArray[14] := AllTrim(Posicione("SBM",1,xFilial("SBM") + TRB1->TF_GRUPO,"BM_DESC"))
		aArray[15] := AllTrim(Posicione("SZO",1,xFilial("SZO") + TRB1->TF_FAMILI,"ZO_DESCRI"))
		
		// Média
		For nx := 1 to Len(aColunas)
			aArray[nx+15] := Round((&("TRB1->TF_T"+aColunas[nx][1]) / &("TRB1->TF_Q"+aColunas[nx][1])),2)
		Next nx
		// Quantidade
		For nx := 1 to Len(aColunas)
			aArray[nx+15+Len(aColunas)] := &("TRB1->TF_Q"+aColunas[nx][1])
		Next nx
		// Valor Total
		For nx := 1 to Len(aColunas)
			aArray[nx+15+(Len(aColunas)*2)] := &("TRB1->TF_T"+aColunas[nx][1])
		Next nx
		// % Participação
		For nx := 1 to Len(aColunas)
			aArray[nx+15+(Len(aColunas)*3)] := &("TRB1->TF_P"+aColunas[nx][1])
		Next nx
		//
		oExcel:AddRow(cNomePlan, cNomeTable, aArray)
		//		
		DbSelectArea("TRB1")
		TRB1->(DbSkip())

	Enddo
	TRB1->(DbCloseArea())
	oTempTabl1:Delete()
	
	TRB2->(DbCloseArea())
	oTempTabl2:Delete()

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD2_AMNR05-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return
