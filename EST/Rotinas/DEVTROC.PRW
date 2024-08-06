#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DEVTROC   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 26/01/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gerar lançamento contábil referente custo.				  ¦¦¦
¦¦¦          ¦ - Entrada de troca. TES contido em MV_XTESTRC.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DEVTROC(cFilAnt,dDtLanc,lExibir)

Local cTesTrc := AllTrim(GetMv("MV_XTESTRC")) // TES para Troca
Private cArqCtb

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL = '"+cFilAnt+"' "
cQuery += " AND SUBSTR(D1_DTDIGIT,1,6) = '"+Substr(DtoS(dDtLanc),1,6)+"' "
cQuery += " AND D1_TES IN"+FormatIn(cTesTrc,",")
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

		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( SQL7->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM) )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SD1->D1_COD )

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA )
			
		_nTotLan += DetProva(_nHdlPrv,"X79","MATA330","008840")

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
