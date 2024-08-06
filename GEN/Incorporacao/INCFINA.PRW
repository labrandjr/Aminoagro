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
¦¦¦Programa  ¦ INCFINA ¦ Autor ¦ Fábrica ERP.BR  ¦   Data  ¦ 04/02/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Incorporação do Módulo Financeiro.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function INCFINA()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("INCFINA",10)
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

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Incorporação do Módulo Financeiro - Qualyquímica" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"INCORPORAÇÃO DO MÓDULO FINANCEIRO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo marcar os registros nas unidades DIMICRON"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"(Filiais 0103 e 0108) para unidades QUALYQUÍMICA (Filiais 0106 e 0107)."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(080,010,{||"Títulos em Aberto."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"Carteira a Receber e Pagar."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
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
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  04/02/2020  ¦¦¦
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

If MsgYesNo("Confirma o processamento - INCORPORAÇÃO MÓDULO FINANCEIRO ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando incorporação do Financeiro", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  04/02/2020 ¦¦¦
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

If mv_par02 == 1 .Or. mv_par02 == 3
	MsgRun("Aguarde, títulos a receber em aberto...","Processando",{|| _CReceb(zFilDe) })
Endif

If mv_par02 == 2 .Or. mv_par02 == 3
	MsgRun("Aguarde, títulos a pagar em aberto...","Processando",{|| _CPagar(zFilDe) })
Endif

Return


Static Function _CReceb(zFilDe)

cQuery := " SELECT R_E_C_N_O_ RECSE1 "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+zFilDe+"' "
cQuery += " AND E1_SALDO > 0  "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSE1", .F., .T.)

DbSelectArea("TSE1")
TSE1->(DbGotop())
While !Eof()
			
	DbSelectArea("SE1")
	SE1->(DbGoto(TSE1->RECSE1))

	RecLock("SE1",.F.)
	SE1->E1_ZZCLIAN := "X"
	MsUnLock()

	// Mov.Bancária
	DbSelectArea("SE5")
	DbSetOrder(7)
	If DbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
		While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		  	RecLock("SE5",.F.)
		  	SE5->E5_PROJPMS := "X"
		  	MsUnLock()
			SE5->(DbSkip())
		Enddo
	Endif
	
	// Borderô
	If !Empty(SE1->E1_NUMBOR)
		DbSelectArea("SEA")
		DbSetOrder(1)
		If DbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
			RecLock("SEA",.F.)
			SEA->EA_VERSAO := "X"
			MsUnLock()	
		Endif
	Endif
	
	DbSelectArea("TSE1")
	TSE1->(DbSkip())
Enddo
TSE1->(DbCloseArea())

Return


Static Function _CPagar(zFilDe)

cQuery := " SELECT R_E_C_N_O_ RECSE2 "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_FILIAL = '"+zFilDe+"' "
cQuery += " AND E2_SALDO > 0  "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSE2", .F., .T.)

DbSelectArea("TSE2")
TSE2->(DbGotop())
While !Eof()
			
	DbSelectArea("SE2")
	SE2->(DbGoto(TSE2->RECSE2))

	RecLock("SE2",.F.)
	SE2->E2_ORDPAGO := "X"
	MsUnLock()

	// Mov.Bancária
	DbSelectArea("SE5")
	DbSetOrder(7)
	If DbSeek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) )
		While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
		  	RecLock("SE5",.F.)
		  	SE5->E5_PROJPMS := "X"
		  	MsUnLock()
			SE5->(DbSkip())
		Enddo
	Endif
	
	// Borderô
	If !Empty(SE2->E2_NUMBOR)
		DbSelectArea("SEA")
		DbSetOrder(1)
		If DbSeek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) )
			RecLock("SEA",.F.)
			SEA->EA_VERSAO := "X"
			MsUnLock()	
		Endif
	Endif

	DbSelectArea("TSE2")
	TSE2->(DbSkip())
Enddo
TSE2->(DbCloseArea())

Return
