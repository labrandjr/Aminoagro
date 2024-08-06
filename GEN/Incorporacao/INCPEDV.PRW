#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "xmlxfun.ch"
#include "apwebsrv.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ INCPEDV ¦ Autor ¦ Fábrica ERP.BR  ¦   Data  ¦ 19/09/2019   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Incorporação dos Pedidos de Venda.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function INCPEDV()

Local cPerg	:= Padr("INCPEDV",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

If __cUserId != "000000"
	MsgAlert("Usuário não autorizado.")
	Return
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Incorporação de Pedidos de Venda - Qualyquímica" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"INCORPORAÇÃO DE PEDIDOS DE VENDA"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo transferir os Pedidos de Venda das unidades DIMICRON"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"(Filiais 0103 e 0108) para unidades QUALYQUÍMICA (Filiais 0106 e 0107)."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(080,010,{||"Pedidos em Aberto."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"Itens com saldo."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
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
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  19/09/2019  ¦¦¦
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

If MsgYesNo("Confirma o processamento - INCORPORAÇÃO PEDIDOS DE VENDA ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando incorporação dos Pedidos de Venda", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  19/09/2019 ¦¦¦
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
Local aCabec  := {}
Local aItens  := {}
Local cFilBkp := cFilAnt
Local _ped, _x

Private nSaveSX8 := IIf(Type("nSaveSx8")=="U", GetSX8Len(), nSaveSX8)
Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

cFilAnt := zFilAt // --> Muda filial corrente para Filial Destino

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+zFilDe+"' "
If !Empty(mv_par02)
	cQuery += " AND C6_NUM = '"+mv_par02+"' "
Endif
cQuery += " AND C6_QTDENT < C6_QTDVEN "
cQuery += " AND C6_BLQ = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TPED", .F., .T.)
nTotSql := TPED->SOMA
TPED->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT DISTINCT(C6_NUM) PEDIDO "
cQuery += " FROM "+RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+zFilDe+"' "
If !Empty(mv_par02)
	cQuery += " AND C6_NUM = '"+mv_par02+"' "
Endif
cQuery += " AND C6_QTDENT < C6_QTDVEN "
cQuery += " AND C6_BLQ = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY PEDIDO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TPED", .F., .T.)

DbSelectArea("TPED")
ProcRegua(nTotSql)
TPED->(DbGotop())
While !Eof()
		
	oProcess:IncRegua1("Transferindo Pedidos...")

	lQtdLib := .F.
	DbSelectArea("SC9")
	DbSetOrder(1)
	If DbSeek( zFilDe + TPED->PEDIDO )
		While !Eof() .And. SC9->( C9_FILIAL + C9_PEDIDO ) == zFilDe + TPED->PEDIDO 
			If Empty(SC9->C9_NFISCAL)
				MsgAlert("Pedido "+SC9->C9_PEDIDO+" possui quantidade liberada, e não será transferido.")
				lQtdLib := .T.
				Exit
			Endif
			SC9->(DbSkip())
		Enddo
	Endif
	If lQtdLib
		DbSelectArea("TPED")
		TPED->(DbSkip())
		Loop
	Endif

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( zFilDe + TPED->PEDIDO )
	
	If SC5->C5_TIPO $("B,D")
		DbSelectArea("TPED")
		TPED->(DbSkip())
		Loop
	Else
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SC5->C5_CLIENTE )
	Endif

	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + SC5->C5_CONDPAG )

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SC5")
	cQuery += " WHERE C5_ZFILINC = '"+SC5->C5_FILIAL+"' "
	cQuery += " AND C5_ZNUMINC = '"+SC5->C5_NUM+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSC5", .F., .T.)
	lExiste := (TSC5->SOMA > 0)
	TSC5->(DbCloseArea())

	If lExiste
		MsgAlert("Pedido "+SC5->C5_FILIAL+"-"+SC5->C5_NUM+" já cadastrado na Filial "+cFilAnt)
		DbSelectArea("TPED")
		TPED->(DbSkip())
		Loop
	Endif

	aCabec  := {}
	aItens  := {}
	aRecSc6 := {}
	aFatSc6 := {}
	aBlqB1  := {}
	aBlqVe  := {}
	zTotPed := 0

	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( zFilDe + TPED->PEDIDO )

	While !Eof() .And. SC6->(C6_FILIAL + C6_NUM) == zFilDe + TPED->PEDIDO
		zQtdSld := SC6->(C6_QTDVEN - C6_QTDENT)
		zQtdFat := SC6->C6_QTDENT
		If zQtdSld > 0
			zTotPed += Round((zQtdSld * SC6->C6_PRCVEN),2)
			AAdd(aRecSc6, SC6->(Recno()))
		Endif
		If zQtdFat > 0
			zTotPed += Round((zQtdFat * SC6->C6_PRCVEN),2)
			AAdd(aFatSc6, SC6->(Recno()))
		Endif
		SC6->(DbSkip())
	Enddo

	z5Parc1 := SC5->C5_PARC1
	z5Parc2 := SC5->C5_PARC2
	z5Parc3 := SC5->C5_PARC3
	z5Parc4 := SC5->C5_PARC4
	z5Data1 := IIf(!Empty(SC5->C5_DATA1) .And. SC5->C5_DATA1 < Date(), Date(), SC5->C5_DATA1)
	z5Data2 := IIf(!Empty(SC5->C5_DATA2) .And. SC5->C5_DATA2 < Date(), Date(), SC5->C5_DATA2)
	z5Data3 := IIf(!Empty(SC5->C5_DATA3) .And. SC5->C5_DATA3 < Date(), Date(), SC5->C5_DATA3)
	z5Data4 := IIf(!Empty(SC5->C5_DATA4) .And. SC5->C5_DATA4 < Date(), Date(), SC5->C5_DATA4)

	If SE4->E4_TIPO == "9" .And. AllTrim(SE4->E4_COND) == "0"
		// % original
		zTotOri := SC5->(C5_PARC1+C5_PARC2+C5_PARC3+C5_PARC4)
		z5Per01 := Round(((SC5->C5_PARC1 / zTotOri) * 100),0)
		z5Per02 := Round(((SC5->C5_PARC2 / zTotOri) * 100),0)
		z5Per03 := Round(((SC5->C5_PARC3 / zTotOri) * 100),0)
		z5Per04 := (100 - (z5Per01 + z5Per02 + z5Per03))
		// Novas parcelas
		z5Parc1 := (zTotPed * (z5Per01/100))
		z5Parc2 := (zTotPed * (z5Per02/100))
		z5Parc3 := (zTotPed * (z5Per03/100))
		z5Parc4 := (zTotPed - (z5Parc1 + z5Parc2 + z5Parc3))
	Endif

	zRec := SC5->(Recno())
	nCnt := 0
	lSeq := .T.
	cDoc := GetSXENum("SC5","C5_NUM")
	RollBackSX8()
	SC5->(DbSetOrder(1))
	While SC5->(DbSeek(xFilial("SC5")+cDoc))
		ConfirmSX8()
		cDoc := GetSXENum("SC5","C5_NUM")
		RollBackSX8()
		nCnt += 1
		If nCnt > 10 // Caso haja mais de 10 tentativas, corrigir o sxe/sxf.
			MsgAlert("Falha no sequenciamento da numeração de pedidos. Contate o Administrador.")
			lSeq := .F.
			Exit
		Endif
	EndDo
	SC5->(DbGoto(zRec))

	If !lSeq
		DbSelectArea("TPED")
		TPED->(DbSkip())
		Loop
	Endif

	AAdd(aCabec,{ "C5_NUM"    , cDoc,            Nil })
	AAdd(aCabec,{ "C5_TIPO"   , SC5->C5_TIPO,    Nil })
	AAdd(aCabec,{ "C5_CLIENTE", SC5->C5_CLIENTE, Nil })
	AAdd(aCabec,{ "C5_LOJACLI", SC5->C5_LOJACLI, Nil })
	AAdd(aCabec,{ "C5_CLIENT" , SC5->C5_CLIENT,  Nil })
	AAdd(aCabec,{ "C5_LOJAENT", SC5->C5_LOJAENT, Nil })
	AAdd(aCabec,{ "C5_TIPOCLI", SC5->C5_TIPOCLI, Nil })			
	AAdd(aCabec,{ "C5_CONDPAG", SC5->C5_CONDPAG, Nil })
	AAdd(aCabec,{ "C5_VEND1"  , SC5->C5_VEND1,   Nil })
	AAdd(aCabec,{ "C5_ZZCDFXV", SC5->C5_ZZCDFXV, Nil })
	AAdd(aCabec,{ "C5_VEND2"  , SC5->C5_VEND2,   Nil })
	AAdd(aCabec,{ "C5_ZZCDFXR", SC5->C5_ZZCDFXR, Nil })
	AAdd(aCabec,{ "C5_VEND3"  , SC5->C5_VEND3,   Nil })
	AAdd(aCabec,{ "C5_ZCDFXR3", SC5->C5_ZCDFXR3, Nil })
	AAdd(aCabec,{ "C5_VEND4"  , SC5->C5_VEND4,   Nil })
	AAdd(aCabec,{ "C5_ZCDFXR4", SC5->C5_ZCDFXR4, Nil })
	AAdd(aCabec,{ "C5_ZZREGVE", SC5->C5_ZZREGVE, Nil })
	AAdd(aCabec,{ "C5_ZZITCTB", SC5->C5_ZZITCTB, Nil })
	AAdd(aCabec,{ "C5_XPRJAMI", SC5->C5_XPRJAMI, Nil })
	AAdd(aCabec,{ "C5_ZEBTDIG", SC5->C5_ZEBTDIG, Nil })
	AAdd(aCabec,{ "C5_PARC1"  , z5Parc1,         Nil })
	AAdd(aCabec,{ "C5_DATA1"  , z5Data1,         Nil })
	AAdd(aCabec,{ "C5_PARC2"  , z5Parc2,         Nil })
	AAdd(aCabec,{ "C5_DATA2"  , z5Data2,         Nil })
	AAdd(aCabec,{ "C5_PARC3"  , z5Parc3,         Nil })
	AAdd(aCabec,{ "C5_DATA3"  , z5Data3,         Nil })
	AAdd(aCabec,{ "C5_PARC4"  , z5Parc4,         Nil })
	AAdd(aCabec,{ "C5_DATA4"  , z5Data4,         Nil })
	AAdd(aCabec,{ "C5_ZZPPONT", SC5->C5_ZZPPONT, Nil })
	AAdd(aCabec,{ "C5_ZZVPONT", SC5->C5_ZZVPONT, Nil })
	AAdd(aCabec,{ "C5_ZZTPBON", SC5->C5_ZZTPBON, Nil })
	AAdd(aCabec,{ "C5_TPFRETE", SC5->C5_TPFRETE, Nil })
	AAdd(aCabec,{ "C5_FRETE"  , SC5->C5_FRETE,   Nil })
	AAdd(aCabec,{ "C5_TRANSP" , SC5->C5_TRANSP,  Nil })
	AAdd(aCabec,{ "C5_MOEDA"  , SC5->C5_MOEDA,   Nil })
	AAdd(aCabec,{ "C5_TXMOEDA", SC5->C5_TXMOEDA, Nil })
	AAdd(aCabec,{ "C5_EMISSAO", Date(),          Nil })
	AAdd(aCabec,{ "C5_PESOL"  , SC5->C5_PESOL,   Nil })
	AAdd(aCabec,{ "C5_PBRUTO" , SC5->C5_PBRUTO,  Nil })
	AAdd(aCabec,{ "C5_SUPER1" , SC5->C5_SUPER1,  Nil })
	AAdd(aCabec,{ "C5_SUPER2" , SC5->C5_SUPER2,  Nil })
	AAdd(aCabec,{ "C5_GEREN1" , SC5->C5_GEREN1,  Nil })
	AAdd(aCabec,{ "C5_GEREN2" , SC5->C5_GEREN2,  Nil })
	AAdd(aCabec,{ "C5_COPMOD2", "N",             Nil })
	AAdd(aCabec,{ "C5_ABTSALD", SC5->C5_ABTSALD, Nil })
	AAdd(aCabec,{ "C5_ZZOBS"  , SC5->C5_ZZOBS,   Nil })
	AAdd(aCabec,{ "C5_MENNOTA", SC5->C5_MENNOTA, Nil })
	AAdd(aCabec,{ "C5_ZEBTDIG", SC5->C5_ZEBTDIG, Nil })
	AAdd(aCabec,{ "C5_ZFILINC", SC5->C5_FILIAL,  Nil })
	AAdd(aCabec,{ "C5_ZNUMINC", SC5->C5_NUM,     Nil })
               
	zFilInc := SC5->C5_FILIAL
	zNumInc := SC5->C5_NUM
	zzDtMod := SC5->C5_ZZDTMOD
	zzUsuar := SC5->C5_ZZUSUAR
	zzItem  := "00"

	// Itens em Aberto
	For _ped := 1 to Len(aRecSc6)
	
		DbSelectArea("SC6")
		SC6->(DbGoto(aRecSc6[_ped]))

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SC6->C6_PRODUTO )
		If SB1->B1_MSBLQL == "1"
			RecLock("SB1",.F.)
			SB1->B1_MSBLQL := "2"
			MsUnLock()
			If aScan(aBlqB1, {|x| x == SB1->B1_COD}) == 0
				AAdd(aBlqB1,SB1->B1_COD)
			Endif
		Endif 
		If SB1->B1_ZBLQVEN == "1"
			RecLock("SB1",.F.)
			SB1->B1_ZBLQVEN := "2"
			MsUnLock()
			If aScan(aBlqVe, {|x| x == SB1->B1_COD}) == 0
				AAdd(aBlqVe,SB1->B1_COD)
			Endif
		Endif 

		zzItem   := SOMA1(zzItem)
		zProduto := SC6->C6_PRODUTO
		zQtdVen  := SC6->(C6_QTDVEN - C6_QTDENT)
		zPrcVen  := SC6->C6_PRCVEN
		zTotal   := Round((zQtdVen * zPrcVen),2)
		zTes     := SC6->C6_TES
		zArmazem := SC6->C6_LOCAL
		zDescri  := SC6->C6_DESCRI
		zUnsVen  := ConvUm(SC6->C6_PRODUTO, zQtdVen, 0, 2)
		zCCusto  := SC6->C6_CCUSTO
		zItCtb   := SC6->C6_ZZITCTB
	
		aLinha := {}			
		AAdd(aLinha,{ "C6_NUM"    , cDoc,      Nil })
		AAdd(aLinha,{ "C6_ITEM"   , zzItem,    Nil })
		AAdd(aLinha,{ "C6_PRODUTO", zProduto,  Nil })
		AAdd(aLinha,{ "C6_QTDVEN" , zQtdVen,   Nil })
		AAdd(aLinha,{ "C6_PRCVEN" , zPrcVen,   Nil })
		AAdd(aLinha,{ "C6_VALOR"  , zTotal,    Nil })
		AAdd(aLinha,{ "C6_ENTREG" , dDatabase, Nil })
		AAdd(aLinha,{ "C6_TES"    , zTes,      Nil })
		AAdd(aLinha,{ "C6_LOCAL"  , zArmazem,  Nil })
		AAdd(aLinha,{ "C6_UNSVEN" , zUnsVen,   Nil })
		AAdd(aLinha,{ "C6_PRUNIT" , zPrcVen,   Nil })
		AAdd(aLinha,{ "C6_DESCRI" , zDescri,   Nil })
		AAdd(aLinha,{ "C6_CCUSTO" , zCCusto,   Nil })
		AAdd(aLinha,{ "C6_ZZITCTB", zItCtb,    Nil })
		AAdd(aItens,aLinha)		

	Next _ped

	// Itens Faturados
	For _ped := 1 to Len(aFatSc6)
	
		DbSelectArea("SC6")
		SC6->(DbGoto(aFatSc6[_ped]))

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SC6->C6_PRODUTO )
		If SB1->B1_MSBLQL == "1"
			RecLock("SB1",.F.)
			SB1->B1_MSBLQL := "2"
			MsUnLock()
			If aScan(aBlqB1, {|x| x == SB1->B1_COD}) == 0
				AAdd(aBlqB1,SB1->B1_COD)
			Endif
		Endif 
		If SB1->B1_ZBLQVEN == "1"
			RecLock("SB1",.F.)
			SB1->B1_ZBLQVEN := "2"
			MsUnLock()
			If aScan(aBlqVe, {|x| x == SB1->B1_COD}) == 0
				AAdd(aBlqVe,SB1->B1_COD)
			Endif
		Endif 

		zzItem   := SOMA1(zzItem)
		zProduto := SC6->C6_PRODUTO
		zQtdVen  := SC6->C6_QTDENT
		zPrcVen  := SC6->C6_PRCVEN
		zTotal   := Round((zQtdVen * zPrcVen),2)
		zTes     := SC6->C6_TES
		zArmazem := SC6->C6_LOCAL
		zDescri  := SC6->C6_DESCRI
		zUnsVen  := ConvUm(SC6->C6_PRODUTO, zQtdVen, 0, 2)
		zCCusto  := SC6->C6_CCUSTO
		zItCtb   := SC6->C6_ZZITCTB
	
		aLinha := {}			
		AAdd(aLinha,{ "C6_NUM"    , cDoc,      Nil })
		AAdd(aLinha,{ "C6_ITEM"   , zzItem,    Nil })
		AAdd(aLinha,{ "C6_PRODUTO", zProduto,  Nil })
		AAdd(aLinha,{ "C6_QTDVEN" , zQtdVen,   Nil })
		AAdd(aLinha,{ "C6_PRCVEN" , zPrcVen,   Nil })
		AAdd(aLinha,{ "C6_VALOR"  , zTotal,    Nil })
		AAdd(aLinha,{ "C6_ENTREG" , dDatabase, Nil })
		AAdd(aLinha,{ "C6_TES"    , zTes,      Nil })
		AAdd(aLinha,{ "C6_LOCAL"  , zArmazem,  Nil })
		AAdd(aLinha,{ "C6_UNSVEN" , zUnsVen,   Nil })
		AAdd(aLinha,{ "C6_PRUNIT" , zPrcVen,   Nil })
		AAdd(aLinha,{ "C6_DESCRI" , zDescri,   Nil })
		AAdd(aLinha,{ "C6_CCUSTO" , zCCusto,   Nil })
		AAdd(aLinha,{ "C6_ZZITCTB", zItCtb,    Nil })
		AAdd(aLinha,{ "C6_PEDCLI" , "FAT",     Nil })
		AAdd(aItens,aLinha)		

	Next _ped

	Begin Transaction

	lMsErroAuto := .F.
	MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabec, aItens, 3)		
	If !lMsErroAuto			
	
		While (GetSX8Len() > nSaveSX8)
			ConFirmSX8()
		Enddo
	
	Else			
	
		MostraErro()
		DisarmTransaction()
		While (GetSX8Len() > nSaveSX8)
			RollBackSX8()
		Enddo

		MsgAlert("Pedido "+zFilInc+"-"+zNumInc+" não transferido.")
	
	Endif

	If !lMsErroAuto
	
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( cFilAnt + cDoc )

		RecLock("SC5",.F.)
		SC5->C5_ZZDTMOD := zzDtMod
		SC5->C5_ZZUSUAR := zzUsuar
		MsUnLock()	

		// Elimina por Resíduo itens faturados
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek( cFilAnt + cDoc )
		While !Eof() .And. SC6->( C6_FILIAL + C6_NUM ) == cFilAnt + cDoc
			If AllTrim(SC6->C6_PEDCLI) == "FAT"
				RecLock("SC6",.F.)
				SC6->C6_PEDCLI := ""
				SC6->C6_BLQ    := "R"
				MsUnLock()
				//
				DbSelectArea("SB2")
				DbSetOrder(1)
				If DbSeek( SC6->( C6_FILIAL + C6_PRODUTO + C6_LOCAL) )
					RecLock("SB2",.F.)
					SB2->B2_QPEDVEN -= SC6->C6_QTDVEN
					SB2->B2_QPEDVE2 -= SC6->C6_UNSVEN
					MsUnLock()
				Endif
			Endif
			DbSelectArea("SC6")
			SC6->(DbSkip())	
		Enddo	

		For _x := 1 to Len(aBlqB1)
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + aBlqB1[_x] )
			RecLock("SB1",.F.)
			SB1->B1_MSBLQL := "1"
			MsUnLock()
		Next _x	

		For _x := 1 to Len(aBlqVe)
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + aBlqVe[_x] )
			RecLock("SB1",.F.)
			SB1->B1_ZBLQVEN := "1"
			MsUnLock()
		Next _x	
	
		If !Empty(mv_par02)	
			MsgBox("Pedido "+cDoc+" gerado com sucesso !!"+cEOL+;
				   cFilAnt+"-"+FWFilialName()+cEOL+;
				   AllTrim(SA1->A1_NOME),"Aviso","INFO")
		Endif

	Endif

	End Transaction
	MsUnLockAll()

	DbSelectArea("TPED")
	TPED->(DbSkip())
Enddo
TPED->(DbCloseArea())

cFilAnt := cFilBkp

Return
