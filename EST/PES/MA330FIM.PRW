#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA330FIM  ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦ 23/04/2021    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamentos complementares após calculo do custo.		  ¦¦¦
¦¦¦          ¦ - Checa diferenças de custos em transferência de filiais.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA330FIM()

Local aArea  := GetArea()
Local dDtIni := Substr(DtoS(mv_par01),1,6)+"01"
Local dDtFim := Substr(DtoS(mv_par01),1,6)+"31"
Local cEOL   := CHR(13)+CHR(10)

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("NNT")+" NNT,"
cQuery += RetSqlName("SD2")+" SD2,"
cQuery += RetSqlName("SD1")+" SD1,"
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE NNT_FILIAL = D2_FILIAL "
cQuery += " AND NNT_DOC = D2_DOC "
cQuery += " AND NNT_SERIE = D2_SERIE "
cQuery += " AND NNT_QUANT = D2_QUANT "
cQuery += " AND NNT_PROD = D2_COD "
cQuery += " AND NNT_LOTECT = D2_LOTECTL "
cQuery += " AND NNT_FILDES = D1_FILIAL "
cQuery += " AND NNT_DOC = D1_DOC "
cQuery += " AND NNT_SERIE = D1_SERIE "
cQuery += " AND NNT_QUANT = D1_QUANT "
cQuery += " AND NNT_PRODD = D1_COD "
cQuery += " AND NNT_LOTED = D1_LOTECTL "
cQuery += " AND NNT_DOC <> ' ' "
cQuery += " AND D2_DOC = D1_DOC "
cQuery += " AND D2_SERIE = D1_SERIE "
cQuery += " AND D2_COD = D1_COD "
cQuery += " AND D2_QUANT = D1_QUANT "
cQuery += " AND D2_LOTECTL = D1_LOTECTL "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND D1_DTDIGIT BETWEEN '"+dDtIni+"' AND '"+dDtFim+"' "
cQuery += " AND D2_EMISSAO BETWEEN '"+dDtIni+"' AND '"+dDtFim+"' "
cQuery += " AND D2_CUSTO1 <> D1_CUSTO "
cQuery += " AND D1_FILIAL <> '0109' "
cQuery += " AND NNT.D_E_L_E_T_ <> '*' "
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB3", .F., .T.)
lDif := ( TRB3->SOMA > 0 )
TRB3->(DbCloseArea())

If lDif
	MsgAlert("Diferenças de custo nas Transferências entre Filiais."+cEOL+"Recalcular o custo médio.")
Else
	MsgInfo("Não foram encontradas diferenças de custo nas Transferências entre Filiais.")
Endif

RestArea(aArea)

Return
