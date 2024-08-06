#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CMA20BLQ  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 19/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exceções na tolerância do recebimento.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CMA20BLQ()

Local aArea     := GetArea()
Local aAreaC7   := SC7->(GetArea())
Local lBloqueio := PARAMIXB[1]
Local lPcMoeda  := (SC7->C7_MOEDA > 1)
Local lTemDesc  := (SC7->C7_VLDESC > 0)
Local lExcecao  := (AllTrim(SC7->C7_FORNECE) $(AllTrim(GetMv("MV_ZSA2NBL"))))

If lBloqueio
	If u_IntCpny("F",SA2->(A2_COD+A2_LOJA))
		lBloqueio := .F. // Não bloqueia para compras intercompany
	Endif
	If lPcMoeda
		lBloqueio := .F. // Não bloqueia para compras em outras moedas
	Endif
	If lTemDesc
		lBloqueio := .F. // Não bloqueia para compras com desconto
	Endif
	If lExcecao
		lBloqueio := .F. // Não bloqueia para alguns fornecedores definidos
	Endif
Endif

RestArea(aAreaC7)
RestArea(aArea)

Return(lBloqueio)
