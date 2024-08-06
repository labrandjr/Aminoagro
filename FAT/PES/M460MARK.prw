#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o M460MARK

O ponto de entrada M460MARK � utilizado para validar os pedidos marcados e est� localizado no inicio 
da fun��o a460Nota (endere�a rotinas para a gera��o dos arquivos SD2/SF2).Ser� informado no terceiro 
par�metro a s�rie selecionada na gera��o da nota e o n�mero da nota fiscal poder� ser verificado pela 
vari�vel private cNumero.

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
