#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA330D3  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 03/07/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualiza custo do movimento para itens inventariados sem   ¦¦¦
¦¦¦          ¦ movimentação anterior.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA330D3()

Local aArea  := GetArea()
Local lGrava := .F.
Local nXCust := 0

If AllTrim(SD3->D3_DOC) == "INVENT" .And. SD3->D3_CF == "DE0"

	If SD3->D3_CUSTO1 == 0
		nCustd := RetField("SBZ",1,xFilial("SBZ")+SD3->D3_COD,"BZ_CUSTD")
		If nCustd > 0
	    	nXCust := SD3->D3_QUANT * nCustd
	    	lGrava := .T.
		Endif
	Endif
Endif

If lGrava
	//
	nCustD3 := SD3->D3_CUSTO1
	//
	RecLock("SD3",.F.)
	SD3->D3_CUSTO1 := nXCust
	MsUnLock()
	//
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( SD3->(D3_FILIAL+D3_COD+D3_LOCAL) )
	//
	RecLock("SB2",.F.)
	SB2->B2_VFIM1 += (nXCust - nCustD3)
	MsUnLock()
	//
Endif

RestArea(aArea)

Return
