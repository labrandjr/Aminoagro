#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMRDIRF  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 07/06/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lista dados de pagamento de DIRF.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMRDIRF()

Local cPerg := "AMRDIRF"
Private cPath := "c:\report\"

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pAmrDirf()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmrDirf  ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 07/06/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmrDirf()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local cKeyAnt := ""
Local lKeyAnt := .F.
Local cQuery, nx
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
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E2_DIRF = '1' "
cQuery += " AND E2_CODRET <> ' ' "
cQuery += " AND E2_TITPAI <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA, "
cQuery += " E2_NOMFOR NOMFOR, E2_DIRF DIRF, E2_CODRET CODRET, E2_VALOR VALOR, E2_TITPAI TITPAI, E2_VENCTO VENCTO, E2_ORIGEM ORIGEM "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E2_DIRF = '1' "
cQuery += " AND E2_CODRET <> ' ' "
cQuery += " AND E2_TITPAI <> ' ' "
cQuery += " AND E2_ORIGEM <> 'FINA050' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " UNION "
cQuery += " SELECT E2_FILIAL FILIAL, E2_PREFIXO PREFIXO, E2_NUM NUMERO, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA, "
cQuery += " E2_NOMFOR NOMFOR, E2_DIRF DIRF, E2_CODRET CODRET, E2_VALOR VALOR, E2_TITPAI TITPAI, E2_VENCTO VENCTO, E2_ORIGEM ORIGEM "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_FILIAL IN("+zFiliais+") "
cQuery += " AND E2_VENCREA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E2_DIRF = '1' "
cQuery += " AND E2_CODRET <> ' ' "
cQuery += " AND E2_ORIGEM = 'FINA050' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, TITPAI, CODRET "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "SE2_DIRF"
	cNomeTable := "Impostos retidos (DIRF) - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cnpj",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cód.Retenção",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Retido",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Imposto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencimento",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Serviço",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número Título",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		If cKeyAnt != SQL->(FILIAL+TITPAI+CODRET)
			If lKeyAnt
				_Impress(@oExcel,@cNomePlan,@cNomeTable,zFilial,zCgcFor,zNomFor,zValSrv,zCodRet,zValRet,zImpRet,zVenRet,zValSrv,zPrefix,zNumero)
			Else
				lKeyAnt := .T.
			Endif
			//
			cKeyAnt := SQL->(FILIAL+TITPAI+CODRET)
			//
			zFilial := ""
			zCgcFor := ""
			zNomFor := ""
			zValSrv := 0
			zPrefix := ""
			zNumero := ""
			//
			zCodRet := ""
			zValRet := 0
			zImpRet := ""
			zVenRet := StoD("")
			//
			ztFound := .F.
			zTitPai := Substr(SQL->TITPAI,1,25)
			//
			If AllTrim(SQL->ORIGEM) == "FINA050"
				DbSelectArea("SE2")
				DbSetOrder(1)
				If DbSeek( SQL->FILIAL + zTitPai )
					ztFound := .T.
					zFilial := SE2->E2_FILIAL
					zCgcFor := RetField("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_CGC")
					zNomFor := RetField("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NOME")
					zValSrv := SE2->E2_VALOR
					zPrefix := SE2->E2_PREFIXO
					zNumero := SE2->E2_NUM
				Else			
					ztFound := .T.
					zFilial := SQL->FILIAL
					zCgcFor := ""
					zNomFor := SQL->NOMFOR
					zValSrv := SQL->VALOR
					zPrefix := SQL->PREFIXO
					zNumero := SQL->NUMERO
				Endif	
			Else
				DbSelectArea("SE2")
				DbSetOrder(1)
				If DbSeek( SQL->FILIAL + zTitPai )
					ztFound := .T.
					zFilial := SE2->E2_FILIAL
					zCgcFor := RetField("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_CGC")
					zNomFor := RetField("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NOME")
					zValSrv := SE2->E2_VALOR
					zPrefix := SE2->E2_PREFIXO
					zNumero := SE2->E2_NUM
				Endif	
			Endif	
			//
		Endif	

		If ztFound
			zCodRet := SQL->CODRET
			zValRet += SQL->VALOR
			If AllTrim(SQL->ORIGEM) == "FINA050"
				zImpRet := IIf(AllTrim(SQL->PARCELA)=="01","IRRF","PIS/COFINS/CSLL")
			Else	
				zImpRet += IIf(!Empty(zImpRet),"/","") + IIf(SE2->E2_PARCIR==SQL->PARCELA,"IRRF",IIf(SE2->E2_PARCPIS==SQL->PARCELA,"PIS",IIf(SE2->E2_PARCCOF==SQL->PARCELA,"COFINS",IIf(SE2->E2_PARCSLL==SQL->PARCELA,"CSLL","XXXX"))))
			Endif	
			zVenRet := StoD(SQL->VENCTO)
		Endif

		DbSelectArea("SQL")
		SQL->(DbSkip())

		If Eof()
			_Impress(@oExcel,@cNomePlan,@cNomeTable,zFilial,zCgcFor,zNomFor,zValSrv,zCodRet,zValRet,zImpRet,zVenRet,zValSrv,zPrefix,zNumero)
		Endif

		DbSelectArea("SQL")
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE2_DIRF-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
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

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Impress ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  07/06/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão da linha.									      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Impress(oExcel,cNomePlan,cNomeTable,zFilial,zCgcFor,zNomFor,zValSrv,zCodRet,zValRet,zImpRet,zVenRet,zValSrv,zPrefix,zNumero)
zLocal := FWFilialName(cEmpAnt,zFilial,1)
oExcel:AddRow(cNomePlan, cNomeTable, {zLocal, zFilial, zCgcFor, zNomFor, zCodRet, zValRet, zImpRet, zVenRet, zValSrv, zPrefix, zNumero})
Return
