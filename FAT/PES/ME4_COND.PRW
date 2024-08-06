#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ME4_COND ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 12/04/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Altera condição de pagamento na emissão da nota fiscal.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ME4_COND()

Local aArea := GetArea()
Local aCond := {}
Local lMuda := .F.

DbSelectArea("SZG")
DbSetOrder(1)
If DbSeek( xFilial("SZG") + SC5->C5_NUM + Space(9) )
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + SZG->ZG_CONDPAG )
	lRetOk := u_ChkCondPv(.F.)
	If lRetOk
		lMuda := .T.
	Else
		RecLock("SZG",.F.)
		DbDelete()
		MsUnLock()
	Endif	
Endif

If lMuda

	aCond := {}
	zCond := SZG->ZG_CONDPAG

	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + zCond )

	If SE4->E4_TIPO == "9"

		RecLock("SZG",.F.)
		SZG->ZG_C5PARC1 := SC5->C5_PARC1
		SZG->ZG_C5DATA1 := SC5->C5_DATA1
		SZG->ZG_C5PARC2 := SC5->C5_PARC2
		SZG->ZG_C5DATA2 := SC5->C5_DATA2
		SZG->ZG_C5PARC3 := SC5->C5_PARC3
		SZG->ZG_C5DATA3 := SC5->C5_DATA3
		SZG->ZG_C5PARC4 := SC5->C5_PARC4
		SZG->ZG_C5DATA4 := SC5->C5_DATA4
		MsUnLock()

		RecLock("SC5",.F.)
		SC5->C5_PARC1 := SZG->ZG_PARC1
		SC5->C5_DATA1 := SZG->ZG_DATA1
		SC5->C5_PARC2 := SZG->ZG_PARC2
		SC5->C5_DATA2 := SZG->ZG_DATA2
		SC5->C5_PARC3 := SZG->ZG_PARC3
		SC5->C5_DATA3 := SZG->ZG_DATA3
		SC5->C5_PARC4 := SZG->ZG_PARC4
		SC5->C5_DATA4 := SZG->ZG_DATA4
		MsUnLock()

	Endif

	AAdd(aCond,SE4->E4_CODIGO)
	AAdd(aCond,SE4->E4_COND)
	AAdd(aCond,SE4->E4_TIPO)
	AAdd(aCond,SE4->E4_DDD)
	AAdd(aCond,SE4->E4_IPI)
	AAdd(aCond,SE4->E4_SOLID)

	Return(aCond)
	
Endif

RestArea(aArea)
                                                                             
Return

/*
If ExistBlock("ME4_COND")                                                     
	// deve retornar um array de 6 posicoes com a condicao de pagamento
   //[1]E4_CODIGO, [2]E4_COND, [3]E4_TIPO, [4]E4_DDD, [5]E4_IPI, [6]E4_SOLID
	aVenc := Condicao(nValTot,cCond,0.00,dDataCnd,0.00,,ExecBlock("ME4_COND",.F.,.F.))
EndIf
*/
