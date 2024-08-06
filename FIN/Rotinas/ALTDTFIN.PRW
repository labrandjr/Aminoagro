#Include "RWMAKE.CH"

User Function ALTDTFIN()
// Defini√ß√£o das vari√°veis do programa.
Public _mvDataFin := GetMv("MV_DATAFIN")
Public _mvUserFin := AllTrim(GetMv("ZZ_USERFIN"))

// Verifica se o usu·rio È o Administrador do sistema ou usu·rios autorizados.
If !Alltrim(__cUserID) $(_mvUserFin)
	Alert("Somente o Administrador ou usu·rios autorizados podem executar esta rotina.")
	Return
EndIf   

@ 150,001 TO 400, 600 DIALOG oMyDlg TITLE OemToAnsi("ConfiguraÁ„o de par‚metros - FINANCEIRO")
@ 002,010 TO 110, 300
@ 020,018 Say " Data limite p/ realizacao de operacoes financeiras?"
@ 040,115 Get _mvDataFin Size 70,50
@ 060,018 Say ""
@ 070,018 Say ""
@ 080,018 Say ""
@ 090,018 Say ""
@ 110,180 BMPBUTTON TYPE 01 ACTION (RunProc(), Close(oMyDlg))
@ 110,210 BMPBUTTON TYPE 02 ACTION Close(oMyDlg)
Activate Dialog oMyDlg Centered
Return

Static Function RunProc()
// Faz valida√ß√µes e Altera os par√¢metros. 
	If !Empty(_mvDataFin)
		PutMv("MV_DATAFIN",_mvDataFin)
	EndIf
Return
