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
¦¦¦Programa  ¦ WFCHECK ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 24/08/2021      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checagem de segurança das aprovações Workflow.  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Pacotes   ¦ 28/09/2021 - Projeto Workflow versão 2.0 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function WFCHECK()

ConOut("Função WFCHECK: Checagem de Segurança WF < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("ZZK")
cQuery += " WHERE ZZK_FILIAL = '"+xFilial("ZZK")+"' "
cQuery += " AND ZZK_OK = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY ZZK_FILIAL, ZZK_DATALB, ZZK_HORALB, ZZK_NUMDOC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
While !Eof()

	DbSelectArea("ZZK")
	ZZK->(DbGoto(SQL2->R_E_C_N_O_))

	// Verifica se o processo Wf foi concluído
	cStatus := IIf(ZZK->ZZK_RESP=="S","03","06")
	DbSelectArea("SCR")
	DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
	If DbSeek( ZZK->(ZZK_FILIAL + ZZK_TIPO + ZZK_NUMDOC + ZZK_USER + cStatus) )
		RecLock("ZZK",.F.)
		ZZK->ZZK_OK := "S"
		MsUnLock()
	Else
		// Condição de chegagem p/ prever documento excluído
		DbSelectArea("SCR")
		DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
		If DbSeek( ZZK->(ZZK_FILIAL + ZZK_TIPO + ZZK_NUMDOC + ZZK_USER + "02") )
			WfAprov2()
		Else
			RecLock("ZZK",.F.)
			ZZK->ZZK_OK := "S"
			MsUnLock()
		Endif	
	Endif

	DbSelectArea("SQL2")
	SQL2->(DbSkip())
Enddo	
SQL2->(DbCloseArea())

ConOut("Função WFCHECK: Checagem de Segurança WF < Fim > "+DtoC(Date())+" - "+Time())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ WfAprov2 ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 24/08/2021      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa novamente o roteiro de aprovação.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function WfAprov2()

Local cPedido    := ""
Local cDocume    := ""
Local cResposta  := ""
Local cMotivo    := ""
Local cAprovador := ""
Local lAprovado  := .F.

// Registra execução
RecLock("ZZK",.F.)
ZZK->ZZK_WF2 += 1
MsUnLock()

If ZZK->ZZK_TIPO == "PC"

	zFilial	   := ZZK->ZZK_FILIAL
	cPedido	   := PadR(AllTrim(ZZK->ZZK_NUMDOC),6)
	cAprovador := ZZK->ZZK_APROV
	cUsuario   := ZZK->ZZK_USER
	cMotivo	   := Alltrim(ZZK->ZZK_MOTIVO)
	cResposta  := ZZK->ZZK_RESP
	lAprovado  := (ZZK->ZZK_RESP == "S")

	ConOut(zFilial)
	ConOut(cPedido)
	ConOut(cAprovador)
	ConOut(cUsuario)
	ConOut(cResposta)
	ConOut("WfAprov2: aprovacao do pedido de compra: " + cPedido + " " + IIf(lAprovado, "Aprovado", "Reprovado"))

	u_WfAprovPc(zFilial, cPedido, cAprovador, cUsuario, cMotivo, lAprovado)

ElseIf ZZK->ZZK_TIPO == "NF"

	zFilial	   := ZZK->ZZK_FILIAL
	cDocume	   := AllTrim(ZZK->ZZK_NUMDOC)
	cAprovador := ZZK->ZZK_APROV
	cUsuario   := ZZK->ZZK_USER
	cMotivo	   := Alltrim(ZZK->ZZK_MOTIVO)
	cResposta  := ZZK->ZZK_RESP
	lAprovado  := (ZZK->ZZK_RESP == "S")

	ConOut(zFilial)
	ConOut(cDocume)
	ConOut(cAprovador)
	ConOut(cUsuario)
	ConOut(cResposta)
	ConOut("WfAprov2: aprovacao do documento: " + cDocume + " " + IIf(lAprovado, "Aprovado", "Reprovado"))

	u_WfAprovNf(zFilial, cDocume, cAprovador, cUsuario, cMotivo, lAprovado)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 24/08/2021      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function WFCHK01()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_WFCHECK()
Return

User Function WFCHK02()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_WFCHECK()
Return

User Function WFCHK06()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_WFCHECK()
Return

User Function WFCHK07()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_WFCHECK()
Return

User Function WFCHK09()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_WFCHECK()
Return

User Function WFCHK10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_WFCHECK()
Return
