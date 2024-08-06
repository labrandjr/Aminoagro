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
¦¦¦Funcao    ¦ DLGEMAIL  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  15/11/2017  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interface para configurar e-mails dos extratos premiação.  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DlgEmail(aLista)

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End() }
Local bActCan := {|| nOpc410:=0,oDlg410:End() }
Local bOk410  := {|| IIf( MsgYesNo("Confirma envio dos e-mails?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona envio dos e-mails?","Sair"), Eval(bActCan), .F.) }
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
Private nFdrCod := 3
Private nFdrNom := 4
Private nFdrEml := 5
Private nFdrPdf := 6

Private oLbx410 := Nil
Private aVet410 := {}
Private oDlg410

Private oMenu410
Private lTodas := .F.

Private aEmlEnv := {}

// Carrega browse no Folder
aVet410 := {}
fCarg410(@aVet410,aLista)

Menu oMenu410 PopUp
	MenuItem "Marca Todos" 		Action Eval( { || lTodas := .T. , aEval( aVet410 , { |k| k[nFdrMkb] := IIf(k[nFdrLeg],lTodas,.F.) } ) , oLbx410:Refresh() } )
	MenuItem "Desmarca Todos"  	Action Eval( { || lTodas := .F. , aEval( aVet410 , { |k| k[nFdrMkb] := lTodas } ) , oLbx410:Refresh() } )
	MenuItem "Inverter Seleção" Action Eval( { || lTodas := Nil , aEval( aVet410 , { |k| k[nFdrMkb] := IIf(k[nFdrLeg],!k[nFdrMkb],.F.) } ) , oLbx410:Refresh() } )
EndMenu

nDlg1 := 001
nDlg2 := 001
nDlg3 := 440
nDlg4 := 900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Extratos de Premiação via E-Mail",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

nBrw1 := 033
nBrw2 := 005
nBrw3 := 440
nBrw4 := 180

oLbx410 := TWBrowse():New(nBrw1,nBrw2,nBrw3,nBrw4,,,,oDlg410,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx410:AddColumn( TcColumn():New( "  "    	         ,{ || IIf(aVet410[oLbx410:nAt][nFdrLeg],oVerde,oVerme) } , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "  "  	         ,{ || IIf(aVet410[oLbx410:nAt][nFdrMkb],oOk,oNo) }       , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )     						
oLbx410:AddColumn( TcColumn():New( "Código"          ,{ || aVet410[oLbx410:nAt][nFdrCod] } , "@!"	                ,,,"LEFT"	,025,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Nome"            ,{ || aVet410[oLbx410:nAt][nFdrNom] } , "@!"                   ,,,"LEFT"	,090,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "E-Mail"          ,{ || aVet410[oLbx410:nAt][nFdrEml] } , "@X"                   ,,,"LEFT"	,090,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Pdf"             ,{ || aVet410[oLbx410:nAt][nFdrPdf] } , "@!"                   ,,,"LEFT"	,100,.F.,.F.,,,,.F.,) )

oLbx410:SetArray(aVet410)
oLbx410:bHeaderClick := { |o,x,y| IIf( x == nFdrMkb , oMenu410:Activate(x,y,oLbx410) , fHeaderR( o , x , y , @oLbx410 , @lTodas , @aVet410 ) ) }					
oLbx410:bLDblClick   := { || fClickR(@oLbx410,@aVet410,oLbx410:nAt,oLbx410:nColPos) }

oDlg410:Activate(,,,.T.,{|| _Validar(aVet410) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	MsgRun("Formatando lista de envio... aguarde","Processando",{|| _MontaLista(@aEmlEnv) })
Endif

Return(aEmlEnv)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg410 ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  15/11/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados no browse.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg410(aVet410,aLista)

For _x := 1 to Len(aLista)
	AAdd(aVet410,{ .T.,;
				   .T.,;
				   aLista[_x][1],;  // Código
				   aLista[_x][2],;  // Nome
				   aLista[_x][3],;  // E-Mail
				   aLista[_x][4] }) // Pdf
Next _x

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

If nCol == nFdrMkb // Markbrowse
	If aVet410[nLin][nFdrLeg] // Somente legenda Verde
		aVet410[nLin][nCol] := !aVet410[nLin][nCol]
	Endif	
Endif

If nCol == nFdrEml // E-Mail
	nVal := aVet410[nLin][nCol]
	lEditCell( @aVet410 , @oLbx410 , "@X" , nCol ) 
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeaderR ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦ 15/11/2017	  ¦¦¦
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
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 15/11/2017	  ¦¦¦
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
		MsgInfo("Nenhum registro selecionado.")
	Endif
Endif

If lRetorno
	For _ped := 1 to Len(aVet410)
		If aVet410[_ped][nFdrMkb]
			If Empty(aVet410[_ped][nFdrEml])
				MsgInfo("Registro selecionado sem e-mail informado.")
				lRetorno := .F.
				Exit
			Endif
		Endif
	Next _ped
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 15/11/2017	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validacao geral da interface.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _MontaLista(aEmlEnv)

For _ped := 1 to Len(aVet410)
	If aVet410[_ped][nFdrMkb]
		AAdd(aEmlEnv,{aVet410[_ped][nFdrCod], aVet410[_ped][nFdrNom], aVet410[_ped][nFdrEml], aVet410[_ped][nFdrPdf]})
	Endif
Next _ped

Return
