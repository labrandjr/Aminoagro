#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ EMLNFTR   ¦ Autor ¦ Fábrica ERPBR  ¦ Data  ¦ 24/04/2021    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envia email referente exclusão de documento fiscal ref.	  ¦¦¦
¦¦¦          ¦ transferência entre filiais.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function EMLNFTR(xTpNf,xFil,xDoc,xSer)

Local aArea    := GetArea()
Local zUsrMail := AllTrim(GetMv("MV_XUSNFTR"))
Local aUsrMail := {}
Local zTitulo  := "Exclusão de Documento Fiscal"
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

	cAssunto := "Exclusão Doc "+IIf(xTpNf=="S","Saída","Entrada")+" ref Transf entre Filiais "+xFil+"-"+xDoc+" "+AllTrim(xSer)

	aMensage := {}
	AAdd(aMensage, "O documento fiscal de transferência entre filiais foi excluído.")
	AAdd(aMensage, "")
	AAdd(aMensage, ">> Filial.: "+xFil)
	AAdd(aMensage, ">> Doc....: "+xDoc)
	AAdd(aMensage, ">> Série..: "+xSer)
	AAdd(aMensage, ">> Obs....: Exclua o documento de "+IIf(xTpNf=="S","entrada","saída")+" na filial de "+IIf(xTpNf=="S","destino","origem"))

	zResult := U_TMailWar(zTitulo, zEmail, cAssunto, aMensage)

Endif	

RestArea(aArea)

Return
