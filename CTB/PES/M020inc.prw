#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M020INC  � Autor � J.DONIZETE R.SILVA � Data �  29/01/04    ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada p/ para cria��o automatica da Conta Conta-���
���          � bil do Fornecedor conforme inclusao do mesmo.              ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Fornecedores                                   ���
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

User Function M020INC()

Local aArea := GetArea()

If Inclui .And. FunName() != "BROWXML"
	If M->A2_COD == SA2->A2_COD
		U_CTBINCFC("F")
	Endif	
Endif

RestArea(aArea)

Return
