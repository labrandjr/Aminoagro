#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CSVCREC   ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦  Set-2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Baixa contas a receber via arquivo Csv gerado no Sap.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo DMA	 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CSVCREC()

Local lOk        := .F.
Local cUsrHab    := "000000,000163,"+AllTrim(GetMv("MV_ZUSCOML"))
Local cEnvAut    := "CJXW4M_HOM,CJXW4M_DEV"
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

If !( __cUserId $(cUsrHab) )
	MsgAlert("Usuário não autorizado.")
	Return
Endif

If !(GetEnvServer() $(cEnvAut))
	MsgAlert("Ambiente não autorizado.")
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

	If MsgYesNo("Confirma o processamento - Baixas a Receber ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando dados", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  Set-2023   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo DMA											  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local aBaixas   := {}
Private lProcOk := .F.
Private lProcEr := .F.
Private lMsErroAuto := .F.

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
	// [01] - Local Negócios (Filial)
	// [02] - Referência (Identificação do Título)
	// [03] - Data Compensação (Data da Baixa)
	// [04] - Exercício
	// [05] - Doc.Compensação
	// [06] - Montante em MI (Valor da Baixa)
	// [07] - Moeda
	// [08] - Desconto (Desconto(+))
	// [09] - Empresa
	// [10] - Cliente
	// [11] - Tipo Documento
	// [12] - No.Documento
	// [13] - Data Entrada
	// [14] - Atribuição
	// [15] - Juros (Juros(-))

	If Len(aLinha) <> 15
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 15 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		If !(aLinha[1] $("0033,0034,0023,0027,0035"))
			MsgInfo("Filial inválida: "+aLinha[1])
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		zFilial := "0101"
		If aLinha[1] == "0033"
			zFilial := "0102"
		ElseIf aLinha[1] == "0034"
			zFilial := "0106"
		ElseIf aLinha[1] == "0023"
			zFilial := "0107"
		ElseIf aLinha[1] == "0027"
			zFilial := "0109"
		ElseIf aLinha[1] == "0035"
			zFilial := "0110"
		Endif	

		nPosic  := 0
		aNumTit := {}
		cTxtLin := aLinha[2]
		While (!Empty(cTxtLin))
			If (((nPosic := AT("-",cTxtLin)) > 0))
				AAdd(aNumTit,Substr(cTxtLin,1,nPosic-1))
				cTxtLin := Stuff(cTxtLin,1,nPosic,"")
			Else
				AAdd(aNumTit,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
				cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
			Endif	
		Enddo
		If Len(aNumTit) < 2 .Or. Len(aNumTit) > 3
			MsgInfo("Número do Título inválido: "+aLinha[2])
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		ElseIf Len(aNumTit) == 2
			zPrefix := PadR(aNumTit[1],3)
			zNumero := PadR(aNumTit[2],9)
			zParcel := Space(2)
		Else
			zPrefix := PadR(aNumTit[1],3)
			zNumero := PadR(aNumTit[2],9)
			zParcel := PadR(aNumTit[3],2)		
		Endif

		If zPrefix == "5"
			Loop
		Endif

		zDataBx := CtoD(aLinha[3])
		zHistBx := "SAP DOC.CMP "+AllTrim(aLinha[5])

		zValoBx := StrTran(aLinha[6],".","")
		zValoBx := StrTran(zValoBx,",",".")
		zValoBx := Val(zValoBx)

		zDescon := StrTran(aLinha[8],".","")
		zDescon := StrTran(zDescon,",",".")
		zDescon := Val(zDescon)

		zVJuros := StrTran(aLinha[15],".","")
		zVJuros := StrTran(zVJuros,",",".")
		zVJuros := Val(zVJuros)

		zValRec := zValoBx + zDescon - zVJuros

		DbSelectArea("SE1")
		DbSetOrder(1)
		If !DbSeek( zFilial + zPrefix + zNumero + zParcel )
			lProcEr := .T.
			MsgInfo("Título não localizado: "+aLinha[1]+"-"+aLinha[2])
	    	If MsgYesNo("Abandona ?","Aviso","INFO")
	    		Exit
	    	Endif
			Loop
		Endif

		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SE5")
		cQuery += " WHERE E5_FILIAL = '"+SE1->E1_FILIAL+"' "
		cQuery += " AND E5_PREFIXO = '"+SE1->E1_PREFIXO+"' "
		cQuery += " AND E5_NUMERO = '"+SE1->E1_NUM+"' "
		cQuery += " AND E5_PARCELA = '"+SE1->E1_PARCELA+"' "
		cQuery += " AND E5_TIPO = '"+SE1->E1_TIPO+"' "
		cQuery += " AND E5_CLIFOR = '"+SE1->E1_CLIENTE+"' "
		cQuery += " AND E5_LOJA = '"+SE1->E1_LOJA+"' "
		cQuery += " AND E5_DATA = '"+DtoS(zDataBx)+"' "
		cQuery += " AND E5_BANCO = 'SAP' "
		cQuery += " AND E5_MOTBX = 'NOR' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
		lBaixado := (SQL5->SOMA > 0)
		SQL5->(DbCloseArea())
		If lBaixado
			lProcEr := .T.
			If __cUserId == "000000"
				MsgInfo("Baixa já realizada: "+aLinha[2]+" - "+DtoC(zDataBx)+" - "+AllTrim(STR(zValRec)))
				If MsgYesNo("Abandona ?","Aviso","INFO")
					Exit
				Endif
			Endif	
			Loop
		Endif

		lProcOk := .T.
		If SE1->E1_SITUACA <> "0"
			RecLock("SE1",.F.)
			SE1->E1_PORTADO := ""
			SE1->E1_AGEDEP  := ""
			SE1->E1_CONTA   := ""
			SE1->E1_SITUACA := "0"
			MsUnLock()
		Endif
		AAdd(aBaixas,{SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, zDataBx, zHistBx, zValRec})

	Endif
		
Enddo

If Len(aBaixas) > 0
	MsgRun("Aguarde, executando baixas a receber","Processando",{|| CsvRecSap(aBaixas) })
Endif	

If lProcOk
	If !lProcEr
		MsgInfo("Processamento concluído com sucesso para todos os registros do arquivo.")
	Else
		MsgInfo("Processamento concluído parcialmente. Analise os registros não processados.")
	Endif	
Else
	MsgAlert("Processamento não executado.")
Endif
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CsvRecSap ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  Set-2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa as baixas a receber.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo DMA											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function CsvRecSap(aBaixas)

Local _b

For _b := 1 to Len(aBaixas)

	cFilAnt := aBaixas[_b][1]

	aBaixa := { {"E1_PREFIXO"  , aBaixas[_b][2] , Nil},;
				{"E1_NUM"	   , aBaixas[_b][3] , Nil},; 
				{"E1_PARCELA"  , aBaixas[_b][4] , Nil},;
				{"E1_TIPO"	   , aBaixas[_b][5] , Nil},;
				{"AUTMOTBX"	   , "NOR"          , Nil},;
				{"AUTBANCO"	   , "SAP"          , Nil},;
				{"AUTAGENCIA"  , "00000"        , Nil},;
				{"AUTCONTA"    , "0000000000"   , Nil},;
				{"AUTDTBAIXA"  , aBaixas[_b][6] , Nil},;
				{"AUTDTCREDITO", aBaixas[_b][6] , Nil},;
				{"AUTHIST"	   , aBaixas[_b][7] , Nil},; 
				{"AUTVALREC"   , aBaixas[_b][8] , Nil} }
	lMsErroAuto := .F.
	MsExecAuto({|x,y| FINA070(x,y)},aBaixa,3)  
	If lMsErroAuto
		lProcEr := .T.
		MostraErro()
		MsgAlert("Falha na execução da baixa a receber: "+cFilAnt+"-"+aBaixas[_b][2]+"-"+aBaixas[_b][3]+"-"+aBaixas[_b][4])
	Endif

Next _b

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  Set-2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua leitura do arquivo e retorna conteudo da linhaa.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo DMA											  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  Set-2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Obtem o tamanho do arquivo texto.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo DMA											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)
