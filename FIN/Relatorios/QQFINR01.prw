#Include 'Protheus.ch'
#Include 'TopConn.ch'

User Function tela02
	
	rpcsetenv("G1","0101")
	//rpcsetenv("99","01",)
	define msdialog omainwnd from 0,0 to 600,800 pixel
	@ 05,05 button "OK" of omainwnd pixel action u_QQFINR01()
	activate msdialog omainwnd
	
Return


/*/{protheus.doc}QQFINR01
Função para obter recibo
@author Gustavo Luiz
@since  29/03/2016
/*/
User Function QQFINR01()
	
	Local oReport			:= Nil
	Private aRet			:= {}
	Private aDadosEmpres	:={}
	Private nValor			:= 0
	Private cValorExtenso	:=""
	Private cTituloDe		:=""
	Private cTituloAte		:=""
	Private cClienteDe		:=""
	Private cClienteAte		:=""
	Private cDataBxDe		:=""
	Private cDataBxAte		:=""
	
	If Perguntas()
		
		cTituloDe	:= aRet[1]
		cTituloAte	:= aRet[2]
		cClienteDe	:= aRet[3]
		cClienteAte	:= aRet[4]
		cDataBxDe	:= dToS(aRet[5])
		cDataBxAte	:= dToS(aRet[6])
		
		oReport:=ReportDef()
		oReport:PrintDialog()
		
	EndIf
	
Return

/**
* Define as seções do relatório
* aDadosEmpres[1] -> nome comercial
* aDadosEmpres[2] -> endereço
* aDadosEmpres[3] -> cnpj/ie
* aDadosEmpres[4] -> cidade
* aDadosEmpres[5] -> estado
**/
Static Function ReportDef()
	
	Local oReport		:= Nil
	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Local oSection3		:= Nil
	Local oSection4		:= Nil
	Local oSection5		:= Nil
	Local oSection6		:= Nil
	Local oSection7		:= Nil
	
	
	aDadosEmpres:=abreEmpresa()
	
	oReport := tReport():New(FunName(),"Recibo",,{|oReport| PrintRep(oReport)})
	oReport:oFontBody:=tFont():New("Courier New",,14)
	oReport:oFontBody:=tFont():New("Courier New",,14)
	oReport:nLineHeight:=45 //para não sair colado nas linhas com o aumento da fonte
	oReport:nFontBody:=14
	oReport:lHeaderVisible := .F. //desabilita o cabeçalho padrão
	
	
	//oReport:SetLandscape()
	oReport:oPage:SetPaperSize(9)//Define o tamanho do papel A4
	
	//IMPRESSÃO DO CABEÇALHO: NOME COMERCIAL, ENDEREÇO, CNPJ
	oSection1:= TrSection():New(oReport,"NOMEFANTASIA")
	TrCell():New(oSection1,"NOMEFANTASIA"	,,"",		"@!",300,.F.,{|| aDadosEmpres[1]},"CENTER",,"CENTER")
	oSection2:= TrSection():New(oReport,"ENDERECO")
	TrCell():New(oSection2,"ENDERECO"		,,"",		"@!",300,.F.,{|| aDadosEmpres[2]},"CENTER",,"CENTER")
	oSection3:= TrSection():New(oReport,"CNPJ/IE")
	TrCell():New(oSection3,"CNPJ/IE"		,,"",		"@!",300,.F.,{|| aDadosEmpres[3]},"CENTER",,"CENTER")
	
	//IMPRESSÃO INFORMAÇOES DO RECIBO
	oSection4:= TrSection():New(oReport,"DADOSRECIBO")
	TrCell():New(oSection4,"EMPRESA"	,,"EMPRESA:",				"@!",030,.F.,{|| cFilAnt})
	TrCell():New(oSection4,"TITULO"		,,"TITULO Nº:",				"@!",030,.F.,{|| QRY->E5_NUMERO})
	TrCell():New(oSection4,"VALOR"		,,"VALOR DO RECIBO (R$):",	"@!",100,.F.,{|| TRANSFORM(QRY->E5_VALOR, PESQPICT("SE5","E5_VALOR"))})
	
	//RECEBEMOS DE:
	oSection5:= TrSection():New(oReport,"DADOSRECEBIDO")
	TrCell():New(oSection5,"CODIGO"		,,"CODIGO"	,	"@!",050,.F.,{|| QRY->E5_CLIFOR})
	TrCell():New(oSection5,"CLIENTE"	,,"CLIENTE"	,	"@!",050,.F.,{|| AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E5_CLIFOR+QRY->E5_LOJA,"A1_NOME"))})
	TrCell():New(oSection5,"CNPJ/CPF"	,,"CNPJ/CPF",	"@!",050,.F.,{|| Transform(AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E5_CLIFOR+QRY->E5_LOJA,"A1_CGC")),"@R 99.999.999/9999-99")})
	TrCell():New(oSection5,"I.E/R.G"	,,"I.E/R.G"	,	"@!",050,.F.,{|| AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E5_CLIFOR+QRY->E5_LOJA,"A1_INSCR"))})
	
	//RELAÇÃO DE DUPLICATAS
	oSection6:= TrSection():New(oReport,"RELACAODUPLICATAS")
	TrCell():New(oSection6,"EMP"		,,"EMP."		,	PesqPict('SE5',"E5_FILIAL")	,050,.F.,{|| cFilAnt})
	TrCell():New(oSection6,"DOC.FISCAL"	,,"DOC. FISCAL.",	PesqPict('SE5',"E5_DOCUMEN"),050,.F.,{|| QRY->E5_DOCUMEN})
	TrCell():New(oSection6,"DESCRICAO"	,,"DESCRICAO."	,	PesqPict('SE5',"E5_TIPO")	,050,.F.,{|| QRY->E5_TIPO})
	TrCell():New(oSection6,"VENCIMENTO"	,,"VENCIMENTO."	,	PesqPict('SE5',"E5_VENCT")	,050,.F.,{|| STOD(QRY->E5_VENCTO)})
	TrCell():New(oSection6,"V.PRINCIPAL",,"V.PRINCIPAL.",	PesqPict('SE1',"E1_VALOR")	,050,.F.,{|| QRY->E1_VALOR},	"RIGHT",,"RIGHT")
	TrCell():New(oSection6,"VALOR"		,,"VALOR",			PesqPict('SE1',"E1_VLCRUZ")	,050,.F.,{|| QRY->E1_VLCRUZ},	"RIGHT",,"RIGHT")
	TrCell():New(oSection6,"ACRESCIMO"	,,"ACRESCIMO",		PesqPict('SE1',"E1_ACRESC")	,050,.F.,{|| QRY->E5_VLACRES},	"RIGHT",,"RIGHT")
	TrCell():New(oSection6,"DESCONTO"	,,"DESCONTO",		PesqPict('SE1',"E1_DECRESC"),050,.F.,{|| QRY->E5_VLDECRE},	"RIGHT",,"RIGHT")
	TrCell():New(oSection6,"TOTAL"		,,"TOTAL",			PesqPict('SE5',"E5_VALOR")	,050,.F.,{|| QRY->E5_VALOR},	"RIGHT",,"RIGHT")
	
	oSection7:= TrSection():New(oReport,"VALORDEVIDO")
	//TrCell():New(oSection7,"VALOR"			,,"",			"@!"	,300,.F.,{|| cValToChar(QRY->E5_VALOR) +" "+cValorExtenso },	"LEFT",,"LEFT")
	TrCell():New(oSection7,"VALOR"			,,"",			"@!"	,300,.F.,{|| AllTrim(TRANSFORM(QRY->E5_VALOR, PESQPICT("SE5","E5_VALOR"))) +" "+cValorExtenso },	"LEFT",,"LEFT")
	
	oSection1:SetLineStyle(.T.)
	oSection2:SetLineStyle(.T.)
	oSection3:SetLineStyle(.T.)
	oSection4:SetLineStyle(.T.)
	oSection5:SetLineStyle(.F.)
	oSection6:SetLineStyle(.F.)
	oSection7:SetLineStyle(.T.)
	
	oSection7:SetLineBreak(.F.)
	
	
Return oReport

Static Function PrintRep(oReport)
	
	Local oSection1 	:= oReport:Section(1)
	Local oSection2		:= oReport:Section(2)
	Local oSection3		:= oReport:Section(3)
	Local oSection4		:= oReport:Section(4)
	Local oSection5		:= oReport:Section(5)
	Local oSection6		:= oReport:Section(6)
	Local oSection7		:= oReport:Section(7)
	Local nTamanhoPag	:= oReport:PageWidth()
	Local cTraco		:= PADR("-",500,"-")
	Local aTiposDoc		:= {}
	Local nPosVL		:= 0
	Local nPosES		:= 0
	Local nTituloImpre	:= 0
	Local aTitulosImpre	:= {}
	Local nQtd			:= 0
	
	nQtd:=QRYSE5()
	oReport:SetMeter(nQtd)
	While QRY->(!Eof())
		
		QRYDOC()
		
		GetTipoDoc(@aTiposDoc)
		IsVLES(@nPosVL,@nPosES,aTiposDoc)
		IsTituloImpresso(aTitulosImpre,@nTituloImpre)
		
		
		If nPosVL>0 .and. nPosES == 0 .and. nTituloImpre==0
			
			aAdd(aTitulosImpre,QRY->E5_NUMERO)
			oSection1:Init()
			oSection1:PrintLine()
			oReport:SkipLine(0)
			oSection1:Finish()
			oSection2:Init()
			oSection2:PrintLine()
			oSection2:Finish()
			oSection3:Init()
			oSection3:PrintLine()
			oSection3:Finish()
			
			oReport:PrintText(cTraco)
			oReport:PrintText("RECEBEMOS DE:",,(nTamanhoPag/2)-50)
			oReport:PrintText(cTraco)
			
			oSection4:Init()
			oSection4:PrintLine()
			oSection4:Finish()
			
			oSection5:Init()
			oSection5:PrintLine()
			oSection5:Finish()
			
			cValorExtenso	:= "(*****"+AllTrim(Extenso(QRY->E5_VALOR))+"*****)"
			oReport:PrintText(cTraco)
			oReport:PrintText("A IMPORTANCIA DE:",,(nTamanhoPag/2)-50)
			oSection7:Init()
			oSection7:PrintLine()
			oSection7:Finish()
			oReport:PrintText(cTraco)
			oReport:PrintText("REFERENTE A:")
			oReport:PrintText("RECEBIMENTO DUPLICATA "+ AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E5_CLIFOR+QRY->E5_LOJA,"A1_NOME")))
			
			oReport:SkipLine(5)
			oReport:PrintText(cTraco)
			oReport:PrintText("RELACAO DE DUPLICATAS:",,(nTamanhoPag/2)-60)
			oReport:PrintText(cTraco)
			oSection6:Init()
			oSection6:PrintLine()
			oSection6:Finish()
			oReport:SkipLine(30)
			
			oReport:PrintText("O presente somente vale como quitacao apos a liquidacao do(s) Documento(s) caracterizado(s) acima.",oReport:PageHeight()-230)
			oReport:PrintText(aDadosEmpres[4]+" - "+aDadosEmpres[5]+", "+DtExtenso(),oReport:PageHeight()-180,500)
			oReport:PrintText('_____________________________________________________',oReport:PageHeight()-100,(500))
			oReport:PrintText(aDadosEmpres[1],(oReport:PageHeight())-20,(500))
			oReport:Endpage()
			
		EndIf
		
		QRYDOC->(DbCloseArea())
		QRY->(dbskip())
		oReport:IncMeter()
		
	EndDo
	QRY->(DbCloseArea())
Return


/**
* Caixa para os dados dos parâmetros
**/
Static Function Perguntas()
	
	Local aPergs  := {}
	
	aAdd(aPergs,{1,"Título de" 		,Space(TamSx3("E5_NUMERO")[1])	,"@!",'.T.',"ZZTIT",'.T.',50,.F.})
	aAdd(aPergs,{1,"Título até" 	,Space(TamSx3("E5_NUMERO")[1])	,"@!",'.T.',"ZZTIT",'.T.',50,.F.})
	aAdd(aPergs,{1,"Cliente De"  	,Space(TamSx3("A1_COD")[1])		,"@!",'.T.',"SA1",'.T.',50,.F.})
	aAdd(aPergs,{1,"Cliente até" 	,Space(TamSx3("A1_COD")[1])		,"@!",'.T.',"SA1",'.T.',50,.F.})
	aAdd(aPergs,{1,"Data Baixa de"	,Stod(""),,'.t.',,'.t.',50,.f.})
	aAdd(aPergs,{1,"Data Baixa até"	,Stod(""),,'.t.',,'.t.',50,.f.})
	
Return ParamBox(aPergs,"Parametros",aRet,,,,,,,FUNNAME(),.t.,.t.)


/**
* Função que obtém os dados da filial corrente cadastrada no SIGAMAT.EMP
**/
Static Function abreEmpresa()
	
	cNomeComerEmpresa 	:= ""
	cEndereco			:= ""
	cCnpj				:= ""
	cCidade				:= ""
	cEstado				:= ""
	
	MSOpenDbf(.T.,"DBFCDX","SIGAMAT.EMP", "NEWSM0",.T.,.F.)
	DbSetIndex("SIGAMAT.IND")
	SET(_SET_DELETED, .T.)
	DbSelectArea("NEWSM0")
	NEWSM0->( dbSetOrder(1))
	NEWSM0->( dbGotop())
	
	While NEWSM0->(!Eof())
		If cFilant == AllTrim(NEWSM0->M0_CODFIL)
			cNomeComerEmpresa 	:= AllTrim(NEWSM0->M0_NOMECOM)
			cEndereco			:= AllTrim(NEWSM0->M0_ENDCOB) + " - " + AllTrim(NEWSM0->M0_BAIRCOB) + ", " + AllTrim(NEWSM0->M0_CIDENT) + " - " + AllTrim(NEWSM0->M0_ESTENT )
			cCNPJ				:= Transform( AllTrim(NEWSM0->M0_CGC), "@R 99.999.999/9999-99" ) + " I.E.:" + AllTrim(NEWSM0->M0_INSC)
			cCidade				:= AllTrim(NEWSM0->M0_CIDENT)
			cEstado				:= AllTrim(NEWSM0->M0_ESTENT)
			Exit
		EndIf
		NEWSM0->(dbskip())
	EndDo
	NEWSM0->(dbCloseArea())
	
Return {cNomeComerEmpresa,cEndereco,cCNPJ,cCidade,cEstado}


/**
* Função que retorna a data por extenso
**/
Static Function DtExtenso(dDataAtual, lAbreviado)
	Local cRetorno := ""
	Default dDataAtual := dDataBase
	Default lAbreviado := .F.
	
	//Se for da forma abreviada, mostra números
	If lAbreviado
		cRetorno += cValToChar(Day(dDataAtual))
		cRetorno += " de "
		cRetorno += MesExtenso(dDataAtual)
		cRetorno += " de "
		cRetorno += cValToChar(Year(dDataAtual))
		
		//Senão for abreviado, mostra texto completo
	Else
		cRetorno += Capital(Extenso(Day(dDataAtual), .T.))
		cRetorno += " de "
		cRetorno += MesExtenso(dDataAtual)
		cRetorno += " de "
		cRetorno += Capital(Extenso(Year(dDataAtual), .T.))
	EndIf
	
Return cRetorno

/**
* Função que retorna os TipoDoc E5_TIPODOC baseado no título
**/
Static Function QRYDOC()
	
	Local cQuery := ""
	Local nQtd	 := 0
	Local cTitulo:=QRY->E5_NUMERO
	
	cQuery:= " SELECT                     "    		  + CRLF
	cQuery+= " SE5.E5_TIPODOC             "    		  +	CRLF
	cQuery+= " FROM SE5G10 SE5            "    		  +	CRLF
	cQuery+= " WHERE                      "    		  +	CRLF
	cQuery+= " SE5.D_E_L_E_T_=' ' AND     "    		  +	CRLF
	cQuery+= " SE5.E5_NUMERO='"+cTitulo+"' AND  "     +	CRLF
	cQuery+= " SE5.E5_FILIAL='"+xFilial("SE5")+"'"    +	CRLF
	
	//DbUseArea(.t.,"TOPCONN",TcGenQry(,,cQuery),"QRYOP",.f.,.f.)
	MemoWrite("SQLDOC.TXT",cQuery)
	TCQUERY cQuery NEW ALIAS QRYDOC
	Count To nQtd
	QRYDOC->(DbGoTop())
	
Return

/**
* Função que retorna os registros baseado nos parâmetros
**/
Static Function QRYSE5()
	
	Local cQuery := ""
	Local nQtd	 := 0
	
	cQuery:= " SELECT " 								                        + 	CRLF
	cQuery+= " SE5.E5_NUMERO, " 						                        +	CRLF
	cQuery+= " SE5.E5_PARCELA, " 						                        +	CRLF
	cQuery+= " SE5.E5_DOCUMEN, " 						                        +	CRLF
	cQuery+= " SE5.E5_CLIFOR, " 						                        +	CRLF
	cQuery+= " SE5.E5_LOJA, " 							                        +	CRLF
	cQuery+= " SE5.E5_TIPO, " 							                        +	CRLF
	cQuery+= " SE5.E5_VENCTO," 							                        +	CRLF
	cQuery+= " SE5.E5_HISTOR," 							                        +	CRLF
	cQuery+= " SE5.E5_TIPODOC," 							                    +	CRLF
	cQuery+= " SE1.E1_VALOR," 							                        +	CRLF
	cQuery+= " SE1.E1_VLCRUZ," 							                        +	CRLF
	cQuery+= " SE5.E5_VLACRES," 							                    +	CRLF
	cQuery+= " SE5.E5_VLDECRE,"							                    	+	CRLF
	cQuery+= " SE5.E5_VALOR"							                        +	CRLF
	cQuery+= " FROM "+RetSqlName("SE5")+" SE5" 			                        +	CRLF
	cQuery+= " INNER JOIN "+RetSqlName("SE1")+" SE1 ON"                         +	CRLF
	cQuery+= " SE1.E1_FILIAL=SE5.E5_FILIAL AND" 		                        +	CRLF
	cQuery+= " SE1.E1_NUM=SE5.E5_NUMERO" 				                        +	CRLF
	cQuery+= " WHERE" 									                        +	CRLF
	cQuery+= " SE5.E5_FILIAL="+xFilial("SE5")+" AND" 	                        +	CRLF
	cQuery+= " SE1.E1_FILIAL="+xFilial("SE1")+" AND" 	                        +	CRLF
	cQuery+= " SE5.E5_NUMERO BETWEEN '"+cTituloDe+"' AND '"+cTituloAte+"' AND" 	+	CRLF
	cQuery+= " SE5.E5_CLIFOR BETWEEN '"+cClienteDe+"' AND '"+cClienteAte+"' AND"+	CRLF
	cQuery+= " SE1.E1_BAIXA BETWEEN  '"+cDataBxDe+"' AND '"+cDataBxAte+"' AND" 	+	CRLF
	cQuery+= " SE1.E1_BAIXA != ' ' AND" 										+	CRLF
	cQuery+= " SE1.D_E_L_E_T_=' ' AND" 									        +	CRLF
	cQuery+= " SE5.D_E_L_E_T_=' ' " 									        +	CRLF
	
	MemoWrite("SQL.TXT",cQuery)
	TCQUERY cQuery NEW ALIAS QRY
	Count To nQtd
	QRY->(DbGoTop())
	
Return nQtd

/**
* Função que verifica a existência do tipo VL e ES
* Caso tenha os dois, pula para o próximo título.
* Caso tenha somente o VL, imprime o recibo baseado no título
**/
Static Function IsVLES(nPosVL,nPosES,aTiposDoc)

	nPosVL		:=aScan(aTiposDoc,		{ |x| x == "VL" })
	nPosES		:=aScan(aTiposDoc,		{ |x| x == "ES" })	

Return

/**
* Função que alimenta o array aTiposDoc com os tipos de documento baseado no título em questão
**/
Static Function GetTipoDoc(aTiposDoc)
	aTiposDoc:={}
	While QRYDOC->(!Eof())
		aAdd(aTiposDoc,QRYDOC->E5_TIPODOC)
		QRYDOC->(dbskip())
	EndDo
	
Return

/**
* Função que verifica se o título já foi impresso. 
**/
Static Function IsTituloImpresso(aTitulosImpre,nTituloImpre)
	
	nTituloImpre:=aScan(aTitulosImpre,	{ |x| x == QRY->E5_NUMERO })

Return
