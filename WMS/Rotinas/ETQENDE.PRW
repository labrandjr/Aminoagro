#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "totvs.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ETQENDE   ¦ Autor ¦  Fábrica ERP.BR   ¦ Data  ¦ 14/05/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gera etiquetas dos endereços.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ETQENDE()

Local aEtiq := {}
Local _etq
Private oFont06  := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
Private oFont07  := TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont07N := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
Private oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont09  := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Private oFont09N := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Private oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont12N := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont14  := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Private oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oFont16  := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
Private oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oFont18  := TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)
Private oFont18N := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
Private oFont20  := TFont():New("Arial",20,20,,.F.,,,,.T.,.F.)
Private oFont20N := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)
Private oFont22  := TFont():New("Arial",22,22,,.F.,,,,.T.,.F.)
Private oFont22N := TFont():New("Arial",22,22,,.T.,,,,.T.,.F.)
Private zPth := ""
Private zPdf := ""
Private oPdf

DbSelectArea("SBE")
DbSetOrder(1)
DbSeek( xFilial("SBE") + "04" )
While !Eof() .And. SBE->(BE_FILIAL+BE_LOCAL) == xFilial("SBE") + "04"
	If SBE->BE_STATUS <> "3" .And. SBE->BE_MSBLQL <> "1"
		AAdd(aEtiq,SBE->BE_LOCALIZ)
	Endif	
	If Len(aEtiq) == 20
		Exit
	Endif
	DbSelectArea("SBE")
	SBE->(DbSkip())
Enddo

zPth := "c:\report\"
nPag := 0
nLim := 6
nMax := 5
nPos := 40
lEtq := .F.
For _etq := 1 to Len(aEtiq)

	If nLim > nMax
		If lEtq
			oPdf:EndPage()
			cFilePrint := zPth + zPdf
			File2Printer(cFilePrint,"PDF")
			oPdf:Preview()
			nLim := 1
			nPos := 40
		Else
			lEtq := .T.
			nLim := 1
		Endif
		//
		nPag += 1
		zPdf := "pagina"+AllTrim(STR(nPag))+".pdf" 
		oPdf:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPth,.T.,,@oPdf,,,,, .F. )
		//
		oPdf:SetResolution(72)
		oPdf:SetPortrait()
		oPdf:SetPaperSize(DMPAPER_A4)
		oPdf:SetMargin(60,60,60,60)
		oPdf:cPathPDF := zPth
		oPdf:StartPage()
	Endif
	
	xEndereco := AllTrim(aEtiq[_etq])
	oPdf:Line(nPos,040,nPos,250)
	oPdf:Say(nPos+20,050,xEndereco,oFont22N)
	oPdf:Code128B(nPos+065,040,xEndereco,045)
	oPdf:Line(nPos+070,040,nPos+070,250)
	nPos += 100
	nLim += 1

	If _etq == Len(aEtiq)
		oPdf:EndPage()
		cFilePrint := zPth + zPdf
		File2Printer(cFilePrint,"PDF")
		oPdf:Preview()
	Endif

Next _etq

Return

