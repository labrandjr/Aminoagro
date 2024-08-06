#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AWMLTMP   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 16/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga inicial de saldo por lote nas MP.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AWMLTMP()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("AWMS001",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.F.)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Saldo Inicial por Lote nas Matérias-Primas" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,060,{||"SALDO INICIAL POR LOTE NAS MATÉRIAS-PRIMAS"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

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

If MsgYesNo("Confirma o processamento - SALDO POR LOTE MP ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Executando carga inicial...", "Aguarde, processando ...", .F. )
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

Local nTotSql  := 0
Local lProcOk  := .F.
Local dDataVld := StoD("20221231")
Local aVetor   := {}
Private lMsErroAuto := .F.

cQuery := " SELECT COUNT(*)AS SOMA " 
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE B2_FILIAL = '"+xFilial("SB2")+"' " 
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B1_TIPO = 'MP' "
cQuery += " AND B2_QEMP = 0 "
cQuery += " AND B2_RESERVA = 0 "
cQuery += " AND B2_QATU > 0 "
If !Empty(mv_par01)
	cQuery += " AND B2_COD = '"+mv_par01+"' "
Endif	
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

cQuery := " SELECT B2_COD PRODUTO, B2_LOCAL ARMAZEM, B2_QATU QUANT " 
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE B2_FILIAL = '"+xFilial("SB2")+"' " 
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B1_TIPO = 'MP' "
cQuery += " AND B2_QEMP = 0 "
cQuery += " AND B2_RESERVA = 0 "
cQuery += " AND B2_QATU > 0 "
If !Empty(mv_par01)
	cQuery += " AND B2_COD = '"+mv_par01+"' "
Endif	
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY B2_COD, B2_LOCAL "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
oProcess:SetRegua1(nTotSql)
	
DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()
	
	oProcess:IncRegua1("Carga inicial saldo por lote...")
	lProcOk := .T.

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + SQL1->PRODUTO )
	If SB1->B1_RASTRO != "L"
		RecLock("SB1",.F.)
		SB1->B1_RASTRO := "L"
		MsUnLock()
	Endif

	DbSelectArea("SB8")
	DbSetOrder(3)
	If DbSeek( xFilial("SB8") + SQL1->PRODUTO + SQL1->ARMAZEM + "LOTEINICIO" )
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		Loop
	Endif	

	aVetor := {}
	DbSelectArea("SD5")
	
	AAdd(aVetor,{"D5_PRODUTO" ,SQL1->PRODUTO ,NIL})
	AAdd(aVetor,{"D5_LOCAL" ,SQL1->ARMAZEM ,NIL})
	AAdd(aVetor,{"D5_LOTECTL" ,"LOTEINICIO" ,NIL})
	AAdd(aVetor,{"D5_DATA" ,dDatabase ,NIL})
	AAdd(aVetor,{"D5_QUANT" ,SQL1->QUANT ,NIL})
	AAdd(aVetor,{"D5_DTVALID" ,dDataVld ,NIL})

	MsExecAuto({|x,y| Mata390(x,y)}, aVetor, 3)
	If lMsErroAuto
		MostraErro()
		Exit
	Endif

	DbSelectArea("SQL1")
	SQL1->(DbSkip())

Enddo
SQL1->(DbCloseArea())

If !lProcOk
	MsgAlert("Sem dados para processamento. Verifique os parâmetros.")
	Return
Else
	MsgInfo("Processo concluído.")
Endif

Return
