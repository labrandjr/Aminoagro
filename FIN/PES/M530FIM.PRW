#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M530FIM  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 04/01/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização do pagamento das comissões Revenda = zero.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function M530FIM()

Local aArea   := GetArea()
Local zQryAdd := ""

Pergunte("A530PER",.F.)

If !Empty(mv_par01)
	zQryAdd += "E3_PREFIXO = '"+mv_par01+"' "
Endif
If !Empty(mv_par02)
	zQryAdd += IIf(!Empty(zQryAdd)," AND ","") + " E3_NUM = '"+mv_par02+"' "
Endif
If !Empty(mv_par03)
	zQryAdd += IIf(!Empty(zQryAdd)," AND ","") + " E3_PARCELA = '"+mv_par03+"' "
Endif
If mv_par04 == 2 // Valor Gerado
	zQryAdd += IIf(!Empty(zQryAdd)," AND ","") + " E3_COMIS <> 0 "
ElseIf mv_par04 == 3 // Valor Zero
	zQryAdd += IIf(!Empty(zQryAdd)," AND ","") + " E3_COMIS = 0 "
Endif	

If Empty(zQryAdd)
	zQryAdd := " E3_FILIAL <> ' ' "
Endif

Pergunte("MTA530",.F.)

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE3")
If mv_par13 == 1
	cQuery += " WHERE E3_FILIAL BETWEEN '"+mv_par14+"' AND '"+mv_par15+"' "
Else
	cQuery += " WHERE E3_FILIAL = '"+xFilial("SE3")+"' "
Endif
cQuery += " AND E3_VEND BETWEEN '"+mv_par04+"' AND '"+mv_par05+"' "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
cQuery += " AND E3_DATA = ' ' "
cQuery += " AND E3_VENCTO BETWEEN '"+DtoS(mv_par10)+"' AND '"+DtoS(mv_par11)+"' "
cQuery += " AND "+zQryAdd
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)

DbSelectArea("SQE3")
SQE3->(DbGotop())
While !Eof()

	DbSelectArea("SE3")
	DbGoto(SQE3->R_E_C_N_O_)

	dVencto := IIf(mv_par12 == 1,SE3->E3_VENCTO,mv_par06)
	RecLock("SE3",.F.)
	SE3->E3_DATA := dVencto
	MsUnLock()
		
	DbSelectArea("SQE3")
	SQE3->(DbSkip())
Enddo
SQE3->(DbCloseArea())

RestArea(aArea)

Return
