#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PDFRTV  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  01/11/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Extrato de Premiação - Modelo RTV. 	  					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDFRTV(aDados,zTotal,lRevenda,aLista,zPer,aNccDet,nCrdNcc,lGrvLog,nFilPag)

Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local zPathPDF := AllTrim(mv_par06)+"\"
Local zPrf     := IIf(lRevenda,"REV - ","RTV - ")
Local zPdf     := zPrf+AllTrim(StrTran(SA3->A3_NOME,".",""))+" - "+zPer
Local zTotFol  := 1
Local rtv
Private oRtv

// Calcula total de páginas
xLin    := 165
xCliAnt := ""
xCliOk  := .F.
For rtv := 1 to Len(aDados)
	If xLin > 545 .And. xCliAnt == aDados[rtv][1]
		zTotFol += 1
		xLin := 165
		If xCliAnt == aDados[rtv][1]
			xLin += 15
		Endif	
	Endif
	If xCliAnt != aDados[rtv][1]
		If xCliOk
			xLin += 25
			//
			If xLin > 545
				zTotFol += 1
				xLin := 165
			Endif
		Else
			xCliOk := .T.
		Endif
		xCliAnt := aDados[rtv][1]
		xLin += 15
	Endif
	xLin += 15
Next rtv
xLin += 10

oRtv:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@oRtv,,,,, (mv_par07==1) )
oRtv:SetResolution(72)
oRtv:SetLandscape()
oRtv:SetPaperSize(DMPAPER_A4)
oRtv:SetMargin(60,60,60,60)
oRtv:cPathPDF := zPathPDF

oRtv:StartPage()
RtvCab(1,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)

zCliAnt := ""
lCliOk  := .F.
zFolha  := 1
zLin    := 165
zSubPag := 0
zSubBas := 0
zSubPlr := 0
For rtv := 1 to Len(aDados)
	If zLin > 545 .And. zCliAnt == aDados[rtv][1]
		oRtv:EndPage()
		oRtv:StartPage()
		zFolha += 1
		RtvCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)
		zLin := 165
		If zCliAnt == aDados[rtv][1]
			oRtv:Say(zLin, 0000, zNomCli,oFont10N)
			zLin += 15
		Endif	
	Endif
	zNomCli := aDados[rtv][2]
	zTitulo := AllTrim(aDados[rtv][3])+"-"+AllTrim(aDados[rtv][4])+"-"+AllTrim(aDados[rtv][15])
	zVencto := aDados[rtv][5]
	zVencto := Day2Str(zVencto)+"/"+Month2Str(zVencto)+"/"+Year2Str(zVencto)
	zPagmto := aDados[rtv][6]
	zPagmto := Day2Str(zPagmto)+"/"+Month2Str(zPagmto)+"/"+Year2Str(zPagmto)
	zPedido := aDados[rtv][7]
	zVlrTit := aDados[rtv][8]
	zBasPlr := aDados[rtv][9]
	zPerPlr := aDados[rtv][10]
	zVlrPlr := aDados[rtv][11]
	zAcordo := aDados[rtv][14]
	zVlrPag := aDados[rtv][16]
	If zCliAnt != aDados[rtv][1]
		If lCliOk
			oRtv:Say(zLin, 0460, Transform(zSubPag, PesqPict("SE1","E1_VALOR")),oFont10N)
			oRtv:Say(zLin, 0545, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
			oRtv:Say(zLin, 0710, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
			zSubPag := 0
			zSubBas := 0
			zSubPlr := 0
			zLin += 10
			oRtv:Line(zLin, 0000, zLin, 0800)
			zLin += 15
			//
			If zLin > 545
				oRtv:EndPage()
				oRtv:StartPage()
				zFolha += 1
				RtvCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)
				zLin := 165
			Endif
		Else
			lCliOk := .T.
		Endif
		zCliAnt := aDados[rtv][1]
		oRtv:Say(zLin, 0000, zNomCli,oFont10N)
		zLin += 15
	Endif
	oRtv:Say(zLin, 0000, zAcordo,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0120, zTitulo,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0220, zVencto,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0280, zPagmto,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0350, zPedido,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))

	oRtv:Say(zLin, 0390, Transform(zVlrTit, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0460, Transform(zVlrPag, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))

	oRtv:Say(zLin, 0545, Transform(zBasPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0650, Transform(zPerPlr, "@E 999.99"),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0710, Transform(zVlrPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	zSubPag += zVlrPag
	zSubBas += zBasPlr
	zSubPlr += zVlrPlr
	zLin += 15
Next rtv
oRtv:Say(zLin, 0460, Transform(zSubPag, PesqPict("SE1","E1_VALOR")),oFont10N)
oRtv:Say(zLin, 0545, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
oRtv:Say(zLin, 0710, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
zLin += 10
oRtv:Line(zLin, 0000, zLin, 0800)

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
	AAdd(aLista,{SA3->A3_COD, AllTrim(StrTran(SA3->A3_NOME,".","")), IIf(lRevenda, Space(80), Lower(AllTrim(SA3->A3_EMAIL))), zPdf+".pdf"})
Endif	

If lGrvLog
	U_LogPremi(SA3->A3_COD, StrTran(SA3->A3_NOME,".",""), cFilePrint, Lower(PadR(SA3->A3_EMAIL,80)), "", Lower(PadR(SA3->A3_EMAIL,80)), "P")
	If !Empty(mv_par09)
		U_LogPremi(SA3->A3_COD, StrTran(SA3->A3_NOME,".",""), cFilePrint, Lower(PadR(mv_par09,80)), "", Lower(PadR(mv_par09,80)), "C")
	Endif
	If !Empty(mv_par10)
		U_LogPremi(SA3->A3_COD, StrTran(SA3->A3_NOME,".",""), cFilePrint, Lower(PadR(mv_par10,80)), "", Lower(PadR(mv_par10,80)), "C")
	Endif
	If !Empty(mv_par11)
		U_LogPremi(SA3->A3_COD, StrTran(SA3->A3_NOME,".",""), cFilePrint, Lower(PadR(mv_par11,80)), "", Lower(PadR(mv_par11,80)), "C")
	Endif
	If !Empty(mv_par12)
		U_LogPremi(SA3->A3_COD, StrTran(SA3->A3_NOME,".",""), cFilePrint, Lower(PadR(mv_par12,80)), "", Lower(PadR(mv_par12,80)), "C")
	Endif
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ RtvCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  01/11/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function RtvCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp    := cStartPath + "logo_premiacao.bmp"
Local zPar01     := DtoS(mv_par01)
Local zPar02     := DtoS(mv_par02)

Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Local oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Local oFont72  := TFont():New("Arial",72,72,,.F.,,,,.T.,.F.)

oRtv:SayBitmap(0030, 0000, cLogoTp, 0210, 0060)

oRtv:Box(0090, 0000, 0110, 0200)
oRtv:Say(0104, 0080, SA3->A3_COD, oFont12)
oRtv:Box(0090, 0200, 0110, 0600)
oRtv:Say(0104, 0300, PadC(AllTrim(SA3->A3_NOME),50),oFont12)
oRtv:Box(0090, 0600, 0110, 0800)
oRtv:Say(0104, 0670, "R$ "+AllTrim(Transform(zTotal,"@E 9,999,999.99")),oFont14N)

If !lRevenda
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0050, 0327, "APURAÇÃO DE COMISSÃO",oFont16N)
	Else
		oRtv:Say(0050, 0350, "APURAÇÃO DE PLR",oFont16N)
	Endif
Else
	oRtv:Say(0050, 0327, "APURAÇÃO DE PREMIAÇÃO",oFont16N)
Endif

oRtv:Say(0070, 0300, "PERÍODO "+zPer,oFont16N)

oRtv:Say(0045, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
oRtv:Say(0059, 0660, "Fonte: Protheus "+MesExtenso(dDatabase)+" "+Year2Str(dDatabase),oFont12)
oRtv:Say(0073, 0660, "ADM..: "+Substr(zPar01,7,2)+Substr(zPar01,5,2)+Substr(zPar01,1,4)+Substr(zPar02,7,2)+Substr(zPar02,5,2)+Substr(zPar02,1,4),oFont12)
oRtv:Say(0087, 0660, IIf(!lRevenda,IIf(Substr(SA3->A3_COD,1,2)=="VC","Comis: ","PLR...: "),"Prem.: ")+IIf(nFilPag==1,"A Pagar",IIf(nFilPag==2,"Pagas","Pagas & A Pagar")) ,oFont12)
                                                                            
oRtv:Say(0125, 0000, "Cliente",oFont10N)
oRtv:Say(0140, 0000, "No.Acordo",oFont10N)

oRtv:Say(0125, 0120, "No.NF/Título",oFont10N)
oRtv:Say(0140, 0120, "Origem da venda",oFont10N)

oRtv:Say(0140, 0220, "Vencimento",oFont10N)
oRtv:Say(0140, 0280, "Pagamento",oFont10N)
oRtv:Say(0140, 0350, "Pedido",oFont10N)

oRtv:Say(0125, 0405, "Valor R$",oFont10N)
oRtv:Say(0140, 0405, "NF/Título",oFont10N)

oRtv:Say(0140, 0475, "Vlr.Pago R$",oFont10N)

If !lRevenda
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0140, 0555, "Base Com R$",oFont10N)
	Else
		oRtv:Say(0140, 0555, "Base PLR R$",oFont10N)
	Endif	
Else
	oRtv:Say(0125, 0553, "Base",oFont10N)
	oRtv:Say(0140, 0553, "Premiação R$",oFont10N)
Endif

If !lRevenda
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0140, 0642, "% Com",oFont10N)
	Else
		oRtv:Say(0140, 0642, "% PLR",oFont10N)
	Endif	
Else
	oRtv:Say(0125, 0645, "%",oFont10N)
	oRtv:Say(0140, 0645, "Prem.",oFont10N)
Endif

If !lRevenda
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0140, 0715, "Valor Com R$",oFont10N)
	Else
		oRtv:Say(0140, 0715, "Valor PLR R$",oFont10N)
	Endif	
Else
	oRtv:Say(0125, 0713, "Valor",oFont10N)
	oRtv:Say(0140, 0713, "Premiação R$",oFont10N)
Endif
	
oRtv:Line(0150, 0000, 0150, 0800)

If !lGrvLog
	oRtv:Say(0300, 0270, "PROJEÇÃO",oFont72,,CLR_HGRAY)
Endif

Return
