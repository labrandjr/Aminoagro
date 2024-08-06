#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SAPRFOR  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 30/05/2023      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exportação de Dados - Cadastro de Fornecedores.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SAPRFOR()

Local cPerg := "SAPRFOR"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pSapRfor()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pSapRfor  ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 30/05/2023     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pSapRfor()

Local oExcel  := FwMsExcel():New()
Local nSequen := 0

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SA2")
cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
cQuery += " AND A2_MSBLQL <> '1' "
If mv_par01 == 1
	cQuery += " AND A2_TIPO IN('J','X') "
ElseIf mv_par01 == 2
	cQuery += " AND A2_TIPO IN('F','X') "
Endif
If mv_par02 == 1
	cQuery += " AND A2_MSBLQL <> '1' "
ElseIf mv_par02 == 2
	cQuery += " AND A2_MSBLQL = '1' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
nTotSql := SQL2->SOMA
SQL2->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECSA2 "
cQuery += " FROM "+RetSqlName("SA2")
cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
If mv_par01 == 1
	cQuery += " AND A2_TIPO IN('J','X') "
ElseIf mv_par01 == 2
	cQuery += " AND A2_TIPO IN('F','X') "
Endif
If mv_par02 == 1
	cQuery += " AND A2_MSBLQL <> '1' "
ElseIf mv_par02 == 2
	cQuery += " AND A2_MSBLQL = '1' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A2_FILIAL, A2_COD, A2_LOJA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

DbSelectArea("SQL2")
ProcRegua(nTotSql)
SQL2->(DbGotop())
If !Eof()

	cNomePlan  := "exp_fornecedores"
	cNomeTable := "exp_fornecedores"

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"ID de Controle",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Empresa",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Organ. Compras",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grupo Contas",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Forma de Tratamento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome1",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CEP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CNPJ",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CPF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"IE",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"País",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Chave Banco",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Conta Bancaria",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Chv. Controle",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo Banco Parceiro",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Conta Conciliação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Chave Ordenação",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Condição Pagamento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Verif. Fatura",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Formas Pagto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Categoria do IRF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Código IRF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"SUJEITO",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Moeda",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Esquema de Calculo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"REVFATEM",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SA2")
		SA2->(DbGoto(SQL2->RECSA2))

		nSequen += 1
		cSequen := AllTrim(STR(nSequen))
		zCnpj   := IIf(SA2->A2_TIPO$"J,X",SA2->A2_CGC,"")
		zCpf    := IIf(SA2->A2_TIPO=="F",SA2->A2_CGC,"")
		zMoeda  := IIf(SA2->A2_PAIS=="105" .Or. Empty(SA2->A2_PAIS),"BRL","USD")

		zChvBco := AllTrim(SA2->A2_BANCO)+"X"+AllTrim(SA2->A2_AGENCIA)
		zConta  := SA2->A2_NUMCON
		nPosTr  := AT("-",zConta)
		If nPosTr > 0
			zConta := Substr(zConta,1,nPosTr-1)
		Endif
		zDigCon := IIf(!Empty(SA2->A2_DVCTA), SA2->A2_DVCTA, "")
		If Empty(zDigCon)
			If nPosTr > 0
				zDigCon := Substr(zConta, nPosTr+1)
			Endif
		Endif

		DbSelectArea("SYA")
		DbSetOrder(1)
		DbSeek( xFilial("SYA") + SA2->A2_PAIS )
		zPais  := SYA->YA_DESCR

		oExcel:AddRow(cNomePlan, cNomeTable, {cSequen, "0100", "0002", "", SA2->A2_NOME, SA2->A2_NREDUZ, SA2->A2_CEP,;
											zCnpj, zCpf, SA2->A2_INSCR, zPais, zChvBco, zConta, zDigCon, "", "", "", "",;
											"X", "", "", "", "", zMoeda, "", "X"})
		DbSelectArea("SQL2")
		SQL2->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "exp_fornecedores"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL2->(DbCloseArea())
	
Return
