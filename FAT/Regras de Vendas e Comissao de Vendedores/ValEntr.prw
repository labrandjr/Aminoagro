#Include 'Protheus.ch'
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função ValEntr

Função que checa a data de entrega dos itens do pedido selecionado, e caso seja superior a data base, retorna falso.

@author 	Augusto Krejci Bem-Haja
@since 		14/01/2016
@return		Booleano
/*/
//-------------------------------------------------------------------

User Function ValEntr()
	Local aArea		:= GetArea()
	Local lRetorno	:= .T. 	
	
	lRetorno := ChkItens(@lRetorno)
	
	RestArea(aArea)
Return lRetorno

Static Function ChkItens(lRetorno)
	Local cMens		:= ""	
	Local cAlias	:= ""
	Local cNumPed	:= SC5->C5_NUM

	cAlias := QryRgs(cNumPed)
	(cAlias)->(dbGoTop())
	/* // Desligado conforme chamado 001178 de 02/06/2021
	While !(cAlias)->(Eof())
		If ((cAlias)->C6_ENTREG > DtoS(dDatabase))
			lRetorno := .F.
		Endif
		(cAlias)->(DbSkip())
	Enddo
	*/	
	If !(lRetorno)
		cMens := "Existem itens com data de entrega superior a data de faturamento!"
		cMens += CHR (13) + CHR (10) + CHR (13) + CHR (10)
		cMens += "Documento de Saída não será gerado!"
		MsgAlert (cMens) 
	Endif

	(cAlias)->(DbCloseArea())
	
Return lRetorno

Static Function QryRgs(cNumPed) 
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cEol   := chr(10) + chr(13)
	
	cQuery := " SELECT * FROM " +RetSqlName("SC9") +" SC9 "+ cEol
	cQuery += " INNER JOIN "+RetSqlName("SC6") + " SC6 ON (C9_PEDIDO = C6_NUM)" + cEol 
	cQuery += " AND (C9_ITEM = C6_ITEM)" + cEol 	
	cQuery += " WHERE C9_PEDIDO = '"+ cNumPed +"'"+ cEol
	cQuery += " AND C9_BLEST = '' "+ cEol
	cQuery += " AND C9_BLCRED = '' "+ cEol
	cQuery += " AND SC9.D_E_L_E_T_ <> '*' " + cEol
	cQuery += " AND SC6.D_E_L_E_T_ <> '*' " + cEol
			
	TCQUERY cQuery NEW ALIAS &cAlias	
Return cAlias
