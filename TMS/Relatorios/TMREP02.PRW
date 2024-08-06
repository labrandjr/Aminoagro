#include "protheus.ch"
#include "totvs.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TMREP02 ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/08/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Emissão da Planilha de Acerto.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TMREP02(zAlias)

Local oExcel := Nil
Local aDados := {}

If zAlias == "SDG"
	DbSelectArea("DTQ")
	DbSetOrder(2)
	If !DbSeek( xFilial("SDG") + SDG->DG_FILORI + SDG->DG_VIAGEM )
		MsgAlert("Viagem não localizada!")
		Return
	Endif
Endif

If !File("C:\TOTVS\*.*")
	MakeDir("C:\TOTVS")
Endif	

If !MsgYesNo("Confirma emissão da Planilha de Acerto para a Viagem "+DTQ->DTQ_VIAGEM+" ?","Aviso","INFO")
	Return
Endif

If DTQ->DTQ_SERTMS == "1" // Coleta

	cQuery := " SELECT A1_NOME CLIENTE, A1_MUN MUN, A1_EST EST, DT6_DATEMI EMISSAO, DT6_DOC DOC, DT6_PESO PESO, DT6_VALMER VALOR, ' ' CCUSTO, "
	cQuery += " DTW_DATREA DSAIDA, DUA_DATOCO DENTREG, DT5_KM KM "
	cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
	cQuery += " INNER JOIN "+RetSqlName("DTP")+" DTP ON DTQ_FILORI = DTP_FILORI AND DTQ_VIAGEM = DTP_VIAGEM AND DTP.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DT5")+" DT5 ON DTP_FILORI = DT5_FILORI AND DTP_LOTNFC = DT5_LOTE AND DT5.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DT5_FILDOC = DT6_FILDOC AND DT5_DOC = DT6_DOC AND DT5_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON DT6_CLIREM = A1_COD AND DT6_LOJREM = A1_LOJA AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DTW")+" DTW ON DTQ_FILORI = DTW_FILORI AND DTQ_VIAGEM = DTW_VIAGEM AND DTW_ATIVID = '049' AND DTW.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DUA")+" DUA ON DTQ_FILORI = DUA_FILORI AND DTQ_VIAGEM = DUA_VIAGEM AND DUA_CODOCO = '01CL' AND DUA_SEQOCO = '0001' AND DUA.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE DTQ_FILORI = '"+DTQ->DTQ_FILORI+"' "
	cQuery += " AND DTQ_VIAGEM = '"+DTQ->DTQ_VIAGEM+"' "
	cQuery += " AND DTQ.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY DOC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)

	TcSetField("QRY","EMISSAO","D",8,0)
	TcSetField("QRY","DSAIDA" ,"D",8,0)
	TcSetField("QRY","DENTREG","D",8,0)

ElseIf DTQ->DTQ_SERTMS == "3" // Entrega

	cQuery := " SELECT A1_NOME CLIENTE, A1_MUN MUN, A1_EST EST, DTC_EMINFC EMISSAO, DTC_NUMNFC DOC, DTC_PESO PESO, DTC_VALOR VALOR, D2_CCUSTO CCUSTO, "
	cQuery += " DTW_DATREA DSAIDA, DUA_DATOCO DENTREG, DTA_DOC DOCTR, DTC_KM KM "
	cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
	cQuery += " INNER JOIN "+RetSqlName("DTA")+" DTA ON DTQ_FILORI = DTA_FILORI AND DTQ_VIAGEM = DTA_VIAGEM AND DTA.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DTA_FILDOC = DT6_FILDOC AND DTA_DOC = DT6_DOC AND DTA_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DTC")+" DTC ON DT6_FILDOC = DTC_FILDOC AND DT6_DOC = DTC_DOC AND DT6_SERIE = DTC_SERIE AND DT6.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON DTC_CLIDES = A1_COD AND DTC_LOJDES = A1_LOJA AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 ON DTC_FILORI = D2_FILIAL AND DTC_NUMNFC = D2_DOC AND DTC_SERNFC = D2_SERIE AND D2_ITEM = '01' AND SD2.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DTW")+" DTW ON DTQ_FILORI = DTW_FILORI AND DTQ_VIAGEM = DTW_VIAGEM AND DTW_ATIVID = '049' AND DTW.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DUA")+" DUA ON DTQ_FILORI = DUA_FILORI AND DTQ_VIAGEM = DUA_VIAGEM AND DUA_CODOCO = '01EN' AND DUA_SEQOCO = '0001' AND DUA.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE DTQ_FILORI = '"+DTQ->DTQ_FILORI+"' "
	cQuery += " AND DTQ_VIAGEM = '"+DTQ->DTQ_VIAGEM+"' "
	cQuery += " AND DTQ.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY DOCTR, DOC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)

	TcSetField("QRY","EMISSAO","D",8,0)
	TcSetField("QRY","DSAIDA" ,"D",8,0)
	TcSetField("QRY","DENTREG","D",8,0)

Endif

cCaminho  := "C:\TOTVS\"
oExcelXML := zExcelXML():New(.F.) //Instância o Objeto
oExcelXML:SetOrigem("\xmls\PACTFRT.xml") // Indica o caminho do arquivo origem (que será aberto e clonado)
oExcelXML:SetDestino(cCaminho+"PLNACER_"+DTQ->DTQ_FILORI+"_"+DTQ->DTQ_VIAGEM+".xml") // Indica o caminho do arquivo destino (que será gerado)

nRecSM0 := SM0->(Recno())
DbSelectArea("SM0")
DbSetOrder(1)
DbSeek( "G1" + DTQ->DTQ_FILORI )

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

cMunFim := ""
DbSelectArea("QRY")
QRY->(DbGotop())
While !Eof()
	cMunFim := AllTrim(QRY->MUN)+"-"+QRY->EST
	QRY->(DbSkip())
Enddo

AAdd(aDados, cMunFim) // #DESTINO [1]
AAdd(aDados, AllTrim(DA4->DA4_NOME)) // #MOTORISTA [2]
AAdd(aDados, Transform(DA4->DA4_CGC,"@R 999.999.999-99")) // #CPF [3]
AAdd(aDados, Substr(DA3->DA3_DESC,1,18)+" "+Substr(DA3->DA3_PLACA,1,3)+"-"+Substr(DA3->DA3_PLACA,4,4)) // #VEICULO [4]
AAdd(aDados, DTQ->DTQ_ZZADTO) // #VLR_ADTO [5]

aDespVia := u_DespVia(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
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
nTotReci := nTotArlC + nTotComC + nTotHosp + nTotPedC + nTotManu + nTotCarg + nTotImpo + nTotLeva + nTotLona + nTotAver + nTotBals + nTotOutr
nTotCart := nTotArla + nTotComb

AAdd(aDados,nTotArlC) // #VL_ARLAC [6]
AAdd(aDados,nTotArla) // #VL_ARLA  [7]
AAdd(aDados,nTotComC) // #VL_COMBC [8]
AAdd(aDados,nTotComb) // #VL_COMB  [9]
AAdd(aDados,nTotHosp) // #VL_HOSP  [10]
AAdd(aDados,nTotPedC) // #VL_PEDAC [11]
AAdd(aDados,nTotManu) // #VL_MANU  [12]
AAdd(aDados,nTotCarg) // #VL_CARG  [13]
AAdd(aDados,nTotImpo) // #VL_IMPO  [14]
AAdd(aDados,nTotLeva) // #VL_LEVA  [15]
AAdd(aDados,nTotLona) // #VL_LONA  [16]
AAdd(aDados,nTotAver) // #VL_AVER  [17]
AAdd(aDados,nTotBals) // #VL_BALS  [18]
AAdd(aDados,nTotOutr) // #VL_OUTR  [19]

AAdd(aDados,nTotReci) // #VL_TOTRC [20]
AAdd(aDados,nTotCart) // #VL_TOTCT [21]

AAdd(aDados,nTotDesp) // #TOTDESP  [22]

nTroco := DTQ->DTQ_ZZADTO - nTotPago
nDepos := 0
If nTroco < 0
	nTroco := 0
	nDepos := ABS(nTroco)
Endif

AAdd(aDados,nTroco) // #TROCO [23]
AAdd(aDados,nDepos) // #DEPOSITO [24]

AAdd(aDados, AllTrim(SM0->M0_CIDCOB)+", "+AllTrim(SM0->M0_ESTCOB)) // #FIL_EST [25]
AAdd(aDados,DtoC(dDatabase)) // #DAT_ASSI [26]

dDtSaid := CtoD("")
nKmSaid := 0
dDtCheg := CtoD("")
nKmCheg := 0
nConsum := 0
nKmPerc := 0
nMedCon := 0
DbSelectArea("DUV")
DbSetOrder(1)
If DbSeek( xFilial("DUV") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )
	dDtSaid := DUV->DUV_DATSAI
	nKmSaid := DUV->DUV_ODOSAI
	dDtCheg := DUV->DUV_DATENT
	nKmCheg := DUV->DUV_ODOENT
	nKmPerc := IIf(DUV->DUV_ODOSAI > 0 .And. DUV->DUV_ODOENT > 0, DUV->(DUV_ODOENT-DUV_ODOSAI), 0)
Endif
AAdd(aDados, DtoC(dDtSaid)) // #DT_SAIDA [27]
AAdd(aDados, nKmSaid) // #KM_SAIDA [28]
AAdd(aDados, DtoC(dDtCheg)) // #DT_CHEGA [29]
AAdd(aDados, nKmCheg) // #KM_CHEGA [30]

DbSelectArea("DUA")
DbSetOrder(2)
If DbSeek( xFilial("DUA") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )
	While !Eof() .And. DUA->(DUA_FILIAL+DUA_FILORI+DUA_VIAGEM) == xFilial("DUA") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM
		If AllTrim(DUA->DUA_CODOCO) == "01EN"
			If DUA->DUA_ZCONSU > 0
				nConsum := DUA->DUA_ZCONSU
				nMedCon := IIf(nKmPerc > 0 .And. nConsum > 0, (nKmPerc/nConsum) , 0)
				Exit
			Endif
		Endif
		DUA->(DbSkip())
	Enddo
Endif
				
AAdd(aDados, nConsum) // #CONSUMO [31]
AAdd(aDados, nKmPerc) // #KM_PERCORR [32]
AAdd(aDados, nMedCon) // #MEDIA_CONS [33]

DbSelectArea("QRY")
QRY->(DbGotop())

oExcelXML:AddTabExcel("#TABELA_REPORT", "QRY") // Adiciona tabela dinâmica

// Carrega variáveis
oExcelXML:AddExpression("#DESTINO"	 , aDados[1])
oExcelXML:AddExpression("#MOTORISTA" , aDados[2])
oExcelXML:AddExpression("#CPF"       , aDados[3])
oExcelXML:AddExpression("#VEICULO"   , aDados[4])
oExcelXML:AddExpression("#VLR_ADTO"  , aDados[5])

oExcelXML:AddExpression("#VL_ARLAC"  , aDados[6])
oExcelXML:AddExpression("#VL_ARLA"   , aDados[7])
oExcelXML:AddExpression("#VL_COMBC"  , aDados[8])
oExcelXML:AddExpression("#VL_COMB"	 , aDados[9])
oExcelXML:AddExpression("#VL_HOSP"   , aDados[10])
oExcelXML:AddExpression("#VL_PEDAC"  , aDados[11])
oExcelXML:AddExpression("#VL_MANU"   , aDados[12])
oExcelXML:AddExpression("#VL_CARG"   , aDados[13])
oExcelXML:AddExpression("#VL_IMPO"	 , aDados[14])
oExcelXML:AddExpression("#VL_LEVA"	 , aDados[15])
oExcelXML:AddExpression("#VL_LONA"	 , aDados[16])
oExcelXML:AddExpression("#VL_AVER"	 , aDados[17])
oExcelXML:AddExpression("#VL_BALS"	 , aDados[18])
oExcelXML:AddExpression("#VL_OUTR"	 , aDados[19])

oExcelXML:AddExpression("#VL_TOTRC"	 , aDados[20])
oExcelXML:AddExpression("#VL_TOTCT"	 , aDados[21])

oExcelXML:AddExpression("#TOTDESP"	 , aDados[22])
oExcelXML:AddExpression("#TROCO"	 , aDados[23])
oExcelXML:AddExpression("#DEPOSITO"	 , aDados[24])
oExcelXML:AddExpression("#FIL_EST"	 , aDados[25])
oExcelXML:AddExpression("#DAT_ASSI"  , aDados[26])

oExcelXML:AddExpression("#DT_SAIDA"	 , aDados[27])
oExcelXML:AddExpression("#KM_SAIDA"	 , aDados[28])
oExcelXML:AddExpression("#DT_CHEGA"  , aDados[29])
oExcelXML:AddExpression("#KM_CHEGA"  , aDados[30])
oExcelXML:AddExpression("#CONSUMO"	 , aDados[31])
oExcelXML:AddExpression("#KM_PERCO"  , aDados[32])
oExcelXML:AddExpression("#MEDIA_CO"  , aDados[33])

oExcelXML:MountFile() // Monta o arquivo
oExcelXML:ViewSO()

oExcelXML:Destroy(.F.)

QRY->(DbCloseArea())

SM0->(DbGoto(nRecSM0))

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DespVia ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 05/09/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula os custos de transporte da viagem.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DespVia(zFilOri,zViagem)

Local aArea := GetArea()
Local nTotArla := 0
Local nTotArlC := 0
Local nTotComb := 0
Local nTotComC := 0
Local nTotHosp := 0
Local nTotPedC := 0
Local nTotManu := 0
Local nTotCarg := 0
Local nTotImpo := 0
Local nTotLeva := 0
Local nTotLona := 0
Local nTotBals := 0
Local nTotOutr := 0
Local nTotDesp := 0
Local nTotPago := 0
Local nTotDiar := 0
Local nTotPeda := 0
Local nTotAver := 0
Local aRetDesp := {}

DbSelectArea("SDG")
DbSetOrder(5)
If DbSeek( xFilial("SDG") + zFilOri + zViagem )
	While !Eof() .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == xFilial("SDG") + zFilOri + zViagem
		If SDG->DG_SALDO == 0 
			If AllTrim(SDG->DG_CODDES) == "DESPTRAN_0009" // Arla (Pagto. c/ Cartão)
				nTotArla := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0016" // Arla complementar
				nTotArlC := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0004" // Combustível (Pagto. c/ Cartão)
				nTotComb := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0015" // Combustível complementar
				nTotComC := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0006" // Hospedagem
				nTotHosp := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0013" // Pedágio complementar
				nTotPedC := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0003" // Manutenção
				nTotManu := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0007" // Carga/Descarga
				nTotCarg := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0008" // Impostos
				nTotImpo := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0010" // Leva
				nTotLeva := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0011" // Lonas e Tampas
				nTotLona := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0012" // Balsa
				nTotBals := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0099" // Outros
				nTotOutr := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0014" // Averbação
				nTotAver := SDG->DG_TOTAL
				nTotDesp += SDG->DG_TOTAL
				nTotPago += SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0001" // Diária (Uso do Motorista)
				nTotDiar := SDG->DG_TOTAL
			ElseIf AllTrim(SDG->DG_CODDES) == "DESPTRAN_0005" // Pedágio (Pagto. c/ Tag)
				nTotPeda := SDG->DG_TOTAL
			Endif	
		Endif
		SDG->(DbSkip())
	Enddo
Endif

AAdd(aRetDesp,nTotArla)
AAdd(aRetDesp,nTotArlC)
AAdd(aRetDesp,nTotComb)
AAdd(aRetDesp,nTotComC)
AAdd(aRetDesp,nTotHosp)
AAdd(aRetDesp,nTotPedC)
AAdd(aRetDesp,nTotManu)
AAdd(aRetDesp,nTotCarg)
AAdd(aRetDesp,nTotImpo)
AAdd(aRetDesp,nTotLeva)
AAdd(aRetDesp,nTotLona)
AAdd(aRetDesp,nTotBals)
AAdd(aRetDesp,nTotOutr)
AAdd(aRetDesp,nTotDesp)
AAdd(aRetDesp,nTotPago)
AAdd(aRetDesp,nTotPeda)
AAdd(aRetDesp,nTotAver)
AAdd(aRetDesp,nTotDiar)

RestArea(aArea)

Return(aRetDesp)
