#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Função Recalc

Função que recalcula os campos da SC6, baseado no preenchimento do cabeçalho.

@author 	Augusto Krejci Bem-Haja
@since 		06/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------
User Function ReCalc()

Local aArea		:= GetArea()
Local cProduto  := ""
Local cMens		:= ""
Local nI
Local nTotVRent	:= 0
Local nTotValor	:= 0
Local nTotPont	:= 0
Local nTotImpos := 0
Local nTotMBR	:= 0
Local cTipoProd := ""
Local objQualy	:= LibQualyQuimica():New()

If objQualy:isSale()
	If !Empty(M->C5_ZZCDFXV)
		If LinhaAtual()
			For nI:= 1 to Len(aCols)
				If !(aCols[nI][Len(aHeader)+1])
					cProduto := aCols[nI,GdFieldPos("C6_PRODUTO")]
					cTipoProd := RetField("SB1",1,xFilial("SB1")+AllTrim(cProduto),"B1_TIPO")
					If (cTipoProd!='SV')
						PegaPerc(nI,cProduto)
						U_GeraVal(nI)
						SomaRent(nI,@nTotVRent,@nTotValor,@nTotPont,@nTotImpos,@nTotMBR)
					Endif
				Endif	
			Next nI
			GravaRent(nTotVRent,nTotValor,nTotPont,nTotImpos,nTotMBR)
		Else
			cMens := "Atenção, item atual não foi finalizado. "
			cMens += CHR(13) + CHR(10)
			cMens += "Preencha os campos obrigatórios antes de processar."
			MsgAlert(cMens)
			U_ZerEBIT()
		Endif
	Else
		cMens := "Atenção, pedido não possui Faixa de Premiação do Vendedor informado no cabeçalho."
		cMens += CHR(13) + CHR(10)
		cMens += "Cálculo de Rentabilidade não foi processado!"
		MsgAlert(cMens)
		U_ZerEBIT()
	Endif
ElseIf objQualy:isEstq()
	If LinhaAtual()
		For nI:= 1 to Len(aCols)
			If !(aCols[nI][Len(aHeader)+1])
				ZeraLote(nI,cProduto)
			Endif	
		Next nI
	Else
		cMens := "Atenção, item atual não foi finalizado. "
		cMens += CHR(13) + CHR(10)
		cMens += "Preencha os campos obrigatórios antes de processar."
		MsgAlert(cMens)
	Endif
Endif

freeObj(objQualy)
RestArea(aArea)
Return

Static Function PegaPerc(nI,cProduto)
If M->C5_ZZPEDAN <> "S" //Para pedidos do Sistema legado, não pode calcular comissão, será digitado % manualmente.
	aCols[nI,GdFieldPos("C6_COMIS1")] := U_RetCom("SZ2",M->C5_ZZCDFXV,cProduto)
	aCols[nI,GdFieldPos("C6_COMIS2")] := U_RetCom("SZ3",M->C5_ZZCDFXR,cProduto)
	aCols[nI,GdFieldPos("C6_COMIS3")] := U_RetCom("SZ2",M->C5_ZCDFXR3,cProduto)
	aCols[nI,GdFieldPos("C6_COMIS4")] := U_RetCom("SZ3",M->C5_ZCDFXR4,cProduto)
EndIf
aCols[nI,GdFieldPos("C6_ZZPFRET")] := IIf( M->C5_TPFRETE=="F", 0, SuperGetMv("MV_ZZPFRET",.T.,0) )
aCols[nI,GdFieldPos("C6_ZZPDPAD")] := SuperGetMv("MV_ZZPDPAD",.T.,0)
aCols[nI,GdFieldPos("C6_ZZPPDD")]  := SuperGetMv("MV_ZZPPDD",.T.,0)
aCols[nI,GdFieldPos("C6_ZZPPONT")] := Val(M->C5_ZZPPONT)
aCols[nI,GdFieldPos("C6_ENTREG")]  := IIf(!Empty(M->C5_FECENT),M->C5_FECENT,Date())
If ValType(lzCpy) == "L"
	If lzCpy
		aCols[nI,GdFieldPos("C6_LOTECTL")] := ""
		aCols[nI,GdFieldPos("C6_DTVALID")] := CtoD("")
	Endif	
Endif	
Return

Static Function ZeraLote(nI,cProduto)
aCols[nI,GdFieldPos("C6_ENTREG")] := IIf(!Empty(M->C5_FECENT),M->C5_FECENT,Date())
If ValType(lzCpy) == "L"
	If lzCpy
		aCols[nI,GdFieldPos("C6_LOTECTL")] := ""
		aCols[nI,GdFieldPos("C6_DTVALID")] := CtoD("")
	Endif	
Endif	
Return

Static Function LinhaAtual()
Local lRetorno := .T.
Local cProduto := aCols[n,GdFieldPos("C6_PRODUTO")]
Local nQtdVen  := aCols[n,GdFieldPos("C6_QTDVEN")]
Local nPrcVen  := aCols[n,GdFieldPos("C6_PRCVEN")]
Local lDelete  := aCols[n][Len(aHeader)+1]

If (Empty(cProduto)) .Or. (nQtdVen <= 0) .Or. (nPrcVen <= 0)
	If !lDelete
		lRetorno := .F.
	Endif	
Endif
Return lRetorno

Static Function SomaRent(nI,nTotVRent,nTotValor,nTotPont,nTotImpos,nTotMBR)
If !(aCols[nI,Len(aHeader)+1])
	nTotVRent	+= aCols[nI,GdFieldPos("C6_ZZVRENT")]
	nTotValor	+= aCols[nI,GdFieldPos("C6_QTDVEN")] * aCols[nI,GdFieldPos("C6_PRCVEN")]
	nTotImpos	+= aCols[nI,GdFieldPos("C6_ZZVIMPO")]
	nTotPont	+= aCols[nI,GdFieldPos("C6_ZZVPONT")]
	nTotMBR		+= aCols[nI,GdFieldPos("C6_ZZVMBR")]
Endif
Return

Static Function GravaRent(nTotVRent,nTotValor,nTotPont,nTotImpos,nTotMBR)
M->C5_ZZVEBIT := nTotVRent
M->C5_ZZPEBIT := ((nTotVRent / (nTotValor-nTotImpos)) * 100)
M->C5_ZZVPONT := nTotPont
M->C5_ZZVMBR  := nTotMBR
M->C5_ZZPMBR  := (nTotMBR / (nTotValor-nTotImpos) * 100)
Return
