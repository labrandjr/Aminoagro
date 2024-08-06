#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA020TOK  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 01/10/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida CNPJ ou CPF duplicado na inclusão do fornecedor.    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA020TOK()

Local aArea := GetArea()
Local lRetF := .T.

If M->A2_EST != "EX"
	If !Empty(M->A2_CGC)
		DbSelectArea("SA2")
		DbSetOrder(3)
		If DbSeek( xFilial("SA2") + M->A2_CGC )
			If M->A2_TIPO == "F"
				zIdent := Transform(M->A2_CGC,"@R 999.999.999-99")
			Else
				zIdent := Transform(M->A2_CGC,"@R 99.999.999/9999-99")
			Endif	
			MsgAlert("Já existe outro fornecedor cadastrado com a identificação: "+zIdent)
			lRetF := .F.
		Endif
	Endif	
Endif

RestArea(aArea)

Return(lRetF)
