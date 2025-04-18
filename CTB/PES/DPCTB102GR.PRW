#INCLUDE "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � DPCTB102GR � Autor � F�brica ERP.BR   �   Data  � 12/11/19 ���
��+----------+------------------------------------------------------------���
���Descricao � Ponto de Entrada depois da grava��o do lan�amento manual.  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function DPCTB102GR()

Local aArea	  := GetArea()
Local lRatCsv := GetMv("MV_ZRATCSV")

// Limpa o flag do movimento banc�rio ref. compensa��o a pagar na exclus�o do lan�amento
If CT2->CT2_LP == "597" .And. PARAMIXB[1] == 5
	cKey := AllTrim(CT2->CT2_KEY)
	DbSelectArea("SE5")
	DbSetOrder(2)
	If DbSeek( cKey )
		RecLock("SE5",.F.)
		SE5->E5_LA := ""
		MsUnLock()
	Endif
ElseIf CT2->CT2_LP == "X90" .And. PARAMIXB[1] == 5 .And. lRatCsv
	cKey := AllTrim(CT2->CT2_KEY)
	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek( cKey )
		If SE2->E2_RATEIO == "S" // O rateio n�o � obrigat�rio. Inserido em 26/08/2021
			RecLock("SE2",.F.)
			SE2->E2_ZRATLA := ""
			MsUnLock()
		Endif	
	Endif
Endif

RestArea(aArea)

Return
