#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LBESTA01 ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 11/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Liberação de Estoque - Automática.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LBESTA01()

Local nOpca    := 0
Local aSays    := {}
Local aButtons := {}
Local cPerg    := "LIBAT2"

ConOut("Função LBESTAUT: Liberação Automática do Estoque < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza arquivo de liberados para geracao na nota            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SC9")
DbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 Pedido de          ?                                 ³
//³ mv_par02 Pedido ate         ?                                 ³
//³ mv_par03 Cliente de         ?                                 ³
//³ mv_par04 Cliente ate        ?                                 ³
//³ mv_par05 Dta Liberacao de   ?                                 ³
//³ mv_par06 Dta Liberacao ate  ?                                 ³
//³ mv_par07 Quanto ao Estoque  ? Estoque/WMS  WMS                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte( cPerg, .F. )
mv_par01 := Space(6)
mv_par02 := "ZZZZZZ"
mv_par03 := Space(6)
mv_par04 := "ZZZZZZ"
mv_par05 := StoD("20160401")
mv_par06 := StoD("20201231")
mv_par07 := 1
Ma450Proces( "SC9", .F., .T., .F., Nil, MV_PAR07==2 )

ConOut("Função LBESTAUT: Liberação Automática do Estoque < Fim > "+DtoC(Date())+" - "+Time())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 19/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LBEST01()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_LBESTA01()
Return

User Function LBEST02()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_LBESTA01()
Return

User Function LBEST03()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_LBESTA01()
Return

User Function LBEST04()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_LBESTA01()
Return

User Function LBEST06()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_LBESTA01()
Return

User Function LBEST07()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_LBESTA01()
Return

User Function LBEST08()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_LBESTA01()
Return

User Function LBEST09()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_LBESTA01()
Return

User Function LBEST10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_LBESTA01()
Return
