#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CSVA5A7  � Autor � F�brica ERPBR    � Data  �  16/10/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Importa��o cliente x fornecedor x produto via arquivo Csv. ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
���Altera��es� Projeto Importador de Xml - 07/12/2021                     ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CSVA5A7()

Local lOk        := .F.
Local lImpXml    := GetMv("MV_IMPXML")
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

If !lImpXml
	MsgInfo("Importador de Xml n�o habilitado (MV_IMPXML).")
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

	If MsgYesNo("Confirma o processamento da atualiza��o 'Produto x Cliente x Fornecedor' ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp(cArquivo) }, "Incluindo dados", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data � 16/10/2021  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da importa��o.								  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp(cArquivo)

Local cEOL   := CHR(13)+CHR(10)
Local _aTmp  := {}
Local zAlias := "LOG"
Private nCountLin := 0

oTempTable := FWTemporaryTable():New( zAlias )
AAdd ( _aTmp, {"LOG_LIN" , "C", 006, 00} )
AAdd ( _aTmp, {"LOG_TIP" , "C", 001, 00} )
AAdd ( _aTmp, {"LOG_COD" , "C", 006, 00} )
AAdd ( _aTmp, {"LOG_PRE" , "C", 015, 00} )
AAdd ( _aTmp, {"LOG_PRI" , "C", 015, 00} )
AAdd ( _aTmp, {"LOG_OKP" , "C", 001, 00} )
AAdd ( _aTmp, {"LOG_OBS" , "C", 200, 00} )
oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"LOG_LIN"})
oTempTable:Create()

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
	// [01] - C=Cliente | F=Fornecedor
	// [02] - C�digo (cliente ou fornecedor)
	// [03] - Produto externo
	// [04] - Produto Protheus

	If Len(aLinha) <> 4
		MsgInfo("Aten��o..., Estrutura do arquivo CSV inv�lida ("+AllTrim(STR(Len(aLinha)))+" posi��es)."+cEOL+"O layout deve conter 4 posi��es.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zTipReg := aLinha[1]
		zCodigo := aLinha[2]
		zPrdExt := aLinha[3]
		zPrdInt := PadR(aLinha[4],15)

		If !(zTipReg $("C,F"))
			zLog := "Tipo do registro inv�lido (C ou F): "+zTipReg
			InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "N", zLog)
			Loop
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zPrdInt )
			zLog := "Produto "+AllTrim(zPrdInt)+" n�o cadastrado"
			InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "N", zLog)
			Loop
		Endif

		If zTipReg == "C"

			DbSelectArea("SA1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SA1") + zCodigo + "01" )
				zLog := "Cliente "+AllTrim(zCodigo)+" n�o cadastrado"
				InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "N", zLog)
				Loop
			Endif

			zPrdExt := PadR(zPrdExt,TamSx3("A7_CODCLI")[1]) // A7_CODCLI | C | 020
			DbSelectArea("SA7")
			DbSetOrder(3) // A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_CODCLI
			If DbSeek( xFilial("SA7") + zCodigo + "01" + zPrdExt )
				zLog := "Cliente "+AllTrim(zCodigo)+" x Produto "+AllTrim(zPrdExt)+" j� associado com o c�digo "+AllTrim(SA7->A7_PRODUTO)
				InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "N", zLog)
				Loop
			Endif

			RecLock("SA7",.T.)
			SA7->A7_FILIAL  := xFilial("SA7")
			SA7->A7_CLIENTE := zCodigo
			SA7->A7_LOJA    := "01"
			SA7->A7_PRODUTO := SB1->B1_COD
			SA7->A7_CODCLI  := zPrdExt
			SA7->A7_UMNFE   := "1"
			MsUnLock()

			zLog := "Ok"
			InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "S", zLog)

		Else

			DbSelectArea("SA2")
			DbSetOrder(1)
			If !DbSeek( xFilial("SA2") + zCodigo )
				zLog := "Fornecedor "+AllTrim(zCodigo)+" n�o cadastrado"
				InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "N", zLog)
				Loop
			Endif

			zPrdExt := PadR(zPrdExt,TamSx3("A5_CODPRF")[1]) // A5_CODPRF | C | 020
			DbSelectArea("SA5")
			DbSetOrder(13) //A5_FILIAL + A5_CODPRF + A5_REFGRD + A5_FABR + A5_FORNECE
			If DbSeek( xFilial("SA5") + zPrdExt + Space(26) + Space(6) + zCodigo )
				zLog := "Fornecedor "+AllTrim(zCodigo)+" x Produto "+AllTrim(zPrdExt)+" j� associado com o c�digo "+AllTrim(SA5->A5_PRODUTO)
				InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "N", zLog)
				Loop
			Endif

			RecLock("SA5",.T.)
			SA5->A5_FILIAL  := xFilial("SA5")
			SA5->A5_FORNECE := zCodigo
			SA5->A5_LOJA    := SA2->A2_LOJA
			SA5->A5_NOMEFOR := SA2->A2_NOME
			SA5->A5_PRODUTO := SB1->B1_COD
			SA5->A5_NOMPROD := SB1->B1_DESC
			SA5->A5_CODPRF  := zPrdExt
			SA5->A5_UMNFE   := "1"
			MsUnLock()

			zLog := "Ok"
			InputLog(nCountLin, zTipReg, zCodigo, zPrdExt, zPrdInt, "S", zLog)

		Endif

	Endif	
		
Enddo

// ************************** //
// ** Log de processamento ** //
// ************************** //
u_LogA5A7()

DbSelectArea("LOG")
LOG->(DbCloseArea())
oTempTable:Delete()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fReadFile � Autor � Fabrica ERPBR � 	  Data �  16/10/2021  ���
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
���Programa  � fFileSize � Autor � Fabrica ERPBR � 	  Data �  16/10/2021  ���
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

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � InputLog  � Autor � F�brica ERPBR    � Data  � 20/02/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Insere registro no log.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function InputLog(logLin, logTip, logCod, logExt, logInt, logOkp, logObs)

DbSelectArea("LOG")
RecLock("LOG",.T.)
LOG->LOG_LIN := AllTrim(STR(logLin))
LOG->LOG_TIP := logTip
LOG->LOG_COD := logCod
LOG->LOG_PRE := logExt
LOG->LOG_PRI := logInt
LOG->LOG_OKP := logOkp
LOG->LOG_OBS := logObs
MsUnLock()

Return


/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � LogA5A7 � Autor � F�brica ERP.BR      � Data  � 16/10/2021 ���
��+----------+------------------------------------------------------------���
���Descricao � Log de processamento.							 		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function LogA5A7()

Local oReport

oReport := ReportDef()

If oReport == Nil
	Return
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportDef � Autor �  Luis Brandini   � Data  � 16/10/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef()

Local oReport
Local oSection1

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("LOGPROC","Log de processamento", , {|oReport| ReportPrint(oReport), "Este relat�rio ir� imprimir as ocorr�ncias de processamento."})

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1 := TRSection():New(oReport,"Log de processamento",{"LOG"},,.F.,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oSection1, "LIN", "LOG", "Linha"      , "@!" , 010, , { || LOG->LOG_LIN } )
TRCell():New(oSection1, "TIP", "LOG", "Tipo"       , "@!" , 005, , { || LOG->LOG_TIP } )
TRCell():New(oSection1, "COD", "LOG", "C�digo"     , "@!" , 010, , { || LOG->LOG_COD } )
TRCell():New(oSection1, "PRE", "LOG", "Pr.Externo" , "@!" , 030, , { || LOG->LOG_PRE } )
TRCell():New(oSection1, "PRI", "LOG", "Produto"    , "@!" , 030, , { || LOG->LOG_PRI } )
TRCell():New(oSection1, "OKP", "LOG", "Ok"         , "@!" , 005, , { || LOG->LOG_OKP } )
TRCell():New(oSection1, "OBS", "LOG", "Ocorr�ncia" , "@!" , 200, , { || LOG->LOG_OBS } )

Return(oReport)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportPrint � Autor � Luis Brandini  � Data  � 16/10/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Log de processamento"
oReport:cTitle := "Log de processamento"

DbSelectArea("LOG")
LOG->(DbGotop())
oReport:SetMeter(LOG->(RecCount()))
oSection1:Init()
While !Eof()
	oReport:IncMeter()
	oSection1:PrintLine()
	LOG->(DbSkip())
	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif
Enddo

Return
