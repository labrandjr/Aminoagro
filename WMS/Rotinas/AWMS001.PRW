#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AWMS001   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 16/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento para carga de dados no SIGAWMS.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AWMS001()

Local cPerg	:= Padr("AWMS001",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private lOkFile  := .F.
Private lInteWms := GetMv("MV_INTWMS")
Private cEOL     := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Carga de Dados - Sequência de Abastecimento" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,050,{||"CADASTRO AUTOMÁTICO DA SEQUÊNCIA DE ABASTECIMENTO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo cadastrar as informações necessárias no Módulo SIGAWMS"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"para que os endereçamentos possam ser realizados. Os cadastros inseridos/alterados são:"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"Produtos, Complemento de Produtos e Sequência de Abastecimento."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  16/05/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If !lInteWms
	MsgInfo("Módulo WMS não habilitado nesta Filial.")
	Return
Endif

If MsgYesNo("Confirma o processamento - SEQUÊNCIA DE ABASTECIMENTO ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Cadastrando informações no SigaWms...", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  16/05/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nTotSql := 0
Local lProcOk := .F.
Local _x

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
If !Empty(mv_par01)
	cQuery += " AND B1_COD = '"+mv_par01+"' "
Endif	
If mv_par02 == 1
	cQuery += " AND B1_TIPO = 'PA' "
ElseIf mv_par02 == 2
	cQuery += " AND B1_TIPO = 'MP' "
Else
	cQuery += " AND B1_TIPO IN('PA','MP') "
Endif
cQuery += " AND B1_MSBLQL <> '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
If !Empty(mv_par01)
	cQuery += " AND B1_COD = '"+mv_par01+"' "
Endif	
If mv_par02 == 1
	cQuery += " AND B1_TIPO = 'PA' "
ElseIf mv_par02 == 2
	cQuery += " AND B1_TIPO = 'MP' "
Else
	cQuery += " AND B1_TIPO IN('PA','MP') "
Endif
cQuery += " AND B1_MSBLQL <> '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY B1_FILIAL, B1_COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
oProcess:SetRegua1(nTotSql)
	
DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()
	
	oProcess:IncRegua1("Atualizando dados cadastrais SigaWms...")
	lProcOk := .T.

	DbSelectArea("SB1")
	SB1->(DbGoto(SQL1->R_E_C_N_O_))	
	lEstrut := .F.

	// 1. Cadastro de Produtos
	If SB1->B1_TIPO == "PA"
		DbSelectArea("SG1")
		DbSetOrder(1)
		If DbSeek( xFilial("SG1") + SB1->B1_COD )
			lEstrut := .T.
			If Empty(SB1->B1_SEGUM)
				DbSelectArea("SBZ")
				DbSetOrder(1)
				If DbSeek( xFilial("SBZ") + SB1->B1_COD )
					If SBZ->BZ_QB > 0
						If SBZ->BZ_QB == 1
							cSegum := "FR"
						ElseIf SBZ->BZ_QB == 1000
							cSegum := "CT"
						Else
							cSegum := "BB"
						Endif
						RecLock("SB1",.F.)
						SB1->B1_SEGUM   := cSegum
						SB1->B1_CONV    := SBZ->BZ_QB
						SB1->B1_TIPCONV := "D"
						MsUnLock()
					Endif
				Endif
			Endif
		Endif
	Endif

	// 2. Complemento de Produtos
	DbSelectArea("SB5")
	DbSetOrder(1)
	If !DbSeek( xFilial("SB5") + SB1->B1_COD )
		RecLock("SB5",.T.)
		SB5->B5_FILIAL := xFilial("SB5")
		SB5->B5_COD    := SB1->B1_COD
		SB5->B5_CEME   := SB1->B1_DESC
	Else
		RecLock("SB5",.F.)	
	Endif
	SB5->B5_CARPER  := "2"
	SB5->B5_ROTACAO := "2"
	SB5->B5_CODZON  := IIf(SB1->B1_TIPO=="PA","000001","000002")
	SB5->B5_UMIND   := IIf(SB1->B1_TIPO=="PA","2","1")
	SB5->B5_INTDI   := "2"
	SB5->B5_PORTMS  := "2"
	SB5->B5_NPULMAO := "1"
	SB5->B5_TIPUNIT := "1"
	SB5->B5_QTDVAR  := "2"
	SB5->B5_IMPETI  := "1"
	SB5->B5_VLDOPER := "1"
	SB5->B5_REVPROD := "2"
	SB5->B5_TPSERV  := "1"
	SB5->B5_WMSEMB  := "2"
	SB5->B5_SEMENTE := "2"
	SB5->B5_FORMMRP := "1"
	SB5->B5_BLQINVA := "2"
	SB5->B5_AGLUMRP := "1"
	SB5->B5_MONTA   := "2"
	SB5->B5_TPISERV := "5"
	SB5->B5_ECFLAG  := "2"
	SB5->B5_CTRWMS  := "2"
	SB5->B5_TIPO    := "1"
	SB5->B5_DEC7174 := "2"
	SB5->B5_ISIDUNI := "1"
	SB5->B5_INSSPAT := "2"
	SB5->B5_ISDSHIP := "0"
	SB5->B5_VLZERO  := "2"
	SB5->B5_ECDESF  := "1"
	SB5->B5_COMPEND := "1"
	MsUnLock()

	// 3. Sequência de Abastecimento
	aEstrFis := {}
	If SB1->B1_TIPO == "PA" .And. lEstrut

		// Armazém de Produção = 03 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "03"
			AAdd(aEstrFis,{"03","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Armazém de Devolução de Venda = 05 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "05"
			AAdd(aEstrFis,{"05","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Armazém de Endereçamento = 04 (Picking)
		If Empty(mv_par03) .Or. mv_par03 == "04"
			AAdd(aEstrFis,{"04","400009","01",IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002",IIf(SB1->B1_CONV==1000,"000005","000003")))}) // Nível 00
			zOrd := SOMA1("01")
			If SB1->B1_CONV != 1000
				// Galpão 04
				AAdd(aEstrFis,{"04","400010",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 01
				zOrd := SOMA1(zOrd)
				AAdd(aEstrFis,{"04","400011",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 02
				zOrd := SOMA1(zOrd)
				// Galpão 09	
				AAdd(aEstrFis,{"04","900009",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002",IIf(SB1->B1_CONV==1000,"000005","000003")))}) // Nível 00
				zOrd := SOMA1("01")
				AAdd(aEstrFis,{"04","900010",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 01
				zOrd := SOMA1(zOrd)
				AAdd(aEstrFis,{"04","900011",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 02
				zOrd := SOMA1(zOrd)
				AAdd(aEstrFis,{"04","900012",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 03
				zOrd := SOMA1(zOrd)
				AAdd(aEstrFis,{"04","900013",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 04
				zOrd := SOMA1(zOrd)
			Endif
			If SB1->B1_CONV == 5
				AAdd(aEstrFis,{"04","900008",zOrd,"000002"}) // Picking 5L
				zOrd := SOMA1(zOrd)
			Endif
			AAdd(aEstrFis,{"04","400002",zOrd,"000004"})
			zOrd := SOMA1(zOrd)
			AAdd(aEstrFis,{"04","900002",zOrd,"000004"})
		Endif	
/*
		// Armazém de Endereçamento = 04 (Picking)
		AAdd(aEstrFis,{"04","000009","01",IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002",IIf(SB1->B1_CONV==1000,"000005","000003")))}) // Nível 00
		zOrd := SOMA1("01")
		If SB1->B1_CONV != 1000
			AAdd(aEstrFis,{"04","000010",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 01
			zOrd := SOMA1(zOrd)
			AAdd(aEstrFis,{"04","000011",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 02
			zOrd := SOMA1(zOrd)
		Endif
		AAdd(aEstrFis,{"04","000002",zOrd,"000004"})

		// Armazém de Endereçamento = 09 (Picking)
		AAdd(aEstrFis,{"09","000009","01",IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002",IIf(SB1->B1_CONV==1000,"000005","000003")))}) // Nível 00
		zOrd := SOMA1("01")
		If SB1->B1_CONV != 1000
			AAdd(aEstrFis,{"09","000010",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 01
			zOrd := SOMA1(zOrd)
			AAdd(aEstrFis,{"09","000011",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 02
			zOrd := SOMA1(zOrd)
			AAdd(aEstrFis,{"09","000012",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 03
			zOrd := SOMA1(zOrd)
			AAdd(aEstrFis,{"09","000013",zOrd,IIf(SB1->B1_CONV==20,"000001",IIf(SB1->B1_CONV==5,"000002","000003"))}) // Nível 04
			zOrd := SOMA1(zOrd)
		Endif	
		If SB1->B1_CONV == 5
			AAdd(aEstrFis,{"09","000008",zOrd,"000002"}) // Picking 5L
			zOrd := SOMA1(zOrd)
		Endif
		AAdd(aEstrFis,{"09","000002",zOrd,"000004"})
*/
		// Descarte = 06 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "06"
			AAdd(aEstrFis,{"06","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Pré-descarte = 08 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "08"
			AAdd(aEstrFis,{"08","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Troca = 09 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "09"
			AAdd(aEstrFis,{"09","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Em análise = 10 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "10"
			AAdd(aEstrFis,{"10","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Reservado = 11 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "11"
			AAdd(aEstrFis,{"11","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Pré-reprocesso = 12 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "12"
			AAdd(aEstrFis,{"12","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Cruz Alta = 13 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "13"
			AAdd(aEstrFis,{"13","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Transf Filiais = 95 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "95"
			AAdd(aEstrFis,{"95","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// ICL Brasil = 14 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "14"
			AAdd(aEstrFis,{"14","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Baixa CQ = 98 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "98"
			AAdd(aEstrFis,{"98","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

	ElseIf SB1->B1_TIPO == "MP"

		// Armazém de Compra = 01 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "01"
			AAdd(aEstrFis,{"01","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		If Empty(mv_par03) .Or. mv_par03 == "04"
			DbSelectArea("DC3")
			DbSetOrder(1)
			If DbSeek( xFilial("DC3") + SB1->B1_COD + "04" )
				zOrd := DC3->DC3_ORDEM
				While !Eof() .And. DC3->(DC3_FILIAL+DC3_CODPRO+DC3_LOCAL) == xFilial("DC3") + SB1->B1_COD + "04"
					If DC3->DC3_TPESTR == "000003"
						zOrd := DC3->DC3_ORDEM
						zNor := DC3->DC3_CODNOR
						AAdd(aEstrFis,{"04","000010",zOrd,zNor}) // Armazém, Estrutura Física, Ordem, Norma
						zOrd := SOMA1(zOrd)
						AAdd(aEstrFis,{"04","000011",zOrd,zNor}) // Armazém, Estrutura Física, Ordem, Norma
						zOrd := SOMA1(zOrd)
					Else
						zEst := DC3->DC3_TPESTR
						zNor := DC3->DC3_CODNOR
						AAdd(aEstrFis,{"04",zEst,zOrd,zNor}) // Armazém, Estrutura Física, Ordem, Norma
						zOrd := SOMA1(zOrd)
					Endif
					DC3->(DbSkip())
				Enddo
			Endif
		Endif	

		// Armazém de Compra = 06 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "06"
			AAdd(aEstrFis,{"06","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Transf Filiais = 95 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "95"
			AAdd(aEstrFis,{"95","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

		// Armazém de Compra = 98 (Pulmão)
		If Empty(mv_par03) .Or. mv_par03 == "98"
			AAdd(aEstrFis,{"98","000002","01","000004"}) // Armazém, Estrutura Física, Ordem, Norma
		Endif	

	Endif

	For _x := 1 to Len(aEstrFis)
		zLocal := aEstrFis[_x][1]
		zEstru := aEstrFis[_x][2]
		zOrdem := aEstrFis[_x][3]
		zNorma := aEstrFis[_x][4]
		DbSelectArea("DC3")
		DbSetOrder(2)
		If DbSeek( xFilial("DC3") + SB1->B1_COD + zLocal + zEstru )
			Loop
		Endif
		DbSelectArea("DC3")
		DbSetOrder(1)
		If !DbSeek( xFilial("DC3") + SB1->B1_COD + zLocal + zOrdem )
			RecLock("DC3",.T.)
			DC3->DC3_FILIAL := xFilial("DC3")
			DC3->DC3_CODPRO := SB1->B1_COD
			DC3->DC3_LOCAL  := zLocal
			DC3->DC3_ORDEM  := zOrdem
		Else
			RecLock("DC3",.F.)
		Endif
		DC3->DC3_TPESTR := zEstru
		DC3->DC3_CODNOR := zNorma
		DC3->DC3_TIPSEP := "3"
		DC3->DC3_NUNITI := 1
		DC3->DC3_EMBDES := "1"
		DC3->DC3_TIPEND := IIf(zLocal $("04") .And. Substr(zEstru,2,5) $("00008,00009,00010,00011,00012,00013"),"1","4") // Endereços Vazios | Compartilha End. Produtos Diferentes
		DC3->DC3_PRIEND := IIf(zLocal $("04"),"1","2") // Picking | Pulmão
		MsUnLock()	    	
	Next _x

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

If !lProcOk
	MsgAlert("Sem dados para processamento. Verifique os parâmetros.")
	Return
Else
	MsgInfo("Processo concluído com sucesso.")
Endif

Return
