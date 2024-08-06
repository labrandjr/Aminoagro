#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ OMSR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 01/08/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório Romaneio de Cargas                      		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function OMSR001()

Local cPerg		:= "OMSR01"

Private cPath	:= "c:\report\"
Private _aArea    := GetArea()
Private _aTmp     := {}
Private cMarca    := GetMark()
Private lInverte  := .F.
Private _nQtda	  := 0
Private _nQuant	  := 0
Private _nPeso	  := 0
Private oDlg
Private oQtda
Private oQuant
Private oPeso
Private oFnt
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	Processa({|| pOmsR01()})

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pOMSR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 01/08/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal 							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pOMSR01()

Local cQuery

Private aCliente := {}
Private aSize    := MsAdvSize()
Private oMainWnd

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM " + RetSqlName("DAK") + " DAK "
cQuery += " INNER JOIN " + RetSqlName("DAI") + " DAI ON (DAK_FILIAL = DAI_FILIAL "
cQuery += "                           AND DAK_COD = DAI_COD)
cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON (DAI_FILIAL = D2_FILIAL
cQuery += "                           AND DAI_NFISCA = D2_DOC
cQuery += "                           AND DAI_SERIE = D2_SERIE
cQuery += "                           AND DAI_CLIENT = D2_CLIENTE
cQuery += "                           AND DAI_LOJA = D2_LOJA)
cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (D2_COD = B1_COD)                                                   
cQuery += " WHERE
cQuery += " DAK_FILIAL BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
cQuery += " AND DAK_DATA BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' "
cQuery += " AND DAK_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
cQuery += " AND DAI_CLIENT BETWEEN '" + mv_par07 + "' AND '" + mv_par09 + "' "
cQuery += " AND DAI_LOJA BETWEEN '" + mv_par08 + "' AND '" + mv_par10 + "' "
cQuery += " AND DAK.D_E_L_E_T_ <> '*'
cQuery += " AND DAI.D_E_L_E_T_ <> '*'
cQuery += " AND SD2.D_E_L_E_T_ <> '*'
cQuery += " AND SB1.D_E_L_E_T_ <> '*'
cQuery += " ORDER BY DAK_FILIAL,DAK_DATA,DAK_COD
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")

If mv_par11 = 1 // Por Pedido

	cQuery := " SELECT DAK_FILIAL, DAK_COD, DAK_DATA, DAK_CAMINH, DAK_MOTORI, "
	cQuery += "        DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, DAI_PESO, DAI_NFISCA, DAI_SERIE, "
	cQuery += "        C6_PRODUTO COD, B1_DESC, B1_PESBRU, DAK.R_E_C_N_O_ DAKRECNO, SUM(C6_QTDVEN) QUANT "
	cQuery += " FROM " + RetSqlName("DAK") + " DAK "
	cQuery += " INNER JOIN " + RetSqlName("DAI") + " DAI ON (DAK_FILIAL = DAI_FILIAL "
	cQuery += "                           AND DAK_COD = DAI_COD) "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON (DAI_FILIAL = C6_FILIAL "
	cQuery += "                           AND DAI_PEDIDO = C6_NUM "
	cQuery += "                           AND DAI_CLIENT = C6_CLI "
	cQuery += "                           AND DAI_LOJA = C6_LOJA) "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (C6_PRODUTO = B1_COD) "
	cQuery += " WHERE "
	cQuery += " DAK_FILIAL BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += " AND DAK_DATA BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' "
	cQuery += " AND DAK_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cQuery += " AND DAI_CLIENT BETWEEN '" + mv_par07 + "' AND '" + mv_par09 + "' "
	cQuery += " AND DAI_LOJA BETWEEN '" + mv_par08 + "' AND '" + mv_par10 + "' "  
	cQuery += " AND DAK.D_E_L_E_T_ <> '*' "
	cQuery += " AND DAI.D_E_L_E_T_ <> '*' "
	cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY DAK_FILIAL,DAK_COD,DAK_CAMINH, DAK_MOTORI,C6_PRODUTO,DAI_PEDIDO,DAI_NFISCA,DAI_SERIE,DAI_CLIENT,DAI_LOJA,DAK_DATA,B1_DESC,DAI_PESO,B1_PESBRU,DAK.R_E_C_N_O_ "
	cQuery += " ORDER BY DAK_FILIAL,DAK_COD,C6_PRODUTO,DAI_CLIENT "

ElseIf mv_par11 = 2 // Por Nota Fiscal

	cQuery := " SELECT DAK_FILIAL, DAK_COD, DAK_DATA, DAK_CAMINH, DAK_MOTORI, "
	cQuery += "        DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, DAI_PESO, DAI_NFISCA, DAI_SERIE, "
	cQuery += "        D2_COD COD, B1_DESC, B1_PESBRU, DAK.R_E_C_N_O_ DAKRECNO, SUM(D2_QUANT) QUANT "
	cQuery += " FROM " + RetSqlName("DAK") + " DAK "
	cQuery += " INNER JOIN " + RetSqlName("DAI") + " DAI ON (DAK_FILIAL = DAI_FILIAL "
	cQuery += "                           AND DAK_COD = DAI_COD) "
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON (DAI_FILIAL = D2_FILIAL "
	cQuery += "                           AND DAI_NFISCA = D2_DOC "
	cQuery += "                           AND DAI_SERIE = D2_SERIE "
	cQuery += "                           AND DAI_CLIENT = D2_CLIENTE "
	cQuery += "                           AND DAI_LOJA = D2_LOJA) "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (D2_COD = B1_COD) "
	cQuery += " WHERE "
	cQuery += " DAK_FILIAL BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += " AND DAK_DATA BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' "
	cQuery += " AND DAK_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cQuery += " AND DAI_CLIENT BETWEEN '" + mv_par07 + "' AND '" + mv_par09 + "' "
	cQuery += " AND DAI_LOJA BETWEEN '" + mv_par08 + "' AND '" + mv_par10 + "' "  
	cQuery += " AND DAK.D_E_L_E_T_ <> '*' "
	cQuery += " AND DAI.D_E_L_E_T_ <> '*' "
	cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY DAK_FILIAL,DAK_COD,DAK_CAMINH, DAK_MOTORI,D2_COD,DAI_NFISCA,DAI_SERIE,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,DAK_DATA,B1_DESC,DAI_PESO,B1_PESBRU,DAK.R_E_C_N_O_ "
	cQuery += " ORDER BY DAK_FILIAL,DAK_COD,D2_COD,DAI_NFISCA "
Endif

DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
SQL->(DbGotop())
If SQL->(Eof())
	Alert("Nao foram encontrados lançamentos para integração!","Atenção")
	SQL->(DbCloseArea())
	Return
Endif

oTempTable := FWTemporaryTable():New("TRB")

AAdd ( _aTmp, {"TH_OK"      , "C", 02, 00} )
AAdd ( _aTmp, {"TH_FILIAL"  , "C", 06, 00} )
AAdd ( _aTmp, {"TH_CARGA" 	, "C", 06, 00} )
AAdd ( _aTmp, {"TH_VEIC"  	, "C", 08, 00} )
AAdd ( _aTmp, {"TH_MOTOR" 	, "C", 06, 00} )
AAdd ( _aTmp, {"TH_COD"  	, "C", 15, 00} )
AAdd ( _aTmp, {"TH_CLIENT"  , "C", 06, 00} )
AAdd ( _aTmp, {"TH_LOJA" 	, "C", 02, 00} )
AAdd ( _aTmp, {"TH_DATA"    , "D", 08, 00} )
AAdd ( _aTmp, {"TH_PEDIDO"  , "C", 06, 00} )
AAdd ( _aTmp, {"TH_NFISCA"	, "C", 09, 00} )
AAdd ( _aTmp, {"TH_SERIE"   , "C", 03, 00} )
AAdd ( _aTmp, {"TH_DESC"	, "C", 40, 00} )
AAdd ( _aTmp, {"TH_QUANT" 	, "N", 11, 00} )
AAdd ( _aTmp, {"TH_DENSID" 	, "N", 14, 02} )
AAdd ( _aTmp, {"TH_PESO" 	, "N", 14, 02} )
AAdd ( _aTmp, {"TH_SEQUEN"  , "C", 02, 00} )
AAdd ( _aTmp, {"TH_RECNO"   , "N", 10, 00} )

oTemptable:SetFields( _aTmp )

//_cTableName := CriaTrab(_aTmp, .T.)
//_cIndName	:= CriaTrab(Nil,.F.)
//DbUseArea(.T.,"DBFCDX",_cTableName,"TRB",.F.,.F.)

If mv_par11 == 1
//	TRB->(DbCreateIndex(_cIndName,"TH_CARGA" ,{|| TH_FILIAL + TH_CARGA + TH_COD + TH_PEDIDO},.F.))
	oTempTable:AddIndex("TH_CARGA", {"TH_FILIAL", "TH_CARGA", "TH_COD", "TH_PEDIDO"})
Elseif mv_par11 == 2
//	TRB->(DbCreateIndex(_cIndName,"TH_CARGA" ,{|| TH_FILIAL + TH_CARGA + TH_COD + TH_NFISCA},.F.))
	oTempTable:AddIndex("TH_CARGA", {"TH_FILIAL", "TH_CARGA", "TH_COD", "TH_NFISCA"})
Endif
oTempTable:Create()
 
//TRB->(DbClearInd())
//TRB->(DbSetIndex(_cIndName))
//TRB->(DbSetOrder(1))

DbSelectArea("TRB")
DbSetOrder(1)

DbSelectArea("SQL")
SQL->(DbGotop())

nSeqCli	:= 0
While !Eof()

	If !aScan(aCliente,{|x|Alltrim(x[2]) == SQL->DAI_CLIENT})
 		nSeqCli++
		cNomCli := Alltrim(GetAdvFVal("SA1","A1_NOME",xFilial("SA1") + SQL->DAI_CLIENT,1))
		cMunCli := Alltrim(GetAdvFVal("SA1","A1_MUN",xFilial("SA1") + SQL->DAI_CLIENT,1))
		cEstCli := GetAdvFVal("SA1","A1_EST",xFilial("SA1") + SQL->DAI_CLIENT,1)
		AAdd(aCliente,{nSeqCli,SQL->DAI_CLIENT,cNomCli,cMunCli,cEstCli})
	Endif

	RecLock("TRB",.T.)
	TRB->TH_FILIAL	:= SQL->DAK_FILIAL
	TRB->TH_CARGA	:= SQL->DAK_COD
	TRB->TH_VEIC	:= SQL->DAK_CAMINH
	TRB->TH_MOTOR	:= SQL->DAK_MOTORI
	TRB->TH_DATA	:= STOD(SQL->DAK_DATA)
	TRB->TH_CLIENT	:= SQL->DAI_CLIENT
	TRB->TH_LOJA	:= SQL->DAI_LOJA
	TRB->TH_PEDIDO	:= SQL->DAI_PEDIDO
	TRB->TH_NFISCA	:= SQL->DAI_NFISCA
	TRB->TH_SERIE	:= SQL->DAI_SERIE
	TRB->TH_COD		:= SQL->COD
	TRB->TH_DESC	:= SQL->B1_DESC
	TRB->TH_QUANT	:= SQL->QUANT
	TRB->TH_DENSID	:= SQL->B1_PESBRU
	TRB->TH_PESO	:= SQL->(B1_PESBRU * QUANT)
	TRB->TH_SEQUEN  := Alltrim(Str(nSeqCli))
	TRB->TH_RECNO   := SQL->DAKRECNO
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())
Enddo
SQL->(DbCloseArea())

// Monta o Browse
aCampos := {}
AAdd(aCampos,{"TH_OK"		,"",""			  ,""			       ,"002","0"})
AAdd(aCampos,{"TH_FILIAL"	,"","Filial"	  ,"@!"		           ,"006","0"})
AAdd(aCampos,{"TH_CARGA"	,"","Carga"		  ,"@!"		           ,"006","0"})
AAdd(aCampos,{"TH_DATA"		,"","Data"		  ,"@D"		           ,"008","0"})
AAdd(aCampos,{"TH_CLIENT"	,"","Cliente"	  ,"@!"		           ,"006","0"})
AAdd(aCampos,{"TH_LOJA"		,"","Loja"		  ,"@!"		           ,"006","0"})
AAdd(aCampos,{"TH_PEDIDO"	,"","Pedido"	  ,"@!"		           ,"006","0"})
AAdd(aCampos,{"TH_NFISCA"	,"","Nota Fiscal" ,"@!"		           ,"009","0"})
AAdd(aCampos,{"TH_SERIE"	,"","Série"		  ,"@!"		           ,"003","0"})
AAdd(aCampos,{"TH_COD"		,"","Código"	  ,"@!"		           ,"015","0"})
AAdd(aCampos,{"TH_DESC"		,"","Descrição"	  ,"@!"		           ,"040","0"})
AAdd(aCampos,{"TH_QUANT"	,"","Quantidade"  ,"@E 999,999,999"	   ,"011","0"})
AAdd(aCampos,{"TH_DENSID"	,"","Densidade"	  ,"@E 999,999,999.99" ,"014","2"})
AAdd(aCampos,{"TH_PESO"		,"","Peso"		  ,"@E 999,999,999.99" ,"014","2"})
AAdd(aCampos,{"TH_SEQUEN"	,"","Sequencia"	  ,"@E 99" 	           ,"002","0"})
AAdd(aCampos,{"TH_RECNO"	,"","Recno"		  ,"@E 999999"         ,"006","0"})

DbSelectArea("TRB")
TRB->(DbGotop())

If !Eof()
	
	nOpca :=0
	
	DEFINE MSDIALOG oDlg TITLE "Romaneio de Carga - Seleção" FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd Pixel
	
	@ 001.5,001 SAY "Romaneio de Carga - Seleção" FONT oFnt COLOR CLR_HRED
	@ 001.5,041 SAY "Selecionados :"
	@ 001.5,046 SAY oQtda VAR _nQtda PICTURE "@E 999,999,999" SIZE 40,05
	@ 001.5,051 SAY "Quantidade Total :"
	@ 001.5,056 SAY oQuant VAR _nQuant PICTURE "@E 999,999,999" SIZE 40,05
	@ 001.5,061 SAY "Peso Bruto Total :"
	@ 001.5,066 SAY oPeso VAR _nPeso PICTURE "@E 999,999,999.99" SIZE 40,05
	
	oMark := MsSelect():New("TRB","TH_OK","",aCampos,@lInverte,@cMarca,{35,0,aSize[6],aSize[5]})
	oMark:bMark := {| | _Atualiza(cMarca,lInverte,oQtda,oQuant,oPeso)}
	oMark:oBrowse:lHasMark := .T.
	oMark:oBrowse:lCanAllMark := .T.
	oMark:oBrowse:bAllMark := { || _MarkAll(cMarca,oQtda,oQuant,oPeso) }
	ACTIVATE MSDIALOG oDlg ON INIT _Enchoice(oDlg,{||nOpca:= 1,oDlg:End()},{||nOpca:= 2,oDlg:End()},oMark,"DAK")
	
	If nOpca == 1
		ROM_OK()
	Endif
Endif

If Select("TRB") > 0
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
	oTempTable:Delete()
Endif

RestArea(_aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ROM_OK   ¦ Autor ¦                  ¦   Data  ¦ OUT/2017   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦                                                      	  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦                    						  				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function ROM_OK()

Local oExcel  := FwMsExcel():New()
Local cKeyAnt := ""
Local cKeyCli := ""
Local cKeyCod := ""
Local zEntr1  := 0
Local zEntr2  := 0
Local zEntr3  := 0
Local zEntr4  := 0
Local zEntr5  := 0
Local zEntr6  := 0
Local zEntr7  := 0
Local zEntr8  := 0
Local zQuant  := 0
Local zPeso   := 0
Local zQuantT := 0
Local zPesoT  := 0
Local zQ1     := 0
Local zQ2     := 0
Local zQ3     := 0
Local zQ4     := 0
Local zQ5     := 0
Local zQ6     := 0
Local zQ7     := 0
Local zQ8     := 0
Local zP1     := 0
Local zP2     := 0
Local zP3     := 0
Local zP4     := 0
Local zP5     := 0
Local zP6     := 0
Local zP7     := 0
Local zP8     := 0
Local lImpres := .F.
Local nX

If _nQtda > 0 .And. _nQuant > 0 .And. _nPeso > 0
	If MsgYesNo("Confirma Geração do Romaneiro de Carga? ","Atenção","INFO")

		cNomePlan  := "DAK_OMSR01"
		cNomeTable := "Romaneio de Cargas - " + DtoC(mv_par03) + " à " + DtoC(mv_par04) + " - por Carga"
		oExcel:AddworkSheet(cNomePlan)
		oExcel:AddTable(cNomePlan,cNomeTable)

		DbSelectArea("TRB")
		TRB->(DbGoTop())
		ProcRegua(nTotSql)

		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2)
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2) 
		oExcel:AddColumn(cNomePlan,cNomeTable,"",1,2) 

		While TRB->(!Eof())

			IncProc("Gerando planilha...")

			If TRB->TH_OK == cMarca

				lCabec1 := .F.
				If TRB->(TH_FILIAL + TH_CARGA) != cKeyAnt
				    lCabec1 := .T.
					cKeyAnt := TRB->(TH_FILIAL + TH_CARGA)
				Endif	

				If lCabec1
				    zEmpNome	:= FWFilialName(cEmpAnt,TRB->TH_FILIAL,1)
					zEmpresa	:= Alltrim(TRB->TH_FILIAL) + "-" + cEmpAnt + "-" + zEmpNome // + " / " + Alltrim(SM0->M0_CIDENT) + "-" + Alltrim(SM0->M0_ESTENT)
					zCarga		:= "Carga: " + TRB->TH_CARGA
					If mv_par11 = 1
						zTipoDoc := "Por Pedido"
					Elseif mv_par11 = 2
						zTipoDoc := "Por N.Fiscal"
					Endif
					oExcel:AddRow(cNomePlan,cNomeTable,{zEmpresa,zCarga,zTipoDoc,"","","","","","","",""})

					zMotorista	:= "Motorista: " + Alltrim(GetAdvFVal("DA4","DA4_NOME",xFilial("DA4") + TRB->TH_MOTOR,1))
					zVeículo	:= "Veículo: " + Alltrim(GetAdvFVal("DA3","DA3_PLACA",xFilial("DA3") + TRB->TH_VEIC,1))
					zData		:= "Data: " + DtoC(TRB->TH_DATA)
					oExcel:AddRow(cNomePlan,cNomeTable,{zMotorista,zVeículo,zData,"","","","","","","",""})

					oExcel:AddRow(cNomePlan,cNomeTable,{"","","","","","","","","","",""})
					oExcel:AddRow(cNomePlan,cNomeTable,{"Produto","Quantidade","Peso","1a. Entrega","2a. Entrega",;
														"3a. Entrega","4a. Entrega","5a. Entrega","6a. Entrega","7a. Entrega","8a. Entrega"})

					zClie1  := ""
					zClie2  := ""
					zClie3  := ""
					zClie4  := ""
					zClie5  := ""
					zClie6  := ""
					zClie7  := ""
					zClie8  := ""

					// ----- Reordena colunas -----
      				aCliente := _Reord()

					// ----- Nome Cliente -----
					For nX := 1 to Len(aCliente)
						xNomVar		:= "zClie" + Alltrim(Str(aCliente[nX,1]))
						&xNomVar	:= Substr(Alltrim(GetAdvFVal("SA1","A1_NOME",xFilial("SA1") + aCliente[nX,2],1)),1,15)
					Next nX
					oExcel:AddRow(cNomePlan,cNomeTable,{"","","",zClie1,zClie2,zClie3,zClie4,zClie5,zClie6,zClie7,zClie8}) 

					// ----- Cidade / Estado Cliente -----
					For nX := 1 to Len(aCliente)
						xNomVar		:= "zClie" + Alltrim(Str(aCliente[nX,1]))
						&xNomVar	:= Substr(Alltrim(GetAdvFVal("SA1","A1_MUN",xFilial("SA1") + aCliente[nX,2],1)),1,12) + "-" +;
													  GetAdvFVal("SA1","A1_EST",xFilial("SA1") + aCliente[nX,2],1)
					Next nX
					oExcel:AddRow(cNomePlan,cNomeTable,{"","","",zClie1,zClie2,zClie3,zClie4,zClie5,zClie6,zClie7,zClie8}) 

					lCabec1 := .F.	
				Endif

				cKeyCod := ""
				cKeyCli := ""	
				zQuant	:= 0
				cKeyCod := TRB->(TH_FILIAL + TH_CARGA + TH_COD)

				While .T.
					If TRB->(TH_FILIAL + TH_CARGA + TH_COD) = cKeyCod

						If mv_par11 == 1
							zCodigo := Alltrim(TRB->TH_PEDIDO) + "-" + Alltrim(TRB->TH_DESC)
						Elseif mv_par11 == 2
							zCodigo := Alltrim(TRB->TH_NFISCA) + "-" + Alltrim(TRB->TH_DESC)				
						Endif

						nPos := aScan(aCliente,{|x|Alltrim(x[2])==TRB->TH_CLIENT})

						xNomVar		:= "zEntr" + Alltrim(Str(aCliente[nPos,1]))
						&xNomVar	:= TRB->TH_QUANT
						zQuant		+= TRB->TH_QUANT
						zPeso		+= TRB->TH_PESO
						
						zQuantT		+= TRB->TH_QUANT
						zPesoT		+= TRB->TH_PESO

						zQtdTot     := "zQ"+Alltrim(Str(aCliente[nPos,1]))
						&zQtdTot    += TRB->TH_QUANT

						zPesTot     := "zP"+Alltrim(Str(aCliente[nPos,1]))
						&zPesTot    += TRB->TH_PESO
						
						lImpres := .T.

						If lImpres
							oExcel:AddRow(cNomePlan,cNomeTable,{zCodigo,;
																IIf(zQuant>0,Transform(zQuant,"@E 999,999,999"),""),;
																IIf(zPeso>0 ,Transform(zPeso ,"@E 999,999,999.99"),""),;
																IIf(zEntr1>0,Transform(zEntr1,"@E 999,999,999"),""),;
																IIf(zEntr2>0,Transform(zEntr2,"@E 999,999,999"),""),;
																IIf(zEntr3>0,Transform(zEntr3,"@E 999,999,999"),""),;
																IIf(zEntr4>0,Transform(zEntr4,"@E 999,999,999"),""),;
																IIf(zEntr5>0,Transform(zEntr5,"@E 999,999,999"),""),;
																IIf(zEntr6>0,Transform(zEntr6,"@E 999,999,999"),""),;
																IIf(zEntr7>0,Transform(zEntr7,"@E 999,999,999"),""),;
																IIf(zEntr8>0,Transform(zEntr8,"@E 999,999,999"),"")})
							zQuant	:= 0
							zPeso 	:= 0
							zEntr1  := 0
							zEntr2  := 0
							zEntr3  := 0
							zEntr4  := 0
							zEntr5  := 0
							zEntr6  := 0
							zEntr7  := 0
							zEntr8  := 0
						Endif				
						TRB->(DbSkip())
						Loop
					Endif
					Exit
				Enddo
			Endif
			If !lImpres
				TRB->(DbSkip())
			Endif
			lImpres := .F.
		Enddo

		oExcel:AddRow(cNomePlan,cNomeTable,{"","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"RESUMO","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"QUANTIDADE",Transform(zQuantT,"@E 999,999,999")  , "", IIf(zQ1>0,Transform(zQ1,"@E 999,999,999"),"")   , IIf(zQ2>0,Transform(zQ2,"@E 999,999,999"),"")   , IIf(zQ3>0,Transform(zQ3,"@E 999,999,999"),"")   , IIf(zQ4>0,Transform(zQ4,"@E 999,999,999"),"")   , IIf(zQ5>0,Transform(zQ5,"@E 999,999,999"),"")   , IIf(zQ6>0,Transform(zQ6,"@E 999,999,999"),"")   , IIf(zQ7>0,Transform(zQ7,"@E 999,999,999"),"")   , IIf(zQ8>0,Transform(zQ8,"@E 999,999,999"),"")    })
		oExcel:AddRow(cNomePlan,cNomeTable,{"PESO (KG)" ,Transform(zPesoT,"@E 999,999,999.99"), "", IIf(zP1>0,Transform(zP1,"@E 999,999,999.99"),""), IIf(zP2>0,Transform(zP2,"@E 999,999,999.99"),""), IIf(zP3>0,Transform(zP3,"@E 999,999,999.99"),""), IIf(zP4>0,Transform(zP4,"@E 999,999,999.99"),""), IIf(zP5>0,Transform(zP5,"@E 999,999,999.99"),""), IIf(zP6>0,Transform(zP6,"@E 999,999,999.99"),""), IIf(zP7>0,Transform(zP7,"@E 999,999,999.99"),""), IIf(zP8>0,Transform(zP8,"@E 999,999,999.99"),"") })
		oExcel:AddRow(cNomePlan,cNomeTable,{"","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"________________________________________","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"Motorista: assinatura por extenso","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"________________________________________","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"Conferente: assinatura por extenso","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"Declaro que recebi e conferi os volumes deste romaneio","","","","","","","","","",""})
		oExcel:AddRow(cNomePlan,cNomeTable,{"em perfeito estado, e assino conforme lei 12.619/2012.","","","","","","","","","",""})

		IncProc("Exportando Informações para Excel")
	
		oExcel:Activate()
		cFile := "DAK_OMSR01-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
		oExcel:GetXmlFile(cFile)
	
		CpyS2t("\system\"+cFile, AllTrim(cPath))

		ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
		MsgInfo(cFile + " Ok !!")
		fErase(cFile)
	Endif
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ _Reord    ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ Outubro/2017 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Reordena entregas                                		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Reord()

Local nOpcCli := 0
Local bActOk  := {|| nOpcCli:=1,oDlgCli:End() }
Local bActCan := {|| nOpcCli:=0,oDlgCli:End() }
Local bOkCli  := {|| IIf( MsgYesNo("Confirma Reordenação?","Confirmar"), Eval(bActOk), .F.) }
Local bCanCli := {|| IIf( MsgYesNo("Abandona Reordenação?","Sair"), Eval(bActCan), .F.) }
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM

//Private oVerde  := LoadBitmap( GetResources(), "ENABLE" )
//Private oVerme  := LoadBitmap( GetResources(), "DISABLE" )
//Private oOk     := LoadBitmap( GetResources(), "LBOK" )
//Private oNo     := LoadBitmap( GetResources(), "LBNO" )

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)
                                                                   
// Colunas do Folder
Private nFdrOrd := 1
Private nFdrCli := 2
Private nFdrNom := 3
Private nFdrMun := 4
Private nFdrEst := 5

//Private cIdPdv  := SC5->C5_NUM
Private oLbxCli := Nil
Private aVetCli := {}
Private oDlgCli

Private oMenuCli
Private lTodas := .F.

// Carrega browse no Folder
aVetCli := aCliente

nDlg1 := 001
nDlg2 := 001
nDlg3 := 440
nDlg4 := 800

oDlgCli := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Reordena Entregas",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

nBrw1 := 035
nBrw2 := 005
nBrw3 := 440
nBrw4 := 180

oLbxCli := TWBrowse():New(nBrw1,nBrw2,nBrw3,nBrw4,,,,oDlgCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxCli:AddColumn( TcColumn():New( "Ordem"			,{ || aVetCli[oLbxCli:nAt][nFdrOrd] } , "@E 99"		,,,"LEFT"	,020,.F.,.F.,,,,.F.,) )
oLbxCli:AddColumn( TcColumn():New( "Codigo"			,{ || aVetCli[oLbxCli:nAt][nFdrCli] } , "@!"		,,,"LEFT"	,020,.F.,.F.,,,,.F.,) )
oLbxCli:AddColumn( TcColumn():New( "Cliente"		,{ || aVetCli[oLbxCli:nAt][nFdrNom] } , "@!"		,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxCli:AddColumn( TcColumn():New( "Cidade"			,{ || aVetCli[oLbxCli:nAt][nFdrMun] } , "@!"		,,,"LEFT"	,040,.F.,.F.,,,,.F.,) )
oLbxCli:AddColumn( TcColumn():New( "UF"				,{ || aVetCli[oLbxCli:nAt][nFdrEst] } , "@!"		,,,"LEFT"	,010,.F.,.F.,,,,.F.,) )

oLbxCli:SetArray(aVetCli)
oLbxCli:bHeaderClick := { |o,x,y| IIf( x == nFdrOrd , oMenuCli:Activate(x,y,oLbxCli) , fHeaderR( o , x , y , @oLbxCli , @lTodas , @aVetCli ) ) }					
oLbxCli:bLDblClick   := { || fClickR(@oLbxCli,@aVetCli,oLbxCli:nAt,oLbxCli:nColPos) }

oDlgCli:Activate(,,,.T., ,,{|| EnchoiceBar(oDlgCli,bOkCli,bCanCli) } )

Return(aVetCli)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClickR    ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦ Outubr/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do Folder 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClickR(oLbx410,aVet410,nLin,nCol) 

If nCol == nFdrOrd // Quantidade
	nVal := aVet410[nLin][nCol]
	lEditCell( @aVet410 , @oLbx410 , "@E 99" , nCol ) 
	If aVet410[nLin][nCol] != nVal // Checa se alterou o conteúdo
		lOrdOk := .F.
		For _x := 1 to Len(aVet410)
			If _x != nLin
				If aVetCli[_x][nFdrOrd] == aVet410[nLin][nCol] // A ordem digitada precisa existir
					lOrdOk := .T.
					Exit
				Endif
			Endif	
		Next _x
		If !lOrdOk
			Alert("Ordem inválida.")
			aVet410[nLin][nCol] := nVal
		Else // Reordena vetor
			For _x := 1 to Len(aVet410)
				If _x != nLin
					If aVetCli[_x][nFdrOrd] == aVet410[nLin][nCol]
						aVetCli[_x][nFdrOrd] := nVal
						Exit
					Endif
				Endif	
			Next _x
			aSort(aVet410,,,{ |x,y| x[1] < y[1]})
			oLbxCli:Refresh()
		Endif
	Endif	
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _Enchoice  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  OUT/2017	  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Monta a Enchoice Bar.									  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦                			 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function _Enchoice(oDlg,bOk,bCancel,oMark,cAlias)

Local oBar, bSet15, bSet24, lOk
Local lVolta := .F.

//DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP OemToAnsi("Recortar")
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP OemToAnsi("Copiar")
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP OemToAnsi("Colar")
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP OemToAnsi("Calculadora")
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda() TOOLTIP OemToAnsi("Agenda")
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP OemToAnsi("Impressao")
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar GROUP ACTION HelProg() TOOLTIP OemToAnsi("Help")
DEFINE BUTTON oBtOk RESOURCE "OK" OF oBar GROUP ACTION (lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP OemToAnsi("Confirmar")
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP OemToAnsi("Cancelar")
SetKEY(24,oBtCan:bAction)
oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _Atualiza  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  01/10/12	  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Marca/desmarca o registro e atualiza qtde./valor total.	  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦               			 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Atualiza(cMarca,lInverte,oQtda,oQuant,oPeso)

If IsMark("TH_OK",cMarca,lInverte)
	_nQtda  += 1
	_nQuant += TH_QUANT
	_nPeso  += TH_PESO
Else
	_nQtda  -= 1
	_nQuant -= TH_QUANT
	_nPeso  -= TH_PESO
Endif

oQtda:Refresh()
oQuant:Refresh()
oPeso:Refresh()
oMark:oBrowse:Refresh(.T.)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Funcao    ¦ _MarkAll  ¦ Autor ¦ Fabrica ERPBR     ¦ Data ¦  01/10/12	  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Marca/desmarca todos os registros.						  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦              			 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _MarkAll(cMarca,oQtda,oQuant,oPeso)

Local nReg := TRB->(Recno())
Local cAlias := Alias()

DbSelectArea("TRB")
TRB->(DbGotop())
While !Eof()
	
	RecLock("TRB",.F.)
	If IsMark("TH_OK",cMarca,lInverte) .Or. lInverte
		Replace TH_OK With Space(2)
	Else
		Replace TH_OK With cMarca
	Endif
	MsUnLock()
	
	If TH_OK == cMarca
		_nQtda  += 1
		_nQuant += TH_QUANT
		_nPeso  += TH_PESO
	Else
		_nQtda  -= 1
		_nQuant -= TH_QUANT
		_nPeso  -= TH_PESO
	Endif
	TRB->(DbSkip())
	
Enddo
TRB->(DbGoto(nReg))

oQtda:Refresh()
oQuant:Refresh()
oPeso:Refresh()
oMark:oBrowse:Refresh(.T.)

Return
