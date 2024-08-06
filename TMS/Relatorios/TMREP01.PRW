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
¦¦¦Programa  ¦ TMREP01 ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/08/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Emissão do Extrato Frete.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TMREP01()

Local oExcel := Nil
Local aDados := {}

If !File("C:\TOTVS\*.*")
	MakeDir("C:\TOTVS")
Endif	

If !MsgYesNo("Confirma emissão do Extrato Frete para a Viagem "+DTQ->DTQ_VIAGEM+" ?","Aviso","INFO")
	Return
Endif

If DTQ->DTQ_SERTMS == "1" // Coleta

	cQuery := " SELECT A1_NOME CLIENTE, A1_MUN MUN, A1_EST EST, DT6_DATEMI EMISSAO, DT6_DOC DOC, DT6_PESO PESO, DT6_VALMER VALOR, DTW_DATREA DSAIDA, DUA_DATOCO DENTREG, "
	cQuery += " ( TO_NUMBER(DUA_DATOCO) - TO_NUMBER(DTW_DATREA) ) AS LDT, DT5_KM KM "
	cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
	cQuery += " INNER JOIN "+RetSqlName("DTP")+" DTP ON DTQ_FILORI = DTP_FILORI AND DTQ_VIAGEM = DTP_VIAGEM AND DTP.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DT5")+" DT5 ON DTP_FILORI = DT5_FILORI AND DTP_LOTNFC = DT5_LOTE AND DT5.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DT5_FILDOC = DT6_FILDOC AND DT5_DOC = DT6_DOC AND DT5_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON DT6_CLIREM = A1_COD AND DT6_LOJREM = A1_LOJA AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DTW")+" DTW ON DTQ_FILORI = DTW_FILORI AND DTQ_VIAGEM = DTW_VIAGEM AND DTW_ATIVID = '049' AND DTW.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DUA")+" DUA ON DT6_FILDOC = DUA_FILDOC AND DT6_DOC = DUA_DOC AND DT6_SERIE = DUA_SERIE AND DUA_CODOCO = '02CL' AND DUA.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE DTQ_FILORI = '"+DTQ->DTQ_FILORI+"' "
	cQuery += " AND DTQ_VIAGEM = '"+DTQ->DTQ_VIAGEM+"' "
	cQuery += " AND DTQ.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY DOC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)

	TcSetField("QRY","EMISSAO","D",8,0)
	TcSetField("QRY","DSAIDA" ,"D",8,0)
	TcSetField("QRY","DENTREG","D",8,0)

ElseIf DTQ->DTQ_SERTMS == "3" // Entrega

	cQuery := " SELECT A1_NOME CLIENTE, A1_MUN MUN, A1_EST EST, DTC_EMINFC EMISSAO, DTC_NUMNFC DOC, DTC_PESO PESO, DTC_VALOR VALOR, DTW_DATREA DSAIDA, DUA_DATOCO DENTREG, "
	cQuery += " ( TO_NUMBER(DUA_DATOCO) - TO_NUMBER(DTW_DATREA) ) AS LDT, DTA_DOC DOCTR, DTC_KM KM "
	cQuery += " FROM "+RetSqlName("DTQ")+" DTQ "
	cQuery += " INNER JOIN "+RetSqlName("DTA")+" DTA ON DTQ_FILORI = DTA_FILORI AND DTQ_VIAGEM = DTA_VIAGEM AND DTA.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DT6")+" DT6 ON DTA_FILDOC = DT6_FILDOC AND DTA_DOC = DT6_DOC AND DTA_SERIE = DT6_SERIE AND DT6.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("DTC")+" DTC ON DT6_FILDOC = DTC_FILDOC AND DT6_DOC = DTC_DOC AND DT6_SERIE = DTC_SERIE AND DT6.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON DTC_CLIDES = A1_COD AND DTC_LOJDES = A1_LOJA AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DTW")+" DTW ON DTQ_FILORI = DTW_FILORI AND DTQ_VIAGEM = DTW_VIAGEM AND DTW_ATIVID = '049' AND DTW.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DUA")+" DUA ON DT6_FILDOC = DUA_FILDOC AND DT6_DOC = DUA_DOC AND DT6_SERIE = DUA_SERIE AND DUA_CODOCO = '02EN' AND DUA.D_E_L_E_T_ <> '*' "
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
oExcelXML:SetOrigem("\xmls\EXTRFRT.xml") // Indica o caminho do arquivo origem (que será aberto e clonado)
oExcelXML:SetDestino(cCaminho+"EXTFRT_"+DTQ->DTQ_FILORI+"_"+DTQ->DTQ_VIAGEM+".xml") // Indica o caminho do arquivo destino (que será gerado)

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

nTotPes := 0
nTotVlr := 0
nKmEstm := 0
cMunFim := ""
cDocTra := ""
DbSelectArea("QRY")
QRY->(DbGotop())
While !Eof()
	zQryDoc := IIf(DTQ->DTQ_SERTMS == "3",QRY->DOCTR,QRY->DOC)
	If zQryDoc != cDocTra
		nKmEstm += QRY->KM
		cDocTra := zQryDoc
	Endif
	nTotPes += QRY->PESO
	nTotVlr += QRY->VALOR
	cMunFim := AllTrim(QRY->MUN)+"-"+QRY->EST
	QRY->(DbSkip())
Enddo

AAdd(aDados, nTotPes) // #TOT_PESO [1]
AAdd(aDados, nTotVlr) // #TOT_VALOR [2]
AAdd(aDados, cMunFim) // #DEST_FINAL [3]
AAdd(aDados, DTQ->DTQ_ZZADTO) // #VLR_ADTO [4]
AAdd(aDados, AllTrim(DA4->DA4_NOME)) // #MOTORISTA [5]
AAdd(aDados, Transform(DA4->DA4_CGC,"@R 999.999.999-99")) // #CPF [6]
AAdd(aDados, Substr(SM0->M0_NOMECOM,1,50)) // #FILIAL [7]
AAdd(aDados, Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")) // #CNPJ [8]
AAdd(aDados, Substr(DA3->DA3_DESC,1,18)+" "+Substr(DA3->DA3_PLACA,1,3)+"-"+Substr(DA3->DA3_PLACA,4,4)) // #VEICULO [9]
AAdd(aDados, Substr(Posicione("SA2",1,xFilial("SA2")+DA3->(DA3_CODFOR+DA3_LOJFOR),"A2_NOME"),1,25)) // #PROPR_VEIC [10]

cTxtRec := "Recebi a importancia de R$ "+AllTrim(Transform(DTQ->DTQ_ZZADTO,"@E 9,999.99"))+" referente despesas de viagem."
AAdd(aDados, cTxtRec) // #TXT_RECIBO [11]
AAdd(aDados, AllTrim(SM0->M0_CIDCOB)+", "+AllTrim(SM0->M0_ESTCOB)) // #FIL_EST [12]

nKmSaid := 0
DbSelectArea("DUV")
DbSetOrder(1)
If DbSeek( xFilial("DUV") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )
	nKmSaid := DUV->DUV_ODOSAI
Endif
AAdd(aDados, nKmSaid) // #KM_SAIDA [13]
AAdd(aDados, nKmEstm) // #KM_ESTIM [14]

DbSelectArea("QRY")
QRY->(DbGotop())

oExcelXML:AddTabExcel("#TABELA_REPORT", "QRY") // Adiciona tabela dinâmica

// Carrega variáveis
oExcelXML:AddExpression("#TOT_PESO"	  , aDados[1])
oExcelXML:AddExpression("#TOT_VALOR"  , aDados[2])
oExcelXML:AddExpression("#DEST_FINAL" , aDados[3])
oExcelXML:AddExpression("#VLR_ADTO"   , aDados[4])
oExcelXML:AddExpression("#MOTORISTA"  , aDados[5])
oExcelXML:AddExpression("#CPF"		  , aDados[6])
oExcelXML:AddExpression("#FILIAL"	  , aDados[7])
oExcelXML:AddExpression("#CNPJ"    	  , aDados[8])
oExcelXML:AddExpression("#VEICULO"	  , aDados[9])
oExcelXML:AddExpression("#PROPR_VEIC" , aDados[10])
oExcelXML:AddExpression("#TXT_RECIBO" , aDados[11])
oExcelXML:AddExpression("#FIL_EST"	  , aDados[12])
oExcelXML:AddExpression("#KM_SAIDA"	  , aDados[13])
oExcelXML:AddExpression("#KM_ESTIM"	  , aDados[14])

oExcelXML:MountFile() // Monta o arquivo
oExcelXML:ViewSO()

oExcelXML:Destroy(.F.)

QRY->(DbCloseArea())

SM0->(DbGoto(nRecSM0))

Return
