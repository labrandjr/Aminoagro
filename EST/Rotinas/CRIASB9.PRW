#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CRIASB9   � Autor � F�brica ERPBR    �   Data  � 06/11/18  ���
��+----------+------------------------------------------------------------���
���Descricao � Cria saldo inicial zero em novo armaz�m.			 		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CRIASB9()

Local lOk    := .F.
Local lEnd	 := .F.
Local cPerg	 := Padr("CRIASB9",10)
Private cEOL := CHR(13)+CHR(10)
Private oProcess

If __cUserId != "000000" // Administrador, Jefferson Costa, Paul Bergman
	MsgInfo("Usu�rio n�o autorizado.")
	Return
Endif

If Pergunte(cPerg,.T.)
	Preparar()
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � Preparar  � Autor � Fabrica ERPBR    � Data �  07/11/18	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Prepara o processamento principal.						  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Preparar()

If Empty(mv_par01)
	MsgAlert("Armaz�m n�o informado. Revise os par�metros.")
	Return
Endif

If MsgYesNo("Confirma a cria��o de saldo inicial (ZERO) para todos os produtos no armaz�m informado ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Criando saldo inicial ZERO.", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	MsgBox("Processamento conclu�do !!!","Aviso","INFO")
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data �  04/06/18	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da rotina.									  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

Local zFiliais := ""
Local nForFilial
Local _x

aFilsCalc := MatFilCalc( mv_par02 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

oProcess:SetRegua1(2)
	
oProcess:IncRegua1("Selecionando registros..")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
//cQuery += " WHERE B2_FILIAL IN("+zFiliais+") "
cQuery += " WHERE B2_FILIAL = '0103' "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B1_TIPO IN('PA','PI','MP','PR') "
//cQuery += " AND B2_QATU > 0 "
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

oProcess:IncRegua1("Selecionando registros..")
cQuery := " SELECT DISTINCT B2_FILIAL FILIAL, B2_COD PRODUTO "
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
//cQuery += " WHERE B2_FILIAL IN("+zFiliais+") "
cQuery += " WHERE B2_FILIAL = '0103' "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B1_TIPO IN('PA','PI','MP','PR') "
//cQuery += " AND B2_QATU > 0 "
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, PRODUTO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
oProcess:SetRegua1(nTotSql)
DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()
	
	oProcess:IncRegua1("Processando...")

	zFil := "0102" //SQL1->FILIAL
	zCod := SQL1->PRODUTO

	DbSelectArea("NNR")
	DbSetOrder(1)
	If !DbSeek( zFil + mv_par01 )
		MsgAlert("Armaz�m "+mv_par01+" n�o cadastrado na Filial "+zFil+". O processo ser� interrompido.")
		Exit
	Endif

	DbSelectArea("SB2")
	DbSetOrder(1)
	If !DbSeek( zFil + zCod + mv_par01 )
	
		DbSelectArea("SB9")
		DbSetOrder(1)
		If !DbSeek( zFil + zCod + mv_par01 )
			RecLock("SB9",.T.)
			SB9->B9_FILIAL := zFil
			SB9->B9_COD    := zCod
			SB9->B9_LOCAL  := mv_par01
			SB9->B9_MCUSTD := "1"
			MsUnLock()
		Endif	

		RecLock("SB2",.T.)
		SB2->B2_FILIAL  := zFil
		SB2->B2_COD     := zCod
		SB2->B2_LOCAL   := mv_par01
		SB2->B2_LOCALIZ := AllTrim(NNR->NNR_DESCRI)
		SB2->B2_TIPO    := "1"
		MsUnLock()

	Endif

	DbSelectArea("SQL1")
	SQL1->(DbSkip())		
Enddo
SQL1->(DbCloseArea())

Return
