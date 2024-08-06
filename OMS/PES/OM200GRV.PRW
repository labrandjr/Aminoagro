#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ OM200GRV  ¦ Autor ¦ Luis Brandini    ¦    Data  ¦ 23/05/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar na montagem de carga.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function OM200GRV()

Local aArea := GetArea()
/*
Local nConv := RetField("SB1",1,xFilial("SB1") + TRBSC9->C9_PRODUTO,"B1_CONV")

If mv_par06 == 1 // por Item
    RecLock("TRBPED",.F.)
    TRBPED->PED_VOLUM += (TRBSC9->C9_QTDLIB / nConv)
    MsUnLock()
ElseIf mv_par06 == 2 // por Item
    RecLock("TRBPED",.F.)
    TRBPED->PED_VOLUM := (TRBSC9->C9_QTDLIB / nConv)
    MsUnLock()
Endif
*/
RestArea(aArea)

Return
