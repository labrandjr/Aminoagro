#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � EMLNFTR   � Autor � F�brica ERPBR  � Data  � 24/04/2021    ���
��+----------+------------------------------------------------------------���
���Descricao � Envia email referente exclus�o de documento fiscal ref.	  ���
���          � transfer�ncia entre filiais.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function EMLNFTR(xTpNf,xFil,xDoc,xSer)

Local aArea    := GetArea()
Local zUsrMail := AllTrim(GetMv("MV_XUSNFTR"))
Local aUsrMail := {}
Local zTitulo  := "Exclus�o de Documento Fiscal"
Local zEmail   := ""
Local _x

If !Empty(zUsrMail)

	nPosic  := 0
	aLinha  := {}
	cTxtLin := zUsrMail
	While (!Empty(cTxtLin))
		If (((nPosic := AT(",",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo
	aUsrMail := aClone(aLinha)

	For _x := 1 to Len(aUsrMail)
		zCodUs := StrZero(Val(aUsrMail[_x]),6)
		zEmlUs := AllTrim(UsrRetMail(zCodUs))
		zEmail += IIf(!Empty(zEmail),";","") + zEmlUs
	Next _x	

	cAssunto := "Exclus�o Doc "+IIf(xTpNf=="S","Sa�da","Entrada")+" ref Transf entre Filiais "+xFil+"-"+xDoc+" "+AllTrim(xSer)

	aMensage := {}
	AAdd(aMensage, "O documento fiscal de transfer�ncia entre filiais foi exclu�do.")
	AAdd(aMensage, "")
	AAdd(aMensage, ">> Filial.: "+xFil)
	AAdd(aMensage, ">> Doc....: "+xDoc)
	AAdd(aMensage, ">> S�rie..: "+xSer)
	AAdd(aMensage, ">> Obs....: Exclua o documento de "+IIf(xTpNf=="S","entrada","sa�da")+" na filial de "+IIf(xTpNf=="S","destino","origem"))

	zResult := U_TMailWar(zTitulo, zEmail, cAssunto, aMensage)

Endif	

RestArea(aArea)

Return
