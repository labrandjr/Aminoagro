#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CHKMOVF  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦03/12/2020       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checa movimentações a partir de arquivo Csv.			 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHKMOVF()

Local lOk  := .F.

Private cPath := "c:\report\"
Private oTempTable

Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

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

	If MsgYesNo("Confirma o processamento ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := pChkMov() }, "Checando movimentações", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pChkMov   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 03/12/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pChkMov()

Local oExcel    := FwMsExcel():New()
Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local i

ChkMvTrab()

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
	// [01] - Código Csv
	// [02] - Nome Csv

	If Len(aLinha) < 2
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 02 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zCodCsv := aLinha[1]
		zNomCsv := AllTrim(aLinha[2])

		nPosic  := 0
		aNomes  := {}
		cTxtLin := zNomCsv
		While (!Empty(cTxtLin))
			If (((nPosic := AT(" ",cTxtLin)) > 0))
				AAdd(aNomes,Substr(cTxtLin,1,nPosic-1))
				cTxtLin := Stuff(cTxtLin,1,nPosic,"")
			Else
				AAdd(aNomes,Substr(cTxtLin,1,Len(cTxtLin)))
				cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
			Endif	
		Enddo

		For i := 1 to Len(aNomes)
			zWord := Upper(aNomes[i])
			zWord := StrTran( zWord,".","" )
			zWord := StrTran( zWord,"'","" )
			zWord := StrTran( zWord,"S.A.","" )
			zWord := StrTran( zWord,"LIMITED","" )
			zWord := StrTran( zWord,"INTERNATIONAL","" )
			zWord := StrTran( zWord,"LTDA","" )
			zWord := StrTran( zWord,"INTER","" )
			zWord := StrTran( zWord,"CORP","" )
			zWord := StrTran( zWord,"MANAGEMENT","" )
			If Len(zWord) > 3

				cQuery := " SELECT A1_COD, A1_NOME "
				cQuery += " FROM "+RetSqlName("SA1")
				cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += " AND A1_EST = 'EX' "
				cQuery += " AND A1_NOME LIKE '%"+AllTrim(zWord)+"%' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

				DbSelectArea("SQL")
				SQL->(DbGotop())
				While !Eof()
					//
					RecLock("TRB",.T.)
					TRB->TF_CODCSV := zCodCsv
					TRB->TF_NOMCSV := zNomCsv
					TRB->TF_TIPO   := "C"
					TRB->TF_CODPRT := SQL->A1_COD
					TRB->TF_NOMPRT := SQL->A1_NOME
					MsUnLock()
					//
					DbSelectArea("SQL")
					SQL->(DbSkip())
				Enddo
				SQL->(DbCloseArea())

				cQuery := " SELECT A2_COD, A2_NOME "
				cQuery += " FROM "+RetSqlName("SA2")
				cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
				cQuery += " AND A2_EST = 'EX' "
				cQuery += " AND A2_NOME LIKE '%"+AllTrim(zWord)+"%' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

				DbSelectArea("SQL")
				SQL->(DbGotop())
				While !Eof()
					//
					RecLock("TRB",.T.)
					TRB->TF_CODCSV := zCodCsv
					TRB->TF_NOMCSV := zNomCsv
					TRB->TF_TIPO   := "F"
					TRB->TF_CODPRT := SQL->A2_COD
					TRB->TF_NOMPRT := SQL->A2_NOME
					MsUnLock()
					//
					DbSelectArea("SQL")
					SQL->(DbSkip())
				Enddo
				SQL->(DbCloseArea())

			Endif
		Next i

	Endif
		
Enddo

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "CHK_MOV"
	cNomeTable := "Movimentações Fiscais"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Csv",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Csv",1,1)	
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Protheus",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Protheus",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)

	While !Eof()

		IncProc("Gerando planilha...")

		zTipo := IIf(TRB->TF_TIPO=="C","Cliente","Fornecedor")
		
		oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_CODCSV, TRB->TF_NOMCSV, TRB->TF_CODPRT, TRB->TF_NOMPRT, zTipo,;
											  TRB->TF_FILIAL, TRB->TF_DOC, TRB->TF_SERIE, TRB->TF_EMISSAO })

		DbSelectArea("TRB")
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "CHK_MOV-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
TRB->(DbCloseArea())
oTempTable:Delete()
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ChkMvTrab ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 20/12/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ChkMvTrab()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_CODCSV"  , "C", 006, 00} )
AAdd ( _aTmp, {"TF_NOMCSV"  , "C", 100, 00} )
AAdd ( _aTmp, {"TF_CODPRT"  , "C", 006, 00} )
AAdd ( _aTmp, {"TF_NOMPRT"  , "C", 100, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 001, 00} )
AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_DOC"     , "C", 009, 00} )
AAdd ( _aTmp, {"TF_SERIE"   , "C", 003, 00} )
AAdd ( _aTmp, {"TF_EMISSAO" , "D", 008, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_CODCSV", "TF_CODPRT", "TF_TIPO", "TF_FILIAL", "TF_DOC"})
oTempTable:Create()

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  03/12/2020  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  03/12/2020  ¦¦¦
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
