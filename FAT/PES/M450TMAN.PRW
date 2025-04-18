#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � M450TMAN � Autor � Luis Brandini    �   Data  � 20/09/17   ���
��+----------+------------------------------------------------------------���
���Descricao � Libera��o manual de cr�dito condicionada.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function M450TMAN()

Local aArea   := GetArea()
Local zUsCrMn := AllTrim(GetMv("MV_XUSCRMN"))
Local lRetOk  := .T.

If __cUserId != "000000"
	If !Empty(zUsCrMn)
		If !(__cUserId $ zUsCrMn)
			MsgInfo("Aten��o, libera��o manual de cr�dito n�o autorizada para este usu�rio. Contate o Administrador.")
			lRetOk := .F.		
			Return
		Endif
	Endif	
Endif

RestArea(aArea)

Return(lRetOk)
