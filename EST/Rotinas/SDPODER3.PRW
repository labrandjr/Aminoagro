#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SDPODER3 ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 18/07/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Correção saldo em poder de terceiros.    				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SDPODER3()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("SDPODER3",10)
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

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Saldo em Poder de Terceiros" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"SALDO EM PODER DE TERCEIROS"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo recalcular o saldo em poder de terceiros"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"a partir do movimento gerado na tabela sb6."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"Processo temporário - aguardando patch de correção da Totvs."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"Processar a rotina 'Refaz Poder Terceiros' antes."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
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
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  31/10/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento - SALDO EM PODER DE TERCEIROS ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando acerto de saldo em poder de terceiros", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  02/01/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local zFiliais := ""
Local nForFilial

aFilsCalc := MatFilCalc( mv_par05 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

ProcRegua(3)

IncProc("Atualizando registros...")
cQuery := " UPDATE "+RetSqlName("SB2")+" SET B2_QNPT = 0, B2_QTER = 0 "
cQuery += " WHERE B2_FILIAL IN("+zFiliais+") "
cQuery += " AND B2_COD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
TCSQLEXEC(cQuery)

cQuery := " COMMIT "
TCSQLEXEC(cQuery)	

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SB6")
cQuery += " WHERE B6_FILIAL IN("+zFiliais+") "
cQuery += " AND B6_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND B6_PRODUTO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND B6_SALDO > 0 "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQB6", .F., .T.)
nTotSql := SQB6->SOMA
SQB6->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT B6_FILIAL, B6_PRODUTO, B6_LOCAL, B6_ESTOQUE, SUM(B6_SALDO) B6_SALDO "
cQuery += " FROM "+RetSqlName("SB6")
cQuery += " WHERE B6_FILIAL IN("+zFiliais+") "
cQuery += " AND B6_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND B6_PRODUTO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND B6_SALDO > 0 "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY B6_FILIAL, B6_PRODUTO, B6_LOCAL, B6_ESTOQUE "
cQuery += " ORDER BY B6_FILIAL, B6_PRODUTO, B6_LOCAL, B6_ESTOQUE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQB6", .F., .T.)

DbSelectArea("SQB6")
ProcRegua(nTotSql)
SQB6->(DbGotop())
While !Eof()

	oProcess:IncRegua1("Saldo em Poder de Terceiros")

	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek( SQB6->B6_FILIAL + SQB6->B6_PRODUTO + SQB6->B6_LOCAL )

		If SQB6->B6_ESTOQUE == "S"
			RecLock("SB2",.F.)
			SB2->B2_QNPT := SQB6->B6_SALDO
			MsUnLock()
		Endif
	
		If SQB6->B6_ESTOQUE == "N"
			RecLock("SB2",.F.)
			SB2->B2_QTER := SQB6->B6_SALDO
			MsUnLock()
		Endif

	Endif	

	DbSelectArea("SQB6")
	SQB6->(DbSkip())
Enddo
SQB6->(DbCloseArea())

MsgInfo("Processo concluído !!!")

Return
