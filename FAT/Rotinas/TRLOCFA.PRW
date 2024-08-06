#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ TRLOCFA   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  26/04/2019  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Realocação de Itens bloqueados em múltiplos armazéns.	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TRLOCFA()

Private cCadastro := "Realocação Múltiplos Armazéns"

Private aCores := {{"!Empty(C9_BLEST) .And. C9_BLEST <> '10'" , "BR_PRETO" }}

Private aCoresLeg := {{"BR_PRETO"	 , "Estoque Bloqueado"}}

Private aRotina := {{"Realocar"   , "U_RESTMUL()" , 0 , 6 },;
            	    {"Visualizar" , "AxVisual"    , 0 , 7 },;
					{"Legenda"    , "BrwLegenda(cCadastro,cLegenda,aCoresLeg)" , 0 , 10 }}

Private cEOL      := CHR(13)+CHR(10) 
Private cLegenda  := "Legenda"

Private zUsrReal  := AllTrim(GetMv("MV_XREALAR"))

Private zFilSC9   := "Empty(C9_BLCRED) .And. !Empty(C9_BLEST) .And. C9_BLEST <> '10'"

If __cUserId != "000000"
	If !(__cUserId $ zUsrReal)
		MsgAlert("Usuário não autorizado. Contate o Administrador.")
		Return
	Endif
Endif

DbSelectArea("SC9")
DbSetOrder(1)
Set Filter to &zFilSC9

SC9->(DbGotop())
MBrowse(6,1,22,75,"SC9",,,,,,aCores)

DbSelectArea("SC9")
DbSetOrder(1)
Set Filter to

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ RESTMUL   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  26/04/2019  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validações iniciais para execuão da realocação.			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function RESTMUL()

Local aArea   := GetArea()
Local nTotSdo := 0
Local aSdoEst := {}
Local cArmRea := AllTrim(GetMv("MV_ZARMREA"))
Local zPedido := SC9->C9_PEDIDO
Local zItem   := SC9->C9_ITEM
Local zSequen := SC9->C9_SEQUEN
Local zQtdLib := SC9->C9_QTDLIB
Local zLocal  := SC9->C9_LOCAL
Local cEOL    := CHR(13)+CHR(10)

lJaReal := .F.
DbSelectArea("SC9")
DbSetOrder(1)
If !DbSeek( xFilial("SC9") + zPedido + zItem + zSequen )
	lJaReal := .T.
Else
	If SC9->C9_QTDLIB != zQtdLib .Or. SC9->C9_LOCAL != zLocal
		lJaReal := .T.
	Endif
Endif
If lJaReal
	MsgAlert("Este Pedido x Item x Sequência já foi realocado.")
	Return
Endif

DbSelectArea("SZN")
DbSetOrder(1)
If DbSeek( xFilial("SZN") + zPedido + zItem + zSequen )
	MsgAlert("Este Pedido x Item x Sequência já está sendo realocado pelo usuário "+AllTrim(SZN->ZN_USER))
	Return
Else
	RecLock("SZN",.T.)
	SZN->ZN_FILIAL := xFilial("SZN")
	SZN->ZN_PEDIDO := zPedido
	SZN->ZN_ITEM   := zItem
	SZN->ZN_SEQUEN := zSequen
	SZN->ZN_USER   := cUserName
	MsUnLock()
Endif

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + SC9->C9_PRODUTO )

DbSelectArea("SB2")
DbSetOrder(1)
DbSeek( xFilial("SB2") + SC9->C9_PRODUTO )
While !Eof() .And. SB2->B2_FILIAL == xFilial("SB2") .And. SB2->B2_COD == SC9->C9_PRODUTO
	If SB2->B2_LOCAL $(cArmRea)
		nSdoLoc := SaldoSb2()
		If nSdoLoc > 0
			AAdd(aSdoEst,{SB2->B2_LOCAL,nSdoLoc})
			nTotSdo += nSdoLoc
		Endif
	Endif	
	DbSelectArea("SB2")
	SB2->(DbSkip())
Enddo

If nTotSdo < SC9->C9_QTDLIB
	MsgAlert("O produto "+AllTrim(SC9->C9_PRODUTO)+" - "+AllTrim(SB1->B1_DESC)+" não possui saldo disponível em estoque."+cEOL+cEOL+;
			"Considerando os armazéns ("+cArmRea+") o total disponível é de "+AllTrim(STR(nTotSdo,14,2))+" "+AllTrim(SB1->B1_UM)+"." )

	DbSelectArea("SZN")
	DbSetOrder(1)
	If DbSeek( xFilial("SZN") + SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN) )
		RecLock("SZN",.F.)
		DbDelete()
		MsUnLock()
	Endif

	Return
Endif

U_EXEREST(aSdoEst)

DbSelectArea("SZN")
DbSetOrder(1)
If DbSeek( xFilial("SZN") + zPedido + zItem + zSequen )
	RecLock("SZN",.F.)
	DbDelete()
	MsUnLock()
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ EXEREST   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  26/04/2019  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interface para execuão da realocação.			  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function EXEREST(aSdoEst)

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End() }
Local bActCan := {|| nOpc410:=0,oDlg410:End() }
Local bOk410  := {|| IIf( MsgYesNo("Confirma realocação?","Confirmar"), Eval(bActOk),  .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona realocação?","Sair")    , Eval(bActCan), .F.) }
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
Private nFdrLoc := 2
Private nFdrQua := 3
Private nFdrRea := 4

Private oLbx410 := Nil
Private aVet410 := {}
Private oDlg410

Private nTotPed := 0

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA )

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + SC9->C9_PRODUTO )

// Carrega browse no Folder
aVet410 := {}
fCarg410(@aVet410,aSdoEst)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 440
nDlg4 := 900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Realocação Múltipla",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

// ******************************************************************************** //
// ** Cabeçalho						                                             ** //
// ******************************************************************************** //
DbSelectArea("SM0")
DbSetOrder(1)
DbSeek( SM0->M0_CODIGO + SC9->C9_FILIAL )

@ 040,005 SAY "Pedido" OF oDlg410 PIXEL SIZE 055,009
@ 039,030 TO 051,080 LABEL "" OF oDlg410 PIXEL
oSayPdc:= TSay():New(042,037,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayPdc:CtrlRefresh()
oSayPdc:SetText(SC9->C9_PEDIDO+"-"+SC9->C9_ITEM)

@ 040,100 SAY "Cliente" OF oDlg410 PIXEL SIZE 055,009
@ 039,130 TO 051,305 LABEL "" OF oDlg410 PIXEL
oSayCli:= TSay():New(042,135,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayCli:SetText(SA1->A1_NOME)
oSayCli:CtrlRefresh()

@ 040,325 SAY "Filial" OF oDlg410 PIXEL SIZE 055,009
@ 039,350 TO 051,445 LABEL "" OF oDlg410 PIXEL
oSayOpe:= TSay():New(042,355,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayOpe:SetText(SC9->C9_FILIAL+" - "+AllTrim(SM0->M0_FILIAL))
oSayOpe:CtrlRefresh()

@ 060,005 SAY "Produto" OF oDlg410 PIXEL SIZE 055,009
@ 059,030 TO 071,080 LABEL "" OF oDlg410 PIXEL
oSayPro:= TSay():New(062,037,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayPro:CtrlRefresh()
oSayPro:SetText(SC9->C9_PRODUTO)

@ 059,100 TO 071,265 LABEL "" OF oDlg410 PIXEL
oSayDes:= TSay():New(062,105,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayDes:CtrlRefresh()
oSayDes:SetText(SB1->B1_DESC)

@ 060,276 SAY "Qtd.Liberada" OF oDlg410 PIXEL SIZE 055,009
@ 059,320 TO 071,370 LABEL "" OF oDlg410 PIXEL
oSayLib:= TSay():New(062,328,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayLib:CtrlRefresh()
oSayLib:SetText(STR(SC9->C9_QTDLIB,10,2)+" "+SB1->B1_UM)

@ 060,385 SAY "Armazém" OF oDlg410 PIXEL SIZE 055,009
@ 059,420 TO 071,445 LABEL "" OF oDlg410 PIXEL
oSayArm:= TSay():New(062,428,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayArm:CtrlRefresh()
oSayArm:SetText(SC9->C9_LOCAL)

@ 202,320 SAY "Qtde.Realocada" OF oDlg410 PIXEL SIZE 055,009
@ 201,373 MSGET oTotPed VAR nTotPed PICTURE "@E 999,999.99" OF oDlg410 PIXEL WHEN .F. SIZE 070,009

nBrw1 := 080
nBrw2 := 005
nBrw3 := 440
nBrw4 := 114

oLbx410 := TWBrowse():New(nBrw1,nBrw2,nBrw3,nBrw4,,,,oDlg410,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx410:AddColumn( TcColumn():New( "  "    	         ,{ || IIf(aVet410[oLbx410:nAt][nFdrLeg],oVerde,oVerme) } , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Armazém"         ,{ || aVet410[oLbx410:nAt][nFdrLoc] } , "@!"                   ,,,"CENTER"	,030,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Qtde.Disponível" ,{ || aVet410[oLbx410:nAt][nFdrQua] } , "@E 999,999.99"        ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Qtde.à Realocar" ,{ || aVet410[oLbx410:nAt][nFdrRea] } , "@E 999,999.99"        ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )

oLbx410:SetArray(aVet410)
oLbx410:bHeaderClick := { |o,x,y| fHeaderR( o , x , y , @oLbx410 , @aVet410 ) }
oLbx410:bLDblClick   := { || fClickR(@oLbx410,@aVet410,oLbx410:nAt,oLbx410:nColPos) }

oDlg410:Activate(,,,.T.,{|| _Validar(aVet410) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	MsgRun("Executando realocação nos armazéns informados... aguarde","Processando",{|| _SendAloc(aVet410,SC9->(Recno())) })
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg410 ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  26/04/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados.											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg410(aVet410,aSdoEst)

For _x := 1 to Len(aSdoEst)
	AAdd(aVet410,{ .T.,;
				   aSdoEst[_x][1],;
				   aSdoEst[_x][2],;
				   0 })
Next _x

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClickR    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦ 26/04/2019   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do Folder.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClickR(oLbx410,aVet410,nLin,nCol) 

If nCol == nFdrRea // Qtde.à Realocar
	If aVet410[nLin][nFdrLeg] // Somente legenda Verde
		nVal := aVet410[nLin][nCol]
		lEditCell( @aVet410 , @oLbx410 , "@E 999,999.99" , nCol ) 
		If aVet410[nLin][nCol] != nVal // Checa se alterou o conteúdo
			If aVet410[nLin][nCol] > aVet410[nLin][nFdrQua]
				Alert("Quantidade maior que a disponível.")
				aVet410[nLin][nCol] := nVal
				lRetEmb := .F.
			Else
				// Valida quantidade por embalagem
				aItEmb := {}
				zPedi  := SC9->C9_PEDIDO
				zItem  := SC9->C9_ITEM
				zSequ  := ""
				zProd  := SC9->C9_PRODUTO
				zQtde  := aVet410[nLin][nCol]
				AAdd(aItEmb,{zPedi, zItem, zSequ, zProd, zQtde, "PED"})
				lRetEmb := u_VldEmblg(aItEmb)
			Endif
        	If !lRetEmb
				aVet410[nLin][nCol] := nVal
			Else
				nTotPed := 0
				For _z := 1 to Len(aVet410)
	   				If _z == nLin
		   				nTotPed += aVet410[nLin][nCol]
	   				Else
		   				nTotPed += aVet410[_z][nFdrRea]
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
¦¦¦Programa  ¦ fHeaderR ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦ 26/04/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fHeaderR(oObj,nCol,nLin,oLbx410,aVet410)

oLbx410:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 26/04/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validacao geral da interface.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Validar(aVet410)

Local lRetorno := .T.
Local _ped

If Len(aVet410) > 0
	// Verifica se o saldo realocado é igual à quantidade liberada
	nTotDig := 0
	For _ped := 1 to Len(aVet410)
		nTotDig += aVet410[_ped][nFdrRea]
	Next _ped
	If nTotDig <> SC9->C9_QTDLIB
		MsgInfo("Quantidade Realocada é diferente da Quantidade Liberada.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	// Calcula quantidade alocada em outros armazéns
	nOutLoc := 0
	For _ped := 1 to Len(aVet410)
		If aVet410[_ped][nFdrLoc] <> SC9->C9_LOCAL .And. aVet410[_ped][nFdrRea] > 0
			nOutLoc += aVet410[_ped][nFdrRea]
		Endif
	Next _ped
	If nOutLoc == 0
		MsgInfo("Quantidade não realocada em outros armazéns.")
		lRetorno := .F.
	Endif
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _SendAloc ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 26/04/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa realocação do estoque conforme digitação.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _SendAloc(aVet410,nRecSC9)

Local lTudoOk := .T.
Local nPedLoc := 0
Local nOutLoc := 0
Local zFilSC9 := "Empty(C9_BLCRED) .And. !Empty(C9_BLEST) .And. C9_BLEST <> '10'"
Local zLastIt := ""
Local lDelSC6 := .F.
Local aItLib  := {}

DbSelectArea("SC9")
DbSetOrder(1)
Set Filter to
SC9->(DbGoto(nRecSC9))

Begin Transaction 

// 1. Estorna a liberação do item.
DbSelectArea("SC5")
DbSetOrder(1)
DbSeek( xFilial("SC5") + SC9->C9_PEDIDO )

DbSelectArea("SC6")
DbSetOrder(1)
DbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM )
zRecSC6 := SC6->(Recno())
zPrcVen := SC6->C6_PRCVEN
zPImpo  := SC6->C6_ZZPIMPO
zPCust  := SC6->C6_ZZPCUST
zComis1 := SC6->C6_COMIS1
zComis2 := SC6->C6_COMIS2
zComis3 := SC6->C6_COMIS3
zComis4 := SC6->C6_COMIS4
zPFret  := SC6->C6_ZZPFRET
zPdPad  := SC6->C6_ZZPDPAD
zPPdd   := SC6->C6_ZZPPDD
zPPont  := SC6->C6_ZZPPONT

For _ped := 1 to Len(aVet410)
	If aVet410[_ped][nFdrLoc] <> SC6->C6_LOCAL .And. aVet410[_ped][nFdrRea] > 0
		nOutLoc += aVet410[_ped][nFdrRea] // Quantidade alocada em outros armazéns
	ElseIf aVet410[_ped][nFdrLoc] == SC6->C6_LOCAL .And. aVet410[_ped][nFdrRea] > 0
		nPedLoc += aVet410[_ped][nFdrRea] // Quantidade alocada no armazém do pedido
	Endif
Next _ped

// Armazena último item do pedido
cQuery := " SELECT MAX(C6_ITEM) ITEM "
cQuery += " FROM "+RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " AND C6_NUM = '"+SC9->C9_PEDIDO+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQC6", .F., .T.)
zLastIt := SQC6->ITEM
SQC6->(DbCloseArea())

DbSelectArea("SC9")
DbSetOrder(1)
SC9->(DbGoto(nRecSC9))

a460Estorna()

// 2. Subtrai do SC6 a quantidade realocada em outros armazéns. Se for total, apaga o registro.
// 3. Desfaz no B2_QPEDVEN a quantidade realocada em outros armazéns. Se for total, zera o registro.
If SC6->C6_QTDVEN == nOutLoc
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL )
	RecLock("SB2",.F.)
	SB2->B2_QPEDVEN -= SC6->C6_QTDVEN
	SB2->B2_QPEDVE2 := ConvUm(SC6->C6_PRODUTO, SB2->B2_QPEDVEN, 0, 2)
	MsUnLock()

	lDelSC6 := .T.

Else

	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL )
	RecLock("SB2",.F.)
	SB2->B2_QPEDVEN -= nOutLoc
	SB2->B2_QPEDVE2 := ConvUm(SC6->C6_PRODUTO, SB2->B2_QPEDVEN, 0, 2)
	MsUnLock()

	RecLock("SC6",.F.)
	SC6->C6_QTDVEN -= nOutLoc
	SC6->C6_UNSVEN := ConvUm(SC6->C6_PRODUTO, SC6->C6_QTDVEN, 0, 2)
	SC6->C6_VALOR  := Round((SC6->C6_QTDVEN * SC6->C6_PRCVEN),2)
	MsUnLock()

	RecLock("SC6",.F.)
	SC6->C6_ZZVIMPO := (SC6->C6_VALOR * (zPImpo/100))
	SC6->C6_ZZVCUST := (SC6->C6_VALOR * (zPCust/100))
	SC6->C6_ZZVCOMV := (((SC6->C6_VALOR - SC6->C6_ZZVIMPO) * zComis1) / 100)
	SC6->C6_ZZVCOMR := (((SC6->C6_VALOR - SC6->C6_ZZVIMPO) * zComis2) / 100)
	SC6->C6_ZVCOMR3 := (((SC6->C6_VALOR - SC6->C6_ZZVIMPO) * zComis3) / 100)
	SC6->C6_ZVCOMR4 := (((SC6->C6_VALOR - SC6->C6_ZZVIMPO) * zComis4) / 100)
	SC6->C6_ZZVFRET := IIf( SC5->C5_TPFRETE=="F", 0, ((SC6->C6_VALOR * zPFret) / 100) )
	SC6->C6_ZZVDPAD := ((SC6->C6_VALOR * zPdPad) / 100)
	SC6->C6_ZZVPDD  := ((SC6->C6_VALOR * zPPdd) / 100)
	SC6->C6_ZZVPONT := ((SC6->C6_VALOR * zPPont) / 100)
	MsUnLock()

	zSomaCm    := SC6->(C6_ZZVCOMV + C6_ZZVCOMR + C6_ZVCOMR3 + C6_ZVCOMR4)
	nRecLiq	   := SC6->C6_VALOR - SC6->C6_ZZVIMPO
	nMargBrut  := nRecLiq - SC6->C6_ZZVCUST
	nPMargBrut := ((nMargBrut / nRecLiq) * 100)
	nVRent	   := nMargBrut - zSomaCm - SC6->C6_ZZVFRET - SC6->C6_ZZVDPAD - SC6->C6_ZZVPDD - SC6->C6_ZZVPONT
	nPRent	   := ((nVRent / nRecLiq) * 100)

	RecLock("SC6",.F.)
	SC6->C6_ZZVMBR  := nMargBrut
	SC6->C6_ZZPMBR  := nPMargBrut
	SC6->C6_ZZVRENT := nVRent
	SC6->C6_ZZPRENT := nPRent
	MsUnLock()

	AAdd(aItLib,{SC6->C6_ITEM,nPedLoc})

Endif

// 4. Cria o(s) novo(s) item(ns) no SC6 conforme armazéns realocados, atualizando B2_QPEDVEN.
aStruct := SC6->(DbStruct())

For _ped := 1 to Len(aVet410)

	SC6->(DbGoto(zRecSC6))

	If aVet410[_ped][nFdrLoc] <> SC6->C6_LOCAL .And. aVet410[_ped][nFdrRea] > 0

		zProxIt    := SOMA1(zLastIt)
		zNewLoc    := aVet410[_ped][nFdrLoc]
		zNewQtd    := aVet410[_ped][nFdrRea]
		zNewTot    := Round((zNewQtd * zPrcVen),2)
		zVImpo     := (zNewTot * (zPImpo/100))
		zVCust     := (zNewTot * (zPCust/100))
		zVFret     := IIf( SC5->C5_TPFRETE=="F", 0, ((zNewTot * zPFret) / 100) )
		zVDpAd     := ((zNewTot * zPdPad) / 100)
		zVpdd      := ((zNewTot * zPPdd) / 100)
		zVPont     := ((zNewTot * zPPont) / 100)
		zVcomV     := (((zNewTot - zVImpo) * zComis1) / 100)
		zVcomR     := (((zNewTot - zVImpo) * zComis2) / 100)
		zVcomR3    := (((zNewTot - zVImpo) * zComis3) / 100)
		zVcomR4    := (((zNewTot - zVImpo) * zComis4) / 100)
		zSomaCm    := zVcomV + zVcomR + zVcomR3 + zVcomR4
		nRecLiq	   := zNewTot - zVImpo
		nMargBrut  := nRecLiq - zVCust
		nPMargBrut := ((nMargBrut / nRecLiq) * 100)
		nVRent	   := nMargBrut - zSomaCm - zVFret - zVDpAd - zVpdd - zVPont
		nPRent	   := ((nVRent / nRecLiq) * 100)
		zLastIt    := zProxIt

		aCopia  := {}
		DbSelectArea("SC6")
		For _xCampo := 1 to ( Len(aStruct) )
			_xConteudo := &("SC6->"+aStruct[_xCampo][1])
			If aStruct[_xCampo][1] == "C6_ITEM"
				_xConteudo := zProxIt
			ElseIf aStruct[_xCampo][1] == "C6_QTDVEN"
				_xConteudo := zNewQtd
			ElseIf aStruct[_xCampo][1] == "C6_VALOR"
				_xConteudo := zNewTot
			ElseIf aStruct[_xCampo][1] == "C6_UNSVEN"
				_xConteudo := ConvUm(SB2->B2_COD, zNewQtd, 0, 2)
			ElseIf aStruct[_xCampo][1] == "C6_LOCAL"
				_xConteudo := zNewLoc
			ElseIf aStruct[_xCampo][1] == "C6_NOTA"
				_xConteudo := ""
			ElseIf aStruct[_xCampo][1] == "C6_SERIE"
				_xConteudo := ""
			ElseIf aStruct[_xCampo][1] == "C6_DATFAT"
				_xConteudo := CtoD("")
			ElseIf aStruct[_xCampo][1] == "C6_QTDEMP"
				_xConteudo := 0
			ElseIf aStruct[_xCampo][1] == "C6_QTDEMP2"
				_xConteudo := 0
			ElseIf aStruct[_xCampo][1] == "C6_QTDENT"
				_xConteudo := 0
			ElseIf aStruct[_xCampo][1] == "C6_QTDENT2"
				_xConteudo := 0
			ElseIf aStruct[_xCampo][1] == "C6_ZZVIMPO"
				_xConteudo := zVImpo
			ElseIf aStruct[_xCampo][1] == "C6_ZZVCUST"
				_xConteudo := zVCust
			ElseIf aStruct[_xCampo][1] == "C6_ZZVCOMV"
				_xConteudo := zVcomV
			ElseIf aStruct[_xCampo][1] == "C6_ZZVCOMR"
				_xConteudo := zVcomR
			ElseIf aStruct[_xCampo][1] == "C6_ZVCOMR3"
				_xConteudo := zVcomR3
			ElseIf aStruct[_xCampo][1] == "C6_ZVCOMR4"
				_xConteudo := zVcomR4
			ElseIf aStruct[_xCampo][1] == "C6_ZZVFRET"
				_xConteudo := zVFret
			ElseIf aStruct[_xCampo][1] == "C6_ZZVDPAD"
				_xConteudo := zVDpAd
			ElseIf aStruct[_xCampo][1] == "C6_ZZVPDD"
				_xConteudo := zVpdd
			ElseIf aStruct[_xCampo][1] == "C6_ZZVPONT"
				_xConteudo := zVPont
			ElseIf aStruct[_xCampo][1] == "C6_ZZVMBR"
				_xConteudo := nMargBrut
			ElseIf aStruct[_xCampo][1] == "C6_ZZPMBR"
				_xConteudo := nPMargBrut
			ElseIf aStruct[_xCampo][1] == "C6_ZZVRENT"
				_xConteudo := nVRent
			ElseIf aStruct[_xCampo][1] == "C6_ZZPRENT"
				_xConteudo := nPRent
			Endif	
			AAdd(aCopia,{aStruct[_xCampo][1],_xConteudo})
		Next _xCampo

		RecLock("SC6",.T.)
		For _xCampo := 1 to ( Len(aCopia) )
			&("SC6->"+aCopia[_xCampo,1]) := aCopia[_xCampo,2]
		Next _xCampo
		MsUnLock()

		AAdd(aItLib,{SC6->C6_ITEM,SC6->C6_QTDVEN})

		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek( xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL )
		RecLock("SB2",.F.)
		SB2->B2_QPEDVEN += SC6->C6_QTDVEN
		MsUnLock()
		
	Endif
Next _ped

// 5. Executa a liberação dos respectivos itens individualmente, sem avaliação de crédito.
For _x := 1 to Len(aItLib)

	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( xFilial("SC6") + SC5->C5_NUM + aItLib[_x][1] )

	nRegSC6   := SC6->(Recno())
	nQtdaLib  := aItLib[_x][2]
	lCredito  := .T.
	lEstoque  := .T.
	lAvCred   := .F.
	lAvEst    := .T.
	lLibPar   := .F.
	lTrfLocal := .F.

//	MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,nVlrCred,nQtdalib2)
	MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal)

Next _x

If lDelSC6
	DbSelectArea("SC6")
	SC6->(DbGoto(zRecSC6))
	RecLock("SC6",.F.)
	DbDelete()
	MsUnLock()
Endif

End Transaction
MsUnLockAll()

DbSelectArea("SC9")
DbSetOrder(1)
Set Filter to &zFilSC9
SC9->(DbGotop())

If lTudoOk
	MsgInfo("Realocação concluída com sucesso !!")
Endif	

Return
