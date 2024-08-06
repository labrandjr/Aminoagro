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
¦¦¦Programa  ¦ PreNotaXML ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
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
User Function PreNotaXML

//Private aTipo			:= {'N','B','D'}
Private aEmpr			:= {}
Private cFile 		   	:= Space(100)
Private lPcNfe		   	:= GETMV("MV_PCNFE")
Private varDtaEntrada  	:= Date()
Private _oPT00006
Private varCodFor		:= ""
Private varLoja			:= ""
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
Private	cCodBar			:= Space(100)
Private cFile
Private cRootPath		:= GetSrvProfString("RootPath","") + "\xml\"

PutMV("MV_PCNFE",.f.)   // Parametro para identificar se vai utilizar o pedido de compra para a xml de entrada (todas as empresas = F - Nao utiliza o pedido de compra)
	
DEFINE MSDIALOG _oPT00005 FROM 50, 050 TO 250,480 TITLE OemToAnsi('Busca de XML de Notas Fiscais de Entrada') PIXEL	// "Movimentacao Bancaria"
	
@ 020,005 Say OemToAnsi("Chave NF-e") Size 040,030
@ 020,060 Get cCodBar  Picture "@!S80" Valid (AchaFile(@cCodBar),If(!Empty(cCodBar),_oPT00005:End(),.t.))  Size 150,03

@ 040,005 Say OemToAnsi("Data de Entrada") Size 070,030
@ 040,060 Get varDtaEntrada Size 40,03
	
@ 073,005 Button OemToAnsi("Baixar XML") Size 036,016 Action (GetTArq(),_oPT00005:End())
@ 073,050 Button OemToAnsi("Arquivo") Size 036,016 Action (GetArq(@cCodBar),_oPT00005:End())
@ 073,172 Button OemToAnsi("Sair") Size 036,016 Action Close(_oPT00005)
	
Activate Dialog _oPT00005 CENTERED
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetArq	  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function GetArq(cFile)

//cFile	:= cGetFile( '*.xml', 'Arquivo NFe (*.xml)', 1, 'T:\totvs\teste\xml\', .F., nOR(GETF_LOCALHARD,GETF_NETWORKDRIVE),.F., .F. )
cFile	:= cGetFile( '*.xml', 'Arquivo NFe (*.xml)' )

If !File(cFile) .and. !Empty(cFile)
	MsgAlert("Arquivo Não Encontrado no Local de Origem Indicado!")
	PutMV("MV_PCNFE",lPcNfe)
	Return
Endif
	
If nHdl == -1
	If !Empty(cFile)
		MsgAlert("O arquivo de nome " + cFile + " nao pode ser aberto! Verifique os parametros.", "Atencao!")
	Endif
	PutMV("MV_PCNFE",lPcNfe)
	Return
Endif

lRetorno := U_PROCXML(cFile)
	
PutMV("MV_PCNFE",lPcNfe)

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AchaFile	  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function AchaFile(cCodBar)

Local lOk := .f.
Local oNf
Local oNfe
Local nArq

If Empty(cCodBar)
	Return .t.
Endif

aFiles := Directory(cRootPath + "*.xml", "D")

For nArq := 1 To Len(aFiles)
	cFile := Alltrim(cRootPath + aFiles[nArq,1])
	
	nHdl    := fOpen(cFile,0)
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
	fClose(nHdl)
	If AT(AllTrim(cCodBar),AllTrim(cBuffer)) > 0
		cCodBar := cFile
		lOk := .t.
		Exit
	Endif
Next
If !lOk
	Alert("Nenhum Arquivo Encontrado, Por Favor Selecione a Opção Arquivo e Faça a Busca na Arvore de Diretórios!")
Endif

Return lOk

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PROCXML    ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function PROCXML(cFile)

Local nHdl		:= fOpen(cFile,0)
Local nX
Local _nL
Local lRetorno   := .T.

If nHdl == -1
	If !Empty(cFile)
		MsgAlert("O arquivo de nome " + cFile + " nao pode ser aberto! Verifique os parametros.", "Atencao!")
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
	MsgAlert("CNPJ no XML não relacionado a nenhuma filial! Verifique os parametros.", "Atencao!")
	Return Nil
Endif
// ------------------------------------------------------------------------------------------------------

If nTipo $ "0/1" // Nota Normal Fornecedor
	
	// Caso o CNPJ nao for encontrado, abrir a tela de cadastro de fornecedores e incluir os dados principais do xml aberto
	SA2->(DbOrderNickName("CNPJIE"))
	If SA2->(!dbSeek(xFilial("SA2") + Padr(cCgc,14) + Padr(varIE,18)))
		
		If _cFormul == "N"
			varRazao         := oEmitente:_xNome:TEXT
			varReduzido      := IIf(Type( "oEmitente:_xFant") == "U", Space(20), Substr(oEmitente:_xFANT:TEXT,1,20))
			varCNPJ          := AllTrim( IIf( Type( "oEmitente:_CPF" ) == "U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT ) )
			varInscMun       := IIf( Type( "oEmitente:_IM") == "U" , Space(20), oEmitente:_IM )
			varEndereco      := oEndEmit:_xLgr:TEXT
			varBairro        := oEndEmit:_xBairro:TEXT
			varCodCid        := oEndEmit:_cMun:TEXT
			varCidade        := oEndEmit:_xMun:TEXT
			varEstado        := oEndEmit:_UF:TEXT
			varCEP           := oEndEmit:_CEP:TEXT
			varDDD			 := IIf( Type( "oEndEmit:_fone") == "U", Space(2), Substr( oEndEmit:_fone:TEXT, 1, 2 ) )
			varTelefone      := IIf( Type( "oEndEmit:_fone") == "U", Space(8), Substr( oEndEmit:_fone:TEXT, 3, 8 ) )
			varRG            := Space(20)
			varNatFornec     := Space(10)
		Else
			varRazao         := oDestino:_xNome:TEXT
			varReduzido      := IIf(Type( "oDestino:_xFant") == "U", Space(20), Substr(oDestino:_xFANT:TEXT,1,20))
			varCNPJ          := AllTrim( IIf( Type( "oDestino:_CPF" ) == "U", oDestino:_CNPJ:TEXT, oDestino:_CPF:TEXT ) )
			varInscMun       := IIf( Type( "oDestino:_IM") == "U" , Space(20), oDestino:_IM )
			varEndereco      := oEndDest:_xLgr:TEXT
			varBairro        := oEndDest:_xBairro:TEXT
			varCodCid        := oEndDest:_cMun:TEXT
			varCidade        := oEndDest:_xMun:TEXT
			varEstado        := oEndDest:_UF:TEXT
			varCEP           := oEndDest:_CEP:TEXT
			varDDD			 := IIf( Type( "oEndDest:_fone") == "U", Space(2), Substr( oEndDest:_fone:TEXT, 1, 2 ) )
			varTelefone      := IIf( Type( "oEndDest:_fone") == "U", Space(8), Substr( oEndDest:_fone:TEXT, 3, 8 ) )
			varRG            := Space(20)
			varNatFornec     := Space(10)
		Endif
		
		IF Msgyesno("CNPJ Origem Não Localizado - Verifique " + Alltrim(cCgc) + " .Deseja Efetuar o cadastro desse fornecedor ?")
			
			DEFINE MSDIALOG _oPT00006 FROM  50, 050 TO 400,500 TITLE OemToAnsi('Cadastro de Fornecedor') PIXEL
			
			@ 020,005 Say OemToAnsi("Razao Social") 					Size 070,030
			@ 035,005 Say OemToAnsi("Nome Reduzido") 					Size 070,030
			@ 035,150 Say OemToAnsi("RG") 			   					Size 070,030
			@ 050,005 Say OemToAnsi("CNPJ/CPF") 						Size 070,030
			@ 050,150 Say OemToAnsi("I.E.") 							Size 070,030
			@ 065,005 Say OemToAnsi("Endereco") 						Size 070,030
			@ 080,005 Say OemToAnsi("Bairro") 							Size 070,030
			@ 095,005 Say OemToAnsi("Cidade") 							Size 070,030
			@ 110,005 Say OemToAnsi("CEP")	 							Size 070,030
			@ 110,150 Say OemToAnsi("IM")								Size 070,030
			@ 125,005 Say OemToAnsi("Telefone")							Size 170,030
			@ 125,130 Say OemToAnsi("Natureza")							Size 170,030
			
			@ 017,060 Get varRazao           Picture "@!" 			   				Size 150,030
			@ 032,060 Get varReduzido        Picture "@!" 			   				Size 060,030
			@ 032,160 Get varRG              Picture "@!"				   			Size 060,030
			@ 047,060 Get varCNPJ            Picture "99999999999999"   			Size 060,030
			@ 047,160 Get varIE              Picture "99999999999999"   			Size 060,030
			@ 062,060 Get varEndereco        Picture "@!" 							Size 150,030
			@ 077,060 Get varBairro          Picture "@!" 			   				Size 150,030
			@ 092,060 Get varCodCid          Picture "9999999" 						Size 030,030
			@ 092,095 Get varCidade          Picture "@!" 			   				Size 100,030
			@ 092,200 Get varEstado          Picture "@!" 			   				Size 020,030
			@ 107,060 Get varCEP             Picture "99999999"                     Size 010,030
			@ 107,160 Get varInscMun         Picture "@!"                           Size 030,030
			@ 122,060 Get varDDD             Picture "@!"                           Size 015,030
			@ 122,080 Get varTelefone        Picture "@!"                           Size 040,030
			@ 122,160 MsGet oNatFornec 	  Var varNatFornec F3 "SED" Valid( ExistCpo("SED") )  	Size 060,010 COLOR CLR_HBLUE PIXEL OF _oPT00006
			
			@ 150,110 Button OemToAnsi("Gravar")  Size 036,016 Action ( GrvForn(), _oPT00006:End() )
			@ 150,160 Button OemToAnsi("Sair")    Size 036,016 Action ( _oPT00006:End() )
			
			Activate Dialog _oPT00006 CENTERED
		Endif
		
		// Efetuar nova pesquisa para novo fornecedor
		SA2->(DbOrderNickName("CNPJIE"))
		If SA2->(!dbSeek(xFilial("SA2") + Padr(varCNPJ,14) + varIE))
			PutMV("MV_PCNFE",lPcNfe)
			Return
		Endif
	Else
		If _cFormul == "N"
			varIE := oEmitente:_IE:TEXT
		Else
			varIE := oDestino:_IE:TEXT
		Endif
		If Alltrim(varIE) <> Alltrim(SA2->A2_INSCR)
			MsgAlert("A Inscrição Estadual no XML (" + Alltrim(varIE) + ") é diferente do cadastro (" + Alltrim(SA2->A2_INSCR) + ") para o fornecedor: " + cCgc + ". Corrija o problema e importe novamente!")
			Return
		Endif
	Endif
Else
	If !SA1->(dbSetOrder(3), dbSeek(xFilial("SA1")+cCgc))
		MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgc)
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
			
			If !MsgYesNo ("Produto Cod.: " + Alltrim(cProduto) + " nao encontrado. Digita codigo de substituicao / adicionar ?" )
				PutMV("MV_PCNFE",lPcNfe)
				Return Nil
			Endif
			
			DEFINE MSDIALOG _oDlg TITLE "Digitação Código de Substituição" FROM C(177),C(192) TO C(509),C(659) PIXEL
			
			// Cria as Groups do Sistema
			@ C(002),C(003) TO C(071),C(186) LABEL "Digitação Código de Substituição " PIXEL OF _oDlg
			
			// Cria Componentes Padroes do Sistema
			@ C(012),C(017) Say 	"Produto no XML: " + cProduto Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(020),C(017) Say 	"Descricao no XML: " + Alltrim(oDet[nX]:_Prod:_xProd:TEXT) + " - NCM: " + cNCM	Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(040),C(017) Say		"Produto Protheus: " Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(039),C(055) MsGet	oEdit1 Var _cProdDig F3 "SB1"  Valid ValProd() .And. NaoVazio() Size C(060),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(048),C(017) Say 	"Descricao Protheus: " + Alltrim(_cDescDig) + " - NCM: " + _cNcmDig	Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(056),C(017) Say		"Almoxarifado: " Size C(060),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(055),C(055) MsGet	oEdit1 Var _cAlmxDig Valid NaoVazio() Size C(010),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			
			@ C(010),C(193) Button	"Processar"      Size C(037),C(012) PIXEL OF _oDlg Action( Troca() )
			@ C(031),C(193) Button	"Cancelar"       Size C(037),C(012) PIXEL OF _oDlg Action( _oDlg:End() )
			
			@ C(075),C(003) TO C(162),C(186) LABEL "Informações do XML" PIXEL OF _oDlg
			@ C(087),C(017) Say 	"Número do Documento:  " + Alltrim(OIdent:_nNF:TEXT) Size C(150),C(008) PIXEL OF _oDlg
			@ C(095),C(017) Say 	"Chave:  " + cChvNfe Size C(150),C(008) PIXEL OF _oDlg
			@ C(103),C(017) Say 	"Fornecedor:  " + "(" + SA2->A2_COD + "-" + SA2->A2_LOJA + ") " + Alltrim(SA2->A2_NOME) Size C(150),C(008) PIXEL OF _oDlg
			@ C(111),C(017) Say 	"CNPJ:  " + SA2->A2_CGC Size C(150),C(008) PIXEL OF _oDlg
			@ C(119),C(017) Say 	"Cidade/UF:  " + Alltrim(SA2->A2_MUN) + "-" + SA2->A2_EST Size C(150),C(008) PIXEL OF _oDlg
			
			oEdit1:SetFocus()
			
			ACTIVATE MSDIALOG _oDlg CENTERED
			
			If !Chkproc
				MsgAlert("Produto Cod.: " + Alltrim(cProduto) + " Nao Encontrado. A Importacao sera interrompida")
				PutMV("MV_PCNFE",lPcNfe)
				Return Nil
			Else
				If SA5->(dbSetOrder(1), dbSeek(xFilial("SA5") + SA2->A2_COD + SA2->A2_LOJA + _cProdDig ) )
					SA5->(RecLock("SA5",.F.))
				Else
					SA5->(Reclock("SA5",.T.))
				Endif
				
				SA5->A5_FILIAL		:= xFilial("SA5")
				SA5->A5_FORNECE		:= SA2->A2_COD
				SA5->A5_LOJA		:= SA2->A2_LOJA
				SA5->A5_NOMEFOR		:= SA2->A2_NOME
				SA5->A5_PRODUTO		:= _cProdDig
				SA5->A5_NOMPROD		:= oDet[nX]:_Prod:_xProd:TEXT
				SA5->A5_CODPRF		:= cProduto
				SA5->(MsUnlock())
				
			EndIf
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
			
			If !MsgYesNo("Produto Cod.: " + Alltrim(cProduto) + " nao encontrado. Digita codigo de substituicao?" )
				PutMV( "MV_PCNFE", lPcNfe )
				Return Nil
			Endif
			DEFINE MSDIALOG _oDlg TITLE "Dig.Cod.Substituicao" FROM C(177),C(192) TO C(509),C(659) PIXEL
			
			// Cria as Groups do Sistema
			DEFINE MSDIALOG _oDlg TITLE "Digitação Código de Substituição" FROM C(177),C(192) TO C(509),C(659) PIXEL
			
			// Cria Componentes Padroes do Sistema
			@ C(012),C(017) Say		"Produto no XML: " + cProduto								Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(020),C(017) Say		"Descricao no XML: " + Alltrim(oDet[nX]:_Prod:_xProd:TEXT) + " - NCM: " + cNCM	Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(040),C(017) Say		"Produto Protheus: "										Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(039),C(055) MsGet	oEdit1 Var _cProdDig F3 "SB1" 	Valid ValProd() .And. NaoVazio() Size C(060),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(048),C(017) Say		"Descricao Protheus: " + Alltrim(_cDescDig) + " - NCM: " + _cNcmDig	Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(056),C(017) Say		"Almoxarifado: "												Size C(060),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			@ C(055),C(055) MsGet	oEdit1 Var _cAlmxDig				Valid NaoVazio()			Size C(010),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
			
			@ C(010),C(193) Button 	"Processar" 												Size C(037),C(012) PIXEL OF _oDlg Action(Troca())
			@ C(031),C(193) Button 	"Cancelar"													Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())
			
			@ C(075),C(003) TO C(162),C(186) LABEL "Informações do XML" PIXEL OF _oDlg
			@ C(087),C(017) Say 	"Número do Documento:  " + Alltrim(OIdent:_nNF:TEXT) Size C(150),C(008) PIXEL OF _oDlg
			@ C(095),C(017) Say 	"Chave:  " + cChvNfe Size C(150),C(008) PIXEL OF _oDlg
			@ C(103),C(017) Say 	"Fornecedor:  " + "(" + SA1->A1_COD + "-" + SA1->A1_LOJA + ") " + Alltrim(SA1->A1_NOME) Size C(150),C(008) PIXEL OF _oDlg
			@ C(111),C(017) Say 	"CNPJ:  " + SA1->A1_CGC Size C(150),C(008) PIXEL OF _oDlg
			@ C(119),C(017) Say 	"Cidade/UF:  " + Alltrim(SA1->A1_MUN) + "-" + SA1->A1_EST Size C(150),C(008) PIXEL OF _oDlg
			
			oEdit1:SetFocus()
			
			ACTIVATE MSDIALOG _oDlg CENTERED
			
			If !Chkproc
				MsgAlert("Produto Cod.: "+cProduto+" Nao Encontrado. A Importacao sera interrompida")
				PutMV("MV_PCNFE",lPcNfe)
				Return Nil
			Else
				If SA7->(dbSetOrder(1), dbSeek(xFilial("SA7") + SA1->A1_COD + SA1->A1_LOJA + _cProdDig))
					SA7->(RecLock("SA7",.F.))
				Else
					SA7->(Reclock("SA7",.T.))
				Endif
				
				SA7->A7_FILIAL		:= xFilial("SA7")
				SA7->A7_CLIENTE		:= SA1->A1_COD
				SA7->A7_LOJA		:= SA1->A1_LOJA
				SA7->A7_DESCCLI		:= oDet[nX]:_Prod:_xProd:TEXT
				SA7->A7_PRODUTO		:= _cProdDig
				SA7->A7_CODCLI		:= cProduto
				SA7->(MsUnlock())
				
			EndIf
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
		
		//xFile := STRTRAN(Upper(cFile),"XML\", "XML\ERRO\")
		xFile := cRootPath + cFilAnt + "\Erro\" + Right(cFile,48)
		
		MSGALERT("Erro no processo de inclusão da NF! Por favor verifique.")
		MostraErro()
		
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
			
			MSGALERT(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Gerada Com Sucesso!")
			lRetorno	:= .T.

			COPY FILE &cFile TO &xFile
			FErase(cFile)

		Else
			MSGALERT(Alltrim(aCabec[3,2])+ ' / '+Alltrim(aCabec[4,2])+ " - Pré Nota Não Gerada - Tente Novamente !")
			lRetorno	:= .F.
		EndIf
	EndIf
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ C		  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

// Tratamento para tema "Flat"
If "MP8" $ oApp:cVersion
	If ( Alltrim( GetTheme()) == "FLAT" ) .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf

Return Int(nTam)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValProd    ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function ValProd()

_cDescDig := Alltrim( GetAdvFVal( "SB1", "B1_DESC", XFilial("SB1") + _cProdDig, 1, "" ) )
_cNcmDig  := GetAdvFVal( "SB1", "B1_POSIPI", XFilial("SB1") + _cProdDig, 1, "" )

Return 	ExistCpo("SB1")

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValProd    ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function Troca()

Chkproc	:= .T.
If Empty(SB1->B1_POSIPI) .and. !Empty(cNCM) .and. cNCM != '00000000'
	SB1->(RecLock("SB1",.F.))
	B1_POSIPI := cNCM
	SB1->(MSUnLock())
Endif
_oDlg:End()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GrvForn	  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de pre-nota          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function GrvForn()

varCodFor := GetSxeNum("SA2","A2_COD")
SA2->(ConfirmSX8())

If Len( varCNPJ ) = 11
	varLoja := "01"
Else
	varLoja := Substr(varCNPJ,11,2)
Endif

SA2->(RecLock("SA2",.T.))
SA2->A2_COD       := varCodFor
SA2->A2_LOJA      := varLoja
SA2->A2_NOME      := varRazao
SA2->A2_NREDUZ    := varReduzido
SA2->A2_END       := varEndereco
SA2->A2_BAIRRO    := varBairro
SA2->A2_EST       := varEstado
SA2->A2_CONTPRE   := "2"
SA2->A2_COD_MUN   := Substr( varCodCid, 3, 5 )
SA2->A2_MUN       := varCidade
SA2->A2_CEP       := varCEP
SA2->A2_TIPO      := Iif( Len( varCNPJ ) = 11, "F", "J" )
SA2->A2_CGC       := varCNPJ
SA2->A2_PFISICA   := varRG
SA2->A2_DDD       := varDDD
SA2->A2_TEL       := varTelefone
SA2->A2_INSCR     := varIE
SA2->A2_INSCRM    := varInscMun
SA2->A2_NATUREZ   := varNatFornec
SA2->A2_RECISS    := "N"
SA2->A2_PAIS      := "105"
SA2->A2_VINCULA   := "1"
SA2->A2_ID_REPR   := "2"
SA2->A2_RECINSS   := "N"
SA2->A2_TPESSOA   := Iif( Len( varCNPJ ) = 11, "PF", "CI" )
SA2->A2_B2B       := "2"
SA2->A2_PLCRRES   := "N"
SA2->A2_PLFIL     := "N"
SA2->A2_MSBLQL    := "2"
SA2->A2_RECPIS    := "1"
SA2->A2_RECCSLL   := "1"
SA2->A2_RECCOFI   := "1"
SA2->A2_IMPIP     := "3"
SA2->A2_MJURIDI   := "2"
SA2->A2_REGESIM   := "2"
SA2->A2_MINIRF    := "2"
SA2->(MsUnlock())

Return