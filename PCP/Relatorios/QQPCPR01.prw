#Include 'Protheus.ch'
#Include 'TopConn.ch'

User Function tela01
	rpcsetenv("G1","0101")
	//rpcsetenv("99","01",)
	define msdialog omainwnd from 0,0 to 600,800 pixel
	@ 05,05 button "OK" of omainwnd pixel action u_QQPCPR01()
	activate msdialog omainwnd
return

/*/{protheus.doc}QQPCPR01
Função para obter as Ordens de Produção
@author Gustavo Luiz
@since  04/03/2016
/*/
User Function QQPCPR01()	
	
	Local oReport 			:= NIL		
	Private aRet			:={}
	Private cRegisMapa		:= ""
	Private cOrdemProducao	:=0
	Private cAlias := GetNextAlias()
	Private nEstru  := 0	//necessário para executar a função padrão Estrut()		
	
	cRegisMapa:=GETMV("MV_ZZREGMP")
	
	If Perguntas()
		cOrdemProducao:=aRet[1]
		oReport:=ReportDef()
		oReport:PrintDialog()		
	EndIf	
	
Return

/**
* Obtém o registro do mapa gravado no parâmetro MV_ZZMAPA
* OBS. Não esta sendo utilizada pois a partir da data 15/03/2016 esta 
* pegando direto do parametro
**/
Static Function GetMapa(aParametros,aTemp)
	
	Local nI			:=1
	Local nPosFilial	:=0
	Local cRegistrMapa	:= ""
	
	For nI:=1 To Len(aParametros)
		aAdd(aTemp,separa(aParametros[nI],"="))
	Next nI
	nPosFilial  := aScan(aTemp,{ |x| x[1] == cFilant })
	cRegistrMapa:=aTemp[nPosFilial][2]
	
Return cRegistrMapa

/**
* Define as seções do relatório
**/
Static Function ReportDef()
	
	Local oReport  := Nil
	Local oSection1:= Nil
	Local oSection2:= Nil
	Local oSection3:= Nil
	Local oSection4:= Nil
	Local oSection5:= Nil
	Local oSection6:= Nil
	Local oBreak   := Nil
	
	oReport := tReport():New(funname(),"Ordem de Produção",,{|oReport| PrintRep(oReport)})
	oReport:SetLandscape()
	oReport:oPage:setPaperSize(9)//DEFINI O TAMANHO A4
	
	
	oSection1 := TrSection():New(oReport,"Ordem de Produção nº:")
	TrCell():New(oSection1,"ORDEMPROD"	,,"Ordem Produção",		"@!",30,.F.,{|| ""})
	TrCell():New(oSection1,"NUMEROOP"	,,"Número",				"@!",30,.F.,{|| QRYOP->NUMEROOP})
	TrCell():New(oSection1,"REGISTRMAPA",,"Registro no Mapa",	"@!",30,.F.,{|| cRegisMapa})
	
	oSection2 := TrSection():New(oReport,"SOLICITANTE")
	TrCell():New(oSection2,"DATA"		,,"Data",					"@!",10,.F.,{|| sToD(QRYOP->ABERTURA)})//possivelmente C2_DATRF aguardando validação
	TrCell():New(oSection2,"LOTE"		,,"Lote",					"@!",10,.F.,{||})
	TrCell():New(oSection2,"DE"			,,"De",						"@!",20,.F.,{|| "Irandu"})
	TrCell():New(oSection2,"RESPFABRIC"	,,"Responsável Fabricação",	"@!",10,.F.,{|| "ASS.____________________"})	
	
	oSection3 := TrSection():New(oReport,"Detalhes :")
	TrCell():New(oSection3,"ITEM"		,,"Item",					"@!",TamSx3("B1_COD")[1],	 .F.,{|| QRYOP->PRODUTO}												,"LEFT",,"LEFT")
	TrCell():New(oSection3,"DESCRICAO"	,,"Descrição",				"@!",TamSx3("B1_DESC")[1],	 .F.,{|| QRYOP->DESCRICAO}												,"LEFT",,"LEFT")
	TrCell():New(oSection3,"UNIDMEDIA"	,,"Uni",					"@!",TamSx3("B1_UM")[1],	 .F.,{|| QRYOP->UNIDMEDIDA}												,"LEFT",,"LEFT")
	TrCell():New(oSection3,"QUANTPROD"	,,"Quantidade a produzir",	"@!",TamSx3("C2_QUANT")[1],	 .F.,{|| QRYOP->QUANTIDADE}												,"RIGHT",,"RIGHT")
	TrCell():New(oSection3,"REGISTRO"	,,"Registro",				"@!",TamSx3("B1_ZZMAPA")[1], .F.,{|| InterfaceSB1SBZ("B1_ZZMAPA","BZ_ZZMAPA"	,QRYOP->PRODUTO)}	,"RIGHT",,"RIGHT")
	TrCell():New(oSection3,"DENSIDADE"	,,"Densidade",				"@!",TamSx3("B1_ZZDENSI")[1],.F.,{|| InterfaceSB1SBZ("B1_ZZDENSI","BZ_ZZDENSI"	,QRYOP->PRODUTO)}	,"RIGHT",,"RIGHT")	
	
	oSection4 := TrSection():New(oReport,"Peso :")
	
	TrCell():New(oSection4,"PESO_PESO"  ,,"Peso_Peso",			"@!",12,.F.)
	TrCell():New(oSection4,"N"		    ,,"N",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZTOTAL","BZ_ZZTOTAL"	,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"P"		    ,,"P",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZP2O5"	,"BZ_ZZP2O5"	,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"K"		    ,,"K",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZK20"	,"BZ_ZZK20"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"CA"		    ,,"Ca",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZCA"	,"BZ_ZZCA"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Mg"		    ,,"Mg",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZMG"	,"BZ_ZZMG"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"S"		    ,,"S",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZS"	,"BZ_ZZS"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Zn"		    ,,"Zn",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZZN"	,"BZ_ZZZN"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Cu"		    ,,"Cu",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZCU"	,"BZ_ZZCU"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"B"		    ,,"B",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZB"	,"BZ_ZZB"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Co"		    ,,"Co",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZCO"	,"BZ_ZZCO"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Mo"		    ,,"Mo",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZMO"	,"BZ_ZZMO"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Mn"		    ,,"Mn",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZMN"	,"BZ_ZZMN"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Fe"		    ,,"Fe",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZFE"	,"BZ_ZZFE"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	TrCell():New(oSection4,"Ni"		    ,,"Ni",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZNI"	,"BZ_ZZNI"		,QRYOP->PRODUTO)},"RIGHT",,"RIGHT")
	
	oSection5 := TrSection():New(oReport,"Volume :")
	
	TrCell():New(oSection5,"PESO_VOLUME"  ,,"Peso_Volume",		"@!",12,.F.)
	TrCell():New(oSection5,"N"		    ,,"N",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZTOTAL","BZ_ZZTOTAL"	,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"P"		    ,,"P",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZP2O5"	,"BZ_ZZP2O5"	,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"K"		    ,,"K",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZK20"	,"BZ_ZZK20"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"CA"		    ,,"Ca",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZCA"	,"BZ_ZZCA"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Mg"		    ,,"Mg",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZMG"	,"BZ_ZZMG"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"S"		    ,,"S",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZS"	,"BZ_ZZS"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Zn"		    ,,"Zn",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZZN"	,"BZ_ZZZN"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Cu"		    ,,"Cu",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZCU"	,"BZ_ZZCU"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"B"		    ,,"B",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZB"	,"BZ_ZZB"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Co"		    ,,"Co",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZCO"	,"BZ_ZZCO"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Mo"		    ,,"Mo",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZMO"	,"BZ_ZZMO"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Mn"		    ,,"Mn",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZMN"	,"BZ_ZZMN"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Fe"		    ,,"Fe",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZFE"	,"BZ_ZZFE"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	TrCell():New(oSection5,"Ni"		    ,,"Ni",					"@!",10,.F.,{|| InterfaceSB1SBZ("B1_ZZNI"	,"BZ_ZZNI"		,QRYOP->PRODUTO)} ,"RIGHT",,"RIGHT")
	
	oSection6 := TrSection():New(oReport,"Matéria Prima :")
	TrCell():New(oSection6,"ITEM"  			,,"Item",							PesqPict('SB1',"B1_COD")	,10,.F.,{||})
	TrCell():New(oSection6,"DESCRICAO"  	,,"Descrição",						PesqPict('SB1',"B1_DESC")	,20,.F.,{||})
	TrCell():New(oSection6,"UNI"  			,,"Uni",							PesqPict('SB1',"B1_UM")		,10,.F.,{||})
	TrCell():New(oSection6,"GARANTIA"  		,,"Garantia Solúveis em Água(%)",	PesqPict('SB1',"B1_ZZSOLUB"),10,.F.,{||})
	TrCell():New(oSection6,"PARTES"  		,,"Partes/1000 Kg",					PesqPict('SG1',"G1_QUANT")	,10,.F.,{||},"RIGHT",,"RIGHT")
	//TrCell():New(oSection6,"QTD/1000"  		,,"Quant/1000 lt",					PesqPict('SG1',"G1_QUANT")	,10,.F.,{||},"RIGHT",,"RIGHT")
	TrCell():New(oSection6,"QTDUTILIZADA"  	,,"Qtde Utilizada",					PesqPict('SG1',"G1_QUANT")	,10,.F.,{||},"RIGHT",,"RIGHT")	
	
	TRFunction():New(oSection6:Cell("PARTES"),		/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection6:Cell("QTDUTILIZADA"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	//TRFunction():New(oSection6:Cell("QTD/1000")	   ,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	
	oSection1:SetLineStyle(.T.)
	oSection3:SetAutoSize(.T.)
	oSection4:SetLineStyle(.F.)
	oSection4:SetAutoSize(.F.)		//definido como false para não desalinha com a seção 5
	oSection5:SetAutoSize(.F.)		//definido como false para não desalinha com a seção 4
	oSection5:SetLineStyle(.F.)
	oSection6:SetLineStyle(.F.)
	oSection6:SetAutoSize(.T.) 		//Abrange toda a tela
	oSection6:SetTotalinLine(.F.)	//Posiciona os totais em suas respectivas colunas
	oSection6:SetTotalText("TOTAIS")
	
	
	
	
Return oReport

Static Function InterfaceSB1SBZ(nomCampSB1,nomCampSBZ,codigoProduto)
	
	Local objQualy:=LibQualyQuimica():New() 
	Local cRetorno := objQualy:GetSB1SBZ(nomCampSB1,nomCampSBZ,codigoProduto)

Return cRetorno

/**
* Função que executa a impressão
**/
Static Function PrintRep(oReport)
	
	Local oSection1 	:= oReport:Section(1)
	Local oSection2		:= oReport:Section(2)
	local oSection3		:= oReport:Section(3)
	local oSection4		:= oReport:Section(4)
	Local oSection5 	:= oReport:Section(5)
	Local oSection6 	:= oReport:Section(6)
	
	Local nRegistros		:= 0
	Local tamanhoPag		:=oReport:PageWidth()
	Local cCodigoComponent	:=""//posição [nI][3]
	Local nQuant			:=""//posição [nI][4]
	Local aEstrutura		:= {}
	Local nSomaCompone		:= 0
	Local nResultado		:= 0
	Local nDensidade		:= 0
	Local cDescricao		:=""
	Local cUnidMedida		:=""
	Local cGarantiaSolAgua  :=""
	
	Local cLoteCTL			:=""
	Local cTipoProduto		:=""
	Local cUsuario			:=""
	Local aInformacoes		:= {}
		
	
	Local aArea				:= GetArea()
	Local aAreaSB1			:= SB1->(GetArea())
	Local aAreaSG1			:= SG1->(GetArea())
	Local aAreaSC2			:= SC2->(GetArea())
	
	GetDetailsOP()
	Count To nRegistros
	oReport:SetMeter(nRegistros)
	QRYOP->(DbGoTop())
	aEstrutura:=GetComponentes()
	nSomaCompone:=GetSomaComponentes(aEstrutura)
	
	While QRYOP->(!EOF())
		
		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()
		
		oSection2:Init()
			
		aInformacoes:=GetInfSD3(QRYOP->PRODUTO)	
		cLoteCTL	:=aInformacoes[1]
		cTipoProduto:=aInformacoes[2]
		cUsuario	:=aInformacoes[3]
		
		
		oSection2:Cell("LOTE"):SetValue(cLoteCTL)
		oSection2:Cell("DE"):SetValue(cUsuario)
		
		
		VerificaTipoProduto(cTipoProduto,@oSection2)
		
		
		oSection2:PrintLine()
		oSection2:Finish()
		
		oSection3:Init()
		oSection3:PrintLine()
		oSection3:Finish()
		
		oSection4:Init()
		oSection4:PrintLine()
		oSection4:Finish()
		
		oSection5:Init()
		oSection5:PrintLine()
		oSection5:Finish()
		
		oReport:SkipLine(2)		
		oReport:PrintText("Matéria Prima",,tamanhoPag/2)
		
		oSection6:Init()
		For nI:=1 To Len(aEstrutura)
			
			cCodigoComponent	:= aEstrutura[nI][3]
			nQuant				:= aEstrutura[nI][4]
			//cCodigoProduto		:= Posicione("SB1",1,XFILIAL('SB1')+cCodigoComponent,"B1_DESC")
			cDescricao			:= Posicione("SB1",1,XFILIAL('SB1')+cCodigoComponent,"B1_DESC")
			cUnidMedida			:= Posicione("SB1",1,XFILIAL('SB1')+cCodigoComponent,"B1_UM")
			//cGarantiaSolAgua	:= Posicione("SB1",1,XFILIAL('SB1')+cCodigoComponent,"B1_ZZSOLUB")
			cGarantiaSolAgua	:= InterfaceSB1SBZ("B1_ZZSOLUB","BZ_ZZSOLUB",cCodigoComponent)			
			//nDensidade			:= Posicione("SB1",1,XFILIAL('SB1')+cCodigoComponent,"B1_ZZDENSI")		
			nDensidade			:= InterfaceSB1SBZ("B1_ZZDENSI","BZ_ZZDENSI",cCodigoComponent)
			
			oSection6:Cell("ITEM"):SetValue(cCodigoComponent)
			oSection6:Cell("DESCRICAO"):SetValue(cDescricao)
			oSection6:Cell("UNI"):SetValue(cUnidMedida)
			oSection6:Cell("GARANTIA"):SetValue(cGarantiaSolAgua)
			nResultado:=(nQuant/nSomaCompone)*1000
			oSection6:Cell("PARTES"):SetValue(nResultado)
			//oSection6:Cell("QTD/1000"):SetValue(nQuant)
			oSection6:Cell("QTDUTILIZADA"):SetValue(nQuant)
			
			oSection6:PrintLine()
			
		Next nI
		
		oSection6:Finish()
		
		QRYOP->(dbskip())
		oReport:IncMeter()
		oReport:Endpage()
		
	EndDo
	QRYOP->(DbCloseArea())
	RestArea(aArea)
	SB1->(RestArea(aAreaSB1))
	SG1->(RestArea(aAreaSG1))
	SC2->(RestArea(aAreaSC2))
	
Return

/**
* Se for tipo de produto PI mostra o usuário (DE)
* Senão retira a célula da seção DE
**/
Static Function VerificaTipoProduto(cTipoProduto,oSection2)
	
	If AllTrim(cTipoProduto)!="PI"
	
		oSection2:cell("DE"):disable()
		//aDel(oSection2:aCell,3)
		//ASIZE(oSection2:aCell,(len(oSection2:aCell)-1))
	EndIf	
	
Return


/**
* Retorna o loteCTL, tipo de produto e usuario
**/
Static Function GetInfSD3(cProduto)

	Local cOrdemProduca		:=""
	Local cLoja				:=""	
	Local cLoteCTL			:=""
	Local cTipoProduto		:=""
	Local cUsuario			:=""

	cOrdemProduca	:=PADR(QRYOP->NUMEROOP+QRYOP->ITEM+QRYOP->SEQUENCIA,TAMSX3("D3_OP")[1])
	cProduto		:=PADR(QRYOP->PRODUTO,TAMSX3("D3_COD")[1])
	cLoja			:=PADR(QRYOP->LOCAL,TAMSX3("D3_LOCAL")[1])
	cLoteCTL		:=Posicione("SD3",1,XFILIAL('SD3')+cOrdemProd+cProduto+cLoja,"D3_LOTECTL")	
	cTipoProduto	:=Posicione("SD3",1,XFILIAL('SD3')+cOrdemProd+cProduto+cLoja,"D3_TIPO")
	cUsuario		:=Posicione("SD3",1,XFILIAL('SD3')+cOrdemProd+cProduto+cLoja,"D3_USUARIO")
Return {cLoteCTL,cTipoProduto,cUsuario}

/**
* Percorre o array aEstrutura somando a quantidade de cada 
* componente e atribuindo à variável nSoma
**/
Static Function GetSomaComponentes(aEstrutura)
	
	Local nSoma	:= 0
	Local nI	:= 1
	
	For nI:=1 To Len(aEstrutura)
		nSoma+=aEstrutura[nI][4]
	Next Ni
	
Return nSoma

/**
* Obtém os componentes de acordo com o produto a ser produzido na Ordem de Produção 
**/
Static Function GetComponentes()
	
	Local aEstrutura := {}
	
	aEstrutura:=Estrut(QRYOP->PRODUTO)
	
Return aEstrutura

/**
* Executa a query para obter as informações do produto
**/
Static Function GetDetailsOP()
	
	Local cQuery := ""
	
	cQuery:= " SELECT "									         + 	CRLF
	cQuery+= " 	SC2.C2_NUM NUMEROOP, "					         +	CRLF
	cQuery+= " 	SC2.C2_ITEM ITEM, "					         	 +	CRLF
	cQuery+= " 	SC2.C2_SEQUEN SEQUENCIA, "				         +	CRLF
	cQuery+= " 	SC2.C2_PRODUTO PRODUTO, "				         +	CRLF
	cQuery+= " 	SC2.C2_LOCAL LOCAL, "				         	 +	CRLF
	cQuery+= " 	SC2.C2_QUANT QUANTIDADE, "				         +	CRLF
	cQuery+= " 	SC2.C2_DATRF ABERTURA, "				         +	CRLF
	cQuery+= " 	SB1.B1_DESC DESCRICAO, "				         +	CRLF
	cQuery+= " 	SB1.B1_UM UNIDMEDIDA, "					         +	CRLF
	cQuery+= " 	SB1.B1_ZZMAPA MAPA, "					         +	CRLF
	cQuery+= " 	SB1.B1_ZZDENSI DENSIDADE, "				         +	CRLF
	cQuery+= " 	SB1.B1_ZZTOTAL N, SB1.B1_ZZP2O5 P, "       	 	 +	CRLF
	cQuery+= " 	SB1.B1_ZZK20 K, SB1.B1_ZZCA  CA, SB1.B1_ZZMG MG,"+	CRLF
	cQuery+= " 	SB1.B1_ZZZN ZN, SB1.B1_ZZCU CU, SB1.B1_ZZB B," 	 +	CRLF
	cQuery+= " 	SB1.B1_ZZCO CO, SB1.B1_ZZMO MO, SB1.B1_ZZMN MN," +	CRLF
	cQuery+= " 	SB1.B1_ZZFE FE, SB1.B1_ZZNI NI, SB1.B1_ZZS S " 	 +	CRLF
	cQuery+= " FROM "+RetSqlName("SC2")+" SC2 "   		         +	CRLF
	cQuery+= " INNER JOIN "+RetSqlName("SB1")+" SB1 ON "         +	CRLF
	cQuery+= "	SB1.B1_COD=SC2.C2_PRODUTO	"			         + 	CRLF
	cQuery+= " WHERE " 								 	         +	CRLF
	cQuery+= " 	SC2.D_E_L_E_T_=' ' " 					         +	CRLF
	cQuery+= " 	AND SB1.D_E_L_E_T_=' ' " 				         +	CRLF
	cQuery+= " 	AND SC2.C2_NUM='"+cOrdemProducao+"' " 	         +	CRLF
	cQuery+= " 	AND SB1.B1_FILIAL='"+xFilial("SB1")+"'"          +	CRLF
	cQuery+= " 	AND SC2.C2_FILIAL='"+xFilial("SC2")+"'"          +	CRLF
	
	
	//DbUseArea(.t.,"TOPCONN",TcGenQry(,,cQuery),"QRYOP",.f.,.f.)
	MemoWrite("SQL.TXT",cQuery)
	TCQUERY cQuery NEW ALIAS QRYOP
	
	
Return


/**
* Caixa para inserir a ordem de produção
**/
Static Function Perguntas()
	
	Local aPergs := {}	
	AADD(apergs,{1,"Ordem de Produção",Space(TamSx3("C2_NUM")[1]),"@!",'.t.',"SC2",'.t.',50,.T.})
	
Return ParamBox(aPergs,"Parametros",aRet,,,,,,,FUNNAME(),.t.,.t.)

