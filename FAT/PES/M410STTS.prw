#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o M410STTS

Este ponto de entrada pertence � rotina de pedidos de venda, MATA410(). Est� em todas as rotinas de altera��o, inclus�o, exclus�o e devolu��o de compras. Executado ap�s todas as altera��es no arquivo de pedidos terem sido feitas.

@author 	Augusto Krejci Bem-Haja
@since 		12/01/2016
@return		Booleano
/*/
//-----------------

User Function M410STTS()
	
If FunName() != "MATA311" // Transfer�ncia de Filiais
	U_ValReg()
Endif

U_QQFAT01()
	
Return
