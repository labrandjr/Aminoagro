#include "totvs.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MA040VLD � Autor � Luis Brandini   �    Data  � 14/02/2022 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��es na manuten��o do Vendedor - Perfil Coml.|RH	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA040VLD()

Local nOpc   := PARAMIXB // 3- Inclus�o | 4- Altera��o | 5- Exclus�o
Local lRet   := .T.
Local lUsuRH := ( __cUserId $ AllTrim(GetMv("MV_XUSPLRH")) )
 
If nOpc == 4
	If (lUsuRH .And. Substr(SA3->A3_COD,1,2) <> "CM") .Or. (!lUsuRH .And. Substr(SA3->A3_COD,1,2) == "CM")
		MsgAlert("Usu�rio n�o autorizado a efetuar altera��es para este vendedor. Contate o Administrador.")
		lRet := .F.
	Endif		
ElseIf nOpc == 5
	If (lUsuRH .And. Substr(SA3->A3_COD,1,2) <> "CM") .Or. (!lUsuRH .And. Substr(SA3->A3_COD,1,2) == "CM")
		MsgAlert("Usu�rio n�o autorizado a efetuar exclus�o deste vendedor. Contate o Administrador.")
		lRet := .F.
	Endif		
Endif
 
Return(lRet)
