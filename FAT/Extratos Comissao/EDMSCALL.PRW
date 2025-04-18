#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � EDMSCALL  � Autor �  F�brica ERP.BR   � Data  � 09/02/2022 ���
��+----------+------------------------------------------------------------���
���Descricao � - Interface de processamento para gera��o dos extratos Pdf ���
���          �   referente �s premia��es de Desenv.Mercado.				  ���
���          � - Envio de e-mails.										  ���
���          � - Log de processamento.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function EDMSCALL()

Local cPerg	:= Padr("EDMSCALL",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local lPlrAdd   := GetMv("MV_ZPLRADD")
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

If !lPlrAdd
	MsgInfo("Processo n�o habilitado.")
	Return
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Emiss�o do Extrato de Premia��o" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,070,{||"EMISS�O DO EXTRATO DE PREMIA��O |Desenv.Mercado|"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo emitir o extrato de premia��o com extens�o pdf"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"e envi�-lo por e-mail, de acordo com os par�metros selecionados."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"A premia��o dever� ser previamente calculada no per�odo desejado."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"Op��o dispon�vel apenas para Desenvolvedores de Mercado."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Par�metros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � Preparar  � Autor � Fabrica ERPBR    � Data �  09/02/2022  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Prepara o processamento principal.						  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Preparar()

Private cEOL    := CHR(13)+CHR(10)
Private zDirPdf := AllTrim(mv_par06)
Private oTempTable

If Empty(mv_par06)
	MsgInfo("Aten��o, diret�rio Pdf n�o informado. Verifique os par�metros.")
	Return
Endif

If !File(zDirPdf+"\*.*")
	MsgInfo("Aten��o, diret�rio Pdf inv�lido."+cEOL+;
			zDirPdf+cEOL+;
			"Verifique os par�metros.")
	Return
Endif

If Select("LOG") > 0
	LOG->(DbCloseArea())
Endif

u_TrbPremi()
	
If MsgYesNo("Confirma o processamento - EXTRATO DE PREMIA��O DM ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Emitindo extratos de premia��o para DM", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

DbSelectArea("LOG")
LOG->(DbCloseArea())
oTempTable:Delete()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data �  09/02/2022 ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da importa��o.								  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

Local zFiliais   := ""
Local nTotSql    := 0
Local nForFilial := 0
Local aFilsCalc  := {}
Local zVenAnt    := ""
Local zPerDms    := 0
Local lKeyOk3    := .F.
Local aVenDet    := {}
Local aRanking   := {}
Local aLista     := {}
Local lGrvLog    := .T.
Local _env, _del

zMes := Month(mv_par02)
zAno := Year(mv_par02)
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
zIni := Upper(MesExtenso(mv_par01))
zFim := Upper(MesExtenso(zAfi))
zPer := zIni+" A "+zFim+" DE "+Year2Str(zAfi)
If Year(mv_par01) != zAno
	zPer := zIni+" "+Year2Str(mv_par01)+" A "+zFim+" "+Year2Str(zAfi)
Endif

aFilsCalc := MatFilCalc( mv_par13 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

// Gera��o dos extratos Pdf
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
cQuery += " AND E3_VEND = A3_COD "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND SUBSTR(E3_VEND,1,1) = 'C' " // Somente DM
cQuery += " AND E3_ZZRTV <> ' ' " // Considera apenas apura��o
If mv_par14 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par14 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par15 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par15 == 2 // Inativos
	cQuery += " AND A3_MSBLQL = '1' "
Endif
cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
nTotSql := SQL3->SOMA
SQL3->(DbCloseArea())

If nTotSql == 0
	MsgAlert("Sem dados para processamento. Verifique os par�metros.")
	Return
Endif

cQuery := " SELECT SE3.* "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
cQuery += " AND E3_VEND = A3_COD "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND SUBSTR(E3_VEND,1,1) = 'C' " // Somente DM
cQuery += " AND E3_ZZRTV <> ' ' " // Considera apenas apura��o
If mv_par14 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par14 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par15 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par15 == 2 // Inativos
	cQuery += " AND A3_MSBLQL = '1' "
Endif
cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E3_VEND, E3_CODCLI, E3_LOJA, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

oProcess:SetRegua1(nTotSql)

DbSelectArea("SQL3")
SQL3->(DbGotop())
While !Eof()

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek( xFilial("SA3") + SQL3->E3_VEND )

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SQL3->E3_CODCLI + SQL3->E3_LOJA )

	oProcess:IncRegua1("Gerando Pdf")

	If SQL3->E3_VEND != zVenAnt
		If lKeyOk3
			u_ExtrDms(zVenAnt,aVenDet,aRanking,zPerDms,@aLista,zPer,lGrvLog)
			aVenDet  := {}
			aRanking := {}
		Else
			lKeyOk3 := .T.
		Endif
		zVenAnt := SQL3->E3_VEND
		zPerDms := SQL3->E3_PORC
	Endif

	zCodRtv  := SQL3->E3_ZZRTV
	zNomRtv  := Substr(RetField("SA3",1,xFilial("SA3")+SQL3->E3_ZZRTV,"A3_NOME"),1,25)
	zCodCli  := SQL3->E3_CODCLI
	zNomCli  := Substr(SA1->A1_NOME,1,30)
	zVlBase  := SQL3->E3_BASE
	zPercen  := SQL3->E3_PORC
	zVlPrem  := SQL3->E3_COMIS

	lAddDet := .F.
	If Len(aVenDet) == 0
		lAddDet := .T.
	Else
		nPos := aScan(aVenDet, {|x| x[1] == zCodRtv .And. x[3] == zCodCli})
		If nPos == 0
			lAddDet := .T.
		Else
			aVenDet[nPos][5] += zVlBase
			aVenDet[nPos][7] += zVlPrem
		Endif
	Endif	
	If lAddDet
		AAdd(aVenDet,{zCodRtv, zNomRtv, zCodCli, zNomCli, zVlBase, zPercen, zVlPrem, "", "" })
	Endif	

	lAddRank := .F.
	If Len(aRanking) == 0
		lAddRank := .T.
	Else
		nPos := aScan(aRanking, {|x| x[1] == zCodRtv})
		If nPos == 0
			lAddRank := .T.
		Else
			aRanking[nPos][3] += zVlPrem
		Endif
	Endif
	If lAddRank
		AAdd(aRanking,{zCodRtv, zNomRtv, zVlPrem, ""})
	Endif

	DbSelectArea("SQL3")
	SQL3->(DbSkip())
	If Eof()
		u_ExtrDms(zVenAnt,aVenDet,aRanking,zPerDms,@aLista,zPer,lGrvLog)
	Endif

	DbSelectArea("SQL3")
Enddo
SQL3->(DbCloseArea())
		
If mv_par08 == 1 // Envio dos E-mails
	aEnvMail := u_DlgEmail(aLista)
	oProcess:SetRegua2( Len(aEnvMail) )
	For _env := 1 to Len(aEnvMail)
		oProcess:IncRegua2("Enviando e-mail")
		zCod   := aEnvMail[_env][1]
		zNome  := aEnvMail[_env][2]
		zEmail := aEnvMail[_env][3]
		zPdf   := aEnvMail[_env][4]
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + zCod )
		zOri := Lower(PadR(SA3->A3_EMAIL,80))
		u_MMextrat(zCod,zNome,zEmail,zPdf,zOri,"DM",zPer,lGrvLog)
	Next _env
	// Apaga os arquivos do servidor
	For _del := 1 to Len(aLista)
		zPdf := "\premiacao\"+aLista[_del][4]
		fErase(zPdf)
	Next _del
Endif

U_LogPrem()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ExtrDms		  	� Autor � F�brica ERPBR   �   09/02/2022  ���
��+----------+------------------------------------------------------------���
���Descricao � Prepara os dados para gera��o do Pdf.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ExtrDms(zVend,aDetalhe,aRanking,zPerDms,aLista,zPer,lGrvLog)

Local zTotal := 0
Local _ord, _det

DbSelectArea("SA3")
DbSetOrder(1)
DbSeek( xFilial("SA3") + zVend )

If mv_par05 == 1 // Ranking
	aSort( aDetalhe,,, { |x,y| x[7] > y[7] } ) // Detalhe: valor da premia��o em ordem decrescente
	aSort( aRanking,,, { |x,y| x[3] > y[3] } ) // Ranking: valor total em ordem decrescente
ElseIf mv_par05 == 2 // Nome
	aSort( aDetalhe,,, { |x,y| x[4] < y[4] } ) // Detalhe: nome do cliente em ordem crescente
	aSort( aRanking,,, { |x,y| x[2] < y[2] } ) // Ranking: nome do rtv em ordem crescente
Endif

For _ord := 1 to Len(aDetalhe)
	aDetalhe[_ord][9] := StrZero(_ord,5) // Atribui ordem2 no detalhe
Next _ord

For _ord := 1 to Len(aRanking)
	aRanking[_ord][4] := StrZero(_ord,5) // Ordena o ranking
	zTotal += aRanking[_ord][3] // Acumula valor total do extrato
Next _ord

For _det := 1 to Len(aDetalhe)
	nPos := aScan(aRanking, {|x| x[1] == aDetalhe[_det][1] })
	If nPos > 0
		aDetalhe[_det][8] := aRanking[nPos][4] // Atribui ordem1 no detalhe
	Endif
Next _det

aSort( aDetalhe,,, { |x,y| x[8]+x[9] < y[8]+y[9] } ) // Ordem1 (ranking ou nome) + Ordem2 (premia��o ou rtv) em ordem crescente

U_PDFDMS(aDetalhe,zTotal,zPerDms,@aLista,zPer,lGrvLog)

Return
