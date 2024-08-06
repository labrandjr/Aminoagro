#include "protheus.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBSXB    �Autor  �Donizete            � Data �  03/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Por uma caracter�stica do sistema, pontos de entrada n�o   ���
���          � s�o disparados quando o usu�rio cadastra um item a partir  ���
���          � de um F3 (Cliente    por exemplo). Neste sentido temos que ���
���          � intervir neste processamento e chamar as duas rotinas, ca- ���
���          � dastro padr�o AXINCLUI e o ponto de entrada. Este programa ���
���          � deve ser colocado no SXB, no campo XB_CONTEM no XB_TIPO=3. ���
���          � Sintaxe da chamada #U_SA1SXB(parametro)                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � No SXB, campo XB_CONTEM do registro XB_TIPO=="3".         ���
�������������������������������������������������������������������������ͼ��
���Data      � Altera��es                                                 ���
���31/08/07  � - Salvo e restaurado �rea de trabalho ativa.               ���
���          �                                                            ���
���16/09/07  � - Unificado programa para tratar tanto o F3 do Cliente     ���
���          �quanto Fornecedor. O tratamento � feito atrav�s de par�metro���
���          �passado na fun��o (1=Cliente  ou 2=Fornecedor).             ���
���          �                                                            ���
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function CTBSXB(_cTipo)

// Declara��o das Vari�veis.
Local _xArea := Getarea()
Local _xAreaX:= {}

If _cTipo=="1" .Or. _cTipo=="SA1" // Chamada para o cadastro de Clientes
	_xAreaX := SA1->(GetArea())
	If AxInclui("SA1",0,3) == 1 // O usu�rio incluiu o registro, neste caso o ponto de entrada deve ser executado.
		U_M030INC()
	EndIf
	RestArea(_xAreaX)
	
ElseIf _cTipo=="2" .Or. _cTipo=="SA2" // Chamada para o cadastro de Fornecedores
	_xAreaX := SA2->(GetArea())
	If AxInclui("SA2",0,3) == 1 // O usu�rio incluiu o registro, neste caso o ponto de entrada deve ser executado.
		U_M020INC()
	EndIf
	RestArea(_xAreaX)
Else
	MsgAlert("ATEN��O, par�metro ref.cria��o de contas n�o informado! Conta cont�bil n�o ser� criada.","CTBSXB")
EndIf

// Restaura �reas de trabalho.
RestArea(_xArea)

Return