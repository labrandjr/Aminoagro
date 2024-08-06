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
¦¦¦Programa  ¦ QEMLCRD ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 26/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mails - Bloqueio de crédito.		  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLCRD()

ConOut("Função QEMLCRD: Bloqueio de Crédito < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

cQuery := " SELECT DISTINCT(C9_PEDIDO) C9_PEDIDO, C9_BLCRED, C9_XMOTBLQ, C9_DATALIB "
cQuery += " FROM "+RetSqlName("SC9")
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND C9_BLCRED <> ' ' "
cQuery += " AND C9_BLCRED <> '10' "
cQuery += " AND C9_XEMLSTT = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C9_PEDIDO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL9", .F., .T.)
While !Eof()
	//
	DbSelectArea("SC9")
	DbSetOrder(1)
	DbSeek( xFilial("SC9") + SQL9->C9_PEDIDO )
	//
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( xFilial("SC5") + SC9->C9_PEDIDO )
	//	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
	//
	lAgrpLim := (GetMv("MV_AGRPLIM") == "S")
	lAgrpCrd := .F.
	lAgrpCgc := .F.
	cCgcCli  := Substr(SA1->A1_CGC,1,8) // Base do Cgc da Matriz
	//
	nRecSa1 := SA1->(Recno()) // Cliente+Loja do Pedido
	If lAgrpLim // Agrupamento de Crédito = Habilitado
		If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
			lAgrpCrd := .T.
		Else
			If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
				DbSelectArea("SA1")
				DbSetOrder(1)
				If DbSeek( xFilial("SA1") + SA1->A1_ZZAGCRD )
					lAgrpCrd := .T.
				Endif
			Else // Agrupamento de Crédito: verifica se código do cliente está sendo usado para agrupamento
				cQuery := " SELECT COUNT(*)AS SOMA "
				cQuery += " FROM "+RetSqlName("SA1")
				cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
				cQuery += " AND A1_ZZAGCRD = '"+SA1->A1_COD+"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLA",.T.,.T.)
				lAgrpCrd := (SQLA->SOMA > 0)
				SQLA->(DbCloseArea())
			Endif
		Endif
		// Se não for agrupamento de crédito, verifica se existe agrupamento pela Base do Cnpj
		If !lAgrpCrd
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek( xFilial("SA1") + cCgcCli + "0001" )
				lAgrpCgc := .T.
			Endif
		Endif
	Endif
	SA1->(DbGoto(nRecSa1))
	//
	cQuery := " SELECT SUM(C9_QTDLIB*C9_PRCVEN) AS VLRLIB "
	cQuery += " FROM "+RetSqlName("SC9")
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQuery += " AND C9_PEDIDO = '"+SQL9->C9_PEDIDO+"' "
	cQuery += " AND C9_BLCRED <> ' ' "
	cQuery += " AND C9_BLCRED <> '10' "
	cQuery += " AND C9_XEMLSTT = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQ9",.T.,.T.)
	zTotLib := SQ9->VLRLIB
	SQ9->(DbCloseArea())
    //
	zCodCli := SA1->A1_COD
	zLojCli := SA1->A1_LOJA
	zAgrCrd := lAgrpCrd
	zAgrCgc := lAgrpCgc
	zCodigo := SQL9->C9_BLCRED
	zMotBlq := SQL9->C9_XMOTBLQ
	zUnidNg := SC5->C5_ZZITCTB
	//
	lEnvMail := .F. // Implementado controle de checagem do envio do alerta, prevendo múltiplas liberações automáticas c/ bloqueio para o mesmo pedido, o que ocasionava repetição de alertas. 30/08/2018
	DbSelectArea("ZZH")
	DbSetOrder(1)
	If !DbSeek( xFilial("ZZH") + SQL9->(C9_PEDIDO + C9_BLCRED + C9_XMOTBLQ + C9_DATALIB) )
		lEnvMail := .T.
		RecLock("ZZH",.T.)
		ZZH->ZZH_FILIAL := xFilial("ZZH")
		ZZH->ZZH_PEDIDO := SQL9->C9_PEDIDO
		ZZH->ZZH_BLCRED := SQL9->C9_BLCRED
		ZZH->ZZH_MOTBLQ := SQL9->C9_XMOTBLQ
		ZZH->ZZH_DATLIB := StoD(SQL9->C9_DATALIB)
		MsUnLock()
	Endif	
	If lEnvMail
		u_MMess450(zCodCli,zLojCli,zAgrCrd,zAgrCgc,zCodigo,zMotBlq,zUnidNg,zTotLib)
	Endif	
    //
	cQuery := " UPDATE "+RetSqlName("SC9")+" SET C9_XEMLSTT = '1' "
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQuery += " AND C9_PEDIDO = '"+SQL9->C9_PEDIDO+"' "
	cQuery += " AND C9_BLCRED <> ' ' "
	cQuery += " AND C9_BLCRED <> '10' "
	cQuery += " AND C9_XEMLSTT = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)	
	//
	cQuery := " COMMIT "
	TCSQLEXEC(cQuery)	
	//
	DbSelectArea("SQL9")
	SQL9->(DbSkip())
Enddo	
SQL9->(DbCloseArea())

ConOut("Função QEMLCRD: Bloqueio de Crédito < Fim > "+DtoC(Date())+" - "+Time())

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess450 ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 20/09/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger Bloqueio de Crédito.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMess450(cCodCli,cLojCli,lAgrpCrd,lAgrpCgc,zCodigo,zMotBlq,zBU,zTotLib)

Local aArea    := GetArea()
Local zUsrParm := AllTrim(GetMv("MV_XEMBLCR"))
Local zUsrMail := ""
Local aUsrMail := {}
Local _x

If !Empty(zUsrParm) // Se o parâmetro estiver preenchido, assume a preferência. Ambiente de Testes.
	zUsrMail := zUsrParm
Else
	DbSelectArea("SX5")
	DbSetOrder(1)
	If DbSeek( xFilial("SX5") + "WA" + PadR(zBU,6) )
		zUsrMail := AllTrim(SX5->X5_DESCRI)
	Endif
Endif

If !Empty(zUsrMail)
	nPosic  := 0
	aLinha  := {}
	cTxtLin := zUsrMail
	While (!Empty(cTxtLin))
		If (((nPosic := AT(",",cTxtLin)) > 0))
			zCpo := Val(Substr(cTxtLin,1,nPosic-1))
			zCpo := StrZero(zCpo,6)
			AAdd(aLinha,zCpo)
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			zCpo := Val(Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			zCpo := StrZero(zCpo,6)
			AAdd(aLinha,zCpo)
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo
	aUsrMail := aClone(aLinha)
Endif	

For _x := 1 to Len(aUsrMail)
	zEmail := UsrRetMail(aUsrMail[_x])
	If !Empty(zEmail)
		nPosic := AT("@",zEmail)
		If nPosic > 0
			
			cAssunto := "Bloqueio de Credito - Pedido "+xFilial("SC5")+"-"+AllTrim(SC5->C5_NUM)+" - "+zBU
			//
			aMensage := {}
			AAdd(aMensage, "Evento X03 - O pedido de venda abaixo foi bloqueado por crédito")
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial.: "+xFilial("SC5"))
			AAdd(aMensage, ">> Pedido.: "+AllTrim(SC5->C5_NUM))
			AAdd(aMensage, ">> Vlr.R$.: "+AllTrim(Transform(zTotLib,"@E 9,999,999.99")))
			AAdd(aMensage, ">> Cliente: "+AllTrim(cCodCli)+" - "+AllTrim( RetField("SA1",1,xFilial("SA1") + cCodCli + cLojCli,"A1_NOME")))
			AAdd(aMensage, ">> Agrupam: "+IIf(lAgrpCrd,"Grupo",IIf(lAgrpCgc,"Cnpj","Não")))
			AAdd(aMensage, ">> RTV....: "+AllTrim(SC5->C5_VEND1) +" - "+AllTrim( RetField("SA3",1,xFilial("SA3") + SC5->C5_VEND1 ,"A3_NOME")))
			AAdd(aMensage, ">> Gerente: "+AllTrim(SC5->C5_GEREN1)+" - "+AllTrim( RetField("SA3",1,xFilial("SA3") + SC5->C5_GEREN1,"A3_NOME")))
			AAdd(aMensage, ">> Motivo.: "+zMotBlq)
            //
			U_MailNotify(zEmail, cAssunto, aMensage, .F.)
		Endif
	Endif
Next _x	
	
RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 26/10/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLC01()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QEMLCRD()
Return

User Function QEMLC02()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_QEMLCRD()
Return

User Function QEMLC03()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_QEMLCRD()
Return

User Function QEMLC04()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_QEMLCRD()
Return

User Function QEMLC06()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_QEMLCRD()
Return

User Function QEMLC07()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_QEMLCRD()
Return

User Function QEMLC08()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_QEMLCRD()
Return

User Function QEMLC09()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_QEMLCRD()
Return

User Function QEMLC10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_QEMLCRD()
Return
