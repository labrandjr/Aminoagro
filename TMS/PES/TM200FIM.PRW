#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TM200FIM  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/04/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar após geração do CTE.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TM200FIM()

Local aArea   := GetArea()
Local zFilDoc := PARAMIXB[1]
Local zDoc    := PARAMIXB[2]
Local zSerie  := PARAMIXB[3]

DbSelectArea("DTC")
DbSetOrder(3)
If DbSeek( xFilial("DTC") + zFilDoc + zDoc + zSerie )
	DbSelectArea("DA3")
	DbSetOrder(1)
	If DbSeek( xFilial("DA3") + DTC->DTC_ZZVEIC )
		DbSelectArea("SD2")
		DbSetOrder(3)
		If DbSeek( xFilial("SD2") + zDoc + zSerie )
			While !Eof() .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == xFilial("SD2") + zDoc + zSerie
				If Substr(SD2->D2_COD,1,3) == "TMS"
					RecLock("SD2",.F.)
					SD2->D2_CCUSTO := DA3->DA3_ZZCC
					SD2->D2_ITEMCC := RetField("CTT",1,xFilial("CTT")+DA3->DA3_ZZCC,"CTT_ZZITCT")
					MsUnLock()
				Endif
				SD2->(DbSkip())
			Enddo
		Endif	
	Endif
Endif

RestArea(aArea)

Return
