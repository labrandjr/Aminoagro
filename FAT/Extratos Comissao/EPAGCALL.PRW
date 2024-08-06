#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ EPAGCALL  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 02/12/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Interface de processamento para geração da relação de      ¦¦¦
¦¦¦          ¦ premiação para folha de pagamento.			 			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function EPAGCALL()

Local cPerg	:= Padr("EPAGCALL",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Relação de Premiação para Folha de Pagamento" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,070,{||"RELAÇÃO DE PREMIAÇÃO - FOLHA DE PAGAMENTO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo emitir a relação de premiação com extensão pdf"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"para folha de pagamento, de acordo com os parâmetros selecionados."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"A premiação deverá ser previamente calculada no período desejado."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"Opção disponível Rtv, Gerentes e Diretores."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  31/10/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

Local dDataDe   := CtoD("")
Local dDataAt   := CtoD("")
Private cEOL    := CHR(13)+CHR(10)
Private zDirPdf := AllTrim(mv_par06)

If Empty(mv_par06)
	MsgInfo("Atenção, diretório Pdf não informado. Verifique os parâmetros.")
	Return
Endif

If !File(zDirPdf+"\*.*")
	MsgInfo("Atenção, diretório Pdf inválido."+cEOL+;
			zDirPdf+cEOL+;
			"Verifique os parâmetros.")
	Return
Endif

DbSelectArea("ZZP")
DbSetOrder(1)
If !DbSeek( xFilial("ZZP") + AllTrim(STR(mv_par01)) + mv_par02 )
	MsgAlert("Período não cadastrado.")
	Return
Else
	dDataDe := ZZP->ZZP_DINI
	dDataAt := ZZP->ZZP_DFIM
Endif

If MsgYesNo("Confirma o processamento - RELAÇÃO DE PREMIAÇÃO ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp(dDataDe,dDataAt) }, "Emitindo relação de premiação", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  31/10/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp(dDataDe,dDataAt)

Local nTotSql := 0
Local aVenDet := {}

zMes := Month(dDataAt)
zAno := Year(dDataAt)
If zAno <= 2022
	If zMes <= 8
		If (zMes-1) == 0
			zMes := 12
			zAno -= 1
		Else
			zMes -= 1
		Endif
	Endif
Endif
zAfi := StoD(AllTrim(STR(zAno))+StrZero(zMes,2)+"01")
zIni := Upper(MesExtenso(dDataDe))
zFim := Upper(MesExtenso(zAfi))
zPer := zIni+" A "+zFim+" DE "+Year2Str(zAfi)

cQuery := " SELECT COUNT(DISTINCT E3_VEND)AS SOMA "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAt)+ "' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND SUBSTR(E3_VEND,1,1) IN('V','G','D') "
cQuery += " AND E3_VEND = A3_COD "
If mv_par08 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par08 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par09 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par09 == 2 // Inativos
	cQuery += " AND A3_MSBLQL = '1' "
Endif
cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
nTotSql := SQL3->SOMA
SQL3->(DbCloseArea())

If nTotSql == 0
	MsgAlert("Sem dados para processamento. Verifique os parâmetros.")
	Return
Endif

cQuery := " SELECT DISTINCT(E3_VEND) AS VEND "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAt)+ "' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND SUBSTR(E3_VEND,1,1) IN('V','G','D') "
cQuery += " AND E3_VEND = A3_COD "
If mv_par08 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par08 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par09 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par09 == 2 // Inativos
	cQuery += " AND A3_MSBLQL = '1' "
Endif
cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E3_VEND "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

oProcess:SetRegua1(nTotSql)

DbSelectArea("SQL3")
SQL3->(DbGotop())
While !Eof()

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek( xFilial("SA3") + SQL3->VEND )

	oProcess:IncRegua1("Gerando Pdf")

	zCodVen := SA3->A3_COD
	zNomVen := SA3->A3_NOME
	zVlPrem := 0

	If Substr(zCodVen,1,1) == "V"
		zVlPrem := _PagRtv(zCodVen,dDataDe,dDataAt)
	Else
		zVlPrem := _PagGrv(zCodVen,dDataDe,dDataAt)
	Endif

	If zVlPrem != 0
		AAdd(aVenDet,{zCodVen, zNomVen, zVlPrem})
	Endif	

	DbSelectArea("ZZR")
	DbSetOrder(1)
	If !DbSeek( xFilial("ZZR") + AllTrim(STR(mv_par01)) + mv_par02 + zCodVen )
		RecLock("ZZR",.T.)
		ZZR->ZZR_FILIAL := xFilial("ZZR")
		ZZR->ZZR_SEMEST := AllTrim(STR(mv_par01))
		ZZR->ZZR_ANO    := mv_par02
		ZZR->ZZR_VEND   := zCodVen
	Else
		RecLock("ZZR",.F.)
	Endif
	ZZR->ZZR_VALOR := zVlPrem
	MsUnLock()

	DbSelectArea("SQL3")
	SQL3->(DbSkip())
	If Eof()
		u_PagPrem(aVenDet,zPer,dDataDe,dDataAt)
	Endif

	DbSelectArea("SQL3")
Enddo
SQL3->(DbCloseArea())

If Len(aVenDet) > 0
	MsgInfo("Relação para pagamento de PLR gerada com sucesso !!")
Else
	MsgAlert("Sem dados para pagamento de PLR nos parâmetros informados.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ PagPrem		  	¦ Autor ¦ Fábrica ERPBR   ¦   31/10/17    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Prepara os dados para geração do Pdf.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PagPrem(aDetalhe,zPer,dDataDe,dDataAt)

Local zTotal := 0
Local _det

If mv_par05 == 1 // Ranking
	aSort( aDetalhe,,, { |x,y| x[3] > y[3] } ) // Detalhe: valor da premiação em ordem decrescente
ElseIf mv_par05 == 2 // Nome
	aSort( aDetalhe,,, { |x,y| x[2] < y[2] } ) // Detalhe: nome em ordem crescente
Endif

For _det := 1 to Len(aDetalhe)
	zTotal += aDetalhe[_det][3] // Acumula valor total do extrato
Next _det

U_PDFPAG(aDetalhe,zTotal,zPer,dDataDe,dDataAt)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _PagRtv  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  31/10/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Calcula valor total da premiação do Rtv.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _PagRtv(zCodVen,dDataDe,dDataAt)

Local aArea   := GetArea()
Local zTotal  := 0
Local lDescAtr := .T.
Local lDescMet := .T.
Local lTotNega := .T.
//Local aNccImp := {}
//Local lNccImp := GetMv("MV_ZNCCDET")
//Local _ncc

DbSelectArea("ZZQ")
DbSetOrder(1)
If DbSeek( xFilial("ZZQ") + zCodVen + AllTrim(STR(mv_par01)) + mv_par02 )
	lDescAtr := (ZZQ->ZZQ_ATRASO == "S")
	lDescMet := (ZZQ->ZZQ_META   == "S")
	lTotNega := (ZZQ->ZZQ_NEGAT  == "S")
Endif

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE3")
cQuery += " WHERE E3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAt)+ "' "
cQuery += " AND E3_VEND = '"+zCodVen+"' "
cQuery += " AND E3_ZZRTV = ' ' " // Não considera apuração GER e DIR
If mv_par08 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par08 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E3_VEND, E3_CODCLI, E3_LOJA, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSQL3", .F., .T.)

DbSelectArea("TSQL3")
TSQL3->(DbGotop())
While !Eof()

/*	If lNccImp
		If TSQL3->E3_TIPO == "NCC" .And. TSQL3->E3_EMISSAO >= "20210101"
			aNccNFis := u_NccNFis(TSQL3->E3_FILIAL, TSQL3->E3_NUM, TSQL3->E3_SERIE, TSQL3->E3_CODCLI, TSQL3->E3_VEND, TSQL3->R_E_C_N_O_)
			For _ncc := 1 to Len(aNccNFis)
				yVended := aNccNFis[_ncc][1]
				yClient := aNccNFis[_ncc][2]
				yNomCli := aNccNFis[_ncc][3]
				yFilial := aNccNFis[_ncc][4]
				yNumNcc := aNccNFis[_ncc][5]
				ySerNcc := aNccNFis[_ncc][6]
				yNccRec := aNccNFis[_ncc][7]
				yNfOrig := aNccNFis[_ncc][8]
				ySerOri := aNccNFis[_ncc][9]
				AAdd(aNccImp,{yVended, yClient, yNomCli, yFilial, yNumNcc, ySerNcc, yNccRec, yNfOrig, ySerOri})	
			Next _ncc
		Endif	
	Endif */
	
	e3Comis := TSQL3->E3_COMIS
	
	If !lDescAtr // Desliga desconto por atraso
		If TSQL3->E3_ZZVDESC > 0
			e3Comis := TSQL3->E3_ZZCOMIS
		Endif
	Endif

	If !lDescMet // Desliga desconto por meta
		zDesMet  := IIf(TSQL3->E3_MTCOMIS > 0, TSQL3->(E3_MTCOMIS - E3_COMIS), 0)
		If zDesMet > 0
			e3Comis := TSQL3->E3_ZZCOMIS
		Endif
	Endif

	zTotal += e3Comis
	
	DbSelectArea("TSQL3")
	TSQL3->(DbSkip())
Enddo
TSQL3->(DbCloseArea())

If !lTotNega
	If zTotal < 0
		zTotal := 0
	Endif
Endif

/*
If Len(aNccImp) > 0
	aCrdNcc := u_NccDeta(aNccImp)
	nCrdNcc := aCrdNcc[1] // Crédito total
	zTotal  += nCrdNcc // Acumula valor total do extrato (crédito dos descontos nos títulos originais)
Endif
*/

RestArea(aArea)

Return(zTotal)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _PagGrv  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  31/10/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Calcula valor total da premiação do Ger/Dir.				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _PagGrv(zCodVen,dDataDe,dDataAt)

Local aArea   := GetArea()
Local zTotal  := 0
//Local aNccImp := {}
//Local lNccImp := GetMv("MV_ZNCCDET")
//Local _ncc

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE3")
cQuery += " WHERE E3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAt)+ "' "
cQuery += " AND E3_VEND = '"+zCodVen+"' "
//cQuery += " AND E3_ZZRTV <> ' ' " // Considera apenas apuração de Gerentes e Diretores --> Linha comentada pois o GER e DIR podem ser RTV nos Pedidos.
If mv_par08 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par08 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E3_VEND, E3_CODCLI, E3_LOJA, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSQL3", .F., .T.)

DbSelectArea("TSQL3")
TSQL3->(DbGotop())
While !Eof()

/*	If lNccImp
		If TSQL3->E3_TIPO == "NCC" .And. TSQL3->E3_EMISSAO >= "20210101"
			aNccNFis := u_NccNFis(TSQL3->E3_FILIAL, TSQL3->E3_NUM, TSQL3->E3_SERIE, TSQL3->E3_CODCLI, TSQL3->E3_VEND, TSQL3->R_E_C_N_O_)
			For _ncc := 1 to Len(aNccNFis)
				yVended := aNccNFis[_ncc][1]
				yClient := aNccNFis[_ncc][2]
				yNomCli := aNccNFis[_ncc][3]
				yFilial := aNccNFis[_ncc][4]
				yNumNcc := aNccNFis[_ncc][5]
				ySerNcc := aNccNFis[_ncc][6]
				yNccRec := aNccNFis[_ncc][7]
				yNfOrig := aNccNFis[_ncc][8]
				ySerOri := aNccNFis[_ncc][9]
				AAdd(aNccImp,{yVended, yClient, yNomCli, yFilial, yNumNcc, ySerNcc, yNccRec, yNfOrig, ySerOri})	
			Next _ncc
		Endif	
	Endif */

	zTotal += TSQL3->E3_COMIS

	DbSelectArea("TSQL3")
	TSQL3->(DbSkip())
Enddo
TSQL3->(DbCloseArea())

/*
If Len(aNccImp) > 0
	aCrdNcc := u_NccDeta(aNccImp)
	nCrdNcc := aCrdNcc[1] // Crédito total
	zTotal  += nCrdNcc // Acumula valor total do extrato (crédito dos descontos nos títulos originais)
Endif
*/

RestArea(aArea)

Return(zTotal)
