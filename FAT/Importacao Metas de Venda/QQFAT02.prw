#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

#define LOGNONE 	0
#define LOGERROR 	1
#define LOGWARN 	2
#define LOGINFO 	3
#define LOGDEBUG 	4


/*/{Protheus.doc} QQFAT02

Rotina para gravar na tabela SCT as metas de vendas originadas de uma fonte .csv

@author Gustavo Luiz
@since 10/05/2016

/*/
User Function QQFAT02()
	
	Local	nMascara	   :=	GETF_LOCALFLOPPY+GETF_LOCALHARD
	Local 	nMascDest	   :=  GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_RETDIRECTORY
	Local	oImpArq		   :=	PapBIImpCSV():New()
	Local	cType		   :=	"Arquivo CSV"+"(*.CSV) |*.csv|"
	Local	cBarraX		   :=	IIf(IsSrvUnix(), "/", "\")
	Local   cTitulo1	   := 	"Selecione o arquivo a importar"
	Local	cArquivo	:=	cGetFile(cType,cTitulo1,0,,.T.,nMascara)
	Local	oProcess	   :=	MsNewProcess():New( { || MVAFAT01A(@oProcess,@oImpArq,cArquivo,cBarraX) },"Importacao e Validacao","Executando...",.t.)
	Local   cTempo		   := SUBSTR(TIME(),1,2)+"-"+SUBSTR(TIME(),4,2)+"-"+SUBSTR(TIME(),7,2)
	
	Private cFolderLOG  := cGetFile("Pasta","Selecione a Pasta Destino Log",0,,.F.,nMascDest)
	Private aRet 		:= {}
	Private oLog		:= TIPLogger():New(cFolderLOG,"ImpLogMeta"+DtoS(Date()) +"-" + cTempo,LOGDEBUG)
	Private cNewRegistro:= ""
	
	oLog:Log(LOGINFO,"Arquivo CSV importado: " + cArquivo + " em "+ DtoC(Date()))// + " - " + TIME())
	
	oProcess:Activate()
	oImpArq:lShowValid	:= .f.
	oImpArq:lRemocAcen	:= .t.
	oImpArq:lShwFields	:= .t.
	oImpArq:mShowData()
	
Return

/**
* Popula grid da classe com as informaões do arquivo .csv
**/
Static Function MVAFAT01A(oProcess,oImpArq,cArquivo,cBarraX)
	Local	lImported	:=	.f.
	Local	bSair		:=	{ || oImpArq:oDlg:End() }
	Local	bProcessa	:=	{ || Processa( { || MVAFAT01B(@oImpArq,@lImported,cBarraX) },"Gravando os registros...") }
	
	oImpArq:bSair		:=	bSair
	oImpArq:bProcessa	:=	bProcessa
	oImpArq:cFile		:=	cArquivo
	oImpArq:lHasCabec	:= .t.
	oImpArq:mImport(@oProcess)
	
Return()

/**
* Função executada após pressionar o botão processar
**/
Static Function MVAFAT01B(oImpArq,lImported,cBarraX)
	
	Local aCamposCabecalho	:= {}
	Local aCamposItens		:= {}
	Local aAux				:= {}
	Local oModel 		:= FwLoadModel("FATA050")
	Local aDados		:= oImpArq:aData
	Local oLibQualy		:= LibQualyQuimica():New()
	Local nPos			:= 0
	Local xValor		:= Nil
	Local cDataExtenco	:= ""
	Local nI			:= 0
	
	dbSelectArea("SCT")
	dbSetOrder(1)
	MsSeek(xFilial())
	
	//pega data que esta no arquivo .scv para servir de nome no cabeçalho
	cDataExtenco:=zDtExtenso(cTod(aDados[1][1]),.T.)
	
	aAdd(aCamposCabecalho,{"CT_DESCRI"	,cDataExtenco})
	
	For nI := 1 To Len(aDados)
		aAdd(aAux, {"CT_SEQUEN",cValToChar(StrZero(nI,TamSx3("CT_SEQUEN")[1]))})
		
		xValor:= oLibQualy:GetConteudArquivo(oImpArq,nI,"CT_DATA")
		aAdd(aAux, {"CT_DATA",cTod(xValor)})
		
		xValor:= oLibQualy:GetConteudArquivo(oImpArq,nI,"CT_VEND")
		aAdd(aAux, {"CT_VEND",xValor})
		
		xValor:= oLibQualy:GetConteudArquivo(oImpArq,nI,"CT_PRODUTO")
		aAdd(aAux, {"CT_PRODUTO",xValor})
		
		xValor:= oLibQualy:GetConteudArquivo(oImpArq,nI,"CT_TIPO")
		aAdd(aAux, {"CT_TIPO",xValor})
		
		xValor:= oLibQualy:GetConteudArquivo(oImpArq,nI,"CT_QUANT")
		aAdd(aAux, {"CT_QUANT",Val(xValor)})
		
		xValor:= oLibQualy:GetConteudArquivo(oImpArq,nI,"CT_VALOR")
		aAdd(aAux, {"CT_VALOR",Val(sTrTran(xValor,",","."))})
		
		//xValor:= oLibQualy:GetConteudArquivo(oImpArq,nI,"CT_MOEDA")
		//aAdd(aAux, {"CT_MOEDA",Val(xValor)})
		
		aAdd(aCamposItens, aAux)
		aAux:={}
	Next nI
	
	Import(aCamposCabecalho, aCamposItens )
	
	oImpArq:oDlg:End()
	
Return


/**
* Realiza a importação baseado no array passado por parâmetro
**/
Static Function Import( aCpoMaster, aCpoDetail )
	
	Local nPos				:= 0
	Local nItErro 			:= 0
	Local nI				:= 0
	Local oStructCab		:= Nil
	Local oStructItem		:= Nil
	Local oModelCab			:= Nil
	Local oModelItem		:= Nil
	Local oModel			:= Nil
	Local aCamposCab		:= {}
	Local aCamposItem		:= {}
	Local aCamposNotExist	:= {}
	Local aErro				:= {}
	Local lStatusCabec		:= .T.
	Local lStatusItem		:= .T.
	Local lAux				:= .F.
	Local cMensagem			:= ""
	
	oModel := FWLoadModel("FATA050")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	
	oModelCab 	:= oModel:GetModel('SCTCAB')
	oStructCab	:= oModelCab:GetStruct()
	aCamposCab	:= oStructCab:GetFields()
	
	oModelItem	:= oModel:GetModel('SCTGRID')
	oStructItem	:= oModelItem:GetStruct()
	aCamposItem	:= oStructItem:GetFields()
	
	For nI:=1 To Len(aCpoMaster)
		
		If nPos := aScan(aCamposCab, {|x| Upper(AllTrim(x[3]))==Upper(AllTrim(aCpoMaster[nI][1]))}) > 0
			oModel:SetValue( "SCTCAB", aCpoMaster[nI][1], aCpoMaster[nI][2])
		Else
			aAdd(aCamposNotExist,aCpoMaster[nI][1])
			lStatusCabec:= .F.
		EndIf
		
	Next nI
	
	For nI:=1 To Len(aCpoDetail)
		
		If nI>1
			oModelItem:AddLine()
		EndIf
		
		For nJ := 1 To Len(aCpoDetail[nI])
			If nPos := aScan(aCamposItem, {|x| Upper(AllTrim(x[3]))==Upper(AllTrim(aCpoDetail[nI][nJ][1]))}) > 0
				If !(lAux:= oModel:SetValue( "SCTGRID", aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2]))
					nItErro := nI
					exit
				EndIf
			Else
				If nPos := aScan(aCamposNotExist,{|x| Upper(AllTrim(x))==Upper(AllTrim(aCpoDetail[nI][nJ][1])) }) == 0
					aAdd(aCamposNotExist,aCpoDetail[nI][nJ][1])
					lStatusItem:= .F.
				EndIf
			EndIf
		Next nJ
	Next nI
	
	If lStatusCabec!=.F. .AND. lStatusItem!=.F.
		If ( lRet := oModel:VldData())
			DbSelectArea("SCT")
			oModel:CommitData()
			
			MsgInfo("Dados importados com sucesso.", "")
			 ConfirmSx8()
			
		Else
			aErro := oModel:GetErrorMessage()
			
			AutoGrLog( "Id do formulário de origem:"+ ' [' + AllToChar( aErro[1] ) + ']')
			AutoGrLog( "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + ']')
			AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']')
			AutoGrLog( "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + ']')
			AutoGrLog( "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + ']')
			AutoGrLog( "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + ']')
			AutoGrLog( "Mensagem da solução: " 		+ ' [' + AllToChar( aErro[7] ) + ']')
			AutoGrLog( "Valor atribuído: " 			+ ' [' + AllToChar( aErro[8] ) + ']')
			AutoGrLog( "Valor anterior: " 			+ ' [' + AllToChar( aErro[9] ) + ']')
		
			If nItErro > 0
				AutoGrLog( "Erro no Item: " + ' [' + AllTrim(AllToChar( nItErro ) ) + ']' )
			EndIf
			ROLLBACKSXE()
			MostraErro()
			
		EndIf
	Else
		For nI:=1 To Len(aCamposNotExist)
			cMensagem += aCamposNotExist[nI] + CRLF
		Next nI
		MsgInfo("Dados não importados. Campos não existem: "+ CRLF + cMensagem + CRLF + "Verificar a estrutura dos arquivos", "")
	EndIf
	
	oModel:DeActivate()
	
Return


/**
* Retorna o último registro da tabela SCT
**/
Static Function GetUltimoRegistroSCT()
	
	Local cRegistro	:= ""
	DBGoBottom()
	cRegistro:=soma1(SCT->CT_DOC)
	
	aArea := GetArea()
	aAreaSCT := SCT->(GetArea())
	SCT->( LASTREC())
	
	RestArea(aAreaSCT)
	RestArea(aArea)
	
Return cRegistro


/**
* Retorna o a data por extenso
**/ 
Static Function zDtExtenso(dDataAtual, lAbreviado)
    Local cRetorno := ""
    Default dDataAtual := dDataBase
    Default lAbreviado := .F.
     
    //Se for da forma abreviada, mostra números
    If lAbreviado
        //cRetorno += cValToChar(Day(dDataAtual))
        //cRetorno += " de "
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
