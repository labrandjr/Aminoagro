#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"
#define OK	  		1
#define CANCELA		2

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BrowseXML  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out;2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Browse				          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function BROWXML()

Private cFile
Private cCadastro := "Manifesto DFe"

Private aCores    :=   {{"ZZG_TIPO == '1'" , 'BR_VERDE' },;
						{"ZZG_TIPO == '2'" , 'BR_AZUL' },;
						{"ZZG_TIPO == '3'" , 'BR_VERMELHO' },;
						{"ZZG_TIPO == '5'" , 'BR_BRANCO' },;
						{"ZZG_TIPO == '6'" , 'BR_LARANJA' },;
						{"ZZG_TIPO == '7'" , 'BR_PRETO' }}

Private aCoresLeg :=   {{"BR_VERDE"		, "1. Nota Fiscal não cadastrada - Gerar Pré-Nota"	},;
						{"BR_AZUL"		, "2. Nota Fiscal já cadastrada" },;
						{"BR_VERMELHO"	, "3. Nota Fiscal Inconsistente" },;
						{"BR_BRANCO"	, "5. Nota Fiscal Combustível não cadastrada - Gerar Nota" },;
						{"BR_LARANJA"	, "6. Nota Fiscal Combustível já cadastrada" },;
						{"BR_PRETO"	    , "7. Nota Fiscal Cancelada" }}

Private aRotina   :=   {{"Ler Arquivos XML Baixados",		   "U_LERXMLBAI", 0 , 4 },;
						{"Gerar Pre-Nota - Diversos",		   "U_GERAPRENF", 0 , 4 },;
						{"Gerar Nota Fiscal - Combustível",	   "U_GERANFCMB", 0 , 4 },;
						{"Vincular Chave NFe",				   "U_VINCCHV"	, 0 , 4 },;
						{"DANFE / DACTE",					   "U_IMPDANFE"	, 0 , 4 },;
						{"Visualizar Registro",			       "AxVisual"	, 0 , 4 },;
						{"Visualizar XML",					   "U_LAN00005"	, 0 , 4 },;
						{"Relatório NF Não Geradas",		   "U_COMR002"	, 0 , 4 },;
						{"Alterar Tipo Docto.NF Comb.- Manual","U_ALTNFCMB"	, 0 , 4 },;
						{"Alterar Tipo Docto.NF Comb.- Lote",  "U_ALTNFCLT"	, 0 , 4 },;
						{"Verificar XML Cancelados",		   "U_LAN00007"	, 0 , 4 },;
						{"Legenda", 						   "BrwLegenda(cCadastro,cLegenda,aCoresLeg)" , 0 , 10 }}

Private cLegenda  := "Legenda"

DbSelectArea("ZZG")
DbSetOrder(1)

ZZG->(DbGotop())
MBrowse(6,1,22,75,"ZZG",,,,,,aCores)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LerXMLBai  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ler XML baixados		          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function LerXMLBai()

Local lJob  := .F.
Local cPerg := "LAN00003A"

If Pergunte(cPerg,.T.)

	MsgRun("Aguarde, transferindo arquivos para o servidor...","Processando",{|| TransfXml() })

	If MsgYesNo("Confirma processamento da leitura dos arquivos XML baixados ?","Aviso","INFO")
		Processa({|| U_DOWNXML(lJob) },"Aguarde... lendo arquivos XML baixados")
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TransfXml  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Jun/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transfere arquivos XML para o servidor.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function TransfXml()

Local cDirGeral := /*GetSrvProfString("RootPath","") +*/ "\xml\Manifesto\ArqXML\"
Local _xml

// Diretório local selecionado
cPatXml := AllTrim(mv_par01)
If Substr(cPatXml,Len(Alltrim(cPatXml)),1) <> "\"
	cPatXml += "\" 
Endif
cPatTrf := cPatXml + "Transferidos\"

If !ExistDir(cPatTrf)
	MakeDir(cPatTrf)
Endif

// Monta um array com todos os arquivos *.gz LOCAL
aArqXml := Directory(cPatXml + "*.gz", "D")

// Percorre todos os arquivos transferindo para o servidor
For _xml := 1 To Len(aArqXml)
	cFileXml := Alltrim(cPatXml + aArqXml[_xml][1])
	__CopyFile( cFileXml, cDirGeral + aArqXml[_xml][1] )
	If File(cDirGeral + aArqXml[_xml][1])
		__CopyFile( cFileXml, cPatTrf + aArqXml[_xml][1] )
		If File(cPatTrf + aArqXml[_xml][1])
			Ferase(cFileXml)
		Endif
	Endif
Next _xml

// Monta um array com todos os arquivos *.gz SERVIDOR
aArquivos := Directory(cDirGeral+"*.gz") 

// Percorre todos os arquivos descompactando
For _xml := 1 to Len(aArquivos)
	// Pega o nome do arquivo com e sem extensao
	cArquivo   := aArquivos[_xml][1]
	cArqSemExt := StrTran(Lower(cArquivo),".gz","")
	//Tenta descompactar o arquivo
	If GzDecomp(cDirGeral + cArquivo, cDirGeral)
		If fRename(cDirGeral + cArqSemExt, cDirGeral + cArqSemExt + ".xml") == 0
			fErase(cDirGeral + cArqSemExt)
			fErase(cDirGeral + cArquivo)
		Endif
	Endif
Next _xml

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DOWNXML    ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ler XML baixados		          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function DOWNXML(lJob)

Local n
Private lArqLido
Private cPrNPr		:= "S"
Private cDirGeral	:= /*GetSrvProfString("RootPath","") +*/ "\xml\Manifesto\ArqXML\"
Private cDirCopia	:= /*GetSrvProfString("RootPath","") +*/ "\xml\Manifesto\ArqLidos\"
Private cDirComb	:= /*GetSrvProfString("RootPath","") +*/ "\xml\Manifesto\ArqLidosComb\"
Private cDirNProc	:= /*GetSrvProfString("RootPath","") +*/ "\xml\Manifesto\ArqNaoProc\"

If lJob
	ConOut("Função DOWNXML: Download Xml Sefaz < Início > "+DtoC(Date())+" - "+Time())
Endif

If !GetMv("MV_SCHDPRO")
	ConOut("Schedule não executado: Ambiente Teste.")
	Return
Endif

cFile	 := ""
cMascara := "*.xml"
aFiles	 := {}
aFiles	 := Directory( cDirGeral + cMascara, "D")

If Len(aFiles) == 0

	If !lJob
		MsgBox("Não foram encontrados arquivos Xml para importação!", "Alerta",  "ALERT")
		MsgBox(cDirGeral + cMascara, "Alerta",  "ALERT")
	Else
		ConOut("Não foram encontrados arquivos Xml para importação!")
		ConOut(cDirGeral + cMascara)
	Endif	

Else
	
	If !lJob
		ProcRegua( Len(aFiles) )
	Endif
	
	For n := 1 to Len(aFiles)

		If !lJob
			IncProc("Importando Xml")
		Endif

		cFile	 := cDirGeral + aFiles[n][1]
		lArqLido := U_LerArqX(lJob,@cPrNPr)
		
		If lArqLido
			If cPrNPr = "S"
				__CopyFile( cFile, cDirCopia + aFiles[n][1] )		
				IF File(cDirCopia + aFiles[n][1])
					Ferase(cFile)
				EndIf
			ElseIf cPrNPr = "C"
				__CopyFile( cFile, cDirComb + aFiles[n][1] )		
				IF File(cDirComb + aFiles[n][1])
					Ferase(cFile)
				EndIf
			Else
				__CopyFile( cFile, cDirNProc + aFiles[n][1] )		
				IF File(cDirNProc + aFiles[n][1])
					Ferase(cFile)
				EndIf
			Endif
		EndIf

	Next n

Endif

If lJob
	ConOut("Função DOWNXML: Download Xml Sefaz < Fim > "+DtoC(Date())+" - "+Time())
Else
	MsgInfo("Processo concluído.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LerArqX   ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Popular tabela ZZG	          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function LerArqX(lJob,cPrNPr)

Private _cFilial
Private _nTipo
Private _cDoc
Private _cSerie
Private _cFornec
Private _cLoja
Private _cNome
Private _dEmissa
Private _nTotal
Private _cModelo
Private _cChvNfe
Private _cXML
Private aEmpr  := {}
Private lRetx  := .F.
Private _xComb := .F.

nHdl := fOpen(cFile,0)

If nHdl == -1
	If !Empty(cFile)
		If !lJob
			MsgAlert("O arquivo de nome " + cFile + " nao pode ser aberto! Verifique os parametros.", "Atencao!")
		Else
			ConOut("O arquivo de nome " + cFile + " nao pode ser aberto! Verifique os parametros.")
		Endif	
	Endif
	PutMV("MV_PCNFE",lPcNfe)
	lRetx  := .T.
	cPrNPr := "N"
	Return(lRetx)
Endif

nTamFile	:= fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
cBuffer		:= Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
nBtLidos	:= fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
fClose(nHdl)

cAviso		:= ""
cErro		:= ""
oNfe		:= XmlParser(cBuffer, "_" , @cAviso, @cErro)

If Type("oNFe:_NfeProc") <> "U"
	oNF := oNFe:_NFeProc:_NFe
Else
	If !lJob	
		MsgAlert("XML inconsistente! Verifique o arquivo.", "Atencao!")
	Else
		ConOut("XML inconsistente! Verifique o arquivo.")
	Endif	
	lRetx  := .T.
	cPrNPr := "N"
	Return(lRetx)
Endif

Private oNFChv	  := oNFe:_NFeProc:_protNFe
Private oEmitente := oNF:_InfNfe:_Emit
Private oIdent	  := oNF:_InfNfe:_IDE
Private oDestino  := oNF:_InfNfe:_Dest
Private oTotal	  := oNF:_InfNfe:_Total
Private oDet	  := oNF:_InfNfe:_Det
Private _ChvNfe	  := oNFChv:_INFPROT:_CHNFE:TEXT

_Emitente	  := ""
_Destinatario := ""

If Type("oEmitente:_CPF") == "U" .or. Type( "oEmitente:_CGC") == "U"
	_Emitente := AllTrim(IIf(Type("oEmitente:_CPF") == "U" , oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT))
EndIF

If Type("oDestino:_CPF") == "U" .or. Type("oDestino:_CGC") == "U"
	_Destinatario := AllTrim(IIf(Type("oDestino:_CPF") == "U" , oDestino:_CNPJ:TEXT, oDestino:_CPF:TEXT))
EndIF

Dbselectarea("SM0")
SM0->(DbSetOrder(1))
SM0->(DbGoTop())
While !SM0->(EOF())
	If !Empty(SM0->M0_CGC)
		AAdd(aEmpr,{SM0->M0_CGC,SM0->M0_CODIGO,SM0->M0_CODFIL})
	Endif
	SM0->(dbskip())
Enddo

If aScan(aEmpr,{|_x|_x[1] == _Destinatario}) > 0
	_cFilial := Alltrim(aEmpr[aScan(aEmpr,{|_x|_x[1] == _Destinatario})][3])
Else
	If !lJob
		MsgAlert("CNPJ "+_Destinatario+" no XML não relacionado a nenhuma filial! Verifique os parametros.", "Atencao!")
	Else
		ConOut("CNPJ "+_Destinatario+" no XML não relacionado a nenhuma filial! Verifique os parametros.")
	Endif	
	lRetx  := .T.
	cPrNPr := "N"
	Return(lRetx)
Endif

_nTipo := oIdent:_TPNF:TEXT

If _nTipo $ "0/1"

	_cDoc     := Right(Alltrim(oIdent:_nNF:TEXT),9)
	_cSerie   := Right(Alltrim(oIdent:_serie:TEXT),3)
	_cFornec  := Posicione("SA2", 3, xFilial("SA2") + _Emitente, "A2_COD")
	_cLoja    := Posicione("SA2", 3, xFilial("SA2") + _Emitente, "A2_LOJA")
	_cNome	  := Alltrim(oEmitente:_xNome:TEXT)
	_dEmissa  := Substr(oIdent:_dhEmi:TEXT, 1, 4) + Substr(oIdent:_dhEmi:TEXT, 6, 2) + Substr(oIdent:_dhEmi:TEXT, 9, 2)
	_nTotal   := oTotal:_ICMSTot:_vNF:TEXT
	_cModelo  := oIdent:_mod:TEXT
	_cChvNfe  := _ChvNfe
	_cXML     := cBuffer
	_cTelef   := IIf(Type("oEmitente:_enderEmit:_fone") == "U", "", oEmitente:_enderEmit:_fone:TEXT)
	_cInfor   := IIf(Type("oNF:_InfNfe:_infAdic:_infCpl") == "U", "", oNF:_InfNfe:_infAdic:_infCpl:TEXT)

	If Type("oDet:_Prod:_comb") <> "U"
		_xComb = .T.
	Endif

	If Type("oDet") == "A"
		If Type("oDet[1]:_Prod:_comb") <> "U"
			_xComb = .T.
		Endif
	Endif

	DbSelectArea("SF3")
	SF3->(DbOrderNickName("CHVNFE"))
	If DbSeek( _cFilial + _cChvNfe )
		If _xComb
			_xStatus := "6" // NF Combustível já cadastrada
		Else
			_xStatus := "2" // NF já cadastrada
		Endif
	Else
		If _xComb
			_xStatus := "5" // NF Combustível não cadastrada
		Else
			_xStatus := "1" // NF não cadastrada
		Endif
	Endif

	ZZG->(DbSetOrder(1))
	_lGrava	:= .F.

	If !ZZG->(DbSeek(_cChvNFe))
		_lGrava	:= .T.
	Endif
	
	// Tratamento para notas fiscais canceladas | notas fiscais de combustível já cadastradas
	If !_lGrava
		If ZZG->ZZG_TIPO == "7"
			_xStatus := "7" // Preserva Status de Nf Cancelada
		ElseIf ZZG->ZZG_TIPO == "6" .And._xStatus == "2"
			_xStatus := "6" // Preserva Status de Nf Combustível, prevendo troca manual do TIPO devido a ausência da TAG <comb>
		Endif
	Endif

	RecLock("ZZG",_lGrava)
	ZZG->ZZG_FILIAL := _cFilial
	ZZG->ZZG_TIPO   := _xStatus
	ZZG->ZZG_DOC    := _cDoc
	ZZG->ZZG_SERIE  := _cSerie
	ZZG->ZZG_FORNEC := _cFornec
	ZZG->ZZG_LOJA   := _cLoja
	ZZG->ZZG_NOME   := Upper(_cNome)
	ZZG->ZZG_CNPJ	:= _Emitente
	ZZG->ZZG_EMISSA := StoD(_dEmissa)
	ZZG->ZZG_TOTAL  := Val(_nTotal)
	ZZG->ZZG_MODELO := Substr(_cChvNfe,21,2)
	ZZG->ZZG_CHVNFE := _cChvNfe
	ZZG->ZZG_DOCENT := IIf(_xStatus $("2,6"),"S","N")
	ZZG->ZZG_ARQXML := _cXML
	ZZG->ZZG_TELEF	:= _cTelef
	ZZG->ZZG_INFOR	:= _cInfor
	MsUnLock()

	If _xComb
		cPrNPr := "C"
	Else
		cPrNPr := "S"
	Endif

	lRetx := .T.

	If lJob
		If _lGrava
			ConOut("Xml incluído: "+AllTrim(ZZG->ZZG_CHVNFE))
		Else
			ConOut("Xml alterado: "+AllTrim(ZZG->ZZG_CHVNFE))
		Endif	
	Endif

EndIf

Return(lRetx)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GERANFCMB  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Enviar para geração de Nota Fiscal Combustivel			  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function GERANFCMB()

Local cPerg	  := "LAN0003"
Local dDatPrz := Date()-3

If Pergunte(cPerg,.T.)

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("ZZG")
	cQuery += " WHERE ZZG_FILIAL = '"+xFilial("ZZG")+"' "
	cQuery += " AND ZZG_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND ZZG_FORNEC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
	cQuery += " AND ZZG_DOC BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
	If !Empty(mv_par07)
		cQuery += " AND ZZG_CNPJ = '"+mv_par07+"' "
	Endif
	cQuery += " AND ZZG_EMISSA <= '"+DtoS(dDatPrz)+"' " // Emitidas a pelo menos 03 dias
	cQuery += " AND ZZG_TIPO = '5' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TREG", .F., .T.)
	zTotReg := TREG->SOMA
	TREG->(DbCloseArea())
	
	If zTotReg == 0
		MsgAlert("Não foram encontrados XML de combustível para importação. Verifique os parâmetros.")
	Else
		MsgRun("Aguarde, importando notas fiscais de combustível...","Processando",{|| _ProcXmlComb() })
		MsgInfo("Processo concluído.")
	Endif

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _ProcXmlComb ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _ProcXmlComb()

Local dDatPrz := Date()-3

cQuery := " SELECT R_E_C_N_O_ RECZZG "
cQuery += " FROM "+RetSqlName("ZZG")
cQuery += " WHERE ZZG_FILIAL = '"+xFilial("ZZG")+"' "
cQuery += " AND ZZG_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND ZZG_FORNEC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND ZZG_DOC BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
If !Empty(mv_par07)
	cQuery += " AND ZZG_CNPJ = '"+mv_par07+"' "
Endif
cQuery += " AND ZZG_EMISSA <= '"+DtoS(dDatPrz)+"' " // Emitidas a pelo menos 03 dias
cQuery += " AND ZZG_TIPO = '5' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TZZG", .F., .T.)
    
DbSelectArea("TZZG")
TZZG->(DbGotop())
While !Eof()

	DbSelectArea("ZZG")
	ZZG->(DbGoto(TZZG->RECZZG))

	_lRetPre := U_NotaCXML(ZZG->ZZG_ARQXML)	//----- Gera NF Combustivel ------

	DbSelectArea("ZZG")
	ZZG->(DbGoto(TZZG->RECZZG))

	If _lRetPre

		RecLock("ZZG",.F.)
		ZZG->ZZG_FORNEC := SA2->A2_COD
		ZZG->ZZG_LOJA   := SA2->A2_LOJA
		ZZG->ZZG_TIPO   := "6"
		ZZG->ZZG_DOCENT := "S"
		MsUnLock()

		// Atualiza códigos de fornecedor no Browse Monitor Xml após cadastro, para facilitar futuras importações em Lote por Fornecedor.
		cQuery := " UPDATE "+RetSqlName("ZZG")
		cQuery += " SET ZZG_FORNEC = '"+SA2->A2_COD+"', ZZG_LOJA = '"+SA2->A2_LOJA+"' "
		cQuery += " WHERE ZZG_CNPJ = '"+SA2->A2_CGC+"' AND ZZG_FORNEC = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		
		cQuery := "COMMIT"
		TCSQLEXEC(cQuery)

	Endif

	DbSelectArea("TZZG")
	TZZG->(DbSkip())	
Enddo
TZZG->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GERAPRENF  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Enviar para geração de Pré-Nota 							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function GERAPRENF()

Local _lRetPre	:= .F.
Local _aArea	:= GetArea()
Local _aAreaZZG	:= ZZG->(GetArea())

If ZZG->ZZG_EMISSA >= Date()-3
	MsgBox("Nota Fiscal " + Alltrim(ZZG->ZZG_DOC) + "-" + Alltrim(ZZG->ZZG_SERIE) + " emitida no período de 03 dias!", "Informação", "INFO")
	Return
Endif

If ZZG->ZZG_TIPO == "1"
	_lRetPre := U_PreNFXML(ZZG->ZZG_ARQXML)	//----- Gera a Pré-NF ------
ElseIf ZZG->ZZG_TIPO == "2"
	MsgBox("Nota Fiscal " + Alltrim(ZZG->ZZG_DOC) + "-" + Alltrim(ZZG->ZZG_SERIE) + " já cadastrada no sistema!", "Informação", "INFO")
ElseIf ZZG->ZZG_TIPO == "3"
	MsgBox("Nota Fiscal " + Alltrim(ZZG->ZZG_DOC) + "-" + Alltrim(ZZG->ZZG_SERIE) + " inconsistente! Verifique o DANFe, DACTe ou o XML", "Informação", "STOP")
ElseIf ZZG->ZZG_TIPO == "5"
	MsgBox("Nota Fiscal " + Alltrim(ZZG->ZZG_DOC) + "-" + Alltrim(ZZG->ZZG_SERIE) + " refere-se a Combustível.", "Informação", "STOP")
Endif

RestArea(_aArea)
ZZG->(RestArea(_aAreaZZG))

If _lRetPre
	RecLock("ZZG",.F.)
	ZZG->ZZG_TIPO   := "2"
	ZZG->ZZG_DOCENT := "S"
	MsUnLock()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VINCCHV    ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Vincula Chave NFe	          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function VINCCHV()

Processa({|| U_VINCCHV1() },"Aguarde... Vinculando Chaves NFe")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VINCCHV    ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Vincula Chave NFe	          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function VINCCHV1()

// ===== Atualiza fornecedor ===========================================================
ProcRegua(2)
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM " + RetSqlName("ZZG") + " ZZG "
cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (ZZG_CNPJ = A2_CGC) "
cQuery += " WHERE ZZG.D_E_L_E_T_ <> '*' AND SA2.D_E_L_E_T_ <> '*' " 
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())
		
IncProc("Selecionando registros...")
cQuery := " SELECT ZZG.R_E_C_N_O_ ZZGRECNO, SA2.R_E_C_N_O_ SA2RECNO, A2_COD, A2_LOJA "
cQuery += " FROM " + RetSqlName("ZZG") + " ZZG "
cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (ZZG_CNPJ = A2_CGC) "
cQuery += " WHERE ZZG.D_E_L_E_T_ <> '*' AND SA2.D_E_L_E_T_ <> '*' " 
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()
	
	IncProc("Aguarde! Vinculando Fornecedores...")

	DbSelectArea("ZZG")
	ZZG->(DbGoto(SQL->ZZGRECNO))

	RecLock("ZZG",.F.)
	ZZG->ZZG_FORNEC	:= SQL->A2_COD
	ZZG->ZZG_LOJA	:= SQL->A2_LOJA
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

// ===== Atualiza Chave NF-e ===========================================================
ProcRegua(2)
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM " + RetSqlName("ZZG") + " ZZG "
cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON (ZZG_CHVNFE = F1_CHVNFE) "
cQuery += " WHERE ZZG.D_E_L_E_T_ <> '*' AND SF1.D_E_L_E_T_ <> '*' " 
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())
		
IncProc("Selecionando registros...")
cQuery := " SELECT ZZG.R_E_C_N_O_ ZZGRECNO, SF1.R_E_C_N_O_ SF1RECNO "
cQuery += " FROM " + RetSqlName("ZZG") + " ZZG "
cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON (ZZG_CHVNFE = F1_CHVNFE) "
cQuery += " WHERE ZZG.D_E_L_E_T_ <> '*' AND SF1.D_E_L_E_T_ <> '*' " 
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()
	
	IncProc("Aguarde! Vinculando Chaves...")

	DbSelectArea("ZZG")
	ZZG->(DbGoto(SQL->ZZGRECNO))

	RecLock("ZZG",.F.)
	ZZG->ZZG_TIPO   := "2"
	ZZG->ZZG_DOCENT := "S"
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

MsgBox("Chaves NF-e vinculadas com sucesso!", "Informação", "INFO")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ALTNFCMB   ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Altera tipo do registro para 5-Combustível - Individual    ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function ALTNFCMB

Local cEOL := CHR(13)+CHR(10)

If ZZG->ZZG_TIPO != "1" .And. ZZG->ZZG_TIPO != "5"
	MsgAlert("Recurso disponível apenas para Notas Fiscais com Tipo Docto.:"+cEOL+;
			"1.Nota Fiscal não cadastrada"+cEOL+;
			"5.Nota Fiscal Combustível não cadastrada")
	Return
Endif

If ZZG->ZZG_TIPO == "1"
	If MsgYesNo("Confirma alteração do Tipo Docto. para:"+cEOL+;
				"5.Nota Fiscal Combustível não cadastrada ?","Aviso","INFO")
		RecLock("ZZG",.F.)
		ZZG->ZZG_TIPO := "5"
		MsUnLock()
	Endif
ElseIf ZZG->ZZG_TIPO == "5"
	If MsgYesNo("Confirma reversão do Tipo Docto. para:"+cEOL+;
				"1.Nota Fiscal não cadastrada ?","Aviso","INFO")
		RecLock("ZZG",.F.)
		ZZG->ZZG_TIPO := "1"
		MsUnLock()
	Endif
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ALTNFCLT  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Altera tipo do registro para 5-Combustível - Em Lote       ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function ALTNFCLT()

Local _aArea	 := GetArea()
Local _aAreaZZG	 := ZZG->(GetArea())
Local lOk        := .F.
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

	If MsgYesNo("Confirma o processamento - ALTERAÇÃO TIPO DOCTO. PARA 5=COMBUSTÍVEL ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcClt() }, "Alterando Tipo Docto. para 5-Combustível", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)
	MsgInfo("Processo concluído.")

Endif

RestArea(_aArea)
ZZG->(RestArea(_aAreaZZG))

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcClt  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  25/03/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcClt()

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
			If Len(aLinha) == 8
				Exit
			Endif
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	// Estrutura de aLinha:
	// [01] - Filial
	// [02] - Nome Filial
	// [03] - Emissão
	// [04] - Série
	// [05] - Documento
	// [06] - Modelo
	// [07] - Valor
	// [08] - Chave

	If Len(aLinha) < 8
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter pelo menos 08 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := aLinha[1]
		zNomFil := aLinha[2]
		zEmissa := aLinha[3]
		zSerie  := aLinha[4]
		zNFisca := aLinha[5]
		zModelo := aLinha[6]
		zValor  := aLinha[7]
		zChave  := PadR(aLinha[8],44)

		DbSelectArea("ZZG")
		DbSetOrder(1)
		If DbSeek( zChave )
			If ZZG->ZZG_TIPO == "1"
				RecLock("ZZG",.F.)
				ZZG->ZZG_TIPO := "5"
				MsUnLock()
			Endif
		Endif

	Endif
		
Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  25/03/17	  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  25/03/17	  ¦¦¦
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
¦¦¦Programa  ¦ IMPDANFE   ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Imprime DANFe		          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function IMPDANFE

Local cIniName	:= GetRemoteIniName() // Resultado: "C:\totvs\bin\SmartClient\smartclient.ini"
Local lUnix		:= IsSrvUnix()
Local nPos		:= Rat(IIf(lUnix, "/", "\"), cIniName)
Local cPathRmt

If !(nPos == 0)
	cPathRmt := SubStr(cIniName, 1, nPos - 1)
Else
	cPathRmt := ""
Endif

cFile := cPathRmt + "\ImpDANFE\ImpDANFE.EXE"

ShellExecute("Open", cFile, "", cPathRmt + "\", 1)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 06/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QBAIXML()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_DOWNXML(.T.)
Return
