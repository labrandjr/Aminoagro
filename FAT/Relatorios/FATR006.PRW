#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FATR006  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/08/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório Metas x Realizado.							  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FATR006()

Local cPerg := "FATR06"
Private cPath := "c:\report\"
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFatR06()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFatR06   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 29/08/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFatR06()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local zCfAdmv  := FormatIn( AllTrim(GetMv("MV_XCFADMV")), ",")
Local nForFilial

Fatr6Trab()

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

// 1. Metas
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SCT")
cQuery += " WHERE CT_FILIAL = '"+xFilial("SCT")+"' "
cQuery += " AND CT_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND CT_MSBLQL <> '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT CT_DATA, CT_VEND, CT_REGIAO, CT_ITEMCC, CT_VALOR "
cQuery += " FROM "+RetSqlName("SCT")
cQuery += " WHERE CT_FILIAL = '"+xFilial("SCT")+"' "
cQuery += " AND CT_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND CT_MSBLQL <> '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()

	IncProc("Calculando metas...")

	If Empty(SQL->CT_VEND)
		DbSelectArea("SQL")
		SQL->(DbSkip())
		Loop	
	Endif

	DbSelectArea("TRB")
	DbSetOrder(1)
	If !DbSeek( SQL->CT_VEND + SQL->CT_REGIAO + SQL->CT_ITEMCC )
		RecLock("TRB",.T.)
		TRB->TF_VEND   := SQL->CT_VEND
		TRB->TF_REGIAO := SQL->CT_REGIAO
		TRB->TF_ITEMCC := SQL->CT_ITEMCC
	Else
		RecLock("TRB",.F.)
	Endif
	TRB->TF_VLRMET += SQL->CT_VALOR
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

// 2. Faturamento
IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL IN("+zFiliais+") "
cQuery += " AND D2_FILIAL = F2_FILIAL "
cQuery += " AND D2_DOC = F2_DOC "
cQuery += " AND D2_SERIE = F2_SERIE "
cQuery += " AND D2_CLIENTE = F2_CLIENTE "
cQuery += " AND D2_LOJA = F2_LOJA "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND SUBSTR(D2_COD,1,3) NOT IN('SER','TMS') "
If mv_par03 == 1 // CFOP Adm.Vendas
	cQuery += " AND D2_CF IN"+zCfAdmv
Endif
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
nTotSql := SQL2->SOMA
SQL2->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT D2_ITEMCC ITEMCC, D2_FILIAL FILIAL, D2_DOC DOC, D2_SERIE SERIE, D2_COD COD, B1_DESC DESCRI, B1_ZZMARCA ZZMARCA, B1_ZZCATEG ZZCATEG, "
cQuery += " D2_QUANT QUANT, D2_PRCVEN PRCVEN, D2_TOTAL TOTAL, D2_VALICM VALICM, D2_CF CFOP, D2_PEDIDO PEDIDO, D2_ITEMPV ITEMPV, D2_LOTECTL LOTECTL, "
cQuery += " D2_CLIENTE CLIENTE, D2_LOJA LOJA, A1_NOME NOMCLI, A1_ZZGECON ZZGECON, D2_EMISSAO EMISSAO, A1_EST EST, F2_VEND1 VEND1, F2_ZZREGVE ZZREGVE, "
cQuery += " D2_CCUSTO CCUSTO, D2_SEGURO SEGURO, D2_VALFRE VALFRE "
cQuery += " FROM "+RetSqlName("SD2")+" SD2, "
cQuery += RetSqlName("SF2")+" SF2, "
cQuery += RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SF4")+" SF4 "
cQuery += " WHERE D2_FILIAL IN("+zFiliais+") "
cQuery += " AND D2_FILIAL = F2_FILIAL "
cQuery += " AND D2_DOC = F2_DOC "
cQuery += " AND D2_SERIE = F2_SERIE "
cQuery += " AND D2_CLIENTE = F2_CLIENTE "
cQuery += " AND D2_LOJA = F2_LOJA "
cQuery += " AND D2_CLIENTE = A1_COD "
cQuery += " AND D2_LOJA = A1_LOJA "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D2_TES = F4_CODIGO "
cQuery += " AND D2_FILIAL = F4_FILIAL "
cQuery += " AND D2_TIPO = 'N' "
cQuery += " AND D2_ORIGLAN = ' ' "
cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND F4_DUPLIC = 'S' "
cQuery += " AND SUBSTR(D2_COD,1,3) NOT IN('SER','TMS') "
If mv_par03 == 1 // CFOP Adm.Vendas
	cQuery += " AND D2_CF IN"+zCfAdmv
Endif
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY EMISSAO, VEND1, ZZREGVE, CCUSTO, ITEMCC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

DbSelectArea("SQL2")
ProcRegua(nTotSql)
SQL2->(DbGotop())
While !Eof()

	IncProc("Calculando faturamento...")

	If Empty(SQL2->VEND1)
		DbSelectArea("SQL2")
		SQL2->(DbSkip())
		Loop	
	Endif

	DbSelectArea("TRB")
	DbSetOrder(1)
	If !DbSeek( SQL2->VEND1 + SQL2->ZZREGVE + SQL2->ITEMCC )
		RecLock("TRB",.T.)
		TRB->TF_VEND   := SQL2->VEND1
		TRB->TF_REGIAO := SQL2->ZZREGVE
		TRB->TF_ITEMCC := SQL2->ITEMCC
	Else
		RecLock("TRB",.F.)
	Endif
	TRB->TF_VLRFAT += SQL2->(TOTAL+VALFRE+SEGURO)
	MsUnLock()

	DbSelectArea("SQL2")
	SQL2->(DbSkip())
Enddo
SQL2->(DbCloseArea())

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SD2_FATR06"
	cNomeTable := "Metas x Realizado"
	cNomeTable += " - "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Vendedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Nome",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Região",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Unid.Neg.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Meta R$",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Real R$",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Diferença R$",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		zNomeVen := RetField("SA3",1,xFilial("SA3")+TRB->TF_VEND,"A3_NOME")
		zDescReg := RetField("SX5",1,xFilial("SX5")+"A2"+PadR(TRB->TF_REGIAO,6),"X5_DESCRI")
		zDiferen := TRB->TF_VLRFAT - TRB->TF_VLRMET
		
		oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_VEND, zNomeVen, TRB->TF_REGIAO, zDescReg, TRB->TF_ITEMCC,;
											  TRB->TF_VLRMET, TRB->TF_VLRFAT, zDiferen })

		DbSelectArea("TRB")
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SCT_FATR06-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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
¦¦¦Função    ¦ Fatr6Trab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 27/08/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Fatr6Trab()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_VEND"    , "C", 006, 00} )
AAdd ( _aTmp, {"TF_REGIAO"  , "C", 003, 00} )
AAdd ( _aTmp, {"TF_ITEMCC"  , "C", 009, 00} )
AAdd ( _aTmp, {"TF_VLRMET"  , "N", 017, 02} )
AAdd ( _aTmp, {"TF_VLRFAT"  , "N", 017, 02} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_VEND", "TF_REGIAO", "TF_ITEMCC"})
oTempTable:Create()

Return
