#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UPDPOCR    ¦ Autor ¦ Fábrica ERPBR    ¦   Data ¦ 03/01/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualiza portador nos títulos a receber - Incorporação.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UPDPOCR()

Private oProcess

If MsgYesNo("Confirma o processamento - ATUALIZA PORTADOR TÍTULOS A RECEBER ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Atualização de Portador", "Aguarde, processando ...", .F. )
	oProcess:Activate()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  03/01/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nTotReg := 0

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '0108' "
cQuery += " AND E1_ZFILINC = '0104' "
cQuery += " AND E1_IDCNAB = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotReg := SQL->SOMA
SQL->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ RECSE1 "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '0108' "
cQuery += " AND E1_ZFILINC = '0104' "
cQuery += " AND E1_IDCNAB = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
oProcess:SetRegua1(nTotReg)
While !Eof()
	
	oProcess:IncRegua1("Atualizando portador..")

	DbSelectArea("SE1")
	SE1->(DbGoto(SQL->RECSE1))

	cQuery := " SELECT E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_SITUACA, E1_NUMBOR, E1_IDCNAB "
	cQuery += " FROM SE1TST "
	cQuery += " WHERE E1_FILIAL = '"+SE1->E1_ZFILINC+"' "
	cQuery += " AND E1_PREFIXO = '"+SE1->E1_PREFIXO+"' "
	cQuery += " AND E1_NUM = '"+SE1->E1_NUM+"' "
	cQuery += " AND E1_PARCELA = '"+SE1->E1_PARCELA+"' "
	cQuery += " AND E1_TIPO = '"+SE1->E1_TIPO+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

	DbSelectArea("SQL1")
	If SQL1->(!Eof())
		RecLock("SE1",.F.)
		SE1->E1_PORTADO := SQL1->E1_PORTADO
		SE1->E1_AGEDEP  := SQL1->E1_AGEDEP
		SE1->E1_CONTA   := SQL1->E1_CONTA
		SE1->E1_SITUACA := SQL1->E1_SITUACA
		SE1->E1_NUMBOR  := SQL1->E1_NUMBOR
		SE1->E1_IDCNAB  := SQL1->E1_IDCNAB
		MsUnLock()
	Endif		
	SQL1->(DbCloseArea())

	DbSelectArea("SQL")
	SQL->(DbSkip())		
Enddo
SQL->(DbCloseArea())

Return
