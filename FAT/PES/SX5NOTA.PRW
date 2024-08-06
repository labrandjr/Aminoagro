#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SX5NOTA  ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 12/06/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtra série para emissão da nota fiscal.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SX5NOTA()

Local aArea := GetArea()
Local lRet  := .F.

If cFilAnt == "0101" .Or. cFilAnt == "0102" .Or. cFilAnt == "0106" .Or. cFilAnt == "0107" .Or. cFilAnt == "0109" .Or. cFilAnt == "0110"
	If FunName() != "SPEDMDFE"
		If cFilAnt == "0106" .Or. cFilAnt == "0110"
			If Alltrim(SX5->X5_CHAVE) == "4" .Or. Alltrim(SX5->X5_CHAVE) == "5" .Or. Alltrim(SX5->X5_CHAVE) == "9"
				lRet := .T.
			Endif
		Else
			If Alltrim(SX5->X5_CHAVE) == "4" .Or. Alltrim(SX5->X5_CHAVE) == "9"
				lRet := .T.
			Endif
		Endif	
	Else // Mdf-e
		If Alltrim(SX5->X5_CHAVE) == "004" .Or. Alltrim(SX5->X5_CHAVE) == "089"
			lRet := .T.
		Endif
	Endif	
ElseIf cFilAnt == "0103"
	If FunName() != "SPEDMDFE"
		If Alltrim(SX5->X5_CHAVE) == "001" .Or. Alltrim(SX5->X5_CHAVE) == "2" .Or. Alltrim(SX5->X5_CHAVE) == "9"
			lRet := .T.
		Endif
	Else // Mdf-e
		If Alltrim(SX5->X5_CHAVE) == "004" .Or. Alltrim(SX5->X5_CHAVE) == "089"
			lRet := .T.
		Endif
	Endif	
ElseIf cFilAnt == "0104"
	If Alltrim(SX5->X5_CHAVE) == "001" .Or. Alltrim(SX5->X5_CHAVE) == "9"
		lRet := .T.
	Endif
ElseIf cFilAnt == "0108"
	If FunName() != "SPEDMDFE"
		If Alltrim(SX5->X5_CHAVE) == "1" .Or. Alltrim(SX5->X5_CHAVE) == "9"
			lRet := .T.
		Endif
	Else // Mdf-e
		If Alltrim(SX5->X5_CHAVE) == "004" .Or. Alltrim(SX5->X5_CHAVE) == "089"
			lRet := .T.
		Endif
	Endif	
Endif

RestArea(aArea)
                                                                             
Return(lRet)
