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
¦¦¦Programa  ¦ INCPEDC ¦ Autor ¦ Fábrica ERP.BR  ¦   Data  ¦ 30/10/2019   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Incorporação dos Pedidos de Compra.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function INCPEDC()

Local cPerg	:= Padr("INCPEDC",10)
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

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Incorporação de Pedidos de Compra - Qualyquímica" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"INCORPORAÇÃO DE PEDIDOS DE COMPRA"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo transferir os Pedidos de Compra das unidades DIMICRON"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
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
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  30/10/2019  ¦¦¦
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

If MsgYesNo("Confirma o processamento - INCORP. PEDIDOS DE COMPRA ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando incorporação dos Pedidos de Compra", "Aguarde, processando ...", .F. )
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
Local _ped

Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

cFilAnt := zFilAt // --> Muda filial corrente para Filial Destino

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+zFilDe+"' "
If !Empty(mv_par02)
	cQuery += " AND C7_NUM = '"+mv_par02+"' "
Endif
cQuery += " AND C7_QUJE < C7_QUANT "
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TPED", .F., .T.)
nTotSql := TPED->SOMA
TPED->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT DISTINCT(C7_NUM) PEDIDO "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+zFilDe+"' "
If !Empty(mv_par02)
	cQuery += " AND C7_NUM = '"+mv_par02+"' "
Endif
cQuery += " AND C7_QUJE < C7_QUANT "
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY PEDIDO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TPED", .F., .T.)

DbSelectArea("TPED")
ProcRegua(nTotSql)
TPED->(DbGotop())
While !Eof()
		
	oProcess:IncRegua1("Transferindo Pedidos...")

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( zFilDe + TPED->PEDIDO )

	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek( xFilial("SA2") + SC7->C7_FORNECE )

	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + SC7->C7_COND )

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SC7")
	cQuery += " WHERE C7_ZFILINC = '"+SC7->C7_FILIAL+"' "
	cQuery += " AND C7_ZNUMINC = '"+SC7->C7_NUM+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSC7", .F., .T.)
	lExiste := (TSC7->SOMA > 0)
	TSC7->(DbCloseArea())

	If lExiste
		MsgAlert("Pedido "+SC7->C7_FILIAL+"-"+SC7->C7_NUM+" já cadastrado na Filial "+cFilAnt)
		DbSelectArea("TPED")
		TPED->(DbSkip())
		Loop
	Endif

	zRec := SC7->(Recno())
	aCabec  := {}
	aItens  := {}
	aRecSc7 := {}

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( zFilDe + TPED->PEDIDO )

	While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == zFilDe + TPED->PEDIDO
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SC7->C7_PRODUTO )
		If SB1->B1_MSBLQL != "1"
			AAdd(aRecSc7, SC7->(Recno()))
		Endif	
		DbSelectArea("SC7")
		SC7->(DbSkip())
	Enddo
	SC7->(DbGoto(zRec))

	If Len(aRecSc7) == 0
		DbSelectArea("TPED")
		TPED->(DbSkip())
		Loop
	Endif

	cQuery := " SELECT MAX(C7_NUM)AS NUMPC "
	cQuery += " FROM "+RetSqlName("SC7")
	cQuery += " WHERE C7_FILIAL = '"+cFilAnt+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TNUM", .F., .T.)
	If Eof()
		cDoc := "000001"
	Else
		cDoc := SOMA1(TNUM->NUMPC)
	Endif
	TNUM->(DbCloseArea())

	AAdd(aCabec,{ "C7_NUM"    , cDoc,            Nil })
	AAdd(aCabec,{ "C7_EMISSAO", SC7->C7_EMISSAO, Nil })
	AAdd(aCabec,{ "C7_FORNECE", SC7->C7_FORNECE, Nil })
	AAdd(aCabec,{ "C7_LOJA"   , SC7->C7_LOJA,    Nil })
	AAdd(aCabec,{ "C7_COND"   , SC7->C7_COND,    Nil })
	AAdd(aCabec,{ "C7_CONTATO", SC7->C7_CONTATO, Nil })
	AAdd(aCabec,{ "C7_FILENT" , cFilAnt,         Nil })			
	AAdd(aCabec,{ "C7_USER"   , SC7->C7_USER,    Nil })			
	AAdd(aCabec,{ "C7_ZFILINC", SC7->C7_FILIAL,  Nil })
	AAdd(aCabec,{ "C7_ZNUMINC", SC7->C7_NUM,     Nil })
               
	zFilInc := SC7->C7_FILIAL
	zNumInc := SC7->C7_NUM

	For _ped := 1 to Len(aRecSc7)
	
		DbSelectArea("SC7")
		SC7->(DbGoto(aRecSc7[_ped]))

		zQuant := SC7->(C7_QUANT - C7_QUJE)
		zPreco := SC7->C7_PRECO
		zTotal := Round((zQuant * zPreco),2)
		zObs   := IIf(!Empty(SC7->C7_OBS), SC7->C7_OBS, SC7->C7_DESCRI)

		If zQuant > 0
			aLinha := {}			
			AAdd(aLinha,{ "C7_PRODUTO", SC7->C7_PRODUTO, Nil })
			AAdd(aLinha,{ "C7_QUANT"  , zQuant         , Nil })
			AAdd(aLinha,{ "C7_PRECO"  , zPreco         , Nil })
			AAdd(aLinha,{ "C7_TOTAL"  , zTotal         , Nil })
			AAdd(aLinha,{ "C7_DATPRF" , SC7->C7_DATPRF , Nil })
			AAdd(aLinha,{ "C7_CC"     , SC7->C7_CC     , Nil })
			AAdd(aLinha,{ "C7_OBS"    , zObs           , Nil })
			AAdd(aLinha,{ "C7_LOCAL"  , SC7->C7_LOCAL  , Nil })
			AAdd(aLinha,{ "C7_DESCRI" , SC7->C7_DESCRI , Nil })
			AAdd(aItens,aLinha)		
		Endif
		
	Next _ped

	Begin Transaction

	lMsErroAuto := .F.
	MSExecAuto({|x,y,z,w| MATA120(x,y,z,w)},1, aCabec, aItens, 3)
	If lMsErroAuto			
	
		MostraErro()
		DisarmTransaction()
		MsgAlert("Pedido "+zFilInc+"-"+zNumInc+" não transferido.")
	
	Else	

		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( cFilAnt + cDoc )

		zRec := SC7->(Recno())
		While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == cFilAnt + cDoc
			RecLock("SC7",.F.)
			SC7->C7_ZFILINC := zFilInc 
			SC7->C7_ZNUMINC := zNumInc
			MsUnLock()
			SC7->(DbSkip())
		Enddo
		SC7->(DbGoto(zRec))

		lProjet := .F.	
		DbSelectArea("AJ7")
		DbSetOrder(2)
		If DbSeek( zFilInc + zNumInc )
			lProjet := .T.
			zProjet := AJ7->AJ7_PROJET
			zRevisa := AJ7->AJ7_REVISA
		Endif
		If lProjet
			zRec := SC7->(Recno())
			While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == cFilAnt + cDoc
				RecLock("AJ7",.T.)
				AJ7->AJ7_FILIAL := SC7->C7_FILIAL
				AJ7->AJ7_PROJET := zProjet
				AJ7->AJ7_TAREFA := "01"
				AJ7->AJ7_NUMPC  := SC7->C7_NUM
				AJ7->AJ7_ITEMPC := SC7->C7_ITEM
				AJ7->AJ7_COD    := SC7->C7_PRODUTO
				AJ7->AJ7_QUANT  := 1
				AJ7->AJ7_REVISA := zRevisa
				MsUnLock()
				SC7->(DbSkip())
			Enddo
			SC7->(DbGoto(zRec))
		Endif
			
		If !Empty(mv_par02)
			MsgBox("Pedido "+cDoc+" gerado com sucesso !!"+cEOL+;
				   cFilAnt+"-"+FWFilialName()+cEOL+;
				   AllTrim(SA2->A2_NOME),"Aviso","INFO")
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
