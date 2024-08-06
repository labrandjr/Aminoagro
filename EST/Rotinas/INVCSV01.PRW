#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ INVCSV01  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 07/02/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação da digitação do inventário.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function INVCSV01()

Local lOk   := .F.
Local lEnd	:= .F.
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

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

	If MsgYesNo("Confirma o processamento - DIGITAÇÃO DO INVENTÁRIO ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importando digitação", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  07/02/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local lProcOk   := .F.
Local lMsgDig   := .T.
Private lMsHelpAuto := .F. // Determina se as mensagens de help devem ser direcionadas para o arq. de log
Private lMsErroAuto := .F. // Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

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
	// [01] - Produto
	// [02] - Armazém
	// [03] - Documento
	// [04] - Quantidade
	// [05] - Data
	// [06] - Lote
	// [07] - Endereço
	// [08] - Contagem

	If Len(aLinha) < 8
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 8 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zProdut := PadR(aLinha[1],15)
		zLocal  := PadR(aLinha[2],2)
		zDocum  := PadR(aLinha[3],9)
		zQuant  := StrTran(aLinha[4],".","")
		zQuant  := StrTran(zQuant,",",".")
		zQuant  := Val(zQuant)
		zData   := StoD(aLinha[5])
		zLote   := PadR(aLinha[6],10)
		zEndere := PadR(aLinha[7],15)
		zContag := PadR(aLinha[8],3)
		lTudoOk := .T.

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zProdut )
			MsgInfo("Produto não localizado: "+AllTrim(zProdut))
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Else
			If SB1->B1_RASTRO == "L"
				If Empty(zLote)
					MsgInfo("O produto "+AllTrim(SB1->B1_COD)+" utiliza Rastreabilidade = 'Lote' porém o arquivo não contém número do lote.")
			    	If MsgYesNo("Abandona ?","Aviso","INFO")
			    		Exit
			    	Endif
					Loop
				Endif
			Endif
			lEndere := (SB1->B1_LOCALIZ == "S")
			DbSelectArea("SBZ")
			DbSetOrder(1)
			If DbSeek( xFilial("SBZ") + SB1->B1_COD )
				lEndere := (SBZ->BZ_LOCALIZ == "S")			
			Endif
			If lEndere
				If Empty(zEndere)
					MsgInfo("O produto "+AllTrim(SB1->B1_COD)+" utiliza controle de endereçamento porém o arquivo não contém o endereço.")
			    	If MsgYesNo("Abandona ?","Aviso","INFO")
			    		Exit
			    	Endif
					Loop
				Endif
			Endif
		Endif

		If SB1->B1_MSBLQL == "1"
			MsgInfo("Produto bloqueado: "+AllTrim(zProdut))
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		DbSelectArea("SB2")
		DbSetOrder(1)
		If !DbSeek( cFilAnt + zProdut + zLocal )
			MsgInfo("Saldo não localizado para o produto "+AllTrim(zProdut)+" no armazém "+AllTrim(zLocal)+" na Filial "+AllTrim(cFilAnt)+".")
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		DbSelectArea("SB7")
		DbSetOrder(1)
		If DbSeek( cFilAnt + DtoS(zData) + zProdut + zLocal + zEndere + Space(TamSx3("B7_NUMSERI")[1]) + zLote + Space(TamSx3("B7_NUMLOTE")[1]) + zContag )
			If lMsgDig
				MsgInfo("A digitação abaixo já foi localizada e será ignorada."+cEOL+cEOL+;
				"Filial: "+cFilAnt+cEOL+;
				"Data: "+DtoC(zData)+cEOL+;  
				"Produto: "+AllTrim(zProdut)+" - "+AllTrim(SB1->B1_DESC)+cEOL+;
				"Armazém: "+zLocal+cEOL+;
				"Lote: "+zLote+cEOL+;
				"Endereço: "+zEndere+cEOL+;
				"Contagem: "+zContag)
		    	If MsgYesNo("Abandona ?","Aviso","INFO")
		    		Exit
		    	Endif
				If !MsgYesNo("Permanece exibindo alertas das digitações já localizadas ?","Aviso","INFO")
					lMsgDig := .F.
				Endif
			Endif	
			Loop
		Endif

		If lTudoOk
			aVetor := {{"B7_FILIAL"  , cFilAnt,  Nil},;
			           {"B7_COD"     , zProdut , Nil},;
			           {"B7_LOCAL"   , zLocal  , Nil},;
			           {"B7_DOC"     , zDocum  , Nil},;
			           {"B7_QUANT"   , zQuant  , Nil},;
			           {"B7_LOTECTL" , zLote   , Nil},;
			           {"B7_LOCALIZ" , zEndere , Nil},;
			           {"B7_ESCOLHA" , " "     , Nil},;
			           {"B7_CONTAGE" , zContag , Nil},;
			           {"B7_DATA"    , zData   , Nil}}
			MsExecAuto( {|x,y,z| MATA270(x,y,z)}, aVetor, .T., 3)
			If lMsErroAuto
			    MostraErro()
			Else
				lProcOk := .T.
			Endif
		Endif	

	Endif
		
Enddo

If lProcOk
	MsgInfo("Processamento concluído.")
Else
	MsgAlert("Dados não importados.")
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  11/09/17	  ¦¦¦
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
