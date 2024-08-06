#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT120BRW  ¦ Autor ¦ ERPBR		    ¦   Data  ¦ Fev/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões no pedido de compras.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Pacotes   ¦ 28/09/2021 - Projeto Workflow versão 2.0 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT120BRW()

Local lWfPc  := ( AllTrim(GetMv("MV_WFPCINT")) == "S" )
Local lWfUsr := ( __cUserId $ AllTrim(GetMv("MV_WFUSMAN")) )
Local lAltFo := ( __cUserId $ AllTrim(GetMv("MV_USALTFO")) )
Local lWfV2  := GetMv("MV_ZWFVER2")

If lWfPc .And. lWfUsr
	AAdd(aRotina, {"WorkFlow", "U_WFPC01(.F.,Nil,.T.,.T.,'MANUAL','Reenvio')", 0, 4} ) // WFPC01(lJob,cNumPed,lShow,lAsk,cRotina,cModo)
Endif	

If lAltFo
	AAdd(aRotina, {"Troca Fornecedor", "U_A120FORN()", 0, 4} )
Endif

If lWfV2
	AAdd(aRotina, {"Alterações genéricas", "U_A120ALGN()", 0, 4} )
	AAdd(aRotina, {"Histórico Alterações", "U_A120HIST()", 0, 4} )
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A120ALGN  ¦ Autor ¦ ERPBR		    ¦   Data  ¦ Ago/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alterações permitidas sem gerar nova aprovação.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A120ALGN()

Local aArea   := GetArea()
Local nRecSc7 := SC7->(Recno())
Local cEOL    := CHR(13)+CHR(10)

If !Empty(SC7->C7_RESIDUO)
	MsgAlert("Item eliminado por resíduo não pode ser alterado.")
	Return
Endif

If Empty(SC7->C7_RESIDUO) .And. SC7->C7_ENCER == "E"
	MsgAlert("Item atendido não pode ser alterado.")
	Return
Endif

If __cUserId != SC7->C7_USER
	MsgAlert("Usuário sem permissão para alterar este pedido."+cEOL+;
			 "Apenas o usuário abaixo pode alterar/excluir este pedido."+cEOL+;
			 "Usuário: "+UsrRetName(SC7->C7_USER))
	Return
Endif

u_AltPedGen()

RestArea(aArea)
SC7->(DbGoto(nRecSc7))

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ AltPedGen  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 14/08/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interface de alterações genéricas.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AltPedGen()

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma alteração?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona alteração?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM
Private oSayVn1,oSayNm1,oSayCm1,oSayVn2,oSayNm2,oSayCm2,oSayVn3,oSayNm3,oSayCm3
Private dDtEnt,cCCust,cProje,cObser
Private cCalt1,cCalt2,cCalt3,cCalt4
Private oCheck1
Private lCheck1 := .F.

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

cTitAd := "Pedido "+SC7->C7_NUM+" Item "+SC7->C7_ITEM
cNumPC := SC7->C7_NUM
dDtEnt := SC7->C7_DATPRF
cCCust := SC7->C7_CC
cProje := RetField("AJ7",2,xFilial("AJ7")+SC7->C7_NUM,"AJ7_PROJET")
cObser := SC7->C7_OBS

nDias  := dDtEnt - dDatabase
cNDias := AllTrim(STR(nDias))+IIf(ABS(nDias) == 0 .Or. ABS(nDias) == 1," DIA"," DIAS")
cDesCC := RetField("CTT",1,xFilial("CTT")+cCCust,"CTT_DESC01")
cDesPr := RetField("AF8",1,xFilial("AF8")+cProje,"AF8_DESCRI")
                                                                   
nDlg1 := 001
nDlg2 := 001
nDlg3 := 260
nDlg4 := 900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Alterações não submetidas à nova aprovação - "+cTitAd,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

// Data de Entrega
@ 040,005 SAY "Dt.Entrega" OF oDlg410 PIXEL SIZE 055,009
@ 039,040 TO 051,085 LABEL "" OF oDlg410 PIXEL
oSayVn1:= TSay():New(042,042,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn1:SetText( DtoC(dDtEnt) )
oSayVn1:CtrlRefresh()

@ 039,090 TO 051,230 LABEL "" OF oDlg410 PIXEL
oSayNm1:= TSay():New(042,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm1:SetText( AllTrim(cNDias) )
oSayNm1:CtrlRefresh()

cCalt1 := dDtEnt
cDalt1 := cNDias
@ 039,250 MSGET oValt1 VAR cCalt1 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" VALID VldDtE()
@ 039,300 TO 051,440 LABEL "" OF oDlg410 PIXEL
oSayAl1:= TSay():New(042,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl1:SetText( AllTrim(cDalt1) )
oSayAl1:CtrlRefresh()


// Centro de Custo
@ 060,005 SAY "C.Custo" OF oDlg410 PIXEL SIZE 055,009
@ 059,040 TO 071,085 LABEL "" OF oDlg410 PIXEL
oSayVn2:= TSay():New(062,042,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn2:SetText( AllTrim(cCCust) )
oSayVn2:CtrlRefresh()

@ 059,090 TO 071,230 LABEL "" OF oDlg410 PIXEL
oSayNm2:= TSay():New(062,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm2:SetText( AllTrim(cDesCC) )
oSayNm2:CtrlRefresh()

cCalt2 := cCCust
cDalt2 := cDesCC
@ 059,250 MSGET oValt2 VAR cCalt2 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "CTT" VALID VldCtt()
@ 059,300 TO 071,440 LABEL "" OF oDlg410 PIXEL
oSayAl2:= TSay():New(062,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl2:SetText( AllTrim(cDalt2) )
oSayAl2:CtrlRefresh()


// Projeto
@ 080,005 SAY "Projeto" OF oDlg410 PIXEL SIZE 055,009
@ 079,040 TO 091,085 LABEL "" OF oDlg410 PIXEL
oSayVn3:= TSay():New(082,045,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn3:SetText( AllTrim(cProje) )
oSayVn3:CtrlRefresh()

@ 079,090 TO 091,230 LABEL "" OF oDlg410 PIXEL
oSayNm3:= TSay():New(082,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm3:SetText( AllTrim(cDesPr) )
oSayNm3:CtrlRefresh()

cCalt3 := cProje
cDalt3 := cDesPr
@ 079,250 MSGET oValt3 VAR cCalt3 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN !Empty(cProje) F3 "AF8" VALID VldPrj()
@ 079,300 TO 091,440 LABEL "" OF oDlg410 PIXEL
oSayAl3:= TSay():New(082,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl3:SetText( AllTrim(cDalt3) )
oSayAl3:CtrlRefresh()


// Observações
@ 100,005 SAY "Observações" OF oDlg410 PIXEL SIZE 055,009
@ 099,040 TO 111,230 LABEL "" OF oDlg410 PIXEL
oSayVn4:= TSay():New(102,045,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn4:SetText( Substr(cObser,1,55) )
oSayVn4:CtrlRefresh()

cCalt4 := cObser
cDalt4 := cDesPr
@ 099,250 MSGET oValt4 VAR cCalt4 SIZE 190,010 OF oDlg410 PIXEL PICTURE "@!" VALID !Empty(cCalt4)

oCheck1 := TCheckBox():New(120,005,"Aplicar para todos os itens em aberto",{|u|IIf(PCount()>0,lCheck1:=u,lCheck1)},oDlg410,100,210,,,,,,,,.T.,,,)

oDlg410:Activate(,,,.T.,{|| ValidAlt(lCheck1) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1

	lAltOk := .F.
	
	If lCheck1 // Altera todos os itens em aberto
		If MsgYesNo("Confirma aplicação das alterações em todos os itens em aberto ?")
			lAltOk := .T.
			DbSelectArea("SC7")
			DbSetOrder(1)
			DbSeek( xFilial("SC7") + cNumPC )
			While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == xFilial("SC7") + cNumPC
				If Empty(SC7->C7_RESIDUO) .And. SC7->C7_ENCER <> "E"
					RecLock("SC7",.F.)
					SC7->C7_DATPRF := cCalt1
					SC7->C7_CC     := cCalt2
					SC7->C7_OBS    := cCalt4
					MsUnLock()
				Endif	
				DbSelectArea("SC7")
				SC7->(DbSkip())	
			Enddo
		Endif	
	Else // Altera somente o item posicionado
		lAltOk := .T.
		RecLock("SC7",.F.)
		SC7->C7_DATPRF := cCalt1
		SC7->C7_CC     := cCalt2
		SC7->C7_OBS    := cCalt4
		MsUnLock()
	Endif

	If lAltOk
		// Altera o projeto em todos os itens, independente do check
		If cCalt3 <> cProje
			DbSelectArea("SC7")
			DbSetOrder(1)
			DbSeek( xFilial("SC7") + cNumPC )
			While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == xFilial("SC7") + cNumPC

				DbSelectArea("AJ7")
				DbSetOrder(2)
				If DbSeek( xFilial("AJ7") + SC7->C7_NUM + SC7->C7_ITEM )
					RecLock("AJ7",.F.)
					AJ7->AJ7_PROJET := cCalt3
					AJ7->AJ7_REVISA := RetField("AF8",1,xFilial("AF8")+cCalt3,"AF8_REVISA")
					MsUnLock()
				Endif

				DbSelectArea("SC7")
				SC7->(DbSkip())	
			Enddo
		Endif	
		MsgInfo("Alterações aplicadas com sucesso.")
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValidAlt   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 14/08/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validação dados alterados.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidAlt(lCheck1)

Local lRet := .T.
Local lAlt := .F.

If dDtEnt <> cCalt1
	lAlt := .T.
Endif

If cCCust <> cCalt2
	lAlt := .T.
Endif

If cProje <> cCalt3
	lAlt := .T.
Endif

If AllTrim(cObser) <> AllTrim(cCalt4)
	lAlt := .T.
Endif

If !lAlt .And. !lCheck1
	MsgAlert("Alterações não informadas para o item.")
	lRet := .F.
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldDtE    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 14/08/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da Data de Entrega.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldDtE()

Local lRetorno := .F.

If Empty(cCalt1)
	MsgAlert("Dt.Entrega inválida.")
	lRetorno := .F.
Else
	lRetorno := .T.	
Endif

If lRetorno
	nDias  := cCalt1 - dDatabase
	cDalt1 := AllTrim(STR(nDias))+IIf(ABS(nDias) == 0 .Or. ABS(nDias) == 1," DIA"," DIAS")
	oSayAl1:SetText( AllTrim(cDalt1) )
	oSayAl1:CtrlRefresh()
Else
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCtt    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Centro de Custo.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCtt()

Local lRetorno := .F.

If Empty(cCalt2)
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("CTT")
DbSetOrder(1)
If DbSeek( xFilial("CTT") + cCalt2 )
	If CTT->CTT_BLOQ == "1"
		MsgAlert("C.Custo bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cDalt2 := Posicione("CTT",1,xFilial("CTT")+cCalt2,"CTT_DESC01")
	oSayAl2:SetText( AllTrim(cDalt2) )
	oSayAl2:CtrlRefresh()
Else
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldPrj    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Projeto.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldPrj()

Local lRetorno := .F.

DbSelectArea("AF8")
DbSetOrder(1)
If DbSeek( xFilial("AF8") + cCalt3 )
	If AF8->AF8_ENCPRJ == "1"
		MsgAlert("Projeto encerrado.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Projeto não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cDalt3 := RetField("AF8",1,xFilial("AF8")+cCalt3,"AF8_DESCRI")
	oSayAl3:SetText( AllTrim(cDalt3) )
	oSayAl3:CtrlRefresh()
Else
	oSayAl3:SetText( "" )
	oSayAl3:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A120FORN  ¦ Autor ¦ ERPBR		    ¦   Data  ¦ Abr/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processo de troca de fornecedor.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A120FORN()

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma alteração?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona alteração?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM

Private cCodAtu := SC7->C7_FORNECE
Private cNomAtu := RetField("SA2",1,xFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA),"A2_NOME")
Private cCodFor := Space(6)
Private cNomFor := Space(40)
Private oSayCod,oSayNom,oSayNew

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

// Checa se existe quantidade entregue
cQuery := " SELECT SUM(C7_QUJE) AS QUJE "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)
nQtdEnt := SQL7->QUJE
SQL7->(DbCloseArea())
If nQtdEnt > 0
	MsgAlert("Pedido possui quantidade entregue.")
	Return
Endif

// Checa se existe quantidade eliminada por resíduo
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
cQuery += " AND C7_RESIDUO <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)
lResid := ( SQL7->SOMA > 0 )
SQL7->(DbCloseArea())
If lResid
	MsgAlert("Pedido possui saldo eliminado por resíduo.")
	Return
Endif

nDlg1 := 001
nDlg2 := 001
nDlg3 := 210
nDlg4 := 850

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Alteração de Fornecedor",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 040,005 SAY "Forn.Atual" OF oDlg410 PIXEL SIZE 055,009
@ 039,040 TO 051,085 LABEL "" OF oDlg410 PIXEL
oSayCod:= TSay():New(042,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCod:SetText( AllTrim(cCodAtu) )
oSayCod:CtrlRefresh()

@ 039,090 TO 051,300 LABEL "" OF oDlg410 PIXEL
oSayNom:= TSay():New(042,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNom:SetText( AllTrim(cNomAtu) )
oSayNom:CtrlRefresh()

@ 060,005 SAY "Forn.Novo" OF oDlg410 PIXEL SIZE 055,009
@ 059,040 MSGET oCodFor VAR cCodFor SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SA2" VALID VldFor()
@ 059,090 TO 071,300 LABEL "" OF oDlg410 PIXEL
oSayNew:= TSay():New(062,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayNew:SetText( AllTrim(cNomFor) )
oSayNew:CtrlRefresh()

oDlg410:Activate(,,,.T.,{|| ValidFor() },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1

	cQuery := " UPDATE "+RetSqlName("SC7")+" SET C7_FORNECE = '"+cCodFor+"' "
	cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
	cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)
	TCSQLEXEC("COMMIT")
	
	MsgInfo("Alteração realizada com sucesso !!")

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValidFor   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validação dados Fornecedor.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidFor()

Local lRet := .T.

If Empty(cCodFor)
	MsgAlert("Fornecedor não informado.")
	lRet := .F.
Endif

If lRet
	If cCodAtu == cCodFor
		MsgAlert("Fornecedor não alterado.")
		lRet := .F.
	Endif
Endif

If lRet
	cCgcAtu := Posicione("SA2",1,xFilial("SA2")+cCodAtu,"A2_CGC")
	cCgcFor := Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_CGC")
	If Substr(cCgcAtu,1,8) <> Substr(cCgcFor,1,8)
		MsgAlert("Base cnpj diferente entre os fornecedores.")
		lRet := .F.
	Endif
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldFor    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Fornecedor.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldFor()

Local lRetorno := .F.

If Empty(cCodFor)
	oSayNew:SetText( "" )
	oSayNew:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("SA2")
DbSetOrder(1)
If DbSeek( xFilial("SA2") + cCodFor )
	If SA2->A2_MSBLQL == "1"
		MsgAlert("Fornecedor bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cNomFor := Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_NOME")
	oSayNew:SetText( AllTrim(cNomFor) )
	oSayNew:CtrlRefresh()
Else
	oSayNew:SetText( "" )
	oSayNew:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A120HIST ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 19/08/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta histórico das alterações no pedido.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A120HIST()

Local aArea   := GetArea()
Local aRotBkp := aClone(aRotina)
Local cCadBkp := cCadastro

Private cCadastro := "Histórico Alterações"

Private aRotina := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	    {"Visualizar" , "AxVisual" , 0 , 2 }}

Private cFiltro   := " ZZJ_FILIAL == '"+xFilial("ZZJ")+"' .And. ZZJ_PEDIDO == '"+SC7->C7_NUM+"' "

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "ZZJ" )
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "ZZJ", , , "ZZJ_FILENT" )		 
oMBrowse:ExecuteFilter()

oMBrowse:Activate()

DbSelectArea("ZZJ")
DbSetOrder(1)
DbClearFilter()
		
cCadastro := cCadBkp
aRotina := aClone(aRotBkp)

RestArea(aArea)

Return
