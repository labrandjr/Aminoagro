#include "Protheus.ch"
#INCLUDE "TopConn.ch"
#include "msobject.ch"

#define LOGNONE 	0
#define LOGERROR 	1
#define LOGWARN 	2
#define LOGINFO 	3
#define LOGDEBUG 	4

//-------------------------------------------------------------------
/*/{Protheus.doc} Função ImpSZ1

Importa registros de arquivo .csv, para a tabela personlizada SZ1. Fonte adaptado sobre acelerador de importação de arquivo .CSV 

@author 	Augusto Krejci Bem-Haja
@since 		18/03/2016
@return		Array
/*/
//-------------------------------------------------------------------

User Function ImpSZ1()
	Local	nMascara	:=	GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE
	Local 	nMascDest	:=  GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_RETDIRECTORY
	Local	lRetorno	:=	.t.
	Local	oImpArq		:=	PapBIImpCSV():New()
	Local	cType		:=	"Arquivo CSV"+"(*.CSV) |*.csv|"
	Local	cBarraX		:=	IIf(IsSrvUnix(), "/", "\")
	Local   cTitulo1	:= 	"Selecione o arquivo a importar"			
	Local	cArquivo	:=	cGetFile(cType,cTitulo1,0,,.T.,nMascara)
	Local	oProcess	:=	MsNewProcess():New( { || MVAFAT01A(@oProcess,@oImpArq,cArquivo,cBarraX) },"Importacao e Validacao","Executando...",.t.)
	//Local	cPerg		:=	"MVAF01"
	Local   cTempo		:= SUBSTR(TIME(),1,2)+"-"+SUBSTR(TIME(),4,2)+"-"+SUBSTR(TIME(),7,2)
	Private cFolderLOG  := cGetFile("Pasta","Selecione a Pasta Destino Log",0,,.F.,nMascDest)
	Private aRet 		:= {}
	Private oLog		:= TIPLogger():New(cFolderLOG,"ImpLogSZ1"+DtoS(Date()) +"-" + cTempo,LOGDEBUG)
	Private nInclui		:= 0
	Private nAltera		:= 0
	
	oLog:Log(LOGINFO,"SZ1Import() - Arquivo CSV importado: " + cArquivo + " em "+ DtoC(Date()))// + " - " + TIME())

	oProcess:Activate()
	oImpArq:lShowValid	:= .f.
	oImpArq:lRemocAcen	:= .t.
	oImpArq:lShwFields	:= .t.
	oImpArq:mShowData()

Return(lRetorno)

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

Static Function MVAFAT01B(oImpArq,lImported,cBarraX)
	Local	nI			:=	0
	Local	nRecs		:=	Len(oImpArq:aData)
	//Local	cFolderLOG	:=	AllTrim(MV_PAR03)
	Local	aTamanho	:=	{}
	Local	nContador	:=	0
	Local	aTamSX3		:=	{}
	Local	cCampo
	
	//	Obtendo previamente o tamanho dos campos no SX3.
	For nContador	:=	1 To Len(oImpArq:aCabec)
		cCampo		:=	Upper(AllTrim(oImpArq:aCabec[nContador]))
		aTamSX3		:=	TamSX3(cCampo)
		
		//	Campos informados no arquivo .CSV. e inexistentes no SX3 serao desprezados
		If Len(aTamSX3) > 0
			If aTamSX3[1] > 0
				aAdd(aTamanho, {cCampo, aTamSX3[3], aTamSX3[1], aTamSX3[2]} )	// cCampo, cTipo, nTamanho, nCasaDecim
			Else
				MsgAlert("Campo "+cCampo+" NAO EXISTE na tabela SX3 e SERA IGNORADO.")
			EndIf
		Else
			MsgAlert("Campo "+cCampo+" NAO EXISTE na tabela SX3 e SERA IGNORADO.")
		Endif	
	Next nContador
	
	cFolderLOG	+=	IIf(Right(AllTrim(cFolderLOG),1)==cBarraX, "", cBarraX)
	
	MakeDir(cFolderLOG)
	
	If !lImported
		If oImpArq:lStatus
			lImported := .T.
			ProcRegua(nRecs)
			oLog:Log(LOGINFO,"Sz1Import() - Iniciando processo de importação de [" + AllTrim(Str(nRecs)) + "] registros.")
			For nI := 1 to nRecs
				If Mod(nI, 50) == 0
					IncProc("Importando " + AllTrim(Str(nI)) + " de " + AllTrim(Str(nRecs)) + "... ["+MV_PAR01+"]")
				EndIf
				MVAFAT01C(oImpArq, nI,cFolderLOG,aTamanho)
		    Next nI
			oLog:Log(LOGINFO,"Total de Registros Alterados: " + cValToChar(nAltera))
			oLog:Log(LOGINFO,"Total de Registros Incluídos: " + cValToChar(nInclui))
			oLog:Log(LOGINFO,"SZ1Import() - Finalizado processo de importação.")
		    If nInclui == 0 .And. nAltera == 0
				MsgInfo("O Arquivo ESTA com INCONSISTENCIA(S). A Importacao nao foi realizada.")
			Else
				MsgInfo("Processo CONCLUIDO. Verifique se os dados foram importados.")
			Endif	
		Else
			MsgStop("O Arquivo ESTA com INCONSISTENCIA(S). A Importacao nao sera realizada.")
		EndIf
	Else
		MsgStop("Os dados ja foram PROCESSADOS.")
	EndIf
Return

Static Function MVAFAT01C(oImpArq, nLinha, cFolderLOG, aTamanho)
	Local	lRetorno	:=	.t.
	Local	aVetor		:=	{}
	Local	nContador	:=	0
	Local	aTamSX3		:=	{}
	Local	cTipo		:=	""
	Local	nTamanho	:=	""
	Local	nCasaDecim	:=	0
	Local	uConteudo
	Local	cCampo
	//Local	cArquivo
	//Local	cMV_PAR01X	:=	AllTrim(MV_PAR01)
	//Local	cMV_PAR02X	:=	AllTrim(MV_PAR02)
	//Local	cFilAntX	:=	cFilAnt
	Local	nPosicao	:=	0
	Local	cVldUser	:=	NIL
	
	lMsErroAuto	:=	.F.
	lMsHelpAuto	:=	.T.
	
	//	Montagem DINAMICA do vetor que sera passado para Rotina Automatica, na ordem informada no arquivo .CSV.
	For nContador	:=	1 To Len(oImpArq:aCabec)
		cCampo		:=	Upper(AllTrim(oImpArq:aCabec[nContador]))
		nPosicao	:=	aScan(aTamanho, {|X| AllTrim(X[1]) == Upper(cCampo)})
		
		//	Campos informados no arquivo .CSV. e inexistentes no SX3 serao desprezados
		If nPosicao > 0
			aTamSX3		:=	aTamanho[nPosicao]
			cTipo		:=	aTamSX3[2]
			nTamanho	:=	aTamSX3[3]
			nCasaDecim	:=	aTamSX3[4]
			cVldUser	:=	NIL
	
			If 		cTipo == "C"
				uConteudo	:=	SubStr(	oImpArq:aData[nLinha][nContador], 01, nTamanho)
			ElseIf	cTipo == "N"
				uConteudo	:=	Val(	StrTran(oImpArq:aData[nLinha][nContador],",","."))
			ElseIf	cTipo == "D"
				uConteudo	:=	CtoD(	oImpArq:aData[nLinha][nContador])
			EndIf
				
			//	Garantindo que o registro sera importado na FILIAL informada no arquivo .CSV.
			If "_FILIAL"$Upper(Right(cCampo, 07))
				cFilAnt	:=	uConteudo
			EndIf
		
			aAdd(aVetor, {cCampo, uConteudo, cVldUser})
		EndIf
	Next nContador
	
	If Len(aVetor) > 0
		If ExisteAtivo(aVetor)
			InativaRegistro(aVetor)
		Endif
		IncluiRegistro(aVetor,nLinha)
	Endif

Return(lRetorno)


static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"
Local cOutros:= "/\:. "

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cOutros+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
		nY:= At(cChar,cOutros)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("_",1,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString


Static Function ExisteAtivo(aVetor)
	Local aArea		:= GetArea()
	Local lRetorno 	:= .F.
	Local cFil		:= aVetor[1,2]
	Local cProduto	:= aVetor[2,2]
	Local cAlias	:= ""
	
	cAlias := QryRgs(cFil,cProduto)
	(cAlias)->(dbGoTop())
	
	If !(cAlias)->(Eof())
		lRetorno := .T.
	Endif
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
Return lRetorno

Static Function QryRgs(cFil,cProduto) 
	Local cQuery := ""
	Local cEol   := chr(10) + chr(13)
	Local cAlias := GetNextAlias()
	
	cQuery := " SELECT * FROM " +RetSqlName("SZ1") +" SZ1 "+ cEol	
	cQuery += " WHERE Z1_CODIGO = '" + cProduto + "'"+ cEol
	cQuery += " AND Z1_ATIVO = 'S'" + cEol
	cQuery += " AND D_E_L_E_T_ = ' ' " + cEol
	cQuery += " AND Z1_FILIAL = '"+ cFil +"'"+ cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return cAlias

Static Function InativaRegistro(aVetor)
	Local aAreaSZ1  := SZ1->(GetArea())
	Local cFil		:= aVetor[1,2]
	Local nTamCod 	:= TamSX3("B1_COD")[1]
	Local cProduto	:= PadR(aVetor[2,2],nTamCod)
	Local cDesc		:= RetField("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
	//Local nCusto	:= aVetor[4,2]
	//Local dVecto	:= aVetor[5,2]
	
	DbSelectArea("SZ1")
	SZ1->(DbSetOrder(2))
	
	If SZ1->(DbSeek(cFil+cProduto+'S'))
		RecLock("SZ1",.F.)
		SZ1->Z1_ATIVO := 'N' 
		SZ1->(MsUnLock())
		oLog:Log(LOGINFO,"Alteração de Registro - Filial: " + cFil + " | Código: " + cProduto + " | Descrição: "+ cDesc + " | Custo: R$ "+ cValToChar(SZ1->Z1_CUSTO) + " | Validade: " + DtoC(SZ1->Z1_VALID) + " | Modificado Status para Inativo. ")
		nAltera++
	Endif
	
	RestArea(aAreaSZ1)
Return

Static Function IncluiRegistro(aVetor,nLinha)
	Local aAreaSZ1  := SZ1->(GetArea())
	Local cFil		:= aVetor[1,2]
	Local nTamCod 	:= TamSX3("B1_COD")[1]
	Local cProduto	:= PadR(aVetor[2,2],nTamCod)
	Local cDesc		:= RetField("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
	Local nCusto	:= aVetor[4,2]
	Local dValid	:= aVetor[5,2]
	
	DbSelectArea("SZ1")
	SZ1->(DbSetOrder(2))
	
	If !(SZ1->(DbSeek(cFil+cProduto+'S')))
		RecLock("SZ1",.T.)
		SZ1->Z1_FILIAL := cFil
		SZ1->Z1_CODIGO := cProduto
		SZ1->Z1_DESC   := cDesc
		SZ1->Z1_CUSTO  := nCusto
		SZ1->Z1_VALID  := dValid
		SZ1->Z1_ATIVO  := 'S'	 
		SZ1->(MsUnLock())
		oLog:Log(LOGINFO,"Inclusão  de Registro - Filial: " + cFil + " | Código: " + cProduto + " | Descrição: "+ cDesc + " | Custo: R$ "+ cValToChar(nCusto) + " | Validade: " + DtoC(dValid) + " | Ativo: S")
		nInclui++
	Endif
	RestArea(aAreaSZ1)
Return
