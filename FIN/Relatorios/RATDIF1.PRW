#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RATDIF1  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 15/06/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Listagem das diferenças na inclusão do rateio.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function RATDIF1()

Local cPerg := "RATDIF1"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pRatR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pRatR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 15/06/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pRatR01()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local cKeyAnt  := ""
Local lKeyAnt  := .F.
Local lDados   := .F. 
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
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
cQuery += " AND E2_RATEIO = 'S' "
cQuery += " AND E2_ARQRAT <> ' ' "
If mv_par01 == 1 // por Emissão
	cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
ElseIf mv_par01 == 2 // por Vencimento
	cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
ElseIf mv_par01 == 3 // por Baixa
	cQuery += " AND E2_BAIXA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
Endif	
If mv_par05 == 1 // Contabilizados = Não
	cQuery += " AND E2_LA = ' ' "
ElseIf mv_par05 == 2 // Contabilizados = Sim
	cQuery += " AND E2_LA = 'S' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

cQuery := " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
cQuery += " AND E2_RATEIO = 'S' "
cQuery += " AND E2_ARQRAT <> ' ' "
If mv_par01 == 1 // por Emissão
	cQuery += " AND E2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
ElseIf mv_par01 == 2 // por Vencimento
	cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
ElseIf mv_par01 == 3 // por Baixa
	cQuery += " AND E2_BAIXA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"' "
Endif	
If mv_par05 == 1 // Contabilizados = Não
	cQuery += " AND E2_LA = ' ' "
ElseIf mv_par05 == 2 // Contabilizados = Sim
	cQuery += " AND E2_LA = 'S' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, FORNECE, LOJA, PREFIXO, NUMERO, PARCELA, TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SE2_RATDIF"
	cNomeTable := "Inclusão de Rateios com Diferença - "+IIf(mv_par01==1,"Emissão ","Vencimento ")+DtoC(mv_par02)+" à "+DtoC(mv_par03)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Rateio",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Seq.Rateio",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Dt.Rateio",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Débito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Crédito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Percent.",3,2)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vlr.Rateio",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Digitado",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Hist.Rateio",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CC.Débito",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"It.Débito",1,1)
	//
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Natureza",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencimento",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Baixa",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CTB",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SE2")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO+FORNECE+LOJA) )
		
		cQuery := " SELECT SUM(CV4_VALOR)AS TOTRAT "
		cQuery += " FROM "+RetSqlName("CV4")
		cQuery += " WHERE CV4_FILIAL = '"+Substr(SE2->E2_ARQRAT,1,4)+"' "
		cQuery += " AND CV4_DTSEQ    = '"+Substr(SE2->E2_ARQRAT,5,8)+"' "
		cQuery += " AND CV4_SEQUEN   = '"+Substr(SE2->E2_ARQRAT,13,10)+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQ4", .F., .T.)
        lSkip := (SE2->E2_VALOR == SQ4->TOTRAT)
        SQ4->(DbCloseArea())

		If lSkip
			DbSelectArea("SQL")
			SQL->(DbSkip())
			Loop
		Endif
		
		lDados := .T.
		cv4Fil := Substr(SE2->E2_ARQRAT,1,4)
		cv4Dts := Substr(SE2->E2_ARQRAT,5,8)
		cv4Seq := Substr(SE2->E2_ARQRAT,13,10)
		DbSelectArea("CV4")
		DbSetOrder(1)
		DbSeek( cv4Fil + cv4Dts + cv4Seq )
		While !Eof() .And. CV4->(CV4_FILIAL+DTOS(CV4_DTSEQ)+CV4_SEQUEN) == cv4Fil + cv4Dts + cv4Seq

			zLocal  := FWFilialName(cEmpAnt,SE2->E2_FILIAL,1)
			zNomFor := RetField("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NOME")
			zNature := RetField("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"ED_DESCRIC")
	
			oExcel:AddRow(cNomePlan, cNomeTable, {CV4->CV4_SEQUEN, CV4->CV4_ITSEQ, CV4->CV4_DTSEQ, CV4->CV4_DEBITO, CV4->CV4_CREDIT,;
												  CV4->CV4_PERCEN, CV4->CV4_VALOR, 0, CV4->CV4_HIST, CV4->CV4_CCD, CV4->CV4_ITEMD,;
												  SE2->E2_FILIAL, zLocal, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO,;
			   									  zNomFor, zNature, SE2->E2_VALOR, SE2->E2_EMISSAO, SE2->E2_VENCREA,;
			   									  SE2->E2_BAIXA, SE2->E2_LA })

			DbSelectArea("CV4")
			CV4->(DbSkip())
		Enddo

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE2_RATDIF-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	lDados := .T.
	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())

If !lDados
	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")
Endif

Return
