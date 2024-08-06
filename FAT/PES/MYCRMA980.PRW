#include "protheus.ch"
#include "fwmvcdef.ch"

//Static __LogTela    := NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980
Ponto de Entrada do Cadastro de Clientes (MVC)
@param      Nao ha
@return     Varios. Dependerá de qual PE esta sendo executado.
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
User Function CRMA980() ///cXXX1,cXXX2,cXXX3,cXXX4,cXXX5,cXXX6

	Local aParam        := PARAMIXB
	Local xRet          := .T.
	Local lIsGrid       := .F.
//	Local nLinha        := 0
//  Local nQtdLinhas    := 0
//	Local cRotMVC       := "CRMA980"
	Local cIDPonto      := ''
	Local cIDModel      := ''
//	Local cIDForm       := ''
//	Local cEvento       := ''
//	Local cCampo        := ''
//	Local cConteudo     := ''
//  Local cMsg          := ''
	Local oObj          := NIL

//	If __LogTela == NIL
//		__LogTela   := ApMsgYesNo("A geracao do 'LOG de processamento' dos PE 'CRMA980' (MVC) sera exibido em TELA?" + CRLF + CRLF +;
//			'SIM = TELA' + CRLF +;
//			'NAO = CONSOLE do AppServer')
//	EndIf

	If aParam <> NIL

		oObj        := aParam[1]
		cIDPonto    := aParam[2]
		cIDModel    := aParam[3]
		lIsGrid     := (Len(aParam) > 3)
		nOperation := oObj:GetOperation()

		If cIdPonto == 'MODELPOS'

			lBlqSap := GetMv("MV_ZBLQSAP")
			If lBlqSap
				MsgInfo("Bloqueio migra��o Sap !")
				xRet := .F.
			Endif

		ElseIf cIdPonto == 'BUTTONBAR'

//			ApMsgInfo("Adicionando um botao na barra de botoes da rotina (PE '" + cIDPonto + "')." + CRLF +;
//					"ID '" + cIDModel + "'")
	
			xRet := {{"Agrometrika", "POSCLI", {|| IIf(Inclui, U_AGRMTK3("I",oObj), U_AGRMTK3("A",oObj))}, "Agrometrika"}}

			/*
			xRet    := {{'TITULO DO BOTAO',;                              //Titulo para o botão
						'SALVAR',;                                         //Nome do Bitmap para exibição
						{|| Alert('Executou uma rotina especifica!')},;    //CodeBlock a ser executado
						'Este botao executa uma rotina especifica.'}}      //ToolTip (Opcional)
			*/

		Endif

	Endif

Return xRet
