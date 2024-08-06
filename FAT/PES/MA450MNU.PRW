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
¦¦¦Programa  ¦ MA450MNU ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 13/09/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na rotina de Liberação de Crédito.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA450MNU()

AAdd(aRotina,{"Lim.Crédito","U_ALTLCRD()", 0, 7, 0, Nil}) 
                                                                             
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AltLCrd ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 13/09/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Interface para alteração dos dados de crédito do cliente.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AltLCrd()

Local aArea   := GetArea()
Local nOpcDwn := 0
Local bActCan := {|| nOpcDwn:=0,oDlgDwn:End() }
Local bActOk  := {|| nOpcDwn:=1,oDlgDwn:End() }
Local bConfir := {|| IIf(MsgYesNo("Confirma alterações ?","Aviso"), Eval(bActOk) , .F.) }
Local zLimite := 0
Local zDatLim := CtoD("")
Local lUsrAlt := .F.
Local oDlgDwn,oFnt2

If __cUserID == "000000"
	lUsrAlt := .T.
Else
	zBU := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_ZZITCTB")
	zCodUsr := AllTrim(Posicione("SX5",1,xFilial("SX5") + "WA" + PadR(zBU,6) ,"X5_DESCRI"))
	zUserId := AllTrim(STR(Val(__cUserID)))
	If zUserId $(zCodUsr)
		lUsrAlt := .T.			
	Endif
Endif

If !lUsrAlt
	MsgAlert("Usuário não pertence à Unid.Negócio.")
	Return
Endif

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + SC9->C9_CLIENTE )
zLimite := SA1->A1_LC
zDatLim := SA1->A1_VENCLC

oFnt2 := TFont():New("Tahoma",,14,,.T.)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376
nLinI := 037

DEFINE MSDIALOG oDlgDwn FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Limite de Crédito" OF oDlgDwn PIXEL

oRepPdc:= TSay():New(nLinI,010,{||""},oDlgDwn,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,150,020)
oRepPdc:SetText("Lim.Crédito")
oRepPdc:CtrlRefresh()
@ nLinI-2,070 MSGET oLimite VAR zLimite SIZE 070,010 OF oDlgDwn PICTURE "999,999,999.99" PIXEL VALID ( zLimite >= 0 )

oRepPdc:= TSay():New(nLinI+15,010,{||""},oDlgDwn,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,150,020)
oRepPdc:SetText("Vencto.Limite")
oRepPdc:CtrlRefresh()
@ nLinI+13,070 MSGET oDatLim VAR zDatLim SIZE 070,010 OF oDlgDwn PIXEL VALID .T.

ACTIVATE MSDIALOG oDlgDwn ON INIT EnchoiceBar(oDlgDwn,bConfir,bActCan) CENTERED

If nOpcDwn == 1
	RecLock("SA1",.F.)
	SA1->A1_LC     := zLimite
	SA1->A1_VENCLC := zDatLim
	MsUnLock()
	MsgInfo("Alteração realizada com sucesso !!")
Endif

RestArea(aArea)

Return
