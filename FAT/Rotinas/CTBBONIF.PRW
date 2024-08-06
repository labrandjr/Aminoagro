#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CTBBONIF ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 09/12/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Regras para contabilização do processo de bonificação.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

/*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EX - Experimento **
BM - Bonificação Marketing **
BC - Bonificação Comercial **
BP - Bonificação PD
BQ - Bonificação Qualidade
BS - Bonif. Simulador
OT - Outros
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1. Bonificação Comercial
Centro de Custo: COMERCIAL (10104) do RTV Conta Contábil: Vendas - BONIFICACAO COMERCIAL (41206004)
Autorização: Customer Service (Simulador) Ex. bonificação dentro do Simulador

2. Experimento:
Centro de Custo: COMERCIAL (10104) do BU, GRV ou RTV Conta Contábil:  Marketing - BONIFICACAO CAMPOS EXPERIMENTAIS (41207001)
Autorização: GRV, Coordenador de Desenvolvimento e Coordenador de Marketing Ex. demoplot do PCP completo, trabalhos de validação comercial de posicionamentos/produtos existentes conduzidos internamente ou com instituições de pesquisa

3. Bonificação Qualidade
Centro de Custo: INDUSTRIA (1010204)
Conta Contábil: Fábrica - BONIFICACAO QUALIDADE (41202???? - a ser criada)
Autorização: Gerente Industrial
Ex. problema de qualidade de produto comprovado pelo Gerente Industrial

4. Bonificação PD
Centro de Custo: PESQUISA (1010106)
Conta Contábil: Pesquisa - BONIFICACAO PESQUISA (????????? - a ser criada)
Autorização: Gerente Pesquisa
Ex. teste no Centro de Inovação Tecnológica (casa de vegetação ou campo experimental Cruz Alta), trabalhos com instituições de pesquisa para validar produtos novos

5. Bonificação Marketing:
Centro de Custo: COMERCIAL (10104) do BU, GRV ou RTV Conta Contábil:  Marketing - BONIFICACAO MARKETING (41207???? - a ser criada)
Autorização: Diretor Comercial
Ex. outras bonificações estratégicas
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

// *****************************
// ** S A Í D A               **
// *****************************

// *****************************
// ** Conta Débito | NF Saída **
// *****************************
User Function BNCTDEB()

Local aArea    := GetArea()
Local cRetorno := "INFORMAR CONTA"
Local cTesBon  := AllTrim(GetMv("MV_XTESBON")) // TES para Bonificação

If SD2->D2_TES $"540,581" .Or. SD2->D2_TP$"MK"
	cRetorno := "41207041"
ElseIf SD2->D2_TES $(cTesBon) .Or. SD2->D2_TP$"PA"
	cRetorno := "31199007" // "41206004" -> CM-32600 - Jefferson Costa
Endif	

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

If SC5->C5_ZZTPBON $("BC") // Bonificação Comercial
	cRetorno := "31199007" // Solicitação Jefferson E-mail em 07/11/2019
ElseIf SC5->C5_ZZTPBON $("BS") // Bonificação Simulador
	cRetorno := "31199008" //"41206007" // Solicitação Elaine E-mail em 30/08/2019
ElseIf SC5->C5_ZZTPBON == "EX" // Experimento
	cRetorno := "41207001"
ElseIf SC5->C5_ZZTPBON == "BQ" // Bonificação Qualidade
	cRetorno := "41202006"
ElseIf SC5->C5_ZZTPBON == "BP" // Bonificação Pesquisa
	cRetorno := "41207045"
ElseIf SC5->C5_ZZTPBON == "BM" // Bonificação Marketing
	cRetorno := "41207046"
ElseIf SC5->C5_ZZTPBON == "OT" // Outros
	cRetorno := "41206008"
Endif

RestArea(aArea)

Return(cRetorno)

// *********************************
// ** Conta Crédito | NF Saída    **
// *********************************

User Function BNCTCRD()

Local aArea    := GetArea()
Local cRetorno := "INFORMAR CONTA"

If SD2->D2_TP$"PA"
	cRetorno := "11303001"
ElseIf SD2->D2_TP$"PR"
	cRetorno := "11304001"
ElseIf SD2->D2_TP$"MK"
	cRetorno := "11305008"
Else
	cRetorno := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CONTA")
Endif

RestArea(aArea)

Return(cRetorno)

// ********************************
// ** Histórico | NF Saída       **
// ********************************
User Function BNHISTOR()

Local aArea    := GetArea()
Local cRetorno := SD2->D2_TP+" - F=CPV-BONIF NF: "+AllTrim(SD2->D2_SERIE)+"/"+SD2->D2_DOC+" - "+Substr(Posicione("SA1",1,xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA,"A1_NOME"),1,15)

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

If Empty(SC5->C5_ZZTPBON)
	cRetorno := SD2->D2_TP+" - CPV-REM.BRINDES - NF: "+AllTrim(SD2->D2_SERIE)+"/"+SD2->D2_DOC+" - "+Substr(Posicione("SA1",1,xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA,"A1_NOME"),1,15)
Endif

RestArea(aArea)                                  
                                                 
Return(cRetorno)

// ****************************
// ** C.C. Débito | NF Saída **
// ****************************
/* -- Desligado --> C.C. no SD2->D2_CCUSTO
User Function BNCCDEB()

Local aArea    := GetArea()
Local cRetorno := SD2->D2_CCUSTO

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

If !Empty(SC5->C5_VEND1)
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek( xFilial("SA3") + SC5->C5_VEND1 )
		cRetorno := SA3->A3_ZZCC
	Endif
Endif

RestArea(aArea)

Return(cRetorno)
*/

// ****************************
// ** Item Débito | NF Saída **
// ****************************
User Function BNITDEB()

Local aArea    := GetArea()
Local cRetorno := ""

DbSelectArea("CTT")
DbSetOrder(1)
DbSeek( xFilial("CTT") + SD2->D2_CCUSTO )
cRetorno := CTT->CTT_ZZITCT

RestArea(aArea)

Return(cRetorno)

// *********************************
// ** D E V O L U Ç Ã O           **
// *********************************

// *********************************
// ** Conta Débito | NF Devolução **
// *********************************

User Function BNDVCTD()

Local aArea    := GetArea()
Local cRetorno := "INFORMAR CONTA"

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

	If SD2->D2_TP$"PA"
		cRetorno := "11303001"
	ElseIf SD2->D2_TP$"PR"
		cRetorno := "11304001"
	ElseIf SD2->D2_TP$"MK"
		cRetorno := "11305008"
	Else
		cRetorno := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CONTA")
	Endif

Endif

RestArea(aArea)

Return(cRetorno)

// **********************************
// ** Conta Crédito | NF Devolução **
// **********************************
User Function BNDVCTC()

Local aArea    := GetArea()
Local cRetorno := "INFORMAR CONTA"
Local cTesBon  := AllTrim(GetMv("MV_XTESBON")) // TES para Bonificação

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

	If SD2->D2_TES $"540,581" .Or. SD2->D2_TP$"MK"
		cRetorno := "41207041"
	ElseIf SD2->D2_TES $(cTesBon) .Or. SD2->D2_TP$"PA"
		cRetorno := "41206004"
	Endif

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

	If SC5->C5_ZZTPBON $("BC") // Bonificação Comercial
		cRetorno := "31199007"  // Solicitação Jefferson E-mail em 07/11/2019
	ElseIf SC5->C5_ZZTPBON $("BS") // Bonificação Simulador
		cRetorno := "31199008"  // Solicitação Jefferson E-mail em 07/11/2019
	ElseIf SC5->C5_ZZTPBON == "EX" // Experimento
		cRetorno := "41207001"
	ElseIf SC5->C5_ZZTPBON == "BQ" // Bonificação Qualidade
		cRetorno := "41202006"
	ElseIf SC5->C5_ZZTPBON == "BP" // Bonificação Pesquisa
		cRetorno := "41207045"
	ElseIf SC5->C5_ZZTPBON == "BM" // Bonificação Marketing
		cRetorno := "41207046"
	ElseIf SC5->C5_ZZTPBON == "OT" // Outros
		cRetorno := "41206008"
	Endif
	
Endif

RestArea(aArea)

Return(cRetorno)

// ********************************
// ** Histórico | NF Devolução   **
// ********************************
User Function BNDVHIST()

Local aArea    := GetArea()
Local cRetorno := SD1->D1_TP+" - F=CPV-DEV.BONIF NF: "+AllTrim(SD1->D1_SERIE)+"/"+SD1->D1_DOC+" - "+Substr(Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME"),1,15)

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )
	
	If Empty(SC5->C5_ZZTPBON)
		cRetorno := SD1->D1_TP+" - CPV-DEV.BRINDES - NF: "+AllTrim(SD1->D1_SERIE)+"/"+SD1->D1_DOC+" - "+Substr(Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME"),1,15)
	Endif
Endif

RestArea(aArea)

Return(cRetorno)

// *********************************
// ** C.C. Crédito | NF Devolução **
// *********************************
User Function BNCCCRD()

Local aArea    := GetArea()
Local cRetorno := ""

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

	cRetorno := SD2->D2_CCUSTO
	
	If Empty(cRetorno)

		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )
		
		If !Empty(SC5->C5_VEND1)
			DbSelectArea("SA3")
			DbSetOrder(1)
			If DbSeek( xFilial("SA3") + SC5->C5_VEND1 )
				cRetorno := SA3->A3_ZZCC
			Endif
		Endif
		
	Endif	

Endif

RestArea(aArea)

Return(cRetorno)

// *********************************
// ** Item Crédito | NF Devolução **
// *********************************
User Function BNITCRD()

Local aArea    := GetArea()
Local cRetorno := ""

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )
	DbSelectArea("CTT")
	DbSetOrder(1)
	DbSeek( xFilial("CTT") + SD2->D2_CCUSTO )
	cRetorno := CTT->CTT_ZZITCT
Endif

If Empty(cRetorno)
	DbSelectArea("CTT")
	DbSetOrder(1)
	DbSeek( xFilial("CTT") + SD1->D1_CC )
	cRetorno := CTT->CTT_ZZITCT
Endif

RestArea(aArea)

Return(cRetorno)

// ********************************
// ** Valor Custo | NF Devolução **
// ********************************
User Function BNDVVLR()

Local aArea    := GetArea()
Local nRetorno := 0

If SD1->D1_TIPO == "D"
	DbSelectArea("SD2")
	DbSetOrder(3)
	If DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )
		nCustoOr := SD1->D1_QUANT * (SD2->(D2_CUSTO1/D2_QUANT)) // Custo da Nf origem
		nRetorno := IIf( Substr(SD2->D2_CF,2,3)=="910" .And. SF4->F4_PODER3=="N" .And. SF4->F4_ESTOQUE=="S", nCustoOr, 0 )
	Endif
Endif

RestArea(aArea)

Return(nRetorno)

User Function INIF2NOM()
cRet := IIf(SF2->F2_TIPO$"D,B",Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_NOME"),Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME"))
Return(cRet)
