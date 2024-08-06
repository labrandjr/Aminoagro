#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F440NEG   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 11/01/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Reprocessamento das comissões referente Negociações.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F440NEG()

Local cPerg	:= Padr("F440NEG",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private zModAtra := AllTrim(GetMv("MV_ZMODATR")) // 1=Calcula pelo Vencto.Real | 2=Calcula pelo Vencto.Original
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Recálculo de Comissão - Negociações" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,080,{||"RECÁLCULO DE COMISSÃO PARA NEGOCIAÇÕES"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo recalcular as comissões para os títulos"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"negociados considerando os títulos geradores, de acordo com os parâmetros selecionados."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"O 'Recálculo de Comissão' deverá ser previamente processado no mesmo período."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  11/01/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento - RECÁLCULO COMIS.NEG. ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Calculando comissão para negociações", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  11/01/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local zFiliais   := ""
Local nTotSql    := 0
Local nForFilial := 0
Local aFilsCalc  := {}
Local lProcOk    := .F.
Local aNccImp    := {}
Local lNccImp    := GetMv("MV_ZNCCDET")
Local _ncc

aFilsCalc := MatFilCalc( mv_par05 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

// 1. Comissões s/ Negociações (gerada sobre os títulos originais | específico)
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO <> 'ACO' "
cQuery += " AND E5_TIPO IN('ICF','CH','TF','NP') "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
nTotSql := SQL5->SOMA
SQL5->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO <> 'ACO' "
cQuery += " AND E5_TIPO IN('ICF','CH','TF','NP') "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

oProcess:SetRegua1(nTotSql)

DbSelectArea("SQL5")
SQL5->(DbGotop())
While !Eof()

	oProcess:IncRegua1("Calculando comissão s/ Negociações")
	lProcOk := .T.

	DbSelectArea("SE5")
	SE5->(DbGoto(SQL5->R_E_C_N_O_))
	dDatPag := SE5->E5_DATA

	If SE5->E5_FILIAL == "0108" .And. SE5->E5_DATA < StoD("20181201") // Implantação da Filial 0108 em 01/12/2018
		DbSelectArea("SQL5")
		SQL5->(DbSkip())
		Loop
	Endif 

	If SE5->E5_FILIAL $ "0106,0107" .And. SE5->E5_DATA < StoD("20200201") // Implantação das Filiais 0106 e 0107 em 01/02/2020
		DbSelectArea("SQL5")
		SQL5->(DbSkip())
		Loop
	Endif 

	If SE5->E5_TIPODOC == "BA"
		If SE5->E5_MOTBX != "CEC"
			DbSelectArea("SQL5")
			SQL5->(DbSkip())
			Loop
		Endif
	Endif

	If !u__EstorSe5(SE5->E5_FILORIG, SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, SE5->E5_LOJA, SE5->E5_SEQ)

		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( SE5->(E5_FILORIG+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) )

		zFilial := SE1->E1_FILIAL
		If !Empty(SE1->E1_ZFILINC)
			zFilial := SE1->E1_ZFILINC
		Endif

		If Empty(SE1->E1_NUMLIQ)
			DbSelectArea("SQL5")
			SQL5->(DbSkip())
			Loop
		Endif 

		cFilAnt := SE5->E5_FILIAL
		DbSelectArea("FI7")
		DbSetOrder(2)
		If DbSeek( zFilial + SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) )
			nBxLiqui := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
			zValNego := u_TotNego(zFilial,SE1->E1_NUMLIQ,Nil)
			nFatorBx := (nBxLiqui / zValNego)
			aNfNegoc := u_NfNegoc(zFilial,SE1->E1_NUMLIQ,nBxLiqui,SE1->E1_ZFILINC,@nFatorBx,dDatPag)
			If Len(aNfNegoc) > 0
				u_GrvCmsLq(aNfNegoc,nBxLiqui,nFatorBx,zFilial)
			Endif	
		Endif

	Endif

	DbSelectArea("SQL5")
	SQL5->(DbSkip())
Enddo
SQL5->(DbCloseArea())

// 2. Comissões s/ Acordos
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO = 'ACO' "
cQuery += " AND E5_FILORIG <> ' ' "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
nTotSql := SQL5->SOMA
SQL5->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO = 'ACO' "
cQuery += " AND E5_FILORIG <> ' ' "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

oProcess:SetRegua2(nTotSql)

DbSelectArea("SQL5")
SQL5->(DbGotop())
While !Eof()

	oProcess:IncRegua2("Calculando comissão s/ Acordos")
	lProcOk := .T.

	DbSelectArea("SE5")
	SE5->(DbGoto(SQL5->R_E_C_N_O_))

	If SE5->E5_FILIAL == "0108" .And. SE5->E5_DATA < StoD("20181201") // Implantação da Filial 0108 em 01/12/2018
		DbSelectArea("SQL5")
		SQL5->(DbSkip())
		Loop
	Endif 

	If SE5->E5_FILIAL $ "0106,0107" .And. SE5->E5_DATA < StoD("20200201") // Implantação das Filiais 0106 e 0107 em 01/02/2020
		DbSelectArea("SQL5")
		SQL5->(DbSkip())
		Loop
	Endif 

	If SE5->E5_TIPODOC == "BA"
		If SE5->E5_MOTBX != "CEC"
			DbSelectArea("SQL5")
			SQL5->(DbSkip())
			Loop
		Endif
	Endif
	
	If !u__EstorSe5(SE5->E5_FILORIG, SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, SE5->E5_LOJA, SE5->E5_SEQ)

		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( SE5->(E5_FILORIG+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) )

		zFilial := SE1->E1_FILIAL
		If !Empty(SE1->E1_ZFILINC)
			zFilial := SE1->E1_ZFILINC
		Endif

		cFilAnt := SE5->E5_FILIAL
		DbSelectArea("Z01")
		DbSetOrder(1)
		If DbSeek( zFilial + SE5->E5_NUMERO )
			nBxLiqui := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
			nFatorBx := (nBxLiqui / Z01->Z01_VALNEG)
			aNfAcord := u_NfAcord(zFilial,Z01->Z01_ACORDO,nBxLiqui,SE1->E1_ZFILINC)
			If Len(aNfAcord) > 0
				u_GrvCmsLq(aNfAcord,nBxLiqui,nFatorBx,zFilial)
			Endif	
		Endif

	Endif

	DbSelectArea("SQL5")
	SQL5->(DbSkip())
Enddo
SQL5->(DbCloseArea())

// 3. NCC Filiais Incorporadas
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TIPO = 'D' "
cQuery += " AND D1_DTDIGIT >= '20181201' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TIPO = 'D' "
cQuery += " AND D1_DTDIGIT >= '20181201' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

oProcess:SetRegua2(nTotSql)

DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()

	oProcess:IncRegua2("Excluindo comissões s/ Devoluções Incorporação")
	lProcOk := .T.

	DbSelectArea("SD1")
	SD1->(DbGoto(SQL1->R_E_C_N_O_))

	If !(SD1->D1_FILIAL $("0106,0107,0108"))
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		Loop
	Endif 

	If SD1->D1_FILIAL == "0108"
		zFilInc := "0104"
		If DtoS(SD1->D1_DTDIGIT) < "20181201" // Incorporação em 01/12/2018
			DbSelectArea("SQL1")
			SQL1->(DbSkip())
			Loop
		Endif
	ElseIf SD1->D1_FILIAL == "0107"
		zFilInc := "0108"
		If DtoS(SD1->D1_DTDIGIT) < "20200101" // Incorporação em 01/01/2020
			DbSelectArea("SQL1")
			SQL1->(DbSkip())
			Loop
		Endif
	ElseIf SD1->D1_FILIAL == "0106"
		zFilInc := "0103"
		If DtoS(SD1->D1_DTDIGIT) < "20200101" // Incorporação em 01/01/2020
			DbSelectArea("SQL1")
			SQL1->(DbSkip())
			Loop
		Endif
	Endif

	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA) )
		If !Empty(SF2->F2_VEND1) .And. (SF2->F2_VEND1 >= mv_par03 .And. SF2->F2_VEND1 <= mv_par04)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS1 > 0
					DbSelectArea("SE3")
					DbSetOrder(1)
					If DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND1 )
						If Empty(SE3->E3_DATA)
							RecLock("SE3",.F.)
							DbDelete()
							MsUnLock()
						Endif	
					Endif	
				Endif
			Endif
		Endif
		If !Empty(SF2->F2_VEND2) .And. (SF2->F2_VEND2 >= mv_par03 .And. SF2->F2_VEND2 <= mv_par04)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS2 > 0
					DbSelectArea("SE3")
					DbSetOrder(1)
					If DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND2 )
						If Empty(SE3->E3_DATA)
							RecLock("SE3",.F.)
							DbDelete()
							MsUnLock()
						Endif	
					Endif	
				Endif
			Endif
		Endif	
		If !Empty(SF2->F2_VEND3) .And. (SF2->F2_VEND3 >= mv_par03 .And. SF2->F2_VEND3 <= mv_par04)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS3 > 0
					DbSelectArea("SE3")
					DbSetOrder(1)
					If DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND3 )
						If Empty(SE3->E3_DATA)
							RecLock("SE3",.F.)
							DbDelete()
							MsUnLock()
						Endif	
					Endif	
				Endif
			Endif
		Endif
		If !Empty(SF2->F2_VEND4) .And. (SF2->F2_VEND4 >= mv_par03 .And. SF2->F2_VEND4 <= mv_par04)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS4 > 0
					DbSelectArea("SE3")
					DbSetOrder(1)
					If DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND4 )
						If Empty(SE3->E3_DATA)
							RecLock("SE3",.F.)
							DbDelete()
							MsUnLock()
						Endif	
					Endif	
				Endif
			Endif
		Endif
	Endif

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TIPO = 'D' "
cQuery += " AND D1_DTDIGIT >= '20181201' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TIPO = 'D' "
cQuery += " AND D1_DTDIGIT >= '20181201' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

oProcess:SetRegua2(nTotSql)

DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()

	oProcess:IncRegua2("Calculando comissões s/ Devoluções Incorporação")
	lProcOk := .T.

	DbSelectArea("SD1")
	SD1->(DbGoto(SQL1->R_E_C_N_O_))

	If !(SD1->D1_FILIAL $("0106,0107,0108"))
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		Loop
	Endif 

	If SD1->D1_FILIAL == "0108"
		zFilInc := "0104"
		If DtoS(SD1->D1_DTDIGIT) < "20181201" // Incorporação em 01/12/2018
			DbSelectArea("SQL1")
			SQL1->(DbSkip())
			Loop
		Endif
	ElseIf SD1->D1_FILIAL == "0107"
		zFilInc := "0108"
		If DtoS(SD1->D1_DTDIGIT) < "20200101" // Incorporação em 01/01/2020
			DbSelectArea("SQL1")
			SQL1->(DbSkip())
			Loop
		Endif
	ElseIf SD1->D1_FILIAL == "0106"
		zFilInc := "0103"
		If DtoS(SD1->D1_DTDIGIT) < "20200101" // Incorporação em 01/01/2020
			DbSelectArea("SQL1")
			SQL1->(DbSkip())
			Loop
		Endif
	Endif
	
	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA) )
		If !Empty(SF2->F2_VEND1)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS1 > 0 .And. (SF2->F2_VEND1 >= mv_par03 .And. SF2->F2_VEND1 <= mv_par04)
					DbSelectArea("SE3")
					DbSetOrder(1)
					If !DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND1 )
						RecLock("SE3",.T.)
						SE3->E3_FILIAL  := SD1->D1_FILIAL
						SE3->E3_PREFIXO := SD1->D1_SERIE
						SE3->E3_NUM     := SD1->D1_DOC
						SE3->E3_PARCELA := Space(2)
						SE3->E3_SEQ     := Space(2)
						SE3->E3_VEND    := SF2->F2_VEND1
					Else
						RecLock("SE3",.F.)
					Endif	
					SE3->E3_TIPO    := "NCC"
					SE3->E3_EMISSAO := SD1->D1_DTDIGIT
					SE3->E3_SERIE   := SD1->D1_SERIE
					SE3->E3_CODCLI  := SD1->D1_FORNECE
					SE3->E3_LOJA    := SD1->D1_LOJA
					SE3->E3_BASE    += SD1->(D1_TOTAL-D1_VALICM)*-1
					SE3->E3_COMIS   += (SD1->(D1_TOTAL-D1_VALICM) * (SD2->D2_COMIS1/100))*-1
					SE3->E3_PORC    := Round((SE3->(E3_COMIS/E3_BASE)*100),2)
					SE3->E3_BAIEMI  := "E"
					SE3->E3_PEDIDO  := ""
					SE3->E3_ORIGEM  := "D"
					SE3->E3_VENCTO  := SD1->D1_DTDIGIT
					SE3->E3_MOEDA   := "01"
					SE3->E3_SDOC    := SD1->D1_SERIE
					SE3->E3_ZZGER   := SF2->F2_GEREN1
					SE3->E3_ZZSUP   := SF2->F2_SUPER1
					SE3->E3_ZZDM    := SF2->F2_ZZDM
					SE3->E3_ZZCOMIS := SE3->E3_COMIS
					SE3->E3_ZFILINC := zFilInc
					MsUnLock()
				Endif
			Endif
		Endif
		If !Empty(SF2->F2_VEND2)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS2 > 0 .And. (SF2->F2_VEND2 >= mv_par03 .And. SF2->F2_VEND2 <= mv_par04)
					DbSelectArea("SE3")
					DbSetOrder(1)
					If !DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND2 )
						RecLock("SE3",.T.)
						SE3->E3_FILIAL  := SD1->D1_FILIAL
						SE3->E3_PREFIXO := SD1->D1_SERIE
						SE3->E3_NUM     := SD1->D1_DOC
						SE3->E3_PARCELA := Space(2)
						SE3->E3_SEQ     := Space(2)
						SE3->E3_VEND    := SF2->F2_VEND2
					Else
						RecLock("SE3",.F.)
					Endif	
					SE3->E3_TIPO    := "NCC"
					SE3->E3_EMISSAO := SD1->D1_DTDIGIT
					SE3->E3_SERIE   := SD1->D1_SERIE
					SE3->E3_CODCLI  := SD1->D1_FORNECE
					SE3->E3_LOJA    := SD1->D1_LOJA
					SE3->E3_BASE    += SD1->(D1_TOTAL-D1_VALICM)*-1
					SE3->E3_COMIS   += (SD1->(D1_TOTAL-D1_VALICM) * (SD2->D2_COMIS2/100))*-1
					SE3->E3_PORC    := Round((SE3->(E3_COMIS/E3_BASE)*100),2)
					SE3->E3_BAIEMI  := "E"
					SE3->E3_PEDIDO  := ""
					SE3->E3_ORIGEM  := "D"
					SE3->E3_VENCTO  := SD1->D1_DTDIGIT
					SE3->E3_MOEDA   := "01"
					SE3->E3_SDOC    := SD1->D1_SERIE
					SE3->E3_ZZCOMIS := SE3->E3_COMIS
					SE3->E3_ZFILINC := zFilInc
					MsUnLock()
				Endif
			Endif
		Endif	
		If !Empty(SF2->F2_VEND3) .And. Substr(SF2->F2_VEND3,1,1) == "V"
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS3 > 0 .And. (SF2->F2_VEND3 >= mv_par03 .And. SF2->F2_VEND3 <= mv_par04)
					DbSelectArea("SE3")
					DbSetOrder(1)
					If !DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND3 )
						RecLock("SE3",.T.)
						SE3->E3_FILIAL  := SD1->D1_FILIAL
						SE3->E3_PREFIXO := SD1->D1_SERIE
						SE3->E3_NUM     := SD1->D1_DOC
						SE3->E3_PARCELA := Space(2)
						SE3->E3_SEQ     := Space(2)
						SE3->E3_VEND    := SF2->F2_VEND3
					Else
						RecLock("SE3",.F.)
					Endif	
					SE3->E3_TIPO    := "NCC"
					SE3->E3_EMISSAO := SD1->D1_DTDIGIT
					SE3->E3_SERIE   := SD1->D1_SERIE
					SE3->E3_CODCLI  := SD1->D1_FORNECE
					SE3->E3_LOJA    := SD1->D1_LOJA
					SE3->E3_BASE    += SD1->(D1_TOTAL-D1_VALICM)*-1
					SE3->E3_COMIS   += (SD1->(D1_TOTAL-D1_VALICM) * (SD2->D2_COMIS3/100))*-1
					SE3->E3_PORC    := Round((SE3->(E3_COMIS/E3_BASE)*100),2)
					SE3->E3_BAIEMI  := "E"
					SE3->E3_PEDIDO  := ""
					SE3->E3_ORIGEM  := "D"
					SE3->E3_VENCTO  := SD1->D1_DTDIGIT
					SE3->E3_MOEDA   := "01"
					SE3->E3_SDOC    := SD1->D1_SERIE
					SE3->E3_ZZCOMIS := SE3->E3_COMIS
					SE3->E3_ZFILINC := zFilInc
					MsUnLock()
				Endif
			Endif
		Endif
		If !Empty(SF2->F2_VEND4) .And. Substr(SF2->F2_VEND4,1,1) == "V"
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( zFilInc + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI) )
				If SD2->D2_COMIS4 > 0 .And. (SF2->F2_VEND4 >= mv_par03 .And. SF2->F2_VEND4 <= mv_par04)
					DbSelectArea("SE3")
					DbSetOrder(1)
					If !DbSeek( SD1->(D1_FILIAL+D1_SERIE+D1_DOC)+Space(2)+Space(2)+SF2->F2_VEND4 )
						RecLock("SE3",.T.)
						SE3->E3_FILIAL  := SD1->D1_FILIAL
						SE3->E3_PREFIXO := SD1->D1_SERIE
						SE3->E3_NUM     := SD1->D1_DOC
						SE3->E3_PARCELA := Space(2)
						SE3->E3_SEQ     := Space(2)
						SE3->E3_VEND    := SF2->F2_VEND4
					Else
						RecLock("SE3",.F.)
					Endif	
					SE3->E3_TIPO    := "NCC"
					SE3->E3_EMISSAO := SD1->D1_DTDIGIT
					SE3->E3_SERIE   := SD1->D1_SERIE
					SE3->E3_CODCLI  := SD1->D1_FORNECE
					SE3->E3_LOJA    := SD1->D1_LOJA
					SE3->E3_BASE    += SD1->(D1_TOTAL-D1_VALICM)*-1
					SE3->E3_COMIS   += (SD1->(D1_TOTAL-D1_VALICM) * (SD2->D2_COMIS4/100))*-1
					SE3->E3_PORC    := Round((SE3->(E3_COMIS/E3_BASE)*100),2)
					SE3->E3_BAIEMI  := "E"
					SE3->E3_PEDIDO  := ""
					SE3->E3_ORIGEM  := "D"
					SE3->E3_VENCTO  := SD1->D1_DTDIGIT
					SE3->E3_MOEDA   := "01"
					SE3->E3_SDOC    := SD1->D1_SERIE
					SE3->E3_ZZCOMIS := SE3->E3_COMIS
					SE3->E3_ZFILINC := zFilInc
					MsUnLock()
				Endif
			Endif
		Endif
	Endif

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

// 4. NCC devolução de descontos
If lNccImp
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SE3")
	cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
	cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " // Filtra somenta os vendedores independente da emissão. Todas NCC não pagas devem ser recalculadas prevendo devoluções em meses posteriores aos já calculados.
	cQuery += " AND E3_EMISSAO >= '20210101' "
	cQuery += " AND SUBSTR(E3_VEND,1,1) <> 'R' " // Desconsidera revenda
	cQuery += " AND E3_ZZRTV = ' ' " // Desconsidera apuração Ger/Dir
	cQuery += " AND E3_TIPO = 'NCC' "
	cQuery += " AND E3_DATA = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	nTotSql := SQL3->SOMA
	SQL3->(DbCloseArea())

	cQuery := " SELECT R_E_C_N_O_ "
	cQuery += " FROM "+RetSqlName("SE3")
	cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
	cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " // Filtra somenta os vendedores independente da emissão. Todas NCC não pagas devem ser recalculadas prevendo devoluções em meses posteriores aos já calculados.
	cQuery += " AND E3_EMISSAO >= '20210101' "
	cQuery += " AND SUBSTR(E3_VEND,1,1) <> 'R' " // Desconsidera revenda
	cQuery += " AND E3_ZZRTV = ' ' " // Desconsidera apuração Ger/Dir
	cQuery += " AND E3_TIPO = 'NCC' "
	cQuery += " AND E3_DATA = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY E3_FILIAL, E3_VEND, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_SEQ "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

	oProcess:SetRegua2(nTotSql)

	DbSelectArea("SQL3")
	SQL3->(DbGotop())
	While !Eof()

		oProcess:IncRegua2("NCC devolução descontos")
		lProcOk := .T.

		DbSelectArea("SE3")
		SE3->(DbGoto(SQL3->R_E_C_N_O_))
		nRecSe3 := SE3->(Recno())
			
		aNccImp  := {} // Inicia vazio para gerar resultado isolado da NCC em questão
		aNccNFis := u_NccNFis(SE3->E3_FILIAL, SE3->E3_NUM, SE3->E3_SERIE, SE3->E3_CODCLI, SE3->E3_VEND, nRecSe3)
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
		
		If Len(aNccImp) > 0
			aCrdNcc := u_NccDeta(aNccImp)
			nCrdNcc := aCrdNcc[1] // Crédito total

			SE3->(DbGoto(nRecSe3))
			nCmsNcc := SE3->E3_ZZCOMIS + nCrdNcc
			If nCmsNcc > 0
				nCmsNcc := 0
			Endif

			RecLock("SE3",.F.)
			SE3->E3_COMIS := nCmsNcc
			MsUnLock()
		Endif

		DbSelectArea("SQL3")
		SQL3->(DbSkip())
	Enddo
	SQL3->(DbCloseArea())
Endif

If !lProcOk
	MsgAlert("Sem dados para processamento. Verifique os parâmetros.")
	Return
Else
	MsgInfo("Processo concluído com sucesso.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ NfAcord   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 31/10/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lista as notas fiscais vinculadas ao Acordo.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function NfAcord(zFilial,zAcordo,zBxLiqui,zFilInc)

Local aArea   := GetArea()
Local aAreaE1 := SE1->(GetArea())
Local aAreaE5 := SE5->(GetArea())
Local aRetorno := {}

DbSelectArea("ZE1")
DbSetOrder(1)
If DbSeek( zFilial + zAcordo )
	While !Eof() .And. ZE1->(ZE1_FILIAL+ZE1_ACORDO) == zFilial + zAcordo

		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( ZE1->(ZE1_FILIAL + ZE1_PREFIX + ZE1_NUM + ZE1_PARCEL + ZE1_TIPO + ZE1_CLIENT) )

		zIcms   := 0
		zPedido := ""
		zComis1 := 0
		zComis2 := 0
		zComis3 := 0
		zComis4 := 0
		zFilSe1 := IIf( Empty(SE1->E1_ZFILINC), SE1->E1_FILIAL, SE1->E1_ZFILINC )
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek( zFilSe1 + SE1->(E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA) )
			zIcms := ( SF2->(F2_VALICM / F2_VALBRUT) * 100 )
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) )
				zPedido := SD2->D2_PEDIDO
				zComis1 := SD2->D2_COMIS1
				zComis2 := SD2->D2_COMIS2
				zComis3 := SD2->D2_COMIS3
				zComis4 := SD2->D2_COMIS4
			Endif
		Endif
	
		AAdd(aRetorno,{SE1->E1_VEND1, SE1->E1_GEREN1, SE1->E1_SUPER1, SE1->E1_VEND2, SE1->E1_GEREN2, SE1->E1_SUPER2,;
		               SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_VENCREA, ZE1->ZE1_SALDO,;
		               zIcms, zPedido, zComis1, zComis2, zFilInc, "A", SE1->E1_VEND3, SE1->E1_VEND4, zComis3, zComis4, SE1->E1_ZZDM })

		DbSelectArea("ZE1")		
		ZE1->(DbSkip())
	Enddo
Endif

RestArea(aAreaE1)
RestArea(aAreaE5)
RestArea(aArea)

Return(aRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TotNego   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 12/11/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula total da negociação. 			  				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TotNego(zFilial,zNumLiq,aNumLiq)

Local aArea := GetArea()
Local aAreaE1 := SE1->(GetArea())
Local aAreaE5 := SE5->(GetArea())
Local zTotNeg := 0
Local _q

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+zFilial+"' "
If !Empty(zNumLiq) .And. zNumLiq != Nil
	cQuery += " AND E5_DOCUMEN = '"+zNumLiq+"' "
Else
	zNumLiq := ""
	For _q := 1 to Len(aNumLiq)
		zNumLiq += IIf(!Empty(zNumLiq),",","")+aNumLiq[_q]
	Next q
	cQuery += " AND E5_DOCUMEN IN"+FormatIn(zNumLiq,",")
Endif	
cQuery += " AND E5_MOTBX = 'LIQ' "
cQuery += " AND E5_TIPODOC = 'BA' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLZ", .F., .T.)
DbSelectArea("SQLZ")
SQLZ->(DbGotop())
While !Eof()

	DbSelectArea("SE5")
	SE5->(DbGoto(SQLZ->R_E_C_N_O_))	

	zTotNeg += SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)

	DbSelectArea("SQLZ")
	SQLZ->(DbSkip())
Enddo
SQLZ->(DbCloseArea())

RestArea(aAreaE1)
RestArea(aAreaE5)
RestArea(aArea)

Return(zTotNeg)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ NfNegoc   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 12/11/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lista as notas fiscais vinculadas à Negociação. 			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function NfNegoc(zFilial,zNumLiq,zBxLiqui,zFilInc,nFatorBx,dDatPag)

Local aArea    := GetArea()
Local aAreaE1  := SE1->(GetArea())
Local aAreaE5  := SE5->(GetArea())
Local aRetorno := {}
Local lNegoci2 := .F.
Local aNumLiq2 := {}
Local _z

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+zFilial+"' "
cQuery += " AND E5_DOCUMEN = '"+zNumLiq+"' "
cQuery += " AND E5_MOTBX = 'LIQ' "
cQuery += " AND E5_TIPODOC = 'BA' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLN", .F., .T.)
DbSelectArea("SQLN")
SQLN->(DbGotop())
While !Eof()

	DbSelectArea("SE5")
	SE5->(DbGoto(SQLN->R_E_C_N_O_))	

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR) )

	If AllTrim(SE5->E5_TIPO)=="ICF" .Or. AllTrim(SE5->E5_TIPO)=="CH"

		If !Empty(SE1->E1_NUMLIQ)
			lNegoci2 := .T.
			If Len(aNumLiq2) == 0
				AAdd(aNumLiq2,SE1->E1_NUMLIQ)
			Else
				nPos := aScan(aNumLiq2, {|x| x == SE1->E1_NUMLIQ})
				If nPos == 0
					AAdd(aNumLiq2,SE1->E1_NUMLIQ)
				Endif
			Endif
		Endif	

	Else

		zVlNego := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
		zIcms   := 0
		zPedido := ""
		zComis1 := 0
		zComis2 := 0
		zComis3 := 0
		zComis4 := 0
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek( SE1->(E1_FILIAL + E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA) )
			zIcms := ( SF2->(F2_VALICM / F2_VALBRUT) * 100 )
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) )
				zPedido := SD2->D2_PEDIDO
				zComis1 := SD2->D2_COMIS1
				zComis2 := SD2->D2_COMIS2
				zComis3 := SD2->D2_COMIS3
				zComis4 := SD2->D2_COMIS4
			Endif
		Endif
	
		AAdd(aRetorno,{SE1->E1_VEND1, SE1->E1_GEREN1, SE1->E1_SUPER1, SE1->E1_VEND2, SE1->E1_GEREN2, SE1->E1_SUPER2,;
		               SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_VENCREA, zVlNego, zIcms,;
		               zPedido, zComis1, zComis2, zFilInc, "1", SE1->E1_VEND3, SE1->E1_VEND4, zComis3, zComis4, SE1->E1_ZZDM })

	Endif

	DbSelectArea("SQLN")
	SQLN->(DbSkip())
Enddo
SQLN->(DbCloseArea())

If lNegoci2
	If Len(aNumLiq2) > 0 .And. DtoS(dDatPag) >= "20190103"
		zValNeg2 := u_TotNego(zFilial,Nil,aNumLiq2)
		nFatorBx := (nBxLiqui / zValNeg2)
		aRet2    := u_Nf2Negoc(SE1->E1_FILIAL,aNumLiq2,zFilInc)
		For _z := 1 to Len(aRet2)
			AAdd(aRetorno,{aRet2[_z][1], aRet2[_z][2], aRet2[_z][3], aRet2[_z][4], aRet2[_z][5], aRet2[_z][6], aRet2[_z][7], aRet2[_z][8],;
			 			   aRet2[_z][9], aRet2[_z][10], aRet2[_z][11], aRet2[_z][12], aRet2[_z][13], aRet2[_z][14], aRet2[_z][15], aRet2[_z][16],;
			 			   aRet2[_z][17], aRet2[_z][18], aRet2[_z][19], aRet2[_z][20], aRet2[_z][21], aRet2[_z][22], aRet2[_z][23] })
		Next _z
	Endif
Endif

RestArea(aAreaE1)
RestArea(aAreaE5)
RestArea(aArea)

Return(aRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Nf2Negoc  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 12/11/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lista as notas fiscais vinculadas à Negociação 2o.nível.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function Nf2Negoc(zFilial,aNumLiq,zFilInc)

Local aArea := GetArea()
Local aAreaE1 := SE1->(GetArea())
Local aAreaE5 := SE5->(GetArea())
Local aRetorno := {}
Local _q

zNumLiq := ""
For _q := 1 to Len(aNumLiq)
	zNumLiq += IIf(!Empty(zNumLiq),",","")+aNumLiq[_q]
Next q

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+zFilial+"' "
cQuery += " AND E5_DOCUMEN IN"+FormatIn(zNumLiq,",")
cQuery += " AND E5_MOTBX = 'LIQ' "
cQuery += " AND E5_TIPODOC = 'BA' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLN2", .F., .T.)
DbSelectArea("SQLN2")
SQLN2->(DbGotop())
While !Eof()

	DbSelectArea("SE5")
	SE5->(DbGoto(SQLN2->R_E_C_N_O_))	

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR) )

	If AllTrim(SE5->E5_TIPO)=="ICF" .Or. AllTrim(SE5->E5_TIPO)=="CH"

		// Renegociação 3o.Nível

	Else
	
		zVlNego := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
		zIcms   := 0
		zPedido := ""
		zComis1 := 0
		zComis2 := 0
		zComis3 := 0
		zComis4 := 0
		zFilInc := SE1->E1_FILIAL
		If !Empty(SE1->E1_ZFILINC)
			zFilInc := SE1->E1_ZFILINC
		Endif
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek( zFilInc + SE1->(E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA) )
			zIcms := ( SF2->(F2_VALICM / F2_VALBRUT) * 100 )
			DbSelectArea("SD2")
			DbSetOrder(3)
			If DbSeek( SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) )
				zPedido := SD2->D2_PEDIDO
				zComis1 := SD2->D2_COMIS1
				zComis2 := SD2->D2_COMIS2
				zComis3 := SD2->D2_COMIS3
				zComis4 := SD2->D2_COMIS4
			Endif
		Endif
	
		AAdd(aRetorno,{SE1->E1_VEND1, SE1->E1_GEREN1, SE1->E1_SUPER1, SE1->E1_VEND2, SE1->E1_GEREN2, SE1->E1_SUPER2,;
		               SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_VENCREA, zVlNego, zIcms,;
		               zPedido, zComis1, zComis2, zFilInc, "2", SE1->E1_VEND3, SE1->E1_VEND4, zComis3, zComis4, SE1->E1_ZZDM })

	Endif	

	DbSelectArea("SQLN2")
	SQLN2->(DbSkip())
Enddo
SQLN2->(DbCloseArea())

RestArea(aAreaE1)
RestArea(aAreaE5)
RestArea(aArea)

Return(aRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GrvCmsLq ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  12/11/18	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação da comissão dos títulos acordados/negociados.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GrvCmsLq(aTitComs,nBxLiqui,nFatorBx,zFilial)

Local aArea    := GetArea()
Local nBxAcumu := 0
Local _x
Local _y

For _x := 1 to Len(aTitComs)
	zVend1   := aTitComs[_x][01]
	zGeren1  := aTitComs[_x][02]
	zSuper1  := aTitComs[_x][03]
	zVend2   := aTitComs[_x][04]
	zGeren2  := ""
	zSuper2  := ""
	zPrefixo := aTitComs[_x][07]
	zNumero  := aTitComs[_x][08]
	zParcela := aTitComs[_x][09]
	zTipo    := aTitComs[_x][10]
	zVencto  := aTitComs[_x][11]
	zIcms    := aTitComs[_x][13]
	zPedido  := aTitComs[_x][14]
	zComis1  := aTitComs[_x][15]
	zComis2  := aTitComs[_x][16]
	zFilInc  := aTitComs[_x][17]
	zNivNeg  := aTitComs[_x][18]
	zVend3   := aTitComs[_x][19]
	zVend4   := aTitComs[_x][20]
	zComis3  := aTitComs[_x][21]
	zComis4  := aTitComs[_x][22]
	zGeren3  := IIf(Substr(zVend3,1,1)=="V",zGeren1,"")
	zSuper3  := IIf(Substr(zVend3,1,1)=="V",zSuper1,"")
	zGeren4  := ""
	zSuper4  := ""
	zzDM1    := aTitComs[_x][23]
	zzDM2    := ""
	zzDM3    := ""
	zzDM4    := ""
	If _x == Len(aTitComs)
		zValor := nBxLiqui - nBxAcumu
	Else
		zValor := Round((aTitComs[_x][12] * nFatorBx),2)
		nBxAcumu += zValor
	Endif
	//
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( zFilial + zPrefixo + zNumero + zParcela + zTipo )
	//
	If zModAtra == "2"
		zDiasAtr := SE5->E5_DATA - DataValida(SE1->E1_VENCORI,.T.)
	Else
		zDiasAtr := SE5->E5_DATA - SE1->E1_VENCREA
	Endif	
	zBaseCom := zValor - (zValor * (zIcms/100))
	//
	For _y := 1 to 4
		zVend   := &("zVend"+AllTrim(STR(_y)))
		zGeren  := &("zGeren"+AllTrim(STR(_y)))
		zSuper  := &("zSuper"+AllTrim(STR(_y)))
		zzDM    := &("zzDM"+AllTrim(STR(_y)))
		zPorc   := &("zComis"+AllTrim(STR(_y)))
		zIdNeg  := SE5->( AllTrim(E5_PREFIXO)+"-"+AllTrim(E5_NUMERO)+"-"+AllTrim(E5_PARCELA) )
		zAtraso := zDiasAtr
		zComiss := (zBaseCom * (zPorc/100))
		
		lJaGrav := .F.
		DbSelectArea("SE3")
		DbSetOrder(5)
		If DbSeek( SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_SEQ + zVend + Space(16) )
			If !Empty(SE3->E3_DATA) // Comissão já foi calculada e paga no modelo antigo.
				lJaGrav := .T.
			Else
				If (zVend >= mv_par03 .And. zVend <= mv_par04)
					RecLock("SE3",.F.) // Comissão não foi paga, portanto exclui antes de inserir o modelo novo.
					DbDelete()
					MsUnLock()
				Endif	
			Endif
		Endif

		If !Empty(zVend) .And. zComiss > 0 .And. (zVend >= mv_par03 .And. zVend <= mv_par04) .And. !lJaGrav
			DbSelectArea("SE3")
			DbSetOrder(5)
			If !DbSeek( SE5->E5_FILIAL + zPrefixo + zNumero + zParcela + SE5->E5_SEQ + zVend + PadR(zIdNeg,16) )
				RecLock("SE3",.T.)
				SE3->E3_FILIAL  := SE5->E5_FILIAL
				SE3->E3_PREFIXO := zPrefixo
				SE3->E3_NUM     := zNumero
				SE3->E3_PARCELA := zParcela
				SE3->E3_SEQ     := SE5->E5_SEQ
				SE3->E3_VEND    := zVend
				SE3->E3_ZZACORD := zIdNeg
			Else
				RecLock("SE3",.F.)
			Endif	
			SE3->E3_TIPO    := zTipo
			SE3->E3_EMISSAO := SE5->E5_DATA
			SE3->E3_SERIE   := zPrefixo
			SE3->E3_CODCLI  := SE1->E1_CLIENTE
			SE3->E3_LOJA    := SE1->E1_LOJA
			SE3->E3_BASE    := zBaseCom
			SE3->E3_PORC    := zPorc
			SE3->E3_COMIS   := zComiss
			SE3->E3_BAIEMI  := "B"
			SE3->E3_PEDIDO  := zPedido
			SE3->E3_ORIGEM  := "R"
			SE3->E3_VENCTO  := SE5->E5_DATA
			SE3->E3_MOEDA   := "01"
			SE3->E3_SDOC    := zPrefixo
			SE3->E3_ZZGER   := zGeren
			SE3->E3_ZZSUP   := zSuper
			SE3->E3_ZZDM    := zzDM
			SE3->E3_ZZCOMIS := zComiss
			SE3->E3_ZVLPAGO := zValor
			SE3->E3_ZICMS   := zIcms
			SE3->E3_ZVALICM := (zValor * (zIcms/100))
			SE3->E3_ZFILINC := IIf(SE5->E5_FILIAL != SE1->E1_FILIAL, SE1->E1_FILIAL, "")
			SE3->E3_ZZATRAS := 0
			SE3->E3_ZZPDESC := 0
			SE3->E3_ZZVDESC := 0
			SE3->E3_ZNIVNEG := zNivNeg
			MsUnLock()

			If zAtraso >= 9999
				zAtraso := 9999
			Endif

			If zAtraso > 0

				RecLock("SE3",.F.)
				SE3->E3_ZZATRAS := zAtraso
				MsUnLock()

				zPDescon := 0
				If Substr(SE3->E3_VEND,1,1) == "R" // Revenda
					If zAtraso > 60 // Acima de 60 dias de atraso NÃO RECEBE O PRÊMIO.
						zPDescon := 100
					ElseIf zAtraso > 30 // 31 a 60 dias de atraso = 50% do prêmio;
						zPDescon := 50
					ElseIf zAtraso > 15 // 16 a 30 dias de atraso = 80% do prêmio;
						zPDescon := 20
					Else // Até 15 dias de atraso = 90% do prêmio;
						zPDescon := 10	
					Endif
				Else // Todos exceto Revenda
					If zAtraso > GetMv("MV_DIATRTV") // Acima de N dias de atraso NÃO RECEBE O PRÊMIO.
						zPDescon := 100
					Endif
				Endif

				If zPDescon > 0
					RecLock("SE3",.F.)
					SE3->E3_ZZPDESC := zPDescon
					If zPDescon == 100
						SE3->E3_ZZVDESC := SE3->E3_COMIS
						SE3->E3_COMIS   := 0.00
					Else
						SE3->E3_ZZVDESC := (SE3->E3_COMIS * (zPDescon/100))
						SE3->E3_COMIS   := SE3->E3_COMIS - SE3->E3_ZZVDESC
					Endif	
					MsUnLock()
				Endif

			Endif

			// ** Início Metas ** //
			If Year(SE1->E1_EMISSAO) >= 2020
				zAno   := Substr(DtoS(SE1->E1_EMISSAO),1,4)
				zPMeta := u_GetPMeta(SE3->E3_VEND,zAno)
				//
				RecLock("SE3",.F.)
				SE3->E3_MTCOMIS := SE3->E3_COMIS // Armazena valor da comissão calculado antes de checar metas
				SE3->E3_MTPMETA := zPMeta
				SE3->E3_COMIS   := (SE3->E3_COMIS * (zPMeta/100))
				MsUnLock()
			Endif
			// ** Fim Metas ** //	

		Endif
	Next _y
	//
Next _x

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ NccRecalc ¦ Autor ¦ Fabrica ERPBR ¦ Data ¦ 10/08/2021	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Recalcula NCC considerando devoluções de descontos.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function NccRecalc()

Return
