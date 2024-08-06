#include "protheus.ch"
#Include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IPCCALL  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 03/08/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Interface de processamento para geração dos pedidos de     ¦¦¦
¦¦¦          ¦ compra modelo específico com extensão Pdf.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IPCCALL()

Local cPerg	:= Padr("IPCCALL",10)

If Pergunte(cPerg,.T.)
	Preparar()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  03/08/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

Private cEOL    := CHR(13)+CHR(10)
Private zDirPdf := AllTrim(mv_par05)

If Empty(mv_par05)
	MsgInfo("Atenção, diretório Pdf não informado. Verifique os parâmetros.")
	Return
Endif

If mv_par07 != 1
	If !(__cUserId $( AllTrim(GetMv("MV_ZIMPCBL")) ))
		MsgAlert("Usuário não autorizado a imprimir Pedidos em aprovação."+cEOL+;
				"Altere o parâmetro 'Imprime Pedidos ?' = Liberados")
		Return
	Endif
Endif

If !File(zDirPdf+"\*.*")
	MsgInfo("Atenção, diretório Pdf inválido."+cEOL+;
			zDirPdf+cEOL+;
			"Verifique os parâmetros.")
	Return
Endif

MsgRun("Aguarde, gerando ordens de compra Pdf...","Processando",{|| ProcImp() })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  03/08/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nTotSql  := 0
Local zPedAnt  := ""
Local lKeyPed  := .F.
Local aPedido  := {}
Local cUsrPcBl := AllTrim(GetMv("MV_USRPCBL"))

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
If !Empty(mv_par01)
	cQuery += " AND C7_NUM = '"+mv_par01+"' "
Endif	
If !Empty(mv_par02)
	cQuery += " AND C7_FORNECE = '"+mv_par02+"' "
Endif
cQuery += " AND C7_EMISSAO BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+ "' "
If __cUserId $ cUsrPcBl
	If mv_par07 == 1 // Liberados
		cQuery += " AND C7_CONAPRO = 'L' "
	ElseIf mv_par07 == 2 // Bloqueados
		cQuery += " AND C7_CONAPRO = 'B' "
	Else
		cQuery += " AND C7_CONAPRO IN('L','B') " // Ambos
	Endif
Else
	cQuery += " AND C7_CONAPRO = 'L' "
Endif
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)
nTotSql := SQL7->SOMA
SQL7->(DbCloseArea())

If nTotSql == 0
	MsgAlert("Sem dados para processamento. Verifique os parâmetros.")
	Return
Endif

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
If !Empty(mv_par01)
	cQuery += " AND C7_NUM = '"+mv_par01+"' "
Endif	
If !Empty(mv_par02)
	cQuery += " AND C7_FORNECE = '"+mv_par02+"' "
Endif
cQuery += " AND C7_EMISSAO BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+ "' "
If __cUserId $ cUsrPcBl
	If mv_par07 == 1 // Liberados
		cQuery += " AND C7_CONAPRO = 'L' "
	ElseIf mv_par07 == 2 // Bloqueados
		cQuery += " AND C7_CONAPRO = 'B' "
	Else
		cQuery += " AND C7_CONAPRO IN('L','B') " // Ambos
	Endif
Else
	cQuery += " AND C7_CONAPRO = 'L' "
Endif
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C7_FILIAL, C7_NUM, C7_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)

DbSelectArea("SQL7")
SQL7->(DbGotop())
While !Eof()

	If SQL7->(C7_FILIAL+C7_NUM) != zPedAnt
		If lKeyPed
			u_PdfPedC(aPedido)
			aPedido := {}
		Else
			lKeyPed := .T.
		Endif
		zPedAnt := SQL7->(C7_FILIAL+C7_NUM)
	Endif

	AAdd(aPedido,{SQL7->C7_FILIAL, SQL7->C7_NUM, SQL7->C7_ITEM })

	DbSelectArea("SQL7")
	SQL7->(DbSkip())
	If Eof()
		u_PdfPedC(aPedido)
	Endif

	DbSelectArea("SQL7")
Enddo
SQL7->(DbCloseArea())

Return
