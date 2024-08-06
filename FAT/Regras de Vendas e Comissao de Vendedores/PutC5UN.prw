#Include "Protheus.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função PutC5UN

Função que grava a unidade de negócio no campo C5_ZZITCTB, conforme
o vendedor selecionado, e zera os campos de EBITDA da SC5.

@author 	Augusto Krejci Bem-Haja
@since 		18/02/2016
@return		Nil

----
Alteração realizada em 21/03/2017 - Luis Brandini
Un.Negócio vem do CC associado ao Vendedor.
/*/
//-------------------------------------------------------------------

User Function PutC5UN()

Local aArea    := GetArea()
Local cCCVend  := RetField("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_ZZCC")
Local cUndNeg  := RetField("CTT",1,xFilial("CTT")+cCCVend,"CTT_ZZITCT")
Local nPosXCus := aScan(aHeader,{|x|Alltrim(x[2])=="C6_CCUSTO"})
Local nPosItCt := aScan(aHeader,{|x|Alltrim(x[2])=="C6_ZZITCTB"})
Local nI

For nI:= 1 to Len(aCols)
	aCols[nI][nPosXCus] := cCCVend
	aCols[nI][nPosItCt] := cUndNeg
Next nI

U_ZerEBIT()

RestArea(aArea)

Return(cUndNeg)
