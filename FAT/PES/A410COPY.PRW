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
¦¦¦Funcao    ¦ A410COPY  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  23/09/2017  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Cópia de Pedidos de Venda - Modelo 2.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A410COPY()

Local nOpcDwn := 0
Local bOkDwn  := {|| nOpcDwn:=1,oDlgDwn:End() }
Local bCanDwn := {|| nOpcDwn:=0,oDlgDwn:End() }
Local nRadio1 := 1
Local oDlgDwn,oRadio1

If SC5->C5_TIPO != "N"
	MsgInfo("Cópia modelo2 permitida apenas para Pedidos do Tipo = 'Normal'.")
	Return
Endif

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376

DEFINE MSDIALOG oDlgDwn FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE " " OF oDlgDwn PIXEL
@ 042,065 RADIO oRadio1 VAR nRadio1 3D SIZE 70,11 PROMPT "Pedido completo","Saldo a faturar" OF oDlgDwn PIXEL
ACTIVATE MSDIALOG oDlgDwn ON INIT EnchoiceBar(oDlgDwn,bOkDwn,bCanDwn) CENTERED

If nOpcDwn == 1
	U_A410EXEC(nRadio1)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ A410EXEC  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  23/09/2017  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Execução da cópia de Pedidos de Venda - Modelo 2.		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A410EXEC(nRadio1)

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End() }
Local bActCan := {|| nOpc410:=0,oDlg410:End() }
Local bOk410  := {|| IIf( MsgYesNo("Confirma cópia do pedido?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona cópia do pedido?","Sair"), Eval(bActCan), .F.) }
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM

Private oVerde  := LoadBitmap( GetResources(), "ENABLE" )
Private oVerme  := LoadBitmap( GetResources(), "DISABLE" )
Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)
                                                                   
// Colunas do Folder
Private nFdrLeg := 1
Private nFdrMkb := 2
Private nFdrIte := 3
Private nFdrPrP := 4
Private nFdrUni := 5
Private nFdrQua := 6
Private nFdrPre := 7
Private nFdrTot := 8
Private nFdrTes := 9
Private nFdrLoc := 10
Private nFdrDeP := 11
Private nFdrCCu := 12
Private nFdrUnN := 13

Private cIdPdv  := SC5->C5_NUM
Private oLbx410 := Nil
Private aVet410 := {}
Private oDlg410

Private oCheck1
Private lCheck1 := IIf(nRadio1 == 1,.F.,.T.)
Private oCheck2
Private lCheck2 := IIf(nRadio1 == 1,.T.,.F.)

Private oMenu410
Private lTodas := .F.

Private nTotPed := 0

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )

// Carrega browse no Folder
aVet410 := {}
fCarg410(@aVet410,@cIdPdv,nRadio1)

Menu oMenu410 PopUp
	MenuItem "Marca Todos" 		Action Eval( { || lTodas := .T. , aEval( aVet410 , { |k| k[nFdrMkb] := IIf(k[nFdrLeg],lTodas,.F.) } ) , oLbx410:Refresh() } )
	MenuItem "Desmarca Todos"  	Action Eval( { || lTodas := .F. , aEval( aVet410 , { |k| k[nFdrMkb] := lTodas } ) , oLbx410:Refresh() } )
	MenuItem "Inverter Seleção" Action Eval( { || lTodas := Nil , aEval( aVet410 , { |k| k[nFdrMkb] := IIf(k[nFdrLeg],!k[nFdrMkb],.F.) } ) , oLbx410:Refresh() } )
EndMenu

nDlg1 := 001
nDlg2 := 001
nDlg3 := 440
nDlg4 := 1055 //900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Cópia Mod.2",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

// ******************************************************************************** //
// ** Cabeçalho						                                             ** //
// ******************************************************************************** //
@ 040,005 SAY "Pedido" OF oDlg410 PIXEL SIZE 055,009
@ 039,030 TO 051,080 LABEL "" OF oDlg410 PIXEL
oSayPdc:= TSay():New(042,042,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,100,020)
oSayPdc:CtrlRefresh()
oSayPdc:SetText(cIdPdv)

@ 040,100 SAY "Cliente" OF oDlg410 PIXEL SIZE 055,009
@ 039,130 TO 051,305 LABEL "" OF oDlg410 PIXEL
oSayCli:= TSay():New(042,135,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCli:SetText(SA1->A1_NOME)
oSayCli:CtrlRefresh()

DbSelectArea("SM0")
DbSetOrder(1)
DbSeek( SM0->M0_CODIGO + SC5->C5_FILIAL )

@ 040,400 SAY "Filial" OF oDlg410 PIXEL SIZE 055,009
@ 039,425 TO 051,520 LABEL "" OF oDlg410 PIXEL
oSayOpe:= TSay():New(042,430,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,100,020)
oSayOpe:SetText(SC5->C5_FILIAL+" - "+AllTrim(SM0->M0_FILIAL))
oSayOpe:CtrlRefresh()

oSayLCon:= TSay():New(059,005,{||""},oDlg410,,oFnt4,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayLCon:SetText("DETALHES DA CÓPIA")
oSayLCon:CtrlRefresh()

@ 065,005 TO 113,520 LABEL "" OF oDlg410 PIXEL

cFilDes := SC5->C5_FILIAL
cNomFil := AllTrim(SM0->M0_FILIAL)
@ 075,010 SAY "Filial" OF oDlg410 PIXEL SIZE 055,009
@ 074,035 MSGET oFilDes VAR cFilDes SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SM0" VALID VldFil()
@ 074,090 TO 086,265 LABEL "" OF oDlg410 PIXEL
oSayFil:= TSay():New(077,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayFil:SetText( AllTrim(cNomFil) )
oSayFil:CtrlRefresh()

cCliDes := SA1->A1_COD
cNomCli := AllTrim(SA1->A1_NOME)
@ 095,010 SAY "Cliente" OF oDlg410 PIXEL SIZE 055,009
@ 094,035 MSGET oCliDes VAR cCliDes SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "CLI" VALID VldCli()
@ 094,090 TO 106,265 LABEL "" OF oDlg410 PIXEL
oSayCli:= TSay():New(097,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayCli:SetText( AllTrim(cNomCli) )
oSayCli:CtrlRefresh()

cOpeDes := IIf(Empty(SC5->C5_ZZTPBON),"01","04")
cNomOpe := Substr(Posicione("SX5",1,xFilial("SX5") + "DJ" + PadR(cOpeDes,6) ,"X5_DESCRI"),1,25)
@ 095,310 SAY "Tp.Operação" OF oDlg410 PIXEL SIZE 055,009
@ 094,345 MSGET oOpeDes VAR cOpeDes SIZE 025,010 OF oDlg410 PIXEL PICTURE "@!" F3 "DJ" VALID VldOpe()
@ 094,375 TO 106,470 LABEL "" OF oDlg410 PIXEL
oSayOpe:= TSay():New(097,383,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayOpe:SetText( AllTrim(cNomOpe) )
oSayOpe:CtrlRefresh()

oCheck1 := TCheckBox():New(070,280,"Subtrair quantidade no pedido origem",{|u|IIf(PCount()>0,lCheck1:=u,lCheck1)},oDlg410,100,210,,,,,,,,.T.,,,)
oCheck2 := TCheckBox():New(070,405,"Atualizar vendedores do cliente",{|u|IIf(PCount()>0,lCheck2:=u,lCheck2)},oDlg410,100,210,,,,,,,,.T.,,,)

@ 202,418 SAY "Total R$" OF oDlg410 PIXEL SIZE 055,009
@ 201,448 MSGET oTotPed VAR nTotPed PICTURE PesqPict("SC6","C6_VALOR",,1) OF oDlg410 PIXEL WHEN .F. SIZE 070,009

nBrw1 := 116
nBrw2 := 005
nBrw3 := 520 //440
nBrw4 := 078

oLbx410 := TWBrowse():New(nBrw1,nBrw2,nBrw3,nBrw4,,,,oDlg410,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx410:AddColumn( TcColumn():New( "  "    	         ,{ || IIf(aVet410[oLbx410:nAt][nFdrLeg],oVerde,oVerme) } , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "  "  	         ,{ || IIf(aVet410[oLbx410:nAt][nFdrMkb],oOk,oNo) }       , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )     						
oLbx410:AddColumn( TcColumn():New( "Item"            ,{ || aVet410[oLbx410:nAt][nFdrIte] } , "@!"	                ,,,"LEFT"	,015,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Produto"         ,{ || aVet410[oLbx410:nAt][nFdrPrP] } , "@!"                   ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "U.M."            ,{ || aVet410[oLbx410:nAt][nFdrUni] } , "@!"                   ,,,"CENTER"	,015,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Quantidade"      ,{ || aVet410[oLbx410:nAt][nFdrQua] } , "@E 999,999.99"        ,,,"RIGHT"	,040,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Prc Unitário"    ,{ || aVet410[oLbx410:nAt][nFdrPre] } , "@E 99,999,999.99"     ,,,"RIGHT"	,040,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Vlr.Total"       ,{ || aVet410[oLbx410:nAt][nFdrTot] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,040,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Tipo Saída"      ,{ || aVet410[oLbx410:nAt][nFdrTes] } , "@!"                   ,,,"CENTER"	,035,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Armazém"         ,{ || aVet410[oLbx410:nAt][nFdrLoc] } , "@!"                   ,,,"CENTER"	,030,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Descrição"       ,{ || aVet410[oLbx410:nAt][nFdrDeP] } , "@!"                   ,,,"LEFT"	,110,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "C.Custo"         ,{ || aVet410[oLbx410:nAt][nFdrCCu] } , "@!"                   ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "UN Negócio"      ,{ || aVet410[oLbx410:nAt][nFdrUnN] } , "@!"                   ,,,"LEFT"	,035,.F.,.F.,,,,.F.,) )

oLbx410:SetArray(aVet410)
oLbx410:bHeaderClick := { |o,x,y| IIf( x == nFdrMkb , oMenu410:Activate(x,y,oLbx410) , fHeaderR( o , x , y , @oLbx410 , @lTodas , @aVet410 ) ) }					
oLbx410:bLDblClick   := { || fClickR(@oLbx410,@aVet410,oLbx410:nAt,oLbx410:nColPos) }

oDlg410:Activate(,,,.T.,{|| _Validar(aVet410,nRadio1,cFilDes,cCliDes,lCheck1,lCheck2) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	MsgRun("Gerando cópia do pedido... aguarde","Processando",{|| _SendCopy(aVet410,cFilDes,cCliDes,nRadio1,lCheck1,lCheck2,SC5->C5_FILIAL,cIdPdv) })
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldFil    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 25/09/2017   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da filial destino. 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldFil()

Local lRetorno := .F.
Local nRecSM0  := SM0->(Recno())

DbSelectArea("SM0")
DbSetOrder(1)
If DbSeek( SM0->M0_CODIGO + cFilDes )
	lRetorno := .T.
Else
	SM0->(DbGoto(nRecSM0))
Endif

If lRetorno
	cNomFil := Posicione("SM0",1,SM0->M0_CODIGO + cFilDes,"M0_FILIAL")
	oSayFil:SetText( AllTrim(cNomFil) )
	oSayFil:CtrlRefresh()
	UpdCodTes(cFilDes,cCliDes,cOpeDes)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCli    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 25/09/2017   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do cliente destino. 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCli()

Local lRetorno := .F.

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek( xFilial("SA1") + cCliDes )
	lRetorno := .T.
Endif

If lRetorno
	cNomCli := Posicione("SA1",1,xFilial("SA1") + cCliDes,"A1_NOME")
	oSayCli:SetText( AllTrim(cNomCli) )
	oSayCli:CtrlRefresh()
	UpdCodTes(cFilDes,cCliDes,cOpeDes)
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldOpe    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 18/10/2017   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do tipo de operação.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldOpe()

Local lRetorno := .F.

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek( xFilial("SX5") + "DJ" + PadR(cOpeDes,6) )
	lRetorno := .T.
Endif

If lRetorno
	cNomOpe := Substr(Posicione("SX5",1,xFilial("SX5") + "DJ" + PadR(cOpeDes,6) ,"X5_DESCRI"),1,25)
	oSayOpe:SetText( AllTrim(cNomOpe) )
	oSayOpe:CtrlRefresh()
	UpdCodTes(cFilDes,cCliDes,cOpeDes)
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdCodTes ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  18/10/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia Tes Inteligente.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function UpdCodTes(zFil,zCli,zOpe)

Local cFilBkp := cFilAnt
Local zProd := ""
Local zzTes := ""
Local _z

cFilAnt := zFil
For _z := 1 to Len(aVet410)
	zProd := aVet410[_z][nFdrPrP]
	zzTes := MaTesInt(2,zOpe,zCli,"01","C",zProd)
	If !Empty(zzTes)
		aVet410[_z][nFdrTes] := zzTes
	Endif	
Next _z
oLbx410:Refresh()

cFilAnt := cFilBkp

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg410 ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  23/09/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados no browse Cópia Mod.2.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg410(aVet410,cIdPdv,nRadio1)

If nRadio1 == 1 // Pedido completo
	cQuery := " SELECT C6_ITEM, C6_PRODUTO, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_TES, C6_LOCAL, C6_CCUSTO, C6_ZZITCTB, C6_DESCRI "
Else
	cQuery := " SELECT C6_ITEM, C6_PRODUTO, C6_UM, (C6_QTDVEN-C6_QTDENT) AS C6_QTDVEN, C6_PRCVEN, ((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN) AS C6_VALOR, "
	cQuery += " C6_TES, C6_LOCAL, C6_CCUSTO, C6_ZZITCTB, C6_DESCRI "
Endif
cQuery += " FROM "+RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " AND C6_NUM = '"+cIdPdv+"' "
If nRadio1 == 2 // Saldo a faturar
	cQuery += " AND (C6_QTDVEN-C6_QTDENT) > 0 "
	cQuery += " AND C6_BLQ <> 'R' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C6_FILIAL, C6_NUM, C6_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"T410", .F., .T.)
T410->(DbGotop())
While !Eof()

	AAdd(aVet410,{ .T.,;
				   .T.,;
				   T410->C6_ITEM,;
				   T410->C6_PRODUTO,;
				   T410->C6_UM,;
				   T410->C6_QTDVEN,;
				   T410->C6_PRCVEN,;
				   T410->C6_VALOR,;
				   T410->C6_TES,;
				   T410->C6_LOCAL,;
				   T410->C6_DESCRI,;
				   T410->C6_CCUSTO,;
				   T410->C6_ZZITCTB })

	nTotPed += T410->C6_VALOR

	DbSelectArea("T410")
	T410->(DbSkip())

Enddo
T410->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClickR    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦ 23/09/2017   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do Folder.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClickR(oLbx410,aVet410,nLin,nCol) 

Local _z

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + aVet410[nLin][nFdrPrP] )

If nCol == nFdrMkb // Markbrowse
	If aVet410[nLin][nFdrLeg] // Somente legenda Verde
		aVet410[nLin][nCol] := !aVet410[nLin][nCol]
	Endif	
	nTotPed := 0
	For _z := 1 to Len(aVet410)
		If aVet410[_z][nFdrMkb]
			nTotPed += aVet410[_z][nFdrTot]
		Endif	
	Next _z
Endif

If nCol == nFdrQua // Quantidade
	If aVet410[nLin][nFdrLeg] // Somente legenda Verde
		nVal := aVet410[nLin][nCol]
		lEditCell( @aVet410 , @oLbx410 , "@E 999,999.99" , nCol ) 
		If aVet410[nLin][nCol] != nVal // Checa se alterou o conteúdo
			If aVet410[nLin][nCol] <= 0
				Alert("Quantidade não informada.")
				aVet410[nLin][nCol] := nVal
			Else
				aVet410[nLin][nFdrTot] := aVet410[nLin][nCol] * aVet410[nLin][nFdrPre]
				nTotPed := 0
				For _z := 1 to Len(aVet410)
					If aVet410[_z][nFdrMkb]
	   					nTotPed += aVet410[_z][nFdrTot]
	   				Endif	
				Next _z
			Endif
		Endif	
	Endif
Endif

oTotPed:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeaderR ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦ 23/09/2017	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fHeaderR(oObj,nCol,nLin,oLbx410,lTodas,aVet410)

oLbx410:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 23/09/2017	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validacao geral da interface.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Validar(aVet410,nRadio1,cFilDes,cCliDes,lCheck1,lCheck2)

Local lRetorno  := .T.
Local cTesBon   := AllTrim(GetMv("MV_XTESBON")) // TES para Bonificação
Local lCultura  := GetMv("MV_ZZCULTU")
Local lRemBon   := .F.
Local cEOL      := CHR(13)+CHR(10)
Local _ped

If Len(aVet410) > 0
	// Verifica se pelo menos 1 item foi selecionado
	lSelec := .F.
	For _ped := 1 to Len(aVet410)
		If aVet410[_ped][nFdrMkb]
			lSelec := .T.
			Exit	
		Endif
	Next _ped
	If !lSelec
		lRetorno := .F.
		MsgInfo("Nenhum item selecionado.")
	Endif
Endif

If lCultura
	If lRetorno
		For _ped := 1 to Len(aVet410)
			If aVet410[_ped][nFdrMkb]
				zCodPro := aVet410[_ped][nFdrPrP]
				zTipSai := aVet410[_ped][nFdrTes]
				//
				cTPed := SC5->C5_TIPO
				zTipo := RetField("SB1",1,xFilial("SB1")+zCodPro,"B1_TIPO")
				lEstq := ( RetField("SF4",1,xFilial("SF4")+zTipSai,"F4_ESTOQUE") == "S" )
				lDupl := ( RetField("SF4",1,xFilial("SF4")+zTipSai,"F4_DUPLIC") == "S" )
				//
				lVenda	:= ( cTPed == "N" .And. zTipo != "SV" .And. Empty(SC5->C5_ZZTPBON) .And. lEstq .And. lDupl )
				If lVenda
					If Empty(SC5->C5_ZZCULT)
						MsgInfo("Cultura não informada no pedido origem.")
						lRetorno := .F.
						Exit
					Endif	
				Endif
			Endif	
		Next _ped
	Endif
Endif

// Avalia se trata-se de operação de Bonificação
If Len(aVet410) > 0
	For _ped := 1 to Len(aVet410)
		If aVet410[_ped][nFdrMkb]
			cTesIt := aVet410[_ped][nFdrTes]
			If cTesIt $(cTesBon)
				lRemBon := .T.
				Exit
			Endif
		Endif
	Next _ped
Endif
If lRemBon
	If Empty(SC5->C5_ZZTPBON)
		MsgAlert("Atenção, Pedido origem não possui tipo de bonificação.")
		Return(.F.)
	Endif
Endif

// Vendedor1 em branco com Faixa de comissão1 informada
zVend1 := IIf(lCheck2, SA1->A1_VEND, SC5->C5_VEND1) // Usuário decide se atualiza os vendedores do cliente
If Empty(zVend1) .And. !Empty(SC5->C5_ZZCDFXV)
	MsgAlert("Faixa de Comissão informada para o Vendedor1 sem relacionamento.")
	Return(.F.)
Endif

// Vendedor2 em branco com Faixa de comissão2 informada
zVend2 := IIf(lCheck2, SA1->A1_ZZREVEN, SC5->C5_VEND2) // Usuário decide se atualiza os vendedores do cliente
If Empty(zVend2) .And. !Empty(SC5->C5_ZZCDFXR)
	MsgAlert("Faixa de Comissão informada para o Vendedor2 sem relacionamento.")
	Return(.F.)
Endif

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek( xFilial("SE4") + SC5->C5_CONDPAG )
If SE4->E4_TIPO == "9"
	If Empty(SC5->C5_DATA1) .And. Empty(SC5->C5_DATA2) .And. Empty(SC5->C5_DATA3) .And. Empty(SC5->C5_DATA4)
		MsgAlert("Pedido original sem o(s) vencimento(s) da(s) parcela(s) para condição de pagamento Tipo 9.")
		Return(.F.)
	ElseIf Empty(SC5->C5_PARC1) .And. Empty(SC5->C5_PARC2) .And. Empty(SC5->C5_PARC3) .And. Empty(SC5->C5_PARC4)
		MsgAlert("Pedido original sem o(s) valor(es) da(s) parcela(s) para condição de pagamento Tipo 9.")
		Return(.F.)
	Endif
Endif

If lRetorno
	aItEmb   := {}
	lVldEmb  := ( AllTrim(GetMv("MV_XVLDEMB"))=="S" )
	If lVldEmb
		For _ped := 1 to Len(aVet410)
			If aVet410[_ped][nFdrMkb]
				zCodPro := aVet410[_ped][nFdrPrP]
				zTipSai := aVet410[_ped][nFdrTes]
				//
				lVend := ( SC5->C5_TIPO == "N" )
				lEstq := ( RetField("SF4",1,xFilial("SF4")+zTipSai,"F4_ESTOQUE") == "S" )
				zTipo := RetField("SB1",1,xFilial("SB1")+zCodPro,"B1_TIPO")
				lAddP := .F.
				If lVend .And. lEstq
					If zTipo == "PA"
						DbSelectArea("SG1")
						DbSetOrder(1)
						If DbSeek( xFilial("SG1") + zCodPro )
		                	lAddP := .T.
						Endif
					ElseIf zTipo == "PR"
						lAddP := .T.
					Endif	
				Endif
				If lAddP
					zPedi := SC5->C5_NUM
					zItem := aVet410[_ped][nFdrIte]
					zSequ := ""
					zProd := zCodPro
					zQtde := aVet410[_ped][nFdrQua]
					AAdd(aItEmb,{zPedi, zItem, zSequ, zProd, zQtde, "PED"})
				Endif
			Endif	
		Next _ped
	Endif
	If Len(aItEmb) > 0
		lRetorno := u_VldEmblg(aItEmb)
	Endif
Endif

If lRetorno
	cFilBkp := cFilAnt
	cFilAnt := cFilDes
	For _ped := 1 to Len(aVet410)
		//
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + cCliDes )
		//
		If aVet410[_ped][nFdrMkb]
			zItemPv  := aVet410[_ped][nFdrIte]
			zProduto := aVet410[_ped][nFdrPrP]
			zQtdVen  := aVet410[_ped][nFdrQua]
			zPrcVen  := aVet410[_ped][nFdrPre]
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + zProduto )
			If SB1->B1_MSBLQL == "1" // Produto bloqueado
				MsgAlert("O produto "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+" está bloqueado para uso.")
				lRetorno := .F.
				Exit
			Endif
			If SB1->B1_ZBLQVEN == "1" // Produto bloqueado p/ Vendas
				MsgAlert("O produto "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+" está bloqueado p/ Vendas.")
				lRetorno := .F.
				Exit
			Endif
			zTipoPrd := SB1->B1_TIPO
			zTes     := aVet410[_ped][nFdrTes]
			zVend1   := IIf(lCheck2, SA1->A1_VEND, SC5->C5_VEND1) // Usuário decide se atualiza os vendedores do cliente
			zCCVend  := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_ZZCC")
			zUniNeg  := RetField("CTT",1,xFilial("CTT")+zCCVend,"CTT_ZZITCT")
			lMovFin  := .F.
			DbSelectArea("SF4")
			DbSetOrder(1)
			If DbSeek( xFilial("SF4") + zTes )
				If SF4->F4_ESTOQUE == "S" .And. SF4->F4_DUPLIC == "S"
					lMovFin := .T.
				Endif
			Endif
			lVenda := ( SC5->C5_TIPO == "N" .And. zTipoPrd != "SV" .And. Empty(SC5->C5_ZZTPBON) .And. lMovFin )
			If lVenda
				lRetorno := U_VldLin(.T.,zItemPv,zProduto,zQtdVen,zPrcVen,zCCVend,zUniNeg,.F.)
				If !lRetorno
					Exit
				Endif
			Endif
		Endif
	Next _ped
	cFilAnt := cFilBkp
Endif

If lRetorno
	If lCheck1
		For _ped := 1 to Len(aVet410)
			If aVet410[_ped][nFdrMkb]
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek( SC5->C5_FILIAL + cIdPdv + aVet410[_ped][nFdrIte] )
				If SC6->C6_QTDLIB > 0 .Or. SC6->C6_QTDEMP > 0
					MsgInfo("Item "+SC6->C6_ITEM+": "+cEOL+;
							"O pedido origem possui itens liberados."+cEOL+;
							"Desmarque a opção 'subtrair quantidade no pedido origem' ou estorne a liberação para prosseguir.")
					lRetorno := .F.
					Exit
				Endif
			Endif
		Next _ped
	Endif
Endif

If lRetorno
	If lCheck1
		For _ped := 1 to Len(aVet410)
			If aVet410[_ped][nFdrMkb]
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek( SC5->C5_FILIAL + cIdPdv + aVet410[_ped][nFdrIte] )
				nQtDisp := SC6->C6_QTDVEN - SC6->C6_QTDENT
				If nQtDisp < aVet410[_ped][nFdrQua]
						MsgInfo("Item "+SC6->C6_ITEM+": "+cEOL+;
								"O saldo no pedido origem ("+AllTrim(STR(nQtDisp,12,2))+") "+;
								"é menor que a quantidade informada ("+AllTrim(STR(aVet410[_ped][nFdrQua],12,2))+")."+cEOL+;
								"Desmarque a opção 'subtrair quantidade no pedido origem' ou altere a quantidade para prosseguir.")
					lRetorno := .F.
					Exit
				Endif
			Endif
		Next _ped
	Endif
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _SendCopy ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 23/09/2017	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria uma cópia do pedido de venda.			  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _SendCopy(aVet410,cFilDes,cCliDes,nRadio1,lCheck1,lCheck2,cFilOri,cIdPdv)

Local cEOL    := CHR(13)+CHR(10)
Local aCabec  := {}
Local aItens  := {}
Local aAbate  := {}
Local nNumIt  := 0
Local cFilBkp := cFilOri
Local _ped, _x

Private nSaveSX8 := IIf(Type("nSaveSx8")=="U", GetSX8Len(), nSaveSX8)
Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

cFilAnt := cFilDes // --> Muda filial corrente para Filial Destino

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + cCliDes ) // --> Posisiona no Cliente Destino

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek( xFilial("SE4") + SC5->C5_CONDPAG ) // --> Posisiona na Condição de Pagamento

z5Parc1 := SC5->C5_PARC1
z5Data1 := IIf(!Empty(SC5->C5_DATA1) .And. SC5->C5_DATA1 < Date(), u_NewData410("Vencimento 1",SC5->C5_DATA1), SC5->C5_DATA1)
z5Per01 := 0
z5Parc2 := SC5->C5_PARC2
z5Data2 := IIf(!Empty(SC5->C5_DATA2) .And. SC5->C5_DATA2 < Date(), u_NewData410("Vencimento 2",SC5->C5_DATA2), SC5->C5_DATA2)
z5Per02 := 0
z5Parc3 := SC5->C5_PARC3
z5Data3 := IIf(!Empty(SC5->C5_DATA3) .And. SC5->C5_DATA3 < Date(), u_NewData410("Vencimento 3",SC5->C5_DATA3), SC5->C5_DATA3)
z5Per03 := 0
z5Parc4 := SC5->C5_PARC4
z5Data4 := IIf(!Empty(SC5->C5_DATA4) .And. SC5->C5_DATA4 < Date(), u_NewData410("Vencimento 4",SC5->C5_DATA4), SC5->C5_DATA4)
z5Per04 := 0

If SE4->E4_TIPO == "9" .And. AllTrim(SE4->E4_COND) == "0"
	// % original
	zTotOri := SC5->(C5_PARC1+C5_PARC2+C5_PARC3+C5_PARC4)
	z5Per01 := Round(((SC5->C5_PARC1 / zTotOri) * 100),0)
	z5Per02 := Round(((SC5->C5_PARC2 / zTotOri) * 100),0)
	z5Per03 := Round(((SC5->C5_PARC3 / zTotOri) * 100),0)
	z5Per04 := (100 - (z5Per01 + z5Per02 + z5Per03))
	// Total selecionado
	zTotSel := 0
	For _ped := 1 to Len(aVet410)
		If aVet410[_ped][nFdrMkb]
			zTotSel += aVet410[_ped][nFdrTot]
		Endif	
	Next _ped
	//
	z5Parc1 := (zTotSel * (z5Per01/100))
	z5Parc2 := (zTotSel * (z5Per02/100))
	z5Parc3 := (zTotSel * (z5Per03/100))
	z5Parc4 := (zTotSel - (z5Parc1 + z5Parc2 + z5Parc3))
	//
Endif

zVend1    := IIf(lCheck2, SA1->A1_VEND, SC5->C5_VEND1)  // Usuário decide se atualiza os vendedores do cliente
zVend2    := IIf(lCheck2, SA1->A1_ZZREVEN, SC5->C5_VEND2)  // Usuário decide se atualiza os vendedores do cliente
zVend3    := IIf(lCheck2, Space(6), SC5->C5_VEND3)  // Usuário decide se atualiza os vendedores do cliente
zVend4    := IIf(lCheck2, Space(6), SC5->C5_VEND4)  // Usuário decide se atualiza os vendedores do cliente
zRegVen   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_REGIAO")
zCCVend   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_ZZCC")
zUniNeg   := RetField("CTT",1,xFilial("CTT")+zCCVend,"CTT_ZZITCT")
zSuper1   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_SUPER")
zSuper2   := RetField("SA3",1,xFilial("SA3")+zVend2,"A3_SUPER")
zGeren1   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_GEREN")
zGeren2   := RetField("SA3",1,xFilial("SA3")+zVend2,"A3_GEREN")
zDesMer   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_ZZDM")
zTxMoed   := RecMoeda(Date(),SC5->C5_MOEDA)
zPrjAmi   := SC5->C5_XPRJAMI
zCultura  := SC5->C5_ZZCULT
zEbtDig   := SC5->C5_ZEBTDIG
z5CondPag := SC5->C5_CONDPAG
z5ZZCDFXV := SC5->C5_ZZCDFXV
z5ZZCDFXR := SC5->C5_ZZCDFXR
z5ZCDFXR3 := SC5->C5_ZCDFXR3
z5ZCDFXR4 := SC5->C5_ZCDFXR4
z5ZZPPONT := SC5->C5_ZZPPONT
z5ZZVPONT := SC5->C5_ZZVPONT
z5ZZTPBON := SC5->C5_ZZTPBON
z5TpFrete := IIf(!Empty(SC5->C5_TPFRETE),SC5->C5_TPFRETE,"C")
z5Frete   := SC5->C5_FRETE
z5Transp  := SC5->C5_TRANSP
z5Moeda   := SC5->C5_MOEDA
z5PesoL   := SC5->C5_PESOL
z5PBruto  := SC5->C5_PBRUTO
z5FecEnt  := SC5->C5_FECENT
zAbtSaldo := IIf(lCheck1,"S","N")

nCnt := 0
cDoc := GetSXENum("SC5","C5_NUM")		
RollBackSX8()
SC5->(DbSetOrder(1))		
While SC5->(DbSeek(xFilial("SC5")+cDoc))			
	ConfirmSX8()			
	cDoc := GetSXENum("SC5","C5_NUM")
	RollBackSX8()
	nCnt += 1
	If nCnt > 10 // Caso haja mais de 10 tentativas, corrigir o sxe/sxf.
		MsgInfo("Falha no sequenciamento da numeração de pedidos. Contate o Administrador.")
		Return
	Endif
EndDo					

AAdd(aCabec,{ "C5_NUM"    , cDoc,            Nil })
AAdd(aCabec,{ "C5_TIPO"   , "N",             Nil })
AAdd(aCabec,{ "C5_CLIENTE", SA1->A1_COD,     Nil })
AAdd(aCabec,{ "C5_LOJACLI", SA1->A1_LOJA,    Nil })
AAdd(aCabec,{ "C5_CLIENT" , SA1->A1_COD,     Nil })
AAdd(aCabec,{ "C5_LOJAENT", SA1->A1_LOJA,    Nil })
AAdd(aCabec,{ "C5_TIPOCLI", SA1->A1_TIPO,    Nil })			
AAdd(aCabec,{ "C5_CONDPAG", z5CondPag,       Nil })
AAdd(aCabec,{ "C5_VEND1"  , zVend1,          Nil })
AAdd(aCabec,{ "C5_ZZCDFXV", z5ZZCDFXV,       Nil })
AAdd(aCabec,{ "C5_VEND2"  , zVend2,          Nil })
AAdd(aCabec,{ "C5_ZZCDFXR", z5ZZCDFXR,       Nil })
AAdd(aCabec,{ "C5_VEND3"  , zVend3,          Nil })
AAdd(aCabec,{ "C5_ZCDFXR3", z5ZCDFXR3,       Nil })
AAdd(aCabec,{ "C5_VEND4"  , zVend4,          Nil })
AAdd(aCabec,{ "C5_ZCDFXR4", z5ZCDFXR4,       Nil })
AAdd(aCabec,{ "C5_ZZREGVE", zRegVen,         Nil })
AAdd(aCabec,{ "C5_ZZITCTB", zUniNeg,         Nil })
AAdd(aCabec,{ "C5_XPRJAMI", zPrjAmi,         Nil })
AAdd(aCabec,{ "C5_ZZCULT" , zCultura,        Nil })
AAdd(aCabec,{ "C5_ZEBTDIG", zEbtDig,         Nil })
AAdd(aCabec,{ "C5_PARC1"  , z5Parc1,         Nil })
AAdd(aCabec,{ "C5_DATA1"  , z5Data1,         Nil })
AAdd(aCabec,{ "C5_PARC2"  , z5Parc2,         Nil })
AAdd(aCabec,{ "C5_DATA2"  , z5Data2,         Nil })
AAdd(aCabec,{ "C5_PARC3"  , z5Parc3,         Nil })
AAdd(aCabec,{ "C5_DATA3"  , z5Data3,         Nil })
AAdd(aCabec,{ "C5_PARC4"  , z5Parc4,         Nil })
AAdd(aCabec,{ "C5_DATA4"  , z5Data4,         Nil })
AAdd(aCabec,{ "C5_ZZPPONT", z5ZZPPONT,       Nil })
AAdd(aCabec,{ "C5_ZZVPONT", z5ZZVPONT,       Nil })
AAdd(aCabec,{ "C5_ZZTPBON", z5ZZTPBON,       Nil })
AAdd(aCabec,{ "C5_TPFRETE", z5TpFrete,       Nil })
AAdd(aCabec,{ "C5_FRETE"  , z5Frete,         Nil })
AAdd(aCabec,{ "C5_TRANSP" , z5Transp,        Nil })
AAdd(aCabec,{ "C5_MOEDA"  , z5Moeda,         Nil })
AAdd(aCabec,{ "C5_TXMOEDA", zTxMoed,         Nil })
AAdd(aCabec,{ "C5_EMISSAO", Date(),          Nil })
AAdd(aCabec,{ "C5_PESOL"  , z5PesoL,         Nil })
AAdd(aCabec,{ "C5_PBRUTO" , z5PBruto,        Nil })
AAdd(aCabec,{ "C5_FECENT" , z5FecEnt,        Nil })
AAdd(aCabec,{ "C5_SUPER1" , zSuper1,         Nil })
AAdd(aCabec,{ "C5_SUPER2" , zSuper2,         Nil })
AAdd(aCabec,{ "C5_GEREN1" , zGeren1,         Nil })
AAdd(aCabec,{ "C5_GEREN2" , zGeren2,         Nil })
AAdd(aCabec,{ "C5_ZZDM"   , zDesMer,         Nil })
AAdd(aCabec,{ "C5_COPMOD2", "S",             Nil })
AAdd(aCabec,{ "C5_ABTSALD", zAbtSaldo,       Nil })
AAdd(aCabec,{ "C5_FILORIG", cFilOri,         Nil })
AAdd(aCabec,{ "C5_PEDORIG", cIdPdv,          Nil })

For _ped := 1 to Len(aVet410)

	If aVet410[_ped][nFdrMkb]

		nNumIt += 1
		zzItem := StrZero(nNumIt,TamSx3("C6_ITEM")[1])

		zItemOri := aVet410[_ped][nFdrIte]
		zProduto := aVet410[_ped][nFdrPrP]
		zQtdVen  := aVet410[_ped][nFdrQua]
		zPrcVen  := aVet410[_ped][nFdrPre]
		zTotal   := aVet410[_ped][nFdrTot]
		zEntrega := IIf(!Empty(z5FecEnt), z5FecEnt, dDatabase)
		zTes     := aVet410[_ped][nFdrTes]
		zArmazem := aVet410[_ped][nFdrLoc]
		zDescri  := aVet410[_ped][nFdrDeP]
		zUnsVen  := ConvUm(zProduto, zQtdVen, 0, 2)
		zCCusto  := ""
		If AllTrim(zProduto) == "SERV0001"
			zCCusto := "106040801001"
		ElseIf !Empty(zVend1)
			DbSelectArea("SA3")
			DbSetOrder(1)
			If DbSeek( xFilial("SA3") + zVend1 )
				zCCusto := SA3->A3_ZZCC
			Endif
		Endif
		zItCtb := RetField("CTT",1,xFilial("CTT")+zCCusto,"CTT_ZZITCT")

		aLinha := {}			
		AAdd(aLinha,{ "C6_NUM"    , cDoc,     Nil })
		AAdd(aLinha,{ "C6_ITEM"   , zzItem,   Nil })
		AAdd(aLinha,{ "C6_PRODUTO", zProduto, Nil })
		AAdd(aLinha,{ "C6_QTDVEN" , zQtdVen,  Nil })
		AAdd(aLinha,{ "C6_PRCVEN" , zPrcVen,  Nil })
		AAdd(aLinha,{ "C6_VALOR"  , zTotal,   Nil })
		AAdd(aLinha,{ "C6_ENTREG" , zEntrega, Nil })
		AAdd(aLinha,{ "C6_TES"    , zTes,     Nil })
		AAdd(aLinha,{ "C6_LOCAL"  , zArmazem, Nil })
		AAdd(aLinha,{ "C6_UNSVEN" , zUnsVen,  Nil })
		AAdd(aLinha,{ "C6_PRUNIT" , zPrcVen,  Nil })
		AAdd(aLinha,{ "C6_DESCRI" , zDescri,  Nil })
		AAdd(aLinha,{ "C6_CCUSTO" , zCCusto,  Nil })
		AAdd(aLinha,{ "C6_ZZITCTB", zItCtb,   Nil })
		AAdd(aItens,aLinha)		

		If lCheck1 // Substrai quantidade no pedido origem
			DbSelectArea("SC6")
			DbSetOrder(1)
			DbSeek( cFilOri + cIdPdv + zItemOri )
			zQtSaldo := (SC6->C6_QTDVEN - SC6->C6_QTDENT)
			// Item do pedido origem | Saldo no pedido origem | Quantidade copiada | Saldo pendente na origem? S/N
			AAdd(aAbate,{ zItemOri, zQtSaldo, zQtdVen, (((zQtSaldo-zQtdVen) > 0) .Or. SC6->C6_QTDENT > 0) })
		Endif

	Endif

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

Endif

If !lMsErroAuto

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( cFilAnt + cDoc )

	MsgBox("Pedido "+cDoc+" gerado com sucesso !!"+cEOL+;
		   cFilAnt+"-"+FWFilialName()+cEOL+;
		   AllTrim(SA1->A1_NOME),"Aviso","INFO")

	// Subtrai saldo no pedido origem
	If lCheck1

		cFilAnt := cFilOri // --> Posiciona na filial origem para alteração/exclusão
		aCabec := {}
		aItens := {}
		aBlqB1 := {}
		aBlqVe := {}
		aElmRs := {}

		lSaldoPv := .F.
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek( cFilAnt + cIdPdv )
		While !Eof() .And. SC6->C6_FILIAL == cFilAnt .And. SC6->C6_NUM == cIdPdv
			nPosIt := aScan(aAbate, {|x| x[1] == SC6->C6_ITEM})
			If nPosIt == 0 // Indica que existe item no pedido origem não marcado para cópia, portanto caracteriza saldo no pedido origem
				// Desbloqueia Produtos
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
				If !Empty(SC6->C6_BLQ)
					AAdd(aElmRs,SC6->(Recno()))
				Endif
				//
				zQtSaldo := (SC6->C6_QTDVEN - SC6->C6_QTDENT)
				// Item do pedido origem | Saldo no pedido origem | Quantidade copiada | Saldo pendente na origem? S/N
				AAdd(aAbate,{ SC6->C6_ITEM, zQtSaldo, 0, ((zQtSaldo > 0) .Or. SC6->C6_QTDENT > 0) })
			Endif
			SC6->(DbSkip())
		Enddo

		For _x := 1 to Len(aAbate)
			If aAbate[_x][4] // Se qualquer item manter saldo
				lSaldoPv := .T. // Indica que permanecerá saldo no pedido origem
				Exit
			Endif
		Next _x

		// Ordena array de alteração do Pedido origem
		aSort( aAbate,,, { |x,y| x[1] < y[1] } )
	
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( cFilAnt + cIdPdv )

		RegToMemory( "SC5", .F., .F. )

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )

		z5Parc1 := SC5->C5_PARC1
		z5Per01 := 0
		z5Parc2 := SC5->C5_PARC2
		z5Per02 := 0
		z5Parc3 := SC5->C5_PARC3
		z5Per03 := 0
		z5Parc4 := SC5->C5_PARC4
		z5Per04 := 0

		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek( xFilial("SE4") + SC5->C5_CONDPAG )
		If SE4->E4_TIPO == "9" .And. AllTrim(SE4->E4_COND) == "0"
			// % original
			zTotOri := SC5->(C5_PARC1+C5_PARC2+C5_PARC3+C5_PARC4)
			z5Per01 := Round(((SC5->C5_PARC1 / zTotOri) * 100),0)
			z5Per02 := Round(((SC5->C5_PARC2 / zTotOri) * 100),0)
			z5Per03 := Round(((SC5->C5_PARC3 / zTotOri) * 100),0)
			z5Per04 := (100 - (z5Per01 + z5Per02 + z5Per03))
			// Total recalculado
			zTotParc := 0
			For _x := 1 to Len(aAbate)
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek( cFilAnt + cIdPdv + aAbate[_x][1] )
				lExcItem := !(aAbate[_x][4])
				If !lExcItem
					zNovaQtd := (aAbate[_x][2] - aAbate[_x][3]) + SC6->C6_QTDENT
					zNovoVlr := zNovaQtd * SC6->C6_PRCVEN
					zTotParc += zNovoVlr
				Endif	
			Next _x
			z5Parc1	:= (zTotParc * (z5Per01/100))
			z5Parc2 := (zTotParc * (z5Per02/100))
			z5Parc3 := (zTotParc * (z5Per03/100))
			z5Parc4 := (zTotParc - (z5Parc1 + z5Parc2 + z5Parc3))
		Endif	

		zzVend1 := SC5->C5_VEND1
		zzCdFxv := SC5->C5_ZZCDFXV
		zzVend2 := SC5->C5_VEND2
		zzCdFxR := SC5->C5_ZZCDFXR

		aCabec := {{"C5_NUM"     , SC5->C5_NUM     , Nil},;
				   {"C5_TIPO"    , "N"             , Nil},;
				   {"C5_CLIENTE" , SC5->C5_CLIENTE , Nil},;
				   {"C5_LOJACLI" , SC5->C5_LOJACLI , Nil},;
				   {"C5_LOJAENT" , SC5->C5_LOJAENT , Nil},;
				   {"C5_TIPOCLI" , SC5->C5_TIPOCLI , Nil},;
				   {"C5_CONDPAG" , SC5->C5_CONDPAG , Nil},;
				   {"C5_EMISSAO" , SC5->C5_EMISSAO , Nil},;
				   {"C5_XPRJAMI" , SC5->C5_XPRJAMI , Nil},;
				   {"C5_ZEBTDIG" , SC5->C5_ZEBTDIG , Nil},;
		           {"C5_VEND1"   , SC5->C5_VEND1   , Nil},;
		           {"C5_ZZCDFXV" , SC5->C5_ZZCDFXV , Nil},;
		           {"C5_VEND2"   , SC5->C5_VEND2   , Nil},;
		           {"C5_ZZCDFXR" , SC5->C5_ZZCDFXR , Nil},;
		           {"C5_ZZREGVE" , SC5->C5_ZZREGVE , Nil},;
		           {"C5_ZZITCTB" , SC5->C5_ZZITCTB , Nil},;
		           {"C5_PARC1"   , z5Parc1         , Nil},;
				   {"C5_DATA1"   , z5Data1         , Nil},;
		           {"C5_PARC2"   , z5Parc2         , Nil},;
				   {"C5_DATA2"   , z5Data2         , Nil},;
		           {"C5_PARC3"   , z5Parc3         , Nil},;
				   {"C5_DATA3"   , z5Data3         , Nil},;
		           {"C5_PARC4"   , z5Parc4         , Nil},;
				   {"C5_DATA4"   , z5Data4         , Nil},;
				   {"C5_MOEDA"   , SC5->C5_MOEDA   , Nil}}

		For _x := 1 to Len(aAbate)

			DbSelectArea("SC6")
			DbSetOrder(1)
			DbSeek( cFilAnt + cIdPdv + aAbate[_x][1] )

			lExcItem := !(aAbate[_x][4])
			cAutDele := IIf(lExcItem,"S","N")
			zNovaQtd := (aAbate[_x][2] - aAbate[_x][3]) + SC6->C6_QTDENT
			zNovoVlr := zNovaQtd * SC6->C6_PRCVEN
			zUnsVen  := ConvUm(SC6->C6_PRODUTO, zNovaQtd, 0, 2)

			aItem := {{"C6_NUM"     , SC6->C6_NUM     , Nil},;
			  		  {"C6_ITEM"    , SC6->C6_ITEM    , Nil},;
					  {"C6_PRODUTO" , SC6->C6_PRODUTO , Nil},;
					  {"C6_QTDVEN"  , zNovaQtd	      , Nil},;
					  {"C6_PRCVEN"  , SC6->C6_PRCVEN  , Nil},;
					  {"C6_VALOR"   , zNovoVlr  	  , Nil},;
					  {"C6_ENTREG"  , SC6->C6_ENTREG  , Nil},;
					  {"C6_TES"     , SC6->C6_TES	  , Nil},;
					  {"C6_LOCAL"   , SC6->C6_LOCAL   , Nil},;
					  {"C6_CLI"     , SC6->C6_CLI  	  , Nil},;
					  {"C6_LOJA"    , SC6->C6_LOJA    , Nil},;
					  {"C6_DESCRI"  , SC6->C6_DESCRI  , Nil},;
					  {"C6_UNSVEN"  , zUnsVen	      , Nil},;
					  {"AUTDELETA"  , cAutDele        , Nil}}
			AAdd(aItens,aItem)

		Next _x

		If lSaldoPv // Altera pedido origem

			// Marca Pedido = 'Em cópia'
			RecLock("SC5",.F.)
			SC5->C5_XEMCOP2 := "S"
			MsUnLock()

			lMsErroAuto := .F.
			MsExecAuto({|x,y,z|MATA410(x,y,z)},aCabec,aItens,4)
			If !lMsErroAuto			
				MsgBox("O pedido origem "+cIdPdv+" foi alterado com sucesso !!"+cEOL+;
					   cFilAnt+"-"+FWFilialName()+cEOL+;
					   AllTrim(SA1->A1_NOME),"Aviso","INFO")
			Else			
				MostraErro()
				DisarmTransaction()
			Endif

			// Desmarca Pedido = 'Em cópia'
			RecLock("SC5",.F.)
			SC5->C5_XEMCOP2 := "N"
			SC5->C5_VEND1   := zzVend1
			SC5->C5_ZZCDFXV := zzCdFxv
			SC5->C5_VEND2   := zzVend2
			SC5->C5_ZZCDFXR := zzCdFxR
			MsUnLock()

			For _x := 1 to Len(aElmRs)
				DbSelectArea("SC6")
				SC6->(DbGoto(aElmRs[_x]))
				RecLock("SC6",.F.)
				SC6->C6_BLQ := "R"
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
			Next _x	

		Else // Exclui pedido origem

			lMsErroAuto := .F.
			MsExecAuto({|x,y,z|MATA410(x,y,z)},aCabec,aItens,5)
			If !lMsErroAuto			
				MsgBox("O pedido origem "+cIdPdv+" foi excluído com sucesso !!"+cEOL+;
					   cFilAnt+"-"+FWFilialName()+cEOL+;
					   AllTrim(SA1->A1_NOME),"Aviso","INFO")
			Else			
				MostraErro()
				DisarmTransaction()
			Endif

		Endif

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

		// Checagem final do status do Pedido Origem
		lEncerra := .T.
		DbSelectArea("SC6")
		DbSetOrder(1)
		If DbSeek( SC5->C5_FILIAL + SC5->C5_NUM )
			While !Eof() .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
				If SC6->(C6_QTDVEN - C6_QTDENT) > 0 .And. Empty(SC6->C6_BLQ)
					lEncerra := .F.
					Exit
				Endif
				SC6->(DbSkip())
			Enddo 
		Endif
		If lEncerra
			RecLock("SC5",.F.)
			SC5->C5_LIBEROK := "S"
			SC5->C5_NOTA    := "XXXXXXXXX"
			MsUnLock()
		Endif

	Endif

Endif

End Transaction
MsUnLockAll()

cFilAnt := cFilBkp

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ NewData410 ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 27/12/2017	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Interface para digitação de novo vencimento.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function NewData410(zTitLabel,zVencto)

Local aArea   := GetArea()
Local nOpcDwn := 0
Local bActiCn := {|| nOpcDwn:=0,oDlgDwn:End() }
Local bOkDwn  := {|| nOpcDwn:=1,oDlgDwn:End() }
Local bCanDwn := {|| IIf(MsgYesNo("O sistema assumirá a data de hoje. Confirma?","Sair"), Eval(bActiCn), .F.) }
Local zNewVen := zVencto
Local zRetDat := zVencto
Local oDlgDwn,oPdc,oFnt2

oFnt2 := TFont():New("Tahoma",,12,,.T.)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376
nLinI := 047

DEFINE MSDIALOG oDlgDwn FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE zTitLabel OF oDlgDwn PIXEL

oRepPdc:= TSay():New(nLinI,010,{||""},oDlgDwn,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,150,020)
oRepPdc:SetText("Novo "+zTitLabel+":")
oRepPdc:CtrlRefresh()

@ nLinI-2,070 MSGET oPdc VAR zNewVen SIZE 070,010 OF oDlgDwn PIXEL VALID ( zNewVen >= Date() )

ACTIVATE MSDIALOG oDlgDwn ON INIT EnchoiceBar(oDlgDwn,bOkDwn,bCanDwn) CENTERED

If nOpcDwn == 1
	zRetDat := zNewVen
Else
	zRetDat := Date()	
Endif

RestArea(aArea)

Return(zRetDat)
