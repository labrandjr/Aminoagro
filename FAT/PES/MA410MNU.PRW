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
¦¦¦Programa  ¦ MA410MNU ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 23/09/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na rotina de Pedidos de Venda.			  ¦¦¦
¦¦¦          ¦ -> Cópia Modelo 2.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA410MNU()

Public lzCpy := .F. 

AAdd(aRotina,{"Cópia Mod.2"   ,"U_A410COPY()", 0, 7, 0, Nil}) 
AAdd(aRotina,{"Frete | Seguro","U_A410FRSG()", 0, 7, 0, Nil}) 
AAdd(aRotina,{"Importação Csv","U_A410ICSV()", 0, 7, 0, Nil})
                                                                             
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A410FRSG ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 29/01/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Interface para alteração do Frete e Seguro.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A410FRSG()

Local aArea   := GetArea()
Local nOpcDwn := 0
Local bActCan := {|| nOpcDwn:=0,oDlgPed:End() }
Local bActOk  := {|| nOpcDwn:=1,oDlgPed:End() }
Local bCancel := {|| IIf(MsgYesNo("Abandona informações ?","Sair") , Eval(bActCan), .F.) }
Local bConfir := {|| IIf(MsgYesNo("Confirma informações ?","Aviso"), Eval(bActOk) , .F.) }
Local zUsrAut := AllTrim(GetMv("MV_ZUSFRSG"))
Local oDlgPed,oPdc,oFnt2
Private aTpFret := {"CIF","FOB","Por conta terceiros","Sem frete"}
Private zTpFret := ""
Private zFrete  := 0
Private zSeguro := 0

If !(__cUserID $(zUsrAut))
	MsgAlert("Usuário não autorizado. Contate o Administrador.")
	Return
Endif

If SC5->C5_TPFRETE == "C"
	zTpFret := "CIF"
ElseIf SC5->C5_TPFRETE == "F"
	zTpFret := "FOB"
ElseIf SC5->C5_TPFRETE == "T"
	zTpFret := "Por conta terceiros"
ElseIf SC5->C5_TPFRETE == "S"
	zTpFret := "Sem frete"
Endif	
zFrete  := SC5->C5_FRETE
zSeguro := SC5->C5_SEGURO

oFnt2 := TFont():New("Tahoma",,14,,.T.)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 180
nDlg4 := 376
nLinI := 037

DEFINE MSDIALOG oDlgPed FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Pedido "+SC5->C5_NUM OF oDlgPed PIXEL

oRepPdc:= TSay():New(nLinI,010,{||""},oDlgPed,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,150,020)
oRepPdc:SetText("Tipo Frete")
oComboI := TComboBox():New(nLinI-1,070,{|u| If(PCount()>0,zTpFret:=u,zTpFret)},aTpFret,070,013,oDlgPed,,,,,,.T.,,,,,,,,,"zTpFret")

oRepPdc:= TSay():New(nLinI+15,010,{||""},oDlgPed,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,150,020)
oRepPdc:SetText("Frete")
oRepPdc:CtrlRefresh()
@ nLinI+13,070 MSGET oFrete VAR zFrete SIZE 070,010 OF oDlgPed PICTURE "@E 999,999,999.99" PIXEL VALID (zFrete >= 0)

oRepPdc:= TSay():New(nLinI+30,010,{||""},oDlgPed,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,150,020)
oRepPdc:SetText("Seguro")
oRepPdc:CtrlRefresh()
@ nLinI+28,070 MSGET oSeguro VAR zSeguro SIZE 070,010 OF oDlgPed PICTURE "@E 999,999,999.99" PIXEL VALID (zSeguro >= 0)

ACTIVATE MSDIALOG oDlgPed ON INIT EnchoiceBar(oDlgPed,bConfir,bActCan) CENTERED

If nOpcDwn == 1
	RecLock("SC5",.F.)
	If zTpFret == "CIF"
		SC5->C5_TPFRETE := "C"
	ElseIf zTpFret == "FOB"
		SC5->C5_TPFRETE := "F"
	ElseIf zTpFret == "Por conta terceiros"
		SC5->C5_TPFRETE := "T"
	ElseIf zTpFret == "Sem frete"
		SC5->C5_TPFRETE := "S"
	Endif
	SC5->C5_FRETE  := zFrete
	SC5->C5_SEGURO := zSeguro
	MsUnLock()
	MsgInfo("Informações registradas com sucesso !!")
Endif

RestArea(aArea)

Return
