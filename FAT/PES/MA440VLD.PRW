#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA440VLD ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 04/10/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações na confirmação da liberação do pedido.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA440VLD()

Local aArea    := GetArea()
Local aItEmb   := {}
Local lVldEmb  := ( AllTrim(GetMv("MV_XVLDEMB"))=="S" )
Local lRetorno := .T.
Local nI

If lVldEmb
	For nI:= 1 to Len(aCols)
		If !(aCols[nI][Len(aHeader)+1])
			zCodPro := aCols[nI][GdFieldPos("C6_PRODUTO")]
			zTipSai := aCols[nI][GdFieldPos("C6_TES")]
			zQtdLib := aCols[nI][GdFieldPos("C6_QTDLIB")]
			//
			lVend := ( SC5->C5_TIPO == "N" )
			lEstq := ( RetField("SF4",1,xFilial("SF4")+zTipSai,"F4_ESTOQUE") == "S" )
			zTipo := RetField("SB1",1,xFilial("SB1")+zCodPro,"B1_TIPO")
			lAddP := .F.
			If lVend .And. lEstq .And. zQtdLib > 0
				If zTipo == "PA"
					DbSelectArea("SG1")
					DbSetOrder(1)
					If DbSeek( xFilial("SG1") + zCodPro )
	                	lAddP := .T.
					Endif
				ElseIf zTipo == "PR"
					lAddP := .T.
				Endif	
			Endif
			If lAddP
				zPedi := SC5->C5_NUM
				zItem := aCols[nI][GdFieldPos("C6_ITEM")]
				zSequ := ""
				zProd := zCodPro
				zQtde := zQtdLib
				AAdd(aItEmb,{zPedi, zItem, zSequ, zProd, zQtde, "PED"})
			Endif
		Endif	
	Next nI
Endif

If Len(aItEmb) > 0
	lRetorno := u_VldEmblg(aItEmb)
Endif

RestArea(aArea)
                                                                             
Return(lRetorno)
