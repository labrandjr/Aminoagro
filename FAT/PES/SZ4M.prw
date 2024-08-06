#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função SZ4M

Ponto de entrada MVC da rotina personalizada CadSZ4, que valida na manutenção
 a duplicação de chave.

@author 	Augusto Krejci Bem-Haja
@since 		19/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function SZ4M()
Local aParam     := PARAMIXB
Local lRetorno       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
 
If aParam <> NIL
    oObj       := aParam[1]
	cIdPonto   := aParam[2]
    cIdModel   := aParam[3]
      
    If cIdPonto == 'MODELPOS'
        lRetorno := U_VldGZ4(oObj)
    EndIf
EndIf
 
Return lRetorno