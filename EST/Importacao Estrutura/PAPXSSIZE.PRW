#INCLUDE "protheus.ch"
#INCLUDE "msobject.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse    ³PAPXSSIZE ºAutor  ³Matheus Nogueira    º Data ³  25/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe para a manipulacao de coordenadas de acordo com a    º±±
±±º          ³resolucao de cada terminal.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProjeto   ³ - Papirus -                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 7.10 MS Sql Server                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Class PapxSSize

	Data aSSize		as Array
	Data nColunas	as Integer
	Data nBorda		as Integer
	Data nPercent	as Integer
	Data nHDialog	as Integer
	Data nVDialog	as Integer
	Data nHorSize	as Integer
	Data nVerSize	as Integer
	Data nHorMax	as Integer
	Data nVerMax	as Integer

	Method New(nParPercent, nParBorda, nParColunas) Constructor
	Method GetCDialog(nParCol, nParLin)
	Method GetCEnchoice(nParCol, nParLin)
	Method GetCGetDados(nParCol, nParLin)
	Method GetCListBox(nParCol, nParLin)

    && Metodos Especias para controle de tela cheia
	Method GetCWindow(nParLin, nParCol)
	Method GetCWLisBox(nParLin, nParCol)	
	Method GetCWGetDados(nParLin, nParCol)
	
EndClass


&& *********************************************************************************************************************************************************************
&& Metodo Construtor
Method New(nParPercent,nParBorda,nParColunas) Class Papxssize

	::nPercent	:= iif(Valtype(nParPercent) == "U", 	100, nParPercent)
	::nColunas	:= iif(Valtype(nParColunas) == "U", 	1, nParColunas)
	::nBorda	:= iif(Valtype(nParBorda) == "U", 		5, nParBorda)
	::aSSize 	:= {0,12,636,308,1100,736,120} //MSAdvSize() //{0,12,636,308,1272,736,120} //MSAdvSize() //Configuracoes do notebook  
	::nHorSize	:= Round( (((::aSSize[5]/2) / 100) * ::nPercent) ,0)     //3
	::nVerSize	:= Round( (((::aSSize[6]/2) / 100) * ::nPercent) ,0)     //4
	::nHDialog	:= ::nHorSize * 2
	::nVDialog	:= ::nVerSize * 2
	::nHorMax	:= ::aSSize[5] + 8
	::nVerMax	:= ::aSSize[6] + 8 
		
Return .T.


&& *********************************************************************************************************************************************************************
&& Metodo para retorno de coodenadas do Dialogo
Method GetCDialog(nParLin, nParCol) Class PapxSSize

Local nParCol	:= iif(Valtype(nParCol) == "U", 	0, nParCol)
Local nParLin	:= iif(Valtype(nParLin) == "U", 	0, nParLin)
Local nSizeV	:= ::nVDialog + nParLin
Local nSizeH	:= ::nHDialog + nParCol
Local aRet := {nParLin, nParCol, nSizeV, nSizeH }
	
Return aRet


&& *********************************************************************************************************************************************************************
&& Metodo para retorno de coodenadas da Enchoice
Method GetCEnchoice(nParLin, nParCol) Class PapxSSize

Local nParLin	:= Round(  iif(Valtype(nParLin) == "U", 	::nBorda, nParLin)  ,0)
Local nParCol	:= Round(  iif(Valtype(nParCol) == "U", 	::nBorda, nParCol)  ,0)
Local nSizeV	:= ::nVerSize - ::nBorda
Local nSizeH	:= ::nHorSize - ::nBorda
Local aRet		:= {nParLin, nParCol , nSizeV, nSizeH }

Return aRet
                                     

&& *********************************************************************************************************************************************************************
&& Metodo para retorno de coodenadas da GetDados
Method GetCGetDados(nParLin, nParCol) Class PapxSSize

Local nParLin	:= Round(  iif(Valtype(nParLin) == "U", 	::nBorda, nParLin)  ,0)
Local nParCol	:= Round(  iif(Valtype(nParCol) == "U", 	::nBorda, nParCol)  ,0)
Local nSizeV	:= ::nVerSize - ::nBorda
Local nSizeH	:= ::nHorSize - ::nBorda
Local aRet		:= {nParLin, nParCol , nSizeV, nSizeH }

Return aRet


&& *********************************************************************************************************************************************************************
&& Metodo para retorno de coodenadas da GetDados
Method GetCListBox(nParLin, nParCol) Class PapxSSize

Local nParLin	:= Round(  iif(Valtype(nParLin) == "U", 	::nBorda, nParLin)  ,0)
Local nParCol	:= Round(  iif(Valtype(nParCol) == "U", 	::nBorda, nParCol)  ,0)
Local nSizeV	:= ::nVerSize - (::nBorda * 2) - iif(nParLin > ::nBorda, nParLin - ::nBorda,0)
Local nSizeH	:= ::nHorSize - (::nBorda * 2) - iif(nParCol > ::nBorda, nParCol - ::nBorda,0)
Local aRet		:= {nParLin, nParCol, nSizeH, nSizeV }

Return aRet


&& *********************************************************************************************************************************************************************
&& Metodo para retorno de coodenadas de Janela Total
Method GetCWindow(nParLin, nParCol) Class PapxSSize

Local nParCol	:= iif(Valtype(nParCol) == "U", 	0, nParCol)
Local nParLin	:= iif(Valtype(nParLin) == "U", 	0, nParLin)
Local nSizeV	:= ::nVerMax + if( nParLin > 0, 0, nParLin)+ 4
Local nSizeH	:= ::nHorMax + if( nParCol > 0, 0, nParCol)
Local aRet := {nParLin, nParCol, nSizeV, nSizeH }

//Alert(StrZero(nParLin,4) + " - " + StrZero(nParCol,4) + " - " +  StrZero(nSizeV,4) + " - " + StrZero(nSizeH,4) )	
	
Return aRet


&& *********************************************************************************************************************************************************************
&& Metodo para retorno de coodenadas de Janela Total
Method GetCWLisBox(nParLin, nParCol) Class PapxSSize

Local nParCol	:= iif(Valtype(nParCol) == "U", 	0, nParCol)
Local nParLin	:= iif(Valtype(nParLin) == "U", 	0, nParLin)
Local nSizeV	:= Round((((::nVerMax + if( nParLin > 0, 0, nParLin) ) / 2 ) - nParLin) - ::nBorda + 2, 0 )
Local nSizeH	:= Round((((::nHorMax + if( nParCol > 0, 0, nParCol) ) / 2 ) - nParCol) - ::nBorda, 0 )
Local aRet := {nParLin, nParCol, nSizeH, nSizeV }

//Alert(StrZero(nParLin,4) + " - " + StrZero(nParCol,4) + " - " +  StrZero(nSizeH,4) + " - " + StrZero(nSizeV,4) )	
	
Return aRet

//Alert(StrZero(nParLin,3) + " - " + StrZero(nParCol,3) + " - " +  StrZero(nSizeV,3) + " - " + StrZero(nSizeH,3) )	
//Alert(StrZero(0,3) + " - " + StrZero(0,3) + " - " +  StrZero(::aSSize[6],3) + " - " + StrZero(::aSSize[5],3) )

&& *********************************************************************************************************************************************************************
&& Metodo para retorno de coodenadas de Janela Total
Method GetCWGetDados(nParLin, nParCol) Class PapxSSize

Local nParCol	:= iif(Valtype(nParCol) == "U", 	0, nParCol)
Local nParLin	:= iif(Valtype(nParLin) == "U", 	0, nParLin)
Local nSizeV	:= ::nVerSize - ::nBorda
Local nSizeH	:= ::nHorSize - ::nBorda
Local aRet := {nParLin, nParCol, nSizeV, nSizeH }

// Alert(StrZero(nParLin,4) + " - " + StrZero(nParCol,4) + " - " +  StrZero(nSizeH,4) + " - " + StrZero(nSizeV,4) )	
	
Return aRet
