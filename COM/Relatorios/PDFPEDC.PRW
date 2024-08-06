#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PdfPedC   ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  03/08/18	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pedido de Compra modelo Pdf.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PdfPedC(aPedido)

Local oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local zPathPDF := AllTrim(mv_par05)+"\"
Local zValIcm  := 0
Local zValIpi  := 0
Local zValDes  := 0
Local zValDsp  := 0
Local zValSeg  := 0
Local zValFre  := 0
Local zValTot  := 0
Local zPrf     := ""
Local zPdf     := ""
Local zTotFol  := 1
Local pdc, _pdc
Private opdc

If Len(aPedido) == 0
	MsgAlert("Sem dados para geração do Pdf.")
	Return
Endif

DbSelectArea("SC7")
DbSetOrder(1)
DbSeek( aPedido[1][1] + aPedido[1][2] )

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )

zPrf := SC7->C7_FILIAL+"-"+SC7->C7_NUM
zPdf := zPrf+" "+AllTrim(SA2->A2_NOME)

zPdf := StrTran(zPdf,".","")
zPdf := StrTran(zPdf,",","")
zPdf := StrTran(zPdf,"-","")
zPdf := StrTran(zPdf,"_","")
zPdf := StrTran(zPdf,";","")
zPdf := StrTran(zPdf,"&","")
zPdf := StrTran(zPdf,"/","")
zPdf := StrTran(zPdf,"\","")
zPdf := StrTran(zPdf,"(","")
zPdf := StrTran(zPdf,")","")
zPdf := StrTran(zPdf,"{","")
zPdf := StrTran(zPdf,"}","")
zPdf := StrTran(zPdf,"[","")
zPdf := StrTran(zPdf,"]","")
zPdf := StrTran(zPdf,"º","")
zPdf := StrTran(zPdf,"@","")
zPdf := StrTran(zPdf,"%","")
zPdf := StrTran(zPdf,"$","")
zPdf := StrTran(zPdf,"#","")
zPdf := StrTran(zPdf,"!","")
zPdf := StrTran(zPdf,"?","")
zPdf := StrTran(zPdf,CHR(13),"")
zPdf := StrTran(zPdf,CHR(10),"")

// Paginas
xLin := 210
For _pdc := 1 to Len(aPedido)
	//
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( aPedido[_pdc][1] + aPedido[_pdc][2] + aPedido[_pdc][3] )
	//
	If xLin > 530
		xLin := 210
		zTotFol += 1
	Endif
	xLin += 15
	If !Empty(SC7->C7_OBS)
		xLin += 15
	Endif	
Next _pdc
xLin += 15
xLin += 10
xLin += 15
If xLin > 500
	zTotFol += 1
Endif

opdc:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@opdc,,,,, (mv_par06==1) )
opdc:SetResolution(72)
opdc:SetLandscape()
opdc:SetPaperSize(DMPAPER_A4)
opdc:SetMargin(60,60,60,60)
opdc:cPathPDF := zPathPDF

opdc:StartPage()
pdcCab(1,zTotFol,.T.)

zEntreg := CtoD("")
zFolha  := 1
zLin    := 210
For pdc := 1 to Len(aPedido)
	If zLin > 530
		opdc:Line(zLin, 0000, zLin, 0800)
		opdc:EndPage()
		opdc:StartPage()
		zFolha += 1
		pdcCab(zFolha,zTotFol,.T.)
		zLin := 210
	Endif
	//
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( aPedido[pdc][1] + aPedido[pdc][2] + aPedido[pdc][3] )
	//
	opdc:Say(zLin, 0000, SC7->C7_ITEM,oFont10,,IIf(GetMv("MV_IMPXML"),CLR_HBLUE,CLR_BLACK))
	opdc:Say(zLin, 0030, SC7->C7_PRODUTO,oFont10)
	opdc:Say(zLin, 0110, Transform(SC7->C7_QUANT, PesqPict("SC7","C7_QUANT")),oFont10)
	opdc:Say(zLin, 0190, SC7->C7_UM,oFont10)
	opdc:Say(zLin, 0240, SC7->C7_DESCRI,oFont10)
	opdc:Say(zLin, 0450, Transform(SC7->C7_PRECO, PesqPict("SC7","C7_PRECO")),oFont10)
	opdc:Say(zLin, 0550, Transform(SC7->C7_TOTAL, PesqPict("SC7","C7_TOTAL")),oFont10)
	opdc:Say(zLin, 0650, Transform(SC7->C7_VALIPI, PesqPict("SC7","C7_VALIPI")),oFont10)
	opdc:Say(zLin, 0750, DtoC(SC7->C7_DATPRF),oFont10)
	zLin += 15
	//
	If !Empty(SC7->C7_OBS)
		opdc:Say(zLin, 0240, Substr(SC7->C7_OBS,1,130),oFont08)
		zLin += 15
	Endif	
	//
	zValIcm += SC7->C7_VALICM
	zValIpi += SC7->C7_VALIPI
	zValDes += SC7->C7_VLDESC
	zValDsp += SC7->C7_DESPESA
	zValSeg += SC7->C7_SEGURO
	zValFre += SC7->C7_VALFRE
	zValTot += SC7->C7_TOTAL
	//
	If Empty(zEntreg) .Or. SC7->C7_DATPRF > zEntreg
		zEntreg := SC7->C7_DATPRF
	Endif
	//
Next pdc
opdc:Line(zLin, 0000, zLin, 0800)
zLin += 15
opdc:Say(zLin, 0000, "ICMS: "+AllTrim(Transform(zValIcm, PesqPict("SC7","C7_VALICM"))),oFont10N)
opdc:Say(zLin, 0120, "IPI: "+AllTrim(Transform(zValIpi, PesqPict("SC7","C7_VALIPI"))),oFont10N)
opdc:Say(zLin, 0240, "Desconto: "+AllTrim(Transform(zValDes, PesqPict("SC7","C7_VLDESC"))),oFont10N)
opdc:Say(zLin, 0360, "Despesas: "+AllTrim(Transform(zValDsp, PesqPict("SC7","C7_DESPESA"))),oFont10N)
opdc:Say(zLin, 0480, "Seguro: "+AllTrim(Transform(zValSeg, PesqPict("SC7","C7_SEGURO"))),oFont10N)
opdc:Say(zLin, 0600, "Frete: "+AllTrim(Transform(zValFre, PesqPict("SC7","C7_VALFRE"))),oFont10N)
opdc:Say(zLin, 0720, "Valor Total: "+AllTrim(Transform(((zValTot+zValIpi+zValDsp+zValSeg+zValFre)-zValDes), PesqPict("SC7","C7_TOTAL"))),oFont10N)
zLin += 10
opdc:Line(zLin, 0000, zLin, 0800)
zLin += 15

If zLin > 500
	opdc:EndPage()
	opdc:StartPage()
	zFolha += 1
	pdcCab(zFolha,zTotFol,.F.)
	zLin := 185
Endif

nMoeda  := IIf(SC7->C7_MOEDA > 1, SC7->C7_MOEDA, 1)
zMoedPc := AllTrim(GetMv("MV_MOEDA"+AllTrim(STR(nMoeda))))
zTaxaPc := IIf(SC7->C7_MOEDA > 1, SC7->C7_TXMOEDA, 1)
zEndEnt := AllTrim(SM0->M0_ENDENT)+" "+AllTrim(SM0->M0_BAIRENT)+" - "+AllTrim(SM0->M0_CIDENT)+"/"+AllTrim(SM0->M0_ESTENT)+" - CEP: "+Transform(SM0->M0_CEPENT,"@R 99999-999")+" - Telefone: "+AllTrim(Transform(SM0->M0_TEL,"@R (999) 9999-9999"))
zEndCob := "Av. Presidente Kennedy, 1386 - 9º.andar - sala 93 - Cidade Nova I – Indaiatuba/SP – Cep: 13334-170 - Telefone: (019) 2516-8700"
zEndCob := Upper(zEndCob)

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek( xFilial("SE4") + SC7->C7_COND )

opdc:Say(zLin, 0000, "Valores expressos em: "+zMoedPc + Space(30) + "Tx.Conversão: "+Transform(zTaxaPc,"@E 9.9999") + Space(30) + "Prazo programado p/ entrega: "+DtoC(zEntreg) + Space(30) + "Cond.Pagamento: "+AllTrim(SE4->E4_DESCRI),oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Endereço de entrega: "+zEndEnt,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Endereço de cobrança: "+zEndCob,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "IMPORTANTE: o faturamento do produto ou serviço objeto desta ordem de compra só poderá ser efetuado após reconfirmarão formal do comprador.",oFont10N)
zLin += 15
opdc:Say(zLin, 0000, "Situação do Pedido: "+IIf(SC7->C7_CONAPRO=="L","APROVADO","EM APROVAÇÃO"),oFont10N)
If GetMv("MV_IMPXML")
	zLin += 15
	opdc:Say(zLin, 0000, "Sr.Fornecedor, favor informar as tags do XML <xPed> e <nItemPed>, conforme comunicado enviado.",oFont10N,,CLR_HBLUE)
Endif
zLin += 10
opdc:Line(zLin, 0000, zLin, 0800)

opdc:EndPage()

cFilePrint := zPathPDF+zPdf+".pdf"
If mv_par06 == 1
	opdc:Preview()
Else
	File2Printer( cFilePrint, "PDF" )
	opdc:Preview()
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ pdcCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦  03/08/18	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pdcCab(zFolha,zTotFol,lCabDet)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp    := cStartPath + "logo_premiacao.bmp"

Local oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)

opdc:SayBitmap(0030, 0000, cLogoTp, 0210, 0060)

opdc:Say(0060, 0325, "PEDIDO DE COMPRA:",oFont16N)
opdc:Say(0060, 0465, SC7->C7_NUM,oFont16N,,IIf(GetMv("MV_IMPXML"),CLR_HBLUE,CLR_BLACK))

opdc:Say(0045, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
opdc:Say(0060, 0660, "Emissão: "+DtoC(SC7->C7_EMISSAO),oFont12)
opdc:Say(0075, 0660, "Fonte: Protheus "+MesExtenso(SC7->C7_EMISSAO)+" "+Year2Str(SC7->C7_EMISSAO),oFont12)

opdc:Box(0090, 0000, 0170, 0800)
opdc:Line(0090, 0400, 0170, 0400)

opdc:Say(0100, 0010, "Solicitante",oFont08N)
opdc:Say(0115, 0010, SM0->M0_NOMECOM,oFont10)
opdc:Say(0130, 0010, "CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  -  I.E: "+SM0->M0_INSC,oFont10)
opdc:Say(0145, 0010, AllTrim(SM0->M0_ENDCOB)+" "+AllTrim(SM0->M0_BAIRCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+"/"+AllTrim(SM0->M0_ESTCOB)+" - CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999"),oFont10)
opdc:Say(0160, 0010, "TEL.: "+Transform(SM0->M0_TEL,"@R (999) 9999-9999"),oFont10)

opdc:Say(0100, 0405, "Fornecedor",oFont08N)
opdc:Say(0115, 0405, SA2->A2_COD+" - "+SA2->A2_NOME,oFont10)
opdc:Say(0115, 0660, "CNPJ: "+Transform(SA2->A2_CGC,"@R 99.999.999/9999-99"),oFont10)
opdc:Say(0130, 0405, SA2->A2_END,oFont10)
opdc:Say(0130, 0660, "IE: "+Transform(SA2->A2_INSCR,"@R 999.999.999"),oFont10)
opdc:Say(0145, 0405, AllTrim(SA2->A2_BAIRRO)+" - "+AllTrim(SA2->A2_MUN)+"/"+AllTrim(SA2->A2_EST)+" - CEP: "+Transform(SA2->A2_CEP,"@R 99999-999"),oFont10)
opdc:Say(0160, 0405, "TEL.: "+SA2->A2_TEL,oFont10)

If lCabDet
	opdc:Say(0185, 0000, "Item",oFont10N)
	opdc:Say(0185, 0030, "Código",oFont10N)
	opdc:Say(0185, 0140, "Qtde",oFont10N)
	opdc:Say(0185, 0190, "Unidade",oFont10N)
	opdc:Say(0180, 0240, "Descrição",oFont10N)
	opdc:Say(0192, 0240, "Observações",oFont10N)
	opdc:Say(0185, 0480, "Vl.Unit.",oFont10N)
	opdc:Say(0185, 0565, "Vl.Total",oFont10N)
	opdc:Say(0185, 0665, "Vl.IPI",oFont10N)
	opdc:Say(0185, 0750, "Dt.Entrega",oFont10N)
	opdc:Line(0195, 0000, 0195, 0800)
Endif

Return
