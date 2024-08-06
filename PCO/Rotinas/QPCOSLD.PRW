#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QPCOSLD   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 03/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calculo de saldos do Módulo SIGAPCO.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QPCOSLD(cVisao,cContaG,cPeriodo,cModo)

Local nTotal  := 0
Local nPosTr  := AT("-",cContaG)
Local cAnoAtu := Substr(cPeriodo,4,4)
Local cAnoAnt := AllTrim(STR((Val(cAnoAtu)-1)))
Local cDtIniM := cAnoAnt+Substr(cPeriodo,1,2)+"01"
Local cDtFimM := cAnoAnt+Substr(cPeriodo,1,2)+"31"
Local cDtIniA := cAnoAnt+"0101"

cVisao  := PadR(cVisao,3)
cContaG := PadR(Substr(cContaG,nPosTr+1),20)
lSintet := .F.

DbSelectArea("AKO")
DbSetOrder(1)
If DbSeek( xFilial("AKO") + cVisao + cContaG )
	If Empty(AKO->AKO_CLASSE) .Or. AKO->AKO_CLASSE == "2"
		lSintet := .T.
	Endif	
Else
	Return(0)
Endif

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("AKO")
cQuery += " WHERE AKO_FILIAL = '"+xFilial("AKO")+"' "
cQuery += " AND AKO_CODIGO = '"+cVisao+"' "
If !lSintet
	cQuery += " AND AKO_CO = '"+cContaG+"' "
Endif	
cQuery += " AND AKO_CLASSE = '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY AKO_FILIAL, AKO_CODIGO, AKO_CO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLO", .F., .T.)

DbSelectArea("SQLO")
SQLO->(DbGotop())
While !Eof()

	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName("AKP")
	cQuery += " WHERE AKP_FILIAL = '"+xFilial("AKP")+"' "
	cQuery += " AND AKP_CODIGO = '"+SQLO->AKO_CODIGO+"' "
	cQuery += " AND AKP_CO = '"+SQLO->AKO_CO+"' "
	cQuery += " AND AKP_ITECFG = '01' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY AKP_FILIAL, AKP_CODIGO, AKP_ITEM "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLP", .F., .T.)
	
	DbSelectArea("SQLP")
	SQLP->(DbGotop())
	While !Eof()
	
		cQuery := " SELECT AK5_CODIGO AK5_CODIGO "
		cQuery += " FROM "+RetSqlName("AK5")
		cQuery += " WHERE AK5_FILIAL = '"+xFilial("AK5")+"' "
		cQuery += " AND AK5_CODIGO BETWEEN '"+SQLP->AKP_VALINI+"' AND '"+SQLP->AKP_VALFIM+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY AK5_CODIGO "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	
		DbSelectArea("SQL5")
		SQL5->(DbGotop())
		While !Eof()
	
			cChave := PadR(AllTrim(SQL5->AK5_CODIGO),12)+"RE"

			cQuery := " SELECT SUM(AKT_MVCRD1) MVCRD1, SUM(AKT_MVDEB1) MVDEB1 "
			cQuery += " FROM "+RetSqlName("AKT")
			cQuery += " WHERE AKT_CONFIG = '01' "
			cQuery += " AND AKT_CHAVE = '"+cChave+"' "
			If cModo == "M" // Mês
				cQuery += " AND AKT_DATA BETWEEN '"+cDtIniM+"' AND '"+cDtFimM+"' "
			Else // Ano
				cQuery += " AND AKT_DATA BETWEEN '"+cDtIniA+"' AND '"+cDtFimM+"' "
			Endif
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
			nTotal += SQLT->(MVCRD1 - MVDEB1)
			SQLT->(DbCloseArea())

			DbSelectArea("SQL5")
			SQL5->(DbSkip())	
		Enddo
		SQL5->(DbCloseArea())
	
		DbSelectArea("SQLP")
		SQLP->(DbSkip())	
	Enddo
	SQLP->(DbCloseArea())

	DbSelectArea("SQLO")
	SQLO->(DbSkip())	
Enddo
SQLO->(DbCloseArea())

Return(nTotal)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QAKNFIL   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 08/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtro na consulta de Visões Gerenciais por usuário.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QAKNFIL()

Local cRet := "@AKN_FILIAL = ' '"
Local cVis := ""
Local aVis := {}

ChkFile("SZK")

DbSelectArea("SZK")
DbSetOrder(1)
If DbSeek( xFilial("SZK") + __cUserId )
	While !Eof() .And. SZK->ZK_FILIAL == xFilial("SZK") .And. SZK->ZK_USER == __cUserId
		AAdd(aVis,SZK->ZK_VISAO)	
		SZK->(DbSkip())
	Enddo 
Endif

If Len(aVis) > 0
	For _x := 1 to Len(aVis)
		cVis += IIf(!Empty(cVis),",","")+aVis[_x]
	Next _x
	cVis := FormatIn(cVis,",")
	cRet := "@AKN_CODIGO IN "+cVis
Endif

Return(cRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VlUsVis   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 08/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação de usuário na consulta de Visões Gerenciais.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function VldUsVis()

Local lRet := .F.
Local lPac := .F.

ChkFile("SZK")

DbSelectArea("SZK")
DbSetOrder(1)
If DbSeek( xFilial("SZK") + __cUserId )
	lPac := .T.
	While !Eof() .And. SZK->ZK_FILIAL == xFilial("SZK") .And. SZK->ZK_USER == __cUserId
		If mv_par01 == SZK->ZK_VISAO
			lRet := .T.
			Exit
		Endif
		SZK->(DbSkip())
	Enddo 
Else
	lRet := .T.
Endif

If lPac .And. !lRet
	MsgAlert("Usuário sem acesso a Visão Gerencial informada.")
Endif

Return(lRet)
