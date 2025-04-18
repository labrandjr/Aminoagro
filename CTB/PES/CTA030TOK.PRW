#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � CTA030TOK � Autor �  F�brica ERP.BR   �   Data  � 16/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Ponto de Entrada p/ registrar altera��es de BU no centro   ���
���          � de custo quando existe hist�rico de emiss�o de NF.		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CTA030TOK()

Local aArea  := GetArea()
Local cEOL   := CHR(13)+CHR(10)
Local lRetOk := .F. // .F.=N�o h� problemas | .T.=Inconsist�ncias

If PARAMIXB == 3 // Inclus�o
	If AllTrim(M->CTT_CLASSE) == "2" // Anal�tico
		If Empty(M->CTT_ZZITCT)
			MsgAlert("Aten��o, 'UN Neg�cio' n�o informada!")
			lRetOk := .T.
		Endif
	Endif
ElseIf PARAMIXB == 4 // Altera��o
	If AllTrim(CTT->CTT_ZZITCT) != AllTrim(M->CTT_ZZITCT)
		If _ExistNfBu(CTT->CTT_CUSTO,CTT->CTT_ZZITCT)
			MsgAlert("Aten��o, existem notas fiscais emitidas para o centro de custo"+cEOL+;
					 " '"+AllTrim(CTT->CTT_CUSTO)+"' e '"+AllTrim(CTT->CTT_ZZITCT)+"'."+cEOL+;
					 "A altera��o para '"+AllTrim(M->CTT_ZZITCT)+"' ser� registrada em Log.")
			If !MsgYesNo("Confirma altera��o ?","Aviso","INFO")
				lRetOk := .T.
			Else
				// Registra altera��o com evid�ncia de hist�rico de NFs emitidas.
				RecLock("SZB",.T.)
				SZB->ZB_FILIAL  := xFilial("SZB")
				SZB->ZB_CUSTO   := CTT->CTT_CUSTO
				SZB->ZB_BUANT   := CTT->CTT_ZZITCT
				SZB->ZB_BUNOV   := M->CTT_ZZITCT
				SZB->ZB_USUARIO := cUserName
				SZB->ZB_DATA    := Date()
				SZB->ZB_HORA    := Time()
				SZB->ZB_TEMNF   := "S"
				MsUnLock()
			Endif
		Else
			// Apenas registra a altera��o
			RecLock("SZB",.T.)
			SZB->ZB_FILIAL  := xFilial("SZB")
			SZB->ZB_CUSTO   := CTT->CTT_CUSTO
			SZB->ZB_BUANT   := CTT->CTT_ZZITCT
			SZB->ZB_BUNOV   := M->CTT_ZZITCT
			SZB->ZB_USUARIO := cUserName
			SZB->ZB_DATA    := Date()
			SZB->ZB_HORA    := Time()
			SZB->ZB_TEMNF   := "N"
			MsUnLock()
		Endif
	Endif
Endif
	
RestArea(aArea)

Return(lRetOk)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � _ExistNfBu � Autor � F�brica ERP.BR   �   Data  � 16/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Pesquisa notas fiscais de sa�da que utilizaram a BU em     ���
���          � refer�ncia do par�metro.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function _ExistNfBu(xCC,xBU)

Local aArea  := GetArea()
Local lRetBu := .F. // N�o existe NF emitida com a BU.

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("SD2")
cQuery += " WHERE D2_CCUSTO = '"+AllTrim(xCC)+"' "
cQuery += " AND D2_ITEMCC = '"+AllTrim(xBU)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSQL", .F., .T.)
lRetBu := (TSQL->SOMA > 0) // Existe NF emitida com a BU.
TSQL->(DbCloseArea())

RestArea(aArea)

Return(lRetBu)
