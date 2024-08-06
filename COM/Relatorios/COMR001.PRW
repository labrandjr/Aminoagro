#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COMR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 13/04/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de notas fiscais Compras x Pagamentos.		      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COMR001()

Local cPerg := "COMR01"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 07/02/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR01()

Local oExcel   := FwMsExcel():New()
Local cKeyAnt  := ""
Local zFiliais := ""
Local cQuery
Local nForFilial

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

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SF1")+" SF1 "
cQuery += " WHERE D1_FILIAL = F1_FILIAL "
cQuery += " AND D1_DOC = F1_DOC "
cQuery += " AND D1_SERIE = F1_SERIE "
cQuery += " AND D1_FORNECE = F1_FORNECE "
cQuery += " AND D1_LOJA = F1_LOJA "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND D1_TIPO = 'N' "
cQuery += " AND D1_ORIGLAN <> 'LF' "
cQuery += " AND ((F4_DUPLIC = 'S') OR (F4_ESTOQUE = 'S' AND F1_EST = 'EX')) "
If !u__UsrMpOk()
	cQuery += " AND D1_ZZMP <> 'X' "
Endif
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT D1_FILIAL FILIAL, D1_DOC DOC, D1_SERIE SERIE, D1_DTDIGIT DTDIGIT, D1_COD PRODUTO, D1_ITEM ITEM, D1_FORNECE FORNECE, D1_LOJA LOJA, D1_QUANT QUANT, "
cQuery += " D1_VUNIT VUNIT, D1_TOTAL TOTAL, D1_TP TP, D1_PEDIDO PEDIDO, D1_ITEMPC ITEM_PED, '' EMISS_PED, '' ENTREG_PED, 0 MOEDA, 0 TXMOEDA, F1_EST EST, F4_DUPLIC DUPLIC "
cQuery += " FROM "+RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SF1")+" SF1 "
cQuery += " WHERE D1_FILIAL = F1_FILIAL "
cQuery += " AND D1_DOC = F1_DOC "
cQuery += " AND D1_SERIE = F1_SERIE "
cQuery += " AND D1_FORNECE = F1_FORNECE "
cQuery += " AND D1_LOJA = F1_LOJA "
cQuery += " AND D1_TES = F4_CODIGO "
cQuery += " AND D1_FILIAL = F4_FILIAL "
cQuery += " AND D1_FILIAL IN ("+zFiliais+") "
cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D1_TP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND D1_TIPO = 'N' "
cQuery += " AND D1_ORIGLAN <> 'LF' "
cQuery += " AND ((F4_DUPLIC = 'S') OR (F4_ESTOQUE = 'S' AND F1_EST = 'EX')) "
If !u__UsrMpOk()
	cQuery += " AND D1_ZZMP <> 'X' "
Endif
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SD1_COMR01"
	cNomeTable := "Compras x Pagamentos - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)+" - por Itens de Notas Fiscais"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Entrada",1,4) 

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cod.For",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Fornecedor",1,1) 

	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Item",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descricao",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Quantidade",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"U.M.",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pedido",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Item",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Entrega",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Moeda",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tx.Moeda",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Moeda",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Estado",1,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"No.Parcelas",3,1)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Vencto.1",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Pagto.1",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Pago 1",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Vencto.2",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Pagto.2",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Pago 2",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Vencto.3",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Pagto.3",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Pago 3",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Vencto.4",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Pagto.4",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Pago 4",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Vencto.5",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Pagto.5",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Pago 5",3,3)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Usuário",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Usuário",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		lImpres := .F.
		If SQL->(FILIAL+DTDIGIT+DOC+SERIE+FORNECE+LOJA+PRODUTO+ITEM) != cKeyAnt
		    lImpres := .T.
			cKeyAnt := SQL->(FILIAL+DTDIGIT+DOC+SERIE+FORNECE+LOJA+PRODUTO+ITEM)
		Endif	

		If lImpres

			zFilial := SQL->FILIAL
			zLocal  := FWFilialName(cEmpAnt,SQL->FILIAL,1)
			zDocum  := SQL->DOC
			zSerie  := SQL->SERIE
			zEntrad := StoD(SQL->DTDIGIT)

			//=====
			zCodFor := SQL->FORNECE
			zNomFor := Alltrim(GetAdvFVal("SA2","A2_NOME",xFilial("SA2") + SQL->FORNECE,1))
			//=====

			zCodigo := SQL->PRODUTO
			zItemNf := SQL->ITEM
			zDescri := RetField("SB1",1,xFilial("SB1")+zCodigo,"B1_DESC")
			zTp		:= SQL->TP
			zQuant  := SQL->QUANT
			zUM     := RetField("SB1",1,xFilial("SB1")+zCodigo,"B1_UM")
			zValor  := SQL->TOTAL
			zPedido := SQL->PEDIDO
			zItemPc := SQL->ITEM_PED
			zEmisPc := ""
			zEntreg := ""
			zMoeda  := 1
			zTxMoed := 1
			zVlrMoe := SQL->TOTAL
			zEstado := SQL->EST
			zCodUsr := ""
			zNomUsr := ""

			If !Empty(SQL->PEDIDO)
				DbSelectArea("SC7")
				DbSetOrder(1)
				If DbSeek( SQL->FILIAL + SQL->PEDIDO + SQL->ITEM_PED )
					zEmisPc := SC7->C7_EMISSAO
					zEntreg := SC7->C7_DATPRF
					zMoeda  := IIf(SC7->C7_MOEDA == 0 .Or. SC7->C7_MOEDA == 1, 1, SC7->C7_MOEDA)
					zTxMoed := IIf(zMoeda == 1, 1, Round((SQL->VUNIT/SC7->C7_PRECO),4) )
					If SC7->C7_MOEDA > 1
						zVlrMoe := Round((SQL->QUANT * SC7->C7_PRECO),2)
					Endif	
					zCodUsr := SC7->C7_USER
					zNomUsr := UsrRetName(SC7->C7_USER)
				Endif
			Endif	
			//
			zNrParc := 1
			//
			zVePar1 := ""
			zPgPar1 := ""
			zVpPar1 := 0
			//
			zVePar2 := ""
			zPgPar2 := ""
			zVpPar2 := 0
			//
			zVePar3 := ""
			zPgPar3 := ""
			zVpPar3 := 0
			//
			zVePar4 := ""
			zPgPar4 := ""
			zVpPar4 := 0
			//
			zVePar5 := ""
			zPgPar5 := ""
			zVpPar5 := 0
			//
			DbSelectArea("SE2")
			DbSetOrder(6)
			If DbSeek( SQL->(FILIAL+FORNECE+LOJA+SERIE+DOC) )
				zNrParc := 0
				While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == SQL->(FILIAL+FORNECE+LOJA+SERIE+DOC)
					zNrParc += 1
					&("zVePar"+AllTrim(STR(zNrParc))) := SE2->E2_VENCREA
					If !Empty(SE2->E2_BAIXA)
						&("zPgPar"+AllTrim(STR(zNrParc))) := SE2->E2_BAIXA
						&("zVpPar"+AllTrim(STR(zNrParc))) := SE2->(E2_VALOR-E2_SALDO)
					Endif
					SE2->(DbSkip())
				Enddo
			Endif
	
			oExcel:AddRow(cNomePlan, cNomeTable, {zFilial, zLocal, zDocum, zSerie, zEntrad, zCodFor, zNomFor, zCodigo, zItemNf, zDescri,;
			   									  zTP, zQuant, zUM, zValor, zPedido, zItemPc, zEmisPc, zEntreg, zMoeda, zTxMoed, zVlrMoe,;
			   									  zEstado, zNrParc,;
			   									  zVePar1, zPgPar1, zVpPar1,;
			   									  zVePar2, zPgPar2, zVpPar2,;
			   									  zVePar3, zPgPar3, zVpPar3,;
						  						  zVePar4, zPgPar4, zVpPar4,;
						  						  zVePar5, zPgPar5, zVpPar5,;
												  zCodUsr, zNomUsr })

		Endif
		
		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SD1_COMR01-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())
	
Return
