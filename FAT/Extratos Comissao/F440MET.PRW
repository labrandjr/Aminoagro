#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F440MET   ¦ Autor ¦  Fábrica ERP.BR   ¦ Data  ¦ 20/12/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento para cálculo das metas de comissões.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F440MET()

Local cPerg	:= Padr("F440MET",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private cUsrComl := "000000,"+AllTrim(GetMv("MV_ZUSCOML"))
Private oDlgUpd, oProcess, cArqCtb

If !(__cUserId $ cUsrComl)
	MsgAlert("Usuário não autorizado a executar essa rotina: MV_ZUSCOML")
	Return
Endif

If DtoS(Date()) >= "20220101"
	MsgAlert("Processo descontinuado. Utilize a importação das metas via CSV.")
	Return
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Apuração das Metas em Comissões" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,100,{||"APURAÇÃO DAS METAS EM COMISSÕES"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo apurar as metas dos RTV´s no exercício anual e aplicar"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"o resultado no valor de comissão à receber."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
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
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/12/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento - APURAÇÃO DE METAS ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Calculando metas para comissões", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ 20/12/2020  ¦¦¦
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
Local zAno       := Substr(DtoS(mv_par01),1,4)
Local zCfAdmv    := FormatIn( AllTrim(GetMv("MV_XCFADMV")), ",")

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

// 1. Apuração das Metas x Faturamento
// Em 2020 foi o primeiro período de apuração das metas, e o resultado foi importado via CSV elaborado pela Sandra - 12/01/2021.
// Metas
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SCT")
cQuery += " WHERE CT_FILIAL = '"+xFilial("SCT")+"' "
cQuery += " AND SUBSTR(CT_DATA,1,4) = '"+zAno+"' "
cQuery += " AND SUBSTR(CT_VEND,1,1) <> 'R' "
cQuery += " AND CT_VEND <> ' ' "
cQuery += " AND CT_MSBLQL <> '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

cQuery := " SELECT CT_VEND, SUM(CT_VALOR) AS CT_VALOR "
cQuery += " FROM "+RetSqlName("SCT")
cQuery += " WHERE CT_FILIAL = '"+xFilial("SCT")+"' "
cQuery += " AND SUBSTR(CT_DATA,1,4) = '"+zAno+"' "
cQuery += " AND SUBSTR(CT_VEND,1,1) <> 'R' "
cQuery += " AND CT_VEND <> ' ' "
cQuery += " AND CT_MSBLQL <> '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY CT_VEND "
cQuery += " ORDER BY CT_VEND "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

oProcess:SetRegua1(nTotSql)
DbSelectArea("SQL")
SQL->(DbGotop())
While !Eof()

	lProcOk := .T.
	oProcess:IncRegua1("Calculando metas...")

	DbSelectArea("SZS")
	DbSetOrder(1)
	If !DbSeek( xFilial("SZS") + SQL->CT_VEND + zAno )
		RecLock("SZS",.T.)
		SZS->ZS_FILIAL := xFilial("SZS")
		SZS->ZS_VEND   := SQL->CT_VEND
		SZS->ZS_ANO    := zAno
	Else
		RecLock("SZS",.F.)
	Endif
	SZS->ZS_VLMETA := SQL->CT_VALOR
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

// Faturamento
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL IN("+zFiliais+") "
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
cQuery += " AND SUBSTR(D2_EMISSAO,1,4) = '"+zAno+"' "
cQuery += " AND SUBSTR(F2_VEND1,1,1) <> 'R' "
cQuery += " AND F2_VEND1 <> ' ' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND B1_TIPO <> 'SV' "
cQuery += " AND D2_CF IN"+zCfAdmv
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
nTotSql := SQL2->SOMA
SQL2->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT F2_VEND1, SUM(D2_TOTAL+D2_SEGURO+D2_VALFRE) D2_TOTAL "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL IN("+zFiliais+") "
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
cQuery += " AND SUBSTR(D2_EMISSAO,1,4) = '"+zAno+"' "
cQuery += " AND SUBSTR(F2_VEND1,1,1) <> 'R' "
cQuery += " AND F2_VEND1 <> ' ' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND B1_TIPO <> 'SV' "
cQuery += " AND D2_CF IN"+zCfAdmv
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY F2_VEND1 "
cQuery += " ORDER BY F2_VEND1 "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

oProcess:SetRegua2(nTotSql)
DbSelectArea("SQL2")
SQL2->(DbGotop())
While !Eof()

	lProcOk := .T.
	oProcess:IncRegua2("Calculando faturamento...")

	DbSelectArea("SZS")
	DbSetOrder(1)
	If DbSeek( xFilial("SZS") + SQL2->F2_VEND1 + zAno )
		zPerc := ((SQL2->D2_TOTAL / SZS->ZS_VLMETA) * 100)
		If zPerc > 9999
			zPerc := 9999 // Para não haver estouro de campo
		Endif
		RecLock("SZS",.F.)
		SZS->ZS_VLFAT := SQL2->D2_TOTAL
		SZS->ZS_PERC  := zPerc
		MsUnLock()
	Endif	

	DbSelectArea("SQL2")
	SQL2->(DbSkip())
Enddo
SQL2->(DbCloseArea())

// 2. Aplicação do desconto nas notas fiscais não pagas
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE3")
cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND SUBSTR(E3_VEND,1,1) <> 'R' "
cQuery += " AND E3_ZZRTV = ' ' "
cQuery += " AND E3_DATA = ' ' "
cQuery += " AND E3_TIPO <> 'NCC' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
nTotSql := SQL3->SOMA
SQL3->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE3")
cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND SUBSTR(E3_VEND,1,1) <> 'R' "
cQuery += " AND E3_ZZRTV = ' ' "
cQuery += " AND E3_DATA = ' ' "
cQuery += " AND E3_TIPO <> 'NCC' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E3_VEND, E3_FILIAL, E3_EMISSAO, E3_PREFIXO, E3_NUM, E3_PARCELA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

oProcess:SetRegua2(nTotSql)
DbSelectArea("SQL3")
SQL3->(DbGotop())
While !Eof()

	lProcOk := .T.
	oProcess:IncRegua2("Notas Fiscais não pagas...")

	DbSelectArea("SE3")
	SE3->(DbGoto(SQL3->R_E_C_N_O_))

	DbSelectArea("SE1")
	DbSetOrder(2)
	If DbSeek( SE3->(E3_FILIAL+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO) )

		If Year(SE1->E1_EMISSAO) >= 2020

			zAnoEm := Substr(DtoS(SE1->E1_EMISSAO),1,4)
			zPMeta := u_GetPMeta(SE3->E3_VEND,zAnoEm)
			
			If Empty(SE3->E3_MTCOMIS)
				RecLock("SE3",.F.)
				SE3->E3_MTCOMIS := SE3->E3_COMIS // Armazena valor da comissão calculado antes de checar metas
				SE3->E3_MTPMETA := zPMeta
				SE3->E3_COMIS   := (SE3->E3_COMIS * (zPMeta/100))
				MsUnLock()
			Else
				If SE3->E3_MTPMETA <> zPMeta
					RecLock("SE3",.F.)
					SE3->E3_MTPMETA := zPMeta
					SE3->E3_COMIS   := (SE3->E3_MTCOMIS * (zPMeta/100))
					MsUnLock()
				Endif
			Endif	

		Endif

	Endif

	DbSelectArea("SQL3")
	SQL3->(DbSkip())
Enddo
SQL3->(DbCloseArea())

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
¦¦¦Programa  ¦ GetPMeta  ¦ Autor ¦  Fábrica ERP.BR   ¦ Data  ¦ 20/12/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calucula % desconto baseado na meta apurada.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GetPMeta(zVend,zAno)

Local aArea  := GetArea()
Local zPMeta := 0

DbSelectArea("SZS")
DbSetOrder(1)
If DbSeek( xFilial("SZS") + zVend + zAno )
	zPMeta := SZS->ZS_PERC
	If zPMeta < 70
		zPMeta := 0
	ElseIf zPMeta >= 95 //.And. zAno $("2020,2021")
		zPMeta := 100
	ElseIf zPMeta > 100
		zPMeta := 100
	Endif
Else
	zPMeta := 100
Endif	

RestArea(aArea)

Return(zPMeta)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GrvDMeta ¦ Autor ¦  Fábrica ERP.BR   ¦ Data  ¦ 20/12/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação do desconto apurado nas comissões pagas.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
/*
User Function GrvDMeta(zVend,zTComis)

Local aArea := GetArea()

zAno    := Substr(DtoS(mv_par01),1,4)
zPMeta  := u_GetPMeta(zVend,zAno)
zFilial := "0101"
zSerie  := "DMT"
zDoc    := "METPG"+zAno

If zPMeta < 100
	DbSelectArea("SE3")
	DbSetOrder(1)
	If !DbSeek( zFilial + zSerie + zDoc + Space(2) + Space(2) + zVend )
		RecLock("SE3",.T.)
		SE3->E3_FILIAL  := zFilial
		SE3->E3_PREFIXO := zSerie
		SE3->E3_NUM     := zDoc
		SE3->E3_PARCELA := Space(2)
		SE3->E3_SEQ     := Space(2)
		SE3->E3_VEND    := zVend
	Else
		RecLock("SE3",.F.)
	Endif	
	SE3->E3_TIPO    := "DMT"
	SE3->E3_EMISSAO := StoD(zAno+"1231")
	SE3->E3_SERIE   := zSerie
	SE3->E3_CODCLI  := "000001"
	SE3->E3_LOJA    := "01"
	SE3->E3_BASE    := zTComis *-1
	If zPMeta == 0
		SE3->E3_PORC  := 100
		SE3->E3_COMIS := zTComis *-1
	Else
		SE3->E3_PORC  := (100 - zPMeta)
		SE3->E3_COMIS := (zTComis * (SE3->E3_PORC/100)) *-1
	Endif
	SE3->E3_BAIEMI  := "B"
	SE3->E3_ORIGEM  := "B"
	SE3->E3_VENCTO  := StoD(zAno+"1231")
	SE3->E3_MOEDA   := "01"
	SE3->E3_SDOC    := zSerie
	SE3->E3_ZZCOMIS := SE3->E3_COMIS
	MsUnLock()
Else
	DbSelectArea("SE3")
	DbSetOrder(1)
	If DbSeek( zFilial + zSerie + zDoc + Space(2) + Space(2) + zVend )
		RecLock("SE3",.F.)
		DbDelete()
		MsUnLock()
	Endif
Endif

RestArea(aArea)

Return
*/
