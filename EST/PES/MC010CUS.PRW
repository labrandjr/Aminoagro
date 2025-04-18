#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MC010CUS  � Autor �  F�brica ERP.BR   �   Data  � 01/11/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Altera��o do custo na forma��o de pre�os.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MC010CUS()

Local aArea   := GetArea()
Local zCodPro := PARAMIXB[1]
Local zCusStd := PARAMIXB[2]

If FunName() == "SML020C" .Or. FunName() == "SML030C" .Or. FunName() == "AMNR010"
	If SB1->B1_TIPO $"MP,MO"
		DbSelectArea("ZZB")
		DbSetOrder(1)
		If DbSeek( cFilAnt + zCodPro )
			zCusStd := ZZB->ZZB_CUSTO // Simulador de Custo
		ElseIf FunName() == "AMNR010"
			zCusStd := ZZB->ZZB_CUST2 // Custo Anal�tico x Simulador
		Else
			zCusStd := 0
		Endif
	Endif
Endif

RestArea(aArea)

Return(zCusStd)
