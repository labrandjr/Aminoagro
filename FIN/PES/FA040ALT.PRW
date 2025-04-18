#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � FA040ALT � Autor � F�brica ERP.BR   �  Data  � 18/03/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��o antes da execu��o dos processos Contas Receber.  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function FA040ALT()

Local aArea  := GetArea()
Local lRetOk := .T.
Local zUsrVn := AllTrim(GetMv("MV_ZUALTVN"))

If (M->E1_VENCTO != SE1->E1_VENCTO) .Or. (M->E1_VENCREA != SE1->E1_VENCREA) 
	If __cUserId $(zUsrVn) .Or. __cUserId == "000000"
		lRetOk := ClassAlt()
	Else
		MsgAlert("Altera��o de Vencimento: usu�rio n�o autorizado.")
		lRetOk := .F.
	Endif
Endif

RestArea(aArea)

Return(lRetOk)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ClassAlt � Autor � F�brica ERP.BR   �  Data  � 18/03/2020  ���
��+----------+------------------------------------------------------------���
���Descricao � Interface de classifica��o.  							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ClassAlt()

Local nOpcDwn := 0
Local bOkDwn  := {|| nOpcDwn:=1,oDlgDwn:End() }
Local bCanDwn := {|| nOpcDwn:=0,oDlgDwn:End() }
Local nRadio1 := 1
Local lRetCla := .F.
Local oDlgDwn,oRadio1

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376

DEFINE MSDIALOG oDlgDwn FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Classificar Altera��o" OF oDlgDwn PIXEL
@ 042,065 RADIO oRadio1 VAR nRadio1 3D SIZE 70,11 PROMPT "Prorroga��o","Corre��o" OF oDlgDwn PIXEL
ACTIVATE MSDIALOG oDlgDwn ON INIT EnchoiceBar(oDlgDwn,bOkDwn,bCanDwn) CENTERED

If nOpcDwn == 1
	M->E1_ZCLASAL := IIf(nRadio1 == 1,"P","C")
	M->E1_ZUSRALT := cUserName
	M->E1_ZDATALT := Date()
	If nRadio1 == 2
		M->E1_ZVENOR1 := SE1->E1_VENCORI
		M->E1_VENCTO  := M->E1_VENCREA
		M->E1_VENCORI := M->E1_VENCREA
	Endif	
	lRetCla := .T.
Endif

Return(lRetCla)
