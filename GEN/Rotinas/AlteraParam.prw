#Include "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณALTPAR    บAutor  ณ Dione Oliveira บ Data ณ  06/05/16       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este programa serve para alterar alguns parโmetros,        บฑฑ
ฑฑบ          ณ permitindo a operacinalidade por parte do usuแrio          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fun็ใo carregada atrav้s do menu. Programa desenhado para  บฑฑ
ฑฑบUso       ณ Protheus 12.                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ALTERAPARAM()

// Defini็ใo das variแveis do programa.
Public _mvCNDCODA 	:= ""
Public _mvCNDEMIS 	:= ""
Public _mvCNDNUM 	:= ""
Public _mvCNDVALI 	:= ""
Public _mvPROCOM 	:= ""
Public _mvUserLib 	:= ""

If !(cFilAnt $("0104,0107,0108"))
	MsgAlert("Op็ใo disponํvel para Filial com Estado = MT")
	Return
Endif

 _mvCNDCODA := GetMv("ZZ_CNDCODA")
 _mvCNDEMIS := GetMv("ZZ_CNDEMIS")
 _mvCNDNUM 	:= GetMv("ZZ_CNDNUM")   
 _mvCNDVALI := GetMv("ZZ_CNDVALI")
 _mvPROCOM 	:= GetMv("ZZ_PROCOM")
 _mvUserLib := GetMv("ZZ_USERLIB")

// Verifica se o usuแrio ้ o Administrador do sistema ou usuแrios autorizados.
If !Alltrim(__cUserID) $ GetMv("ZZ_USERLIB")
	Alert("Somente o Administrador ou usuแrios autorizados podem executar esta rotina.")
	Return
EndIf   

// Solicita ao usuแrio nome do arquivo.
	@ 150,  1 TO 400, 600 DIALOG oMyDlg TITLE OemToAnsi("Configura็ใo de Parโmetros")
	@   2, 10 TO 110, 300
	@  10, 18 Say " CND Codigo de Autenticidade?"
	@  10,115 Get _mvCNDCODA Size 70,50
	@  20, 18 Say " CND Data de Emissao?"
	@  20,115 Get _mvCNDEMIS Size 70,50
	@  30, 18 Say " N๚mero da CND.?"
	@  30,115 Get _mvCNDNUM Size 70,50
	@  40, 18 Say " CND Validade?"    
	@  40,115 Get _mvCNDVALI Size 70,50
	@  50, 18 Say " Texto Procom MT?"    
	@  50,115 Get _mvPROCOM Size 180,50
	@  60, 18 Say ""
	@  70, 18 Say ""
	@  80, 18 Say ""
	@  90, 18 Say ""
	@ 110,180 BMPBUTTON TYPE 01 ACTION (RunProc(), Close(oMyDlg))
	@ 110,210 BMPBUTTON TYPE 02 ACTION Close(oMyDlg)
	Activate Dialog oMyDlg Centered

Return

Static Function RunProc()

// Faz valida็๕es e Altera os parโmetros. 
	If !Empty(_mvCNDCODA)
		PutMv("ZZ_CNDCODA",_mvCNDCODA)
	EndIf
	
	If !Empty(_mvCNDEMIS)
		PutMv("ZZ_CNDEMIS",_mvCNDEMIS)
	EndIf
	
	If !Empty(_mvCNDNUM)
		PutMv("ZZ_CNDNUM",_mvCNDNUM)
	EndIf   
	 
	If !Empty(_mvCNDVALI)
		PutMv("ZZ_CNDVALI",_mvCNDVALI)
	EndIf   

	If !Empty(_mvPROCOM)
		PutMv("ZZ_PROCOM",_mvPROCOM)
	EndIf   
Return
