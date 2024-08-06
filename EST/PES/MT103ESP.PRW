#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT103ESP  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 09/06/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualiza informações no cabeçalho da nota fiscal.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT103ESP()

Local aArea  := GetArea()
Local zEspec := PARAMIXB

Local xNfOri   := GdFieldGet("D1_NFORI",n)
Local xSeriOri := GdFieldGet("D1_SERIORI",n)
Local xTes     := GdFieldGet("D1_TES",n)
Local cTesTrc  := AllTrim(GetMv("MV_XTESTRC")) // TES para Troca

If !Empty(xNfOri) .And. Empty(CA100FOR) .And. CTIPO == "B" .And. xTes $(cTesTrc)
	CA100FOR := Posicione("SF2",1,xFilial("SF2")+xNfOri+xSeriOri,"F2_CLIENTE")
	CLOJA    := Posicione("SF2",1,xFilial("SF2")+xNfOri+xSeriOri,"F2_LOJA")
Endif

If CFORMUL == "S"
	zEspec := "SPED"
Else
	zEspec := ""
Endif

RestArea(aArea)

Return(zEspec)
