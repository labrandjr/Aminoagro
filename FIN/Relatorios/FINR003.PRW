#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FINR003  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 08/09/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Análise e desempenho do contas a receber.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FINR003()

Local cPerg := "FINR03"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFinR03()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFinR03   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 08/09/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFinR03()

Local oExcel  := FwMsExcel():New()
Local zFiliais := ""
Local cKeyAnt := ""
Local lKeyAnt := .F.
Local nForFilial

aFilsCalc := MatFilCalc( mv_par03 == 1 )
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
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
If mv_par04 == 1 // Vencto.
	cQuery += " AND E1_VENCTO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
Else // Vencto.Real
	cQuery += " AND E1_VENCREA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT E1_FILIAL FILIAL, E1_PREFIXO PREFIXO, E1_NUM NUMERO, E1_PARCELA PARCELA, E1_TIPO TIPO, E1_CLIENTE CLIENTE, E1_LOJA LOJA, "
cQuery += " E1_NOMCLI NOMCLI, E1_EMISSAO EMISSAO, E1_VENCREA VENCREA, E1_VALOR VALOR, E1_SALDO SALDO, E1_BAIXA BAIXA "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
If mv_par04 == 1 // Vencto.
	cQuery += " AND E1_VENCTO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
Else // Vencto.Real
	cQuery += " AND E1_VENCREA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, CLIENTE, LOJA, PREFIXO, NUMERO, PARCELA, TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SE1_FINR03"
	cNomeTable := "Contas a Receber - "+IIf(mv_par04 == 1,"por Vencimento - ","por Vencimento Real - ")+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Código",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Natureza",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descr.Natureza",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.Real",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pago no Período",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Em Atraso",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Pago fora Período",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( SQL->(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO+CLIENTE+LOJA) )

		// Valor Baixado p/Liquidação
		DbSelectArea("FI7")
		DbSetOrder(1)
		If DbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
			DbSelectArea("SQL")
			SQL->(DbSkip())
			Loop
		Endif

		zLocal  := FWFilialName(cEmpAnt,SE1->E1_FILIAL,1)
		zNomCli := RetField("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_NOME")
		zNomCli := StrTran(zNomCli,"&","E")
		zCodNat := SE1->E1_NATUREZ
		zNature := RetField("SED",1,xFilial("SED")+SE1->E1_NATUREZ,"ED_DESCRIC")
		zValor  := SE1->E1_VALOR
		zVlPago := IIf(SE1->E1_BAIXA >= mv_par01 .And. SE1->E1_BAIXA <= mv_par02,SE1->(E1_VALOR-E1_SALDO),0)
		zVlAtra := SE1->E1_SALDO
		zVlFora := IIf(SE1->E1_BAIXA < mv_par01 .Or. SE1->E1_BAIXA > mv_par02,SE1->(E1_VALOR-E1_SALDO),0)

		If SE1->E1_TIPO == "NCC" .Or. Substr(SE1->E1_TIPO,3,1) == "-"
			zValor  := zValor*-1
			zVlPago := zVlPago*-1
			zVlAtra := zVlAtra*-1
			zVlFora := zVlFora*-1
		Endif
	
		oExcel:AddRow(cNomePlan, cNomeTable, {SE1->E1_FILIAL, zLocal, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, zNomCli,;
		   									  zCodNat, zNature, SE1->E1_EMISSAO, SE1->E1_VENCTO, SE1->E1_VENCREA,;
		   									  zValor, zVlPago, zVlAtra, zVlFora })

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE1_FINR03-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
