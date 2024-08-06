#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT120SCR  ¦ Autor ¦ ERPBR            ¦   Data  ¦ Jun/18    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona objetos na interface.			     	  		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT120SCR()

Local aArea := GetArea()
Private aComboWf := {"Sim","Não"}
Private oComboWf

cZZEnvWf := IIf(Inclui, RetTpWf(CriaVar("C7_ZZENVWF",.T.)), RetTpWf(SC7->C7_ZZENVWF))

@ 014,zLinWf+090 SAY "Envia WF" OF oFolder:aDialogs[6] PIXEL SIZE 035,009
@ 014,zLinWf+120 MSCOMBOBOX oComboWf VAR cZZEnvWf ITEMS aComboWf WHEN (Inclui .Or. Altera) SIZE 065,050 OF oFolder:aDialogs[6] PIXEL

/*
oFolder:aDialogs[6]:oFont := oDlg:oFont
@ 005,aPosGet[11,1] TO 055,aPosGet[11,2] LABEL STR0053 OF oFolder:aDialogs[6] PIXEL //"Reajuste"
@ 005,003 TO 055,aPosGet[11,3] LABEL STR0054 OF oFolder:aDialogs[6] PIXEL // "Mensagem"
@ 015,aPosGet[12,1] SAY   STR0055   OF oFolder:aDialogs[6] PIXEL SIZE 040,009 // "Cod. Formula"
@ 014,aPosGet[12,2] MSGET cMsg      PICTURE PesqPict('SC7','C7_MSG')     F3 CpoRetF3('C7_MSG')     WHEN !l120Visual .And.VisualSX3('C7_MSG') .And. !lMt120Ped  VALID CheckSX3('C7_MSG',cMsg).And.A120FormDesc(cMsg,@cDescMsg) .And. A120FRefresh(aObj2) OF oFolder:aDialogs[6] PIXEL SIZE 023,009 HASBUTTON
@ 014,aPosGet[12,3] MSGET cReajuste PICTURE PesqPict('SC7','C7_REAJUST') F3 CpoRetF3('C7_REAJUST') WHEN !l120Visual .And.VisualSX3('C7_REAJUST') .And. !lMt120Ped VALID CheckSX3('C7_REAJUST',cReajuste).And.A120FormReaj(cReajuste,@cDescFor) .And. A120FRefresh(aObj2) OF oFolder:aDialogs[6] PIXEL SIZE 023,009 HASBUTTON
@ 015,aPosGet[12,4] SAY   STR0057   OF oFolder:aDialogs[6] PIXEL SIZE 040,009 // "Cod.Formula"
@ 032,aPosGet[12,5] MSGET aObj2[1]  VAR cDescMsg  PICTURE "@!" OF oFolder:aDialogs[6] WHEN .F. PIXEL SIZE 124,009
@ 031,aPosGet[12,6] MSGET aObj2[2]  VAR cDescFor  PICTURE "@!" OF oFolder:aDialogs[6] WHEN .F. PIXEL SIZE 140,009

@ 009,aPosGet[7,1] SAY STR0037    OF  oFolder:aDialogs[3] PIXEL SIZE 035,009 // "Tp. Frete"
@ 008,aPosGet[7,2] MSCOMBOBOX aObj[11] VAR cTpFrete       ITEMS      aCombo ON CHANGE A120VldCombo(cTpFrete,@aValores) .And. A120VFold("NF_FRETE",aValores[FRETE]) WHEN !l120Visual .And. !lMt120Ped SIZE 065,050 OF oFolder:aDialogs[3] PIXEL
*/

RestArea(aArea)

Return


Static Function RetTpWf(zEnvWf)

Local zRetTp := "Sim"

If zEnvWf == "N"
	zRetTp := "Não"
Endif

Return(zRetTp)
