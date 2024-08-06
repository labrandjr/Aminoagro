#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SF2460I  ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 12/04/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após geração da nota fiscal.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SF2460I()

Local aArea   := GetArea()
Local aAreaD2 := SD2->(GetArea())

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) )

	DbSelectArea("SZG")
	DbSetOrder(1)
	If DbSeek( xFilial("SZG") + SD2->D2_PEDIDO + Space(9) )

		RecLock("SZG",.F.)
		SZG->ZG_NFISCAL := SD2->D2_DOC
		MsUnLock()

		RecLock("SF2",.F.)
		SF2->F2_COND := SZG->ZG_CONDPAG
		MsUnLock()

		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

		RecLock("SC5",.F.)
		SC5->C5_PARC1 := SZG->ZG_C5PARC1
		SC5->C5_DATA1 := SZG->ZG_C5DATA1
		SC5->C5_PARC2 := SZG->ZG_C5PARC2
		SC5->C5_DATA2 := SZG->ZG_C5DATA2
		SC5->C5_PARC3 := SZG->ZG_C5PARC3
		SC5->C5_DATA3 := SZG->ZG_C5DATA3
		SC5->C5_PARC4 := SZG->ZG_C5PARC4
		SC5->C5_DATA4 := SZG->ZG_C5DATA4
		MsUnLock()
		
		// Avalia se a quantidade liberada de carteira foi 100% faturada.
		// Caso contrário, cadastra novamente a mesma CP exclusiva para a próxima nota fiscal.
		lSaldoLib := u_SaldoLib(SC5->C5_NUM)
		If lSaldoLib
			zgPedido := SZG->ZG_PEDIDO
			zgCondPg := SZG->ZG_CONDPAG
			zgUsuari := SZG->ZG_USUARIO
			zParc1   := SZG->ZG_PARC1
			zData1   := SZG->ZG_DATA1
			zParc2   := SZG->ZG_PARC2
			zData2   := SZG->ZG_DATA2
			zParc3   := SZG->ZG_PARC3
			zData3   := SZG->ZG_DATA3
			zParc4   := SZG->ZG_PARC4
			zData4   := SZG->ZG_DATA4
			zDatau   := SZG->ZG_DATA
			zHorau   := SZG->ZG_HORA
			//
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL  := xFilial("SZG")
			SZG->ZG_PEDIDO  := zgPedido
			SZG->ZG_CONDPAG := zgCondPg
			SZG->ZG_PARC1   := zParc1
			SZG->ZG_DATA1   := zData1
			SZG->ZG_PARC2   := zParc2
			SZG->ZG_DATA2   := zData2
			SZG->ZG_PARC3   := zParc3
			SZG->ZG_DATA3   := zData3
			SZG->ZG_PARC4   := zParc4
			SZG->ZG_DATA4   := zData4
			SZG->ZG_USUARIO := zgUsuari 
			SZG->ZG_DATA    := zDatau
			SZG->ZG_HORA    := zHorau
			MsUnLock()
		Endif

	Endif

Endif

RestArea(aArea)
RestArea(aAreaD2)
                                                                             
Return
