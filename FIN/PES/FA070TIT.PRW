#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FA070TIT ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 08/12/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia dados da baixa do título - desconto pontualidade.   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FA070TIT()

Local aArea  := GetArea()
Local cEOL   := CHR(13)+CHR(10)
Local lRetOk := .T.

If lRetOk .And. SE1->E1_DESCFIN > 0 .And. FunName() $("FINA070,FINA740")
	zPedido := RetField("SD2",3,xFilial("SE1")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA),"D2_PEDIDO")
	zDesPon := RetField("SC5",1,xFilial("SE1")+zPedido,"C5_ZZPPONT")
	lDesPon := !Empty(zDesPon)
	dDataBx := IIf(FunName()=="FINA070",DBAIXA,dDatabase)
	lDataOk := (dDataBx <= SE1->E1_VENCREA)
	If lDesPon .And. lDataOk
		zDesPon := Round((SE1->E1_VALOR * (SE1->E1_DESCFIN/100)),2)
		zValRec := SE1->E1_VALOR - nParciais
		zValRec += nJuros - zDesPon + nMulta + nAcresc - nDecresc
		zValRec := zValRec-nPis-nCoFins-nCsll-nIrrf
		If nValRec != zValRec .And. nDescont > 0
			MsgInfo("Para utilizar o DESCONTO PONTUALIDADE é necessário liquidar o SALDO TOTAL EM ABERTO."+cEOL+;
			 		"Corrija o VALOR RECEBIDO ou remova o -DESCONTOS para efetuar a baixa."+cEOL+;
			 		"O processamento será interrompido.")
			lRetOk := .F.
		ElseIf nDescont != zDesPon .And. nDescont > 0
			MsgInfo("O valor do DESCONTO PONTUALIDADE foi alterado."+cEOL+;
			 		"Corrija o valor do -DESCONTOS para efetuar a baixa."+cEOL+;
			 		"O DESCONTO PONTUALIDADE total é "+AllTrim(STR(zDesPon,12,2))+cEOL+;
			 		"O processamento será interrompido.")
			lRetOk := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
