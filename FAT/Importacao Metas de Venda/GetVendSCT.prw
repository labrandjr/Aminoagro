#Include 'Protheus.ch'

/*/{Protheus.doc} GetVendSCT()

Rotina para posicionar o nome do vendedor no campo CT_ZZNOME. Chamada realizada no inicializador padrão
do campo CT_ZZNOME 

@author Gustavo Luiz
@since 10/05/2016

/*/
User Function GetVendSCT()

	Local cNome := ""

	If !INCLUI
	
		cNome:= POSICIONE("SA3",1,XFILIAL("SA3")+SCT->CT_VEND,'A3_NOME')                        
	
	EndIf

Return cNome

