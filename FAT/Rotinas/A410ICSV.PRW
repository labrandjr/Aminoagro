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
¦¦¦Funcao    ¦ A410ICSV  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  10/03/2020   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Importação de Pedidos de Venda - Arquivo Csv.			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A410ICSV()

Local lOk  := .F.
Local lCsvImp := GetMv("MV_ZCSVIMP")
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

If !lCsvImp
	MsgAlert("Processo não habilitado.")
	Return
Endif

cArquivo := cGetFile("Arquivos CSV|*.CSV|",OemToAnsi("Selecione o arquivo"))
cArquivo := AllTrim(cArquivo)
If !Empty(cArquivo)
	If File(cArquivo)
		If MsgYesNo("Arquivo a ser processado: "+cEOL+cArquivo+"."+cEOL+"Deseja prosseguir ?","Aviso","INFO")
			lOkFile := .T.
		Endif
	Else
		MsgAlert("Arquivo não encontrado.")
	Endif
Else
	MsgAlert("Arquivo não selecionado.")
Endif

If lOkFile

	nHandle := fOpen(cArquivo,2)
	
	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	If MsgYesNo("Confirma o processamento - IMPORTAÇÃO CSV ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp(cArquivo) }, "Validando arquivo", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  28/02/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp(cArquivo)
Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local lProcOk   := .F.
Local xClien    := ""
Local xDesPo    := 0
Local xCodFv    := "011"
Local xFaixV    := 0
Local xCodFr    := "011"
Local xFaixR    := 0
Local xEbtDg    := 0
Local aProdu    := {}
Local lTudoOk   := .T.

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando arquivo csv..")

	// Fim de Arquivo
	If Len(cString) < 3
		Exit
	Endif

	nPosic  := 0
	aLinha  := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT(";",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	// Estrutura de aLinha:
	// [01] - Cnpj
	// [02] - I.E.
	// [03] - Desc.Pontualidade
	// [04] - Faixa Vendedor
	// [05] - Faixa Revenda
	// [06] - Produto
	// [07] - Quantidade
	// [08] - Preço Unitário
	// [09] - Ebitda Real/Total

	If Len(aLinha) < 7
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter pelo menos 7 posições.")
		Return
	Endif

	If Len(aLinha) == 7
		AAdd(aLinha,"0") // Completa 8a.posição
	Endif

	If Len(aLinha) == 8
		AAdd(aLinha,"0") // Completa 9a.posição
	Endif
	
	If Len(aLinha) > 0

		zCnpj  := aLinha[1]
		zInscr := aLinha[2]
		
		zDesPo := StrTran(aLinha[3],".","")
		zDesPo := StrTran(zDesPo,",",".")
		zDesPo := Val(zDesPo)

		zFaixV := StrTran(aLinha[4],".","")
		zFaixV := StrTran(zFaixV,",",".")
		zFaixV := Val(zFaixV)

		zFaixR := StrTran(aLinha[5],".","")
		zFaixR := StrTran(zFaixR,",",".")
		zFaixR := Val(zFaixR)
		 
		zProdu := aLinha[6]

		zQuant := StrTran(aLinha[7],".","")
		zQuant := StrTran(zQuant,",",".")
		zQuant := Val(zQuant)

		zPreco := StrTran(aLinha[8],".","")
		zPreco := StrTran(zPreco,",",".")
		zPreco := Val(zPreco)

		zEbtDg := StrTran(aLinha[9],".","")
		zEbtDg := StrTran(zEbtDg,",",".")
		zEbtDg := Val(zEbtDg)

		If !Empty(zCnpj)
			If Empty(xClien)
				zCnpj := PadR(zCnpj,14)
				DbSelectArea("SA1")
				DbSetOrder(3)
				If DbSeek( xFilial("SA1") + zCnpj )
					lInscr := .F.
					While !Eof() .And. SA1->A1_CGC == zCnpj
						A1inscr := StrTran(SA1->A1_INSCR,".","")
						A1inscr := StrTran(A1inscr,"-","")
						Csinscr := StrTran(zInscr,".","")
						Csinscr := StrTran(Csinscr,"-","")
						If AllTrim(A1inscr) == AllTrim(Csinscr)
							lInscr := .T.
							xClien := SA1->A1_COD
							Exit
						Endif
						SA1->(DbSkip())
					Enddo
					If !lInscr
						MsgAlert("I.E. "+AllTrim(zInscr)+" não cadastrado para o cliente "+AllTrim(SA1->A1_COD)+"-"+AllTrim(SA1->A1_NOME))
						lTudoOk := .F.
						Exit
					Endif	
					If SA1->A1_MSBLQL == "1"
						MsgAlert("Cliente "+AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_NOME)+" bloqueado.")
						lTudoOk := .F.
						Exit
					Endif
				Else
					MsgAlert("Cnpj não cadastrado: "+zCnpj)
					lTudoOk := .F.
					Exit
				Endif
			Endif
		Endif 

		If zDesPo > 0
			If Empty(xDesPo)
				xDesPo := zDesPo
			Endif
		Endif 

		If zFaixV > 0
			If Empty(xFaixV)
				xFaixV := zFaixV
			Endif
		Endif 

		If zFaixR > 0
			If Empty(xFaixR)
				xFaixR := zFaixR
			Endif
		Endif 

		If zEbtDg > 0
			If Empty(xEbtDg)
				xEbtDg := zEbtDg
			Endif
		Endif 

		If !Empty(zProdu)
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek( xFilial("SB1") + zProdu )
				If SB1->B1_MSBLQL == "1"
					MsgAlert("O produto "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+" está bloqueado para uso.")
					lTudoOk := .F.
					Exit
				ElseIf SB1->B1_ZBLQVEN == "1" 
					MsgAlert("O produto "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+" está bloqueado p/ Vendas.")
					lTudoOk := .F.
					Exit
				Else
					AAdd(aProdu,{SB1->B1_COD, zQuant, zPreco, SB1->B1_DESC})
				Endif	
			Else
				MsgInfo("Produto não localizado: "+zProdu)
	    		lTudoOk := .F.
	    		Exit
			Endif
		Endif

	Endif
		
Enddo

// Valida produtos
If lTudoOk
	If Len(aProdu) == 0
		MsgAlert("Não há produtos informados no arquivo.")
		lTudoOk := .F.
	Endif
Endif

// Valida Desconto Pontualidade
If lTudoOk
	xDesPo := AllTrim(STR(xDesPo))
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SX5")
	cQuery += " WHERE X5_FILIAL = '"+xFilial("SX5")+"' "
	cQuery += " AND X5_TABELA = 'ZZ' "
	cQuery += " AND X5_DESCRI = '"+xDesPo+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRX5", .F., .T.)
	lDesPo := (TRX5->SOMA > 0)
	TRX5->(DbCloseArea())
	If !lDesPo
		MsgAlert("Desconto pontuallidade não cadastrado: "+xDesPo)
		lTudoOk := .F.
	Endif
Endif

// Valida Faixa Vendedor
If lTudoOk .And. !Empty(xFaixV)
	cQuery := " SELECT Z2_CODIGO CODIGO "
	cQuery += " FROM "+RetSqlName("SZ2")
	cQuery += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' "
	cQuery += " AND Z2_COMIS = "+AllTrim(STR(xFaixV))+" "
	cQuery += " AND Z2_VALID >= '"+DtoS(dDatabase)+"' "
	cQuery += " AND Z2_ATIVO = 'S' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ2", .F., .T.)
	xCodFv := TRZ2->CODIGO
	TRZ2->(DbCloseArea())
	If Empty(xCodFv)
		MsgAlert("Faixa de Vendedor não cadastrada ou inválida: "+AllTrim(STR(xFaixV))+" %")
		lTudoOk := .F.
	Endif
Endif

// Valida Faixa Revenda
If lTudoOk .And. !Empty(xFaixR)
	cQuery := " SELECT Z3_CODIGO CODIGO "
	cQuery += " FROM "+RetSqlName("SZ3")
	cQuery += " WHERE Z3_FILIAL = '"+xFilial("SZ3")+"' "
	cQuery += " AND Z3_COMIS = "+AllTrim(STR(xFaixR))+" "
	cQuery += " AND Z3_VALID >= '"+DtoS(dDatabase)+"' "
	cQuery += " AND Z3_ATIVO = 'S' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ3", .F., .T.)
	xCodFr := TRZ3->CODIGO
	TRZ3->(DbCloseArea())
	If Empty(xCodFr)
		MsgAlert("Faixa de Revenda não cadastrada ou inválida: "+AllTrim(STR(xFaixR))+" %")
		lTudoOk := .F.
	Endif
Endif

If lTudoOk
	lProcOk := ImpCsv410(xClien, xDesPo, xCodFv, xFaixV, xCodFr, xFaixR, xEbtDg, aProdu, cArquivo)
	If lProcOk
		MsgInfo("Processo concluído.")
	Else
		MsgAlert("Processo não concluído.")
	Endif
Else
	MsgAlert("Processo interrompido.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  11/09/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua leitura do arquivo e retorna conteudo da linhaa.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fReadFile(nHandle,xFileSize,xBytesRead,nBytes)

Local nBytesRead := IIf(!((xBytesRead == 0) .Or. (xBytesRead == Nil)),xBytesRead,IIf(xFileSize < 1536,xFileSize,1536)) // Indica o numero de bytes a serem lidos
Local cBuffer    := Space(nBytesread) // Guarda o conteudo lido
Local nPosition  := 0 // Posicao do caracter 13 (return)
Local nIncbytes  := Nil // Incremento de bytes 2 CHR(13) + CHR(10)
Local xReturn    := Nil // Retorno da funcao

If ( ((FREAD(nHandle,@cBuffer,nBytesRead) = nBytesRead) .Or. (!Empty(cBuffer))) )
	// Verifica se procura o caracter 13 para identificar o registro
	xReturn := Substr(cBuffer,1,IIf(((nPosition := AT(CHR(13),cBuffer)) > 0),(nPosition - 1),Len(cBuffer)))
	// Verifica se incrementa bytes
	nIncBytes := IIf(nPosition > 0,2,0)
	// Bytes ja lidos somando os caracteres especiais
	nBytes := (nBytes + (Len(xReturn) + nIncBytes))
	// Retorna o descritor se necessario
	FSEEK(nHandle,(-1 * ABS((Len(cBuffer) - (Len(xReturn) + nIncBytes)))),1)
Endif

Return(xReturn)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  11/03/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Obtem o tamanho do arquivo texto.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ImpCsv410 ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  11/03/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Interface do processo de importação.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ImpCsv410(xClien, xDesPo, xCodFv, xFaixV, xCodFr, xFaixR, xEbtDg, aProdu, cArquivo)

Local nOpc410  := 0
Local bActOk   := {|| nOpc410:=1,PrepImp(cArquivo)}
Local bActCan  := {|| nOpc410:=0,oDlg410:End()}
Local bOk410   := {|| Eval(bActOk) }
Local bCan410  := {|| Eval(bActCan) }
Local lCultura := GetMv("MV_ZZCULTU")

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oLbx410 := Nil
Private aVet410 := {}
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM,oFilDes,oVende1,oVende2,oCondPg,oParc1,oParc2,oParc3,oParc4,oVenc1,oVenc2,oVenc3,oVenc4,oCultura
Private cFilDes, cClient, cVende1, cVende2, cFaixaV, cFaixaR, cCondPg, cDescPo, nEbtDg, nParc1, dVenc1, nParc2, dVenc2, nParc3, dVenc3, nParc4, dVenc4,cCultura
Private cPedVen := ""
Private cPedBon := ""
Private lRet410 := .T.

// Colunas do Folder
Private nFdrPro := 1
Private nFdrQtd := 2
Private nFdrPrc := 3
Private nFdrDes := 4

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)
                                                                   
// Carrega browse no Folder
aVet410 := {}
fCarg410(@aVet410,aProdu)
                                                                   
nDlg1 := 001
nDlg2 := 001
nDlg3 := 620
nDlg4 := 900

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + xClien )

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Importação Csv",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

cFilDes := Space(4)
cNomFil := ""
@ 040,005 SAY "Filial" OF oDlg410 PIXEL SIZE 055,009
@ 039,030 MSGET oFilDes VAR cFilDes SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SM0" VALID VldFil()
@ 039,090 TO 051,230 LABEL "" OF oDlg410 PIXEL
oSayFil:= TSay():New(042,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayFil:SetText( AllTrim(cNomFil) )
oSayFil:CtrlRefresh()

cClient := SA1->A1_COD
cNomCli := SA1->A1_NOME
@ 060,005 SAY "Cliente" OF oDlg410 PIXEL SIZE 055,009
@ 059,030 TO 071,075 LABEL "" OF oDlg410 PIXEL
oSayCod:= TSay():New(062,040,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCod:SetText( AllTrim(cClient) )
oSayCod:CtrlRefresh()

@ 059,090 TO 071,230 LABEL "" OF oDlg410 PIXEL
oSayCli:= TSay():New(062,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCli:SetText( AllTrim(cNomCli) )
oSayCli:CtrlRefresh()

cCnpj := SA1->A1_CGC
@ 060,240 SAY "CNPJ/CPF" OF oDlg410 PIXEL SIZE 055,009
@ 059,270 TO 071,338 LABEL "" OF oDlg410 PIXEL
oSayCgc:= TSay():New(062,273,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
If Len(AllTrim(cCnpj)) > 11
	oSayCgc:SetText( Transform(cCnpj,"@R 99.999.999/9999-99") )
Else
	oSayCgc:SetText( Transform(cCnpj,"@R 999.999.999-99") )
Endif	
oSayCgc:CtrlRefresh()

cInscr := SA1->A1_INSCR
@ 060,350 SAY "Ins.Estad." OF oDlg410 PIXEL SIZE 055,009
@ 059,380 TO 071,445 LABEL "" OF oDlg410 PIXEL
oSayIns:= TSay():New(062,383,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayIns:SetText( AllTrim(cInscr) )
oSayIns:CtrlRefresh()

cVende1 := Space(6)
cNomVe1 := ""
@ 080,005 SAY "Vend.1" OF oDlg410 PIXEL SIZE 055,009
@ 079,030 MSGET oVende1 VAR cVende1 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SA3" VALID VldVe1()
@ 079,090 TO 091,230 LABEL "" OF oDlg410 PIXEL
oSayVe1:= TSay():New(082,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayVe1:SetText( AllTrim(cNomVe1) )
oSayVe1:CtrlRefresh()

cFaixaV := xCodFv
@ 080,240 SAY "Faixa Vend" OF oDlg410 PIXEL SIZE 055,009
@ 079,270 TO 091,300 LABEL "" OF oDlg410 PIXEL
oSayFxV:= TSay():New(082,278,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayFxV:SetText( AllTrim(cFaixaV) )
oSayFxV:CtrlRefresh()
cAliquV := AllTrim(STR(xFaixV))+" %"
@ 079,305 TO 091,338 LABEL "" OF oDlg410 PIXEL
oSayPcV:= TSay():New(082,317,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayPcV:SetText( AllTrim(cAliquV) )
oSayPcV:CtrlRefresh()

cVende2 := Space(6)
cNomVe2 := ""
@ 100,005 SAY "Vend.2" OF oDlg410 PIXEL SIZE 055,009
@ 099,030 MSGET oVende2 VAR cVende2 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SA3" VALID VldVe2()
@ 099,090 TO 111,230 LABEL "" OF oDlg410 PIXEL
oSayVe2:= TSay():New(102,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayVe2:SetText( AllTrim(cNomVe2) )
oSayVe2:CtrlRefresh()

cFaixaR := xCodFr
@ 100,240 SAY "Faixa Rev" OF oDlg410 PIXEL SIZE 055,009
@ 099,270 TO 111,300 LABEL "" OF oDlg410 PIXEL
oSayFxR:= TSay():New(102,278,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayFxR:SetText( AllTrim(cFaixaR) )
oSayFxR:CtrlRefresh()
cAliquR := AllTrim(STR(xFaixR))+" %"
@ 099,305 TO 111,338 LABEL "" OF oDlg410 PIXEL
oSayPcR:= TSay():New(102,317,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayPcR:SetText( AllTrim(cAliquR) )
oSayPcR:CtrlRefresh()

cCondPg := Space(3)
cDescCp := ""
@ 120,005 SAY "Cond.Pg." OF oDlg410 PIXEL SIZE 055,009
@ 119,030 MSGET oCondPg VAR cCondPg SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SE4" VALID VldCpg()
@ 119,090 TO 131,230 LABEL "" OF oDlg410 PIXEL
oSayCpg:= TSay():New(122,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayCpg:SetText( AllTrim(cDescCp) )
oSayCpg:CtrlRefresh()

cDescPo := xDesPo
@ 120,240 SAY "Desc.Pont" OF oDlg410 PIXEL SIZE 055,009
@ 119,270 TO 131,338 LABEL "" OF oDlg410 PIXEL
oSayDpn:= TSay():New(122,298,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayDpn:SetText( AllTrim(cDescPo)+" %" )
oSayDpn:CtrlRefresh()

nEbtDg := xEbtDg
@ 120,350 SAY "Ebit R/Tot" OF oDlg410 PIXEL SIZE 055,009
@ 119,380 TO 131,445 LABEL "" OF oDlg410 PIXEL
oSayEbt:= TSay():New(122,400,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayEbt:SetText(AllTrim(STR(nEbtDg,14,2)))
oSayEbt:CtrlRefresh()

nParc1 := 0
dVenc1 := CtoD("")
@ 140,005 SAY "Parc.1" OF oDlg410 PIXEL SIZE 055,009
@ 139,030 MSGET oParc1 VAR nParc1 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 9,999,999.99"
@ 139,080 MSGET oVenc1 VAR dVenc1 SIZE 050,010 OF oDlg410 PIXEL

nParc2 := 0
dVenc2 := CtoD("")
@ 140,160 SAY "Parc.2" OF oDlg410 PIXEL SIZE 055,009
@ 139,185 MSGET oParc2 VAR nParc2 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 9,999,999.99"
@ 139,235 MSGET oVenc2 VAR dVenc2 SIZE 050,010 OF oDlg410 PIXEL

nParc3 := 0
dVenc3 := CtoD("")
@ 160,005 SAY "Parc.3" OF oDlg410 PIXEL SIZE 055,009
@ 159,030 MSGET oParc3 VAR nParc3 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 9,999,999.99"
@ 159,080 MSGET oVenc3 VAR dVenc3 SIZE 050,010 OF oDlg410 PIXEL

nParc4 := 0
dVenc4 := CtoD("")
@ 160,160 SAY "Parc.4" OF oDlg410 PIXEL SIZE 055,009
@ 159,185 MSGET oParc4 VAR nParc4 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 9,999,999.99"
@ 159,235 MSGET oVenc4 VAR dVenc4 SIZE 050,010 OF oDlg410 PIXEL

If lCultura
	cCultura := Space(6)
	@ 160,350 SAY "Cultura" OF oDlg410 PIXEL SIZE 055,009
	@ 159,380 MSGET oCultura VAR cCultura SIZE 065,010 OF oDlg410 PIXEL PICTURE "@!" F3 "ZB" VALID VldCult()
Endif

oSayLCon:= TSay():New(264,005,{||""},oDlg410,,oFnt4,,,,.T.,CLR_BLACK,CLR_WHITE,100,020)
oSayLCon:SetText("PEDIDOS GERADOS")
oSayLCon:CtrlRefresh()

@ 270,005 TO 300,445 LABEL "" OF oDlg410 PIXEL

cPedVen := ""
@ 280,010 SAY "Pedido de Venda" OF oDlg410 PIXEL SIZE 055,009
@ 279,060 TO 291,110 LABEL "" OF oDlg410 PIXEL
oSayPvv:= TSay():New(282,073,{||""},oDlg410,,oFnt2,,,,.T.,CLR_GREEN,CLR_WHITE,200,020)
oSayPvv:SetText( AllTrim(cPedVen) )
oSayPvv:CtrlRefresh()

cPedBon := ""
@ 280,140 SAY "Pedido de Bonificação" OF oDlg410 PIXEL SIZE 055,009
@ 279,200 TO 291,250 LABEL "" OF oDlg410 PIXEL
oSayPvb:= TSay():New(282,213,{||""},oDlg410,,oFnt2,,,,.T.,CLR_GREEN,CLR_WHITE,200,020)
oSayPvb:SetText( AllTrim(cPedBon) )
oSayPvb:CtrlRefresh()

nBrw1 := 180
nBrw2 := 005
nBrw3 := 445
nBrw4 := 078

oLbx410 := TWBrowse():New(nBrw1,nBrw2,nBrw3,nBrw4,,,,oDlg410,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx410:AddColumn( TcColumn():New( "Produto"         ,{ || aVet410[oLbx410:nAt][nFdrPro] } , "@!"                   ,,,"LEFT"	,050,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Quantidade"      ,{ || aVet410[oLbx410:nAt][nFdrQtd] } , "@E 999,999.99"        ,,,"RIGHT"	,040,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Prc Unitário"    ,{ || aVet410[oLbx410:nAt][nFdrPrc] } , "@E 99,999,999.99"     ,,,"RIGHT"	,040,.F.,.F.,,,,.F.,) )
oLbx410:AddColumn( TcColumn():New( "Descrição"       ,{ || aVet410[oLbx410:nAt][nFdrDes] } , "@!"                   ,,,"LEFT"	,150,.F.,.F.,,,,.F.,) )

oLbx410:SetArray(aVet410)
oLbx410:bHeaderClick := { |o,x,y| fHeader( o , x , y , @oLbx410 , @aVet410 ) }
oLbx410:bLDblClick   := { || fClickR(@oLbx410,@aVet410,oLbx410:nAt,oLbx410:nColPos) }

oDlg410:Activate(,,,.T.,{|| .T. },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

Return(lRet410)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldFil    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da filial.			 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldFil()

Local lRetorno := .F.
Local nRecSM0  := SM0->(Recno())

DbSelectArea("SM0")
DbSetOrder(1)
If DbSeek( SM0->M0_CODIGO + cFilDes )
	lRetorno := .T.
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cNomFil := Posicione("SM0",1,SM0->M0_CODIGO + cFilDes,"M0_FILIAL")
	oSayFil:SetText( AllTrim(cNomFil) )
	oSayFil:CtrlRefresh()
Else
	oSayFil:SetText( "" )
	oSayFil:CtrlRefresh()
Endif

SM0->(DbGoto(nRecSM0))

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldVe1    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Vendedor1.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldVe1()

Local lRetorno := .F.

If Empty(cVende1)
	oSayVe1:SetText( "" )
	oSayVe1:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cVende1 )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Vendedor bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cNomVe1 := Posicione("SA3",1,xFilial("SA3")+cVende1,"A3_NOME")
	oSayVe1:SetText( AllTrim(cNomVe1) )
	oSayVe1:CtrlRefresh()
Else
	oSayVe1:SetText( "" )
	oSayVe1:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldVe2    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Vendedor2.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldVe2()

Local lRetorno := .F.

If Empty(cVende2)
	oSayVe2:SetText( "" )
	oSayVe2:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cVende2 )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Vendedor bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cNomVe2 := Posicione("SA3",1,xFilial("SA3")+cVende2,"A3_NOME")
	oSayVe2:SetText( AllTrim(cNomVe2) )
	oSayVe2:CtrlRefresh()
Else
	oSayVe2:SetText( "" )
	oSayVe2:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCpg    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da Condição de Pagamento.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCpg()

Local lRetorno := .F.

If Empty(cCondPg)
	oSayCpg:SetText( "" )
	oSayCpg:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("SE4")
DbSetOrder(1)
If DbSeek( xFilial("SE4") + cCondPg )
	lRetorno := .T.
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cDescCp := Posicione("SE4",1,xFilial("SE4")+cCondPg,"E4_DESCRI")
	oSayCpg:SetText( AllTrim(cDescCp) )
	oSayCpg:CtrlRefresh()
Else
	oSayCpg:SetText( "" )
	oSayCpg:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCult   ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 11/03/2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da Cultura.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCult()

Local lRetorno := .F.

If Empty(cCultura)
	lRetorno := .T.
	Return
Endif

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek( xFilial("SX5") + "ZB" + cCultura )
	lRetorno := .T.
Else
	MsgAlert("Cultura não cadastrada.")
	lRetorno := .F.
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarg410 ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  11/03/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados no browse.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarg410(aVet410,aProdu)

aVet410 := aProdu

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClickR    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦ 11/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do Folder.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClickR(oLbx410,aVet410,nLin,nCol) 

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeader ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦ 11/03/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fHeader(oObj,nCol,nLin,oLbx410,lTodas,aVet410)

oLbx410:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PrepImp    ¦ Autor ¦ Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Prepara processamento.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function PrepImp(cArquivo)

If Empty(cPedVen) .And. Empty(cPedBon)
	If _Valida()
		MsgRun("Processando importação... aguarde","Processando",{|| _ImpCsvPv(cArquivo) })
	Endif	
Else
	oDlg410:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Valida  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 10/03/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Realiza validação no arquivo e dados digitados.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Valida()

Local lRetOk   := .T.
Local cFilBkp  := cFilAnt 
Local cEOL     := CHR(13)+CHR(10)
Local lCultura := GetMv("MV_ZZCULTU")
Local _ped

If Empty(cFilDes)
	MsgAlert("Filial não informada.")
	lRetOk := .F.
Endif

If lRetOk
	If Empty(cVende1)
	 	If !Empty(cFaixaV) .And. cFaixaV != "011" 
			MsgAlert("Vendedor1 não informado.")
			lRetOk := .F.
		Endif	
	Endif 
Endif

If lRetOk
	If Empty(cVende2)
	 	If !Empty(cFaixaR) .And. cFaixaR != "011" 
			MsgAlert("Vendedor2 não informado.")
			lRetOk := .F.
		Endif	
	Endif 
Endif

If lRetOk
	If Empty(cCondPg)
		MsgAlert("Cond.Pagamento não informada.")
		lRetOk := .F.
	Else
		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek( xFilial("SE4") + cCondPg )
		If SE4->E4_TIPO == "9"
			If Empty(nParc1) .And. Empty(dVenc1) .And. Empty(nParc2) .And. Empty(dVenc2) .And.;
			   Empty(nParc3) .And. Empty(dVenc3) .And. Empty(nParc4) .And. Empty(dVenc4)
			   MsgAlert("Dados da condição de pagamento tipo 9 não informados.")
			   lRetOk := .F.
			Else
				If AllTrim(SE4->E4_COND) == "0"
					zTotVen := 0
					zTotPar := nParc1 + nParc2 + nParc3 + nParc4
					For _ped := 1 to Len(aVet410)
						If aVet410[_ped][nFdrPrc] > 0
							zTotVen += ( aVet410[_ped][nFdrQtd] * aVet410[_ped][nFdrPrc] )
						Endif	
					Next _ped
					If zTotVen <> zTotPar
						MsgAlert("Soma das parcelas (R$ "+AllTrim(STR(zTotPar,12,2))+") é diferente do valor total do pedido (R$ "+AllTrim(STR(zTotVen,12,2))+").")
						lRetOk := .F.
					Endif
				Endif
			Endif     
		Endif
	Endif 
Endif

If lCultura
	If lRetOk
		If Empty(cCultura)
			MsgAlert("Cultura não informada.")
			lRetOk := .F.
		Endif 
	Endif
Endif

If lRetOk

	cFilAnt := cFilDes
	For _ped := 1 to Len(aVet410)
		If aVet410[_ped][nFdrPrc] == 0
	
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + aVet410[_ped][nFdrPro] )
			
			zProduto := SB1->B1_COD
			zTes     := MaTesInt(2,"04",SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
			zPrcVen  := PrcRefBon(SB1->B1_COD,SA1->A1_COD,zTes)
			If zPrcVen == 0
				MsgAlert("Produto "+AllTrim(SB1->B1_COD)+" sem referência de preço para Bonificação.")
				lRetOk := .F.
				Exit
			Else
				nPrcVen := zPrcVen
				aPrcHis := U_PrcHist(SA1->A1_COD,SB1->B1_COD,"")
				If nPrcVen < aPrcHis[1]
					MsgAlert("O preço de venda do produto "+AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)+" é menor que "+;
							 "o praticado no histórico desse cliente."+cEOL+;
							 "Preço de Venda no Histórico: R$ "+AllTrim(STR(aPrcHis[1],9,2))+cEOL+;
							 IIf(aPrcHis[2]=="D","Documento: "+aPrcHis[3]+" - Emissão: "+aPrcHis[4] ,"Pedido: "+aPrcHis[3]+" - Emissão: "+aPrcHis[4]))
				Endif
			Endif

		Endif
	Next _ped

Endif

If lRetOk

	cFilAnt := cFilDes
	For _ped := 1 to Len(aVet410)

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + aVet410[_ped][nFdrPro] )
		
		If aVet410[_ped][nFdrQtd] == 0
			MsgAlert("Produto "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+" sem quantidade informada.")
			lRetOk := .F.
			Exit
		Endif
		
		If lRetOk
			zCCVend := RetField("SA3",1,xFilial("SA3")+cVende1,"A3_ZZCC")
			zUniNeg := RetField("CTT",1,xFilial("CTT")+zCCVend,"CTT_ZZITCT")
			If !(U_VldCusto(.T.,SB1->B1_COD,zUniNeg))
				lRetOk := .F.
				Exit
			Endif
		Endif
		If lRetOk
			If !(U_VldCom("SZ2",cFaixaV,SB1->B1_COD))
				lRetOk := .F.
				Exit
			Endif
		Endif
		If lRetOk	
			If !(U_VldCom("SZ3",cFaixaR,SB1->B1_COD))
				lRetOk := .F.
				Exit
			Endif
		Endif	

		If aVet410[_ped][nFdrPrc] > 0
			nPrcVen := aVet410[_ped][nFdrPrc]
			aPrcHis := U_PrcHist(SA1->A1_COD,SB1->B1_COD,"")
			If nPrcVen < aPrcHis[1]
				MsgAlert("O preço de venda do produto "+AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)+" é menor que "+;
						 "o praticado no histórico desse cliente."+cEOL+;
						 "Menor preço encontrado no histórico: R$ "+AllTrim(STR(aPrcHis[1],9,2))+" ("+aPrcHis[2]+")")
			Endif
		Endif	

	Next _ped

Endif

// CM-33167 - Inclusão de validação da quantidade por embalagem - 23/11/2022
If lRetOk

	aItEmb   := {}
	lVldEmb  := ( AllTrim(GetMv("MV_XVLDEMB"))=="S" )
	If lVldEmb
		For _ped := 1 to Len(aVet410)
			zPedi := "IMPCSV"
			zItem := StrZero(_ped,2)
			zSequ := ""
			zProd := aVet410[_ped][nFdrPro]
			zQtde := aVet410[_ped][nFdrQtd]
			AAdd(aItEmb,{zPedi, zItem, zSequ, zProd, zQtde, "PED"})
		Next _ped
	Endif
	If Len(aItEmb) > 0
		lRetOk := u_VldEmblg(aItEmb)
	Endif

Endif

cFilAnt := cFilBkp 

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _ImpCsvPv ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦ 10/03/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processa importação do pedido de venda.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _ImpCsvPv(cArquivo)

Local aCabec   := {}
Local aItens   := {}
Local nNumIt   := 0
Local cFilBkp  := cFilAnt
Local lCultura := GetMv("MV_ZZCULTU")
Local _ped

Private nSaveSX8 := IIf(Type("nSaveSx8")=="U", GetSX8Len(), nSaveSX8)
Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

cFilAnt := cFilDes // --> Muda filial corrente para Filial Destino

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + cClient )

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek( xFilial("SE4") + cCondPg )

z5Parc1 := nParc1
z5Data1 := dVenc1
z5Parc2 := nParc2
z5Data2 := dVenc2
z5Parc3 := nParc3
z5Data3 := dVenc3
z5Parc4 := nParc4
z5Data4 := dVenc4

zVend1    := cVende1
zVend2    := cVende2
zRegVen   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_REGIAO")
zCCVend   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_ZZCC")
zUniNeg   := RetField("CTT",1,xFilial("CTT")+zCCVend,"CTT_ZZITCT")
zSuper1   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_SUPER")
zSuper2   := RetField("SA3",1,xFilial("SA3")+zVend2,"A3_SUPER")
zGeren1   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_GEREN")
zGeren2   := RetField("SA3",1,xFilial("SA3")+zVend2,"A3_GEREN")
zDesMer   := RetField("SA3",1,xFilial("SA3")+zVend1,"A3_ZZDM")
zPrjAmi   := "N"
z5CondPag := cCondPg
z5ZZCDFXV := IIf(Empty(cVende1),"",cFaixaV)
z5ZZCDFXR := IIf(Empty(cVende2),"",cFaixaR)
z5ZZPPONT := cDescPo
z5ZEBTDIG := nEbtDg
z5ZZTPBON := "BS"
z5Moeda   := 1 
zTxMoed   := 1
zArqCsv   := cArquivo
If lCultura
	zCultura := cCultura
Endif	

lPedVen := .F.
For _ped := 1 to Len(aVet410)
	If aVet410[_ped][nFdrPrc] > 0
		lPedVen := .T.
	Endif
Next _ped

// Pedido de Venda
If lPedVen

	nCnt := 0
	cDoc := GetSXENum("SC5","C5_NUM")		
	RollBackSX8()
	SC5->(DbSetOrder(1))		
	While SC5->(DbSeek(xFilial("SC5")+cDoc))			
		ConfirmSX8()			
		cDoc := GetSXENum("SC5","C5_NUM")
		RollBackSX8()
		nCnt += 1
		If nCnt > 10 // Caso haja mais de 10 tentativas, corrigir o sxe/sxf.
			MsgInfo("Falha no sequenciamento da numeração de pedidos. Contate o Administrador.")
			lRet410 := .F.
			Return
		Endif
	EndDo					
	
	aCabec := {}
	aItens := {}
	nNumIt := 0
	
	AAdd(aCabec,{ "C5_NUM"    , cDoc,         Nil })
	AAdd(aCabec,{ "C5_TIPO"   , "N",          Nil })
	AAdd(aCabec,{ "C5_CLIENTE", SA1->A1_COD,  Nil })
	AAdd(aCabec,{ "C5_LOJACLI", SA1->A1_LOJA, Nil })
	AAdd(aCabec,{ "C5_CLIENT" , SA1->A1_COD,  Nil })
	AAdd(aCabec,{ "C5_LOJAENT", SA1->A1_LOJA, Nil })
	AAdd(aCabec,{ "C5_TIPOCLI", SA1->A1_TIPO, Nil })			
	AAdd(aCabec,{ "C5_CONDPAG", z5CondPag,    Nil })
	AAdd(aCabec,{ "C5_TPFRETE", "C", 	      Nil })
	AAdd(aCabec,{ "C5_VEND1"  , zVend1,       Nil })
	AAdd(aCabec,{ "C5_ZZCDFXV", z5ZZCDFXV,    Nil })
	AAdd(aCabec,{ "C5_VEND2"  , zVend2,       Nil })
	AAdd(aCabec,{ "C5_ZZCDFXR", z5ZZCDFXR,    Nil })
	AAdd(aCabec,{ "C5_ZZREGVE", zRegVen,      Nil })
	AAdd(aCabec,{ "C5_ZZITCTB", zUniNeg,      Nil })
	AAdd(aCabec,{ "C5_XPRJAMI", zPrjAmi,      Nil })
	AAdd(aCabec,{ "C5_ZEBTDIG", z5ZEBTDIG,    Nil })
	AAdd(aCabec,{ "C5_PARC1"  , z5Parc1,      Nil })
	AAdd(aCabec,{ "C5_DATA1"  , z5Data1,      Nil })
	AAdd(aCabec,{ "C5_PARC2"  , z5Parc2,      Nil })
	AAdd(aCabec,{ "C5_DATA2"  , z5Data2,      Nil })
	AAdd(aCabec,{ "C5_PARC3"  , z5Parc3,      Nil })
	AAdd(aCabec,{ "C5_DATA3"  , z5Data3,      Nil })
	AAdd(aCabec,{ "C5_PARC4"  , z5Parc4,      Nil })
	AAdd(aCabec,{ "C5_DATA4"  , z5Data4,      Nil })
	AAdd(aCabec,{ "C5_ZZPPONT", z5ZZPPONT,    Nil })
	AAdd(aCabec,{ "C5_MOEDA"  , z5Moeda,      Nil })
	AAdd(aCabec,{ "C5_TXMOEDA", zTxMoed,      Nil })
	AAdd(aCabec,{ "C5_EMISSAO", Date(),       Nil })
	AAdd(aCabec,{ "C5_SUPER1" , zSuper1,      Nil })
	AAdd(aCabec,{ "C5_SUPER2" , zSuper2,      Nil })
	AAdd(aCabec,{ "C5_GEREN1" , zGeren1,      Nil })
	AAdd(aCabec,{ "C5_GEREN2" , zGeren2,      Nil })
	AAdd(aCabec,{ "C5_ZZDM"   , zDesMer,      Nil })
	AAdd(aCabec,{ "C5_ZARQCSV", zArqCsv,      Nil })
	If lCultura
		AAdd(aCabec,{ "C5_ZZCULT" , zCultura, Nil })
	Endif	
	
	For _ped := 1 to Len(aVet410)
	
		If aVet410[_ped][nFdrPrc] > 0
	
			nNumIt += 1
			zzItem := StrZero(nNumIt,TamSx3("C6_ITEM")[1])
	
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + aVet410[_ped][nFdrPro] )
			
			zProduto := SB1->B1_COD
			zQtdVen  := aVet410[_ped][nFdrQtd]
			zPrcVen  := aVet410[_ped][nFdrPrc]
			zTotal   := Round((zQtdVen * zPrcVen),2) 
			zTes     := MaTesInt(2,"01",SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
			zArmazem := "04"
			zDescri  := SB1->B1_DESC
			zUnsVen  := ConvUm(zProduto, zQtdVen, 0, 2)
			zCCusto  := ""
			If AllTrim(zProduto) == "SERV0001"
				zCCusto := "106040801001"
			ElseIf !Empty(zVend1)
				DbSelectArea("SA3")
				DbSetOrder(1)
				If DbSeek( xFilial("SA3") + zVend1 )
					zCCusto := SA3->A3_ZZCC
				Endif
			Endif
			zItCtb := RetField("CTT",1,xFilial("CTT")+zCCusto,"CTT_ZZITCT")
	
			aLinha := {}			
			AAdd(aLinha,{ "C6_NUM"    , cDoc,      Nil })
			AAdd(aLinha,{ "C6_ITEM"   , zzItem,    Nil })
			AAdd(aLinha,{ "C6_PRODUTO", zProduto,  Nil })
			AAdd(aLinha,{ "C6_QTDVEN" , zQtdVen,   Nil })
			AAdd(aLinha,{ "C6_PRCVEN" , zPrcVen,   Nil })
			AAdd(aLinha,{ "C6_VALOR"  , zTotal,    Nil })
			AAdd(aLinha,{ "C6_ENTREG" , dDatabase, Nil })
			AAdd(aLinha,{ "C6_TES"    , zTes,      Nil })
			AAdd(aLinha,{ "C6_LOCAL"  , zArmazem,  Nil })
			AAdd(aLinha,{ "C6_UNSVEN" , zUnsVen,   Nil })
			AAdd(aLinha,{ "C6_PRUNIT" , zPrcVen,   Nil })
			AAdd(aLinha,{ "C6_DESCRI" , zDescri,   Nil })
			AAdd(aLinha,{ "C6_CCUSTO" , zCCusto,   Nil })
			AAdd(aLinha,{ "C6_ZZITCTB", zItCtb,    Nil })
			AAdd(aItens,aLinha)		
	
		Endif
	
	Next _ped
	
	Begin Transaction
	
	lMsErroAuto := .F.
	MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabec, aItens, 3)		
	If !lMsErroAuto			
	
		While (GetSX8Len() > nSaveSX8)
			ConFirmSX8()
		Enddo
	
		cPedVen := SC5->C5_NUM
		oSayPvv:SetText( AllTrim(cPedVen) )
		oSayPvv:CtrlRefresh()
	
	Else			
	
		MostraErro()
		DisarmTransaction()
		While (GetSX8Len() > nSaveSX8)
			RollBackSX8()
		Enddo
		lRet410 := .F.
	
	Endif
	
	If lMsErroAuto
		cFilAnt := cFilBkp
		Return
	Endif

	End Transaction
	MsUnLockAll()

Endif

lPedBon := .F.
For _ped := 1 to Len(aVet410)
	If aVet410[_ped][nFdrPrc] == 0
		lPedBon := .T.
	Endif
Next _ped

If lPedBon

	// Pedido de Bonificação
	nCnt := 0
	cDoc := GetSXENum("SC5","C5_NUM")		
	RollBackSX8()
	SC5->(DbSetOrder(1))		
	While SC5->(DbSeek(xFilial("SC5")+cDoc))			
		ConfirmSX8()			
		cDoc := GetSXENum("SC5","C5_NUM")
		RollBackSX8()
		nCnt += 1
		If nCnt > 10 // Caso haja mais de 10 tentativas, corrigir o sxe/sxf.
			MsgInfo("Falha no sequenciamento da numeração de pedidos. Contate o Administrador.")
			DisarmTransaction()
			cFilAnt := cFilBkp
			lRet410 := .F.
			Return
		Endif
	EndDo					
	
	aCabec := {}
	aItens := {}
	nNumIt := 0
	
	AAdd(aCabec,{ "C5_NUM"    , cDoc,            Nil })
	AAdd(aCabec,{ "C5_TIPO"   , "N",             Nil })
	AAdd(aCabec,{ "C5_CLIENTE", SA1->A1_COD,     Nil })
	AAdd(aCabec,{ "C5_LOJACLI", SA1->A1_LOJA,    Nil })
	AAdd(aCabec,{ "C5_CLIENT" , SA1->A1_COD,     Nil })
	AAdd(aCabec,{ "C5_LOJAENT", SA1->A1_LOJA,    Nil })
	AAdd(aCabec,{ "C5_TIPOCLI", SA1->A1_TIPO,    Nil })			
	AAdd(aCabec,{ "C5_CONDPAG", "015",           Nil })
	AAdd(aCabec,{ "C5_TPFRETE", "C", 	         Nil })
	AAdd(aCabec,{ "C5_VEND1"  , zVend1,          Nil })
	AAdd(aCabec,{ "C5_ZZCDFXV", "",              Nil })
	AAdd(aCabec,{ "C5_VEND2"  , zVend2,          Nil })
	AAdd(aCabec,{ "C5_ZZCDFXR", "",              Nil })
	AAdd(aCabec,{ "C5_ZZREGVE", zRegVen,         Nil })
	AAdd(aCabec,{ "C5_ZZITCTB", zUniNeg,         Nil })
	AAdd(aCabec,{ "C5_XPRJAMI", zPrjAmi,         Nil })
	AAdd(aCabec,{ "C5_ZEBTDIG", z5ZEBTDIG,       Nil })
	AAdd(aCabec,{ "C5_ZZPPONT", z5ZZPPONT,       Nil })
	AAdd(aCabec,{ "C5_ZZTPBON", z5ZZTPBON,       Nil })
	AAdd(aCabec,{ "C5_MOEDA"  , z5Moeda,         Nil })
	AAdd(aCabec,{ "C5_TXMOEDA", zTxMoed,         Nil })
	AAdd(aCabec,{ "C5_EMISSAO", Date(),          Nil })
	AAdd(aCabec,{ "C5_SUPER1" , zSuper1,         Nil })
	AAdd(aCabec,{ "C5_SUPER2" , zSuper2,         Nil })
	AAdd(aCabec,{ "C5_GEREN1" , zGeren1,         Nil })
	AAdd(aCabec,{ "C5_GEREN2" , zGeren2,         Nil })
	AAdd(aCabec,{ "C5_ZZDM"   , zDesMer,         Nil })
	AAdd(aCabec,{ "C5_ZARQCSV", zArqCsv,         Nil })
	
	For _ped := 1 to Len(aVet410)
	
		If aVet410[_ped][nFdrPrc] == 0
	
			nNumIt += 1
			zzItem := StrZero(nNumIt,TamSx3("C6_ITEM")[1])
	
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + aVet410[_ped][nFdrPro] )
			
			zProduto := SB1->B1_COD
			zTes     := MaTesInt(2,"04",SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
			zQtdVen  := aVet410[_ped][nFdrQtd]
			zPrcVen  := PrcRefBon(SB1->B1_COD,SA1->A1_COD,zTes)
			zTotal   := Round((zQtdVen * zPrcVen),2) 
			zArmazem := "04"
			zDescri  := SB1->B1_DESC
			zUnsVen  := ConvUm(zProduto, zQtdVen, 0, 2)
			zCCusto  := ""
			If AllTrim(zProduto) == "SERV0001"
				zCCusto := "106040801001"
			ElseIf !Empty(zVend1)
				DbSelectArea("SA3")
				DbSetOrder(1)
				If DbSeek( xFilial("SA3") + zVend1 )
					zCCusto := SA3->A3_ZZCC
				Endif
			Endif
			zItCtb := RetField("CTT",1,xFilial("CTT")+zCCusto,"CTT_ZZITCT")
	
			aLinha := {}			
			AAdd(aLinha,{ "C6_NUM"    , cDoc,      Nil })
			AAdd(aLinha,{ "C6_ITEM"   , zzItem,    Nil })
			AAdd(aLinha,{ "C6_PRODUTO", zProduto,  Nil })
			AAdd(aLinha,{ "C6_QTDVEN" , zQtdVen,   Nil })
			AAdd(aLinha,{ "C6_PRCVEN" , zPrcVen,   Nil })
			AAdd(aLinha,{ "C6_VALOR"  , zTotal,    Nil })
			AAdd(aLinha,{ "C6_ENTREG" , dDatabase, Nil })
			AAdd(aLinha,{ "C6_TES"    , zTes,      Nil })
			AAdd(aLinha,{ "C6_LOCAL"  , zArmazem,  Nil })
			AAdd(aLinha,{ "C6_UNSVEN" , zUnsVen,   Nil })
			AAdd(aLinha,{ "C6_PRUNIT" , zPrcVen,   Nil })
			AAdd(aLinha,{ "C6_DESCRI" , zDescri,   Nil })
			AAdd(aLinha,{ "C6_CCUSTO" , zCCusto,   Nil })
			AAdd(aLinha,{ "C6_ZZITCTB", zItCtb,    Nil })
			AAdd(aItens,aLinha)		
	
		Endif
	
	Next _ped
	
	Begin Transaction
	
	lMsErroAuto := .F.
	MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabec, aItens, 3)		
	If !lMsErroAuto			
	
		While (GetSX8Len() > nSaveSX8)
			ConFirmSX8()
		Enddo
	
		cPedBon := SC5->C5_NUM
		oSayPvb:SetText( AllTrim(cPedBon) )
		oSayPvb:CtrlRefresh()
	
	Else			
	
		MostraErro()
		DisarmTransaction()
		While (GetSX8Len() > nSaveSX8)
			RollBackSX8()
		Enddo
		lRet410 := .F.
	
	Endif
	
	If lMsErroAuto
		cFilAnt := cFilBkp
		Return
	Endif
	
	End Transaction
	MsUnLockAll()

Endif

cFilAnt := cFilBkp

oFilDes:Disable()
oVende1:Disable()
oVende2:Disable()
oCondPg:Disable()
oParc1:Disable()
oParc2:Disable()
oParc3:Disable()
oParc4:Disable()
oVenc1:Disable()
oVenc2:Disable()
oVenc3:Disable()
oVenc4:Disable()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ PrcRefBon ¦ Autor ¦ Fabrica ERPBR     ¦ Data ¦  13/03/20	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Pesquisa histórico de bonificação.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function PrcRefBon(yProduto,yCliente,yTes)

Local aArea   := GetArea()
Local nPrcBon := 0

cQuery := " SELECT C6_NUM PEDIDO, C6_PRCVEN PRCVEN "
cQuery += " FROM "+RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " AND C6_PRODUTO = '"+AllTrim(yProduto)+"' "
cQuery += " AND C6_CLI = '"+AllTrim(yCliente)+"' "
cQuery += " AND C6_TES = '"+AllTrim(yTes)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY PEDIDO DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBX", .F., .T.)
TRBX->(DbGotop())
If !Eof()
	nPrcBon := TRBX->PRCVEN
Endif	
TRBX->(DbCloseArea())

If nPrcBon == 0
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + yProduto )
	nPrcBon := SB1->B1_ZPRCREF
Endif

RestArea(aArea)

Return(nPrcBon)
