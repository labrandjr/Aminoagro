#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FINR005  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 30/05/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Títulos liquidados x pagamentos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FINR005()

Local cPerg := "FINR05"
Private cPath := "c:\report\"
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFinR05()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFinR05   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 30/05/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFinR05()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local cKeyAnt  := ""
Local lKeyAnt  := .F.
Local nForFilial

Finr5Trab()

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
cQuery += " FROM "+RetSqlName("SE1") "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND E1_CLIENTE = '"+mv_par03+"' "
Endif
cQuery += " AND E1_TIPOLIQ <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT E1_FILIAL FILIAL, E1_CLIENTE CLIENTE, E1_LOJA LOJA, E1_PREFIXO PREFIXO, E1_NUM NUMERO, E1_PARCELA PARCELA, E1_TIPO TIPO "
cQuery += " FROM "+RetSqlName("SE1") "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
If !Empty(mv_par03)
	cQuery += " AND E1_CLIENTE = '"+mv_par03+"' "
Endif
cQuery += " AND E1_TIPOLIQ <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, CLIENTE, LOJA, PREFIXO, NUMERO, PARCELA, TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()

	IncProc("Preparando arquivo...")

	DbSelectArea("SE1")
	DbSetOrder(2)
	If !DbSeek( SQL->(FILIAL+CLIENTE+LOJA+PREFIXO+NUMERO+PARCELA+TIPO) )
		DbSelectArea("SQL")
		SQL->(DbSkip())
		Loop
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE1->E1_CLIENTE )

	cQuery := " SELECT E5_DOCUMEN NUM_NEG, E5_VALOR VAL_NEG "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '"+SE1->E1_FILIAL+"' "
	cQuery += " AND E5_PREFIXO = '"+SE1->E1_PREFIXO+"' "
	cQuery += " AND E5_NUMERO = '"+SE1->E1_NUM+"' "
	cQuery += " AND E5_PARCELA = '"+SE1->E1_PARCELA+"' "
	cQuery += " AND E5_TIPO = '"+SE1->E1_TIPO+"' "
	cQuery += " AND E5_DOCUMEN <> ' ' "
	cQuery += " AND E5_MOTBX = 'LIQ' "
	cQuery += " AND E5_TIPODOC = 'BA' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLI", .F., .T.)
	DbSelectArea("SQLI")
	SQLI->(DbGotop())
	While !Eof()

		zNumNeg  := AllTrim(SQLI->NUM_NEG)
		zValNeg  := SQLI->VAL_NEG
		zTotNeg  := u_TotNegoc(SE1->E1_FILIAL,zNumNeg)
		zPropNeg := (zValNeg / zTotNeg)
		//
		zTotPag  := _TotPag(zNumNeg)
		zValPag  := (zTotPag * zPropNeg)
		zInfoPag := _InfoPag(zNumNeg)
		zDatPag  := zInfoPag[1]
		zBcoPag  := zInfoPag[2]
	
		If zTotPag > 0
			RecLock("TRB",.T.)
			TRB->TF_CLIENTE := SA1->A1_COD
			TRB->TF_NOMCLI  := SA1->A1_NOME
			TRB->TF_FILIAL  := SE1->E1_FILIAL
			TRB->TF_PREFIXO := SE1->E1_PREFIXO
			TRB->TF_NUM     := SE1->E1_NUM
			TRB->TF_PARCELA := SE1->E1_PARCELA
			TRB->TF_TIPO    := SE1->E1_TIPO
			TRB->TF_IDTIT   := SE1->(E1_PREFIXO+"-"+E1_NUM+"-"+E1_PARCELA)
			TRB->TF_EMISSAO := SE1->E1_EMISSAO
			TRB->TF_VENCREA := SE1->E1_VENCREA
			TRB->TF_VALNEG  := zValNeg // Valor Negociado
			TRB->TF_PROP    := zPropNeg // Proporção ao total negociado
			TRB->TF_VALORPG := zValPag // Valor pago da negociação
			TRB->TF_PAGTO   := zDatPag // Data de pagamento mais recente da negociação
			TRB->TF_BANCO   := zBcoPag // Dados bancários do último pagamento da negociação
			MsUnLock()
		Endif

		DbSelectArea("SQLI")
		SQLI->(DbSkip())
	Enddo
	SQLI->(DbCloseArea())

	DbSelectArea("SQL")
	SQL->(DbSkip())
	
Enddo
SQL->(DbCloseArea())

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SE1_FINR05"
	cNomeTable := "Títulos negociados x pagamentos"
	If !Empty(mv_par03)
		cNomeTable += " - Cliente: "+Posicione("SA1",1,xFilial("SA1")+mv_par03,"A1_NOME")
	Endif
	cNomeTable += " - Emissão de "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Id.Título",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencimento",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor negociado",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor pago",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data Pagto.",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Banco",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emis. x Pagto.",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Venc. x Pagto.",3,1)

	While !Eof()

		IncProc("Gerando planilha...")

		If TRB->TF_VALORPG <= 0
			DbSelectArea("TRB")
			TRB->(DbSkip())
			Loop			
		Endif

		zDiasExP := TRB->TF_PAGTO - TRB->TF_EMISSAO
		zDiasVxP := TRB->TF_PAGTO - TRB->TF_VENCREA

		oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_CLIENTE, TRB->TF_NOMCLI, TRB->TF_FILIAL, TRB->TF_PREFIXO, TRB->TF_NUM, TRB->TF_PARCELA,;
		   									  TRB->TF_TIPO, TRB->TF_IDTIT, TRB->TF_EMISSAO, TRB->TF_VENCREA, TRB->TF_VALNEG, TRB->TF_VALORPG,;
		   									  TRB->TF_PAGTO, TRB->TF_BANCO, zDiasExP, zDiasVxP })
		DbSelectArea("TRB")
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE1_FINR05-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
¦¦¦Função    ¦ _TotPag   ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 31/05/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Total pago da negociação.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _TotPag(zNumNeg)

Local aArea   := GetArea()
Local zTotPag := 0

// Total baixado da negociação
cQuery := " SELECT SUM(E1_VALOR-E1_SALDO) AS TOT_PAG "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+SE1->E1_FILIAL+"' "
cQuery += " AND E1_NUMLIQ = '"+AllTrim(zNumNeg)+"' "
cQuery += " AND E1_SALDO < E1_VALOR "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLP", .F., .T.)
zTotPag := SQLP->TOT_PAG
SQLP->(DbCloseArea())

// Desconta valores baixados referente FAT ou LIQ (renegociações)
cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+SE1->E1_FILIAL+"' "
cQuery += " AND E1_NUMLIQ = '"+AllTrim(zNumNeg)+"' "
cQuery += " AND E1_SALDO < E1_VALOR "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E1_BAIXA DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLP", .F., .T.)

DbSelectArea("SQLP")
SQLP->(DbGotop())
While !Eof()

	cQuery := " SELECT SUM(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)AS PAGRENEG "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '"+SQLP->E1_FILIAL+"' "
	cQuery += " AND E5_PREFIXO = '"+SQLP->E1_PREFIXO+"' "
	cQuery += " AND E5_NUMERO = '"+SQLP->E1_NUM+"' "
	cQuery += " AND E5_PARCELA = '"+SQLP->E1_PARCELA+"' "
	cQuery += " AND E5_CLIFOR = '"+SQLP->E1_CLIENTE+"' "
	cQuery += " AND E5_MOTBX IN('FAT','LIQ') "
	cQuery += " AND E5_TIPODOC = 'BA'
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLN", .F., .T.)
	zTotPag -= SQLN->PAGRENEG
	SQLN->(DbCloseArea())

	DbSelectArea("SQLP")
	SQLP->(DbSkip())	
Enddo
SQLP->(DbCloseArea())

RestArea(aArea)

Return(zTotPag)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _InfoPag  ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 31/05/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Informações do pagamento da negociação.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _InfoPag(zNumNeg)

Local aArea   := GetArea()
Local zInfoPag := {}
Local lOkInfo  := .F.

AAdd(zInfoPag,CtoD(""))
AAdd(zInfoPag,"")

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+SE1->E1_FILIAL+"' "
cQuery += " AND E1_NUMLIQ = '"+zNumNeg+"' "
cQuery += " AND E1_SALDO < E1_VALOR "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E1_BAIXA DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLIP", .F., .T.)
DbSelectArea("SQLIP")
SQLIP->(DbGotop())
While !Eof()
	cQuery := " SELECT E5_DATA DAT_PAG, E5_BANCO BANCO, E5_AGENCIA AGENCIA, E5_CONTA CONTA "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '"+SQLIP->E1_FILIAL+"' "
	cQuery += " AND E5_PREFIXO = '"+SQLIP->E1_PREFIXO+"' "
	cQuery += " AND E5_NUMERO = '"+SQLIP->E1_NUM+"' "
	cQuery += " AND E5_PARCELA = '"+SQLIP->E1_PARCELA+"' "
	cQuery += " AND E5_MOTBX NOT IN('FAT','LIQ') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLB", .F., .T.)
	DbSelectArea("SQLB")
	SQLB->(DbGotop())
	If !Eof()
        lOkInfo := .T.
		zInfoPag[1] := StoD(SQLB->DAT_PAG)
		zInfoPag[2] := AllTrim(SQLB->BANCO)+"-"+AllTrim(SQLB->AGENCIA)+"-"+AllTrim(SQLB->CONTA)
	Endif	
	SQLB->(DbCloseArea())
	If lOkInfo
		Exit
	Endif	
	DbSelectArea("SQLIP")
	SQLIP->(DbSkip())
Enddo
SQLIP->(DbCloseArea())

RestArea(aArea)

Return(zInfoPag)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Finr5Trab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 31/05/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Finr5Trab()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_CLIENTE" , "C", 006, 00} )
AAdd ( _aTmp, {"TF_NOMCLI"  , "C", 040, 00} )
AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_PREFIXO" , "C", 003, 00} )
AAdd ( _aTmp, {"TF_NUM"     , "C", 009, 00} )
AAdd ( _aTmp, {"TF_PARCELA" , "C", 002, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 003, 00} )
AAdd ( _aTmp, {"TF_IDTIT"   , "C", 014, 00} )
AAdd ( _aTmp, {"TF_EMISSAO" , "D", 008, 00} )
AAdd ( _aTmp, {"TF_VENCREA" , "D", 008, 00} )
AAdd ( _aTmp, {"TF_VALNEG"  , "N", 014, 02} )
AAdd ( _aTmp, {"TF_PROP"    , "N", 005, 02} )
AAdd ( _aTmp, {"TF_PAGTO"   , "D", 008, 00} )
AAdd ( _aTmp, {"TF_VALORPG" , "N", 014, 02} )
AAdd ( _aTmp, {"TF_BANCO"   , "C", 018, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_NOMCLI", "TF_FILIAL", "TF_PREFIXO", "TF_NUM", "TF_PARCELA"})
oTempTable:Create()

Return
