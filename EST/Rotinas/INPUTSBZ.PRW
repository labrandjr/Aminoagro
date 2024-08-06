#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ INPUTSBZ ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 27/02/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Inclusão de produtos em Indicadores.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function INPUTSBZ()

Local cPerg	:= Padr("INPUTSBZ",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

If __cUserId != "000000"
//	MsgAlert("Usuário não autorizado.")
//	Return
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Inclusão de produtos em Indicadores" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,090,{||"CADASTRO AUTOMÁTICO DE INDICADORES"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo cadastrar produtos em Indicadores"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"a partir dos parâmetros informados."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"Produtos com Tipo = PA e MP."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"Processo de Endereçamento."},oDlgUpd,,oFnt2,,,,.T.,CLR_RED,CLR_WHITE,300,020)
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
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  27/02/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento - CADASTRO DE INDICADORES ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando inclusão de indicadores", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  27/02/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nForFilial

aFilsCalc := MatFilCalc( mv_par03 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]

		cFilAnt := aFilsCalc[nForFilial][2]

		ProcRegua(2)
		
 		IncProc("Selecionando registros...")
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SB1")
		cQuery += " WHERE B1_TIPO IN('PA','MP') "
		cQuery += " AND B1_MSBLQL <> '1' "
		cQuery += " AND B1_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " AND B1_COD NOT IN "
		cQuery += " (SELECT BZ_COD FROM "+RetSqlName("SBZ")+" WHERE BZ_FILIAL = '"+cFilAnt+"' AND D_E_L_E_T_ <> '*')
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQB1", .F., .T.)
		nTotSql := SQB1->SOMA
		SQB1->(DbCloseArea())

 		IncProc("Selecionando registros...")
		cQuery := " SELECT R_E_C_N_O_ RECSB1 "
		cQuery += " FROM "+RetSqlName("SB1")
		cQuery += " WHERE B1_TIPO IN('PA','MP') "
		cQuery += " AND B1_MSBLQL <> '1' "
		cQuery += " AND B1_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " AND B1_COD NOT IN "
		cQuery += " (SELECT BZ_COD FROM "+RetSqlName("SBZ")+" WHERE BZ_FILIAL = '"+cFilAnt+"' AND D_E_L_E_T_ <> '*')
		cQuery += " ORDER BY R_E_C_N_O_ "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQB1", .F., .T.)

		DbSelectArea("SQB1")
		ProcRegua(nTotSql)
		SQB1->(DbGotop())
		While !Eof()
		
			oProcess:IncRegua1("Cadastrando Indicadores...")

			DbSelectArea("SB1")
			SB1->(DbGoto(SQB1->RECSB1))

			DbSelectArea("SBZ")
			DbSetOrder(1)
			If !DbSeek( cFilAnt + SB1->B1_COD )
		
				aCab := {}
		        lMsErroAuto := .F.
		        zLocaliz := IIf(cFilAnt=="0102","S","N")
		        
		        AAdd(aCab,{"BZ_COD"     , SB1->B1_COD   , Nil})
		        AAdd(aCab,{"BZ_LOCPAD"  , SB1->B1_LOCPAD, Nil})
		        AAdd(aCab,{"BZ_ZZDESC"  , SB1->B1_DESC  , Nil})
		        AAdd(aCab,{"BZ_LOCALIZ" , zLocaliz      , Nil})
		
		        MsExecAuto({|v,x| MATA018(v,x)},aCab,3)
		        If lMsErroAuto
		            MsgAlert("Erro na atualização de Indicadores: "+SB1->B1_COD)
			        MostraErro()
		        Endif
		
			Endif

			DbSelectArea("SQB1")
			SQB1->(DbSkip())
		Enddo
		SQB1->(DbCloseArea())

	Endif	
Next nForFilial

MsgInfo("Processo concluído !!!")

Return
