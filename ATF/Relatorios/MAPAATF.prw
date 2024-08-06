#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MAPAATF  ¦ Autor ¦   ERPBR		    ¦   Data  ¦ ABR/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressao de Mapa Ativo Fixo                       		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MAPAATF()

Local oReport
Private cPerg := PadR("MAPAATF",10)
Private oTempTable

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
¦¦¦Programa  ¦ ReportDef ¦ Autor ¦  ERPBR           ¦   Data  ¦ ABRIL/17  ¦¦¦
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
Local oSection2
Local oSection3 
Local cPictTit	:= PesqPict("SN4","N4_VLROC1")
Local nTamVal	:= TamSx3("N4_VLROC1")[1]

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
oReport := TReport():New("MAPAATF","Mapa do Ativo", "MAPAATF", {|oReport| ReportPrint(oReport), "Este relatório irá imprimir a movimentação por conta contábil do ativo fixo."})

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
oSection1 := TRSection():New(oReport,"MAPA DO ATIVO",{"TRA","TRB","SN4","CT1"},,.F.,.F.)

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

TRCell():New(oSection1, "CODCTA", "TRB", "Código" ,		 	"@!" , 		20,  , 		{ || TRB->CTABEM } )
TRCell():New(oSection1, "DESCTA", "TRB", "Descrição" ,		"@!" , 		40,  ,		{ || TRB->DESBEM } )
TRCell():New(oSection1, "SLDINI", "TRB", "Saldo Inicial" ,	cPictTit , 	nTamVal,  , { || TRB->SLDINI } )
TRCell():New(oSection1, "BAIXAS", "TRB", "Baixas" ,			cPictTit , 	nTamVal,  , { || TRB->BAIXAS } )
TRCell():New(oSection1, "AQUISI", "TRB", "Aquisições" ,		cPictTit , 	nTamVal,  , { || TRB->AQUISI } )
TRCell():New(oSection1, "DEPREC", "TRB", "Despreciações" ,	cPictTit , 	nTamVal,  , { || TRB->DEPREC } )
TRCell():New(oSection1, "SLDFIM", "TRB", "Saldo Final" ,	cPictTit , 	nTamVal,  , { || TRB->SLDINI - TRB->BAIXAS + TRB->AQUISI - TRB->DEPREC } )

Return(oReport)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ReportPrint ¦ Autor ¦ ERPBR          ¦   Data  ¦ ABRIL/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa impressao do relatorio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo MIRASSOL  										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReportPrint(oReport)

Local cProAnt   := ""
Local lProOk    := .F.
Local oSection1 := oReport:Section(1)
Local _aCampos  := {}
Local nA		:= 0
Local zAlias    := "TRB"
Local cQuery

MakeAdvplExpr(oReport:uParam)

oReport:cRealTitle := "Mapa Ativo"
oReport:cTitle := "Mapa Ativo"

oTempTable := FWTemporaryTable():New( zAlias )

aAdd( _aCampos , { "FILIAL" , "C", 04, 0 }) 
aAdd( _aCampos , { "CTABEM" , "C", 20, 0 }) 
aAdd( _aCampos , { "DESBEM" , "C", 40, 0 })
aAdd( _aCampos , { "CTADEP" , "C", 20, 0 }) 
aAdd( _aCampos , { "DESDEP" , "C", 40, 0 })
aAdd( _aCampos , { "SLDINI" , "N", 16, 2 })
aAdd( _aCampos , { "BAIXAS" , "N", 16, 2 })
aAdd( _aCampos , { "AQUISI" , "N", 16, 2 })
aAdd( _aCampos , { "DEPREC" , "N", 16, 2 })  
aAdd( _aCampos , { "SLDFIM" , "N", 16, 2 })  

oTemptable:SetFields( _aCampos )
oTempTable:AddIndex("indice1", {"FILIAL", "CTABEM"})
oTempTable:AddIndex("indice2", {"FILIAL", "CTADEP"})

oTempTable:Create()

//===== Carregamento Ativos ===============================================================
If Select("TRA") > 0
	TRA->(DbCloseArea())
Endif
cQuery := " SELECT DISTINCT N3_FILIAL FILIAL, N3_CCONTAB CTABEM, N3_CCDEPR CTADEP "
cQuery += " FROM " + RetSqlName("SN3")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND N3_FILIAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
cQuery += " ORDER BY 1,2,3 "
TCQUERY cQuery ALIAS "TRA" NEW

DbSelectArea("TRB")
DbSetOrder(1)

While TRA->(!Eof())
	TRB->(RecLock("TRB",.T.))
		TRB->FILIAL		:= TRA->FILIAL
		TRB->CTABEM		:= TRA->CTABEM
		TRB->DESBEM		:= Alltrim(GetAdvFVal("CT1","CT1_DESC01",xFilial("CT1")+TRA->CTABEM,1))
		TRB->CTADEP		:= TRA->CTADEP
		TRB->DESDEP		:= Alltrim(GetAdvFVal("CT1","CT1_DESC01",xFilial("CT1")+TRA->CTADEP,1))
		TRB->SLDINI		:= 0
		TRB->BAIXAS		:= 0
		TRB->AQUISI		:= 0
		TRB->DEPREC		:= 0
		TRB->SLDFIM		:= 0
   	TRB->(MsUnLock())
	TRA->(DbSkip())
Enddo
//=========================================================================================

//===== SALDO INICIAL POR CONTA ATÉ A DATA ================================================
If Select("TRA") > 0
	TRA->(DbCloseArea())
Endif
cQuery := " SELECT N4_FILIAL FILIAL, N4_CONTA CTABEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT, "
cQuery += " SUM(N4_VLROC1) SLDINI "
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " WHERE N4_TIPO = '01' AND N4_OCORR = '05' AND D_E_L_E_T_ <> '*'  "
cQuery += " AND N4_FILIAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
cQuery += " AND SUBSTR(N4_DATA,1,6) < '" + mv_par02+mv_par01 + "' "
cQuery += " AND N4_CONTA  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
cQuery += " GROUP BY N4_FILIAL, N4_CONTA, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT "
cQuery += " ORDER BY 1 "
TCQUERY cQuery ALIAS "TRA" NEW

DbSelectArea("TRB")
DbSetOrder(1) // Conta do Ativo

While TRA->(!Eof())
	If TRB->(Dbseek(TRA->FILIAL + TRA->CTABEM ))
		TRB->(RecLock("TRB",.F.))
			TRB->SLDINI := TRA->SLDINI
	   	TRB->(MsUnLock())
   	Endif
	TRA->(DbSkip())
Enddo
//========================================================================================

//===== DEPRECIAÇÃO ATÉ DATA =============================================================
If Select("TRA") > 0
	TRA->(DbCloseArea())
Endif
cQuery := " SELECT N4_FILIAL FILIAL, N4_CONTA CTADEP, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT, "
cQuery += " SUM(N4_VLROC1) DEPREC "
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " WHERE N4_OCORR = '06' AND D_E_L_E_T_ <> '*' "
cQuery += " AND N4_FILIAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
cQuery += " AND SUBSTR(N4_DATA,1,6) < '" + mv_par02+mv_par01 + "' "
cQuery += " AND N4_CONTA  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
cQuery += " GROUP BY N4_FILIAL, N4_CONTA, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT, N4_TIPOCNT "
cQuery += " ORDER BY 1 "
TCQUERY cQuery ALIAS "TRA" NEW

DbSelectArea("TRB")
DbSetOrder(2) // Conta de Depreciação

While TRA->(!Eof())
	If TRB->(Dbseek(TRA->FILIAL + TRA->CTADEP))
		TRB->(RecLock("TRB",.F.))
			TRB->DEPREC := TRA->DEPREC
	   	TRB->(MsUnLock())
   	Endif
	TRA->(DbSkip())
Enddo
//=========================================================================================

//===== BAIXAS NA DATA ====================================================================
If Select("TRA") > 0
	TRA->(DbCloseArea())
Endif
cQuery := " SELECT N4_FILIAL FILIAL, N4_CONTA CTABEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT, "
cQuery += " SUM(N4_VLROC1) BAIXAS "
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " WHERE N4_OCORR = '01' AND D_E_L_E_T_ <> '*' "
cQuery += " AND N4_FILIAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
cQuery += " AND SUBSTR(N4_DATA,1,6) = '" + mv_par02+mv_par01 + "' "
cQuery += " AND N4_CONTA  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
cQuery += " GROUP BY N4_FILIAL, N4_CONTA, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT "
cQuery += " ORDER BY 1 "
TCQUERY cQuery ALIAS "TRA" NEW

DbSelectArea("TRB")
DbSetOrder(1) // Conta do Ativo

While TRA->(!Eof())
	If TRB->(Dbseek(TRA->FILIAL + TRA->CTABEM ))
		TRB->(RecLock("TRB",.F.))
			TRB->BAIXAS := TRA->BAIXAS
	   	TRB->(MsUnLock())
   	Endif
	TRA->(DbSkip())
Enddo
//=========================================================================================

//===== AQUISIÇÕES NA DATA ================================================================
If Select("TRA") > 0
	TRA->(DbCloseArea())
Endif
cQuery := " SELECT N4_FILIAL FILIAL, N4_CONTA CTABEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT, "
cQuery += " SUM(N4_VLROC1) AQUISI "
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " WHERE N4_TIPO = '01' AND N4_OCORR = '05' AND D_E_L_E_T_ <> '*' "
cQuery += " AND N4_FILIAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
cQuery += " AND SUBSTR(N4_DATA,1,6) = '" + mv_par02+mv_par01 + "' "
cQuery += " AND N4_CONTA  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
cQuery += " GROUP BY N4_FILIAL, N4_CONTA, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT "
cQuery += " ORDER BY 1 "
TCQUERY cQuery ALIAS "TRA" NEW

DbSelectArea("TRB")
DbSetOrder(1) // Conta do Ativo

While TRA->(!Eof())
	If TRB->(Dbseek(TRA->FILIAL + TRA->CTABEM ))
		TRB->(RecLock("TRB",.F.))
			TRB->AQUISI := TRA->AQUISI
	   	TRB->(MsUnLock())
   	Endif
	TRA->(DbSkip())
Enddo
//=========================================================================================

//===== DEPRECIAÇÕES NA DATA ==============================================================
If Select("TRA") > 0
	TRA->(DbCloseArea())
Endif
cQuery := " SELECT N4_FILIAL FILIAL, N4_CONTA CTADEP, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT, "
cQuery += " SUM(N4_VLROC1) DEPREC "
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " WHERE N4_OCORR = '06' AND D_E_L_E_T_ <> '*' "
cQuery += " AND N4_FILIAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
cQuery += " AND SUBSTR(N4_DATA,1,6) = '" + mv_par02+mv_par01 + "' "
cQuery += " AND N4_CONTA  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
cQuery += " GROUP BY N4_FILIAL, N4_CONTA, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_TIPOCNT, N4_TIPOCNT "
cQuery += " ORDER BY 1 "
TCQUERY cQuery ALIAS "TRA" NEW

DbSelectArea("TRB")
DbSetOrder(1) // Conta do Ativo

While TRA->(!Eof())
	TRB->(RecLock("TRB",.T.))
		TRB->FILIAL		:= TRA->FILIAL
		TRB->CTABEM		:= TRA->CTADEP // Repete
		TRB->DESBEM		:= Alltrim(GetAdvFVal("CT1","CT1_DESC01",xFilial("CT1")+TRA->CTADEP,1))
		TRB->CTADEP		:= TRA->CTADEP
		TRB->DESDEP		:= Alltrim(GetAdvFVal("CT1","CT1_DESC01",xFilial("CT1")+TRA->CTADEP,1))
		TRB->SLDINI		:= 0
		TRB->BAIXAS		:= 0
		TRB->AQUISI		:= 0
		TRB->DEPREC		:= TRA->DEPREC
		TRB->SLDFIM		:= 0
   	TRB->(MsUnLock())
	TRA->(DbSkip())
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ³
//³                                                                        ³
//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
//³realizado antes da impressao de cada linha do relatório.                ³
//³                                                                        ³
//³ExpO1 : Objeto Report da Secao                                          ³
//³ExpC2 : Alias da Tabela                                                 ³
//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
//³ExpX4 : String ou Bloco de código para pesquisa. A string será macroexe-³
//³        cutada.                                                         ³
//³                                                                        ³				
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotSql	:= 40
oReport:SetMeter(nTotSql)

DbSelectArea("TRB")
TRB->(DbGotop())
While !Eof() .And. !oReport:Cancel() 

	oReport:IncMeter()

	oSection1:Init()	
	cNomeFil := Alltrim(GetAdvFVal("SM0","M0_NOME",Substr(cNumEmp,1,2) + TRB->FILIAL,1))
	
	oSection1:PrintLine()

	DbSelectarea("TRB")
	TRB->(DbSkip())

	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif

	DbSelectarea("TRB")
Enddo
TRB->(DbCloseArea())
oTempTable:Delete()

Return
