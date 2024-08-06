#include "protheus.ch"
#include "rwmake.ch"        
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA450R  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦  26/09/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após rejeição do crédito.	  		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA450R()

Local aArea := GetArea()

Private nOpcBxa := 0
Private oDlgBxa := Nil
Private bBxaOk  := {|| nOpcBxa:=1,oDlgBxa:End()}
Private bBxaCan := {|| nOpcBxa:=0,oDlgBxa:End()}
Private bOkBxa  := {|| IIf(MsgYesNo("Confirma gravação do motivo?","Movimentar"), Eval(bBxaOk), .F.) }
Private bCanBxa := {|| Eval(bBxaCan) }

oFnt1 := TFont():New("Tahoma",,12,,.F.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.T.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 650
nLinI := 035
nLin1 := nLinI

oDlgBxa := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Motivo da Rejeição",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

zMotRej := Space(100)
@ nLin1,005 SAY "Informe o Motivo da Rejeição:" OF oDlgBxa PIXEL SIZE 150,010
@ nLin1+015,005 MSGET oMotRej VAR zMotRej SIZE 285,010 OF oDlgBxa PIXEL PICTURE "@X" VALID !Empty(zMotRej)

oDlgBxa:Activate(,,,.T.,,,{|| EnchoiceBar(oDlgBxa,bOkBxa,bCanBxa) } )

If nOpcBxa == 1
	_GrvRej(zMotRej)	
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _GrvRej  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦  14/05/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após rejeição do crédito.	  		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _GrvRej(zMotRej)

Local aArea := GetArea()

If Empty(zMotRej)
	zMotRej := "Não informado"
Endif

DbSelectArea("ZZA")
DbSetOrder(1)
If DbSeek( xFilial("ZZA") + SC9->C9_PEDIDO + SC9->C9_ITEM )
	RecLock("ZZA",.F.)
	ZZA->ZZA_EMLSTT := "2" // Aguardando envio do email
	ZZA->ZZA_TXTLIB := "Rejeitado por "+AllTrim(cUserName)+" em "+DtoC(Date())+". Item: "+SC9->C9_ITEM+". Motivo: "+AllTrim(zMotRej)
	ZZA->ZZA_TIPLIB := "I" // I=Item
	MsUnLock()
Endif

RestArea(aArea)

Return
