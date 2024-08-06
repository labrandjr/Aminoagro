#Include "Protheus.ch"
#Include "RWMAKE.CH"

/*/{Protheus.doc} LockParameters

Programa responsável pela atualizaçao dos parâmetros MV_ZZPPDD, MV_ZZPFRET e MV_ZZPDPAD. Programa desenvolvido com base no
programa ALTPAR do Shopping Eldorado

@author Augusto Krejci Bem-Haja
@since 29/02/2016
@return nil
/*/

User Function LockParameters()

	Local cMVZZPPDD  	:= GetMv("MV_ZZPPDD")
	Local cMVZZPFRET 	:= GetMv("MV_ZZPFRET")
	Local cMVZZPDPAD 	:= GetMv("MV_ZZPDPAD")
	Local cZZPERCGER	:= GetMv("ZZ_PERCGER")
	Local cZZPERCDIR	:= GetMv("ZZ_PERCDIR")
	Local oDlg		 	:= Nil
	
	//Monta tela com os parâmetros
	@ 150, 001 To 320, 435 DIALOG oDlg Title OemToAnsi("Manutenção de Parâmetros - Regras de Vendas")
	@ 002, 010 To 065, 210
	@ 010, 018 Say " Percentual de PDD: "
	@ 010, 115 Get cMVZZPPDD Size 50,50 PICTURE "@E 99"
	@ 020, 018 Say " Percentual de Frete: "
	@ 020, 115 Get cMVZZPFRET Size 50,50 PICTURE "@E 99"
	@ 030, 018 Say " Percentual de Desp. Adm.: "
	@ 030, 115 Get cMVZZPDPAD Size 50,50 PICTURE "@E 99"
	@ 040, 018 Say " Percentual de Premiação Gerente: "
	@ 040, 115 Get cZZPERCGER Size 50,50 PICTURE "@E 99"
	@ 050, 018 Say " Percentual de Premiação Diretor: "
	@ 050, 115 Get cZZPERCDIR Size 50,50 PICTURE "@E 99"
	@ 070, 150 BMPBUTTON TYPE 01 ACTION (ChangeParameter(cMVZZPPDD, cMVZZPFRET, cMVZZPDPAD,cZZPERCGER,cZZPERCDIR), Close(oDlg))
	@ 070, 180 BMPBUTTON TYPE 02 ACTION Close(oDlg)
	
	Activate Dialog oDlg Centered

Return Nil

Static Function ChangeParameter(cMVZZPPDD, cMVZZPFRET, cMVZZPDPAD, cZZPERCGER, cZZPERCDIR)

	PutMv("MV_ZZPPDD", cMVZZPPDD)
	PutMv("MV_ZZPFRET", cMVZZPFRET)
	PutMv("MV_ZZPDPAD", cMVZZPDPAD)
	PutMv("ZZ_PERCGER", cZZPERCGER)
	PutMv("ZZ_PERCDIR", cZZPERCDIR)

Return Nil

