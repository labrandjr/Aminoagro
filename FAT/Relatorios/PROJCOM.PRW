#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PROJCOM  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 02/01/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Projeção de Comissões (Pagas + Em Aberto).    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PROJCOM()

Local cPerg	:= Padr("PROJCOM",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private zModAtra := AllTrim(GetMv("MV_ZMODATR")) // 1=Calcula pelo Vencto.Real | 2=Calcula pelo Vencto.Original
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb
Private oTempTable

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Projeção de Premiação" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"EMISSÃO DA PROJEÇÃO DE PREMIAÇÃO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo emitir uma listagem com a projeção da premiação"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"considerando os pagamentos realizados e os títulos em aberto dentro do"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"período selecionado em 'Parâmetros'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"É necessário processar as rotinas abaixo antes da emissão do relatório:"},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText4:CtrlRefresh()

oText5:= TSay():New(100,010,{||"- 'Recálculo de Comissão'"},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText5:CtrlRefresh()

oText6:= TSay():New(110,010,{||"- 'Recálculo de Comissão Negociações'"},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText6:CtrlRefresh()

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

Private cPath := "c:\report\"

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

If MsgYesNo("Confirma o processamento - PROJEÇÃO DE PREMIAÇÃO ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Emitindo listagem da projeção de premiação", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  02/01/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local cFilBkp  := cFilAnt
Local zPorcG   := GetMv("ZZ_PERCGER")
Local zPorcD   := GetMv("ZZ_PERCDIR")
Local cEOL     := CHR(13)+CHR(10)
Local nForFilial
Private aLiquid := {}
Private aValLiq := {}

If !MsgYesNo("Atenção:"+cEOL+cEOL+;
		 	 "Certifique-se que as rotinas abaixo foram executadas no período de "+DtoC(mv_par01)+" até "+DtoC(mv_par02)+;
			 " para todas as Filiais:"+cEOL+cEOL+;
			 "-> Recalculo de Comissão"+cEOL+;
			 "-> Recalculo de Comissão Negociações"+cEOL+cEOL+;
			 "Caso contrário o relatório irá fornecer dados divergentes !!"+cEOL+cEOL+;
			 "Confirma emissão do relatório ?")
	Return		 
Endif

TrabProj()

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

ProcRegua(2)

// 1.Baixas
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE3")
cQuery += " WHERE E3_FILIAL IN("+zFiliais+") "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
If mv_par06 == 2 // Revenda = Não
	cQuery += " AND SUBSTR(E3_VEND,1,1) <> 'R' "
Endif
cQuery += " AND E3_DATA = ' ' "
cQuery += " AND E3_ZZRTV = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)
nTotSql := SQE3->SOMA
SQE3->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT E3_FILIAL FILIAL, E3_VEND VEND, E3_PREFIXO PREFIXO, E3_NUM NUM, E3_PARCELA PARCELA, E3_TIPO TIPO, E3_SEQ SEQ, "
cQuery += " E3_CODCLI CODCLI, E3_LOJA LOJA, E3_EMISSAO EMISSAO, E3_BASE BASE, E3_PORC PORC, E3_COMIS COMIS, E3_ZZCOMIS ZZCOMIS, "
cQuery += " E3_ZZATRAS ZZATRAS, E3_ZZPDESC ZZPDESC, E3_ZZVDESC ZZVDESC, E3_ZZACORD ZZACORD, E3_ZVLPAGO ZVLPAGO, E3_ZZGER ZZGER, " 
cQuery += " E3_ZZSUP ZZSUP, E3_ZFILINC ZFILINC "
cQuery += " FROM "+RetSqlName("SE3")
cQuery += " WHERE E3_FILIAL IN("+zFiliais+") "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
If mv_par06 == 2 // Revenda = Não
	cQuery += " AND SUBSTR(E3_VEND,1,1) <> 'R' "
Endif
cQuery += " AND E3_DATA = ' ' "
cQuery += " AND E3_ZZRTV = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, VEND, PREFIXO, NUM, PARCELA, TIPO, SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)

DbSelectArea("SQE3")
ProcRegua(nTotSql)
SQE3->(DbGotop())
While !Eof()

	oProcess:IncRegua1("Títulos baixados..")

	zFil := SQE3->FILIAL 
	zInc := SQE3->FILIAL
	zPrf := SQE3->PREFIXO
	zNum := SQE3->NUM
	zPar := IIf(SQE3->TIPO=="NCC","01",SQE3->PARCELA)
	zTip := SQE3->TIPO
	
	If !Empty(SQE3->ZFILINC)
		zInc := SQE3->ZFILINC
	Endif
	
	lFound := .F.
	DbSelectArea("SE1")
	DbSetOrder(1)
	If DbSeek( zInc + zPrf + zNum + zPar + zTip )
		lFound := .T.
	Endif
	If !lFound
		If DbSeek( zFil + zPrf + zNum + zPar + zTip )
			lFound := .T.
		Endif
	Endif
	If !lFound
		//MsgAlert(SQE3->PREFIXO + " "+SQE3->NUM+" "+SQE3->PARCELA+" "+SQE3->TIPO)
	Endif

	If mv_par07 == 1
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->TF_FILIAL  := SQE3->FILIAL
		TRB->TF_ITEMCC  := RetField("SD2",3,SE1->E1_FILIAL + SQE3->(NUM + PREFIXO + CODCLI),"D2_ITEMCC")
		TRB->TF_VEND    := SQE3->VEND
		TRB->TF_PREFIXO := SQE3->PREFIXO
		TRB->TF_NUM     := SQE3->NUM
		TRB->TF_PARCELA := SQE3->PARCELA
		TRB->TF_TIPO    := SQE3->TIPO
		TRB->TF_SEQ     := SQE3->SEQ
		TRB->TF_CLIENTE := SQE3->CODCLI
		TRB->TF_EMISSAO := SE1->E1_EMISSAO
		TRB->TF_VENCORI := DataValida(SE1->E1_VENCORI,.T.)
		TRB->TF_VENCREA := SE1->E1_VENCREA
		TRB->TF_PAGTO   := StoD(SQE3->EMISSAO)
		TRB->TF_STATUS  := "BX"
		TRB->TF_BASE    := SQE3->BASE
		TRB->TF_PORC    := SQE3->PORC
		TRB->TF_COMIS   := SQE3->COMIS
		TRB->TF_ZZCOMIS := SQE3->ZZCOMIS
		TRB->TF_ZZATRAS := SQE3->ZZATRAS
		TRB->TF_ZZPDESC := SQE3->ZZPDESC
		TRB->TF_ZZVDESC := SQE3->ZZVDESC
		TRB->TF_ZZACORD := SQE3->ZZACORD
		TRB->TF_ZVLPAGO := SQE3->ZVLPAGO
		MsUnLock()
	Else
		aClas := _GetClas("C",Substr(SQE3->VEND,1,1))
		zVend := aClas[1]
		zClas := aClas[2]
		zStat := "BX"
		DbSelectArea("TRB")
		DbSetOrder(1)
		If !DbSeek( zVend + zStat )
			RecLock("TRB",.T.)
			TRB->TF_VEND    := zVend
			TRB->TF_CLASSIF := zClas
			TRB->TF_STATUS  := zStat
		Else
			RecLock("TRB",.F.)
		Endif	
		TRB->TF_COMIS   += SQE3->COMIS
		TRB->TF_ZZCOMIS += SQE3->ZZCOMIS
		MsUnLock()
	Endif

	If Substr(SQE3->VEND,1,1)!="R"

		If !Empty(SQE3->ZZGER) .And. (SQE3->ZZGER >= mv_par03 .And. SQE3->ZZGER <= mv_par04) .And. (SQE3->COMIS * (zPorcG/100)) != 0
			If mv_par07 == 1
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := SQE3->FILIAL
				TRB->TF_ITEMCC  := RetField("SD2",3,SE1->E1_FILIAL + SQE3->(NUM + PREFIXO + CODCLI),"D2_ITEMCC")
				TRB->TF_VEND    := SQE3->ZZGER
				TRB->TF_PREFIXO := SQE3->PREFIXO
				TRB->TF_NUM     := SQE3->NUM
				TRB->TF_PARCELA := SQE3->PARCELA
				TRB->TF_TIPO    := SQE3->TIPO
				TRB->TF_SEQ     := SQE3->SEQ
				TRB->TF_CLIENTE := SQE3->CODCLI
				TRB->TF_EMISSAO := SE1->E1_EMISSAO
				TRB->TF_VENCORI := DataValida(SE1->E1_VENCORI,.T.)
				TRB->TF_VENCREA := SE1->E1_VENCREA
				TRB->TF_PAGTO   := StoD(SQE3->EMISSAO)
				TRB->TF_STATUS  := "GB"
				TRB->TF_BASE    := SQE3->COMIS
				TRB->TF_PORC    := zPorcG
				TRB->TF_COMIS   := (SQE3->COMIS * (zPorcG/100))
				TRB->TF_ZZCOMIS := (SQE3->COMIS * (zPorcG/100))
				MsUnLock()
			Else
				aClas := _GetClas("A",Substr(SQE3->ZZGER,1,1))
				zVend := aClas[1]
				zClas := aClas[2]
				zStat := "BX"
				DbSelectArea("TRB")
				DbSetOrder(1)
				If !DbSeek( zVend + zStat )
					RecLock("TRB",.T.)
					TRB->TF_VEND    := zVend
					TRB->TF_CLASSIF := zClas
					TRB->TF_STATUS  := zStat
				Else
					RecLock("TRB",.F.)
				Endif	
				TRB->TF_COMIS   += (SQE3->COMIS * (zPorcG/100))
				TRB->TF_ZZCOMIS += (SQE3->COMIS * (zPorcG/100))
				MsUnLock()
			Endif	
		Endif
	
		If !Empty(SQE3->ZZSUP) .And. (SQE3->ZZSUP >= mv_par03 .And. SQE3->ZZSUP <= mv_par04) .And. ((SQE3->COMIS * (zPorcD/100))) != 0
			If mv_par07 == 1
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := SQE3->FILIAL
				TRB->TF_ITEMCC  := RetField("SD2",3,SE1->E1_FILIAL + SQE3->(NUM + PREFIXO + CODCLI),"D2_ITEMCC")
				TRB->TF_VEND    := SQE3->ZZSUP
				TRB->TF_PREFIXO := SQE3->PREFIXO
				TRB->TF_NUM     := SQE3->NUM
				TRB->TF_PARCELA := SQE3->PARCELA
				TRB->TF_TIPO    := SQE3->TIPO
				TRB->TF_SEQ     := SQE3->SEQ
				TRB->TF_CLIENTE := SQE3->CODCLI
				TRB->TF_EMISSAO := SE1->E1_EMISSAO
				TRB->TF_VENCORI := DataValida(SE1->E1_VENCORI,.T.)
				TRB->TF_VENCREA := SE1->E1_VENCREA
				TRB->TF_PAGTO   := StoD(SQE3->EMISSAO)
				TRB->TF_STATUS  := "DB"
				TRB->TF_BASE    := SQE3->COMIS
				TRB->TF_PORC    := zPorcD
				TRB->TF_COMIS   := (SQE3->COMIS * (zPorcD/100))
				TRB->TF_ZZCOMIS := (SQE3->COMIS * (zPorcD/100))
				MsUnLock()
			Else
				aClas := _GetClas("A",Substr(SQE3->ZZSUP,1,1))
				zVend := aClas[1]
				zClas := aClas[2]
				zStat := "BX"
				DbSelectArea("TRB")
				DbSetOrder(1)
				If !DbSeek( zVend + zStat )
					RecLock("TRB",.T.)
					TRB->TF_VEND    := zVend
					TRB->TF_CLASSIF := zClas
					TRB->TF_STATUS  := zStat
				Else
					RecLock("TRB",.F.)
				Endif	
				TRB->TF_COMIS   += (SQE3->COMIS * (zPorcD/100))
				TRB->TF_ZZCOMIS += (SQE3->COMIS * (zPorcD/100))
				MsUnLock()
			Endif	
		Endif

	Endif

	DbSelectArea("SQE3")
	SQE3->(DbSkip())
Enddo
SQE3->(DbCloseArea())

// 2.Em Aberto
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE1")+" SE1, "
cQuery += RetSqlName("SF2")+" SF2 "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_FILIAL = F2_FILIAL "
cQuery += " AND E1_PREFIXO = F2_SERIE "
cQuery += " AND E1_NUM = F2_DOC "
cQuery += " AND E1_CLIENTE = F2_CLIENTE "
cQuery += " AND E1_LOJA = F2_LOJA "
cQuery += " AND F2_TIPO = 'N' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_VENCREA <= '"+DtoS(mv_par02)+"' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)
nTotSql := SQE3->SOMA
SQE3->(DbCloseArea())

cQuery := " SELECT E1_FILIAL FILIAL, E1_PREFIXO PREFIXO, E1_NUM NUM, E1_PARCELA PARCELA, E1_TIPO TIPO, E1_SALDO SALDO, "
cQuery += " E1_EMISSAO EMISSAO, E1_VENCREA VENCREA, E1_VENCORI VENCORI, E1_GEREN1 GEREN1, E1_SUPER1 SUPER1, E1_GEREN2 GEREN2, "
cQuery += " E1_SUPER2 SUPER2, F2_SERIE SERIE, F2_DOC DOC, F2_CLIENTE CLIENTE, F2_LOJA LOJA, F2_VEND1 VEND1, F2_VEND2 VEND2, "
cQuery += " F2_VEND3 VEND3, F2_VEND4 VEND4, F2_VALBRUT VALBRUT, F2_VALICM VALICM, ((F2_VALICM/F2_VALBRUT)*100) ALIQICM "
cQuery += " FROM "+RetSqlName("SE1")+" SE1, "
cQuery += RetSqlName("SF2")+" SF2 "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_FILIAL = F2_FILIAL "
cQuery += " AND E1_PREFIXO = F2_SERIE "
cQuery += " AND E1_NUM = F2_DOC "
cQuery += " AND E1_CLIENTE = F2_CLIENTE "
cQuery += " AND E1_LOJA = F2_LOJA "
cQuery += " AND F2_TIPO = 'N' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_VENCREA <= '"+DtoS(mv_par02)+"' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, PREFIXO, NUM, PARCELA, TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)

DbSelectArea("SQE3")
ProcRegua(nTotSql)
SQE3->(DbGotop())
While !Eof()

	oProcess:IncRegua1("Títulos em aberto..")

	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek( SQE3->(FILIAL+DOC+SERIE+CLIENTE+LOJA) )

	// Vendedor1
	lVend1Ok := .T.
	If Empty(SQE3->VEND1) .Or. (SQE3->VEND1 < mv_par03) .Or. (SQE3->VEND1 > mv_par04)
		lVend1Ok := .F.
	Endif

	If mv_par06 == 2 // Revenda = Não
		If Substr(SQE3->VEND1,1,1) == "R"
			lVend1Ok := .F.
		Endif
	Endif

	If lVend1Ok
	
		zBase := Round(SQE3->SALDO - (SQE3->(SALDO*(ALIQICM/100))),2)
		zPorc := SD2->D2_COMIS1
		zComs := Round(zBase * (zPorc/100),2)
	
		If zComs != 0
	
			If mv_par07 == 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := SQE3->FILIAL
				TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
				TRB->TF_VEND    := SQE3->VEND1
				TRB->TF_PREFIXO := SQE3->PREFIXO
				TRB->TF_NUM     := SQE3->NUM
				TRB->TF_PARCELA := SQE3->PARCELA
				TRB->TF_TIPO    := SQE3->TIPO
				TRB->TF_CLIENTE := SQE3->CLIENTE
				TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
				TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
				TRB->TF_VENCREA := StoD(SQE3->VENCREA)
				TRB->TF_PAGTO   := StoD("")
				TRB->TF_STATUS  := "AB"
				TRB->TF_BASE    := zBase
				TRB->TF_PORC    := zPorc
				TRB->TF_COMIS   := zComs
				TRB->TF_ZZCOMIS := zComs
				MsUnLock()
			Else
				aClas := _GetClas("C",Substr(SQE3->VEND1,1,1))
				zVend := aClas[1]
				zClas := aClas[2]
				zStat := "AB"
				DbSelectArea("TRB")
				DbSetOrder(1)
				If !DbSeek( zVend + zStat )
					RecLock("TRB",.T.)
					TRB->TF_VEND    := zVend
					TRB->TF_CLASSIF := zClas
					TRB->TF_STATUS  := zStat
				Else
					RecLock("TRB",.F.)
				Endif	
				TRB->TF_COMIS   += zComs
				TRB->TF_ZZCOMIS += zComs
				MsUnLock()
			Endif	
	
			If zModAtra == "2"
				zAtraso  := dDatabase - DataValida(StoD(SQE3->VENCORI),.T.)
			Else
				zAtraso  := dDatabase - StoD(SQE3->VENCREA)
			Endif	
			
			zPDescon := 0
			If zAtraso > 0
				If mv_par07 == 1
					RecLock("TRB",.F.)
					TRB->TF_ZZATRAS := zAtraso
					MsUnLock()
				Endif	
				If Substr(TRB->TF_VEND,1,1) == "R"
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
				If zAtraso >= 9999
					zAtraso := 9999
				Endif
				If zPDescon > 0
					RecLock("TRB",.F.)
					If mv_par07 == 1
						TRB->TF_ZZPDESC := zPDescon
					Endif	
					If zPDescon == 100
						If mv_par07 == 1
							TRB->TF_ZZVDESC := TRB->TF_COMIS
							TRB->TF_COMIS   := 0.00
						Else
							zNewCom := 0
						Endif	
					Else
						If mv_par07 == 1
							TRB->TF_ZZVDESC := (TRB->TF_COMIS * (zPDescon/100))
							TRB->TF_COMIS   := TRB->TF_COMIS - (TRB->TF_COMIS * (zPDescon/100))
						Else
							zzVDesc := (zComs * (zPDescon/100))
							zNewCom := zComs - zzVDesc
						Endif	
					Endif	
					MsUnLock()
					If mv_par07 == 2
						RecLock("TRB",.F.)
						TRB->TF_COMIS += (zNewCom - zComs)
						MsUnLock()
					Endif
					zComs := IIf(mv_par07==1,TRB->TF_COMIS,zNewCom)
				Endif
			Endif
	
		Endif	
	
		If Substr(SQE3->VEND1,1,1)!="R"
	
			If !Empty(SQE3->GEREN1) .And. (SQE3->GEREN1 >= mv_par03 .And. SQE3->GEREN1 <= mv_par04) .And. ((zComs * (zPorcG/100))) != 0
				If mv_par07 == 1
					RecLock("TRB",.T.)
					TRB->TF_FILIAL  := SQE3->FILIAL
					TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
					TRB->TF_VEND    := SQE3->GEREN1
					TRB->TF_PREFIXO := SQE3->PREFIXO
					TRB->TF_NUM     := SQE3->NUM
					TRB->TF_PARCELA := SQE3->PARCELA
					TRB->TF_TIPO    := SQE3->TIPO
					TRB->TF_CLIENTE := SQE3->CLIENTE
					TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
					TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
					TRB->TF_VENCREA := StoD(SQE3->VENCREA)
					TRB->TF_PAGTO   := StoD("")
					TRB->TF_STATUS  := "GA"
					TRB->TF_BASE    := zComs
					TRB->TF_PORC    := zPorcG
					TRB->TF_COMIS   := (zComs * (zPorcG/100))
					TRB->TF_ZZCOMIS := (zComs * (zPorcG/100))
					MsUnLock()
				Else
					aClas := _GetClas("A",Substr(SQE3->GEREN1,1,1))
					zVend := aClas[1]
					zClas := aClas[2]
					zStat := "AB"
					DbSelectArea("TRB")
					DbSetOrder(1)
					If !DbSeek( zVend + zStat )
						RecLock("TRB",.T.)
						TRB->TF_VEND    := zVend
						TRB->TF_CLASSIF := zClas
						TRB->TF_STATUS  := zStat
					Else
						RecLock("TRB",.F.)
					Endif	
					TRB->TF_COMIS   += (zComs * (zPorcG/100))
					TRB->TF_ZZCOMIS += (zComs * (zPorcG/100))
					MsUnLock()
				Endif	
			Endif
		
			If !Empty(SQE3->SUPER1) .And. (SQE3->SUPER1 >= mv_par03 .And. SQE3->SUPER1 <= mv_par04) .And. ((zComs * (zPorcD/100))) != 0
				If mv_par07 == 1
					RecLock("TRB",.T.)
					TRB->TF_FILIAL  := SQE3->FILIAL
					TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
					TRB->TF_VEND    := SQE3->SUPER1
					TRB->TF_PREFIXO := SQE3->PREFIXO
					TRB->TF_NUM     := SQE3->NUM
					TRB->TF_PARCELA := SQE3->PARCELA
					TRB->TF_TIPO    := SQE3->TIPO
					TRB->TF_CLIENTE := SQE3->CLIENTE
					TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
					TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
					TRB->TF_VENCREA := StoD(SQE3->VENCREA)
					TRB->TF_PAGTO   := StoD("")
					TRB->TF_STATUS  := "DA"
					TRB->TF_BASE    := zComs
					TRB->TF_PORC    := zPorcD
					TRB->TF_COMIS   := (zComs * (zPorcD/100))
					TRB->TF_ZZCOMIS := (zComs * (zPorcD/100))
					MsUnLock()
				Else
					aClas := _GetClas("A",Substr(SQE3->SUPER1,1,1))
					zVend := aClas[1]
					zClas := aClas[2]
					zStat := "AB"
					DbSelectArea("TRB")
					DbSetOrder(1)
					If !DbSeek( zVend + zStat )
						RecLock("TRB",.T.)
						TRB->TF_VEND    := zVend
						TRB->TF_CLASSIF := zClas
						TRB->TF_STATUS  := zStat
					Else
						RecLock("TRB",.F.)
					Endif	
					TRB->TF_COMIS   += (zComs * (zPorcD/100))
					TRB->TF_ZZCOMIS += (zComs * (zPorcD/100))
					MsUnLock()
				Endif	
			Endif
	
		Endif
	
	Endif // Vendedor1

	// Vendedor2
	lVend2Ok := .T.
	If Empty(SQE3->VEND2) .Or. (SQE3->VEND2 < mv_par03) .Or. (SQE3->VEND2 > mv_par04)
		lVend2Ok := .F.
	Endif

	If mv_par06 == 2 // Revenda = Não
		If Substr(SQE3->VEND2,1,1) == "R"
			lVend2Ok := .F.
		Endif
	Endif

	If lVend2Ok

		zBase := Round(SQE3->SALDO - (SQE3->(SALDO*(ALIQICM/100))),2)
		zPorc := SD2->D2_COMIS2
		zComs := Round(zBase * (zPorc/100),2)
	
		If zComs != 0
	
			If mv_par07 == 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := SQE3->FILIAL
				TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
				TRB->TF_VEND    := SQE3->VEND2
				TRB->TF_PREFIXO := SQE3->PREFIXO
				TRB->TF_NUM     := SQE3->NUM
				TRB->TF_PARCELA := SQE3->PARCELA
				TRB->TF_TIPO    := SQE3->TIPO
				TRB->TF_CLIENTE := SQE3->CLIENTE
				TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
				TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
				TRB->TF_VENCREA := StoD(SQE3->VENCREA)
				TRB->TF_PAGTO   := StoD("")
				TRB->TF_STATUS  := "AB"
				TRB->TF_BASE    := zBase
				TRB->TF_PORC    := zPorc
				TRB->TF_COMIS   := zComs
				TRB->TF_ZZCOMIS := zComs
				MsUnLock()
			Else
				aClas := _GetClas("C",Substr(SQE3->VEND2,1,1))
				zVend := aClas[1]
				zClas := aClas[2]
				zStat := "AB"
				DbSelectArea("TRB")
				DbSetOrder(1)
				If !DbSeek( zVend + zStat )
					RecLock("TRB",.T.)
					TRB->TF_VEND    := zVend
					TRB->TF_CLASSIF := zClas
					TRB->TF_STATUS  := zStat
				Else
					RecLock("TRB",.F.)
				Endif	
				TRB->TF_COMIS   += zComs
				TRB->TF_ZZCOMIS += zComs
				MsUnLock()
			Endif	
	
			If zModAtra == "2"
				zAtraso  := dDatabase - DataValida(StoD(SQE3->VENCORI),.T.)
			Else
				zAtraso  := dDatabase - StoD(SQE3->VENCREA)
			Endif	

			zPDescon := 0
			If zAtraso > 0
				If mv_par07 == 1
					RecLock("TRB",.F.)
					TRB->TF_ZZATRAS := zAtraso
					MsUnLock()
				Endif	
				If Substr(TRB->TF_VEND,1,1) == "R"
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
				If zAtraso >= 9999
					zAtraso := 9999
				Endif
				If zPDescon > 0
					RecLock("TRB",.F.)
					If mv_par07 == 1
						TRB->TF_ZZPDESC := zPDescon
					Endif	
					If zPDescon == 100
						If mv_par07 == 1
							TRB->TF_ZZVDESC := TRB->TF_COMIS
							TRB->TF_COMIS   := 0.00
						Else
							zNewCom := 0
						Endif	
					Else
						If mv_par07 == 1
							TRB->TF_ZZVDESC := (TRB->TF_COMIS * (zPDescon/100))
							TRB->TF_COMIS   := TRB->TF_COMIS - (TRB->TF_COMIS * (zPDescon/100))
						Else	
							zzVDesc := (zComs * (zPDescon/100))
							zNewCom := zComs - zzVDesc
						Endif	
					Endif	
					MsUnLock()
					If mv_par07 == 2
						RecLock("TRB",.F.)
						TRB->TF_COMIS += (zNewCom - zComs)
						MsUnLock()
					Endif
					zComs := IIf(mv_par07==1,TRB->TF_COMIS,zNewCom)
				Endif
			Endif
	
		Endif
		
	Endif // Vendedor2

	// Vendedor3
	lVend3Ok := .T.
	If Empty(SQE3->VEND3) .Or. (SQE3->VEND3 < mv_par03) .Or. (SQE3->VEND3 > mv_par04)
		lVend3Ok := .F.
	Endif

	If mv_par06 == 2 // Revenda = Não
		If Substr(SQE3->VEND3,1,1) == "R"
			lVend3Ok := .F.
		Endif
	Endif

	If lVend3Ok

		zBase := Round(SQE3->SALDO - (SQE3->(SALDO*(ALIQICM/100))),2)
		zPorc := SD2->D2_COMIS3
		zComs := Round(zBase * (zPorc/100),2)
	
		If zComs != 0
	
			If mv_par07 == 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := SQE3->FILIAL
				TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
				TRB->TF_VEND    := SQE3->VEND3
				TRB->TF_PREFIXO := SQE3->PREFIXO
				TRB->TF_NUM     := SQE3->NUM
				TRB->TF_PARCELA := SQE3->PARCELA
				TRB->TF_TIPO    := SQE3->TIPO
				TRB->TF_CLIENTE := SQE3->CLIENTE
				TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
				TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
				TRB->TF_VENCREA := StoD(SQE3->VENCREA)
				TRB->TF_PAGTO   := StoD("")
				TRB->TF_STATUS  := "AB"
				TRB->TF_BASE    := zBase
				TRB->TF_PORC    := zPorc
				TRB->TF_COMIS   := zComs
				TRB->TF_ZZCOMIS := zComs
				MsUnLock()
			Else
				aClas := _GetClas("C",Substr(SQE3->VEND3,1,1))
				zVend := aClas[1]
				zClas := aClas[2]
				zStat := "AB"
				DbSelectArea("TRB")
				DbSetOrder(1)
				If !DbSeek( zVend + zStat )
					RecLock("TRB",.T.)
					TRB->TF_VEND    := zVend
					TRB->TF_CLASSIF := zClas
					TRB->TF_STATUS  := zStat
				Else
					RecLock("TRB",.F.)
				Endif	
				TRB->TF_COMIS   += zComs
				TRB->TF_ZZCOMIS += zComs
				MsUnLock()
			Endif	
	
			If zModAtra == "2"
				zAtraso  := dDatabase - DataValida(StoD(SQE3->VENCORI),.T.)
			Else
				zAtraso  := dDatabase - StoD(SQE3->VENCREA)
			Endif	

			zPDescon := 0
			If zAtraso > 0
				If mv_par07 == 1
					RecLock("TRB",.F.)
					TRB->TF_ZZATRAS := zAtraso
					MsUnLock()
				Endif	
				If Substr(TRB->TF_VEND,1,1) == "R"
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
				If zAtraso >= 9999
					zAtraso := 9999
				Endif
				If zPDescon > 0
					RecLock("TRB",.F.)
					If mv_par07 == 1
						TRB->TF_ZZPDESC := zPDescon
					Endif	
					If zPDescon == 100
						If mv_par07 == 1
							TRB->TF_ZZVDESC := TRB->TF_COMIS
							TRB->TF_COMIS   := 0.00
						Else
							zNewCom := 0
						Endif	
					Else
						If mv_par07 == 1
							TRB->TF_ZZVDESC := (TRB->TF_COMIS * (zPDescon/100))
							TRB->TF_COMIS   := TRB->TF_COMIS - (TRB->TF_COMIS * (zPDescon/100))
						Else	
							zzVDesc := (zComs * (zPDescon/100))
							zNewCom := zComs - zzVDesc
						Endif	
					Endif	
					MsUnLock()
					If mv_par07 == 2
						RecLock("TRB",.F.)
						TRB->TF_COMIS += (zNewCom - zComs)
						MsUnLock()
					Endif
					zComs := IIf(mv_par07==1,TRB->TF_COMIS,zNewCom)
				Endif
			Endif
	
		Endif

		If Substr(SQE3->VEND3,1,1)!="R"
	
			If !Empty(SQE3->GEREN1) .And. (SQE3->GEREN1 >= mv_par03 .And. SQE3->GEREN1 <= mv_par04) .And. ((zComs * (zPorcG/100))) != 0
				If mv_par07 == 1
					RecLock("TRB",.T.)
					TRB->TF_FILIAL  := SQE3->FILIAL
					TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
					TRB->TF_VEND    := SQE3->GEREN1
					TRB->TF_PREFIXO := SQE3->PREFIXO
					TRB->TF_NUM     := SQE3->NUM
					TRB->TF_PARCELA := SQE3->PARCELA
					TRB->TF_TIPO    := SQE3->TIPO
					TRB->TF_CLIENTE := SQE3->CLIENTE
					TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
					TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
					TRB->TF_VENCREA := StoD(SQE3->VENCREA)
					TRB->TF_PAGTO   := StoD("")
					TRB->TF_STATUS  := "GA"
					TRB->TF_BASE    := zComs
					TRB->TF_PORC    := zPorcG
					TRB->TF_COMIS   := (zComs * (zPorcG/100))
					TRB->TF_ZZCOMIS := (zComs * (zPorcG/100))
					MsUnLock()
				Else
					aClas := _GetClas("A",Substr(SQE3->GEREN1,1,1))
					zVend := aClas[1]
					zClas := aClas[2]
					zStat := "AB"
					DbSelectArea("TRB")
					DbSetOrder(1)
					If !DbSeek( zVend + zStat )
						RecLock("TRB",.T.)
						TRB->TF_VEND    := zVend
						TRB->TF_CLASSIF := zClas
						TRB->TF_STATUS  := zStat
					Else
						RecLock("TRB",.F.)
					Endif	
					TRB->TF_COMIS   += (zComs * (zPorcG/100))
					TRB->TF_ZZCOMIS += (zComs * (zPorcG/100))
					MsUnLock()
				Endif	
			Endif
		
			If !Empty(SQE3->SUPER1) .And. (SQE3->SUPER1 >= mv_par03 .And. SQE3->SUPER1 <= mv_par04) .And. ((zComs * (zPorcD/100))) != 0
				If mv_par07 == 1
					RecLock("TRB",.T.)
					TRB->TF_FILIAL  := SQE3->FILIAL
					TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
					TRB->TF_VEND    := SQE3->SUPER1
					TRB->TF_PREFIXO := SQE3->PREFIXO
					TRB->TF_NUM     := SQE3->NUM
					TRB->TF_PARCELA := SQE3->PARCELA
					TRB->TF_TIPO    := SQE3->TIPO
					TRB->TF_CLIENTE := SQE3->CLIENTE
					TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
					TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
					TRB->TF_VENCREA := StoD(SQE3->VENCREA)
					TRB->TF_PAGTO   := StoD("")
					TRB->TF_STATUS  := "DA"
					TRB->TF_BASE    := zComs
					TRB->TF_PORC    := zPorcD
					TRB->TF_COMIS   := (zComs * (zPorcD/100))
					TRB->TF_ZZCOMIS := (zComs * (zPorcD/100))
					MsUnLock()
				Else
					aClas := _GetClas("A",Substr(SQE3->SUPER1,1,1))
					zVend := aClas[1]
					zClas := aClas[2]
					zStat := "AB"
					DbSelectArea("TRB")
					DbSetOrder(1)
					If !DbSeek( zVend + zStat )
						RecLock("TRB",.T.)
						TRB->TF_VEND    := zVend
						TRB->TF_CLASSIF := zClas
						TRB->TF_STATUS  := zStat
					Else
						RecLock("TRB",.F.)
					Endif	
					TRB->TF_COMIS   += (zComs * (zPorcD/100))
					TRB->TF_ZZCOMIS += (zComs * (zPorcD/100))
					MsUnLock()
				Endif	
			Endif
	
		Endif
		
	Endif // Vendedor3

	// Vendedor4
	lVend4Ok := .T.
	If Empty(SQE3->VEND4) .Or. (SQE3->VEND4 < mv_par03) .Or. (SQE3->VEND4 > mv_par04)
		lVend4Ok := .F.
	Endif

	If mv_par06 == 2 // Revenda = Não
		If Substr(SQE3->VEND4,1,1) == "R"
			lVend4Ok := .F.
		Endif
	Endif

	If lVend4Ok

		zBase := Round(SQE3->SALDO - (SQE3->(SALDO*(ALIQICM/100))),2)
		zPorc := SD2->D2_COMIS4
		zComs := Round(zBase * (zPorc/100),2)
	
		If zComs != 0
	
			If mv_par07 == 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := SQE3->FILIAL
				TRB->TF_ITEMCC  := RetField("SD2",3,SQE3->(FILIAL + NUM + PREFIXO + CLIENTE),"D2_ITEMCC")
				TRB->TF_VEND    := SQE3->VEND4
				TRB->TF_PREFIXO := SQE3->PREFIXO
				TRB->TF_NUM     := SQE3->NUM
				TRB->TF_PARCELA := SQE3->PARCELA
				TRB->TF_TIPO    := SQE3->TIPO
				TRB->TF_CLIENTE := SQE3->CLIENTE
				TRB->TF_EMISSAO := StoD(SQE3->EMISSAO)
				TRB->TF_VENCORI := DataValida(StoD(SQE3->VENCORI),.T.)
				TRB->TF_VENCREA := StoD(SQE3->VENCREA)
				TRB->TF_PAGTO   := StoD("")
				TRB->TF_STATUS  := "AB"
				TRB->TF_BASE    := zBase
				TRB->TF_PORC    := zPorc
				TRB->TF_COMIS   := zComs
				TRB->TF_ZZCOMIS := zComs
				MsUnLock()
			Else
				aClas := _GetClas("C",Substr(SQE3->VEND4,1,1))
				zVend := aClas[1]
				zClas := aClas[2]
				zStat := "AB"
				DbSelectArea("TRB")
				DbSetOrder(1)
				If !DbSeek( zVend + zStat )
					RecLock("TRB",.T.)
					TRB->TF_VEND    := zVend
					TRB->TF_CLASSIF := zClas
					TRB->TF_STATUS  := zStat
				Else
					RecLock("TRB",.F.)
				Endif	
				TRB->TF_COMIS   += zComs
				TRB->TF_ZZCOMIS += zComs
				MsUnLock()
			Endif	
	
			If zModAtra == "2"
				zAtraso  := dDatabase - DataValida(StoD(SQE3->VENCORI),.T.)
			Else
				zAtraso  := dDatabase - StoD(SQE3->VENCREA)
			Endif	

			zPDescon := 0
			If zAtraso > 0
				If mv_par07 == 1
					RecLock("TRB",.F.)
					TRB->TF_ZZATRAS := zAtraso
					MsUnLock()
				Endif	
				If Substr(TRB->TF_VEND,1,1) == "R"
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
				If zAtraso >= 9999
					zAtraso := 9999
				Endif
				If zPDescon > 0
					RecLock("TRB",.F.)
					If mv_par07 == 1
						TRB->TF_ZZPDESC := zPDescon
					Endif	
					If zPDescon == 100
						If mv_par07 == 1
							TRB->TF_ZZVDESC := TRB->TF_COMIS
							TRB->TF_COMIS   := 0.00
    					Else
							zNewCom := 0
						Endif	
					Else
						If mv_par07 == 1
							TRB->TF_ZZVDESC := (TRB->TF_COMIS * (zPDescon/100))
							TRB->TF_COMIS   := TRB->TF_COMIS - (TRB->TF_COMIS * (zPDescon/100))
						Else	
							zzVDesc := (zComs * (zPDescon/100))
							zNewCom := zComs - zzVDesc
						Endif	
					Endif	
					MsUnLock()
					If mv_par07 == 2
						RecLock("TRB",.F.)
						TRB->TF_COMIS += (zNewCom - zComs)
						MsUnLock()
					Endif
					zComs := IIf(mv_par07==1,TRB->TF_COMIS,zNewCom)
				Endif
			Endif
	
		Endif
		
	Endif // Vendedor4

	DbSelectArea("SQE3")
	SQE3->(DbSkip())
Enddo
SQE3->(DbCloseArea())

// 3.Negociação
// 3.1 - Negociações
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_VENCREA <= '"+DtoS(mv_par02)+"' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_NUMLIQ <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)
nTotSql := SQE3->SOMA
SQE3->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_VENCREA <= '"+DtoS(mv_par02)+"' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_NUMLIQ <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)

DbSelectArea("SQE3")
ProcRegua(nTotSql)
SQE3->(DbGotop())
While !Eof()

	oProcess:IncRegua1("Negociações em aberto..")

	DbSelectArea("SE1")
	SE1->(DbGoto(SQE3->R_E_C_N_O_))
	dDatPag := IIf(SE1->E1_VENCREA >= dDatabase, SE1->E1_VENCREA, dDatabase)

	zFilial := SE1->E1_FILIAL
	If !Empty(SE1->E1_ZFILINC)
		zFilial := SE1->E1_ZFILINC
	Endif

	cFilAnt := SE1->E1_FILIAL
	DbSelectArea("FI7")
	DbSetOrder(2)
	If DbSeek( zFilial + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
		nBxLiqui := SE1->E1_SALDO
		zValNego := u_TotNego(zFilial,SE1->E1_NUMLIQ)
		nFatorBx := (nBxLiqui / zValNego)
		aNfNegoc := u_NfNegoc(zFilial,SE1->E1_NUMLIQ,nBxLiqui,SE1->E1_ZFILINC,@nFatorBx,dDatPag)
		zAcordo  := SE1->( AllTrim(E1_PREFIXO)+"-"+AllTrim(E1_NUM)+"-"+AllTrim(E1_PARCELA))
		If Len(aNfNegoc) > 0
			u_PrjCmsLq(aNfNegoc,nBxLiqui,nFatorBx,SE1->E1_VENCREA,zAcordo,SE1->E1_SALDO,zFilial)
		Endif	
	Endif

	DbSelectArea("SQE3")
	SQE3->(DbSkip())
Enddo
SQE3->(DbCloseArea())

// 3.2 - Acordos
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_VENCREA <= '"+DtoS(mv_par02)+"' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_PREFIXO = 'ACO' "
cQuery += " AND E1_ZZACORD <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)
nTotSql := SQE3->SOMA
SQE3->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_VENCREA <= '"+DtoS(mv_par02)+"' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_PREFIXO = 'ACO' "
cQuery += " AND E1_ZZACORD <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE3", .F., .T.)

DbSelectArea("SQE3")
ProcRegua(nTotSql)
SQE3->(DbGotop())
While !Eof()

	oProcess:IncRegua1("Acordos em aberto..")

	DbSelectArea("SE1")
	SE1->(DbGoto(SQE3->R_E_C_N_O_))

	zFilial := SE1->E1_FILIAL
	If !Empty(SE1->E1_ZFILINC)
		zFilial := SE1->E1_ZFILINC
	Endif

	cFilAnt := SE1->E1_FILIAL
	DbSelectArea("Z01")
	DbSetOrder(1)
	If DbSeek( zFilial + SE1->E1_NUM )
		nBxLiqui := SE1->E1_SALDO
		nFatorBx := (nBxLiqui / Z01->Z01_VALNEG)
		aNfAcord := u_NfAcord(zFilial,Z01->Z01_ACORDO,nBxLiqui,SE1->E1_ZFILINC)
		zAcordo  := SE1->( AllTrim(E1_PREFIXO)+"-"+AllTrim(E1_NUM)+"-"+AllTrim(E1_PARCELA))
		If Len(aNfAcord) > 0
			u_PrjCmsLq(aNfAcord,nBxLiqui,nFatorBx,SE1->E1_VENCREA,zAcordo,SE1->E1_SALDO,zFilial)
		Endif	
	Endif

	DbSelectArea("SQE3")
	SQE3->(DbSkip())
Enddo
SQE3->(DbCloseArea())
cFilAnt := cFilBkp

// 4.Impressão
DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SE3_PROJCOM"
	If mv_par07 == 1
		cNomeTable := "Projeção de Comissões - Visão Detalhada"
	Else
		cNomeTable := "Projeção de Comissões - Visão Resumida"
	Endif	
	
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	If mv_par07 == 1
		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Neg.",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Título",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Seq.",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Venc.Orig",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Venc.Real",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Pagamento",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Base Comis.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"%Comis.",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Comis.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Status",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Comiss.Orig.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Dias Atraso",3,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"% Desc.Atras",3,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Desc.Atr",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"No.Acordo",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Pago",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.Acordo",1,4)
	Else
		oExcel:AddColumn(cNomePlan,cNomeTable,"Classificação",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Comis.c/Desc.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Comis.s/Desc.",3,3)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Status",1,1)
	Endif	

	While !Eof()

		oProcess:IncRegua2("Gerando planilha...")

		If mv_par07 == 1

			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + TRB->TF_VEND )
	
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + TRB->TF_CLIENTE )
	
			zLocal  := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
	
			zStatus := ""
			If TRB->TF_STATUS=="AB"
				zStatus := "Em Aberto"
			ElseIf TRB->TF_STATUS=="BX"
				zStatus := "Baixado"
			ElseIf TRB->TF_STATUS=="GA"
				zStatus := "Ger.em Aberto"
			ElseIf TRB->TF_STATUS=="DA"
				zStatus := "Dir.em Aberto"
			ElseIf TRB->TF_STATUS=="GB"
				zStatus := "Ger.Baixado"
			ElseIf TRB->TF_STATUS=="DB"
				zStatus := "Dir.Baixado"
			Endif
	
			oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_FILIAL, zLocal, TRB->TF_ITEMCC, TRB->TF_VEND, SA3->A3_NOME, TRB->TF_PREFIXO, TRB->TF_NUM,;
			 									  TRB->TF_PARCELA, TRB->TF_TIPO, TRB->TF_SEQ, SA1->A1_COD, SA1->A1_NOME, TRB->TF_EMISSAO,;
			 									  TRB->TF_VENCORI, TRB->TF_VENCREA, TRB->TF_PAGTO, TRB->TF_BASE, TRB->TF_PORC, TRB->TF_COMIS,;
			 									  zStatus, TRB->TF_ZZCOMIS, TRB->TF_ZZATRAS, TRB->TF_ZZPDESC, TRB->TF_ZZVDESC, TRB->TF_ZZACORD,;
			 									  TRB->TF_ZVLPAGO, TRB->TF_ZVENACO })

		Else

			zStatus := ""
			If TRB->TF_STATUS=="AB"
				zStatus := "Em Aberto"
			ElseIf TRB->TF_STATUS=="BX"
				zStatus := "Baixado"
			Endif
	
			oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_CLASSIF, TRB->TF_COMIS, TRB->TF_ZZCOMIS, zStatus })
		
		Endif
		
		DbSelectArea("TRB")
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE3_PROJCOM-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
TRB->(DbCloseArea())
oTempTable:Delete()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PrjCmsLq ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  12/11/18	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Projeção da comissão dos títulos acordados/negociados.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PrjCmsLq(aTitComs,nBxLiqui,nFatorBx,dVencNeg,zAcordo,zVlrNeg,zFilial)

Local aArea    := GetArea()
Local nBxAcumu := 0
Local zPorcG   := GetMv("ZZ_PERCGER")
Local zPorcD   := GetMv("ZZ_PERCDIR")
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
	zVend3   := aTitComs[_x][19]
	zVend4   := aTitComs[_x][20]
	zComis3  := aTitComs[_x][21]
	zComis4  := aTitComs[_x][22]
	zGeren3  := IIf(Substr(zVend3,1,1)=="V",zGeren1,"")
	zSuper3  := IIf(Substr(zVend3,1,1)=="V",zSuper1,"")
	zGeren4  := ""
	zSuper4  := ""
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

	zFilTit := SE1->E1_FILIAL
	If !Empty(SE1->E1_ZFILINC)
		zFilTit := SE1->E1_ZFILINC
	Endif
	//
	dDatVenc := IIf(dVencNeg > dDatabase, dVencNeg, dDatabase) // Neg vencida, considero database.
	If zModAtra == "2"
		zDiasAtr := IIf(dDatVenc > DataValida(SE1->E1_VENCORI,.T.), dDatVenc - DataValida(SE1->E1_VENCORI,.T.), 0)
	Else
		zDiasAtr := IIf(dDatVenc > SE1->E1_VENCREA, dDatVenc - SE1->E1_VENCREA, 0)
	Endif
	zBaseCom := zValor - (zValor * (zIcms/100))				
	//
	For _y := 1 to 4

		zVend   := &("zVend"+AllTrim(STR(_y)))
		zGeren  := &("zGeren"+AllTrim(STR(_y)))
		zSuper  := &("zSuper"+AllTrim(STR(_y)))
		zPorc   := &("zComis"+AllTrim(STR(_y)))
		zAtraso := zDiasAtr
		zComiss := (zBaseCom * (zPorc/100))

		If mv_par06 == 2 // Revenda = Não
			If Substr(zVend,1,1) == "R"
				Loop
			Endif
		Endif

		If !Empty(zVend) .And. zComiss != 0 .And. (zVend >= mv_par03 .And. zVend <= mv_par04)

			If mv_par07 == 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->TF_FILIAL  := cFilAnt
				TRB->TF_ITEMCC  := RetField("SD2",3,zFilTit + zNumero + zPrefixo + SE1->E1_CLIENTE,"D2_ITEMCC")
				TRB->TF_VEND    := zVend
				TRB->TF_PREFIXO := zPrefixo
				TRB->TF_NUM     := zNumero
				TRB->TF_PARCELA := zParcela
				TRB->TF_TIPO    := zTipo
				TRB->TF_CLIENTE := SE1->E1_CLIENTE
				TRB->TF_EMISSAO := SE1->E1_EMISSAO
				TRB->TF_VENCORI := DataValida(SE1->E1_VENCORI,.T.)
				TRB->TF_VENCREA := SE1->E1_VENCREA
				TRB->TF_PAGTO   := StoD("")
				TRB->TF_STATUS  := "AB"
				TRB->TF_BASE    := zBaseCom
				TRB->TF_PORC    := zPorc
				TRB->TF_COMIS   := zComiss
				TRB->TF_ZZCOMIS := zComiss
				TRB->TF_ZZACORD := zAcordo
				TRB->TF_ZVLPAGO := zVlrNeg
				TRB->TF_ZVENACO := dVencNeg
				MsUnLock()
			Else
				aClas := _GetClas("C",Substr(zVend,1,1))
				zVend := aClas[1]
				zClas := aClas[2]
				zStat := "AB"
				DbSelectArea("TRB")
				DbSetOrder(1)
				If !DbSeek( zVend + zStat )
					RecLock("TRB",.T.)
					TRB->TF_VEND    := zVend
					TRB->TF_CLASSIF := zClas
					TRB->TF_STATUS  := zStat
				Else
					RecLock("TRB",.F.)
				Endif	
				TRB->TF_COMIS   += zComiss
				TRB->TF_ZZCOMIS += zComiss
				MsUnLock()
			Endif	

			If zAtraso >= 9999
				zAtraso := 9999
			Endif

			If zAtraso > 0

				If mv_par07 == 1
					RecLock("TRB",.F.)
					TRB->TF_ZZATRAS := zAtraso
					MsUnLock()
				Endif	

				zPDescon := 0
				If Substr(zVend,1,1) == "R" // Revenda
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
					RecLock("TRB",.F.)
					If mv_par07 == 1
						TRB->TF_ZZPDESC := zPDescon
					Endif	
					If zPDescon == 100
						If mv_par07 == 1
							TRB->TF_ZZVDESC := TRB->TF_COMIS
							TRB->TF_COMIS   := 0.00
    					Else
							zNewCom := 0
						Endif	
					Else
						If mv_par07 == 1
							TRB->TF_ZZVDESC := (TRB->TF_COMIS * (zPDescon/100))
							TRB->TF_COMIS   := TRB->TF_COMIS - (TRB->TF_COMIS * (zPDescon/100))
						Else
							zzVDesc := (zComiss * (zPDescon/100))
							zNewCom := zComiss - zzVDesc
						Endif	
					Endif	
					MsUnLock()
					If mv_par07 == 2
						RecLock("TRB",.F.)
						TRB->TF_COMIS += (zNewCom - zComiss)
						MsUnLock()
					Endif
					zComiss := IIf(mv_par07==1,TRB->TF_COMIS,zNewCom)
				Endif

			Endif

			If Substr(zVend,1,1)!="R"
			
				If !Empty(zGeren) .And. (zGeren >= mv_par03 .And. zGeren <= mv_par04) .And. ((zComiss * (zPorcG/100))) != 0
					If mv_par07 == 1
						RecLock("TRB",.T.)
						TRB->TF_FILIAL  := cFilAnt
						TRB->TF_ITEMCC  := RetField("SD2",3,zFilTit + zNumero + zPrefixo + SE1->E1_CLIENTE,"D2_ITEMCC")
						TRB->TF_VEND    := zGeren
						TRB->TF_PREFIXO := zPrefixo
						TRB->TF_NUM     := zNumero
						TRB->TF_PARCELA := zParcela
						TRB->TF_TIPO    := zTipo
						TRB->TF_CLIENTE := SE1->E1_CLIENTE
						TRB->TF_EMISSAO := SE1->E1_EMISSAO
						TRB->TF_VENCORI := DataValida(SE1->E1_VENCORI,.T.)
						TRB->TF_VENCREA := SE1->E1_VENCREA
						TRB->TF_PAGTO   := StoD("")
						TRB->TF_STATUS  := "GA"
						TRB->TF_BASE    := zComiss
						TRB->TF_PORC    := zPorcG
						TRB->TF_COMIS   := (zComiss * (zPorcG/100))
						TRB->TF_ZZCOMIS := (zComiss * (zPorcG/100))
						MsUnLock()
					Else
						aClas := _GetClas("A",Substr(zGeren,1,1))
						zVend := aClas[1]
						zClas := aClas[2]
						zStat := "AB"
						DbSelectArea("TRB")
						DbSetOrder(1)
						If !DbSeek( zVend + zStat )
							RecLock("TRB",.T.)
							TRB->TF_VEND    := zVend
							TRB->TF_CLASSIF := zClas
							TRB->TF_STATUS  := zStat
						Else
							RecLock("TRB",.F.)
						Endif	
						TRB->TF_COMIS   += (zComiss * (zPorcG/100))
						TRB->TF_ZZCOMIS += (zComiss * (zPorcG/100))
						MsUnLock()
					Endif	
				Endif

				If !Empty(zSuper) .And. (zSuper >= mv_par03 .And. zSuper <= mv_par04) .And. ((zComiss * (zPorcD/100))) != 0
					If mv_par07 == 1
						RecLock("TRB",.T.)
						TRB->TF_FILIAL  := cFilAnt
						TRB->TF_ITEMCC  := RetField("SD2",3,zFilTit + zNumero + zPrefixo + SE1->E1_CLIENTE,"D2_ITEMCC")
						TRB->TF_VEND    := zSuper
						TRB->TF_PREFIXO := zPrefixo
						TRB->TF_NUM     := zNumero
						TRB->TF_PARCELA := zParcela
						TRB->TF_TIPO    := zTipo
						TRB->TF_CLIENTE := SE1->E1_CLIENTE
						TRB->TF_EMISSAO := SE1->E1_EMISSAO
						TRB->TF_VENCORI := DataValida(SE1->E1_VENCORI,.T.)
						TRB->TF_VENCREA := SE1->E1_VENCREA
						TRB->TF_PAGTO   := StoD("")
						TRB->TF_STATUS  := "DA"
						TRB->TF_BASE    := zComiss
						TRB->TF_PORC    := zPorcD
						TRB->TF_COMIS   := (zComiss * (zPorcD/100))
						TRB->TF_ZZCOMIS := (zComiss * (zPorcD/100))
						MsUnLock()
					Else
						aClas := _GetClas("A",Substr(zSuper,1,1))
						zVend := aClas[1]
						zClas := aClas[2]
						zStat := "AB"
						DbSelectArea("TRB")
						DbSetOrder(1)
						If !DbSeek( zVend + zStat )
							RecLock("TRB",.T.)
							TRB->TF_VEND    := zVend
							TRB->TF_CLASSIF := zClas
							TRB->TF_STATUS  := zStat
						Else
							RecLock("TRB",.F.)
						Endif	
						TRB->TF_COMIS   += (zComiss * (zPorcD/100))
						TRB->TF_ZZCOMIS += (zComiss * (zPorcD/100))
						MsUnLock()
					Endif	
				Endif

			Endif

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
¦¦¦Função    ¦ Fa440AbeSe1 ¦ Autor ¦ Fábrica ERPBR  ¦    Data  ¦ 09/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Fa440AbeSe1(zNumLiq,aLiquid,aValLiq)

Local aArea   := GetArea()
Local nRecSe1 := SE1->(Recno())

cQuery := " SELECT E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIENTE, E5_LOJA "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+cFilAnt+"' "
cQuery += " AND E5_DOCUMEN = '"+zNumLiq+"' " 
cQuery += " AND E5_MOTBX = 'LIQ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TNEG", .F., .T.)

DbSelectArea("TNEG")
TNEG->(DbGotop())
While !Eof()

	DbSelectArea("SE1")
	DbSetOrder(1)
	If DbSeek( TNEG->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIENTE+E5_LOJA) )
		AAdd(aLiquid,SE1->(Recno()))
		AAdd(aValLiq,{SE1->(Recno()),SE1->(E1_VALOR-E1_SALDO)}) // Saldo em Aberto
	Endif
	
	DbSelectArea("TNEG")
	TNEG->(DbSkip())
Enddo
TNEG->(DbCloseArea())

SE1->(DbGoto(nRecSe1))
RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ TrabProj  ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 08/01/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function TrabProj()

Local _aTmp := {}
Local zAlias := "TRB"

If Select("TRB") > 0
	TRB->(DbCloseArea())
Endif

oTempTable := FWTemporaryTable():New( zAlias )

If mv_par07 == 1

	AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
	AAdd ( _aTmp, {"TF_VEND"    , "C", 006, 00} )
	AAdd ( _aTmp, {"TF_PREFIXO" , "C", 003, 00} )
	AAdd ( _aTmp, {"TF_NUM"     , "C", 009, 00} )
	AAdd ( _aTmp, {"TF_PARCELA" , "C", 002, 00} )
	AAdd ( _aTmp, {"TF_TIPO"    , "C", 003, 00} )
	AAdd ( _aTmp, {"TF_SEQ"     , "C", 002, 00} )
	AAdd ( _aTmp, {"TF_CLIENTE" , "C", 006, 00} )
	AAdd ( _aTmp, {"TF_EMISSAO" , "D", 008, 00} )
	AAdd ( _aTmp, {"TF_VENCORI" , "D", 008, 00} )
	AAdd ( _aTmp, {"TF_VENCREA" , "D", 008, 00} )
	AAdd ( _aTmp, {"TF_PAGTO"   , "D", 008, 00} )
	AAdd ( _aTmp, {"TF_STATUS"  , "C", 002, 00} )
	AAdd ( _aTmp, {"TF_BASE"    , "N", 017, 02} )
	AAdd ( _aTmp, {"TF_PORC"    , "N", 006, 02} )
	AAdd ( _aTmp, {"TF_COMIS"   , "N", 011, 02} )
	AAdd ( _aTmp, {"TF_ZZCOMIS" , "N", 011, 02} )
	AAdd ( _aTmp, {"TF_ZZATRAS" , "N", 009, 00} )
	AAdd ( _aTmp, {"TF_ZZPDESC" , "N", 006, 02} )
	AAdd ( _aTmp, {"TF_ZZVDESC" , "N", 011, 02} )
	AAdd ( _aTmp, {"TF_ZZACORD" , "C", 016, 00} )
	AAdd ( _aTmp, {"TF_ZVLPAGO" , "N", 017, 02} )
	AAdd ( _aTmp, {"TF_ZVENACO" , "D", 008, 00} )
	AAdd ( _aTmp, {"TF_ITEMCC"  , "C", 012, 00} )
	
	oTemptable:SetFields( _aTmp )
	oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_VEND", "TF_PREFIXO", "TF_NUM", "TF_PARCELA", "TF_TIPO", "TF_SEQ"})
	oTempTable:Create()

Else

	AAdd ( _aTmp, {"TF_VEND"    , "C", 006, 00} )
	AAdd ( _aTmp, {"TF_CLASSIF" , "C", 020, 00} )
	AAdd ( _aTmp, {"TF_STATUS"  , "C", 002, 00} )
	AAdd ( _aTmp, {"TF_COMIS"   , "N", 011, 02} )
	AAdd ( _aTmp, {"TF_ZZCOMIS" , "N", 011, 02} )
	
	oTemptable:SetFields( _aTmp )
	oTempTable:AddIndex("indice1", {"TF_VEND", "TF_STATUS"})
	oTempTable:Create()

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _GetClas ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  25/03/19	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Classifica a comissão.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _GetClas(xTipo,xClas)

Local aRet := {}

AAdd(aRet,"999999")
AAdd(aRet,"NÃO CLASSIFICADO")

If xClas == "V"
	aRet[1] := "A01RTV"
	aRet[2] := "RTV"
ElseIf xClas == "G"
	If xTipo == "C"
		aRet[1] := "A02GRT"
		aRet[2] := "GERENTE->RTV"
	Else
		aRet[1] := "A04GER"
		aRet[2] := "GERENTE"
	Endif	
ElseIf xClas == "D"
	If xTipo == "C"
		aRet[1] := "A03DRT"
		aRet[2] := "DIRETOR->RTV"
	Else
		aRet[1] := "A05DIR"
		aRet[2] := "DIRETOR"
	Endif	
ElseIf xClas == "R"
	aRet[1] := "R06REV"
	aRet[2] := "REVENDA"
Endif	

Return(aRet)
