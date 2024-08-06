#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F070DES  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 08/12/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula o desconto pontualidade na baixa do título.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F070DES()

Local aArea := GetArea()
Local zDesc := PARAMIXB

If SE1->E1_DESCFIN > 0
	zPedido := RetField("SD2",3,xFilial("SE1")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA),"D2_PEDIDO")
	zDesPon := RetField("SC5",1,xFilial("SE1")+zPedido,"C5_ZZPPONT")
	lDesPon := !Empty(zDesPon)
	dDataBx := IIf(FunName()=="FINA070",DBAIXA,dDatabase)
	lDataOk := (dDataBx <= SE1->E1_VENCREA)
	If lDesPon .And. lDataOk
		zDesPon := Round((SE1->E1_VALOR * (SE1->E1_DESCFIN/100)),2)
		If FunName() $("FINA070")
			nValRec := IIf(nValRec == 0, SE1->E1_SALDO - zDesPon, nValRec)
			zValRec := SE1->E1_VALOR - nParciais
			zValRec += nJuros - zDesPon + nMulta + nAcresc - nDecresc
			zValRec := zValRec-nPis-nCoFins-nCsll-nIrrf
		Else
			nValRec := SE1->E1_SALDO - zDesc
			zValRec := SE1->E1_SALDO - zDesPon
		Endif
		If nValRec != zValRec .And. nValRec > 0 .And. !(FunName() $("FINC040,FINR130"))
			zDesc := 0
		Else
			zDesc := Round((SE1->E1_VALOR * (SE1->E1_DESCFIN/100)),2)
		Endif	
	Endif
Endif

If SE1->E1_DESCFIN > 0 .And. FunName() == "FINA740"
	MsgAlert("Título com desconto pontualidade utilize a opção 'Baixas a Receber'.")
Endif

RestArea(aArea)

Return(zDesc)
