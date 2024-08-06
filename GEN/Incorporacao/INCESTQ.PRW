#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ INCESTQ ¦ Autor ¦ Fábrica ERP.BR  ¦   Data  ¦ 31/10/2019   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Incorporação do Saldo em Estoque.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function INCESTQ()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("INCESTQ",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.F.)
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

If __cUserId != "000000"
	MsgAlert("Usuário não autorizado.")
	Return
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Incorporação de Saldo em Estoque - Qualyquímica" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"INCORPORAÇÃO DE SALDO EM ESTOQUE"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo transferir o Saldo em Estoque das unidades DIMICRON"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"(Filiais 0103 e 0108) para unidades QUALYQUÍMICA (Filiais 0106 e 0107)."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(080,010,{||"Todos os Armazéns."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"Itens sem Empenho/Reserva."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
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
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  31/10/2019  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If !(mv_par01 $("0103,0108"))
	MsgAlert("Filial origem inválida."+cEOL+"Utilize: 0103 ou 0108.")
	Return
Endif

If MsgYesNo("Confirma o processamento - INCORP. SALDO EM ESTOQUE ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando incorporação do Saldo em Estoque", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  31/10/2019 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local cEOL    := CHR(13)+CHR(10)
Local zFilDe  := mv_par01
Local zFilAt  := IIf(mv_par01=="0103","0106","0107")
Local aTrfSld := {}

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE B2_FILIAL = '"+zFilDe+"' "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B2_QATU > 0 "
cQuery += " AND B1_TIPO NOT IN('MC') " 
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
If !Empty(mv_par02)
	cQuery += " AND B2_COD = '"+mv_par02+"' "
Endif
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TPRD", .F., .T.)
nTotSql := TPRD->SOMA
TPRD->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT B2_COD PRODUTO, B1_DESC DESCRI, B1_TIPO TIPO, B2_LOCAL ARMAZEM, B2_QATU QATU "
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE B2_FILIAL = '"+zFilDe+"' "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B2_QATU > 0 "
cQuery += " AND B1_TIPO NOT IN('MC') " 
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
If !Empty(mv_par02)
	cQuery += " AND B2_COD = '"+mv_par02+"' "
Endif
cQuery += " ORDER BY PRODUTO, ARMAZEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TPRD", .F., .T.)

DbSelectArea("TPRD")
ProcRegua(nTotSql)
TPRD->(DbGotop())
While !Eof()
		
	oProcess:IncRegua1("Transferindo Saldos...")

	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( zFilDe + TPRD->PRODUTO + TPRD->ARMAZEM )
	nRecB2 := SB2->(Recno())

	zProdt := SB2->B2_COD
	zLocal := SB2->B2_LOCAL

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + zProdt )
	
	If SB2->B2_QEMP > 0
		MsgAlert("Produto "+AllTrim(zProdt)+" possui empenho no armazém "+zLocal+" e não pode ser transferido.")
		DbSelectArea("TPRD")
		TPRD->(DbSkip())
		Loop
	Endif

	If SB2->B2_RESERVA > 0
		MsgAlert("Produto "+AllTrim(zProdt)+" possui reserva no armazém "+zLocal+" e não pode ser transferido.")
		DbSelectArea("TPRD")
		TPRD->(DbSkip())
		Loop
	Endif

	If SB2->B2_QACLASS > 0
		MsgAlert("Produto "+AllTrim(zProdt)+" possui quantidade a endereçar no armazém "+zLocal+" e não pode ser transferido.")
		DbSelectArea("TPRD")
		TPRD->(DbSkip())
		Loop
	Endif

	zQuant := SB2->( B2_QATU - B2_QNPT - B2_QTNP )
	If zQuant <= 0
		MsgAlert("Produto "+AllTrim(zProdt)+" não possui quantidade disponível e não pode ser transferido.")
		DbSelectArea("TPRD")
		TPRD->(DbSkip())
		Loop
	Endif

	DbSelectArea("NNR")
	DbSetOrder(1)
	If !DbSeek( zFilAt + zLocal )
		MsgAlert("Armazém "+zLocal+" não cadastrado na Filial "+zFilAt+". O saldo do produto será ignorado.")
		DbSelectArea("TPRD")
		TPRD->(DbSkip())
		Loop
	Endif

	DbSelectArea("SB2")
	DbSetOrder(1)
	If !DbSeek( zFilAt + zProdt + zLocal )

		DbSelectArea("SB9")
		DbSetOrder(1)
		If !DbSeek( zFilAt + zProdt + zLocal )
			RecLock("SB9",.T.)
			SB9->B9_FILIAL := zFilAt
			SB9->B9_COD    := zProdt
			SB9->B9_LOCAL  := zLocal
			SB9->B9_MCUSTD := "1"
			MsUnLock()
		Endif	

		RecLock("SB2",.T.)
		SB2->B2_FILIAL  := zFilAt
		SB2->B2_COD     := zProdt
		SB2->B2_LOCAL   := zLocal
		SB2->B2_LOCALIZ := AllTrim(NNR->NNR_DESCRI)
		SB2->B2_TIPO    := "1"
		MsUnLock()

	Endif
	SB2->(DbGoto(nRecB2))

	If SB1->B1_RASTRO == "L"
		DbSelectArea("SB8")
		DbSetOrder(1)
		If DbSeek( zFilDe + zProdt + zLocal )
			While !Eof() .And. SB8->( B8_FILIAL + B8_PRODUTO + B8_LOCAL ) == zFilDe + zProdt + zLocal
				If SB8->B8_SALDO > 0
					AAdd(aTrfSld,{SB8->B8_FILIAL, SB8->B8_PRODUTO, SB8->B8_LOCAL, SB8->B8_LOTECTL, SB8->B8_DTVALID,;
					 			  SB8->B8_SALDO, zFilAt, SB8->B8_PRODUTO, SB8->B8_LOCAL, SB8->B8_LOTECTL, SB8->B8_DTVALID})
				Endif
				SB8->(DbSkip())
			Enddo 
		Endif
	Else
		AAdd(aTrfSld,{SB2->B2_FILIAL, SB2->B2_COD, SB2->B2_LOCAL, "", CtoD(""), zQuant, zFilAt, SB2->B2_COD, SB2->B2_LOCAL, "", CtoD("")})
	Endif
	
	If Len(aTrfSld) >= 50
		_ExecTrf(aTrfSld)
		aTrfSld := {}
	Endif

	DbSelectArea("TPRD")
	TPRD->(DbSkip())
Enddo
TPRD->(DbCloseArea())

If Len(aTrfSld) > 0
	_ExecTrf(aTrfSld)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _ExecTrf ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  31/10/2019 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _ExecTrf(aTrfSld)

Local lCabec  := .F.
Local zTesSai := "596"
Local zTesEnt := "123"

For _x := 1 to Len(aTrfSld)

	zFilOr := aTrfSld[_x][1]
	zPrdOr := aTrfSld[_x][2]
	zLocOr := aTrfSld[_x][3]
	zLotOr := aTrfSld[_x][4]
	zVldOr := aTrfSld[_x][5]
	zQuant := aTrfSld[_x][6]
	zFilDe := aTrfSld[_x][7]
	zPrdDe := aTrfSld[_x][8]
	zLocDe := aTrfSld[_x][9]
	zLotDe := aTrfSld[_x][10]
	zVldDe := aTrfSld[_x][11]
	
	If !lCabec
		lCabec := .T.
		zCodSt := _PrxDocSt(zFilOr)
		RecLock("NNS",.T.)
		NNS->NNS_FILIAL := zFilOr
		NNS->NNS_COD    := zCodSt
		NNS->NNS_DATA   := Date()
		NNS->NNS_SOLICT := "000000"
		NNS->NNS_STATUS := "1"
		NNS->NNS_CLASS  := "2"
		NNS->NNS_ESPECI := "SPED"
		MsUnLock()	
	Endif

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + zPrdOr )

	RecLock("NNT",.T.)
	NNT->NNT_FILIAL := zFilOr
	NNT->NNT_COD    := zCodSt
	NNT->NNT_FILORI := zFilOr
	NNT->NNT_PROD   := SB1->B1_COD
	NNT->NNT_UM     := SB1->B1_UM
	NNT->NNT_LOCAL  := zLocOr
	If !Empty(zLotOr)
		NNT->NNT_LOTECT := zLotOr
		NNT->NNT_DTVALI := zVldOr
	Endif	
	NNT->NNT_QUANT  := zQuant 
	NNT->NNT_QTSEG  := ConvUm(SB1->B1_COD, zQuant, 0, 2)
	NNT->NNT_FILDES := zFilDe
	NNT->NNT_PRODD  := zPrdDe
	NNT->NNT_UMD    := SB1->B1_UM
	NNT->NNT_LOCLD  := zLocDe
	If !Empty(zLotDe)
		NNT->NNT_LOTED  := zLotDe
		NNT->NNT_DTVALD := zVldDe
	Endif	
	NNT->NNT_TS := zTesSai 
	NNT->NNT_TE := zTesEnt
	MsUnLock()

	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( zFilOr + zPrdOr + zLocOr )
	RecLock("SB2",.F.)
	SB2->B2_QEMP  += NNT->NNT_QUANT
	SB2->B2_QEMP2 += NNT->NNT_QTSEG 
	MsUnLock()

	If !Empty(zLotOr)
		DbSelectArea("SB8")
		DbSetOrder(3)
		DbSeek( zFilOr + zPrdOr + zLocOr + zLotOr )
		RecLock("SB8",.F.)
		SB8->B8_EMPENHO += NNT->NNT_QUANT
		SB8->B8_EMPENH2 += NNT->NNT_QTSEG
		MsUnLock()
	Endif
	
Next _x

MsgInfo("Solic.Transf. "+NNS->NNS_COD+" incluída com sucesso!", "Aviso")
 
Return


Static Function _PrxDocSt(zFilOr)

Local cRetX := "0000000001"

cQuery := " SELECT MAX(NNS_COD)AS CODST "
cQuery += " FROM "+RetSqlName("NNS")
cQuery += " WHERE NNS_FILIAL = '"+zFilOr+"' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TNNS", .F., .T.)
TNNS->(DbGotop())
If !Eof()
	cRetX := SOMA1(TNNS->CODST)
Endif	
TNNS->(DbCloseArea())

Return(cRetX)
