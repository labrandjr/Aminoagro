#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FA050INC ¦ Autor ¦  Luis Brandini   ¦   Data  ¦ 11/01/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida centro de custo na inclusão do título a pagar.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FA050INC()

Local lRetorno := .T.
Local l2PaForn := GetMv("MV_Z2PAFOR")
Local lRatCsv  := GetMv("MV_ZRATCSV")

If FunName() == "TMSAB30"
	Return(.T.)
Endif

If lRatCsv
	If !Empty(M->E2_CONTAD)
		lRatOb := Posicione("CT1",1,xFilial("CT1")+M->E2_CONTAD,"CT1_ZRATOB")=="S"
		If lRatOb
			If M->E2_RATEIO != "S"
				If !MsgYesNo("Rateio para a conta contábil "+AllTrim(M->E2_CONTAD)+" não informado. Deseja prosseguir ?")
					lRetorno := .F.
				Endif	
			Endif
		Endif
	Endif
Endif

If lRetorno
	If M->E2_RATEIO != "S"
		If Empty(M->E2_CONTAD)
			MsgAlert("Atenção, conta contábil não informada!")
			ConOut("Atenção, conta contábil não informada!")
			lRetorno := .F.
		ElseIf Empty(M->E2_CCUSTO)
			MsgAlert("Atenção, centro de custo não informado!")
			ConOut("Atenção, centro de custo não informado!")
			lRetorno := .F.
		Endif
	Endif
Endif

If lRetorno .And. Inclui .And. l2PaForn
	If AllTrim(M->E2_TIPO) == "PA"
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SE2")
		cQuery += " WHERE E2_FORNECE = '"+M->E2_FORNECE+"' "
		cQuery += " AND E2_LOJA = '"+M->E2_LOJA+"' "
		cQuery += " AND E2_TIPO = 'PA' "
		cQuery += " AND E2_SALDO > 0 "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQE2", .F., .T.)
		lAdiant := (SQE2->SOMA > 0)
		SQE2->(DbCloseArea())
		If lAdiant
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + M->E2_FORNECE + M->E2_LOJA )
			If SA2->A2_XBLQPA == "S"
				MsgInfo("O Fornecedor deste título já possui Adiantamento.")
				ConOut("O Fornecedor deste título já possui Adiantamento.")
				lRetorno := .F.
			Endif	
		Endif
	Endif		
Endif

Return(lRetorno)
