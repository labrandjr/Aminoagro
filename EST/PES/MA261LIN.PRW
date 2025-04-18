#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MA261LIN  � Autor � Luis Brandini    �   Data  � 06/06/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��o de linha na Transfer�ncia Modelo 2.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA261LIN()

Local aArea      := GetArea()
Local lRetOk     := .T.
Local nLinha     := PARAMIXB[1]
Local cEOL       := CHR(13)+CHR(10)
Local nPosCODOri := 1	//Codigo do Produto Origem
Local nPosLOCOri := 4	//Armazem Origem
Local nPosLcZOri := 5	//Localizacao Origem
Local nPosCODDes := 6	//Codigo do Produto Destino
Local nPosLOCDes := 9	//Armazem Destino
Local nPosLcZDes := 10	//Localizacao Destino
Local nPosServic := 0
Local lInteWms   := GetMv("MV_INTWMS")

If !lInteWms // Integra��o Wms
	Return(lRetOk)
Endif

nPosServic := aScan(aheader,{|x| Alltrim(x[2])=="D3_SERVIC"})
cCodOrig   := aCols[nLinha,nPosCODOri]
cLocOrig   := aCols[nLinha,nPosLOCOri]
cLoclzOrig := aCols[nLinha,nPosLcZOri]
cCodDest   := aCols[nLinha,nPosCODDes]
cLocDest   := aCols[nLinha,nPosLOCDes]
cLoclzDest := aCols[nLinha,nPosLcZDes]
cServico   := aCols[nLinha,nPosServic]

If AllTrim(cCodOrig) == AllTrim(cCodDest) .And. AllTrim(cLocOrig) == AllTrim(cLocDest) .And. !Empty(cLoclzOrig) .And. Empty(cLoclzDest)
	If cLocDest $("04,09") .And. Empty(cServico)
		If !MsgYesNo("C�digo do servi�o Wms n�o informado."+cEOL+"Deseja prosseguir ?")
			lRetOk := .F.
		Endif	
	Endif
Endif

RestArea(aArea)

Return(lRetOk)
