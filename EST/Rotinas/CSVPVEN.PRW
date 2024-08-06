#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CSVPVEN   ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 28/02/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação da dados para processamento do Mrp.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CSVPVEN()

Local cUsErPc    := AllTrim(GetMv("MV_ZUSERPC"))
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

If !(__cUserId $(cUsErPc))
    MsgAlert("Usuário não autorizado. Contate o Administrador.")
    Return
Endif

cArquivo := cGetFile("Arquivos CSV|*.CSV|",OemToAnsi("Selecione o arquivo"))
cArquivo := AllTrim(cArquivo)

nPosic  := 0
aLinha  := {}
cTxtLin := cArquivo
cNomArq := ""
While (!Empty(cTxtLin))
	If (((nPosic := AT("\",cTxtLin)) > 0))
		cTxtLin := Stuff(cTxtLin,1,nPosic,"")
	Else
		cNomArq := cTxtLin
		cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
	Endif	
Enddo

If Upper(Substr(cNomArq,1,3)) != "MRP"
	MsgAlert("O nome do arquivo deve começar com 'MRP'. Processo cancelado.")
	Return
Endif

zAno := Substr(cNomArq,4,4)
If Val(zAno) < 2021
	MsgAlert("Ano inválido: "+zAno+". O nome do arquivo deve conter o ano após 'MRP'.")
	Return
Endif

zTpMrp := Upper(Substr(cNomArq,8,Len(cNomArq)-11)) // MRP(3) + 2021(4) + .csv(4) = 11
If !(zTpMrp $("PV,PM"))
	MsgAlert("Tipo do MRP inválido: "+zTpMrp+". O nome do arquivo deve terminar com 'PV' ou 'PM'.")
	Return
Endif

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

	cTpImp := IIf(zTpMrp=="PV","PREVISÃO DE VENDAS","PLANO MESTRE DE PRODUÇÃO")
	If MsgYesNo("Confirma o processamento - "+cTpImp+" ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | ProcImp(zAno,zTpMrp) }, "Importando", "Aguarde, processando ...", .F. )
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

Static Function ProcImp(zAno,zTpMrp)

Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local lProcOk   := .F.
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
	// [01] - Filial
	// [02] - Produto
	// [03] - Descrição
	// [04] - Qtd.Jan
	// [05] - Qtd.Fev
	// [06] - Qtd.Mar
	// [07] - Qtd.Abr
	// [08] - Qtd.Mai
	// [09] - Qtd.Jun
	// [10] - Qtd.Jul
	// [11] - Qtd.Ago
	// [12] - Qtd.Set
	// [13] - Qtd.Out
	// [14] - Qtd.Nov
	// [15] - Qtd.Dez

	If Len(aLinha) != 15
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 15 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := StrZero(Val(aLinha[1]),4)
		zProdut := PadR(StrZero(Val(aLinha[2]),6),15)
		zDescri := aLinha[3]

		zJan := StrTran(aLinha[4],".","")
		zJan := StrTran(zJan,",",".")
		zJan := Val(zJan)

		zFev := StrTran(aLinha[5],".","")
		zFev := StrTran(zFev,",",".")
		zFev := Val(zFev)

		zMar := StrTran(aLinha[6],".","")
		zMar := StrTran(zMar,",",".")
		zMar := Val(zMar)

		zAbr := StrTran(aLinha[7],".","")
		zAbr := StrTran(zAbr,",",".")
		zAbr := Val(zAbr)

		zMai := StrTran(aLinha[8],".","")
		zMai := StrTran(zMai,",",".")
		zMai := Val(zMai)

		zJun := StrTran(aLinha[9],".","")
		zJun := StrTran(zJun,",",".")
		zJun := Val(zJun)

		zJul := StrTran(aLinha[10],".","")
		zJul := StrTran(zJul,",",".")
		zJul := Val(zJul)

		zAgo := StrTran(aLinha[11],".","")
		zAgo := StrTran(zAgo,",",".")
		zAgo := Val(zAgo)

		zSet := StrTran(aLinha[12],".","")
		zSet := StrTran(zSet,",",".")
		zSet := Val(zSet)

		zOut := StrTran(aLinha[13],".","")
		zOut := StrTran(zOut,",",".")
		zOut := Val(zOut)

		zNov := StrTran(aLinha[14],".","")
		zNov := StrTran(zNov,",",".")
		zNov := Val(zNov)

		zDez := StrTran(aLinha[15],".","")
		zDez := StrTran(zDez,",",".")
		zDez := Val(zDez)

		lTudoOk := .T.

		If !FWFilExist("G1",zFilial)
			MsgInfo("Filial não localizada: "+zFilial)
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zProdut )
			MsgInfo("Produto não localizado: "+zProdut)
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		If zTpMrp == "PV"
			zAlias := "SC4"
			zInCpo := "SC4->C4"
			zChave := "zFilial + zProdut + DtoS(zDtPrev)"
		Else
			zAlias := "SHC"
			zInCpo := "SHC->HC"
			zChave := "zFilial + DtoS(zDtPrev) + zProdut"
		Endif	

		zDtPrev := StoD(zAno+"0101")
		If zJan >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"01"
			&(zInCpo+"_QUANT") := zJan
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0201")
		If zFev >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"02"
			&(zInCpo+"_QUANT") := zFev
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0301")
		If zMar >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"03"
			&(zInCpo+"_QUANT") := zMar
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0401")
		If zAbr >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"04"
			&(zInCpo+"_QUANT") := zAbr
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0501")
		If zMai >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"05"
			&(zInCpo+"_QUANT") := zMai
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0601")
		If zJun >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"06"
			&(zInCpo+"_QUANT") := zJun
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0701")
		If zJul >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"07"
			&(zInCpo+"_QUANT") := zJul
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0801")
		If zAgo >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"08"
			&(zInCpo+"_QUANT") := zAgo
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"0901")
		If zSet >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"09"
			&(zInCpo+"_QUANT") := zSet
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"1001")
		If zOut >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"10"
			&(zInCpo+"_QUANT") := zOut
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"1101")
		If zNov >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"11"
			&(zInCpo+"_QUANT") := zNov
			MsUnLock()
		Endif

		zDtPrev := StoD(zAno+"1201")
		If zDez >= 0
			lProcOk := .T.
			DbSelectArea(zAlias)
			DbSetOrder(1)
			If !DbSeek( &(zChave) )
				RecLock(zAlias,.T.)
				&(zInCpo+"_FILIAL")  := zFilial
				&(zInCpo+"_PRODUTO") := zProdut
				&(zInCpo+"_DATA")    := zDtPrev
			Else
				RecLock(zAlias,.F.)
			Endif
			&(zInCpo+"_LOCAL") := SB1->B1_LOCPAD
			&(zInCpo+"_DOC")   := zAno+"12"
			&(zInCpo+"_QUANT") := zDez
			MsUnLock()
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
