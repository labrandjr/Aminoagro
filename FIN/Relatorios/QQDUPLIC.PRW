#include "protheus.ch"
#include "totvs.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QQDUPLIC ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Emissão de duplicatas.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QQDUPLIC(lSched,lExibe,lEmail,aEmail)

If lSched

	ConOut("Função QQDUPLIC: Emissão de duplicatas < Início > "+DtoC(Date())+" - "+Time())
	ConOut(cEmpAnt)
	ConOut(cFilAnt)

	cQuery := " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
	cQuery += " FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery += " AND E1_XEMIDUP = ' ' "
	cQuery += " AND E1_ORIGEM = 'MATA460' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	While !Eof()
		//
		DbSelectArea("SE1")
		DbSetOrder(1)
		If DbSeek( SQL1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
			SendDupl(lSched,lExibe,lEmail,aEmail)
		Endif			
		//
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
	Enddo	
	SQL1->(DbCloseArea())

	ConOut("Função QQDUPLIC: Emissão de duplicatas < Fim > "+DtoC(Date())+" - "+Time())

Else

	SendDupl(lSched,lExibe,lEmail,aEmail)

Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ SendDupl ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Emissão de duplicatas.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function SendDupl(lSched,lExibe,lEmail,aEmail)

Local lDuplOk := .F.

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( SE1->(E1_FILIAL+E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) )
	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek( SD2->(D2_FILIAL+D2_PEDIDO) )
		DbSelectArea("SX5")
		DbSetOrder(1)
		If DbSeek( xFilial("SX5") + "WB" + PadR(SC5->C5_ZZITCTB,6) )
			U_GeraDupl(lSched,lExibe,lEmail,aEmail,SC5->C5_ZZITCTB)
			RecLock("SE1",.F.)
			SE1->E1_XEMIDUP := IIf(lSched,"1","2")
			MsUnLock()
			lDuplOk := .T.
			If !lSched .And. !lExibe
				MsgInfo("Duplicata "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")+" gerada com sucesso.")
			Endif
		Endif	
	Endif
Endif

If !lDuplOk .And. !lSched
	MsgInfo("A duplicata não foi gerada. Verifique a origem e a BU do título a receber.")
Endif

If Empty(SE1->E1_XEMIDUP)
	RecLock("SE1",.F.)
	SE1->E1_XEMIDUP := "3"
	MsUnLock()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GeraDupl ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Emissão de duplicatas.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GeraDupl(lSched,lExibe,lEmail,aEmail,zBU)

Local lExcel := ( AllTrim(GetMv("MV_XFORMDP")) == "1" )
Local lPDF   := ( AllTrim(GetMv("MV_XFORMDP")) == "2" )

If lExcel
	ConOut("Formato Excel")
	_GeraXls(lSched,lExibe,lEmail,aEmail,zBU)
ElseIf lPDF
	ConOut("Formato PDF")
	_GeraPdf(lSched,lExibe,lEmail,aEmail,zBU)
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _GeraXls ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 02/02/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Emissão de duplicatas - Formato Excel.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _GeraXls(lSched,lExibe,lEmail,aEmail,zBU)

Local aDados := {}

If !lSched
	If !File("C:\TOTVS\*.*")
		MakeDir("C:\TOTVS")
	Endif	
Endif

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )

zEnder := AllTrim(SM0->M0_ENDCOB)
zBairr := AllTrim(SM0->M0_BAIRCOB)
zMunic := AllTrim(SM0->M0_CIDCOB)
zEstad := AllTrim(SM0->M0_ESTCOB)
zCepCb := Transform(SM0->M0_CEPCOB,"@R 99999-999")
zTelef := "("+Substr(SM0->M0_TEL,1,3)+") "+Substr(SM0->M0_TEL,4,4)+"-"+Substr(SM0->M0_TEL,8,4)
zCondi := ""
zText1 := "Reconheco(cemos) a exatidao desta duplicata de VENDA MERCANTIL na importancia acima, "
zText1 += "que pagaremos a "+AllTrim(SM0->M0_NOMECOM)+", ou a sua ordem, na praca e vencimento indicados."
zText2 := "Pagamentos em cheque somente nominal a "+AllTrim(SM0->M0_NOMECOM)

AAdd(aDados, AllTrim(SM0->M0_NOMECOM)) // #ESTABELECIMENTO [1]
AAdd(aDados, Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")) // #CNPJ [2]
AAdd(aDados, zEnder+", "+zBairr+", "+zMunic+"-"+zEstad+", "+zCepCb) // # ENDERECO [3]
AAdd(aDados, zTelef) // #FONE [4]

AAdd(aDados, AllTrim(SM0->M0_NOMECOM)) // #ACEITE [5]
AAdd(aDados, DtoC(SE1->E1_EMISSAO)) // #EMISSAO [6]

AAdd(aDados, AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)) // #TITULO [7]
AAdd(aDados, Transform(SE1->E1_VALOR,"@E 99,999,999.99")) // #VALOR [8]
AAdd(aDados, AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")) // #ORDEM [9]
AAdd(aDados, DtoC(SE1->E1_VENCREA)) // #VENCTO [10]

AAdd(aDados, Transform(SE1->E1_DESCONT,"@E 99,999,999.99")) // #DESCON [11]
AAdd(aDados, zCondi) // ##CONDESP [12]

AAdd(aDados, AllTrim(SA1->A1_NOME)) // #NOMCLI [13]
AAdd(aDados, AllTrim(SA1->A1_END)) // #ENDCLI [14]
AAdd(aDados, Transform(SA1->A1_CEP,"@R 99999-999")) // #CEPCLI [15]
AAdd(aDados, AllTrim(SA1->A1_MUN)+"-"+AllTrim(SA1->A1_EST)) // #PRACACLI [16]
AAdd(aDados, IIf(SA1->A1_PESSOA=="J","CGC","CPF")) // #TITCLI [17]
AAdd(aDados, IIf(SA1->A1_PESSOA=="J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99"))) // #CGCCLI [18]
AAdd(aDados, AllTrim(SA1->A1_INSCR)) // #INSCLI [19]

If !Empty(SA1->A1_ENDCOB)
	AAdd(aDados, AllTrim(SA1->A1_NOME)) // #NOMCOB [20]
	AAdd(aDados, AllTrim(SA1->A1_ENDCOB)) // #ENDCOB [21]
	AAdd(aDados, Transform(SA1->A1_CEPC,"@R 99999-999")) // #CEPCOB [22]
	AAdd(aDados, AllTrim(SA1->A1_MUNC)+"-"+AllTrim(SA1->A1_ESTC)) // #PRACACOB [23]
	AAdd(aDados, IIf(SA1->A1_PESSOA=="J","CGC","CPF")) // #TITCOB [24]
	AAdd(aDados, IIf(SA1->A1_PESSOA=="J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99"))) // #CGCCOB [25]
	AAdd(aDados, AllTrim(SA1->A1_INSCR)) // #INSCOB [26]
Else
	AAdd(aDados, AllTrim(SA1->A1_NOME)) // #NOMCOB [20]
	AAdd(aDados, AllTrim(SA1->A1_END)) // #ENDCOB [21]
	AAdd(aDados, Transform(SA1->A1_CEP,"@R 99999-999")) // #CEPCOB [22]
	AAdd(aDados, AllTrim(SA1->A1_MUN)+"-"+AllTrim(SA1->A1_EST)) // #PRACACOB [23]
	AAdd(aDados, IIf(SA1->A1_PESSOA=="J","CGC","CPF")) // #TITCOB [24]
	AAdd(aDados, IIf(SA1->A1_PESSOA=="J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99"))) // #CGCCOB [25]
	AAdd(aDados, AllTrim(SA1->A1_INSCR)) // #INSCOB [26]
Endif

AAdd(aDados,Extenso(SE1->E1_VALOR)) // #VALEXTENSO [27]
AAdd(aDados,zText1) // #TEXTO1 [28]
AAdd(aDados,zText2) // #TEXTO2 [29]
	
cCaminho  := IIf(!lSched,"C:\TOTVS\","\duplicatas\")
oExcelXML := zExcelXML():New(.F.) //Instância o Objeto
oExcelXML:SetOrigem("\xmls\QQDUPLIC.xml") // Indica o caminho do arquivo origem (que será aberto e clonado)
oExcelXML:SetDestino(cCaminho+cFilAnt+"-"+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")+".xml") // Indica o caminho do arquivo destino (que será gerado)

oExcelXML:AddExpression("#ESTABELECIMENTO"	, aDados[1])
oExcelXML:AddExpression("#CNPJ"  			, aDados[2])
oExcelXML:AddExpression("#ENDERECO"			, aDados[3])
oExcelXML:AddExpression("#FONE"  			, aDados[4])

oExcelXML:AddExpression("#ACEITE"			, aDados[5])
oExcelXML:AddExpression("#EMISSAO"			, aDados[6])

oExcelXML:AddExpression("#TITULO"			, aDados[7])
oExcelXML:AddExpression("#VALOR"    		, aDados[8])
oExcelXML:AddExpression("#ORDEM"			, aDados[9])
oExcelXML:AddExpression("#VENCTO"			, aDados[10])

oExcelXML:AddExpression("#DESCON"   		, aDados[11])
oExcelXML:AddExpression("#CONDESP"			, aDados[12])

oExcelXML:AddExpression("#NOMCLI"	        , aDados[13])
oExcelXML:AddExpression("#ENDCLI"	        , aDados[14])
oExcelXML:AddExpression("#CEPCLI"	        , aDados[15])
oExcelXML:AddExpression("#PRACACLI"	        , aDados[16])
oExcelXML:AddExpression("#TITCLI"	        , aDados[17])
oExcelXML:AddExpression("#CGCCLI"	        , aDados[18])
oExcelXML:AddExpression("#INSCLI"	        , aDados[19])

oExcelXML:AddExpression("#NOMCOB"	        , aDados[20])
oExcelXML:AddExpression("#ENDCOB"	        , aDados[21])
oExcelXML:AddExpression("#CEPCOB"	        , aDados[22])
oExcelXML:AddExpression("#PRACACOB"	        , aDados[23])
oExcelXML:AddExpression("#TITCOB"	        , aDados[24])
oExcelXML:AddExpression("#CGCCOB"	        , aDados[25])
oExcelXML:AddExpression("#INSCOB"	        , aDados[26])

oExcelXML:AddExpression("#VALEXTENSO"       , aDados[27])
oExcelXML:AddExpression("#TEXTO1"           , aDados[28])
oExcelXML:AddExpression("#TEXTO2"           , aDados[29])
	
oExcelXML:MountFile() // Monta o arquivo

If lEmail
	zArqServd := "\duplicatas\"+cFilAnt+"-"+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")+".xml"
	If !lSched
		zArqLocal := cCaminho+cFilAnt+"-"+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")+".xml"
		CpyT2S( zArqLocal, "\duplicatas", .F. )
	Endif	
	aAttach := {}
	AAdd(aAttach,zArqServd)
	MMess040(aAttach,aEmail,zBU)
	fErase(zArqServd)
Endif

If !lSched .And. lExibe
	oExcelXML:ViewSO()
Endif	

oExcelXML:Destroy(.F.)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _GeraPdf ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 02/02/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Emissão de duplicatas - Formato PDF.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _GeraPdf(lSched,lExibe,lEmail,aEmail,zBU)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp	 := cStartPath + "logo_premiacao.bmp"
Local oFont07N   := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
Local oFont08    := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Local oFont08N   := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Local oFont10    := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12N   := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Local zPathPDF   := IIf(!lSched,"C:\TOTVS\","\duplicatas\")
Local zPdf       := cFilAnt+"-"+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")
Private oDup

If !lSched
	If !File("C:\TOTVS\*.*")
		MakeDir("C:\TOTVS")
	Endif	
Endif

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )

zEnder := AllTrim(SM0->M0_ENDCOB)
zBairr := AllTrim(SM0->M0_BAIRCOB)
zMunic := AllTrim(SM0->M0_CIDCOB)
zEstad := AllTrim(SM0->M0_ESTCOB)
zCepCb := Transform(SM0->M0_CEPCOB,"@R 99999-999")
zTelef := "("+Substr(SM0->M0_TEL,1,3)+") "+Substr(SM0->M0_TEL,4,4)+"-"+Substr(SM0->M0_TEL,8,4)
zCondi := ""

oDup:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@oDup,,,,, (!lSched .And. lExibe) )
oDup:SetResolution(72)
oDup:SetPortrait()
oDup:SetPaperSize(DMPAPER_A4)
oDup:SetMargin(60,60,60,60)
oDup:cPathPDF := zPathPDF    

oDup:StartPage()

oDup:SayBitmap(0030, 0000, cLogoTp, 0150, 0040)

oDup:Box(0030, 0150, 0080, 0550)
oDup:Say(0040, 0155, AllTrim(SM0->M0_NOMECOM),oFont12N)

oDup:Say(0055, 0155, "CNPJ: ",oFont10)
oDup:Say(0055, 0200, Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont10)

oDup:Say(0065, 0155, "Endereço: ",oFont10)
oDup:Say(0065, 0200, zEnder+", "+zBairr+", "+zMunic+"-"+zEstad+", "+zCepCb,oFont10)

oDup:Say(0075, 0155, "Fone: ",oFont10)
oDup:Say(0075, 0200, zTelef,oFont10)

oDup:Box(0085, 0150, 0100, 0550)
oDup:Say(0095, 0155, "Emissão: ",oFont10)
oDup:Say(0095, 0200, DtoC(SE1->E1_EMISSAO),oFont10)

nLnE := IIf(AllTrim(SM0->M0_CODFIL)$("0101,0102,0106,0107"),385,IIf(AllTrim(SM0->M0_CODFIL)$("0103,0104,0108"),325,345))
oDup:Box(0100, 0000, 0395, 0150)
oDup:Say(nLnE, 0050, AllTrim(SM0->M0_NOMECOM),oFont10N,,,0270)
oDup:Say(0350, 0090, "_________________________________________________",oFont08,,,0270)
oDup:Say(0290, 0100, "Assinatura do Emitente",oFont08,,,0270)

oDup:Box(0100, 0150, 0125, 0215)
oDup:Box(0100, 0215, 0125, 0280)
oDup:Box(0100, 0280, 0125, 0345)
oDup:Box(0100, 0345, 0125, 0410)

oDup:Say(0115, 0165, "Fatura No.",oFont10N)
oDup:Say(0110, 0235, "Fatura/",oFont10N)
oDup:Say(0120, 0230, "Duplicata",oFont10N)
oDup:Say(0115, 0293, "Duplicata",oFont10N)
oDup:Say(0115, 0363, "Vencto.",oFont10N)

oDup:Box(0100, 0410, 0155, 0550)
oDup:Say(0120, 0440, "Para uso da instituição",oFont10)
oDup:Say(0135, 0460, "financeira",oFont10)

oDup:Box(0125, 0150, 0155, 0215)
oDup:Box(0125, 0215, 0155, 0280)
oDup:Box(0125, 0280, 0155, 0345)
oDup:Box(0125, 0345, 0155, 0410)

zColOrd := IIf( Len(AllTrim(SE1->E1_PREFIXO))>1,0155,0160)
oDup:Say(0143, zColOrd, AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM),oFont10)

oDup:Say(0135, 0232, "Valor R$",oFont10)
oDup:Line(0140, 0215, 0140, 0280)
oDup:Say(0150, 0230, Transform(SE1->E1_VALOR,"@E 999,999.99"),oFont10)

oDup:Say(0135, 0293, "No.Ordem",oFont10)
oDup:Line(0140, 0280, 0140, 0345)
zColOrd := IIf(!Empty(SE1->E1_PARCELA),0288,0290)
oDup:Say(0150, zColOrd, AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),""),oFont10)

oDup:Say(0143, 0358, DtoC(SE1->E1_VENCREA),oFont10)

oDup:Say(0165, 0155, "Desconto de R$: "+Transform(SE1->E1_DESCONT,"@E 99,999.99"),oFont10)
oDup:Say(0175, 0155, "Condições especiais:",oFont10)

oDup:Box(0180, 0150, 0235, 0550)
oDup:Say(0190, 0155, "Nome do sacado:",oFont10)
oDup:Say(0200, 0155, "Endereço:",oFont10)
oDup:Say(0210, 0155, "CEP:",oFont10)
oDup:Say(0220, 0155, "Praça de Pagamento:",oFont10)
oDup:Say(0230, 0155, IIf(SA1->A1_PESSOA=="J","CGC","CPF"),oFont10)
oDup:Say(0230, 0410, "I.E.: "+AllTrim(SA1->A1_INSCR),oFont10)

oDup:Say(0190, 0250, AllTrim(SA1->A1_NOME),oFont08)
oDup:Say(0200, 0250, AllTrim(SA1->A1_END),oFont08)
oDup:Say(0210, 0250, Transform(SA1->A1_CEP,"@R 99999-999"),oFont08)
oDup:Say(0220, 0250, AllTrim(SA1->A1_MUN)+"-"+AllTrim(SA1->A1_EST),oFont08)
oDup:Say(0230, 0250, IIf(SA1->A1_PESSOA=="J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99")),oFont08)

oDup:Say(0250, 0155, "Endereço de Cobrança:",oFont08N)
oDup:Box(0255, 0150, 0310, 0550)
oDup:Say(0265, 0155, "Nome do sacado:",oFont10)
oDup:Say(0275, 0155, "Endereço:",oFont10)
oDup:Say(0285, 0155, "CEP:",oFont10)
oDup:Say(0295, 0155, "Praça de Pagamento:",oFont10)
oDup:Say(0305, 0155, IIf(SA1->A1_PESSOA=="J","CGC","CPF"),oFont10)
oDup:Say(0305, 0410, "I.E.: "+AllTrim(SA1->A1_INSCR),oFont10)

If !Empty(SA1->A1_ENDCOB)
	oDup:Say(0265, 0250, AllTrim(SA1->A1_NOME),oFont08)
	oDup:Say(0275, 0250, AllTrim(SA1->A1_ENDCOB),oFont08)
	oDup:Say(0285, 0250, Transform(SA1->A1_CEPC,"@R 99999-999"),oFont08)
	oDup:Say(0295, 0250, AllTrim(SA1->A1_MUNC)+"-"+AllTrim(SA1->A1_ESTC),oFont08)
	oDup:Say(0305, 0250, IIf(SA1->A1_PESSOA=="J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99")),oFont08)
Else
	oDup:Say(0265, 0250, AllTrim(SA1->A1_NOME),oFont08)
	oDup:Say(0275, 0250, AllTrim(SA1->A1_END),oFont08)
	oDup:Say(0285, 0250, Transform(SA1->A1_CEP,"@R 99999-999"),oFont08)
	oDup:Say(0295, 0250, AllTrim(SA1->A1_MUN)+"-"+AllTrim(SA1->A1_EST),oFont08)
	oDup:Say(0305, 0250, IIf(SA1->A1_PESSOA=="J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99")),oFont08)
Endif

oDup:Box(0320, 0150, 0345, 0215)
oDup:Say(0330, 0165, "Valor por",oFont10)
oDup:Say(0340, 0167, "extenso",oFont10)

oDup:Box(0320, 0215, 0345, 0550)
oDup:Say(0336, 0220, Extenso(SE1->E1_VALOR),oFont07N)

oDup:Box(0355, 0150, 0380, 0550)
oDup:Say(0365, 0155, "Reconheço(cemos) a exatidão desta duplicata de VENDA MERCANTIL na importância acima, que pagaremos à",oFont08)
oDup:Say(0375, 0155, AllTrim(SM0->M0_NOMECOM)+", ou a sua ordem, na praça e vencimento indicados.",oFont08)

oDup:Box(0380, 0150, 0395, 0550)
oDup:Say(0390, 0155, "Pagamentos em cheque somente nominal à "+AllTrim(SM0->M0_NOMECOM),oFont08)

oDup:Say(0415, 0130, "Em",oFont10)

oDup:Line(0420, 0150, 0420, 0250)
oDup:Say(0430, 0172, "Data do Aceite",oFont10)

oDup:Line(0420, 0350, 0420, 0550)
oDup:Say(0430, 0412, "Assinatura do Sacado",oFont10)

oDup:EndPage()

cFilePrint := zPathPDF+zPdf+".pdf"
If !lSched .And. lExibe
	oDup:Preview()
Else
	File2Printer( cFilePrint, "PDF" )
	oDup:Preview()
Endif	

If lEmail
	zArqServd := "\duplicatas\"+cFilAnt+"-"+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")+".pdf"
	If !lSched
		zArqLocal := "C:\TOTVS\"+cFilAnt+"-"+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")+".pdf"
		CpyT2S( zArqLocal, "\duplicatas", .F. )
	Endif	
	aAttach := {}
	AAdd(aAttach,zArqServd)
	MMess040(aAttach,aEmail,zBU)
	fErase(zArqServd)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess040 ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 20/10/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger duplicatas.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function MMess040(aAttach,aEmail,zBU)

Local aArea    := GetArea()
Local zUsrParm := AllTrim(GetMv("MV_XEMBLCR"))
Local zUsrMail := ""
Local aUsrMail := {}
Local aMailEnv := {}
Local _x

If Len(aEmail) > 0
	For _x := 1 to Len(aEmail)
		AAdd(aMailEnv,AllTrim(aEmail[_x]))
	Next _x
ElseIf !Empty(zUsrParm) // Se o parâmetro estiver preenchido, assume a preferência. Ambiente de Testes.
	zUsrMail := zUsrParm
Else
	DbSelectArea("SX5")
	DbSetOrder(1)
	If DbSeek( xFilial("SX5") + "WB" + PadR(zBU,6) )
		zUsrMail := AllTrim(SX5->X5_DESCRI)
	Endif
Endif

If !Empty(zUsrMail)
	nPosic  := 0
	aLinha  := {}
	cTxtLin := zUsrMail
	While (!Empty(cTxtLin))
		If (((nPosic := AT(",",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo
	aUsrMail := aClone(aLinha)
Endif	

For _x := 1 to Len(aUsrMail)
	zEmail := UsrRetMail(aUsrMail[_x])
	If !Empty(zEmail)
		nPosic := AT("@",zEmail)
		If nPosic > 0
			AAdd(aMailEnv,zEmail)
		Endif
	Endif
Next _x	

For _x := 1 to Len(aMailEnv)
	zEmail := aMailEnv[_x]
	If !Empty(zEmail)
		nPosic := AT("@",zEmail)
		If nPosic > 0
			cAssunto := "Duplicata "+cFilAnt+"-"+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),"")+" < "+zBU+" >"
			//
			aMensage := {}
			AAdd(aMensage, "Evento X05 - Envio de duplicata para aceite do cliente")
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial.: "+xFilial("SE1"))
			AAdd(aMensage, ">> Prefixo: "+AllTrim(SE1->E1_PREFIXO))
			AAdd(aMensage, ">> Título.: "+AllTrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"-"+AllTrim(SE1->E1_PARCELA),""))
			AAdd(aMensage, ">> Cliente: "+AllTrim(SE1->E1_CLIENTE)+" - "+AllTrim( RetField("SA1",1,xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA),"A1_NOME") ))
			AAdd(aMensage, ">> RTV....: "+AllTrim(SE1->E1_VEND1) +" - "+AllTrim( RetField("SA3",1,xFilial("SA3") + SE1->E1_VEND1 ,"A3_NOME") ))
			AAdd(aMensage, ">> Gerente: "+AllTrim(SE1->E1_GEREN1)+" - "+AllTrim( RetField("SA3",1,xFilial("SA3") + SE1->E1_GEREN1,"A3_NOME") ))
            //
			U_MailNotify(zEmail, cAssunto, aMensage, .F., aAttach)
		Endif
	Endif
Next _x	
	
RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QQDUP02()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return

User Function QQDUP03()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return

User Function QQDUP04()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return

User Function QQDUP06()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return

User Function QQDUP07()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return

User Function QQDUP08()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return

User Function QQDUP09()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return

User Function QQDUP10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_QQDUPLIC(.T.,.F.,.T.,{})
Return
