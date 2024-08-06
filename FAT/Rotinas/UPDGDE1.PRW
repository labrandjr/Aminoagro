#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UPDGDE1   ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 22/01/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização do gerente e diretor no SE1 a partir do SF2.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UPDGDE1()

If __cUserId != "000163"
	MsgAlert("Usuário não autorizado.")
	Return
Endif

If MsgYesNo("Confirma o processamento - ATUALIZAÇÃO GER E DIR no Título ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | ProcImp() }, "Atualizando dados", "Aguarde, processando ...", .F. )
	oProcess:Activate()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ 22/01/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SE1")+" SE1 "
cQuery += " WHERE F2_FILIAL = E1_FILIAL "
cQuery += " AND F2_DOC = E1_NUM "
cQuery += " AND F2_SERIE = E1_PREFIXO "
cQuery += " AND F2_VEND1 <> ' ' "
cQuery += " AND F2_GEREN1 <> E1_GEREN1 "
cQuery += " AND F2_VEND1 <> '555555' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

cQuery := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_VEND1, F2_GEREN1, F2_SUPER1, E1_GEREN1, E1_SUPER1 "
cQuery += " FROM "+RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SE1")+" SE1 "
cQuery += " WHERE F2_FILIAL = E1_FILIAL "
cQuery += " AND F2_DOC = E1_NUM "
cQuery += " AND F2_SERIE = E1_PREFIXO "
cQuery += " AND F2_VEND1 <> ' ' "
cQuery += " AND F2_GEREN1 <> E1_GEREN1 "
cQuery += " AND F2_VEND1 <> '555555' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

oProcess:SetRegua1(nTotSql)

DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()

	oProcess:IncRegua1("Atualizando dados no título")

	DbSelectArea("SE1")
	DbSetOrder(1)
	If DbSeek( SQL1->(F2_FILIAL + F2_SERIE + F2_DOC ) )
		While !Eof() .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM) == SQL1->(F2_FILIAL + F2_SERIE + F2_DOC )
			RecLock("SE1",.F.)
			SE1->E1_GEREN1 := SQL1->F2_GEREN1
			SE1->E1_SUPER1 := SQL1->F2_SUPER1
			MsUnLock()
			SE1->(DbSkip())
		Enddo
	Endif

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

MsgInfo("Processamento concluído.")

Return
