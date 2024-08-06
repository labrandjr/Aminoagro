#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LCTOVIS   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/04/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lançamentos x Visões Gerenciais SIGAPCO.		  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LCTOVIS()

Local zFiltro := ""
Local aVisoes := {}
Local _x

Private cCadastro := "Lançamentos x Visões Gerenciais"

Private aRotina   := {{"Pesquisar"  , "AxPesqui"    , 0 , 1 },;
            	      {"Visualizar" , "AxVisual"    , 0 , 2 },;
            	      {"Imprimir"   , "U_ILANVIS()" , 0 , 3 }}

DbSelectArea("SZK")
DbSetOrder(1)
If DbSeek( xFilial("SZK") + __cUserId )
	While !Eof() .And. SZK->ZK_FILIAL == xFilial("SZK") .And. SZK->ZK_USER == __cUserId
		AAdd(aVisoes,SZK->ZK_VISAO)	
		SZK->(DbSkip())
	Enddo 
Endif

If Len(aVisoes) > 0
	For _x := 1 to Len(aVisoes)
		If _x == 1
			zFiltro := "AKN_CODIGO == '"+aVisoes[_x]+"' "
		Else
			zFiltro += ".Or. AKN_CODIGO == '"+aVisoes[_x]+"' "
		Endif
	Next _x
	DbSelectArea("AKN")
	Set Filter to &(zFiltro)
Endif

DbSelectArea("AKN")
DbSetOrder(1)
MBrowse(6,1,22,75,"AKN",,,)

Set Filter to

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ILANVIS  ¦ Autor ¦ Fábrica ERPBR   ¦   Data  ¦ 	07/04/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão dos lançamentos da Visão Gerencial.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ILANVIS()

Local oReport

oReport := ReportDef()

If oReport == Nil
	Return
Endif

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ReportDef ¦ Autor ¦  Luis Brandini   ¦   Data  ¦ 04/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa impressao do relatorio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReportDef()

Local oReport
Local oSection1

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
oReport := TReport():New("LCTOVIS","Lançamentos x Visão Gerencial","LCTOVIS",{|oReport| ReportPrint(oReport),"Este relatório irá imprimir os lançamentos da visão gerencial."})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,"Lançamentos da Visão Gerencial",{"LOG"},,.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1, "UNIORC" , "AKD", "Unidade"      , "@!"                , 010, , { || AKD->AKD_UNIORC } )
TRCell():New(oSection1, "DATALAN", "AKD", "Data"         , ""                  , 010, , { || AKD->AKD_DATA } )
TRCell():New(oSection1, "CONTA"  , "AKD", "C.O."         , "@!"                , 020, , { || AKD->AKD_CO } )
TRCell():New(oSection1, "DESCR"  , "AKD", "Descr.C.O."   , "@!"                , 100, , { || CT1->CT1_DESC01 } )
TRCell():New(oSection1, "CCUSTO" , "AKD", "C.C."         , "@!"                , 020, , { || AKD->AKD_CC } )
TRCell():New(oSection1, "DESCR"  , "AKD", "Descr.C.C"    , "@!"                , 100, , { || CTT->CTT_DESC01 } )
TRCell():New(oSection1, "ITEMCT" , "AKD", "B.U."         , "@!"                , 010, , { || AKD->AKD_ITCTB } )
TRCell():New(oSection1, "TIPO"   , "AKD", "Tipo Lancto." , "@!"                , 010, , { || IIf(AKD->AKD_TIPO=="1","Crédito","Débito") } )
TRCell():New(oSection1, "TPSALD" , "AKD", "Tipo Saldo"   , "@!"                , 010, , { || IIf(AKD->AKD_TPSALD=="OR","Orçado","Real") } )
TRCell():New(oSection1, "HISTOR" , "AKD", "Histórico"    , "@!"                , 200, , { || AKD->AKD_HIST } )
TRCell():New(oSection1, "VALOR"  , "AKD", "Valor R$"     , "@E 999,999,999.99" , 050, , { || IIf(AKD->AKD_TIPO=="1",AKD->AKD_VALOR1,AKD->AKD_VALOR1*-1) } )
TRCell():New(oSection1, "OBS"    , "AKD", "Observações"  , "@!"                , 200, , { || zObsPed } )

Return(oReport)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ReportPrint ¦ Autor ¦ Luis Brandini  ¦   Data  ¦ 04/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa impressao do relatorio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Lançamentos da Visão Gerencial | "+AKN->AKN_CODIGO+"-"+AllTrim(AKN->AKN_DESCRI)+"|"
oReport:cTitle := "Lançamentos da Visão Gerencial | "+AKN->AKN_CODIGO+"-"+AllTrim(AKN->AKN_DESCRI)+"|"

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("AKD")
cQuery += " WHERE AKD_FILIAL = '"+xFilial("AKD")+"' "
cQuery += " AND AKD_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND AKD_CO IN
cQuery += " (SELECT AKO_CO FROM "+RetSqlName("AKO")+" WHERE AKO_CODIGO = '"+AllTrim(AKN->AKN_CODIGO)+"' AND D_E_L_E_T_ <> '*') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TAKD", .F., .T.)
nTotReg := TAKD->SOMA
TAKD->(DbCloseArea())

cQuery := " SELECT R_E_C_N_O_ RECAKD "
cQuery += " FROM "+RetSqlName("AKD")
cQuery += " WHERE AKD_FILIAL = '"+xFilial("AKD")+"' "
cQuery += " AND AKD_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " AND AKD_CO IN
cQuery += " (SELECT AKO_CO FROM "+RetSqlName("AKO")+" WHERE AKO_CODIGO = '"+AllTrim(AKN->AKN_CODIGO)+"' AND D_E_L_E_T_ <> '*') "
cQuery += " ORDER BY AKD_FILIAL, AKD_UNIORC, AKD_CO, AKD_CC, AKD_ITCTB "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TAKD", .F., .T.)

DbSelectArea("TAKD")
TAKD->(DbGotop())
oReport:SetMeter(nTotReg)
oSection1:Init()
While !Eof()

	oReport:IncMeter()

	DbSelectArea("AKD")
	AKD->(DbGoto(TAKD->RECAKD))

	DbSelectArea("AKO")
	DbSetOrder(1)
	If DbSeek( xFilial("AKO") + AKN->AKN_CODIGO + AKD->AKD_CO )
		//
		DbSelectArea("CT1")
		DbSetOrder(1)
		DbSeek( xFilial("CT1") + AKD->AKD_CO )
		//
		DbSelectArea("CTT")
		DbSetOrder(1)
		DbSeek( xFilial("CTT") + AKD->AKD_CC )
		//
		zObsPed := ""
		DbSelectArea("CT2")
		DbSetOrder(1)
		If DbSeek( AllTrim(AKD->AKD_CHAVE) )
			If !Empty(CT2->CT2_KEY)
				DbSelectArea("SD1")
				DbSetOrder(1)
				If DbSeek( AllTrim(CT2->CT2_KEY) )
					If !Empty(SD1->D1_PEDIDO)
						DbSelectArea("SC7")
						DbSetOrder(1)
						If DbSeek( SD1->(D1_FILIAL+D1_PEDIDO+D1_ITEMPC) )
							zObsPed := AllTrim(SC7->C7_OBS)
						Endif
					Endif
				Endif
			Endif	
		Endif
		//
		oSection1:PrintLine()
		//
	Endif	

	DbSelectArea("TAKD")
	TAKD->(DbSkip())

	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif

	DbSelectArea("TAKD")
Enddo
TAKD->(DbCloseArea())

Return
