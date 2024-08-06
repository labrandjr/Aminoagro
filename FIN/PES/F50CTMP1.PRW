#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F50CTMP1 ¦ Autor ¦  Luis Brandini   ¦   Data  ¦ 12/01/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar na tabela de rateios.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F50CTMP1()

Local aArea   := GetArea()
Local aHdrRat := {}
Local aColRat := {}
Local lRatCsv := GetMv("MV_ZRATCSV")
Local nRetOpc := 0
Local lExecut := FunName() $("FINA050,FINA750") .And. Inclui

If lExecut

    If lRatCsv
        nRetOpc := u_AskTipRat()
        If nRetOpc == 1 // 1=Importar Csv | 2=Digitar
            MsgRun("Aguarde, importando rateios","Processando",{|| aColRat := u_ImpRatCsv(@aHdrRat,@aColRat) })
        Endif
    Endif

    If Len(aColRat) > 0
        MsgRun("Aguarde, concluindo importação","Processando",{|| Rat050Imp(aColRat) })
    Endif

Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Rat050Imp ¦ Autor ¦ Luis Brandini   ¦ Data  ¦ 30/08/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carrega importação dos rateios a pagar.      			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Rat050Imp(aColRat)

Local zTot := 0
Local _x

For _x := 1 to Len(aColRat)
    zPer := aColRat[_x][2]
    zCCu := aColRat[_x][3]
    zCta := aColRat[_x][4]
    zIte := aColRat[_x][5]
    zVlr := IIf( _x == Len(aColRat), (M->E2_VALOR - zTot), Round((M->E2_VALOR * (zPer/100)),2) )
    zTot += zVlr
    //
    DbSelectArea("TMP")
    If AllTrim(M->E2_TIPO) == "NDF"
        Reclock("TMP",.T.)
        TMP->CTJ_DEBITO := M->E2_CONTAD
        TMP->CTJ_CREDIT := zCta
        TMP->CTJ_PERCEN := zPer
        TMP->CTJ_VALOR  := zVlr
        TMP->CTJ_HIST   := "RATEIO "+AllTrim(M->E2_PREFIXO)+"/"+AllTrim(M->E2_NUM)+" "+AllTrim(Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE,"A2_NREDUZ"))
        TMP->CTJ_CCD    := M->E2_CCUSTO
        TMP->CTJ_CCC    := zCCu
        TMP->CTJ_ITEMD  := Posicione("CTT",1,xFilial("CTT")+M->E2_CCUSTO,"CTT_ZZITCT")
        TMP->CTJ_ITEMC  := zIte
        TMP->CTJ_XVALOR := zVlr
        TMP->CTJ_FLAG   := .F.
        MsUnLock()
    Else
        Reclock("TMP",.T.)
        TMP->CTJ_DEBITO := zCta
        TMP->CTJ_CREDIT := M->E2_CONTAD
        TMP->CTJ_PERCEN := zPer
        TMP->CTJ_VALOR  := zVlr
        TMP->CTJ_HIST   := "RATEIO "+AllTrim(M->E2_PREFIXO)+"/"+AllTrim(M->E2_NUM)+" "+AllTrim(Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE,"A2_NREDUZ"))
        TMP->CTJ_CCD    := zCCu
        TMP->CTJ_CCC    := M->E2_CCUSTO
        TMP->CTJ_ITEMD  := zIte
        TMP->CTJ_ITEMC  := Posicione("CTT",1,xFilial("CTT")+M->E2_CCUSTO,"CTT_ZZITCT")
        TMP->CTJ_XVALOR := zVlr
        TMP->CTJ_FLAG   := .F.
        MsUnLock()
    Endif
Next _x

Return
