#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ EMP650   ¦ Autor ¦ Fábrica ERP.BR  ¦   Data ¦ 30/01/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Tratamento específico no empenho de PI.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function EMP650()

Local aArea := GetArea()
Local lLtPI := (AllTrim(GetMv("MV_ZLOTEPI")) == "S")
Local _emp

If lLtPI
	For _emp := 1 to Len(aCols)
		zTipo := RetField("SB1",1,xFilial("SB1")+aCols[_emp][1],"B1_TIPO")
		If zTipo == "PI" // Remove empenho automático do lote para PI
			aCols[_emp][6] := CriaVar("B8_LOTECTL")
			aCols[_emp][7] := CriaVar("B8_DTVALID")
		Endif
	Next _emp
Endif

RestArea(aArea)

Return
