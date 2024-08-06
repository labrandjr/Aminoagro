#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR010   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Registro de Acordos.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR010()

Local aArea := GetArea()

Local aObjects := {}
Local aSizeAut := {}
Local aInfo    := {}
Local aPosObj  := {}

Private nOpcAco := 0
Private oDlgAco := Nil
Private bActOk  := {|| nOpcAco:=1,oDlgAco:End() }
Private bActCan := {|| nOpcAco:=0,oDlgAco:End() }
Private bOkAcor := {|| IIf(MsgYesNo("Confirma os títulos selecionados?","Registrar"), Eval(bActOk), .F.) }
Private bCanAco := {|| IIf(MsgYesNo("Abandona a inclusão do acordo?","Sair"), Eval(bActCan), .F.) }

// Colunas do browse
Private nFdrLeg := 1
Private nFdrMkb := 2
Private nFdrPre := 3
Private nFdrNum := 4
Private nFdrPar := 5
Private nFdrTip := 6
Private nFdrCli := 7
Private nFdrNom := 8
Private nFdrVen := 9
Private nFdrVeR := 10
Private nFdrVal := 11
Private nFdrSal := 12
Private nFdrHis := 13

Private cDBType	:= Alltrim(Upper(TCGetDB()))
Private lSQL	:= !(cDBType $"ORACLE|POSTGRES|DB2|INFORMIX")

Private oLbxAco := Nil
Private aVetAco := {}

Private oMenuAco
Private lTodos := .F.

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
Private cCadastro := "Inclusão de Acordo"

Private cAcordo := ""
Private aInterv := {"Emissão","Vencimento"}
Private nQtdTit := 0
Private nValTit := 0
Private cBaseCgc := ""
Private cAgrupCr := ""
Private cCliente := ""
Private cInterv  := ""
Private dDataDe  := CtoD("")
Private dDataAt  := CtoD("")
Private oBaseCgc,oQtdTit,oValTit

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.T.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

Menu oMenuAco PopUp
	MenuItem "Marca Todos" 		Action Eval( { || lTodos := .T. , aEval( aVetAco , { |k| k[nFdrMkb] := lTodos      } ) , nQtdTit := 0 , aEval( aVetAco , { |k| nQtdTit += IIf( k[nFdrMkb], 1, 0 ) } ) , nValTit := 0 , aEval( aVetAco , { |k| nValTit += IIf( k[nFdrMkb], k[nFdrSal], 0 ) } ) , oQtdTit:Refresh() , oValTit:Refresh() , oLbxAco:Refresh() } )
	MenuItem "Desmarca Todos"  	Action Eval( { || lTodos := .F. , aEval( aVetAco , { |k| k[nFdrMkb] := lTodos      } ) , nQtdTit := 0 , aEval( aVetAco , { |k| nQtdTit += IIf( k[nFdrMkb], 1, 0 ) } ) , nValTit := 0 , aEval( aVetAco , { |k| nValTit += IIf( k[nFdrMkb], k[nFdrSal], 0 ) } ) , oQtdTit:Refresh() , oValTit:Refresh() , oLbxAco:Refresh() } )
	MenuItem "Inverter Seleção" Action Eval( { || lTodos := Nil , aEval( aVetAco , { |k| k[nFdrMkb] := !k[nFdrMkb] } ) , nQtdTit := 0 , aEval( aVetAco , { |k| nQtdTit += IIf( k[nFdrMkb], 1, 0 ) } ) , nValTit := 0 , aEval( aVetAco , { |k| nValTit += IIf( k[nFdrMkb], k[nFdrSal], 0 ) } ) , oQtdTit:Refresh() , oValTit:Refresh() , oLbxAco:Refresh() } )
EndMenu

aSizeAut := MsAdvSize(,.F.,400)

aObjects := {}  
AAdd( aObjects, { 000, 030, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

oDlgAco := MsDialog():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

// Dimensionamento do Dlg
nLaDlg := aSizeAut[5] // 1474
nAlDlg := aSizeAut[6] // 659

// Fator Altura do Dlg
nFtAlt := (200/659)
nAlBr4 := Round((nFtAlt * nAlDlg),0) // Linha final (Browse Redimensionado)

// Fator Largura do Dlg
nFtLar := (730/1474)
nLaBr3 := Round((nFtLar * nLaDlg),0) // Coluna final (Browse Redimensionado)

// ***************************************************************************************************** //
// ** Cabeçalho - Identificação do acordo e parâmetros                                                ** //
// ***************************************************************************************************** //
cPrxNum := u_PrxAcor()
cAcordo := cPrxNum

// Coluna 1
nLin1 := 040
@ nLin1,005 SAY "No.Acordo" OF oDlgAco PIXEL SIZE 055,009
@ nLin1-1,050 TO nLin1+11,150 LABEL "" OF oDlgAco PIXEL
oSayAco:= TSay():New(nLin1+2,055,{|| cAcordo },oDlgAco,,oFnt3,,,,.T.,CLR_RED,CLR_WHITE,200,020)
oSayAco:CtrlRefresh()

@ nLin1+15,005 SAY "Usuário" OF oDlgAco PIXEL SIZE 055,009
@ nLin1+14,050 TO nLin1+26,150 LABEL "" OF oDlgAco PIXEL
oSayUsu:= TSay():New(nLin1+17,055,{|| cUserName },oDlgAco,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayUsu:CtrlRefresh()

@ nLin1+30,005 SAY "Emissão" OF oDlgAco PIXEL SIZE 055,009
@ nLin1+29,050 TO nLin1+41,150 LABEL "" OF oDlgAco PIXEL
oSayDat:= TSay():New(nLin1+32,055,{|| DtoC(Date()) },oDlgAco,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayDat:CtrlRefresh()

// Coluna 2
cBaseCgc := Space(8)
@ nLin1,205 SAY "Base Cnpj" OF oDlgAco PIXEL SIZE 100,009
@ nLin1-1,260 MSGET oBaseCgc VAR cBaseCgc SIZE 070,010 OF oDlgAco PIXEL PICTURE "@!" F3 "DE4" VALID VldCgc()

cAgrupCr := Space(6)
@ nLin1+15,205 SAY "Agrup.Crédito" OF oDlgAco PIXEL SIZE 100,009
@ nLin1+14,260 MSGET oAGrupCr VAR cAgrupCr SIZE 070,010 OF oDlgAco PIXEL PICTURE "@!" F3 "CLI" VALID VldAgr()

cCliente := Space(6)
@ nLin1+30,205 SAY "Cliente" OF oDlgAco PIXEL SIZE 100,009
@ nLin1+29,260 MSGET oCliente VAR cCliente SIZE 070,010 OF oDlgAco PIXEL PICTURE "@!" F3 "CLI" VALID VldCli()

// Coluna 3
cInterv := "Emissão"
@ nLin1,405 SAY "Intervalo por" OF oDlgAco PIXEL SIZE 100,009
oComboI := TComboBox():New(nLin1-1,460,{|u| If(PCount()>0,cInterv:=u,cInterv)},aInterv,070,013,oDlgAco,,,,,,.T.,,,,,,,,,"cInterv")

dDataDe := CtoD("")
@ nLin1+15,405 SAY "Data De" OF oDlgAco PIXEL SIZE 100,009
@ nLin1+14,460 MSGET oDataDe VAR dDataDe SIZE 070,010 OF oDlgAco PIXEL

dDataAt := CtoD("")
@ nLin1+30,405 SAY "Data Até" OF oDlgAco PIXEL SIZE 100,009
@ nLin1+29,460 MSGET oDataAt VAR dDataAt SIZE 070,010 OF oDlgAco PIXEL

@ 050,550 BUTTON "Aplicar Filtro" SIZE 070,015 FONT oDlgAco:oFont ACTION fCarga(@aVetAco) OF oDlgAco PIXEL

// Dimensões do Browse
n2Brw1 := 095
n2Brw2 := 005
n2Brw3 := nLaBr3
n2Brw4 := nAlBr4

// Dimensões do rodapé
nLI1Rod := n2Brw1 + nAlBr4 + 10
nCo2Rod := 550

// ***************************************************************************************************** //
// ** Browse de títulos a receber para seleção                                                        ** //
// ***************************************************************************************************** //
oLbxAco := TWBrowse():New(n2Brw1,n2Brw2,n2Brw3,n2Brw4,,,,oDlgAco,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxAco:AddColumn( TcColumn():New( "  "    	       ,{ || IIf(aVetAco[oLbxAco:nAt][nFdrLeg],oVerde,oVerme) } , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "  "  	       ,{ || IIf(aVetAco[oLbxAco:nAt][nFdrMkb],oOk,oNo) }       , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )     						
oLbxAco:AddColumn( TcColumn():New( "Prefixo"       ,{ || aVetAco[oLbxAco:nAt][nFdrPre] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "No.Título"     ,{ || aVetAco[oLbxAco:nAt][nFdrNum] } , "@!"       ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Parcela"       ,{ || aVetAco[oLbxAco:nAt][nFdrPar] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Tipo"          ,{ || aVetAco[oLbxAco:nAt][nFdrTip] } , "@!"       ,,,"LEFT"	,020,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Cliente"       ,{ || aVetAco[oLbxAco:nAt][nFdrCli] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Razão"         ,{ || aVetAco[oLbxAco:nAt][nFdrNom] } , "@!"       ,,,"LEFT"	,120,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Vencto."       ,{ || aVetAco[oLbxAco:nAt][nFdrVen] } , ""	      ,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Vencto.Real"   ,{ || aVetAco[oLbxAco:nAt][nFdrVeR] } , ""	      ,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Valor R$"      ,{ || aVetAco[oLbxAco:nAt][nFdrVal] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Saldo R$"      ,{ || aVetAco[oLbxAco:nAt][nFdrSal] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Histórico"     ,{ || aVetAco[oLbxAco:nAt][nFdrHis] } , "@!"       ,,,"LEFT"	,100,.F.,.F.,,,,.F.,) )

oLbxAco:SetArray(aVetAco)
oLbxAco:bHeaderClick := { |o,x,y| IIf( x == nFdrMkb , oMenuAco:Activate(x,y,oLbxAco) , fHeader( o , x , y , @oLbxAco , @aVetAco ) ) }
oLbxAco:bLDblClick := { || fClick(@oLbxAco,@aVetAco,oLbxAco:nAt,oLbxAco:nColPos) }

@ nLI1Rod,020 SAY "Títulos Selecionados" OF oDlgAco PIXEL SIZE 055,009
@ nLI1Rod-1,080 MSGET oQtdTit VAR nQtdTit PICTURE "@E 9,999" OF oDlgAco PIXEL WHEN .F. SIZE 070,009

@ nLI1Rod,nCo2Rod-50 SAY "Valor Total R$" OF oDlgAco PIXEL SIZE 055,009
@ nLI1Rod-1,nCo2Rod MSGET oValTit VAR nValTit PICTURE  PesqPict("SE1","E1_VALOR",,1) OF oDlgAco PIXEL WHEN .F. SIZE 070,009

oDlgAco:Activate(,,,.T.,{|| _Validar(aVetAco) },,{|| EnchoiceBar(oDlgAco,bOkAcor,bCanAco) } )

If nOpcAco == 1
	MsgRun("Reservando títulos selecionados... aguarde","Processando",{|| _Etapa01(aVetAco) })
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldcGC    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da base do cnpj.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCgc()

Local lRetorno := .T.

If !Empty(cBaseCgc)
	DbSelectArea("SA1")
	DbSetOrder(3)
	If !DbSeek( xFilial("SA1") + cBaseCgc )
		MsgInfo("Base do Cnpj não cadastrada.")
		lRetorno := .F.
	Endif
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldAgr    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do agrupamento de crédito.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldAgr()

Local lRetorno := .T.

If !Empty(cAgrupCr)
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek( xFilial("SA1") + cAgrupCr )
		MsgInfo("Agrupamento de crédito não cadastrado.")
		lRetorno := .F.
	Endif
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCli    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do código do cliente.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCli()

Local lRetorno := .T.

If !Empty(cCliente)
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek( xFilial("SA1") + cCliente )
		MsgInfo("Cliente não cadastrado.")
		lRetorno := .F.
	Endif
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeader  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fHeader(oObj,nCol,nLin,oLbxAco,aVetAco)

oLbxAco:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClick    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦  20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do browse Saída.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClick(oLbxAco,aVetAco,nLin,nCol)

If nCol == nFdrMkb // Markbrowse
	aVetAco[nLin][nCol] := !aVetAco[nLin][nCol]
	nQtdTit += IIf( aVetAco[nLin][nCol] , 1 , -1 )
	nValTit += IIf( aVetAco[nLin][nCol] , aVetAco[nLin][nFdrSal] , aVetAco[nLin][nFdrSal]*-1 )
	oQtdTit:Refresh()
	oValTit:Refresh()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarga  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtra títulos a receber.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarga(aVetAco)

Local lExecuta := .T.

If Empty(cBaseCgc) .And. Empty(cAgrupCr) .And. Empty(cCliente)
	MsgInfo("Informe um dos seguintes parâmetros:"+cEOL+;
			"| Base Cnpj | AGrup.Crédito | Cliente |")
	lExecuta := .F.
Endif

If lExecuta
	MsgRun("Selecionando títulos... aguarde","Processando",{|| fCarg01(@aVetAco) })
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg01  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa filtro dos títulos a receber.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg01(aVetAco)

Local lFiltrOk := .F.

aVetAco := {}
nQtdTit := 0
nValTit := 0

cQuery := " SELECT E1_FILIAL FILIAL, E1_PREFIXO PREFIXO, E1_NUM NUMERO, E1_PARCELA PARCELA, E1_TIPO TIPO, E1_CLIENTE CLIENTE, E1_LOJA LOJA "
cQuery += " FROM "+RetSqlName("SE1")+" SE1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND E1_CLIENTE = A1_COD "
cQuery += " AND E1_LOJA = A1_LOJA "
If !Empty(cBaseCgc)
	If lSQL
		cQuery += " AND SUBSTRING(A1_CGC,1,8) = '"+cBaseCgc+"' "
	Else
		cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+cBaseCgc+"' "
	Endif
Endif
If !Empty(cAgrupCr)
	cQuery += " AND A1_ZZAGCRD = '"+cAgrupCr+"' "
Endif
If !Empty(cCliente)
	cQuery += " AND E1_CLIENTE = '"+cCliente+"' "
Endif
If cInterv == "Emissão"
	cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAt)+"' "
Else
	cQuery += " AND E1_VENCREA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAt)+"' "
Endif	
cQuery += " AND E1_TIPO = 'NF' "
cQuery += " AND E1_ZZACORD = ' ' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_SITUACA = '0' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSQL",.T.,.T.)

DbSelectArea("TSQL")
TSQL->(DbGotop())
While !Eof()

	lFiltrOk := .T.

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( xFilial("SE1") + TSQL->(PREFIXO+NUMERO+PARCELA+TIPO+CLIENTE+LOJA) )

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + TSQL->(CLIENTE+LOJA) )

	AAdd(aVetAco,{ .T.,; // Legenda Verde
				   .F.,; // Marcado
				   SE1->E1_PREFIXO,;
				   SE1->E1_NUM,;
				   SE1->E1_PARCELA,;
				   SE1->E1_TIPO,;
				   SE1->E1_CLIENTE,;
				   SA1->A1_NOME,;
				   SE1->E1_VENCTO,;
				   SE1->E1_VENCREA,;
				   SE1->E1_VALOR,;
				   SE1->E1_SALDO,;
				   SE1->E1_HIST })

	DbSelectArea("TSQL")
	TSQL->(DbSkip())
Enddo
TSQL->(DbCloseArea())

If !lFiltrOk
	MsgInfo("Títulos não localizados para os parâmetros informados.")
Endif

oLbxAco:SetArray(aVetAco)
oLbxAco:Gotop()
oQtdTit:Refresh()
oValTit:Refresh()
oLbxAco:Refresh()
oDlgAco:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validacao geral da interface.		  					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Validar(aVetAco)

Local lRetorno := .F.
Local lReserva := .F.
Local _x

For _x := 1 to Len(aVetAco)
	If aVetAco[_x][nFdrMkb]
		lRetorno := .T.
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( xFilial("SE1") + aVetAco[_x][nFdrPre] + aVetAco[_x][nFdrNum] + aVetAco[_x][nFdrPar] + aVetAco[_x][nFdrTip] + aVetAco[_x][nFdrCli] )
		If !Empty(SE1->E1_ZZACORD)
			MsgInfo("O título "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+"-"+AllTrim(SE1->E1_PARCELA)+" encontra-se reservado em outro processo.")
			lReserva := .T.
			lRetorno := .F.
		Endif
	Endif
Next _x

If !lRetorno .And. !lReserva
	MsgInfo("Nenhum título selecionado.")
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Etapa01  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processa etapa 1.					  					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Etapa01(aVetAco)

Local aTitSel := {}
Local _x

Begin Transaction

// Reserva o título
For _x := 1 to Len(aVetAco)
	If aVetAco[_x][nFdrMkb]
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( xFilial("SE1") + aVetAco[_x][nFdrPre] + aVetAco[_x][nFdrNum] + aVetAco[_x][nFdrPar] + aVetAco[_x][nFdrTip] + aVetAco[_x][nFdrCli] )
		RecLock("SE1",.F.)
		SE1->E1_ZZACORD := cAcordo
		MsUnLock()
		AAdd(aTitSel,SE1->(Recno()))
	Endif
Next _x

U_ACOR020(aTitSel,"I")

End Transaction
MsUnLockAll()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PrxAcor  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula o próximo sequencial de acordos.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PrxAcor()

Local aArea   := GetArea()
Local cUltAco := "000000000"
Local cDBType := Alltrim(Upper(TCGetDB()))
Local lSQL	  := !(cDBType $"ORACLE|POSTGRES|DB2|INFORMIX")

If lSQL
	cQuery := " SELECT MAX(Z01_ACORDO) ACORDO "
Else
	cQuery := " SELECT MAX(Z01_ACORDO) ACORDO "
Endif
cQuery += " FROM "+RetSqlName("Z01")
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZ01",.T.,.T.)

TZ01->(DbGotop())
If !Eof()
	cUltAco := TZ01->ACORDO
Endif	
TZ01->(DbCloseArea())

cPrxNum := SOMA1(cUltAco)

RestArea(aArea)

Return(cPrxNum)
