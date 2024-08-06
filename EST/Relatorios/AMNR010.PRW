#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR010  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 01/05/2020      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de custo analítico x simulador.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR010()

Local cPerg := "AMNR10"
Private cPath := "c:\report\"
Private aColunas := {}
Private oTempTable,oTempTabl2,oTempTabl3,oTempTabl4

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
	If Select("TR2") > 0
		TR2->(DbCloseArea())
	Endif
	If Select("TR3") > 0
		TR3->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab10()()})
		Processa({|| pAmnR10()})
		Processa({|| pImpR10()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab10   ¦ Autor ¦ Fábrica ERPBR    ¦  Data  ¦ 01/05/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab10()

Local _aTmp := {}
Local _aTm2 := {}
Local _aTm3 := {}
Local _aTm4 := {}
Local zAlias := "TRB"
Local zAlia2 := "TR2"
Local zAlia3 := "TR3"
Local zAlia4 := "TR4"

oTempTable := FWTemporaryTable():New( zAlias )
AAdd ( _aTmp, {"TF_FILIAL" , "C", 004, 00} )
AAdd ( _aTmp, {"TF_COD"    , "C", 015, 00} )
AAdd ( _aTmp, {"TF_DESC"   , "C", 040, 00} )
AAdd ( _aTmp, {"TF_QUA1"   , "N", 017, 05} )
AAdd ( _aTmp, {"TF_CUS1"   , "N", 017, 06} )
AAdd ( _aTmp, {"TF_QUA2"   , "N", 017, 05} )
AAdd ( _aTmp, {"TF_CUS2"   , "N", 017, 06} )
AAdd ( _aTmp, {"TF_QUA3"   , "N", 017, 05} )
AAdd ( _aTmp, {"TF_CUS3"   , "N", 017, 06} )
AAdd ( _aTmp, {"TF_NIVEL"  , "C", 001, 00} )
AAdd ( _aTmp, {"TF_TIPO"   , "C", 002, 00} )
AAdd ( _aTmp, {"TF_UM"     , "C", 002, 00} )
AAdd ( _aTmp, {"TF_CLASS"  , "C", 003, 00} )
AAdd ( _aTmp, {"TF_PARTC"  , "N", 006, 02} )
AAdd ( _aTmp, {"TF_PAI"    , "C", 015, 00} )
AAdd ( _aTmp, {"TF_DPAI"   , "C", 040, 00} )
AAdd ( _aTmp, {"TF_ORDEM"  , "C", 002, 00} )
AAdd ( _aTmp, {"TF_OPPI"   , "C", 011, 00} )
oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_COD", "TF_PAI", "TF_NIVEL", "TF_OPPI"})
oTempTable:AddIndex("indice2", {"TF_FILIAL", "TF_PAI", "TF_ORDEM"})
oTempTable:Create()

oTempTabl2 := FWTemporaryTable():New( zAlia2 )
AAdd ( _aTm2, {"T2_FILIAL" , "C", 004, 00} )
AAdd ( _aTm2, {"T2_PAI"    , "C", 015, 00} )
AAdd ( _aTm2, {"T2_NIVEL"  , "C", 001, 00} )
AAdd ( _aTm2, {"T2_QTDTOT" , "N", 017, 05} )
AAdd ( _aTm2, {"T2_CUSTOT" , "N", 017, 06} )
oTemptabl2:SetFields( _aTm2 )
oTempTabl2:AddIndex("indice1", {"T2_FILIAL", "T2_PAI", "T2_NIVEL"})
oTempTabl2:Create()

oTempTabl3 := FWTemporaryTable():New( zAlia3 )
AAdd ( _aTm3, {"T3_FILIAL" , "C", 004, 00} )
AAdd ( _aTm3, {"T3_CODPI"  , "C", 015, 00} )
AAdd ( _aTm3, {"T3_PAI"    , "C", 015, 00} )
AAdd ( _aTm3, {"T3_NIVEL"  , "C", 001, 00} )
AAdd ( _aTm3, {"T3_ORDEM"  , "C", 002, 00} )
AAdd ( _aTm3, {"T3_QTDTOT" , "N", 017, 05} )
AAdd ( _aTm3, {"T3_CUSTOT" , "N", 017, 06} )
oTemptabl3:SetFields( _aTm3 )
oTempTabl3:AddIndex("indice1", {"T3_FILIAL", "T3_CODPI", "T3_PAI", "T3_NIVEL"})
oTempTabl3:Create()

oTempTabl4 := FWTemporaryTable():New( zAlia4 )
AAdd ( _aTm4, {"T4_FILIAL" , "C", 004, 00} )
AAdd ( _aTm4, {"T4_CODPI"  , "C", 015, 00} )
AAdd ( _aTm4, {"T4_PAI"    , "C", 015, 00} )
AAdd ( _aTm4, {"T4_NIVEL"  , "C", 001, 00} )
AAdd ( _aTm4, {"T4_ORDEM"  , "C", 002, 00} )
AAdd ( _aTm4, {"T4_QTDTOT" , "N", 017, 05} )
AAdd ( _aTm4, {"T4_CUSTOT" , "N", 017, 06} )
oTemptabl4:SetFields( _aTm4 )
oTempTabl4:AddIndex("indice1", {"T4_FILIAL", "T4_CODPI", "T4_PAI", "T4_NIVEL"})
oTempTabl4:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR10   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/05/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR10()

Local nRecSM0   := SM0->(Recno())
Local xFilOri   := cFilAnt
Local lSelFil   := (mv_par03 == 1)
Local aProdutos := {}
Local aFilsCalc := {}

MsgRun("Aguarde, selecionando produtos...","Processando",{|| SelProd(@aProdutos,@aFilsCalc,lSelFil) })
If Len(aFilsCalc) == 0
	MsgAlert("Nenhuma filial selecionada.")
	Return
Endif
MsgRun("Aguarde, carregando estruturas...","Processando",{|| CarEstr(@aProdutos) })
MsgRun("Aguarde, totalizando produções...","Processando",{|| ApontPr(aFilsCalc) })

DbSelectArea("TR3")
ProcRegua(RecCount())
TR3->(DbGotop())
While !Eof()
	
	IncProc("Rateio PI nível 3...")
	
	cFilAnt := TR3->T3_FILIAL
	cCodPai := TR3->T3_PAI
	cPrxNiv := AllTrim(STR(Val(TR3->T3_NIVEL)+1))
	
	// Última produção
	cQuery := " SELECT D3_OP "
	cQuery += " FROM "+RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL = '"+TR3->T3_FILIAL+"' " 
	cQuery += " AND D3_COD = '"+TR3->T3_CODPI+"' "
	cQuery += " AND D3_CF = 'PR0' "
	cQuery += " AND D3_ESTORNO = ' ' "
	cQuery += " AND D3_EMISSAO < '"+DtoS(GetMv("MV_ULMES"))+"' "
	cQuery += " AND D3_EMISSAO < '"+DtoS(mv_par01)+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY D3_EMISSAO DESC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

	DbSelectArea("SQL3")
	SQL3->(DbGotop())
	If !Eof()

		// Fator de produção
		cQuery := " SELECT D3_QUANT QUANT, D3_CUSTO1 CUSTO "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+TR3->T3_FILIAL+"' " 
		cQuery += " AND D3_OP = '"+SQL3->D3_OP+"' "
		cQuery += " AND D3_CF = 'PR0' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLP", .F., .T.)
		nFatorQ := (TR3->T3_QTDTOT / SQLP->QUANT)
		nFatorC := (TR3->T3_CUSTOT / SQLP->CUSTO)
		SQLP->(DbCloseArea())

		cQuery := " SELECT D3_FILIAL FILIAL, D3_COD CODEMP, SUM(D3_QUANT) QUANT, SUM(D3_CUSTO1) CUSTO "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+TR3->T3_FILIAL+"' " 
		cQuery += " AND D3_OP = '"+SQL3->D3_OP+"' "
		cQuery += " AND D3_CF <> 'PR0' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY D3_FILIAL, D3_COD "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL4", .F., .T.)

		DbSelectArea("SQL4")
		SQL4->(DbGotop())
		While !Eof()

			zQuant := Round((SQL4->QUANT * nFatorQ),5)
			zCusto := Round((SQL4->CUSTO * nFatorC),6)

			zClassif := ""
			zTipo    := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_TIPO")
			zGrupo   := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_GRUPO")
			zUM      := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_UM")
			zDescric := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_DESC")
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

			DbSelectArea("TRB")
			DbSetOrder(1)
			If !DbSeek( SQL4->FILIAL + SQL4->CODEMP + cCodPai + cPrxNiv + Space(11) ) 
				RecLock("TRB",.T.)
				TRB->TF_FILIAL := SQL4->FILIAL
				TRB->TF_COD    := SQL4->CODEMP
				TRB->TF_DESC   := zDescric
				TRB->TF_QUA1   := zQuant
				TRB->TF_CUS1   := zCusto	
				TRB->TF_QUA2   := zQuant / TR3->T3_QTDTOT
				TRB->TF_CUS2   := zCusto / TR3->T3_CUSTOT	
				TRB->TF_QUA3   := 0
				TRB->TF_CUS3   := 0	
				TRB->TF_NIVEL  := cPrxNiv
				TRB->TF_TIPO   := zTipo
				TRB->TF_UM     := zUM
				TRB->TF_CLASS  := zClassif
				TRB->TF_PARTC  := 0
				TRB->TF_PAI    := cCodPai
				TRB->TF_DPAI   := RetField("SB1",1,xFilial("SB1")+cCodPai,"B1_DESC")
				TRB->TF_ORDEM  := SOMA1(TR3->T3_ORDEM)
				TRB->TF_OPPI   := SQL3->D3_OP
				MsUnLock()
			Else
				RecLock("TRB",.F.)
				TRB->TF_QUA1 := zQuant
				TRB->TF_CUS1 := zCusto	
				TRB->TF_QUA2 := zQuant / TR3->T3_QTDTOT
				TRB->TF_CUS2 := zCusto / TR3->T3_CUSTOT
				TRB->TF_OPPI := SQL3->D3_OP
				MsUnLock()
			Endif

			If TRB->TF_CLASS == "PI " .And. TRB->TF_NIVEL <> "1"
				DbSelectArea("TR4")
				DbSetOrder(1)
				If !DbSeek( TRB->TF_FILIAL + TRB->TF_COD + TRB->TF_PAI + TRB->TF_NIVEL )
					RecLock("TR4",.T.)
					TR4->T4_FILIAL := TRB->TF_FILIAL
					TR4->T4_CODPI  := TRB->TF_COD
					TR4->T4_PAI    := TRB->TF_PAI
					TR4->T4_NIVEL  := TRB->TF_NIVEL
					TR4->T4_ORDEM  := TRB->TF_ORDEM
					TR4->T4_QTDTOT := TRB->TF_QUA1
					TR4->T4_CUSTOT := TRB->TF_CUS1
					MsUnLock()
				Endif	
			Endif 

			DbSelectArea("SQL4")
			SQL4->(DbSkip())
		Enddo
		SQL4->(DbCloseArea())

	Endif
	SQL3->(DbCloseArea())

	DbSelectArea("TR3")
	TR3->(DbSkip())
Enddo

DbSelectArea("TR4")
ProcRegua(RecCount())
TR4->(DbGotop())
While !Eof()
	
	IncProc("Rateio PI nível 4...")
	
	cFilAnt := TR4->T4_FILIAL
	cCodPai := TR4->T4_PAI
	cPrxNiv := AllTrim(STR(Val(TR4->T4_NIVEL)+1))
	
	// Última produção
	cQuery := " SELECT D3_OP "
	cQuery += " FROM "+RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL = '"+TR4->T4_FILIAL+"' " 
	cQuery += " AND D3_COD = '"+TR4->T4_CODPI+"' "
	cQuery += " AND D3_CF = 'PR0' "
	cQuery += " AND D3_ESTORNO = ' ' "
	cQuery += " AND D3_EMISSAO < '"+DtoS(GetMv("MV_ULMES"))+"' "
	cQuery += " AND D3_EMISSAO < '"+DtoS(mv_par01)+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY D3_EMISSAO DESC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

	DbSelectArea("SQL3")
	SQL3->(DbGotop())
	If !Eof()

		// Fator de produção
		cQuery := " SELECT D3_QUANT QUANT, D3_CUSTO1 CUSTO "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+TR4->T4_FILIAL+"' " 
		cQuery += " AND D3_OP = '"+SQL3->D3_OP+"' "
		cQuery += " AND D3_CF = 'PR0' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLP", .F., .T.)
		nFatorQ := (TR4->T4_QTDTOT / SQLP->QUANT)
		nFatorC := (TR4->T4_CUSTOT / SQLP->CUSTO)
		SQLP->(DbCloseArea())

		cQuery := " SELECT D3_FILIAL FILIAL, D3_COD CODEMP, SUM(D3_QUANT) QUANT, SUM(D3_CUSTO1) CUSTO "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+TR4->T4_FILIAL+"' " 
		cQuery += " AND D3_OP = '"+SQL3->D3_OP+"' "
		cQuery += " AND D3_CF <> 'PR0' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY D3_FILIAL, D3_COD "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL4", .F., .T.)

		DbSelectArea("SQL4")
		SQL4->(DbGotop())
		While !Eof()

			zQuant := Round((SQL4->QUANT * nFatorQ),5)
			zCusto := Round((SQL4->CUSTO * nFatorC),6)

			zClassif := ""
			zTipo    := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_TIPO")
			zGrupo   := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_GRUPO")
			zUM      := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_UM")
			zDescric := RetField("SB1",1,xFilial("SB1")+SQL4->CODEMP,"B1_DESC")
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

			DbSelectArea("TRB")
			DbSetOrder(1)
			If !DbSeek( SQL4->FILIAL + SQL4->CODEMP + cCodPai + cPrxNiv + Space(11) ) 
				RecLock("TRB",.T.)
				TRB->TF_FILIAL := SQL4->FILIAL
				TRB->TF_COD    := SQL4->CODEMP
				TRB->TF_DESC   := zDescric
				TRB->TF_QUA1   := zQuant
				TRB->TF_CUS1   := zCusto	
				TRB->TF_QUA2   := zQuant / TR4->T4_QTDTOT
				TRB->TF_CUS2   := zCusto / TR4->T4_CUSTOT	
				TRB->TF_QUA3   := 0
				TRB->TF_CUS3   := 0	
				TRB->TF_NIVEL  := cPrxNiv
				TRB->TF_TIPO   := zTipo
				TRB->TF_UM     := zUM
				TRB->TF_CLASS  := zClassif
				TRB->TF_PARTC  := 0
				TRB->TF_PAI    := cCodPai
				TRB->TF_DPAI   := RetField("SB1",1,xFilial("SB1")+cCodPai,"B1_DESC")
				TRB->TF_ORDEM  := SOMA1(TR4->T4_ORDEM)
				TRB->TF_OPPI   := SQL3->D3_OP
				MsUnLock()
			Else
				RecLock("TRB",.F.)
				TRB->TF_QUA1 := zQuant
				TRB->TF_CUS1 := zCusto	
				TRB->TF_QUA2 := zQuant / TR4->T4_QTDTOT
				TRB->TF_CUS2 := zCusto / TR4->T4_CUSTOT
				TRB->TF_OPPI := SQL3->D3_OP
				MsUnLock()
			Endif

			DbSelectArea("SQL4")
			SQL4->(DbSkip())
		Enddo
		SQL4->(DbCloseArea())

	Endif
	SQL3->(DbCloseArea())

	DbSelectArea("TR4")
	TR4->(DbSkip())
Enddo

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
While !Eof()
	
	IncProc("Calculando custo real...")
	
	RecLock("TRB",.F.)
	If TRB->TF_TIPO $ "PA,PI"
		TRB->TF_QUA2 := TRB->TF_QUA3 
	Else
		cNivAnt := AllTrim(STR(Val(TRB->TF_NIVEL)-1))
		DbSelectArea("TR2")
		DbSetOrder(1)
		If DbSeek( TRB->TF_FILIAL + TRB->TF_PAI + cNivAnt )
			TRB->TF_QUA2 := TRB->TF_QUA1 / TR2->T2_QTDTOT // Quantidade total do produto / Quantidade total do nível anterior
		Endif
	Endif
	//
	If TRB->TF_NIVEL == "1"
		TRB->TF_CUS2 := TRB->(TF_CUS1/TF_QUA1)
	Else
		cNivAnt := "1"
		DbSelectArea("TR2")
		DbSetOrder(1)
		If DbSeek( TRB->TF_FILIAL + TRB->TF_PAI + cNivAnt )
			TRB->TF_CUS2 := TRB->TF_CUS1 / TR2->T2_QTDTOT // Custo total do produto / Quantidade total do nível 1
		Endif
	Endif
	MsUnLock()
	
	DbSelectArea("TRB")
	TRB->(DbSkip())
Enddo

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SelProd   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Seleciona os produtos para processamento.		  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function SelProd(aProdutos,aFilsCalc,lSelFil)

Local nForFilial

aFilsCalc := MatFilCalc( lSelFil )
If Len(aFilsCalc) == 0
	Return
Endif
For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[nForFilial][1]

		cFilAnt := aFilsCalc[nForFilial][2]

		ProcRegua(2)
		IncProc("Selecionando registros...")
		cQuery := " SELECT DISTINCT D3_COD AS PROD "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
		cQuery += " AND D3_CF = 'PR0' "
		cQuery += " AND D3_COD <> 'MANUTENCAO' "
		cQuery += " AND D3_ESTORNO = ' ' "
		If !Empty(mv_par04)
			cQuery += " AND D3_OP = '"+mv_par04+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY D3_COD "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()

			lAdd := .F.
			If Len(aProdutos) == 0
				lAdd := .T.
			Else
				If aScan(aProdutos, {|x| x[1] == cFilAnt .And. x[2] == SQL->PROD}) == 0
					lAdd := .T.
				Endif
			Endif
			If lAdd
				AAdd(aProdutos,{cFilAnt,SQL->PROD})
			Endif

			DbSelectArea("SQL")
			SQL->(DbSkip())
		Enddo
		SQL->(DbCloseArea())

	Endif	

Next nForFilial

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CarEstr   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/05/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carrega estrutura dos produtos produzidos no período.  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function CarEstr(aProdutos)

Local aArray	:= {}
Local aArray1	:= {}
Local aPar		:= Array(20)
Local aParC010	:= Array(20)
//Local lFirstCb	:= .T.
//Local cCondFiltr:= ""
Local nReg
Local nI, nProd, _x

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

For nProd := 1 To Len(aProdutos)

	cFilAnt := aProdutos[nProd][1]
	cProdut := aProdutos[nProd][2]

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + cProdut )
	zPai  := SB1->B1_COD
	zDPai := SB1->B1_DESC

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
			zUM      := RetField("SB1",1,xFilial("SB1")+zProduto,"B1_UM")
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
			TRB->TF_FILIAL := cFilAnt
			TRB->TF_COD    := zProduto
			TRB->TF_DESC   := zDescric
			TRB->TF_QUA1   := 0
			TRB->TF_CUS1   := 0	
			TRB->TF_QUA2   := IIf(zTipo == "PA",1,0)
			TRB->TF_CUS2   := 0	
			TRB->TF_QUA3   := zQuant
			TRB->TF_CUS3   := zCusto	
			TRB->TF_NIVEL  := zNivel
			TRB->TF_TIPO   := zTipo
			TRB->TF_UM     := zUM
			TRB->TF_CLASS  := zClassif
			TRB->TF_PARTC  := zPartic
			TRB->TF_PAI    := zPai
			TRB->TF_DPAI   := zDPai
			TRB->TF_ORDEM  := zOrdem
			MsUnLock()
		Next _x
	Endif

Next nForFilial

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ApontPr   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/05/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Totaliza apontamentos de produção do período.  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ApontPr(aFilsCalc)

Local zFiliais := ""
Local nForFilial

Pergunte("AMNR10",.F.)

For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

// PA
cQuery := " SELECT D3_FILIAL FILIAL, D3_OP OP, '1PA 'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'PR' "
cQuery += " AND D3_COD <> 'MANUTENCAO' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
If !Empty(mv_par04)
	cQuery += " AND D3_OP = '"+mv_par04+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// PI (MP DE EMB OU SOL)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '1PI 'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
cQuery += " AND D3_TIPO = 'PI' "
If !Empty(mv_par04)
	cQuery += " AND D3_OP = '"+mv_par04+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MP (EMBALAGEM)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '2EMB'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
cQuery += " AND D3_TIPO = 'MP' AND D3_GRUPO IN('0003','0004') "
If !Empty(mv_par04)
	cQuery += " AND D3_OP = '"+mv_par04+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MP (SOLUÇÃO)
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '3SOL'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
cQuery += " AND D3_TIPO = 'MP' AND D3_GRUPO IN('0005','0006') "
If !Empty(mv_par04)
	cQuery += " AND D3_OP = '"+mv_par04+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MOD
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '4MOD'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO "
cQuery += " FROM "+RetSqlName("SD3")+" SD3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_COD = B1_COD "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
cQuery += " AND D3_TIPO = 'MO' "
cQuery += " AND SUBSTR(D3_OP,7,2) <> 'OS' "
cQuery += " AND SUBSTR(B1_DESC,1,3) <> 'CIF' "
If !Empty(mv_par04)
	cQuery += " AND D3_OP = '"+mv_par04+"' "
Endif
cQuery += " AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " UNION "
// MOI
cQuery += " SELECT D3_FILIAL FILIAL, D3_OP OP, '5MOI'AS CLASSIF, D3_COD PRODUTO, D3_TIPO TIPO, D3_GRUPO GRUPO, D3_UM UM, D3_QUANT QUANT, D3_CUSTO1 CUSTO "
cQuery += " FROM "+RetSqlName("SD3")+" SD3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE D3_FILIAL IN ("+zFiliais+") "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D3_COD = B1_COD "
cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_OP <> ' ' "
cQuery += " AND D3_TIPO = 'MO' "
cQuery += " AND SUBSTR(D3_OP,7,2) <> 'OS' "
cQuery += " AND SUBSTR(B1_DESC,1,3) = 'CIF' "
If !Empty(mv_par04)
	cQuery += " AND D3_OP = '"+mv_par04+"' "
Endif
cQuery += " AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, OP, CLASSIF "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
While !Eof()

	// Identifica o PA
	cPr0 := ""
	If SQL->CLASSIF == "1PA "
		cPr0 := SQL->PRODUTO
		lNivPI := .T.
		lNivMP := .T.
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

	zTipo    := SQL->TIPO
	zGrupo   := SQL->GRUPO
	zDescric := RetField("SB1",1,xFilial("SB1")+SQL->PRODUTO,"B1_DESC")
	zClassif := ""
	
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

	If SQL->CLASSIF == "1PA "
		zNivel := "1"
	ElseIf SQL->CLASSIF == "1PI "
		If lNivPI
			lNivPI := .F.
			zNivel := SOMA1(zNivel)
		Endif	
	Else
		If lNivMP
			lNivMP := .F.
			zNivel := SOMA1(zNivel)
		Endif	
	Endif
	
	DbSelectArea("TRB")
	DbSetOrder(1)
	If !DbSeek( SQL->FILIAL + SQL->PRODUTO + cPr0 ) 
		RecLock("TRB",.T.)
		TRB->TF_FILIAL := SQL->FILIAL
		TRB->TF_COD    := SQL->PRODUTO
		TRB->TF_DESC   := zDescric
		TRB->TF_QUA1   := SQL->QUANT
		TRB->TF_CUS1   := SQL->CUSTO	
		TRB->TF_QUA2   := 0
		TRB->TF_CUS2   := 0	
		TRB->TF_QUA3   := 0
		TRB->TF_CUS3   := 0	
		TRB->TF_NIVEL  := zNivel
		TRB->TF_TIPO   := SQL->TIPO
		TRB->TF_UM     := SQL->UM
		TRB->TF_CLASS  := zClassif
		TRB->TF_PARTC  := 0
		TRB->TF_PAI    := cPr0
		TRB->TF_DPAI   := RetField("SB1",1,xFilial("SB1")+cPr0,"B1_DESC")
		TRB->TF_ORDEM  := "0"+zNivel
		MsUnLock()
	Else
		RecLock("TRB",.F.)
		TRB->TF_QUA1 += SQL->QUANT
		TRB->TF_CUS1 += SQL->CUSTO	
		MsUnLock()
	Endif

	If SQL->CLASSIF == "1PA "
		DbSelectArea("TR2")
		DbSetOrder(1)
		If !DbSeek( TRB->TF_FILIAL + TRB->TF_PAI + TRB->TF_NIVEL )
			RecLock("TR2",.T.)
			TR2->T2_FILIAL := TRB->TF_FILIAL
			TR2->T2_PAI    := TRB->TF_PAI
			TR2->T2_NIVEL  := TRB->TF_NIVEL
		Else
			RecLock("TR2",.F.)
		Endif
		TR2->T2_QTDTOT += SQL->QUANT
		TR2->T2_CUSTOT += SQL->CUSTO
		MsUnLock()
	Endif 

	If SQL->CLASSIF == "1PI "
		DbSelectArea("TR3")
		DbSetOrder(1)
		If !DbSeek( TRB->TF_FILIAL + TRB->TF_COD + TRB->TF_PAI + TRB->TF_NIVEL )
			RecLock("TR3",.T.)
			TR3->T3_FILIAL := TRB->TF_FILIAL
			TR3->T3_CODPI  := TRB->TF_COD
			TR3->T3_PAI    := TRB->TF_PAI
			TR3->T3_NIVEL  := TRB->TF_NIVEL
			TR3->T3_ORDEM  := TRB->TF_ORDEM
		Else
			RecLock("TR3",.F.)
		Endif
		TR3->T3_QTDTOT += SQL->QUANT
		TR3->T3_CUSTOT += SQL->CUSTO
		MsUnLock()
	Endif 

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pImpR10   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/05/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR10()

Local oExcel := FWMsExcelEx():New()

DbSelectArea("TRB")
DbSetOrder(2)
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "CUSTO_SIMULADOR"
	cNomeTable := "Custo Analítico x Simulador"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde Visão Total",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Visão Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde Visão Unitária",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Visão Unitária",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Unit Real",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde Visão Standard",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Visão Standard",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Unit Standard",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nível",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unidade",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Classificação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"%Participação",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Pai",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Pai",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Op.PI",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

        aArray := Array(22)
		aArray[1]  := TRB->TF_FILIAL
		aArray[2]  := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
		aArray[3]  := TRB->TF_COD
		aArray[4]  := TRB->TF_DESC
		aArray[5]  := TRB->TF_QUA1
		aArray[6]  := TRB->TF_CUS1
		aArray[7]  := TRB->TF_QUA2
		aArray[8]  := TRB->TF_CUS2
		aArray[9]  := TRB->(TF_CUS2 / TF_QUA2)
		aArray[10] := TRB->TF_QUA3
		aArray[11] := TRB->TF_CUS3
		aArray[12] := TRB->(TF_CUS3 / TF_QUA3)
		aArray[13] := TRB->TF_NIVEL
		aArray[14] := TRB->TF_COD
		aArray[15] := TRB->TF_DESC
		aArray[16] := TRB->TF_TIPO
		aArray[17] := TRB->TF_UM
		aArray[18] := TRB->TF_CLASS
		aArray[19] := TRB->TF_PARTC
		aArray[20] := TRB->TF_PAI
		aArray[21] := TRB->TF_DPAI
		aArray[22] := TRB->TF_OPPI
		
		oExcel:AddRow(cNomePlan, cNomeTable, aArray)

		DbSelectArea("TRB")
		TRB->(DbSkip())

	Enddo
	TRB->(DbCloseArea())
	TR2->(DbCloseArea())
	TR3->(DbCloseArea())
	TR4->(DbCloseArea())
	oTempTable:Delete()
	oTempTabl2:Delete()
	oTempTabl3:Delete()
	oTempTabl4:Delete()

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "CUSTO_SIMULADOR-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return
