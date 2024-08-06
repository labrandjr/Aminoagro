#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PDFPAG  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  01/11/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relação para Pagamento de Premiação.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDFPAG(aDados,zTotal,zPer,dDataDe,dDataAt)

Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local zPathPDF := AllTrim(mv_par06)+"\"
Local zPdf     := "extrato de PLR - "
Local zTotFol  := 1
Local rtv, _pag
Private oPag

If Empty(mv_par03)
	zPdf += "(      ) "
Else
	zPdf += "("+mv_par03+") "
Endif
zPdf += "a ("+mv_par04+") - "+zPer
zPdf += " - ordenado por "+IIf(mv_par05==1,"ranking","nome")

// Paginas
xLin := 145
For _pag := 1 to Len(aDados)
	If xLin > 790
		xLin := 145
		zTotFol += 1
	Endif
	xLin += 15
Next _pag

oRtv:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@oRtv,,,,, (mv_par07==1) )
oRtv:SetResolution(72)
oRtv:SetPortrait()
oRtv:SetPaperSize(DMPAPER_A4)
oRtv:SetMargin(60,60,60,60)
oRtv:cPathPDF := zPathPDF    

oRtv:StartPage()
PagCab(1,zTotFol,zPer,zTotal,dDataDe,dDataAt)

zFolha  := 1
zLin    := 145
For rtv := 1 to Len(aDados)
	If zLin > 790
		oRtv:EndPage()
		oRtv:StartPage()
		zFolha += 1
		PagCab(zFolha,zTotFol,zPer,zTotal,dDataDe,dDataAt)
		zLin := 145
	Endif
	zCodRtv := aDados[rtv][1]
	zNomRtv := aDados[rtv][2]
	zVlrPlr := aDados[rtv][3]
	oRtv:Say(zLin, 0000, zCodRtv,oFont10)
	oRtv:Say(zLin, 0050, zNomRtv,oFont10)
	oRtv:Say(zLin, 0250, Replicate(".",110),oFont10)
	oRtv:Say(zLin, 0470, Transform(zVlrPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zVlrPlr<0,CLR_HRED,CLR_BLACK))
	zLin += 15
Next rtv
zLin += 10
oRtv:Line(zLin, 0000, zLin, 0550)

oRtv:EndPage()

cFilePrint := zPathPDF+zPdf+".pdf"
If mv_par07 == 1
	oRtv:Preview()
Else
	File2Printer( cFilePrint, "PDF" )
	oRtv:Preview()
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PagCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  01/11/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function PagCab(zFolha,zTotFol,zPer,zTotal,dDataDe,dDataAt)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp	 := cStartPath + "logo_premiacao.bmp"
Local zPar01     := DtoS(dDataDe)
Local zPar02     := DtoS(dDataAt)

Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont12N := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Local oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)

oRtv:SayBitmap(0030, 0000, cLogoTp, 0150, 0040)

oRtv:Box(0070, 0000, 0090, 0150)
oRtv:Say(0084, 0060, "P A G",oFont12)
oRtv:Box(0070, 0150, 0090, 0400)
oRtv:Say(0084, 0230, "FOLHA DE PAGAMENTO",oFont12)
oRtv:Box(0070, 0400, 0090, 0550)
oRtv:Say(0084, 0435, "R$ "+AllTrim(Transform(zTotal,"@E 9,999,999.99")),oFont14N)

oRtv:Say(0050, 0245, "EXTRATO DE PLR",oFont12N)
oRtv:Say(0065, 0200, "PERÍODO "+zPer,oFont12N)

oRtv:Say(0035, 0435, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont10)
oRtv:Say(0046, 0435, "Fonte: Protheus "+MesExtenso(dDatabase)+" "+Year2Str(dDatabase),oFont10)
oRtv:Say(0057, 0435, "ADM.: "+Substr(zPar01,7,2)+Substr(zPar01,5,2)+Substr(zPar01,1,4)+Substr(zPar02,7,2)+Substr(zPar02,5,2)+Substr(zPar02,1,4),oFont10)
oRtv:Say(0068, 0435, "PLR..: "+IIf(mv_par08==1,"A Pagar",IIf(mv_par08==2,"Pagas","Pagas & A Pagar")) ,oFont10)

oRtv:Say(0120, 0000, "Código",oFont10N)
oRtv:Say(0120, 0050, "Nome",oFont10N)
oRtv:Say(0120, 0490, "Valor PLR ",oFont10N)

oRtv:Line(0130, 0000, 0130, 0550)

Return
