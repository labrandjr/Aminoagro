#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MAAVCRED  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 22/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avaliação de Crédito de Clientes por CNPJ.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MAAVCRED()
 
Local aArea   := GetArea()
Local cCodCli := PARAMIXB[1]
Local cLojCli := PARAMIXB[2]
Local nValor  := IIf(SC5->C5_TIPLIB == "2", _VlrLibPed(SC5->C5_NUM), PARAMIXB[3])
Local nMoeda  := PARAMIXB[4]
Local lPedido := PARAMIXB[5]
//
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local aStruSA1 := {}
Local cQuery   := ""
Local cAliasSA1:= "SA1"
Local cAliasQry:= ""
Local nLimCred := 0
Local nLimCredFin := 0
Local nVlrReal := xMoeda(nValor,nMoeda,1,dDataBase,2)
Local nVlrFin  := 0
Local nVlrPed  := nVlrReal
Local nLiminCr := SuperGetMv("MV_LIMINCR") //Limite Minimo de Credito
Local nPerMax  := SuperGetMv("MV_PERMAX")  //Percentual Maximo comprometido com o Limite de Credito
Local nFaixaA  := SuperGetMv("MV_PEDIDOA") //Limite de Credito para a Faixa A
Local nFaixaB  := SuperGetMv("MV_PEDIDOB") //Limite de Credito para a Faixa B
Local nFaixaC  := SuperGetMv("MV_PEDIDOC") //Limite de Credito para a Faixa C
Local nNumDias := 0
Local nRegEmp  := 0
Local nMCusto  := 0
Local nX       := 0
Local lQuery   := .F.
Local lAgrpCrd := .F.
Local lAgrpCgc := .F.
Local cAgrupCr := ""
Local cCgcCli  := Substr(SA1->A1_CGC,1,8) // Base do Cgc da Matriz
Local lRetorno := .T.
Local xRetorno := ""
Local aEmpenho := {}
Local nVlrCred := 0
Local lAgrpLim := (GetMv("MV_AGRPLIM") == "S")
Local _v

Public zCodCli  := cCodCli
Public zLojCli  := cLojCli
Public zAgrpCrd := .F.
Public zAgrpCgc := .F.
Public zCodigo  := ""
Public zMotBlq  := ""

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCodCli+cLojCli)
nRecSa1 := SA1->(Recno()) // Cliente+Loja do Pedido

If lAgrpLim // Agrupamento de Crédito = Habilitado
	If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
		lAgrpCrd := .T.
		cAgrupCr := SA1->A1_ZZAGCRD
	Else
		If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
			dbSelectArea("SA1")
			dbSetOrder(1)
			If !dbSeek(xFilial("SA1")+SA1->A1_ZZAGCRD)
				dbSelectArea("SA1")
				dbSetOrder(1)
				SA1->(DbGoto(nRecSa1)) // Restaura cliente+loja do Pedido
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
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL1",.T.,.T.)
			lAgrpCrd := (SQL1->SOMA > 0)
			SQL1->(DbCloseArea())
			If !lAgrpCrd
				dbSelectArea("SA1")
				dbSetOrder(1)
				SA1->(DbGoto(nRecSa1)) // Restaura cliente+loja do Pedido
			Else
				cAgrupCr := SA1->A1_COD
			Endif	
		Endif
	Endif
	// Se não for agrupamento de crédito, verifica se existe agrupamento pela Base do Cnpj
	If !lAgrpCrd
		dbSelectArea("SA1")
		dbSetOrder(3)
		If !dbSeek(xFilial("SA1")+cCgcCli+"0001")
			dbSelectArea("SA1")
			dbSetOrder(1)
			SA1->(DbGoto(nRecSa1)) // Restaura cliente+loja do Pedido
		Else
			nRecSa1  := SA1->(Recno()) // Matriz - Base do Cnpj
			lAgrpCgc := .T.
		Endif
	Endif
Endif

zAgrpCrd := lAgrpCrd
zAgrpCgc := lAgrpCgc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aqui e verificado apenas o Codigo ( Matriz )                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//If ( MsSeek(xFilial("SA1")+cCodCli) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O Grau de Risco deve ser Avaliado da Matriz                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SA1->A1_RISCO == "A" )
		lRetorno := .T.
		zCodigo  := ""
	EndIf
	If ( SA1->A1_RISCO == "E" .And. nVlrCred<=0)
		lRetorno := .F.
		zCodigo  := "01" // Limite de Credito
		zMotBlq  := "RISCO E"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aqui e avaliado a condição de pagamento do Pedido		              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SC5->C5_ZZITCTB)
		If AllTrim(SC5->C5_ZZITCTB) == "BU4"
			zMxCp := GetMv("MV_PRZBLQX")
		Else
			zMxCp := GetMv("MV_PRZBLQ4")
		Endif
		//
		zCondPag := SC5->C5_CONDPAG
		zData1   := SC5->C5_DATA1
		zData2   := SC5->C5_DATA2
		zData3   := SC5->C5_DATA3
		zData4   := SC5->C5_DATA4
		DbSelectArea("SZG")
		DbSetOrder(1)
		If DbSeek( xFilial("SZG") + SC5->C5_NUM + Space(9) )
			zCondPag := SZG->ZG_CONDPAG
			zData1   := SZG->ZG_DATA1
			zData2   := SZG->ZG_DATA2
			zData3   := SZG->ZG_DATA3
			zData4   := SZG->ZG_DATA4
		Endif
        //
		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek( xFilial("SE4") + zCondPag )
		If SE4->E4_TIPO == "9"
			If !Empty(zData1)
				zDias := zData1 - dDatabase
				If zDias > zMxCp
					lRetorno := .F.
					zCodigo  := "01" // Limite de Credito
					zMotBlq  := "CONDICAO DE PAGAMENTO ULTRAPASSA "+AllTrim(STR(zMxCp))+" DIAS"
				Endif
			ElseIf !Empty(zData2)
				zDias := zData2 - dDatabase
				If zDias > zMxCp
					lRetorno := .F.
					zCodigo  := "01" // Limite de Credito
					zMotBlq  := "CONDICAO DE PAGAMENTO ULTRAPASSA "+AllTrim(STR(zMxCp))+" DIAS"
				Endif
			ElseIf !Empty(zData3)
				zDias := zData3 - dDatabase
				If zDias > zMxCp
					lRetorno := .F.
					zCodigo  := "01" // Limite de Credito
					zMotBlq  := "CONDICAO DE PAGAMENTO ULTRAPASSA "+AllTrim(STR(zMxCp))+" DIAS"
				Endif
			ElseIf !Empty(zData4)
				zDias := zData4 - dDatabase
				If zDias > zMxCp
					lRetorno := .F.
					zCodigo  := "01" // Limite de Credito
					zMotBlq  := "CONDICAO DE PAGAMENTO ULTRAPASSA "+AllTrim(STR(zMxCp))+" DIAS"
				Endif
			Endif	
		Else
			aVenc := Condicao(nVlrPed, zCondPag, 0, dDatabase, 0)
			For _v := 1 to Len(aVenc)
				zDias := aVenc[_v][1] - dDatabase
				If zDias > zMxCp
					lRetorno := .F.
					zCodigo  := "01" // Limite de Credito
					zMotBlq  := "CONDICAO DE PAGAMENTO ULTRAPASSA "+AllTrim(STR(zMxCp))+" DIAS"
					Exit
				Endif
			Next _v
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aqui e avaliado o Vencimento do Limite de Credito do Cliente            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase .And. lRetorno )
		lRetorno := .F.
		zCodigo  := "04" // Vencimento do Limite de Credito
		zMotBlq  := "VENCIMENTO DO LIMITE DE CREDITO"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aqui e verificado o Limite de Credito do Cliente                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O Limite de Credito sempre esta na Moeda MV_MCUSTO, mas os calculos sao ³
	//³em na moeda corrente.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SA1->A1_RISCO <> "A" .And. !(SA1->A1_RISCO $ "E,Z" .And. nVlrCred<=0) .And. lRetorno )
		nLimCred := 0
		nLimCredFin	:= 0	
		dbSelectArea("SA1")
		dbSetOrder(1)				
//		#IFDEF TOP
			cAliasSA1 := "QRYSA1"
			lQuery    := .T.

			aStruSa1  := SA1->(dbStruct())

			cQuery := "SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_CGC,A1_ZZAGCRD,A1_MOEDALC,A1_LC,A1_LCFIN,A1_SALFIN,A1_SALDUP,A1_SALPEDL,A1_VENCLC,A1_RISCO,R_E_C_N_O_ RECSA1 "
			cQuery += " FROM "+RetSqlName("SA1")+" SA1 "
			cQuery += "WHERE "
			cQuery += "A1_FILIAL = '"+xFilial("SA1")+"' AND "
			//cQuery += "A1_COD = '"+cCodCli+"' AND "
			If lAgrpCrd
				cQuery += "((A1_COD = '"+cAgrupCr+"') OR (A1_ZZAGCRD = '"+cAgrupCr+"')) AND "
			ElseIf lAgrpCgc
				cQuery += "SUBSTR(A1_CGC,1,8) = '"+cCgcCli+"' AND "
			Else
				cQuery += "A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND "
			Endif	
			cQuery += "SA1.D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SA1->(IndexKey()))					

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1,.T.,.T.)

			For nX := 1 To Len(aStruSA1)
				If aStruSA1[nX,1]$"A1_FILIAL,A1_COD,A1_MOEDALC,A1_LC,A1_LCFIN,A1_SALFIN,A1_SALDUP,A1_SALPEDL,A1_VENCLC"						
					If aStruSA1[nX,2] <> "C" .And. FieldPos(aStruSA1[nX,1])<>0
						TcSetField(cAliasSA1,aStruSA1[nX,1],aStruSA1[nX,2],aStruSA1[nX,3],aStruSA1[nX,4])
					EndIf						
				EndIf
			Next nX

//		#ELSE
//			MsSeek(xFilial("SA1")+cCodCli)
//		#ENDIF
//		nMCusto	:= IIf((cAliasSA1)->A1_MOEDALC > 0,(cAliasSA1)->A1_MOEDALC,Val(SuperGetMv("MV_MCUSTO")))
		nMCusto	:= Val(SuperGetMv("MV_MCUSTO"))
		nVlrCred := xMoeda(nVlrCred,nMoeda,1,dDataBase,2)
		nLimCred := 0
//		While ( !Eof() .And. xFilial("SA1") == (cAliasSA1)->A1_FILIAL .And. cCodCli == (cAliasSA1)->A1_COD .And. lRetorno)
		While ( !Eof() .And. lRetorno )
			If !(cAliasSA1)->A1_RISCO$"E,Z"
				nLimCred += xMoeda((cAliasSA1)->A1_LC,nMCusto,1,dDataBase,2)
			Else
				nLimCred += 0
			EndIf
			If (cAliasSA1)->A1_LCFIN >= 0
				nLimCredFin	+= xMoeda((cAliasSA1)->A1_LCFIN,nMCusto,1,dDataBase,MsDecimais(1))
				nVlrFin 	+= (cAliasSA1)->A1_SALFIN
			EndIf	
			If ( lPedido )
				nVlrAnt := nVlrReal
				If nVlrCred < nVlrReal
					nVlrReal += (cAliasSA1)->A1_SALDUP + xMoeda((cAliasSA1)->A1_SALPEDL,nMCusto,1,dDatabase,2)
					If nVlrReal < 0
						nVlrReal := nVlrAnt
					Endif
				Else
					nVlrReal -= nVlrCred
					nLimCred -= (cAliasSA1)->A1_SALDUP + xMoeda((cAliasSA1)->A1_SALPEDL,nMCusto,1,dDatabase,2)
				EndIf
				If ( aEmpenho <> Nil ) .And. ( !Empty(aEmpenho) )
					nRegEmp  := aScan(aEmpenho[1],{|x| x[1]==IIf(lQuery,(cAliasSA1)->RECSA1,SA1->(RecNo())) })
					If ( nRegEmp <> 0 )
						nVlrReal += xMoeda(aEmpenho[1][nRegEmp][2],nMCusto,1,dDatabase,2)
					EndIf
					If ( nRegEmp <> 0 )
						nVlrFin += aEmpenho[1][nRegEmp][3]
					EndIf
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aqui e avaliado o Vencimento do Limite de Credito do Cliente            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( !Empty((cAliasSA1)->A1_VENCLC) .And. (cAliasSA1)->A1_VENCLC < dDataBase ) .And. nVlrCred <= 0
				lRetorno := .F.
				zCodigo  := "04" // Vencimento do Limite de Credito
				zMotBlq  := "VENCIMENTO DO LIMITE DE CREDITO"
			EndIf
			dbSelectArea(cAliasSA1)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSA1)
			dbCloseArea()
			dbSelectArea("SA1")
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o Valor nao eh maior que o Limite de Credito                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lRetorno .And. nVlrReal > nLimCred .And. nVlrReal > 0)
			lRetorno := .F.
			zCodigo  := "01" // Limite de Credito
			zMotBlq  := "LIMITE DE CREDITO INDISPONIVEL"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle de limite de credito secundario                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno .And. nVlrFin > nLimCredFin .And. nLimCredFin > 0
			lRetorno := .F.
			zCodigo := "01" // Limite de Credito
			zMotBlq  := "LIMITE SECUNDARIO INDISPONIVEL"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica as Classes de Cliente                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nVlrReal > 0
			dbSelectArea("SA1")
			dbSetOrder(1)
			//MsSeek(xFilial("SA1")+cCodCli)
			SA1->(DbGoto(nRecSa1))
			Do Case
			Case ( lRetorno .And. nVlrReal <= nLiMinCr )
				lRetorno := .T.
				zCodigo  := ""
			Case ( lRetorno .And. nVlrReal > ((nPerMax * nLimCred) / 100) )
				lRetorno := .F.
				zCodigo  := "01" // Limite de Credito
				zMotBlq  := "(%)LIMITE DE CREDITO INDISPONIVEL"
			Case ( lRetorno .And. SA1->A1_CLASSE == "A" .And. nVlrPed > nfaixaA .And. nFaixaA <> 0 )
				lRetorno := .F.
				zCodigo  := "01" // Limite de Credito
				zMotBlq  := "LIMITE INDISPONIVEL (CLASSE A)"
			Case ( lRetorno .And. SA1->A1_CLASSE == "B" .And. nVlrPed > nfaixaB .And. nFaixaB <> 0 )
				lRetorno := .F.
				zCodigo  := "01" // Limite de Credito
				zMotBlq  := "LIMITE INDISPONIVEL (CLASSE B)"
			Case ( lRetorno .And. SA1->A1_CLASSE == "C" .And. nVlrPed > nfaixaC .And. nFaixaC <> 0 )
				lRetorno := .F.
				zCodigo  := "01" // Limite de Credito
				zMotBlq  := "LIMITE INDISPONIVEL (CLASSE C)"
			EndCase
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aqui e avaliado o risco do Cliente - ( Matriz + Filiais )   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( lRetorno .And. !Empty(SA1->A1_RISCO) .And. !SA1->A1_RISCO$"E,Z" )						
//				#IFDEF TOP
					dbSelectArea("SE1")
					dbSetOrder(8)

					cAliasQry  := "QRYAVALCRD"
					lQuery     := .T.

					cQuery := "SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_CGC,A1_ZZAGCRD,A1_RISCO,E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_TIPO,E1_VENCREA"
					cQuery += " FROM "+RetSqlName("SA1")+" SA1, "
					cQuery += RetSqlName("SE1")+" SE1 "
					cQuery += "WHERE "
					cQuery += "A1_FILIAL ='"+xFilial("SA1")+"' AND "
					//cQuery += "A1_COD = '"+cCodCli+"' AND "
					If lAgrpCrd
						cQuery += "((A1_COD = '"+cAgrupCr+"') OR (A1_ZZAGCRD = '"+cAgrupCr+"')) AND "
					ElseIf lAgrpCgc
						cQuery += "SUBSTR(A1_CGC,1,8) = '"+cCgcCli+"' AND "
					Else
						cQuery += "A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND "
					Endif	
					cQuery += "SA1.D_E_L_E_T_ = ' ' AND "												
					//cQuery += "E1_FILIAL = '"+xFilial("SE1")+"' AND "
					cQuery += "E1_CLIENTE = A1_COD AND "
					cQuery += "E1_LOJA = A1_LOJA AND "
					cQuery += "E1_STATUS = 'A' AND "
					cQuery += "SE1.D_E_L_E_T_ = ' ' "
					cQuery += "ORDER BY "+SqlOrder(StrTran(SE1->(IndexKey()),"E1_LOJA+",""))

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

					TcSetField(cAliasQry,"E1_VENCREA","D",8,0)

					While (cAliasQry)->(!Eof()) .And. lRetorno
						nNumDias := SuperGetMv("MV_RISCO"+SA1->A1_RISCO)
						If ( !(cAliasQry)->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !(cAliasQry)->E1_TIPO $ MVABATIM)
							If ( ( dDataBase - (cAliasQry)->E1_VENCREA ) >= nNumDias ) .And. ( dDataBase - (cAliasQry)->E1_VENCREA ) > 0
								lRetorno := .F.
								zCodigo  := "01" // Limite de Credito
								zMotBlq  := "TITULOS VENCIDOS"
								Exit
							EndIf
						EndIf

						dbSelectArea(cAliasQry)
						dbSkip()

					EndDo
					If lQuery
						dbSelectArea(cAliasQry)
						dbCloseArea()
						dbSelectArea("SA1")
					EndIf
/*				#ELSE
					dbSelectArea("SA1")
					dbSetOrder(1)
					MsSeek(xFilial("SA1")+cCodCli)
					While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
							cCodCli        == SA1->A1_COD )
						nNumDias := SuperGetMv("MV_RISCO"+SA1->A1_RISCO)
						dbSelectArea("SE1")
						dbSetOrder(8)
						MsSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA+"A")
						While ( !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And.;
								SE1->E1_CLIENTE== SA1->A1_COD .And.;
								SE1->E1_LOJA   == SA1->A1_LOJA .And.;
								SE1->E1_STATUS == "A" )
							If ( !SE1->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !SE1->E1_TIPO $ MVABATIM)
								If ( ( dDataBase - SE1->E1_VENCREA ) >= nNumDias )
									lRetorno := .F.
									zCodigo  := "01" // Limite de Credito
								EndIf
								Exit
							EndIf
							dbSelectArea("SE1")
							dbSkip()
						EndDo
						If ( !lRetorno )
							Exit
						EndIf
						dbSelectArea("SA1")
						dbSkip()
					EndDo
				#ENDIF */
			EndIf
		EndIf
	EndIf
//EndIf

xRetorno := zCodigo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Entrada da Rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA1)
RestArea(aAreaSE1)
RestArea(aArea)

Return( xRetorno )

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _VlrLibPed ¦ Autor ¦ Luis Brandini   ¦  Data  ¦ 20/09/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula o valor total conforme Tipo de Liberação.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _VlrLibPed(zPedido)

Local aArea   := GetArea()
Local nValLib := 0

If FunName() == "MATA450" // Análise de Crédito de Pedido de Venda - Automática
	nRecSC6 := SC6->(Recno())
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( xFilial("SC6") + SC5->C5_NUM )
	While !Eof() .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
		zQtdLib := IIf(SC6->C6_QTDLIB > 0, SC6->C6_QTDLIB, SC6->C6_QTDEMP)
		If zQtdLib > 0
			nValLib += zQtdLib * SC6->C6_PRCVEN
			DbSelectArea("SC9")
			DbSetOrder(1)
			If DbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
				While !Eof() .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM
					If Empty(SC9->C9_NFISCAL) // Não faturado
						If Empty(SC9->C9_BLCRED) // Crédito liberado
							nValLib -= zQtdLib * SC6->C6_PRCVEN
						Endif
					Endif
					SC9->(DbSkip())
				Enddo
			Endif
		Endif
		DbSelectArea("SC6")
		SC6->(DbSkip())
	Enddo
	SC6->(DbGoto(nRecSC6))
Else // Liberação de Pedidos de Venda
	cQuery := " SELECT SUM(C6_QTDLIB*C6_PRCVEN)AS TOTLIB "
	cQuery += " FROM "+RetSqlName("SC6")
	cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery += " AND C6_NUM = '"+zPedido+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"SQ6",.T.,.T.)
	nValLib := SQ6->TOTLIB
	SQ6->(DbCloseArea())
Endif

RestArea(aArea)

Return(nValLib)
