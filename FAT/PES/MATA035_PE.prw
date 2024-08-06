#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função MATA035

Ponto de entrada MVC da rotina padrão MATA035, que valida a exclusão de grupo de produto.

@author 	Augusto Krejci Bem-Haja
@since 		05/02/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function MATA035()
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
        lRetorno := U_VldExBM(oObj)
    EndIf
EndIf
 
Return lRetorno