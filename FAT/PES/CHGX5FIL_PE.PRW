#INCLUDE "RWMAKE.CH"       

/*/{Protheus.doc} CHGX5FIL
                             
Ponto de Entrada chamado para filtrar as S�ries de Notas Fiscais conforme a Filial 
que est� sendo utilizada.

@author Cassiano G. Ribeiro
@since 16/07/201
/*/
User Function CHGX5FIL()
	Local cRet 	:= ""
	
	cRet := xFilial("SF2")
  
Return (cRet)