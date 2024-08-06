#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CT20GRD   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 05/09/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger na inclusão da conta contábil.   			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CT20GRD()

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
			cAssunto := "Inclusao de Conta Contábil"
			//
			aMensage := {}
			AAdd(aMensage, "Evento X02 - A conta contábil abaixo acaba de ser incluída no sistema pelo usuário "+AllTrim(cUserName))
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Filial: "+xFilial("CT1"))
			AAdd(aMensage, ">> Conta Contábil: "+AllTrim(CT1->CT1_CONTA)+" - "+AllTrim(CT1->CT1_DESC01))
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
