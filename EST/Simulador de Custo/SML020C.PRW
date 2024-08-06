#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SML020C  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 01/11/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Visão Analítica - Simulador de Custos.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SML020C()

Local cPerg := "SML020C"
Private cPath := "c:\report\"
Private aColunas := {}
Private oTempTable

If !(__cUserId $ ( AllTrim(GetMv("MV_XGEREST")) )) // Administrador, Jefferson Costa, Paul Bergman
	MsgAlert("Usuário não autorizado. Contate o Administrador.")
	Return
Endif

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab20()()})
		Processa({|| pAmnR20()})
		Processa({|| pImpR20()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab20   ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 01/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab20()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_PAI"     , "C", 015, 00} )
AAdd ( _aTmp, {"TF_DPAI"    , "C", 040, 00} )
AAdd ( _aTmp, {"TF_ORDEM"   , "C", 002, 00} )
AAdd ( _aTmp, {"TF_NIVEL"   , "C", 001, 00} )
AAdd ( _aTmp, {"TF_PRODUTO" , "C", 015, 00} )
AAdd ( _aTmp, {"TF_DESCRI"  , "C", 040, 00} )
AAdd ( _aTmp, {"TF_UM"      , "C", 002, 00} )
AAdd ( _aTmp, {"TF_QUANT"   , "N", 017, 05} )
AAdd ( _aTmp, {"TF_CUSTO"   , "N", 017, 06} )
AAdd ( _aTmp, {"TF_CLASSIF" , "C", 003, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 002, 00} )
AAdd ( _aTmp, {"TF_PARTIC"  , "N", 006, 02} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_PAI", "TF_ORDEM"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR20   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR20()

Local nRecSM0   := SM0->(Recno())
Local xFilOri   := cFilAnt
Local aArray	:= {}
Local aArray1	:= {}
Local aPar		:= Array(20)
Local aParC010	:= Array(20)
Local lFirstCb	:= .T.
Local nReg
Local nI, nX
Local cCondFiltr:= ""
Local cProdDe := mv_par01
Local cProdAt := mv_par02
Local lSelFil := (mv_par03 == 1)
Local nForFilial
Local aFilsCalc
Local _x

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privadas exclusivas deste programa                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cProg := "R430"  // Usada na funcao externa MontStru()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Custo a ser considerado nos calculos                           ³
//³ 1 = STANDARD    2 = MEDIO     3 = MOEDA2     4 = MOEDA3        ³
//³ 5 = MOEDA4      6 = MOEDA5    7 = ULTPRECO   8 = PLANILHA      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nQualCusto := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vetor declarado para inversao do calculo do Valor Unitario   ³
//³ Utilizado no MATC010X -> M010Forma e CalcTot                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aAuxCusto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nome do arquivo que contem a memoria de calculo desta planilha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cArqMemo := "AMINOAGR"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Direcao do calculo .T. para baixo .F. para cima                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lDirecao := .T.

Private lConsNeg := .T. //(mv_par08 = 1)     // Esta variavel sera' usada na funcao MC010FORMA

Pergunte("MTR430",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Produto inicial                              ³
//³ mv_par02     // Produto final                                ³
//³ mv_par03     // Nome da planilha utilizada                   ³
//³ mv_par04     // Imprime estrutura : Sim / Nao                ³
//³ mv_par05     // Moeda Secundaria  : 1 2 3 4 5                ³
//³ mv_par06     // Nivel de detalhamento da estrutura           ³
//³ mv_par07     // Qual a Quantidade Basica                     ³
//³ mv_par08     // Considera Qtde Neg na estrutura: Sim/Nao     ³
//³ mv_par09     // Considera Estrutura / Pre Estrutura          ³
//³ mv_par10     // Revisao da Estrutura 				         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca utilizacao da estrutura caso nao tenha SGG               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SGG") == 0
	mv_par09 := 1
Endif
//Salvar variaveis existentes
For ni := 1 to 20
	aPar[ni] := &("mv_par"+StrZero(ni,2))
Next ni

Pergunte("MTC010",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca utilizacao da estrutura caso nao tenha SGG               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SGG") == 0
	mv_par09 := 1
Endif
//Salvar variaveis existentes
For ni := 1 to 20
	aParC010[ni] := &("mv_par"+StrZero(ni,2))
Next ni
//Forca mesmo valor do relatorio na pergunta 09
mv_par09     := aPar[09]
aParC010[09] := aPar[09]

// Restaura parametros MTR430
For ni := 1 to 20
	&("mv_par"+StrZero(ni,2)) := aPar[ni]
Next ni

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o nome padrao da planilha com o nome selecionado pelo usuario ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqMemo := "AMINOAGR"

aFilsCalc := MatFilCalc( lSelFil )
For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[nForFilial][1]

		cFilAnt := aFilsCalc[nForFilial][2]

		ProcRegua(2)
		IncProc("Selecionando registros...")
		cQuery := " SELECT COUNT(DISTINCT G1_COD)AS SOMA "
		cQuery += " FROM "+RetSqlName("SG1")+" SG1, "
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE G1_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND G1_COD = B1_COD "
		cQuery += " AND G1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAt+"' "
		cQuery += " AND SG1.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nTotSql := SQL->SOMA
		SQL->(DbCloseArea())
		
		IncProc("Selecionando registros...")
		cQuery := " SELECT DISTINCT G1_FILIAL, G1_COD, B1_DESC, B1_UM "
		cQuery += " FROM "+RetSqlName("SG1")+" SG1, "
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE G1_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND G1_COD = B1_COD "
		cQuery += " AND G1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAt+"' "
		cQuery += " AND SG1.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY G1_FILIAL, G1_COD "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
		DbSelectArea("SQL")
		ProcRegua(nTotSql)
		SQL->(DbGotop())
		While !Eof()
	
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + SQL->G1_COD )
			zPai  := SB1->B1_COD
			zDPai := SB1->B1_DESC

			IncProc("Simulando custo: "+cFilAnt+"-"+AllTrim(SB1->B1_COD))

			DbSelectArea("SBZ")
			DbSetOrder(1)
			If !DbSeek( cFilAnt + SB1->B1_COD )
		
				aCab := {}
		        lMsErroAuto := .F.
		        
		        AAdd(aCab,{"BZ_COD"     , SB1->B1_COD   , Nil})
		        AAdd(aCab,{"BZ_LOCPAD"  , SB1->B1_LOCPAD, Nil})
		        AAdd(aCab,{"BZ_ZZDESC"  , SB1->B1_DESC  , Nil})
		        AAdd(aCab,{"BZ_QB"      , SB1->B1_QB    , Nil})
		
		        MsExecAuto({|v,x| MATA018(v,x)},aCab,3)
		        If !lMsErroAuto
		            ConOut("Sucesso na atualização de indicadores: "+cFilAnt+"-"+SB1->B1_COD)
		        Else
		            ConOut("Erro na atualização de indicadores: "+cFilAnt+"-"+SB1->B1_COD)
			        //MostraErro()
		        Endif
		
			Endif

			// Restaura parametros MTC010
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aParc010[ni]
			Next ni
			
			aArray1 := MC010Forma("SB1",nReg,99,1/*apar[07]*/,,.F.,apar[10])
						
			// Restaura parametros MTR430
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aPar[ni]
			Next ni

			If Len(aArray1) > 0
				aArray := aClone(aArray1[2])
				For _x := 1 to Len(aArray)
					If Substr(aArray[_x][2],1,3) == "---"
						Loop
					Endif
					zOrdem   := StrZero(aArray[_x][1],2)
					zNivel   := AllTrim(aArray[_x][2])
					zProduto := aArray[_x][4]
					zDescric := aArray[_x][3]
					zQuant   := aArray[_x][5]
					zCusto   := aArray[_x][6]
					zPartic  := Round(aArray[_x][7],2)
					zClassif := ""
					zTipo    := RetField("SB1",1,xFilial("SB1")+zProduto,"B1_TIPO")
					zGrupo   := RetField("SB1",1,xFilial("SB1")+zProduto,"B1_GRUPO")
					If zTipo == "PA"
						zClassif := "PA"
					ElseIf zTipo == "PI"
						zClassif := "PI"	
					ElseIf zTipo == "MP" .And. zGrupo $("0003,0004")
						zClassif := "EMB"
					ElseIf zTipo == "MP" .And. zGrupo $("0005,0006")
						zClassif := "SOL"
					ElseIf zTipo == "MO" .And. Substr(zDescric,1,3) != "CIF"
						zClassif := "MOD"
					ElseIf zTipo == "MO" .And. Substr(zDescric,1,3) == "CIF"
						zClassif := "MOI"
					Endif					
					//
					DbSelectArea("TRB")
					RecLock("TRB",.T.)
					TRB->TF_FILIAL  := cFilAnt
					TRB->TF_PAI     := zPai
					TRB->TF_DPAI    := zDPai
					TRB->TF_ORDEM   := zOrdem
					TRB->TF_NIVEL   := zNivel
					TRB->TF_PRODUTO := zProduto
					TRB->TF_DESCRI  := zDescric
					TRB->TF_UM      := RetField("SB1",1,xFilial("SB1")+zProduto,"B1_UM")
					TRB->TF_QUANT   := zQuant
					TRB->TF_CUSTO   := zCusto
					TRB->TF_CLASSIF := zClassif
					TRB->TF_TIPO    := zTipo
					TRB->TF_PARTIC  := zPartic
					MsUnLock()
				Next _x
			Endif
			DbSelectArea("SQL")
			SQL->(DbSkip())
		Enddo
		SQL->(DbCloseArea())

	Endif	

Next nForFilial

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pImpR20   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR20()

Local oExcel := FwMsExcel():New()
Local aDados := {}
Local nTotal := 0
Local cQuery, nx

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "ZZB_ANALITICO"
	cNomeTable := "Simulador de Custos - Visão Analítica"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nível",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unidade",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Classificação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	If mv_par04 == 1
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Participação",3,2)
	Endif	
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Pai",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Pai",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

        aArray := Array(IIf(mv_par04==1,13,12))
		aArray[1]  := TRB->TF_FILIAL
		aArray[2]  := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
		aArray[3]  := TRB->TF_NIVEL
		aArray[4]  := TRB->TF_PRODUTO
		aArray[5]  := TRB->TF_DESCRI
		aArray[6]  := TRB->TF_UM
		aArray[7]  := TRB->TF_QUANT
		aArray[8]  := TRB->TF_CUSTO
		aArray[9]  := TRB->TF_CLASSIF
		aArray[10] := TRB->TF_TIPO
		If mv_par04 == 1
			aArray[11] := TRB->TF_PARTIC
			aArray[12] := TRB->TF_PAI
			aArray[13] := TRB->TF_DPAI
		Else
			aArray[11] := TRB->TF_PAI
			aArray[12] := TRB->TF_DPAI
		Endif	
		//
		oExcel:AddRow(cNomePlan, cNomeTable, aArray)
		//		
		DbSelectArea("TRB")
		TRB->(DbSkip())

	Enddo
	TRB->(DbCloseArea())
	oTempTable:Delete()

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "ZZB_ANALITICO-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return
