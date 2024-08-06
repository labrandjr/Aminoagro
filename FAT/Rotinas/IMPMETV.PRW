#include "protheus.ch"
#include "fwmvcdef.ch"

#define LOGNONE 	0
#define LOGERROR 	1
#define LOGWARN 	2
#define LOGINFO 	3
#define LOGDEBUG 	4

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IMPMETV   ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 05/09/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação das Metas de Vendas.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IMPMETV()

Local lOk        := .F.
Local lEnd	     := .F.
Local cType      := "Arquivos CSV|*.CSV|"
Local cTitulo1   := "Selecione o arquivo a importar"
Local nMascara   := GETF_LOCALFLOPPY+GETF_LOCALHARD
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

cArquivo := cGetFile(cType,cTitulo1,0,,.T.,nMascara)
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

	If MsgYesNo("Confirma o processamento - IMPORTAÇÃO METAS DE VENDAS ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importando Metas de Vendas", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  05/09/18	  ¦¦¦
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
Local nCountInc := 0
Local nCountAlt := 0

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
	// [01] - Documento
	// [02] - Descrição
	// [03] - Data
	// [04] - Vendedor
	// [05] - Valor

	If Len(aLinha) < 5
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+;
				"O layout deve conter 5 posições:"+cEOL+;
				"Documento ; Descrição ; Data (dd/mm/aaaa) ; Vendedor ; Valor")
		Return
	Endif
	
	If Len(aLinha) > 0

		zDocum  := PadR(aLinha[1],9)
		zDescr  := aLinha[2]
		zData   := CtoD(aLinha[3])
		zVend   := PadR(aLinha[4],6)
		zValor  := aLinha[5]
		zValor  := StrTran(zValor,".","")
		zValor  := Val(StrTran(zValor,",","."))
		lInclui := .F.
		lAltera := .F.
		lTudoOk := .T.

		DbSelectArea("SA3")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA3") + zVend )
			MsgAlert("Vendedor não cadastrado: "+AllTrim(zVend))
			lTudoOk := .F.
		Endif
		
		If lTudoOk
			If Empty(zData)
				MsgAlert("Data inválida: "+aLinha[3])
				lTudoOk := .F.
			Endif
		Endif

		If lTudoOk
			If zValor <= 0
				MsgAlert("Valor menor ou igual a zero para o Vendedor "+zVend)
				lTudoOk := .F.
			Endif
		Endif

		If !lTudoOk
			MsgAlert("O processo será interrompido."+cEOL+;
					 "Corrija as informações e reinicie a importção.")
			Exit
		Endif

		If lTudoOk

			// Verifica se já existe
			zSeque := ""
			cQuery := " SELECT CT_SEQUEN "
			cQuery += " FROM " + RetSqlName("SCT")
			cQuery += " WHERE CT_FILIAL = '"+xFilial("SCT")+"' " 
			cQuery += " AND CT_DOC = '"+zDocum+"' "
			cQuery += " AND CT_DATA = '"+DtoS(zData)+"' "
			cQuery += " AND CT_VEND = '"+zVend+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
			SQLT->(DbGotop())
			If !Eof()
				lAltera := .T.
				zSeque  := SQLT->CT_SEQUEN
			Else
				lInclui := .T.
				zSeque  := _ProxSeq(zDocum)
			Endif
			SQLT->(DbCloseArea())

			If lInclui
				nCountInc += 1
				DbSelectArea("SA3")
				DbSetOrder(1)
				DbSeek( xFilial("SA3") + zVend )
				//
				DbSelectArea("SCT")
				RecLock("SCT",.T.)
				SCT->CT_FILIAL := xFilial("SCT")
				SCT->CT_DOC    := zDocum
				SCT->CT_SEQUEN := zSeque
				SCT->CT_DESCRI := zDescr
				SCT->CT_DATA   := zData
				SCT->CT_VEND   := zVend
				SCT->CT_ZZNOME := SA3->A3_NOME
				SCT->CT_REGIAO := SA3->A3_REGIAO
				SCT->CT_QUANT  := 1
				SCT->CT_VALOR  := zValor
				SCT->CT_MOEDA  := 1
				SCT->CT_CCUSTO := SA3->A3_ZZCC
				SCT->CT_ITEMCC := RetField("CTT",1,xFilial("CTT")+SA3->A3_ZZCC,"CTT_ZZITCT")
				SCT->CT_MSBLQL := "2"
				MsUnLock()
			ElseIf lAltera
				nCountAlt += 1
				DbSelectArea("SCT")
				DbSetOrder(1)
				If DbSeek( xFilial("SCT") + zDocum + zSeque )
					RecLock("SCT",.F.)
					SCT->CT_VALOR := zValor
					MsUnLock()
				Endif
			Endif

		Endif	

	Endif
		
Enddo

If lTudoOk
	MsgInfo("Processamento concluído."+cEOL+;
			AllTrim(STR(nCountLin))+IIf(nCountLin==1," registro processado."," registros processados.")+cEOL+;
			AllTrim(STR(nCountInc))+IIf(nCountInc==1," registro incluído."  ," registros incluídos.")+cEOL+;
			AllTrim(STR(nCountAlt))+IIf(nCountAlt==1," registro alterado."  ," registros alterados."))
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _ProxSeq  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  05/09/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Próxima sequencia disponível.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _ProxSeq(zDocum)

Local aArea   := GetArea()
Local cUltSeq := "000"

cQuery := " SELECT MAX(CT_SEQUEN) SEQUEN "
cQuery += " FROM "+RetSqlName("SCT")
cQuery += " WHERE CT_FILIAL = '"+xFilial("SCT")+"' " 
cQuery += " AND CT_DOC = '"+zDocum+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSEQ",.T.,.T.)
TSEQ->(DbGotop())
If !Eof()
	cUltSeq := TSEQ->SEQUEN
Endif	
TSEQ->(DbCloseArea())

cPrxSeq := SOMA1(cUltSeq)

RestArea(aArea)

Return(cPrxSeq)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  05/09/18	  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  05/09/18	  ¦¦¦
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
