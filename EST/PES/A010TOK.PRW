#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � A010TOK   � Autor � F�brica ERP.BR   �    Data  � 08/01/20 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��o adicional na Inclus�o/Altera��o do Produto.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function A010TOK()

Local aArea := GetArea()
Local lRetP := .T.
Local cEOL  := CHR(13)+CHR(10)
Local lBlqSap := GetMv("MV_ZBLQSAP")

If lBlqSap
	MsgInfo("Bloqueio migra��o Sap !")
	Return(.F.)
Endif

If M->B1_TIPO == "PA"
	If Empty(M->B1_ZFAMILI)
		MsgInfo("Fam�lia n�o informada (aba 'Espec�ficos')."+cEOL+;
				"Informa��o obrigat�ria para PA.")
		lRetP := .F.
	ElseIf M->B1_RASTRO != "L"
		MsgInfo("Para 'PA' o Rastro deve ser preenchido com 'L=Lote'.")
		lRetP := .F.
	ElseIf M->B1_LOCALIZ != "S" // Tratamento desativado aqui e inserido no PE MT010INC
//		MsgInfo("Para 'PA' o Contr.Endere�o deve ser preenchido com 'S=Sim'.")
//		lRetP := .F.
	Endif
ElseIf M->B1_TIPO == "SV"
	If Empty(M->B1_CODISS)
		MsgInfo("Cod.Serv.ISS n�o informado (aba 'Impostos')."+cEOL+;
				"Informa��o obrigat�ria para SV.")
		lRetP := .F.
	Endif
ElseIf M->B1_TIPO == "MP"
	If M->B1_RASTRO != "L"
		MsgInfo("Para 'MP' o Rastro deve ser preenchido com 'L=Lote'.")
		lRetP := .F.
	ElseIf M->B1_LOCALIZ != "S" // Tratamento desativado aqui e inserido no PE MT010INC
//		MsgInfo("Para 'MP' o Contr.Endere�o deve ser preenchido com 'S=Sim'.")
//		lRetP := .F.
	Endif
Endif

RestArea(aArea)

Return(lRetP)
