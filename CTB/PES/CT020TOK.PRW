#INCLUDE "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CT020TOK  � Autor �  F�brica ERP.BR   �   Data  � 10/07/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Ponto de Entrada Validacao Plano de Contas			 	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CT020TOK()

Local aArea		:= GetArea()
Local lRetorno	:= .T.
Local nA		:= 0
Local xB:= Len(acols)

While .T.
	For nA := 1 to xB
		If Empty(Alltrim(acols[nA][2]))
			Alert("Conta Referencial em branco! O preenchimento � obrigat�rio!")
			lRetorno	:= .F.
			Exit
		Endif
	Next nA
	Exit
Enddo

RestArea(aArea)

Return(lRetorno)
