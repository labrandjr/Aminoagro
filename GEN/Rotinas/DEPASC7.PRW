#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DEPASC7   ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 13/10/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteração em pedidos de compra - produtos bloqueados.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DEPASC7()

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

	If MsgYesNo("Confirma o processamento - DE-PARA PRODUTOS PC ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "De-Para Produtos Ped.Compra", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  27/09/17	  ¦¦¦
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
Local cEOL := CHR(13)+CHR(10)

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
	// [01] - Filial
	// [02] - Pedido
	// [03] - Item
	// [04] - Produto de
	// [05] - Produto para
	
	If Len(aLinha) < 5
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 5 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := aLinha[1]
		zPedido := aLinha[2]
		zItemPc := aLinha[3]
		zProdDe := PadR(aLinha[4],15)
		zProdAt := PadR(aLinha[5],15)

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zProdDe )
			MsgAlert("Filial: "+zFilial+cEOL+;
					 "Pedido: "+zPedido+cEOL+;
					 "Item: "+zItemPc+cEOL+;
					 "Prod.DE: "+zProdDe+cEOL+;
					 "Prod.ATÉ: "+zProdAt+cEOL+;
					 "PRODUTO 'DE' INVÁLIDO.")
			Loop
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zProdAt )
			MsgAlert("Filial: "+zFilial+cEOL+;
					 "Pedido: "+zPedido+cEOL+;
					 "Item: "+zItemPc+cEOL+;
					 "Prod.DE: "+zProdDe+cEOL+;
					 "Prod.ATÉ: "+zProdAt+cEOL+;
					 "PRODUTO 'ATÉ' INVÁLIDO.")
			Loop
		Endif

		DbSelectArea("SC7")
		DbSetOrder(1)
		If !DbSeek( zFilial + zPedido + zItemPc )
			MsgAlert("Filial: "+zFilial+cEOL+;
					 "Pedido: "+zPedido+cEOL+;
					 "Item: "+zItemPc+cEOL+;
					 "Prod.DE: "+zProdDe+cEOL+;
					 "Prod.ATÉ: "+zProdAt+cEOL+;
					 "'FILIAL + PEDIDO + ITEM' INVÁLIDO.")
			Loop
		Endif

		If AllTrim(zProdDe) != AllTrim(zProdAt) //.And. AllTrim(SC7->C7_PRODUTO) != AllTrim(zProdAt)

			If SC7->C7_QUJE > 0
				
				cQuery := " SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM, D1_COD "
				cQuery += " FROM "+RetSqlName("SD1")
				cQuery += " WHERE D1_FILIAL = '"+zFilial+"' "
				cQuery += " AND D1_PEDIDO = '"+zPedido+"' "
				cQuery += " AND D1_ITEMPC = '"+zItemPc+"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
				
				DbSelectArea("SQL1")
				SQL1->(DbGotop())
				While !Eof()
					cQuery := " UPDATE "+RetSqlName("CD2")+" SET CD2_CODPRO = '"+zProdAt+"' "
					cQuery += " WHERE CD2_FILIAL = '"+SQL1->D1_FILIAL+"' "
					cQuery += " AND CD2_DOC = '"+SQL1->D1_DOC+"' "
					cQuery += " AND CD2_SERIE = '"+SQL1->D1_SERIE+"' "
					cQuery += " AND CD2_CODFOR = '"+SQL1->D1_FORNECE+"' "
					cQuery += " AND CD2_LOJFOR = '"+SQL1->D1_LOJA+"' "
					cQuery += " AND CD2_ITEM = '"+SQL1->D1_ITEM+"' "
					cQuery += " AND CD2_TPMOV = 'E' "
					cQuery += " AND D_E_L_E_T_ <> '*' "
					TCSQLEXEC(cQuery)	

					cQuery := " COMMIT "
					TCSQLEXEC(cQuery)	

					DbSelectArea("SQL1")
					SQL1->(DbSkip())
				Enddo
				SQL1->(DbCloseArea())

				cQuery := " UPDATE "+RetSqlName("SD1")+" SET D1_COD = '"+zProdAt+"' "
				cQuery += " WHERE D1_FILIAL = '"+zFilial+"' "
				cQuery += " AND D1_PEDIDO = '"+zPedido+"' "
				cQuery += " AND D1_ITEMPC = '"+zItemPc+"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				TCSQLEXEC(cQuery)	

				cQuery := " COMMIT "
				TCSQLEXEC(cQuery)	

			Endif

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + zProdAt )

			RecLock("SC7",.F.)
			SC7->C7_PRODUTO := zProdAt
			SC7->C7_DESCRI  := SB1->B1_DESC
			MsUnLock()	
/*	
			MsgInfo("Filial: "+zFilial+cEOL+;
				 "Pedido: "+zPedido+cEOL+;
				 "Item: "+zItemPc+cEOL+;
				 "Prod.DE: "+zProdDe+cEOL+;
				 "Prod.ATÉ: "+zProdAt+cEOL+;
				 "ATUALIZAÇÃO OK !!")
*/
		Endif

	Endif
		
Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  27/09/17	  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  27/09/17	  ¦¦¦
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
