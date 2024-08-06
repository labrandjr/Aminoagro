#include "protheus.ch"
#include "rwmake.ch"        
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR040   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interface para baixa de acordo.							  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR040()

Private nOpcBxa := 0
Private oDlgBxa := Nil
Private bBxaOk  := {|| nOpcBxa:=1,oDlgBxa:End()}
Private bBxaCan := {|| nOpcBxa:=0,oDlgBxa:End()}
Private bOkBxa  := {|| IIf(MsgYesNo("Confirma baixa do acordo?","Movimentar"), Eval(bBxaOk), .F.) }
Private bCanBxa := {|| IIf(MsgYesNo("Abandona a baixa do acordo?","Sair"), Eval(bBxaCan), .F.) }

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

Private cEOL    := CHR(13)+CHR(10) 
Private cAcordo := ""
Private dEmissa := CtoD("")
Private cParcel := ""
Private cClient := ""
Private cRazao  := ""
Private cBanco  := ""
Private cAgenci := ""
Private cConta  := ""
Private cNomBco := ""
Private dDataBx := CtoD("")
Private dVencto := CtoD("")
Private nVlBaix := 0
Private nVlPrin := 0
Private nVlAcre := 0
Private nVlJuro := 0
Private nTxJuro := 0
Private cHistor := ""
Private nTotRec := 0
Private oSayAco,oSayEmi,oSayPar,oSayCli,oSayRaz,oBanco,oAgenci,oConta,oSayBco,oDataBx,oVencto,oVlBaix,oVlPrin,oVlAcre,oVlJuro,oTxJuro,oHistor,oSayTot

oFnt1 := TFont():New("Tahoma",,12,,.F.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.T.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 470
nDlg4 := 650
nLinI := 035
nLin1 := nLinI

oDlgBxa := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Movimentação de Acordo",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

cAcordo := Z02->Z02_ACORDO
@ nLin1,005 SAY "No.Acordo" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1-1,040 TO nLin1+11,100 LABEL "" OF oDlgBxa PIXEL
oSayAco:= TSay():New(nLin1+2,045,{|| cAcordo },oDlgBxa,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,200,020)
oSayAco:CtrlRefresh()

dEmissa := Z01->Z01_EMISSA
@ nLin1,133 SAY "Emissão" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1-1,165 TO nLin1+11,215 LABEL "" OF oDlgBxa PIXEL
oSayEmi:= TSay():New(nLin1+2,170,{|| DtoC(dEmissa) },oDlgBxa,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayEmi:CtrlRefresh()

cParcel := Z02->Z02_PARCEL
@ nLin1,245 SAY "Parcela" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1-1,275 TO nLin1+11,317 LABEL "" OF oDlgBxa PIXEL
oSayPar:= TSay():New(nLin1+2,280,{|| cParcel },oDlgBxa,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,200,020)
oSayPar:CtrlRefresh()

cClient := Z01->Z01_CLIENT
cRazao  := Z01->Z01_NOME
@ nLin1+15,005 SAY "Cliente" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+14,040 TO nLin1+26,100 LABEL "" OF oDlgBxa PIXEL
oSayCli:= TSay():New(nLin1+17,045,{|| cClient },oDlgBxa,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayCli:CtrlRefresh()

@ nLin1+14,105 TO nLin1+26,317 LABEL "" OF oDlgBxa PIXEL
oSayRaz:= TSay():New(nLin1+17,110,{|| cRazao },oDlgBxa,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayRaz:CtrlRefresh()

@ nLin1+30,005 TO nLin1+77,317 LABEL "" OF oDlgBxa PIXEL

cBanco := Space(3)
@ nLin1+35,070 SAY "Banco" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+45,070 MSGET oBanco VAR cBanco SIZE 040,010 OF oDlgBxa PIXEL PICTURE "@!" F3 "SA6" VALID VldBco()

cAgenci := Space(5)
@ nLin1+35,120 SAY "Agência" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+45,120 MSGET oAgenci VAR cAgenci SIZE 050,010 OF oDlgBxa PIXEL PICTURE "@!" VALID VldAge()

cConta := Space(10)
@ nLin1+35,180 SAY "Conta" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+45,180 MSGET oConta VAR cConta SIZE 080,010 OF oDlgBxa PIXEL PICTURE "@!" VALID VldCon()

cNomBco := ""
@ nLin1+60,070 TO nLin1+72,260 LABEL "" OF oDlgBxa PIXEL
oSayBco:= TSay():New(nLin1+63,075,{|| cNomBco },oDlgBxa,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayBco:CtrlRefresh()

dDataBx := dDatabase
@ nLin1+85,005 SAY "Data" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+85,030 MSGET oDataBx VAR dDataBx SIZE 060,010 OF oDlgBxa PIXEL PICTURE "" VALID VldDat()

dVencto := Z02->Z02_VENCTO
@ nLin1+85,110 SAY "Vencto." OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+85,140 MSGET oVencto VAR dVencto SIZE 060,010 OF oDlgBxa PIXEL PICTURE "" WHEN .F.

nVlBaix := Z02->Z02_SALDO
@ nLin1+105,005 SAY "Valor" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+105,030 MSGET oVlBaix VAR nVlBaix SIZE 060,010 OF oDlgBxa PIXEL PICTURE "@E 999,999,999.99" VALID VldVlr()

nVlAcre := u_AcrProp(cAcordo,Z02->Z02_SALDO)
nVlPrin := Z02->Z02_SALDO - nVlAcre
@ nLin1+105,110 SAY "Principal" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+105,140 MSGET oVlPrin VAR nVlPrin SIZE 060,010 OF oDlgBxa PIXEL PICTURE "@E 999,999,999.99" WHEN .F.

@ nLin1+105,220 SAY "Acréscimo" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+105,255 MSGET oVlAcre VAR nVlAcre SIZE 060,010 OF oDlgBxa PIXEL PICTURE "@E 999,999,999.99" WHEN .F.

nTxJuro := Z01->Z01_TXJURO
nVlJuro := _CalcJuros(nVlBaix)
@ nLin1+125,005 SAY "Juros" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+125,030 MSGET oVlJuro VAR nVlJuro SIZE 060,010 OF oDlgBxa PIXEL PICTURE "@E 999,999.99" VALID VldJur()

@ nLin1+125,110 SAY "Taxa % a.m." OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+125,140 MSGET oTxJuro VAR nTxJuro SIZE 060,010 OF oDlgBxa PIXEL PICTURE "@E 99.99" WHEN .F.

cHistor := Space(100)
@ nLin1+145,005 SAY "Histórico" OF oDlgBxa PIXEL SIZE 055,009
@ nLin1+145,030 MSGET oHistor VAR cHistor SIZE 285,010 OF oDlgBxa PIXEL PICTURE "@!" VALID .T.

nTotRec := nVlBaix + nVlJuro
oSayTot:= TSay():New(nLin1+173,200,{|| "TOTAL RECEBIDO" },oDlgBxa,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayTot:CtrlRefresh()
@ nLin1+170,255 MSGET oTotRec VAR nTotRec SIZE 060,010 OF oDlgBxa PIXEL PICTURE "@E 999,999,999.99" WHEN .F.

oDlgBxa:Activate(,,,.T.,{|| _Validar() },,{|| EnchoiceBar(oDlgBxa,bOkBxa,bCanBxa) } )

If nOpcBxa == 1
	MsgRun("Gerando movimentações... aguarde","Processando",{|| u_BxParAc(cAcordo,cParcel,dDataBx,cBanco,cAgenci,cConta,nVlBaix,nVlPrin,nVlAcre,nVlJuro,cHistor) })
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

Static Function _Validar()

Local lRetorno := .T.

If dDataBx < GetMv("MV_DATAFIN")
	MsgAlert("Data limite p/ realização de operações financeiras: "+DtoC(GetMv("MV_DATAFIN")))
	lRetorno := .F.
Endif

If lRetorno
	If Empty(cBanco) .Or. Empty(cAgenci) .Or. Empty(cConta)
		MsgAlert("Dados bancários não informados ou incompletos.")
		lRetorno := .F.
	Endif
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldBco    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do banco.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldBco()

Local lRetorno := .T.

If !Empty(cBanco)
	DbSelectArea("SA6")
	DbSetOrder(1)
	If !DbSeek( xFilial("SA6") + cBanco )
		MsgInfo("Banco não cadastrado.")
		lRetorno := .F.
	Endif
Else
	MsgInfo("Informe o banco.")
	lRetorno := .F.
Endif

If lRetorno
	cNomBco := SA6->A6_NOME
Else
	cNomBco := ""
Endif
oSayBco:SetText(cNomBco)
oSayBco:Refresh()

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldAge    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da agência.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldAge()

Local lRetorno := .T.

If Empty(cBanco)
	MsgInfo("Informe o banco.")
	lRetorno := .F.
ElseIf !Empty(cAgenci)
	DbSelectArea("SA6")
	DbSetOrder(1)
	If !DbSeek( xFilial("SA6") + cBanco + cAgenci )
		MsgInfo("Agência não cadastrada para o banco informado.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cNomBco := SA6->A6_NOME
Else
	cNomBco := ""
Endif
oSayBco:SetText(cNomBco)
oSayBco:Refresh()

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCon    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da conta.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCon()

Local lRetorno := .T.

If Empty(cBanco)
	MsgInfo("Informe o banco.")
	lRetorno := .F.
ElseIf !Empty(cConta)
	DbSelectArea("SA6")
	DbSetOrder(1)
	If !DbSeek( xFilial("SA6") + cBanco + cAgenci + cConta )
		MsgInfo("Conta não cadastrada para o banco/agência informado.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cNomBco := SA6->A6_NOME
Else
	cNomBco := ""
Endif
oSayBco:SetText(cNomBco)
oSayBco:Refresh()

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldDat    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da data da baixa.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldDat()

Local lRetorno := .T.

If dDataBx < GetMv("MV_DATAFIN")
	MsgAlert("Data limite p/ realização de operações financeiras: "+DtoC(GetMv("MV_DATAFIN")))
	lRetorno := .F.
Endif

If lRetorno
	If dDataBx < Z01->Z01_EMISSA
		MsgAlert("A data da baixa não pode ser menor que a emissão do acordo.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	If dDataBx > dDatabase
		MsgAlert("A data da baixa não pode ser maior que a data base do sistema.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	nVlJuro := _CalcJuros(nVlBaix)
	nTotRec := nVlBaix + nVlJuro
Endif

oTotRec:Refresh()

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldVlr    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do valor da baixa.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldVlr()

Local lRetorno := .T.

If nVlBaix > Z02->Z02_SALDO
	MsgAlert("O valor recebido não pode ser maior que o saldo da parcela:"+cEOL+;
			 "R$ "+AllTrim(STR(Z02->Z02_SALDO,15,2))+"|"+cEOL+;
			 "Se necessário informe a diferença em 'Juros'.")
	lRetorno := .F.
ElseIf nVlBaix <= 0
	MsgAlert("O valor recebido deve ser informado.")
	lRetorno := .F.
Endif

If lRetorno
	nVlAcre := u_AcrProp(cAcordo,nVlBaix)
	nVlPrin := nVlBaix - nVlAcre
	nVlJuro := _CalcJuros(nVlBaix)
	nTotRec := nVlBaix + nVlJuro
Endif

oVlPrin:Refresh()
oVlAcre:Refresh()
oVlJuro:Refresh()
oTotRec:Refresh()

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldJur    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do valor de juros.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldJur()

Local lRetorno := .T.

nTotRec := nVlBaix + nVlJuro

oVlJuro:Refresh()
oTotRec:Refresh()

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _CalcJuros ¦ Autor ¦  Fabrica ERPBR ¦ Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula o valor dos juros.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _CalcJuros(zValor)

Local zValJur := 0
Local dDatVld := DataValida(dVencto)

If dDataBx > dDatVld
	If nTxJuro > 0
		nDiasAt := dDataBx - dVencto
		nFatJur := ((zValor * (nTxJuro/100)) / 30)
		zValJur := Round((nDiasAt * nFatJur),2)
	Endif	
Endif

Return(zValJur)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BxParAc  ¦ Autor ¦  Fabrica ERPBR ¦ Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa baixa da parcela do acordo.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BxParAc(zAcordo,zParcela,zDataBx,zBanco,zAgencia,zConta,zVlBaix,zVlPrin,zVlAcre,zVlJuro,zHistor)

Local zFatBaix := 0
Local zFatAcre := 0
Local zCount   := 0
Local tE1Jur   := 0
Local cEOL     := CHR(13)+CHR(10) 
Private lMsErroAuto := .F.

DbSelectArea("Z01")
DbSetOrder(1)
DbSeek( xFilial("Z01") + cAcordo )
zFatBaix := (zVlBaix / Z01->(Z01_VALNEG+Z01_ACRESC))
zFatJuro := (zVlJuro / nVlBaix)
zSeqMovA := u_SeqMovA(zAcordo,zParcela)

Begin Transaction

// 1. Gera movimentação de baixa do acordo
DbSelectArea("Z05")
RecLock("Z05",.T.)
Z05->Z05_FILIAL := xFilial("Z05")
Z05->Z05_ACORDO := zAcordo
Z05->Z05_PARC   := zParcela
Z05->Z05_BANCO  := zBanco
Z05->Z05_AGENCI := zAgencia
Z05->Z05_CONTA  := zConta
Z05->Z05_DATA   := zDataBx
Z05->Z05_SEQ    := zSeqMovA
Z05->Z05_VALOR  := zVlBaix
Z05->Z05_VLPRIN := zVlPrin
Z05->Z05_VLACRE := zVlAcre
Z05->Z05_VLJURO := zVlJuro
Z05->Z05_TIPDOC := "VL"
Z05->Z05_HIST   := zHistor
Z05->Z05_USUARI := cUserName
Z05->Z05_DTDIGI := Date()
MsUnLock()

// 2. Atualiza saldo da parcela
DbSelectArea("Z02")
DbSetOrder(1)
DbSeek( xFilial("Z02") + zAcordo + zParcela )
RecLock("Z02",.F.)
Z02->Z02_SALDO -= zVlBaix
MsUnLock()

// 3. Atualiza status do acordo
RecLock("Z01",.F.)
Z01->Z01_STATUS := IIf( u_EncAcor(zAcordo), "E", "L" )
MsUnLock()

// 4. Gera movimentação nos títulos a receber pertencentes ao acordo - integração com módulo financeiro
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("ZE1")
cQuery += " WHERE ZE1_FILIAL = '"+xFilial("ZE1")+"' "
cQuery += " AND ZE1_ACORDO = '"+zAcordo+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZE1",.T.,.T.)
nTotTit := TZE1->SOMA
TZE1->(DbCloseArea())

DbSelectArea("ZE1")
DbSetOrder(1)
DbSeek( xFilial("ZE1") + zAcordo )
While !Eof() .And. ZE1->ZE1_FILIAL == xFilial("ZE1") .And. ZE1->ZE1_ACORDO == zAcordo

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( xFilial("SE1") + ZE1->( ZE1_PREFIX + ZE1_NUM + ZE1_PARCEL + ZE1_TIPO + ZE1_CLIENT ) )

	zCount += 1
	zE1Rec := Round((ZE1->(ZE1_SALDO+ZE1_ACRESC) * zFatBaix),2)
	If zCount == nTotTit
		zE1Jur := zVlJuro - tE1Jur // Arredonda na última parcela
	Else
		zE1Jur := Round((zE1Rec * zFatJuro),2)
		tE1Jur += zE1Jur
	Endif	

	zHisBx := "Valor recebido s/ Acordo "+AllTrim(zAcordo)

	aBaixa := { {"E1_PREFIXO"  , SE1->E1_PREFIXO , Nil},;
				{"E1_NUM"	   , SE1->E1_NUM     , Nil},; 
				{"E1_PARCELA"  , SE1->E1_PARCELA , Nil},;
				{"E1_TIPO"	   , SE1->E1_TIPO    , Nil},;
				{"AUTMOTBX"	   , "NOR"           , Nil},;
				{"AUTBANCO"    , zBanco          , Nil},;
				{"AUTAGENCIA"  , zAgencia        , Nil},;
				{"AUTCONTA"    , zConta        	 , Nil},;
				{"AUTDTBAIXA"  , zDataBx         , Nil},;
				{"AUTDTCREDITO", zDataBx         , Nil},;
				{"AUTHIST"	   , zHisBx          , Nil},; 
				{"AUTJUROS"	   , zE1Jur          , Nil},; 
				{"AUTVALREC"   , zE1Rec          , Nil} }

	lMsErroAuto := .F.
	MsExecAuto({|x,y| FINA070(x,y)},aBaixa,3)  

	If !lMsErroAuto
		DbSelectArea("ZE5")
		RecLock("ZE5",.T.)
		ZE5->ZE5_FILIAL := xFilial("ZE5")
		ZE5->ZE5_ACORDO := zAcordo
		ZE5->ZE5_PARC   := zParcela
		ZE5->ZE5_SEQ    := zSeqMovA
		ZE5->ZE5_TIPDOC := "VL"
		ZE5->ZE5_PREFIX := SE5->E5_PREFIXO
		ZE5->ZE5_NUMERO := SE5->E5_NUMERO
		ZE5->ZE5_PARTIT := SE5->E5_PARCELA
		ZE5->ZE5_TIPO   := SE5->E5_TIPO
		ZE5->ZE5_CLIENT := SE5->E5_CLIFOR
		ZE5->ZE5_SEQSE5 := SE5->E5_SEQ
		MsUnLock()
	Else
		DisarmTransaction()
		MostraErro()
		MsgAlert("Falha na execução da baixa a receber:"+cEOL+;
		"Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+cEOL+;
		"O processo será interrompido e os dados restaurados na condição original.")
		Exit
	Endif

	DbSelectArea("ZE1")
    ZE1->(DbSkip())
Enddo

End Transaction
MsUnLockAll()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SeqMovA  ¦ Autor ¦  Fabrica ERPBR ¦ Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula próxima sequência da movimentação do acordo.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SeqMovA(zAcordo,zParcela)

Local aArea   := GetArea()
Local cUltMov := "00"

cQuery := " SELECT MAX(Z05_SEQ) AS SEQMOV "
cQuery += " FROM "+RetSqlName("Z05")
cQuery += " WHERE Z05_FILIAL = '"+xFilial("Z05")+"' "
cQuery += " AND Z05_ACORDO = '"+zAcordo+"' "
cQuery += " AND Z05_PARC = '"+zParcela+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZ05",.T.,.T.)

TZ05->(DbGotop())
If !Eof()
	cUltMov := TZ05->SEQMOV
Endif	
TZ05->(DbCloseArea())

cSeqMov := SOMA1(cUltMov)

RestArea(aArea)

Return(cSeqMov)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ EncAcor  ¦ Autor ¦  Fabrica ERPBR ¦ Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verifica se o acordo está encerrado.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function EncAcor(zAcordo)

Local aArea   := GetArea()
Local lEncerr := .F.

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("Z02")
cQuery += " WHERE Z02_FILIAL = '"+xFilial("Z02")+"' "
cQuery += " AND Z02_ACORDO = '"+zAcordo+"' "
cQuery += " AND Z02_SALDO > 0 "
cQuery += " AND D_E_L_E_T_ <> '*' "	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZ02",.T.,.T.)
lEncerr := ( TZ02->SOMA == 0 )
TZ02->(DbCloseArea())

RestArea(aArea)

Return(lEncerr)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcrProp  ¦ Autor ¦  Fabrica ERPBR ¦ Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula o valor proporcional pendente do acréscimo.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AcrProp(zAcordo,zVlBaix)

Local aArea   := GetArea()
Local nAcrPro := 0

DbSelectArea("Z01")
DbSetOrder(1)
DbSeek( xFilial("Z01") + zAcordo )
nFtBaix := (zVlBaix / Z01->(Z01_VALNEG+Z01_ACRESC))

DbSelectArea("ZE1")
DbSetOrder(1)
DbSeek( xFilial("ZE1") + zAcordo )
While !Eof() .And. ZE1->ZE1_FILIAL == xFilial("ZE1") .And. ZE1->ZE1_ACORDO == zAcordo

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( xFilial("SE1") + ZE1->( ZE1_PREFIX + ZE1_NUM + ZE1_PARCEL + ZE1_TIPO + ZE1_CLIENT ) )

	nE1Rece := Round((ZE1->(ZE1_SALDO+ZE1_ACRESC) * nFtBaix),2)
	nAcrPro += IIf( nE1Rece < SE1->E1_SDACRES, nE1Rece, SE1->E1_SDACRES )

	DbSelectArea("ZE1")
    ZE1->(DbSkip())
Enddo

RestArea(aArea)

Return(nAcrPro)
