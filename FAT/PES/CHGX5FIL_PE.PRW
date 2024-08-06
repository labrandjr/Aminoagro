#INCLUDE "RWMAKE.CH"       

/*/{Protheus.doc} CHGX5FIL
                             
Ponto de Entrada chamado para filtrar as Séries de Notas Fiscais conforme a Filial 
que está sendo utilizada.

@author Cassiano G. Ribeiro
@since 16/07/201
/*/
User Function CHGX5FIL()
	Local cRet 	:= ""
	
	cRet := xFilial("SF2")
  
Return (cRet)