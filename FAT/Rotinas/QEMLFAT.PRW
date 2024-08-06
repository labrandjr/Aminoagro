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
¦¦¦Programa  ¦ QEMLFAT ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 06/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mails - Relação de Faturamento.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLFAT(lJob)

If lJob
	ConOut("Função QEMLFAT: Relação de Notas Fiscais < Início > "+DtoC(Date())+" - "+Time())
	ConOut(cEmpAnt)
	ConOut(cFilAnt)
Endif

If !lJob
	If !GetMv("MV_SCHDPRO")
		ConOut("Schedule não executado: Ambiente Teste.")
		Return
	Endif
Endif

zzzData := IIf(lJob,Date(),dDatabase)
dDatFat := zzzData-1
zCfAdmv := FormatIn( AllTrim(GetMv("MV_XCFADMV")), ",")

zAnoAtu := Substr(DtoS(zzzData),1,4)
zAnoAnt := AllTrim(Str((Val(zAnoAtu)-1)))
zMesAtu := Substr(DtoS(zzzData),5,2)
zMesAnt := StrZero((Val(zMesAtu)-1),2)
zDiaAtu := Substr(DtoS(zzzData),7,2)
lDia001 := (zDiaAtu == "01")

If zMesAnt == "00"
	zMesAnt := "12"
Endif

// Relação do mês anterior
// zDatIni := IIf(zMesAnt=="12",zAnoAnt,zAnoAtu) + zMesAnt + "01"
// zDatFim := IIf(zMesAnt=="12",zAnoAnt,zAnoAtu) + zMesAnt + "31"

If lDia001 // Envia relação acumulada do ano atual (dia 01/Janeiro envia o ano anterior completo)
	zDatIni := IIf(zMesAnt=="12",zAnoAnt,zAnoAtu) + "01" + "01"
	zDatFim := DtoS(zzzData-1)
Else // Envia relação acumulada do mês atual
	zDatIni := zAnoAtu + zMesAtu + "01"
	zDatFim := zAnoAtu + zMesAtu + StrZero((Val(zDiaAtu)-1),2)
Endif

cQuery := " SELECT DISTINCT(F2_VEND1) VEND1 "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL <> ' ' "
cQuery += " AND D2_FILIAL = F2_FILIAL "
cQuery += " AND D2_DOC = F2_DOC "
cQuery += " AND D2_SERIE = F2_SERIE "
cQuery += " AND D2_CLIENTE = F2_CLIENTE "
cQuery += " AND D2_LOJA = F2_LOJA "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND D2_EMISSAO BETWEEN '"+zDatIni+"' AND '"+zDatFim+"' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND SUBSTR(D2_COD,1,3) NOT IN('SER','TMS') "
cQuery += " AND D2_CF IN"+zCfAdmv
cQuery += " AND F2_VEND1 <> ' ' "
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY VEND1 "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

DbSelectArea("SQL2")
SQL2->(DbGotop())
While !Eof()

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek( xFilial("SA3") + SQL2->VEND1 )
	If !Empty(SA3->A3_EMAIL)
		u_MMess460(zDatIni,zDatFim,lDia001)
	Endif

	DbSelectArea("SQL2")
	SQL2->(DbSkip())
Enddo	
SQL2->(DbCloseArea())

If lJob
	ConOut("Função QEMLFAT: Relação de Notas Fiscais < Fim > "+DtoC(Date())+" - "+Time())
Endif	

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMess460 ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 06/05/19   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger Relação de Notas Fiscais.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMess460(zDatIni,zDatFim,lDia001)

Local aArea    := GetArea()
Local zUsrParm := AllTrim(GetMv("MV_WFEMTST"))
Local zUsrMail := ""
Local oExcel   := FwMsExcel():New()
Local _x

If !Empty(zUsrParm) // Se o parâmetro estiver preenchido, assume a preferência. Ambiente de Testes.
	zUsrMail := zUsrParm
Else
	zUsrMail := AllTrim(Lower(SA3->A3_EMAIL))
Endif

cQuery := " SELECT F2_FILIAL FILIAL, F2_DOC DOC, F2_SERIE SERIE, Trim(A1_NOME) NOME, F2_EMISSAO EMISSAO, SUM(D2_TOTAL) TOTAL "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL <> ' ' "
cQuery += " AND D2_FILIAL = F2_FILIAL "
cQuery += " AND D2_DOC = F2_DOC "
cQuery += " AND D2_SERIE = F2_SERIE "
cQuery += " AND D2_CLIENTE = F2_CLIENTE "
cQuery += " AND D2_LOJA = F2_LOJA "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND D2_EMISSAO BETWEEN '"+zDatIni+"' AND '"+zDatFim+"' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND SUBSTR(D2_COD,1,3) NOT IN('SER','TMS') "
cQuery += " AND D2_CF IN"+zCfAdmv
cQuery += " AND F2_VEND1 = '"+SA3->A3_COD+"' "
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, A1_NOME, F2_EMISSAO "
cQuery += " ORDER BY FILIAL, DOC, SERIE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TF2", .F., .T.)

DbSelectArea("TF2")
TF2->(DbGotop())

cNomePlan := "SF2_FATVEN"
cNomeTable := "Relação de Notas Fiscais emitidas entre "+DtoC(StoD(zDatIni))+" e "+DtoC(StoD(zDatFim))+" < "+AllTrim(SA3->A3_COD)+" >"
oExcel:AddworkSheet(cNomePlan)
oExcel:AddTable(cNomePlan,cNomeTable)

oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Total R$",3,3)

zValTot := 0
While !Eof()
	oExcel:AddRow(cNomePlan, cNomeTable, {TF2->FILIAL, TF2->DOC, TF2->SERIE, TF2->NOME, StoD(TF2->EMISSAO), TF2->TOTAL })
	zValTot += TF2->TOTAL
	TF2->(DbSkip())
Enddo
oExcel:AddRow(cNomePlan, cNomeTable, {"", "", "", "", "", zValTot })
TF2->(DbCloseArea())

oExcel:Activate()
cFile := "notas_fiscais_"+AllTrim(SA3->A3_COD)+"_"+zDatIni+"_a_"+zDatFim+".xml"
oExcel:GetXmlFile(cFile)

aAttach := {}
AAdd(aAttach,"\system\"+cFile)

cAssunto := "Relação de Notas Fiscais emitidas entre "+DtoC(StoD(zDatIni))+" e "+DtoC(StoD(zDatFim))+" < "+AllTrim(SA3->A3_COD)+" >"	
zEmail   := zUsrMail

aMensage := {}
AAdd(aMensage, "Prezado "+CapitalAce(SA3->A3_NOME))
AAdd(aMensage, "")
If lDia001
	AAdd(aMensage, "Informamos o valor faturado, acumulado referente ao ano corrente.")
Else
	AAdd(aMensage, "Informamos o valor faturado, acumulado referente ao mês corrente.")
Endif	
AAdd(aMensage, "")
AAdd(aMensage, "Administração de Vendas.")

U_MailNotify(zEmail, cAssunto, aMensage, .F., aAttach)

// Emails adicionais
If SA3->A3_COD $("V00068")

	zUsrParm := AllTrim(GetMv("MV_XUSEMFT"))
	aUsrMail := {}
	zUsrMail := zUsrParm

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

				cAssunto := "Relação de Notas Fiscais emitidas entre "+DtoC(StoD(zDatIni))+" e "+DtoC(StoD(zDatFim))+" < "+AllTrim(SA3->A3_COD)+" > - Cópia"

				aMensage := {}
				AAdd(aMensage, "Prezado "+CapitalAce(SA3->A3_NOME))
				AAdd(aMensage, "")
				If lDia001
					AAdd(aMensage, "Informamos o valor faturado, acumulado referente ao ano corrente.")
				Else
					AAdd(aMensage, "Informamos o valor faturado, acumulado referente ao mês corrente.")
				Endif	
				AAdd(aMensage, "")
				AAdd(aMensage, "Administração de Vendas.")

				U_MailNotify(zEmail, cAssunto, aMensage, .F., aAttach)

			Endif
		Endif	
	Next _x

Endif

fErase(cFile)

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MENU	 ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 06/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QMANFA1()
U_QEMLFAT(.F.)
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 06/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QEMLFA1()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_QEMLFAT(.T.)
Return
