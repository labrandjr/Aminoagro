#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M530FIL  ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 12/04/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtro complementar na atualização de pagto. comissão.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function M530FIL()

Local aArea := GetArea()
Local zCond := ""
Local cPerg := "A530PER"
Local cX1Bk := "MTA530"

If Pergunte(cPerg,.T.)
	If !Empty(mv_par01)
		zCond += "SE3->E3_PREFIXO == '"+mv_par01+"' "
	Endif
	If !Empty(mv_par02)
		zCond += IIf(!Empty(zCond),".And.","") + " SE3->E3_NUM == '"+mv_par02+"' "
	Endif
	If !Empty(mv_par03)
		zCond += IIf(!Empty(zCond),".And.","") + " SE3->E3_PARCELA == '"+mv_par03+"' "
	Endif
	If mv_par04 == 2 // Valor Gerado
		zCond += IIf(!Empty(zCond),".And.","") + " SE3->E3_COMIS <> 0"
	ElseIf mv_par04 == 3 // Valor Zero
		zCond += IIf(!Empty(zCond),".And.","") + " SE3->E3_COMIS == 0"
	Endif                                                             
Else
	zCond := ".F."
Endif

If Empty(zCond)
	zCond := ".T."
Endif

Pergunte(cX1Bk,.F.)
RestArea(aArea)
                                                                             
Return(zCond)
