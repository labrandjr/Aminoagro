#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M030INC  � Autor � J.DONIZETE R.SILVA � Data �  29/01/04    ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada p/ para cria��o automatica da Conta Conta-���
���          � bil do Cliente conforme inclusao do mesmo.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Clientes                                       ���
�������������������������������������������������������������������������ͼ��
���Data      � Altera��es                                                 ���
���23/12/2006� - Adaptado do modelo desenvolvido pelo Vitor L.Fattori     ���
���          �                                                             ��
���12/02/2008� - Alterado por Donizete                                    ���
���          � Incorporado tratamento para compartilhamento de arquivos.   ��
���          �ajustado nome de vari�veis e igualado ao programa de carga   ��
���          �de clientes/fornecedores, corre��o de pequenos erros.        ��
���          �                                                             ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function M030INC()

Local aArea  := GetArea()
Local nParam := PARAMIXB

If Inclui .And. PARAMIXB == 0 // Inclus�o | Confirma Inclus�o
	U_CTBINCFC("C")
Endif

RestArea(aArea)

Return
