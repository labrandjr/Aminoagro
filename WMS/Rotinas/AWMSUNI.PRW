#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AWMSUNI   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 16/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Unificação dos Armazéns 04 e 09 no SIGAWMS.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AWMSUNI()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("AWMS001",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.F.)
Private lOkFile  := .F.
Private lInteWms := GetMv("MV_INTWMS")
Private cEOL     := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Unificação de Armazéns - Sequência de Abastecimento" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,050,{||"UNIFICAÇÃO DE ARMAZÉNS - SEQUÊNCIA DE ABASTECIMENTO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  16/05/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If !lInteWms
	MsgInfo("Módulo WMS não habilitado nesta Filial.")
	Return
Endif

If MsgYesNo("Confirma o processamento - UNIFICAR SEQUÊNCIA DE ABASTECIMENTO ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Cadastrando informações no SigaWms...", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  16/05/19	  ¦¦¦
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
Local lProcOk    := .F.
Local cProdAnt   := ""
Local lOkProd    := .F.
Local _x

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("DC3")+" DC3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE DC3_FILIAL = '"+xFilial("DC3")+"' "
cQuery += " AND DC3_CODPRO = B1_COD "
If !Empty(mv_par01)
	cQuery += " AND B1_COD = '"+mv_par01+"' "
Endif	
cQuery += " AND DC3_LOCAL = '04' "
cQuery += " AND B1_TIPO = 'PA' "
cQuery += " AND SUBSTR(DC3_TPESTR,1,1) = '4' "
cQuery += " AND DC3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

cQuery := " SELECT DC3_CODPRO PRODUTO, DC3_LOCAL ARMAZEM, DC3_ORDEM ORDEM "
cQuery += " FROM "+RetSqlName("DC3")+" DC3, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE DC3_FILIAL = '"+xFilial("DC3")+"' "
cQuery += " AND DC3_CODPRO = B1_COD "
If !Empty(mv_par01)
	cQuery += " AND B1_COD = '"+mv_par01+"' "
Endif	
cQuery += " AND DC3_LOCAL = '04' "
cQuery += " AND B1_TIPO = 'PA' "
cQuery += " AND SUBSTR(DC3_TPESTR,1,1) = '4' "
cQuery += " AND DC3.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY PRODUTO, ARMAZEM, ORDEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
oProcess:SetRegua1(nTotSql)
	
DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()
	
	oProcess:IncRegua1("Unificando SigaWms...")
	lProcOk := .T.

	If SQL1->PRODUTO != cProdAnt
		If lOkProd
			_GrvSeq09(cProdAnt,zOrd)
		Else
			lOkProd := .T.
		Endif
		cProdAnt := SQL1->PRODUTO
	Endif
	zOrd := SQL1->ORDEM

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
	If Eof()
		_GrvSeq09(cProdAnt,zOrd)
		Exit
	Endif
Enddo
SQL1->(DbCloseArea())

If !lProcOk
	MsgAlert("Sem dados para processamento. Verifique os parâmetros.")
	Return
Else
	MsgInfo("Processo concluído com sucesso.")
Endif

Return

// Função de Gravação das Sequências de Abastecimento do Armazém 09
Static Function _GrvSeq09(cProdAnt,zOrd)

Local aEstrFis := {}

// Posiciona no Produto
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + cProdAnt )

// Armazena sequências do armazém 09
cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("DC3")
cQuery += " WHERE DC3_FILIAL = '"+xFilial("DC3")+"' "
cQuery += " AND DC3_CODPRO = '"+SB1->B1_COD+"' "
cQuery += " AND DC3_LOCAL = '09' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY DC3_CODPRO, DC3_LOCAL, DC3_ORDEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL9", .F., .T.)
DbSelectArea("SQL9")
SQL9->(DbGotop())
While !Eof()
	zOrd := SOMA1(zOrd)
	AAdd(aEstrFis,{"04", "9"+Substr(SQL9->DC3_TPESTR,2,5), zOrd, SQL9->DC3_CODNOR})
	SQL9->(DbSkip())
Enddo
SQL9->(DbCloseArea())

// Gravação
If Len(aEstrFis) > 0
	zOrd := SOMA1(zOrd)
	AAdd(aEstrFis,{"04","400002",zOrd,"000004"})
	zOrd := SOMA1(zOrd)
	AAdd(aEstrFis,{"04","900002",zOrd,"000004"})
	For _x := 1 to Len(aEstrFis)
		zLocal := aEstrFis[_x][1]
		zEstru := aEstrFis[_x][2]
		zOrdem := aEstrFis[_x][3]
		zNorma := aEstrFis[_x][4]
		DbSelectArea("DC3")
		DbSetOrder(2)
		If DbSeek( xFilial("DC3") + SB1->B1_COD + zLocal + zEstru )
			Loop
		Endif
		DbSelectArea("DC3")
		DbSetOrder(1)
		If !DbSeek( xFilial("DC3") + SB1->B1_COD + zLocal + zOrdem )
			RecLock("DC3",.T.)
			DC3->DC3_FILIAL := xFilial("DC3")
			DC3->DC3_CODPRO := SB1->B1_COD
			DC3->DC3_LOCAL  := zLocal
			DC3->DC3_ORDEM  := zOrdem
		Else
			RecLock("DC3",.F.)
		Endif
		DC3->DC3_TPESTR := zEstru
		DC3->DC3_CODNOR := zNorma
		DC3->DC3_TIPSEP := "3"
		DC3->DC3_NUNITI := 1
		DC3->DC3_EMBDES := "1"
		DC3->DC3_TIPEND := IIf(zLocal $("04") .And. Substr(zEstru,2,5) $("00008,00009,00010,00011,00012,00013"),"1","4") // Endereços Vazios | Compartilha End. Produtos Diferentes
		DC3->DC3_PRIEND := IIf(zLocal $("04"),"1","2") // Picking | Pulmão
		MsUnLock()	    	
	Next _x
Endif		

Return
