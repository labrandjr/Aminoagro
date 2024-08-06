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
¦¦¦Programa  ¦ QEMLBON ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 26/06/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mails - Baixa a Receber por Bonificação.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLBON()

ConOut("Função QEMLBON: Baixa a Receber por Bonificação < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

cQuery := " SELECT R_E_C_N_O_ RECSE5 "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
cQuery += " AND E5_MOTBX = 'BON' "
cQuery += " AND E5_XEMLBON = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
While !Eof()
	//
	DbSelectArea("SE5")
	DbSetOrder(1)
	SE5->(DbGoto(SQL5->RECSE5))
	//
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE5->E5_CLIFOR + SE5->E5_LOJA )
	//
	u_MMess070()
    //
	RecLock("SE5",.F.)
	SE5->E5_XEMLBON := "X"
	MsUnLock()
	//
	DbSelectArea("SQL5")
	SQL5->(DbSkip())
Enddo	
SQL5->(DbCloseArea())

ConOut("Função QEMLBON: Baixa a Receber por Bonificação < Fim > "+DtoC(Date())+" - "+Time())

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess070 ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 26/06/18   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger Baixa a Receber por Bonificação.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMess070()

Local aArea    := GetArea()
Local zUsrParm := AllTrim(GetMv("MV_XEMLCOM"))
Local aUsrMail := {}
Local zUsrMail := zUsrParm
Local _x

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
			
			zIniAssu := IIf(SE5->E5_TIPODOC=="ES","Cancelamento de Baixa ","Baixa ")
			cAssunto := zIniAssu+"a Receber por Bonificação - "+xFilial("SE5")+"-"+AllTrim(SE5->E5_PREFIXO)+"-"+AllTrim(SE5->E5_NUMERO)
			//
			aMensage := {}
			AAdd(aMensage, "Evento X08 - "+zIniAssu+"por bonificação no título a receber abaixo")
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial.: "+xFilial("SE5"))
			AAdd(aMensage, ">> Prefixo: "+AllTrim(SE5->E5_PREFIXO))
			AAdd(aMensage, ">> Título.: "+AllTrim(SE5->E5_NUMERO))
			AAdd(aMensage, ">> Parcela: "+AllTrim(SE5->E5_PARCELA))
			AAdd(aMensage, ">> Cliente: "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NOME))
			AAdd(aMensage, ">> Vlr.R$.: "+AllTrim(Transform(SE5->E5_VALOR,"@E 9,999,999.99")))
			AAdd(aMensage, ">> Data Bx: "+DtoC(SE5->E5_DATA))
			AAdd(aMensage, ">> Sequ Bx: "+SE5->E5_SEQ)
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
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 26/06/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLBO1()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QEMLBON()
Return

User Function QEMLBO2()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_QEMLBON()
Return

User Function QEMLBO3()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_QEMLBON()
Return

User Function QEMLBO4()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_QEMLBON()
Return

User Function QEMLBO6()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_QEMLBON()
Return

User Function QEMLBO7()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_QEMLBON()
Return

User Function QEMLBO8()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_QEMLBON()
Return

User Function QEMLBO9()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_QEMLBON()
Return

User Function QEMLB10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_QEMLBON()
Return
