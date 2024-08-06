#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 20/04/17
#INCLUDE "FINR850.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE VALORPAGO 	3

User Function AMNR850()        // incluido pelo assistente de conversao do AP6 IDE em 20/04/17

Static lFWCodFil := FindFunction("FWCodFil")

Local oReport
Local aAreaR4	:= GetArea()

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Return FinR850R3() // Executa versão anterior do fonte
Endif

RestArea(aAreaR4)  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Marcio Menon		   º Data ³  28/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Grupo de perguntas do relatorio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 												                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 20/04/17 ==> Static Function ReportDef()
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local cReport 	:= "FINR850" 				// Nome do relatorio
Local cDescri 	:= STR0001 +;				//"Este programa tem como objetivo imprimir o arquivo"
						" " + STR0002 +;		//"Retorno da Comunicação Bancária SISPAG, conforme"
						STR0003    				//"layout previamente configurado"
Local cTitulo 	:= OemToAnsi(STR0004) 	//"Impressao do Retorno do SISPAG "
Local cPerg		:= "FIN850"					// Nome do grupo de perguntas

Private lAchouTit:= .T.
Private cNumtit  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("FIN850",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Arquivo de Entrada                    ³
//³ mv_par02            // Arquivo de Configuracao               ³
//³ mv_par03            // Codigo do Banco                       ³
//³ mv_par04            // Codigo Agencia                        ³
//³ mv_par05            // Codigo Conta                          ³
//³ mv_par06            // Codigo SubConta                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescri) 

oReport:SetPortrait()	//Imprime o relatorio no formato retrato

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                      Definicao das Secoes                              ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao 01                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport, STR0035, "SE2")

TRCell():New(oSection1, "PREFIXO", "SE2" , STR0028 ,PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1] ,/*lPixel*/,{ || SE2->E2_PREFIXO } )	//"PRF"
TRCell():New(oSection1, "NUM"  	 , "SE2" , STR0029 ,PesqPict("SE2","E2_NUM")	 	, 10                       ,/*lPixel*/,{ || SE2->E2_NUM }  )	//"TITULO"
TRCell():New(oSection1, "PARCELA", "SE2" , STR0030 ,PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1] ,/*lPixel*/,{ || SE2->E2_PARCELA } )	//"PC"
TRCell():New(oSection1, "TIPO"   , "SE2" , STR0031 ,PesqPict("SE2","E2_TIPO")	, TamSX3("E2_TIPO")[1] 	   ,/*lPixel*/,{ || SE2->E2_TIPO 	 } )	//"TP"
TRCell():New(oSection1, "FORNECE", "SE2" , STR0032 ,PesqPict("SE2","E2_FORNECE"), TamSX3("E2_FORNECE")[1] ,/*lPixel*/,{ || SE2->E2_FORNECE } )	//"FORNECEDOR"
TRCell():New(oSection1, "VALOR"  , ""    , STR0033 , TM(0,13)  , 13 ,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"VALOR"
TRCell():New(oSection1, "OCORR"  , ""    , STR0034 ,/*Picture*/, 30 ,/*lPixel*/,/*CodeBlock*/)		//"OCORRENCIA"
oSection1:SetNoFilter("SE2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao 02                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1, STR0036, "")

TRCell():New(oSection2, "TXTSTR"  , "" , STR0025 ,/*Picture*/, 32 ,/*lPixel*/,/*CodeBlock*/)	//"Totais do Relatorio"
TRCell():New(oSection2, "TOTVLR"  , "" , STR0033 ,TM(0,13)   , 13 ,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")	//"VALOR"

oSection2:SetHeaderSection(.F.)	//Nao imprime o cabeçalho da secao
oSection2:SetNoFilter("")

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrint ºAutor³ Marcio Menon       º Data ³  28/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime o objeto oReport definido na funcao ReportDef.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport do relatorio                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 20/04/17 ==> Static Function ReportPrint(oReport)
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1) 

Local aHeadA  	:= {}, aHead1 := {}, aHead2   := {}
Local aDetA   	:= {}, aDetB  := {}, aDetJ    := {}
Local aTraiA  	:= {}, aTrai1 := {}, aTrai2   := {}
Local nBytes  	:= 0 , nTamArq := 0 , nLidos  := 0
Local cArqConf	:= "", cArqEnt := "", nHdlConf := 0
Local xBuffer 	:= "", cTabela := "", cRegistro:= "", cRetorno := ""
Local cSegmento:= "", cValpag := "", nRectit  := 0
Local aDetN  	:= {}
Local aDetO  	:= {}
Local nTamTit 	:= TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+;
						TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]
Local nAscan 	:= 0
Local cTabRej 	:= GetMv("MV_TABREJ",,"")
Local nValt 	:= 0      
Local aCntOco 	:= {}     
Local nX 		:= 0
Local	cDesc1 	:= "DATA" 
Local	cDesc2 	:= "PRINCIPAL"     
Local	cDesc3 	:= "MULTA"
Local	cDesc4 	:= "JUROS"			
Local	lDataGrv := .F.      
Local	lDifPag 	:= GetNewPar("MV_DIFPAG",.F.)
Local lRejet   := .T.
Local cDescRej := ""
Local lPaMov	:= .F.
Local cKeySE5	:= ""
Local lNewIndice := FaVerInd()  //Verifica a existencia dos indices de IDCNAB sem filial
Local nTamPre	:= TamSX3("E2_PREFIXO")[1]
Local nTamNum	:= TamSX3("E2_NUM")[1] 
Local lGestao	:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicoes das secoes.			                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Cell("VALOR"):SetBlock ( { || nvalpag } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Banco indicado                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA6->(dbSeek(xFilial("SA6")+mv_par03+mv_par04+mv_par05))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica configuracao Remota                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !SEE->(dbSeek(xFilial("SEE")+mv_par03+mv_par04+mv_par05+mv_par06))
	Help(" ",1,"PAR150")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a tabela existe           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabela := Iif( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )
If !SX5->(dbSeek(cFilial+cTabela))
	Help(" ",1,"PAR150")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Leitura da Configuracao SISPAG ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqConf := alltrim(mv_par02)
If !FILE(cArqConf)
	Help(" ",1,"NOARQPAR")
	Return .F.
Endif
nHdlConf := FOPEN(cArqConf,0)

If nHdlConf < 0
	Help(" ",1,"NOARQUIVO",,cArqConf,5,1)
	Return .F.
Endif

nTamArq := FSEEK(nHdlConf,0,2)
FSEEK(nHdlConf,0,0)
xBuffer := Space(85)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche os arrays de acordo com o Identificador  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While nBytes < nTamArq

	FREAD(nHdlConf,@xBuffer,85)
	IF SubStr(xBuffer,1,1) == "A" .or. SubStr(xBuffer,1,1) == Chr(1)
      AADD(aHeadA,{  SubStr(xBuffer,02,15),;
                     SubStr(xBuffer,17,03),;
                     SubStr(xBuffer,20,03),;
                     SubStr(xBuffer,23,01),;
                     SubStr(xBuffer,24,60)})
	ElseIf SubStr(xBuffer,1,1) == "B" .or. SubStr(xBuffer,1,1) == Chr(2)
		AADD(aHead1,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60 ) } )
	ElseIf SubStr(xBuffer,1,1) == "C" .or. SubStr(xBuffer,1,1) == Chr(3)
		AADD(aHead2,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60 ) } )
	Elseif SubStr(xBuffer,1,1) == "D" .or. SubStr(xBuffer,1,1) == Chr(4)
		AADD(aTrai1,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "E" .or. SubStr(xBuffer,1,1) == Chr(5)
		AADD(aTrai2,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "F" .or. SubStr(xBuffer,1,1) == Chr(6)
		AADD(aTraiA,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "G" .or. SubStr(xBuffer,1,1) == Chr(7)
		AADD(aDetA,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "H" .or. SubStr(xBuffer,1,1) == Chr(8)
		AADD(aDetB,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "J" .or. SubStr(xBuffer,1,1) == Chr(10)
		AADD(aDetJ,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "N" .or. SubStr(xBuffer,1,1) == Chr(16)
		AADD(aDetN,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
			SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
			SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "O" .or. SubStr(xBuffer,1,1) == Chr(17)
		AADD(aDetO,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
			SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
			SubStr(xBuffer,24,60) } )
	Endif
	nBytes += 85
Enddo
fclose(nHdlConf)

If Len(aHeadA) == 0  .And. Len(aHead1) == 0 .And. Len(aHead2) == 0 ;
		.And. Len(aTrai1) == 0 .And. Len(aTrai2) == 0 ;
		.And. Len(aDetA)  == 0 .And. Len(aDetB)  == 0 ;
		.And. Len(aDetJ)  == 0 .And. Len(aDetN)  == 0 ;
		.And. Len(aDetO)  == 0
	Help(" ",1,"AX044BCO")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqEnt := mv_par01
IF !FILE(cArqEnt)
	Help(" ",1,"NOARQENT")
	Return .F.
Endif
nHdlBco := FOPEN(cArqEnt,0)
If nHdlBco < 0
	Help(" ",1,"NOARQUIVO",,cArqEnt,5,1)
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLidos := 0
nTamArq := FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)
xBuffer := Space(242)

oReport:SetMeter(nTamArq / Len(xBuffer))

While nLidos <= nTamArq

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le linha do arquivo retorno ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FREAD(nHdlBco,@xBuffer,242)
	nLidos += 242
  	oReport:IncMeter()   	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro:ÚÄ0 - Header de Arquivo     ³
	//³          ³ÚÄÄ1 - Header de Lote      ³
	//³          ³³    3 - Detalhes Variados ³
	//³          ³ÀÄÄ5 - Trailler de Lote    ³
	//³          ÀÄ9 - Trailler de Arquivo   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRegistro := Subst( xBuffer , Val(aHeada[3,2]) , ;
							    1+Val(aHeada[3,3])-Val(aHeada[3,2]))

	IF cRegistro == "0"
		Loop
	Endif
	If cRegistro == "1"
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retornos: 00-Credito efetuado BD-Pagamento Agendado  TA-Lote nao aceito ³
	//³ Retornos: BE-Pagto Agendado c/Forma Alterada p/ OP   RJ-Pagto Rejeitado ³
	//³ Header de Lote - verificar se houve rejeicao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Codigos de Rejeicao - TABELA=60                                         ³
	//³                                                                         ³
	//³ AD - Forma de lancamento invalida (Forma X Segmento)                    ³
	//³ AH - Numero sequencial do registro no lote invalido                     ³
	//³ AJ - Tipo de movimento invalido                                         ³
	//³ AL - Codigo do Banco do favorecido ou depositario invalido              ³
	//³ AM - Agencia do cedente invalido                                        ³
	//³ AN - Conta corrente do cedente invalido                                 ³
	//³ AO - Nome do cedente invalido                                           ³
	//³ AP - Data de lancamento / pagamento invalida                            ³
	//³ BC - Nosso numero invalido                                              ³
	//³ IA - Remetente / Motivo invalido                                        ³
	//³ IB - Valor do titulo invalido                                           ³
	//³ IC - Valor do abatimento invalido                                       ³
	//³ ID - Valor do desconto invalido                                         ³
	//³ IE - Valor da mora invalido                                             ³
	//³ IF - Valor da multa invalido                                            ³
	//³ IG - Valor da deducao invalido                                          ³
	//³ IH - Valor do acrescimo invalido                                        ³
	//³ II - Data de vecnto invalida                                            ³
	//³ IJ - Sequencia invalida de segmento                                     ³
	//³ IK - Codigo de instrucao invalida                                       ³
	//³ IL - Uso banco invalido para unibanco                                   ³
	//³ IM - Tipo X Forma nao compativel                                        ³
	//³ IN - Banco / Agencia nao pertence as pracas de compensacao ITAU         ³
	//³ IO - Identificacao Tipo de Cheque invalido                              ³
	//³ IP - Rejeicao do DAC do codigo de barras                                ³
	//³                                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cRegistro == "9"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Final do lote e arquivo - Sai da leitura ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Exit
	Endif

	If cRegistro != "3"
		LOOP
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Segmentos opcionais : B                               ³
	//³ Obs: Segmentos A e J possuem informacoes sobre o      ³
	//³ retorno.                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSegmento := Subst( xBuffer , Val(aDeta[5,2]) , 1+Val(aDeta[5,3])-Val(aDeta[5,2]) )

	If cSegmento == "A"
		cRetorno   := Subst( xBuffer, Val(aDeta[Len(aDeta),2]) , 1+Val(aDeta[Len(aDeta),3] )-Val(aDeta[Len(aDeta),2]))
		cNumTit    := Subst( xBuffer, Val(aDeta[11,2])         , 1+Val(aDeta[11,3] )-Val(aDeta[11,2]))
		cValPag    := Subst( xBuffer, Val(aDeta[15,2])         , 1+Val(aDeta[15,3] )-Val(aDeta[15,2]))
	ElseIf cSegmento == "J"
		cRetorno   := Subst( xBuffer, Val(aDetJ[Len(aDetJ),2]) , 1+Val(aDetJ[Len(aDetJ),3])-Val(aDetJ[Len(aDetJ),2]))
		cNumTit    := Subst( xBuffer, Val(aDetJ[20,2])         , 1+Val(aDetJ[20,3] )-Val(aDetJ[20,2]))
		cValPag    := Subst( xBuffer, Val(aDetJ[18,2])         , 1+Val(aDetJ[18,3] )-Val(aDetJ[18,2]))
	ElseIf cSegmento == "N"
		If !lDifPag
			cRetorno := Subst( xBuffer, Val(aDetN[Len(aDetN),2]) , 1+Val(aDetN[Len(aDetN),3])-Val(aDetN[Len(aDetN),2]))
		Else
			nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))=="OCORRENCIAS"})                                                 
			If nAscan > 0
				cRetorno    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))		
			Else	
				ApMsgAlert(STR0026+ "OCORRENCIAS" + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador OCORRENCIAS utilizado para localizar, no arquivo retorno, o valor dos campos.")
			EndIf
		EndIf
		
		// Procura a posicao do numero do titulo
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))=="SEU NUMERO"})                                                 
		If nAscan > 0
			cNumTit    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))		
		Else	
			ApMsgAlert(STR0017) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "SEU NUMERO" utilizado para localizar, no arquivo retorno,o título a ser baixado.") 
		EndIf
		
		//Retorno contem configuracao de campos de acordo com o tipo do tributo
		If lDifPag 
			//Verifico o tipo do imposto para saber qual posicao do array
			//contem as posicoes dos campos com os dados do tributo
			cTipoImp := Substr( xBuffer,Val(aDetN[07,2])         , 1+Val(aDetN[07,3] )-Val(aDetN[07,2]))		   
		   Do Case
				Case cTipoImp == "01"		// 01 - GPS
					cDesc1 := "DATA GPS" 
					cDesc2 := "PRINCIPAL GPS"     
					cDesc3 := "MULTA GPS"
					cDesc4 := "JUROS GPS"			
				Case cTipoImp == "02"		//02 - DARF
					cDesc1 := "DATA DARF"
					cDesc2 := "PRINCIPAL DARF"     
					cDesc3 := "MULTA DARF"
					cDesc4 := "JUROS DARF"
				Case cTipoImp == "03"	//03 - DARF Simples
					cDesc1 := "DATA SIMPLES"
					cDesc2 := "PRINC. SIMPLES"	
					cDesc3 := "MULTA SIMPLES"
					cDesc4 := "JUROS SIMPLES"
				Case cTipoImp == "04"	//04 - DARJ 
					cDesc1 := "DATA DARJ"
					cDesc2 := "PRINCIPAL DARJ"			
					cDesc3 := "MULTA DARJ"
					cDesc4 := "JUROS DARJ"
				Case cTipoImp == "05"	//05 - ICMS SP
					cDesc1 := "DATA ICMS"
					cDesc2 := "PRINCIPAL ICMS"			
					cDesc3 := "MULTA ICMS"
					cDesc4 := "JUROS ICMS"
				Case cTipoImp $ "07#08"	//07 - IPVA (SP e MG), 08 - DPVAT
					cDesc1 := "DATA IPVA"
					cDesc2 := "PRINCIPAL IPVA"			
					cDesc3 := "MULTA IPVA"
					cDesc4 := "JUROS IPVA"
				Case cTipoImp $ "11"	//11 - FGTS
					cDesc1 := "DATA FGTS"
					cDesc2 := "PRINCIPAL FGTS"								
			EndCase
		Else
			nPos := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))=="DATA"})
			If nPos <= 0
				cTipoImp := Substr( xBuffer,Val(aDetN[07,2])         , 1+Val(aDetN[07,3] )-Val(aDetN[07,2]))		
				If cTipoImp == "01"			//GPS
					nPos := 15
				ElseIf cTipoImp == "02"		//DARF
					nPos := 18			
				ElseIf cTipoImp $ "03#04#05"	//03 - DARF Simples, 04 - DARJ e 05 - ICMS SP
					nPos := 20			
				Endif
			Endif
			//Verifico o tipo do imposto para saber qual posicao do array
			//contem as posicoes das datas de baixa.
			cData      := Substr( xBuffer,Val(aDetN[nPos,2])         , 1+Val(aDetN[nPos,3] )-Val(aDetN[nPos,2]))
			cData      := ChangDate(cData,SEE->EE_TIPODAT)
			dBaixa     := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
			lDataGrv   := .T.	   
	   EndIF
		
		// Procura a posicao da data do tributo		
		If !lDataGrv .And. lDifPag 
			nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc1})
			If nAscan > 0
				cData := Substr( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))
				cData      := ChangDate(cData,SEE->EE_TIPODAT)
				dBaixa     := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
			Else
				ApMsgAlert(STR0026+ cDesc1 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc1 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
			Endif	
		EndIf
	
		// Procura a posicao do valor principal do tributo		
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc2})
		If nAscan > 0
			cValPag    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))
		Else
			ApMsgAlert(STR0026+ cDesc2 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc2 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
		Endif	

		// Procura a posicao da multa do tributo
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc3})
		If cTipoImp $ "11" //FGTS
			nMulta := 0
		ElseIf nAscan > 0
			nMulta := Round(Val(Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2])))/100,2)
		Else
			ApMsgAlert(STR0026+ cDesc3 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc3 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
		Endif	

		// Procura a posicao do juros do tributo
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc4})
		If cTipoImp $ "11" //FGTS
			nJuros := 0
		ElseIf nAscan > 0
			cValJur    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))
			nJuros	  := Val(cValJur)/100       
		Else
			ApMsgAlert(STR0026+ cDesc4 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc4 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
		Endif	  
	ElseIf cSegmento == "O"
		cRetorno   := Subst( xBuffer, Val(aDetO[Len(aDetO),2]) , 1+Val(aDetO[Len(aDetO),3])-Val(aDetO[Len(aDetO),2]))
		cNumTit    := Subst( xBuffer, Val(aDetO[16,2])         , 1+Val(aDetO[16,3] )-Val(aDetO[16,2]))
		cValPag    := Subst( xBuffer, Val(aDetO[14,2])         , 1+Val(aDetO[14,3] )-Val(aDetO[14,2]))
	Else
		Loop
	Endif

	nvalpag := val(cvalpag)/100
	
	//Totalizador Geral do Arquivo de Retorno	
	nValT  += nValPag

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o titulo no SE2.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE2")
	lAchouTit := .T.

	If lNewIndice .and. !Empty( Iif( lGestao, FWFilial("SE2"), xFilial("SE2") ) )
		//Busca por IdCnab (sem filial)
		nRecTit := Recno()
		SE2->(dbSetOrder(13)) // IdCnab
		If SE2->(MsSeek(Substr(cNumTit,1,10)))
			cFilAnt	:= SE2->E2_FILIAL
		Endif
		mv_par09	:= 2  //Desligo contabilizacao on-line				
	Else
		//Busca por IdCnab
		nRecTit := Recno()
		SE2->(dbSetOrder(11)) // Filial+IdCnab
		SE2->(MsSeek(xFilial("SE2")+	Substr(cNumTit,1,10)))
	Endif

	//Se nao achou, utiliza metodo antigo (titulo)
	If SE2->(!Found())
		//Busca pela chave antiga como retornado pelo banco
		dbSetOrder(1)
		If !dbSeek(xFilial("SE2")+Pad(cNumTit,nTamTit))
			// Busca por chave antiga adaptada para o tamanho de 9 posicoes para numero de NF
	   	// Isto ocorre quando titulo foi enviado com 6 posicoes para numero de NF e retornou com o
	   	// campo ja atualizado para 9 posicoes
			cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,4,6),nTamNum)+SubStr(cNumTit,10)
			If !dbSeek(xFilial("SE2")+Pad(cNumTit,nTamTit))
				lAchouTit := .F.	
			Endif
      Endif
	Endif	      

	//Verifico existencia de movimento anterior (arquivo reprocessado)
	lPaMov = .F.
	dbSelectArea("SE5")
	SE5->(DBSETORDER(2))  //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO                   
	cKeySe5 := xFilial("SE5")+IIF(SE2->E2_TIPO $ MVPAGANT,"PA","TX")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)
	cKeySe5 += IIF(SE2->E2_TIPO $ MVPAGANT,"PA ","TXA")
	If SE5->(MsSeek(cKeySe5))
		While !SE5->(EOF()) .and. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == cKeySe5
			If SE2->(E2_FORNECE+E2_LOJA) == SE5->(E5_CLIFOR+E5_LOJA)
				lPaMov = .T. 
				Exit
			Else
				SE5->(dbSkip())
			Endif
		Enddo
	Endif
	dbSelectArea("SE2")

   oSection1:Init()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata os titulos rejeitados e nao encontrados.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "00" $ cRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 00-Credito efetuado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe o titulo no SE2.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAchouTit
			oSection1:Cell("PREFIXO"):Hide()
			oSection1:Cell("NUM"):SetBlock ( { || cNumtit } )	         
			oSection1:Cell("PARCELA"):Hide()
			oSection1:Cell("TIPO"):Hide()
			oSection1:Cell("FORNECE"):Hide()
			oSection1:Cell("VALOR"):SetBlock ( { || nValPag } ) 
			oSection1:Cell("OCORR"):SetBlock ( { || OemToAnsi(STR0009) } )		//"TITULO NAO ENCONTRADO"
		   oSection1:PrintLine()
			//Totaliza Ocorrencia
			TotOcorr (cRetorno,STR0021,nValPag,aCntOco)	//"Titulos nao encontrados"
			oSection1:Cell("PREFIXO"):Show()
			oSection1:Cell("PARCELA"):Show()
			oSection1:Cell("TIPO"):Show()
			oSection1:Cell("FORNECE"):Show()

			dbGoTo(nRecTit)
			Loop
		ElseIf SE2->E2_SALDO == 0
			oSection1:Cell("OCORR"):SetBlock ( { || OemToAnsi(STR0011) } )	//"TITULO JA BAIXADO"
		   oSection1:PrintLine()
			//Totaliza Ocorrencia
			TotOcorr (cRetorno,STR0022,nValPag,aCntOco) //"Titulos ja baixados"
			dbGoTo(nRecTit)
			Loop
		ElseIf lPaMov .and. SE2->E2_TIPO $ MVPAGANT+"#"+MVTXA
			oSection1:Cell("OCORR"):SetBlock ( { || OemToAnsi(STR0037) } )	//"PA JA DEBITADO"
		   oSection1:PrintLine()
			//Totaliza Ocorrencia
			TotOcorr (cRetorno,STR0037,nValPag,aCntOco) //"PA ja Debitado"
			dbGoTo(nRecTit)
			Loop			
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica c¢digo da ocorrencia ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SEB")
		dbSeek(xFilial("SEB")+mv_par03+Padr(Substr(cRetorno,1,3),3)+"R")
		If !LEFT(SEB->EB_OCORR,2) $ "06/07/08"  //Baixa do Titulo
			oSection1:Cell("OCORR"):SetBlock ( { || OemToAnsi(STR0008) } )	//"OCORRENCIA NAO ENCONTRADA"
		   oSection1:PrintLine()
			//Totaliza Ocorrencia
			TotOcorr (cRetorno,STR0008 ,nValPag,aCntOco) //"Ocorrencia nao encontrada"
			Loop
		Else

			nJuros		:= If(Type("nJuros") != "N"	,0,nJuros	)
			nMulta		:= IF(Type("nMulta") != "N"	,0,nMulta	)
			nDescont		:= If(Type("nDescont") != "N",0,nDescont	)

			nValPadrao := nValPag-(nJuros+nMulta-nDescont)
			nTotAbat	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,SE2->E2_MOEDA,"S",dDatabase,SE2->E2_LOJA)
			If Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) < Round(NoRound(nValPadrao,3),2)
				oSection1:Cell("OCORR"):SetBlock ( { || STR0038} ) //"VLR PAGO MAIOR"
			   oSection1:PrintLine()
				//Totaliza Ocorrencia
				TotOcorr (cRetorno,"",nValPag,aCntOco)
			ElseIf Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) > Round(NoRound(nValPadrao,3),2)
				oSection1:Cell("OCORR"):SetBlock ( { || STR0039} ) //"VLR PAGO MENOR"
			   oSection1:PrintLine()
				//Totaliza Ocorrencia
				TotOcorr (cRetorno,"",nValPag,aCntOco)
			Else
				oSection1:Cell("OCORR"):SetBlock ( { || OemToAnsi(STR0010)} )			//"TITULO OK"
			   oSection1:PrintLine()
				//Totaliza Ocorrencia
				TotOcorr (cRetorno,"",nValPag,aCntOco) 
			Endif
		EndIf	

	ElseIf ("BD" $ cRetorno) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BD-Pagamento Agendado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection1:Cell("OCORR"):SetBlock ( { || STR0015 } )	//"PAGAMENTO AGENDADO"
	   oSection1:PrintLine()
		TotOcorr (cRetorno,STR0015,nValPag,aCntOco) //"PAGAMENTO AGENDADO"
	ElseIf ("BE" $ cRetorno) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BE-Pagto Agendado c/Forma Alterada p/ OP ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection1:Cell("OCORR"):SetBlock ( { || STR0016 } )	//"PGTO AGENDADO ALTER. P/ OP"  
	   oSection1:PrintLine()
		TotOcorr (cRetorno,STR0016,nValPag,aCntOco) //"PGTO AGENDADO ALTER. P/ OP"
	Elseif !Empty(cTabRej)

			lRejet := .T.
			FOR nX := 1 to Len(Alltrim(cRetorno)) Step 2
				cDescRej := Left(Tabela(cTabRej,Substr(cRetorno,nX,2),.F.),30)
				If Empty(cDescRej) 
					cDescRej := STR0008
				EndIf
	  		Next
			  
		If lAchoutit
		   		oSection1:Cell("OCORR"):SetBlock ( { || cDescRej } )	//Imprime o conteudo da tabela de rejeicoes	
		  		oSection1:PrintLine()
		   		TotOcorr(cRetorno,cDescRej,nValPag,aCntOco)//Imprime o conteudo da tabela de rejeicoes     
		  	Else     
				oSection1:Cell("PREFIXO"):Hide()
				oSection1:Cell("NUM"):SetBlock ( { || cNumtit } )	         
				oSection1:Cell("PARCELA"):Hide()
				oSection1:Cell("TIPO"):Hide()
				oSection1:Cell("FORNECE"):Hide()
				oSection1:Cell("VALOR"):SetBlock ( { || nValPag } )
				oSection1:Cell("OCORR"):SetBlock ( { || OemToAnsi(STR0009) } )		//"TITULO NAO ENCONTRADO"
			    oSection1:PrintLine()
				//Totaliza Ocorrencia
				TotOcorr (cRetorno,STR0021,nValPag,aCntOco)	//"Titulos nao encontrados"
				oSection1:Cell("PREFIXO"):Show()
				oSection1:Cell("PARCELA"):Show()
				oSection1:Cell("TIPO"):Show()
				oSection1:Cell("FORNECE"):Show()
			Endif     
			Loop
	Else        
		    If lAchoutit
		   		dbSelectArea("SEB")
		  		dbSeek(xFilial("SEB")+mv_par03+Padr(Substr(cRetorno,1,3),3)+"R")
		  		cDescRej:= SEB->EB_DESCRI
	   	   		oSection1:Cell("OCORR"):SetBlock ( { || cDescRej } )	//Imprime o conteudo da tabela de rejeicoes	
		  		oSection1:PrintLine()
		   		TotOcorr(cRetorno,cDescRej,nValPag,aCntOco)//Imprime o conteudo da tabela de rejeicoes     
		  		cDescRej:="" 
			Else     
				oSection1:Cell("PREFIXO"):Hide()
				oSection1:Cell("NUM"):SetBlock ( { || cNumtit } )	         
				oSection1:Cell("PARCELA"):Hide()
				oSection1:Cell("TIPO"):Hide()
				oSection1:Cell("FORNECE"):Hide()
				oSection1:Cell("VALOR"):SetBlock ( { || nValPag } )
				oSection1:Cell("OCORR"):SetBlock ( { || OemToAnsi(STR0009) } )		//"TITULO NAO ENCONTRADO"
			    oSection1:PrintLine()
				//Totaliza Ocorrencia
				TotOcorr (cRetorno,STR0021,nValPag,aCntOco)	//"Titulos nao encontrados"
				oSection1:Cell("PREFIXO"):Show()
				oSection1:Cell("PARCELA"):Show()
				oSection1:Cell("TIPO"):Show()
				oSection1:Cell("FORNECE"):Show()
			
			Endif
	Endif

Enddo

oSection1:Finish()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Subtotais por ocorrencia  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SkipLine()
oReport:SkipLine()
oReport:PrintText(OemToAnsi(STR0024))	//"SubTotais do Relatorio"

For nX :=1 to Len(aCntOco)         
	oSection2:Init()
	oSection2:Cell("TXTSTR"):SetBlock ( { || AllTrim(aCntOco[nX][1]) + " - " + Substr(aCntOco[nX][2],1,30) } )
	oSection2:Cell("TOTVLR"):SetBlock ( { || aCntOco[nX][VALORPAGO] } )
	oSection2:PrintLine()
Next

oSection2:Finish()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Totais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:Init()
oSection2:Cell("TXTSTR"):SetBlock ( { || OemToAnsi(STR0025) } )
oSection2:Cell("TOTVLR"):SetBlock ( { || nValT } )
oSection2:PrintLine()
oSection2:Finish()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos ASCII ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCLOSE(nHdlBco)

Return

/*
---------------------------------------------- Release 3 ---------------------------------------------------------
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Finr850   ³ Autor ³ Julio Wittwer         ³ Data ³ 06.12.99 ³±±
±±³          ³          ³ Autor ³ Jose Novaes           ³ Data ³ 20.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Relatorio do Arquivo de Retorno SISPAG                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Finr850()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 20/04/17 ==> Function FinR850R3()
Static Function FinR850R3()
LOCAL wnrel   := "FINR850"          //Nome Default do relatorio em Disco
LOCAL cString := ""
LOCAL cDesc1  := STR0001 //"Este programa tem como objetivo imprimir o arquivo"
LOCAL cDesc2  := STR0002 //"Retorno da Comunicação Bancária SISPAG, conforme"
LOCAL cDesc3  := STR0003 //"layout previamente configurado"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE Titulo  := OemToAnsi(STR0004) //"Impressao do Retorno do SISPAG "
PRIVATE cabec1  := OemToAnsi(STR0007) //"PREFIXO NUMERO PAR TIPO FORNECEDOR                OCORRENCIA"
PRIVATE cabec2  := ""
PRIVATE aReturn := {OemToAnsi(STR0005) , 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE cPerg   := "FIN850"   , nLastKey := 0
PRIVATE nomeprog:= "FINR850"
PRIVATE nTipo
PRIVATE tamanho := "P"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Arquivo de Entrada                    ³
//³ mv_par02            // Arquivo de Configuracao               ³
//³ mv_par03            // Codigo do Banco                       ³
//³ mv_par04            // Codigo Agencia                        ³
//³ mv_par05            // Codigo Conta                          ³
//³ mv_par06            // Codigo SubConta                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

nTipo:=Iif(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))

If nLastKey == 27
	Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

RptStatus( {| lEnd | Fa850Imp(@lEnd,wnRel,cString) } , Titulo )

Set Device to Screen
If aReturn[5] = 1
   Set Printer To
   dbCommitAll()
   Ourspool(wnrel)
End

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FA850Imp ³ Autor ³ Julio Wittwer         ³ Data ³ 06.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao da Comunicacao Bancaria - Retorno SISPAG         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA850Imp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR850                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 20/04/17 ==> STATIC FUNCTION FA850IMP(lEnd,wnRel,cString)
STATIC FUNCTION FA850IMP(lEnd,wnRel,cString)

LOCAL aHeadA  := {}, aHead1 := {}, aHead2   := {}
LOCAL aDetA   := {}, aDetB  := {}, aDetJ    := {}
LOCAL aTraiA  := {}, aTrai1 := {}, aTrai2   := {}
LOCAL nBytes  := 0 , nTamArq  := 0 , nLidos  := 0
LOCAL cArqConf:= "", cArqEnt:= "", nHdlConf := 0
LOCAL xBuffer := "", cTabela:= "", cRegistro:= "", cRetorno:= ""
LOCAL cSegmento:= "",cNumtit:= "", cValpag  := "", nRectit:= 0
Local aDetN  := {}
Local aDetO  := {}
Local nTamTit := TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+;
						TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]
Local lAchouTit := .T.
Local nAscan := 0
Local cTabRej := GetMv("MV_TABREJ",,"")
Local nValt := 0      
Local aCntOco := {}     
Local nX := 0
Local	cDesc1 := "DATA" 
Local	cDesc2 := "PRINCIPAL"     
Local	cDesc3 := "MULTA"
Local	cDesc4 := "JUROS"			
Local	lDataGrv := .F.      
Local	lDifPag := GetNewPar("MV_DIFPAG",.F.)
Local lPaMov	:= .F.
Local cKeySE5	:= ""
Local lNewIndice := FaVerInd()  //Verifica a existencia dos indices de IDCNAB sem filial
Local nTamPre	:= TamSX3("E2_PREFIXO")[1]
Local nTamNum	:= TamSX3("E2_NUM")[1] 
Local lGestao	:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt   := SPACE(10)
Private cbcont  := 0
Private li      := 80
Private m_pag   := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Banco indicado                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA6->(dbSeek(xFilial("SA6")+mv_par03+mv_par04+mv_par05))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica configuracao Remota                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !SEE->(dbSeek(xFilial("SEE")+mv_par03+mv_par04+mv_par05+mv_par06))
	Help(" ",1,"PAR150")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a tabela existe           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabela := Iif( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )
If !SX5->(dbSeek(cFilial+cTabela))
	Help(" ",1,"PAR150")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Leitura da Configuracao SISPAG ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqConf := alltrim(mv_par02)
If !FILE(cArqConf)
	Help(" ",1,"NOARQPAR")
	Return .F.
Endif
nHdlConf := FOPEN(cArqConf,0)

If nHdlConf < 0
	Help(" ",1,"NOARQUIVO",,cArqConf,5,1)
	Return .F.
Endif

nTamArq := FSEEK(nHdlConf,0,2)
FSEEK(nHdlConf,0,0)
xBuffer := Space(85)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche os arrays de acordo com o Identificador  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While nBytes < nTamArq

	FREAD(nHdlConf,@xBuffer,85)
	IF SubStr(xBuffer,1,1) == "A" .or. SubStr(xBuffer,1,1) == Chr(1)
      AADD(aHeadA,{  SubStr(xBuffer,02,15),;
                     SubStr(xBuffer,17,03),;
                     SubStr(xBuffer,20,03),;
                     SubStr(xBuffer,23,01),;
                     SubStr(xBuffer,24,60)})
	ElseIf SubStr(xBuffer,1,1) == "B" .or. SubStr(xBuffer,1,1) == Chr(2)
		AADD(aHead1,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60 ) } )
	ElseIf SubStr(xBuffer,1,1) == "C" .or. SubStr(xBuffer,1,1) == Chr(3)
		AADD(aHead2,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60 ) } )
	Elseif SubStr(xBuffer,1,1) == "D" .or. SubStr(xBuffer,1,1) == Chr(4)
		AADD(aTrai1,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "E" .or. SubStr(xBuffer,1,1) == Chr(5)
		AADD(aTrai2,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "F" .or. SubStr(xBuffer,1,1) == Chr(6)
		AADD(aTraiA,{  SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "G" .or. SubStr(xBuffer,1,1) == Chr(7)
		AADD(aDetA,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "H" .or. SubStr(xBuffer,1,1) == Chr(8)
		AADD(aDetB,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "J" .or. SubStr(xBuffer,1,1) == Chr(10)
		AADD(aDetJ,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
							SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
							SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "N" .or. SubStr(xBuffer,1,1) == Chr(16)
		AADD(aDetN,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
			SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
			SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == "O" .or. SubStr(xBuffer,1,1) == Chr(17)
		AADD(aDetO,{   SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
			SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
			SubStr(xBuffer,24,60) } )
	Endif
	nBytes += 85
Enddo
fclose(nHdlConf)

If Len(aHeadA) == 0  .And. Len(aHead1) == 0 .And. Len(aHead2) == 0 ;
		.And. Len(aTrai1) == 0 .And. Len(aTrai2) == 0 ;
		.And. Len(aDetA)  == 0 .And. Len(aDetB)  == 0 ;
		.And. Len(aDetJ)  == 0 .And. Len(aDetN)  == 0 ;
		.And. Len(aDetO)  == 0
	Help(" ",1,"AX044BCO")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqEnt := mv_par01
IF !FILE(cArqEnt)
	Help(" ",1,"NOARQENT")
	Return .F.
Endif
nHdlBco := FOPEN(cArqEnt,0)
If nHdlBco < 0
	Help(" ",1,"NOARQUIVO",,cArqEnt,5,1)
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLidos := 0
nTamArq := FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)
xBuffer := Space(242)

SetRegua(nTamArq/242)

While nLidos <= nTamArq .and. !lEnd
	
	IF lEnd
		@ PROW()+1, 001 PSAY OemToAnsi(STR0012)//"CANCELADO PELO OPERADOR"
		Exit
	End
	
	IF li > 58
		cabec(Titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le linha do arquivo retorno ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FREAD(nHdlBco,@xBuffer,242)
	nLidos += 242
	IncRegua()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro:ÚÄ0 - Header de Arquivo     ³
	//³          ³ÚÄÄ1 - Header de Lote      ³
	//³          ³³    3 - Detalhes Variados ³
	//³          ³ÀÄÄ5 - Trailler de Lote    ³
	//³          ÀÄ9 - Trailler de Arquivo   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRegistro := Subst( xBuffer , Val(aHeada[3,2]) , ;
							    1+Val(aHeada[3,3])-Val(aHeada[3,2]))

	IF cRegistro == "0"
		Loop
	Endif
	If cRegistro == "1"
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retornos: 00-Credito efetuado BD-Pagamento Agendado  TA-Lote nao aceito ³
	//³ Retornos: BE-Pagto Agendado c/Forma Alterada p/ OP   RJ-Pagto Rejeitado ³
	//³ Header de Lote - verificar se houve rejeicao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Codigos de Rejeicao - TABELA=60                                         ³
	//³                                                                         ³
	//³ AD - Forma de lancamento invalida (Forma X Segmento)                    ³
	//³ AH - Numero sequencial do registro no lote invalido                     ³
	//³ AJ - Tipo de movimento invalido                                         ³
	//³ AL - Codigo do Banco do favorecido ou depositario invalido              ³
	//³ AM - Agencia do cedente invalido                                        ³
	//³ AN - Conta corrente do cedente invalido                                 ³
	//³ AO - Nome do cedente invalido                                           ³
	//³ AP - Data de lancamento / pagamento invalida                            ³
	//³ BC - Nosso numero invalido                                              ³
	//³ IA - Remetente / Motivo invalido                                        ³
	//³ IB - Valor do titulo invalido                                           ³
	//³ IC - Valor do abatimento invalido                                       ³
	//³ ID - Valor do desconto invalido                                         ³
	//³ IE - Valor da mora invalido                                             ³
	//³ IF - Valor da multa invalido                                            ³
	//³ IG - Valor da deducao invalido                                          ³
	//³ IH - Valor do acrescimo invalido                                        ³
	//³ II - Data de vecnto invalida                                            ³
	//³ IJ - Sequencia invalida de segmento                                     ³
	//³ IK - Codigo de instrucao invalida                                       ³
	//³ IL - Uso banco invalido para unibanco                                   ³
	//³ IM - Tipo X Forma nao compativel                                        ³
	//³ IN - Banco / Agencia nao pertence as pracas de compensacao ITAU         ³
	//³ IO - Identificacao Tipo de Cheque invalido                              ³
	//³ IP - Rejeicao do DAC do codigo de barras                                ³
	//³                                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cRegistro == "9"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Final do lote e arquivo - Sai da leitura ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Exit
	Endif

	If cRegistro != "3"
		LOOP
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Segmentos opcionais : B                               ³
	//³ Obs: Segmentos A e J possuem informacoes sobre o      ³
	//³ retorno.                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSegmento := Subst( xBuffer , Val(aDeta[5,2]) , 1+Val(aDeta[5,3])-Val(aDeta[5,2]) )

	If cSegmento == "A"
		cRetorno   := Subst( xBuffer, Val(aDeta[Len(aDeta),2]) , 1+Val(aDeta[Len(aDeta),3] )-Val(aDeta[Len(aDeta),2]))
		cNumTit    := Subst( xBuffer, Val(aDeta[11,2])         , 1+Val(aDeta[11,3] )-Val(aDeta[11,2]))
		cValPag    := Subst( xBuffer, Val(aDeta[15,2])         , 1+Val(aDeta[15,3] )-Val(aDeta[15,2]))
	ElseIf cSegmento == "J"
		cRetorno   := Subst( xBuffer, Val(aDetJ[Len(aDetJ),2]) , 1+Val(aDetJ[Len(aDetJ),3])-Val(aDetJ[Len(aDetJ),2]))
		cNumTit    := Subst( xBuffer, Val(aDetJ[20,2])         , 1+Val(aDetJ[20,3] )-Val(aDetJ[20,2]))
		cValPag    := Subst( xBuffer, Val(aDetJ[18,2])         , 1+Val(aDetJ[18,3] )-Val(aDetJ[18,2]))
	ElseIf cSegmento == "N"
		If !lDifPag
			cRetorno := Subst( xBuffer, Val(aDetN[Len(aDetN),2]) , 1+Val(aDetN[Len(aDetN),3])-Val(aDetN[Len(aDetN),2]))
		Else
			nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))=="OCORRENCIAS"})                                                 
			If nAscan > 0
				cRetorno    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))		
			Else	
				ApMsgAlert(STR0026+ "OCORRENCIAS" + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador OCORRENCIAS utilizado para localizar, no arquivo retorno, o valor dos campos.")
			EndIf
		EndIf
		
		// Procura a posicao do numero do titulo
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))=="SEU NUMERO"})                                                 
		If nAscan > 0
			cNumTit    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))		
		Else	
			ApMsgAlert(STR0017) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "SEU NUMERO" utilizado para localizar, no arquivo retorno,o título a ser baixado.") 
		EndIf
		
		//Retorno contem configuracao de campos de acordo com o tipo do tributo
		If lDifPag 
			//Verifico o tipo do imposto para saber qual posicao do array
			//contem as posicoes dos campos com os dados do tributo
			cTipoImp := Substr( xBuffer,Val(aDetN[07,2])         , 1+Val(aDetN[07,3] )-Val(aDetN[07,2]))		   
		   Do Case
				Case cTipoImp == "01"		// 01 - GPS
					cDesc1 := "DATA GPS" 
					cDesc2 := "PRINCIPAL GPS"     
					cDesc3 := "MULTA GPS"
					cDesc4 := "JUROS GPS"			
				Case cTipoImp == "02"		//02 - DARF
					cDesc1 := "DATA DARF"
					cDesc2 := "PRINCIPAL DARF"     
					cDesc3 := "MULTA DARF"
					cDesc4 := "JUROS DARF"
				Case cTipoImp == "03"	//03 - DARF Simples
					cDesc1 := "DATA SIMPLES"
					cDesc2 := "PRINC. SIMPLES"	
					cDesc3 := "MULTA SIMPLES"
					cDesc4 := "JUROS SIMPLES"
				Case cTipoImp == "04"	//04 - DARJ 
					cDesc1 := "DATA DARJ"
					cDesc2 := "PRINCIPAL DARJ"			
					cDesc3 := "MULTA DARJ"
					cDesc4 := "JUROS DARJ"
				Case cTipoImp == "05"	//05 - ICMS SP
					cDesc1 := "DATA ICMS"
					cDesc2 := "PRINCIPAL ICMS"			
					cDesc3 := "MULTA ICMS"
					cDesc4 := "JUROS ICMS"
				Case cTipoImp $ "07#08"	//07 - IPVA (SP e MG), 08 - DPVAT
					cDesc1 := "DATA IPVA"
					cDesc2 := "PRINCIPAL IPVA"			
					cDesc3 := "MULTA IPVA"
					cDesc4 := "JUROS IPVA"
				Case cTipoImp $ "11"	//11 - FGTS
					cDesc1 := "DATA FGTS"
					cDesc2 := "PRINCIPAL FGTS"								
			EndCase
		Else
			nPos := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))=="DATA"})
			If nPos <= 0
				cTipoImp := Substr( xBuffer,Val(aDetN[07,2])         , 1+Val(aDetN[07,3] )-Val(aDetN[07,2]))		
				If cTipoImp == "01"			//GPS
					nPos := 15
				ElseIf cTipoImp == "02"		//DARF
					nPos := 18			
				ElseIf cTipoImp $ "03#04#05"	//03 - DARF Simples, 04 - DARJ e 05 - ICMS SP
					nPos := 20			
				Endif
			Endif
			//Verifico o tipo do imposto para saber qual posicao do array
			//contem as posicoes das datas de baixa.
			cData      := Substr( xBuffer,Val(aDetN[nPos,2])         , 1+Val(aDetN[nPos,3] )-Val(aDetN[nPos,2]))
			cData      := ChangDate(cData,SEE->EE_TIPODAT)
			dBaixa     := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
			lDataGrv   := .T.	   
	   EndIF
		
		// Procura a posicao da data do tributo		
		If !lDataGrv .And. lDifPag 
			nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc1})
			If nAscan > 0
				cData := Substr( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))
				cData      := ChangDate(cData,SEE->EE_TIPODAT)
				dBaixa     := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
			Else
				ApMsgAlert(STR0026+ cDesc1 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc1 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
			Endif	
		EndIf
	
		// Procura a posicao do valor principal do tributo		
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc2})
		If nAscan > 0
			cValPag    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))
		Else
			ApMsgAlert(STR0026+ cDesc2 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc2 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
		Endif	

		// Procura a posicao da multa do tributo
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc3})
		If cTipoImp $ "11" //FGTS
			nMulta := 0
		ElseIf nAscan > 0
			nMulta := Round(Val(Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2])))/100,2)
		Else
			ApMsgAlert(STR0026+ cDesc3 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc3 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
		Endif	

		// Procura a posicao do juros do tributo
		nAscan := Ascan(aDetN, {|e| AllTrim(Upper(e[1]))==cDesc4})
		If cTipoImp $ "11" //FGTS
			nJuros := 0
		ElseIf nAscan > 0
			cValJur    := Subst( xBuffer, Val(aDetN[nAscan,2])         , 1+Val(aDetN[nAscan,3] )-Val(aDetN[nAscan,2]))
			nJuros	  := Val(cValJur)/100       
		Else
			ApMsgAlert(STR0026+ cDesc4 + STR0027) //"Por favor, indique no registro detalhe do arquivo de configuração segmento N, no nome do campo, o identificador "+ cDesc4 +" utilizado para localizar, no arquivo retorno, o valor da multa.")
		Endif	  
	ElseIf cSegmento == "O"
		cRetorno   := Subst( xBuffer, Val(aDetO[Len(aDetO),2]) , 1+Val(aDetO[Len(aDetO),3])-Val(aDetO[Len(aDetO),2]))
		cNumTit    := Subst( xBuffer, Val(aDetO[16,2])         , 1+Val(aDetO[16,3] )-Val(aDetO[16,2]))
		cValPag    := Subst( xBuffer, Val(aDetO[14,2])         , 1+Val(aDetO[14,3] )-Val(aDetO[14,2]))
	Else
		Loop
	Endif

	nvalpag := val(cvalpag)/100
	
	//Totalizador Geral do Arquivo de Retorno	
	nValT  += nValPag

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o titulo no SE2.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE2")
	lAchouTit := .T.

	If lNewIndice .and. !Empty( Iif( lGestao, FWFilial("SE2"), xFilial("SE2") ) )
		//Busca por IdCnab (sem filial)
		nRecTit := Recno()
		SE2->(dbSetOrder(13)) // IdCnab
		If SE2->(MsSeek(Substr(cNumTit,1,10)))
			cFilAnt	:= SE2->E2_FILIAL
			mv_par09	:= 2  //Desligo contabilizacao on-line				
		Endif
	Else
		//Busca por IdCnab
		nRecTit := Recno()
		SE2->(dbSetOrder(11)) // Filial+IdCnab
		SE2->(MsSeek(xFilial("SE2")+	Substr(cNumTit,1,10)))
	Endif

	//Se nao achou, utiliza metodo antigo (titulo)
	If SE2->(!Found())
		//Busca pela chave antiga como retornado pelo banco
		dbSetOrder(1)
		If !dbSeek(xFilial("SE2")+Pad(cNumTit,nTamTit))
			// Busca por chave antiga adaptada para o tamanho de 9 posicoes para numero de NF
	   	// Isto ocorre quando titulo foi enviado com 6 posicoes para numero de NF e retornou com o
	   	// campo ja atualizado para 9 posicoes
			cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,4,6),nTamNum)+SubStr(cNumTit,10)
			If !dbSeek(xFilial("SE2")+Pad(cNumTit,nTamTit))
				lAchouTit := .F.	
			Endif
      Endif
	Endif	      
	If lAchouTit 
		@ li,00 PSAY SE2->E2_PREFIXO+" "+SE2->E2_NUM+" "+SE2->E2_PARCELA
		@ li,15 PSAY SE2->E2_TIPO+" "+SE2->E2_FORNECE
   Else
	    cNumTit:=SubStr(cNumTit,1,10)
		@ li,00 PSAY cNumTit
	Endif
	@ li,37 PSAY nvalpag PICTURE tm(nvalpag,13)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o titulo no SE2.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAchouTit
		@ li,52 PSAY OemToAnsi(STR0009) //titulo nao encontrado
		//Totaliza Ocorrencia
		TotOcorr (cRetorno,STR0021,nValPag,aCntOco)	//"Titulos nao encontrados"
		li++
		dbGoTo(nRecTit)
		Loop
	Endif
	If SE2->E2_SALDO = 0
		@ li,52 PSAY OemToAnsi(STR0011) //titulo ja baixado
		//Totaliza Ocorrencia
		TotOcorr (cRetorno,STR0022,nValPag,aCntOco) //"Titulos ja baixados"
		li++
		dbGoTo(nRecTit)
		Loop
	Endif

	//Totaliza Ocorrencia
	If lAchouTit
		TotOcorr (cRetorno,fa850rejei(cRetorno,cTabRej),nValPag,aCntOco)
	Endif
	
Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Subtotais por ocorrencia  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Li+=2
   @li,000 PSAY OemToAnsi(STR0024) //"SubTotais do Relatorio"
  	Li+=2   
	For nX :=1 to Len(aCntOco)         
		@li,000 PSAY aCntOco[nX][1] + " - " + Substr(aCntOco[nX][2],1,30) 
		@li,038 PSAY (aCntOco[nX][VALORPAGO])      picture Tm((aCntOco[nX][03]),12) //'@E 9,999,999,999.99'
		Li ++
	Next
	Li+=2

	If (Len(aCntOco) + Li) > 58
   	Cabec(Titulo+' - '+mv_par01,cabec1,cabec2,nomeprog,tamanho,nTipo)
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Totais                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@li,000 PSAY OemToAnsi(STR0025) //"Totais do Relatorio"
	@li,38  PSAY nValT       picture Tm(nValT,12)  //'@E 9,999,999,999.99'
	roda(cbcont,cbtxt,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos ASCII ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCLOSE(nHdlBco)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fA850Rejei³ Autor ³ Julio Wittwer         ³ Data ³ 06/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Trata titulo rejeitado.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fa850Rejei                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP6 IDE em 20/04/17 ==> Static Function fa850Rejei(cRetString,cTabela)
Static Function fa850Rejei(cRetString,cTabela)
Local cDescr := " "
Local nX := 0
Local nTotAbat := 0
Local nValPadrao := 0

nJuros		:= If(Type("nJuros") != "N"	,0,nJuros	)
nMulta		:= IF(Type("nMulta") != "N"	,0,nMulta	)
nDescont		:= If(Type("nDescont") != "N",0,nDescont	)


IF "00" $ cRetString
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 00-Credito efetuado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cDescr := STR0010 //"TITULO OK"

	//Verifico existencia de movimento anterior (arquivo reprocessado)
	lPaMov = .F.
	dbSelectArea("SE5")
	SE5->(DBSETORDER(2))  //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO                   
	cKeySe5 := xFilial("SE5")+IIF(SE2->E2_TIPO $ MVPAGANT,"PA","TX")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)
	cKeySe5 += IIF(SE2->E2_TIPO $ MVPAGANT,"PA ","TXA")
	If SE5->(MsSeek(cKeySe5))
		While !SE5->(EOF()) .and. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == cKeySe5
			If SE2->(E2_FORNECE+E2_LOJA) == SE5->(E5_CLIFOR+E5_LOJA)
			   cDescr := STR0037 //"PA JA DEBITADO"
			   EXIT
			Else
				SE5->(dbSkip())
			Endif
		Enddo
	Endif

	nValPadrao := nValPag-(nJuros+nMulta-nDescont)
	nTotAbat	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,SE2->E2_MOEDA,"S",dDatabase,SE2->E2_LOJA)
	If Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) < Round(NoRound(nValPadrao,3),2)
	   cDescr := STR0038 //"VLR PAGO MAIOR"

	ElseIf Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) > Round(NoRound(nValPadrao,3),2)
	   cDescr := STR0039 //"VLR PAGO MENOR"

	Endif

ElseIf ("BD" $ cRetString) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ BD-Pagamento Agendado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cDescr := STR0015 //"PAGAMENTO AGENDADO"
ElseIf ("BE" $ cRetString) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ BE-Pagto Agendado c/Forma Alterada p/ OP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cDescr := STR0016 //"PGTO AGENDADO ALTER. P/ OP"
Else
	If !Empty(cTabela)
		For nX := 1 to Len(Alltrim(cRetString)) Step 2
			// Imprime e retorna o conteudo da tabela de rejeicoes
			cDescr := Left(Tabela(cTabela,Substr(cRetString,nX,2),.F.),30)
			If Empty(cDescr) 
			   cDescr := STR0008 //"OCORRENCIA NAO ENCONTRADA "
			Endif
  		Next			
   Else
	   cDescr := STR0008 //"OCORRENCIA NAO ENCONTRADA "
	Endif			
Endif

If !Empty(cDescr)
	@ li,52 PSAY cDescr 
	li++
Endif

Return cDescr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TotOcorr  ºAutor  ³Ricardo A. Canteras º Data ³  05/10/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acumula o valor pago por ocorrencia		                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FINR850                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 20/04/17 ==> Static Function TotOcorr(cOcorr,cDescr,nValPag,aCntOco)
Static Function TotOcorr(cOcorr,cDescr,nValPag,aCntOco)

Local aArea := GetArea()
Local nCntOco := 0
Default cDescr:=""                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica codigo da ocorrencia ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEB")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua contagem dos SubTotais por ocorrencia  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If (dbSeek(xFilial("SEB")+mv_par03+Pad(cOcorr,TamSX3("EB_REFBAN")[1])+"R"))
	nCntOco := Ascan(aCntOco, { |X| X[1] == SEB->EB_OCORR})	
	If nCntOco == 0
		Aadd(aCntOco,{SEB->EB_OCORR,Subs(SEB->EB_DESCRI,1,27),nValPAG})
	Else                                         
		aCntOco[nCntOco][VALORPAGO]+=nValPag
	Endif                     
Else
	nCntOco := Ascan(aCntOco, { |X| X[1] == Pad(cOcorr,Len(SEB->EB_OCORR))})
	If nCntOco == 0
		Aadd(aCntOco,{Pad(cOcorr,Len(SEB->EB_OCORR)),Subs(cDescr,1,27),nValPAG})
	Else                                         
		aCntOco[nCntOco][VALORPAGO]+=nValPag
	Endif
Endif

RestArea (aArea)

Return 
