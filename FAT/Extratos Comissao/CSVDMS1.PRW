#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CSVDMS1   � Autor � F�brica ERPBR    � Data  � 01/12/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Atualiza��o do v�nculo Vendedor x DM.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CSVDMS1()

Local lOk        := .F.
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private cUsrAut  := "000163"
Private oProcess

If !(__cUserId $ cUsrAut)
	MsgAlert("Usu�rio n�o autorizado a executar essa rotina.")
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

	If MsgYesNo("Confirma o processamento - ATUALIZA��O VENDEDOR X DM ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Atualizando V�nculo DM", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data � 20/07/2022  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da importa��o.								  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local lProcOk   := .F.
Local lProcEr   := .F.

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando arquivo csv..")

	// Fim de Arquivo
	If Len(cString) < 4
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
	// [01] - Vendedor
	// [02] - DM

	If Len(aLinha) <> 2
		MsgInfo("Aten��o..., Estrutura do arquivo CSV inv�lida ("+AllTrim(STR(Len(aLinha)))+" posi��es)."+cEOL+"O layout deve conter 2 posi��es.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zVend := aLinha[1]
		zDM   := aLinha[2]

		DbSelectArea("SA3")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA3") + zDM )
			lProcEr := .T.
			MsgInfo("DM n�o localizado: "+zDM)
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		DbSelectArea("SA3")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA3") + zVend )
			lProcEr := .T.
			MsgInfo("Vendedor n�o localizado: "+zVend)
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		lProcOk := .T.

		RecLock("SA3",.F.)
		SA3->A3_ZZDM := zDM
		MsUnLock()

	Endif
		
Enddo

If lProcOk
	If !lProcEr
		MsgInfo("Processamento conclu�do com sucesso para todos os registros do arquivo.")
	Else
		MsgInfo("Processamento conclu�do parcialmente. Analise os registros n�o processados.")
	Endif	
Else
	MsgAlert("Processamento n�o executado.")
Endif
	
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fReadFile � Autor � Fabrica ERPBR � 	  Data �  01/12/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Efetua leitura do arquivo e retorna conteudo da linhaa.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
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
���Programa  � fFileSize � Autor � Fabrica ERPBR � 	  Data �  01/12/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Obtem o tamanho do arquivo texto.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)

