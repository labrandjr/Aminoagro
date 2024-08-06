#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SLDENDE   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 30/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria saldo inicial por endereço conforme arquivo csv.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SLDENDE()

Local lOk   := .F.
Local lEnd	:= .F.
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

If __cUserId != "000000"
	MsgAlert("Rotina disponível para o Administrador.")
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

	If MsgYesNo("Confirma carga inicial - ENDEREÇAMENTO ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := pProcSld() }, "Atualizando dados", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pProcSld  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 30/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa processamento.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pProcSld()

Local aCargEnd := {}
Local aSldLote := {}
Local lInicOk  := .T.

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/38)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
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
	// [01] - Produto
	// [02] - Armazém
	// [03] - Lote
	// [04] - Endereço
	// [05] - Quantidade

	If Len(aLinha) != 5
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 5 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := "0102"
		zProduto := PadR(AllTrim(aLinha[1]),15)
		zArmazem := AllTrim(aLinha[2])
		zLoteCtl := PadR(AllTrim(aLinha[3]),10)
		zEnderec := PadR(AllTrim(aLinha[4]),15)
		zQuantid := AllTrim(aLinha[5])
		zQuantid := StrTran(zQuantid,".","")
		zQuantid := Val(StrTran(zQuantid,",","."))
		zNumLote := Space(6)
		zPriorid := Space(3)
		lTudoOk := .T.

		DbSelectArea("SB8")
		DbSetOrder(3)
		If !DbSeek( zFilial + zProduto + zArmazem + zLoteCtl )
//			MsgAlert("Produto sem saldo no lote: "+AllTrim(zProduto)+" - "+AllTrim(zArmazem)+" - "+AllTrim(zLoteCtl)+".")
			ConOut("Produto sem saldo no lote: "+AllTrim(zProduto)+" - "+AllTrim(zArmazem)+" - "+AllTrim(zLoteCtl)+".")
			lTudoOk := .F.
			lInicOk := .F.
		Else
			lAddLot := .F.
			If Len(aSldLote) == 0
				lAddLot := .T.
			Else
				nPos := aScan(aSldLote, {|x| x[1] == zProduto .And. x[2] == zArmazem .And. x[3] == zLoteCtl })
				If nPos > 0
					aSldLote[nPos][4] += zQuantid
				Else
					lAddLot := .T.
				Endif
			Endif
			If lAddLot
				AAdd(aSldLote,{zProduto, zArmazem, zLoteCtl, zQuantid})
			Endif
		Endif

		If lTudoOk
			DbSelectArea("SBE")
			DbSetOrder(1)
			If !DbSeek( zFilial + zArmazem + zEnderec )
//				MsgAlert("Endereço não cadastrado: "+AllTrim(zArmazem)+" - "+AllTrim(zEnderec)+".")
				ConOut("Endereço não cadastrado: "+AllTrim(zArmazem)+" - "+AllTrim(zEnderec)+".")
				lTudoOk := .F.
				lInicOk := .F.
/*				RecLock("SBE",.T.)
				SBE->BE_FILIAL  := zFilial
				SBE->BE_LOCAL   := zArmazem
				SBE->BE_LOCALIZ := zEnderec
				SBE->BE_DESCRIC := zEnderec
				SBE->BE_PRIOR   := "ZZZ"
				SBE->BE_STATUS  := "1"
				SBE->BE_DATGER  := Date()
				MsUnLock() */
			Endif
		Endif	

		If lTudoOk
			DbSelectArea("SBF")
			DbSetOrder(2)
			If DbSeek( zFilial + zProduto + zArmazem + zLoteCtl + zNumLote + zPriorid + zEnderec )
//				MsgAlert("Produto com saldo por endereço já cadastrado: "+AllTrim(zProduto)+" - "+AllTrim(zArmazem)+" - "+AllTrim(zLoteCtl)+" - "+AllTrim(zEnderec)+".")
				ConOut("Produto com saldo por endereço já cadastrado: "+AllTrim(zProduto)+" - "+AllTrim(zArmazem)+" - "+AllTrim(zLoteCtl)+" - "+AllTrim(zEnderec)+".")
				lTudoOk := .F.
				lInicOk := .F.
			Endif
		Endif	

		If lTudoOk
			AAdd(aCargEnd,{zProduto, zArmazem, zLoteCtl, zEnderec, zQuantid})
		Endif

	Endif
		
Enddo

lSldSb8Ok := .T.
For _x := 1 to Len(aSldLote)
	zFilial  := "0102"
	zProduto := aSldLote[_x][1]
	zArmazem := aSldLote[_x][2]
	zLoteCtl := aSldLote[_x][3]
	zSaldSb8 := aSldLote[_x][4]
	DbSelectArea("SB8")
	DbSetOrder(3)
	DbSeek( zFilial + zProduto + zArmazem + zLoteCtl )
	If SB8->B8_SALDO != zSaldSb8
//		MsgAlert("Produto com saldo divergente no lote: "+AllTrim(zProduto)+" - "+AllTrim(zArmazem)+" - "+AllTrim(zLoteCtl)+": SB8 = "+AllTrim(STR(SB8->B8_SALDO))+" | CSV = "+AllTrim(STR(zSaldSb8)))
		ConOut("Produto com saldo divergente no lote: "+AllTrim(zProduto)+" - "+AllTrim(zArmazem)+" - "+AllTrim(zLoteCtl)+": SB8 = "+AllTrim(STR(SB8->B8_SALDO))+" | CSV = "+AllTrim(STR(zSaldSb8)))
		lSldSb8Ok := .F.
	Endif	
Next _x

If lInicOk .And. lSldSb8Ok
	If Len(aCargEnd) > 0
		MsgRun("Aguarde, carga inicial endereços...","Processando",{|| _InputSbf(aCargEnd) })
		MsgInfo("Carga inicial concluída com sucesso !!")
	Else
		MsgAlert("Sem dados para carga inicial.")
	Endif
Else
	MsgAlert("Divergências no arquivo. Processo interrompido.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  04/02/17	  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  04/02/17	  ¦¦¦
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
¦¦¦Programa  ¦ _InputSbf ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  13/12/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Obtem o tamanho do arquivo texto.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _InputSbf(aCargEnd)

Local cNumSeq   := ProxNum()
Local cCounter	:= StrZero(0,TamSx3("DB_ITEM")[1])
Local cSerieDoc	:= "001"
Local cFilBkp   := cFilAnt
Local i

cFilAnt := "0102"

For i := 1 to Len(aCargEnd)

	cCounter := Soma1(cCounter)

	CriaSDB(aCargEnd[i,1],;	// Produto
			aCargEnd[i,2],;	// Armazem
			aCargEnd[i,5],;	// Quantidade
			aCargEnd[i,4],;	// Localizacao
			"",;			// Numero de Serie
			"SLDINICIO",;	// Doc
			"001",;		    // Serie
			"",;			// Cliente / Fornecedor
			"",;			// Loja
			"",;			// Tipo NF
			"ACE",;			// Origem do Movimento
			dDataBase,;		// Data
			aCargEnd[i,3],;	// Lote
			"",; 			// Sub-Lote
			cNumSeq,;		// Numero Sequencial
			"499",;			// Tipo do Movimento
			"M",;			// Tipo do Movimento (Distribuicao/Movimento)
			cCounter,;		// Item
			.F.,;			// Flag que indica se e' mov. estorno
			0,;				// Quantidade empenhado
			aCargEnd[i,5])	// Quantidade segunda UM

	GravaSBF("SDB")

Next i

cFilAnt := cFilBkp

Return

/*
Static Function MA805Process(lEnd)
// Obtem numero sequencial do movimento
LOCAL cNumSeq:=ProxNum(),i
// Numero do Item do Movimento
Local cCounter	:=	StrZero(0,TamSx3('DB_ITEM')[1])
Local lIntegPPI  := PCPIntgPPI()
Local aPPIDelete := {}
Local cSerieDoc	:= ""
Local cEspec		:= CriaVar("F1_ESPECIE")

ProcRegua(Len(aCols))
cSerieDoc:= SerieNfId("SDB",4,"DB_SERIE",dDataBase,cEspec,cSerie805)
// Varre o ACols gravando o SDB
For i:=1 to Len(aCols)
	IncProc()
	If !(aCols[i,Len(aCols[i])])
		cCounter := Soma1(cCounter)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria registro de movimentacao por Localizacao (SDB)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CriaSDB(aCols[i,1],;	// Produto
				aCols[i,2],;	// Armazem
				aCols[i,4],;	// Quantidade
				aCols[i,3],;	// Localizacao
				aCols[i,8],;	// Numero de Serie
				cDoc805,;		// Doc
				cSerieDoc,;		// Serie
				"",;			// Cliente / Fornecedor
				"",;			// Loja
				"",;			// Tipo NF
				"ACE",;			// Origem do Movimento
				dDataBase,;		// Data
				aCols[i,6],;	// Lote
				If(Rastro(aCols[i,1],"S"),aCols[i,7],""),; // Sub-Lote
				cNumSeq,;		// Numero Sequencial
				"499",;			// Tipo do Movimento
				"M",;			// Tipo do Movimento (Distribuicao/Movimento)
				cCounter,;		// Item
				.F.,;			// Flag que indica se e' mov. estorno
				0,;				// Quantidade empenhado
				aCols[i,5])		// Quantidade segunda UM
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma saldo em estoque por localizacao fisica (SBF)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GravaSBF("SDB")

		// Integração com TOTVS MES
		if lIntegPPI
			dbSelectArea("SOE")
			SOE->(dbSetOrder(1))
			If SOE->(dbSeek(xFilial("SOE")+"SB2")) .AND. ALLTRIM(SOE->OE_VAR3) == '1'
				MATA225PPI(aCols[i,1],; // Produto
							aCols[i,2],; // Armazém
							aCols[i,3],; // Localização
							aCols[i,8],; // Número de série
							aCols[i,6],; // Lote
							If(Rastro(aCols[i,1],"S"),aCols[i,7],""),; // Sub-lote
							dDataBase,;  // Data
							aCols[i,4],; // Quantidade
							'1',; // Tipo de movimento
							cNumSeq,; // Sequencia
							cDoc805,; // Documento
							aPPIDelete)
			Endif
		Endif
	EndIf
Next i

*/
