#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função M410STTS

Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). Está em todas as rotinas de alteração, inclusão, exclusão e devolução de compras. Executado após todas as alterações no arquivo de pedidos terem sido feitas.

@author 	Augusto Krejci Bem-Haja
@since 		12/01/2016
@return		Booleano
/*/
//-----------------

User Function M410STTS()
	
If FunName() != "MATA311" // Transferência de Filiais
	U_ValReg()
Endif

U_QQFAT01()
	
Return
