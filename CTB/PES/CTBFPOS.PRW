#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CTBFPOS ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 13/05/2021    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ponto de Entrada depois da contabilização off-line FIN.    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CTBFPOS()

Local aArea	:= GetArea()
Local lExibir := (mv_par01 == 1)
Local dDataDe := mv_par04
Local dDataAt := mv_par05
Local lCtaPag := (mv_par06 == 2 .Or. mv_par06 == 4)
Local zFiliDe := IIf(mv_par08 == 1,mv_par09,cFilAnt)
Local zFiliAt := IIf(mv_par08 == 1,mv_par10,cFilAnt)
Local aCodFil := FWAllFilial("01",,"G1",.F.)
Local aFilCtb := {}
Local cFilBkp := cFilAnt
Local lRatCsv := GetMv("MV_ZRATCSV")
Local _x

// Filiais de processamento
If lCtaPag .And. lRatCsv
	For _x := 1 to Len(aCodFil)
		zFil := aCodFil[_x]
		If zFil >= zFiliDe .And. zFil <= zFiliAt
			AAdd(aFilCtb,zFil)
		Endif
	Next _x
Endif

For _x := 1 to Len(aFilCtb)
	zFilCtb := aFilCtb[_x]
	MsgRun("Aguarde, contabilizando cp rateios "+AllTrim(zFilCtb),"Processando",{|| u_CpRatOb(zFilCtb, lExibir, dDataDe, dDataAt) })
Next _x

cFilAnt := cFilBkp

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CpRatOb ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 13/05/2021    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Contabilização do LP 510 para CP com rateio obrigatório.   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CpRatOb(zFilCtb, lExibir, dDataDe, dDataAt)

Local dDtLanc := CtoD("")
Local lDataOk := .F.
Private cArqCtb

cFilAnt := zFilCtb
cQuery := " SELECT SE2.R_E_C_N_O_ RECSE2 "
cQuery += " FROM "+RetSqlName("SE2")+" SE2, "
cQuery += RetSqlName("CT1")+" CT1 "
cQuery += " WHERE E2_FILIAL = '"+cFilAnt+"' "
cQuery += " AND E2_CONTAD = CT1_CONTA "
cQuery += " AND CT1_ZRATOB = 'S' "
cQuery += " AND E2_EMIS1 BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAt)+"'"
cQuery += " AND E2_ZRATLA = ' ' " 
cQuery += " AND E2_RATEIO = 'S' " // O rateio não é obrigatório. Inserido em 26/08/2021
cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
cQuery += " AND CT1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E2_FILIAL, E2_EMIS1 "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

DbSelectArea("SQL2")
SQL2->(DbGotop())
If !Eof()

	DbSelectArea("SQL2")
	SQL2->(DbGotop())
	While !Eof()

		DbSelectArea("SE2")
		DbSetOrder(1)
		SE2->(DbGoto(SQL2->RECSE2))

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SE2->E2_FORNECE )

		If dDtLanc != SE2->E2_EMIS1
			If lDataOk
				If _nTotLan > 0
					RodaProva(_nHdlPrv,_nTotLan)
					cA100Incl(cArqCtb,_nHdlPrv,3,"008850",lExibir,.F.,,dDtLanc)
				Endif
			Else
				lDataOk := .T.
			Endif
			dDtLanc := SE2->E2_EMIS1
			_nHdlPrv := HeadProva("008850","FINA370",__cUserId,@cArqCtb)
			_nTotLan := 0
		Endif	

		_LinLcto := DetProva(_nHdlPrv,"X90","FINA370","008850")
		If _LinLcto > 0
			RecLock("SE2",.F.)
			SE2->E2_ZRATLA := "S"
			MsUnLock()
		Endif
		_nTotLan += _LinLcto

		DbSelectArea("SQL2")
		SQL2->(DbSkip())
		If Eof()
			If _nTotLan > 0
				RodaProva(_nHdlPrv,_nTotLan)
				cA100Incl(cArqCtb,_nHdlPrv,3,"008850",lExibir,.F.,,dDtLanc)
			Endif
			Exit
		Endif
	Enddo

Endif	
DbSelectArea("SQL2")
SQL2->(DbCloseArea())

Return
