#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ MEMLBOL   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  28/02/2019  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Monitor para envio de e-mails dos Boletos Pdf.			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MEMLBOL()

Local aArea    := GetArea()
Local cPerg	   := Padr("MEMLBOL",10)
Local aFiles   := {}
Local aBoletos := {}
Local nArq

If Pergunte(cPerg,.T.)

	zDiret := AllTrim(mv_par01)+"\"
	aFiles := Directory(zDiret+"*.pdf","D")

	If Len(aFiles) == 0
		MsgAlert("Não foram encontrados arquivos PDf no diretório informado.")
	Else
		For nArq := 1 to Len(aFiles)
			cFile  := Alltrim(zDiret + aFiles[nArq,1])
			cIdBol := AllTrim(aFiles[nArq,1])
			nPosTr := AT("-",cIdBol)
			cIdTit := Substr(cIdBol,nPosTr+1,18) // 18 = Filial(4) + Prefixo(3) + Numero(9) + Parcela(2)
			DbSelectArea("SE1")
			DbSetOrder(1)
			If DbSeek( cIdTit )
				lFound := .F.
				While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cIdTit
					If Substr(SE1->E1_TIPO,3,1) <> "-"
						lFound := .T.
						Exit
					Endif
					SE1->(DbSkip())
				Enddo 
				If (mv_par02 == 1 .And. Empty(SE1->E1_ZBOLEML)) .Or. (mv_par02 == 2 .And. !Empty(SE1->E1_ZBOLEML)) .Or. (mv_par02 == 3) .And. lFound
					AAdd(aBoletos,{SE1->(Recno()), cIdBol, cFile})
				Endif	
			Endif
		Next nArq	
	Endif

	If Len(aBoletos) == 0
		MsgAlert("Sem dados para envio. Verifique os parâmetros.")
	Else
		U_MAILBOL(aBoletos)			
	Endif

Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ MAILBOL   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  28/02/2019  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interface para envio de e-mails.							  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MAILBOL(aBoletos)

Local aArea := GetArea()

Local aObjects := {}
Local aSizeAut := {}
Local aInfo    := {}
Local aPosObj  := {}

Private nOpcAco := 0
Private oDlgAco := Nil
Private bActOk  := {|| nOpcAco:=1,oDlgAco:End() }
Private bActCan := {|| nOpcAco:=0,oDlgAco:End() }
Private bOkAcor := {|| IIf(MsgYesNo("Confirma envio dos boletos selecionados?","Enviar e-mail"), Eval(bActOk), .F.) }
Private bCanAco := {|| IIf(MsgYesNo("Abandona o processo?","Sair"), Eval(bActCan), .F.) }

// Colunas do browse
Private nFdrLeg := 1
Private nFdrMkb := 2
Private nFdrFil := 3
Private nFdrPre := 4
Private nFdrNum := 5
Private nFdrPar := 6
Private nFdrTip := 7
Private nFdrCli := 8
Private nFdrNom := 9
Private nFdrVeR := 10
Private nFdrVal := 11
Private nFdrEml := 12
Private nFdrPdf := 13

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
Private cCadastro := "Monitor de E-mails - Boletos de Cobrança"

Private nQtdTit := 0
Private nValTit := 0

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.T.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

Menu oMenuAco PopUp
	MenuItem "Marca Todos" 		Action Eval( { || lTodos := .T. , aEval( aVetAco , { |k| k[nFdrMkb] := lTodos      } ) , nQtdTit := 0 , aEval( aVetAco , { |k| nQtdTit += IIf( k[nFdrMkb], 1, 0 ) } ) , nValTit := 0 , aEval( aVetAco , { |k| nValTit += IIf( k[nFdrMkb], k[nFdrVal], 0 ) } ) , oQtdTit:Refresh() , oValTit:Refresh() , oLbxAco:Refresh() } )
	MenuItem "Desmarca Todos"  	Action Eval( { || lTodos := .F. , aEval( aVetAco , { |k| k[nFdrMkb] := lTodos      } ) , nQtdTit := 0 , aEval( aVetAco , { |k| nQtdTit += IIf( k[nFdrMkb], 1, 0 ) } ) , nValTit := 0 , aEval( aVetAco , { |k| nValTit += IIf( k[nFdrMkb], k[nFdrVal], 0 ) } ) , oQtdTit:Refresh() , oValTit:Refresh() , oLbxAco:Refresh() } )
	MenuItem "Inverter Seleção" Action Eval( { || lTodos := Nil , aEval( aVetAco , { |k| k[nFdrMkb] := !k[nFdrMkb] } ) , nQtdTit := 0 , aEval( aVetAco , { |k| nQtdTit += IIf( k[nFdrMkb], 1, 0 ) } ) , nValTit := 0 , aEval( aVetAco , { |k| nValTit += IIf( k[nFdrMkb], k[nFdrVal], 0 ) } ) , oQtdTit:Refresh() , oValTit:Refresh() , oLbxAco:Refresh() } )
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
nFtAlt := (260/659)
nAlBr4 := Round((nFtAlt * nAlDlg),0) // Linha final (Browse Redimensionado)

// Fator Largura do Dlg
nFtLar := (730/1474)
nLaBr3 := Round((nFtLar * nLaDlg),0) // Coluna final (Browse Redimensionado)

// Dimensões do Browse
n2Brw1 := 035
n2Brw2 := 005
n2Brw3 := nLaBr3
n2Brw4 := nAlBr4

// Dimensões do rodapé
nLI1Rod := n2Brw1 + nAlBr4 + 10
nCo2Rod := 550

// Carga de dados
fCarga(@aVetAco,aBoletos)

// ***************************************************************************************************** //
// ** Browse de títulos a receber para seleção                                                        ** //
// ***************************************************************************************************** //
oLbxAco := TWBrowse():New(n2Brw1,n2Brw2,n2Brw3,n2Brw4,,,,oDlgAco,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxAco:AddColumn( TcColumn():New( "  "    	       ,{ || IIf(aVetAco[oLbxAco:nAt][nFdrLeg],oVerde,oAzul) }  , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "  "  	       ,{ || IIf(aVetAco[oLbxAco:nAt][nFdrMkb],oOk,oNo) }       , "@!",,,"CENTER"	,010,.T.,.F.,,,,.F.,) )     						
oLbxAco:AddColumn( TcColumn():New( "Filial"        ,{ || aVetAco[oLbxAco:nAt][nFdrFil] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Prefixo"       ,{ || aVetAco[oLbxAco:nAt][nFdrPre] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "No.Título"     ,{ || aVetAco[oLbxAco:nAt][nFdrNum] } , "@!"       ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Parcela"       ,{ || aVetAco[oLbxAco:nAt][nFdrPar] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Tipo"          ,{ || aVetAco[oLbxAco:nAt][nFdrTip] } , "@!"       ,,,"LEFT"	,020,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Cliente"       ,{ || aVetAco[oLbxAco:nAt][nFdrCli] } , "@!"       ,,,"LEFT"	,030,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Razão"         ,{ || aVetAco[oLbxAco:nAt][nFdrNom] } , "@!"       ,,,"LEFT"	,120,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Vencto."       ,{ || aVetAco[oLbxAco:nAt][nFdrVeR] } , ""	      ,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Valor R$"      ,{ || aVetAco[oLbxAco:nAt][nFdrVal] } , "@E 99,999,999,999.99" ,,,"RIGHT"	,050,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "E-mail"        ,{ || aVetAco[oLbxAco:nAt][nFdrEml] } , "@X"       ,,,"LEFT"	,100,.F.,.F.,,,,.F.,) )
oLbxAco:AddColumn( TcColumn():New( "Arquivo Pdf"   ,{ || aVetAco[oLbxAco:nAt][nFdrPdf] } , "@!"       ,,,"LEFT"	,100,.F.,.F.,,,,.F.,) )

oLbxAco:SetArray(aVetAco)
oLbxAco:bHeaderClick := { |o,x,y| IIf( x == nFdrMkb , oMenuAco:Activate(x,y,oLbxAco) , fHeader( o , x , y , @oLbxAco , @aVetAco ) ) }
oLbxAco:bLDblClick := { || fClick(@oLbxAco,@aVetAco,oLbxAco:nAt,oLbxAco:nColPos) }

@ nLI1Rod,020 SAY "Títulos Selecionados" OF oDlgAco PIXEL SIZE 055,009
@ nLI1Rod-1,080 MSGET oQtdTit VAR nQtdTit PICTURE "@E 9,999" OF oDlgAco PIXEL WHEN .F. SIZE 070,009

@ nLI1Rod,nCo2Rod-50 SAY "Valor Total R$" OF oDlgAco PIXEL SIZE 055,009
@ nLI1Rod-1,nCo2Rod MSGET oValTit VAR nValTit PICTURE  PesqPict("SE1","E1_VALOR",,1) OF oDlgAco PIXEL WHEN .F. SIZE 070,009

oDlgAco:Activate(,,,.T.,{|| _Validar(aVetAco) },,{|| EnchoiceBar(oDlgAco,bOkAcor,bCanAco) } )

If nOpcAco == 1
	MsgRun("Enviando boletos selecionados... aguarde","Processando",{|| ExBolEml(aVetAco) })
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ExBolEml ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  28/02/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa envio dos e-mails.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ExBolEml(aVetAco)

Local lEnvMail := .F.
Local bol

For bol := 1 to Len(aVetAco)

	If aVetAco[bol][nFdrMkb]

		zFil := aVetAco[bol][nFdrFil]
		zPre := aVetAco[bol][nFdrPre]
		zNum := aVetAco[bol][nFdrNum]
		zPar := aVetAco[bol][nFdrPar]

		DbSelectArea("SE1")
		DbSetOrder(1)
		If DbSeek( zFil + zPre + zNum + zPar )

			aMensage := {}
			AAdd(aMensage, "Prezado(a) "+CapitalAce(aVetAco[bol][nFdrNom]))
			AAdd(aMensage, "")
			AAdd(aMensage, "Anexo boleto de cobrança referente nota fiscal emitida em "+DtoC(SE1->E1_EMISSAO)+" com vencimento dia "+DtoC(SE1->E1_VENCREA)+".")
			AAdd(aMensage, "Em caso de dúvidas contate o Departamento Contas a Receber através dos e-mails:")
			AAdd(aMensage, "gleice.oliveira@icl-group.com;carolina.santos@icl-group.com ou através do telefone (19) 2516-8700")

			zEmail   := AllTrim(aVetAco[bol][nFdrEml])
			zCopias  := AllTrim(GetMv("MV_ZEMLBOL")) // "boletospreventiva@fertilaqua.com"
			zAssunto := "Boleto de Cobrança - Nfe "+AllTrim(aVetAco[bol][nFdrPre])+"-"+AllTrim(aVetAco[bol][nFdrNum])+IIf(!Empty(aVetAco[bol][nFdrPar]),"-"+aVetAco[bol][nFdrPar],"")
	
			zArqLocal := AllTrim(mv_par01)+"\"+AllTrim(aVetAco[bol][nFdrPdf])
			zArqServd := "\boletos\"+aVetAco[bol][nFdrPdf]
			CpyT2S( zArqLocal, "\boletos", .F. )
	
			aAttach  := {}
			zAttach  := zArqServd
			AAdd(aAttach,zAttach)
	
			U_TMailBol(zEmail, zAssunto, aMensage, zAttach, zCopias)
	
			fErase(zArqServd)

			RecLock("SE1",.F.)
			SE1->E1_ZBOLEML := "E"
			MsUnLock()

			If mv_par03 == 1 // Atualiza cadastro do cliente = Email2
				DbSelectArea("SA1")
				DbSetOrder(1)
				If DbSeek( xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA) )
					RecLock("SA1",.F.)
					SA1->A1_EMAIL2 := aVetAco[bol][nFdrEml]
					MsUnLock()
				Endif
			Endif

			lEnvMail := .T.
			
		Endif

	Endif

Next bol

If lEnvMail
	MsgInfo("E-mails enviados com sucesso.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeader  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  28/02/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
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
¦¦¦Programa  ¦ fClick    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦  28/02/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do browse.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClick(oLbxAco,aVetAco,nLin,nCol)

If nCol == nFdrMkb // Markbrowse
	aVetAco[nLin][nCol] := !aVetAco[nLin][nCol]
	nQtdTit += IIf( aVetAco[nLin][nCol] , 1 , -1 )
	nValTit += IIf( aVetAco[nLin][nCol] , aVetAco[nLin][nFdrVal] , aVetAco[nLin][nFdrVal]*-1 )
	oQtdTit:Refresh()
	oValTit:Refresh()
Endif

If nCol == nFdrEml // E-Mail
	nVal := aVetAco[nLin][nCol]
	lEditCell( @aVetAco , @oLbxAco , "@X" , nCol ) 
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarga  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  28/02/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtro de dados.											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarga(aVetAco,aBoletos)

MsgRun("Selecionando títulos... aguarde","Processando",{|| fCarg01(@aVetAco,aBoletos) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg01  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  27/02/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa filtro dos títulos a receber.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg01(aVetAco,aBoletos)

Local bol

aVetAco := {}

For bol := 1 to Len(aBoletos)

	DbSelectArea("SE1")
	SE1->(DbGoto(aBoletos[bol][1]))

	If SE1->E1_VENCREA < mv_par04 .Or. SE1->E1_VENCREA > mv_par05
		Loop
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) )

	lLegenda := ( Empty(SE1->E1_ZBOLEML) )
	cMailEnv := IIf(!Empty(SA1->A1_EMAIL2),Lower(AllTrim(SA1->A1_EMAIL2)),Lower(AllTrim(SA1->A1_EMAIL)))

	AAdd(aVetAco,{ lLegenda,; // Verde = Não enviado |  Azul = Enviado
				   .F.,; // Não marcado
				   SE1->E1_FILIAL,;
				   SE1->E1_PREFIXO,;
				   SE1->E1_NUM,;
				   SE1->E1_PARCELA,;
				   SE1->E1_TIPO,;
				   SE1->E1_CLIENTE,;
				   SA1->A1_NOME,;
				   SE1->E1_VENCREA,;
				   SE1->E1_VALOR,;
				   PadR(cMailEnv,100),;
				   aBoletos[bol][2] })

Next bol

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  28/02/2019	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validacao geral da interface.		  					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Validar(aVetAco)

Local lRetorno := .F.
Local _x

For _x := 1 to Len(aVetAco)
	If aVetAco[_x][nFdrMkb]
		lRetorno := .T.
	Endif
Next _x

If !lRetorno
	MsgInfo("Nenhum boleto selecionado.")
Endif

Return(lRetorno)
