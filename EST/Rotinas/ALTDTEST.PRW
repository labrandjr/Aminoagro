#Include "RWMAKE.CH"

User Function ALTDTEST()
// Defini��o das vari�veis do programa.
Public _mvDataEst := GetMv("MV_DBLQMOV")
Public _mvUserEst := AllTrim(GetMv("ZZ_USEREST"))

// Verifica se o usu�rio � o Administrador do sistema ou usu�rios autorizados.
If !Alltrim(__cUserID) $(_mvUserEst)
	Alert("Somente o Administrador ou usu�rios autorizados podem executar esta rotina.")
	Return
EndIf   

@ 150,001 TO 400, 600 DIALOG oMyDlg TITLE OemToAnsi("Configura��o de Par�metros - ESTOQUE")
@ 002,010 TO 110, 300
@ 020,018 Say " �ltima data para movimenta��es de estoque ?"
@ 040,115 Get _mvDataEst Size 70,50
@ 060,018 Say ""
@ 070,018 Say ""
@ 080,018 Say ""
@ 090,018 Say ""
@ 110,180 BMPBUTTON TYPE 01 ACTION (RunProc(), Close(oMyDlg))
@ 110,210 BMPBUTTON TYPE 02 ACTION Close(oMyDlg)
Activate Dialog oMyDlg Centered
Return

Static Function RunProc()
// Faz valida��es e Altera os par�metros. 
	If !Empty(_mvDataEst)
		PutMv("MV_DBLQMOV",_mvDataEst)
	EndIf
Return
