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
¦¦¦Programa  ¦ QEMLCOM ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 28/06/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mails - Baixa a receber período complementar.   ¦¦¦
¦¦¦          ¦ 01 a 05 de Janeiro e Julho.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLCOM()

ConOut("Função QEMLCOM: Movimentação à receber retroativa < Início > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

zAnoAtu := Substr(DtoS(Date()),1,4)
zDtHoje := DtoS(Date())
zIniJan := zAnoAtu+"0103"
zFimJan := zAnoAtu+"0231"
zExcJan := zAnoAtu+"0102"
zIniJul := zAnoAtu+"0703"
zFimJul := zAnoAtu+"0831"
zExcJul := zAnoAtu+"0702"
zIniMov := ""
zFimMov := ""
zIniChk := ""
zFimChk := ""
lExecut := .F.

If (zDtHoje >= zIniJan) .And. (zDtHoje <= zFimJan) // Execução em Janeiro e Fevereiro
    zIniMov := AllTrim(STR((Val(zAnoAtu)-1)))+"1201" // 01-Dezembro-Ano anterior
    zFimMov := zAnoAtu+"0102" // 02-Janeiro-Ano corrente
	zIniChk := zIniJan
	zFimChk := zFimJan
	lExecut := .T.
ElseIf (zDtHoje >= zIniJul) .And. (zDtHoje <= zFimJul) // Execução em Julho e Agosto
    zIniMov := zAnoAtu+"0601" // 01-Junho-ano corrente
	zFimMov := zAnoAtu+"0702" // 02-Julho-ano corrente
	zIniChk := zIniJul
	zFimChk := zFimJul
	lExecut := .T.
Endif	

If lExecut

	// Inseridos
	cQuery := " SELECT E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, E5_VALOR, E5_DATA, E5_ZDATDIG, E5_TIPODOC, E5_MOTBX, R_E_C_N_O_ "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery += " AND E5_DATA BETWEEN '"+zIniMov+"' AND '"+zFimMov+"' "
	cQuery += " AND E5_ZDATDIG BETWEEN '"+zIniChk+"' AND '"+zFimChk+"' "
	cQuery += " AND E5_XEMLCOM = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	While !Eof()

		lNegociac := .F.
		lPgComiss := .F.
		DbSelectArea("SE1")
		DbSetOrder(2)
		If DbSeek( SQL5->(E5_FILIAL+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) )

			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )

			DbSelectArea("FI7")
			DbSetOrder(2)
			If DbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
				lNegociac := .T.
			Endif

			If !lNegociac
				If !Empty(SE1->E1_VEND1)
					DbSelectArea("SA3")
					DbSetOrder(1)
					DbSeek( xFilial("SA3") + SE1->E1_VEND1 )
					//
					DbSelectArea("SD2")
					DbSetOrder(3)
					If DbSeek( xFilial("SD2") + SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) )
						If SD2->D2_COMIS1 > 0
							lPgComiss := .T.
						Endif
					Endif
				Endif
			Endif
		
		Endif

		If lNegociac .Or. lPgComiss
			u_MMess440("I")
			cQuery := " UPDATE "+RetSqlName("SE5")+" SET E5_XEMLCOM = 'X' WHERE R_E_C_N_O_ = "+AllTrim(STR(SQL5->R_E_C_N_O_))
			TCSQLEXEC(cQuery)
			//
			cQuery := " COMMIT "
			TCSQLEXEC(cQuery)	
		Endif

		DbSelectArea("SQL5")
		SQL5->(DbSkip())
	Enddo	
	SQL5->(DbCloseArea())

	// Estornados
	cQuery := " SELECT E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, E5_VALOR, E5_DATA, E5_ZDATDIG, E5_TIPODOC, E5_MOTBX, R_E_C_N_O_ "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery += " AND E5_DATA BETWEEN '"+zIniMov+"' AND '"+zFimMov+"' "
	cQuery += " AND E5_DTCANBX BETWEEN '"+zIniChk+"' AND '"+zFimChk+"' "
	cQuery += " AND E5_TIPODOC = 'ES' "
	cQuery += " AND E5_XEMLCOM = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	While !Eof()

		lNegociac := .F.
		lPgComiss := .F.
		DbSelectArea("SE1")
		DbSetOrder(2)
		If DbSeek( SQL5->(E5_FILIAL+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) )

			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )

			DbSelectArea("FI7")
			DbSetOrder(2)
			If DbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
				lNegociac := .T.
			Endif

			If !lNegociac
				If !Empty(SE1->E1_VEND1)
					DbSelectArea("SA3")
					DbSetOrder(1)
					DbSeek( xFilial("SA3") + SE1->E1_VEND1 )
					//
					DbSelectArea("SD2")
					DbSetOrder(3)
					If DbSeek( xFilial("SD2") + SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) )
						If SD2->D2_COMIS1 > 0
							lPgComiss := .T.
						Endif
					Endif
				Endif
			Endif
		
		Endif

		If lNegociac .Or. lPgComiss
			u_MMess440("S")
			cQuery := " UPDATE "+RetSqlName("SE5")+" SET E5_XEMLCOM = 'X' WHERE R_E_C_N_O_ = "+AllTrim(STR(SQL5->R_E_C_N_O_))
			TCSQLEXEC(cQuery)
			//
			cQuery := " COMMIT "
			TCSQLEXEC(cQuery)	
		Endif

		DbSelectArea("SQL5")
		SQL5->(DbSkip())
	Enddo	
	SQL5->(DbCloseArea())

	// Excluídos
	cQuery := " SELECT E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, E5_VALOR, E5_DATA, E5_ZDATDIG, E5_TIPODOC, E5_MOTBX, R_E_C_N_O_ "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery += " AND E5_DATA BETWEEN '"+zIniMov+"' AND '"+zFimMov+"' "
	cQuery += " AND E5_XEMLCOM = ' ' "
	cQuery += " AND D_E_L_E_T_ = '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	While !Eof()

		lNegociac := .F.
		lPgComiss := .F.
		DbSelectArea("SE1")
		DbSetOrder(2)
		If DbSeek( SQL5->(E5_FILIAL+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) )

			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )

			DbSelectArea("FI7")
			DbSetOrder(2)
			If DbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
				lNegociac := .T.
			Endif

			If !lNegociac
				If !Empty(SE1->E1_VEND1)
					DbSelectArea("SA3")
					DbSetOrder(1)
					DbSeek( xFilial("SA3") + SE1->E1_VEND1 )
					//
					DbSelectArea("SD2")
					DbSetOrder(3)
					If DbSeek( xFilial("SD2") + SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) )
						If SD2->D2_COMIS1 > 0
							lPgComiss := .T.
						Endif
					Endif
				Endif
			Endif
		
		Endif

		If lNegociac .Or. lPgComiss
			u_MMess440("E")
			cQuery := " UPDATE "+RetSqlName("SE5")+" SET E5_XEMLCOM = 'X' WHERE R_E_C_N_O_ = "+AllTrim(STR(SQL5->R_E_C_N_O_))
			TCSQLEXEC(cQuery)
			//
			cQuery := " COMMIT "
			TCSQLEXEC(cQuery)	
		Endif	

		DbSelectArea("SQL5")
		SQL5->(DbSkip())
	Enddo	
	SQL5->(DbCloseArea())

Endif

If (zDtHoje == zExcJan) .Or. (zDtHoje == zExcJul) // Exclusão dos registros deletados em 05-Jan e 05-Jul
	ConOut("Exclusão dos registros deletados SE5 - "+DtoC(Date())+" - "+Time())
    //
	cQuery := " DELETE "+RetSqlName("SE5")+" WHERE D_E_L_E_T_ = '*' "
	TCSQLEXEC(cQuery)
	//
	cQuery := " COMMIT "
	TCSQLEXEC(cQuery)	
Endif

ConOut("Função QEMLCOM: Movimentação à receber retroativa < Fim > "+DtoC(Date())+" - "+Time())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess440 ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 27/06/18   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger baixa a receber período complementar.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMess440(zTpMens)

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
			//
			zIniMens := IIf(zTpMens=="I","Inclusao",IIf(zTpMens=="S","Estorno","Exclusao"))
			cAssunto := zIniMens+" de movimentacao a receber com influencia no calculo de premiacao - "+xFilial("SE5")+"-"+AllTrim(SQL5->E5_NUMERO)+" - "+AllTrim(SQL5->E5_PREFIXO)
			//
			aMensage := {}
			AAdd(aMensage, "Evento X09 - "+zIniMens+" de movimentação à receber com influência no calculo de premiação")
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial.: "+xFilial("SE5"))
			AAdd(aMensage, ">> Prefixo: "+AllTrim(SQL5->E5_PREFIXO))
			AAdd(aMensage, ">> Título.: "+AllTrim(SQL5->E5_NUMERO))
			AAdd(aMensage, ">> Parcela: "+AllTrim(SQL5->E5_PARCELA))
			AAdd(aMensage, ">> Cliente: "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NOME))
			AAdd(aMensage, ">> Vlr.R$.: "+AllTrim(Transform(SQL5->E5_VALOR,"@E 9,999,999.99")))
			AAdd(aMensage, ">> Dt.Mov.: "+DtoC(StoD(SQL5->E5_DATA)))
			AAdd(aMensage, ">> Dt.Dig.: "+DtoC(StoD(SQL5->E5_ZDATDIG)))
			AAdd(aMensage, ">> Sequ.Bx: "+SQL5->E5_SEQ)
			AAdd(aMensage, ">> Tipo...: "+SQL5->E5_TIPODOC)
			AAdd(aMensage, ">> Motivo.: "+SQL5->E5_MOTBX)
			AAdd(aMensage, ">> Rtv....: "+AllTrim(SA3->A3_COD)+" - "+AllTrim(SA3->A3_NOME))
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
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/06/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLCM1()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QEMLCOM()
Return

User Function QEMLCM2()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_QEMLCOM()
Return

User Function QEMLCM3()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_QEMLCOM()
Return

User Function QEMLCM4()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_QEMLCOM()
Return

User Function QEMLCM6()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_QEMLCOM()
Return

User Function QEMLCM7()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_QEMLCOM()
Return

User Function QEMLCM8()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_QEMLCOM()
Return

User Function QEMLCM9()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_QEMLCOM()
Return

User Function QEMCM10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_QEMLCOM()
Return
