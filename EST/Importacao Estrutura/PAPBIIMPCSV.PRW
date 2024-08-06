#INCLUDE "protheus.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse    ³PapBIImpCSV ºAutor  ³Matheus Nogueira  º Data ³  15/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta Classe contem os metodos responsaveis pela importacao º±±
±±º          ³ de um arquivo com extensao CSV e suas devidas validacoes.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProjeto   ³ 108567 - Integracao Execplan X Protheus                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7.10 MS Sql Server                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Class PapBIImpCSV

	Data lError		as Logical		&& Variavel de Erro, caso tenha acontecido
	Data cError		as Character	&& Mensagem de Erro, caso tenha acontecido
	Data cFile		as Character	&& Arquivo a ser importado
	Data lStatus	as Logical		&& Variavel informando se o arquivo esta OK, sem falhas de validacao.
	Data lHasCabec	as Logical		&& Variavel informando se existe cabecalho no arquivo
	Data lShowValid	as Logical		&& Variavel informando se as validacoes devem ser exibidas no arquivo
	Data lShwFieldS	as Logical		&& Variavel informando se as validacoes devem ser exibidas por campo ou por linha
	Data lUpperConv	as Logical		&& Variavel informando se os dados importados devem ser transformados em UPPERCASE
	Data lRemocAcen	as Logical		&& Variavel informando se os dados importados devem ter os acentos removidos
	Data aCabec		as Array		&& Array com os dados do cabecalho
	Data aDataMaxC	as Array		&& Array com a largura maxima de cada coluna
	Data aData		as Array		&& Array com os dados do arquivo
	Data aCritic	as Array		&& Array com os dados dos itens com problemas de validacao
	Data aValRules	as Array		&& Array com as informacoes de validacao dos campos
	Data nColunas	as Numeric		&& Numero de Colunas do arquivo
	Data nRecords	as Numeric		&& Numero de linhas do arquivo
	Data bSair
	Data bProcessa
	Data oDlg
	Data cTitulo	as Character	&& Titulo da janela [TDialog]
	Data cTextSair	as Character	&& Texto do botao SAIR
	Data cTextProce	as Character	&& Texto do botao PROCESSAR

	Method New() Constructor
	Method mImport()	&& Importa o arquivo CSV e gravas as informacoes na propriedade aData
	Method mStrTreat()	&& Faz o tratamento da String, removendo acentos e colocando em caixa alta.
	Method mSetValid()	&& Configura uma validacao para o campo em questao
	Method mExecValid()	&& Executa a validacao dos dados conforme as definicoes
	Method mShowData()	&& Exibe os Dados importados em um objeto ListBox	

EndClass


&& Metodo : New()
&& Descric: Metodo Construtor. Instancia a classe PapBIImpCSV()
&& Param  : Nenhum
&& Retorno: Nil
Method New() Class PapBIImpCSV

	::lError		:= .F.
	::cError		:= ""
	::cFile			:= ""
	::lStatus		:= .T.
	::lHasCabec		:= .F.
	::lShowValid	:= .F.
	::lShwFieldS	:= .F.
	::lUpperConv	:= .T.
	::lRemocAcen	:= .T.
	::aCabec		:= {}
	::aDataMaxC		:= {}
	::aData			:= {}
	::aCritic		:= {}
	::aValRules		:= {}
	::nColunas		:= 0
	::nRecords		:= 0
	::cTitulo		:= "Importação de Arquivo CSV"
	::cTextSair		:= "Sair"
	::cTextProce	:= "Processar"
		
Return


***************************************************************************************************************************************************
&& Metodo : mImport()
&& Descric: Importa o arquivo CSV e gravas as informacoes na propriedade aData
&& Param  : Nenhum
&& Retorno: Retorna Verdadeiro caso a importacao tenha ocorrido sem problemas
***************************************************************************************************************************************************
Method mImport(oProcess) Class PapBIImpCSV

Local cRootPath		:= GetSrvProfString("StartPath","")
Local cFileTmp		:= cRootPath + "TMPIMPORCSV.CSV"
Local nHdl			:= -1
Local cBuffer		:= ""
Local nBuffer		:= 0 
Local nTotal		:= 0
Local nX			:= 0
Local cTmp			:= ""
Local aTmp 			:= {}
Local aTmpL			:= {}

If File( ::cFile )
	_CopyFile(::cFile,cFileTmp)
	nHdl := FOpen( cFileTmp, 0 )
	If nHdl >= 0
	    FSeek(nHdl,0,0)
		nTotal := FSeek(nHdl,0,2)
		nBuffer := Min(50*1024,nTotal) 
		FSeek(nHdl,0,0)
	Endif
Else
	::lError    := .T.
	::cError    := "Falha na abertura do arquivo: " + ::cFile
Endif


If !::lError

	If oProcess != NIL
		oProcess:SetRegua1(3)
		oProcess:IncRegua1( "Importando o arquivo... ") 
		oProcess:SetRegua2(2)
		oProcess:IncRegua2( "Lendo dados do arquivo... ") 
	Endif

	nTotal := 0

	While fReadLn(nHdl,@cBuffer,nBuffer) .and. !::lError
			
		If !Empty(AllTrim(cBuffer))
		
			cTmp := cBuffer
			aTmp := {}
			
			Do While at(";",cTmp) > 0
				nX := at(";",cTmp)
				If ( nX > 0 )
					aadd(aTmp, ::mStrTreat(Substr(cTmp,1,nX-1)) )
				Endif
				cTmp := Substr(cTmp, nX+1,Len(cTmp) )
			Enddo
			
			If Len(/*AllTrim*/(cTmp)) > 0		//	Fabricio M Vieira 08/09/2010. Funcao AllTrim fazia a leitura do arquivo CSV ser interrompida
				aadd(aTmp, ::mStrTreat(cTmp) )	//	quando a ultima coluna era composta SOMENTE de espacos em branco. Ex.: A1_COMPLEM.
			Endif
			
			If Len(aTmp) < ::nColunas
				For nX := Len(aTmp) to ::nColunas
					aadd(aTmp, "" )
				Next nX
			Endif
			
			If ::lHasCabec .and. nTotal == 0
			
				&& Carrega o nome das colunas
				::aCabec 	:= aTmp
				
				&& Carrega o numero de colunas do arquivo, para validacao de integridade
				::nColunas	:= Len(aTmp)
				
				&& Ajusta a propriedade de largura maxima das colunas para os casos em que existem colunas de cabecalho
				For nX := 1 to ::nColunas
					Aadd(::aDataMaxC, Len(aTmp[nX]) )
				Next nX
				
			Else		
				&& Carrega o numero de colunas do arquivo, para validacao de integridade
				If ::nColunas == 0
					::nColunas := Len(aTmp)
				Endif
				
				&& Ajusta a propriedade de largura maxima das colunas para os casos em que existem colunas de cabecalho
				If Len(::aDataMaxC) == 0
					For nX := 1 to ::nColunas
						Aadd(::aDataMaxC, Len(aTmp[nX]) )
					Next nX
				Endif					
				
				&& Carrega o array de dados
				Aadd(::aData, aClone(aTmp) )				
				
				&& Ajusta a propriedade de largura maxima das colunas
				For nX := 1 to Len(aTmp)
					If nX <= Len(::aDataMaxC)
						::aDataMaxC[nX] := Iif( ::aDataMaxC[nX] < Len(aTmp[nX]), Len(aTmp[nX]) ,::aDataMaxC[nX] )
					Endif
					aTmp[nX] := .T.
				Next nX
				
				&& Carrega o status padrao de critica dos itens importados
				aTmpL := aClone(aTmp)
				aadd(aTmpL,.T.)
				Aadd(::aCritic, aClone(aTmpL) )
				
			Endif
								
			If Len(aTmp) > ::nColunas
				::lError    := .T.
				::cError    := "Inconsistencia na estrutura do arquivo na linha: " + AllTrim(Str(nTotal))
			Endif
			
			nTotal ++
			
		Endif
		                                
	Enddo
	   
	FClose( nHdl )
	
	If Len(::aData) == 0 .and. !::lError
	
		::lError    := .T.
		::cError    := "Não foram encontrados dados no arquivo: " + ::cFile
		
	Elseif !::lError
	
		::lStatus	:= .T.
		For nX := 1 to ::nColunas
			aadd(::aValRules, {"CMD",".T.",""} )
		Next nX
	
		If oProcess != NIL				
			oProcess:IncRegua2( "Arquivo Importado... ") 
		Endif
			
	Endif
	
Endif
	
Return(!::lError)


***************************************************************************************************************************************************
&& Metodo : mStrTreat()
&& Descric: Faz o tratamento da String, removendo acentos e colocando em caixa alta.
&& Param  : String a ser tratada
&& Retorno: String ja tratada
***************************************************************************************************************************************************
Method mStrTreat(cString) Class PapBIImpCSV

Local cAcentos	:= "ÁÀÂÃáàâãÉÈÊéèêÍÌÎíìîÓÒÔÕóòôõÚÙÛÜúùûüÇç"
Local cAcSubst	:= "AAAAaaaaEEEeeeIIIiiiOOOOooooUUUUuuuuCc"
Local cTmp		:= ""
Local cTexto	:= ""
Local nI	   	:= 0
Local nAt		:= 0

cString := AllTrim(cString)

If ::lRemocAcen

	For nI := 1 To Len(cString)
		cTmp := SubStr( cString , nI , 1 )
		If ( nAt := At( cTmp , cAcentos ) ) > 0
			cTmp := SubStr( cAcSubst , nAt , 1 )
		Endif
		cTexto += cTmp
	Next nI
	
	cString := StrTran(AllTrim(cTexto),"$","")

Endif                  

If ::lUpperConv
	cString := Upper(cString)
Endif

Return(cString)


***************************************************************************************************************************************************
&& Metodo : mSetValid(nField,cType,cCmd)
&& Descric: Configura uma validacao para o campo em questao
&& Param  : Nenhum
&& Retorno: Nenhum
***************************************************************************************************************************************************
Method mSetValid(nField,cType,cCmd,cSQL) Class PapBIImpCSV

Local lOk		:= .F.
Local cJuncoes	:= "AND/OR"

If ::lStatus
	If cType $ cJuncoes
		::aValRules[nField] := {cType,cCmd,cSQL}
		lOk		:= .T.
	Endif
Endif                

Return(lOk)


***************************************************************************************************************************************************
&& Metodo : mExecValid()
&& Descric: Executa a validacao dos dados conforme as definicoes
&& Param  : Nenhum
&& Retorno: Nenhum
***************************************************************************************************************************************************
Method mExecValid(oProcess) Class PapBIImpCSV

Local nI		:= 0
Local nX		:= 0
Local lValid01	:= .T.
Local lValid02	:= .T.
Local lTmp		:= .T.
Local cInstruc	:= ""

If ::lStatus

	If oProcess != NIL				
		oProcess:IncRegua1("Executando Validações Secundárias... ") 
		oProcess:SetRegua2(Len(::aValRules)*Len(::aData)) 
	Endif

	For nI := 1 to Len(::aValRules)
	
		If oProcess != NIL				
			oProcess:IncRegua2( "Validações Secundárias... " )
		Endif		
	
		For nX := 1 to Len(::aData)
		
			If oProcess != NIL				
				oProcess:IncRegua2( "Validações Secundárias... " ) 
			Endif

			If !Empty(AllTrim(::aData[nX,nI]))
			
				lValid01	:= .T. 
				lValid02	:= .T.

				&& Verifica se existe uma validacao de Campo
				If !Empty(AllTrim(::aValRules[nI,2]))
					cInstruc := StrTran(::aValRules[nI,2],"cCampo","'"+::aData[nX,nI]+"'")
					If !&(cInstruc)
						lValid01	:= .F.
					Endif
				Endif
				
				If !Empty(AllTrim(::aValRules[nI,3]))
					cInstruc := StrTran(::aValRules[nI,3],"cCampo","'"+::aData[nX,nI]+"'")
				   	TcQuery cInstruc New Alias "VALSQL"
				   	If VALSQL->VALREG = 0
				   		lValid02	:= .F.
				   	Endif
				   	VALSQL->(dbCloseArea())				
				Endif
					
				If ::aValRules[nI,1] = 'AND'
					If !lValid01 .or. !lValid02
						::aCritic[nX,nI] := .F.
					Endif
				Elseif ::aValRules[nI,1] = 'OR'
					If !lValid01 .and. !lValid02
						::aCritic[nX,nI] := .F.
					Endif					
				Endif     

			Endif
	
		Next nX

	Next nI
	
	For nI := 1 to Len(::aCritic)
		lTmp := .T.
		For nX := 1 to ::nColunas
			If lTmp
				lTmp := ::aCritic[nI,nX]
			Endif
		Next nX
		::aCritic[nI,::nColunas+1] := lTmp
		If ::lStatus
			::lStatus := lTmp
		Endif
	Next nI	
	
Endif                

Return


***************************************************************************************************************************************************
&& Metodo : mShowData()
&& Descric: Exibe os Dados importados em um objeto ListBox
&& Param  : Nenhum
&& Retorno: Nenhum
***************************************************************************************************************************************************
Method mShowData() Class PapBIImpCSV

Local oLbl1, oListBox, oBtn01, oBtn02
Local oSize		:= PapxSSize():New(60, 5, 0)	//	New(90, 5, 0)
Local aCoordDLG	:= oSize:GetCDialog()
Local aCoordLBX	:= oSize:GetCListBox(5, 5)
Local aCoordBtn	:= oSize:GetCGetDados(0, 0)
Local aColSize	:= {}
Local aDesCabec	:= {}
Local cbLine 	:=  ""
Local nX 		:= 0
Local nTmp 		:= 0
Local aTmp		:= {}
Local aDataShow	:= ::aData

Private oClrVerd   	:= LoadBitmap( GetResources(), "BR_VERDE" )
Private oClrVerm  	:= LoadBitmap( GetResources(), "BR_VERMELHO" )

	If Len(aDataShow) > 0
	                   
		&& Monta o bloco de codigo de exibicao dos dados no listbox
		If ::lShowValid .and. ::lShwFieldS
			aDataShow := {}
			For nX := 1 to Len(::aData)
				aTmp := {}
				For nI := 1 to Len(::aData[nX])
					aadd( aTmp, ::aCritic[nX,nI] )
					aadd( aTmp, ::aData[nX,nI] )
				Next nI
				aadd( aTmp, ::aCritic[nX,::nColunas+1] )
				aadd(aDataShow, aClone(aTmp))
			Next nX
			
			aadd(aColSize,5)
			cbLine :=  "{ || { if( oListBox:aArray[oListBox:nAt, " + AllTrim(Str((::nColunas*2)+1)) +  " ], oClrVerd, oClrVerm ), "
			for nX := 1 to (::nColunas*2)
				If Mod(nX,2) == 0
					nTmp ++
					cbLine += " oListBox:aArray[oListBox:nAt, " + AllTrim(Str(nX)) +  " ] "
					aadd(aColSize,::aDataMaxC[nTmp]*3)
				Else
					cbLine += " if( oListBox:aArray[oListBox:nAt," + AllTrim(Str(nX)) +  " ], oClrVerd, oClrVerm ) "
					//cbLine += " if( oListBox:aArray[oListBox:nAt," + AllTrim(Str(nX)) +  " ], '', oClrVerm ) "
					aadd(aColSize,5)
				Endif
				cbLine += Iif(nX < (::nColunas*2), ", ","} }")
			Next nX			

			aadd(aDesCabec,"")
			For nX := 1 to ::nColunas
				aadd(aDesCabec,"")
				If ::lHasCabec
					aadd(aDesCabec,::aCabec[nX]) 
				Else
					aadd(aDesCabec,"")
				Endif					
			Next nX

		Elseif ::lShowValid .and. !::lShwFieldS
		
			aDataShow := {}
			For nX := 1 to Len(::aData)
				aTmp := {}
				For nI := 1 to Len(::aData[nX])
					aadd( aTmp, ::aData[nX,nI] )
				Next nI
				aadd( aTmp, ::aCritic[nX,::nColunas+1] )
				aadd(aDataShow, aClone(aTmp))
			Next nX		
		
			cbLine :=  "{ || { if( oListBox:aArray[oListBox:nAt, " + AllTrim(Str(::nColunas+1)) +  " ], oClrVerd, oClrVerm ), "
			for nX := 1 to (::nColunas)
				cbLine += " oListBox:aArray[oListBox:nAt, " + AllTrim(Str(nX)) +  " ] "
				cbLine += Iif(nX < (::nColunas), ", ","} }")
				aadd(aColSize,::aDataMaxC[nX]*3)
			Next nX
			
			aadd(aDesCabec,"")
			For nX := 1 to ::nColunas				
				If ::lHasCabec
					aadd(aDesCabec,::aCabec[nX]) 
				Else
					aadd(aDesCabec,"")
				Endif					
			Next nX

		Else
			cbLine :=  "{ || { "
			for nX := 1 to ::nColunas
				cbLine += " oListBox:aArray[oListBox:nAt, " + AllTrim(Str(nX)) +  " ] "
				cbLine += Iif(nX < ::nColunas, ", ","} }")
				aadd(aColSize,::aDataMaxC[nX]*3)
			Next nX
			
			If ::lHasCabec
				aDesCabec := ::aCabec
			Else
				For nX := 1 to ::nColunas
					aadd(aDesCabec,"")
				Next nX
			Endif
				
		Endif
	
		::oDlg	:= TDialog():New( aCoordDLG[1], aCoordDLG[2], aCoordDLG[3], aCoordDLG[4], ::cTitulo,,,,,,,,,.T.)
		::oDlg	:lCentered := .T.	
		oLbl1   := TSay():New(005, 005, { || "Total de Registros: " + StrZero(Len(aDataShow),5) } , ::oDlg,,,,,, .T.,,,)
		oListBox:= TWBrowse():New( aCoordLBX[1], aCoordLBX[2], aCoordLBX[3], aCoordLBX[4]-20,,aDesCabec, aColSize, ::oDlg,,,,,,,,,,,, .T.,,.T.,,,,,,)
		oListBox:SetArray(aDataShow)
		oListBox:bLine	:= &cbLine
		oBtn01 := TButton():New(aCoordBtn[3]-17, aCoordBtn[4]-110	,::cTextProce,	::oDlg, ::bProcessa, 50, 20 ,,,,.T. )
		oBtn02 := TButton():New(aCoordBtn[3]-17, aCoordBtn[4]-050	,::cTextSair,	::oDlg, ::bSair, 50, 20 ,,,,.T. )
		::oDlg	:Activate()
	Else
		::lError    := .T.
		::cError    := "Não foram encontrados dados no arquivo: " + ::cFile	
	Endif

Return


***************************************************************************************************************************************************
&& Fim da Classe
***************************************************************************************************************************************************
