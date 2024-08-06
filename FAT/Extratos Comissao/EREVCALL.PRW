#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ EREVCALL  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 31/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ - Interface de processamento para geração dos extratos Pdf ¦¦¦
¦¦¦          ¦   referente às premiações de Revenda.		 			  ¦¦¦
¦¦¦          ¦ - Envio de e-mails.										  ¦¦¦
¦¦¦          ¦ - Log de processamento.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function EREVCALL()

Local cPerg	:= Padr("EREVCALL",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Emissão do Extrato de Premiação" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,080,{||"EMISSÃO DO EXTRATO DE PREMIAÇÃO |REVENDA|"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo emitir o extrato de premiação com extensão pdf"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"e enviá-lo por e-mail, de acordo com os parâmetros selecionados."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"A premiação deverá ser previamente calculada no período desejado."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"Opção disponível apenas para Revenda."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
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

Private cEOL     := CHR(13)+CHR(10)
Private zDirPdf  := AllTrim(mv_par06)
Private zModAtra := AllTrim(GetMv("MV_ZMODATR")) // 1=Calcula pelo Vencto.Real | 2=Calcula pelo Vencto.Original
Private oTempTable

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

If Select("LOG") > 0
	LOG->(DbCloseArea())
Endif

u_TrbPremi()
	
If MsgYesNo("Confirma o processamento - EXTRATO DE PREMIAÇÃO REVENDA ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Emitindo extratos de premiação para Revenda", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

DbSelectArea("LOG")
LOG->(DbCloseArea())
oTempTable:Delete()

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

Static Function ProcImp()

Local zFiliais   := ""
Local nTotSql    := 0
Local nForFilial := 0
Local aFilsCalc  := {}
Local zVenAnt    := ""
Local lKeyOk3    := .F.
Local aVenDet    := {}
Local aRanking   := {}
Local aLista     := {}
Local lGrvLog    := .T.
Local _env, _del

zMes := Month(mv_par02)
zAno := Year(mv_par02)
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

// Geração dos extratos Pdf
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
cQuery += " AND E3_VEND = A3_COD "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND SUBSTR(E3_VEND,1,1) = 'R' " // Somente Revenda
cQuery += " AND E3_ZZRTV = ' ' " // Não considera apuração GER e DIR
If mv_par15 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par15 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par16 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par16 == 2 // Inativos
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

cQuery := " SELECT SE3.* "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
cQuery += " AND E3_VEND = A3_COD "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND SUBSTR(E3_VEND,1,1) = 'R' " // Somente Revenda
cQuery += " AND E3_ZZRTV = ' ' " // Não considera apuração GER e DIR
If mv_par15 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par15 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par16 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par16 == 2 // Inativos
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

	oProcess:IncRegua1("Gerando Pdf")

	If SQL3->E3_VEND != zVenAnt
		If lKeyOk3
			u_ExtrRev(zVenAnt,aVenDet,aRanking,@aLista,zPer,lGrvLog,mv_par15)
			aVenDet  := {}
			aRanking := {}
		Else
			lKeyOk3 := .T.
		Endif
		zVenAnt := SQL3->E3_VEND
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SQL3->E3_CODCLI + SQL3->E3_LOJA )

	DbSelectArea("SE1")
	DbSetOrder(2)
	DbSeek( SQL3->(E3_FILIAL+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO) )

	zCodCli  := SQL3->E3_CODCLI
	zNomCli  := AllTrim(SA1->A1_NOME)
	zNFiscal := SQL3->E3_NUM
	zParcela := IIf(!Empty(SQL3->E3_PARCELA),AllTrim(SQL3->E3_PARCELA),"U")
	zVencto  := IIf(SQL3->E3_TIPO == "NCC", StoD(SQL3->E3_EMISSAO), IIf(zModAtra == "2",DataValida(SE1->E1_VENCORI,.T.),SE1->E1_VENCREA))
	zPagto   := StoD(SQL3->E3_EMISSAO)
	zPedido  := IIf(SQL3->E3_TIPO == "NCC", u_PedNcc(), SQL3->E3_PEDIDO)
	zVlrTit  := IIf(SQL3->E3_TIPO == "NCC", SQL3->E3_BASE, SE1->E1_VALOR)
	zVlBase  := SQL3->E3_BASE
	zPercen  := SQL3->E3_PORC
	zVlPrem  := SQL3->E3_COMIS
	zVlOrig  := SQL3->E3_ZZCOMIS
	zAtraso  := SQL3->E3_ZZATRAS
	zPerDesc := SQL3->E3_ZZPDESC
	zVlrDesc := SQL3->E3_ZZVDESC
	zNrAcord := SQL3->E3_ZZACORD
	zSeqBaix := SQL3->E3_SEQ
	zVlPago  := SQL3->E3_ZVLPAGO	
	zEmiTit  := IIf(SQL3->E3_TIPO == "NCC",StoD(SQL3->E3_EMISSAO),SE1->E1_EMISSAO)
	zDesMet  := 0

	If mv_par14 == 1 // Modelo com atraso
		AAdd(aVenDet,{zCodCli, zNomCli, zNFiscal, zParcela, zVencto, zPagto, zPedido, zVlrTit, zVlBase, zPercen, zVlPrem, zVlOrig, zAtraso, zPerDesc, zVlrDesc, "", "", zNrAcord, zSeqBaix, zVlPago, zEmiTit, zDesMet })
	Else // Modelo padrão
		AAdd(aVenDet,{zCodCli, zNomCli, zNFiscal, zParcela, zVencto, zPagto, zPedido, zVlrTit, zVlBase, zPercen, zVlOrig, "", "", zNrAcord, zSeqBaix, zVlPago })
	Endif

	lAddRank := .F.
	If Len(aRanking) == 0
		lAddRank := .T.
	Else
		nPos := aScan(aRanking, {|x| x[1] == zCodCli})
		If nPos == 0
			lAddRank := .T.
		Else
			aRanking[nPos][3] += IIf(mv_par14 == 1,zVlPrem,zVlOrig)
		Endif
	Endif
	If lAddRank
		AAdd(aRanking,{zCodCli, zNomCli, IIf(mv_par14 == 1,zVlPrem,zVlOrig), ""})
	Endif

	DbSelectArea("SQL3")
	SQL3->(DbSkip())
	If Eof()
		u_ExtrRev(zVenAnt,aVenDet,aRanking,@aLista,zPer,lGrvLog,mv_par15)
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
		zOri   := Space(80)
		u_MMextrat(zCod,zNome,zEmail,zPdf,zOri,"REV",zPer,lGrvLog)
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
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ExtrRev 	¦ Autor 	¦ Fábrica ERPBR   	¦   31/10/17      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Prepara os dados para geração do Pdf.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ExtrRev(zVend,aDetalhe,aRanking,aLista,zPer,lGrvLog,nFilPag)

Local zTotal := 0
Local _ord, _det

DbSelectArea("SA3")
DbSetOrder(1)
DbSeek( xFilial("SA3") + zVend )

If mv_par05 == 1 // Ranking
	aSort( aDetalhe,,, { |x,y| x[11] > y[11] } ) // Detalhe: valor da premiação em ordem decrescente
	aSort( aRanking,,, { |x,y| x[3]  > y[3]  } ) // Ranking: valor total em ordem decrescente
ElseIf mv_par05 == 2 // Nome
	If mv_par14 == 1 // Modelo com atraso
		aSort( aDetalhe,,, { |x,y| x[2]+x[3]+x[4]+x[19] < y[2]+y[3]+y[4]+y[19] } ) // Detalhe: nome + nota fiscal + parcela + sequência (em ordem crescente)
	Else // Modelo padrão
		aSort( aDetalhe,,, { |x,y| x[2]+x[3]+x[4]+x[15] < y[2]+y[3]+y[4]+y[15] } ) // Detalhe: nome + nota fiscal + parcela + sequência (em ordem crescente)
	Endif
	aSort( aRanking,,, { |x,y| x[2] < y[2] } ) // Ranking: nome em ordem crescente
Endif

If mv_par14 == 1 // Modelo com atraso
	For _ord := 1 to Len(aDetalhe)
		aDetalhe[_ord][17] := StrZero(_ord,5) // Atribui ordem2 no detalhe
	Next _ord
Else // Modelo padrão
	For _ord := 1 to Len(aDetalhe)
		aDetalhe[_ord][13] := StrZero(_ord,5) // Atribui ordem2 no detalhe
	Next _ord
Endif

For _ord := 1 to Len(aRanking)
	aRanking[_ord][4] := StrZero(_ord,5) // Ordena o ranking
	zTotal += aRanking[_ord][3] // Acumula valor total do extrato
Next _ord

For _det := 1 to Len(aDetalhe)
	nPos := aScan(aRanking, {|x| x[1] == aDetalhe[_det][1] })
	If nPos > 0
		If mv_par14 == 1 // Modelo com atraso
			aDetalhe[_det][16] := aRanking[nPos][4] // Atribui ordem1 no detalhe
		Else // Modelo padrão
			aDetalhe[_det][12] := aRanking[nPos][4] // Atribui ordem1 no detalhe
		Endif
	Endif
Next _det

aNccDet := {}
nCrdNcc := 0
If mv_par14 == 1 // Modelo com atraso
	aSort( aDetalhe,,, { |x,y| x[16]+x[17] < y[16]+y[17] } ) // Ordem1 (ranking ou nome) + Ordem2 (premiação ou nota fiscal) em ordem crescente
	lRevenda := .T.
	U_PDFREV(aDetalhe,zTotal,lRevenda,@aLista,zPer,aNccDet,nCrdNcc,lGrvLog,nFilPag)
Else // Modelo padrão
	aSort( aDetalhe,,, { |x,y| x[12]+x[13] < y[12]+y[13] } ) // Ordem1 (ranking ou nome) + Ordem2 (premiação ou nota fiscal) em ordem crescente
	lRevenda := .T.
	U_PDFRTV(aDetalhe,zTotal,lRevenda,@aLista,zPer,aNccDet,nCrdNcc,lGrvLog,nFilPag)
Endif

Return
