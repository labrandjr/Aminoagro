#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FINR002  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 10/08/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório da carteira de pagamentos - Capex.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FINR002()

Local cPerg := "FINR02"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFinR02()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFinR02   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 10/08/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFinR02()

Local oExcel  := FwMsExcel():New()
Local zFiliais := ""
Local cKeyAnt := ""
Local lKeyAnt := .F.
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
cQuery += " ORDER BY FILIAL, FORNECE, LOJA, PREFIXO, NUMERO, PARCELA, TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SE2_FINR02"
	cNomeTable := "Capex - "+IIf(mv_par01==1,"Emissão ","Vencimento ")+DtoC(mv_par02)+" à "+DtoC(mv_par03)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Projeto",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Projeto",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Natureza",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Natureza",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencimento",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Moeda",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Pagto",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Pago",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Forma Pagto",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SE2")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO+FORNECE+LOJA) )

		DbSelectArea("SD1")
		DbSetOrder(1)
		If DbSeek( SQL->(FILIAL+NUMERO+PREFIXO+FORNECE+LOJA) )
			lCapex := .F.
			While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SQL->(FILIAL+NUMERO+PREFIXO+FORNECE+LOJA)
				If SD1->D1_TP == "AI"
					lCapex := .T.
					Exit
				Endif
				SD1->(DbSkip())
			Enddo
			If !lCapex
				DbSelectArea("SQL")
				SQL->(DbSkip())
				Loop
			Endif
		Else
			DbSelectArea("SQL")
			SQL->(DbSkip())
			Loop
		Endif

		zLocal  := FWFilialName(cEmpAnt,SE2->E2_FILIAL,1)
		zNomFor := RetField("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NREDUZ")
		zNomFor := StrTran(zNomFor,"&","E")
		zCodPrj := RetField("AFN",2,SE2->(E2_FILIAL+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),"AFN_PROJET")
		zProjet := RetField("AF8",1,SE2->E2_FILIAL+zCodPrj,"AF8_DESCRI")
		zCodNat := SE2->E2_NATUREZ
		zNature := RetField("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"ED_DESCRIC")
		zDtPagt := IIf(AllTrim(SE2->E2_TIPO) == "PA",SE2->E2_EMISSAO,SE2->E2_BAIXA)
		zVlPagt := IIf(AllTrim(SE2->E2_TIPO) == "PA",SE2->E2_VALOR,0)
		zMoedPg := IIf(SE2->E2_MOEDA==1,"R$", AllTrim(GetMv("MV_SIMB"+AllTrim(STR(SE2->E2_MOEDA)))) )
		zFormPg := ""
		aFormPg := {}

		DbSelectArea("SE5")
		DbSetOrder(7)
		If DbSeek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )
			While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
				If SE5->E5_TIPODOC $("VL,CP,BA")
					zVlPagt += SE5->E5_VALOR
				Endif
				If Len(aFormPg) == 0
					AAdd(aFormPg,SE5->E5_MOTBX)
				Else
					nPos := aScan(aFormPg, {|x| x == SE5->E5_MOTBX })
					If nPos == 0
						AAdd(aFormPg,SE5->E5_MOTBX)
					Endif
				Endif
				SE5->(DbSkip())
			Enddo
		Endif
		
		If zVlPagt == 0
			zDtPagt := CtoD("")
		Endif

		For z := 1 to Len(aFormPg)
			zFormPg += IIf(!Empty(zFormPg),"|","") + aFormPg[z]
		Next z
	
		oExcel:AddRow(cNomePlan, cNomeTable, {SE2->E2_FILIAL, zLocal, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, zNomFor,;
		   									  zCodPrj, zProjet, zCodNat, zNature, SE2->E2_EMISSAO, SE2->E2_VENCREA, SE2->E2_VALOR,;
		   									  zMoedPg, zDtPagt, zVlPagt, zFormPg })

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE2_FINR02-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
