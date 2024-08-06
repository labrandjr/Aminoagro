#INCLUDE "msobject.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

#define LOGNONE 	0
#define LOGERROR 	1
#define LOGWARN 	2
#define LOGINFO 	3
#define LOGDEBUG 	4

***************************************************************************************************************************************************
/****c* classes/TIPLogger
  *  NAME
  *    TIPLogger - 
  *  AUTHOR 
  *    Matheus Nogueira
  *  CREATION DATE 
  *    09-09-2010
  *  SYNOPSIS
  *    object := TIPLogger():New()
  *  FUNCTION
  *    
  *  ATTRIBUTES
  *    nHdl			- Handler do arquivo a ser gravado
  *    cDir			- Nome do diretorio de log
  *    cFileName	- Nome do arquivo de log
  *    cFileAndPath	- Path e Nome do arquivo de log
  *    cFileExtens	- Extensao do arquivo de log
  *    cEOF			- EOF
  *    lGrvData		- Determina se vai ser gravado a data da transacao
  *    lGrvHora		- Determina se vai ser gravado a hora da transacao
  *    SeqMsErro	- Sequencia do arquivo de MSErroAuto
  *    cAster		- String de asteriscos  
  *  METHODS   
  *    New(cDir,cFile,nLogLevel)			- Construtor
  *    StartProcess()						- Inicia um novo processo de log
  *    EndProcess()							- Finaliza o processo de log
  *    DecodeArray(aArray)          	    - Converte o conteudo do array em uma String
  *    Write(xVar1,xVar2)					- Grava informacoes no arquivo de log
  *    WriteStr(cBuff)						- Grava informacoes no arquivo de log
  *    AddErroMsAuto(cReferencia) 			- Grava informacoes de log de uma rotina execAuto
  *    ViewRpt() 							- Metodo para visualizacao/impressao do relatorio
  *    PrintRpt(Cabec1,Cabec2,Titulo,nLin)  - Metodo para visualizacao/impressao do relatorio
  *    CloseFile() 							- Metodo para fechar o arquivo de log  
  *  INPUTS
  *      *  RESULT
  *    algum resultado
  *  EXAMPLE
  *    object := TIPLogger():New()
  *  NOTES
  *    Nao execute as sextas feiras depois das 18h.
  *  BUGS
  *    Trabalhamos para que nao surjam.
  *  SEE ALSO
  *    Descansar.
  ******
  * Outras informacoes a respeito da classe ou funcao.
  */
***************************************************************************************************************************************************

***************************************************************************************************************************************************
&& 'dummy' function - Uso Interno
***************************************************************************************************************************************************
User Function _SGTOracleBridge; Return && 'dummy' function - Uso Interno


***************************************************************************************************************************************************
&& Definicao da classe
***************************************************************************************************************************************************
Class TIPLogger

	Data nHdl			as Integer	&& Handler do arquivo a ser gravado
	Data cDir			as String	&& Nome do diretorio de log
	Data cFileName		as String	&& Nome do arquivo de log
	Data cFileAndPath	as String	&& Path e Nome do arquivo de log
	Data cFileExtens	as String	&& Extensao do arquivo de log
	Data cEOF			as String	&& EOF
	Data nLogLevel		as Integer	&& Define o nivel de LOG do objeto
	Data nLoggingLevel	as Integer	&& Define o nivel de LOG da mensagem enviada
	Data lGrvData		as String	&& Determina se vai ser gravado a data da transacao
	Data lGrvHora		as String	&& Determina se vai ser gravado a hora da transacao
	Data SeqMsErro		as Integer	&& Sequencia do arquivo de MSErroAuto
	Data cAster			as String	&& String de asteriscos

	Method New(cDir,cFile,nLogLevel) Constructor	&& Construtor
	Method StartProcess()				 			&& Inicia um novo processo de log
	Method EndProcess()								&& Finaliza o processo de log
	Method DecodeArray(aArray)          		    && Converte o conteudo do array em uma String	
	Method Log(nLogLevel,cLogMsg,xVar1,xVar2)		&& Metodo para gravacao das informacoes no log
	Method LogVar(xVar1,xVar2) 						&& Metodo para gravacao das informacoes de uma ou duas variaveis
	Method WriteStr(cBuff)							&& Grava informacoes no arquivo de log
	Method AddErroMsAuto(cReferencia) 				&& Grava informacoes de log de uma rotina execAuto
	Method ViewRpt() 								&& Metodo para visualizacao/impressao do relatorio
	Method PrintRpt(Cabec1,Cabec2,Titulo,nLin)		&& Metodo para visualizacao/impressao do relatorio
	Method CloseFile() 								&& Metodo para fechar o arquivo de log

EndClass 

***************************************************************************************************************************************************
&& Metodo construtor
***************************************************************************************************************************************************
Method New(cDir,cFile,nLogLevel) Class TIPLogger

Local nSeq	:= 0
Local cStartPath	:= GetSrvProfString("StartPath","")

Default cDir		:= "" 
Default cFile		:= ""
Default nLogLevel   := LOGDEBUG

	cFile	:= AllTrim(cFile)
	cDir	:= AllTrim(cDir)

	&& Verifica se foi passado o nome do arquivo de log
	If Empty(cFile)
		cFile := "LOG_DT_" + DtoS(Date()) + ".TXT"
	Endif
	
	&& Verifica se foi passado o nome do diretorio de log
	If Empty(cDir)
		cDir := cStartPath + "LOGS\"
	Else
		If Substr(cDir,Len(cDir),1) != "\"
			cDir += "\"
		Endif
	Endif
	
	If !lIsDir(cDir)
		MontaDir(cDir)
	Endif

	&& Instacia os atributos
	::nHdl			:= -1
	::cDir			:= cDir
	::cFileName		:= cFile
	::cFileAndPath	:= cDir + cFile
	::cFileExtens	:= ".TXT"
	::cEOF			:= Chr(13) + Chr(10)
	::nLoggingLevel	:= nLogLevel
	::nLogLevel		:= nLogLevel
	::lGrvData		:= .T.
	::lGrvHora		:= .T.
	::SeqMsErro		:= 0
	::cAster		:= Replicate("*",100)

	&& Cria ou abre o arquivo de log
	Conout("TIPLOGGER - Checking file [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
	If File(::cFileAndPath+::cFileExtens)
		Conout("TIPLOGGER - File found [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
		
		
		::nHdl := FOpen(::cFileAndPath+::cFileExtens,66)
		If ::nHdl >= 0
			Conout("TIPLOGGER - File open [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
			FSeek(::nHdl,0,2)
		Else
			Conout("TIPLOGGER - No handler [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
			If fError() != 0
           		Conout("TIPLOGGER - Cannot open file [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
   			Endif
		EndIf
	Else
		::nHdl := FCreate(::cFileAndPath+::cFileExtens)
		FClose(::nHdl)
		
		::nHdl := FOpen(::cFileAndPath+::cFileExtens,66)
		If ::nHdl >= 0
			Conout("TIPLOGGER - File open [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
			FSeek(::nHdl,0,2)
		Else
			Conout("TIPLOGGER - No handler [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
			If fError() != 0
           		Conout("TIPLOGGER - Cannot open file [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
   			Endif
		EndIf
				
		Conout("TIPLOGGER - Create file [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
		If fError() != 0
        	Conout("TIPLOGGER - Cannot create file [" + ::cFileAndPath+::cFileExtens + "], DOS error ", fError() )
		EndIf		
	EndIf
		
Return


***************************************************************************************************************************************************
&& Metodo para iniciar um novo processo de log
***************************************************************************************************************************************************
Method StartProcess() Class TIPLogger

	::WriteStr(::cAster)
	::WriteStr("INICIANDO PROCESSO")
	::WriteStr(::cAster)

Return


***************************************************************************************************************************************************
&& Metodo para finalizar o processo de log
***************************************************************************************************************************************************
Method EndProcess() Class TIPLogger

	::WriteStr(::cAster)
	::WriteStr("FINALIZANDO PROCESSO")
	::WriteStr(::cAster)
	
	::CloseFile()

Return

***************************************************************************************************************************************************
&& Metodo para gravacao das informacoes no log
***************************************************************************************************************************************************
Method Log(nLogLevel,cLogMsg,xVar1,xVar2) Class TIPLogger

Default nLogLevel   := LOGDEBUG 
Default cLogMsg		:= ""
Default xVar1		:= "" 
Default xVar2		:= ""

	If nLogLevel >= 0 .and. nLogLevel <= 4
		::nLoggingLevel := nLogLevel
	Else
		::nLoggingLevel := LOGNONE
	Endif

	If ::nLogLevel > LOGNONE

		If ( ::nLogLevel >= nLogLevel )
		
			 ::WriteStr( cLogMsg + Iif( !Empty(xVar1) .or. !Empty(xVar2), " ->>> VARIAVEL(IS) ABAIXO <<<-" ,"")  )
			 
			 If !Empty(xVar1) .or. !Empty(xVar2)
			 
			 	::LogVar(xVar1,xVar2)
			 
			 Endif
			 
		Endif
		
	Endif
	
Return

***************************************************************************************************************************************************
&& Metodo para gravacao das informacoes de uma ou duas variaveis
***************************************************************************************************************************************************
Method LogVar(xVar1,xVar2) Class TIPLogger

Local cVar1	:= ""
Local cVar2	:= ""

Default xVar1 := ""
Default xVar2 := ""

	If ValType(xVar1) == "C"
		cVar1 := "C>" + AllTrim(xVar1)
	ElseIf ValType(xVar1) == "N"
		cVar1 := "N>" + AllTrim(Str(xVar1))
	ElseIf ValType(xVar1) == "D"
		cVar1 := "D>" + DtoC(xVar1)
	ElseIf ValType(xVar1) == "L"
		cVar1 := "L>" + Iif(xVar1,".T.",".F.")
	ElseIf ValType(xVar1) == "A"
		cVar1 := ::cEOF + ::DecodeArray(xVar1)
	Endif

	If ValType(xVar2) == "C"
		cVar2 := "C>" + AllTrim(xVar2)
	ElseIf ValType(xVar2) == "N"
		cVar2 := "N>" + AllTrim(Str(xVar2))
	ElseIf ValType(xVar2) == "D"
		cVar2 := "D>" + DtoC(xVar2)
	ElseIf ValType(xVar2) == "L"
		cVar2 := "L>" + Iif(xVar2,".T.",".F.")
	ElseIf ValType(xVar2) == "A"
		cVar2 := ::cEOF + ::DecodeArray(xVar2)
	Endif
		
	If !Empty(cVar1) .and. !Empty(cVar2)
		::WriteStr(cVar1 + "=>" + cVar2)
	ElseIf !Empty(cVar1)
		::WriteStr(cVar1)
	Endif
	
Return


***************************************************************************************************************************************************
&& Metodo para gravacao das informacoes do log
***************************************************************************************************************************************************
Method WriteStr(cBuff) Class TIPLogger

Local cStr	:= ""

Default cBuff	:= ""
	
	If !Empty(cBuff) .and. ::nHdl >= 0

		&& Informa o nivel do log
		If ::nLoggingLevel == 0 
			cStr += "[NONE]  "		
		ElseIf ::nLoggingLevel == 1 
			cStr += "[ERROR] "
		ElseIf ::nLoggingLevel == 2 
			cStr += "[WARN]  "
		ElseIf ::nLoggingLevel == 3 
			cStr += "[INFO]  "
		ElseIf ::nLoggingLevel == 4 
			cStr += "[DEBUG] " 
		Endif		
		/*
		&& Adiciona informacoes do usuario
		If Type("cUserName") <> "U"
			cStr += "- User: " + cUserName + " - "		
		Endif
		*/
		&& Determina se sera gravada a informacao de data e hora
		If ::lGrvData .or. ::lGrvHora
			cStr += Iif(::lGrvData, DtoC(Date()), "")
			cStr += Iif(::lGrvData .and. ::lGrvHora, "-", "")
			cStr += Iif(::lGrvHora, Time(), "")
			cStr += Iif(::lGrvData .or. ::lGrvHora, "-> ", "")
		Endif
				
		FWrite(::nHdl,cStr + cBuff + ::cEOF,Len(cStr + cBuff + ::cEOF))
				
	Endif

Return


***************************************************************************************************************************************************
&& Metodo Destrutor
***************************************************************************************************************************************************
Method DecodeArray(aArray,nNivel) Class TIPLogger

Local cRet	:= ""
Local cTmp	:= ""
Local nI	:= 0

Default nNivel := 1

	For nI := 1 to Len(aArray)
			
		cTmp := ""
			
		If ValType(aArray[nI]) == "C"
			cTmp := "C>" + AllTrim(aArray[nI])
		ElseIf ValType(aArray[nI]) == "N"
			cTmp := "N>" + AllTrim(Str(aArray[nI]))
		ElseIf ValType(aArray[nI]) == "D"
			cTmp := "D>" + DtoC(aArray[nI])
		ElseIf ValType(aArray[nI]) == "L"
			cTmp := "L>" + Iif(aArray[nI],".T.",".F.")			
		ElseIf ValType(aArray[nI]) == "A"
			cTmp := Iif(nNivel=1,::cEOF,"") + ::DecodeArray(aClone(aArray[nI]),nNivel+1)
		Endif
		
		cRet += Space(nNivel) + StrZero(nNivel,2) + "-" + StrZero(nI,3) + "->" + cTmp + ::cEOF

	Next nI

Return cRet


****************************************************************************************************************************************************
&& Metodo para adicionar o erro ocorrido pela rotina automatica no vetor aErros
****************************************************************************************************************************************************
Method AddErroMsAuto(cReferencia,lApaga) Class TIPLogger

Local cFileErro	:= ::cFileName+"_MsErroAuto"+ StrZero(++::SeqMsErro,5)+::cFileExtens
Local cError	:= ""

	MostraErro(::cDir,cFileErro)
	cError := MemoRead(::cDir+cFileErro)	
	::WriteStr(cReferencia + chr(13) + chr(10) + cError,,.F.)
	If lApaga
		FErase(::cDir+cFileErro)
	EndIf

Return 


***************************************************************************************************************************************************
&& Metodo para fechar o arquivo de log
***************************************************************************************************************************************************
Method CloseFile() Class TIPLogger

	If ::nHdl >= 0
		FClose(::nHdl)
		::nHdl := -1
	Endif
	
Return


****************************************************************************************************************************************************
&& Metodo para visualizar o conteudo do array aErros em um relatorio padrao SIGA
****************************************************************************************************************************************************
Method ViewRpt(lApaga) Class TIPLogger
	
	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "Relatorio de Log"
	Local cPict         := ""
	Local titulo       	:= "Relatorio de Log"
	Local nLin         	:= 80
	Local Cabec1       	:= "Ref.    Erro"
	Local Cabec2      	:= ""
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "GENERIC" 
	Private nTipo       := 15
	Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GENERIC" 	
	Private cString	 	:= ""
	
	Default lApaga := .F.
	
	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus({|| ::PrintRpt(Cabec1,Cabec2,Titulo,nLin), IIF(lApaga,Ferase(::cFileAndPath+::cFileExtens),.T.) },Titulo)
	
Return 


****************************************************************************************************************************************************
&& Metodo para impressao do relatorio padrao SIGA
****************************************************************************************************************************************************
Method PrintRpt(Cabec1,Cabec2,Titulo,nLin) Class TIPLogger
	
	Local nTotLin	:= 0
	Local cLinha	:= ""
	Local _nTamDesc	:= 0
	Local _nTMens	:= 0
	Local aLinha	:= {}
	
	::CloseFile()
	
	FT_FUse(::cFileAndPath+::cFileExtens)
	FT_FGotop()
		
	nTotLin := FT_FLASTREC()
	SetRegua(nTotLin)
	Conout( "Total de Linhas: " + AllTrim(Str(nTotLin)) )
	
	FT_FGotop()
	While ( !FT_FEof() ) .and. nTotLin > 0
	
		IncRegua()
		
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			Conout( "Imprimindo nova pagina: " )
		Endif
		
		cLinha := FT_FREADLN()
		
		aLinha		:= {}
		_nTamDesc	:= 130
		_nTMens		:= MLCount(cLinha,_nTamDesc)
		AADD(aLinha,MemoLine(cLinha,_nTamDesc,1))
		For _nI := 2 To _nTMens
			AADD(aLinha,Memoline(cLinha,_nTamDesc,_nI))
		Next _nI
		
		For nI := 1 to Len(aLinha)
			//oReport:Say(nLin,nInicio + 0040,aLinha[nI]	,oFont10,100,,,0)
			@nLin,01 PSAY aLinha[nI]
			nLin++
		Next nI
		
		//@nLin,01 PSAY cLinha
		
		nLin++
				
		FT_FSkip()
		
	EndDo    
	
	Conout( "Fora do loop" )
	
	FT_FUse()
	
	Conout( "Fechando arquivo" )
	
	Set Device To Screen
	
	If aReturn[5]==1
	   dbCommitAll()
	   Set Printer To
	   OurSpool(wnrel)
	Endif
	
	MS_FLUSH()      
	
	Conout( "Fim da rotina" )
	
Return 


****************************************************************************************************************************************************
&& Fim da rotina
****************************************************************************************************************************************************
