#INCLUDE "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CT105CT2 � Autor � F�brica ERP.BR   �   Data  � 12/11/19   ���
��+----------+------------------------------------------------------------���
���Descricao � Ponto de Entrada depois da grava��o do lancto. autom�tico. ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CT105CT2()

Local aArea	:= GetArea()

// Grava o flag no t�tulo a pagar ref. rateio na inclus�o do lan�amento
If CT2->CT2_LP == "511" .And. CT2->CT2_TPSALD == "1" .And. PARAMIXB[1] == 1
	cKey := AllTrim(CT2->CT2_KEY)
	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek( cKey )
		RecLock("SE2",.F.)
		SE2->E2_LA := "S"
		MsUnLock()
	Endif
Endif

RestArea(aArea)

Return
