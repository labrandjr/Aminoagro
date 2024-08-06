#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o MT410TOK

Este ponto de entrada � executado ao clicar no bot�o OK e pode ser usado para validar a confirma��o das opera��es: incluir,  alterar, copiar e excluir.

@author 	Augusto Krejci Bem-Haja
@since 		01/02/2016
@return		Booleano
/*/
//-----------------

User Function MT410TOK()

Local aArea    := GetArea()
Local lRetorno := .T.
Local lRecalc  := .F.
Local lRemBri  := .F.
Local lRemBon  := .F.
Local cTesRmb  := AllTrim(GetMv("MV_XTESRMB")) // TES para Remessa de Brindes
Local cTesBon  := AllTrim(GetMv("MV_XTESBON")) // TES para Bonifica��o
Local cTesRTr  := AllTrim(GetMv("MV_XTESRTR")) // TES para Remessa de Trocas
Local nPosXCus := aScan(aHeader,{|x|Alltrim(x[2])=="C6_CCUSTO"})
Local nPosItCt := aScan(aHeader,{|x|Alltrim(x[2])=="C6_ZZITCTB"})
Local lIncorp  := ( FunName() == "INCPEDV" ) // Incorpora��o
Local lFinan   := .F.
Local lBlqSap  := GetMv("MV_ZBLQSAP")
Local nI

If lBlqSap
	MsgInfo("Bloqueio migra��o Sap !")
	Return(.F.)
Endif

If PARAMIXB[1] == 1 // Exclus�o
	Return(.T.)
Endif

If FunName() == "MATA311" // Transfer�ncia de Filiais
	Return(.T.)
Endif

// Verifica se o Projeto foi informado
If Empty(M->C5_XPRJAMI) .And. ((M->C5_COPMOD2 != "S" .And. Inclui) .Or. (M->C5_COPMOD2 == "S" .And. Altera))
	MsgAlert("Informe o Projeto.")
	Return(.F.)
Endif

// Verifica se o Ebitda foi digitado
If cFilAnt != "0101" .And. !lIncorp
	If Empty(M->C5_ZEBTDIG) .And. M->C5_TIPO == "N" .And. ((M->C5_COPMOD2 != "S" .And. Inclui) .Or. (M->C5_COPMOD2 == "S" .And. Altera)) .And. Empty(M->C5_ZARQCSV)
		If MsgYesNo("Pedido com Simulador ?","Aviso","INFO")
			MsgInfo("Informe o Ebitda Real/Total.")
			Return(.F.)
		Endif
	Endif
Endif

// Vendedor1 em branco com Faixa de comiss�o1 informada
If Empty(M->C5_VEND1) .And. !Empty(M->C5_ZZCDFXV) .And. !lIncorp
	MsgAlert("Faixa de Comiss�o informada para o Vendedor1 sem relacionamento.")
	Return(.F.)
Endif

// Vendedor2 em branco com Faixa de comiss�o2 informada
If Empty(M->C5_VEND2) .And. !Empty(M->C5_ZZCDFXR) .And. !lIncorp
	MsgAlert("Faixa de Comiss�o informada para o Vendedor2 sem relacionamento.")
	Return(.F.)
Endif

// Vendedor3 em branco com Faixa de comiss�o3 informada
If Empty(M->C5_VEND3) .And. !Empty(M->C5_ZCDFXR3) .And. !lIncorp
	MsgAlert("Faixa de Comiss�o informada para o Vendedor3 sem relacionamento.")
	Return(.F.)
Endif

// Vendedor4 em branco com Faixa de comiss�o4 informada
If Empty(M->C5_VEND4) .And. !Empty(M->C5_ZCDFXR4) .And. !lIncorp
	MsgAlert("Faixa de Comiss�o informada para o Vendedor4 sem relacionamento.")
	Return(.F.)
Endif

// Verifica se o pedido gera financeiro
For nI:= 1 to Len(aCols)
	If !(aCols[nI][Len(aHeader)+1])
		cTesIt := aCols[nI][GdFieldPos("C6_TES")]
		lFinan := (Posicione("SF4",1,xFilial("SF4") + cTesIt,"F4_DUPLIC") == "S")
		If lFinan
			Exit
		Endif
	Endif	
Next nI

// Condi��o de pagamento Tipo 9 sem valores e/ou datas informados.
If lFinan .And. !lIncorp
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + M->C5_CONDPAG )
	If SE4->E4_TIPO == "9"
		If Empty(M->C5_DATA1) .And. Empty(M->C5_DATA2) .And. Empty(M->C5_DATA3) .And. Empty(M->C5_DATA4)
			MsgAlert("Informe o(s) vencimento(s) da(s) parcela(s) para condi��o de pagamento Tipo 9.")
			Return(.F.)
		ElseIf Empty(M->C5_PARC1) .And. Empty(M->C5_PARC2) .And. Empty(M->C5_PARC3) .And. Empty(M->C5_PARC4)
			MsgAlert("Informe o(s) valor(es) da(s) parcela(s) para condi��o de pagamento Tipo 9.")
			Return(.F.)
		ElseIf !Empty(M->C5_DATA1) .And. M->C5_DATA1 < dDatabase
			MsgAlert("Vencimento1 menor que a data atual.")
			Return(.F.)
		ElseIf !Empty(M->C5_DATA2) .And. M->C5_DATA2 < dDatabase
			MsgAlert("Vencimento2 menor que a data atual.")
			Return(.F.)
		ElseIf !Empty(M->C5_DATA3) .And. M->C5_DATA3 < dDatabase
			MsgAlert("Vencimento3 menor que a data atual.")
			Return(.F.)
		ElseIf !Empty(M->C5_DATA4) .And. M->C5_DATA4 < dDatabase
			MsgAlert("Vencimento4 menor que a data atual.")
			Return(.F.)
		Endif
	Endif
Endif

// Condi��o de pagamento Tipo # 9 com valores e/ou datas informados.
If lFinan .And. !lIncorp
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + M->C5_CONDPAG )
	If SE4->E4_TIPO != "9"
		If !Empty(M->C5_DATA1) .Or. !Empty(M->C5_DATA2) .Or. !Empty(M->C5_DATA3) .Or. !Empty(M->C5_DATA4)
			MsgAlert("Vencimento(s) de parcela(s) informado(s) para condi��o de pagamento com Tipo # 9.")
			Return(.F.)
		ElseIf !Empty(M->C5_PARC1) .Or. !Empty(M->C5_PARC2) .Or. !Empty(M->C5_PARC3) .Or. !Empty(M->C5_PARC4)
			MsgAlert("Valor(es) de parcela(s) informado(s) para condi��o de pagamento com Tipo # 9.")
			Return(.F.)
		Endif
	Endif
Endif

// Avalia se trata-se de opera��o de Remessa de Brindes
For nI:= 1 to Len(aCols)
	If !(aCols[nI][Len(aHeader)+1])
		cTesIt := aCols[nI][GdFieldPos("C6_TES")]
		If cTesIt $(cTesRmb)
			lRemBri := .T.
			Exit
		Endif
	Endif	
Next nI

If !lRemBri .And. !lIncorp
	If Empty(M->C5_VEND1)
		MsgAlert("Aten��o, 'Vendedor1' n�o informado.")
		Return(.F.)
	ElseIf Empty(M->C5_ZZITCTB)
		MsgAlert("Aten��o, 'UN Negocio' n�o informada. Informe novamente o Vendedor1.")
		Return(.F.)
	ElseIf Empty(M->C5_ZZREGVE)
		MsgAlert("Aten��o, 'Regi�o Vend' n�o informada. Informe novamente o Vendedor1.")
		Return(.F.)
	Endif
Endif

// Avalia se trata-se de opera��o de Bonifica��o
For nI:= 1 to Len(aCols)
	If !(aCols[nI][Len(aHeader)+1])
		cTesIt := aCols[nI][GdFieldPos("C6_TES")]
		If cTesIt $(cTesBon)
			lRemBon := .T.
			Exit
		Endif
	Endif	
Next nI

If lRemBon .And. !lIncorp
	If Empty(M->C5_ZZTPBON)
		MsgAlert("Aten��o, tipo de bonifica��o n�o informado.")
		Return(.F.)
	Endif
Endif

// Checa se foi informado Tipo de Bonifica��o x TES com integra��o financeira
If !Empty(M->C5_ZZTPBON) .And. !lIncorp
	If lFinan
		MsgAlert("Aten��o, informado 'Tipo de Bonifica��o' com integra��o financeira.")					
		Return(.F.)
	Endif
Endif

// Opera��es de remessa de troca
lTrcOk := .T.
lRemTr := .F. 
If !lIncorp
	For nI:= 1 to Len(aCols)
		If !(aCols[nI][Len(aHeader)+1])
			cTesIt := aCols[nI][GdFieldPos("C6_TES")]
			lRemTr := (cTesIt $(cTesRTr))
			If lRemTr
				zNfTro := aCols[nI][GdFieldPos("C6_ZZNFTRO")]
				If Empty(zNfTro)
					MsgAlert("Aten��o, para opera��es de 'Remessa de Troca' � obrigat�rio vincular o Item � 'Nota Fiscal de Entrada de Troca'.")					
					lTrcOk := .F.
					Exit
				Else
					DbSelectArea("SD1")
					DbSetOrder(1)
					If !DbSeek( xFilial("SD1") + zNfTro )
						MsgAlert("Aten��o, v�nculo inv�lido com a 'Nota Fiscal de Entrada de Troca'.")
						lTrcOk := .F.
						Exit
					Else
						// Se o CC ou BU do vendedor do pedido for diferente do CC ou BU do documento de entrada vinculado, faz a pergunta
						If AllTrim(aCols[nI][nPosXCus]) <> AllTrim(SD1->D1_CC) .Or. AllTrim(aCols[nI][nPosItCt]) <> AllTrim(SD1->D1_ITEMCTA)
							If MsgYesNo("Retorno de Troca: deseja considerar o C.Custo da Nota Fiscal de Entrada de Troca ?","Aviso")
								aCols[nI][nPosXCus] := SD1->D1_CC
								aCols[nI][nPosItCt] := SD1->D1_ITEMCTA
							Endif
						Endif	
					Endif
				Endif	
			Endif
		Endif	
	Next nI
	If !lTrcOk
		Return(.F.)
	Endif
Endif

If !lIncorp
	lRetorno := VldCCusto(lRemBri,lRemTr) // Luis Brandini - 11/01/2017. Tratamento para valida��o do C.Custo.
Endif	

If lRetorno .And. !lIncorp
	lRetorno := VldEmbalg() // Luis Brandini - 17/05/2017. Tratamento para valida��o de Embalagens.
Endif

If lRetorno
	If Inclui
		lRecalc := .T.
	ElseIf Altera
		//If MsgYesNo("Deseja reprocessar as Regras de Vendas?","Aten��o") // Desativado em 19/12/2019 - E-mail Sandra
			lRecalc := .T.
		//Endif
	Endif
	If lRecalc
		U_ReCalc()
	Endif
Endif

RestArea(aArea)

Return(lRetorno)

// Luis Brandini - 11/01/2017
Static Function VldCCusto(lRemBri,lRemTr)

Local lCCok   := .T.
Local lAvalia := .F.
Local cCCVend := ""
Local lErrCd  := .F.
Local lErrSt  := .F.
Local lErrBl  := .F.
Local lErrBu  := .F.
Local nI

For nI:= 1 to Len(aCols)
	If !(aCols[nI][Len(aHeader)+1])
		cCCItem := aCols[nI][GdFieldPos("C6_CCUSTO")]
		DbSelectArea("CTT")
		DbSetOrder(1)
		If !DbSeek( xFilial("CTT") + cCCItem )
			lErrCd := .T.
			Exit
		ElseIf CTT->CTT_CLASSE == "1"
			lErrSt := .T.
			Exit
		ElseIf CTT->CTT_BLOQ == "1"
			lErrBl := .T.
			Exit
		ElseIf Empty(CTT->CTT_ZZITCT)
			lErrBu := .T.
			Exit
		Endif
	Endif	
Next nI
If lErrCd
	MsgAlert("Aten��o, centro de custo n�o cadastrado! "+AllTrim(cCCItem))
	lCCok := .F.
Endif
If lErrSt
	MsgAlert("Aten��o, centro de custo 'sint�tico' n�o permitido! "+AllTrim(cCCItem))
	lCCok := .F.
Endif
If lErrBl
	MsgAlert("Aten��o, centro de custo 'bloqueado' n�o permitido! "+AllTrim(cCCItem))
	lCCok := .F.
Endif
If lErrBu
	MsgAlert("Aten��o, centro de custo sem 'Un Negocio' (BU) n�o permitido! "+AllTrim(cCCItem))
	lCCok := .F.
Endif
If lCCok // Caso o Centro de Custo estiver Ok
	If !Empty(M->C5_VEND1)
		cCCVend := RetField("SA3",1,xFilial("SA3") + M->C5_VEND1,"A3_ZZCC")
		If !Empty(cCCVend)
			lAvalia := .T.
		Endif
	Endif
	If lAvalia
		lErrSv := .F. // Servi�o
		lErrCC := .F. // C.Custo Item x Vendedor
		For nI:= 1 to Len(aCols)
			If !(aCols[nI][Len(aHeader)+1])
				cCodPro := aCols[nI][GdFieldPos("C6_PRODUTO")]
				cCCItem := aCols[nI][GdFieldPos("C6_CCUSTO")]
				zItemPv := aCols[nI][GdFieldPos("C6_ITEM")]
				lEntreg := .F.
				//
				If Altera
					DbSelectArea("SC6")
					DbSetOrder(1)
					DbSeek( xFilial("SC6") + M->C5_NUM + zItemPv )
					lEntreg := ( SC6->C6_QTDENT > 0 .Or. !Empty(SC6->C6_BLQ) )
				Endif
				//
				If AllTrim(cCodPro) == "SERV0001"
					If AllTrim(cCCItem) != "106040801001"
                    	lErrSv := .T.
                    	Exit
                    Endif	
				ElseIf AllTrim(cCCItem) != AllTrim(cCCVend) .And. !lEntreg
					lErrCC := .T.
					Exit
				Endif
			Endif	
		Next nI
		If lErrSv
			MsgAlert("Para SERVI�O informe o centro de custo '106040801001'.")
 			lCCok := .F.
		Endif
		If lErrCC
			If !lRemBri .And. !lRemTr
				MsgAlert("Diverg�ncias de centro de custo: itens do pedido x Vendedor 1.","Aten��o","INFO")
				lCCok := .F.
			Else // Opera��es de Remessa de Brindes ou Remessa de Troca
				If !MsgYesNo("Diverg�ncias de centro de custo: itens do pedido x Vendedor 1. Deseja continuar ?","Aten��o","INFO")
					lCCok := .F.
				Endif	
			Endif	
		Endif
	Endif
Endif

Return(lCCok)

// Luis Brandini - 17/05/2017
Static Function VldEmbalg()

Local aArea    := GetArea()
Local aItEmb   := {}
Local lVldEmb  := ( AllTrim(GetMv("MV_XVLDEMB"))=="S" )
Local lRetorno := .T.
Local nI

If lVldEmb
	For nI:= 1 to Len(aCols)
		If !(aCols[nI][Len(aHeader)+1])
			zCodPro := aCols[nI][GdFieldPos("C6_PRODUTO")]
			zTipSai := aCols[nI][GdFieldPos("C6_TES")]
			zTipoPr := RetField("SB1",1,xFilial("SB1")+zCodPro,"B1_TIPO")
			//
			lVend := ( M->C5_TIPO == "N" )
			lEstq := ( RetField("SF4",1,xFilial("SF4")+zTipSai,"F4_ESTOQUE") == "S" )
			lAddP := .F.
			If lVend .And. lEstq
				If zTipoPr == "PA"
					DbSelectArea("SG1")
					DbSetOrder(1)
					If DbSeek( xFilial("SG1") + zCodPro )
	                	lAddP := .T.
					Endif
				ElseIf zTipoPr == "PR"
					lAddP := .T.
				Endif	
			Endif
			If lAddP
				zPedi := M->C5_NUM
				zItem := aCols[nI][GdFieldPos("C6_ITEM")]
				zSequ := ""
				zProd := zCodPro
				If aCols[nI][GdFieldPos("C6_QTDLIB")] > 0
					zQtde := aCols[nI][GdFieldPos("C6_QTDLIB")]
				Else
					zQtde := aCols[nI][GdFieldPos("C6_QTDVEN")]
				Endif	
				AAdd(aItEmb,{zPedi, zItem, zSequ, zProd, zQtde, "PED"})
			Endif
		Endif	
	Next nI
Endif

If Len(aItEmb) > 0
	lRetorno := u_VldEmblg(aItEmb)
Endif

RestArea(aArea)

Return(lRetorno)
