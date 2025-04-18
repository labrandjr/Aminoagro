#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CSVBENS   � Autor � F�brica ERPBR    � Data  � 20/10/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Atualiza��o de dados no cadastro de bens.				  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CSVBENS()

Local lOk  := .F.
Local lEnd := .F.
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
		MsgAlert("Arquivo n�o encontrado.")
	Endif
Else
	MsgAlert("Arquivo n�o selecionado.")
Endif

If lOkFile

	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	If MsgYesNo("Confirma o processamento - CADASTRO DE BENS ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Atualizando bens", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data �  20/10/2020 ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da importa��o.								  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local lProcOk   := .F.

DbSelectArea("ST9")
aStruct := ST9->(DbStruct())

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
			AAdd(aLinha,Substr(cTxtLin,1,Len(cTxtLin)))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	// Estrutura de aLinha:
	// [01] - Filial
	// [02] - C�digo do Bem (plaqueta)
	// [03] - Descri��o
	// [04] - Modelo
	// [05] - Fam�lia
	// [06] - C.Custo
	// [07] - Localiza��o
	// [08] - Data da instala��o

	If Len(aLinha) <> 8
		MsgInfo("Aten��o..., Estrutura do arquivo CSV inv�lida ("+AllTrim(STR(Len(aLinha)))+" posi��es)."+cEOL+"O layout deve conter 8 posi��es.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := AllTrim(aLinha[1])
		zCodigo := PadR(AllTrim(aLinha[2]),16)
		zDescri := AllTrim(aLinha[3])
		zModelo := Upper(PadR(AllTrim(aLinha[4]),10))
		zFamili := PadR(AllTrim(aLinha[5]),6)
		zCCusto := PadR(AllTrim(aLinha[6]),12)
		zLocali := AllTrim(aLinha[7])
		zDtInst := CtoD(AllTrim(aLinha[8]))
		lTudoOk := .T.

		cFilAnt := zFilial

		DbSelectArea("TQR")
		DbSetOrder(1)
		If !DbSeek( xFilial("TQR") + zModelo )
			lTudoOk := .F.
			MsgInfo("Modelo n�o cadastrado: "+AllTrim(zModelo))
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		DbSelectArea("ST6")
		DbSetOrder(1)
		If !DbSeek( xFilial("ST6") + zFamili )
			lTudoOk := .F.
			MsgInfo("Fam�lia n�o cadastrada: "+AllTrim(zFamili))
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		DbSelectArea("CTT")
		DbSetOrder(1)
		If !DbSeek( xFilial("CTT") + zCCusto )
			lTudoOk := .F.
			MsgInfo("C.Custo n�o cadastrado: "+AllTrim(zFamili))
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		If lTudoOk

			DbSelectArea("ST9")
			DbSetOrder(1)
			If !DbSeek( zFilial + zCodigo )

				aCopia  := {}
				
				// Bem refer�ncia
				DbSelectArea("ST9")
				DbSetOrder(1)
				If !DbSeek( "0102" + PadR("AF0116",16) )
					MsgAlert("Bem refer�ncia n�o localizado: 'AF0116'.")
					Loop
				Endif
	
				For _xCampo := 1 to ( Len(aStruct) )
					_xConteudo := &("ST9->"+aStruct[_xCampo][1])
					If aStruct[_xCampo][1] == "T9_FILIAL"
						_xConteudo := zFilial
					ElseIf aStruct[_xCampo][1] == "T9_CODBEM"
						_xConteudo := zCodigo
					ElseIf aStruct[_xCampo][1] == "T9_TIPMOD"
						_xConteudo := zModelo
					ElseIf aStruct[_xCampo][1] == "T9_CODFAMI"
						_xConteudo := zFamili
					ElseIf aStruct[_xCampo][1] == "T9_NOME"
						_xConteudo := zDescri
					ElseIf aStruct[_xCampo][1] == "T9_MODELO"
						_xConteudo := zModelo
					ElseIf aStruct[_xCampo][1] == "T9_CHAPA"
						_xConteudo := zCodigo
					ElseIf aStruct[_xCampo][1] == "T9_CCUSTO"
						_xConteudo := zCCusto
					ElseIf aStruct[_xCampo][1] == "T9_LOCAL"
						_xConteudo := zLocali
					ElseIf aStruct[_xCampo][1] == "T9_DTCOMPR"
						_xConteudo := zDtInst
					ElseIf aStruct[_xCampo][1] == "T9_DTINSTA"
						_xConteudo := zDtInst
					Endif	
					AAdd(aCopia,{aStruct[_xCampo][1],_xConteudo})
				Next _xCampo

				RecLock("ST9",.T.)
				For _xCampo := 1 to ( Len(aCopia) )
					&("ST9->"+aCopia[_xCampo,1]) := aCopia[_xCampo,2]
				Next _xCampo
				MsUnLock()

			Else

				RecLock("ST9",.F.)
				ST9->T9_TIPMOD  := zModelo
				ST9->T9_CODFAMI := zFamili
				ST9->T9_NOME    := zDescri
				ST9->T9_MODELO  := zModelo
				ST9->T9_CHAPA   := zCodigo
				ST9->T9_CCUSTO  := zCCusto
				ST9->T9_LOCAL   := zLocali
				ST9->T9_DTINSTA := zDtInst
				ST9->T9_DTCOMPR := zDtInst
				MsUnLock()

			Endif

			lProcOk := .T.

		Endif	

	Endif
		
Enddo

If lProcOk
	MsgInfo("Processamento conclu�do.")
Else
	MsgAlert("Dados n�o importados.")
Endif
	
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fReadFile � Autor � Fabrica ERPBR � 	  Data �  20/10/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Efetua leitura do arquivo e retorna conteudo da linhaa.	  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fFileSize � Autor � Fabrica ERPBR � 	  Data �  20/10/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Obtem o tamanho do arquivo texto.						  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)
