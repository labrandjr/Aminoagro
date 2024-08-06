#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR007  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/08/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Comissões geradas via pagamento de acordos/negociações. 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR007()

Local cPerg := "FATR07"
Private cPath := "c:\report\"
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR07()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR07   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 12/11/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR07()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local nForFilial

Fatr7Trab()

aFilsCalc := MatFilCalc( mv_par05 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

ProcRegua(2)

// 1. Comissões s/ Negociações (gerada sobre os títulos originais | específico)
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO <> 'ACO' "
cQuery += " AND E5_TIPO IN('ICF','CH','TF') "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES','BA') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())
	
IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO <> 'ACO' "
cQuery += " AND E5_TIPO IN('ICF','CH','TF') "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES','BA') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()

	IncProc("Calculando comissão s/ Negociações...")

	DbSelectArea("SE5")
	SE5->(DbGoto(SQL->R_E_C_N_O_))
	dDatPag := SE5->E5_DATA
	
	If !u__EstorSe5(SE5->E5_FILIAL, SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, SE5->E5_LOJA, SE5->E5_SEQ)

		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) )

		zFilial := SE1->E1_FILIAL
		If !Empty(SE1->E1_ZFILINC)
			zFilial := SE1->E1_ZFILINC
		Endif

		cFilAnt := SE5->E5_FILIAL
		DbSelectArea("FI7")
		DbSetOrder(2)
		If DbSeek( zFilial + SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) )
			nBxLiqui := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
			zValNego := u_TotNego(zFilial,SE1->E1_NUMLIQ)
			nFatorBx := (nBxLiqui / zValNego)
			aNfNegoc := u_NfNegoc(zFilial,SE1->E1_NUMLIQ,nBxLiqui,SE1->E1_ZFILINC,@nFatorBx,dDatPag)
			If Len(aNfNegoc) > 0
				u_TRBCmsLq(aNfNegoc,nBxLiqui,nFatorBx,zFilial)
			Endif	
		Endif

	Endif

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

// 2. Comissões s/ Acordos
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO = 'ACO' "
cQuery += " AND E5_FILORIG <> ' ' "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES','BA') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL IN ("+zFiliais+") "
cQuery += " AND E5_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E5_PREFIXO = 'ACO' "
cQuery += " AND E5_FILORIG <> ' ' "
cQuery += " AND E5_TIPODOC NOT IN('DC','JR','MT','ES','BA') "
cQuery += " AND E5_MOTBX IN('NOR','CMP','CEC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()

	IncProc("Calculando comissão s/ Negociações...")

	DbSelectArea("SE5")
	SE5->(DbGoto(SQL->R_E_C_N_O_))
	
	If !u__EstorSe5(SE5->E5_FILIAL, SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, SE5->E5_LOJA, SE5->E5_SEQ)

		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) )

		zFilial := SE1->E1_FILIAL
		If !Empty(SE1->E1_ZFILINC)
			zFilial := SE1->E1_ZFILINC
		Endif

		cFilAnt := SE5->E5_FILIAL
		DbSelectArea("Z01")
		DbSetOrder(1)
		If DbSeek( zFilial + SE5->E5_NUMERO )
			nBxLiqui := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
			nFatorBx := (nBxLiqui / Z01->Z01_VALNEG)
			aNfAcord := u_NfAcord(zFilial,Z01->Z01_ACORDO,nBxLiqui,SE1->E1_ZFILINC)
			If Len(aNfAcord) > 0
				u_TRBCmsLq(aNfAcord,nBxLiqui,nFatorBx,zFilial)
			Endif	
		Endif

	Endif

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SE3_FATR07"
	cNomeTable := "Comissões s/ Acordos e Negociações"
	cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"No.Acordo/Neg.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Título",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.Real",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Pagto.",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data Pagto.",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Seq.Pagto.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Base Comis.",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"%Comis.",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Comis.",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% Icms",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Icms",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Comiss.Orig.",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dias Atraso",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"% Desc.Atras",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Desc.Atr",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		zNomeVen := RetField("SA3",1,xFilial("SA3")+TRB->TF_VEND,"A3_NOME")
		zNomeCli := RetField("SA1",1,xFilial("SA1")+TRB->TF_CLIENTE,"A1_NOME")
		
		oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_FILIAL, TRB->TF_VEND, zNomeVen, TRB->TF_ACORDO, TRB->TF_PREFIXO, TRB->TF_NUM,;
											  TRB->TF_PARCELA, TRB->TF_TIPO, TRB->TF_CLIENTE, zNomeCli, TRB->TF_VALOR, TRB->TF_VENCREA,;
											  TRB->TF_VALORPG, TRB->TF_DATAPG, TRB->TF_SEQPG, TRB->TF_BASE, TRB->TF_PORC, TRB->TF_COMIS,;
											  TRB->TF_ICMS, TRB->TF_VALICM, TRB->TF_ZZCOMIS, TRB->TF_ZZATRAS, TRB->TF_ZZPDESC, TRB->TF_ZZVDESC })

		DbSelectArea("TRB")
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE3_FINR07-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
TRB->(DbCloseArea())
oTempTable:Delete()
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TRBCmsLq ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  12/11/18	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cálculo da comissão dos títulos acordados/negociados.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TRBCmsLq(aTitComs,nBxLiqui,nFatorBx,zFilial)

Local aArea    := GetArea()
Local nBxAcumu := 0
Local _x
Local _y

For _x := 1 to Len(aTitComs)
	zVend1   := aTitComs[_x][01]
	zGeren1  := aTitComs[_x][02]
	zSuper1  := aTitComs[_x][03]
	zVend2   := aTitComs[_x][04]
	zGeren2  := aTitComs[_x][05]
	zSuper2  := aTitComs[_x][06]
	zPrefixo := aTitComs[_x][07]
	zNumero  := aTitComs[_x][08]
	zParcela := aTitComs[_x][09]
	zTipo    := aTitComs[_x][10]
	zVencto  := aTitComs[_x][11]
	zIcms    := aTitComs[_x][13]
	zPedido  := aTitComs[_x][14]
	zComis1  := aTitComs[_x][15]
	zComis2  := aTitComs[_x][16]
	zVend3   := aTitComs[_x][19]
	zVend4   := aTitComs[_x][20]
	zComis3  := aTitComs[_x][21]
	zComis4  := aTitComs[_x][22]
	zGeren3  := ""
	zSuper3  := ""
	zGeren4  := ""
	zSuper4  := ""
	If _x == Len(aTitComs)
		zValor := nBxLiqui - nBxAcumu
	Else
		zValor := Round((aTitComs[_x][12] * nFatorBx),2)
		nBxAcumu += zValor
	Endif
	//
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( zFilial + zPrefixo + zNumero + zParcela + zTipo )
	//
	zDiasAtr := SE5->E5_DATA - SE1->E1_VENCREA
	zBaseCom := zValor - (zValor * (zIcms/100))
	//
	For _y := 1 to 4
		zVend   := &("zVend"+AllTrim(STR(_y)))
		zGeren  := &("zGeren"+AllTrim(STR(_y)))
		zSuper  := &("zSuper"+AllTrim(STR(_y)))
		zPorc   := &("zComis"+AllTrim(STR(_y)))
		zAtraso := zDiasAtr
		zComiss := (zBaseCom * (zPorc/100))
		If !Empty(zVend) .And. zComiss > 0 .And. (zVend >= mv_par03 .And. zVend <= mv_par04)
			RecLock("TRB",.T.)
			TRB->TF_FILIAL  := SE5->E5_FILIAL
			TRB->TF_VEND    := zVend
			TRB->TF_ACORDO  := SE5->( AllTrim(E5_PREFIXO)+"-"+AllTrim(E5_NUMERO)+"-"+AllTrim(E5_PARCELA))
			TRB->TF_PREFIXO := zPrefixo
			TRB->TF_NUM     := zNumero
			TRB->TF_PARCELA := zParcela
			TRB->TF_TIPO    := zTipo
			TRB->TF_CLIENTE := SE1->E1_CLIENTE
			TRB->TF_VALOR   := SE1->E1_VALOR
			TRB->TF_VENCREA := SE1->E1_VENCREA
			TRB->TF_VALORPG := zValor
			TRB->TF_DATAPG  := SE5->E5_DATA
			TRB->TF_SEQPG   := SE5->E5_SEQ
			TRB->TF_BASE    := zBaseCom
			TRB->TF_PORC    := zPorc
			TRB->TF_COMIS   := zComiss
			TRB->TF_ZZCOMIS := zComiss
			TRB->TF_ICMS    := zIcms
			TRB->TF_VALICM  := (zValor * (zIcms/100))
			MsUnLock()

			If zAtraso >= 9999
				zAtraso := 9999
			Endif

			If zAtraso > 0

				RecLock("TRB",.F.)
				TRB->TF_ZZATRAS := zAtraso
				MsUnLock()

				zPDescon := 0
				If Substr(TRB->TF_VEND,1,1) == "R" // Revenda
					If zAtraso > 60 // Acima de 60 dias de atraso NÃO RECEBE O PRÊMIO.
						zPDescon := 100
					ElseIf zAtraso > 30 // 31 a 60 dias de atraso = 50% do prêmio;
						zPDescon := 50
					ElseIf zAtraso > 15 // 16 a 30 dias de atraso = 80% do prêmio;
						zPDescon := 20
					Else // Até 15 dias de atraso = 90% do prêmio;
						zPDescon := 10	
					Endif
				Else // Todos exceto Revenda
					If zAtraso > GetMv("MV_DIATRTV") // Acima de N dias de atraso NÃO RECEBE O PRÊMIO.
						zPDescon := 100
					Endif
				Endif	

				If zPDescon > 0
					RecLock("TRB",.F.)
					TRB->TF_ZZPDESC := zPDescon
					If zPDescon == 100
						TRB->TF_ZZVDESC := TRB->TF_COMIS
						TRB->TF_COMIS   := 0.00
					Else
						TRB->TF_ZZVDESC := (TRB->TF_COMIS * (zPDescon/100))
						TRB->TF_COMIS   := TRB->TF_COMIS - TRB->TF_ZZVDESC
					Endif	
					MsUnLock()
				Endif

			Endif

		Endif
	Next _y
	//
Next _x

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Fatr7Trab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 12/11/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Fatr7Trab()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_VEND"    , "C", 006, 00} )
AAdd ( _aTmp, {"TF_ACORDO"  , "C", 016, 00} )
AAdd ( _aTmp, {"TF_PREFIXO" , "C", 003, 00} )
AAdd ( _aTmp, {"TF_NUM"     , "C", 009, 00} )
AAdd ( _aTmp, {"TF_PARCELA" , "C", 002, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 003, 00} )
AAdd ( _aTmp, {"TF_CLIENTE" , "C", 006, 00} )
AAdd ( _aTmp, {"TF_VALOR"   , "N", 017, 02} )
AAdd ( _aTmp, {"TF_VENCREA" , "D", 008, 00} )
AAdd ( _aTmp, {"TF_VALORPG" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_DATAPG"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_SEQPG"   , "C", 002, 00} )
AAdd ( _aTmp, {"TF_BASE"    , "N", 017, 02} )
AAdd ( _aTmp, {"TF_PORC"    , "N", 005, 02} )
AAdd ( _aTmp, {"TF_COMIS"   , "N", 011, 02} )
AAdd ( _aTmp, {"TF_ICMS"    , "N", 005, 02} )
AAdd ( _aTmp, {"TF_VALICM"  , "N", 011, 02} )
AAdd ( _aTmp, {"TF_ZZCOMIS" , "N", 011, 02} )
AAdd ( _aTmp, {"TF_ZZATRAS" , "N", 009, 00} )
AAdd ( _aTmp, {"TF_ZZPDESC" , "N", 006, 02} )
AAdd ( _aTmp, {"TF_ZZVDESC" , "N", 011, 02} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_VEND", "TF_ACORDO", "TF_SEQPG", "TF_PREFIXO", "TF_NUM", "TF_PARCELA", "TF_TIPO", "TF_CLIENTE"})
oTempTable:Create()

Return
