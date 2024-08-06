#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR020   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Confirmação do registro de acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR020(aTitSel,zRotina)

Local aArea := GetArea()

Local aObjects := {}
Local aSizeAut := {}
Local aInfo    := {}
Local aPosObj  := {}

Private zVisual := (zRotina == "V")
Private zInclui := (zRotina == "I")
Private zAltera := (zRotina == "A")
Private zExclui := (zRotina == "E")
Private zRenego := (zRotina == "R")

Private nOpcAc2 := 0
Private oDlgAc2 := Nil
Private bActOk2 := {|| nOpcAc2:=1,oDlgAc2:End() }
Private bActCa2 := {|| nOpcAc2:=0,oDlgAc2:End() }
Private bOkAco2 := {}
Private bCanAc2 := {}

// Colunas do browse - títulos selecionados
Private nFdoLeg := 1
Private nFdoPre := 2
Private nFdoNum := 3
Private nFdoPar := 4
Private nFdoTip := 5
Private nFdoCli := 6
Private nFdoNom := 7
Private nFdoVen := 8
Private nFdoVeR := 9
Private nFdoVal := 10
Private nFdoSal := 11
Private nFdoHis := 12

// Colunas do browse - parcelas do acordo
Private nFdnLeg := 1
Private nFdnNum := 2
Private nFdnPar := 3
Private nFdnVen := 4
Private nFdnVal := 5
Private nFdnVar := 6
Private nFdnTot := 7
Private nFdnBco := 8
Private nFdnAge := 9
Private nFdnCon := 10
Private nFdnChe := 11
Private nFdnEmi := 12
Private nFdnNpr := 13
Private nFdnObs := 14

Private oLbxOld := Nil
Private oLbxNew := Nil

Private aVetOld := {}
Private aVetNew := {}

Private cEOL    := CHR(13)+CHR(10) 
Private cRatAcr := "Ratear nas Parcelas"
Private aRatAcr := {"Ratear nas Parcelas","Digitar Manualmente"}
Private cTipTax := "Acrescimo"
Private aTipTax := {"Acrescimo","Decrescimo"}
Private cCliDes := ""
Private cRazSoc := ""
Private nValNeg := 0
Private nNumPar := 0
Private dVenc1a := CtoD("")
Private nInterv := 30
Private nTJuros := 0
Private nValAcr := 0
Private nValTot := 0
Private nSalAco := 0
Private oSayAco,oSayAcr,oSayUsu,oSayDat,oSayRaz,oValNeg,oNumPar,oVenc1a,oInterv,oTJuros,oValAcr,oValTot,oSalAco,oComboA

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

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.T.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

If zVisual
	bOkAco2 := {|| Eval(bActOk2) }
	bCanAc2 := {|| Eval(bActCa2) }
ElseIf zInclui
	bOkAco2 := {|| IIf(MsgYesNo("Confirma a inclusão do acordo?","Registrar"), Eval(bActOk2), .F.) }
	bCanAc2 := {|| IIf(MsgYesNo("Cancela a inclusão do acordo?","Sair"), Eval(bActCa2), .F.) }
ElseIf zAltera
	bOkAco2 := {|| IIf(MsgYesNo("Confirma a alteração do acordo?","Registrar"), Eval(bActOk2), .F.) }
	bCanAc2 := {|| IIf(MsgYesNo("Abandona a alteração do acordo?","Sair"), Eval(bActCa2), .F.) }
ElseIf zExclui
	bOkAco2 := {|| IIf(MsgYesNo("Confirma a exclusão do acordo?","Registrar"), Eval(bActOk2), .F.) }
	bCanAc2 := {|| IIf(MsgYesNo("Abandona a exclusão do acordo?","Sair"), Eval(bActCa2), .F.) }
ElseIf zRenego
	bOkAco2 := {|| IIf(MsgYesNo("Confirma a renegociação do acordo?","Registrar"), Eval(bActOk2), .F.) }
	bCanAc2 := {|| IIf(MsgYesNo("Abandona a renegociação do acordo?","Sair"), Eval(bActCa2), .F.) }
Endif

aSizeAut := MsAdvSize(,.F.,400)

aObjects := {}  
AAdd( aObjects, { 000, 030, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

oDlgAc2 := MsDialog():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

// Dimensionamento do Dlg
nLaDlg := aSizeAut[5] // 1474
nAlDlg := aSizeAut[6] // 659

// Fator Altura do Dlg
nFtAlt := (100/659)
nAlBr4 := Round((nFtAlt * nAlDlg),0) // Linha final (Browse Redimensionado)

// Fator Largura do Dlg
nFtLar := (730/1474)
nLaBr3 := Round((nFtLar * nLaDlg),0) // Coluna final (Browse Redimensionado)

// ***************************************************************************************************** //
// ** Cabeçalho - Identificação do acordo e parâmetros                                                ** //
// ***************************************************************************************************** //
// Coluna 1
nLin1 := 040

cAcordo := IIf(zInclui .Or. zRenego,cAcordo,Z01->Z01_ACORDO)
nCol1L1 := IIf(zRenego .Or. !Empty(Z01->Z01_ACOREN),110,150)
@ nLin1,005 SAY "No.Acordo" OF oDlgAc2 PIXEL SIZE 055,009
@ nLin1-1,050 TO nLin1+11,nCol1L1 LABEL "" OF oDlgAc2 PIXEL
oSayAco:= TSay():New(nLin1+2,055,{|| cAcordo },oDlgAc2,,oFnt3,,,,.T.,CLR_RED,CLR_WHITE,200,020)
oSayAco:CtrlRefresh()

If zRenego .Or. !Empty(Z01->Z01_ACOREN)
	cAcoRen := IIf(zRenego,Z01->Z01_ACORDO,Z01->Z01_ACOREN)
	@ nLin1,120 SAY "Ren." OF oDlgAc2 PIXEL SIZE 055,009
	@ nLin1-1,135 TO nLin1+11,185 LABEL "" OF oDlgAc2 PIXEL
	oSayAcr:= TSay():New(nLin1+2,140,{|| cAcoRen },oDlgAc2,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
	oSayAcr:CtrlRefresh()
Endif

zUserName := IIf(zInclui .Or. zRenego,cUserName,Z01->Z01_USUARI)
nCol1L2   := IIf(zRenego .Or. !Empty(Z01->Z01_ACOREN),110,150)
@ nLin1+15,005 SAY "Usuário" OF oDlgAc2 PIXEL SIZE 055,009
@ nLin1+14,050 TO nLin1+26,nCol1L2 LABEL "" OF oDlgAc2 PIXEL
oSayUsu:= TSay():New(nLin1+17,055,{|| zUserName },oDlgAc2,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayUsu:CtrlRefresh()

zEmissao := IIf(zInclui .Or. zRenego,DtoC(dDatabase),DtoC(Z01->Z01_EMISSA))
nCol1L3  := IIf(zRenego .Or. !Empty(Z01->Z01_ACOREN),110,150)
@ nLin1+30,005 SAY "Emissão" OF oDlgAc2 PIXEL SIZE 055,009
@ nLin1+29,050 TO nLin1+41,nCol1L3 LABEL "" OF oDlgAc2 PIXEL
oSayDat:= TSay():New(nLin1+32,055,{|| zEmissao },oDlgAc2,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayDat:CtrlRefresh()

// Coluna 2
cCliDes := IIf(zInclui,Space(6),Z01->Z01_CLIENT)
cRazSoc := IIf(zInclui,"",Posicione("SA1",1,xFilial("SA1")+Z01->Z01_CLIENT,"A1_NOME"))
@ nLin1,195 SAY "Cliente" OF oDlgAc2 PIXEL SIZE 100,009
@ nLin1-1,220 MSGET oCliDes VAR cCliDes SIZE 040,010 OF oDlgAc2 PIXEL WHEN (zInclui .Or. zRenego) PICTURE "@!" F3 "CLI" VALID VldCli()
@ nLin1-1,260 TO nLin1+11,500 LABEL "" OF oDlgAc2 PIXEL
oSayRaz:= TSay():New(nLin1+2,265,{|| cRazSoc },oDlgAc2,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,200,020)
oSayRaz:SetText( Substr(cRazSoc,1,40) )
oSayRaz:CtrlRefresh()

nValNeg := IIf(zInclui .Or. zRenego,nValTit,Z01->Z01_VALNEG)
@ nLin1+15,165 SAY "Valor Negociado R$" OF oDlgAc2 PIXEL SIZE 100,009
@ nLin1+14,220 MSGET oValNeg VAR nValNeg PICTURE "@E 999,999,999.99" OF oDlgAc2 PIXEL WHEN .F. SIZE 060,009

nNumPar := IIf(zInclui .Or. zRenego,0,Z01->Z01_NPARC)
@ nLin1+15,290 SAY "No.Parcelas" OF oDlgAc2 PIXEL SIZE 100,009
@ nLin1+14,325 MSGET oNumPar VAR nNumPar SIZE 020,010 OF oDlgAc2 PIXEL WHEN (zInclui .Or. zRenego) PICTURE "@E 99" VALID (nNumPar > 0)

dVenc1a := IIf(zInclui .Or. zRenego,CtoD(""),Z01->Z01_VENC1A)
@ nLin1+15,355 SAY "Vencto.1a.P" OF oDlgAc2 PIXEL SIZE 100,009
@ nLin1+14,390 MSGET oVenc1a VAR dVenc1a SIZE 050,010 OF oDlgAc2 PIXEL WHEN (zInclui .Or. zRenego) PICTURE "@!" VALID (dVenc1a >= dDatabase)

nInterv := IIf(zInclui .Or. zRenego,30,Z01->Z01_INTERV)
@ nLin1+15,450 SAY "Intervalo" OF oDlgAc2 PIXEL SIZE 100,009
@ nLin1+14,480 MSGET oInterv VAR nInterv SIZE 020,010 OF oDlgAc2 PIXEL WHEN (zInclui .Or. zRenego) PICTURE "@E 999" VALID (nInterv > 0)

bWhenTx := {|| zInclui .Or. zRenego }
If zInclui .Or. zRenego
	cTipTax := "Acrescimo"
Else
	cTipTax := "Acrescimo"
	aTipTax := {"Acrescimo","Decrescimo"}
	If Z01->Z01_TIPTAX == "A"
		cTipTax := "Acrescimo"
	Else
		cTipTax := "Decrescimo"
	Endif	
Endif	
oComboT := TComboBox():New(nLin1+29,165,{|u| If(PCount()>0,cTipTax:=u,cTipTax)},aTipTax,065,013,oDlgAc2,,{|| PCombo1()},,,,.T.,,,,bWhenTx,,,,,"cTipTax")

nTJuros := IIf(zInclui .Or. zRenego,0,Z01->Z01_TXJURO)
@ nLin1+30,245 SAY "Taxa %" OF oDlgAc2 PIXEL SIZE 100,009
@ nLin1+29,270 MSGET oTJuros VAR nTJuros SIZE 030,010 OF oDlgAc2 PIXEL WHEN (zInclui .Or. zRenego) PICTURE "@E 99.99" VALID _CalcVaria(1)

nValAcr := IIf(zInclui .Or. zRenego,0,Z01->Z01_ACRESC)
@ nLin1+30,315 SAY "Valor R$" OF oDlgAc2 PIXEL SIZE 100,009
@ nLin1+29,345 MSGET oValAcr VAR nValAcr SIZE 060,010 OF oDlgAc2 PIXEL WHEN (zInclui .Or. zRenego) PICTURE "@E 999,999,999.99" VALID _CalcVaria(2)

bWhenRt := {|| zInclui .Or. zRenego }
If zInclui .Or. zRenego
	cRatAcr := "Ratear nas Parcelas"
Else
	cRatAcr := "Rateado nas Parcelas"
	aRatAcr := {"Rateado nas Parcelas","Digitado Manualmente"}
	If Z01->Z01_RATEIO == "M"
		cRatAcr := "Digitado Manualmente"
	Else
		cRatAcr := "Rateado nas Parcelas"
	Endif	
Endif	
oComboA := TComboBox():New(nLin1+29,420,{|u| If(PCount()>0,cRatAcr:=u,cRatAcr)},aRatAcr,080,013,oDlgAc2,,,,,,.T.,,,,bWhenRt,,,,,"cRatAcr")

// Coluna 3
nValTot := IIf(zInclui .Or. zRenego,nValTit,IIf(Z01->Z01_TIPTAX=="A",Z01->(Z01_VALNEG+Z01_ACRESC),Z01->(Z01_VALNEG-Z01_ACRESC)))
nSalAco := IIf(zInclui .Or. zRenego,nValTit,Z01->Z01_SALDO)
If zInclui .Or. zRenego
	@ nLin1+30,517 SAY "Valor Total R$" OF oDlgAc2 PIXEL SIZE 100,009
	@ nLin1+29,560 MSGET oValTot VAR nValTot SIZE 070,010 OF oDlgAc2 PIXEL WHEN .F. PICTURE "@E 999,999,999.99"
Else
	@ nLin1+15,517 SAY "Valor Total R$" OF oDlgAc2 PIXEL SIZE 100,009
	@ nLin1+14,560 MSGET oValTot VAR nValTot SIZE 070,010 OF oDlgAc2 PIXEL WHEN .F. PICTURE "@E 999,999,999.99"
	//
	@ nLin1+30,517 SAY "Saldo Acordo R$" OF oDlgAc2 PIXEL SIZE 100,009
	@ nLin1+29,560 MSGET oSalAco VAR nSalAco SIZE 070,010 OF oDlgAc2 PIXEL WHEN .F. PICTURE "@E 999,999,999.99"
Endif

If zInclui .Or. zRenego
	@ 040,560 BUTTON "Gerar Parcelas" SIZE 070,015 FONT oDlgAc2:oFont ACTION fCarga2(@aVetNew,zInclui,zRenego) OF oDlgAc2 PIXEL
Else
	fCarg02(@aVetNew,.F.)
Endif	

// Dimensões do Browse 1
n1Brw1 := 095
n1Brw2 := 005
n1Brw3 := nLaBr3 // 730
n1Brw4 := nAlBr4 // 100
nL1Ini := n1Brw1 - 8 // 067

// Dimensões do Browse 2
n2Brw1 := 075 + nAlBr4 + 040
n2Brw2 := 005
n2Brw3 := nLaBr3 // 730
n2Brw4 := nAlBr4 // 100
nL2Ini := n2Brw1 - 8 // 187

// Carrega browse
fCargaO(@aVetOld,aTitSel,zInclui,zRenego)

// ***************************************************************************************************** //
// ** Browse de títulos a receber selecionados                                                        ** //
// ***************************************************************************************************** //
oSayOld:= TSay():New(nL1Ini,005,{|| "TÍTULOS SELECIONADOS" },oDlgAc2,,oFnt4,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayOld:CtrlRefresh()

oLbxOld := TWBrowse():New(n1Brw1,n1Brw2,n1Brw3,n1Brw4,,,,oDlgAc2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxOld:AddColumn( TcColumn():New( "  "    	       ,{ || oTAmare } , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Prefixo"       ,{ || aVetOld[oLbxOld:nAt][nFdoPre] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "No.Título"     ,{ || aVetOld[oLbxOld:nAt][nFdoNum] } , "@!"       ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Parcela"       ,{ || aVetOld[oLbxOld:nAt][nFdoPar] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Tipo"          ,{ || aVetOld[oLbxOld:nAt][nFdoTip] } , "@!"       ,,,"LEFT"	,020,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Cliente"       ,{ || aVetOld[oLbxOld:nAt][nFdoCli] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Razão"         ,{ || aVetOld[oLbxOld:nAt][nFdoNom] } , "@!"       ,,,"LEFT"	,120,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Vencto."       ,{ || aVetOld[oLbxOld:nAt][nFdoVen] } , ""	      ,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Vencto.Real"   ,{ || aVetOld[oLbxOld:nAt][nFdoVeR] } , ""	      ,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Valor R$"      ,{ || aVetOld[oLbxOld:nAt][nFdoVal] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Saldo R$"      ,{ || aVetOld[oLbxOld:nAt][nFdoSal] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxOld:AddColumn( TcColumn():New( "Histórico"     ,{ || aVetOld[oLbxOld:nAt][nFdoHis] } , "@!"       ,,,"LEFT"	,100,.F.,.F.,,,,.F.,) )

oLbxOld:SetArray(aVetOld)
oLbxOld:bLDblClick := { || fClicko(@oLbxOld,@aVetOld,oLbxOld:nAt,oLbxOld:nColPos) }

// ***************************************************************************************************** //
// ** Browse de parcelas do acordo                                                                    ** //
// ***************************************************************************************************** //
oSayNew:= TSay():New(nL2Ini,005,{|| "PARCELAS DO ACORDO" },oDlgAc2,,oFnt4,,,,.T.,CLR_BLUE,CLR_WHITE,200,020) // 187
oSayNew:CtrlRefresh()

oLbxNew := TWBrowse():New(n2Brw1,n2Brw2,n2Brw3,n2Brw4,,,,oDlgAc2,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // 195,005,730,100
oLbxNew:AddColumn( TcColumn():New( "  "    	       ,{ || oTVerde } , "@!"	,,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "No.Acordo"     ,{ || aVetNew[oLbxNew:nAt][nFdnNum] } , "@!"       ,,,"LEFT"	,060,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Parcela"       ,{ || aVetNew[oLbxNew:nAt][nFdnPar] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Vencimento"    ,{ || aVetNew[oLbxNew:nAt][nFdnVen] } , ""	      ,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Valor R$"      ,{ || aVetNew[oLbxNew:nAt][nFdnVal] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Variação R$"   ,{ || aVetNew[oLbxNew:nAt][nFdnVar] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Total R$"      ,{ || aVetNew[oLbxNew:nAt][nFdnTot] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Banco"         ,{ || aVetNew[oLbxNew:nAt][nFdnBco] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Agência"       ,{ || aVetNew[oLbxNew:nAt][nFdnAge] } , "@!"       ,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Conta Banco"   ,{ || aVetNew[oLbxNew:nAt][nFdnCon] } , "@!"       ,,,"LEFT"	,060,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Cheque"        ,{ || aVetNew[oLbxNew:nAt][nFdnChe] } , "@!"       ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Emitente"      ,{ || aVetNew[oLbxNew:nAt][nFdnEmi] } , "@!"       ,,,"LEFT"	,120,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "NP"            ,{ || aVetNew[oLbxNew:nAt][nFdnNpr] } , "@!"       ,,,"LEFT"	,060,.F.,.F.,,,,.F.,) )
oLbxNew:AddColumn( TcColumn():New( "Observações"   ,{ || aVetNew[oLbxNew:nAt][nFdnObs] } , "@!"       ,,,"LEFT"	,200,.F.,.F.,,,,.F.,) )

oLbxNew:SetArray(aVetNew)
oLbxNew:bLDblClick := { || fClickn(@oLbxNew,@aVetNew,oLbxNew:nAt,oLbxNew:nColPos) }

oDlgAc2:Activate(,,,.T.,{|| _Validar(aVetNew,zInclui,zRenego) },,{|| EnchoiceBar(oDlgAc2,bOkAco2,bCanAc2) } )

If nOpcAc2 == 1
	If zInclui
		MsgRun("Incluindo acordo... aguarde","Processando", {|| _Etapa02(1,aVetOld,aVetNew,aTitSel) })
	ElseIf zAltera
		MsgRun("Alterando acordo... aguarde","Processando", {|| _Etapa02(1,aVetOld,aVetNew,aTitSel) })
	ElseIf zExclui
		MsgRun("Excluindo acordo... aguarde","Processando", {|| _Etapa02(1,aVetOld,aVetNew,aTitSel) })
	ElseIf zRenego
		MsgRun("Renegociando acordo... aguarde","Processando", {|| _Etapa02(1,aVetOld,aVetNew,aTitSel) })
	Endif	
Else
	If zInclui
		MsgRun("Liberando reserva dos títulos selecionados... aguarde","Processando",{|| _Etapa02(2,aVetOld,aVetNew,aTitSel) })
	Endif	
Endif

RestArea(aArea)

Return

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

Local lRetorno := ( ExistCpo("SA1") )

If lRetorno
	cRazSoc := Posicione("SA1",1,xFilial("SA1")+cCliDes,"A1_NOME")
	oSayRaz:SetText( Substr(cRazSoc,1,40) )
	oSayRaz:Refresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCombo1  ¦ Autor ¦ Fabrica ERPBR ¦  Data ¦  06/02/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alerações após seleção do combo 1.		 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function PCombo1()

nTJuros := 0.00
nValAcr := 0.00
nValTot := nValNeg

oTJuros:Refresh()
oValAcr:Refresh()
oValTot:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _CalcVaria ¦ Autor ¦ Fabrica ERPBR ¦  Data ¦  04/10/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calculo do valor total considerando o acréscimo.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _CalcVaria(zModo)

If zModo == 1 // % Variação
	If cTipTax == "Acrescimo"
		nValAcr := Round((nValNeg * (nTJuros/100)),2)
		nValTot := nValNeg + nValAcr
		oValAcr:Refresh()
		oValTot:Refresh()
	Else
		nValAcr := Round((nValNeg * (nTJuros/100)),2)
		nValTot := nValNeg - nValAcr
		oValAcr:Refresh()
		oValTot:Refresh()
	Endif
Else // Valor Variação
	If cTipTax == "Acrescimo"
		nTJuros := Round(((nValAcr/nValNeg)*100),2)
		nValTot := nValNeg + nValAcr
		oValAcr:Refresh()
		oValTot:Refresh()
	Else
		nTJuros := Round(((nValAcr/nValNeg)*100),2)
		nValTot := nValNeg - nValAcr
		oValAcr:Refresh()
		oValTot:Refresh()
	Endif
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClicko   ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦  20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do browse Títulos.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClicko(oLbxOld,aVetOld,nLin,nCol)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClickn   ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦  20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do browse Parcelas.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClickn(oLbxNew,aVetNew,nLin,nCol)

Local _x

If zInclui .Or. zRenego
	If nCol == nFdnBco // Banco
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
		If nLin == 1
			If Len(aVetNew) > 1
				For _x := 2 to Len(aVetNew)
					aVetNew[_x][nFdnBco] := aVetNew[1][nFdnBco]
				Next _x
				oLbxNew:Refresh()
			Endif	
		Endif
	Endif
Endif

If zInclui .Or. zRenego
	If nCol == nFdnAge // Agência
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
		If nLin == 1
			If Len(aVetNew) > 1
				For _x := 2 to Len(aVetNew)
					aVetNew[_x][nFdnAge] := aVetNew[1][nFdnAge]
				Next _x
				oLbxNew:Refresh()
			Endif	
		Endif
	Endif
Endif

If zInclui .Or. zRenego
	If nCol == nFdnCon // Conta
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
		If nLin == 1
			If Len(aVetNew) > 1
				For _x := 2 to Len(aVetNew)
					aVetNew[_x][nFdnCon] := aVetNew[1][nFdnCon]
				Next _x
				oLbxNew:Refresh()
			Endif	
		Endif
	Endif
Endif

If zInclui .Or. zRenego
	If nCol == nFdnChe // Cheque
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
		If nLin == 1
			If Len(aVetNew) > 1
				For _x := 2 to Len(aVetNew)
					If !Empty(aVetNew[1][nFdnChe])
						aVetNew[_x][nFdnChe] := StrZero( (Val(aVetNew[1][nFdnChe])+(_x-1)), Len(AllTrim(aVetNew[1][nFdnChe])) )
					Else
						aVetNew[_x][nFdnChe] := Space(15)
					Endif	
				Next _x
				oLbxNew:Refresh()
			Endif	
		Endif
	Endif
Endif

If zInclui .Or. zRenego
	If nCol == nFdnEmi // Emitente
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
		If nLin == 1
			If Len(aVetNew) > 1
				For _x := 2 to Len(aVetNew)
					aVetNew[_x][nFdnEmi] := aVetNew[1][nFdnEmi]
				Next _x
				oLbxNew:Refresh()
			Endif	
		Endif
	Endif
Endif

If zInclui .Or. zRenego
	If nCol == nFdnNpr // NP
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
		If nLin == 1
			If Len(aVetNew) > 1
				For _x := 2 to Len(aVetNew)
					If !Empty(aVetNew[1][nFdnNpr])
						aVetNew[_x][nFdnNpr] := StrZero( (Val(aVetNew[1][nFdnNpr])+(_x-1)), Len(AllTrim(aVetNew[1][nFdnNpr])) )
					Else
						aVetNew[_x][nFdnNpr] := Space(9)
					Endif	
				Next _x
				oLbxNew:Refresh()
			Endif	
		Endif
	Endif
Endif
	
If zInclui .Or. zRenego
	If nCol == nFdnVen // Vencimento
		nVal := aVetNew[nLin][nCol]
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
		If aVetNew[nLin][nCol] != nVal // Checa se alterou o conteúdo
			dNewVen := aVetNew[nLin][nCol]
			If Empty(dNewVen)
				MsgAlert("Vencimento inválido.")
				aVetNew[nLin][nCol] := nVal
			ElseIf dNewVen < Date()
				MsgAlert("Vencimento retroativo não permitido.")
				aVetNew[nLin][nCol] := nVal
			Endif
		Endif
	Endif
Endif

If zInclui .Or. zRenego
	If nCol == nFdnVal // Valor
		nVal := aVetNew[nLin][nCol]
		lEditCell( @aVetNew , @oLbxNew , "@E 99,999,999,999.99" , nCol ) 
		If aVetNew[nLin][nCol] != nVal // Checa se alterou o conteúdo
			If aVetNew[nLin][nCol] <= 0
				MsgAlert("Valor inválido.")
				aVetNew[nLin][nCol] := nVal
			Else
				If cTipTax == "Acrescimo"
					aVetNew[nLin][nFdnTot] := aVetNew[nLin][nFdnVal] + aVetNew[nLin][nFdnVar]
				Else
					aVetNew[nLin][nFdnTot] := aVetNew[nLin][nFdnVal] - aVetNew[nLin][nFdnVar]
				Endif	
			Endif
		Endif
	Endif
Endif

If zInclui .Or. zRenego
	If nCol == nFdnVar // Variação
		nVal := aVetNew[nLin][nCol]
		lEditCell( @aVetNew , @oLbxNew , "@E 99,999,999,999.99" , nCol ) 
		If aVetNew[nLin][nCol] != nVal // Checa se alterou o conteúdo
			If aVetNew[nLin][nCol] < 0
				MsgAlert(cTipTax+" inválido.")
				aVetNew[nLin][nCol] := nVal
			Else
				If cTipTax == "Acrescimo"
					aVetNew[nLin][nFdnTot] := aVetNew[nLin][nFdnVal] + aVetNew[nLin][nFdnVar]
				Else
					aVetNew[nLin][nFdnTot] := aVetNew[nLin][nFdnVal] - aVetNew[nLin][nFdnVar]
				Endif	
			Endif
		Endif
	Endif
Endif

If zInclui .Or. zRenego .Or. Altera
	If nCol == nFdnObs // Observações
		nVal := aVetNew[nLin][nCol]
		lEditCell( @aVetNew , @oLbxNew , "@!" , nCol ) 
	Endif
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCargaO  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carrega os títulos selecionados.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCargaO(aVetOld,aTitSel,zInclui,zRenego)

Local _x

If zInclui

	For _x := 1 to Len(aTitSel)
		SE1->(DbGoto(aTitSel[_x]))
		AAdd(aVetOld,{ .T.,;
					   SE1->E1_PREFIXO,;
					   SE1->E1_NUM,;
					   SE1->E1_PARCELA,;
					   SE1->E1_TIPO,;
					   SE1->E1_CLIENTE,;
					   SA1->A1_NOME,;
					   SE1->E1_VENCTO,;
					   SE1->E1_VENCREA,;
					   SE1->E1_VALOR,;
					   SE1->(E1_SALDO+E1_SDACRES),;
					   0.00,;
					   SE1->E1_HIST })
	Next _x

ElseIf zRenego

	nTotPar := 0
	nSdoAco := u_SdoAcor(Z01->Z01_ACORDO)
	For _x := 1 to Len(aTitSel)
		SE1->(DbGoto(aTitSel[_x]))
		//
		DbSelectArea("ZE1")
		DbSetOrder(1)
		DbSeek( xFilial("ZE1") + Z01->Z01_ACORDO + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE )
	    If _x == Len(aTitSel)
	    	nSdoTit := nSdoAco - nTotPar
		Else
		    nSdoTit := Round(((ZE1->ZE1_SALDO / Z01->Z01_VALNEG) * nSdoAco),2)
		    nTotPar += nSdoTit
		Endif
		//
		AAdd(aVetOld,{ .T.,;
					   SE1->E1_PREFIXO,;
					   SE1->E1_NUM,;
					   SE1->E1_PARCELA,;
					   SE1->E1_TIPO,;
					   SE1->E1_CLIENTE,;
					   SA1->A1_NOME,;
					   SE1->E1_VENCTO,;
					   SE1->E1_VENCREA,;
					   SE1->E1_VALOR,;
					   nSdoTit,;
					   0.00,;
					   SE1->E1_HIST })
	Next _x

Else

	DbSelectArea("ZE1")
	DbSetOrder(1)
	If DbSeek( xFilial("ZE1") + Z01->Z01_ACORDO )
		While !Eof() .And. ZE1->ZE1_FILIAL == xFilial("ZE1") .And. ZE1->ZE1_ACORDO == Z01->Z01_ACORDO

			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek( ZE1->(ZE1_FILIAL+ZE1_PREFIX+ZE1_NUM+ZE1_PARCEL+ZE1_TIPO+ZE1_CLIENT) )
	
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SE1->E1_CLIENTE )

			AAdd(aVetOld,{ .T.,;
						   SE1->E1_PREFIXO,;
						   SE1->E1_NUM,;
						   SE1->E1_PARCELA,;
						   SE1->E1_TIPO,;
						   SE1->E1_CLIENTE,;
						   SA1->A1_NOME,;
						   SE1->E1_VENCTO,;
						   ZE1->ZE1_VENCRE,;
						   SE1->E1_VALOR,;
						   ZE1->ZE1_SALDO,;
						   SE1->E1_HIST })
			
			ZE1->(DbSkip())
		Enddo
	Endif

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarga2  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gera as parcelas do acordo.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarga2(aVetNew,zInclui,zRenego)

Local lExecuta := .T.

If Empty(cCliDes) .Or. (nNumPar <= 0) .Or. Empty(dVenc1a) .Or. (nInterv <= 0)
	MsgInfo("Parâmetros insuficientes.")
	lExecuta := .F.
Endif

If lExecuta
	MsgRun("Gerando parcelas... aguarde","Processando",{|| fCarg02(@aVetNew,zInclui,zRenego) })
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg02  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  20/08/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa geração das parcelas do acordo.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg02(aVetNew,zInclui,zRenego)

Local nParAco := 0
Local nVlrAcu := 0
Local nAcrAcu := 0
Local cDiaVen := Substr(DtoS(dVenc1a),7,2)
Local _x

If Len(aVetNew) > 0
	If !MsgYesNo("Deseja sobrepor as parcelas geradas ?","Aviso","INFO")
		Return
	Endif
Endif

aVetNew := {}

If zInclui .Or. zRenego

	For _x := 1 to nNumPar
	
		nParAco += 1	
		nMesLas := IIf(_x == 1, Month(dVenc1a), Month(dVencto) )
		nAnoLas := IIf(_x == 1, Year(dVenc1a) , Year(dVencto)  )
		dVencto := IIf(_x == 1, dVenc1a, (dDtLast+nInterv) )
		dDtLast := dVencto
//		dVencto := DataValida(dVencto)
		lMensal := ( Mod(nInterv,30) == 0 )
		nFatMen := (nInterv / 30)

		If lMensal // Para intervalo múltiplo de 30 dias (padrão), calcula como parcelas mensais conforme o fator informado.
			If _x > 1
				lAddAno := .F.
				nPrxMes := nMesLas+nFatMen
				nAnoAtu := nAnoLas
				If nPrxMes > 12
					lAddAno := .T.
					nPrxMes := nPrxMes - 12
				Endif
				nPrxAno := IIf(lAddAno,nAnoAtu+1,nAnoAtu)
				dVencto := StoD((StrZero(nPrxAno,4)+StrZero(nPrxMes,2)+cDiaVen))
//				dVencto := DataValida(dVencto)
				While .T.
					If Month(dVencto) == nPrxMes .And. Year(dVencto) == nPrxAno
						dDtLast := dVencto
						Exit
					Else
						dVencto += 1
						dVencto := DataValida(dVencto)
					Endif
				Enddo
			Endif
		Endif	

		nValorP := IIf( _x == nNumPar, (nValNeg-nVlrAcu), (Round((nValNeg / nNumPar),2)) )
		If cRatAcr == "Ratear nas Parcelas"
			nValorA := IIf( _x == nNumPar, (nValAcr-nAcrAcu), (Round((nValAcr / nNumPar),2)) )
		Else
			nValorA := 0
		Endif
		nVlrAcu += nValorP
		nAcrAcu += nValorA
	
		AAdd(aVetNew,{ .T.,;
					   cAcordo,;
					   StrZero(nParAco,2),;
					   dVencto,;
					   nValorP,;
					   nValorA,;
		               IIf(cTipTax=="Acrescimo",(nValorP + nValorA),(nValorP - nValorA)),;
                       Space(3),;
                       Space(5),;
                       Space(10),;
                       Space(15),;
                       Space(40),;
                       Space(9),;
					   Space(200) })
	
	Next _x

	// Atualiza acréscimo informado nos títulos negociados
	tFatAcr := (nValAcr/nValNeg)
	tAcrAcu := 0
	For _x := 1 to Len(aVetOld)
		tAcresc := Round((aVetOld[_x][nFdoSal] * tFatAcr),2)
		If _x == Len(aVetOld)
			tAcresc := nValAcr - tAcrAcu // Arredonda na última parcela
		Endif
		tAcrAcu += tAcresc
	Next _x

	oLbxNew:SetArray(aVetNew)
	oLbxNew:Gotop()
	oLbxNew:Refresh()
	oLbxOld:Refresh()
	oDlgAc2:Refresh()

Else

	DbSelectArea("Z02")
	DbSetOrder(1)
	If DbSeek( xFilial("Z02") + Z01->Z01_ACORDO )
		While !Eof() .And. Z02->Z02_FILIAL == xFilial("Z02") .And. Z02->Z02_ACORDO == Z01->Z01_ACORDO

			AAdd(aVetNew,{ .T.,;
						   Z02->Z02_ACORDO,;
						   Z02->Z02_PARCEL,;
						   Z02->Z02_VENCTO,;
						   Z02->Z02_VALOR,;
						   Z02->Z02_ACRESC,;
						   IIf(Z01->Z01_TIPTAX=="A",Z02->(Z02_VALOR + Z02_ACRESC),Z02->(Z02_VALOR - Z02_ACRESC)),;
						   Z02->Z02_BANCO,;
						   Z02->Z02_AGENCI,;
						   Z02->Z02_CONTA,;
						   Z02->Z02_CHEQUE,;
						   Z02->Z02_EMITEN,;
						   Z02->Z02_NP,;
						   Z02->Z02_OBS })
			
			Z02->(DbSkip())
		Enddo
	Endif

Endif

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

Static Function _Validar(aVetNew,zInclui,zRenego)

Local lRetorno := .T.
Local pValNeg  := 0
Local pValAcr  := 0
Local pValTot  := 0
Local _x

If zInclui .Or. zRenego

	If Len(aVetNew) == 0
		MsgAlert("As parcelas não foram geradas.")
		lRetorno := .F.
	Endif
	
	If lRetorno
		For _x := 1 to Len(aVetNew)
			pValNeg += aVetNew[_x][nFdnVal]
			pValAcr += aVetNew[_x][nFdnVar]
			pValTot += aVetNew[_x][nFdnTot]
		Next _x
		If cTipTax == "Acrescimo"
			zTotNeg := (nValNeg + nValAcr)
			zTotDig := (pValNeg + pValAcr)
		Else
			zTotNeg := (nValNeg - nValAcr)
			zTotDig := (pValNeg - pValAcr)
		Endif	
		//
		If nValNeg != pValNeg
			MsgAlert("Valor negociado é diferente da soma das parcelas."+cEOL+;
					 "Valor negociado: R$ "+AllTrim(STR(nValNeg,17,2))+cEOL+;
					 "Valor digitado: R$ "+AllTrim(STR(pValNeg,17,2)) )
			lRetorno := .F.
		ElseIf nValTot != pValTot
			MsgAlert("Total negociado é diferente do total das parcelas."+cEOL+;
					 "Total negociado: R$ "+AllTrim(STR(nValTot,17,2))+cEOL+;
					 "Total digitado: R$ "+AllTrim(STR(pValTot,17,2)) )
			lRetorno := .F.
		ElseIf nValAcr != pValAcr
			pTipTax := IIf(cTipTax=="Acrescimo","acréscimo","decréscimo")
			MsgAlert("Valor do "+pTipTax+" é diferente da soma das parcelas."+cEOL+;
					 "Valor do "+pTipTax+": R$ "+AllTrim(STR(nValAcr,17,2))+cEOL+;
					 "Valor digitado: R$ "+AllTrim(STR(pValAcr,17,2)) )
			lRetorno := .F.
		ElseIf zTotNeg != zTotDig
			pTipTax := IIf(cTipTax=="Acrescimo","Acréscimos","Decréscimos")			
			MsgAlert("Valor total (Negociado + "+pTipTax+") é diferente da soma das parcelas."+cEOL+;
					 "Valor total (Negociado + "+pTipTax+"): R$ "+AllTrim(STR(zTotNeg,17,2))+cEOL+;
					 "Valor digitado: R$ "+AllTrim(STR(zTotDig,17,2)) )
			lRetorno := .F.
		Endif
		//
	Endif

	If lRetorno
		For _x := 1 to Len(aVetNew)
			If !Empty(aVetNew[_x][nFdnChe]) .And. !Empty(aVetNew[_x][nFdnNpr])
				MsgAlert("Informe 'Cheque' ou 'NP'. Não é permitido informar ambos na mesma parcela.")
				lRetorno := .F.
				Exit
			Endif
		Next _x
	Endif

	If lRetorno
		If zRenego
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek( xFilial("SE1") + "ACO" + cAcoRen )
			While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1") + "ACO" + cAcoRen
				If SE1->E1_SALDO > 0 .And. SE1->E1_SITUACA <> "0"
					MsgAlert("A parcela "+SE1->E1_PARCELA+" do Acordo "+cAcoRen+" precisa ser transferida para carteira antes de prosseguir.")
					lRetorno := .F.
					Exit
				Endif
				SE1->(DbSkip())
			Enddo
		Endif
	Endif

ElseIf zAltera

ElseIf zExclui

Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Etapa02  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processa etapa 2.					  					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Etapa02(nModo,aVetOld,aVetNew,aTitSel)

Local _x
Private lMsErroAuto := .F.

If zInclui .Or. zRenego

	// Refaz o sequencial do acordo para prever inclusão simulatânea. 
	// Este será o número atribuído oficialmente.
	cAcoAnt := cAcordo
	cPrxNum := u_PrxAcor()
	cAcordo := cPrxNum

    Begin Transaction
	
	If nModo == 1 // Gravar
		//Desbloqueia o vendedor
		lDesblq := .F.
		nRecSa3 := 0
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + cCliDes )
		If !Empty(SA1->A1_VEND)
			DbSelectArea("SA3")
			DbSetOrder(1)
			If DbSeek( xFilial("SA3") + SA1->A1_VEND )
				If SA3->A3_MSBLQL == "1"
					lDesblq := .T.
					nRecSa3 := Recno()
					RecLock("SA3",.F.)
					SA3->A3_MSBLQL := "2"
					MsUnLock()
				Endif
			Endif
		Endif
		// Acordo
		zTipo := IIf(!Empty(aVetNew[1][nFdnChe]),"CH",IIf(!Empty(aVetNew[1][nFdnNpr]),"NP","ICF"))
		DbSelectArea("Z01")
		RecLock("Z01",.T.)
		Z01->Z01_FILIAL := xFilial("Z01")
		Z01->Z01_ACORDO := cAcordo
		Z01->Z01_TIPO   := zTipo
		Z01->Z01_EMISSA := dDatabase
		Z01->Z01_CLIENT := cCliDes
		Z01->Z01_NOME   := cRazSoc
		Z01->Z01_VALNEG := nValNeg
		Z01->Z01_NPARC  := Len(aVetNew)
		Z01->Z01_VENC1A := aVetNew[1][nFdnVen]
		Z01->Z01_INTERV := nInterv
		Z01->Z01_TXJURO := nTJuros
		Z01->Z01_ACRESC := nValAcr
		Z01->Z01_RATEIO := IIf(cRatAcr == "Ratear nas Parcelas","R","M")
		Z01->Z01_TIPTAX := IIf(cTipTax == "Acrescimo","A","D")
		Z01->Z01_USUARI := cUserName
		Z01->Z01_SALDO  := IIf(cTipTax == "Acrescimo",(nValNeg+nValAcr),(nValNeg-nValAcr))
		Z01->Z01_STATUS := "A"
		If zRenego
			Z01->Z01_ACOREN := cAcoRen
		Endif
		MsUnLock()
		// Titulos selecionados
		For _x := 1 to Len(aVetOld)
			DbSelectArea("ZE1")
			RecLock("ZE1",.T.)
			ZE1->ZE1_FILIAL := xFilial("ZE1")
			ZE1->ZE1_ACORDO := cAcordo
			ZE1->ZE1_PREFIX := aVetOld[_x][nFdoPre]
			ZE1->ZE1_NUM    := aVetOld[_x][nFdoNum]
			ZE1->ZE1_PARCEL := aVetOld[_x][nFdoPar]
			ZE1->ZE1_TIPO   := aVetOld[_x][nFdoTip]
			ZE1->ZE1_CLIENT := aVetOld[_x][nFdoCli]
			ZE1->ZE1_VENCRE := aVetOld[_x][nFdoVeR]
			ZE1->ZE1_SALDO  := aVetOld[_x][nFdoSal]
			MsUnLock()
		Next _x	
		// Parcelas geradas
		lPGerOk := .T.
		For _x := 1 to Len(aVetNew)
			zTipo := IIf(!Empty(aVetNew[_x][nFdnChe]),"CH",IIf(!Empty(aVetNew[_x][nFdnNpr]),"NP","ICF"))
			zHist := IIf(zTipo=="CH","CH "+AllTrim(aVetNew[_x][nFdnBco])+"-"+AllTrim(aVetNew[_x][nFdnAge])+"-"+AllTrim(aVetNew[_x][nFdnCon])+"-"+AllTrim(aVetNew[_x][nFdnChe]),;
					 IIf(zTipo=="NP","NP "+AllTrim(aVetNew[_x][nFdnNpr]),""))
			zCheq := aVetNew[_x][nFdnChe]
			zNP   := aVetNew[_x][nFdnNpr]
			DbSelectArea("Z02")
			RecLock("Z02",.T.)
			Z02->Z02_FILIAL := xFilial("Z02")
			Z02->Z02_ACORDO := cAcordo
			Z02->Z02_PARCEL := aVetNew[_x][nFdnPar]
			Z02->Z02_TIPO   := zTipo
			Z02->Z02_VENCTO := aVetNew[_x][nFdnVen]
			Z02->Z02_VALOR  := aVetNew[_x][nFdnVal]
			Z02->Z02_ACRESC := aVetNew[_x][nFdnVar]
            Z02->Z02_BANCO  := aVetNew[_x][nFdnBco]
            Z02->Z02_AGENCI := aVetNew[_x][nFdnAge]
            Z02->Z02_CONTA  := aVetNew[_x][nFdnCon]
            Z02->Z02_CHEQUE := aVetNew[_x][nFdnChe]
            Z02->Z02_EMITEN := aVetNew[_x][nFdnEmi]
            Z02->Z02_NP     := aVetNew[_x][nFdnNpr]
			Z02->Z02_OBS    := aVetNew[_x][nFdnObs]
			Z02->Z02_SALDO  := IIf(cTipTax=="Acrescimo",(aVetNew[_x][nFdnVal] + aVetNew[_x][nFdnVar]),(aVetNew[_x][nFdnVal] - aVetNew[_x][nFdnVar]))
			MsUnLock()
			// Gera o título no contas a receber
			gAcresc := IIf(cTipTax=="Acrescimo",Z02->Z02_ACRESC,0)
			gDecres := IIf(cTipTax=="Acrescimo",0,Z02->Z02_ACRESC)
			DbSelectArea("SE1")
			aVetor := { { "E1_PREFIXO"  , "ACO"                       , Nil },;
			            { "E1_NUM"      , Z02->Z02_ACORDO             , Nil },;
			            { "E1_PARCELA"  , Z02->Z02_PARCEL             , Nil },;
			            { "E1_TIPO"     , zTipo                       , Nil },;
			            { "E1_NATUREZ"  , PadR("101001",10)           , Nil },;
			            { "E1_CLIENTE"  , cCliDes                     , Nil },;
			            { "E1_LOJA"     , "01"                        , Nil },;
			            { "E1_EMISSAO"  , dDatabase                   , Nil },;
			            { "E1_VENCTO"   , Z02->Z02_VENCTO             , Nil },;
			            { "E1_VENCREA"  , DataValida(Z02->Z02_VENCTO) , Nil },;
			            { "E1_VALOR"    , Z02->Z02_VALOR              , Nil },;
			            { "E1_ACRESC"   , gAcresc                     , Nil },;
			            { "E1_DECRESC"  , gDecres		              , Nil },;
			            { "E1_HIST"     , zHist                       , Nil },;
			            { "E1_ZZOBS"    , Z02->Z02_OBS                , Nil },;
			            { "E1_ZCHACOR"  , zCheq                       , Nil },;
			            { "E1_ZNPACOR"  , zNP                         , Nil },;
			            { "E1_ZZACORD"  , Z02->Z02_ACORDO             , Nil } }
			lMsErroAuto := .F.
			MsExecAuto({|x,y| FINA040(x,y)},aVetor,3)
			If lMsErroAuto
				lPGerOk := .F.
				DisarmTransaction()
				MostraErro()
				MsgAlert("Falha na execução da geração do título a receber:"+cEOL+;
				"Título: ACO-"+AllTrim(Z02->Z02_ACORDO)+"-"+AllTrim(Z02->Z02_PARCEL)+cEOL+;
				"O processo será interrompido e os dados restaurados na condição original.")
				//
				For _x := 1 to Len(aTitSel)
					SE1->(DbGoto(aTitSel[_x]))
					RecLock("SE1",.F.)
					SE1->E1_ZZACORD := ""
					MsUnLock()
				Next _x
				//
				Exit
			Endif
			//
		Next _x
		If lDesblq
			DbSelectArea("SA3")
			DbGoto(nRecSa3)
			RecLock("SA3",.F.)
			SA3->A3_MSBLQL := "1" // Bloqueia novamente
			MsUnLock()
		Endif
		//
		If zInclui
			// Títulos selecionados
			If lPGerOk
				lPBxaOk := .T.
				For _x := 1 to Len(aVetOld)
					//					
					zPrefix := aVetOld[_x][nFdoPre]
					zNumero := aVetOld[_x][nFdoNum]
					zParcel := aVetOld[_x][nFdoPar]
					zTipo   := aVetOld[_x][nFdoTip]
					zClient := aVetOld[_x][nFdoCli]
					//
					DbSelectArea("SE1")
					DbSetOrder(1)
					DbSeek( xFilial("SE1") + zPrefix + zNumero + zParcel + zTipo + zClient )
					//
					zPort := SE1->E1_PORTADO
					RecLock("SE1",.F.)
					SE1->E1_PORTADO := ""
					SE1->E1_AGEDEP  := ""
					SE1->E1_CONTA   := ""
					SE1->E1_SITUACA := "0"
					MsUnLock()
					// Baixa o título negociado
					zHisBx := "Valor Baixado p/Acordo "+AllTrim(cAcordo)
					aBaixa := { {"E1_PREFIXO"  , SE1->E1_PREFIXO                     , Nil},;
								{"E1_NUM"	   , SE1->E1_NUM                         , Nil},; 
								{"E1_PARCELA"  , SE1->E1_PARCELA                     , Nil},;
								{"E1_TIPO"	   , SE1->E1_TIPO                        , Nil},;
								{"AUTMOTBX"	   , "ACO"                               , Nil},;
								{"AUTDTBAIXA"  , dDatabase                           , Nil},;
								{"AUTDTCREDITO", dDatabase                           , Nil},;
								{"AUTHIST"	   , zHisBx                              , Nil},; 
								{"AUTACRESC"   , SE1->E1_SDACRES                     , Nil},; 
								{"AUTMULTA"	   , SE1->E1_MULTA                       , Nil},; 
								{"AUTVALREC"   , SE1->(E1_SALDO+E1_SDACRES+E1_MULTA) , Nil} }
					lMsErroAuto := .F.
					MsExecAuto({|x,y| FINA070(x,y)},aBaixa,3)  
					If lMsErroAuto
						lPBxaOk := .F.
						DisarmTransaction()
						MostraErro()
						MsgAlert("Falha na execução da baixa a receber:"+cEOL+;
						"Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+"-"+AllTrim(SE1->E1_PARCELA)+cEOL+;
						"O processo será interrompido e os dados restaurados na condição original.")
						//
						For _x := 1 to Len(aTitSel)
							SE1->(DbGoto(aTitSel[_x]))
							RecLock("SE1",.F.)
							SE1->E1_ZZACORD := ""
							MsUnLock()
						Next _x
						//
						Exit
					Else
						RecLock("SE1",.F.)
						SE1->E1_ZZACORD := ""
						SE1->E1_PORTADO := zPort // Regrava o Portador. Solicitação Gleice em 18/07/2019.
						MsUnLock()
						//
						zSeq := SE5->E5_SEQ
						zRec := SE5->(Recno())
						DbSelectArea("SE5")
						DbSetOrder(7)
						DbSeek( xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+zSeq )
						While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) == xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+zSeq
							RecLock("SE5",.F.)
							SE5->E5_DOCUMEN := "ACO"+cAcordo
							MsUnLock()
							SE5->(DbSkip())
						Enddo
						SE5->(DbGoto(zRec))
					Endif
				Next _x
				If lPBxaOk
					If cAcordo != cAcoAnt
						MsgInfo("O número do acordo foi atualizado para a próxima sequência disponível.")
					Endif
					MsgInfo("Acordo "+cAcordo+" incluído com sucesso !!")
				Endif	
			Endif
		ElseIf zRenego
			// Títulos renegociados
			If lPGerOk
				//tFatAcr := (nValAcr/nValNeg)
				//tAcrAcu := 0
				lPBxaOk := .T.
				aTitRen := {}
				DbSelectArea("SE1")
				DbSetOrder(1)
				DbSeek( xFilial("SE1") + "ACO" + cAcoRen )
				While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1") + "ACO" + cAcoRen
					If SE1->E1_SALDO > 0
						AAdd(aTitRen,SE1->(Recno()))
					Endif
					SE1->(DbSkip())
				Enddo
                For _x := 1 to Len(aTitRen)
					DbSelectArea("SE1")
					SE1->(DbGoto(aTitRen[_x]))
					//
					zPrefix := SE1->E1_PREFIXO
					zNumero := SE1->E1_NUM
					zParcel := SE1->E1_PARCELA
					zTipo   := SE1->E1_TIPO
					zClient := SE1->E1_CLIENTE
					//tAcresc := Round((SE1->(E1_SALDO+E1_SDACRES-E1_SDDECRE) * tFatAcr),2)
					//
					//If _x == Len(aTitRen)
						//tAcresc := nValAcr - tAcrAcu // Arredonda na última parcela
					//Endif
					//
					tMulta := 0
					tDesco := 0
				/*	If cTipTax == "Acrescimo"
						tMulta := tAcresc
						RecLock("SE1",.F.)
						SE1->E1_MULTA := tAcresc
						MsUnLock()
					Else
						tDesco := tAcresc
						RecLock("SE1",.F.)
						SE1->E1_DESCONT := tAcresc
						MsUnLock()
					Endif	*/
					//			
					//tAcrAcu += tAcresc
					// Baixa o título negociado
					zHisBx := "Valor Baixado p/Acordo "+AllTrim(cAcordo)
					zVlRec := SE1->(E1_SALDO+E1_SDACRES-E1_SDDECRE)
					aBaixa := { {"E1_PREFIXO"  , SE1->E1_PREFIXO  , Nil},;
								{"E1_NUM"	   , SE1->E1_NUM      , Nil},; 
								{"E1_PARCELA"  , SE1->E1_PARCELA  , Nil},;
								{"E1_TIPO"	   , SE1->E1_TIPO     , Nil},;
								{"AUTMOTBX"	   , "ACO"            , Nil},;
								{"AUTDTBAIXA"  , dDatabase        , Nil},;
								{"AUTDTCREDITO", dDatabase        , Nil},;
								{"AUTHIST"	   , zHisBx           , Nil},; 
								{"AUTACRESC"   , SE1->E1_SDACRES  , Nil},; 
								{"AUTDECRESC"  , SE1->E1_SDDECRE  , Nil},; 
								{"AUTMULTA"	   , tMulta		      , Nil},; 
								{"AUTDESCONT"  , tDesco			  , Nil},; 
								{"AUTVALREC"   , zVlRec           , Nil} }
					lMsErroAuto := .F.
					MsExecAuto({|x,y| FINA070(x,y)},aBaixa,3)  
					If lMsErroAuto
						lPBxaOk := .F.
						DisarmTransaction()
						MostraErro()
						MsgAlert("Falha na execução da baixa a receber:"+cEOL+;
						"Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+"-"+AllTrim(SE1->E1_PARCELA)+cEOL+;
						"O processo será interrompido e os dados restaurados na condição original.")
						Exit
					Else
						zSeq := SE5->E5_SEQ
						zRec := SE5->(Recno())
						DbSelectArea("SE5")
						DbSetOrder(7)
						DbSeek( xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+zSeq )
						While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) == xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+zSeq
							RecLock("SE5",.F.)
							SE5->E5_DOCUMEN := "ACO"+cAcordo
							MsUnLock()
							SE5->(DbSkip())
						Enddo
						SE5->(DbGoto(zRec))
					Endif
				Next _x
				//
				u_AcUpdLeg(Z01->Z01_FILIAL,cAcoRen)
				//
				If lPBxaOk
					If cAcordo != cAcoAnt
						MsgInfo("O número do acordo foi atualizado para a próxima sequência disponível.")
					Endif
					MsgInfo("Acordo "+cAcordo+" incluído com sucesso !!")
				Endif	
			Endif
		Endif	
		//
	Else // Liberar a reserva dos títulos selecionados
		If zInclui
			For _x := 1 to Len(aTitSel)
				SE1->(DbGoto(aTitSel[_x]))
				RecLock("SE1",.F.)
				SE1->E1_ZZACORD := ""
				MsUnLock()
			Next _x
		Endif	
	Endif

	End Transaction
	MsUnLockAll()

ElseIf zAltera

	For _x := 1 to Len(aVetNew)
		zParcel := aVetNew[_x][nFdnPar]
		DbSelectArea("Z02")
		DbSetOrder(1)
		DbSeek( xFilial("Z02") + cAcordo + zParcel )
		RecLock("Z02",.F.)
		Z02->Z02_BANCO  := aVetNew[_x][nFdnBco]
		Z02->Z02_AGENCI := aVetNew[_x][nFdnAge]
		Z02->Z02_CONTA  := aVetNew[_x][nFdnCon]
		Z02->Z02_CHEQUE := aVetNew[_x][nFdnChe]
		Z02->Z02_EMITEN := aVetNew[_x][nFdnEmi]
		Z02->Z02_NP     := aVetNew[_x][nFdnNpr]
		Z02->Z02_OBS    := aVetNew[_x][nFdnObs]
		MsUnLock()
	Next _x
	MsgInfo("Acordo alterado com sucesso !!")

ElseIf zExclui

    Begin Transaction

	DbSelectArea("Z01")
	DbSetOrder(1)
	DbSeek( xFilial("Z01") + cAcordo )
	lReneg := !Empty(Z01->Z01_ACOREN)
	zAcoRn := Z01->Z01_ACOREN
	
	RecLock("Z01",.F.)
	DbDelete()
	MsUnLock()

	lCanBxOk := .T.
	If !lReneg
		For _x := 1 to Len(aVetOld)
			//
			zPrefix := aVetOld[_x][nFdoPre]
			zNumero := aVetOld[_x][nFdoNum]
			zParcel := aVetOld[_x][nFdoPar]
			zTipo   := aVetOld[_x][nFdoTip]
			zClient := aVetOld[_x][nFdoCli]
			DbSelectArea("ZE1")
			DbSetOrder(1)
			DbSeek( xFilial("ZE1") + cAcordo + zPrefix + zNumero + zParcel + zTipo + zClient )
			RecLock("ZE1",.F.)
			DbDelete()
			MsUnLock()
			// Exclui o movimento de baixa
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek( xFilial("SE1") + zPrefix + zNumero + zParcel + zTipo + zClient )
			//
			nSalvRec  := SE1->(Recno())
			nSaldo    := 0
		    aBaixa    := {}
			aBaixaSE5 := {}
			aBaixa    := Sel070Baixa("VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,SE1->E1_TIPO,,,SE1->E1_CLIENTE,SE1->E1_LOJA,@nSaldo,,,)
			SE1->( DbGoto( nSalvRec ) )
			nQualBx := Len(aBaixaSE5)
	        //
			If nQualBx > 0
		
				aBaixa := { {"E1_PREFIXO"  , SE1->E1_PREFIXO , Nil},;
							{"E1_NUM"	   , SE1->E1_NUM     , Nil},; 
							{"E1_PARCELA"  , SE1->E1_PARCELA , Nil},;
							{"E1_TIPO"	   , SE1->E1_TIPO    , Nil},;
							{"E1_CLIENTE"  , SE1->E1_CLIENTE , Nil},;
							{"E1_LOJA"	   , SE1->E1_LOJA    , Nil} }
		
				lMsErroAuto := .F.
				MSExecAuto({|x,w,y,z| FINA070(x,w,y,z)},aBaixa,6,,nQualBx)
				If lMsErroAuto
					lCanBxOk := .F.
					DisarmTransaction()
					MostraErro()
					MsgAlert("Falha na exclusão da baixa:"+cEOL+;
					"Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+cEOL+;
					"O processo será interrompido e os dados restaurados na condição original.")
					Exit
				Endif
		
			Else
				/*
				MsgAlert("Sequência de baixa não localizada."+cEOL+;
						 "Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+cEOL+;
						 "O processo será interrmpido.")
				lCanBxOk := .F.
				DisarmTransaction()
				Exit
				*/
			Endif
	        //
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek( xFilial("SE1") + zPrefix + zNumero + zParcel + zTipo + zClient )
			RecLock("SE1",.F.)
			SE1->E1_ZZACORD := ""
			SE1->E1_MULTA   := 0.00
			MsUnLock()
			//
		Next _x	
    Else // Exclusão de renegociação
		For _x := 1 to Len(aVetOld)
			zPrefix := aVetOld[_x][nFdoPre]
			zNumero := aVetOld[_x][nFdoNum]
			zParcel := aVetOld[_x][nFdoPar]
			zTipo   := aVetOld[_x][nFdoTip]
			zClient := aVetOld[_x][nFdoCli]
			DbSelectArea("ZE1")
			DbSetOrder(1)
			DbSeek( xFilial("ZE1") + cAcordo + zPrefix + zNumero + zParcel + zTipo + zClient )
			RecLock("ZE1",.F.)
			DbDelete()
			MsUnLock()
		Next _x
		//
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( xFilial("SE1") + "ACO" + zAcoRn )
		While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1") + "ACO" + zAcoRn
			cSeqE5 := ""
			DbSelectArea("SE5")
			DbSetOrder(7)
			If DbSeek( xFilial("SE5") + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
				While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == xFilial("SE5") + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
					If SE5->E5_MOTBX == "ACO" .And. SE5->E5_TIPODOC == "BA"
						cSeqE5 := SE5->E5_SEQ
						Exit
					Endif 
					SE5->(DbSkip())
				Enddo
			Endif
			If !Empty(cSeqE5)
				//
				nSalvRec  := SE1->(Recno())
				nSaldo    := 0
			    aBaixa    := {}
				aBaixaSE5 := {}
				aBaixa    := Sel070Baixa("VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,SE1->E1_TIPO,,,SE1->E1_CLIENTE,SE1->E1_LOJA,@nSaldo,,,)
				SE1->( DbGoto( nSalvRec ) )
				nQualBx := aScan(aBaixaSE5, {|x| x[9] == cSeqE5 })
		        //
				If nQualBx > 0
			
					aBaixa := { {"E1_PREFIXO"  , SE1->E1_PREFIXO , Nil},;
								{"E1_NUM"	   , SE1->E1_NUM     , Nil},; 
								{"E1_PARCELA"  , SE1->E1_PARCELA , Nil},;
								{"E1_TIPO"	   , SE1->E1_TIPO    , Nil},;
								{"E1_CLIENTE"  , SE1->E1_CLIENTE , Nil},;
								{"E1_LOJA"	   , SE1->E1_LOJA    , Nil} }
			
					lMsErroAuto := .F.
					MSExecAuto({|x,w,y,z| FINA070(x,w,y,z)},aBaixa,6,,nQualBx)
					If lMsErroAuto
						lCanBxOk := .F.
						DisarmTransaction()
						MostraErro()
						MsgAlert("Falha na exclusão da baixa:"+cEOL+;
						"Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+cEOL+;
						"O processo será interrompido e os dados restaurados na condição original.")
						Exit
					Endif
			
				Else
					/*
					MsgAlert("Sequência de baixa não localizada."+cEOL+;
							 "Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+cEOL+;
							 "O processo será interrmpido.")
					lCanBxOk := .F.
					DisarmTransaction()
					Exit
					*/
				Endif
		        //
			Endif
			//
			DbSelectArea("SE1")
			SE1->(DbSkip())
		Enddo
    Endif
    //
	If lCanBxOk

		lExclOk := .T.
		For _x := 1 to Len(aVetNew)
			//
			zParcel := aVetNew[_x][nFdnPar]
			DbSelectArea("Z02")
			DbSetOrder(1)
			DbSeek( xFilial("Z02") + cAcordo + zParcel )
			zTipo := Z02->Z02_TIPO
			//
			RecLock("Z02",.F.)
			DbDelete()
			MsUnLock()
			// Exclui os novos títulos gerados pelo acordo
			DbSelectArea("SE1")
			DbSetOrder(1)
			If DbSeek( xFilial("SE1") + "ACO" + cAcordo + zParcel + zTipo )
				aVetor := { { "E1_PREFIXO" , SE1->E1_PREFIXO , Nil },;
							{ "E1_NUM"     , SE1->E1_NUM     , Nil },;
							{ "E1_PARCELA" , SE1->E1_PARCELA , Nil },;
							{ "E1_TIPO"    , SE1->E1_TIPO    , Nil },;
							{ "E1_CLIENTE" , SE1->E1_CLIENTE , Nil },;
							{ "E1_LOJA"    , SE1->E1_LOJA    , Nil } }
				lMsErroAuto := .F.
				MsExecAuto({|x,y| FINA040(x,y)},aVetor,5)
				If lMsErroAuto
					lExclOk := .F.
					DisarmTransaction()
					MostraErro()
					MsgAlert("Falha na exclusão do título a receber:"+cEOL+;
					"Título: ACO-"+cAcordo+"-"+zParcel+"-"+zTipo+cEOL+;
					"O processo será interrompido e os dados restaurados na condição original.")
					Exit
				Endif
			Endif	
			//			
		Next _x

		If lExclOk
    		If !Empty(zAcoRn)
				u_AcUpdLeg(Z01->Z01_FILIAL,zAcoRn)
			Endif	
			MsgInfo("Acordo excluído com sucesso !!")
		Endif	

	Endif	

	End Transaction
	MsUnLockAll()

Endif

Return
