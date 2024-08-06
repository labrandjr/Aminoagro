#include "rwmake.ch"
#include "protheus.ch"
#include "xmlxfun.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TRFAXML  ¦ Autor ¦ Fábrica ERP.BR  ¦ Data    ¦ 14/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transfere os arquivos Xml para Cloud diretório Importador. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TRFAXML()

Local cPerg   := "TRFAXML"
Local lImpXml := GetMv("MV_IMPXML")
Local nVersao := 2

If lImpXml
	If Pergunte(cPerg,.T.)
		If nVersao == 1
			MsgRun("Aguarde, transferindo arquivos para o diretório do Importador","Processando",{|| TransfXml() })
		Else
			MsgRun("Aguarde, transferindo arquivos para o diretório do Importador","Processando",{|| TrfXmlve2() })
		Endif	
	Endif
Else
	MsgInfo("Importador de Xml não habilitado (MV_IMPXML).")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TrfXmlve2  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transfere arquivos Xml para o servidor.					  ¦¦¦
¦¦¦          ¦ Utiliza diretório original mapeado e não move os arquivos. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function TrfXmlve2()

Local cDirGeral := AllTrim(GetMv("MV_NGINN"))+"\"
Local nTotArq   := 0
Local _xml

// Diretório origem selecionado
cPatXml := AllTrim(mv_par01)
If Substr(cPatXml,Len(Alltrim(cPatXml)),1) <> "\"
	cPatXml += "\" 
Endif

// Monta um array com todos os arquivos
aArqXml := Directory(cPatXml + "*.xml", "D")

// Percorre os arquivos e transfere para o servidor
For _xml := 1 to Len(aArqXml)
	cFileXml := Alltrim(cPatXml + aArqXml[_xml][1])
	If aArqXml[_xml][3] >= mv_par02 .And. aArqXml[_xml][3] <= mv_par03
		__CopyFile( cFileXml, cDirGeral + aArqXml[_xml][1] )
		nTotArq += 1
	Endif	
Next _xml

If Len(aArqXml) == 0
	MsgAlert("Arquivos não localizados no diretório informado.")
Else
	MsgInfo(AllTrim(STR(nTotArq))+" arquivo(s) transferido(s).")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TransfXml  ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transfere arquivos Xml para o servidor.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function TransfXml()

Local cError    := ""
Local cWarning  := ""
Local cDirGeral := AllTrim(GetMv("MV_NGINN"))+"\"
Local _xml

// Diretório origem selecionado
cPatXml := AllTrim(mv_par01)
If Substr(cPatXml,Len(Alltrim(cPatXml)),1) <> "\"
	cPatXml += "\" 
Endif
cPatTrf := cPatXml + "transferidos\"

If !ExistDir(cPatTrf)
	MakeDir(cPatTrf)
Endif

// Monta um array com todos os arquivos
aArqXml := Directory(cPatXml + "*.xml", "D")

// Percorre os arquivos e transfere para o servidor
For _xml := 1 to Len(aArqXml)

	cFileXml := Alltrim(cPatXml + aArqXml[_xml][1])
	__CopyFile( cFileXml, cDirGeral + aArqXml[_xml][1] )

	//Gera o Objeto XML
	oXml := XmlParserFile( cDirGeral + aArqXml[_xml][1], "_", @cError, @cWarning )
	If (oXml == Nil )
		MsgStop("Falha ao gerar Objeto Xml: "+cError+" / "+cWarning)
		Loop
	Endif

	If ValType( XmlChildEx(oXML,"_PROCESSAMENTO") ) == "O"

		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_CHAVE_ACESSO") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_CHAVE_ACESSO")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_CHNFE") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_CHNFE")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_CSTAT") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_CSTAT")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_DHRECBTO") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_DHRECBTO")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_MOD") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_MOD")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_NPROT") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_NPROT")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_REVALIDA") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_REVALIDA")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_TIPO") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_TIPO")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_TPIMP") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_TPIMP")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_UF") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_UF")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_VALIDA_ASSINATURA") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_VALIDA_ASSINATURA")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_VALIDA_DIGEST") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_VALIDA_DIGEST")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_VALIDA_SCHEMA") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_VALIDA_SCHEMA")
		Endif	
		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_VALIDA_USO") ) == "O"
			XmlDelNode(oXml:_PROCESSAMENTO,"_VALIDA_USO")
		Endif	

		If ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_NFEPROC") ) == "O"
			oXml := XmlGetParent(oXml:_PROCESSAMENTO:_NFEPROC)
		ElseIf ValType( XmlChildEx(oXML:_PROCESSAMENTO,"_CTEPROC") ) == "O"
			oXml := XmlGetParent(oXml:_PROCESSAMENTO:_CTEPROC)
		Endif	

		If ValType( XmlChildEx(oXML,"_NFEPROC") ) == "O"
			SAVE oXML XMLFILE cFileXml
			SAVE oXML XMLFILE cDirGeral + aArqXml[_xml][1]
		Else
			If ValType( XmlChildEx(oXML,"_CTEPROC") ) == "O"
				SAVE oXML XMLFILE cFileXml
				SAVE oXML XMLFILE cDirGeral + aArqXml[_xml][1]
			Endif	
		Endif

	Endif

	If File(cDirGeral + aArqXml[_xml][1])
		__CopyFile( cFileXml, cPatTrf + aArqXml[_xml][1] )
		If File(cPatTrf + aArqXml[_xml][1])
			Ferase(cFileXml)
		Endif
	Endif

Next _xml

Return

