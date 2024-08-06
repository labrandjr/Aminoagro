#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LABCTBX   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 28/12/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gerar lançamento contábil - Custo de Análise de Sementes.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LABCTBX(cFilAnt,dDtLanc,lExibir)

Private cArqCtb

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SZ7")
cQuery += " WHERE Z7_FILIAL = '"+cFilAnt+"' "
cQuery += " AND SUBSTR(Z7_EMISSAO,1,6) = '"+Substr(DtoS(dDtLanc),1,6)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)

DbSelectArea("SQL7")
SQL7->(DbGotop())
If !Eof()

	_nHdlPrv := HeadProva("008840","MATA330",__cUserId,@cArqCtb)
	_nTotLan := 0

	DbSelectArea("SQL7")
	SQL7->(DbGotop())
	While !Eof()

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SQL7->Z7_MOD )
		
		DbSelectArea("SB2")
		DbSetOrder(1)
		If DbSeek( cFilAnt + SQL7->Z7_MOD + SB1->B1_LOCPAD )

			CCTADEB := IIf(SQL7->Z7_COBRANC=="S","32201003","41207047") // CUSTO SERVIÇO VENDIDO | BONIFICAÇÃO LAS
			CCTACRD := "41101999" // Alterado em 22/02/2017 conforme E-Mail Jefferson. Conta anterior = "41101026" // ABSORCAO
			CCUSDEB := IIf(SQL7->Z7_COBRANC=="S","106040801001",SQL7->Z7_CC) // SERVIÇO ANÁLISE SEMENTES | RTV ou GRV ou BU, conforme dados do requerente da FR
			CCUSCRD := "101010602001" // LAS
			CITEDEB := Posicione("CTT",1,xFilial("CTT")+CCUSDEB,"CTT_ZZITCT")
			CITECRD := Posicione("CTT",1,xFilial("CTT")+CCUSCRD,"CTT_ZZITCT")
			CHISTOR := "CUSTOS SERVICOS-LAS "+IIf(SQL7->Z7_COBRANC=="S","NF ","FR ")+AllTrim(SQL7->Z7_DOC)
			NVLRLAN := (SQL7->Z7_QUANT * SB2->B2_CM1)
			
			_nTotLan += DetProva(_nHdlPrv,"X78","MATA330","008840")

		Endif

		DbSelectArea("SQL7")
		SQL7->(DbSkip())
	Enddo
	
	If _nTotLan > 0
		RodaProva(_nHdlPrv,_nTotLan)
		cA100Incl(cArqCtb,_nHdlPrv,3,"008840",lExibir/*(__cUserid=="000000")*/,.F.,,dDtLanc)
	Endif
	
Endif	
SQL7->(DbCloseArea())

Return
