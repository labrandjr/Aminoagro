#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TMSR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦   03/09/2019    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Resumo geral de frete.								  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TMSR001()

Local cPerg := "TMSR01"
Private cPath := "c:\report\"
Private oTempTabl1
Private oTempTabl2
Private oTempTabl3

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTmsR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pTmsR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 03/09/2019     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTmsR01()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local nTotSql  := 0
Local nForFilial

Tmsr1Trab()

aFilsCalc := MatFilCalc( mv_par03 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
cQuery += " INNER JOIN "+RetSqlName("DA8")+" DA8 ON DTQ_FILIAL = DA8_FILIAL AND DTQ_ROTA = DA8_COD AND DA8.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DTA")+" DTA ON DTQ_FILORI = DTA_FILORI AND DTQ_VIAGEM = DTA_VIAGEM AND DTA.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DTA_FILDOC = DT6_FILDOC AND DTA_DOC = DT6_DOC AND DTA_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
cQuery += " WHERE DTQ_FILORI IN("+zFiliais+") "
cQuery += " AND DTQ_SERTMS = '3' "
cQuery += " AND DT6_DATEMI BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND DTQ.D_E_L_E_T_ <> '*' "
cQuery += " UNION ALL "
cQuery += " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
cQuery += " INNER JOIN "+RetSqlName("DA8")+" DA8 ON DTQ_FILIAL = DA8_FILIAL AND DTQ_ROTA = DA8_COD AND DA8.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DTP")+" DTP ON DTQ_FILORI = DTP_FILORI AND DTQ_VIAGEM = DTP_VIAGEM AND DTP.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DT5")+" DT5 ON DTP_FILORI = DT5_FILORI AND DTP_LOTNFC = DT5_LOTE AND DT5.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DT5_FILDOC = DT6_FILDOC AND DT5_DOC = DT6_DOC AND DT5_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
cQuery += " WHERE DTQ_FILORI IN("+zFiliais+") "
cQuery += " AND DTQ_SERTMS = '1' "
cQuery += " AND DT6_DATEMI BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND DTQ.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
While !Eof()
	nTotSql += SQL->SOMA
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT DTQ_FILORI FILORI, DTQ_VIAGEM VIAGEM, DTQ_ROTA ROTA, DA8_DESC DESCRT, DTQ_DATGER DATGER, DTQ_HORGER HORGER, DTQ_SERTMS SERTMS, "
cQuery += " DT6_FILDOC FILDOC, DT6_DOC DOC, DT6_SERIE SERIE, DT6_DATEMI DATEMI, DT6_VOLORI VOLORI, DT6_PESO PESO, DT6_VALMER VALMER, DT6_VALFRE VALFRE, "
cQuery += " DT6_VALIMP VALIMP, DT6_VALTOT VALTOT, DT6_DOCTMS DOCTMS, DT6_TABFRE TABFRE, DT6_SERVIC SERVIC, DT6_CLIREM CLIREM, DT6_LOJREM LOJREM, "
cQuery += " DT6_CLIDES CLIDES, DT6_LOJDES LOJDES "
cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
cQuery += " INNER JOIN "+RetSqlName("DA8")+" DA8 ON DTQ_FILIAL = DA8_FILIAL AND DTQ_ROTA = DA8_COD AND DA8.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DTA")+" DTA ON DTQ_FILORI = DTA_FILORI AND DTQ_VIAGEM = DTA_VIAGEM AND DTA.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DTA_FILDOC = DT6_FILDOC AND DTA_DOC = DT6_DOC AND DTA_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
cQuery += " WHERE DTQ_FILORI IN("+zFiliais+") "
cQuery += " AND DTQ_SERTMS = '3' "
cQuery += " AND DT6_DATEMI BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND DTQ.D_E_L_E_T_ <> '*' "
cQuery += " UNION ALL "
cQuery += " SELECT DTQ_FILORI FILORI, DTQ_VIAGEM VIAGEM, DTQ_ROTA ROTA, DA8_DESC DESCRT, DTQ_DATGER DATGER, DTQ_HORGER HORGER, DTQ_SERTMS SERTMS, "
cQuery += " DT6_FILDOC FILDOC, DT6_DOC DOC, DT6_SERIE SERIE, DT6_DATEMI DATEMI, DT6_VOLORI VOLORI, DT6_PESO PESO, DT6_VALMER VALMER, DT6_VALFRE VALFRE, "
cQuery += " DT6_VALIMP VALIMP, DT6_VALTOT VALTOT, DT6_DOCTMS DOCTMS, DT6_TABFRE TABFRE, DT6_SERVIC SERVIC, DT6_CLIREM CLIREM, DT6_LOJREM LOJREM, "
cQuery += " DT6_CLIDES CLIDES, DT6_LOJDES LOJDES "
cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
cQuery += " INNER JOIN "+RetSqlName("DA8")+" DA8 ON DTQ_FILIAL = DA8_FILIAL AND DTQ_ROTA = DA8_COD AND DA8.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DTP")+" DTP ON DTQ_FILORI = DTP_FILORI AND DTQ_VIAGEM = DTP_VIAGEM AND DTP.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DT5")+" DT5 ON DTP_FILORI = DT5_FILORI AND DTP_LOTNFC = DT5_LOTE AND DT5.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DT5_FILDOC = DT6_FILDOC AND DT5_DOC = DT6_DOC AND DT5_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
cQuery += " WHERE DTQ_FILORI IN("+zFiliais+") "
cQuery += " AND DTQ_SERTMS = '1' "
cQuery += " AND DT6_DATEMI BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND DTQ.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILORI, DATEMI, FILDOC, DOC, SERIE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()

	IncProc("Analisando viagens...")

	// Viagem
	DbSelectArea("DTQ")
	DbSetOrder(2)
	DbSeek( xFilial("DTQ") + SQL->FILORI + SQL->VIAGEM )

	// Veículos da Viagem
	DbSelectArea("DTR")
	DbSetOrder(1)
	DbSeek( xFilial("DTR") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )
	
	// Motoristas da Viagem
	DbSelectArea("DUP")
	DbSetOrder(1)
	DbSeek( xFilial("DUP") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )
	
	// Cadastro de Veículos
	DbSelectArea("DA3")
	DbSetOrder(1)
	DbSeek( DTQ->DTQ_FILORI + DTR->DTR_CODVEI )
	
	// Cadastro de Motoristas
	DbSelectArea("DA4")
	DbSetOrder(1)
	DbSeek( xFilial("DA4") + DUP->DUP_CODMOT )
	
    nKmTotl := 0
	If SQL->SERTMS == "1" // Coleta

		DbSelectArea("DTP")
		DbSetOrder(3)
		If DbSeek( SQL->FILORI + SQL->FILORI + SQL->VIAGEM )

			DbSelectArea("DT5")
			DbSetOrder(8)
			If DbSeek( DTP->(DTP_FILIAL+DTP_FILORI+DTP_LOTNFC) )
				While !Eof() .And. DT5->(DT5_FILIAL+DT5_FILORI+DT5_LOTE) == DTP->(DTP_FILIAL+DTP_FILORI+DTP_LOTNFC)
					
					nKmTotl += DT5->DT5_KM

					nQtdVol := 0
					nPesoBr := 0
					nValMer := 0
					DbSelectArea("DUM")
					DbSetOrder(1)
					If DbSeek( xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL )
						While !Eof() .And. DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) == xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL
							nQtdVol += DUM->DUM_QTDVOL
							nPesoBr += DUM->DUM_PESO
							nValMer += DUM->DUM_VALMER
							DUM->(DbSkip())
						Enddo
					Endif

					// Notas Fiscais
					DbSelectArea("ZT2")
					RecLock("ZT2",.T.)
					ZT2->T2_FILIAL := DT5->DT5_FILIAL
					ZT2->T2_VIAGEM := SQL->VIAGEM
					ZT2->T2_SERTMS := SQL->SERTMS
					ZT2->T2_DOC    := DT5->DT5_DOC
					ZT2->T2_SERIE  := DT5->DT5_SERIE
					ZT2->T2_LOTNFC := DT5->DT5_LOTE
					ZT2->T2_NUMNFC := DT5->DT5_NUMSOL
					ZT2->T2_SERNFC := "SOL"
					ZT2->T2_EMINFC := DT5->DT5_DATSOL
					ZT2->T2_CLIREM := DT5->DT5_CLIREM
					ZT2->T2_LOJREM := DT5->DT5_LOJREM
					ZT2->T2_CLIDES := DT5->DT5_CLIDES
					ZT2->T2_LOJDES := DT5->DT5_LOJDES
					ZT2->T2_QTDVOL := nQtdVol
					ZT2->T2_PESO   := nPesoBr
					ZT2->T2_VALOR  := nValMer
					ZT2->T2_CF     := ""
					ZT2->T2_NFEID  := ""
					MsUnLock()
					
					DbSelectArea("DT5")
					DT5->(DbSkip())
				Enddo
			Endif
		Endif

	ElseIf SQL->SERTMS == "3" // Entrega

		DbSelectArea("DTC")
		DbSetOrder(3)
		If DbSeek( SQL->FILORI + SQL->FILDOC + SQL->DOC + SQL->SERIE )
			While !Eof() .And. DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE) == SQL->FILORI + SQL->FILDOC + SQL->DOC + SQL->SERIE

				If nKmTotl == 0
					nKmTotl := DTC->DTC_KM
				Endif

				// Notas Fiscais
				DbSelectArea("ZT2")
				RecLock("ZT2",.T.)
				ZT2->T2_FILIAL := DTC->DTC_FILIAL
				ZT2->T2_VIAGEM := SQL->VIAGEM
				ZT2->T2_SERTMS := SQL->SERTMS
				ZT2->T2_DOC    := SQL->DOC
				ZT2->T2_SERIE  := SQL->SERIE
				ZT2->T2_LOTNFC := DTC->DTC_LOTNFC
				ZT2->T2_NUMNFC := DTC->DTC_NUMNFC
				ZT2->T2_SERNFC := DTC->DTC_SERNFC
				ZT2->T2_EMINFC := DTC->DTC_EMINFC
				ZT2->T2_CLIREM := DTC->DTC_CLIREM
				ZT2->T2_LOJREM := DTC->DTC_LOJREM
				ZT2->T2_CLIDES := DTC->DTC_CLIDES
				ZT2->T2_LOJDES := DTC->DTC_LOJDES
				ZT2->T2_QTDVOL := DTC->DTC_QTDVOL
				ZT2->T2_PESO   := DTC->DTC_PESO
				ZT2->T2_VALOR  := DTC->DTC_VALOR
				ZT2->T2_CF     := DTC->DTC_CF
				ZT2->T2_NFEID  := DTC->DTC_NFEID
				MsUnLock()
				
				DbSelectArea("DTC")
				DTC->(DbSkip())
			Enddo
		Endif

	Endif

    dDtLead := CtoD("")
    cHrLead := ""
    nCustCd := 0
	nConsLt := 0
	DbSelectArea("DUA")
	DbSetOrder(4)
	If DbSeek( DTQ->DTQ_FILIAL + SQL->FILDOC + SQL->DOC + SQL->SERIE )
		While !Eof() .And. DUA->(DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE) == DTQ->DTQ_FILIAL + SQL->FILDOC + SQL->DOC + SQL->SERIE
			If DUA->DUA_CODOCO == "02EN"
				dDtLead := DUA->DUA_DATOCO
				cHrLead := Substr(DUA->DUA_HOROCO,1,2)+":"+Substr(DUA->DUA_HOROCO,3,2)
				nCustCd := DUA->DUA_ZCUSCD
			ElseIf DUA->DUA_CODOCO == "01EN"
				nConsLt := DUA->DUA_ZCONSU
			Endif
			DbSelectArea("DUA")
			DUA->(DbSkip())
		Enddo
	Endif

	// Frete
	DbSelectArea("ZT1")
	RecLock("ZT1",.T.)
	ZT1->T1_FILORI := SQL->FILORI
	ZT1->T1_VIAGEM := SQL->VIAGEM
	ZT1->T1_ROTA   := SQL->DESCRT
	ZT1->T1_DATGER := StoD(SQL->DATGER)
	ZT1->T1_HORGER := Substr(SQL->HORGER,1,2)+":"+Substr(SQL->HORGER,3,2)
	ZT1->T1_SERTMS := SQL->SERTMS
	ZT1->T1_CODVEI := DA3->DA3_COD
	ZT1->T1_PLACA  := DA3->DA3_PLACA
	ZT1->T1_DESCVE := DA3->DA3_DESC  
	ZT1->T1_CODMOT := DA4->DA4_COD
	ZT1->T1_NOMEMT := DA4->DA4_NOME
	ZT1->T1_FILDOC := SQL->FILDOC
	ZT1->T1_DOC    := SQL->DOC
	ZT1->T1_SERIE  := SQL->SERIE
	ZT1->T1_DOCTMS := SQL->DOCTMS
	ZT1->T1_DATEMI := StoD(SQL->DATEMI)
	ZT1->T1_CLIREM := SQL->CLIREM
	ZT1->T1_LOJREM := SQL->LOJREM
	ZT1->T1_MUNREM := Posicione("SA1",1,xFilial("SA1")+SQL->CLIREM+SQL->LOJREM,"A1_MUN")
	ZT1->T1_ESTREM := Posicione("SA1",1,xFilial("SA1")+SQL->CLIREM+SQL->LOJREM,"A1_EST")
	ZT1->T1_CLIDES := SQL->CLIDES
	ZT1->T1_LOJDES := SQL->LOJDES
	ZT1->T1_MUNDES := Posicione("SA1",1,xFilial("SA1")+SQL->CLIDES+SQL->LOJDES,"A1_MUN")
	ZT1->T1_ESTDES := Posicione("SA1",1,xFilial("SA1")+SQL->CLIDES+SQL->LOJDES,"A1_EST")
	ZT1->T1_VOLORI := SQL->VOLORI
	ZT1->T1_PESO   := SQL->PESO
	ZT1->T1_VALMER := SQL->VALMER
	ZT1->T1_KM     := nKmTotl
	ZT1->T1_VALFRE := SQL->VALFRE
	ZT1->T1_VALIMP := SQL->VALIMP
	ZT1->T1_VALTOT := SQL->VALTOT
	ZT1->T1_SERVIC := SQL->SERVIC
	ZT1->T1_TABFRE := SQL->TABFRE
	ZT1->T1_DTLEAD := dDtLead
	ZT1->T1_HRLEAD := cHrLead
	ZT1->T1_CUSTCD := nCustCd
	MsUnLock()

	dDatSai := CtoD("")
	nOdoSai := 0
	dDatEnt := CtoD("")
	nOdoEnt := 0
	nKmPerc := 0
	nConsum := 0
	nMediaC := 0
	DbSelectArea("DUV")
	DbSetOrder(1)
	If DbSeek( DTQ->DTQ_FILIAL + SQL->FILORI + SQL->VIAGEM )
		dDatSai := DUV->DUV_DATSAI
		nOdoSai := DUV->DUV_ODOSAI
		dDatEnt := DUV->DUV_DATENT
		nOdoEnt := DUV->DUV_ODOENT
		nKmPerc := IIf(DUV->DUV_ODOENT > 0 .And. DUV->DUV_ODOSAI > 0, DUV->DUV_ODOENT - DUV->DUV_ODOSAI, 0)
		nConsum := nConsLt
		nMediaC := IIf(nKmPerc > 0 .And. nConsum > 0, (nKmPerc/nConsum) , 0)
	Endif

	// Despesas x Consumo
	DbSelectArea("ZT3")
	DbSetOrder(1)
	If !DbSeek( SQL->FILORI + SQL->VIAGEM )

		aDespVia := u_DespVia(SQL->FILORI,SQL->VIAGEM)
		nTotArla := aDespVia[1]
		nTotArlC := aDespVia[2]
		nTotComb := aDespVia[3]
		nTotComC := aDespVia[4]
		nTotHosp := aDespVia[5]
		nTotPedC := aDespVia[6]
		nTotManu := aDespVia[7]
		nTotCarg := aDespVia[8]
		nTotImpo := aDespVia[9]
		nTotLeva := aDespVia[10]
		nTotLona := aDespVia[11]
		nTotBals := aDespVia[12]
		nTotOutr := aDespVia[13]
		nTotDesp := aDespVia[14]
		nTotPago := aDespVia[15]
		nTotPeda := aDespVia[16]
		nTotAver := aDespVia[17]
		nTotDiar := aDespVia[18]

		RecLock("ZT3",.T.)
		ZT3->T3_FILIAL := SQL->FILORI
		ZT3->T3_VIAGEM := SQL->VIAGEM
		ZT3->T3_ROTA   := SQL->DESCRT
		ZT3->T3_CODVEI := DA3->DA3_COD
		ZT3->T3_PLACA  := DA3->DA3_PLACA
		ZT3->T3_DESCVE := DA3->DA3_DESC  
		ZT3->T3_CODMOT := DA4->DA4_COD
		ZT3->T3_NOMEMT := DA4->DA4_NOME
		ZT3->T3_DATSAI := dDatSai
		ZT3->T3_ODOSAI := nOdoSai
		ZT3->T3_DATENT := dDatEnt
		ZT3->T3_ODOENT := nOdoEnt
		ZT3->T3_KMPERC := nKmPerc
		ZT3->T3_CONSUM := nConsum
		ZT3->T3_MEDIAC := nMediaC
		ZT3->T3_QTDIAR := DTQ->DTQ_ZZQDIA
		ZT3->T3_QTPEDA := DTQ->DTQ_ZZQPDG
		ZT3->T3_ADIANT := DTQ->DTQ_ZZADTO
		ZT3->T3_DIARIA := nTotDiar
		ZT3->T3_COMBUS := nTotComb
		ZT3->T3_PEDAGI := nTotPeda
		ZT3->T3_MANUTE := nTotManu
		ZT3->T3_HOSPED := nTotHosp
		ZT3->T3_CARDES := nTotCarg
		ZT3->T3_IMPOST := nTotImpo
		ZT3->T3_ARLA   := nTotArla
		ZT3->T3_LEVA   := nTotLeva
		ZT3->T3_LONAS  := nTotLona
		ZT3->T3_BALSA  := nTotBals
		ZT3->T3_AVERB  := nTotAver
		ZT3->T3_PEDCOM := nTotPedC
		ZT3->T3_CMBCOM := nTotComC
		ZT3->T3_ARLCOM := nTotArlC
		ZT3->T3_OUTROS := nTotOutr
		ZT3->T3_TOTALD := (nTotDiar + nTotComb + nTotPeda + nTotManu + nTotHosp + nTotCarg + nTotImpo + nTotArla + nTotLeva + nTotLona + nTotBals + nTotAver + nTotPedC + nTotComC + nTotArlC + nTotOutr)
		MsUnLock()

	Endif
	
	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

DbSelectArea("ZT1")
ProcRegua(RecCount())
ZT1->(DbGotop())
If !Eof()

	cNomePlan  := "Fretes"
	cNomeTable := "Fretes"
	cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Viagem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Rota",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Hora",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Serv.Transp.",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Veículo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Placa",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Motorista",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Doc.Tms",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Remetente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Munic.Rem.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UF Rem.",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Destinatário",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Munic.Dest.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"UF Dest.",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Volume",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Peso",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Merc.",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Km",3,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Frete",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Icms",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Frete Total",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Serviço",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Serv.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tab.Frete",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Tab.",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Entrega",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Hr.Entrega",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Carg/Desc",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		cSerTms := IIf(ZT1->T1_SERTMS=="1","Coleta","Entrega")
		cDocTms := IIf(ZT1->T1_DOCTMS=="B","Ctrc Próprio",IIf(ZT1->T1_DOCTMS=="1","Coleta","Ct-e"))
		cRemete := RetField("SA1",1,xFilial("SA1")+ZT1->(T1_CLIREM+T1_LOJREM),"A1_NOME")
		cDestin := RetField("SA1",1,xFilial("SA1")+ZT1->(T1_CLIDES+T1_LOJDES),"A1_NOME")
		cDesSer := RetField("SX5",1,xFilial("SX5")+"L4"+PadR(ZT1->T1_SERVIC,6),"X5_DESCRI")
		cDesTab := RetField("DTL",1,xFilial("DTL")+ZT1->T1_TABFRE,"DTL_DESCRI")
		
		oExcel:AddRow(cNomePlan, cNomeTable, { ZT1->T1_FILORI, ZT1->T1_VIAGEM, ZT1->T1_ROTA, ZT1->T1_DATGER, ZT1->T1_HORGER, cSerTms,;
											   ZT1->T1_DESCVE, ZT1->T1_PLACA, ZT1->T1_NOMEMT, ZT1->T1_DOC, ZT1->T1_SERIE, cDocTms, ZT1->T1_DATEMI,;
											   cRemete, ZT1->T1_MUNREM, ZT1->T1_ESTREM, cDestin, ZT1->T1_MUNDES, ZT1->T1_ESTDES, ZT1->T1_VOLORI,;
											   ZT1->T1_PESO, ZT1->T1_VALMER, ZT1->T1_KM, ZT1->T1_VALFRE, ZT1->T1_VALIMP, ZT1->T1_VALTOT,;
											   ZT1->T1_SERVIC, cDesSer, ZT1->T1_TABFRE, cDesTab, ZT1->T1_DTLEAD, ZT1->T1_HRLEAD, ZT1->T1_CUSTCD })

		DbSelectArea("ZT1")
		ZT1->(DbSkip())
		
	Enddo

	DbSelectArea("ZT2")
	ProcRegua(RecCount())
	ZT2->(DbGotop())
	If !Eof()

		cNomePlan  := "Notas Fiscais"
		cNomeTable := "Notas Fiscais"
		cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Viagem",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Serv.Transp.",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Lote",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nota Fiscal",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Série NF",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão NF",1,4)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Remetente",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Destinatário",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Volume",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Peso",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Merc.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"CFOP",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Chave",1,1)

		While !Eof()

			IncProc("Gerando planilha...")

			cSerTms := IIf(ZT2->T2_SERTMS=="1","Coleta","Entrega")
			cRemete := RetField("SA1",1,xFilial("SA1")+ZT2->(T2_CLIREM+T2_LOJREM),"A1_NOME")
			cDestin := RetField("SA1",1,xFilial("SA1")+ZT2->(T2_CLIDES+T2_LOJDES),"A1_NOME")

			oExcel:AddRow(cNomePlan, cNomeTable, { ZT2->T2_FILIAL, ZT2->T2_VIAGEM, cSerTms, ZT2->T2_DOC, ZT2->T2_SERIE, ZT2->T2_LOTNFC,;
			                                       ZT2->T2_NUMNFC, ZT2->T2_SERNFC, ZT2->T2_EMINFC, cRemete, cDestin, ZT2->T2_QTDVOL, ZT2->T2_PESO,;
			                                       ZT2->T2_VALOR, ZT2->T2_CF, ZT2->T2_NFEID })

			DbSelectArea("ZT2")
			ZT2->(DbSkip())
			
		Enddo

	Endif

	DbSelectArea("ZT3")
	ProcRegua(RecCount())
	ZT3->(DbGotop())
	If !Eof()

		cNomePlan  := "Despesas x Consumo"
		cNomeTable := "Despesas x Consumo"
		cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)
	
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Viagem",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Rota",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Veículo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Placa",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Motorista",1,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Data Saída",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Km Saída",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Data Chegada",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Km Chegada",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Km Percorrido",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Consumo Lt",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Média Cons.",3,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Diárias",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd.Pedágios",3,1)

		oExcel:AddColumn(cNomePlan,cNomeTable,"Adiantamento",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Diárias",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Combustível",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedágio",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Manutenção",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Hospedagem",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Carga/Desc.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Impostos",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Arla",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Leva",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Lonas",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Balsa",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Averbação",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pedágio Compl.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Combust.Compl.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Arla Compl.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Outras Desp.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Total Despesas",3,3)

		While !Eof()

			IncProc("Gerando planilha...")

			oExcel:AddRow(cNomePlan, cNomeTable, { ZT3->T3_FILIAL, ZT3->T3_VIAGEM, ZT3->T3_ROTA, ZT3->T3_DESCVE, ZT3->T3_PLACA, ZT3->T3_NOMEMT,;
												   ZT3->T3_DATSAI, ZT3->T3_ODOSAI, ZT3->T3_DATENT, ZT3->T3_ODOENT, ZT3->T3_KMPERC, ZT3->T3_CONSUM,;
												   ZT3->T3_MEDIAC, ZT3->T3_QTDIAR, ZT3->T3_QTPEDA, ZT3->T3_ADIANT, ZT3->T3_DIARIA, ZT3->T3_COMBUS,;
												   ZT3->T3_PEDAGI, ZT3->T3_MANUTE, ZT3->T3_HOSPED, ZT3->T3_CARDES, ZT3->T3_IMPOST, ZT3->T3_ARLA,;
												   ZT3->T3_LEVA, ZT3->T3_LONAS, ZT3->T3_BALSA, ZT3->T3_AVERB, ZT3->T3_PEDCOM, ZT3->T3_CMBCOM,;
												   ZT3->T3_ARLCOM, ZT3->T3_OUTROS, ZT3->T3_TOTALD })

			DbSelectArea("ZT3")
			ZT3->(DbSkip())
			
		Enddo

	Endif

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "Resumo_Frete-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif

ZT1->(DbCloseArea())
oTempTabl1:Delete()

ZT2->(DbCloseArea())
oTempTabl2:Delete()

ZT3->(DbCloseArea())
oTempTabl3:Delete()
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Tmsr1Trab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 04/09/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Tmsr1Trab()

Local _aTmp   := {}
Local zAlias1 := "ZT1"
Local zAlias2 := "ZT2"
Local zAlias3 := "ZT3"

oTempTabl1 := FWTemporaryTable():New( zAlias1 )
// Frete
_aTmp := {}
AAdd ( _aTmp, {"T1_FILORI"  , "C", 004, 00} )
AAdd ( _aTmp, {"T1_VIAGEM"  , "C", 006, 00} )
AAdd ( _aTmp, {"T1_ROTA"    , "C", 030, 00} )
AAdd ( _aTmp, {"T1_DATGER"  , "D", 008, 00} )
AAdd ( _aTmp, {"T1_HORGER"  , "C", 005, 00} )
AAdd ( _aTmp, {"T1_SERTMS"  , "C", 001, 00} )
AAdd ( _aTmp, {"T1_CODVEI"  , "C", 008, 00} )
AAdd ( _aTmp, {"T1_PLACA"   , "C", 008, 00} )
AAdd ( _aTmp, {"T1_DESCVE"  , "C", 030, 00} )
AAdd ( _aTmp, {"T1_CODMOT"  , "C", 008, 00} )
AAdd ( _aTmp, {"T1_NOMEMT"  , "C", 040, 00} )
AAdd ( _aTmp, {"T1_FILDOC"  , "C", 004, 00} )
AAdd ( _aTmp, {"T1_DOC"     , "C", 009, 00} )
AAdd ( _aTmp, {"T1_SERIE"   , "C", 003, 00} )
AAdd ( _aTmp, {"T1_DOCTMS"  , "C", 001, 00} )
AAdd ( _aTmp, {"T1_DATEMI"  , "D", 008, 00} )
AAdd ( _aTmp, {"T1_CLIREM"  , "C", 006, 00} )
AAdd ( _aTmp, {"T1_LOJREM"  , "C", 002, 00} )
AAdd ( _aTmp, {"T1_MUNREM"  , "C", 060, 00} )
AAdd ( _aTmp, {"T1_ESTREM"  , "C", 002, 00} )
AAdd ( _aTmp, {"T1_CLIDES"  , "C", 006, 00} )
AAdd ( _aTmp, {"T1_LOJDES"  , "C", 002, 00} )
AAdd ( _aTmp, {"T1_MUNDES"  , "C", 060, 00} )
AAdd ( _aTmp, {"T1_ESTDES"  , "C", 002, 00} )
AAdd ( _aTmp, {"T1_VOLORI"  , "N", 005, 00} )
AAdd ( _aTmp, {"T1_PESO"    , "N", 011, 04} )
AAdd ( _aTmp, {"T1_VALMER"  , "N", 014, 02} )
AAdd ( _aTmp, {"T1_KM"      , "N", 007, 01} )
AAdd ( _aTmp, {"T1_VALFRE"  , "N", 014, 02} )
AAdd ( _aTmp, {"T1_VALIMP"  , "N", 014, 02} )
AAdd ( _aTmp, {"T1_VALTOT"  , "N", 014, 02} )
AAdd ( _aTmp, {"T1_SERVIC"  , "C", 003, 00} )
AAdd ( _aTmp, {"T1_TABFRE"  , "C", 004, 00} )
AAdd ( _aTmp, {"T1_DTLEAD"  , "D", 008, 00} )
AAdd ( _aTmp, {"T1_HRLEAD"  , "C", 005, 00} )
AAdd ( _aTmp, {"T1_CUSTCD"  , "N", 009, 02} )
oTemptabl1:SetFields( _aTmp )
oTempTabl1:AddIndex("indice1", {"T1_FILORI", "T1_VIAGEM", "T1_FILDOC", "T1_DOC", "T1_SERIE"})
oTempTabl1:Create()

oTempTabl2 := FWTemporaryTable():New( zAlias2 )
// Notas Fiscais
_aTmp := {}
AAdd ( _aTmp, {"T2_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"T2_VIAGEM"  , "C", 006, 00} )
AAdd ( _aTmp, {"T2_SERTMS"  , "C", 001, 00} )
AAdd ( _aTmp, {"T2_DOC"     , "C", 009, 00} )
AAdd ( _aTmp, {"T2_SERIE"   , "C", 003, 00} )
AAdd ( _aTmp, {"T2_LOTNFC"  , "C", 006, 00} )
AAdd ( _aTmp, {"T2_NUMNFC"  , "C", 009, 00} )
AAdd ( _aTmp, {"T2_SERNFC"  , "C", 003, 00} )
AAdd ( _aTmp, {"T2_EMINFC"  , "D", 008, 00} )
AAdd ( _aTmp, {"T2_CLIREM"  , "C", 006, 00} )
AAdd ( _aTmp, {"T2_LOJREM"  , "C", 002, 00} )
AAdd ( _aTmp, {"T2_CLIDES"  , "C", 006, 00} )
AAdd ( _aTmp, {"T2_LOJDES"  , "C", 002, 00} )
AAdd ( _aTmp, {"T2_QTDVOL"  , "N", 005, 00} )
AAdd ( _aTmp, {"T2_PESO"    , "N", 011, 04} )
AAdd ( _aTmp, {"T2_VALOR"   , "N", 014, 02} )
AAdd ( _aTmp, {"T2_CF"      , "C", 004, 00} )
AAdd ( _aTmp, {"T2_NFEID"   , "C", 044, 00} )
oTemptabl2:SetFields( _aTmp )
oTempTabl2:AddIndex("indice1", {"T2_FILIAL", "T2_VIAGEM", "T2_DOC", "T2_SERIE", "T2_NUMNFC", "T2_SERNFC"})
oTempTabl2:Create()

oTempTabl3 := FWTemporaryTable():New( zAlias3 )
// Despesas x Consumo
_aTmp := {}
AAdd ( _aTmp, {"T3_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"T3_VIAGEM"  , "C", 006, 00} )
AAdd ( _aTmp, {"T3_ROTA"    , "C", 030, 00} )
AAdd ( _aTmp, {"T3_CODVEI"  , "C", 008, 00} )
AAdd ( _aTmp, {"T3_PLACA"   , "C", 008, 00} )
AAdd ( _aTmp, {"T3_DESCVE"  , "C", 030, 00} )
AAdd ( _aTmp, {"T3_CODMOT"  , "C", 008, 00} )
AAdd ( _aTmp, {"T3_NOMEMT"  , "C", 040, 00} )
AAdd ( _aTmp, {"T3_DATSAI"  , "D", 008, 00} )
AAdd ( _aTmp, {"T3_ODOSAI"  , "N", 006, 00} )
AAdd ( _aTmp, {"T3_DATENT"  , "D", 008, 00} )
AAdd ( _aTmp, {"T3_ODOENT"  , "N", 006, 00} )
AAdd ( _aTmp, {"T3_KMPERC"  , "N", 006, 00} )
AAdd ( _aTmp, {"T3_CONSUM"  , "N", 006, 01} )
AAdd ( _aTmp, {"T3_MEDIAC"  , "N", 009, 02} )
AAdd ( _aTmp, {"T3_QTDIAR"  , "N", 002, 00} )
AAdd ( _aTmp, {"T3_QTPEDA"  , "N", 003, 00} )
AAdd ( _aTmp, {"T3_DIARIA"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_ADIANT"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_COMBUS"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_PEDAGI"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_MANUTE"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_HOSPED"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_CARDES"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_IMPOST"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_ARLA"    , "N", 014, 02} )
AAdd ( _aTmp, {"T3_LEVA"    , "N", 014, 02} )
AAdd ( _aTmp, {"T3_LONAS"   , "N", 014, 02} )
AAdd ( _aTmp, {"T3_BALSA"   , "N", 014, 02} )
AAdd ( _aTmp, {"T3_AVERB"   , "N", 014, 02} )
AAdd ( _aTmp, {"T3_PEDCOM"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_CMBCOM"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_ARLCOM"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_OUTROS"  , "N", 014, 02} )
AAdd ( _aTmp, {"T3_TOTALD"  , "N", 014, 02} )
oTemptabl3:SetFields( _aTmp )
oTempTabl3:AddIndex("indice1", {"T3_FILIAL", "T3_VIAGEM"})
oTempTabl3:Create()

Return
