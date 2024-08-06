#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IMPSA2     ¦ Autor ¦ Fábrica ERPBR    ¦   Data ¦ 01/07/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação Fornecedores.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IMPSA2()

Local lOk  := .F.
Local lEnd := .F.
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private cTabl2   := Nil
Private oProcess, cArqCtb

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

	If MsgYesNo("Confirma o processamento - IMPORTAÇÃO DE FORNECEDORES ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importando Fornecedores", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  01/07/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nCountLi  := 0
Private cPath   := "\cfglog\logsa2.csv"
Private ENTER   := CHR(13)+CHR(10)
Private lFirst  := .T.
Private lLancOk := .T.

nHdlLog := fCreate(cPath)
If nHdlLog < 0
	MsgBox("Falha na criação do arquivo de log: "+AllTrim(cPath)+". Contate o Administrador.")
	Return
Endif

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(34000)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLi += 1
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
	// [01] - Filial
	// [02] - Codigo Anterior
	// [03] - Loja
	// [04] - Nome
	// [05] - NReduz
	// [06] - Endereço
	// [07] - Numero
	// [08] - Bairro
	// [09] - Estado
	// [10] - CodMun
	// [11] - Municipio
	// [12] - IBGE
	// [13] - CEP
	// [14] - Tipo
	// [15] - CGC
	// [16] - DDD
	// [17] - Telefone
	// [18] - Fax
	// [19] - Inscricao Estadual
	// [20] - Pais
	// [21] - Pais Descrição
	// [22] - Email
	// [23] - Tipo Pessoa

/*
A2_FILIAL;A2_ZZCODAN;A2_LOJA;A2_NOME;A2_NREDUZ;A2_END;A2_NR_END;A2_BAIRRO;A2_EST;A2_COD_MUN;A2_MUN;A2_IBGE;A2_CEP;A2_TIPO;A2_CGC;A2_DDD;A2_TEL;A2_FAX;A2_INSCR;A2_PAIS;A2_PAISDES;A2_EMAIL;A2_TPESSOA
*/

	If Len(aLinha) < 22
		MsgInfo("Linha "+AllTrim(STR(nCountLi))+": Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter pelo menos 22 posições.")
		lTudoOk := .F.
		lLancOk := .F.
		If MsgYesNo("Abandona a rotina ?","Aviso","INFO")
			Exit
		Else
			Loop
		Endif	
	Endif
	If Len(aLinha) == 22
		AAdd(aLinha,"")
	Endif
	
	If Len(aLinha) > 0

		zFilLan := aLinha[1]
		zIdFil  := zFilLan
		zCodAnt := aLinha[2]
		zLoja   := aLinha[3]
		zNome   := aLinha[4]
		zNReduz := aLinha[5]
		zEndere := aLinha[6]
		zNumero := aLinha[7]
		zBairro := aLinha[8]
		zEstado := aLinha[9]
		zCodMun := aLinha[10]
		zMun    := aLinha[11]
		zIbge   := aLinha[12]
		zCep    := aLinha[13]
		zTipo   := aLinha[14]
		zCgc    := aLinha[15]
		zDDD    := aLinha[16]
		zTel    := aLinha[17]
		zFax    := aLinha[18]
		zInscr  := aLinha[19]
		zPais   := "105" //aLinha[20]
		zPaisDe := aLinha[21]
		zEmail  := aLinha[22]
		zTPesso := aLinha[23]
		lTudoOk := .T.

		// Filial
		If zIdFil == "A2_FILIAL"
			Alert("Elimine o cabeçalho do arquivo.")
			lTudoOk := .F.
			lLancOk := .F.
		Endif

		DbSelectArea("SA2")
		DbSetOrder(3)
		If DbSeek( xFilial("SA2") + zCgc )
			_InputLog("JA CADASTRADO",zCgc,zIdFil)
			lTudoOk := .F.
			lLancOk := .F.
		Endif

		If lTudoOk

			zCodigo := GetSxeNum("SA2","A2_COD")
			ConfirmSX8()
			
			aVetor := { {"A2_COD"       , zCodigo          , Nil},;
						{"A2_LOJA"      , "01"             , Nil},;
						{"A2_NOME"      , zNome            , Nil},;
						{"A2_NREDUZ"    , zNReduz          , Nil},;
						{"A2_END"       , zEndere          , Nil},;
						{"A2_NR_END"    , zNumero          , Nil},;
						{"A2_BAIRRO"    , zBairro          , Nil},;
						{"A2_EST"       , zEstado          , Nil},;
						{"A2_COD_MUN"   , zCodMun          , Nil},;
						{"A2_MUN"       , zMun             , Nil},;
						{"A2_CEP"       , zCep             , Nil},;
						{"A2_TIPO"      , zTipo            , Nil},;
						{"A2_CGC"       , zCgc             , Nil},;
						{"A2_DDD"       , zDDD             , Nil},;
						{"A2_TEL"       , zTel             , Nil},;
						{"A2_FAX"       , zFax             , Nil},;
						{"A2_INSCR"     , zInscr           , Nil},;
						{"A2_PAIS"      , zPais            , Nil},;
						{"A2_PAISDES"   , zPaisDe          , Nil},;
						{"A2_EMAIL"     , zEmail           , Nil},;
						{"A2_TPESSOA"   , zTPesso          , Nil},;
						{"A2_MSBLQL"    , "2"              , Nil},;
						{"A2_CALCIRF"   , "1"              , Nil},;
						{"A2_ZZCODAN"   , zCodAnt          , Nil} }

			lMsErroAuto := .F.
			MsExecAuto({|x,y| MATA020(x,y)},aVetor,3)
			If lMsErroAuto
				MostraErro()
			Endif

		Endif	

	Endif
		
Enddo

If !lLancOk
	fClose(nHdlLog)
	Alert("A importação foi concluída parcialmente. Verifique o arquivo de Log.")
Endif

fClose(nHdlLog)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  10/04/17	  ¦¦¦
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
Local cBuffer    := Space(nBytesRead) // Guarda o conteudo lido
Local nPosition  := 0 // Posicao do caracter 13 (return)
Local nIncbytes  := Nil // Incremento de bytes 2 CHR(13) + CHR(10)
Local xReturn    := Nil // Retorno da funcao

If ( ((FREAD(nHandle,@cBuffer,nBytesRead) = nBytesRead) .Or. (!Empty(cBuffer))) )
	// Verifica se procura o caracter 13 para identificar o registro
	xReturn := Substr(cBuffer,1,IIf(((nPosition := AT(CHR(13),cBuffer)) > 0),(nPosition - 1),Len(cBuffer)))
	// Verifica se incrementa bytes
	nIncbytes := IIf(nPosition > 0,2,0)
	// Bytes ja lidos somando os caracteres especiais
	nBytes := (nBytes + (Len(xReturn) + nIncbytes))
	// Retorna o descritor se necessario
	FSEEK(nHandle,(-1 * ABS((Len(cBuffer) - (Len(xReturn) + nIncbytes)))),1)
Endif

Return(xReturn)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  10/04/17	  ¦¦¦
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
¦¦¦Função    ¦ _InputLog ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 10/07/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Grava log de ocorrências.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _InputLog(zPos1,zPos2,zPos3)

cTexto := AllTrim(zPos1)+";"+AllTrim(zPos2)+";"+AllTrim(zPos3)+";"+""+ENTER
fWrite(nHdlLog,cTexto)

Return
