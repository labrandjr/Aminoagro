#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � LBESTA01 � Autor �  F�brica ERP.BR   �    Data  � 11/10/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Libera��o de Estoque - Autom�tica.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function LBESTA01()

Local nOpca    := 0
Local aSays    := {}
Local aButtons := {}
Local cPerg    := "LIBAT2"

ConOut("Fun��o LBESTAUT: Libera��o Autom�tica do Estoque < In�cio > "+DtoC(Date())+" - "+Time())
ConOut(cEmpAnt)
ConOut(cFilAnt)

//��������������������������������������������������������������Ŀ
//� Utiliza arquivo de liberados para geracao na nota            �
//����������������������������������������������������������������
DbSelectArea("SC9")
DbSetOrder(1)
//���������������������������������������������������������������Ŀ
//� mv_par01 Pedido de          ?                                 �
//� mv_par02 Pedido ate         ?                                 �
//� mv_par03 Cliente de         ?                                 �
//� mv_par04 Cliente ate        ?                                 �
//� mv_par05 Dta Liberacao de   ?                                 �
//� mv_par06 Dta Liberacao ate  ?                                 �
//� mv_par07 Quanto ao Estoque  ? Estoque/WMS  WMS                �
//�����������������������������������������������������������������
Pergunte( cPerg, .F. )
mv_par01 := Space(6)
mv_par02 := "ZZZZZZ"
mv_par03 := Space(6)
mv_par04 := "ZZZZZZ"
mv_par05 := StoD("20160401")
mv_par06 := StoD("20201231")
mv_par07 := 1
Ma450Proces( "SC9", .F., .T., .F., Nil, MV_PAR07==2 )

ConOut("Fun��o LBESTAUT: Libera��o Autom�tica do Estoque < Fim > "+DtoC(Date())+" - "+Time())

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � SCHEDULE � Autor � F�brica ERPBR	� Data  � 19/10/2017      ���
��+----------+------------------------------------------------------------���
���Descricao � Chamadas via schedule.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function LBEST01()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_LBESTA01()
Return

User Function LBEST02()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_LBESTA01()
Return

User Function LBEST03()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_LBESTA01()
Return

User Function LBEST04()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0104"
U_LBESTA01()
Return

User Function LBEST06()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_LBESTA01()
Return

User Function LBEST07()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_LBESTA01()
Return

User Function LBEST08()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_LBESTA01()
Return

User Function LBEST09()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_LBESTA01()
Return

User Function LBEST10()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_LBESTA01()
Return
