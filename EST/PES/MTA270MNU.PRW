#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA270MNU ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 07/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada no menu do Inventário para importação CSV.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA270MNU()

Local aArea      := GetArea()
Local aRotinaNew := {}

AAdd(aRotinaNew,{"Pesquisar"   , "AxPesqui"    , 0, 1, 0 , .F.})
AAdd(aRotinaNew,{"Visualizar"  , "A270Visual"  , 0, 2, 0 , Nil})
AAdd(aRotinaNew,{"Incluir"     , "A270Inclui"  , 0, 3, 17, Nil})
AAdd(aRotinaNew,{"Alterar"     , "A270Altera"  , 0, 4, 17, Nil})
AAdd(aRotinaNew,{"Excluir"     , "A270Deleta"  , 0, 5, 17, Nil})
AAdd(aRotinaNew,{"Imp Contagem", "u_InvCsv01()", 0, 3, 17})
AAdd(aRotinaNew,{"Sel Contagem", "A270Contag"  , 0, 3, 17})
AAdd(aRotinaNew,{"Sel Autom"   , "A270Autom"   , 0, 3, 17})
AAdd(aRotinaNew,{"Legenda"     , "A270Legend"  , 0, 2    })

RestArea(aArea)

Return(aRotinaNew)
