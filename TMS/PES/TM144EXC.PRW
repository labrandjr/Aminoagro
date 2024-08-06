#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TM144EXC ¦ Autor ¦  Fábrica ERP.BR    ¦   Data  ¦ 31/07/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravações específicas para a Viagem.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TM144EXC()

Local aArea := GetArea()
Local lRetX := .T.

DbSelectArea("SDG")
DbSetOrder(5)
If DbSeek( xFilial("SDG") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )
	While !Eof() .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == xFilial("SDG") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM
		RecLock("SDG",.F.)
		DbDelete()
		MsUnLock()
		SDG->(DbSkip())
	Enddo
Endif

RestArea(aArea)

Return(lRetX)
