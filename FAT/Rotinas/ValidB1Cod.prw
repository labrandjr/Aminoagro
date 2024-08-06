#Include 'Protheus.ch'


/*/{Protheus.doc} ValB1Cod
Rotina para validar se o tamanho de caracteres � superior a 6.
Caso seja, � emitido um sinal de alerta ao usu�rio, informando
inserir um c�digo de tamanho <=6
@author Gustavo
@since 03/03/2016
@version 1.0
/*/
User Function ValB1Cod()

	Local lStatus := .T.
	
	If Len(AllTrim(M->B1_COD))>6
		
		MsgAlert("N�mero de caracteres superior a 6")
		lStatus:= .F.
	
	EndIf	

Return lStatus

