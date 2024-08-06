#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AWMSTRF   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 16/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transferência dos Armazéns 04 e 09 no SIGAWMS.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AWMSTRF()

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

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Transferência de Endereços para Unificação" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,060,{||"TRANSFERÊNCIA DE ENDEREÇOS PARA UNIFICAÇÃO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
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

If MsgYesNo("Confirma o processamento - TRANSFERÊNCIA DE ENDEREÇOS ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Executando transferências...", "Aguarde, processando ...", .F. )
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

Local nTotSql  := 0
Local lProcOk  := .F.
Local aTrfEnde := {} 

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SBF")
cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"' "
If !Empty(mv_par01)
	cQuery += " AND BF_PRODUTO = '"+mv_par01+"' "
Endif	
cQuery += " AND BF_LOCAL IN('04','09') "
cQuery += " AND SUBSTR(BF_ESTFIS,1,1) = '0' "
cQuery += " AND (BF_QUANT - BF_EMPENHO) > 0 "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ RECSBF "
cQuery += " FROM "+RetSqlName("SBF")
cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"' "
If !Empty(mv_par01)
	cQuery += " AND BF_PRODUTO = '"+mv_par01+"' "
Endif	
cQuery += " AND BF_LOCAL IN('04','09') "
cQuery += " AND SUBSTR(BF_ESTFIS,1,1) = '0' "
cQuery += " AND (BF_QUANT - BF_EMPENHO) > 0 "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
oProcess:SetRegua1(nTotSql)
	
DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()
	
	oProcess:IncRegua1("Transferindo endereços...")
	lProcOk := .T.

	DbSelectArea("SBF")
	SBF->(DbGoto(SQL1->RECSBF))
	
	lEndBlq := .F.
	DbSelectArea("SBE")
	DbSetOrder(1)
	DbSeek( xFilial("SBE") + SBF->BF_LOCAL + SBF->BF_LOCALIZ )
	If SBE->BE_STATUS == "3"
		lEndBlq := .T.
	Endif
	
	AAdd(aTrfEnde,{ SBF->BF_PRODUTO, SBF->BF_LOCAL, SBF->BF_LOCALIZ, SBF->BF_LOTECTL, SBF->(BF_QUANT-BF_EMPENHO), lEndBlq })
	
	If Len(aTrfEnde) == 10
		If _ExecTrf(aTrfEnde)
			MsgAlert("Processo interrompido.")
			Exit
		Endif
		aTrfEnde := {}
	Endif

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
	If Eof()
		If _ExecTrf(aTrfEnde)
			MsgAlert("Processo interrompido.")
		Endif
		Exit
	Endif
Enddo
SQL1->(DbCloseArea())

If !lProcOk
	MsgAlert("Sem dados para processamento. Verifique os parâmetros.")
	Return
Else
	MsgInfo("Processo concluído.")
Endif

Return

// ExecAuto de Transferência Múltipla - MATA261
Static Function _ExecTrf(aTrfEnde)

Local aAuto  := {}
Local aItem  := {}
Local aLinha := {}
Local aBloqu := {}
Local nX
Local nOpcAuto := 3
Private lMsErroAuto := .F.

If Len(aTrfEnde) == 0
	Return(.F.)
Endif

//Cabecalho a Incluir
AAdd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho

//Itens a Incluir 
aItem := {}

For nX := 1 to Len(aTrfEnde)

	aLinha := {}

	zProduto := aTrfEnde[nX][1] 

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + zProduto )

	zArmazem := aTrfEnde[nX][2]
	zLocaliz := aTrfEnde[nX][3]
	zLoteCtl := aTrfEnde[nX][4]
	dDtValid := CtoD("")
	dDtVlDes := CtoD("")
	zQuantid := aTrfEnde[nX][5]
	zLocaDes := PadR((Substr(zArmazem,2,1)+"-"+AllTrim(zLocaliz)),15)
	zQtSegum := ConvUm(SB1->B1_COD, zQuantid, 0, 2)
	lEndBloq := aTrfEnde[nX][6]

	If lEndBloq
		AAdd(aBloqu,{zArmazem,zLocaliz})
		AAdd(aBloqu,{"04",zLocaDes})
		//
		DbSelectArea("SBE")
		DbSetOrder(1)
		DbSeek( xFilial("SBE") + zArmazem + zLocaliz )
		RecLock("SBE",.F.)
		SBE->BE_STATUS := "2"
		MsUnLock()
		//
		DbSelectArea("SBE")
		DbSetOrder(1)
		DbSeek( xFilial("SBE") + "04" + zLocaDes )
		RecLock("SBE",.F.)
		SBE->BE_STATUS := "2"
		MsUnLock()
	Endif

	// Data Validade Lote Origem
	DbSelectArea("SB8")
	DbSetOrder(3)
	If DbSeek( xFilial("SB8") + zProduto + zArmazem + zLoteCtl )
		dDtValid := SB8->B8_DTVALID
	Endif	

	// Data Validade Lote Destino
	DbSelectArea("SB8")
	DbSetOrder(3)
	If DbSeek( xFilial("SB8") + zProduto + "04" + zLoteCtl )
		dDtVlDes := SB8->B8_DTVALID
	Else
		dDtVlDes := dDtValid
	Endif	
	
	//Origem 
	AAdd(aLinha,{"ITEM","00"+cValtoChar(nX),Nil})
	AAdd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //Cod Produto origem 
	AAdd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem 
	AAdd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem 
	AAdd(aLinha,{"D3_LOCAL", zArmazem, Nil}) //armazem origem 
	AAdd(aLinha,{"D3_LOCALIZ", zLocaliz,Nil}) //Informar endereço origem

	//Destino 
	AAdd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //cod produto destino 
	AAdd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino 
	AAdd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino 
	AAdd(aLinha,{"D3_LOCAL", "04", Nil}) //armazem destino 
	AAdd(aLinha,{"D3_LOCALIZ", zLocaDes, Nil}) //Informar endereço destino

	AAdd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
	AAdd(aLinha,{"D3_LOTECTL", zLoteCtl, Nil}) //Lote Origem
	AAdd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
	AAdd(aLinha,{"D3_DTVALID", dDtValid, Nil}) //data validade 
	AAdd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
	AAdd(aLinha,{"D3_QUANT", zQuantid, Nil}) //Quantidade
	AAdd(aLinha,{"D3_QTSEGUM", zQtSegum, Nil}) //Seg unidade medida
	AAdd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno 
	AAdd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ
	
	AAdd(aLinha,{"D3_LOTECTL", zLoteCtl, Nil}) //Lote destino
	AAdd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino 
	AAdd(aLinha,{"D3_DTVALID", dDtVlDes, Nil}) //validade lote destino
	AAdd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade
	
	AAdd(aAuto,aLinha)

Next nX

MSExecAuto({|x,y| Mata261(x,y)},aAuto,nOpcAuto)

If lMsErroAuto 
	MostraErro()
Endif

For _y := 1 to Len(aBloqu)
	zLoc := aBloqu[_y][1]
	zEnd := aBloqu[_y][2]
	//
	DbSelectArea("SBE")
	DbSetOrder(1)
	DbSeek( xFilial("SBE") + zLoc + zEnd )
	RecLock("SBE",.F.)
	SBE->BE_STATUS := "3"
	MsUnLock()
Next _y

Return(lMsErroAuto)
