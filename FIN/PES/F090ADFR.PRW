#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � F090ADFR � Autor � F�brica ERP.BR   �    Data  � 14/12/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Habilita checagem de adiantamentos/devolu��es multi-filial.���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function F090ADFR()

Local aArea := GetArea()
Local aRet  := {}

AAdd(aRet,PARAMIXB[1])
AAdd(aRet,.T.)

RestArea(aArea)

Return(aRet)

/*
//���������������������������������������������������������Ŀ
//� Ponto de Entrada para manipula��o o filtro que         �
//� seleciona os registros de abatimentos do fornecedor.   �
//����������������������������������������������������������
If lF090ADFR
	aIndReg := ExecBlock("F090ADFR", .F., .F., {cCondicao1,lMultFil})
	cCondicao1 := aIndReg[1]
    lMultFil := aIndReg[2]
    If lMultFil
    	cKey1	   	:= "E2_FORNECE+E2_LOJA"
    Else
   		cKey1	   	:= "E2_FILIAL+E2_FORNECE+E2_LOJA"
   	EndIf
EndIf
*/
