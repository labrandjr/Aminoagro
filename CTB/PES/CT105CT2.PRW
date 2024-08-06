#INCLUDE "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CT105CT2 ¦ Autor ¦ Fábrica ERP.BR   ¦   Data  ¦ 12/11/19   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ponto de Entrada depois da gravação do lancto. automático. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CT105CT2()

Local aArea	:= GetArea()

// Grava o flag no título a pagar ref. rateio na inclusão do lançamento
If CT2->CT2_LP == "511" .And. CT2->CT2_TPSALD == "1" .And. PARAMIXB[1] == 1
	cKey := AllTrim(CT2->CT2_KEY)
	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek( cKey )
		RecLock("SE2",.F.)
		SE2->E2_LA := "S"
		MsUnLock()
	Endif
Endif

RestArea(aArea)

Return
