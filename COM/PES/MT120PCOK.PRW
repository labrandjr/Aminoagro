#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT120PCOK ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 10/08/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações diversas antes da confirmação do pedido.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT120PCOK()

Local aArea    := GetArea()
Local lRetorno := .T.
Local lTipoAI  := .F.
Local nPosProd := aScan(aHeader,{|x|Alltrim(x[2])=="C7_PRODUTO"})
Local nPosDel  := Len(aHeader)+1
Local _y
Local _x

If Inclui .Or. Altera .Or. lCop

	For _y := 1 to Len(aCols)
		If !aCols[_y][nPosDel]
			lTipoAI := ( RetField("SB1",1,xFilial("SB1")+aCols[_y][nPosProd],"B1_TIPO") == "AI" )
			If lTipoAI
				Exit
			Endif
		Endif
	Next _y

	lAtivo := .F.
	If Len(aRatAJ7) > 0
		For _x := 1 to Len(aRatAJ7)
			aPrjIt := aRatAJ7[_x][2]
			For _y := 1 to Len(aPrjIt)
				If !aPrjIt[_y][8] .And. !Empty(aPrjIt[_y][1])
					lAtivo := .T.
					Exit
				Endif 	
			Next _y
		Next _x
	Endif

	If lTipoAI
		If !lAtivo			
			MsgInfo("Atenção..., para compra de Ativo Imobilizado é obrigatório informar o PROJETO.")
			lRetorno := .F.
		Endif	
	Else
		If lAtivo			
			MsgInfo("Atenção..., informar o PROJETO é obrigatório apenas para compra de Ativo Imobilizado. Remova o PROJETO.")
			lRetorno := .F.
		Endif	
	Endif

	If lRetorno
		DbSelectArea("SA2")
		DbSetOrder(1)
		If DbSeek( xFilial("SA2") + CA120FORN + CA120LOJ )
			If SA2->A2_QUALI == "2"
				MsgAlert("Fornecedor desqualificado. Contate o depto. de compras.")
				lRetorno := .F.
			Endif
		Endif
	Endif

Endif

RestArea(aArea)

Return(lRetorno)
