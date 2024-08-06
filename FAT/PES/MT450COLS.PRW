#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT450COLS ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 29/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Liberação de Crédito Pedido de Venda - por CNPJ.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT450COLS()

Local aArea      := GetArea()
Local aAreaSA1   := SA1->(GetArea())
Local aDados     := PARAMIXB[2]
Local zCgcCli    := Substr(SA1->A1_CGC,1,8)
Local zAgrupCr   := SA1->A1_ZZAGCRD
Local nMCusto    := Val(SuperGetMv("MV_MCUSTO"))
Local nLimCred   := 0
Local nSalPed    := 0
Local nSalPedL   := 0
Local nSalDup    := 0
Local nSalDupM   := 0
Local nSalFin    := 0
Local nLcFin     := 0
Local nSalFinM   := 0
Local nValAtraso := 0
Local lAgrpCrd   := .F.
Local lAgrpCgc   := .F.
Local cAgrupCr   := ""
Local cCgcCli    := Substr(SA1->A1_CGC,1,8) // Base do Cgc da Matriz
Local lAgrpLim   := (GetMv("MV_AGRPLIM") == "S")

If lAgrpLim // Agrupamento de Crédito = Habilitado

	If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
		lAgrpCrd := .T.
		cAgrupCr := SA1->A1_ZZAGCRD
	Else
		If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1")+SA1->A1_ZZAGCRD)
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
			If lAgrpCrd
				cAgrupCr := SA1->A1_COD
			Endif	
		Endif
	Endif
	// Se não for agrupamento de crédito, verifica se existe agrupamento pela Base do Cnpj
	If !lAgrpCrd
		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbSeek(xFilial("SA1")+cCgcCli+"0001")
			lAgrpCgc := .T.
		Endif
	Endif

	RestArea(aAreaSA1)

	cQuery := " SELECT A1_COD, A1_LOJA "
	cQuery += " FROM "+RetSqlName("SA1")
	cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	If lAgrpCrd
		cQuery += " AND ((A1_COD = '"+cAgrupCr+"') OR (A1_ZZAGCRD = '"+cAgrupCr+"')) "
	ElseIf lAgrpCgc
		cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+cCgcCli+"' "
	Else
		cQuery += " AND A1_COD = '"+SA1->A1_COD+"' "
		cQuery += " AND A1_LOJA = '"+SA1->A1_LOJA+"' "
	Endif	
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	DbSelectArea("SQL")
	SQL->(DbGotop())
	While !Eof()
		//
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SQL->A1_COD + SQL->A1_LOJA )
		//
		nMCustoCli := Val(SuperGetMv("MV_MCUSTO"))
		nLimCred   += xMoeda(SA1->A1_LC,nMCustoCli,nMCusto,dDataBase)
		nSalPed    += xMoeda(SA1->A1_SALPED+SA1->A1_SALPEDB,nMCustoCli,nMCusto,dDataBase)
		nSalPedL   += xMoeda(SA1->A1_SALPEDL,nMCustoCli,nMCusto,dDataBase)
		nSalDup    += SA1->A1_SALDUP
		nSalDupM   += xMoeda(SA1->A1_SALDUPM,nMCustoCli,nMCusto,dDataBase)
		nSalFin    += SA1->A1_SALFIN
		nLcFin     += xMoeda(SA1->A1_LCFIN,nMCustoCli,nMCusto,dDataBase)
		nSalFinM   += xMoeda(SA1->A1_SALFINM,nMCustoCli,nMCusto,dDataBase)
        //
		DbSelectArea("SQL")
		SQL->(DbSkip())
	Enddo
	SQL->(DbCloseArea())

	nSalvEmp := SM0->(Recno())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analisar o atraso de Todas as Filiais do Sistema                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SM0")
	DbSeek(cEmpAnt)
	While !Eof() .And. SM0->M0_CODIGO == cEmpAnt

		cQuery := " SELECT A1_COD, A1_LOJA "
		cQuery += " FROM "+RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
		If lAgrpCrd
			cQuery += " AND ((A1_COD = '"+cAgrupCr+"') OR (A1_ZZAGCRD = '"+cAgrupCr+"')) "
		ElseIf lAgrpCgc
			cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+cCgcCli+"' "
		Else
			cQuery += " AND A1_COD = '"+SA1->A1_COD+"' "
			cQuery += " AND A1_LOJA = '"+SA1->A1_LOJA+"' "
		Endif	
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()
			//
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SQL->A1_COD + SQL->A1_LOJA )
			//
			nValAtraso += _FtSomaAtr(SM0->M0_CODFIL)
	        //
			DbSelectArea("SQL")
			SQL->(DbSkip())
		Enddo
		SQL->(DbCloseArea())

		DbSelectArea("SM0")
		DbSkip()
	Enddo
	DbSelectArea("SM0")
	DbGoto(nSalvEmp)

	aDados[1][2] := Transform(xMoeda(nLimCred,nMCusto,1),PesqPict("SA1","A1_LC",17,1))
	aDados[1][3] := TRansform(nLimCred,PesqPict("SA1","A1_LC",17,nMcusto))

	aDados[2][2] := Transform(nSalDup,PesqPict("SA1","A1_SALDUP",17,1))
	aDados[2][3] := Transform(nSalDupM,PesqPict("SA1","A1_SALDUPM",17,nMcusto))

	aDados[3][2] := Transform(xMoeda(nSalPedL,nMCusto,1),PesqPict("SA1","A1_SALPEDL",17,1))
	aDados[3][3] := Transform(nSalPedL,PesqPict("SA1","A1_SALPEDL",17,nMcusto))

	aDados[4][2] := Transform(xMoeda(nLimCred-nSaldupM-nSalPedL,nMCusto,1),PesqPict("SA1","A1_SALDUP",17,1))
	aDados[4][3] := Transform(nLimCred-nSaldupM-nSalPedL,PesqPict("SA1","A1_SALDUPM",17,nMcusto))

	aDados[7][2] := Transform(xMoeda(nSalPed,nMCusto,1),PesqPict("SA1","A1_SALPED",17,1))
	aDados[7][3] := Transform(nSalPed,PesqPict("SA1","A1_SALPED",17,nMcusto))

	aDados[8][2] := Transform(xMoeda(nLCFin,nMcusto,1),PesqPict("SA1","A1_LC",17,1))
	aDados[8][3] := Transform(nLcFin,PesqPict("SA1","A1_LC",17,nMcusto))
	aDados[8][6] := Transform(nValAtraso,PesqPict("SA1","A1_SALDUP",17,1))

Endif

RestArea(aArea)

Return(aDados)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FtSomaAtr ³ Rev.  ³ Eduardo Riera         ³ Data ³02.02.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de calculo do atraso do cliente                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina realiza o calculo do atraso do cliente com base  ³±±
±±³          ³no titulos em aberto. A tabela de clientes deve estar posicio³±±
±±³          ³nada.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function _FtSomaAtr(cFilNew)

Local aArea      := GetArea()
Local aAreaSE1   := SE1->(GetArea())
Local cSalvFil   := cFilAnt
Local cAliasSE1  := "SE1"
Local nValAtraso := 0
Local aStruSE1   := {}
Local cQuery     := ""	
Local nX         := 0	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Troca a filial corrente                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//DEFAULT cFilNew := cFilAnt
cFilAnt := cFilNew
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa os titulos em aberto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE1")
dbSetOrder(8)

aStruSE1  := SE1->(dbStruct())
cAliasSE1 := "SOMAATRASO"

cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
cQuery += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
cQuery += "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
cQuery += "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
cQuery += "SE1.E1_STATUS='A' AND "
cQuery += "SE1.D_E_L_E_T_=' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
For nX := 1 To Len(aStruSE1)
	If aStruSE1[nX][2] <> "C"
		TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
	EndIf
Next nX
While ( !Eof() .And. (cAliasSE1)->E1_FILIAL == xFilial("SE1") .And. ;
		(cAliasSE1)->E1_CLIENTE+(cAliasSE1)->E1_LOJA == SA1->A1_COD+SA1->A1_LOJA .And.;
		(cAliasSE1)->E1_STATUS == "A" )
	If ( dDataBase > (cAliasSE1)->E1_VENCREA )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o t¡tulo seja de qualquer natureza credora (-) o saldo  ³
		//³ deve ser abatido. Os t¡tulos tipo RA (Receb.Antecipado),     ³
		//³ NCC (Nota de Cr‚dito) e PR (Provis¢rio) n„o precisam de      ³
		//³ tratamento especial. Bops 00323-A                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSE1)->E1_TIPO $ MVABATIM
			nValAtraso += xMoeda( (cAliasSE1)->E1_SALDO , (cAliasSE1)->E1_MOEDA , 1 )
		ElseIf !((cAliasSE1)->E1_TIPO $ MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG)
			nValAtraso -= xMoeda( (cAliasSE1)->E1_SALDO , (cAliasSE1)->E1_MOEDA , 1 )
		Endif
	EndIf
	dbSelectArea(cAliasSE1)
	dbSkip()
EndDo

dbSelectArea(cAliasSE1)
dbCloseArea()
dbSelectArea("SE1")

dbSetOrder(1)
cFilAnt := cSalvFil
RestArea(aAreaSE1)
RestArea(aArea)
Return (nValAtraso)

/*

PARAMIXB[2][2] - aSaldos[_LIMCRED]
PARAMIXB[2][3] - aSaldos[_LIMCREDM]

PARAMIXB[2][2] - aSaldos[_SALDUP]
PARAMIXB[2][3] - aSaldos[_SALDUPM]

PARAMIXB[3][2] - aSaldos[_SALPEDL]
PARAMIXB[3][3] - aSaldos[_SALPEDLM]
PARAMIXB[3][6] - aSaldos[_MCOMPRAM]

PARAMIXB[4][2] - aSaldos[_SALDOLC]
PARAMIXB[4][3] - aSaldos[_SALDOLCM]
PARAMIXB[4][6] - aSaldos[_MAIDUPLM]

PARAMIXB[7][2] - aSaldos[_SALPED]
PARAMIXB[7][3] - aSaldos[_SALPEDM]

PARAMIXB[8][2] - aSaldos[_LCFIN]
PARAMIXB[8][3] - aSaldos[_LCFINM]
PARAMIXB[8][6] - aSaldos[_VALATR]

PARAMIXB[9][2] - aSaldos[_SALFIN]
PARAMIXB[9][3] - aSaldos[_SALFINM]

	//Limite de Credito/Tit.Protestados/DT.ULT TIT [1]
	Aadd(aCols,{OemToAnsi(STR0018),TRansform(aSaldos[_LIMCRED],PesqPict("SA1","A1_LC",17,1)),;
		TRansform(aSaldos[_LIMCREDM],PesqPict("SA1","A1_LC",17,nMcusto))," ",;
		OemToAnsi(STR0019),Space(02)+STR(SA1->A1_TITPROT,3)+Space(05)+;
		OemToAnsi(STR0020)+Space(03)+DtoC(SA1->A1_DTULTIT)}) //Limite de Credito/Tit.Protestados/DT.ULT TIT

	// Saldo Titulos / Cheques Devolvidos/DT.ULT.CHQ [2]
	Aadd(aCols,{OemToAnsi(STR0021),TRansform(aSaldos[_SALDUP],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALDUPM],PesqPict("SA1","A1_SALDUPM",17,nMcusto))," ",;
		OemToAnsi(STR0022),Space(02)+STR(SA1->A1_CHQDEVO,3)+Space(05)+;
		OemToAnsi(STR0020)+Space(03)+DtoC(SA1->A1_DTULCHQ)}) // Saldo Titulos / Cheques Devolvidos/DT.ULT.CHQ

	// Pedidos Aprovados/Maior Compra [3]
	Aadd(aCols,{OemToAnsi(STR0023),TRansform(aSaldos[_SALPEDL],PesqPict("SA1","A1_SALPEDL",17,1)),;
		TRansform(aSaldos[_SALPEDLM],PesqPict("SA1","A1_SALPEDL",17,nMcusto))," ",OemToAnsi(STR0024),;
		Transform(aSaldos[_MCOMPRAM],PesqPict("SA1","A1_MCOMPRA",17,nMCusto))}) // Pedidos Aprovados/Maior Compra

	// Saldo Lim Credito/Maior Duplicata [4]
	Aadd(aCols,{OemToAnsi(STR0025),TRansform(aSaldos[_SALDOLC],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALDOLCM],PesqPict("SA1","A1_SALDUPM",17,nMcusto))," ",;
		OemToAnsi(STR0026),Transform(aSaldos[_MAIDUPLM],PesqPict("SA1","A1_MAIDUPL",17,nMCusto))}) // Saldo Lim Credito/Maior Duplicata

	// Item Pedido Atual/Media de Atraso [5]
	Aadd(aCols,{OemToAnsi(STR0027),TRansform(aSaldos[_ITATU],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_ITATUM],PesqPict("SA1","A1_SALDUP",17,nMcusto))," ",;
		OemToAnsi(STR0029),Space(14)+Transform(SA1->A1_METR,PesqPict("SA1","A1_METR",7))+Space(04)+;
		OemToAnsi(STR0028)}) // Item Pedido Atual/Media de Atraso

	If SC5->C5_TIPLIB=="2" [6]
		Aadd(aCols,{OemToAnsi(STR0036),TRansform(aSaldos[_PEDATU],PesqPict("SA1","A1_SALDUP",17,1)),;
			TRansform(aSaldos[_PEDATUM],PesqPict("SA1","A1_SALDUP",17,nMcusto))," ",;
			OemToAnsi(STR0031),Space(10)+DtoC(SA1->A1_VENCLC)}) //Pedido Atual/ Vencto.Lim.Credito
	Else
		Aadd(aCols,{"","","","",;
			OemToAnsi(STR0031),Space(10)+DtoC(SA1->A1_VENCLC)}) //Pedido Atual/ Vencto.Lim.Credito
	EndIf

	// Saldo de Pedidos / Data Limite Liberação	[7]
	Aadd(aCols,{OemToAnsi(STR0030),TRansform(aSaldos[_SALPED],PesqPict("SA1","A1_SALPED",17,1)),;
		TRansform(aSaldos[_SALPEDM],PesqPict("SA1","A1_SALPED",17,nMcusto))," ",;
		OemToAnsi(STR0033),Space(10)+DtoC(dLimLib)}) // Saldo de Pedidos / Data Limite Liberação

	//Lim. de Cred. Secundario/Atraso Atual [8]
	Aadd(aCols,{OemToAnsi(STR0057),TRansform(aSaldos[_LCFIN],PesqPict("SA1","A1_LC",17,1)),;
		TRansform(aSaldos[_LCFINM],PesqPict("SA1","A1_LC",17,nMcusto))," ",;
		OemToAnsi(STR0032),TRansform(aSaldos[_VALATR],PesqPict("SA1","A1_SALDUP",17,1))}) //Lim. de Cred. em Cheque/Atraso Atual

	Aadd(aCols,{OemToAnsi(STR0058),TRansform(aSaldos[_SALFIN],PesqPict("SA1","A1_SALDUP",17,1)),; [9]
		TRansform(aSaldos[_SALFINM],PesqPict("SA1","A1_SALDUP",17,nMcusto))," ",,,}) // Saldo em Cheques


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma-se Todos os Limites de Credito do Cliente          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+SC5->C5_CLIENTE)
	While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
			SC5->C5_CLIENTE ==  SA1->A1_COD )

		nMCustoCli := Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(SuperGetMv("MV_MCUSTO")))
		nLimCred += xMoeda(SA1->A1_LC,nMCustoCli,nMCusto,dDataBase)
		nSalPed  += xMoeda(SA1->A1_SALPED+SA1->A1_SALPEDB,nMCustoCli,nMCusto,dDataBase)
		nSalPedL += xMoeda(SA1->A1_SALPEDL,nMCustoCli,nMCusto,dDataBase)
		nSalDup  += SA1->A1_SALDUP
		nSalDupM += xMoeda(SA1->A1_SALDUPM,nMCustoCli,nMCusto,dDataBase)
		nSalFin  += SA1->A1_SALFIN
		nLcFin   += xMoeda(SA1->A1_LCFIN,nMCustoCli,nMCusto,dDataBase)
		nSalFinM += xMoeda(SA1->A1_SALFINM,nMCustoCli,nMCusto,dDataBase)
		dbSelectArea("SA1")
		dbSkip()
	EndDo

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+SC5->C5_CLIENTE)
	While ( !Eof() .And. xFilial("SA1")  == SA1->A1_FILIAL .And.;
			SC5->C5_CLIENTE == SA1->A1_COD )
		nValAtraso += FtSomaAtr(FWGETCODFILIAL)
		dbSelectArea("SA1")
		dbSkip()
	EndDo

	aSaldos[_LIMCREDM] 	:=	nLimCred
	aSaldos[_LIMCRED ] 	:=  xMoeda(nLimCred,nMCusto,1)
	aSaldos[_SALDUPM ] 	:=	nSalDupM
	aSaldos[_SALDUP  ] 	:=	nSalDup
	aSaldos[_SALPEDLM] 	:=	nSalPedL
	aSaldos[_SALPEDL ] 	:=	xMoeda(nSalPedL,nMCusto,1)
	aSaldos[_MCOMPRAM] 	:=	SA1->A1_MCOMPRA
	aSaldos[_MCOMPRA ] 	:=	xMoeda(SA1->A1_MCOMPRA,nMCusto,1)
	aSaldos[_SALDOLCM] 	:=  nLimCred-nSaldupM-nSalPedL
	aSaldos[_SALDOLC ] 	:=  xMoeda(nLimCred-nSaldupM-nSalPedL,nMCusto,1)
	aSaldos[_MAIDUPLM] 	:=	SA1->A1_MAIDUPL
	aSaldos[_MAIDUPL ] 	:=	xMoeda(SA1->A1_MAIDUPL,nMCusto,1)
	aSaldos[_ITATUM  ] 	:=	xMoeda((SC9->C9_PRCVEN * SC9->C9_QTDLIB),nMoeda,nMcusto)
	aSaldos[_ITATU   ] 	:=	xMoeda((SC9->C9_PRCVEN * SC9->C9_QTDLIB),nMoeda,1)
	aSaldos[_PEDATUM ] 	:=  nValPed
	aSaldos[_PEDATU  ]	:=  xMoeda(nValPed ,nMCusto,1)
	aSaldos[_SALPEDM ]	:=	nSalPed
	aSaldos[_SALPED  ]	:=  xMoeda(nSalPed ,nMCusto,1)
	aSaldos[_VALATRM ] 	:=	xMoeda(nValAtraso,1,nMCusto)
	aSaldos[_VALATR  ] 	:=	nValAtraso
	aSaldos[_LCFINM  ] 	:=	nLcFin
	aSaldos[_LCFIN   ] 	:=  xMoeda(nLCFin,nMcusto,1)
	aSaldos[_SALFINM ] 	:=	nSalFinM
	aSaldos[_SALFIN  ] 	:=	nSalFin

*/
