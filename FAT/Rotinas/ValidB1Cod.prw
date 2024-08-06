#Include 'Protheus.ch'


/*/{Protheus.doc} ValB1Cod
Rotina para validar se o tamanho de caracteres é superior a 6.
Caso seja, é emitido um sinal de alerta ao usuário, informando
inserir um código de tamanho <=6
@author Gustavo
@since 03/03/2016
@version 1.0
/*/
User Function ValB1Cod()

	Local lStatus := .T.
	
	If Len(AllTrim(M->B1_COD))>6
		
		MsgAlert("Número de caracteres superior a 6")
		lStatus:= .F.
	
	EndIf	

Return lStatus

