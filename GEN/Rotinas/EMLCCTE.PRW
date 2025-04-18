#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � EMLCCTE   � Autor � F�brica ERPBR  � Data  � 29/04/2021    ���
��+----------+------------------------------------------------------------���
���Descricao � Envia email referente inclus�o de documento fiscal ref.	  ���
���          � ct-e quando nf associada n�o tem cta.cont�bil no tes.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function EMLCCTE(xFil,xDoc,xSer,xFor,aTesCte)

Local aArea    := GetArea()
Local zUsrMail := AllTrim(GetMv("MV_XUSCCTE"))
Local aUsrMail := {}
Local zTitulo  := "Inclus�o de Ct-e sem Cta.Cont�bil no Tes"
Local zEmail   := ""
Local zNomFor  := POSICIONE("SA2",1,XFILIAL("SA2")+xFor,"A2_NREDUZ")
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

	zTes := ""
	For _x := 1 to Len(aTesCte)
		zTes += IIf(!Empty(zTes),", ","")+aTesCte[_x]
	Next _x

	For _x := 1 to Len(aUsrMail)
		zCodUs := StrZero(Val(aUsrMail[_x]),6)
		zEmlUs := AllTrim(UsrRetMail(zCodUs))
		zEmail += IIf(!Empty(zEmail),";","") + zEmlUs
	Next _x	

	cAssunto := "Inclus�o de Ct-e sem conta cont�bil "+xFil+"-"+AllTrim(xDoc)+" "+AllTrim(xSer)

	aMensage := {}
	AAdd(aMensage, "O ct-e possui documentos fiscais associados sem conta cont�bil cadastrada no Tes.")
	AAdd(aMensage, "")
	AAdd(aMensage, ">> Filial.: "+xFil)
	AAdd(aMensage, ">> Doc....: "+xDoc)
	AAdd(aMensage, ">> S�rie..: "+xSer)
	AAdd(aMensage, ">> Fornec.: "+zNomFor)
	AAdd(aMensage, ">> Tes....: "+zTes)
	AAdd(aMensage, ">> Obs....: Cadastre a conta cont�bil no(s) Tes informado(s) acima.")

	zResult := U_TMailWar(zTitulo, zEmail, cAssunto, aMensage)

Endif	

RestArea(aArea)

Return
