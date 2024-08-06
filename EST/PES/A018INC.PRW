#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A018INC   ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 18/07/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após cadastro de indicadores.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A018INC()

Local aArea    := GetArea()
Local lLocaliz := ( GetMv("MV_LOCALIZ") == "S" ) 

RecLock("SBZ",.F.)
SBZ->BZ_ZZDESC := SB1->B1_DESC
MsUnLock()

If lLocaliz
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + SBZ->BZ_COD )
	If SB1->B1_TIPO $ ("PA,MP") .And. SBZ->BZ_LOCALIZ != "S"
		RecLock("SBZ",.F.)
		SBZ->BZ_LOCALIZ := "S"
		MsUnLock()
	Endif	
Endif

RestArea(aArea)

Return
