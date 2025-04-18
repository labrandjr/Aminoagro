#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � FA040B01 � Autor � Luis Brandini   �   Data  � 04/10/2019  ���
��+----------+------------------------------------------------------------���
���Descricao � Valida exclus�o do t�tulo a receber.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function FA040B01()

Local lRetorno := .T.
Local dDataFin := GetMv("MV_DATAFIN")
Local cEOL     := CHR(13)+CHR(10)

If FunName() == "FINA040"
	If SE1->E1_EMISSAO < dDataFin
		MsgAlert("Manuten��o n�o permitida."+cEOL+;
				 "Per�odo fechado."+cEOL+;
				 "MV_DATAFIN = "+DtoC(dDataFin))
				 lRetorno := .F.
	Endif
ElseIf FunName() == "FINA050"	
	If SE2->E2_EMISSAO < dDataFin
		MsgAlert("Manuten��o n�o permitida."+cEOL+;
				 "Per�odo fechado."+cEOL+;
				 "MV_DATAFIN = "+DtoC(dDataFin))
				 lRetorno := .F.
	Endif
Endif

Return(lRetorno)
