#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CRDMANG    ¦ Autor ¦ Fábrica ERPBR    ¦ Data ¦ 03/05/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geração de arquivos Credit Management.			  		  ¦¦¦
¦¦¦          ¦ - Open/Closed Itens.			  							  ¦¦¦
¦¦¦          ¦ - Master Data.				  							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CRDMANG(lJob)

Local cPerg := PadR("CRDMANG",10)
Local lOfic := .T.

If !lJob
	If Date() != dDatabase
		MsgAlert("Data base inválida. O processo será interrompido.")
		Return
	Endif
Endif	

If !lJob
	If Pergunte(cPerg,.T.)
		If !Empty(mv_par01)
			lOfic := .F.
		Endif
		MsgInfo( IIf(!lOfic,"< Arquivos não oficiais - Cliente "+AllTrim(mv_par01)+" >","< Arquivos oficiais >") )
		If MsgYesNo("Confirma geração dos arquivos Credit Management ?","Aviso","INFO")
			oProcess := MsNewProcess():New( { | lEnd | ProcExp(lJob,lOfic) }, "Gerando arquivo", "Aguarde, processando ...", .F. )
			oProcess:Activate()
		Else
			MsgInfo("Processo interrompido.")
		Endif	
	Else
		MsgInfo("Processo interrompido.")	
	Endif
Else
	ProcExp(lJob)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcExp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ 03/05/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da exportação de dados.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcExp(lJob,lOfic)

Local _x
Local dDate := IIf(lJob,Date(),dDatabase)
Local cTime := StrTran(Time(),":","")
Private cPathOCI := "\crdmng\ICL_UR_ITEM-FERTIL-"+DtoS(dDate)+cTime+IIf(!lOfic,"-"+AllTrim(mv_par01),"")+".TXT"
Private cPathMDT := "\crdmng\ICL_UR_CUSTOMER-FERTIL-"+DtoS(dDate)+cTime+IIf(!lOfic,"-"+AllTrim(mv_par01),"")+".TXT"
Private cDest := "C:\crdmng\"
Private ENTER := CHR(13)+CHR(10)
Private nHdlOCI, nHdlMDT
Private oTempTab1, oTempTab2

If !lJob
	If !ExistDir(cDest)
		MakeDir(cDest)
	EndIf
Endif

nHdlOCI := fCreate(cPathOCI)
If nHdlOCI < 0
	If !lJob
		MsgBox("Falha na criação do arquivo de log: "+AllTrim(cPathOCI)+". Contate o Administrador.")
	Endif	
	Return
Endif

nHdlMDT := fCreate(cPathMDT)
If nHdlMDT < 0
	If !lJob
		MsgBox("Falha na criação do arquivo de log: "+AllTrim(cPathMDT)+". Contate o Administrador.")
	Endif	
	Return
Endif

// Cria arquivo temporário para armazenar os clientes das movimentações
CrdMnTrab()

// Cabeçalho do arquivo Open/Close Items
cTexto := "SRCID;BELNR;GJAHR;BUZEI;SABNR;BUTXT;KUNNR;KUNWE;VKORG;VKORGTX;SPART;PRCTR;KOKRS;UMSKZ;VKBUR;"
cTexto += "VKBURTX;VBELN;AUART;REGIO;XREF3;SOLD_L;SHIP_L;ZUONR;ZTERM;ZTERMTX;FKDAT;FAEDN;FKART;FKARTTX;REBZG;"
cTexto += "REBZJ;REBZZ;WRBTR;DMBTR;WRBTR_USD;NEBTR;NEBTR_HW;NEBTR_USD;WAERS;HWAER;AUGDT;AUGBL;CPUDT"+ENTER
fWrite(nHdlOCI,cTexto)

// Cabeçalho do arquivo Master Data
cTexto := "SRCID;SABNR;SAPNR;KNAME;STREET;HSNM1;PSTCD1;CITY1;COUNTRY;STCEG;TELF1;EMAIL;CUSINT;AKONT;CHACC;"
cTexto += "KVGR1;LOEVM_X;ERDAT;KLIMK;KLIMK_USD;EXIDTYP1;EXID1;EXIDTYP2;EXID2;SAUFT;SAUFT_USD;SSOBL;SSOBL_USD;"
cTexto += "ABSBT;ABSBT_USD;CRCVU;CRCVU_USD;ADDCV;WAERS;HWAER;STCD5"+ENTER
fWrite(nHdlMDT,cTexto)

// 1. Seleciona os títulos em aberto não enviados
If lOfic
	If !lJob
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SE1")
		cQuery += " WHERE E1_SALDO > 0 "
		cQuery += " AND E1_TIPO NOT IN('RA','NCC') " // Créditos
		cQuery += " AND SUBSTR(E1_TIPO,3,1) <> '-' " // Impostos
		//cQuery += " AND E1_PORTADO NOT IN('PDD','LOS') " // Desconsiderar portadores de perda
		cQuery += " AND E1_ZCMDEN = ' ' " // Não enviados
		cQuery += " AND E1_ZCMDBX = ' ' " // Não encerrados
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
		nTotSql := SQL1->SOMA
		SQL1->(DbCloseArea())
	Endif

	cQuery := " SELECT R_E_C_N_O_ "
	cQuery += " FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_SALDO > 0 "
	cQuery += " AND E1_TIPO NOT IN('RA','NCC') " // Créditos
	cQuery += " AND SUBSTR(E1_TIPO,3,1) <> '-' " // Impostos
	//cQuery += " AND E1_PORTADO NOT IN('PDD','LOS') " // Desconsiderar portadores de perda
	cQuery += " AND E1_ZCMDEN = ' ' " // Não enviados
	cQuery += " AND E1_ZCMDBX = ' ' " // Não encerrados
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

	If !lJob
		oProcess:SetRegua1(nTotSql)
	Endif	

	DbSelectArea("SQL1")
	SQL1->(DbGotop())
	While !Eof()

		If !lJob
			oProcess:IncRegua1("Open Items")
		Endif	

		DbSelectArea("SE1")
		SE1->(DbGoto(SQL1->R_E_C_N_O_))
		cNomFil := FWFilialName(cEmpAnt,SE1->E1_FILIAL,1)

		RecLock("SE1",.F.)
		SE1->E1_ZCMDEN := dDate // Atualiza data do envio
		MsUnLock()

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) )

		cPais := "BR"
		cRegn := "SA"
		If SA1->A1_EST == "EX"
			DbSelectArea("SYA")
			DbSetOrder(1)
			If DbSeek( xFilial("SYA") + SA1->A1_PAIS )
				cPais := SYA->YA_PAISDUE
				cRegn := SYA->YA_ZREGION
			Endif
		Endif

		cE1Numer := IIf( Len(AllTrim(SE1->E1_NUM)) > 7, Substr(SE1->E1_NUM,3,7), Substr(SE1->E1_NUM,1,7) )
		cIdTitul := AllTrim(SE1->E1_PREFIXO) + AllTrim(cE1Numer) + AllTrim(SE1->E1_PARCELA)
		cItemTit := "1"
		cUnidNeg := ""
		cDescUnd := ""
		cPedido  := ""
		cCondPag := "NEG"
		cDescCpg := "RENEGOTIATION"
		nPerIcms := 0
		nPerImpo := Round(( SE1->( (E1_IRRF+E1_ISS+E1_CSLL+E1_COFINS+E1_PIS+E1_INSS) / E1_VALOR) * 100 ),2)
		zFilSe1  := IIf(!Empty(SE1->E1_ZFILINC), SE1->E1_ZFILINC, SE1->E1_FILIAL)
		
		DbSelectArea("SD2")
		DbSetOrder(3)
		If DbSeek( zFilSe1 + SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) )
			DbSelectArea("SC5")
			DbSetOrder(1)
			If DbSeek( SD2->(D2_FILIAL+D2_PEDIDO) )
				cUnidNeg := AllTrim(SC5->C5_ZZITCTB)
				cDescUnd := Posicione("CTD",1,xFilial("CTD")+cUnidNeg,"CTD_DESC01")
				cPedido  := SC5->C5_NUM
			Endif
			DbSelectArea("SF2")
			DbSetOrder(1)
			If DbSeek( zFilSe1 + SE1->(E1_NUM+E1_PREFIXO) )
				nPerIcms := ( SF2->(F2_VALICM / F2_VALBRUT) * 100 )
				cCondPag := SF2->F2_COND
				DbSelectArea("SE4")
				DbSetOrder(1)
				DbSeek( xFilial("SE4")+cCondPag )
				cDescCpg := SE4->E4_ZDEENGL
			Endif
		Endif		
		nSaldTit := SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES-(IIf(E1_VENCREA>=dDate,(E1_VALOR*(E1_DESCFIN/100)),0)))
		nTotImpo := (nSaldTit * (nPerIcms/100)) // Icms
		nTotImpo += (nSaldTit * (nPerImpo/100)) // Impostos
		nValLiqu := nSaldTit - nTotImpo

		aOCI := {}
		AAdd(aOCI,{"E0299",; // SRCID
					cIdTitul,; // BELNR
					Substr(DtoS(SE1->E1_EMISSAO),1,4),; // GJAHR
					AllTrim(cItemTit),; // BUZEI
					"0298",; // SABNR
					"FERTILAQUA",; // BUTXT
					SA1->A1_COD,; // KUNNR
					AllTrim(Substr(SA1->A1_NOME,1,30)),; // KUNWE
					"IAS",; // VKORG
					"IAS",; // VKORGTX
					"IAS",; // SPART
					"",; // PRCTR
					"",; // KOKRS
					"",; // UMSKZ
					SE1->E1_FILIAL,; // VKBUR
					AllTrim(cNomFil),; // VKBURTX
					cPedido,; // VBELN
					"",; // AUART
					cRegn,; // REGIO
					"",; // XREF3
					cPais,; // SOLD_L
					cPais,; // SHIP_L
					AllTrim(SE1->E1_NUM),; // ZUONR
					cCondPag,; // ZTERM
					AllTrim(cDescCpg),; // ZTERMTX	
					DtoS(SE1->E1_EMISSAO),; // FKDAT
					DtoS(SE1->E1_VENCREA),; // FAEDN
					"",; // FKART
					"",; // FKARTTX
					AllTrim(SE1->E1_NUM),; // REBZG
					Substr(DtoS(SE1->E1_EMISSAO),1,4),; // REBZJ
					AllTrim(cItemTit),; // REBZZ
					AllTrim(STR(nSaldTit,11,2)),; // WRBTR
					AllTrim(STR(nSaldTit,11,2)),; // DMBTR
					"",; // WRBTR_USD
					AllTrim(STR(nValLiqu,11,2)),; // NEBTR
					AllTrim(STR(nValLiqu,11,2)),; // NEBTR_HW
					"",; // NEBTR_USD
					"BRL",; // WAERS
					"BRL",; // HWAER
					"",; // AUGDT
					"",; // AUGBL
					DtoS(dDate)}) // CPUDT

		GravaOCI(aOCI)

		DbSelectArea("SQL1")
		SQL1->(DbSkip())
	Enddo
	SQL1->(DbCloseArea())
Endif

// 2. Baixas realizadas para os títulos enviados anteriormente
If !lJob
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_TIPO NOT IN('RA','NCC') " // Créditos
	cQuery += " AND SUBSTR(E1_TIPO,3,1) <> '-' " // Impostos
	//cQuery += " AND E1_PORTADO NOT IN('PDD','LOS') " // Desconsiderar portadores de perda
	If lOfic
		cQuery += " AND E1_ZCMDEN <> ' ' " // Já enviados
		cQuery += " AND E1_ZCMDEN <> '"+DtoS(dDate)+"' " // Desconsidera os enviados nesta remessa
		cQuery += " AND E1_ZCMDBX = ' ' " // Não encerrados
	Else
		cQuery += " AND E1_SALDO > 0 " // Títulos em aberto do cliente exclusivo
		cQuery += " AND E1_CLIENTE = '"+mv_par01+"' " // Cliente exclusivo
	Endif	
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	nTotSql := SQL1->SOMA
	SQL1->(DbCloseArea())
Endif

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_TIPO NOT IN('RA','NCC') " // Créditos
cQuery += " AND SUBSTR(E1_TIPO,3,1) <> '-' " // Impostos
//cQuery += " AND E1_PORTADO NOT IN('PDD','LOS') " // Desconsiderar portadores de perda
If lOfic
	cQuery += " AND E1_ZCMDEN <> ' ' " // Já enviados
	cQuery += " AND E1_ZCMDEN <> '"+DtoS(dDate)+"' " // Desconsidera os enviados nesta remessa
	cQuery += " AND E1_ZCMDBX = ' ' " // Não encerrados
Else
	cQuery += " AND E1_SALDO > 0 " // Títulos em aberto do cliente exclusivo
	cQuery += " AND E1_CLIENTE = '"+mv_par01+"' " // Cliente exclusivo
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

If !lJob
	oProcess:SetRegua1(nTotSql)
Endif	

DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()

	If !lJob
		oProcess:IncRegua1("Closed Itens")
	Endif	

	DbSelectArea("SE1")
	SE1->(DbGoto(SQL1->R_E_C_N_O_))
	cNomFil := FWFilialName(cEmpAnt,SE1->E1_FILIAL,1)
	dDatIni := SE1->E1_ZCMDEN
	dDatFim := dDate
	If !lOfic
		dDatIni := SE1->E1_EMISSAO // Se não for geração oficial (cliente exclusivo) percorre todas as baixas desde a emissão do título
	Endif

	aBaixas := u_TotBaixas(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, dDatIni, dDatFim)
	nBaixas := aBaixas[1] // Valor das baixas desde o último envio até hoje
	dBaixas := aBaixas[2] // Data do último movimento encontrado no período (desde o último envio até hoje)

	// Se não encontrar movimento no período, não reenvia
	If lOfic
		If nBaixas == 0
			DbSelectArea("SQL1")
			SQL1->(DbSkip())
			Loop
		Endif
	Endif

	nLinhas := 1
	lSaldoA := .F.
	If SE1->E1_SALDO > 0
		If lOfic
			RecLock("SE1",.F.)
			SE1->E1_ZCMDEN := dDate
			MsUnLock()
		Endif	
		If lOfic
			nLinhas := 2
			lSaldoA := .T.
		Else
			lSaldoA := .T.
			If nBaixas > 0
				nLinhas := 2
			Endif
		Endif	
	Else
		If lOfic
			RecLock("SE1",.F.)
			SE1->E1_ZCMDBX := dDate
			MsUnLock()
		Endif	
	Endif	

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) )

	cPais := "BR"
	cRegn := "SA"
	If SA1->A1_EST == "EX"
		DbSelectArea("SYA")
		DbSetOrder(1)
		If DbSeek( xFilial("SYA") + SA1->A1_PAIS )
			cPais := SYA->YA_PAISDUE
			cRegn := SYA->YA_ZREGION
		Endif
	Endif

	For _x := 1 to nLinhas

		cE1Numer := IIf( Len(AllTrim(SE1->E1_NUM)) > 7, Substr(SE1->E1_NUM,3,7), Substr(SE1->E1_NUM,1,7) )
		cIdTitul := AllTrim(SE1->E1_PREFIXO) + AllTrim(cE1Numer) + AllTrim(SE1->E1_PARCELA)
		cItemTit := IIf(_x == 1, "1", "2")
		cUnidNeg := ""
		cDescUnd := ""
		cPedido  := ""
		cCondPag := "NEG"
		cDescCpg := "RENEGOTIATION"
		nPerIcms := 0
		nPerImpo := Round(( SE1->( (E1_IRRF+E1_ISS+E1_CSLL+E1_COFINS+E1_PIS+E1_INSS) / E1_VALOR) * 100 ),2)
		zFilSe1  := IIf(!Empty(SE1->E1_ZFILINC), SE1->E1_ZFILINC, SE1->E1_FILIAL)
		cDtBaixa := DtoS(dBaixas)
		cIdBaixa := AllTrim(SE1->E1_NUM)
		If _x == 1 .And. lSaldoA
			cDtBaixa := ""
			cIdBaixa := ""
		Endif
		
		DbSelectArea("SD2")
		DbSetOrder(3)
		If DbSeek( zFilSe1 + SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) )
			DbSelectArea("SC5")
			DbSetOrder(1)
			If DbSeek( SD2->(D2_FILIAL+D2_PEDIDO) )
				cUnidNeg := AllTrim(SC5->C5_ZZITCTB)
				cDescUnd := Posicione("CTD",1,xFilial("CTD")+cUnidNeg,"CTD_DESC01")
				cPedido  := SC5->C5_NUM
			Endif
			DbSelectArea("SF2")
			DbSetOrder(1)
			If DbSeek( zFilSe1 + SE1->(E1_NUM+E1_PREFIXO) )
				nPerIcms := ( SF2->(F2_VALICM / F2_VALBRUT) * 100 )
				cCondPag := SF2->F2_COND
				DbSelectArea("SE4")
				DbSetOrder(1)
				DbSeek( xFilial("SE4")+cCondPag )
				cDescCpg := SE4->E4_ZDEENGL
			Endif
		Endif		

		nTotImpo := (nBaixas * (nPerIcms/100)) // Icms
		nTotImpo += (nBaixas * (nPerImpo/100)) // Impostos
		nValLiqu := nBaixas - nTotImpo
		nVlrTitu := nBaixas
		If _x == 1 .And. lSaldoA
			nSaldTit := SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES-(IIf(E1_VENCREA>=dDate,(E1_VALOR*(E1_DESCFIN/100)),0)))
			nTotImpo := (nSaldTit * (nPerIcms/100)) // Icms
			nTotImpo += (nSaldTit * (nPerImpo/100)) // Impostos
			nValLiqu := nSaldTit - nTotImpo
			nVlrTitu := nSaldTit
		Endif	

		aOCI := {}
		AAdd(aOCI,{"E0299",; // SRCID
					cIdTitul,; // BELNR
					Substr(DtoS(SE1->E1_EMISSAO),1,4),; // GJAHR
					AllTrim(cItemTit),; // BUZEI
					"0298",; // SABNR
					"FERTILAQUA",; // BUTXT
					SA1->A1_COD,; // KUNNR
					AllTrim(Substr(SA1->A1_NOME,1,30)),; // KUNWE
					"IAS",; // VKORG
					"IAS",; // VKORGTX
					"IAS",; // SPART
					"",; // PRCTR
					"",; // KOKRS
					"",; // UMSKZ
					SE1->E1_FILIAL,; // VKBUR
					AllTrim(cNomFil),; // VKBURTX
					cPedido,; // VBELN
					"",; // AUART
					cRegn,; // REGIO
					"",; // XREF3
					cPais,; // SOLD_L
					cPais,; // SHIP_L
					AllTrim(SE1->E1_NUM),; // ZUONR
					cCondPag,; // ZTERM
					AllTrim(cDescCpg),; // ZTERMTX	
					DtoS(SE1->E1_EMISSAO),; // FKDAT
					DtoS(SE1->E1_VENCREA),; // FAEDN
					"",; // FKART
					"",; // FKARTTX
					AllTrim(SE1->E1_NUM),; // REBZG
					Substr(DtoS(SE1->E1_EMISSAO),1,4),; // REBZJ
					AllTrim(cItemTit),; // REBZZ
					AllTrim(STR(nVlrTitu,11,2)),; // WRBTR
					AllTrim(STR(nVlrTitu,11,2)),; // DMBTR
					"",; // WRBTR_USD
					AllTrim(STR(nValLiqu,11,2)),; // NEBTR
					AllTrim(STR(nValLiqu,11,2)),; // NEBTR_HW
					"",; // NEBTR_USD
					"BRL",; // WAERS
					"BRL",; // HWAER
					cDtBaixa,; // AUGDT
					AllTrim(cIdBaixa),; // AUGBL
					DtoS(dDate)}) // CPUDT

		GravaOCI(aOCI)

	Next _x

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

// 3. Clientes (matriz e filiais) relacionados aos títulos em aberto
If !lJob	
	cQuery := " SELECT COUNT( DISTINCT E1_CLIENTE ) AS SOMA "
	cQuery += " FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_TIPO NOT IN('RA','NCC') " // Créditos
	cQuery += " AND SUBSTR(E1_TIPO,3,1) <> '-' " // Impostos
	//cQuery += " AND E1_PORTADO NOT IN('PDD','LOS') " // Desconsiderar portadores de perda
	cQuery += " AND E1_SALDO > 0 " // Títulos em aberto
	If !lOfic
		cQuery += " AND E1_CLIENTE = '"+mv_par01+"' " // Cliente exclusivo
	Endif	
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	nTotSql := SQL1->SOMA
	SQL1->(DbCloseArea())
Endif

cQuery := " SELECT DISTINCT(E1_CLIENTE) AS CLIENTE "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_TIPO NOT IN('RA','NCC') " // Créditos
cQuery += " AND SUBSTR(E1_TIPO,3,1) <> '-' " // Impostos
//cQuery += " AND E1_PORTADO NOT IN('PDD','LOS') " // Desconsiderar portadores de perda
cQuery += " AND E1_SALDO > 0 " // Títulos em aberto
If !lOfic
	cQuery += " AND E1_CLIENTE = '"+mv_par01+"' " // Cliente exclusivo
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY CLIENTE "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
SQL1->(DbGotop())
If !lJob
	oProcess:SetRegua2(nTotSql)
Endif	
While !Eof()

	If !lJob
		oProcess:IncRegua2("Loading customers")
	Endif	

	// Informações individuais do código
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SQL1->CLIENTE )
	cCodCli := SA1->A1_COD
	cLojCli := SA1->A1_LOJA
	cCgcCli := SA1->A1_CGC

	// Informações do cliente Matriz
	aLimCrd := u_LcAgrup(SA1->A1_COD, SA1->A1_LOJA)
	// Resultado do agrupamento
	// ------------------------
	// [1] - Limite de Crédito vigente
	// [2] - Limite secundário
	// [3] - Vencto. Limite
	// [4] - Saldo de duplicatas em aberto
	// [5] - Saldo de pedidos liberados
	// [6] - Limite de Crédito cadastrado
	// [7] - Cgc do cliente Matriz
	// [8] - Códigos dos clientes do grupo
	If cCgcCli == aLimCrd[7]
		nLimite := aLimCrd[1] // Limite cliente Matriz
	Else
		nLimite := 2 // Limite cliente Filial
	Endif	
	If nLimite == 0
		nLimite := 2
	Endif

	// Cgc do cliente matriz
	cCgcMat := aLimCrd[7]

	// Armazena o cliente do título
	DbSelectArea("TR1")
	DbSetOrder(1)
	If !DbSeek( cCodCli + cLojCli )
		RecLock("TR1",.T.)
		TR1->T1_CODCLI := cCodCli
		TR1->T1_LOJCLI := cLojCli
		TR1->T1_CGCMAT := cCgcMat
		TR1->T1_LIMITE := nLimite
		MsUnLock()
	Endif

	// Complementa com todos os clientes do grupo
	nLimMat := aLimCrd[1]
	If nLimMat == 0
		nLimMat := 2
	Endif
	aGrpCli := aLimCrd[8]
	For _x := 1 to Len(aGrpCli)

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + aGrpCli[_x] )

		DbSelectArea("TR1")
		DbSetOrder(1)
		If !DbSeek( SA1->(A1_COD+A1_LOJA) )
			RecLock("TR1",.T.)
			TR1->T1_CODCLI := SA1->A1_COD
			TR1->T1_LOJCLI := SA1->A1_LOJA
			TR1->T1_CGCMAT := cCgcMat
			TR1->T1_LIMITE := IIf(SA1->A1_CGC == cCgcMat, nLimMat, 2)
			MsUnLock()
		Endif

	Next _x

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo

DbSelectArea("TR1")
TR1->(DbGotop())
If !lJob
	oProcess:SetRegua2(RecCount())
Endif	
While !Eof()

	If !lJob
		oProcess:IncRegua2("Master Data")
	Endif	

	// Informações da Matriz
	cCgcMat := TR1->T1_CGCMAT
	nLimite := TR1->T1_LIMITE

	// Informações individuais do código
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + TR1->(T1_CODCLI + T1_LOJCLI) )

	cCodCli  := SA1->A1_COD
	cNomCli  := SA1->A1_NOME
	cEndCli  := AllTrim(FisGetEnd(SA1->A1_END,SA1->A1_EST)[1])
	cNumEnd  := AllTrim(FisGetEnd(SA1->A1_END,SA1->A1_EST)[3])
	cCepCli  := SA1->A1_CEP
	cMunCli  := SA1->A1_MUN
	cCgcCli  := SA1->A1_CGC
	cTelCli  := SA1->A1_TEL
	cMailCli := AllTrim(SA1->A1_EMAIL)
	nPosMail := AT(";",cMailCli)
	If nPosMail > 0
		cMailCli := AllTrim(Substr(cMailCli,1,nPosMail-1))
	Endif
	cIntern  := IIf(SA1->A1_ZINTERN=="1","X"," ")
	cInativ  := IIf(SA1->A1_MSBLQL=="1","X"," ")

	If SA1->A1_MSBLQL == "1" // Para cliente inativo, o limite deve ser = 2 (Gleice em 01/09/2021)
		nLimite := 2
	Endif

	cTipoEx1 := SA1->A1_ZIDEXT1
	cExtId1  := AllTrim(Posicione("SX5",1,xFilial("SX5")+"WE"+SA1->A1_ZIDEXT1,"X5_DESCRI"))
	cTipoEx2 := SA1->A1_ZIDEXT1
	cExtId2  := AllTrim(Posicione("SX5",1,xFilial("SX5")+"WE"+SA1->A1_ZIDEXT2,"X5_DESCRI"))
	nLcUtil  := SA1->(A1_SALDUP + A1_SALPEDL)

	cPais := "BR"
	cRegn := "SA"
	If SA1->A1_EST == "EX"
		DbSelectArea("SYA")
		DbSetOrder(1)
		If DbSeek( xFilial("SYA") + SA1->A1_PAIS )
			cPais := SYA->YA_PAISDUE
			cRegn := SYA->YA_ZREGION
		Endif
	Endif

	aMDT := {}
	AAdd(aMDT,{"E0299",; // SRCID
				"1000",; // SABNR
				AllTrim(cCodCli),; // SAPNR
				AllTrim(cNomCli),; // KNAME
				AllTrim(cEndCli),; // STREET
				AllTrim(cNumEnd),; // HSNM1			
				AllTrim(cCepCli),; // PSTCD1
				AllTrim(cMunCli),; // CITY1
				cPais,; // COUNTRY
				AllTrim(cCgcMat),; // STCEG
				AllTrim(cTelCli),; // TELF1
				cMailCli,; // EMAIL
				cIntern,; // CUSINT
				"",; // AKONT
				"",; // CHACC
				"",; // KVGR1
				cInativ,; // LOEVM_X
				DtoS(dDate),; // ERDAT
				AllTrim(STR(nLimite,13,2)),; // KLIMK
				"",; // KLIMK_USD
				AllTrim(cTipoEx1),; // EXIDTYP1
				AllTrim(cExtId1),; // EXID1
				AllTrim(cTipoEx2),; // EXIDTYP2
				AllTrim(cExtId2),; // EXID2
				"0",; // SAUFT
				"",; // SAUFT_USD
				"0",; // SSOBL
				"",; // SSOBL_USD
				"0",; // ABSBT
				"",; // ABSBT_USD
				AllTrim(STR(nLcUtil,15,2)),; // CRCVU
				"",; // CRCVU_USD
				"0",; // ADDCV
				"USD",; // WAERS
				"BRL",; // HWAER
				 AllTrim(cCgcCli)}) // STCD5

	GravaMDT(aMDT)

	DbSelectArea("TR1")
	TR1->(DbSkip())
Enddo

TR1->(DbCloseArea())
oTempTab1:Delete()

fClose(nHdlOCI)
fClose(nHdlMDT)

If !lJob
	CpyS2t(cPathOCI, cDest)
	CpyS2t(cPathMDT, cDest)
	MsgAlert("Arquivos gerados com sucesso no diretório "+cDest+"")
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ GravaOCI  ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 03/05/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Grava linha do arquivo Open/Close Items.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GravaOCI(aOCI)

cTexto := aOCI[1][01]+";"+aOCI[1][02]+";"+aOCI[1][03]+";"+aOCI[1][04]+";"+aOCI[1][05]+";"+aOCI[1][06]+";"+aOCI[1][07]+";"+aOCI[1][08]+";"+aOCI[1][09]+";"+aOCI[1][10]+";"
cTexto += aOCI[1][11]+";"+aOCI[1][12]+";"+aOCI[1][13]+";"+aOCI[1][14]+";"+aOCI[1][15]+";"+aOCI[1][16]+";"+aOCI[1][17]+";"+aOCI[1][18]+";"+aOCI[1][19]+";"+aOCI[1][20]+";"
cTexto += aOCI[1][21]+";"+aOCI[1][22]+";"+aOCI[1][23]+";"+aOCI[1][24]+";"+aOCI[1][25]+";"+aOCI[1][26]+";"+aOCI[1][27]+";"+aOCI[1][28]+";"+aOCI[1][29]+";"+aOCI[1][30]+";"
cTexto += aOCI[1][31]+";"+aOCI[1][32]+";"+aOCI[1][33]+";"+aOCI[1][34]+";"+aOCI[1][35]+";"+aOCI[1][36]+";"+aOCI[1][37]+";"+aOCI[1][38]+";"+aOCI[1][39]+";"+aOCI[1][40]+";"
cTexto += aOCI[1][41]+";"+aOCI[1][42]+";"+aOCI[1][43]+ENTER
fWrite(nHdlOCI,cTexto)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ GravaMDT  ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 03/05/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Grava linha do arquivo Master Data.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GravaMDT(aMDT)

cTexto := aMDT[1][01]+";"+aMDT[1][02]+";"+aMDT[1][03]+";"+aMDT[1][04]+";"+aMDT[1][05]+";"+aMDT[1][06]+";"+aMDT[1][07]+";"+aMDT[1][08]+";"+aMDT[1][09]+";"+aMDT[1][10]+";"
cTexto += aMDT[1][11]+";"+aMDT[1][12]+";"+aMDT[1][13]+";"+aMDT[1][14]+";"+aMDT[1][15]+";"+aMDT[1][16]+";"+aMDT[1][17]+";"+aMDT[1][18]+";"+aMDT[1][19]+";"+aMDT[1][20]+";"
cTexto += aMDT[1][21]+";"+aMDT[1][22]+";"+aMDT[1][23]+";"+aMDT[1][24]+";"+aMDT[1][25]+";"+aMDT[1][26]+";"+aMDT[1][27]+";"+aMDT[1][28]+";"+aMDT[1][29]+";"+aMDT[1][30]+";"
cTexto += aMDT[1][31]+";"+aMDT[1][32]+";"+aMDT[1][33]+";"+aMDT[1][34]+";"+aMDT[1][35]+";"+aMDT[1][36]+ENTER
fWrite(nHdlMDT,cTexto)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ CrdMnTrab ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 03/05/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function CrdMnTrab()

Local _aTmp1 := {}

oTempTab1 := FWTemporaryTable():New("TR1")
AAdd ( _aTmp1, {"T1_CODCLI", "C", 006, 00} )
AAdd ( _aTmp1, {"T1_LOJCLI", "C", 002, 00} )
AAdd ( _aTmp1, {"T1_CGCMAT", "C", 014, 00} )
AAdd ( _aTmp1, {"T1_LIMITE", "N", 014, 02} )
oTemptab1:SetFields( _aTmp1 )
oTempTab1:AddIndex("indice1", {"T1_CODCLI", "T1_LOJCLI"})
oTempTab1:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ TotBaixas ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 14/06/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pesquisa movimentações de baixa do título.			   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TotBaixas(zFilial, zPrefixo, zNumero, zParcela, zTipo, zDtEnvio, dDate)

Local aArea   := GetArea()
Local aBaixas := {}
Local nBaixas := 0
Local dBaixas := CtoD("")

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+zFilial+"' "
cQuery += " AND E5_PREFIXO = '"+zPrefixo+"' "
cQuery += " AND E5_NUMERO = '"+zNumero+"' "
cQuery += " AND E5_PARCELA = '"+zParcela+"' "
cQuery += " AND E5_TIPO = '"+zTipo+"' "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(zDtEnvio)+"' AND '"+DtoS(dDate)+"' "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_FILIAL, E5_DATA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

DbSelectArea("SQL5")
SQL5->(DbGotop())
While !Eof()

	DbSelectArea("SE5")
	SE5->(DbGoto(SQL5->R_E_C_N_O_))

	If !u__EstorSe5(SE5->E5_FILORIG, SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, SE5->E5_LOJA, SE5->E5_SEQ)
		nBaixas += SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
		dBaixas := SE5->E5_DATA
	Endif

	DbSelectArea("SQL5")
	SQL5->(DbSkip())
Enddo
SQL5->(DbCloseArea())

AAdd(aBaixas,nBaixas)
AAdd(aBaixas,dBaixas)

RestArea(aArea)

Return(aBaixas)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MCRDMNG    ¦ Autor ¦ Fábrica ERPBR    ¦ Data ¦ 03/05/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada do processo manual.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MCRDMNG()

Local cUsrAut := AllTrim(GetMv("MV_ZCRDMNG"))

If !(__cUserId $(cUsrAut))
	MsgAlert("Usuário não autorizado. Contate o Administrador.")
	Return
Endif

U_CRDMANG(.F.)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ JCRDMNG    ¦ Autor ¦ Fábrica ERPBR    ¦ Data ¦ 03/05/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada do processo via schedule.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function JCRDMNG()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
ConOut("Função JCRDMNG: Geração de arquivos Credit Management < Início > "+DtoC(Date())+" - "+Time())
U_CRDMANG(.T.)
ConOut("Função JCRDMNG: Geração de arquivos Credit Management < Fim > "+DtoC(Date())+" - "+Time())
Return
