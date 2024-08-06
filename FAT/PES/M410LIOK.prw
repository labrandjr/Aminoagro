#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função M410LIOK

Ponto de entrada para validação de linha no pedido de venda.

@author 	Augusto Krejci Bem-Haja
@since 		25/01/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function M410LIOK()

Local lRetorno := .T.
Local lAltCpM2 := (Altera .And. SC5->C5_XEMCOP2 == "S")

If FunName() != "INCPEDV"
	lRetorno := U_VldLin(.F.,Nil,Nil,Nil,Nil,Nil,Nil,lAltCpM2)
Endif	

Return lRetorno
