#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � F300VAR  � Autor � F�brica ERP.BR   �  Data  � 12/03/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Tratamento de vari�veis no retorno a pagar.		  		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function F300VAR()

Local aArea  := GetArea()
Local aParam := PARAMIXB[1]

Return

/*
ParamIxb - Array contendo na sua primeira posi��o a seguinte estrutura:
01 - Filial atual
02 - Banco
03 - Ag�ncia
04 - Conta
05 - Data da Baixa
06 - N�mero do Titulo
07 - Valor Recebido
08 - Juros
09 - Multa
10 - Tipo de Imposto
11 - Segmento
12 - Descri��o1
13 - Descri��o2
14 - Descri��o3
15 - Descri��o4
16 - Linha inteira
*/
