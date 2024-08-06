#Include "RWMAKE.CH"

User Function ALTDTFIS()
// Definição das variáveis do programa.
Public _mvDataFis := GetMv("MV_DATAFIS")
Public _mvUserFis := AllTrim(GetMv("ZZ_USERFIS"))

// Verifica se o usuário é o Administrador do sistema ou usuários autorizados.
If !Alltrim(__cUserID) $(_mvUserFis)
	Alert("Somente o Administrador ou usuários autorizados podem executar esta rotina.")
	Return
EndIf   

@ 150,001 TO 400, 600 DIALOG oMyDlg TITLE OemToAnsi("Configuração de Parâmetros - FISCAL")
@ 002,010 TO 110, 300
@ 020,018 Say " Ultima data de encerramento de operacoes fiscais ?"
@ 040,115 Get _mvDataFis Size 70,50
@ 060,018 Say ""
@ 070,018 Say ""
@ 080,018 Say ""
@ 090,018 Say ""
@ 110,180 BMPBUTTON TYPE 01 ACTION (RunProc(), Close(oMyDlg))
@ 110,210 BMPBUTTON TYPE 02 ACTION Close(oMyDlg)
Activate Dialog oMyDlg Centered
Return

Static Function RunProc()
// Faz validações e Altera os parâmetros. 
	If !Empty(_mvDataFis)
		PutMv("MV_DATAFIS",_mvDataFis)
	EndIf
Return
