#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ LOTINVM   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  11/06/2019  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Monitor de contagem do inventário RF.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LOTINVM()

Local aArea := GetArea()

Local aObjects := {}
Local aSizeAut := {}
Local aInfo    := {}
Local aPosGet  := {}
Local aPosObj  := {}

Private nOpcAco := 0
Private oDlgInv := Nil
Private bActOk  := {|| nOpcAco:=1,oDlgInv:End() }
Private bActCan := {|| nOpcAco:=0,oDlgInv:End() }
Private bOkAcor := {|| Eval(bActOk)  }
Private bCanAco := {|| Eval(bActCan) }

// Colunas do browse
Private nFdrLeg := 1
Private nFdrUsr := 2
Private nFdrNom := 3
Private nFdrQEn := 4
Private nFdrQCo := 5
Private nFdrPCo := 6
Private nFdrQTr := 7
Private nFdrPTr := 8
Private nFdrObs := 9

Private cDBType	:= Alltrim(Upper(TCGetDB()))
Private lSQL	:= !(cDBType $"ORACLE|POSTGRES|DB2|INFORMIX")

Private oLbxInv := Nil
Private aVetInv := {}
Private aButton := {}
Private zTotCon := 0
Private zTotTra := 0

Private oVerde  := LoadBitmap( GetResources(), "ENABLE" )
Private oVerme  := LoadBitmap( GetResources(), "DISABLE" )
Private oViolet := LoadBitmap( GetResources(), "BR_VIOLETA" )
Private oAzul   := LoadBitmap( GetResources(), "BR_AZUL" )
Private oAmare  := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oMarrom := LoadBitmap( GetResources(), "BR_MARROM" )
Private oCinza  := LoadBitmap( GetResources(), "BR_CINZA" )
Private oPink   := LoadBitmap( GetResources(), "BR_PINK" )
Private oPreto  := LoadBitmap( GetResources(), "BR_PRETO" )
Private oLaranj := LoadBitmap( GetResources(), "BR_LARANJA" )
Private oTAmare := LoadBitmap( GetResources(), "PMSEDT2" )
Private oTVerde := LoadBitmap( GetResources(), "PMSEDT3" )
Private oTCinza := LoadBitmap( GetResources(), "PMSEDT4" )
Private oBranco := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oVerEsc := LoadBitmap( GetResources(), "BR_VERDE_ESCURO" )
Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM

Private cEOL      := CHR(13)+CHR(10) 
Private cCadastro := "Monitor de Contagem do Inventário - Rádio Frequência"

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.T.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

aSizeAut := MsAdvSize(,.F.,400)

aObjects := {}  
AAdd( aObjects, { 000, 030, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

oDlgInv := MsDialog():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

// Dimensionamento do Dlg
nLaDlg := aSizeAut[5] // 1474
nAlDlg := aSizeAut[6] // 659

// Fator Altura do Dlg
nFtAlt := (200/659)
nAlBr4 := Round((nFtAlt * nAlDlg),0) // Linha final (Browse Redimensionado)

// Fator Largura do Dlg
nFtLar := (730/1474)
nLaBr3 := Round((nFtLar * nLaDlg),0) // Coluna final (Browse Redimensionado)

DbSelectArea("NNR")
DbSetOrder(1)
DbSeek( xFilial("NNR") + SZM->ZM_LOCAL )

// Linha 1
nLin1 := 040
@ nLin1,005 SAY "Data Contagem" OF oDlgInv PIXEL SIZE 055,009
@ nLin1-1,050 TO nLin1+11,100 LABEL "" OF oDlgInv PIXEL
oSayDat:= TSay():New(nLin1+2,057,{|| DtoC(SZM->ZM_DATA) },oDlgInv,,oFnt3,,,,.T.,CLR_RED,CLR_WHITE,200,020)
oSayDat:CtrlRefresh()

@ nLin1,350 SAY IIf(SZM->ZM_UNICO=="S","Produtos","Endereços") OF oDlgInv PIXEL SIZE 055,009
@ nLin1-1,390 TO nLin1+11,430 LABEL "" OF oDlgInv PIXEL
oSayEnd:= TSay():New(nLin1+2,400,{|| AllTrim(STR(SZM->ZM_TOTEND)) },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayEnd:CtrlRefresh()

// Linha 2
@ nLin1+15,005 SAY "Armazém" OF oDlgInv PIXEL SIZE 055,009
@ nLin1+14,050 TO nLin1+26,070 LABEL "" OF oDlgInv PIXEL
oSayLoc:= TSay():New(nLin1+17,055,{|| SZM->ZM_LOCAL },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayLoc:CtrlRefresh()

If !Empty(SZM->ZM_ARQ) .Or. SZM->ZM_UNICO == "S"

	@ nLin1+14,075 TO nLin1+26,305 LABEL "" OF oDlgInv PIXEL
	oSayNNR:= TSay():New(nLin1+17,082,{|| NNR->NNR_DESCRI },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayNNR:CtrlRefresh()

Else

	@ nLin1+15,005 SAY "Armazém" OF oDlgInv PIXEL SIZE 055,009
	@ nLin1+14,050 TO nLin1+26,070 LABEL "" OF oDlgInv PIXEL
	oSayLoc:= TSay():New(nLin1+17,055,{|| SZM->ZM_LOCAL },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayLoc:CtrlRefresh()
	
	@ nLin1+14,075 TO nLin1+26,200 LABEL "" OF oDlgInv PIXEL
	oSayNNR:= TSay():New(nLin1+17,082,{|| NNR->NNR_DESCRI },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayNNR:CtrlRefresh()
	
	@ nLin1+15,215 SAY "Galpão" OF oDlgInv PIXEL SIZE 055,009
	@ nLin1+14,260 TO nLin1+26,305 LABEL "" OF oDlgInv PIXEL
	oSayLoc:= TSay():New(nLin1+17,282,{|| SZM->ZM_GALPAO },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayLoc:CtrlRefresh()

Endif

@ nLin1+15,350 SAY "Conferidos" OF oDlgInv PIXEL SIZE 055,009
@ nLin1+14,390 TO nLin1+26,430 LABEL "" OF oDlgInv PIXEL
oSayCon:= TSay():New(nLin1+17,400,{|| AllTrim(STR(SZM->ZM_TOTCON)) },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayCon:CtrlRefresh()

zPConfe := 0
oSayPCo:= TSay():New(nLin1+15,450,{||""},oDlgInv,,oFnt3,,,,.T.,CLR_BLUE,CLR_WHITE,050,020)
oSayPCo:SetText(AllTrim(STR(zPConfe,6,2))+" %")
oSayPCo:CtrlRefresh()

// Linha 3
If !Empty(SZM->ZM_ARQ)

	@ nLin1+30,005 SAY "Arquivo" OF oDlgInv PIXEL SIZE 055,009
	@ nLin1+29,050 TO nLin1+41,305 LABEL "" OF oDlgInv PIXEL
	oSayEnd:= TSay():New(nLin1+32,057,{|| SZM->ZM_ARQ+".CSV  |  Tipo: "+IIf(SZM->ZM_TPARQ=="P","Produto  ","Endereço  ")+IIf(!Empty(SZM->ZM_LOCALIZ),"|  "+SZM->ZM_LOCALIZ,"") },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayEnd:CtrlRefresh()

ElseIf SZM->ZM_UNICO == "S"

	@ nLin1+30,005 SAY "Endereço" OF oDlgInv PIXEL SIZE 055,009
	@ nLin1+29,050 TO nLin1+41,305 LABEL "" OF oDlgInv PIXEL
	oSayEnd:= TSay():New(nLin1+32,057,{|| SZM->ZM_LOCALIZ },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayEnd:CtrlRefresh()

Else

	@ nLin1+30,005 SAY "Rua De-Até" OF oDlgInv PIXEL SIZE 055,009
	@ nLin1+29,050 TO nLin1+41,070 LABEL "" OF oDlgInv PIXEL
	oSayRuaI:= TSay():New(nLin1+32,057,{|| SZM->ZM_RUAI },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayRuaI:CtrlRefresh()
	
	@ nLin1+29,075 TO nLin1+41,095 LABEL "" OF oDlgInv PIXEL
	oSayRuaF:= TSay():New(nLin1+32,082,{|| SZM->ZM_RUAF },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayRuaF:CtrlRefresh()
	
	@ nLin1+30,110 SAY "Módulo De-Até" OF oDlgInv PIXEL SIZE 055,009
	@ nLin1+29,155 TO nLin1+41,175 LABEL "" OF oDlgInv PIXEL
	oSayModI:= TSay():New(nLin1+32,162,{|| SZM->ZM_MODI },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayModI:CtrlRefresh()
	
	@ nLin1+29,180 TO nLin1+41,200 LABEL "" OF oDlgInv PIXEL
	oSayModF:= TSay():New(nLin1+32,187,{|| SZM->ZM_MODF },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayModF:CtrlRefresh()
	
	@ nLin1+30,215 SAY "Nível De-Até" OF oDlgInv PIXEL SIZE 055,009
	@ nLin1+29,260 TO nLin1+41,280 LABEL "" OF oDlgInv PIXEL
	oSayNivI:= TSay():New(nLin1+32,267,{|| SZM->ZM_NIVI },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayNivI:CtrlRefresh()
	
	@ nLin1+29,285 TO nLin1+41,305 LABEL "" OF oDlgInv PIXEL
	oSayNivF:= TSay():New(nLin1+32,292,{|| SZM->ZM_NIVF },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayNivF:CtrlRefresh()
	
Endif

@ nLin1+30,350 SAY "Transferidos" OF oDlgInv PIXEL SIZE 055,009
@ nLin1+29,390 TO nLin1+41,430 LABEL "" OF oDlgInv PIXEL
oSayTra:= TSay():New(nLin1+32,400,{|| AllTrim(STR(SZM->ZM_TOTTRA)) },oDlgInv,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayTra:CtrlRefresh()

zPTrans := 0
oSayPTr:= TSay():New(nLin1+30,450,{||""},oDlgInv,,oFnt3,,,,.T.,CLR_BLUE,CLR_WHITE,050,020)
oSayPTr:SetText(AllTrim(STR(zPTrans,6,2))+" %")
oSayPTr:CtrlRefresh()

// Dimensões do Browse
n2Brw1 := 095
n2Brw2 := 005
n2Brw3 := nLaBr3
n2Brw4 := nAlBr4

// Dimensões do rodapé
nLI1Rod := n2Brw1 + nAlBr4 + 10
nCo2Rod := 550

MsgRun("Carregando contagens... aguarde","Processando",{|| fCarga(@aVetInv,.F.) })

zPConfe := Round(((zTotCon / SZM->ZM_TOTEND) * 100),2)
oSayPCo:SetText(AllTrim(STR(zPConfe,6,2))+" %")
oSayPCo:CtrlRefresh()

zPTrans := Round(((zTotTra / SZM->ZM_TOTEND) * 100),2)
oSayPTr:SetText(AllTrim(STR(zPTrans,6,2))+" %")
oSayPTr:CtrlRefresh()

oLbxInv := TWBrowse():New(n2Brw1,n2Brw2,n2Brw3,n2Brw4,,,,oDlgInv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxInv:AddColumn( TcColumn():New( "  "    	       ,{ || IIf(aVetInv[oLbxInv:nAt][nFdrLeg]=="1",oVerde,IIf(aVetInv[oLbxInv:nAt][nFdrLeg]=="2",oAmare,IIf(aVetInv[oLbxInv:nAt][nFdrLeg]=="3",oAzul,oVerme)) ) } , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "Usuário"       ,{ || aVetInv[oLbxInv:nAt][nFdrUsr] } , "@!"           ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "Nome"          ,{ || aVetInv[oLbxInv:nAt][nFdrNom] } , "@!"           ,,,"LEFT"	,100,.F.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "Endereços"     ,{ || aVetInv[oLbxInv:nAt][nFdrQEn] } , "@E 9,999,999" ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "Conferidos"    ,{ || aVetInv[oLbxInv:nAt][nFdrQCo] } , "@E 9,999,999" ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "% Confer."     ,{ || aVetInv[oLbxInv:nAt][nFdrPCo] } , "@E 999.99"    ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "Transferidos"  ,{ || aVetInv[oLbxInv:nAt][nFdrQTr] } , "@E 9,999,999" ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "% Transf."     ,{ || aVetInv[oLbxInv:nAt][nFdrPTr] } , "@E 999.99"    ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxInv:AddColumn( TcColumn():New( "Observações"   ,{ || aVetInv[oLbxInv:nAt][nFdrObs] } , ""	          ,,,"LEFT"	,200,.F.,.F.,,,,.F.,) )

oLbxInv:SetArray(aVetInv)
oLbxInv:bHeaderClick := { |o,x,y| fHeader( o , x , y , @oLbxInv , @aVetInv ) }
oLbxInv:bLDblClick := { || fClick(@oLbxInv,@aVetInv,oLbxInv:nAt,oLbxInv:nColPos) }

// ****************************************************************************************************************
// ** T i m e r				                                                                                     //
// ****************************************************************************************************************
nIntervalo := 30 // Informar o conteudo em segundos (60 = 1 minuto, 600 = 10 minutos, 900 = 15 minutos, etc.)
nIntervalo := nIntervalo * 1000 // Converte em milisegundos
DEFINE TIMER oTimer INTERVAL nIntervalo ACTION ExecTimer() OF oDlgInv

AAdd(aButton,{"NOTE", {|| Legenda() }, "Legenda", "Legenda"})

oDlgInv:Activate(,,,.T.,,,{|| EnchoiceBar(oDlgInv,bOkAcor,bCanAco,,@aButton),oTimer:Activate() } )

If nOpcAco == 1
	MsgInfo("Monitoramento encerrado.")
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Legenda  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦ 12/06/2019   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Legenda.					   								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Legenda()

Local aCores := {}
                                                      
aCores := {{"BR_VERDE"    , "Sub-lote Aberto"      },;
		   {"BR_AMARELO"  , "Sub-lote em Contagem" },;
		   {"BR_AZUL"     , "Sub-lote Finalizado"  },;
		   {"BR_VERMELHO" , "Sub-lote Transferido" }}

BrwLegenda(cCadastro,"Legenda",aCores)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ExecTimer  ¦ Autor ¦  Fabrica ERPBR ¦ Data ¦ 12/06/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa ação do objeto oTimer.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.							 			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ExecTimer()

fCarga(@aVetInv,.T.)

oSayCon:SetText(AllTrim(STR(zTotCon)))
oSayCon:CtrlRefresh()

zPConfe := Round(((zTotCon / SZM->ZM_TOTEND) * 100),2)
oSayPCo:SetText(AllTrim(STR(zPConfe,6,2))+" %")
oSayPCo:CtrlRefresh()

oSayTra:SetText(AllTrim(STR(zTotTra)))
oSayTra:CtrlRefresh()

zPTrans := Round(((zTotTra / SZM->ZM_TOTEND) * 100),2)
oSayPTr:SetText(AllTrim(STR(zPTrans,6,2))+" %")
oSayPTr:CtrlRefresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeader  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  12/06/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fHeader(oObj,nCol,nLin,oLbxInv,aVetInv)

oLbxInv:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClick    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦  12/06/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do browse Saída.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClick(oLbxInv,aVetInv,nLin,nCol)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarga  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  12/06/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtra dados.											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarga(aVetInv,lUpdFiltro)

aVetInv := {}
zTotCon := 0
zTotTra := 0

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SZL")
cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
cQuery += " AND ZL_USUARIO <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY ZL_FILIAL, ZL_ID, ZL_USUARIO "
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSQL",.T.,.T.)

DbSelectArea("TSQL")
TSQL->(DbGotop())
While !Eof()

	lAdd := .F.
	nPos := 0
	If Len(aVetInv) == 0
		lAdd := .T.
	Else
		nPos := aScan(aVetInv, {|x| x[2] == TSQL->ZL_USUARIO })
		If nPos == 0
			lAdd := .T.
		Endif
	Endif	

	If lAdd
		AAdd(aVetInv,{"", TSQL->ZL_USUARIO, TSQL->ZL_USRFULL, 1, IIf(TSQL->ZL_CONF=="S",1,0), 0, IIf(TSQL->ZL_TRANSF=="S",1,0), 0, TSQL->ZL_OBS})
	ElseIf nPos > 0
		aVetInv[nPos][4] += 1
		aVetInv[nPos][5] += IIf(TSQL->ZL_CONF=="S",1,0)
		aVetInv[nPos][7] += IIf(TSQL->ZL_TRANSF=="S",1,0)
	Endif

	If TSQL->ZL_CONF == "S"
		zTotCon += 1
	Endif

	If TSQL->ZL_TRANSF == "S"
		zTotTra += 1
	Endif

	DbSelectArea("TSQL")
	TSQL->(DbSkip())
Enddo
TSQL->(DbCloseArea())

For _x := 1 to Len(aVetInv)
	aVetInv[_x][1] := IIf(aVetInv[_x][5]==0,"1",IIf(aVetInv[_x][4]==aVetInv[_x][7],"4",IIf(aVetInv[_x][4]==aVetInv[_x][5],"3","2")))
	aVetInv[_x][6] := Round(((aVetInv[_x][5] / aVetInv[_x][4]) * 100),2)
	aVetInv[_x][8] := Round(((aVetInv[_x][7] / aVetInv[_x][4]) * 100),2)
Next _x

If lUpdFiltro
	oLbxInv:SetArray(aVetInv)
	oLbxInv:Gotop()
	oLbxInv:Refresh()
	oDlgInv:Refresh()
Endif

Return
