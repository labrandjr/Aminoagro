#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR003  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/02/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Composição de Custo.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR003()

Local cPerg := "AMNR03"
Private cPath := "c:\report\"
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab03()()})
		Processa({|| pAmnR03()})
		Processa({|| pImpR03()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab03   ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 15/02/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab03()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_PRODUTO" , "C", 015, 00} )
AAdd ( _aTmp, {"TF_DESCRI"  , "C", 040, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 002, 00} )
AAdd ( _aTmp, {"TF_GRUPO"   , "C", 004, 00} )
AAdd ( _aTmp, {"TF_FAMILI"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_QUANTT"  , "N", 017, 05} )
AAdd ( _aTmp, {"TF_UM"      , "C", 002, 00} )
AAdd ( _aTmp, {"TF_CUSTOT"  , "N", 017, 02} )
AAdd ( _aTmp, {"TF_CUSEMB"  , "N", 017, 02} )
AAdd ( _aTmp, {"TF_PEREMB"  , "N", 006, 02} )
AAdd ( _aTmp, {"TF_CUSSOL"  , "N", 017, 02} )
AAdd ( _aTmp, {"TF_PERSOL"  , "N", 006, 02} )
AAdd ( _aTmp, {"TF_CUSMOD"  , "N", 017, 02} )
AAdd ( _aTmp, {"TF_PERMOD"  , "N", 006, 02} )
AAdd ( _aTmp, {"TF_CUSMOI"  , "N", 017, 02} )
AAdd ( _aTmp, {"TF_PERMOI"  , "N", 006, 02} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_PRODUTO"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR03   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 14/02/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR03()

Local aDados := {}
Local nTotal := 0
Local cQuery, nx
Local zFiliais := ""
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
cQuery := " SELECT COUNT(*)AS SOMA FROM "
cQuery += " ( "
// PA
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '1PA 'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'PR' "
cQuery += " AND D3_COD <> 'MANUTENCAO' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// PI (MP DE EMB OU SOL)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '1PI 'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_TIPO = 'PI' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MP (EMBALAGEM)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '2EMB'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_TIPO = 'MP' AND D3_GRUPO IN('0003','0004') "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MP (SOLUÇÃO)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '3SOL'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_TIPO = 'MP' AND D3_GRUPO IN('0005','0006') "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MOD
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '4MOD'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")+" SD3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_COD = B1_COD "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_TIPO = 'MO' "
cQuery += " AND SUBSTR(D3_OP,7,2) <> 'OS' "
cQuery += " AND SUBSTR(B1_DESC,1,3) <> 'CIF' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MOI
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '5MOI'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")+" SD3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_COD = B1_COD "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D3_TIPO = 'MO' "
cQuery += " AND SUBSTR(D3_OP,7,2) <> 'OS' "
cQuery += " AND SUBSTR(B1_DESC,1,3) = 'CIF' "
cQuery += " AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ) "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
// PA
cQuery := " SELECT D3_FILIAL FILIAL, D3_OP OP, '1PA 'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'PR' "
cQuery += " AND D3_COD <> 'MANUTENCAO' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// PI (MP DE EMB OU SOL)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '1PI 'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D3_TIPO = 'PI' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MP (EMBALAGEM)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '2EMB'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D3_TIPO = 'MP' AND D3_GRUPO IN('0003','0004') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MP (SOLUÇÃO)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '3SOL'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D3_TIPO = 'MP' AND D3_GRUPO IN('0005','0006') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MOD
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '4MOD'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")+" SD3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_COD = B1_COD "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D3_TIPO = 'MO' "
cQuery += " AND SUBSTR(D3_OP,7,2) <> 'OS' "
cQuery += " AND SUBSTR(B1_DESC,1,3) <> 'CIF' "
cQuery += " AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MOI
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '5MOI'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO, D3_EMISSAO EMISSAO, D3_SEQCALC SEQCALC "
cQuery += " FROM "+RetSqlName("SD3")+" SD3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_COD = B1_COD "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par07)
	cQuery += " AND D3_OP = '"+mv_par07+"' "
Endif
cQuery += " AND D3_TIPO = 'MO' "
cQuery += " AND SUBSTR(D3_OP,7,2) <> 'OS' "
cQuery += " AND SUBSTR(B1_DESC,1,3) = 'CIF' "
cQuery += " AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, OP, CLASSIF "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	While !Eof()

		IncProc("Calculando custos de produção...")

		// Identifica o PA
		cPr0 := ""
		If SQL->CLASSIF == "1PA "
			cPr0 := SQL->PRODUTO
		Else
			DbSelectArea("SD3")
			DbSetOrder(1)
			If DbSeek( SQL->FILIAL + SQL->OP )
				While !Eof() .And. SD3->D3_FILIAL == SQL->FILIAL .And. SD3->D3_OP == SQL->OP
					If SD3->D3_CF == "PR0"
						cPr0 := SD3->D3_COD
						Exit
					Endif
					SD3->(DbSkip())
				Enddo
			Endif
		Endif	

		If AllTrim(cPr0) == "000736"
			cDebug := ""
		Endif

		If !Empty(cPr0)

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + cPr0 )

			// TIPO: Considera no filtro do relatório PA e PI
			If SB1->B1_TIPO < mv_par03 .Or. SB1->B1_TIPO > mv_par04
				DbSelectArea("SQL")
				SQL->(DbSkip())
				Loop
			Endif

			// GRUPO: Considera no filtro do relatório PA e PI
			If SB1->B1_GRUPO < mv_par05 .Or. SB1->B1_GRUPO > mv_par06
				DbSelectArea("SQL")
				SQL->(DbSkip())
				Loop
			Endif

			DbSelectArea("TRB")
			DbSetOrder(1)
			If !DbSeek( SQL->FILIAL + cPr0 )
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := SQL->FILIAL
				TRB->TF_PRODUTO := cPr0
				TRB->TF_DESCRI  := SB1->B1_DESC
				TRB->TF_TIPO    := SB1->B1_TIPO
				TRB->TF_GRUPO   := SB1->B1_GRUPO
				TRB->TF_FAMILI  := SB1->B1_ZFAMILI
				TRB->TF_UM      := SB1->B1_UM
			Else
				RecLock("TRB",.F.)
			Endif

			If SQL->CLASSIF == "1PA "
				TRB->TF_QUANTT += SQL->QUANT
				TRB->TF_CUSTOT += SQL->CUSTO
			ElseIf SQL->CLASSIF == "1PI "
				//
				nCusEmb := 0
				nCusSol := 0
				nCusMod := 0
				nCusMoi := 0
				// Neste caso apenas rateia o custo da produção, uma vez que não consigo compor o custo do PI requisitado para a OP.
				DbSelectArea("SZE")
				DbSetOrder(1)
				If DbSeek( SQL->FILIAL + SQL->PRODUTO + Substr(SQL->EMISSAO,1,6) )
					// Rateia o valor da requisição do PI conforme Composição de Custo do PI.
					nCusEmb := (SQL->CUSTO * (SZE->ZE_PEREMB/100))
					nCusSol := (SQL->CUSTO * (SZE->ZE_PERSOL/100))
					nCusMod := (SQL->CUSTO * (SZE->ZE_PERMOD/100))
					nCusMoi := (SQL->CUSTO * (SZE->ZE_PERMOI/100))
				Else
					// Rateia o valor da requisição do PI conforme Formação de Preços.
					DbSelectArea("SZA")
					DbSetOrder(1)
					If DbSeek( SQL->FILIAL + SQL->PRODUTO )
						nCusEmb := (SQL->CUSTO * (SZA->ZA_PEREMB/100))
						nCusSol := (SQL->CUSTO * (SZA->ZA_PERSOL/100))
						nCusMod := (SQL->CUSTO * (SZA->ZA_PERMOD/100))
						nCusMoi := (SQL->CUSTO * (SZA->ZA_PERMOI/100))
					Else
						nCusSol := SQL->CUSTO // Caso o produto não for submetido ao Calculo da Formação de Preços, atribui 100% para Solução.
					Endif
				Endif	
				//
				If nCusEmb > 0
					TRB->TF_CUSEMB += nCusEmb
				Endif
				If nCusSol > 0
					TRB->TF_CUSSOL += nCusSol
				Endif
				If nCusMod > 0
					TRB->TF_CUSMOD += nCusMod
				Endif
				If nCusMoi > 0
					TRB->TF_CUSMOI += nCusMoi
				Endif
				//
			ElseIf SQL->CLASSIF == "2EMB"
				TRB->TF_CUSEMB += SQL->CUSTO
			ElseIf SQL->CLASSIF == "3SOL"
				TRB->TF_CUSSOL += SQL->CUSTO
			ElseIf SQL->CLASSIF == "4MOD"
				TRB->TF_CUSMOD += SQL->CUSTO
			ElseIf SQL->CLASSIF == "5MOI"
				TRB->TF_CUSMOI += SQL->CUSTO
			Endif
			MsUnLock()
			
		Endif	

		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())

// Calcula os percentuais
DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
While !Eof()

	IncProc("Gerando planilha...")

	If AllTrim(cPr0) == "000736"
		cDebug := ""
	Endif

	RecLock("TRB",.F.)
	TRB->TF_PEREMB := ((TRB->TF_CUSEMB / TRB->TF_CUSTOT) * 100)
	TRB->TF_PERSOL := ((TRB->TF_CUSSOL / TRB->TF_CUSTOT) * 100)
	TRB->TF_PERMOD := ((TRB->TF_CUSMOD / TRB->TF_CUSTOT) * 100)
	TRB->TF_PERMOI := ((TRB->TF_CUSMOI / TRB->TF_CUSTOT) * 100)
	MsUnLock()

	TRB->(DbSkip())
Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pImpR03   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 14/02/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR03()

Local oExcel := FwMsExcel():New()

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SD3_AMNR03"
	cNomeTable := "Composição de Custos - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Família",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UM",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde. Total",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Embalagem",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% Embalagem",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Solução",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% Solução",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"MOD",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% MOD",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"MOI",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% MOI",3,2)

	While !Eof()

		IncProc("Gerando planilha...")

		zLocal   := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
		zFamilia := Posicione("SZO",1,xFilial("SZO")+TRB->TF_FAMILI,"ZO_DESCRI") 	

		oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, TRB->TF_FILIAL, TRB->TF_PRODUTO, TRB->TF_DESCRI, TRB->TF_TIPO, TRB->TF_GRUPO, zFamilia,;
											  TRB->TF_UM, TRB->TF_QUANTT, TRB->TF_CUSTOT, TRB->TF_CUSEMB, TRB->TF_PEREMB, TRB->TF_CUSSOL, TRB->TF_PERSOL,;
											  TRB->TF_CUSMOD, TRB->TF_PERMOD, TRB->TF_CUSMOI, TRB->TF_PERMOI })
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD3_AMNR03-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif
TRB->(DbCloseArea())
oTempTable:Delete()

Return
