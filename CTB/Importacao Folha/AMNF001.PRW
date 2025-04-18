#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNF001   � Autor � F�brica ERPBR    �   Data  � 04/02/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Importa��o de dados referente de-para a partir de arquivo  ���
���          � extens�o csv com layout pr�-definido.			  		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNF001()

Local lOk   := .F.
Local lEnd	:= .F.
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.F.)
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private cTable   := Nil
Private cTabl2   := Nil
Private oDlgUpd, oProcess
Private oTempTabl1
Private oTempTabl2

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Importa��o de Dados | De-Para" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,060,{||"DE-PARA IMPORTA��O CONT�BIL FOLHA DE PAGAMENTO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo fazer a importa��o de dados cadastrais de-para,"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"de acordo com arquivo extens�o 'csv' e layout definido."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

@ 150,170 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()    OF oDlgUpd PIXEL
@ 150,250 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End() OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � Preparar  � Autor � Fabrica ERPBR    � Data �  04/02/17	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Prepara o processamento principal.						  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Preparar()

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

    If Select("TRB") > 0
    	TRB->(DbCloseArea())
    Endif

    If Select("LOG") > 0
    	LOG->(DbCloseArea())
    Endif

	_CriaTrab()
	
	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	If MsgYesNo("Confirma o processamento - DE-PARA IMPORTA��O DE DADOS ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importando dados cadastrais", "Aguarde, processando ...", .F. )
		oProcess:Activate()
		oDlgUpd:End()
	Endif

	fClose(nHandle)

	TRB->(DbCloseArea())
	oTempTabl1:Delete()
	
	LOG->(DbCloseArea())
	oTempTabl2:Delete()
	
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data �  04/02/17	  ���
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

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(160)
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
	// [01] - Verba
	// [02] - Tipo
	// [03] - ADM �rea
	// [04] - ADM D�bito
	// [05] - ADM Cr�dito
	// [06] - Brancos
	// [07] - FABRICA �rea
	// [08] - FABRICA D�bito
	// [09] - FABRICA Cr�dito
	// [10] - Brancos
	// [11] - LOG�STICA �rea
	// [12] - LOG�STICA D�bito
	// [13] - LOG�STICA Cr�dito
	// [14] - Brancos
	// [15] - VENDAS �rea
	// [16] - VENDAS D�bito
	// [17] - VENDAS Cr�dito
	// [18] - Descri��o
	// [19] - Classifica��o

	If Len(aLinha) != 19
		MsgInfo("Aten��o..., Estrutura do arquivo CSV inv�lida ("+AllTrim(STR(Len(aLinha)))+" posi��es)."+cEOL+"O layout deve conter 19 posi��es.")
		Return
	Endif
	
	If Len(aLinha) > 0

		cVerba  := PadR(aLinha[1],6)
		cTipoV  := aLinha[2]
		//
		cAdmAre := Substr(aLinha[3],1,1)
		cAdmDeb := aLinha[4]
		cAdmCrd := aLinha[5]
		// Posi��o 6 em branco
		cFabAre := Substr(aLinha[7],1,1)
		cFabDeb := aLinha[8]
		cFabCrd := aLinha[9]
		// Posi��o 10 em branco
		cLogAre := Substr(aLinha[11],1,1)
		cLogDeb := aLinha[12]
		cLogCrd := aLinha[13]
		// Posi��o 14 em branco
		cVenAre := Substr(aLinha[15],1,1)
		cVenDeb := aLinha[16]
		cVenCrd := aLinha[17]
		//
		cDescri := aLinha[18]
		cClassf := aLinha[19]
		//
		lTudoOk := .T.

		If Empty(cVerba)  .Or. Empty(cTipoV)  .Or.;
		   Empty(cAdmAre) .Or. Empty(cAdmDeb) .Or. Empty(cAdmCrd) .Or.;
		   Empty(cFabAre) .Or. Empty(cFabDeb) .Or. Empty(cFabCrd) .Or.;
		   Empty(cLogAre) .Or. Empty(cLogDeb) .Or. Empty(cLogCrd) .Or.;
		   Empty(cVenAre) .Or. Empty(cVenDeb) .Or. Empty(cVenCrd) .Or.;
		   Empty(cDescri) .Or. Empty(cClassf)
			InputLog("Inconsist�ncia na linha "+AllTrim(STR(nCountLin))+".")
			lTudoOk := .F.
		Endif

		DbSelectArea("TRB")
		DbSetOrder(1)
		If DbSeek( cVerba )
			InputLog("Verba duplicada no arquivo: "+AllTrim(cVerba)+".")
			lTudoOk := .F.
		Endif
		
		If lTudoOk
			InputLin(cVerba,cTipoV,cAdmAre,cAdmDeb,cAdmCrd,cFabAre,cFabDeb,cFabCrd,cLogAre,cLogDeb,cLogCrd,cVenAre,cVenDeb,cVenCrd,cDescri,cClassf)
		Endif

	Endif
		
Enddo

DbSelectArea("LOG")
If LOG->(RecCount()) > 0
	MsgInfo("Foram encontradas inconsist�ncias no arquivo 'csv'.")
	u_Rep001(cArquivo)
	Return
Endif

// Atualiza��o dos dados cadastrais de-para
DbSelectArea("TRB")
TRB->(DbGotop())
If !Eof()

	lTudoOk := .T.
	DbSelectArea("SZ9")
	SZ9->(DbGotop())
	If SZ9->(RecCount()) > 0
		If !MsgYesNo("Existem dados De-Para j� cadastrados."+cEOL+"Confirma atualiza��o dos dados ?","Aten��o","INFO")
			InputLog("Dados n�o importados/atualizados conforme a��o do usu�rio.")
			lTudoOk := .F.
		Endif
	Endif

	If lTudoOk
		DbSelectArea("TRB")
		DbSetOrder(1)
		oProcess:SetRegua2( TRB->(RecCount()) )
		TRB->(DbGotop())
		While !Eof()
		
			oProcess:IncRegua2("Atualizando dados De-Para..")
		
	    	DbSelectArea("SZ9")
	    	DbSetOrder(1)
	    	If !DbSeek( xFilial("SZ9") + TRB->TF_VERBA + TRB->TF_AREA )
	    		RecLock("SZ9",.T.)
	    		SZ9->Z9_FILIAL := xFilial("SZ9")
				SZ9->Z9_VERBA  := TRB->TF_VERBA
	    		SZ9->Z9_AREA   := TRB->TF_AREA
	    	Else
	    		RecLock("SZ9",.F.)
	    	Endif
	   		SZ9->Z9_TIPO   := TRB->TF_TIPO
	   		SZ9->Z9_DEBITO := TRB->TF_DEBITO
	   		SZ9->Z9_CREDIT := TRB->TF_CREDIT
	   		SZ9->Z9_DESCRI := TRB->TF_DESCRI
	   		SZ9->Z9_CLASSF := TRB->TF_CLASSF
	    	MsUnLock()
	
			DbSelectArea("TRB")
			TRB->(DbSkip())
		Enddo
	Endif	

Endif

u_Rep001(cArquivo)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � _CriaTrab � Autor � F�brica ERPBR    �    Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Cria arquivos temporarios.							   	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function _CriaTrab()

Local _aTmp   := {}
Local _aTm2   := {}
Local zAlias1 := "LOG"
Local zAlias2 := "TRB"

oTempTabl1 := FWTemporaryTable():New( zAlias1 )
AAdd ( _aTmp, {"LOG_LINLOG" , "C", 004, 00} )
AAdd ( _aTmp, {"LOG_OBSERV" , "C", 200, 00} )
oTemptabl1:SetFields( _aTmp )
oTempTabl1:AddIndex("indice1", {"LOG_LINLOG"})
oTempTabl1:Create()

oTempTabl2 := FWTemporaryTable():New( zAlias2 )
AAdd ( _aTm2, {"TF_VERBA"  , "C", 006, 00} )
AAdd ( _aTm2, {"TF_TIPO"   , "C", 100, 00} )
AAdd ( _aTm2, {"TF_AREA"   , "C", 001, 00} )
AAdd ( _aTm2, {"TF_DEBITO" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_CREDIT" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_DESCRI" , "C", 100, 00} )
AAdd ( _aTm2, {"TF_CLASSF" , "C", 100, 00} )
oTemptabl2:SetFields( _aTm2 )
oTempTabl2:AddIndex("indice1", {"TF_VERBA"})
oTempTabl2:Create()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � InputLog  � Autor � F�brica ERPBR    �    Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Insere registro invalido no arquivo de log.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function InputLog(xObserv)

cLinLog := StrZero((LOG->(RecCount())+1),4)

RecLock("LOG",.T.)
LOG->LOG_LINLOG := cLinLog
LOG->LOG_OBSERV := xObserv
MsUnLock()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � InputLin  � Autor � F�brica ERPBR    �    Data  � 04/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Insere registro valido.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function InputLin(cVerba,cTipoV,cAdmAre,cAdmDeb,cAdmCrd,cFabAre,cFabDeb,cFabCrd,cLogAre,cLogDeb,cLogCrd,cVenAre,cVenDeb,cVenCrd,cDescri,cClassf)

DbSelectArea("TRB")
// Adm
RecLock("TRB",.T.)
TRB->TF_VERBA  := cVerba
TRB->TF_TIPO   := cTipoV
TRB->TF_AREA   := cAdmAre
TRB->TF_DEBITO := cAdmDeb
TRB->TF_CREDIT := cAdmCrd
TRB->TF_DESCRI := cDescri
TRB->TF_CLASSF := cClassf
MsUnLock()
// Fabrica
RecLock("TRB",.T.)
TRB->TF_VERBA  := cVerba
TRB->TF_TIPO   := cTipoV
TRB->TF_AREA   := cFabAre
TRB->TF_DEBITO := cFabDeb
TRB->TF_CREDIT := cFabCrd
TRB->TF_DESCRI := cDescri
TRB->TF_CLASSF := cClassf
MsUnLock()
// Log�stica
RecLock("TRB",.T.)
TRB->TF_VERBA  := cVerba
TRB->TF_TIPO   := cTipoV
TRB->TF_AREA   := cLogAre
TRB->TF_DEBITO := cLogDeb
TRB->TF_CREDIT := cLogCrd
TRB->TF_DESCRI := cDescri
TRB->TF_CLASSF := cClassf
MsUnLock()
// Vendas
RecLock("TRB",.T.)
TRB->TF_VERBA  := cVerba
TRB->TF_TIPO   := cTipoV
TRB->TF_AREA   := cVenAre
TRB->TF_DEBITO := cVenDeb
TRB->TF_CREDIT := cVenCrd
TRB->TF_DESCRI := cDescri
TRB->TF_CLASSF := cClassf
MsUnLock()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fReadFile � Autor � Fabrica ERPBR � 	  Data �  04/02/17	  ���
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
���Programa  � fFileSize � Autor � Fabrica ERPBR � 	  Data �  04/02/17	  ���
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
���Programa  � Rep001  � Autor � F�brica ERPBR   �   Data  � 	04/02/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Impress�o do log de ocorr�ncias.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function Rep001(cArquivo)

Local oReport

oReport := ReportDef(cArquivo)

If oReport == Nil
	Return
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportDef � Autor �  Luis Brandini   �   Data  � 04/02/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef(cArquivo)

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
oReport := TReport():New("AMNF001","Ocorr�ncias do Arquivo CSV", , {|oReport| ReportPrint(oReport,cArquivo), "Este relat�rio ir� imprimir as ocorr�ncias da importa��o do arquivo CSV de-para cadastro importa��o folha."})

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
oSection1 := TRSection():New(oReport,"Ocorr�ncias do Arquivo CSV",{"LOG"},,.F.,.F.)

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
TRCell():New(oSection1, "LINLOG", "LOG", "Linha"      , "@!" , 010, , { || LOG->LOG_LINLOG } )
TRCell():New(oSection1, "OBSERV", "LOG", "Ocorr�ncia" , "@!" , 200, , { || LOG->LOG_OBSERV } )

Return(oReport)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportPrint � Autor � Luis Brandini  �   Data  � 04/02/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportPrint(oReport,cArquivo)

Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Log de ocorr�ncias da importa��o csv | De-Para Importa��o Folha | Arquivo "+cArquivo+"|"
oReport:cTitle := "Log de ocorr�ncias da importa��o csv | De-Para Importa��o Folha | Arquivo "+cArquivo+"|"

DbSelectArea("LOG")
LOG->(DbGotop())
If Eof()
	RecLock("LOG",.T.)
	LOG->LOG_LINLOG := "0001"
	LOG->LOG_OBSERV := "Arquivo "+cArquivo+" importado com sucesso, sem ocorr�ncia de erros."
	MsUnLock()
Endif

DbSelectArea("LOG")
LOG->(DbGotop())
oReport:SetMeter(LOG->(RecCount()))
oSection1:Init()
While !Eof()

	oReport:IncMeter()

	oSection1:PrintLine()

	DbSelectArea("LOG")
	LOG->(DbSkip())

	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif

	DbSelectArea("LOG")
Enddo

Return
