#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F050LRCT ¦ Autor ¦  Luis Brandini   ¦   Data  ¦ 09/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação na linha do rateio - CC Obrigatório.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F050LRCT()

Local aArea  := GetArea()
Local lRetOk := .T.

If !Empty(TMP->CTJ_DEBITO)
	lCCObrg := ( RetField("CT1",1,xFilial("CT1")+TMP->CTJ_DEBITO,"CT1_CCOBRG") == "1" )
	If lCCObrg
		If Empty(TMP->CTJ_CCD)
			MsgInfo("Atenção..., Centro de Custo DÉBITO não informado (obrigatório para a Conta DÉBITO).")
			lRetOk := .F.
		Endif
	Endif
Endif

If !Empty(TMP->CTJ_CREDIT)
	lCCObrg := ( RetField("CT1",1,xFilial("CT1")+TMP->CTJ_CREDIT,"CT1_CCOBRG") == "1" )
	If lCCObrg
		If Empty(TMP->CTJ_CCC)
			MsgInfo("Atenção..., Centro de Custo CRÉDITO não informado (obrigatório para a Conta CRÉDITO).")
			lRetOk := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
