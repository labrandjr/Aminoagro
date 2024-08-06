#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PDFREV  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  01/11/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Extrato de Premiação - Modelo Revenda.			 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDFREV(aDados,zTotal,lRevenda,aLista,zPer,aNccDet,nCrdNcc,lGrvLog,nFilPag)

Local oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Local oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
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
xLin += 25

If Len(aNccDet) > 0
	zCliAnt := ""
	lCliOk  := .F.
	For rtv := 1 to Len(aNccDet)
		If xLin > 545 .And. zCliAnt == aNccDet[rtv][2]
			zTotFol += 1
			xLin := 165
			If zCliAnt == aNccDet[rtv][2]
				xLin += 15
			Endif	
		Endif
		If zCliAnt != aNccDet[rtv][2]
			If lCliOk
				xLin += 25
				If xLin > 545
					zTotFol += 1
					xLin := 165
				Endif
			Else
				lCliOk := .T.
			Endif
			zCliAnt := aNccDet[rtv][2]
			xLin += 15
		Endif
		xLin += 15
	Next rtv
	xLin += 50
Endif
If !lGrvLog
	If xLin >= 545
		zTotFol += 1
	Endif
Endif

oRtv:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@oRtv,,,,, (mv_par07==1) )
oRtv:SetResolution(72)
oRtv:SetLandscape()
oRtv:SetPaperSize(DMPAPER_A4)
oRtv:SetMargin(60,60,60,60)
oRtv:cPathPDF := zPathPDF    

oRtv:StartPage()
RevCab(1,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)

zCliAnt := ""
lCliOk  := .F.
zFolha  := 1
zLin    := 165
zSubPag := 0
zSubBas := 0
zSubPlr := 0
zSubOri := 0
zSubDes := 0
zSubMet := 0
For rtv := 1 to Len(aDados)
	If zLin > 545 .And. zCliAnt == aDados[rtv][1]
		oRtv:EndPage()
		oRtv:StartPage()
		zFolha += 1
		RevCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)
		zLin := 165
		If zCliAnt == aDados[rtv][1]
			oRtv:Say(zLin, 0000, zNomCli,oFont10N)
			zLin += 15
		Endif	
	Endif
	zNomCli := aDados[rtv][2]
	zTitulo := AllTrim(aDados[rtv][3])+"-"+AllTrim(aDados[rtv][4])+"-"+AllTrim(aDados[rtv][19])
	zVencto := aDados[rtv][5]
	zVencto := Day2Str(zVencto)+"/"+Month2Str(zVencto)+"/"+Year2Str(zVencto)
	zPagmto := aDados[rtv][6]
	zPagmto := Day2Str(zPagmto)+"/"+Month2Str(zPagmto)+"/"+Year2Str(zPagmto)
	zPedido := aDados[rtv][7]
	zVlrTit := aDados[rtv][8]
	zBasPlr := aDados[rtv][9]
	zPerPlr := aDados[rtv][10]
	zVlrPlr := aDados[rtv][11]
	zPlrOri := aDados[rtv][12]
	zAtraso := aDados[rtv][13]
	zDesAtr := aDados[rtv][14]
	zVlrAtr := aDados[rtv][15]
	zAcordo := aDados[rtv][18]
	zVlrPag := aDados[rtv][20]
	zEmiTit := aDados[rtv][21]
	zEmiTit := Day2Str(zEmiTit)+"/"+Month2Str(zEmiTit)+"/"+Year2Str(zEmiTit)
	zDesMet := aDados[rtv][22]

	If zCliAnt != aDados[rtv][1]
		If lCliOk
			If !lRevenda
				oRtv:Say(zLin, 0380, Transform(zSubPag, PesqPict("SE1","E1_VALOR")),oFont10N)
				oRtv:Say(zLin, 0435, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
				oRtv:Say(zLin, 0525, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
				oRtv:Say(zLin, 0585, Transform(zSubOri, PesqPict("SE1","E1_VALOR")),oFont08N)
				oRtv:Say(zLin, 0705, Transform(zSubDes, PesqPict("SE1","E1_VALOR")),oFont08N)
				oRtv:Say(zLin, 0745, Transform(zSubMet, PesqPict("SE1","E1_VALOR")),oFont08N)
			Else
				oRtv:Say(zLin, 0380, Transform(zSubPag, PesqPict("SE1","E1_VALOR")),oFont10N)
				oRtv:Say(zLin, 0435, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
				oRtv:Say(zLin, 0540, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
				oRtv:Say(zLin, 0600, Transform(zSubOri, PesqPict("SE1","E1_VALOR")),oFont08N)
				oRtv:Say(zLin, 0745, Transform(zSubDes, PesqPict("SE1","E1_VALOR")),oFont08N)
			Endif	
			zSubPag := 0
			zSubBas := 0
			zSubPlr := 0
			zSubOri := 0
			zSubDes := 0
			zSubMet := 0
			zLin += 10
			oRtv:Line(zLin, 0000, zLin, 0800)
			zLin += 15
			//
			If zLin > 545
				oRtv:EndPage()
				oRtv:StartPage()
				zFolha += 1
				RevCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)
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
	oRtv:Say(zLin, 0090, zTitulo,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0160, zEmiTit,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0210, zVencto,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0260, zPagmto,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0310, zPedido,oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))

	oRtv:Say(zLin, 0330, Transform(zVlrTit, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0380, Transform(zVlrPag, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))

	oRtv:Say(zLin, 0435, Transform(zBasPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	oRtv:Say(zLin, 0510, Transform(zPerPlr, "@E 999.99"),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	
	If !lRevenda
		oRtv:Say(zLin, 0525, Transform(zVlrPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0585, Transform(zPlrOri, PesqPict("SE1","E1_VALOR")),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0655, IIf(zAtraso > 0,AllTrim(STR(zAtraso))+IIf(zAtraso==1," dia"," dias"),"     --"),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0695, Transform(zDesAtr, "@E 999.99"),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0705, Transform(zVlrAtr, PesqPict("SE1","E1_VALOR")),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0745, Transform(zDesMet, PesqPict("SE1","E1_VALOR")),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	Else
		oRtv:Say(zLin, 0540, Transform(zVlrPlr, PesqPict("SE1","E1_VALOR")),oFont10,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0600, Transform(zPlrOri, PesqPict("SE1","E1_VALOR")),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0670, IIf(zAtraso > 0,AllTrim(STR(zAtraso))+IIf(zAtraso==1," dia"," dias"),"     --"),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0715, Transform(zDesAtr, "@E 999.99"),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
		oRtv:Say(zLin, 0745, Transform(zVlrAtr, PesqPict("SE1","E1_VALOR")),oFont08,,IIf(zBasPlr<0,CLR_HRED,CLR_BLACK))
	Endif
	zSubPag += zVlrPag
	zSubBas += zBasPlr
	zSubPlr += zVlrPlr
	zSubOri += zPlrOri
	zSubDes += zVlrAtr
	zSubMet += zDesMet
	zLin += 15
Next rtv
If !lRevenda
	oRtv:Say(zLin, 0380, Transform(zSubPag, PesqPict("SE1","E1_VALOR")),oFont10N)
	oRtv:Say(zLin, 0435, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
	oRtv:Say(zLin, 0525, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
	oRtv:Say(zLin, 0585, Transform(zSubOri, PesqPict("SE1","E1_VALOR")),oFont08N)
	oRtv:Say(zLin, 0705, Transform(zSubDes, PesqPict("SE1","E1_VALOR")),oFont08N)
	oRtv:Say(zLin, 0745, Transform(zSubMet, PesqPict("SE1","E1_VALOR")),oFont08N)
Else
	oRtv:Say(zLin, 0380, Transform(zSubPag, PesqPict("SE1","E1_VALOR")),oFont10N)
	oRtv:Say(zLin, 0435, Transform(zSubBas, PesqPict("SE1","E1_VALOR")),oFont10N)
	oRtv:Say(zLin, 0540, Transform(zSubPlr, PesqPict("SE1","E1_VALOR")),oFont10N)
	oRtv:Say(zLin, 0600, Transform(zSubOri, PesqPict("SE1","E1_VALOR")),oFont08N)
	oRtv:Say(zLin, 0745, Transform(zSubDes, PesqPict("SE1","E1_VALOR")),oFont08N)
Endif
zLin += 10
oRtv:Line(zLin, 0000, zLin, 0800)
zLin += 15

If Len(aNccDet) > 0
	// Detalhe NCC´s
	zCliAnt := ""
	lCliOk  := .F.
	zSubDes := 0
	zSubMet := 0
	For rtv := 1 to Len(aNccDet)
		If zLin > 545 .And. zCliAnt == aNccDet[rtv][2]
			oRtv:EndPage()
			oRtv:StartPage()
			zFolha += 1
			RevCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)
			zLin := 165
			If zCliAnt == aNccDet[rtv][2]
				oRtv:Say(zLin, 0000, zNomCli,oFont10N)
				zLin += 15
			Endif	
		Endif
		zNomCli := aNccDet[rtv][3]
		zNumNcc := AllTrim(aNccDet[rtv][5])+"-"+AllTrim(aNccDet[rtv][6])
		zTitulo := AllTrim(aNccDet[rtv][7])+"-"+AllTrim(aNccDet[rtv][9])+"-"+AllTrim(aNccDet[rtv][10])
		zEmiTit := aNccDet[rtv][11]
		zEmiTit := Day2Str(zEmiTit)+"/"+Month2Str(zEmiTit)+"/"+Year2Str(zEmiTit)
		zVencto := aNccDet[rtv][12]
		zVencto := Day2Str(zVencto)+"/"+Month2Str(zVencto)+"/"+Year2Str(zVencto)
		zPagmto := aNccDet[rtv][13]
		zPagmto := Day2Str(zPagmto)+"/"+Month2Str(zPagmto)+"/"+Year2Str(zPagmto)
		zPedido := aNccDet[rtv][14]
		zVlrTit := aNccDet[rtv][15]
		zVlrPag := aNccDet[rtv][16]
		zBasPlr := aNccDet[rtv][17]
		zPerPlr := aNccDet[rtv][18]
		zVlrPlr := aNccDet[rtv][19]
		zPlrOri := aNccDet[rtv][20]
		zVlrAtr := aNccDet[rtv][21]
		zDesMet := aNccDet[rtv][22]

		If zCliAnt != aNccDet[rtv][2]
			If lCliOk
				oRtv:Say(zLin, 0705, Transform(zSubDes, PesqPict("SE1","E1_VALOR")),oFont08N,,CLR_BLACK)
				oRtv:Say(zLin, 0745, Transform(zSubMet, PesqPict("SE1","E1_VALOR")),oFont08N,,CLR_BLACK)
				zSubDes := 0
				zSubMet := 0
				zLin += 10
				oRtv:Line(zLin, 0000, zLin, 0800)
				zLin += 15
				//
				If zLin > 545
					oRtv:EndPage()
					oRtv:StartPage()
					zFolha += 1
					RevCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)
					zLin := 165
				Endif
			Else
				lCliOk := .T.
			Endif
			zCliAnt := aNccDet[rtv][2]
			oRtv:Say(zLin, 0000, zNomCli+" (NCC)",oFont10N,,CLR_HRED)
			zLin += 15
		Endif
		oRtv:Say(zLin, 0000, "NCC-"+zNumNcc,oFont10,,CLR_HRED)
		oRtv:Say(zLin, 0090, zTitulo,oFont10,,CLR_BLACK)
		oRtv:Say(zLin, 0160, zEmiTit,oFont10,,CLR_BLACK)
		oRtv:Say(zLin, 0210, zVencto,oFont10,,CLR_BLACK)
		oRtv:Say(zLin, 0260, zPagmto,oFont10,,CLR_BLACK)
		oRtv:Say(zLin, 0310, zPedido,oFont10,,CLR_BLACK)

		oRtv:Say(zLin, 0330, Transform(zVlrTit, PesqPict("SE1","E1_VALOR")),oFont10,,CLR_BLACK)
		oRtv:Say(zLin, 0380, Transform(zVlrPag, PesqPict("SE1","E1_VALOR")),oFont10,,CLR_BLACK)

		oRtv:Say(zLin, 0435, Transform(zBasPlr, PesqPict("SE1","E1_VALOR")),oFont10,,CLR_BLACK)
		oRtv:Say(zLin, 0510, Transform(zPerPlr, "@E 999.99"),oFont10,,CLR_BLACK)
		
		oRtv:Say(zLin, 0525, Transform(zVlrPlr, PesqPict("SE1","E1_VALOR")),oFont10,,CLR_BLACK)
		oRtv:Say(zLin, 0585, Transform(zPlrOri, PesqPict("SE1","E1_VALOR")),oFont08,,CLR_BLACK)
		oRtv:Say(zLin, 0705, Transform(zVlrAtr, PesqPict("SE1","E1_VALOR")),oFont08,,CLR_BLACK)
		oRtv:Say(zLin, 0745, Transform(zDesMet, PesqPict("SE1","E1_VALOR")),oFont08,,CLR_BLACK)
		zSubDes += zVlrAtr
		zSubMet += zDesMet
		zLin += 15
	Next rtv
	oRtv:Say(zLin, 0705, Transform(zSubDes, PesqPict("SE1","E1_VALOR")),oFont08N,,CLR_BLACK)
	oRtv:Say(zLin, 0745, Transform(zSubMet, PesqPict("SE1","E1_VALOR")),oFont08N,,CLR_BLACK)
	zLin += 10
	oRtv:Line(zLin, 0000, zLin, 0800)
	zLin += 15
	oRtv:Say(zLin, 0000, "Devolução s/ Descontos Total:",oFont10N,,CLR_HBLUE)
	oRtv:Say(zLin, 0745, Transform(nCrdNcc, PesqPict("SE1","E1_VALOR")),oFont10N,,CLR_HBLUE)
	zLin += 10
	oRtv:Line(zLin, 0000, zLin, 0800)
	zLin += 15
Endif

If !lGrvLog
	If xLin >= 545
		oRtv:EndPage()
		oRtv:StartPage()
		zFolha += 1
		RevCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)
		zLin := 165
	Endif
	oRtv:Say(zLin, 0000,"O presente extrato aqui apresentado possui caráter meramente indicativo, e deve ser utilizado pelo colaborador apenas para fins informativos e indicativos, sendo que, os valores poderão sofrer alterações",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"em virtude das premissas estabelecidas no Acordo Coletivo de Trabalho - Programa de Participação nos Resultados vigente, que dispõe como critério de elegibilidade o atingimento mínimo de 70% (setenta por cento)",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"da meta anual estabelecida, bem como o recebimento dos títulos dentro do prazo máximo de 360 (trezentos sessenta) dias a contar do vencimento origem. As informações não constituem qualquer tipo de direito líquido",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"e certo em relação ao valor a ser recebido pelo colaborador, não devendo ser utilizadas com este propósito. O valor efetivo ao qual o colaborador terá direito ao recebimento serão confirmados nos períodos oficiais",oFont10,,CLR_GRAY)
	zLin += 10
	oRtv:Say(zLin, 0000,"de apuração nos meses de janeiro e julho, momento em que receberá seu extrato definitivo com os respectivos valores.",oFont10,,CLR_GRAY)
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
	AAdd(aLista,{SA3->A3_COD, AllTrim(StrTran(SA3->A3_NOME,".","")), IIf(lRevenda, Space(80), Lower(AllTrim(SA3->A3_EMAIL))), zPdf+".pdf"})
Endif

If lGrvLog
	U_LogPremi(SA3->A3_COD, StrTran(SA3->A3_NOME,".",""), cFilePrint, Space(80), "", Space(80), "P")
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
¦¦¦Funcao    ¦ RevCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  01/11/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function RevCab(zFolha,zTotFol,zPer,zTotal,lRevenda,lGrvLog,nFilPag)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp	 := cStartPath + "logo_premiacao.bmp"
Local zPar01     := DtoS(mv_par01)
Local zPar02     := DtoS(mv_par02)
Local oFont08  := TFont():New("Courier new",08,08,,.F.,,,,.T.,.F.)
Local oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Local oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Local oFont72  := TFont():New("Arial",72,72,,.F.,,,,.T.,.F.)
Local _x

oRtv:SayBitmap(0030, 0000, cLogoTp, 0210, 0060)

oRtv:Box(0090, 0000, 0110, 0200)
oRtv:Say(0104, 0080, SA3->A3_COD,oFont12)
oRtv:Box(0090, 0200, 0110, 0600)
If !lRevenda
	cMsgInic := "Últimas Metas Apuradas:"
	cMsgAdic := ""
	cMsgMeta := ""
	aApurMet := {}
	DbSelectArea("SZS")
	DbSetOrder(1)
	If DbSeek( xFilial("SZS") + SA3->A3_COD )
		While !Eof() .And. SZS->(ZS_FILIAL+ZS_VEND) == xFilial("SZS") + SA3->A3_COD
			AAdd(aApurMet,{SZS->ZS_ANO, SZS->ZS_PERC})
			SZS->(DbSkip())
		Enddo
		aSort( aApurMet,,, { |x,y| x[1] > y[1] } ) // Ano da apuração em ordem decrescente
		nCnt := 0
		For _x := 1 to Len(aApurMet)
			nCnt += 1
			If nCnt > 4 // Exibe somente as últimas 4 metas apuradas, em ordem decrescente
				Exit
			Endif
			cMsgAdic += IIf(!Empty(cMsgAdic),"  |","") + "  "+aApurMet[_x][1]+" - "+AllTrim(STR(aApurMet[_x][2]))+"%"
		Next _x
		cMsgMeta := cMsgInic + cMsgAdic
		oRtv:Box(0075, 0200, 0090, 0600)
		oRtv:Say(0085, 0220, PadC(cMsgMeta,080),oFont08)
	Endif
Endif	

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

oRtv:Say(0125, 0090, "No.NF/Título",oFont10N)
oRtv:Say(0140, 0090, "Origem da venda",oFont10N)

oRtv:Say(0140, 0160, "Emissão",oFont10N)
oRtv:Say(0140, 0210, "Vencimento",oFont10N)
oRtv:Say(0140, 0260, "Pagamento",oFont10N)
oRtv:Say(0140, 0310, "Pedido",oFont10N)

If !lRevenda
	oRtv:Say(0125, 0355, "Valor R$",oFont10N)
	oRtv:Say(0140, 0355, "NF/Título",oFont10N)
Else
	oRtv:Say(0125, 0360, "Valor R$",oFont10N)
	oRtv:Say(0140, 0360, "NF/Título",oFont10N)
Endif

If !lRevenda
	oRtv:Say(0125, 0405, "Valor",oFont10N)
	oRtv:Say(0140, 0405, "Pago R$",oFont10N)
Else
	oRtv:Say(0125, 0400, "Valor",oFont10N)
	oRtv:Say(0140, 0400, "Pago R$",oFont10N)
Endif

If !lRevenda
	oRtv:Say(0125, 0460, "Base",oFont10N)
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0140, 0460, "Com R$",oFont10N)
	Else
		oRtv:Say(0140, 0460, "PLR R$",oFont10N)
	Endif	
Else
	oRtv:Say(0125, 0442, "Base",oFont10N)
	oRtv:Say(0140, 0442, "Premiação R$",oFont10N)
Endif

If !lRevenda
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0140, 0503, "% Com",oFont10N)
	Else
		oRtv:Say(0140, 0503, "% PLR",oFont10N)
	Endif	
Else
	oRtv:Say(0125, 0506, "%",oFont10N)
	oRtv:Say(0140, 0506, "Prem.",oFont10N)
Endif

If !lRevenda
	oRtv:Say(0125, 0550, "Valor",oFont10N)
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0140, 0550, "Com R$",oFont10N)
	Else
		oRtv:Say(0140, 0550, "PLR R$",oFont10N)
	Endif	
Else
	oRtv:Say(0125, 0546, "Valor",oFont10N)
	oRtv:Say(0140, 0546, "Premiação R$",oFont10N)
Endif

If !lRevenda
	If Substr(SA3->A3_COD,1,2)=="VC"
		oRtv:Say(0125, 0600, "Comissão",oFont08N)
	Else
		oRtv:Say(0125, 0600, "PLR",oFont08N)
	Endif	
	oRtv:Say(0140, 0600, "Origem R$",oFont08N)
Else
	oRtv:Say(0125, 0615, "Premiação",oFont08N)
	oRtv:Say(0140, 0615, "Origem R$",oFont08N)
Endif

If !lRevenda
	oRtv:Say(0140, 0655, "Atraso",oFont08N)
	oRtv:Say(0140, 0690, "% Desc.",oFont08N)

	oRtv:Say(0125, 0730, "Desc.",oFont08N)
	oRtv:Say(0140, 0730, "Atraso",oFont08N)

	oRtv:Say(0125, 0770, "Desc.",oFont08N)
	oRtv:Say(0140, 0770, "Meta",oFont08N)
Else
	oRtv:Say(0140, 0670, "Atraso",oFont08N)
	oRtv:Say(0140, 0710, "% Desc.",oFont08N)

	oRtv:Say(0125, 0770, "Desc.",oFont08N)
	oRtv:Say(0140, 0770, "Atraso",oFont08N)
Endif

oRtv:Line(0150, 0000, 0150, 0800)

If !lGrvLog
	oRtv:Say(0300, 0270, "PROJEÇÃO",oFont72,,CLR_HGRAY)
Endif

Return
