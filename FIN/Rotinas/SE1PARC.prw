#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SE1PARC  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 24/11/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Retorna numero de parcelas SE1							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SE1PARC(_cFilial,_cPrefixo,_cNum,_cCliente,_cLoja)

Local aArea		:= GetArea()
Local _cReturn	:= 0

cQuery := " SELECT COUNT(*) PARCELA "
cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
cQuery += " WHERE E1_FILIAL = '" + _cFilial + "' "
cQuery += " AND E1_PREFIXO = '" + _cPrefixo + "'
cQuery += " AND E1_NUM = '" + _cNum + "'
cQuery += " AND E1_CLIENTE = '" + _cCliente + "'
cQuery += " AND E1_LOJA = '" + _cLoja + "'
cQuery += " AND D_E_L_E_T_ <> '*'

DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())

If SQL->(!Eof())
	_cReturn = SQL->PARCELA
Endif                      

SQL->(DbCloseArea())

RestArea(aArea)

Return(_cReturn)
