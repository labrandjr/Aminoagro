#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SAPRCLI  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 30/05/2023      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exportação de Dados - Cadastro de Clientes.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SAPRCLI()

Local cPerg := "SAPRCLI"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If __cUserId == "000163"
		If MsgYesNo("Atualiza Última Nf ?","Aviso","INFO")
			MsgRun("Aguarde, atualizando data da última nota fiscal...","Processando",{|| UltmNota() })
		Endif
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pSapRcli()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pSapRcli  ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 30/05/2023     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pSapRcli()

Local oExcel := FwMsExcel():New()

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SA1")
cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND A1_MSBLQL <> '1' "
If mv_par01 == 1
	cQuery += " AND A1_PESSOA = 'J' "
ElseIf mv_par01 == 2
	cQuery += " AND A1_PESSOA = 'F' "
Endif
If mv_par02 == 1
	cQuery += " AND A1_MSBLQL <> '1' "
ElseIf mv_par02 == 2
	cQuery += " AND A1_MSBLQL = '1' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
nTotSql := SQL1->SOMA
SQL1->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ AS RECSA1 "
cQuery += " FROM "+RetSqlName("SA1")
cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
If mv_par01 == 1
	cQuery += " AND A1_PESSOA = 'J' "
ElseIf mv_par01 == 2
	cQuery += " AND A1_PESSOA = 'F' "
Endif
If mv_par02 == 1
	cQuery += " AND A1_MSBLQL <> '1' "
ElseIf mv_par02 == 2
	cQuery += " AND A1_MSBLQL = '1' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
ProcRegua(nTotSql)
SQL1->(DbGotop())
If !Eof()

	cNomePlan  := "exp_clientes"
	cNomeTable := "exp_clientes"

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Pessoa",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Código",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome Fantasia",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Endereço",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Bairro",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.IBGE",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Estado",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CEP",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Telefone",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"CNPJ/CPF",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"I.E.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Email",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Status",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Contribuinte",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("SA1")
		SA1->(DbGoto(SQL1->RECSA1))

		zPessoa := IIf(SA1->A1_PESSOA=="J","Jurídica","Física")
		zTipoCl := ""
		If SA1->A1_TIPO == "F"
			zTipoCl := "Cons.Final"
		ElseIf SA1->A1_TIPO == "L"
			zTipoCl := "Produtor Rural"
		ElseIf SA1->A1_TIPO == "R"
			zTipoCl := "Revendedor"
		ElseIf SA1->A1_TIPO == "S"
			zTipoCl := "Solidario"
		ElseIf SA1->A1_TIPO == "X"
			zTipoCl := "Exportação"
		Endif
		zStatus := IIf(SA1->A1_MSBLQL=="1","Inativo","Ativo")
		zContri := IIf(SA1->A1_CONTRIB=="1","Sim","Não")

		oExcel:AddRow(cNomePlan, cNomeTable, {zPessoa, SA1->A1_COD, SA1->A1_NOME, SA1->A1_NREDUZ, SA1->A1_END, SA1->A1_BAIRRO, SA1->A1_COD_MUN,;
											SA1->A1_MUN, SA1->A1_EST, SA1->A1_CEP, SA1->A1_TEL, SA1->A1_CGC, SA1->A1_INSCR, SA1->A1_EMAIL,;
											zTipoCl, zStatus, zContri })
		DbSelectArea("SQL1")
		SQL1->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "exp_clientes"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL1->(DbCloseArea())
	
Return


Static Function UltmNota()

cQuery := " SELECT R_E_C_N_O_ AS RECSA1 "
cQuery += " FROM "+RetSqlName("SA1")
cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()

	DbSelectArea("SA1")
	SA1->(DbGoto(SQL1->RECSA1))

	cQuery := " SELECT DISTINCT(F2_EMISSAO)AS EMISSAO "
	cQuery += " FROM "+RetSqlName("SF2")
	cQuery += " WHERE F2_CLIENTE = '"+SA1->A1_COD+"' "
	cQuery += " AND F2_TIPO NOT IN('D','B') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY F2_EMISSAO DESC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

	DbSelectArea("SQL2")
	SQL2->(DbGotop())
	If !Eof()
		RecLock("SA1",.F.)
		SA1->A1_ULTVIS := StoD(SQL2->EMISSAO)
		MsUnLock()
	Else
		If !Empty(SA1->A1_ULTCOM)
			RecLock("SA1",.F.)
			SA1->A1_ULTVIS := SA1->A1_ULTCOM
			MsUnLock()
		Endif
	Endif
	SQL2->(DbCloseArea())

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

Return
