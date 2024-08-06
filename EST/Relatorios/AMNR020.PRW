#include "protheus.ch"
#include "topconn.ch"


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNR020  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 13/12/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Romaneio de Separação por Endereço.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNR020()

Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Eduardo Riera          ³ Data ³10.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef()

Local oReport
Local oCarga
Local oItCarga
Local oItPedido
Local oItPedido2
Local oItNF
Local oItNF2
Local lQuery  := .F.
Local cNReduz := ""

#IFDEF TOP
	Local cAliasDAK := GetNextAlias()
	Local cAliasDAI := cAliasDAK
	Local cAliasSC9 := cAliasDAK
	Local cAliasSD2 := cAliasDAK
#ELSE
	Local cAliasSC9 := "SC9"
	Local cAliasDAK := "DAK"
	Local cAliasDAI := "DAI"
	Local cAliasSD2 := "SD2"
#ENDIF

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
oReport := TReport():New("AMNR020","Romaneio de Separação","OMR020", {|oReport| ReportPrint(oReport,cAliasSC9,oItPedido,cAliasSD2,oITNF,oItPedido2,oItNF2,cAliasDAK,cAliasDAI,oCarga,cAliasSD2,@lQuery,cNReduz)},"Este relatorio ira imprimir a listagem de cargas de acordo com os parametros informados pelo usuario.")
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a secao.                   ³
//³ExpA4 : Array com as Ordens do relatorio                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatorio. O SX3 sera consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de codigo para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1)                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCarga:= TRSection():New(oReport,"Carga",{"DAK","DA3","DA4"},{"Pedido/Item","Produto"},/*Campos do SX3*/,/*Campos do SIX*/)
oCarga:SetTotalInLine(.F.)
TRCell():New(oCarga , "DAK_COD"    , "DAK" , "Carga"    , PesqPict("DAK","DAK_COD")   	, TamSx3("DAK_COD")[1]+1   	, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_SEQCAR" , "DAK" , "Seq."     , PesqPict("DAK","DAK_SEQCAR")	, TamSx3("DAK_COD")[1]     	, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_CAMINH" , "DAK" , /*Titulo*/ , PesqPict("DAK","DAK_CAMINH")	, TamSx3("DAK_CAMINH")[1]+3	, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DA3_DESC"   , "DA3" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_MOTORI" , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DA4_NOME"   , "DA4" , ""         , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_PESO"   , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_CAPVOL" , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_PTOENT" , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/	 			, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_VALOR"  , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_DATA"   , "DAK" , /*Titulo*/ , /*Picture*/					, TamSx3("DAK_DATA")[1]+6	, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_HORA"   , "DAK" , /*Titulo*/ , /*Picture*/					, TamSx3("DAK_HORA")[1]+4	, /*lPixel*/ , /*{|| code-block de impressao }*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1):Section(1)                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItCarga:= TRSection():New(oCarga,"Item da Carga",{"DAI","SA1","SF2"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItCarga:SetTotalInLine(.F.)
TRCell():New(oItCarga , "DAI_SEQUEN" ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_PEDIDO" ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_CLIENT" ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_LOJA"   ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "A1_NREDUZ"  ,      , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_PESO"   ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_CAPVOL" ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "F2_TIPODOC" ,"SF2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "F2_DOC"     ,"SF2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "F2_SERIE"   ,"SF2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 1                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1):Section(1):Section(1)                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItPedido:= TRSection():New(oItCarga,"Item da liberação do Pedido de venda",{"SC9","SB1","SC6","SD2","SDC","SF2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItPedido:SetTotalInLine(.F.)
TRCell():New(oItPedido , "C9_ITEM"    , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_PRODUTO" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_LOCAL"   , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_LOTECTL" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "DC_LOCALIZ" , "SDC" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
//TRCell():New(oItPedido , "C9_NUMLOTE" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "DC_QUANT"   , "SDC" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
//TRCell():New(oItPedido , "C9_QTDLIB2" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
//TRCell():New(oItPedido , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C6_VALOR"   , "SC6" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , {|| (cAliasSC9)->DC_QUANT*(cAliasSC9)->C9_PRCVEN })
TRCell():New(oItPedido , "D2_PESO"    , "SDC" , "Peso"     , PesqPict("SB1","B1_PESO") , /*Tamanho*/ , /*lPixel*/ , {||IIf(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*(cAliasSC9)->DC_QUANT})
TRCell():New(oItPedido , "F2_VOLUME1" , "SF2" , "Volume"   , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , {|| (cAliasSC9)->DC_QUANT / SBZ->BZ_QB })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1):Section(1):Section(2)                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItNF:= TRSection():New(oItCarga,"Item do documento de saída",{"SD2","SB1","SF2","SDB"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItNF:SetTotalInLine(.F.)
TRCell():New(oItNF , "D2_ITEM"    , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_COD"     , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_LOCAL"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_LOTECTL" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "DB_LOCALIZ" , "SDB" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItNF , "D2_NUMLOTE" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "DB_QUANT"   , "SDB" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItNF , "D2_QTSEGUM" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItNF , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_TOTAL"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_PESO"    , "SDB" , "Peso"     , PesqPict("SB1","B1_PESO") , /*Tamanho*/ , /*lPixel*/ , {||IIf(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*(cAliasSD2)->DB_QUANT})
TRCell():New(oItNF , "F2_VOLUME1" , "SF2" , "Volume"   , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| (cAliasSD2)->DB_QUANT / SBZ->BZ_QB } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 2                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Section(1):Section(2)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItPedido2:= TRSection():New(oCarga,"Item da liberação do Pedido de venda",{"SC9","SB1","SD2","SDC"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItPedido2:SetTotalInLine(.F.)
TRCell():New(oItPedido2 , "C9_PRODUTO" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C9_LOCAL"   , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C9_LOTECTL" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "DC_LOCALIZ" , "SDC" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItPedido2 , "C9_NUMLOTE" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "DC_QUANT"   , "SDC" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| IIF(MV_PAR11 == 1 .And. lQuery ,QTDE,(cAliasSC9)->DC_QUANT) })
TRCell():New(oItPedido2 , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItPedido2 , "C9_QTDLIB2" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| IIF(MV_PAR11 == 1 .And. lQuery ,QTDE2,(cAliasSC9)->C9_QTDLIB2) })
//TRCell():New(oItPedido2 , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C6_VALOR"   , "SC6" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| IIF(MV_PAR11 == 1 .And. lQuery,VALOR,(cAliasSC9)->DC_QUANT*(cAliasSC9)->C9_PRCVEN) })
TRCell():New(oItPedido2 , "D2_PESO"    , "SDC" , "Peso"     , PesqPict("SB1","B1_PESO") , /*Tamanho*/ , /*lPixel*/ , {|| IIF(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*(IIF(MV_PAR11 == 1 .And. lQuery,QTDE,(cAliasSC9)->DC_QUANT))})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Section(1):Section(3)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItNF2:= TRSection():New(oCarga,"Item do documento de saída",{"DAI","SD2","SDB","SB1","SF2"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItNF2:SetTotalInLine(.F.)
TRCell():New(oItNF2 , "D2_DOC"     , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_SERIE"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_ITEM"    , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_COD"     , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_LOCAL"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_LOTECTL" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "DB_LOCALIZ" , "SDB" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItNF2 , "D2_NUMLOTE" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "DB_QUANT"   , "SDB" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItNF2 , "D2_QTSEGUM" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
//TRCell():New(oItNF2 , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_TOTAL"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_PESO"    , "SDB" , "Peso"     , PesqPict("SB1","B1_PESO") , /*Tamanho*/ , /*lPixel*/ , {|| IIf(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*(cAliasSD2)->DB_QUANT })
TRCell():New(oItNF2 , "F2_VOLUME1" , "SF2" , "Volume"   , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| (cAliasSD2)->DB_QUANT / SBZ->BZ_QB } )

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Eduardo Riera          ³ Data ³04.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportPrint(oReport,cAliasSC9,oItPedido,cAliasSD2,oITNF,oItPedido2,oItNF2,cAliasDAK,cAliasDAI,oCarga,cAliasSD2,lQuery,cNReduz)

Local cFilPV    := ""
Local lRemito	:= DAI->(FieldPos("DAI_REMITO")) > 0 .And. DAI->(FieldPos("DAI_SERREM")) > 0
Local nTipoOper := OsVlEntCom()
Local cFilWhere	:= ""
#IFNDEF TOP
	Local cCondicao  := ""
#ELSE
	Local cQrySelect := "%%"
	Local cQryWhere  := ""
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

If MV_PAR11 == 2 .And. MV_PAR13 == 2 // Tipo do Relatório = Analitico | Carga por = Notas Fiscais ** Romaneio de Separação **
	If oReport:Section(1):nOrder == 1 // Ordem por Pedido
		oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),"Total da Carga",.F.)
		TRFunction():New(oItNF:Cell("DB_QUANT")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
//		TRFunction():New(oItNF:Cell("D2_QTSEGUM"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItNF:Cell("D2_TOTAL")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItNF:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItNF:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
	Else // Ordem por Produto
		oBreak := TRBreak():New(oItPedido,oItPedido:Cell("C9_PRODUTO" ),"TOTAL DO ITEM",.F.) 	// por Emissao
		TRFunction():New(oItPedido:Cell("DC_QUANT") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
//		TRFunction():New(oItPedido:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
		TRFunction():New(oItPedido:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
		TRFunction():New(oItPedido:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
		TRFunction():New(oItPedido:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)

		oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),"Total da Carga",.F.)
		TRFunction():New(oItPedido2:Cell("DC_QUANT") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
//		TRFunction():New(oItPedido2:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItPedido2:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItPedido2:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
	EndIf
Else // Sintetico
	If oReport:Section(1):nOrder == 2 // Por produto
		If MV_PAR13 == 2 // Carga por Nota
			oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),"Total da Carga",.F.)
			TRFunction():New(oItNF2:Cell("DB_QUANT")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
//			TRFunction():New(oItNF2:Cell("D2_QTSEGUM"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItNF2:Cell("D2_TOTAL")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItNF2:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItNF2:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		Else	// Carga por Pedido
			oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),"Total da Carga",.F.)
			TRFunction():New(oItPedido2:Cell("DC_QUANT") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
//			TRFunction():New(oItPedido2:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItPedido2:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItPedido2:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		EndIf
	Else	// Por Pedido	
		oBreak := TRBreak():New(oItPedido,oItPedido:Cell("C9_PRODUTO" ),"TOTAL DO ITEM",.F.)
		TRFunction():New(oItPedido:Cell("DC_QUANT") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
//		TRFunction():New(oItPedido:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
		TRFunction():New(oItPedido:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
		TRFunction():New(oItPedido:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
		TRFunction():New(oItPedido:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
		
		oReport:Section(1):Section(1):SetLinesBefore(0) //-- Quantidade de linhas saltadas antes da impressao da secao.
		oReport:Section(1):Section(1):SetHeaderPage(.T.) //-- Imprime o cabecalho no topo da pagina
	EndIf
EndIf

If	mv_par14 == 2 // Nao Imprimir Lote
	oReport:Section(1):Section(1):Section(1):Cell("C9_LOTECTL"):Disable()
//	oReport:Section(1):Section(1):Section(1):Cell("C9_NUMLOTE"):Disable()
	oReport:Section(1):Section(1):Section(2):Cell("D2_LOTECTL"):Disable()
//	oReport:Section(1):Section(1):Section(2):Cell("D2_NUMLOTE"):Disable()

	oReport:Section(1):Section(2):Cell("C9_LOTECTL"):Disable()
//	oReport:Section(1):Section(2):Cell("C9_NUMLOTE"):Disable()
	oReport:Section(1):Section(3):Cell("D2_LOTECTL"):Disable()
//	oReport:Section(1):Section(3):Cell("D2_NUMLOTE"):Disable()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	lQuery := .T.
	If cPaisLoc == "BRA"
		cQryWhere := "C9_NFISCAL = F2_DOC AND C9_SERIENF = F2_SERIE AND "
	EndIf
	cQryWhere := "%"+cQryWhere+"%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case

		Case oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 1	// Ordem = Pedido | Carga por = Pedido
			cQrySelect := ""
			If lRemito
				cQrySelect	+=	",DAI_REMITO,DAI_SERREM "
			EndIf
			If nTipoOper == 2 .Or. nTipoOper == 3
				cQrySelect += ",DAI_FILPV "
			EndIf

			If MV_PAR11 == 1 // Ordem = Pedido | Carga por = Pedido | Tipo do Relatorio = Sintetico - OK
				cQrySelect := "%"+cQrySelect+"%"
				oReport:Section(1):BeginQuery()
				BeginSQL Alias cAliasDAK
					SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,
							DAK_PTOENT,DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,
							DAI_CLIENT,DAI_LOJA,DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE
							%exp:cQrySelect%
					FROM %table:DAK% DAK ,%table:DAI% DAI
					WHERE DAK_FILIAL = %xFilial:DAK% AND 
							DAK_COD    >= %exp:mv_par01% AND 
							DAK_COD    <= %exp:mv_par02% AND 
							DAK_SEQCAR >= %exp:mv_par03% AND 
							DAK_SEQCAR <= %exp:mv_par04% AND 
							DAK_CAMINH >= %exp:mv_par05% AND 
							DAK_CAMINH <= %exp:mv_par06% AND 
							DAK_MOTORI >= %exp:mv_par07% AND 
							DAK_MOTORI <= %exp:mv_par08% AND 
							DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
							DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
							DAK.%NotDel% AND 
							DAI_FILIAL = %exp:xFilial("DAI")% AND 
							DAI_COD    = DAK.DAK_COD AND 
							DAI_SEQCAR = DAK.DAK_SEQCAR AND 
							DAI.%NotDel%
					ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN
				EndSQL
				oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
			Else // // Ordem = Pedido | Carga por = Pedido | Tipo do Relatorio = Analitico - OK
				cQrySelect := ""
				If cPaisLoc <> "BRA"
					cQrySelect += ",C9_REMITO "
				EndIf
				If nTipoOper == 2 .Or. nTipoOper == 3
					cQrySelect += ",DAI_FILPV "
				EndIf 
				cQrySelect := "%"+cQrySelect+"%"

				cFilWhere := Iif(nTipoOper == 1, xFilial("SC9"),"%"+OsFilQry("SC9","DAI.DAI_FILPV")+"%" )

				oReport:Section(1):BeginQuery()
				BeginSQL Alias cAliasDAK
					SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_HORA,
							DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,
							C9_FILIAL,C9_CLIENTE,C9_LOJA,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_PRODUTO,DC_QUANT,C9_PRCVEN,C9_CARGA,C9_SEQCAR,C9_NFISCAL,
							C9_SERIENF,C9_LOCAL,C9_LOTECTL,DC_LOCALIZ,B1_UM,B1_SEGUM
							%exp:cQrySelect%
					FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SC9% SC9 ,%table:SB1% SB1, %table:SDC% SDC
					WHERE DAK_FILIAL = %xFilial:DAK% AND 
							DAK_COD    >= %exp:mv_par01% AND 
							DAK_COD    <= %exp:mv_par02% AND 
							DAK_SEQCAR >= %exp:mv_par03% AND 
							DAK_SEQCAR <= %exp:mv_par04% AND 
							DAK_CAMINH >= %exp:mv_par05% AND 
							DAK_CAMINH <= %exp:mv_par06% AND 
							DAK_MOTORI >= %exp:mv_par07% AND 
							DAK_MOTORI <= %exp:mv_par08% AND 
							DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
							DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
							DAK.%NotDel% AND 
							DAI_FILIAL = %exp:xFilial("DAI")% AND 
							DAI_COD    = DAK_COD AND 
							DAI_SEQCAR = DAK_SEQCAR AND 
							DAI.%NotDel% AND 
							B1_FILIAL  = %exp:xFilial("SB1")% AND 
							B1_COD = C9_PRODUTO AND
							SB1.%NotDel% AND 
							C9_FILIAL  = %exp:cFilWhere% AND 
							C9_PEDIDO  = DAI_PEDIDO AND 
							C9_CLIENTE = DAI_CLIENT AND 
							C9_LOJA    = DAI_LOJA   AND 
							C9_CARGA   = DAI_COD    AND 
							C9_SEQCAR  = DAI_SEQCAR AND 
							SC9.%NotDel% AND
							DC_FILIAL  = %exp:cFilWhere% AND 
							DC_PEDIDO  = C9_PEDIDO AND 
							DC_ITEM    = C9_ITEM AND 
							DC_SEQ     = C9_SEQUEN AND 
							DC_ORIGEM  = 'SC6' AND 
							SDC.%NotDel%
					ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN,C9_PEDIDO,C9_ITEM,C9_SEQUEN
				EndSQL
				oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
			EndIf

			oReport:Section(1):Section(1):SetParentQuery()
			oReport:Section(1):Section(1):Section(1):SetParentQuery()

		Case oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 1	// Ordem por = Produto | Carga por = Pedido
			cQrySelect := ""
			
			If nTipoOper == 2 .Or. nTipoOper == 3
				cQrySelect += ",DAI_FILPV "
			EndIf 
			cQrySelect := "%"+cQrySelect+"%"

			If mv_par11 == 2 // Ordem por = Produto | Carga por = Pedido | Tipo do Relatorio = Analitico - OK
				cFilWhere := Iif(nTipoOper == 1, xFilial("SC9"),"%"+OsFilQry("SC9","DAI.DAI_FILPV")+"%" )
				oReport:Section(1):BeginQuery()
				BeginSQL Alias cAliasDAK
					SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
							DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,
							DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,C9_FILIAL,C9_CLIENTE,C9_LOJA,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_PRODUTO,
							DC_QUANT,C9_PRCVEN,C9_CARGA,C9_SEQCAR,C9_NFISCAL,C9_SERIENF,C9_LOCAL,C9_LOTECTL,DC_LOCALIZ,B1_UM,B1_SEGUM
							%exp:cQrySelect%
					FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SC9% SC9 ,%table:SB1% SB1 ,%table:SDC% SDC
					WHERE DAK_FILIAL = %xFilial:DAK% AND 
							DAK_COD    >= %exp:mv_par01% AND 
							DAK_COD    <= %exp:mv_par02% AND 
							DAK_SEQCAR >= %exp:mv_par03% AND 
							DAK_SEQCAR <= %exp:mv_par04% AND 
							DAK_CAMINH >= %exp:mv_par05% AND 
							DAK_CAMINH <= %exp:mv_par06% AND 
							DAK_MOTORI >= %exp:mv_par07% AND 
							DAK_MOTORI <= %exp:mv_par08% AND 
							DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
							DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
							DAK.%NotDel% AND 
							DAI_FILIAL = %exp:xFilial("DAI")% AND 
							DAI_COD    = DAK_COD AND 
							DAI_SEQCAR = DAK_SEQCAR AND 
							DAI.%NotDel% AND
							B1_FILIAL  = %exp:xFilial("SB1")% AND 
							B1_COD = C9_PRODUTO AND
							SB1.%NotDel% AND 
							C9_FILIAL  = %exp:cFilWhere% AND 
							C9_PEDIDO  = DAI_PEDIDO AND 
							C9_CLIENTE = DAI_CLIENT AND 
							C9_LOJA    = DAI_LOJA AND 
							C9_CARGA   = DAI_COD AND 
							C9_SEQCAR  = DAI_SEQCAR AND 
							SC9.%NotDel% AND
							DC_FILIAL  = %exp:cFilWhere% AND 
							DC_PEDIDO  = C9_PEDIDO AND 
							DC_ITEM    = C9_ITEM AND 
							DC_SEQ     = C9_SEQUEN AND 
							DC_ORIGEM  = 'SC6' AND 
							SDC.%NotDel%
					ORDER BY C9_FILIAL,C9_CARGA,C9_SEQCAR,C9_PRODUTO,DC_LOCALIZ
				EndSql
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Metodo EndQuery ( Classe TRSection )                                    ³
				//³                                                                        ³
				//³Prepara o relatório para executar o Embedded SQL.                       ³
				//³                                                                        ³
				//³ExpA1 : Array com os parametros do tipo Range                           ³
				//³                                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
				oReport:Section(1):Section(2):SetParentQuery()
			Else // Ordem por = Produto | Carga por = Pedido | Tipo do Relatorio = Sintético - OK
				cQrySelect := ""

				If nTipoOper == 2 .Or. nTipoOper == 3
					cQrySelect += ",DAI_FILPV "
				EndIf 
				cQrySelect := "%"+cQrySelect+"%"

				cFilWhere := Iif(nTipoOper == 1, xFilial("SC9"),"%"+OsFilQry("SC9","DAI.DAI_FILPV")+"%" )

				oReport:Section(1):BeginQuery()
				BeginSQL Alias cAliasDAK
					SELECT C9_FILIAL,C9_CARGA,C9_SEQCAR,DAK_COD,DAK_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,
							DAK_PTOENT,DAK_VALOR,DAK_PESO,DAK_HORA,C9_PRODUTO,C9_LOCAL,C9_LOTECTL,DC_LOCALIZ,B1_PESO,B1_PESBRU,
							SUM(DC_QUANT)QTDE,SUM(DC_QUANT*C9_PRCVEN)VALOR,B1_UM,B1_SEGUM
							%exp:cQrySelect%
					FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SC9% SC9 ,%table:SB1% SB1 ,%table:SDC% SDC
					WHERE DAK_FILIAL = %xFilial:DAK% AND 
							DAK_COD    >= %exp:mv_par01% AND 
							DAK_COD    <= %exp:mv_par02% AND 
							DAK_SEQCAR >= %exp:mv_par03% AND 
							DAK_SEQCAR <= %exp:mv_par04% AND 
							DAK_CAMINH >= %exp:mv_par05% AND 
							DAK_CAMINH <= %exp:mv_par06% AND 
							DAK_MOTORI >= %exp:mv_par07% AND 
							DAK_MOTORI <= %exp:mv_par08% AND 
							DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
							DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
							DAK.%NotDel% AND 
							DAI_FILIAL = %exp:xFilial("DAI")% AND 
							DAI_COD    = DAK_COD AND 
							DAI_SEQCAR = DAK_SEQCAR AND 
							DAI.%NotDel% AND 
							C9_FILIAL  = %exp:cFilWhere% AND 
							C9_PEDIDO  = DAI_PEDIDO AND 
							C9_CLIENTE = DAI_CLIENT AND 
							C9_LOJA    = DAI_LOJA AND 
							C9_CARGA   = DAI_COD AND 
							C9_SEQCAR  = DAI_SEQCAR AND
							SC9.%NotDel% AND
							DC_FILIAL  = %exp:cFilWhere% AND 
							DC_PEDIDO  = C9_PEDIDO AND 
							DC_ITEM    = C9_ITEM AND 
							DC_SEQ     = C9_SEQUEN AND 
							DC_ORIGEM  = 'SC6' AND 
							SDC.%NotDel% AND
							B1_FILIAL  = %exp:xFilial("SB1")% AND 
							B1_COD     = SC9.C9_PRODUTO AND 
							SB1.%NotDel%
					GROUP BY
							C9_FILIAL,C9_CARGA,C9_SEQCAR,DAK_COD,DAK_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,
							DAK_PTOENT,DAK_VALOR,DAK_PESO,DAK_HORA,C9_PRODUTO,C9_LOCAL,C9_LOTECTL,DC_LOCALIZ,B1_PESO,B1_PESBRU,B1_UM,B1_SEGUM
							%exp:cQrySelect%
				EndSQL
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Metodo EndQuery ( Classe TRSection )                                    ³
				//³                                                                        ³
				//³Prepara o relatório para executar o Embedded SQL.                       ³
				//³                                                                        ³
				//³ExpA1 : Array com os parametros do tipo Range                           ³
				//³                                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
				oReport:Section(1):Section(2):SetParentQuery()
			EndIf

		Case oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 2	// Ordem por = Produto | Carga por = Nota Fiscal
			cQrySelect := ""

			If nTipoOper == 2 .Or. nTipoOper == 3
				cQrySelect += ",DAI_FILPV "
			EndIf 
			cQrySelect := "%"+cQrySelect+"%"

			cFilWhere := Iif(nTipoOper == 1, xFilial("SD2"),"%"+OsFilQry("SD2","DAI.DAI_FILPV")+"%" )

			oReport:Section(1):BeginQuery()
			BeginSQL Alias cAliasDAK
				SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
						DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,
						DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,C9_NFISCAL,C9_SERIENF,
						D2_PEDIDO,D2_ITEMPV,D2_ITEM,D2_COD,DB_QUANT,D2_QTSEGUM,D2_LOCAL,D2_LOTECTL,DB_LOCALIZ,(DB_QUANT*D2_PRCVEN)D2_TOTAL,B1_UM,B1_SEGUM
						%exp:cQrySelect%
				FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SD2% SD2 ,%table:SF2% SF2 ,%table:SC9% SC9 ,%table:SB1% SB1 ,%table:SDB% SDB
				WHERE DAK_FILIAL = %xFilial:DAK% AND 
						DAK_COD    >= %exp:mv_par01% AND 
						DAK_COD    <= %exp:mv_par02% AND 
						DAK_SEQCAR >= %exp:mv_par03% AND 
						DAK_SEQCAR <= %exp:mv_par04% AND 
						DAK_CAMINH >= %exp:mv_par05% AND 
						DAK_CAMINH <= %exp:mv_par06% AND 
						DAK_MOTORI >= %exp:mv_par07% AND 
						DAK_MOTORI <= %exp:mv_par08% AND 
						DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
						DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
						DAK.%NotDel% AND 
						DAI_FILIAL = %exp:xFilial("DAI")% AND 
						DAI_COD    = DAK.DAK_COD AND 
						DAI_SEQCAR = DAK.DAK_SEQCAR AND 
						DAI_PEDIDO = D2_PEDIDO  AND
						DAI.%NotDel% AND 
						F2_FILIAL  = %exp:cFilWhere% AND 
						F2_CARGA   = DAI_COD AND 
						F2_SEQCAR  = DAI_SEQCAR AND 
						SF2.%NotDel% AND 
						D2_FILIAL  = %exp:cFilWhere% AND 
						D2_DOC     = F2_DOC AND 
						D2_SERIE   = F2_SERIE AND 
						D2_CLIENTE = F2_CLIENTE AND 
						D2_LOJA    = F2_LOJA AND 
						SD2.%NotDel%  AND
						D2_DOC     = DB_DOC AND
						D2_SERIE   = DB_SERIE AND
						D2_COD     = DB_PRODUTO AND
						D2_NUMSEQ  = DB_NUMSEQ AND
						D2_LOTECTL = DB_LOTECTL AND
						SDB.%NotDel% AND
						C9_FILIAL  = %exp:cFilWhere% AND 
						C9_PEDIDO  = D2_PEDIDO AND 
						C9_ITEM    = D2_ITEMPV AND 
						C9_LOTECTL = D2_LOTECTL AND
						C9_BLEST   = '10' AND
						%exp:cQryWhere%
						SC9.%NotDel% AND
						B1_FILIAL  = %exp:xFilial("SB1")% AND 
						B1_COD     = D2_COD AND 
						SB1.%NotDel%
				ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,D2_COD
			EndSQL
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Metodo EndQuery ( Classe TRSection )                                    ³
				//³                                                                        ³
				//³Prepara o relatório para executar o Embedded SQL.                       ³
				//³                                                                        ³
				//³ExpA1 : Array com os parametros do tipo Range                           ³
				//³                                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)	
				oReport:Section(1):Section(3):SetParentQuery()	

		Case oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 2	// Ordem por = Pedido | Carga por = Nota Fiscal
			cQrySelect := ""
			If lRemito
				cQrySelect	+=	",DAI_REMITO,DAI_SERREM "
			EndIf
			If nTipoOper == 2 .Or. nTipoOper == 3
				cQrySelect += ",DAI_FILPV "
			EndIf

			cFilWhere := Iif(nTipoOper == 1, xFilial("SD2"),"%"+OsFilQry("SD2","DAI.DAI_FILPV")+"%" )

			If	MV_PAR11 == 1	// Ordem = Pedido | Tipo do Relatorio = Sintetico | Carga por = Nota Fiscal
				cQrySelect := "%"+cQrySelect+"%"
				oReport:Section(1):BeginQuery()
				BeginSQL Alias cAliasDAK
					SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
							DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,
							DAI_LOJA,DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,D2_DOC,D2_SERIE,F2_DOC,F2_SERIE,F2_TIPODOC
							%exp:cQrySelect%
					FROM %table:DAK% DAK ,%table:DAI% DAI, %table:SD2% SD2, %table:SF2% SF2 
					WHERE DAK_FILIAL = %xFilial:DAK% AND 
							DAK_COD    >= %exp:mv_par01% AND 
							DAK_COD    <= %exp:mv_par02% AND 
							DAK_SEQCAR >= %exp:mv_par03% AND 
							DAK_SEQCAR <= %exp:mv_par04% AND 
							DAK_CAMINH >= %exp:mv_par05% AND 
							DAK_CAMINH <= %exp:mv_par06% AND 
							DAK_MOTORI >= %exp:mv_par07% AND 
							DAK_MOTORI <= %exp:mv_par08% AND 
							DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
							DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
							DAK_FEZNF  = '1' AND 
							DAK.%NotDel% AND 
							DAI_FILIAL = %exp:xFilial("DAI")% AND 
							DAI_COD    = DAK_COD AND 
							DAI_SEQCAR = DAK_SEQCAR AND 
							DAI.%NotDel% AND 
							D2_FILIAL  = %exp:cFilWhere% AND 
							D2_PEDIDO  = DAI_PEDIDO AND 
							D2_CLIENTE = DAI_CLIENT AND 
							D2_LOJA    = DAI_LOJA AND
							D2_DOC     = F2_DOC AND 
							D2_SERIE   = F2_SERIE AND 
							SD2.%NotDel% 
					ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN
				EndSQL
				oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
			Else	// Ordem = Pedido | Tipo do Relatorio = Analitico | Carga por = Nota Fiscal - **Romaneio de Separação**
				cQrySelect := ""
				If cPaisLoc <> "BRA"
					cQrySelect += ",D2_REMITO "
				EndIf
				If nTipoOper == 2 .Or. nTipoOper == 3
					cQrySelect += ",DAI_FILPV "
				EndIf

				cQrySelect := "%"+cQrySelect+"%"

				cFilWhere := Iif(nTipoOper == 1, xFilial("SD2"),"%"+OsFilQry("SD2","DAI.DAI_FILPV")+"%" )

				oReport:Section(1):BeginQuery()
				BeginSQL Alias cAliasDAK
					SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
							DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,
							DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_PEDIDO,
							D2_ITEMPV,D2_ITEM,D2_COD,DB_QUANT,(DB_QUANT*D2_PRCVEN)AS D2_TOTAL,D2_LOCAL,D2_LOTECTL,DB_LOCALIZ,F2_DOC,F2_SERIE,F2_TIPODOC,B1_UM,B1_SEGUM
							%exp:cQrySelect%
					FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SD2% SD2, %table:SF2% SF2, %table:SB1% SB1, %table:SDB% SDB
					WHERE DAK_FILIAL = %xFilial:DAK% AND 
							DAK_COD    >= %exp:mv_par01% AND 
							DAK_COD    <= %exp:mv_par02% AND 
							DAK_SEQCAR >= %exp:mv_par03% AND 
							DAK_SEQCAR <= %exp:mv_par04% AND 
							DAK_CAMINH >= %exp:mv_par05% AND 
							DAK_CAMINH <= %exp:mv_par06% AND 
							DAK_MOTORI >= %exp:mv_par07% AND 
							DAK_MOTORI <= %exp:mv_par08% AND 
							DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
							DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
							DAK_FEZNF  = '1' AND 
							DAK.%NotDel% AND 
							DAI_FILIAL = %Exp:xFilial("DAI")% AND 
							DAI_COD    = DAK_COD AND 
							DAI_SEQCAR = DAK_SEQCAR AND 
							DAI_PEDIDO = D2_PEDIDO  AND 
							DAI.%NotDel% AND 
							F2_FILIAL  = %exp:cFilWhere% AND 
							F2_CLIENTE = DAI_CLIENT AND
							F2_LOJA    = DAI_LOJA AND
							F2_CARGA   = DAI_COD AND 
							F2_SEQCAR  = DAI_SEQCAR AND 
							F2_CARGA   = DAK_COD AND 
							SF2.%NotDel% AND 
							D2_FILIAL  = %exp:cFilWhere% AND 
							D2_DOC     = F2_DOC AND 
							D2_SERIE   = F2_SERIE AND 
							D2_TIPO    = F2_TIPO AND 
							D2_CLIENTE = F2_CLIENTE AND 
							D2_LOJA    = F2_LOJA AND 
							SD2.%NotDel% AND
							DB_FILIAL  = %exp:cFilWhere% AND 
							D2_DOC     = DB_DOC AND
							D2_SERIE   = DB_SERIE AND
							D2_COD     = DB_PRODUTO AND
							D2_NUMSEQ  = DB_NUMSEQ AND
							D2_LOTECTL = DB_LOTECTL AND
							SDB.%NotDel% AND
							B1_FILIAL  = %exp:xFilial("SB1")% AND 
							B1_COD     = D2_COD AND 
							SB1.%NotDel% 
					ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN,D2_DOC,D2_ITEM
				EndSQL
				oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
			EndIf
			oReport:Section(1):Section(1):SetParentQuery()
			oReport:Section(1):Section(1):Section(2):SetParentQuery()
	EndCase
#ELSE
	DbSelectArea(cAliasDAK)
	DbSetOrder(1)

	cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.' 
	cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
	cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
	cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'
	cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'
	cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'"'

	oReport:Section(1):SetFilter(cCondicao,(cAliasDAK)->(IndexKey()))

	If	MV_PAR13 <> 2 .Or. oReport:Section(1):nOrder <> 2
		oReport:Section(1):Section(1):SetRelation({|| xfilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}, cAliasDAI , 1 , .T. )
	EndIf

	If oReport:Section(1):nOrder == 1	// Ordem por Pedido
		If	MV_PAR13 == 1	// Carga por: Pedido
			oReport:Section(1):Section(1):Section(1):SetRelation({|| OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA+(cAliasDAI)->DAI_PEDIDO}, cAliasSC9 , 2 , .T. )
		Else				// carga por: Nota Fiscal
			oReport:Section(1):Section(1):Section(2):SetRelation({|| OsFilial("SD2",cFilPv)+(cAliasDAk)->D2_DOC+(cAliasDAK)->D2_SERIE}, cAliasSD2, 3 , .T. )
			oReport:Section(1):Section(1):SetLineConditional({ || !Empty((cAliasDAI)->DAI_NFISCA)  })
			oReport:Section(1):SetLineConditional({ || (cAliasDAK)->DAK_FEZNF = '1'  })
		EndIf
	Else	// Ordem por Produto
		If MV_PAR13 == 1	// Carga por: Pedido
			oReport:Section(1):Section(2):SetRelation({|| OsFilial("SC9",cFilPv)+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}, cAliasSC9 , 5 , .T. )
		Else				// carga por: Nota Fiscal
			//oReport:Section(1):Section(3):SetRelation({|| OsFilial("SD2",cFilPv)+(cAliasDAI)->DAI_NFISCA+(cAliasDAI)->DAI_SERIE}, cAliasSD2, 3 , .T. )
		EndIf
	EndIf

#ENDIF

If oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem Pedido, Carga por Pedido                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(1):SetParentFilter({|x| (cAliasDAI)->DAI_FILIAL+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == x})
	oReport:Section(1):Section(1):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),xFilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}

	oReport:Section(1):Section(1):Section(1):SetParentFilter({|x|(cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_CLIENTE+(cAliasSC9)->C9_LOJA+(cAliasSC9)->C9_PEDIDO == x})
	oReport:Section(1):Section(1):Section(1):bParentParam := {||OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA+(cAliasDAI)->DAI_PEDIDO}
ElseIf	oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 2
	// ** Romaneio de Separação **
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem por Pedido, Carga por Nota Fiscal                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(1):SetParentFilter({|x| (cAliasDAI)->DAI_FILIAL+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == x})
	oReport:Section(1):Section(1):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),xFilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}

	oReport:Section(1):Section(1):Section(2):SetParentFilter({|x|(cAliasDAK)->D2_FILIAL+(cAliasDAK)->D2_DOC+(cAliasDAK)->D2_SERIE == x})
	oReport:Section(1):Section(1):Section(2):bParentParam := {||OsFilial("SD2",cFilPv)+(cAliasDAK)->D2_DOC+(cAliasDAK)->D2_SERIE}
ElseIf	oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem por Produto, Carga por Pedido                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(2):SetParentFilter({|x|(cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_CARGA+(cAliasSC9)->C9_SEQCAR == x})
	oReport:Section(1):Section(2):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),OsFilial("SC9",cFilPv)+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}
ElseIf	oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem por Produto, Carga por Nota Fiscal                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	MV_PAR13 <> 2 .Or. oReport:Section(1):nOrder <> 2 .Or. lQuery
		oReport:Section(1):Section(3):SetParentFilter({|x|(cAliasSD2)->D2_FILIAL+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR == x})
		oReport:Section(1):Section(3):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),OsFilial("SD2",cFilPv)+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desliga e liga as section com base na ordem do relatorio.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	oReport:Section(1):nOrder == 1
	oReport:Section(1):Section(1):Enable()
	oReport:Section(1):Section(2):Disable()
	oReport:Section(1):Section(3):Disable()
	If	MV_PAR13 == 1 		// Carga por: Pedido
		oReport:Section(1):Section(1):Section(2):Disable()
		If	MV_PAR11 == 1	// Sintetico
			oReport:Section(1):Section(1):Section(1):Disable()
		EndIf
	Else					// Carga por: Nota Fiscal
		oReport:Section(1):Section(1):Section(1):Disable()	
		If	MV_PAR11 == 1 	// Sintetico
			oReport:Section(1):Section(1):Section(2):Disable()
		EndIf
	EndIf
Else
	oReport:Section(1):Section(1):Section(1):Disable()
	oReport:Section(1):Section(1):Section(2):Disable()
	If	MV_PAR13 == 1	// Carga por: Pedido
		oReport:Section(1):Section(1):Disable()
		oReport:Section(1):Section(2):Enable()		// Habilita por Pedido
		oReport:Section(1):Section(3):Disable()	// Desabilita por Nota
	Else				// Carga por: Nota Fiscal
		oReport:Section(1):Section(1):Hide()
		oReport:Section(1):Section(2):Disable()	// Desabilita por Pedido
		oReport:Section(1):Section(3):Enable()		// Habilita por nota
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ³
//³                                                                        ³
//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
//³realizado antes da impressao de cada linha do relatorio.                ³
//³                                                                        ³
//³                                                                        ³
//³ExpO1 : Objeto Report da Secao                                          ³
//³ExpC2 : Alias da Tabela                                                 ³
//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
//³ExpX4 : String ou Bloco de codigo para pesquisa. A string sera macroexe-³
//³        cutada.                                                         ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 1                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 2	// Ordem por = Pedido | Carga por = Nota Fiscal
	oReport:Section(1):Section(1):Cell("F2_TIPODOC"):SetBlock({|| IIf(IsRemito(1,"'"+(cAliasDAK)->F2_TIPODOC+"'"),"(2)","(1)")})
EndIf
oReport:Section(1):Section(1):Cell("A1_NREDUZ" ):SetBlock({|| cNReduz})
TRPosition():New(oReport:Section(1),"DA3",1,{|| xFilial("DA3")+(cAliasDAK)->DAK_CAMINH })
TRPosition():New(oReport:Section(1),"DA4",1,{|| xFilial("DA4")+(cAliasDAK)->DAK_MOTORI })
TRPosition():New(oReport:Section(1):Section(1),"SC5",1,{|| BuscaNome(OsFilial("SC5",cFilPv)+(cAliasDAI)->DAI_PEDIDO,@cNReduz)})

If	MV_PAR13 == 1 // Por Pedido
	If	MV_PAR11 == 1    // Sintetico
		TRPosition():New(oReport:Section(1):Section(1),"SF2",1,{|| OsFilial("SD2",cFilPv)+(cAliasDAK)->DAI_NFISCA+(cAliasDAK)->DAI_SERIE+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA})
	ElseIf MV_PAR11 == 2 // Analitico 
		TRPosition():New(oReport:Section(1):Section(1),"SF2",1,{|| OsFilial("SD2",cFilPv)+(cAliasDAK)->C9_NFISCAL+(cAliasDAK)->C9_SERIENF+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA})	
	EndIf
EndIf

TRPosition():New(oReport:Section(1):Section(1):Section(1),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSC9)->C9_PRODUTO})
TRPosition():New(oReport:Section(1):Section(1):Section(2),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSD2)->D2_COD})
TRPosition():New(oReport:Section(1):Section(1):Section(1),"SBZ",1,{|| OsFilial("SBZ",cFilPv)+(cAliasSC9)->C9_PRODUTO})
TRPosition():New(oReport:Section(1):Section(1):Section(2),"SBZ",1,{|| OsFilial("SBZ",cFilPv)+(cAliasSD2)->D2_COD})
TRPosition():New(oReport:Section(1):Section(1),"SA1",1,{|| OsFilial("SA1",cFilPv) + SC5->C5_CLIENTE + SC5->C5_LOJACLI })

oReport:Section(1):Section(1):Section(1):Cell("F2_VOLUME1"):SetBlock({|| (cAliasSC9)->DC_QUANT / SBZ->BZ_QB })
oReport:Section(1):Section(1):Section(2):Cell("F2_VOLUME1"):SetBlock({|| (cAliasSD2)->DB_QUANT / SBZ->BZ_QB })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 2                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oReport:Section(1):Section(2),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSC9)->C9_PRODUTO})
TRPosition():New(oReport:Section(1):Section(3),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSD2)->D2_COD})
TRPosition():New(oReport:Section(1):Section(2),"SBZ",1,{|| OsFilial("SBZ",cFilPv)+(cAliasSC9)->C9_PRODUTO})
TRPosition():New(oReport:Section(1):Section(3),"SBZ",1,{|| OsFilial("SBZ",cFilPv)+(cAliasSD2)->D2_COD})
TRPosition():New(oReport:Section(1):Section(3),"SF2",1,{|| OsFilial("SF2",cFilPv)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(DAK->(LastRec()))
If	MV_PAR12 == 1
	oReport:Section(1):SetPageBreak()
EndIf

If	MV_PAR13 <> 2 .Or. oReport:Section(1):nOrder <> 2 .Or. lQuery
	oReport:Section(1):Print()
Else

	DbSelectArea("DAK")
	oReport:SetMeter((cAliasDAK)->(LastRec()))
	While !oReport:Cancel() .And. !(cAliasDAK)->(Eof())

		oReport:Section(1):Init()
		oReport:Section(1):Section(3):Init()
		oReport:Section(1):PrintLine()
		DbSelectArea(cAliasDAI)
		DbSetOrder(1)
		MSSeek(xFilial("DAI")+ (cALiasDAK)->DAK_COD + (cALiasDAK)->DAK_SEQCAR)
		While !oReport:Cancel() .And. !(cAliasDAI)->(Eof()) .And. (cALiasDAK)->DAK_COD + (cALiasDAK)->DAK_SEQCAR == (cALiasDAI)->DAI_COD + (cALiasDAI)->DAI_SEQCAR

			DbSelectArea(cAliasSD2)
			DbSetOrder(3)
			MSSeek(xFilial("SD2")+ (cAliasDAI)->DAI_NFISCA+(cAliasDAI)->DAI_SERIE)
			While !oReport:Cancel() .And. !(cAliasDAI)->(Eof()) .And. (cAliasDAI)->DAI_NFISCA+(cAliasDAI)->DAI_SERIE == (cAliasSD2)->D2_DOC + (cAliasSD2)->D2_SERIE
				
				DbSelectArea("SDB")
				DbSetOrder(1)
				If DbSeek( xFilial("SDB") + (cAliasSD2)->D2_COD + (cAliasSD2)->D2_LOCAL + (cAliasSD2)->D2_NUMSEQ + (cAliasSD2)->D2_DOC + (cAliasSD2)->D2_SERIE + (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA )
					//MsgInfo("Achei "+SDB->DB_NUMSEQ)
				Endif

				oReport:Section(1):Section(3):PrintLine()
				DbSelectArea(cAliasSD2)
				DbSkip()
			EndDo

			dbSelectAre(cAliasDAI)
			dbSkip()
		EndDo

		oReport:Section(1):Finish()
		oReport:Section(1):Section(3):Finish()

		dbSelectAre(cAliasDAK)
		dbSkip()
	EndDo
EndIf

RetIndex("SC9")
RetIndex("SD2")
RetIndex("SDB")
RetIndex("DAK")
RetIndex("DAI")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaNome   ºAutor  ³Marco Bianchi       º Data ³ 19/11/2007º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca nome do cliente/fornecedor dependendo do tipo do     º±±
±±º          ³ pedido de vendas.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Filial_Numero do pedido de vendas                    º±±
±±º          ³ExpC2: Nome do cliente/fornececor                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8/P10                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function BuscaNome(cChave,cNReduz)

DbSelectArea("SC5")
DbSetOrder(1)
If DbSeek(cChave)
	If !SC5->C5_TIPO $ "BD"
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNReduz := SA1->A1_NREDUZ
	Else
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNReduz := SA2->A2_NREDUZ
	EndIf
EndIf

Return( cChave )
