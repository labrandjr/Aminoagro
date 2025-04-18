#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � UPDBXCM  � Autor � F�brica ERPBR    � Data � Out-2023	  ���
��+----------+------------------------------------------------------------���
���Descricao � Restaura data de baixa de comiss�o a partir de Bkp.		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function UPDBXCM()

Private oProcess

If !(__cUserId $("000000,000163"))
	MsgAlert("Usu�rio n�o autorizado.")
	Return
Endif

If MsgYesNo("Confirma o processamento - ATUALIZA BAIXA DE COMISS�O ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Atualiza��o baixa de comiss�o", "Aguarde, processando ...", .F. )
	oProcess:Activate()
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR   � Data �  13/10/2023   ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento principal.									  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

Local nTotReg  := 0

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM SE3G100110 "
cQuery += " WHERE E3_DATA <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotReg := SQL->SOMA
SQL->(DbCloseArea())

cQuery := " SELECT E3_FILIAL, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_SEQ, E3_VEND, E3_ZZACORD, E3_DATA "
cQuery += " FROM SE3G100110 "
cQuery += " WHERE E3_DATA <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
oProcess:SetRegua1(nTotReg)
While !Eof()
	
	oProcess:IncRegua1("Atualizando baixa de comiss�o")

	DbSelectArea("SE3")
	DbSetOrder(5)
	If DbSeek( SQL->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND+E3_ZZACORD) )
		If Empty(SE3->E3_DATA)
			RecLock("SE3",.F.)
			SE3->E3_DATA := StoD(SQL->E3_DATA)
			MsUnLock()
		Endif	
	Else
		MsgInfo("N�o achou: "+SQL->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND+E3_ZZACORD))
	Endif

	DbSelectArea("SQL")
	SQL->(DbSkip())		
Enddo
SQL->(DbCloseArea())

Return
