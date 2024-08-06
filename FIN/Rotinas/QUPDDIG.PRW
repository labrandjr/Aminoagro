#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QUPDDIG ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/06/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Preenche data do evento na movimentação bancária.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QUPDDIG()

ConOut("Função QUPDDIG: Data do evento na Movimentação Bancária < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

cQuery := " SELECT R_E_C_N_O_ RECSE5 "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
cQuery += " AND E5_ZDATDIG = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
While !Eof()
	//
	DbSelectArea("SE5")
	DbSetOrder(1)
	SE5->(DbGoto(SQL5->RECSE5))
	//
	RecLock("SE5",.F.)
	SE5->E5_ZDATDIG := Date()
	MsUnLock()
	//
	DbSelectArea("SQL5")
	SQL5->(DbSkip())
Enddo	
SQL5->(DbCloseArea())

ConOut("Função QUPDDIG: Data do evento na Movimentação Bancária < Fim > "+DtoC(Date())+" - "+Time())
//
ConOut("Função QUPDDIG: Flag de envio Cnab para negociações < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

cQuery := " SELECT R_E_C_N_O_ RECSE1 "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND E1_ZZCNAB = ' ' "
cQuery += " AND E1_TIPO NOT IN('RA','NCC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
While !Eof()
	//
	DbSelectArea("SE1")
	DbSetOrder(1)
	SE1->(DbGoto(SQL1->RECSE1))
	//
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
	//
	RecLock("SE1",.F.)
	SE1->E1_ZZCNAB := SA1->A1_ZZCNAB
	MsUnLock()
	//
	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo	
SQL1->(DbCloseArea())

ConOut("Função QUPDDIG: Flag de envio Cnab para negociações < Fim > "+DtoC(Date())+" - "+Time())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/06/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QUPDDG1()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QUPDDIG()
Return

User Function QUPDDG2()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_QUPDDIG()
Return

User Function QUPDDG3()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_QUPDDIG()
Return

User Function QUPDDG4()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_QUPDDIG()
Return

User Function QUPDDG6()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_QUPDDIG()
Return

User Function QUPDDG7()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_QUPDDIG()
Return

User Function QUPDDG8()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_QUPDDIG()
Return

User Function QUPDDG9()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_QUPDDIG()
Return

User Function QUPDD10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_QUPDDIG()
Return
