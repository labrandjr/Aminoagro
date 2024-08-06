#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SACI008 ¦ Autor ¦  Fábrica ERP.BR    ¦   Data  ¦ 24/11/16  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ponto de entrada após confirmação da baixa			      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SACI008()

Local aArea		:= GetArea()
Local lGrava	:= .T.
Local aRegsD	:= {}
Local aRegsM	:= {}
Private cPergD	:= PadR("CRDESC",10)
Private cPergM	:= PadR("CRMULT",10)

If SE1->E1_DESCONT > 0
	If Pergunte(cPergD,.T.)
		If mv_par01 = 1
			SE1->(RecLock("SE1",.F.))
			SE1->E1_XTPDESC	:= "1"
			SE1->(MsUnlock())
		Elseif mv_par01 = 2
			SE1->(RecLock("SE1",.F.))
			SE1->E1_XTPDESC	:= "2"
			SE1->(MsUnlock())
		Endif		
	Endif
Endif

If SE1->E1_MULTA > 0
	If Pergunte(cPergM,.T.)
		If mv_par01 = 1
			SE1->(RecLock("SE1",.F.))
			SE1->E1_XTPMULT	:= "1"
			SE1->(MsUnlock())
		Elseif mv_par01 = 2
			SE1->(RecLock("SE1",.F.))
			SE1->E1_XTPMULT	:= "2"
			SE1->(MsUnlock())
		Endif		
	Endif
Endif

RestArea(aArea)

Return(lGrava)
