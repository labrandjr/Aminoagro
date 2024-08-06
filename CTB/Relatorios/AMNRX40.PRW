#Include "PROTHEUS.Ch"
#Include "CTBR140.Ch"

#DEFINE TAM_VALOR	20
#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CLVL   			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_SALDO_ANT     	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_VLR_DEBITO    	8
#DEFINE 	COL_SEPARA5			9 
#DEFINE 	COL_VLR_CREDITO   	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_MOVIMENTO 		12
#DEFINE 	COL_SEPARA7			13                                                                                       
#DEFINE 	COL_SALDO_ATU 		14
#DEFINE 	COL_SEPARA8			15

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNRX40  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 21/04/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Balancente Conta Contabil x Classe de Valor.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNRX40()

Local aArea := GetArea()
Local oReport          

Local lOk := .T.
Local aCtbMoeda		:= {}
Local nDivide		:= 1

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "AMRX40"
PRIVATE nomeProg  	:= "AMNRX40"  
PRIVATE oTRF1
PRIVATE oTRF2
PRIVATE oTRF3
PRIVATE oTRF4
PRIVATE oTRF5
PRIVATE oTRF6
PRIVATE nTotMov	:= 0
PRIVATE nTotdbt	:= 0
PRIVATE nTotcrt	:= 0
PRIVATE titulo
PRIVATE nTotAnt	:= 0
PRIVATE nTotAtu	:= 0
PRIVATE aSelFil	:= {}

If TRepInUse()
	
	Pergunte(cPerg,.T.) // Precisa ativar as perguntas antes das definicoes.

	If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
		lOk := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
	//³ Gerencial -> montagem especifica para impressao)			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ct040Valid(mv_par08) // Set Of Books
		lOk := .F.
	EndIf 

	If mv_par24 == 2			// Divide por cem
		nDivide := 100
	ElseIf mv_par24 == 3		// Divide por mil
		nDivide := 1000
	ElseIf mv_par24 == 4		// Divide por milhao
		nDivide := 1000000
	EndIf	

	If lOk .And. mv_par28 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			lOk := .F.
		EndIf 
	EndIf     

	If lOk
		aCtbMoeda  	:= CtbMoeda(mv_par10) // Moeda?
	   If Empty(aCtbMoeda[1])
	      Help(" ",1,"NOMOEDA")
	      lOk := .F.
	   Endif
	Endif 
	
	If lOk
		oReport := ReportDef(aCtbMoeda,nDivide)
		oReport:PrintDialog()
	EndIf
Else
	CTBR140R3() // Executa versão anterior do fonte
Endif

//Limpa os arquivos temporários 
CTBGerClean()
	
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Cicero J. Silva    º Data ³  01/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCtbMoeda  - Matriz ref. a moeda                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef(aCtbMoeda,nDivide)

Local oReport
Local oSection1
Local oSection2 
Local oBreak

Local cSayCLVL		:= CtbSayApro("CTH")

LOCAL cDesc1 		:= OemToAnsi(STR0001)+ Upper(cSayCLVL)	//"Este programa ira imprimir o Balancete de Conta / "
LOCAL cDesc2 		:= OemToansi(STR0002)  //"de acordo com os parametros solicitados pelo Usuario"

Local aTamCLVL  	:= TAMSX3("CTH_CLVL")
Local aTamItRes 	:= TAMSX3("CTH_RES")    
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCtaRes	:= TAMSX3("CT1_RES")
                                            
Local nTamCLVL		:= Len(CriaVar("CTH->CTH_DESC"+mv_par10))
Local nTamCta 		:= Len(CriaVar("CT1->CT1_DESC"+mv_par10))

Local lSaltaPag		:= Iif(mv_par20==1,.T.,.F.)
Local lPula			:= Iif(mv_par21==1,.T.,.F.)
Local lCLVLNormal	:= Iif(mv_par23==1,.T.,.F.)
Local lContaNormal	:= Iif(mv_par25==1,.T.,.F.)
Local lPrintZero	:= Iif(mv_par22==1,.T.,.F.)

Local cSegAte 	   	:= mv_par13 // Imprimir ate o Segmento?
Local cSegmento		:= mv_par14
Local cSegIni		:= mv_par15
Local cSegFim		:= mv_par16
Local cFiltSegm		:= mv_par17
Local nDigitAte		:= 0
Local nPos			:= 0
Local nDigitos		:= 0
Local lImpMov		:= IIF(mv_par18 == 1,.T.,.F.) // Imprime movimento ?

Local cSepara1		:= ""
Local cSepara2		:= ""
Local aSetOfBook := CTBSetOf(mv_par08)	
	
Local cMascara1		:= IIF (Empty(aSetOfBook[7]),"",RetMasCtb(aSetOfBook[7],@cSepara1))//Mascara do Centro de Custo
Local cMascara2		:= IIF (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara2))//Mascara da Conta

Local cPicture 		:= aSetOfBook[4]
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par10)
Local cDescMoeda 	:= aCtbMoeda[2]

Local bCdCLVL	:= {|| EntidadeCTB(cArqTmp->CLVL,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.) }
Local bCdCLRES	:= {|| EntidadeCTB(cArqTmp->CLVLRES,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.) }

Local bCdCONTA	:= {|| EntidadeCTB(cArqTmp->CONTA,0,0,25 ,.F.,cMascara2,cSepara2,,,,,.F.)}
Local bCdCTRES	:= {|| EntidadeCTB(cArqTmp->CTARES,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.)}

Local bNormal 	:= {|| Posicione("CTH",1,xFilial("CTH")+cArqTmp->CLVL,"CTH_NORMAL") }
Local cNormal	:= ''

titulo	:= STR0003+ Upper(cSayCLVL) 	//"Balancete de Verificacao Conta / "


oReport := TReport():New(nomeProg,titulo,cPerg,{|oReport| ReportPrint(oReport,aSetOfBook,cDescMoeda,cSayCLVL,nDivide)},cDesc1+cDesc2)
oReport:SetLandScape(.T.)

// Sessao 1
oSection1 := TRSection():New(oReport,STR0023+" x "+cSayCLVL ,{"cArqTmp","CT1"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/) //"Conta"
oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)

//Somente sera impresso centro de custo analitico	
TRCell():New(oSection1,"CONTA"		,"cArqTmp",STR0024	,/*Picture*/,aTamConta[1]	,/*lPixel*/, bCdCONTA )// Codigo da Conta //"Código"
TRCell():New(oSection1,"CTARES"		,"cArqTmp",STR0025	,/*Picture*/,aTamCtaRes[1]	,/*lPixel*/, bCdCTRES )// Codigo Reduzido da Conta //"Cód. reduzido"
TRCell():New(oSection1,"DESCCTA"	,"cArqTmp",STR0026	,/*Picture*/,nTamCta		,/*lPixel*/,/*{|| }*/ )// Descricao da Conta //"Descrição"

TRPosition():New( oSection1, "CT1", 1, {|| xFilial("CT1") + cArqTMP->CONTA })

If lContaNormal
	oSection1:Cell("CTARES"):Disable()
Else
	oSection1:Cell("CONTA" ):Disable() 
EndIf

If lSaltaPag
	oSection1:SetPageBreak(.T.)
EndIf

oSection1:SetLineCondition({|| IIF(cArqTmp->TIPOCONTA == "1",.F.,.T.) })

// Sessao 2
oSection2 := TRSection():New(oSection1,cSayCLVL,{"cArqTmp","CTH"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage()

TRCell():New(oSection2,"CLVL"		,"cArqTmp"	,"Código"  	  		,/*Picture*/,aTamCLVL[1]+5	,/*lPixel*/, bCdCLVL  )// Codigo do CLVL          
TRCell():New(oSection2,"CLVLRES"	,"cArqTmp"	,STR0025   	  		,/*Picture*/,aTamItRes[1]	,/*lPixel*/, bCdCLRES )// Codigo Reduzido do CLVL //"Cód. reduzido"
TRCell():New(oSection2,"DESCCLVL"	,"cArqTmp"	,STR0027   	   		,/*Picture*/,nTamCLVL		,/*lPixel*/,/*{|| }*/) //"Descricao"
TRCell():New(oSection2,"SALDOANT"	,"cArqTmp"	,STR0028   	   		,/*Picture*/,TAM_VALOR+2	,/*lPixel*/,{|| ValorCTB(cArqTmp->SALDOANT ,,,TAM_VALOR,nDecimais,.T.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.)}		, /*"RIGHT"*/,,"RIGHT",,,.F.)// Saldo Anterior //"Saldo anterior"
TRCell():New(oSection2,"SALDODEB"	,"cArqTmp"	,STR0029   			,/*Picture*/,TAM_VALOR		,/*lPixel*/,{|| ValorCTB(cArqTmp->SALDODEB ,,,TAM_VALOR,nDecimais,.F.,cPicture,,,,,,,lPrintZero,.F.)}					, /*"RIGHT"*/,,"RIGHT",,,.F.)// Debito //"Débito"
TRCell():New(oSection2,"SALDOCRD"	,"cArqTmp"	,STR0030	   		,/*Picture*/,TAM_VALOR		,/*lPixel*/,{|| ValorCTB(cArqTmp->SALDOCRD ,,,TAM_VALOR,nDecimais,.F.,cPicture,,,,,,,lPrintZero,.F.)}					, /*"RIGHT"*/,,"RIGHT",,,.F.)// Credito //"Crédito"

If lImpMov //Imprime Coluna Movimento!!
	TRCell():New(oSection2,"MOVIMENTO","cArqTmp",STR0031  			,/*Picture*/,TAM_VALOR+2		,/*lPixel*/,{|| ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR,nDecimais,.T.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.)}		, /*"RIGHT"*/,,"RIGHT",,,.F.)// Movimento do Periodo //"Movimento do periodo"
EndIf

TRCell():New(oSection2,	"SALDOATU"	,"cArqTmp"	,STR0032			,/*Picture*/,TAM_VALOR+2		, /*lPixel*/,{|| ValorCTB(cArqTmp->SALDOATU ,,,TAM_VALOR,nDecimais,.T.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.)}		, /*"RIGHT"*/,,"RIGHT",,,.F.)// Saldo Atual //"Saldo atual"

TRCell():New(oSection2,"TIPOCLVL"	,"cArqTmp"	,STR0033+cSayCLVL	,/*Picture*/,01		   		,/*lPixel*/,/*{|| }*/)// Centro Custo / Sintetica            //"Tipo "
TRCell():New(oSection2,"TIPOCONTA"	,"cArqTmp"	,STR0033+STR0023	,/*Picture*/,01		   		,/*lPixel*/,/*{|| }*/)// Conta Analitica / Sintetica            //"Tipo "###"Conta"
TRCell():New(oSection2,"NIVEL1"		,"cArqTmp"	,STR0034			,/*Picture*/,01		   		,/*lPixel*/,/*{|| }*/)// Logico para identificar se  //"Nivel 1"	

oSection2:Cell("TIPOCLVL"):Disable()
oSection2:Cell("TIPOCONTA"	):Disable()
oSection2:Cell("NIVEL1"  	):Disable()

oSection2:Cell("SALDOANT"):lHeaderSize	:= .F.
oSection2:Cell("SALDODEB"):lHeaderSize	:= .F.
oSection2:Cell("SALDOCRD"):lHeaderSize	:= .F.

If lImpMov //Imprime Coluna Movimento!!
	oSection2:Cell("MOVIMENTO"):lHeaderSize	:= .F.
Endif

oSection2:Cell("SALDOATU"):lHeaderSize	:= .F.  

TRPosition():New( oSection2, "CTH", 1, {|| xFilial("CTH") + cArqTMP->CLVL })

If lCLVLNormal
	oSection2:Cell("CLVLRES"	):Disable()
Else
	oSection2:Cell("CLVL"	):Disable() 
EndIf

oSection2:OnPrintLine( {|| ( IIf( lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCLVL == "1" .And. cTipoAnt == "2")), oReport:SkipLine(),NIL),;
								 cTipoAnt := cArqTmp->TIPOCLVL,cNormal:=cArqTmp->NORMAL, conout(cArqTmp->NORMAL);
							)  })

oSection2:SetLineCondition({|| f140Fil(cSegAte,cSegmento,nDigitAte,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,cMascara1) })

// Totais das sessoes
oBreak:= TRBreak():New(oSection2,{ || cArqTmp->CONTA },STR0020,.F.)
oBreak:OnBreak({ || nTotAnt := oTRF1:GetValue(),nTotdbt := oTRF2:GetValue(),nTotcrt := oTRF3:GetValue(),nTotAtu :=oTRF4:GetValue()})

oTRF1 := TRFunction():New(oSection2:Cell("SALDOANT"),nil,"SUM",oBreak,/*Titulo*/,/*cPicture*/,{ || f140Soma("A",cSegAte) },.F.,.F.,.F.,oSection2)
oTRF2 := TRFunction():New(oSection2:Cell("SALDODEB"),nil,"SUM",oBreak,/*Titulo*/,/*cPicture*/,{ || f140Soma("D",cSegAte) },.F.,.F.,.F.,oSection2)
oTRF3 := TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"SUM",oBreak,/*Titulo*/,/*cPicture*/,{ || f140Soma("C",cSegAte) },.F.,.F.,.F.,oSection2)
oTRF4 := TRFunction():New(oSection2:Cell("SALDOATU"),nil,"SUM",oBreak,/*Titulo*/,/*cPicture*/,{ || f140Soma("T",cSegAte) },.F.,.F.,.F.,oSection2)

oTRF1:disable()
oTRF2:disable()
oTRF3:disable()
oTRF4:disable()

TRFunction():New(oSection2:Cell("SALDOANT"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ValorCTB(nTotAnt,,,TAM_VALOR,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)
TRFunction():New(oSection2:Cell("SALDODEB"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ValorCTB(nTotdbt,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)
TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ValorCTB(nTotcrt,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)
If lImpMov
	TRFunction():New(oSection2:Cell("MOVIMENTO"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ValorCTB(nTotcrt - nTotdbt,,,TAM_VALOR,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.)},.F.,.F.,.F.,oSection2)
EndIf  
TRFunction():New(oSection2:Cell("SALDOATU"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ValorCTB(nTotAtu,,,TAM_VALOR,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)
oTRF5 := TRFunction():New(oSection2:Cell("SALDODEB"),nil,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || f140Soma("D",cSegAte) },.F.,.F.,.F.,oSection2)
oTRF6 := TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || f140Soma("C",cSegAte) },.F.,.F.,.F.,oSection2)
oTRF5:disable()
oTRF6:disable()
TRFunction():New(oSection2:Cell("SALDODEB"),nil,"ONPRINT",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || ValorCTB(oTRF5:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.T.,.F.,oSection2)
TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"ONPRINT",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || ValorCTB(oTRF6:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },.F.,.T.,.F.,oSection2)
    	
Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintº Autor ³ Cicero J. Silva    º Data ³  14/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportPrint(oReport,aSetOfBook,cDescMoeda,cSayCLVL,nDivide)

Local oSection1 	:= oReport:Section(1)
Local oSection2	:= oReport:Section(1):Section(1)

Local cArqTmp		:= ""
Local cFiltro	:= oSection1:GetAdvplExp('CT1')

Local dDataLP		:= mv_par27
Local dDataFim		:= mv_par02
Local cMascCLVL		:= IIF (Empty(aSetOfBook[7]),"",aSetOfBook[7])//Mascara do Centro de Custo
Local cMascCta		:= IIF (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),aSetOfBook[2])//Mascara da Conta
Local lImpSint		:= Iif(mv_par07==1 .Or. mv_par07 ==3,.T.,.F.)
Local lVlrZerado	:= Iif(mv_par09==1,.T.,.F.)
Local lImpMov		:= Iif(mv_par18==1,.T.,.F.)
Local lPrintZero	:= Iif(mv_par22==1,.T.,.F.)
Local lImpAntLP		:= Iif(mv_par26==1,.T.,.F.)
Local cSegmento		:= mv_par14
Local nDigitAte		:= 0
Local nPos			:= 0
Local nDigitos		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega titulo do relatorio: Analitico / Sintetico			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF mv_par07 == 1
	Titulo:=	OemToAnsi(STR0006) + Upper(cSayCLVL)	//"BALANCETE ANALITICO DE CONTA / "
ElseIf mv_par07 == 2
	Titulo:=	OemToAnsi(STR0007) + Upper(cSayCLVL)	//"BALANCETE SINTETICO DE CONTA / "
ElseIf mv_par07 == 3
	Titulo:=	OemToAnsi(STR0008) + Upper(cSayCLVL)	//"BALANCETE DE CONTA / "
EndIf

Titulo += 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) + Dtoc(mv_par02) + ;
				OemToAnsi(STR0011) + cDescMoeda
	
If mv_par12 > "1"
	Titulo += " (" + Tabela("SL", mv_par12, .F.) + ")"
EndIf

If nDivide > 1			
	Titulo += " (" + OemToAnsi(STR0022) + Alltrim(Str(nDivide)) + ")"
EndIf	

oReport:SetPageNumber(mv_par11) //mv_par14	-	Pagina Inicial
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
			 mv_par01, mv_par02, "CTI", "", mv_par03, mv_par04,,,,,mv_par05, mv_par06, mv_par10,;
		      mv_par12, aSetOfBook, mv_par14, mv_par15, mv_par16, mv_par17, !lImpMov, .T.,, "CT1",;
			   lImpAntLP,dDataLP, nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,cFiltro,,,,,,,,,,,,aSelFil)},;
				OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor rio..."
				 OemToAnsi(STR0003)+cSayCLVL)     //"Balancete Verificacao Conta /"
/*
01-oMeter      = Controle da regua                                  
02-oText       = Controle da regua                                  
03-oDlg        = Janela                                             
04-lEnd        = Controle da regua -> finalizar                     
05-cArqTmp     = Arquivo temporario                                 
06-dDataIni    = Data Inicial de Processamento                      
07-dDataFim    = Data Final de Processamento                        
08-cAlias      = Alias do Arquivo                                   
09-cIdent      = Identificador do arquivo a ser processado          
10-cContaIni   = Conta Inicial                                      
11-cContaFim   = Conta Final                                        
12-cCCIni      = Centro de Custo Inicial                            
13-cCCFim      = Centro de Custo Final                             
14-cItemIni    = Item Inicial                                       
15-cItemFim    = Item Final                                         
16-cClvlIni    = Classe de Valor Inicial                            
17-cClvlFim    = Classe de Valor Final                             
18-cMoeda      = Moeda                                                
19-cSaldos     = Tipos de Saldo a serem processados                 
20-aSetOfBook  = Matriz de configuracao de livros                   
21-cSegmento   = Indica qual o segmento sera filtrado               
22-cSegIni     = Conteudo Inicial do segmento                      
23-cSegFim     = Conteudo Final do segmento                         
24-cFiltSegm   = Filtra por Segmento                                   
25-lNImpMov    = Se Imprime Entidade sem movimento                  
26-lImpConta   = Se Imprime Conta                                   
27-nGrupo      = Grupo                                              
28-cHeader     = Identifica qual a Entidade Principal               
29-lImpAntLP   = Se imprime lancamentos Lucros e Perdas             
30-dDataLP     = Data da ultima Apuracao de Lucros e Perdas        
31-nDivide     = Divide valores por (100,1000,1000000)              
32-lVlrZerado  = Grava ou nao valores zerados no arq temporario     
33-cFiltroEnt  = Entidade Gerencial que servira de filtro dentro    
                 de outra Entidade Gerencial. Ex.: Centro de Custo 
                 sendo filtrado por Item Contabil (CTH)             
34-cCodFilEnt  = Codigo da Entidade Gerencial utilizada como filtro 
35-cSegmentoG  = Filtra por Segmento Gerencial (CC/Item ou ClVl)    
36-cSegIniG    = Segmento Gerencial Inicial                         
37-cSegFimG    = Segmento Gerencial Final                           
38-cFiltSegmG  = Segmento Gerencial Contido em                      
39-lUsGaap     = Se e Balancete de Conversao de moeda               
40-cMoedConv   = Moeda para a qual buscara o criterio de conversao 
                 no Pl.Contas                                       
41-cConsCrit   = Criterio de conversao utilizado: 1-Diario, 2-Medio,
                 3-Mensal, 4-Informada, 5-Plano de Contas           
42-dDataConv   = Data de Conversao                                  
43-nTaxaConv   = Taxa de Conversao                                  
44-aGeren      = Matriz que armazena os compositores do Pl. Ger.    
                 para efetuar o filtro de relatorio.               
45-lImpMov     = Nao utilizado                                      
46-lImpSint    = Se atualiza sinteticas                             
47-cFilUSU     = Filtro informado pelo usuario                      
48-lRecDesp0   = Se imprime saldo anterior do periodo anterior      
                 zerado                                             
49-cRecDesp    = Grupo de receitas e despesas                      
50-dDtZeraRD   = Data de zeramento de receitas e despesas           
51-lImp3Ent    = Se e Balancete C.Custo / Conta / Item              
52-lImp4Ent    = Se e Balancete por CC x Cta x Item x Cl.Valor      
53-lImpEntGer  = Se e Balancete de Entidade (C.Custo/Item/Cl.Vlr    
                 por Entid. Gerencial)                             
54-lFiltraCC   = Se considera o filtro das perguntas para C.Custo   
55-lFiltraIt   = Se considera o filtro das perguntas para Item      
56-lFiltraCV   = Se considera o filtro das perguntas para Cl.Valor 
57-cMoedaDsc   = Codigo da moeda para descricao das entidades       
58-lMovPeriodo = Se imprime movimento do periodo anterior   
*/

If !Empty(cSegmento)
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascCLVL)  
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascCLVL
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)      
				Exit
			EndIf	
			dbSkip()
		EndDo	
	EndIf	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a impressao do relatorio                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("cArqTmp")
dbSetOrder(1)	
dbGotop()
//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If !( RecCount() == 0 .And. !Empty(aSetOfBook[5]) )
	
	oSection2:SetParentFilter( { |cParam| cArqTmp->CONTA == cParam },{ || cArqTmp->CONTA })// SERVE PARA IMPRIMIR O TITULO DA SECAO PAI

	oSection1:Print()
	
EndIf
	
dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
//	Ferase(cArqTmp+GetDBExtension())
//	FErase("cArqInd"+OrdBagExt())
EndIf	
dbselectArea("CT2")


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f140Soma  ºAutor  ³Cicero J. Silva     º Data ³  24/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR140                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function f140Soma(cTipo,cSegAte)

Local nRetValor		:= 0

If mv_par07 != 1					// Imprime Analiticas ou Ambas
	If cArqTmp->TIPOCLVL == "2"
		If cArqTmp->TIPOCONTA== "2"
			If cTipo == "D"
				nRetValor := cArqTmp->SALDODEB
			ElseIf cTipo == "C"
				nRetValor := cArqTmp->SALDOCRD
			ElseIf cTipo == "A"
				nRetValor := cArqTmp->SALDOANT
			ElseIf cTipo == "T"
				nRetValor := cArqTmp->SALDOATU
			EndIf
		EndIf
		If cTipo == "D"
			nRetValor := cArqTmp->SALDODEB
		ElseIf cTipo == "C"
			nRetValor := cArqTmp->SALDOCRD
		ElseIf cTipo == "A"
			nRetValor := cArqTmp->SALDOANT
		ElseIf cTipo == "T"
			nRetValor := cArqTmp->SALDOATU
		EndIf
	Endif
Else
	If cArqTmp->TIPOCLVL == "1" .And. cArqTmp->NIVEL1
		If cTipo == "D"
			nRetValor := cArqTmp->SALDODEB
		ElseIf cTipo == "C"
			nRetValor := cArqTmp->SALDOCRD
		ElseIf cTipo == "A"
			nRetValor := cArqTmp->SALDOANT
		ElseIf cTipo == "T"
			nRetValor := cArqTmp->SALDOATU
		EndIf
	Endif
	If cArqTmp->TIPOCLVL == "1" .And. Empty(cArqTmp->ITSUP)
		If cTipo == "D"
			nRetValor := cArqTmp->SALDODEB
		ElseIf cTipo == "C"
			nRetValor := cArqTmp->SALDOCRD
		ElseIf cTipo == "A"
			nRetValor := cArqTmp->SALDOANT
		ElseIf cTipo == "T"
			nRetValor := cArqTmp->SALDOATU
		EndIf
	Endif
Endif

Return nRetValor                                                                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f140Fil   ºAutor  ³Cicero J. Silva     º Data ³  24/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR140                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function f140Fil(cSegAte,cSegmento,nDigitAte,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,cMascara1)

Local lDeixa	:= .T.
Local nCont    := 0

	If mv_par07 == 1					// So imprime Sinteticas
		If cArqTmp->TIPOCLVL == "2"
			lDeixa := .F.
		EndIf
	ElseIf mv_par07 == 2				// So imprime Analiticas
		If cArqTmp->TIPOCLVL == "1"
			lDeixa := .F.
		EndIf
	EndIf

	// Verifica Se existe filtragem Ate o Segmento
	If !Empty(cSegAte)
		nDigitAte := CtbRelDig( cSegAte, cMascara1 )
	EndIf		

	//Filtragem ate o Segmento do centro de custo(antigo nivel do SIGACON)		
	If !Empty(cSegAte)
		If Len(Alltrim(cArqTmp->CLVL)) > nDigitAte
			lDeixa := .F.
		Endif
	EndIf

dbSelectArea("cArqTmp")

Return (lDeixa)

/*
------------------------------------------------------- RELESE 4 ---------------------------------------------------------------
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr140	³ Autor ³ Simone Mie Sato   	³ Data ³ 24.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Conta/CLVL.                   			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctbr140()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ SIGACTB      											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctbr140R3()

Local aSetOfBook
Local aCtbMoeda		:= {}
Local cSayCLVL		:= CtbSayApro("CTH")
LOCAL cDesc1 		:= OemToAnsi(STR0001)+ Upper(cSayCLVL)	//"Este programa ira imprimir o Balancete de Conta / "
LOCAL cDesc2 		:= OemToansi(STR0002)  //"de acordo com os parametros solicitados pelo Usuario"

LOCAL wnrel
LOCAL cString		:= "CT1"
Local titulo 		:= OemToAnsi(STR0003)+ Upper(cSayCLVL)  	//"Balancete de Verificacao Conta / "
Local lRet			:= .T.
Local nDivide		:= 1

PRIVATE nLastKey 	:= 0
PRIVATE cPerg	 	:= "AMNX40"
PRIVATE aReturn 	:= { OemToAnsi(STR0015), 1,OemToAnsi(STR0016), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha		:= {}
PRIVATE nomeProg  	:= "AMNRX40"
PRIVATE Tamanho		:="M"

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

li 		:= 80
m_pag	:= 1

Pergunte("AMRX40",.T.) 

If mv_par28 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf 
EndIf     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  	   	³
//³ mv_par01				// Data Inicial              	       	³
//³ mv_par02				// Data Final                          	³
//³ mv_par03				// Conta Inicial                       	³
//³ mv_par04				// Conta Final  					   	³
//³ mv_par05				// Item Inicial                        	³
//³ mv_par06				// Item Final   					   	³
//³ mv_par07				// Imprime Itens:  Sintet/Analit/Ambas	³
//³ mv_par08				// Set Of Books				    	   	³
//³ mv_par09				// Saldos Zerados?			     	   	³
//³ mv_par10				// Moeda?          			     	   	³
//³ mv_par11				// Pagina Inicial  		     		   	³
//³ mv_par12				// Saldos? Reais / Orcados	/Gerenciais	³
//³ mv_par13				// Imprimir ate o Segmento?			  	³
//³ mv_par14				// Filtra Segmento?					   	³
//³ mv_par15				// Conteudo Inicial Segmento?		   	³
//³ mv_par16				// Conteudo Final Segmento?		       	³
//³ mv_par17				// Conteudo Contido em?				   	³
//³ mv_par18				// Imprime Movimento do Mes            	³
//³ mv_par19				// Imprime Totalizacao de Contas Sontet.³
//³ mv_par20				// Pula Pagina                         	³

//³ mv_par21				// Salta linha sintetica ?			    ³
//³ mv_par22				// Imprime valor 0.00    ?			    ³
//³ mv_par23				// Imprimir Codigo? Normal / Reduzido  	³
//³ mv_par24				// Divide por ?                   		³
                                                                     
//³ mv_par25				// Imprime Cod. Conta ? Normal/Reduzido ³
//³ mv_par26				// Posicao Ant. L/P? Sim / Nao         	³
//³ mv_par27 				// Data Lucros/Perdas?                	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := "CTBR140"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,,.F.,"",,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par08)
	lRet := .F.
Else
   aSetOfBook := CTBSetOf(mv_par08)
Endif

If mv_par24 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par24 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par24 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par10)
	If Empty(aCtbMoeda[1])                       
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif

If !lRet
	Set Filter To
	Return
EndIf

If mv_par19 == 1			// Se imprime coluna movimento -> relatorio 220 colunas
	tamanho := "G"
EndIf

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR140Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda,cSayCLVL,nDivide)})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTR140IMP ³ Autor ³ Simone Mie Sato       ³ Data ³ 24.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relatorio -> Balancete Conta/CLVL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr140Imp(lEnd,Wnrel,cString,aSetOfBook,aCtbMoeda,cSayCLVL) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigactb                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd       - A‡ao do Codeblock                             ³±±
±±³          ³ wnRel      - Nome do Relatorio                             ³±±
±±³          ³ cString    - Mensagem                                      ³±±
±±³          ³ aSetOfBook - Array de configuracao set of book             ³±±
±±³          ³ aCtbMoeda  - Moeda                                         ³±±
±±³          ³ cSayCLVL   - Descricao do CLVL utilizada pelo usuario.     ³±±
±±³          ³ nDivide    - Fator de divisao de valores                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CTR140Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda,cSayCLVL,nDivide)

LOCAL CbTxt			:= Space(10)
Local CbCont		:= 0
LOCAL tamanho		:= "M"
LOCAL limite		:= 132
Local cabec1  		:= ""
Local cabec2		:= ""

Local aColunas

Local cSepara1		:= ""
Local cSepara2		:= ""
Local cPicture
Local cDescMoeda
Local cMascara1
Local cMascara2
Local cContaAnt 	:= ""
Local cCtaAntRes	:= ""
Local cSegAte   	:= mv_par13
Local cArqTmp		:= ""
Local cSegmento		:= mv_par14
Local cSegIni		:= mv_par15
Local cSegFim		:= mv_par16
Local cFiltSegm		:= mv_par17
Local cMascCta		:= ""
Local cMascCLVL		:= ""

Local dDataLP		:= mv_par27
Local dDataFim		:= mv_par02

Local lFirstPage	:= .T.
Local lPula			:= Iif(mv_par21==1,.T.,.F.)
Local lJaPulou		:= .F.
Local l132			:= .T.
Local lImpAntLP		:= Iif(mv_par26==1,.T.,.F.)
Local lVlrZerado	:= Iif(mv_par09==1,.T.,.F.)
Local lPrintZero	:= Iif(mv_par22==1,.T.,.F.)
Local lCLVLNormal	:= Iif(mv_par23==1,.T.,.F.)
Local lContaNormal	:= Iif(mv_par25==1,.T.,.F.)
Local lSaltaPag		:= Iif(mv_par20==1,.T.,.F.)
Local lImpMov		:= Iif(mv_par18==1,.T.,.F.)
Local lImpSint		:= Iif(mv_par07=1 .Or. mv_par07 ==3,.T.,.F.)

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0

Local nTamCta		:= Len(CriaVar("CT1_CONTA"))
Local nTotCtDeb		:= 0
Local nTotCtCrd		:= 0
Local nTotAnt		:= 0
Local nTotAtu		:= 0

Local nDigitAte		:= 0

Local nPos			:= 0
Local nDigitos		:= 0
Local nCont			:= 0

Local cItNormal	:= ''
Local cCoNormal	:= ''

cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par10)


// Mascara do CLVL Contabil
If Empty(aSetOfBook[7])
	cMascara1 := ""
Else                                                
	cMascCLVL := aSetOfBook[7]
	cMascara1 := RetMasCtb(aSetOfBook[7],@cSepara1)
EndIf

//Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara2 := GetMv("MV_MASCARA")
Else
	cMascCta	:= aSetOfBook[2]
	cMascara2 	:= RetMasCtb(aSetOfBook[2],@cSepara2)
EndIf             


cPicture 		:= aSetOfBook[4]

If mv_par18 == 1 // Se imprime saldo movimento do periodo
	cabec1 := OemToAnsi(STR0004)  //"|  CODIGO              |   D  E  S  C  R  I  C  A  O    |   SALDO ANTERIOR  |    DEBITO     |    CREDITO   | MOVIMENTO DO PERIODO |   SALDO ATUAL    |"
	tamanho := "G"
	limite	:= 220        
	l132	:= .F.
Else	
	cabec1 := OemToAnsi(STR0005)  //"|  CODIGO               |   D  E  S  C  R  I  C  A  O    |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ATUAL     |"
Endif
SetDefault(aReturn,cString,,,Tamanho,If(Tamanho="G",2,1))	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega titulo do relatorio: Analitico / Sintetico			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF mv_par07 == 1
	Titulo:=	OemToAnsi(STR0006) + Upper(cSayCLVL)	//"BALANCETE ANALITICO DE CONTA / "
ElseIf mv_par07 == 2
	Titulo:=	OemToAnsi(STR0007) + Upper(cSayCLVL)	//"BALANCETE SINTETICO DE CONTA / "
ElseIf mv_par07 == 3
	Titulo:=	OemToAnsi(STR0008) + Upper(cSayCLVL)	//"BALANCETE DE CONTA / "
EndIf

Titulo += 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) + Dtoc(mv_par02) + ;
				OemToAnsi(STR0011) + cDescMoeda

If mv_par12 > "1"
	Titulo += " (" + Tabela("SL", mv_par12, .F.) + ")"
EndIf

If nDivide > 1			
	Titulo += " (" + OemToAnsi(STR0022) + Alltrim(Str(nDivide)) + ")"
EndIf	

If l132
	aColunas :={ 000,001, 024, 025, 057,058, 077, 078, 094, 095, 111, , , 112, 131 }
	
Else
	aColunas := { 000,001, 030, 032, 080,082, 112, 114, 131, 133, 151, 153, 183,185,219}
Endif

m_pag := mv_par11
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CTI","",mv_par03,mv_par04,,,,,mv_par05,mv_par06,mv_par10,;
				mv_par12,aSetOfBook,mv_par14,mv_par15,mv_par16,mv_par17, l132,.T.,,"CT1",;
				lImpAntLP,dDataLP, nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,aReturn[7],,,,,,,,,,,,aSelFil)},;
				OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor rio..."
				OemToAnsi(STR0003)+cSayCLVL)     //"Balancete Verificacao Conta /"

// Verifica Se existe filtragem Ate o Segmento
If !Empty(cSegAte)
	For nCont := 1 to Val(cSegAte)
		nDigitAte += Val(Subs(cMascara1,nCont,1))	
	Next
EndIf		

dbSelectArea("cArqTmp")
dbSetOrder(1)
dbGoTop()        

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If RecCount() == 0 .And. !Empty(aSetOfBook[5])                                       
	dbCloseArea()
	Ferase(cArqTmp+GetDBExtension())
	Ferase("cArqInd"+OrdBagExt())
	Return
Endif

SetRegua(RecCount())

If !Empty(cSegmento)
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascCLVL)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascCLVL
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)      
				Exit
			EndIf	
			dbSkip()
		EndDo	
	EndIf	
EndIf	

dbSelectArea("cArqTmp")

While !Eof()

	If lEnd
		@Prow()+1,0 PSAY OemToAnsi(STR0017)   //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF

	IncRegua()

	******************** "FILTRAGEM" PARA IMPRESSAO *************************

	If mv_par07 == 1					// So imprime Itens Sinteticos
		If TIPOCLVL == "2"
			dbSkip()
			Loop
		EndIf
	ElseIf mv_par07 == 2				// So imprime Itens Analiticos
		If TIPOCLVL == "1"
			dbSkip()
			Loop
		EndIf
	EndIf
	
	If !Empty(cSegmento)
		If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
			If  !(Substr(cArqTmp->CLVL,nPos,nDigitos) $ (Alltrim(cFiltSegm)) ) 
				dbSkip()
				Loop
			EndIf	
		Else
			If Substr(cArqTmp->CLVL,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
				Substr(cArqTmp->CLVL,nPos,nDigitos) > Alltrim(cSegFim)
				dbSkip()
				Loop
			EndIf	
		Endif
	EndIf	
	
	//Filtragem ate o Segmento do CLVL( antigo nivel do SIGACON)		
	If !Empty(cSegAte)
		If Len(Alltrim(CLVL)) > nDigitAte
			dbSkip()
			Loop
		Endif
	EndIf

	************************* ROTINA DE IMPRESSAO *************************
		
	cContaAnt	:= cArqTmp->CONTA
	cCtaAntRes 	:= cArqTmp->CTARES

	If li > 58 .Or. lFirstPage .Or. lSaltaPag
		If !lFirstPage
			@Prow()+1,00 PSAY	Replicate("-",limite)
		EndIf
		CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
		lFirstPage := .F.
	EndIf	
	
	@ li,000 PSAY REPLICATE("-",limite)
	li++
	@ li,000 PSAY "|"                                
	@ li,001 PSAY Upper(STR0021) + " : "
	If lContaNormal .or. TIPOCONTA == "1"
		EntidadeCTB(CONTA,li,17,nTamCta+Len(cSepara2),.F.,cMascara2,cSepara2)					
	Else
		EntidadeCTB(CTARES,li,17,nTamCta+Len(cSepara2),.F.,cMascara2,cSepara2)		
	Endif			
	@ li,aColunas[COL_CLVL]+ Len(CriaVar("CT1_DESC01")) PSAY " - " +cArqTMP->DESCCTA
	@ li,131 PSAY "|"		                                        
	li++
	@ li,000 PSAY REPLICATE("-",limite)		
	li+=1		                                                    			
   
	While !Eof() .And. cContaAnt == cArqTmp->CONTA
	
		If mv_par07 == 1					// So imprime Itens Sinteticos
			If TIPOCLVL == "2"
				dbSkip()
				Loop
			EndIf
		ElseIf mv_par07 == 2				// So imprime Itens Analiticos
			If TIPOCLVL == "1"
				dbSkip()
				Loop
			EndIf
		EndIf	
		
		//Filtragem ate o Segmento do CLVL( antigo nivel do SIGACON)		
		If !Empty(cSegAte)
			If Len(Alltrim(CLVL)) > nDigitAte
				dbSkip()
				Loop
			Endif
		EndIf		
		
		If !Empty(cSegmento)
			If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
				If  !(Substr(cArqTmp->CLVL,nPos,nDigitos) $ (Alltrim(cFiltSegm)) ) 
					dbSkip()
					Loop
				EndIf	
			Else
				If Substr(cArqTmp->CLVL,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
					Substr(cArqTmp->CLVL,nPos,nDigitos) > Alltrim(cSegFim)
					dbSkip()
					Loop
				EndIf	
			Endif
		EndIf			

		//***********************************
		// Busca natureza do CLVL Contabil  *
		cItNormal := Posicione("CTH",1,xFilial("CTH")+cArqTmp->CLVL,"CTH_NORMAL")

		@ li,aColunas[COL_SEPARA1] PSAY "|"
		If lCLVLNormal .or. TIPOCLVL == "1"
			EntidadeCTB(CLVL,li,aColunas[COL_CLVL],20,.F.,cMascara1,cSepara1)
		Else	
			EntidadeCTB(CLVLRES,li,aColunas[COL_CLVL],20,.F.,cMascara1,cSepara1)
		EndIf	
		
		@ li,aColunas[COL_SEPARA2] PSAY "|"
		@ li,aColunas[COL_DESCRICAO] PSAY Substr(DESCCLVL,1,Iif(!l132,40,31))
		@ li,aColunas[COL_SEPARA3] PSAY "|"
		ValorCTB(SALDOANT,li,aColunas[COL_SALDO_ANT],16,nDecimais,.T.,cPicture,NORMAL, , , , , ,lPrintZero)
		@ li,aColunas[COL_SEPARA4] PSAY "|"
		ValorCTB(SALDODEB,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,NORMAL, , , , , ,lPrintZero)
		@ li,aColunas[COL_SEPARA5] PSAY "|"
		ValorCTB(SALDOCRD,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,NORMAL, , , , , ,lPrintZero)
		@ li,aColunas[COL_SEPARA6] PSAY "|"
		If !l132
			ValorCTB(MOVIMENTO,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,cItNormal, , , , , ,lPrintZero)
			@ li,aColunas[COL_SEPARA7] PSAY "|"	
		Endif
		ValorCTB(SALDOATU,li,aColunas[COL_SALDO_ATU],17,nDecimais,.T.,cPicture,cItNormal, , , , , ,lPrintZero)
		@ li,aColunas[COL_SEPARA8] PSAY "|"
		
		lJaPulou := .F.
		If lPula .And. TIPOCLVL == "1"				// Pula linha entre sinteticas
			li++
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_SEPARA2] PSAY "|"
			@ li,aColunas[COL_SEPARA3] PSAY "|"	
			@ li,aColunas[COL_SEPARA4] PSAY "|"
			@ li,aColunas[COL_SEPARA5] PSAY "|"
			@ li,aColunas[COL_SEPARA6] PSAY "|"
			If !l132  
				@ li,aColunas[COL_SEPARA7] PSAY "|"
				@ li,aColunas[COL_SEPARA8] PSAY "|"
			Else
				@ li,aColunas[COL_SEPARA8] PSAY "|"
			EndIf	
			li++
			lJaPulou := .T.
		Else
			li++
		EndIf			

		// Soma dos totalizadores
		If mv_par07 != 1					// Imprime Analiticas ou Ambas
			If TIPOCLVL == "2"
				If TIPOCONTA== "2"
					nTotDeb 		+= SALDODEB 
					nTotCrd    		+= SALDOCRD
				EndIf	
				nTotCtDeb 		+= SALDODEB
				nTotCtCrd 		+= SALDOCRD				
				nTotAnt 		+= SALDOANT
				nTotAtu 		+= SALDOATU								
				cCoNormal		:= NORMAL // natureza da Conta utilizada no totalizador
			Endif
		Else
			If TIPOCLVL == "1" .And. NIVEL1
				nTotDeb += SALDODEB
				nTotCrd += SALDOCRD
			Endif
			If TIPOCLVL == "1" .And. Empty(ITSUP)
				nTotCtDeb 	+= SALDODEB
				nTotCtCrd 	+= SALDOCRD  
				nTotAnt		+= SALDOANT
				nTotAtu 	+= SALDOATU								
								
			Endif
		Endif	
		
		dbSkip()  
		
		If lPula .And. TIPOCLVL == "1" 			// Pula linha entre sinteticas
			If !lJaPulou
				@ li,aColunas[COL_SEPARA1] PSAY "|"
				@ li,aColunas[COL_SEPARA2] PSAY "|"
				@ li,aColunas[COL_SEPARA3] PSAY "|"	
				@ li,aColunas[COL_SEPARA4] PSAY "|"
				@ li,aColunas[COL_SEPARA5] PSAY "|"
				@ li,aColunas[COL_SEPARA6] PSAY "|"
				If !l132  
					@ li,aColunas[COL_SEPARA7] PSAY "|"
					@ li,aColunas[COL_SEPARA8] PSAY "|"
				Else
					@ li,aColunas[COL_SEPARA8] PSAY "|"
				EndIf	
				li++
			EndIf	
		EndIf
		
		If li > 58 
			If !lFirstPage
				@Prow()+1,00 PSAY	Replicate("-",limite)
			EndIf		
			CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
			lFirstPage := .F.
		EndIf	
		
    EndDo
    
	// Impressao do Totalizador da Conta
	@li,00 PSAY	Replicate("-",limite)
	li++
	@li,0 PSAY "|"          			
	@li,01 PSAY STR0020//"T O T A I S  D A  C O N T A:  "
	If lContaNormal .or. TIPOCONTA == "1"		// Codigo Normal da Conta ou sintetica
		EntidadeCTB(cContaAnt,li,30,nTamCta+Len(cSepara2),.F.,cMascara2,cSepara2)		
	Else
		EntidadeCTB(cCtaAntRes,li,30,nTamCta+Len(cSepara2),.F.,cMascara2,cSepara2)
	EndIf   
	
 	@ li,aColunas[COL_SEPARA3] PSAY "|"
 	ValorCTB(nTotAnt,li,aColunas[COL_SALDO_ANT],16,nDecimais,.T.,cPicture,cCoNormal, , , , , ,lPrintZero)
	@ li,aColunas[COL_SEPARA4] PSAY "|"
	ValorCTB(nTotCtDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
	@ li,aColunas[COL_SEPARA5] PSAY "|"
	ValorCTB(nTotCtCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)			
	@ li,aColunas[COL_SEPARA6] PSAY "|"

	nTotMov := (nTotCtCrd - nTotCtDeb)

	If !l132
		ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,cCoNormal, , , , , ,lPrintZero)
		@ li,aColunas[COL_SEPARA7] PSAY "|"	
	Endif
	
	ValorCTB(nTotAtu,li,aColunas[COL_SALDO_ATU],17,nDecimais,.T.,cPicture,cCoNormal, , , , , ,lPrintZero)
	
	@ li,aColunas[COL_SEPARA8] PSAY "|"
	nTotCtDeb := 0
	nTotCtCrd := 0                     
	nTotAnt		:= 0
	nTotAtu		:= 0
	li++
	
	If li > 58  	
		If !lFirstPage
			@Prow()+1,00 PSAY	Replicate("-",limite)
		EndIf
		CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
		lFirstPage := .F.
	EndIf	
	
EndDO

IF li != 80 .And. !lEnd
	li++
	@li,00 PSAY REPLICATE("-",limite)
	li++
	@li,0 PSAY "|"          			
	@li, 10 PSAY OemToAnsi(STR0018)  		//"T O T A I S  D O  P E R I O D O : "
	@ li,aColunas[COL_SEPARA4] PSAY "|"	
	ValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
	@ li,aColunas[COL_SEPARA5] PSAY "|"
	ValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
	@ li,aColunas[COL_SEPARA6] PSAY "|"
	@ li,aColunas[COL_SEPARA8] PSAY "|"
	li++
	@li,00 PSAY REPLICATE("-",limite)
	li++
	@li,0 PSAY " "
	If !lExterno
		roda(cbcont,cbtxt,"M")
		Set Filter To
	EndIf		
EndIF

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
EndIf

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
Ferase(cArqTmp+GetDBExtension())
FErase("cArqInd"+OrdBagExt())

dbselectArea("CT2")

MS_FLUSH()

Return Nil
