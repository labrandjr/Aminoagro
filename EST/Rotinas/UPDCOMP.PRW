#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UPDCOMP   ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 04/06/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização de flag nas compras de matéria-prima. 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UPDCOMP()

Local lOk    := .F.
Local lEnd	 := .F.
Local cPerg	 := Padr("UPDCOMP",10)
Private cEOL := CHR(13)+CHR(10)
Private oProcess

If !(__cUserId $ AllTrim(GetMv("MV_USMPMAS"))) // Administrador, Jefferson Costa, Paul Bergman
	MsgInfo("Usuário não autorizado.")
	Return
Endif

If Pergunte(cPerg,.T.)
	Preparar()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  04/06/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Atualizando flag compra de matéria-prima.", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	MsgBox("Processo concluído !!!","Aviso","INFO")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  04/06/18	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da rotina.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local zFiliais := ""
Local nForFilial
Local _x

aFilsCalc := MatFilCalc( mv_par04 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

// Pedidos de Compra
If mv_par03 == 1 .Or. mv_par03 == 3

	oProcess:SetRegua1(2)
	
	oProcess:IncRegua1("Selecionando registros..")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7, "
	cQuery += RetSqlName("SB1")+" SB1 "
	cQuery += " WHERE C7_FILIAL IN("+zFiliais+") "
	cQuery += " AND C7_PRODUTO = B1_COD "
	cQuery += " AND C7_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND C7_ZZMP = ' ' "
	cQuery += " AND B1_TIPO = 'MP' "
	cQuery += " AND SC7.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	nTotSql := SQL1->SOMA
	SQL1->(DbCloseArea())

	oProcess:IncRegua1("Selecionando registros..")
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7, "
	cQuery += RetSqlName("SB1")+" SB1 "
	cQuery += " WHERE C7_FILIAL IN("+zFiliais+") "
	cQuery += " AND C7_PRODUTO = B1_COD "
	cQuery += " AND C7_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND C7_ZZMP = ' ' "
	cQuery += " AND B1_TIPO = 'MP' "
	cQuery += " AND SC7.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
	oProcess:SetRegua1(nTotSql)
	DbSelectArea("SQL1")
	SQL1->(DbGotop())
	While !Eof()
		
		oProcess:IncRegua1("Processando...")
	
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( SQL1->(C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN) )
	
		u_ChkPcMp()
	
		DbSelectArea("SQL1")
		SQL1->(DbSkip())		
	Enddo
	SQL1->(DbCloseArea())

Endif

// Notas Fiscais
If mv_par03 == 2 .Or. mv_par03 == 3

	oProcess:SetRegua2(2)
	
	oProcess:IncRegua2("Selecionando registros..")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SF1")
	cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
	cQuery += " AND F1_TIPO = 'N' "
	cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND F1_ZZMP = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	nTotSql := SQL1->SOMA
	SQL1->(DbCloseArea())
	
	oProcess:IncRegua2("Selecionando registros..")
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName("SF1")
	cQuery += " WHERE F1_FILIAL IN("+zFiliais+") "
	cQuery += " AND F1_TIPO = 'N' "
	cQuery += " AND F1_DTDIGIT BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND F1_ZZMP = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
	oProcess:SetRegua2(nTotSql)
	DbSelectArea("SQL1")
	SQL1->(DbGotop())
	While !Eof()
		
		oProcess:IncRegua2("Processando...")
	
		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( SQL1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO) )
	
		u_ChkNfMp()
	
		DbSelectArea("SQL1")
		SQL1->(DbSkip())		
	Enddo
	SQL1->(DbCloseArea())

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChkPcMp   ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 04/06/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia se o pedido de compra contém matéria-prima.	 	  ¦¦¦
¦¦¦          ¦ * Deve-se estar com SC7 posicionado.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ChkPcMp()

Local aArea   := GetArea()
Local aAreaC7 := SC7->(GetArea())
Local zFilial := SC7->C7_FILIAL
Local zPedido := SC7->C7_NUM
Local zRecSC7 := SC7->(Recno())
Local lPcMp   := .F.

cQuery := " SELECT COUNT(*) AS TOT_MP "
cQuery += " FROM "+RetSqlName("SC7")+" SC7, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE C7_FILIAL = '"+zFilial+"' "
cQuery += " AND C7_NUM = '"+zPedido+"' "
cQuery += " AND C7_PRODUTO = B1_COD "
cQuery += " AND B1_TIPO = 'MP' "
cQuery += " AND SC7.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLMP", .F., .T.)
lPcMp := (SQLMP->TOT_MP > 0)
SQLMP->(DbCloseArea())

If lPcMp
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( zFilial + zPedido )
	While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == zFilial + zPedido
		RecLock("SC7",.F.)
		SC7->C7_ZZMP := "X"
		MsUnLock()
		SC7->(DbSkip())
	Enddo
Endif

RestArea(aAreaC7)
RestArea(aArea)
SC7->(DbGoto(zRecSC7))

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChkNfMp   ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 04/06/18  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia se a nota fiscal contém matéria-prima.	 	  	  ¦¦¦
¦¦¦          ¦ * Deve-se estar com SF1 posicionado.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ChkNfMp()

Local aArea   := GetArea()
Local aAreaF1 := SF1->(GetArea())
Local aAreaD1 := SD1->(GetArea())
Local zRecSF1 := SF1->(Recno())
Local zRecSD1 := SD1->(Recno())
Local lNfMp   := .F.

cQuery := " SELECT COUNT(*) AS TOT_MP "
cQuery += " FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL = '"+SF1->F1_FILIAL+"' "
cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' "
cQuery += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
cQuery += " AND D1_LOJA = '"+SF1->F1_LOJA+"' "
cQuery += " AND D1_TIPO = '"+SF1->F1_TIPO+"' "
cQuery += " AND D1_TP = 'MP' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLMP", .F., .T.)
lNfMp := (SQLMP->TOT_MP > 0)
SQLMP->(DbCloseArea())

If lNfMp

	DbSelectArea("SF1")
	RecLock("SF1",.F.)
	SF1->F1_ZZMP := "X"
	MsUnLock()

	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
	While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		RecLock("SD1",.F.)
		SD1->D1_ZZMP := "X"
		MsUnLock()
		SD1->(DbSkip())
	Enddo

Endif

RestArea(aAreaF1)
RestArea(aAreaD1)
RestArea(aArea)
SF1->(DbGoto(zRecSF1))
SD1->(DbGoto(zRecSD1))

Return
