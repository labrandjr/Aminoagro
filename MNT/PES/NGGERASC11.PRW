#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA450MNU ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 13/09/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na rotina de Liberação de Crédito.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function NGGERASC11()

Local aArea := GetArea()
Local lVeic := .T.

DbSelectArea("ST9")
DbSetOrder(1)
If DbSeek( xFilial("ST9") + STJ->TJ_CODBEM )
	If ST9->T9_CATBEM == "1"
		lVeic := .F. // 1=Bem | 2=Veículo
	Endif
Endif

RecLock("SC1",.F.)
SC1->C1_PRODUTO := IIf(lVeic,"DESPADM_0008","DESPADM_0006")
SC1->C1_UM      := Posicione("SB1",1,xFilial("SB1") + SC1->C1_PRODUTO,"B1_UM")
SC1->C1_DESCRI  := "OS"+Substr(SC1->C1_OP,1,6)+" "+AllTrim(STJ->TJ_CODBEM)+" "+AllTrim(Posicione("ST4",1,xFilial("ST4")+STJ->TJ_SERVICO,"T4_NOME"))
SC1->C1_CONTA   := Posicione("SB1",1,xFilial("SB1") + SC1->C1_PRODUTO,"B1_CONTA")
MsUnLock()

RestArea(aArea)
                                                                             
Return
