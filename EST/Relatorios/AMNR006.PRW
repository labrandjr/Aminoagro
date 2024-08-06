#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR006  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 13/09/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório Slow Moving.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR006()

Local cPerg := "AMNR06"
Private cPath  := "c:\report\"
Private dUlMes := GetMv("MV_ULMES")
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmnR06()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR06   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 13/09/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR06()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local nForFilial

If !(__cUserId $( AllTrim(GetMv("MV_ZAMNR06")) ))
	MsgAlert("Usuário não autorizado. Contate o Administrador.")
	Return
Endif

If mv_par03 <= 0
	MsgAlert("Informe o No.Dias para critério de cálculo.")
	Return
Endif

Amnr6Trab()

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
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SB9")+" SB9, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SBM")+" SBM "
cQuery += " WHERE B9_FILIAL IN("+zFiliais+") "
cQuery += " AND B9_COD = B1_COD "
cQuery += " AND B1_GRUPO = BM_GRUPO "
cQuery += " AND B1_TIPO IN('PA','PI','MP','PR') "
cQuery += " AND B9_LOCAL NOT IN('06') "
cQuery += " AND B9_DATA = '"+DtoS(dUlMes)+"' "
If !Empty(mv_par01)
	cQuery += " AND B1_TIPO = '"+mv_par01+"' "
Endif	
If !Empty(mv_par02)
	cQuery += " AND B1_COD = '"+mv_par02+"' "
Endif	
cQuery += " AND SB9.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SBM.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT B9_FILIAL FILIAL, B9_COD PRODUTO, B1_DESC DESCRI, B1_TIPO TIPO, B1_GRUPO GRUPO, BM_DESC DESC_GRP, B1_UM UM, B9_LOCAL ARMAZEM, "
cQuery += " B9_DATA DATFEC, B9_QINI QINI, B9_VINI1 VINI1 "
cQuery += " FROM "+RetSqlName("SB9")+" SB9, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SBM")+" SBM "
cQuery += " WHERE B9_FILIAL IN("+zFiliais+") "
cQuery += " AND B9_COD = B1_COD "
cQuery += " AND B1_GRUPO = BM_GRUPO "
cQuery += " AND B1_TIPO IN('PA','PI','MP','PR') "
cQuery += " AND B9_LOCAL NOT IN('06') "
cQuery += " AND B9_DATA = '"+DtoS(dUlMes)+"' "
If !Empty(mv_par01)
	cQuery += " AND B1_TIPO = '"+mv_par01+"' "
Endif	
If !Empty(mv_par02)
	cQuery += " AND B1_COD = '"+mv_par02+"' "
Endif	
cQuery += " AND SB9.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SBM.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY B9_FILIAL, B9_COD, B9_LOCAL "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()

	IncProc("Slow Moving...")

	nDSlow := 0
	dtUltT := CtoD("")
	dtUltI := CtoD("")
	dtUltE := CtoD("")
	dtUltS := u__UltSaida(SQL->FILIAL,SQL->PRODUTO)
	lSlowM := .F.

	If !Empty(dtUltS)
		nDSlow := (dUlMes - dtUltS) // Calcula pela última saída
		lSlowM := .T.
	Endif

	If !lSlowM
		dtUltE := u__UltEntr(SQL->FILIAL,SQL->PRODUTO)
		If !Empty(dtUltE)
			nDSlow := (dUlMes - dtUltE) // Calcula pela última entrada
			lSlowM := .T.
		Endif	
	Endif

	If !lSlowM
		dtUltT := u__UltTrans(SQL->FILIAL,SQL->PRODUTO)
		If !Empty(dtUltT)
			nDSlow := (dUlMes - dtUltT) // Calcula pela entrada via transferência de outro código
			lSlowM := .T.
		Endif	
	Endif

	If !lSlowM
		dtUltI := u__UltSaldo(SQL->FILIAL,SQL->PRODUTO)
		If !Empty(dtUltI)
			nDSlow := (dUlMes - dtUltI) // Calcula pelo saldo inicial digitado
			lSlowM := .T.
		Endif	
	Endif

	If lSlowM
		RecLock("TRB",.T.)
		TRB->TF_FILIAL := SQL->FILIAL
		TRB->TF_COD    := SQL->PRODUTO
		TRB->TF_DESCRI := SQL->DESCRI
		TRB->TF_TIPO   := SQL->TIPO
		TRB->TF_GRUPO  := SQL->GRUPO
		TRB->TF_DESCGR := SQL->DESC_GRP
		TRB->TF_UM     := SQL->UM
		TRB->TF_LOCAL  := SQL->ARMAZEM
		TRB->TF_DATA   := StoD(SQL->DATFEC)
		TRB->TF_QINI   := SQL->QINI
		TRB->TF_VINI1  := SQL->VINI1
		TRB->TF_DTULTS := dtUltS
		TRB->TF_DTULTE := dtUltE
		TRB->TF_DTULTT := dtUltT
		TRB->TF_DTULTI := dtUltI
		TRB->TF_SLOWMV := IIf(nDSlow > mv_par03,"Sim","Não")
		TRB->TF_NDIAS  := nDSlow
		MsUnLock()
	Endif

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SB9_AMNR06"
	cNomeTable := "Slow Moving - "+AllTrim(STR(mv_par03))+" dias"

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descricao",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Desc Grupo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unid",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Armazem",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Fecham.",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Qtd Inic Mes",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Custo Medio",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Sld Ini.Mes",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Saída",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Entrada",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Transf.",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Últ.Sld.Ini.",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Slow Moving",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"No.Dias",3,1)

	While !Eof()

		IncProc("Gerando planilha...")

		zLocal := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
		zCmedi := IIf(TRB->TF_VINI1 > 0, Round((TRB->TF_VINI1 / TRB->TF_QINI),2), 0)
		oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, TRB->TF_FILIAL, TRB->TF_COD, TRB->TF_DESCRI, TRB->TF_TIPO, TRB->TF_GRUPO, TRB->TF_DESCGR, TRB->TF_UM,;
					  						  TRB->TF_LOCAL, TRB->TF_DATA, TRB->TF_QINI, zCmedi, TRB->TF_VINI1, TRB->TF_DTULTS, TRB->TF_DTULTE, TRB->TF_DTULTT,;
					  						  TRB->TF_DTULTI, TRB->TF_SLOWMV, TRB->TF_NDIAS })
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SB9_AMNR06-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
¦¦¦Função    ¦ Amnr6Trab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 27/08/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Amnr6Trab()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_COD"     , "C", 015, 00} )
AAdd ( _aTmp, {"TF_DESCRI"  , "C", 040, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 002, 00} )
AAdd ( _aTmp, {"TF_GRUPO"   , "C", 004, 00} )
AAdd ( _aTmp, {"TF_DESCGR"  , "C", 030, 00} )
AAdd ( _aTmp, {"TF_UM"      , "C", 002, 00} )
AAdd ( _aTmp, {"TF_LOCAL"   , "C", 002, 00} )
AAdd ( _aTmp, {"TF_DATA"    , "D", 008, 00} )
AAdd ( _aTmp, {"TF_QINI"    , "N", 017, 05} )
AAdd ( _aTmp, {"TF_VINI1"   , "N", 017, 02} )
AAdd ( _aTmp, {"TF_DTULTS"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_DTULTE"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_DTULTT"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_DTULTI"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_SLOWMV"  , "C", 003, 00} )
AAdd ( _aTmp, {"TF_NDIAS"   , "N", 010, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_COD", "TF_LOCAL"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _UltSaida ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  13/09/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pesquisa último movimento de saída.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function _UltSaida(zFilial,zProduto)

Local aArea  := GetArea()
Local dUlMov := CtoD("")
Local zTipo  := Posicione("SB1",1,xFilial("SB1")+zProduto,"B1_TIPO")

If zFilial == "0108"
	zFilial := "'0104','0108'"
ElseIf zFilial == "0107"
	zFilial := "'0104','0107','0108'"
ElseIf zFilial == "0106"
	zFilial := "'0103','0106'"
Else
	zFilial := "'"+zFilial+"'"
Endif

If zTipo $("PA,PR") // Documento de Saída
	cQuery := " SELECT MAX(D2_EMISSAO) AS ULMOV "
	cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
	cQuery += RetSqlName("SF4")+" SF4 "
	cQuery += " WHERE D2_FILIAL IN("+zFilial+") "
	cQuery += " AND D2_COD = '"+AllTrim(zProduto)+"' "
	cQuery += " AND D2_FILIAL = F4_FILIAL "
	cQuery += " AND D2_TES = F4_CODIGO "
	cQuery += " AND D2_EMISSAO < '"+DtoS(dUlMes)+"' "
	cQuery += " AND D2_TIPO = 'N' "
	cQuery += " AND D2_ORIGLAN = ' ' "
	cQuery += " AND F4_DUPLIC = 'S' "
	cQuery += " AND F4_ESTOQUE = 'S' "
	cQuery += " AND D2_ORIGLAN <> 'LF' "
	cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
	cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
	DbSelectArea("SQL2")
	SQL2->(DbGotop())
	If !Eof()
		dUlMov := StoD(SQL2->ULMOV)
	Endif
	SQL2->(DbCloseArea())
ElseIf zTipo $("PI,MP") // Requisição para Produção
	cQuery := " SELECT MAX(D3_EMISSAO) AS ULMOV "
	cQuery += " FROM "+RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL IN("+zFilial+") "
	cQuery += " AND D3_COD = '"+zProduto+"' "
	cQuery += " AND D3_EMISSAO < '"+DtoS(dUlMes)+"' "
	cQuery += " AND D3_OP <> ' ' "
	cQuery += " AND D3_ESTORNO = ' ' "
	cQuery += " AND SUBSTR(D3_CF,1,2) = 'RE' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	DbSelectArea("SQL3")
	SQL3->(DbGotop())
	If !Eof()
		dUlMov := StoD(SQL3->ULMOV)
	Endif
	SQL3->(DbCloseArea())
Endif

RestArea(aArea)

Return(dUlMov)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _UltEntr ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  13/09/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pesquisa último movimento de entrada.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function _UltEntr(zFilial,zProduto)

Local aArea  := GetArea()
Local dUlMov := CtoD("")
Local zTipo  := Posicione("SB1",1,xFilial("SB1")+zProduto,"B1_TIPO")

If zFilial == "0108"
	zFilial := "'0104','0108'"
ElseIf zFilial == "0107"
	zFilial := "'0104','0107','0108'"
ElseIf zFilial == "0106"
	zFilial := "'0103','0106'"
Else
	zFilial := "'"+zFilial+"'"
Endif

If zTipo $("PA,PI") // Apontamento de Produção
	cQuery := " SELECT MAX(D3_EMISSAO) AS ULMOV "
	cQuery += " FROM "+RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL IN("+zFilial+") "
	cQuery += " AND D3_COD = '"+zProduto+"' "
	cQuery += " AND D3_EMISSAO < '"+DtoS(dUlMes)+"' "
	cQuery += " AND D3_OP <> ' ' "
	cQuery += " AND D3_ESTORNO = ' ' "
	cQuery += " AND SUBSTR(D3_CF,1,2) = 'PR' "
	cQuery += " AND D3_COD <> 'MANUTENCAO' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	DbSelectArea("SQL3")
	SQL3->(DbGotop())
	If !Eof()
		dUlMov := StoD(SQL3->ULMOV)
	Endif
	SQL3->(DbCloseArea())
ElseIf zTipo $("MP,PR") // Documento de Entrada
	cQuery := " SELECT MAX(D1_DTDIGIT) AS ULMOV "
	cQuery += " FROM "+RetSqlName("SD1")+" SD1, "
	cQuery += RetSqlName("SF4")+" SF4 "
	cQuery += " WHERE D1_FILIAL IN("+zFilial+") "
	cQuery += " AND D1_COD = '"+zProduto+"' "
	cQuery += " AND D1_FILIAL = F4_FILIAL "
	cQuery += " AND D1_TES = F4_CODIGO "
	cQuery += " AND D1_DTDIGIT < '"+DtoS(dUlMes)+"' "
	cQuery += " AND D1_TIPO = 'N' "
	cQuery += " AND D1_ORIGLAN <> 'LF' "
	cQuery += " AND F4_DUPLIC = 'S' "
	cQuery += " AND F4_ESTOQUE = 'S' "
	cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	DbSelectArea("SQL1")
	SQL1->(DbGotop())
	If !Eof()
		dUlMov := StoD(SQL1->ULMOV)
	Endif
	SQL1->(DbCloseArea())
Endif

RestArea(aArea)

Return(dUlMov)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _UltSaldo ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  13/09/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pesquisa último saldo inicial com quantidade.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function _UltSaldo(zFilial,zProduto)

Local aArea  := GetArea()
Local dUlMov := CtoD("")

If zFilial == "0108"
	zFilial := "'0104','0108'"
ElseIf zFilial == "0107"
	zFilial := "'0104','0107','0108'"
ElseIf zFilial == "0106"
	zFilial := "'0103','0106'"
Else
	zFilial := "'"+zFilial+"'"
Endif

cQuery := " SELECT MIN(B9_DATA) AS ULMOV "
cQuery += " FROM "+RetSqlName("SB9")
cQuery += " WHERE B9_FILIAL IN("+zFilial+") "
cQuery += " AND B9_COD = '"+zProduto+"' "
cQuery += " AND B9_DATA < '"+DtoS(dUlMes)+"' "
cQuery += " AND B9_DATA <> ' ' "
cQuery += " AND B9_QINI > 0 "
cQuery += " AND B9_LOCAL <> '06' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL9", .F., .T.)
DbSelectArea("SQL9")
SQL9->(DbGotop())
If !Eof()
	dUlMov := StoD(SQL9->ULMOV)
Endif
SQL9->(DbCloseArea())

RestArea(aArea)

Return(dUlMov)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _UltTrans ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  13/09/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pesquisa última entrada via transferência de outro código. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function _UltTrans(zFilial,zProduto)

Local aArea  := GetArea()
Local dUlMov := CtoD("")
Local lUlMov := .F.

If zFilial == "0108"
	zFilial := "'0104','0108'"
ElseIf zFilial == "0107"
	zFilial := "'0104','0107','0108'"
ElseIf zFilial == "0106"
	zFilial := "'0103','0106'"
Else
	zFilial := "'"+zFilial+"'"
Endif

cQuery := " SELECT D3_FILIAL, D3_NUMSEQ "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL IN("+zFilial+") "
cQuery += " AND D3_COD = '"+zProduto+"' "
cQuery += " AND D3_EMISSAO <= '"+DtoS(dUlMes)+"' "
cQuery += " AND D3_LOCAL <> '06' "
cQuery += " AND D3_CF = 'DE4' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D3_EMISSAO DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
DbSelectArea("SQL3")
SQL3->(DbGotop())
While !Eof()

	cQuery := " SELECT D3_EMISSAO ULMOV "
	cQuery += " FROM "+RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL = '"+SQL3->D3_FILIAL+"' "
	cQuery += " AND D3_NUMSEQ = '"+SQL3->D3_NUMSEQ+"' "
	cQuery += " AND D3_CF = 'RE4' "
	cQuery += " AND D3_COD <> '"+zProduto+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLX", .F., .T.)
	DbSelectArea("SQLX")
	SQLX->(DbGotop())
	If !Eof()
		If !Empty(SQLX->ULMOV)
			dUlMov := StoD(SQLX->ULMOV)
			lUlMov := .T.
		Endif
	Endif
	SQLX->(DbCloseArea())
	
	If lUlMov
		Exit
	Endif
	
	DbSelectArea("SQL3")
	SQL3->(DbSkip())
Enddo
SQL3->(DbCloseArea())

RestArea(aArea)

Return(dUlMov)
