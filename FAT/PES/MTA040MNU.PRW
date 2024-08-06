#include 'totvs.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA040MNU ¦ Autor ¦ Luis Brandini  ¦ Data  ¦  14/02/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na rotina de Vendedores.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA040MNU()

Local lPlrAdd := GetMv("MV_ZPLRADD")
Local lUsuRH  := ( __cUserId $ AllTrim(GetMv("MV_XUSPLRH")) )

If lPlrAdd
	If lUsuRH
		AAdd(aRotina,{"Vincular DM" ,"U_PLR040DM()", 0, 7, 0, Nil}) 
	Endif	
	AAdd(aRotina,{"Extrato Projeção","U_PLR040EX()", 0, 7, 0, Nil}) 
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PLR040DM ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 14/02/2022 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Vincular DM no RTV - Acesso exclusivo RH.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PLR040DM()

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma alteração?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona alteração?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM
Private oSayVn1,oSayNm1,oSayAl1,oSayVn2,oSayNm2,oSayAl2,oSayVn3,oSayNm3,oSayAl3,oSayVn4,oSayNm4,oSayAl4
Private cGeren,cSuper
Private cGcalt,cGnalt,cScalt,cSnalt

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

If Substr(SA3->A3_COD,1,1) <> "V"
	MsgAlert("Vínculo de DM não permitido para este código.")
	Return
Endif

nRecSa3 := SA3->(Recno())
cTitAd  := "RTV "+SA3->A3_COD+" - "+SA3->A3_NOME
cDesMer := SA3->A3_ZZDM
cNomeDM := Posicione("SA3",1,xFilial("SA3")+cDesMer,"A3_NOME")
                                                                   
nDlg1 := 001
nDlg2 := 001
nDlg3 := 200
nDlg4 := 700

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Vincular DM - "+cTitAd,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 040,005 SAY "D.M." OF oDlg410 PIXEL SIZE 055,009
@ 039,050 MSGET oValt1 VAR cDesMer SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SA3" VALID VldDms()
@ 039,100 TO 051,240 LABEL "" OF oDlg410 PIXEL
oSayAl1:= TSay():New(042,103,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl1:SetText( AllTrim(cNomeDM) )
oSayAl1:CtrlRefresh()

oDlg410:Activate(,,,.T.,{|| .T. },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	SA3->(DbGoto(nRecSa3))
	RecLock("SA3",.F.)
	SA3->A3_ZZDM := cDesMer
	MsUnLock()
	If !Empty(cDesMer)
		MsgInfo("Vínculo realizado com sucesso !!")
	Endif	
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldDms    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 14/02/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do DM.				 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldDms()

Local lRetorno := .F.

If Empty(cDesMer)
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
	lRetorno := .T.
	Return(lRetorno)
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cDesMer )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Código bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	If Substr(SA3->A3_COD,1,2) <> "CM"
		MsgAlert("Código inválido para DM.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cNomeDM := Posicione("SA3",1,xFilial("SA3")+cDesMer,"A3_NOME")
	oSayAl1:SetText( AllTrim(cNomeDM) )
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
¦¦¦Programa  ¦ PLR040EX ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 14/02/2022 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Reenvio do extrato modelo projeção.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PLR040EX()

If Substr(SA3->A3_COD,1,1) == "V"
	U_QRTVMAN() // Extrato projeção modelo RTV
ElseIf Substr(SA3->A3_COD,1,2) == "CM"
	U_QDMSMAN() // Extrato projeção modelo DM
ElseIf Substr(SA3->A3_COD,1,1) == "G"
	If MsgYesNo("Enviar modelo GRV ?")
		U_QGRVMAN() // Extrato projeção modelo GRV - Gerentes
	Else
		If MsgYesNo("Enviar modelo RTV ?")
			U_QRTVMAN() // Extrato projeção modelo RTV
		Endif
	Endif	
ElseIf Substr(SA3->A3_COD,1,1) == "D"
	U_QGRVMAN() // Extrato projeção modelo GRV - Diretores
Else
	MsgInfo("Modelo projeção não previsto para este código.")
Endif

Return
