#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT116TOK  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 06/06/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação na inclusão de nota fiscal conhecimento de frete.¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT116TOK()

Local aArea    := GetArea()
Local lRetorno := .T.
Local aTiposPr := {}
Local lDuplica := .F.
Local _z
Local _x

If FunName() == "RPC" .Or. FunName() == "SCHEDCOMCOL"
	Return(.T.)
Endif

For _z := 1 to Len(aCols)
	If !(aCols[_z][Len(aHeader)+1])
		xProdut := GdFieldGet("D1_COD",_z)
		xTipoPr := RetField("SB1",1,xFilial("SB1")+xProdut,"B1_TIPO")
		xTipEnt := GdFieldGet("D1_TES",_z)
		xDuplic := RetField("SF4",1,xFilial("SF4")+xTipEnt,"F4_DUPLIC")
		// Valida natureza financeira conforme tipo de produto
		If !lDuplica
			lDuplica := (xDuplic == "S")
		Endif
		If Len(aTiposPr) == 0
			AAdd(aTiposPr,xTipoPr)
		Else
			nPos := aScan(aTiposPr, {|x| x == xTipoPr })
			If nPos == 0
				AAdd(aTiposPr,xTipoPr)
			Endif
		Endif
	Endif		
Next _z

If lDuplica
	For _x := 1 to Len(aTiposPr)
		zTipo := aTiposPr[_x]
		DbSelectArea("SZF")
		DbSetOrder(1)
		If DbSeek( xFilial("SZF") + zTipo )
			If !DbSeek( xFilial("SZF") + zTipo + SED->ED_CODIGO )
				MsgInfo("Atenção, a natureza informada não pode ser utilizada na entrada de produtos com Tipo = '"+zTipo+"'.")
				lRetorno := .F.
				Exit
			Endif
		Endif
	Next _x
Endif

If lRetorno
	If AllTrim(CESPECIE) == "CTE" .And. CTIPO == "C"
		If Empty(aInfAdic[10]) .Or. Empty(aInfAdic[11]) .Or. Empty(aInfAdic[12]) .Or. Empty(aInfAdic[13])
			MsgInfo("UF/Mun. Origem/Destino não informados. Verifique em 'Informações Adicionais'.")
			lRetorno := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return(lRetorno)
