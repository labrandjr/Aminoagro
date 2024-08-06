#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CT030GRI  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 31/08/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envia email após inclusão do centro de custo.   			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CT030GRI()

Local aArea    := GetArea()
Local zUsrMail := AllTrim(GetMv("MV_XEMCCUS"))
Local aUsrMail := {}
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
Endif

For _x := 1 to Len(aUsrMail)
	zEmail := UsrRetMail(aUsrMail[_x])
	If !Empty(zEmail)
		nPosic := AT("@",zEmail)
		If nPosic > 0
			cAssunto := "Inclusão de Centro de Custo"
			//
			aMensage := {}
			AAdd(aMensage, "Evento X01 - O centro de custo abaixo acaba de ser incluído no sistema pelo usuário "+AllTrim(cUserName))
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial: "+xFilial("CTT"))
			AAdd(aMensage, ">> Centro de Custo: "+AllTrim(CTT->CTT_CUSTO)+" - "+AllTrim(CTT->CTT_DESC01))
			AAdd(aMensage, ">> UN Negócio: "+AllTrim(CTT->CTT_ZZITCT))
            //
			//zEmail := "luis.brandini@erpbr.net"
			U_MailNotify(zEmail, cAssunto, aMensage, .F.)
		Endif
	Endif
Next _x	
	
RestArea(aArea)

Return

/*
Evento 033 - O Produto abaixo acaba de ser incluido no sistema pelo usuario irandu.silveira

>> Filial : 
>> Produto : 002484 - MAXI TURBO ORGAN 10L BD PY 
>> Tipo : PA
>> Armazem Padrao : 04
>> Unidade de Medida : L 

E-Mail automatico enviado pelo modulo SIGAEST
*/
