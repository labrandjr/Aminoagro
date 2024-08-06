#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função M460MARK

O ponto de entrada M460MARK é utilizado para validar os pedidos marcados e está localizado no inicio 
da função a460Nota (endereça rotinas para a geração dos arquivos SD2/SF2).Será informado no terceiro 
parâmetro a série selecionada na geração da nota e o número da nota fiscal poderá ser verificado pela 
variável private cNumero.

@author 	Augusto Krejci Bem-Haja
@since 		18/01/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function M460MARK()

Local lRetMark := .F.

If FunName() != "MATA460B"
	lRetMark := U_VldEntr("FAT")
Else
	lRetMark := U_VldEntr("OMS")
Endif	
	
Return(lRetMark)
