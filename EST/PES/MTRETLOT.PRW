#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTRETLOT  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 18/09/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações de embalagem na liberação do Pedido.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTRETLOT()

Local aArea   := GetArea()
Local aRetLot := {}
Local zProdut := PARAMIXB[1]
Local zEmpenh := PARAMIXB[5]
Local zEmpen2 := PARAMIXB[6]
Local lVldEmb := ( AllTrim(GetMv("MV_XVLDEMB"))=="S" )
Local lFunNam := ( FunName() $("MATA410,MATA440,MATA450,MATA455") )

// Garante o retorno
AAdd(aRetLot,zEmpenh)
AAdd(aRetLot,zEmpen2)

If lVldEmb .And. lFunNam
	DbSelectArea("SG1")
	DbSetOrder(1)
	If DbSeek( xFilial("SG1") + zProdut )
		zQtBase := RetField("SBZ",1,xFilial("SBZ")+zProdut,"BZ_QB")
		bQtBase := RetField("SB1",1,xFilial("SB1")+zProdut,"B1_QB")
		nQtBase := IIf(zQtBase > 0,zQtBase,bQtBase) // Prioriza Indicadores de Produtos (SBZ)
		If nQtBase > 1
			zResto := Mod(zEmpenh,nQtBase)
			If zResto > 0
				zEmpenh -= zResto
				zEmpen2 := ConvUm(zProdut, zEmpenh, 0, 2)
				// Retorno recalculado conforme Embalagem
				aRetLot[1] := zEmpenh
				aRetLot[2] := zEmpen2
				//
			Endif
		Endif	
	Endif
Endif

RestArea(aArea)

Return(aRetLot)

/*
aQtdRdmake:=ExecBlock("MTRETLOT",.F.,.F.,{cCodPro,cLocal,nQtd,nQtd2UM,nEmpenho,nEmpenho2,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_NUMSERI})			
If Valtype(aQtdRdmake) == "A"
	If (Valtype(aQtdRdmake[1]) == "N") .And. (aQtdRdmake[1] <= nEmpenho) .And. (aQtdRdmake[1] >= 0) 					
		nEmpenho:=aQtdRdmake[1]
	EndIf
	If (Valtype(aQtdRdmake[2]) == "N") .And. (aQtdRdmake[2] <= nEmpenho2) .And. (aQtdRdmake[2] >= 0) 					
		nEmpenho2:=aQtdRdmake[2]
	EndIf
EndIf
*/
