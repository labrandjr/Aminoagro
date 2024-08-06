#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ TLIBEST   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  19/02/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Liberação de Itens bloqueados de acordo com a quantidade	  ¦¦¦
¦¦¦          ¦ disponível em estoque.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TLIBEST()

Private cCadastro := "Liberação de Estoque Disponível"

Private aCores := {{"!Empty(C9_BLEST) .And. C9_BLEST <> '10'" , "BR_PRETO" }}

Private aCoresLeg := {{"BR_PRETO"	 , "Estoque Bloqueado"}}

Private aRotina := {{"Liberar"    , "U_RESTLIB()" , 0 , 6 },;
            	    {"Visualizar" , "AxVisual"    , 0 , 7 },;
					{"Legenda"    , "BrwLegenda(cCadastro,cLegenda,aCoresLeg)" , 0 , 10 }}

Private cEOL      := CHR(13)+CHR(10) 
Private cLegenda  := "Legenda"

Private zUsrLibD  := AllTrim(GetMv("MV_XLBESTD"))

Private zFilSC9   := "Empty(C9_BLCRED) .And. !Empty(C9_BLEST) .And. C9_BLEST <> '10'"

If __cUserId != "000000"
	If !(__cUserId $ zUsrLibD)
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
¦¦¦Funcao    ¦ RESTLIB   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  19/02/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validações iniciais para execuão da liberação.			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function RESTLIB()

Local aArea   := GetArea()
Local nTotSdo := 0
Local aSdoEst := {}
Local cArmRea := SC9->C9_LOCAL
Local zPedido := SC9->C9_PEDIDO
Local zItem   := SC9->C9_ITEM
Local zSequen := SC9->C9_SEQUEN
Local zQtdLib := SC9->C9_QTDLIB
Local zLocal  := SC9->C9_LOCAL
Local cEOL    := CHR(13)+CHR(10)
Local lExecOk := .T.

lJaReal := .F.
DbSelectArea("SC9")
DbSetOrder(1)
If !DbSeek( xFilial("SC9") + zPedido + zItem + zSequen )
	lJaReal := .T.
Else
	If SC9->C9_QTDLIB != zQtdLib .Or. SC9->C9_LOCAL != zLocal .Or. !Empty(SC9->C9_NFISCAL)
		lJaReal := .T.
	Endif
Endif
If lJaReal
	MsgAlert("Este Pedido x Item x Sequência já foi liberado.")
	Return
Endif

DbSelectArea("SZN")
DbSetOrder(1)
If DbSeek( xFilial("SZN") + zPedido + zItem + zSequen )
	MsgAlert("Este Pedido x Item x Sequência está sendo liberado pelo usuário "+AllTrim(SZN->ZN_USER))
	Return
Endif

Begin Transaction

RecLock("SZN",.T.)
SZN->ZN_FILIAL := xFilial("SZN")
SZN->ZN_PEDIDO := zPedido
SZN->ZN_ITEM   := zItem
SZN->ZN_SEQUEN := zSequen
SZN->ZN_USER   := cUserName
MsUnLock()

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

If nTotSdo == 0
	MsgAlert("O produto "+AllTrim(SC9->C9_PRODUTO)+" - "+AllTrim(SB1->B1_DESC)+" não possui saldo disponível em estoque."+cEOL+;
			 "Verifique o saldo no armazém "+cArmRea+"." )
	DbSelectArea("SZN")
	DbSetOrder(1)
	If DbSeek( xFilial("SZN") + SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN) )
		RecLock("SZN",.F.)
		DbDelete()
		MsUnLock()
	Endif
	lExecOk := .F.
Endif

If lExecOk
	U_EXLIBED(aSdoEst)
	DbSelectArea("SZN")
	DbSetOrder(1)
	If DbSeek( xFilial("SZN") + zPedido + zItem + zSequen )
		RecLock("SZN",.F.)
		DbDelete()
		MsUnLock()
	Endif
Endif

End Transaction
MsUnLockAll()

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ EXLIBED   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  19/02/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interface para execuão da liberação.				  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function EXLIBED(aSdoEst)

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End() }
Local bActCan := {|| nOpc410:=0,oDlg410:End() }
Local bOk410  := {|| IIf( MsgYesNo("Confirma liberação?","Confirmar"), Eval(bActOk),  .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona liberação?","Sair")    , Eval(bActCan), .F.) }
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

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Liberação de Estoque Disponível",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

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

@ 202,320 SAY "Qtde.Liberada" OF oDlg410 PIXEL SIZE 055,009
@ 201,373 MSGET oTotPed VAR nTotPed PICTURE "@E 999,999.99" OF oDlg410 PIXEL WHEN .F. SIZE 070,009

nBrw1 := 080
nBrw2 := 005
nBrw3 := 440
nBrw4 := 114

oLbx410 := TWBrowse():New(nBrw1,nBrw2,nBrw3,nBrw4,,,,oDlg410,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx410:AddColumn( TcColumn():New( "  "    	         ,{ || IIf(aVet410[oLbx410:nAt][nFdrLeg],oVerde,oVerme) } , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Armazém"         ,{ || aVet410[oLbx410:nAt][nFdrLoc] } , "@!"                   ,,,"CENTER"	,030,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Qtde.Disponível" ,{ || aVet410[oLbx410:nAt][nFdrQua] } , "@E 999,999.99"        ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Qtde.à Liberar"  ,{ || aVet410[oLbx410:nAt][nFdrRea] } , "@E 999,999.99"        ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )

oLbx410:SetArray(aVet410)
oLbx410:bHeaderClick := { |o,x,y| fHeaderR( o , x , y , @oLbx410 , @aVet410 ) }
oLbx410:bLDblClick   := { || fClickR(@oLbx410,@aVet410,oLbx410:nAt,oLbx410:nColPos) }

oDlg410:Activate(,,,.T.,{|| _Validar(aVet410) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	MsgRun("Executando liberação da quantidade informada... aguarde","Processando",{|| _SendLibe(aVet410,SC9->(Recno())) })
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg410 ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  19/02/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados.											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg410(aVet410,aSdoEst)

Local _x

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
¦¦¦Programa  ¦ fClickR    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦ 19/02/2020   ¦¦¦
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

If nCol == nFdrRea // Qtde.à Liberar
	If aVet410[nLin][nFdrLeg] // Somente legenda Verde
		nVal := aVet410[nLin][nCol]
		lEditCell( @aVet410 , @oLbx410 , "@E 999,999.99" , nCol ) 
		If aVet410[nLin][nCol] != nVal // Checa se alterou o conteúdo
			If aVet410[nLin][nCol] > aVet410[nLin][nFdrQua]
				Alert("Quantidade maior que a disponível.")
				aVet410[nLin][nCol] := nVal
				lRetEmb := .F.
			ElseIf aVet410[nLin][nCol] > SC9->C9_QTDLIB
				Alert("Quantidade maior que a liberada.")
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
¦¦¦Programa  ¦ fHeaderR ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦ 19/02/2020	  ¦¦¦
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
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 19/02/2020	  ¦¦¦
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
	// Verifica se a quantidade liberada foi informada corretamente
	nTotDig := 0
	For _ped := 1 to Len(aVet410)
		nTotDig += aVet410[_ped][nFdrRea]
	Next _ped
	If nTotDig == 0
		MsgInfo("Quantidade Liberada não informada.")
		lRetorno := .F.
	ElseIf nTotDig > SC9->C9_QTDLIB
		MsgInfo("Quantidade informada é maior que a liberada.")
		lRetorno := .F.
	Endif
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _SendLibe ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 19/02/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa liberação do estoque conforme digitação.		  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _SendLibe(aVet410,nRecSC9)

Local lTudoOk := .T.
Local nQtdLib := 0
Local nQtdBlq := 0
Local zFilSC9 := "Empty(C9_BLCRED) .And. !Empty(C9_BLEST) .And. C9_BLEST <> '10'"
Local _ped

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

For _ped := 1 to Len(aVet410)
	nQtdLib += aVet410[_ped][nFdrRea] // Quantidade liberada
Next _ped

nQtdBlq := SC9->C9_QTDLIB - nQtdLib

a460Estorna()

// 2. Executa a liberação da quantidade liberada, sem avaliação de crédito.
nRegSC6   := SC6->(Recno())
nQtdaLib  := nQtdLib
lCredito  := .T.
lEstoque  := .T.
lAvCred   := .F.
lAvEst    := .T.
lLibPar   := .F.
lTrfLocal := .F.

//MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,nVlrCred,nQtdalib2)
MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal)

// 3. Executa a liberação da quantidade bloqueada, sem avaliação de crédito.
nRegSC6   := SC6->(Recno())
nQtdaLib  := nQtdBlq
lCredito  := .T.
lEstoque  := .T.
lAvCred   := .F.
lAvEst    := .T.
lLibPar   := .F.
lTrfLocal := .F.

//MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,nVlrCred,nQtdalib2)
MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal)

End Transaction
MsUnLockAll()

DbSelectArea("SC9")
DbSetOrder(1)
Set Filter to &zFilSC9
SC9->(DbGotop())

If lTudoOk
	MsgInfo("Liberação concluída com sucesso !!")
Endif	

Return
