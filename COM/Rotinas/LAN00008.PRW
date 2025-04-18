#Include "Protheus.ch"
#Include "ApWebSrv.ch"
#Include "TopConn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � BrowseXML  � Autor �  F�brica ERP.BR   �  Data  � Out;2017 ���
��+----------+------------------------------------------------------------���
���Descricao � Browse				          							  ���
���          �                                                      	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
MV_X_BXUF  - C�digo do Estado conforme IBGE
MV_X_BXAMB - Tipo de Ambiente SPED: 1 = Produ��o, 2 = Homologa��o
MV_X_BXCA  - Diret�rio do certificado "ca" - \certs\000001_ca.pem
MV_X_BXCER - Diret�rio do certificado "cert" - \certs\000001_cert.pem
MV_X_BXKEY - Diret�rio do certificado "key" - \certs\000001_key.pem
MV_X_BXPSW - Senha do Certificado
MV_X_BXPRO - Tipo do Protocolo, 0=Automatico; 1=TLSv1; 2=SSLv2; 3=SSLv3
MV_X_BXDIR - Diret�rio dos arquivos XML
MV_X_SSLIN - Define se far� a conex�o SSL com o servidor de forma an�nima, sem verifica��o de certificados ou chaves. Default .T.
/*/

User Function LAN00008(cChaveNFe)

Local aArea		:= GetArea()
Local lRet      := .T.
Local cURL      := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
Local cMsg      := ""
Local oWsdl     := Nil
Local cMsgRet   := ""
Local cError    := ""
Local cWarning  := ""
Local cXmlGZip  := ""
Local cArqXML   := ""
Local cUfAutor  := SuperGetMV("MV_X_BXUF",  .F., "35")
Local cTpAmb    := SuperGetMV("MV_X_BXAMB", .F., "1")
Local cCNPJEmp  := Alltrim(SM0->M0_CGC)
Local lContinua := .T.

Private oXmlDocZip

//Inst�ncia a classe, setando as par�metriza��es necess�rias
oWsdl := TWsdlManager():New()
oWsdl:cSSLCACertFile := SuperGetMV("MV_X_BXCA",  .F., "\certs\000001_ca.pem")
oWsdl:cSSLCertFile   := SuperGetMV("MV_X_BXCER", .F., "\certs\000001_cert.pem")
oWsdl:cSSLKeyFile    := SuperGetMV("MV_X_BXKEY", .F., "\certs\000001_key.pem")
oWsdl:cSSLKeyPwd     := SuperGetMV("MV_X_BXPSW", .F., "senha")
oWsdl:nSSLVersion    := SuperGetMV("MV_X_BXPRO", .F., "0")
oWsdl:lSSLInsecure   := SuperGetMV("MV_X_SSLIN", .F., .T.)
oWsdl:nTimeout       := 120

//Tenta fazer o Parse da URL
lRet := oWsdl:ParseURL(cURL)
If !lRet
	//ConOut("[u_zBxXML] - Erro ParseURL: " + oWsdl:cError)
	//lContinua := .F.
EndIf

If lContinua
	//Tenta definir a opera��o
	lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
	If !lRet
		ConOut("[u_zBxXML] - Erro SetOperation: " + oWsdl:cError)
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//Monta a mensagem que ser� enviada
	cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">' + CRLF
	cMsg += '    <soapenv:Header/>' + CRLF
	cMsg += '    <soapenv:Body>' + CRLF
	cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">' + CRLF
	cMsg += '                <nfeDadosMsg>' + CRLF
	cMsg += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">' + CRLF
	cMsg += '                        <tpAmb>'+cTpAmb+'</tpAmb>' + CRLF
	cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>' + CRLF
	cMsg += '                        <CNPJ>'+cCNPJEmp+'</CNPJ>' + CRLF
	cMsg += '                      <consChNFe>' + CRLF
	cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>' + CRLF
	cMsg += '                      </consChNFe>' + CRLF
	cMsg += '                    </distDFeInt>' + CRLF
	cMsg += '                </nfeDadosMsg>' + CRLF
	cMsg += '            </nfeDistDFeInteresse>' + CRLF
	cMsg += '        </soapenv:Body>' + CRLF
	cMsg += '    </soapenv:Envelope>' + CRLF
	
	//Envia uma mensagem SOAP personalizada ao servidor
	lRet := oWsdl:SendSoapMsg(cMsg)
	If ! lRet
		ConOut("[u_zBxXML] - Erro SendSoapMsg: " + oWsdl:cError)
		ConOut("[u_zBxXML] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//resposta do SOAP
	cMsgRet := oWsdl:GetSoapResponse()
	
	//Transforma a resposta em um objeto
	oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
	
	//Se existir Warning, mostra no console.log
	If !Empty(cWarning)
		ConOut("[u_zBxXML] - Alerta cWarning: " + cWarning)
	EndIf
	
	//Se houve erro, n�o permitir� prosseguir
	If !Empty(cError)
		ConOut("[u_zBxXML] - Erro cError: " + cError)
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//Se a tag DocZip existir (for diferente de Undefinied)
	If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
		
		//Pega tag que cont�m XML em zip
		cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
		
		//Gera arquivo XML
		cArqXML := fGeraXML(cXmlGZip, cChaveNFe)
	else
		conout("[u_zBxXML] - Ocorreu algum problema no momento de baixar o arquivo da sefaz!")
	endif
EndIf

RestArea(aArea)
Return cArqXML

// Gera o arquivo XML na pasta  =================================================================

Static Function fGeraXML(cConteudo, cChave)
Local aArea        := getArea()
Local lRet         := .T.
Local cArquivo     := cChave + ".xml"
Local cDiretorio := Alltrim(SuperGetMV("MV_X_BXDIR", .F., "C:\TOTVS\XML\"))
Local nTamanho     := 0
Local cUnXML       := ""
Local cDecode64  := ""
Local cArqFull   := ""
Local lHouveErro := .F.

If SubStr(cDiretorio, Len(cDiretorio), 1) != "\"
	cDiretorio += "\"
EndIf

//Define o caminho final do arquivo
cArqFull := cDiretorio + cArquivo

//Pega o tamanho e descriptografa o conte�do
nTamanho  := Len(cConteudo)
cDecode64 := Decode64(cConteudo)
lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)

If lRet
	
	If !ExistDir(cDiretorio)
		MakeDir(cDiretorio)
	EndIf
	
	lRet := MemoWrite(cDiretorio+cArquivo, cUnXML)
	
	If !lRet
		ConOut("[u_zBxXML][fGeraXML] - N�o foi possivel criar o arquivo: " + cArqFull)
		lHouveErro := .T.
	EndIf
Else
	ConOut("[u_zBxXML][fGeraXML] - Houve algum erro na descompacta��o do arquivo!")
	lHouveErro := .T.
EndIf

//Se houve erro, zera o nome do arquivo para retornar em branco
If lHouveErro
	cArqFull := ""
EndIf

RestArea(aArea)
Return cArqFull
