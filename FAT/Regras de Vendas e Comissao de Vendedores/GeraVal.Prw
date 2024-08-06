#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função GeraVal

Calcula os valores de campos personalizados.

@author 	Augusto Krejci Bem-Haja
@since 		06/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------
User Function GeraVal(nI)

Local aArea	   := GetArea()
Local nPrcVen  := aCols[nI,GdFieldPos("C6_PRCVEN")]
Local nQtdVen  := aCols[nI,GdFieldPos("C6_QTDVEN")]
Local nValor   := (nQtdVen * nPrcVen)
Local cTES	   := aCols[nI,GdFieldPos("C6_TES")]
Local nCustoT  := 0
Local nValICM  := 0
Local objQualy := LibQualyQuimica():New()

If objQualy:isSale()
	If (nQtdVen > 0) .and. (nPrcVen > 0) .and. (!Empty(cTES))
		If !(aCols[nI,Len(aHeader)+1])
			nCustoT := U_RetCusto(aCols[nI,GdFieldPos("C6_PRODUTO")]) * nQtdVen
			ProcMF(@nValICM,nValor,nI)
			AtribVal(nValICM,nValor,nQtdVen,nCustoT,nI)
			AtribRent(nValICM,nValor,nCustoT,nI)
		Endif
	Else
		ZeraVal(nI)
	Endif
Endif

freeObj(objQualy)
RestArea(aArea)

Return

Static Function ProcMF(nValICM,nValor,nI)
MaFisSave()
MaFisEnd()
MaFisIni(M->C5_CLIENTE,;  			// 1-Código Cliente/Fornecedor
M->C5_LOJACLI,;  				// 2-Loja do Cliente/Fornecedor
"C",;    						// 3-C:Cliente , F:Fornecedor
"N",;    						// 4-Tipo da NF
SA1->A1_TIPO,;   				// 5-Tipo do Cliente/Fornecedor
Nil, Nil, Nil, Nil, "MATA410")

MaFisAdd(aCols[nI,GdFieldPos("C6_PRODUTO")],;        	 // 1-Código do Produto ( Obrigatório )
aCols[nI,GdFieldPos("C6_TES")],;				         // 2-Código do TES ( Opcional )
aCols[nI,GdFieldPos("C6_QTDVEN")],; 		             // 3-Quantidade ( Obrigatório )
aCols[nI,GdFieldPos("C6_PRCVEN")],;  			     // 4-Preço Unitário ( Obrigatório )
0,;				                 // 5-Valor do Desconto ( Opcional )
"",;   							 // 6-Numero da NF Original ( Devolução/Benef )
"",; 							 // 7-Serie da NF Original ( Devolução/Benef )
0,;								 // 8-RecNo da NF Original no arq SD1/SD2
0,; 							 // 9-Valor do Frete do Item ( Opcional )
0,; 							 // 10-Valor da Despesa do item ( Opcional )
0,; 							 // 11-Valor do Seguro do item ( Opcional )
0,;   							 // 12-Valor do Frete Autônomo ( Opcional )
nValor,;  					 	 // 13-Valor da Mercadoria ( Obrigatório )
0)   							 // 14-Valor da Embalagem ( Opcional )

//MaFisRecal("",nItem) //Teste
nValICM  := MaFisRet(1,"IT_VALICM")  //Retorno calculado do ICMS.
MaFisEnd() 							 // Finaliza a MATXFIS
MaFisRestore()
Return

Static Function AtribVal(nValICM,nValor,nQtdVen,nCustoT,nI)

aCols[nI,GdFieldPos("C6_ZZVIMPO")] := nValICM
aCols[nI,GdFieldPos("C6_ZZPIMPO")] := ((aCols[nI,GdFieldPos("C6_ZZVIMPO")] / nValor) * 100)
aCols[nI,GdFieldPos("C6_ZZVCUST")] := (nCustoT)
aCols[nI,GdFieldPos("C6_ZZPCUST")] := ((aCols[nI,GdFieldPos("C6_ZZVCUST")] / nValor) * 100)
aCols[nI,GdFieldPos("C6_ZZVCOMV")] := (((nValor - aCols[nI,GdFieldPos("C6_ZZVIMPO")]) * aCols[nI,GdFieldPos("C6_COMIS1")]) / 100)		//Confirmar cálculo da base da comissão
aCols[nI,GdFieldPos("C6_ZZVCOMR")] := (((nValor - aCols[nI,GdFieldPos("C6_ZZVIMPO")]) * aCols[nI,GdFieldPos("C6_COMIS2")]) / 100)		//Confirmar cálculo da base da comissão
aCols[nI,GdFieldPos("C6_ZVCOMR3")] := (((nValor - aCols[nI,GdFieldPos("C6_ZZVIMPO")]) * aCols[nI,GdFieldPos("C6_COMIS3")]) / 100)		//Confirmar cálculo da base da comissão
aCols[nI,GdFieldPos("C6_ZVCOMR4")] := (((nValor - aCols[nI,GdFieldPos("C6_ZZVIMPO")]) * aCols[nI,GdFieldPos("C6_COMIS4")]) / 100)		//Confirmar cálculo da base da comissão
aCols[nI,GdFieldPos("C6_ZZVFRET")] := IIf( M->C5_TPFRETE=="F", 0, ((nValor * aCols[nI,GdFieldPos("C6_ZZPFRET")]) / 100) )
aCols[nI,GdFieldPos("C6_ZZVDPAD")] := ((nValor * aCols[nI,GdFieldPos("C6_ZZPDPAD")]) / 100)
aCols[nI,GdFieldPos("C6_ZZVPDD")]  := ((nValor * aCols[nI,GdFieldPos("C6_ZZPPDD")]) / 100)
aCols[nI,GdFieldPos("C6_ZZVPONT")] := ((nValor * aCols[nI,GdFieldPos("C6_ZZPPONT")]) / 100)
Return

Static Function AtribRent(nValICM,nValor,nCustoT,nI)
Local nRecLiq	:= 0
Local nMargBrut	:= 0
Local nPMargBrut:= 0
Local nSomaComis:= aCols[nI,GdFieldPos("C6_ZZVCOMV")] + aCols[nI,GdFieldPos("C6_ZZVCOMR")] + aCols[nI,GdFieldPos("C6_ZVCOMR3")] + aCols[nI,GdFieldPos("C6_ZVCOMR4")]
Local nVFret	:= aCols[nI,GdFieldPos("C6_ZZVFRET")]
Local nVDpAd	:= aCols[nI,GdFieldPos("C6_ZZVDPAD")]
Local nVPDD		:= aCols[nI,GdFieldPos("C6_ZZVPDD")]
Local nVPont	:= aCols[nI,GdFieldPos("C6_ZZVPONT")]
Local nVRent	:= 0
Local nPRent	:= 0

nRecLiq		:= nValor - nVAlICM
nMargBrut	:= nRecLiq - nCustoT
nPMargBrut	:= nMargBrut / nRecLiq * 100
nVRent		:= nMargBrut - nSomaComis - nVFret - nVDpAd - nVPDD - nVPont
nPRent		:= nVRent / nRecLiq * 100

aCols[nI,GdFieldPos("C6_ZZVMBR")]  := (nMargBrut)
aCols[nI,GdFieldPos("C6_ZZPMBR")]  := (nPMargBrut)
aCols[nI,GdFieldPos("C6_ZZVRENT")] := nVRent
aCols[nI,GdFieldPos("C6_ZZPRENT")] := nPRent
Return

Static Function ZeraVal(nI)

aCols[nI,GdFieldPos("C6_ZZVIMPO")] := 0
aCols[nI,GdFieldPos("C6_ZZPIMPO")] := 0
aCols[nI,GdFieldPos("C6_ZZVCUST")] := 0
aCols[nI,GdFieldPos("C6_ZZPCUST")] := 0
aCols[nI,GdFieldPos("C6_ZZVCOMV")] := 0
aCols[nI,GdFieldPos("C6_ZZVCOMR")] := 0
aCols[nI,GdFieldPos("C6_ZVCOMR3")] := 0
aCols[nI,GdFieldPos("C6_ZVCOMR4")] := 0
aCols[nI,GdFieldPos("C6_ZZVFRET")] := 0
aCols[nI,GdFieldPos("C6_ZZVDPAD")] := 0
aCols[nI,GdFieldPos("C6_ZZVPDD")]  := 0
aCols[nI,GdFieldPos("C6_ZZVPONT")] := 0
aCols[nI,GdFieldPos("C6_ZZVMBR")]  := 0
aCols[nI,GdFieldPos("C6_ZZPMBR")]  := 0
aCols[nI,GdFieldPos("C6_ZZVRENT")] := 0
aCols[nI,GdFieldPos("C6_ZZPRENT")] := 0
M->C5_ZZVEBIT := 0
M->C5_ZZPEBIT := 0
M->C5_ZZVPONT := 0
M->C5_ZZVMBR  := 0
M->C5_ZZPMBR  := 0

GetDRefresh()

Return
