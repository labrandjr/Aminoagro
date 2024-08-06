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
¦¦¦Programa  ¦ QEMLLVC ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 03/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mails - Vencimento do Limite próximos 30 dias.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLLVC()

ConOut("Função QEMLLVC: Vencimento do Limite de Crédito < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

If !GetMv("MV_SCHDPRO")
	ConOut("Schedule não executado: Ambiente Teste.")
	Return
Endif

cQuery := " SELECT A1_COD "
cQuery += " FROM "+RetSqlName("SA1")
cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND A1_LC > 0 "
cQuery += " AND A1_VENCLC BETWEEN '"+DtoS(Date())+"' AND '"+DtoS(Date()+30)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A1_COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
While !Eof()
	//
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SQL1->A1_COD )

	cQuery := " SELECT C5_ZZITCTB "
	cQuery += " FROM "+RetSqlName("SC5")
	cQuery += " WHERE C5_CLIENTE = '"+SA1->A1_COD+"' "
	cQuery += " AND C5_TIPO = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY C5_EMISSAO DESC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	
	zUnidNg := ""
	DbSelectArea("SQL5")
	SQL5->(DbGotop())
	If !Eof()
		zUnidNg := SQL5->C5_ZZITCTB
	Endif	
	SQL5->(DbCloseArea())

	If !Empty(zUnidNg)
		u_MMess030L(zUnidNg)
	Endif	

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo	
SQL1->(DbCloseArea())

ConOut("Função QEMLLVC: Vencimento do Limite de Crédito < Fim > "+DtoC(Date())+" - "+Time())

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess030L ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 03/05/2019 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger Devolução de Vendas.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMess030L(zBU)

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
	If DbSeek( xFilial("SX5") + "WB" + PadR(zBU,6) )
		zUsrMail := AllTrim(SX5->X5_DESCRI)
	Endif
Endif

If !Empty(zUsrMail)
	nPosic  := 0
	aLinha  := {}
	cTxtLin := zUsrMail
	While (!Empty(cTxtLin))
		If (((nPosic := AT(",",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
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
			
			cAssunto := "Vencimento do Limite de Credito - "+AllTrim(SA1->A1_NOME)+" - "+zBU
			//
			aMensage := {}
			AAdd(aMensage, "Evento X10 - O limite de crédito do cliente vencerá nos próximos 30 dias")
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Cliente: "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NOME))
			AAdd(aMensage, ">> Limite.: R$ "+AllTrim(Transform(SA1->A1_LC,"@E 999,999,999.99")))
			AAdd(aMensage, ">> Vencto.: "+DtoC(SA1->A1_VENCLC))
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
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 03/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLV01()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QEMLLVC()
Return
