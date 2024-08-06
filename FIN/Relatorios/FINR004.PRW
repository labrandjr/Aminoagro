#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FINR004  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 16/01/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Posição à Receber x Limite de Crédito.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FINR004()

Local cPerg := "FINR04"
Private cPath := "c:\report\"
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFinR04()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFinR04   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 08/09/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFinR04()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local cKeyAnt  := ""
Local lKeyAnt  := .F.
Local nForFilial

Finr4Trab()

aFilsCalc := MatFilCalc( mv_par06 == 1 )
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
cQuery += " FROM "+RetSqlName("SE1")+" SE1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_CLIENTE = A1_COD "
cQuery += " AND E1_LOJA = A1_LOJA "
cQuery += " AND E1_SALDO > 0 "
If !Empty(mv_par01)
	cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+Substr(mv_par01,1,8)+"' "
Endif
If !Empty(mv_par02)
	cQuery += " AND ((A1_ZZAGCRD = '"+mv_par02+"') OR (A1_COD = '"+mv_par02+"')) "
Endif
If !Empty(mv_par03)
	cQuery += " AND A1_COD = '"+mv_par03+"' "
Endif
cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par04)+"' AND '"+DtoS(mv_par05)+"' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT E1_FILIAL FILIAL, E1_CLIENTE CLIENTE, E1_LOJA LOJA, A1_NOME NOMCLI, E1_PREFIXO PREFIXO, E1_NUM NUMERO, E1_PARCELA PARCELA, E1_TIPO TIPO, "
cQuery += " E1_PEDIDO PEDIDO, E1_VALOR VALOR, E1_SALDO SALDO, E1_SDACRES SDACRES, E1_SDDECRE SDDECRE, E1_DESCFIN DESCFIN, E1_VENCREA VENCREA, A1_CGC CGCCLI, "
cQuery += " A1_ZZAGCRD ZZAGCRD, A1_LC LIMCRD, A1_VENCLC VENCLC, A1_MUN MUN, A1_EST EST, A1_ZZCLASS "
cQuery += " FROM "+RetSqlName("SE1")+" SE1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_CLIENTE = A1_COD "
cQuery += " AND E1_LOJA = A1_LOJA "
cQuery += " AND E1_SALDO > 0 "
If !Empty(mv_par01)
	cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+Substr(mv_par01,1,8)+"' "
Endif
If !Empty(mv_par02)
	cQuery += " AND ((A1_ZZAGCRD = '"+mv_par02+"') OR (A1_COD = '"+mv_par02+"')) "
Endif
If !Empty(mv_par03)
	cQuery += " AND A1_COD = '"+mv_par03+"' "
Endif
cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par04)+"' AND '"+DtoS(mv_par05)+"' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
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
	DbSeek( xFilial("SA1") + SQL->CLIENTE )
	zAgrCrd := ""

	nRecSA1 := SA1->(Recno())
	If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
		zAgrCrd := SA1->A1_ZZAGCRD
	Else
		If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek( xFilial("SA1") + SA1->A1_ZZAGCRD )
				zAgrCrd := SA1->A1_COD
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
				zAgrCrd := SA1->A1_COD
			Endif	
		Endif
	Endif
	SA1->(DbGoto(nRecSA1))

	zBU := ""
	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek( SQL->(FILIAL+PEDIDO) )
		zBU := SC5->C5_ZZITCTB
	Endif

	DbSelectArea("TRB")
	DbSetOrder(1)
	If !DbSeek( SQL->CLIENTE )
		RecLock("TRB",.T.)
		TRB->TF_CLIENTE := SQL->CLIENTE
		TRB->TF_NOMCLI  := SA1->A1_NOME
		TRB->TF_ZZCLASS := SA1->A1_ZZCLASS
		TRB->TF_CGC     := SA1->A1_CGC
		TRB->TF_ZZAGCRD := zAgrCrd
		TRB->TF_LC      := SA1->A1_LC
		TRB->TF_VENCLC  := SA1->A1_VENCLC
		TRB->TF_MUN     := SA1->A1_MUN
		TRB->TF_EST     := SA1->A1_EST
		TRB->TF_BU      := zBU
	Else
		RecLock("TRB",.F.)
	Endif
	If Empty(TRB->TF_BU)
		TRB->TF_BU := zBU
	ElseIf zBU != TRB->TF_BU
		TRB->TF_BU := "BUN"
	Endif

	zVencRea := StoD(SQL->VENCREA)
	zDescPon := 0
	If SQL->DESCFIN > 0
		zDescPon := IIf(zVencRea >= Date(), SQL->VALOR*(SQL->DESCFIN/100), 0)
	Endif	

	zSaldos := IIf(SQL->TIPO == "NCC" .Or. AllTrim(SQL->TIPO) == "RA", SQL->SALDO*-1, SQL->SALDO)
	zSaldos += SQL->SDACRES
	zSaldos -= SQL->SDDECRE
	zSaldoc := zSaldos - zDescPon

	TRB->TF_SALDOC += zSaldoc
	TRB->TF_SALDOS += zSaldos
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())
	
Enddo
SQL->(DbCloseArea())

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SE1_FINR04"
	cNomeTable := "Posição a Receber"
	If !Empty(mv_par01)
		cNomeTable += " - Base Cgc: "+Substr(mv_par01,1,8)
	Endif
	If !Empty(mv_par02)	
		cNomeTable += " - Grupo Créd.: "+mv_par02
	Endif
	If !Empty(mv_par03)
		cNomeTable += " - Cliente: "+mv_par03
	Endif
	cNomeTable += " - Emissão de "+DtoC(mv_par04)+" à "+DtoC(mv_par05)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Classe Valor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cnpj",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Agrup.Créd.",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Lim.Crédito",3,3) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Venc.Lim.Créd.",1,4) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Município",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Estado",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"BU",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Saldo c/ Desc.",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Saldo s/ Desc.",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_CLIENTE, TRB->TF_NOMCLI, TRB->TF_ZZCLASS, TRB->TF_CGC, TRB->TF_ZZAGCRD, TRB->TF_LC,;
		   									  TRB->TF_VENCLC, TRB->TF_MUN, TRB->TF_EST, TRB->TF_BU, TRB->TF_SALDOC, TRB->TF_SALDOS })

		DbSelectArea("TRB")
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE1_FINR04-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
¦¦¦Função    ¦ Finr4Trab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 16/01/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Finr4Trab()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_CLIENTE" , "C", 006, 00} )
AAdd ( _aTmp, {"TF_NOMCLI"  , "C", 040, 00} )
AAdd ( _aTmp, {"TF_ZZCLASS" , "C", 009, 00} )
AAdd ( _aTmp, {"TF_CGC"     , "C", 014, 00} )
AAdd ( _aTmp, {"TF_ZZAGCRD" , "C", 006, 00} )
AAdd ( _aTmp, {"TF_LC"      , "N", 014, 02} )
AAdd ( _aTmp, {"TF_VENCLC"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_MUN"     , "C", 060, 00} )
AAdd ( _aTmp, {"TF_EST"     , "C", 002, 00} )
AAdd ( _aTmp, {"TF_BU"      , "C", 003, 00} )
AAdd ( _aTmp, {"TF_SALDOC"  , "N", 014, 02} )
AAdd ( _aTmp, {"TF_SALDOS"  , "N", 014, 02} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_CLIENTE"})
oTempTable:Create()

Return
