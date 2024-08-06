#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT175FOK  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 11/04/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações de linha na digitação da Baixa do CQ. 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT175FOK()

Local aArea  := GetArea()
Local xTipo  := GdFieldGet("D7_TIPO",n)
Local xNfTra := GdFieldGet("D7_XNF",n)
Local lRetOk := .T.

If xTipo == 1
	If Empty(xNfTra)
		lTrFil := u_DocTrFil(SD7->D7_DOC,SD7->D7_SERIE,SD7->D7_PRODUTO)
		If !lTrFil
			MsgInfo("No.Documento de Transporte não informado.")
			lRetOk := .F.
		Endif	
	Endif
Endif

RestArea(aArea)

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VL175DOC  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 11/04/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações de linha na digitação da Baixa do CQ. 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function VL175DOC()

Local aArea   := GetArea()
Local lRetOk  := .T.
Local cBxCqOk := AllTrim(GetMv("MV_ZBXCQOK")) // AMOSTRA,INTERCOMP,SEMTRANSP

If !(AllTrim(M->D7_XNF) $(cBxCqOk))
	DbSelectArea("SF1")
	DbSetOrder(1)
	If !DbSeek( xFilial("SF1") + M->D7_XNF )
		MsgInfo("No.Documento de Transporte não localizado.")
		lRetOk := .F.
	Else
		lNfOk := .F.
		While !Eof() .And. SF1->(F1_FILIAL+F1_DOC) == xFilial("SF1") + M->D7_XNF
			If SF1->F1_EST == "EX"
				lNfOk := .T.
				Exit
			Endif
			SF1->(DbSkip())
		Enddo
		If !lNfOk
			MsgInfo("No.Documento de Transporte inválido.")
			lRetOk := .F.
		Else	
			DbSelectArea("SD1")
			DbSetOrder(1)
			If DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) + SD7->D7_PRODUTO )
				lEstOk := ( RetField("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_ESTOQUE") == "N" )
				If !lEstOk
					MsgInfo("Documento de Transporte não pode movimentar estoque.")
					lRetOk := .F.
				Endif
			Else
				MsgInfo("No.Documento de Transporte inválido para este produto.")
				lRetOk := .F.
			Endif
		Endif	
	Endif
Endif

RestArea(aArea)

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DOCTR98   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/07/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Busca documento de transporte no movimento de baixa do cq. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DOCTR98()

cDocTransp := RetField("SD7",2,xFilial("SD7") + Substr(SD3->D3_DOC,1,6) + SD3->D3_COD + SD3->D3_LOCAL + SD3->D3_NUMSEQ,"D7_XNF")

Return(cDocTransp)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DocTrFil  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 17/10/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verifica se o documento refere-se a Transf.de Filiais.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DocTrFil(zDoc,zSer,zCod)

Local aArea  := GetArea()
Local lTrFil := .F.

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("NNT")
cQuery += " WHERE NNT_FILDES = '"+xFilial("SD7")+"' " 
cQuery += " AND NNT_DOC = '"+zDoc+"' "
cQuery += " AND NNT_SERIE = '"+zSer+"' "
cQuery += " AND NNT_PRODD = '"+zCod+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
lTrFil := (SQL->SOMA > 0)
SQL->(DbCloseArea())

RestArea(aArea)

Return(lTrFil)
