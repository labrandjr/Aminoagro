#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FUNCFIN   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 25/08/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Funções Genéricas - Módulo Financeiro.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

// ********************************************************************************** //
// Luis Brandini - 25/08/17
// ********************************************************************************** //
// ** Valida a emissão do título a pagar inserido manualmente = database.		   ** //
// ********************************************************************************** //
User Function EMCPMAN()

Local lRetorno := .T.

If M->E2_EMISSAO != dDatabase
	MsgInfo("A emissão deve ser igual a data base.")
	lRetorno := .F.
Endif

Return(lRetorno)

// ********************************************************************************** //
// Luis Brandini - 15/09/17
// ********************************************************************************** //
// ** Inicializador padrão CONTA CONTÁBIL na Substituição de Títulos Provisórios.  ** //
// ********************************************************************************** //
User Function INPRCTA()

Local aArea    := GetArea()
Local cRetorno := ""
Local lInicial := .F.

If FunName() == "FINA050"
	If _Opc != 2
		lInicial := .T.
	Endif
ElseIf FunName() == "FINA750"
	If _Opc != 13
		lInicial := .T.
	Endif
Endif		

If lInicial
	cRetorno := IIf(!Inclui .And. !Altera,IIf(lSubst,SE2->E2_CONTAD,""),"")
Endif	

RestArea(aArea)

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 15/09/17
// ********************************************************************************** //
// ** Inicializador padrão CENTRO DE CUSTO na Substituição de Títulos Provisórios. ** //
// ********************************************************************************** //
User Function INPRCCU()

Local aArea    := GetArea()
Local cRetorno := ""
Local lInicial := .F.

If FunName() == "FINA050"
	If _Opc != 2
		lInicial := .T.
	Endif
ElseIf FunName() == "FINA750"
	If _Opc != 13
		lInicial := .T.
	Endif
Endif		

If lInicial
	cRetorno := IIf(!Inclui .And. !Altera,IIf(lSubst,SE2->E2_CCUSTO,""),"")
Endif	

RestArea(aArea)

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 07/03/18
// ********************************************************************************** //
// ** Inicializador padrão SALDO LÍQUIDO do Título a Receber. 					   ** //
// ********************************************************************************** //
User Function SalLiqSe1()
nRet := IIf(SE1->E1_SALDO<=0,0,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES-E1_IRRF-E1_INSS-E1_CSLL-E1_COFINS-E1_PIS-(IIf(E1_VENCREA>=dDatabase,(E1_VALOR*(E1_DESCFIN/100)),0))))
Return(nRet)

// ********************************************************************************** //
// Luis Brandini - 07/03/18
// ********************************************************************************** //
// ** Retorna valor do título para uso em CNAB a Receber.	 					   ** //
// ********************************************************************************** //
User Function VlCnabRec()
nRet := IIf(SE1->E1_SALDO<=0,0,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES-E1_IRRF-E1_INSS-E1_CSLL-E1_COFINS-E1_PIS)) // Idem SalLiqSe1() porém sem o Desconto Pontualidade 
Return(nRet)

// ********************************************************************************** //
// Luis Brandini - 08/03/18
// ********************************************************************************** //
// ** Atualização em dados do Pedido de Venda conforme BU.	 					   ** //
// ********************************************************************************** //
User Function UpdRegBu()
MsgRun("Aguarde, atualizando Região e BU...","Processando",{|| AtuRegBu() })
Return

Static Function AtuRegBu()

cQuery := " SELECT DISTINCT C6_FILIAL FILIAL, C6_NUM NUMERO "
cQuery += " FROM "+RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SC5")+" SC5 "
cQuery += " WHERE C5_FILIAL = C6_FILIAL "
cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND C5_VEND1 <> ' ' "
cQuery += " AND (C6_QTDVEN - C6_QTDENT) > 0 "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C6_FILIAL, C6_NUM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( SQL1->(FILIAL + NUMERO) )

	cCCVend := RetField("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_ZZCC")
	cUndNeg := RetField("CTT",1,xFilial("CTT")+cCCVend,"CTT_ZZITCT")
	cRegVen := RetField("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_REGIAO")

	If !(AllTrim(cUndNeg) $("BU1,BU7"))
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		Loop
	Endif	

	RecLock("SC5",.F.)
	SC5->C5_ZZITCTB := cUndNeg
	SC5->C5_ZZREGVE := cRegVen
	SC5->C5_SUPER1  := RetField("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_SUPER")
	SC5->C5_GEREN1  := RetField("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_GEREN")
	SC5->C5_SUPER2  := RetField("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_SUPER")
	SC5->C5_GEREN2  := RetField("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_GEREN")
	MsUnLock()

	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( SC5->(C5_FILIAL+C5_NUM) )
	While !Eof() .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
		If SC6->(C6_QTDVEN-C6_QTDENT) > 0 .And. Empty(SC6->C6_BLQ)
			RecLock("SC6",.F.)
			SC6->C6_CCUSTO  := cCCVend
			SC6->C6_ZZITCTB := cUndNeg
			MsUnLock()	
		Endif	
		SC6->(DbSkip())
	Enddo

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

Return

// ********************************************************************************** //
// Luis Brandini - 21/06/18
// ********************************************************************************** //
// ** Coluna 'Dt.Últ.Baixa' no relatório 'Posição Clientes' layout 'Gerencial'	   ** //
// ********************************************************************************** //
User Function E1DULBX()

Local aArea := GetArea()

cQuery := " SELECT E5_DATA DTBAIXA "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
cQuery += " AND E5_PREFIXO = '"+SE1->E1_PREFIXO+"' "
cQuery += " AND E5_NUMERO = '"+SE1->E1_NUM+"' "
cQuery += " AND E5_PARCELA = '"+SE1->E1_PARCELA+"' "
cQuery += " AND E5_TIPO = '"+SE1->E1_TIPO+"' "
cQuery += " AND E5_CLIFOR = '"+SE1->E1_CLIENTE+"' "
cQuery += " AND E5_LOJA = '"+SE1->E1_LOJA+"' "
If mv_par14 == 1
	cQuery += " AND E5_DATA <= '"+DtoS(mv_par08)+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_DATA DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
zRet := StoD(SQL5->DTBAIXA)
SQL5->(DbCloseArea())

RestArea(aArea)

Return(zRet)

// ********************************************************************************** //
// Luis Brandini - 21/06/18
// ********************************************************************************** //
// ** Coluna 'Documento' no relatório 'Posição Clientes' layout 'Gerencial'	   	   ** //
// ********************************************************************************** //
User Function E1ULDOC()

Local aArea := GetArea()

cQuery := " SELECT E5_DOCUMEN DOCUMEN "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
cQuery += " AND E5_PREFIXO = '"+SE1->E1_PREFIXO+"' "
cQuery += " AND E5_NUMERO = '"+SE1->E1_NUM+"' "
cQuery += " AND E5_PARCELA = '"+SE1->E1_PARCELA+"' "
cQuery += " AND E5_TIPO = '"+SE1->E1_TIPO+"' "
cQuery += " AND E5_CLIFOR = '"+SE1->E1_CLIENTE+"' "
cQuery += " AND E5_LOJA = '"+SE1->E1_LOJA+"' "
If mv_par14 == 1
	cQuery += " AND E5_DATA <= '"+DtoS(mv_par08)+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_DATA DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
zRet := SQL5->DOCUMEN
SQL5->(DbCloseArea())

RestArea(aArea)

Return(zRet)

// ********************************************************************************** //
// Luis Brandini - 20/07/18
// ********************************************************************************** //
// ** Função para checar se a liquidação possui títulos com pagamento de comissão  ** //
// ********************************************************************************** //
User Function ChkLqCm(zNumLiq)

Local aArea   := GetArea()
Local aAreaE5 := SE5->(GetArea())
Local lComs   := .F.

cQuery := " SELECT R_E_C_N_O_ RECSE5 "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+SE5->E5_FILIAL+"' "
cQuery += " AND E5_DOCUMEN = '"+zNumLiq+"' "
cQuery += " AND E5_MOTBX = 'LIQ' "
cQuery += " AND E5_TIPODOC = 'BA' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

DbSelectArea("SQL5")
SQL5->(DbGotop())
While !Eof()

	SE5->(DbGoto(SQL5->RECSE5))
	zNumLiq2 := RetField("SE1",1,SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA),"E1_NUMLIQ")

	If Empty(zNumLiq2)

		zVend1 := RetField("SE1",1,SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA),"E1_VEND1")
		If !Empty(zVend1)
			nComis1 := RetField("SD2",3,SE5->(E5_FILIAL+E5_NUMERO+E5_PREFIXO+E5_CLIFOR+E5_LOJA),"D2_COMIS1")
			If nComis1 > 0
				lComs := .T.
				Exit
			Endif
		Endif

	Else

		lComs2 := .F.
		cQuery := " SELECT R_E_C_N_O_ RECSE5 "
		cQuery += " FROM "+RetSqlName("SE5")
		cQuery += " WHERE E5_FILIAL = '"+SE5->E5_FILIAL+"' "
		cQuery += " AND E5_DOCUMEN = '"+zNumLiq2+"' "
		cQuery += " AND E5_MOTBX = 'LIQ' "
		cQuery += " AND E5_TIPODOC = 'BA' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL52", .F., .T.)

		DbSelectArea("SQL52")
		SQL52->(DbGotop())
		While !Eof()
			SE5->(DbGoto(SQL52->RECSE5))
			zVend1 := RetField("SE1",1,SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA),"E1_VEND1")
			If !Empty(zVend1)
				nComis1 := RetField("SD2",3,SE5->(E5_FILIAL+E5_NUMERO+E5_PREFIXO+E5_CLIFOR+E5_LOJA),"D2_COMIS1")
				If nComis1 > 0
					lComs2 := .T.
					Exit
				Endif
			Endif
			DbSelectArea("SQL52")
			SQL52->(DbSkip())
		Enddo
		SQL52->(DbCloseArea())

		If lComs2
			lComs := .T.
			Exit
		Endif

	Endif

	DbSelectArea("SQL5")
	SQL5->(DbSkip())
Enddo
SQL5->(DbCloseArea())

RestArea(aArea)
RestArea(aAreaE5)

Return(lComs)

// ********************************************************************************** //
// Luis Brandini - 31/07/18
// ********************************************************************************** //
// ** Utilizado no CNAB Daycoval.							 					   ** //
// ********************************************************************************** //
User Function DatDesc()
nRet := IIF(SE1->E1_DESCFIN > 0, GRAVADATA(SE1->E1_VENCREA,.F.,1), REPLICATE("0",6))
Return(nRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ TotNegoc  ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 31/05/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valor total da negociação a partir do número da liquidação.¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TotNegoc(zFilial,zNumNeg)

Local aArea   := GetArea()
Local zTotNeg := 0

cQuery := " SELECT SUM(E5_VALOR) TOT_NEG "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+zFilial+"' "
cQuery += " AND E5_DOCUMEN = '"+zNumNeg+"' "
cQuery += " AND E5_MOTBX = 'LIQ' "
cQuery += " AND E5_TIPODOC = 'BA' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
zTotNeg := SQLT->TOT_NEG
SQLT->(DbCloseArea())

RestArea(aArea)

Return(zTotNeg)

// ********************************************************************************** //
// Luis Brandini - 30/11/18
// ********************************************************************************** //
// ** Regra LP 510-001.										 					   ** //
// ********************************************************************************** //
User Function LP510_001()

If SE2->E2_XIDTRIB == "2" .And. SE2->(E2_XJUROS+E2_XMULTA) > 0
	nRet := SE2->(E2_VALOR+E2_ACRESC)
Else
	nRet := IIf(SE2->(!E2_TIPO$"AB-/PR /NDF".AND.E2_ORIGEM!="FINA290M".AND.!E2_MULTNAT$"1".AND.E2_FORNECE!="UNIAO ".AND.E2_MOEDA==1.AND.;
						E2_PREFIXO!="EMP".AND.AllTrim(E2_NATUREZ)!="207063".AND.EMPTY(E2_NUMLIQ)), SE2->(E2_VALOR+E2_IRRF+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL+E2_INSS+E2_DECRESC-E2_ACRESC), 0)
Endif

Return(nRet)

// ********************************************************************************** //
// Luis Brandini - 30/11/18
// ********************************************************************************** //
// ** Regra LP 510-010.										 					   ** //
// ********************************************************************************** //
User Function LP510_010()

nRet := IIf(SE2->(!E2_TIPO$"AB-/PR /NDF".AND.E2_ORIGEM!="FINA290M".AND.!E2_MULTNAT$"1".AND.E2_FORNECE!="UNIAO ".AND.E2_MOEDA==1.AND.;
					E2_PREFIXO!="EMP".AND.AllTrim(E2_NATUREZ)=="207063"), SE2->(E2_VALOR+E2_IRRF+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL+E2_INSS+E2_DECRESC-E2_ACRESC), 0)

Return(nRet)

// ********************************************************************************** //
// Luis Brandini - 23/12/2018
// ********************************************************************************** //
// ** Coluna 'Saldo a Receber' layout 'Conciliação' relatório FINR130.			   ** //
// ********************************************************************************** //
User Function SdoRec_Con(CellAA,CellAB,CellAH,CellAG)
// CellAA - Tit Vencidos Valor Corrigido
// CellAB - Titulos a Vencer Valor Atual
// CellAH - Desconto Financeiro
// CellAG - Acréscimo

Local nRet := SE1->(E1_SALDO+E1_SDACRES-E1_SDDECRE)
Local dIni := AllTrim(GetMv("MV_ZINIACR"))

// Fev-2021 - Alteração no tratamento do Acréscimo nas Negociações
If (!Empty(SE1->E1_NUMLIQ) .Or. !Empty(SE1->E1_ZZACORD)) .And. DtoS(SE1->E1_EMISSAO) >= dIni
	nRet := SE1->(E1_SALDO-E1_SDDECRE)
Endif

If mv_par36 <> Date() .And. mv_par20 == 1
	If SE1->E1_SALDO <> SE1->E1_VALOR .And. SE1->E1_DECRESC > 0 .And. SE1->E1_SDDECRE == 0
		zMov := u_MovBxCr(SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,mv_par36,SE1->E1_ACRESC,SE1->E1_DECRESC)
		nRet := SE1->E1_VALOR - zMov
//	ElseIf SE1->E1_SALDO <> SE1->E1_VALOR .And. SE1->E1_ACRESC > 0 .And. SE1->E1_SDACRES == 0
//		zMov := u_MovBxCr(SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,mv_par36,SE1->E1_ACRESC,SE1->E1_DECRESC)
//		nRet := SE1->E1_VALOR - zMov
	Else
		nRet := (CellAA+CellAB+CellAH)
		// Fev-2021 - Alteração no tratamento do Acréscimo nas Negociações
		If (!Empty(SE1->E1_NUMLIQ) .Or. !Empty(SE1->E1_ZZACORD)) .And. DtoS(SE1->E1_EMISSAO) >= dIni
			nRet -= CellAG
		Endif
	Endif	
Endif	

Return(nRet)

// ********************************************************************************** //
// Luis Brandini - 23/12/18
// ********************************************************************************** //
// ** Calcula o valor total das movimentações de baixa a receber no título.		   ** //
// ********************************************************************************** //
User Function MovBxCr(zFilial,zPrefixo,zTitulo,zParcela,zTipo,zData,zAcresc,zDecresc)

Local aArea   := GetArea()
Local aAreaE5 := SE5->(GetArea())
Local nMov    := 0
Local lDcr    := .F.
Local lAcr    := .F.

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+zFilial+"' "
cQuery += " AND E5_PREFIXO = '"+zPrefixo+"' "
cQuery += " AND E5_NUMERO = '"+zTitulo+"' "
cQuery += " AND E5_PARCELA = '"+zParcela+"' "
cQuery += " AND E5_TIPO = '"+zTipo+"' "
cQuery += " AND E5_DATA <= '"+DtoS(zData)+"' "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

DbSelectArea("SQL5")
SQL5->(DbGotop())
While !Eof()

	DbSelectArea("SE5")
	SE5->(DbGoto(SQL5->R_E_C_N_O_))
	
	If !u__EstorSe5(SE5->E5_FILIAL, SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, SE5->E5_LOJA, SE5->E5_SEQ)
		nMov += SE5->E5_VALOR
		If SE5->E5_VLDECRE > 0
			nMov += SE5->E5_VLDECRE
			lDcr := .T.
		ElseIf SE5->E5_VLDESCO > 0
			nMov += SE5->E5_VLDESCO
		Endif
		//
/*		If SE5->E5_VLACRES > 0
			nMov -= SE5->E5_VLACRES
			lAcr := .T.
		ElseIf SE5->E5_VLJUROS > 0 .Or. SE5->E5_VLMULTA > 0
			nMov -= SE5->(E5_VLJUROS+E5_VLMULTA)
		Endif */
	Endif

	DbSelectArea("SQL5")
	SQL5->(DbSkip())
Enddo
SQL5->(DbCloseArea())

If !lAcr
	nMov -= zAcresc
Endif

If !lDcr
	nMov += zDecresc
Endif

RestArea(aAreaE5)
RestArea(aArea)

Return(nMov)

// ********************************************************************************** //
// Luis Brandini - 22/01/20
// ********************************************************************************** //
// ** Monta numeração do título considerando parcela "01" quando parcela única.	   ** //
// ********************************************************************************** //
User Function NumParUnica()

cRet := AllTrim(PadL(Val(SE1->E1_NUM),10,""))+"/"+IIf(Empty(SE1->E1_PARCELA),"01",SE1->E1_PARCELA)
    
Return(cRet)

// ********************************************************************************** //
// Luis Brandini - 05/05/2021
// ********************************************************************************** //
// ** Conta débido LP 513-001 													   ** //
// ********************************************************************************** //
User Function LP5131D()

cRet := IIf(AllTrim(SE5->E5_TIPO)$"PA",IIf(!Empty(Posicione("SED",1,xFilial("SED")+SE5->E5_NATUREZ,"ED_CONTA")),SED->ED_CONTA,;
		IIf(!Empty(Posicione("SE2",1,xFilial("SE2")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E2_CONTAD")),SE2->E2_CONTAD,"CTA. NATUREZA")),"CTA.NATUREZA")        

Return(cRet)

// ********************************************************************************** //
// Luis Brandini - 05/07/2021
// ********************************************************************************** //
// ** Retorna limite de crédito agrupado										   ** //
// ********************************************************************************** //
User Function LcAgrup(zCodCli,zLojCli)

Local aArea    := GetArea()
Local aLimCrd  := {}
Local lAgrpLim := ( GetMv("MV_AGRPLIM") == "S" )
Local lAgrpCrd := .F.
Local lAgrpCgc := .F.
Local cAgrupCr := ""
Local cCgcCli  := ""
Local cCgcMat  := ""
Local aGrupCli := {}
Local nX

AAdd(aLimCrd,0) // Limite de Crédito principal disponível
AAdd(aLimCrd,0) // Limite de crédito secundário
AAdd(aLimCrd,CtoD("")) // Vencimento do limite
AAdd(aLimCrd,0) // Saldo de duplicatas em aberto
AAdd(aLimCrd,0) // Saldo de pedidos liberados por crédito e não faturados
AAdd(aLimCrd,0) // Limite de Crédito principal cadastrado
AAdd(aLimCrd,cCgcMat) // Cnpj do cliente Matriz
AAdd(aLimCrd,aGrupCli) // Códigos dos clientes do grupo

DbSelectArea("SA1")
DbSetOrder(1)
If !DbSeek( xFilial("SA1") + zCodCli + zLojCli )
	RestArea(aArea)
	Return(aLimCrd)
Endif	
nRecSa1 := SA1->(Recno()) // Cliente + Loja
cCgcCli := Substr(SA1->A1_CGC,1,8) // Base do Cgc da Matriz

If lAgrpLim // Agrupamento de Crédito = Habilitado
	If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
		lAgrpCrd := .T.
		cAgrupCr := SA1->A1_ZZAGCRD
	Else
		If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
			DbSelectArea("SA1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SA1") + SA1->A1_ZZAGCRD )
				DbSelectArea("SA1")
				DbSetOrder(1)
				SA1->(DbGoto(nRecSa1)) // Restaura Cliente + Loja
			Else
				nRecSa1  := SA1->(Recno()) // Agrupamento de Crédito: posiciona na Matriz
				lAgrpCrd := .T.
				cAgrupCr := SA1->A1_COD
			Endif
		Else // Agrupamento de Crédito: verifica se código do cliente está sendo usado para agrupamento
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SA1")
			cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
			cQuery += " AND A1_ZZAGCRD = '"+SA1->A1_COD+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSQL1",.T.,.T.)
			lAgrpCrd := (TSQL1->SOMA > 0)
			TSQL1->(DbCloseArea())
			If !lAgrpCrd
				DbSelectArea("SA1")
				DbSetOrder(1)
				SA1->(DbGoto(nRecSa1)) // Restaura Cliente + Loja
			Else
				cAgrupCr := SA1->A1_COD
			Endif	
		Endif
	Endif
	// Se não for agrupamento de crédito, verifica se existe agrupamento pela Base do Cnpj
	If !lAgrpCrd
		DbSelectArea("SA1")
		DbSetOrder(3)
		If !DbSeek( xFilial("SA1") + cCgcCli + "0001" )
			DbSelectArea("SA1")
			DbSetOrder(1)
			SA1->(DbGoto(nRecSa1)) // Restaura Cliente + Loja
		Else
			nRecSa1  := SA1->(Recno()) // Matriz - Base do Cnpj
			lAgrpCgc := .T.
		Endif
	Endif
Endif

nLimCred  := 0
nLimCFin  := 0	
dVencLim  := SA1->A1_VENCLC
nSalDupl  := 0
nSalPedL  := 0
nLimCada  := 0
cAliasSA1 := "QRYSA1"
aStruSa1  := SA1->(DbStruct())

cQuery := "SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_CGC, A1_ZZAGCRD, A1_MOEDALC, A1_LC, A1_LCFIN, A1_SALFIN, A1_SALDUP, A1_SALPEDL, A1_VENCLC, A1_RISCO, R_E_C_N_O_ RECSA1 "
cQuery += " FROM "+RetSqlName("SA1")+" SA1 "
cQuery += "WHERE "
cQuery += "A1_FILIAL = '"+xFilial("SA1")+"' AND "
If lAgrpCrd
	cQuery += "((A1_COD = '"+cAgrupCr+"') OR (A1_ZZAGCRD = '"+cAgrupCr+"')) AND "
ElseIf lAgrpCgc
	cQuery += "SUBSTR(A1_CGC,1,8) = '"+cCgcCli+"' AND "
Else
	cQuery += "A1_COD = '"+zCodCli+"' AND A1_LOJA = '"+zLojCli+"' AND "
Endif	
cQuery += "SA1.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY "+SqlOrder(SA1->(IndexKey()))					
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1,.T.,.T.)

For nX := 1 To Len(aStruSA1)
	If aStruSA1[nX,1]$"A1_FILIAL,A1_COD,A1_MOEDALC,A1_LC,A1_LCFIN,A1_SALFIN,A1_SALDUP,A1_SALPEDL,A1_VENCLC"						
		If aStruSA1[nX,2] <> "C" .And. FieldPos(aStruSA1[nX,1])<>0
			TcSetField(cAliasSA1,aStruSA1[nX,1],aStruSA1[nX,2],aStruSA1[nX,3],aStruSA1[nX,4])
		EndIf						
	EndIf
Next nX

DbSelectArea(cAliasSA1)
(cAliasSA1)->(DbGotop())
While !Eof()
	If !(cAliasSA1)->A1_RISCO$"E,Z" .And. !Empty((cAliasSA1)->A1_VENCLC) .And. (cAliasSA1)->A1_VENCLC >= dDataBase
		nLimCred += (cAliasSA1)->A1_LC
	Else
		nLimCred += 0
	Endif
	nLimCFin += (cAliasSA1)->A1_LCFIN
	nSalDupl += (cAliasSA1)->A1_SALDUP
	nSalPedL += (cAliasSA1)->A1_SALPEDL
	nLimCada += (cAliasSA1)->A1_LC

	AAdd(aGrupCli, (cAliasSA1)->(A1_COD+A1_LOJA) )
	
	DbSelectArea(cAliasSA1)
	DbSkip()
Enddo
(cAliasSA1)->(DbCloseArea())

RestArea(aArea)

DbSelectArea("SA1")
DbSetOrder(1)
SA1->(DbGoto(nRecSa1))

aLimCrd[1] := nLimCred
aLimCrd[2] := nLimCFin
aLimCrd[3] := dVencLim
aLimCrd[4] := nSalDupl
aLimCrd[5] := nSalPedL
aLimCrd[6] := nLimCada
aLimCrd[7] := SA1->A1_CGC
aLimCrd[8] := aGrupCli

Return(aLimCrd)
