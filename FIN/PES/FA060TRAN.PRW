#include 'rwmake.ch'

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � FA60TRAN � Autor � Luis Brandini   �    Data  � 26/06/2018 ���
��+----------+------------------------------------------------------------���
���Descricao � Filtra dados para gera��o do border�.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function FA60TRAN()

If SE1->E1_SITUACA == "0"
	RecLock("SE1",.F.)
	SE1->E1_VENCREA := zVencRea // Desenvolvido para corrigir erro da Totvs que sobrep�e o vencimento real = vencimento original ap�s a transfer�ncia para carteira
	MsUnLock()
Endif
                                                                             
Return
