#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IMPSA1S    ¦ Autor ¦ Fábrica ERPBR    ¦   Data ¦ 01/07/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação Clientes - Layout SA1.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IMPSA1S()

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

	If MsgYesNo("Confirma o processamento - IMPORTAÇÃO DE CLIENTES ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importando Clientes", "Aguarde, processando ...", .F. )
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
Private cPath   := "\cfglog\logsa1.csv"
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
	// [02] - Bloqueado
	// [03] - Codigo Anterior
	// [04] - Loja
	// [05] - Pessoa
	// [06] - Nome
	// [07] - NReduz
	// [08] - Endereço
	// [09] - Bairro
	// [10] - CodMun
	// [11] - Municipio
	// [12] - Estado
	// [13] - CEP
	// [14] - DDD
	// [15] - Telefone
	// [16] - Fax
	// [17] - End.Cobrança
	// [18] - Bairro Cobrança
	// [19] - Mun.Cobrança
	// [20] - Est.Cobrança
	// [21] - Cep.Cobrança
	// [22] - Email
	// [23] - Cód.Pais
	// [24] - Pais Descrição
	// [25] - CGC
	// [26] - Inscricao Estadual

/*
A1_FILIAL;A1_MSBLQL;A1_ZZCODAN;A1_LOJA;A1_PESSOA;A1_NOME;A1_NREDUZ;A1_END;A1_BAIRRO;A1_COD_MUN;A1_MUN;A1_EST;A1_CEP;A1_DDD;A1_TEL;A1_FAX;A1_ENDCOB;A1_BAIRROC;A1_MUNC;A1_ESTC;A1_CEPC;A1_EMAIL;A1_CODPAIS;A1_PAISDES;A1_CGC;A1_INSCR
01;1;10011975;01;F;JAIRO APARECIDO YAMAMOTO;JAIRO APARECIDO YAMA;COND GRAMADO ARAUCARIA, 33372;CHAPADA NOVO MUNDO;09502;CAMPINAS;SP;13000000;089;35448002;;COND GRAMADO ARAUCARIA, 33372;CHAPADA NOVO MUNDO;CAMPINAS;SP;13000000;faboespi@gmail.com;01058;BRASIL;02924091845; 
*/

	If Len(aLinha) < 25
		MsgInfo("Linha "+AllTrim(STR(nCountLi))+": Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter pelo menos 25 posições.")
		lTudoOk := .F.
		lLancOk := .F.
		If MsgYesNo("Abandona a rotina ?","Aviso","INFO")
			Exit
		Else
			Loop
		Endif	
	Endif
	If Len(aLinha) == 25
		AAdd(aLinha,"")
	Endif
	
	If Len(aLinha) > 0

		zFilLan := Space(4)
		zIdFil  := zFilLan
		zCodAnt := aLinha[3]
		zLoja   := aLinha[4]
		zNome   := aLinha[6]
		zNReduz := aLinha[7]
		zEndere := aLinha[8]
		zBairro := aLinha[9]
		zCodMun := aLinha[10]
		zMun    := aLinha[11]
		zEstado := aLinha[12]
		zCep    := aLinha[13]
		zDDD    := aLinha[14]
		zTel    := aLinha[15]
		zFax    := aLinha[16]
		zEmail  := aLinha[22]
		zPais   := aLinha[23]
		zPaisDe := aLinha[24]
		zCgc    := aLinha[25]
		zCgc    := PadR(zCgc,14)
		zInscr  := aLinha[26]
		lTudoOk := .T.

		// Filial
		If Substr(zIdFil,3) == "_FILIAL"
			Alert("Elimine o cabeçalho do arquivo.")
			lTudoOk := .F.
			lLancOk := .F.
		Endif

		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek( xFilial("SA1") + zCgc )
			_InputLog("JA CADASTRADO",zCgc,zIdFil)
			lTudoOk := .F.
			lLancOk := .F.
		Endif

		If lTudoOk

			zCodigo := GetSxeNum("SA1","A1_COD")
			ConfirmSX8()
			
			aVetor := { {"A1_COD"       , zCodigo          , Nil},;
						{"A1_LOJA"      , "01"             , Nil},;
						{"A1_NOME"      , zNome            , Nil},;
						{"A1_PESSOA"    , IIf(Len(AllTrim(zCgc))>11,"J","F") , Nil},;
						{"A1_END"       , zEndere          , Nil},;
						{"A1_ZZGECON"   , zNReduz          , Nil},;
						{"A1_TIPO"      , "F"              , Nil},;
						{"A1_NREDUZ"    , zNReduz          , Nil},;
						{"A1_BAIRRO"    , zBairro          , Nil},;
						{"A1_EST"       , zEstado          , Nil},;
						{"A1_COD_MUN"   , zCodMun          , Nil},;
						{"A1_MUN"       , zMun             , Nil},;
						{"A1_CEP"       , zCep             , Nil},;
						{"A1_CGC"       , zCgc             , Nil},;
						{"A1_DDD"       , zDDD             , Nil},;
						{"A1_TEL"       , zTel             , Nil},;
						{"A1_FAX"       , zFax             , Nil},;
						{"A1_INSCR"     , zInscr           , Nil},;
						{"A1_CODPAIS"   , zPais            , Nil},;
						{"A1_PAIS"      , "105"            , Nil},;
						{"A1_PAISDES"   , "BRASIL"         , Nil},;
						{"A1_EMAIL"     , zEmail           , Nil},;
						{"A1_MSBLQL"    , "2"              , Nil},;
						{"A1_ZZCODAN"   , zCodAnt          , Nil} }

			lMsErroAuto := .F.
			MsExecAuto({|x,y| MATA030(x,y)},aVetor,3)
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
