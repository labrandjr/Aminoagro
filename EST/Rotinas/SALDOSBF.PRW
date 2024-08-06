#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SALDOSBF ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 27/02/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Inclusão de saldo por endereço - genérico.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SALDOSBF()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("SALDOSBF",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.F.)
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

If __cUserId != "000000"
	MsgAlert("Usuário não autorizado.")
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Inclusão de saldo por endereço genérico" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"INCLUSÃO DE SALDO POR ENDEREÇO GENÉRICO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo incluir saldo por endereço genérico"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"a partir dos parâmetros informados."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"Produtos com Tipo = PA e MP."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"Processo de Endereçamento."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  27/02/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento - INCLUSÃO DE SALDO POR ENDEREÇO ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando inclusão de saldo por endereço", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  27/02/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local cNumSeq   := ProxNum()
Local cCounter	:= "0000"
Local cSerieDoc	:= "MP"
Local nForFilial

aFilsCalc := MatFilCalc( mv_par05 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]

		cFilAnt := aFilsCalc[nForFilial][2]

		ProcRegua(3)

 		IncProc("Selecionando registros...")
		cQuery := " SELECT MAX(DB_ITEM) ITEM "
		cQuery += " FROM "+RetSqlName("SDB")
		cQuery += " WHERE DB_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND DB_DOC = 'SLDINICIO' "
		cQuery += " AND DB_SERIE = 'MP' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQDB", .F., .T.)
		SQDB->(DbGotop())
		If !Eof()
			cCounter := SQDB->ITEM
		Endif	
		SQDB->(DbCloseArea())
		
 		IncProc("Selecionando registros...")
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE B2_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND B2_COD = B1_COD "
		cQuery += " AND B2_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
		cQuery += " AND B1_TIPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
		cQuery += " AND B1_TIPO IN('PA','MP') "
		cQuery += " AND B2_QATU > 0 "
		cQuery += " AND B2_QEMP = 0 AND B2_RESERVA = 0 "
		cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQB2", .F., .T.)
		nTotSql := SQB2->SOMA
		SQB2->(DbCloseArea())

 		IncProc("Selecionando registros...")
		cQuery := " SELECT SB2.R_E_C_N_O_ RECSB2 "
		cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE B2_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND B2_COD = B1_COD "
		cQuery += " AND B2_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
		cQuery += " AND B1_TIPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
		cQuery += " AND B1_TIPO IN('PA','MP') "
		cQuery += " AND B2_QATU > 0 "
		cQuery += " AND B2_QEMP = 0 AND B2_RESERVA = 0 "
		cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY SB2.R_E_C_N_O_ "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQB2", .F., .T.)

		DbSelectArea("SQB2")
		ProcRegua(nTotSql)
		SQB2->(DbGotop())
		While !Eof()
		
			oProcess:IncRegua1("Incluindo saldo por endereço...")

			DbSelectArea("SB2")
			SB2->(DbGoto(SQB2->RECSB2))

			cQuery := " SELECT SUM(BF_QUANT) QUANTBF "
			cQuery += " FROM "+RetSqlName("SBF")
			cQuery += " WHERE BF_FILIAL = '"+cFilAnt+"' " 
			cQuery += " AND BF_PRODUTO = '"+SB2->B2_COD+"' "
			cQuery += " AND BF_LOCAL = '"+SB2->B2_LOCAL+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQBF", .F., .T.)
			nTotSbf := SQBF->QUANTBF
			SQBF->(DbCloseArea())

			If SB2->B2_QATU > nTotSbf
			
				nQtdSbf := SB2->B2_QATU - nTotSbf
				zEndere := ""
				If SB2->B2_LOCAL == "01"
					zEndere := "GEN1-01-00-01"
				ElseIf SB2->B2_LOCAL == "02"
					zEndere := "GEN2-01-00-01"
				ElseIf SB2->B2_LOCAL == "03"
					zEndere := "TRS1-01-00-01"
				ElseIf SB2->B2_LOCAL == "04"
					zEndere := "GEN1-01-00-01"
				ElseIf SB2->B2_LOCAL == "05"
					zEndere := "DEV1-01-00-01"
				ElseIf SB2->B2_LOCAL == "06"
					zEndere := "DES1-01-00-01"
				ElseIf SB2->B2_LOCAL == "09"
					zEndere := "PAL1-01-00-01"
				ElseIf SB2->B2_LOCAL == "10"
					zEndere := "OBS1-01-00-01"
				ElseIf SB2->B2_LOCAL == "11"
					zEndere := "RES-01-00-01"
				ElseIf SB2->B2_LOCAL == "12"
					zEndere := "SLW-01-00-01"
				Endif	

				cCounter := Soma1(cCounter)
			
				RecLock("SDB",.T.)
				SDB->DB_FILIAL  := cFilAnt
				SDB->DB_ITEM    := cCounter
				SDB->DB_PRODUTO := SB2->B2_COD
				SDB->DB_LOCAL   := SB2->B2_LOCAL
				SDB->DB_LOCALIZ := zEndere
				SDB->DB_DOC     := "SLDINICIO"
				SDB->DB_SERIE   := "MP"
				SDB->DB_TM      := "499"
				SDB->DB_ORIGEM  := "ACE"
				SDB->DB_QUANT   := nQtdSbf
				SDB->DB_DATA    := dDatabase
				SDB->DB_NUMSEQ  := cNumSeq
				SDB->DB_TIPO    := "M"
				SDB->DB_SERVIC  := "499"
				SDB->DB_ATIVID  := "ZZZ"
				SDB->DB_HRINI   := Substr(Time(),1,5)
				SDB->DB_ATUEST  := "S"
				SDB->DB_STATUS  := "M"
				SDB->DB_ORDATIV := "ZZ"
				SDB->DB_IDOPERA := StrZero(Val(cCounter),10)
				MsUnLock()
/*
				CriaSDB(SB2->B2_COD,;	// Produto
						SB2->B2_LOCAL,;	// Armazem
						nQtdSbf,;	    // Quantidade
						zEndere,;	    // Localizacao
						"",;			// Numero de Serie
						"SLDINICIO",;	// Doc
						"002",;		    // Serie
						"",;			// Cliente / Fornecedor
						"",;			// Loja
						"",;			// Tipo NF
						"ACE",;			// Origem do Movimento
						dDataBase,;		// Data
						"",;	        // Lote
						"",; 			// Sub-Lote
						cNumSeq,;		// Numero Sequencial
						"499",;			// Tipo do Movimento
						"M",;			// Tipo do Movimento (Distribuicao/Movimento)
						cCounter,;		// Item
						.F.,;			// Flag que indica se e' mov. estorno
						0,;				// Quantidade empenhado
						nQtdSbf)	    // Quantidade segunda UM
			
				GravaSBF("SDB")
*/			
			Endif

			DbSelectArea("SQB2")
			SQB2->(DbSkip())
		Enddo
		SQB2->(DbCloseArea())

	Endif	
Next nForFilial

MsgInfo("Processo concluído !!!")

Return
