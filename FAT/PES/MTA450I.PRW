#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA450I  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦  26/09/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após liberação manual de crédito.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA450I()

Local aArea := GetArea()

If PARAMIXB[1] == 1 // Libera item
	DbSelectArea("ZZA")
	DbSetOrder(1)
	If DbSeek( xFilial("ZZA") + SC9->C9_PEDIDO + SC9->C9_ITEM )
		RecLock("ZZA",.F.)
		ZZA->ZZA_EMLSTT := "2" // Aguardando envio do email
		ZZA->ZZA_TXTLIB := "Liberado por "+AllTrim(cUserName)+" em "+DtoC(Date())+" - Manual/Lib.Item-"+SC9->C9_ITEM  // Motivo da liberação
		ZZA->ZZA_TIPLIB := "I" // I=Item
		MsUnLock()
	Endif
Else // Libera todos
	DbSelectArea("ZZA")
	DbSetOrder(1)
	If DbSeek( xFilial("ZZA") + SC9->C9_PEDIDO )
		While !Eof() .And. ZZA->(ZZA_FILIAL+ZZA_PEDIDO) == xFilial("ZZA") + SC9->C9_PEDIDO
			If ZZA->ZZA_TIPLIB != "I"
				RecLock("ZZA",.F.)
				ZZA->ZZA_EMLSTT := "2" // Aguardando envio do email
				ZZA->ZZA_TXTLIB := "Liberado por "+AllTrim(cUserName)+" em "+DtoC(Date())+" - Manual/Lib.Todos"  // Motivo da liberação
				ZZA->ZZA_TIPLIB := "T" // T=Todos
				MsUnLock()
			Endif
			ZZA->(DbSkip())
		Enddo
	Endif	
Endif

RestArea(aArea)

Return
