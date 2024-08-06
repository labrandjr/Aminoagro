#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA094RO  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 19/09/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na rotina de liberação de documentos.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA094RO()

Local aRotina := PARAMIXB[1]

AAdd(aRotina, {"Conhecimento", "U_Mt094Doc()" , 0, 4, 0, Nil} )

Return(aRotina)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Mt094Doc  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 19/09/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pesquisa o documento relacionado ao pedido de compra.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function Mt094Doc()

Local aArea   := GetArea()

aRotina := {}
AAdd(aRotina,{"Pesquisar"   , "AxPesqui"  , 0, 1, 0, Nil})
AAdd(aRotina,{"Visualizar"  , "AxVisual"  , 0, 2, 0, Nil})
AAdd(aRotina,{"Incluir"     , "AxInclui"  , 0, 3, 0, Nil})
AAdd(aRotina,{"Alterar"     , "AxAltera"  , 0, 4, 0, Nil})
AAdd(aRotina,{"Excluir"     , "AxDeleta"  , 0, 5, 0, Nil})

If SCR->CR_TIPO == "PC"

	cQuery := " SELECT AC9_CODENT CODENT "
	cQuery += " FROM " + RetSqlName("AC9")
	cQuery += " WHERE AC9_FILENT = '"+SCR->CR_FILIAL+"' " 
	cQuery += " AND AC9_ENTIDA = 'SC7' "
	cQuery += " AND SUBSTR(AC9_CODENT,1,4) = '"+AllTrim(SCR->CR_FILIAL)+"' "
	cQuery += " AND SUBSTR(AC9_CODENT,5,6) = '"+AllTrim(SCR->CR_NUM)+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL9", .F., .T.)
	DbSelectArea("SQL9")
	SQL9->(DbGotop())
	If !Eof()
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek( Substr(SQL9->CODENT,1,14) ) // Filial + Pedido + Item associado ao documento
			MsDocument("SC7",SC7->(RecNo()),4)
		Else
			MsgAlert("Documento não associado ao Pedido.")
		Endif
	Else
		MsgAlert("Documento não associado ao Pedido.")
	Endif
	SQL9->(DbCloseArea())

Else

Endif

RestArea(aArea)

Return
