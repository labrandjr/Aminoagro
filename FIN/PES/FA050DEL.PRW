#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � FA050DEL � Autor �  Luis Brandini   �   Data  � 04/10/2019 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida exclus�o do t�tulo a pagar.			  			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function FA050DEL()

Local lRetorno := .T.
Local dDataFin := GetMv("MV_DATAFIN")
Local cEOL     := CHR(13)+CHR(10)
	
If AllTrim(SE2->E2_TIPO) != "PR"
	If SE2->E2_EMISSAO < dDataFin
		MsgAlert("Manuten��o n�o permitida."+cEOL+;
				 "Per�odo fechado."+cEOL+;
				 "MV_DATAFIN = "+DtoC(dDataFin))
				 lRetorno := .F.
	Endif
Endif

Return(lRetorno)
