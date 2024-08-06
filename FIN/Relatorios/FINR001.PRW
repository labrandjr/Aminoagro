#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FINR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 20/06/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório da carteira de pagamentos. 					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FINR001()

Local cPerg := "FINR01"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFinR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFinR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 09/06/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFinR01()

Local oExcel  := FwMsExcel():New()
Local zFiliais := ""
Local nForFilial

aFilsCalc := MatFilCalc( mv_par04 == 1 )
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
cQuery := " SELECT COUNT(*)AS SOMA FROM "
cQuery += " (
cQuery += " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA "
cQuery += " FROM "+RetSqlName("SE2")+" SE2, "
cQuery += RetSqlName("SF1")+" SF1 "
cQuery += " WHERE E2_FILIAL = F1_FILIAL "
cQuery += " AND E2_PREFIXO = F1_SERIE "
cQuery += " AND E2_NUM = F1_DOC "
cQuery += " AND E2_FORNECE = F1_FORNECE "
cQuery += " AND E2_LOJA = F1_LOJA "
cQuery += " AND E2_FILIAL IN("+zFiliais+") "
If mv_par01 == 1 // por Emissão
	cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
ElseIf mv_par01 == 2 // por Vencimento
	cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
Endif	
cQuery += " AND E2_MOEDA = 1 "
cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
If mv_par05 == 2 // Consid.Param.Abaixo = Não (Filtro por Tipo de Produto)
	cQuery += " UNION "
	cQuery += " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA "
	cQuery += " FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
	If mv_par01 == 1 // por Emissão
		cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	ElseIf mv_par01 == 2 // por Vencimento
		cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	Endif	
	cQuery += " AND E2_MOEDA <> 1 "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA "
	cQuery += " FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
	If mv_par01 == 1 // por Emissão
		cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	ElseIf mv_par01 == 2 // por Vencimento
		cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	Endif	
	cQuery += " AND E2_MOEDA = 1 "
	cQuery += " AND E2_TIPO = 'PA' "
	cQuery += " AND E2_PREFIXO = 'PAF' "
	cQuery += " AND E2_SALDO > 0 "
	cQuery += " AND D_E_L_E_T_ <> '*' "
Endif	
cQuery += " ) "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA "
cQuery += " FROM "+RetSqlName("SE2")+" SE2, "
cQuery += RetSqlName("SF1")+" SF1 "
cQuery += " WHERE E2_FILIAL = F1_FILIAL "
cQuery += " AND E2_PREFIXO = F1_SERIE "
cQuery += " AND E2_NUM = F1_DOC "
cQuery += " AND E2_FORNECE = F1_FORNECE "
cQuery += " AND E2_LOJA = F1_LOJA "
cQuery += " AND E2_FILIAL IN("+zFiliais+") "
If mv_par01 == 1 // por Emissão
	cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
ElseIf mv_par01 == 2 // por Vencimento
	cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
Endif	
cQuery += " AND E2_MOEDA = 1 "
cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
If mv_par05 == 2 // Consid.Param.Abaixo = Não (Filtro por Tipo de Produto)
	cQuery += " UNION "
	cQuery += " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA "
	cQuery += " FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
	If mv_par01 == 1 // por Emissão
		cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	ElseIf mv_par01 == 2 // por Vencimento
		cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	Endif	
	cQuery += " AND E2_MOEDA <> 1 "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA "
	cQuery += " FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
	If mv_par01 == 1 // por Emissão
		cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	ElseIf mv_par01 == 2 // por Vencimento
		cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
	Endif	
	cQuery += " AND E2_MOEDA = 1 "
	cQuery += " AND E2_TIPO = 'PA' "
	cQuery += " AND E2_PREFIXO = 'PAF' "
	cQuery += " AND E2_SALDO > 0 "
	cQuery += " AND D_E_L_E_T_ <> '*' "
Endif
cQuery += " ORDER BY FILIAL, FORNECE, LOJA, PREFIXO, NUMERO, PARCELA, TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SE2_FINR01"
	cNomeTable := "Carteira de Pagamentos - "+IIf(mv_par01==1,"Emissão ","Vencimento ")+DtoC(mv_par02)+" à "+DtoC(mv_par03)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Natureza",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencimento",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Moeda",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Pagto",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Pago",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SE2")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO+FORNECE+LOJA) )

		If mv_par05 == 1 // Consid.Param.Abaixo = Sim (Filtro por Tipo de Produto)
			DbSelectArea("SD1")
			DbSetOrder(1)
			If DbSeek( SQL->(FILIAL+NUMERO+PREFIXO+FORNECE+LOJA) )
				lTipo := .F.
				While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SQL->(FILIAL+NUMERO+PREFIXO+FORNECE+LOJA)
					If SD1->D1_TP >= mv_par06 .And. SD1->D1_TP <= mv_par07
						lTipo := .T.
						Exit
					Endif
					SD1->(DbSkip())
				Enddo
				If !lTipo
					DbSelectArea("SQL")
					SQL->(DbSkip())
					Loop
				Endif
			Else
				DbSelectArea("SQL")
				SQL->(DbSkip())
				Loop
			Endif
		Endif

		zLocal  := FWFilialName(cEmpAnt,SE2->E2_FILIAL,1)
		zNomFor := RetField("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NOME")
		zNature := RetField("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"ED_DESCRIC")
		zDtPagt := IIf(AllTrim(SE2->E2_TIPO) == "PA",SE2->E2_EMISSAO,SE2->E2_BAIXA)
		zVlPagt := IIf(AllTrim(SE2->E2_TIPO) == "PA",SE2->E2_VALOR,0)
		zMoedPg := IIf(SE2->E2_MOEDA==1,"R$", AllTrim(GetMv("MV_SIMB"+AllTrim(STR(SE2->E2_MOEDA)))) )

		If AllTrim(SE2->E2_TIPO) != "PA"
			DbSelectArea("SE5")
			DbSetOrder(7)
			If DbSeek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )
				While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
					If SE5->E5_TIPODOC $("VL,CP,BA")
						zVlPagt += SE5->E5_VALOR
					Endif
					SE5->(DbSkip())
				Enddo
			Endif
		Endif	
		
		If zVlPagt == 0
			zDtPagt := CtoD("")
		Endif
	
		oExcel:AddRow(cNomePlan, cNomeTable, {SE2->E2_FILIAL, zLocal, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, zNomFor,;
		   									  zNature, SE2->E2_EMISSAO, SE2->E2_VENCREA, SE2->E2_VALOR, zMoedPg, zDtPagt, zVlPagt })

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE2_FINR01-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
