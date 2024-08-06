#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FUNCCTB   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 19/01/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Funções Genéricas - Módulo Contabilidade Gerencial.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

// ********************************************************************************** //
// Luis Brandini - 19/01/17
// ********************************************************************************** //
// ** Função para identificar operações intercompany nos LP                        ** //
// ********************************************************************************** //
// Chamada:
// U_INTCPNY("C",cCodLoj)
// U_INTCPNY("F",cCodLoj)
// ********************************************************************************** //

User Function INTCPNY(cCliFor,cCodLoj)

Local lIntcpny := .F.
Local cCnpjInt := AllTrim(GetMv("MV_CGCINTE")) // Preencher com todos os CNPJ do sigamat.emp (separar por vírgula)

If cCliFor == "C"
	cCnpjCli := Posicione("SA1",1,xFilial("SA1") + cCodLoj,"A1_CGC")
	lIntcpny := ( cCnpjCli $ (cCnpjInt) )
ElseIf cCliFor == "F"
	cCnpjFor := Posicione("SA2",1,xFilial("SA2") + cCodLoj,"A2_CGC")
	lIntcpny := ( cCnpjFor $ (cCnpjInt) )
Endif

Return(lIntcpny)

// ********************************************************************************** //
// Luis Brandini - 25/01/17
// ********************************************************************************** //
// ** Função para obter o C.C do veículo nas NF frete                              ** //
// ********************************************************************************** //
User Function CCVEIC()

Local cRetorno := "102030101001"

cCodVeic := Posicione("DTC",7,xFilial("DTC")+SD2->(D2_DOC+D2_SERIE+D2_FILIAL),"DTC_ZZVEIC")
If !Empty(cCodVeic)
	cCCVeicu := Posicione("DA3",1,xFilial("DA3")+cCodVeic,"DA3_ZZCC")
	If !Empty(cCCVeicu)
		cRetorno := cCCVeicu
	Endif
Endif

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 25/01/17
// ********************************************************************************** //
// ** Função para obter a BU do C.C ref. ao veículo nas NF frete                   ** //
// ********************************************************************************** //
User Function BUVEIC()

Local cRetorno := "BU9"

cCodVeic := Posicione("DTC",7,xFilial("DTC")+SD2->(D2_DOC+D2_SERIE+D2_FILIAL),"DTC_ZZVEIC")
If !Empty(cCodVeic)
	cCCVeicu := Posicione("DA3",1,xFilial("DA3")+cCodVeic,"DA3_ZZCC")
	If !Empty(cCCVeicu)
		cBUVeicu := Posicione("CTT",1,xFilial("CTT")+cCCVeicu,"CTT_ZZITCT")
		If !Empty(cBUVeicu)
			cRetorno := cBUVeicu
		Endif	
	Endif
Endif

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 09/02/17
// ********************************************************************************** //
// ** Função para validar a amarração Conta Contábil x Centro de Custo			   ** //
// ********************************************************************************** //
User Function CtbAmrr(xConta,xCC,xItem,xClasse)

Local lRetorno := .T.

// CtbAmarra(TMP->CT2_CREDITO,TMP->CT2_CCC,TMP->CT2_ITEMC,TMP->CT2_CLVLCR,.T.)
lRetorno := CtbAmarra(xConta,xCC,xItem,xClasse,.T.)

Return(lRetorno)

// ********************************************************************************** //
// Luis Brandini - 09/05/17
// ********************************************************************************** //
// ** Regra para valor da contabilização do LP 650-001							   ** //
// ********************************************************************************** //
User Function LP650_01()

Local nRetorno := IIF(SD1->D1_TIPO$"NCI".AND.;
					  SF4->(F4_PODER3=="N".AND.F4_DUPLIC=="S").AND.;
					  !SD1->D1_TES$"033,034,039,052,071,072,132,079,081,232",SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_ICMSRET),0)

Return(nRetorno)

// ********************************************************************************** //
// Luis Brandini - 29/01/2018
// ********************************************************************************** //
// ** Regra para conta débito da contabilização do LP 650-001					   ** //
// ********************************************************************************** //
User Function L65001D()

Local zRetorno := IF(U_INTCPNY("F",SD1->(D1_FORNECE+D1_LOJA)).AND.SD1->D1_TP$"PA,PR",;
					"11304001",;
					IIF(SD1->D1_TP$"PA",;
						"11303001",;
						IIF(SD1->D1_TP$"PR",;
							"11304001",;
							IIF(SD1->D1_TP$"AI".AND.SD1->D1_TIPO=="C",;
								"41202003",;
								IIf(SD1->D1_LOCAL=="14",;
									"11301004",;
									IIF( !Empty(SD1->D1_CONTA), SD1->D1_CONTA, IIF(AllTrim(SF1->F1_ESPECIE)=="CTE","61105006","61105001")) )))))

Return(zRetorno)

// ********************************************************************************** //
// Luis Brandini - 08/02/2021
// ********************************************************************************** //
// ** Regra para conta crédito da contabilização do LP 650-100					   ** //
// ********************************************************************************** //
User Function L65100C()

Local zRetorno := ""
Local lImpXml  := GetMv("MV_IMPXML")

If SF4->F4_TRANFIL == "1"
	zRetorno := "11399097"
ElseIf lImpXml .And. AllTrim(SD1->D1_COD) == AllTrim(GetMv("MV_XMLPFCT")) .And. AllTrim(SD1->D1_CONTA) == AllTrim(GetMv("MV_ZXMLCTR"))
    DbSelectArea("ZZO")
    DbSetOrder(1)
    If DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
		zRetorno := ZZO->ZZO_CTANFE
	Else
		zRetorno := "41202007"
	Endif
Else
	zRetorno := IIf(U_INTCPNY("F",SD1->(D1_FORNECE+D1_LOJA)).AND.SD1->D1_TP$"PA,PR",;
					"11304001",;
					IIF(SD1->D1_TP$"PA",;
						"11303001",;
						IIF(SD1->D1_TP$"PR",;
							"11304001",;
							IIf(SD1->D1_LOCAL=="14",;
								"11301004",;
								SD1->D1_CONTA))))
Endif


Return(zRetorno)

// ********************************************************************************** //
// Luis Brandini - 26/02/2021
// ********************************************************************************** //
// ** Regra para conta crédito da contabilização do LP 650-310					   ** //
// ********************************************************************************** //
User Function L65310C()

Local zRetorno := ""
Local lImpXml  := GetMv("MV_IMPXML")

If lImpXml .And. AllTrim(SD1->D1_COD) == AllTrim(GetMv("MV_XMLPFCT")) .And. AllTrim(SD1->D1_CONTA) == AllTrim(GetMv("MV_ZXMLCTR"))
    DbSelectArea("ZZO")
    DbSetOrder(1)
    If DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
		zRetorno := ZZO->ZZO_CTANFE
	Else
		zRetorno := "41202007"
	Endif
Else
	zRetorno := IF(U_INTCPNY("F",SD1->(D1_FORNECE+D1_LOJA)).AND.SD1->D1_TP$"PA,PR",;
					"11304001",;
					IIF(SD1->D1_TP$"PA",;
						"11303001",;
						IIF(SD1->D1_TP$"PR",;
							"11304001",;
							IIf(SD1->D1_LOCAL=="14",;
								"11301004",;
								SD1->D1_CONTA))))
Endif

Return(zRetorno)

// ********************************************************************************** //
// Luis Brandini - 26/02/2021
// ********************************************************************************** //
// ** Regra para conta crédito da contabilização do LP 650-311					   ** //
// ********************************************************************************** //
User Function L65311C()

Local zRetorno := ""
Local lImpXml  := GetMv("MV_IMPXML")

If lImpXml .And. AllTrim(SD1->D1_COD) == AllTrim(GetMv("MV_XMLPFCT")) .And. AllTrim(SD1->D1_CONTA) == AllTrim(GetMv("MV_ZXMLCTR"))
    DbSelectArea("ZZO")
    DbSetOrder(1)
    If DbSeek( SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) )
		zRetorno := ZZO->ZZO_CTANFE
	Else
		zRetorno := "41202007"
	Endif
Else
	zRetorno := IF(U_INTCPNY("F",SD1->(D1_FORNECE+D1_LOJA)).AND.SD1->D1_TP$"PA,PR",;
					"11304001",;
					IIF(SD1->D1_TP$"PA",;
						"11303001",;
						IIF(SD1->D1_TP$"PR",;
							"11304001",;
							IIf(SD1->D1_LOCAL=="14",;
								"11301004",;
								SD1->D1_CONTA))))
Endif

Return(zRetorno)

// ********************************************************************************** //
// Luis Brandini - 31/07/17
// ********************************************************************************** //
// ** Regra para C.Custo nos LP 641-301 a 305									   ** //
// ********************************************************************************** //

User Function CCNFEORI()

Local cCCOrigi := POSICIONE("SD2",3,XFILIAL("SD2")+SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI),"D2_CCUSTO")
Local cRetorno := IIf(!Empty(cCCOrigi),cCCOrigi,SD1->D1_CC)

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 13/09/17
// ********************************************************************************** //
// ** Atualização de contas contábeis nas regras dos LP							   ** //
// ********************************************************************************** //

User Function UPDCTLP()

DbSelectArea("ZZF")
DbSetOrder(1)
ZZF->(DbGotop())
While !Eof()
	zContaDe := AllTrim(ZZF->ZZF_CTADE)
	zContaPa := AllTrim(ZZF->ZZF_CTAPA)
	//
	DbSelectArea("CT5")
	DbSetOrder(1)
	CT5->(DbGotop())
	While !Eof()
		//
		zCt5Deb := AllTrim(CT5->CT5_DEBITO)
		nPosDeb := AT(zContaDe,zCt5Deb)
		If nPosDeb > 0
			While .T.
				zCt5Deb := StrTran(zCt5Deb,zContaDe,zContaPa)
				nPosDeb := AT(zContaDe,zCt5Deb)
				If nPosDeb == 0
					Exit
				Endif
			Enddo
			MsgInfo(AllTrim(CT5->CT5_DEBITO))
			RecLock("CT5",.F.)
			CT5->CT5_DEBITO := zCt5Deb
			MsUnLock()
			MsgInfo(AllTrim(zCt5Deb))
		Endif
		//
		zCt5Crd := AllTrim(CT5->CT5_CREDIT)
		nPosCrd := AT(zContaDe,zCt5Crd)
		If nPosCrd > 0
			While .T.
				zCt5Crd := StrTran(zCt5Crd,zContaDe,zContaPa)
				nPosCrd := AT(zContaDe,zCt5Crd)
				If nPosCrd == 0
					Exit
				Endif
			Enddo
			MsgInfo(AllTrim(CT5->CT5_CREDIT))
			RecLock("CT5",.F.)
			CT5->CT5_CREDIT := zCt5Crd
			MsUnLock()
			MsgInfo(AllTrim(zCt5Crd))
		Endif
		//
		CT5->(DbSkip())
	Enddo
	DbSelectArea("ZZF")
	ZZF->(DbSkip())
Enddo

MsgBox("Processo finalizado.")

Return

// ********************************************************************************** //
// Luis Brandini - 15/09/17
// ********************************************************************************** //
// ** Função para obter a classe de valor do Título Pai - Contas a Pagar           ** //
// ********************************************************************************** //
User Function PCLVLPAI()

Local cRetorno := IIf(!Empty(SA2->A2_ZZCLASS),SA2->A2_ZZCLASS,"FALTA CLASSE VALOR")
Local zClVlPai := ""

zFornPai := Substr(SE2->E2_TITPAI,18,8)
zClVlPai := RetField("SA2",1,xFilial("SA2")+zFornPai,"A2_ZZCLASS")
If !Empty(zClVlPai)
	cRetorno := zClVlPai
Endif

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 19/06/18
// ********************************************************************************** //
// ** Função para obter o centro de custo da nota fiscal de saída ou fixo FIN     ** //
// ********************************************************************************** //
User Function CCNFFIN()

Local cRetorno := POSICIONE("SD2",3,XFILIAL("SD2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA),"D2_CCUSTO")

If Empty(cRetorno)
	cRetorno := "101010203001"
Endif

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 19/06/18
// ********************************************************************************** //
// ** Função para obter a unid.negócio da nota fiscal de saída ou fixo BU9	       ** //
// ********************************************************************************** //
User Function BUNFFIN()

Local cRetorno := POSICIONE("SD2",3,XFILIAL("SD2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA),"D2_ITEMCC")

If Empty(cRetorno)
	cRetorno := "BU9"
Endif

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 28/04/2021
// ********************************************************************************** //
// ** Função para obter a conta contábil para ct-e conforme doc.entrada associado. ** //
// ********************************************************************************** //
User Function ECTACTE(xNfiscal)

Local xRet := "41202007"
Local xCod := GdFieldGet("D1_COD")
If !Empty(xCod)
	xRet := Posicione("SB1",1,xFilial("SB1")+xCod,"B1_CONTA")
Endif

If !Empty(xNfiscal) .And. AllTrim(xCod) $(AllTrim(GetMv("MV_ZPRDFRT")))
	zTes := POSICIONE("SD1",1,XFILIAL("SD1")+xNfiscal,"D1_TES")
	zCta := POSICIONE("SF4",1,XFILIAL("SF4")+zTes,"F4_ZCTACTE")
	If !Empty(zCta)
		xRet := zCta
	Endif	
Endif

Return(xRet)

// ********************************************************************************** //
// Luis Brandini - 28/04/2021
// ********************************************************************************** //
// ** Função para obter a conta contábil para ct-e conforme doc.saída associado.   ** //
// ********************************************************************************** //
User Function SCTACTE(xNfiscal)

Local xRet := "41202007"
Local xCod := GdFieldGet("D1_COD")
If !Empty(xCod)
	xRet := Posicione("SB1",1,xFilial("SB1")+xCod,"B1_CONTA")
Endif

If !Empty(xNfiscal) .And. AllTrim(xCod) $(AllTrim(GetMv("MV_ZPRDFRT")))
	zTes := POSICIONE("SD2",3,XFILIAL("SD2")+xNfiscal,"D2_TES")
	zCta := POSICIONE("SF4",1,XFILIAL("SF4")+zTes,"F4_ZCTACTE")
	If !Empty(zCta)
		xRet := zCta
	Endif	
Endif

Return(xRet)

// ********************************************************************************** //
// Luis Brandini - 25/10/2021
// ********************************************************************************** //
// ** Função para obter a conta contábil crédito do título gerado pela liquidação. ** //
// ********************************************************************************** //
User Function CTALIQPG()

Local aArea := GetArea()
Local zRetX := "CTA. BANCO"

cQry := " SELECT E2_BCOCHQ, E2_AGECHQ, E2_CTACHQ "
cQry += " FROM "+RetSqlName("SE2")
cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
cQry += " AND E2_NUMLIQ = '"+AllTrim(SE5->E5_DOCUMEN)+"' "
cQry += " AND D_E_L_E_T_ <> '*' "
cQry := ChangeQuery(cQry)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"TSE2", .T., .T.)

DbSelectArea("TSE2")
TSE2->(DbGotop())
If !Eof()
	zBco := PadR(TSE2->E2_BCOCHQ,3)
	zAge := PadR(TSE2->E2_AGECHQ,5)
	zCta := PadR(TSE2->E2_CTACHQ,10)
	DbSelectArea("SA6")	
	DbSetOrder(1)
	If DbSeek( xFilial("SA6") + zBco + zAge + zCta )
		zRetX := SA6->A6_CONTA
	Endif
Endif
TSE2->(DbCloseArea())

RestArea(aArea)

Return(zRetX)
