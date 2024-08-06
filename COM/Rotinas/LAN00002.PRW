#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "HBUTTON.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#include "FILEIO.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PreNotaAUT ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota - AUTOMATICO							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦¦          ¦ SA5 -> A5_FILIAL + A5_FORNECE + A5_LOJA  + A5_CODPRF       ¦¦¦
¦¦¦          ¦ NICK NAME -> FORPROD                                       ¦¦¦
¦¦¦          ¦ SA7 -> A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_CODCLI        ¦¦¦
¦¦¦          ¦ NICK NAME -> CLIPROD                                       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function PreNotaAUT

//Private aTipo			:= {'N','B','D'}
Private aEmpr			:= {}
Private cFile 		   	:= Space(100)
Private lPcNfe		   	:= GETMV("MV_PCNFE")
Private varDtaEntrada  	:= Date()
Private oNF
Private oNFChv
Private nTipo			:= ""
Private nHdl
Private _cProdDig		:= Space(15)
Private _cDescDig		:= Space(55)
Private _cAlmxDig		:= Space(02)
Private _cNcmDig		:= Space(8)
Private _cTipo			:= ""
Private _cFormul		:= ""
Private cFile
Private cRootPath		:= GetSrvProfString("RootPath","") + "\xml\"

GetTArq()
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetTArq	  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function GetTArq

Local n

cFile := ""

aFiles	:= Directory(cRootPath + "*.xml", "D") // array com todos os aquivos da pasta
	
If Len(aFiles) = 0
	// Não foram encontrados arquivos Xml para importação
Else
		
	// ----- Percorre os arquivos do diretorio -------------------------------------------------------------
	For n := 1 to Len(aFiles)
		cFile	:= cRootPath + aFiles[n][1]
		U_PROCAUT()
		PutMV("MV_PCNFE",lPcNfe)
	Next
EndIf

Return( cFile )

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PROCAUT    ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function PROCAUT(cFile)

Local nHdl		:= fOpen(cFile,0)
Local nX
Local _nL
Local lRetorno   := .T.

If nHdl == -1
	If !Empty(cFile)
		_aMsg := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		AAdd(_aMsg, "")
		AAdd(_aMsg, "Erro na Geração de Pré-Nota via XML") 
		AAdd(_aMsg, "O arquivo de nome " + cFile + " nao pode ser aberto!" )
		AAdd(_aMsg, " Verifique se o arquivo é válido." )
		cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
		cAssunto := "Erro na Geração de Pré-Nota via XML"
		U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)
	Endif
	PutMV("MV_PCNFE",lPcNfe)
	Return
Endif

nTamFile	:= fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
cBuffer		:= Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
nBtLidos	:= fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
fClose(nHdl)

cAviso		:= ""
cErro		:= ""
oNfe		:= XmlParser( cBuffer, "_" , @cAviso, @cErro)

If Type("oNFe:_NfeProc")<> "U"
	oNF		:= oNFe:_NFeProc:_NFe
Else
	oNF		:= oNFe:_NFe
Endif

oNFChv		:= oNFe:_NFeProc:_protNFe

Private oEmitente  := oNF:_InfNfe:_Emit
Private oEndEmit   := oNF:_InfNfe:_Emit:_enderEmit
Private oIdent     := oNF:_InfNfe:_IDE
Private oDestino   := oNF:_InfNfe:_Dest
Private oEndDest   := oNF:_InfNfe:_Dest:_enderDest
Private oTotal     := oNF:_InfNfe:_Total
Private oTransp    := oNF:_InfNfe:_Transp
Private oDet       := oNF:_InfNfe:_Det
Private cChvNfe    := oNFChv:_INFPROT:_CHNFE:TEXT
Private oICM	   := nil

If Type( "oNF:_InfNfe:_ICMS" ) <> "U"
	oICM	:= oNF:_InfNfe:_ICMS
Endif

Private oFatura		:= IIf( Type( "oNF:_InfNfe:_Cobr" ) == "U", Nil, oNF:_InfNfe:_Cobr)

oDet := IIf( ValType( oDet ) == "O", {oDet}, oDet )

// Validacoe - CNPJ da NOTA = CNPJ do CLIENTE ? oEmitente:_CNPJ
nTipo := oIdent:_TPNF:TEXT
If Alltrim(nTipo) == "0"
	_cTipo		:= "N"
	_cFormul	:= "S"
ElseIF Alltrim(nTipo) == "1"
	_cTipo		:= "N"
	_cFormul	:= "N"
Endif

If _cFormul == "N"
	cCgc  := AllTrim( IIf( Type("oEmitente:_CPF") == "U" , oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT ) )
	cCgcD := AllTrim( oDestino:_CNPJ:TEXT )
	varIE := oEmitente:_IE:TEXT
Else
	cCgc  := AllTrim( IIf( Type("oDestino:_CPF") == "U" , oDestino:_CNPJ:TEXT, oDestino:_CPF:TEXT ) )
	cCgcD := AllTrim( oEmitente:_CNPJ:TEXT )
	varIE := oDestino:_IE:TEXT
Endif

// Carrega em matriz o cnpj, nome e filial --------------------------------------------------------------
Dbselectarea("SM0")
SM0->(DbSetOrder(1))
SM0->(DbGoTop())
While !SM0->(EOF())
	If Alltrim(SM0->M0_CGC) <> ''
		Aadd(aEmpr,{SM0->M0_CGC,SM0->M0_CODIGO,SM0->M0_CODFIL})
	Endif
	SM0->(dbskip())
Enddo
//cEmp := Alltrim(aEmpr[AScan(aEmpr,{|_x|_x[1] == cCgcD})][2])
cFil := Alltrim(aEmpr[AScan(aEmpr,{|_x|_x[1] == cCgcD})][3])
If !Empty(cFil)
	cFilAnt := cFil
Else
	_aMsg := {}
	zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
	AAdd(_aMsg, "")
	AAdd(_aMsg, "CNPJ no XML não relacionado a nenhuma filial") 
	AAdd(_aMsg, "O arquivo de nome " + cFile + " nao pode ser aberto!" )
	AAdd(_aMsg, " Verifique se o arquivo é válido." )
	cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
	cAssunto := "Erro na Geração de Pré-Nota via XML"
	U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)
	Return Nil
Endif
// ------------------------------------------------------------------------------------------------------

If nTipo $ "0/1" // Nota Normal Fornecedor
	
	// Caso o CNPJ nao for encontrado, abrir a tela de cadastro de fornecedores e incluir os dados principais do xml aberto
	SA2->(DbOrderNickName("CNPJIE"))
	If SA2->(!dbSeek(xFilial("SA2") + Padr(cCgc,14) + Padr(varIE,18)))
		_aMsg := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		AAdd(_aMsg, "")
		AAdd(_aMsg, "CNPJ Fornecedor de origem Não Localizado - Verifique " + Alltrim(cCgc)) 
		AAdd(_aMsg, "A arquivo de nome: " + cFile)
		AAdd(_aMsg, "Efetue o cadastro e importe novamente." )
		cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
		cAssunto := "Erro na Geração de Pré-Nota via XML"
		U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)	
	Else
		If _cFormul == "N"
			varIE := oEmitente:_IE:TEXT
		Else
			varIE := oDestino:_IE:TEXT
		Endif
		If Alltrim(varIE) <> Alltrim(SA2->A2_INSCR)
			_aMsg := {}
			zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
			AAdd(_aMsg, "")
			AAdd(_aMsg, "A Inscrição Estadual no XML (" + Alltrim(varIE) + ") é diferente do cadastro (" + Alltrim(SA2->A2_INSCR) + ") para o fornecedor: " + cCgc) 
			AAdd(_aMsg, "A arquivo de nome: " + cFile)
			AAdd(_aMsg, "Corrija o problema e importe novamente." )
			cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
			cAssunto := "Erro na Geração de Pré-Nota via XML"
			U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)	
			Return
		Endif
	Endif
Else
	If !SA1->(dbSetOrder(3), dbSeek(xFilial("SA1")+cCgc))
		_aMsg := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		AAdd(_aMsg, "")
		AAdd(_aMsg, "CNPJ Cliente de origem Não Localizado - Verifique " + Alltrim(cCgc)) 
		AAdd(_aMsg, "A arquivo de nome: " + cFile)
		AAdd(_aMsg, "Analise o cadastro e importe novamente." )
		cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
		cAssunto := "Erro na Geração de Pré-Nota via XML"
		U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)	
		PutMV("MV_PCNFE",lPcNfe)
		Return
	Endif
Endif

// ------ Verifica se a Nota Fiscal ja existe ----------------------
DbSelectArea("SF1")
SF1->(DbSetOrder(1))
If SF1->( DbSeek( xFilial("SF1") + Right("000000000" + Alltrim(OIdent:_nNF:TEXT), 9) + Padr(OIdent:_serie:TEXT, 3) + SA2->A2_COD + SA2->A2_LOJA ))
	IF nTipo $ "0/1"
		MsgAlert( "Nota No.: " + Right("000000000" + Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Ja Existe. A Importacao sera interrompida")
	Else
		MsgAlert( "Nota No.: " + Right("000000000" + Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" Ja Existe. A Importacao sera interrompida")
	Endif
	PutMV( "MV_PCNFE", lPcNfe )
	
	xFile := cRootPath + cFilAnt + "\Processado\" + Right(cFile,48)
	COPY FILE &cFile TO &xFile
	FErase(cFile)
	
	Return Nil
EndIf

aCabec	:= {}
aItens	:= {}
_aItSd1	:= {}

_cDocto	:= Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
_cSerie := OIdent:_serie:TEXT
_cForne := IIf(nTipo $ "0/1",SA2->A2_COD,SA1->A1_COD)
_cLoja  := IIf(nTipo $ "0/1",SA2->A2_LOJA,SA1->A1_LOJA)

aadd(aCabec,{"F1_TIPO"		, _cTipo 											, Nil , Nil})
aadd(aCabec,{"F1_FORMUL"	, _cFormul											, Nil , Nil})
aadd(aCabec,{"F1_DOC"		, _cDocto										 	, Nil , Nil})
aadd(aCabec,{"F1_SERIE"		, _cSerie			 								, Nil , Nil})

// NFe 3.1
iF Type("OIdent:_dEmi:TEXT")=="U"
	cData	:= Substring( Alltrim(OIdent:_dhEmi:TEXT), 1, 10 )      // VERSAO 3.1
Else
	cData	:= Substring( Alltrim(OIdent:_dEmi:TEXT), 1, 10 )
EndIf

dData	:= CTOD(Right(cData,2) + '/' + Substr(cData,6,2) + '/' + Left(cData,4))

aadd(aCabec,{"F1_DTDIGIT"	, varDtaEntrada 									, Nil , Nil})
aadd(aCabec,{"F1_EMISSAO"	, dData 											, Nil , Nil})
aadd(aCabec,{"F1_FORNECE"	, _cForne		 									, Nil , Nil})
aadd(aCabec,{"F1_LOJA"   	, _cLoja	 										, Nil , Nil})
aadd(aCabec,{"F1_ESPECIE"	, "SPED" 											, Nil , Nil})
Aadd(aCabec,{"F1_CHVNFE"	, cChvNfe 											, Nil , Nil})

If _cTipo == "N"
	aadd(aCabec,{"F1_COND"	, IIf(Empty(SA2->A2_COND),'007',SA2->A2_COND)		, Nil, Nil})
Else
	aadd(aCabec,{"F1_COND"	, IIf(Empty(SA1->A1_COND),'007',SA1->A1_COND)		, Nil, Nil})
Endif

// Primeiro Processamento. Busca de Informacoes para Pedidos de Compras
cProds	:= ""
aPedIte	:={}

For nX := 1 To Len(oDet)
	_cProdDig	:= Space(15)
	_cDescDig	:= space(55)
	_cNcmDig	:= space(8)
	
	If nTipo $ "0/1"
		cProduto:= PadR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSx3("A5_CODPRF")[1])
		
		cNCM	:= IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
		Chkproc	:= .F.
		
		SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
		If !SA5->(dbSeek(xFilial("SA5") + SA2->A2_COD + SA2->A2_LOJA + cProduto))	
			_aMsg := {}
			zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
			AAdd(_aMsg, "")
			AAdd(_aMsg, "Produto Cod.: " + Alltrim(cProduto) + " nao encontrado no relacionamento produto x fornecedor") 
			AAdd(_aMsg, "A arquivo de nome: " + cFile)
			AAdd(_aMsg, "Efetue o relacionamento e importe novamente." )
			cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
			cAssunto := "Erro na Geração de Pré-Nota via XML"
			U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)
		Else
			SB1->(dbSetOrder(1), dbSeek(xFilial("SB1") + SA5->A5_PRODUTO))		
			If ! Empty(cNCM) .and. cNCM != '00000000' .And. SB1->B1_POSIPI <> cNCM
				SB1->(RecLock("SB1",.F.))
				SB1->B1_POSIPI	:= cNCM
 				SB1->(MSUnLock())
			Endif
		Endif
	Else

		cProduto := PadR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSx3("A7_CODCLI")[1])
		
		cNCM	:= IIF( Type( "oDet[nX]:_Prod:_NCM" ) == "U", Space(12), oDet[nX]:_Prod:_NCM:TEXT )
		Chkproc	:= .F.
		
		SA7->(DbOrderNickName("CLIPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
		
		If SA7->(!dbSeek(xFilial("SA7") + SA1->A1_COD + SA1->A1_LOJA + cProduto))	
			_aMsg := {}
			zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
			AAdd(_aMsg, "")
			AAdd(_aMsg, "Produto Cod.: " + Alltrim(cProduto) + " nao encontrado no relacionamento produto x cliente,") 
			AAdd(_aMsg, "A arquivo de nome: " + cFile)
			AAdd(_aMsg, "Efetue o relacionamento e importe novamente." )
			cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
			cAssunto := "Erro na Geração de Pré-Nota via XML"
			U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)
		Else
			SB1->(dbSetOrder(1), dbSeek(xFilial("SB1")+SA7->A7_PRODUTO))
			If !Empty(cNCM) .and. cNCM != '00000000' .And. SB1->B1_POSIPI <> cNCM
				SB1->(RecLock("SB1",.F.))
				SB1->B1_POSIPI := cNCM
				SB1->(MSUnLock())
			Endif
		Endif
	Endif
	SB1->(dbSetOrder(1))
	
	cProds += ALLTRIM(SB1->B1_COD)+'/'
	
	AAdd(aPedIte,{SB1->B1_COD,Val(oDet[nX]:_Prod:_qTrib:TEXT),Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Val(oDet[nX]:_Prod:_vProd:TEXT)})

Next nX

cProds := Left(cProds,Len(cProds)-1) 	// Retira a Ultima "/" da Variavel cProds

For nX := 1 To Len(oDet)
	
	aLinha	:= {}
	cProduto:=Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),35)
	
	cNCM	:= IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
	Chkproc	:= .F.
	
	If nTipo $ "0/1"
		SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
		SA5->(dbSeek(xFilial("SA5") + SA2->A2_COD + SA2->A2_LOJA + cProduto))
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SA5->A5_PRODUTO))
	Else
		SA7->(DbOrderNickName("CLIPROD"))
		SA7->(dbSeek(xFilial("SA7") + SA1->A1_COD + SA1->A1_LOJA + cProduto))
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SA7->A7_PRODUTO))
	Endif
	
	aadd(aLinha,{"D1_COD"	 		, SB1->B1_COD								, Nil , Nil})
	Aadd(_aItSd1, {SB1->B1_COD})
	
	aadd(aLinha,{"D1_LOCAL"			, IIf(Empty(_cAlmxDig),"01",_cAlmxDig)		, Nil , Nil})
	
	If Val(oDet[nX]:_Prod:_qCom:TEXT) != 0
		aadd(aLinha,{"D1_QUANT"		, Val(oDet[nX]:_Prod:_qCom:TEXT)			, Nil , Nil})
		aadd(aLinha,{"D1_VUNIT"		, Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6) , Nil , Nil})
	Else
		aadd(aLinha,{"D1_QUANT"		, Val(oDet[nX]:_Prod:_qTrib:TEXT)			, Nil , Nil})
		aadd(aLinha,{"D1_VUNIT"		, Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT),6) , Nil , Nil})
	Endif
	
	aadd(aLinha,{"D1_TOTAL"			, Val(oDet[nX]:_Prod:_vProd:TEXT)			, Nil , Nil})
	
	_cfop:=oDet[nX]:_Prod:_CFOP:TEXT
	If Left(Alltrim(_cfop),1)="5"
		_cfop:=Stuff(_cfop,1,1,"1")
	Else
		_cfop:=Stuff(_cfop,1,1,"2")
	Endif
	
	// aadd(aLinha,{"D1_CF",_cfop,Nil,Nil})
	
	If Type("oDet[nX]:_Prod:_vDesc")<> "U"
		aadd(aLinha,{"D1_VALDESC"	, Val(oDet[nX]:_Prod:_vDesc:TEXT)			, Nil , Nil})
	Else
		aadd(aLinha,{"D1_VALDESC"	, 0											, Nil , Nil})
	Endif
	
	Do Case
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS00
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS10
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS20
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS30
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS40
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS51
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS60
			
			If XmlChildEx(oDet[nX]:_Imposto:_ICMS:_ICMS60,"_VBCSTRET")!= Nil
				_nVBCSTRET := Val(oDet[nX]:_Imposto:_ICMS:_ICMS60:_VBCSTRET:TEXT)
				aadd(aLinha,{"D1_BRICMS"	, _nVBCSTRET								, Nil , Nil})
			Endif
			If XmlChildEx(oDet[nX]:_Imposto:_ICMS:_ICMS60,"_VICMSSTRET")!= Nil
				_nVICMSSTRET := Val(oDet[nX]:_Imposto:_ICMS:_ICMS60:_VICMSSTRET:TEXT)
				aadd(aLinha,{"D1_BRICMS"	, _nVICMSSTRET								, Nil , Nil})
			Endif
			
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS70
		Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS90
	EndCase
	
	If Type("oICM:_orig:TEXT")<> "U" .And. Type("oICM:_CST:TEXT")<> "U"
		CST_Aux:=Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT)
		aadd(aLinha,{"D1_CLASFIS"	, CST_Aux									, Nil , Nil})
	Endif
	
	aadd(aItens,aLinha)
	
Next nX

If Len(aItens) > 0
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	
	SB1->(DbSetOrder(1))
	SA2->(DbSetOrder(1))
	
	MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItens,3)
	
	IF lMsErroAuto
		
		xFile := cRootPath + cFilAnt + "\Erro\" + Right(cFile,48)
		
		_aMsg := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		AAdd(_aMsg, "")
		AAdd(_aMsg, "Erro no processo de inclusão da NF!") 
		AAdd(_aMsg, "A arquivo de nome: " + cFile)
		AAdd(_aMsg, "Faça a inclusão manual e verifique o erro." )
		cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
		cAssunto := "Erro na Geração de Pré-Nota via XML"
		U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)

		COPY FILE &cFile TO &xFile
		FErase(cFile)
		
		lRetorno	:= .F.
		
	Else
		
		If SF1->F1_DOC == Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
			
			ConfirmSX8()
			xFile := cRootPath + cFilAnt + "\Processado\" + Right(cFile,48)
			
			// Grava Chave da Nota Fiscal Eletronica
			
			If SF1->(RecLock("SF1",.F.))
				SF1->F1_CHVNFE	:= cChvNfe
				SF1->F1_XIMPXML	:= "S"
				SF1->(MsUnlock())
			Endif
			
			For _nL := 1 to Len(_aItSd1)
				SD1->(DbSetOrder(1))
				If SD1->(DbSeek(xFilial("SD1") + _cDocto + Padr(_cSerie,3) + Padr(_cForne,6) + _cLoja + _aItSd1[_nL,1]))
					RecLock("SD1",.F.)
					SD1->D1_QTSEGUM	:= SD1->D1_QUANT
					SD1->(MsUnLock())
				Endif
			Next _nL
			
			_aMsg := {}
			zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
			AAdd(_aMsg, "")
			AAdd(_aMsg, Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Gerada Com Sucesso!") 
			AAdd(_aMsg, "A arquivo de nome: " + cFile)
			cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
			cAssunto := Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Gerada Com Sucesso!"
			U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)

			lRetorno	:= .T.

			COPY FILE &cFile TO &xFile
			FErase(cFile)

		Else
			_aMsg := {}
			zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
			AAdd(_aMsg, "")
			AAdd(_aMsg, Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Não Gerada.") 
			AAdd(_aMsg, "A arquivo de nome: " + cFile)
			AAdd(_aMsg, "Faça a inclusão manual e verifique o erro." )
			cEmailWf := IIf( !Empty(GetMv("MV_WFXML")), AllTrim(GetMv("MV_WFXML")), "sandro.ribeiro@erpbr.net" )
			cAssunto := Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Não Gerada"
			U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)

			lRetorno	:= .F.
		EndIf
	EndIf
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 26/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LAN0101()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_PreNotaAUT()
Return

User Function LAN0102()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_PreNotaAUT()
Return

User Function LAN0103()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_PreNotaAUT()
Return

User Function LAN0104()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_PreNotaAUT()
Return

User Function LAN0106()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_PreNotaAUT()
Return

User Function LAN0107()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_PreNotaAUT()
Return

User Function LAN0108()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_PreNotaAUT()
Return

User Function LAN0109()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_PreNotaAUT()
Return

User Function LAN0110()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_PreNotaAUT()
Return
