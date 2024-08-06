#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PDFDMS  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  09/02/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Extrato de Premiação - Modelo DM. 	  					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDFDMS(aDados,zTotal,zPerDms,aLista,zPer,lGrvLog)

Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local zPathPDF := AllTrim(mv_par06)+"\"
Local zPdf     := "DM - "+AllTrim( StrTran(SA3->A3_NOME,".","") )+" - "+zPer
Local zTotFol  := 1
Local rtv, _rtv
Private oRtv

// Paginas
xLin    := 145
xRtvAnt := ""
xRtvOk  := .F.
For _rtv := 1 to Len(aDados)
	If xLin > 790
		xLin := 145
		zTotFol += 1
	Endif
	If xRtvAnt != aDados[_rtv][1]
		If xRtvOk
			xLin += 25
		Else
			xRtvOk := .T.
		Endif
		xRtvAnt := aDados[_rtv][1]
	Endif
	xLin += 15
Next _rtv
xLin += 25
If !lGrvLog
	If xLin >= 790
		zTotFol += 1
	Endif
Endif

oRtv:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@oRtv,,,,, (mv_par07==1) )
oRtv:SetResolution(72)
oRtv:SetPortrait()
oRtv:SetPaperSize(DMPAPER_A4)
oRtv:SetMargin(60,60,60,60)
oRtv:cPathPDF := zPathPDF    

oRtv:StartPage()
DmsCab(1,zTotFol,zPer,zTotal,zPerDms,lGrvLog)

zRtvAnt := ""
lRtvOk  := .F.
zFolha  := 1
zLin    := 145
zSubBas := 0
zSubPlr := 0
For rtv := 1 to Len(aDados)
	If zLin > 790 .And. zRtvAnt == aDados[rtv][1]
		oRtv:EndPage()
		oRtv:StartPage()
		zFolha += 1
		DmsCab(zFolha,zTotFol,zPer,zTotal,zPerDms,lGrvLog)
		zLin := 145
		If zRtvAnt == aDados[rtv][1]
			oRtv:Say(zLin, 0000, zNomRtv,oFont10)
		Endif	
	Endif
	zNomRtv := aDados[rtv][2]
	zNomCli := aDados[rtv][4]
	zBasPlr := aDados[rtv][5]
	zPerPlr := aDados[rtv][6]
	zVlrPlr := aDados[rtv][7]
	If zRtvAnt != aDados[rtv][1]
		If lRtvOk
			oRtv:Say(zLin, 0380, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
			oRtv:Say(zLin, 0490, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
			zSubBas := 0
			zSubPlr := 0
			zLin += 10
			oRtv:Line(zLin, 0000, zLin, 0550)
			zLin += 15
			//
			If zLin > 790
				oRtv:EndPage()
				oRtv:StartPage()
				zFolha += 1
				DmsCab(zFolha,zTotFol,zPer,zTotal,zPerDms,lGrvLog)
				zLin := 145
			Endif
		Else
			lRtvOk := .T.
		Endif
		zRtvAnt := aDados[rtv][1]
		oRtv:Say(zLin, 0000, zNomRtv,oFont10)
	Endif
	oRtv:Say(zLin, 0150, zNomCli,oFont10,,IIf(zVlrPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0325, Transform(zPerPlr, "@E 99.99"),oFont10,,IIf(zVlrPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0380, Transform(zBasPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zVlrPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0490, Transform(zVlrPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zVlrPlr<0,CLR_HRED,CLR_BLACK))
	zSubBas += zBasPlr
	zSubPlr += zVlrPlr
	zLin += 15
Next rtv
oRtv:Say(zLin, 0380, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
oRtv:Say(zLin, 0490, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
zLin += 10
oRtv:Line(zLin, 0000, zLin, 0550)
zLin += 15

If !lGrvLog
	If zLin > 790
		oRtv:EndPage()
		oRtv:StartPage()
		zFolha += 1
		DmsCab(zFolha,zTotFol,zPer,zTotal,zPerDms,lGrvLog)
		zLin := 145
	Endif
	oRtv:Say(zLin, 0000,"O presente extrato aqui apresentado possui caráter meramente indicativo, e deve ser utilizado pelo colaborador apenas para fins informativos e indicativos,",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"sendo que, os valores poderão sofrer alterações em virtude das premissas estabelecidas no Acordo Coletivo de Trabalho - Programa de Participação nos",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"Resultados vigente, que dispõe como critério de elegibilidade o atingimento mínimo de 70% (setenta por cento) da meta anual estabelecida, bem como o",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"recebimento dos títulos dentro do prazo máximo de 360 (trezentos sessenta) dias a contar do vencimento origem. As informações não constituem qualquer",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"tipo de direito líquido e certo em relação ao valor a ser recebido pelo colaborador, não devendo ser utilizadas com este propósito. O valor efetivo ao qual",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"o colaborador terá direito ao recebimento serão confirmados nos períodos oficiais de apuração nos meses de janeiro e julho, momento em que receberá",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"seu extrato definitivo com os respectivos valores.",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Line(zLin, 0000, zLin, 0800)
Endif

oRtv:EndPage()

cFilePrint := zPathPDF+zPdf+".pdf"
If mv_par07 == 1
	oRtv:Preview()
Else
	File2Printer( cFilePrint, "PDF" )
	oRtv:Preview()
Endif	
If mv_par08 == 1
	zArqServd := "\premiacao\"+zPdf+".pdf"
	If lGrvLog
		CpyT2S( cFilePrint, "\premiacao", .F. )
	Endif	
	AAdd(aLista,{SA3->A3_COD, AllTrim(SA3->A3_NOME), Lower(AllTrim(SA3->A3_EMAIL)), zPdf+".pdf"})
Endif

If lGrvLog
	U_LogPremi(SA3->A3_COD, SA3->A3_NOME, cFilePrint, Lower(PadR(SA3->A3_EMAIL,80)), "", Lower(PadR(SA3->A3_EMAIL,80)), "P")
	If !Empty(mv_par09)
		U_LogPremi(SA3->A3_COD, SA3->A3_NOME, cFilePrint, Lower(PadR(mv_par09,80)), "", Lower(PadR(mv_par09,80)), "C")
	Endif
	If !Empty(mv_par10)
		U_LogPremi(SA3->A3_COD, SA3->A3_NOME, cFilePrint, Lower(PadR(mv_par10,80)), "", Lower(PadR(mv_par10,80)), "C")
	Endif
	If !Empty(mv_par11)
		U_LogPremi(SA3->A3_COD, SA3->A3_NOME, cFilePrint, Lower(PadR(mv_par11,80)), "", Lower(PadR(mv_par11,80)), "C")
	Endif
	If !Empty(mv_par12)
		U_LogPremi(SA3->A3_COD, SA3->A3_NOME, cFilePrint, Lower(PadR(mv_par12,80)), "", Lower(PadR(mv_par12,80)), "C")
	Endif
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ DmsCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  09/02/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function DmsCab(zFolha,zTotFol,zPer,zTotal,zPerDms,lGrvLog)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp	 := cStartPath + "logo_premiacao.bmp"
Local zPar01     := DtoS(mv_par01)
Local zPar02     := DtoS(mv_par02)

Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont12N := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Local oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Local oFont72  := TFont():New("Arial",72,72,,.F.,,,,.T.,.F.)

oRtv:SayBitmap(0030, 0000, cLogoTp, 0150, 0040)

oRtv:Box(0070, 0000, 0090, 0150)
oRtv:Say(0084, 0055, SA3->A3_COD,oFont12)
oRtv:Box(0070, 0150, 0090, 0400)
oRtv:Say(0084, 0190, PadC(AllTrim(SA3->A3_NOME),40),oFont12)
oRtv:Box(0070, 0400, 0090, 0550)
oRtv:Say(0084, 0445, "R$ "+AllTrim(Transform(zTotal,"@E 999,999.99")),oFont14N)

oRtv:Say(0035, 0235, "APURAÇÃO DE PLR",oFont12N)
oRtv:Say(0050, 0200, "D.M. - "+AllTrim(STR(zPerDms))+"% SOBRE EQUIPE DE VENDAS",oFont12N)
oRtv:Say(0065, 0200, "PERÍODO "+zPer,oFont12N)

oRtv:Say(0035, 0435, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont10)
oRtv:Say(0045, 0435, "Fonte: Protheus "+MesExtenso(dDatabase)+" "+Year2Str(dDatabase),oFont10)
oRtv:Say(0055, 0435, "ADM.: "+Substr(zPar01,7,2)+Substr(zPar01,5,2)+Substr(zPar01,1,4)+Substr(zPar02,7,2)+Substr(zPar02,5,2)+Substr(zPar02,1,4),oFont10)
oRtv:Say(0065, 0435, "PLR..: "+IIf(mv_par14==1,"A Pagar",IIf(mv_par14==2,"Pagas","Pagas & A Pagar")) ,oFont10)

oRtv:Say(0120, 0000, "RTV",oFont10N)
oRtv:Say(0120, 0150, "Cliente",oFont10N)
oRtv:Say(0120, 0320, "% PLR",oFont10N)
oRtv:Say(0105, 0400, "Base PLR",oFont10N)
oRtv:Say(0120, 0380, "(Valor PLR RTV)",oFont10N)
oRtv:Say(0120, 0490, "Valor PLR DM",oFont10N)

oRtv:Line(0130, 0000, 0130, 0550)

If !lGrvLog
	oRtv:Say(0300, 0150, "PROJEÇÃO",oFont72,,CLR_HGRAY)
Endif

Return
