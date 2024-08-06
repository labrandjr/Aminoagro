#INCLUDE "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DPCTB102GR ¦ Autor ¦ Fábrica ERP.BR   ¦   Data  ¦ 12/11/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ponto de Entrada depois da gravação do lançamento manual.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DPCTB102GR()

Local aArea	  := GetArea()
Local lRatCsv := GetMv("MV_ZRATCSV")

// Limpa o flag do movimento bancário ref. compensação a pagar na exclusão do lançamento
If CT2->CT2_LP == "597" .And. PARAMIXB[1] == 5
	cKey := AllTrim(CT2->CT2_KEY)
	DbSelectArea("SE5")
	DbSetOrder(2)
	If DbSeek( cKey )
		RecLock("SE5",.F.)
		SE5->E5_LA := ""
		MsUnLock()
	Endif
ElseIf CT2->CT2_LP == "X90" .And. PARAMIXB[1] == 5 .And. lRatCsv
	cKey := AllTrim(CT2->CT2_KEY)
	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek( cKey )
		If SE2->E2_RATEIO == "S" // O rateio não é obrigatório. Inserido em 26/08/2021
			RecLock("SE2",.F.)
			SE2->E2_ZRATLA := ""
			MsUnLock()
		Endif	
	Endif
Endif

RestArea(aArea)

Return
