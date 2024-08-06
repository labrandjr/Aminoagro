#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RATLCTB   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 05/09/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa o rateio dos lançamentos contábeis a partir do     ¦¦¦
¦¦¦          ¦ cadastro 'Rateio Off-Line' - CTBA270.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function RATLCTB()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("RATLCTB",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.F.)
Private cEOL   := CHR(13)+CHR(10)
Private cTabl2 := Nil
Private oDlgUpd, oProcess, cArqCtb
Private oTempTable

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Rateio Off-Line" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,125,{||"RATEIO OFF-LINE"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo gerar os lançamentos contábeis de rateio automaticamente"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"de acordo com o cadastro 'Rateio Off-Line'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"O lote poderá ser identificado com o código 'RT' seguido do mês (MM) e ano (AA) conforme"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"a data do lançamento contábil original."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

oText5:= TSay():New(090,010,{||"O lançamento padrão 'X91' foi configurado para esta finalidade."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText5:CtrlRefresh()

oText6:= TSay():New(100,010,{||"Configure os parâmetros antes de iniciar o processamento."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText6:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  05/09/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

lLctPadX91 := VerPadrao("X91")
If !lLctPadX91
	Alert("Lançamento padrão 'X91' não cadastrado. Contate o Administrador.")
	Return
Endif

If Empty(mv_par01) .Or. Empty(mv_par02)
	MsgInfo("Atenção, data dos lançamentos não informada. Verifique os parâmetros.")
	Return
Endif

If Select("TRB") > 0
	TRB->(DbCloseArea())
Endif

_CriaTrab()
	
If MsgYesNo("Confirma o processamento - RATEIO OFF-LINE ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Gerando lançamentos contábeis de rateio", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

TRB->(DbCloseArea())
oTempTable:Delete()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  05/02/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local _x

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("CTQ")
cQuery += " WHERE CTQ_FILIAL = '"+xFilial("CTQ")+"' "
cQuery += " AND CTQ_TIPO = '1' "
cQuery += " AND CTQ_MSBLQL = '2' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
nTotSql := SQL2->SOMA
SQL2->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ RECCTQ "
cQuery += " FROM "+RetSqlName("CTQ")
cQuery += " WHERE CTQ_FILIAL = '"+xFilial("CTQ")+"' "
cQuery += " AND CTQ_TIPO = '1' "
cQuery += " AND CTQ_MSBLQL = '2' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY CTQ_FILIAL, CTQ_RATEIO, CTQ_SEQUEN "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

oProcess:SetRegua1(nTotSql)
DbSelectArea("SQL2")
SQL2->(DbGotop())
While !Eof()
	
	oProcess:IncRegua1("Analisando lançamentos do período")

	DbSelectArea("CTQ")
	CTQ->(DbGoto(SQL2->RECCTQ))

	// Débito
	cQuery := " SELECT R_E_C_N_O_ RECCT2 "
	cQuery += " FROM "+RetSqlName("CT2")
	cQuery += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
	cQuery += " AND CT2_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND CT2_DEBITO = '"+CTQ->CTQ_CTORI+"' "
	cQuery += " AND CT2_CCD = '"+CTQ->CTQ_CCORI+"' "
	If !Empty(CTQ->CTQ_ITORI)
		cQuery += " AND CT2_ITEMD = '"+CTQ->CTQ_ITORI+"' "
    Endif
	If !Empty(CTQ->CTQ_CLORI)
		cQuery += " AND CT2_CLVLDB = '"+CTQ->CTQ_CLORI+"' "
	Endif	
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"LCT2", .F., .T.)

	DbSelectArea("LCT2")
	LCT2->(DbGotop())
	While !Eof()

		DbSelectArea("CT2")
		CT2->(DbGoto(LCT2->RECCT2))
		zLoteRt := "RT" + Substr(DtoS(CT2->CT2_DATA),5,2) + Substr(DtoS(CT2->CT2_DATA),3,2)

		// Checagem se já existe
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("CT2")
		cQuery += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
		cQuery += " AND CT2_DATA   = '"+DtoS(CT2->CT2_DATA)+"' "
		cQuery += " AND CT2_LOTE   = '"+zLoteRt+"' "
		cQuery += " AND CT2_DEBITO = '"+CTQ->CTQ_CTCPAR+"' "
		cQuery += " AND CT2_CREDIT = '"+CTQ->CTQ_CTPAR+"' "
		cQuery += " AND CT2_CCD    = '"+CTQ->CTQ_CCCPAR+"' "
		cQuery += " AND CT2_CCC    = '"+CTQ->CTQ_CCPAR+"' "
		cQuery += " AND CT2_ITEMD  = '"+CTQ->CTQ_ITCPAR+"' "
		cQuery += " AND CT2_ITEMC  = '"+CTQ->CTQ_ITPAR+"' "
		cQuery += " AND CT2_CLVLDB = '"+CTQ->CTQ_CLCPAR+"' "
		cQuery += " AND CT2_CLVLCR = '"+CTQ->CTQ_CLPAR+"' "
		cQuery += " AND SUBSTR(CT2_ORIGEM,1,3) = 'X91' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TROK", .F., .T.)
		lRatGrv := (TROK->SOMA > 0)
		TROK->(DbCloseArea())

		If !lRatGrv
			DbSelectArea("TRB")
			RecLock("TRB",.T.)
			TRB->TF_DATA   := CT2->CT2_DATA
			TRB->TF_RATEIO := CTQ->CTQ_RATEIO
			TRB->TF_SEQUEN := CTQ->CTQ_SEQUEN
			TRB->TF_DEBITO := CTQ->CTQ_CTCPAR // Contra partida
			TRB->TF_CREDIT := CTQ->CTQ_CTPAR
			TRB->TF_CCD    := CTQ->CTQ_CCCPAR // Contra partida
			TRB->TF_CCC    := CTQ->CTQ_CCPAR
			TRB->TF_ITEMD  := CTQ->CTQ_ITCPAR // Contra partida
			TRB->TF_ITEMC  := CTQ->CTQ_ITPAR
			TRB->TF_CLVLDB := CTQ->CTQ_CLCPAR // Contra partida
			TRB->TF_CLVLCR := CTQ->CTQ_CLPAR
			TRB->TF_VALOR  := (CT2->CT2_VALOR * (CTQ->CTQ_PERCEN/100))
			TRB->TF_HIST   := CT2->CT2_HIST
			MsUnLock()
		Endif	

		DbSelectArea("LCT2")
		LCT2->(DbSkip())	
	Enddo
	LCT2->(DbCloseArea())
	
	// Crédito
	cQuery := " SELECT R_E_C_N_O_ RECCT2 "
	cQuery += " FROM "+RetSqlName("CT2")
	cQuery += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
	cQuery += " AND CT2_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND CT2_CREDIT = '"+CTQ->CTQ_CTORI+"' "
	cQuery += " AND CT2_CCC = '"+CTQ->CTQ_CCORI+"' "
	If !Empty(CTQ->CTQ_ITORI)
		cQuery += " AND CT2_ITEMC = '"+CTQ->CTQ_ITORI+"' "
	Endif	
	If !Empty(CTQ->CTQ_CLORI)
		cQuery += " AND CT2_CLVLCR = '"+CTQ->CTQ_CLORI+"' "
	Endif	
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"LCT2", .F., .T.)

	DbSelectArea("LCT2")
	LCT2->(DbGotop())
	While !Eof()

		DbSelectArea("CT2")
		CT2->(DbGoto(LCT2->RECCT2))
		zLoteRt := "RT" + Substr(DtoS(CT2->CT2_DATA),5,2) + Substr(DtoS(CT2->CT2_DATA),3,2)

		// Checagem se já existe
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("CT2")
		cQuery += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
		cQuery += " AND CT2_DATA   = '"+DtoS(CT2->CT2_DATA)+"' "
		cQuery += " AND CT2_LOTE   = '"+zLoteRt+"' "
		cQuery += " AND CT2_DEBITO = '"+CTQ->CTQ_CTPAR+"' "
		cQuery += " AND CT2_CREDIT = '"+CTQ->CTQ_CTCPAR+"' "
		cQuery += " AND CT2_CCD    = '"+CTQ->CTQ_CCPAR+"' "
		cQuery += " AND CT2_CCC    = '"+CTQ->CTQ_CCCPAR+"' "
		cQuery += " AND CT2_ITEMD  = '"+CTQ->CTQ_ITPAR+"' "
		cQuery += " AND CT2_ITEMC  = '"+CTQ->CTQ_ITCPAR+"' "
		cQuery += " AND CT2_CLVLDB = '"+CTQ->CTQ_CLPAR+"' "
		cQuery += " AND CT2_CLVLCR = '"+CTQ->CTQ_CLCPAR+"' "
		cQuery += " AND SUBSTR(CT2_ORIGEM,1,3) = 'X91' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TROK", .F., .T.)
		lRatGrv := (TROK->SOMA > 0)
		TROK->(DbCloseArea())

		If !lRatGrv
			DbSelectArea("TRB")
			RecLock("TRB",.T.)
			TRB->TF_DATA   := CT2->CT2_DATA
			TRB->TF_RATEIO := CTQ->CTQ_RATEIO
			TRB->TF_SEQUEN := CTQ->CTQ_SEQUEN
			TRB->TF_DEBITO := CTQ->CTQ_CTPAR
			TRB->TF_CREDIT := CTQ->CTQ_CTCPAR // Contra partida
			TRB->TF_CCD    := CTQ->CTQ_CCPAR
			TRB->TF_CCC    := CTQ->CTQ_CCCPAR // Contra partida
			TRB->TF_ITEMD  := CTQ->CTQ_ITPAR
			TRB->TF_ITEMC  := CTQ->CTQ_ITCPAR // Contra partida
			TRB->TF_CLVLDB := CTQ->CTQ_CLPAR
			TRB->TF_CLVLCR := CTQ->CTQ_CLCPAR // Contra partida
			TRB->TF_VALOR  := (CT2->CT2_VALOR * (CTQ->CTQ_PERCEN/100))
			TRB->TF_HIST   := CT2->CT2_HIST
			MsUnLock()
		Endif

		DbSelectArea("LCT2")
		LCT2->(DbSkip())	
	Enddo
	LCT2->(DbCloseArea())

	DbSelectArea("SQL2")
	SQL2->(DbSkip())		
Enddo
SQL2->(DbCloseArea())

// Geração dos Lançamentos Contábeis
Begin Transaction

xDatAnt := CtoD("")
lDataOk := .F.
zLoteRt := ""

DbSelectArea("TRB")
TRB->(DbGotop())
If !Eof()

	oProcess:SetRegua2( TRB->(RecCount()) )

	DbSelectArea("TRB")
	TRB->(DbGotop())
	While !Eof()

		oProcess:IncRegua2("Gerando lançamentos de rateio")

		If TRB->TF_DATA != xDatAnt
		
			If lDataOk
			
				// Totaliza Data
				If _nTotLan > 0
					RodaProva(_nHdlPrv,_nTotLan)
					cA100Incl(cArqCtb,_nHdlPrv,3,zLoteRt,(mv_par03==1),.F.,,xDatAnt)
				Endif
				
			Else
			
				lDataOk := .T.
			
			Endif

			// Inicializa Data
			xDatAnt := TRB->TF_DATA
			zLoteRt := "RT" + Substr(DtoS(TRB->TF_DATA),5,2) + Substr(DtoS(TRB->TF_DATA),3,2)

			// Abre novo Documento
			_nHdlPrv := HeadProva(zLoteRt,"RATLCTB",__cUserId,@cArqCtb)
			_nTotLan := 0
		
		Endif

		CCTADEB := TRB->TF_DEBITO
		CCTACRD := TRB->TF_CREDIT
		CCCDEB  := TRB->TF_CCD
		CCCCRD  := TRB->TF_CCC
		CBUDEB  := TRB->TF_ITEMD
		CBUCRD  := TRB->TF_ITEMC
		CCVDEB  := TRB->TF_CLVLDB
		CCVCRD  := TRB->TF_CLVLCR
		CHISTOR := TRB->TF_HIST
		NVLRLAN := TRB->TF_VALOR
		_nTotLan += DetProva(_nHdlPrv,"X91","RATLCTB",zLoteRt)

		DbSelectArea("TRB")
		TRB->(DbSkip())
		
		If Eof()

			// Totaliza Filial
			If _nTotLan > 0
				RodaProva(_nHdlPrv,_nTotLan)
				cA100Incl(cArqCtb,_nHdlPrv,3,zLoteRt,(mv_par03==1),.F.,,xDatAnt)
			Endif

		Endif

		DbSelectArea("TRB")
	Enddo	

Endif

End Transaction
MsUnLockAll()

MsgInfo("Processamento concluído.")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _CriaTrab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 05/09/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _CriaTrab()

Local _aTm2 := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTm2, {"TF_DATA"   , "D", 008, 00} )
AAdd ( _aTm2, {"TF_RATEIO" , "C", 006, 00} )
AAdd ( _aTm2, {"TF_SEQUEN" , "C", 003, 00} )
AAdd ( _aTm2, {"TF_DEBITO" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_CREDIT" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_CCD"    , "C", 012, 00} )
AAdd ( _aTm2, {"TF_CCC"    , "C", 012, 00} )
AAdd ( _aTm2, {"TF_ITEMD"  , "C", 009, 00} )
AAdd ( _aTm2, {"TF_ITEMC"  , "C", 009, 00} )
AAdd ( _aTm2, {"TF_CLVLDB" , "C", 009, 00} )
AAdd ( _aTm2, {"TF_CLVLCR" , "C", 009, 00} )
AAdd ( _aTm2, {"TF_VALOR"  , "N", 016, 02} )
AAdd ( _aTm2, {"TF_HIST"   , "C", 040, 00} )

oTemptable:SetFields( _aTm2 )
oTempTable:AddIndex("indice1", {"TF_DATA", "TF_RATEIO", "TF_SEQUEN"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  05/02/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua a leitura do arquivo txt e retorna a linha lida.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fReadFile(nHandle,xFileSize,xBytesRead,nBytes)

Local nBytesRead := IIf(!((xBytesRead == 0) .Or. (xBytesRead == Nil)),xBytesRead,IIf(xFileSize < 1536,xFileSize,1536)) // Indica o numero de bytes a serem lidos
Local cBuffer    := Space(nBytesread) // Guarda o conteudo lido
Local nPosition  := 0 // Posicao do caracter 13 (return)
Local nIncbytes  := Nil // Incremento de bytes 2 CHR(13) + CHR(10)
Local xReturn    := Nil // Retorno da funcao

If ( ((FREAD(nHandle,@cBuffer,nBytesRead) = nBytesRead) .Or. (!Empty(cBuffer))) )
	// Verifica se procura o caracter 13 para identificar o registro
	xReturn := Substr(cBuffer,1,IIf(((nPosition := AT(CHR(13),cBuffer)) > 0),(nPosition - 1),Len(cBuffer)))
	// Verifica se incrementa bytes
	nIncBytes := IIf(nPosition > 0,2,0)
	// Bytes ja lidos somando os caracteres especiais
	nBytes := (nBytes + (Len(xReturn) + nIncBytes))
	// Retorna o descritor se necessario
	FSEEK(nHandle,(-1 * ABS((Len(cBuffer) - (Len(xReturn) + nIncBytes)))),1)
Endif

Return(xReturn)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  05/02/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Obtem o tamanho do arquivo texto.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)
