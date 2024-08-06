#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FUNCEST   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 19/01/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Funções Genéricas - Módulo Estoque/Custos.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

// ********************************************************************************** //
// ** Luis Brandini - 19/01/17
// ********************************************************************************** //
// ** Validação no rateio na rotina de Desmontagem - x3_vlduser do campo d3_rateio ** //
// ********************************************************************************** //
User Function VRATDES()

Local lRetOk := .T.

If FunName() == "MATA242"
	cTipoPr := Posicione("SB1",1,xFilial("SB1") + aCols[n][GdFieldPos("D3_COD")],"B1_TIPO")
	If cTipoPr == "MO"
		MsgAlert("Atenção, rateio para 'MO' não permitido!")
		lRetOk := .F.
	Endif
Endif

Return(lRetOk)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 15/03/17
// ********************************************************************************************************************************************** //
// ** Inibe o preenchimento dos campos (x3_when) na rotina de Desmontagem, caso o processo personalizado esteja habilitado (MV_DESMAUT == "S") ** //
// ********************************************************************************************************************************************** //
// ** Exceção: usuários inseridos no parâmetro MV_UEXCDES.																					   ** //
// ********************************************************************************************************************************************** //
User Function When241()

Local lDesmAut := ( AllTrim(GetMv("MV_DESMAUT")) == "S" )
Local lRetorno := .T.

If FunName() == "MATA242"
	If !( __cUserId $ AllTrim(GetMv("MV_UEXCDES")) ) // Se o usuário logado não estiver inserido no parâmetro de exceção.
		lRetorno := ( !lDesmAut )
	Endif	
Endif	

Return(lRetorno)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 05/04/17
// ********************************************************************************************************************************************** //
// ** Preenche o armazém conforme operação (98 para importação que atualiza estoque). 														   ** //
// ********************************************************************************************************************************************** //
User Function LocalCq()

Local aArea    := GetArea()
Local xProdut  := GdFieldGet("D1_COD",n)
Local xLocPad  := IIf((CTIPO $"B,D"),GdFieldGet("D1_LOCAL",n),RetField("SB1",1,xFilial("SB1")+xProdut,"B1_LOCPAD"))
Local xEstado  := RetField("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_EST")
Local lEstoqu  := IIf(l103Class, .F., (RetField("SF4",1,xFilial("SF4")+M->D1_TES,"F4_ESTOQUE") == "S") )
Local lBaixaCq := (GetMv("MV_XBAIXCQ") == "S")

If lBaixaCq .And. lEstoqu
	If xEstado == "EX"
		xLocPad := "98"
	Endif
Endif

RestArea(aArea)

Return(xLocPad)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 11/08/17
// ********************************************************************************************************************************************** //
// ** Preenche a BU conforme o CENTRO DE CUSTO do produto no Pedido de Compra.		 														   ** //
// ********************************************************************************************************************************************** //
User Function BuSb1Pc()

Local aArea   := GetArea()
Local xCCProd := RetField("SB1",1,xFilial("SB1")+M->C7_PRODUTO,"B1_CC")
Local xBUCCus := RetField("CTT",1,xFilial("CTT")+xCCProd,"CTT_ZZITCT")

RestArea(aArea)

Return(xBUCCus)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 05/06/18
// ********************************************************************************************************************************************** //
// ** Avalia se o usuário tem permissão para visualizar matéria-prima.				 														   ** //
// ********************************************************************************************************************************************** //
User Function _UsrMpOk()

Local aArea    := GetArea()
Local lRetorno := .T.

If __cUserId != "000000" // Administrador
	DbSelectArea("SZH")
	DbSetOrder(1)
	If !DbSeek( xFilial("SZH") + __cUserId )
		lRetorno := .F.
	Endif
Endif

RestArea(aArea)

Return(lRetorno)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 04/08/18
// ********************************************************************************************************************************************** //
// ** Retorna a descrição do produto no SD1.										 														   ** //
// ********************************************************************************************************************************************** //
User Function IniDescD1()

Local aArea    := GetArea()
Local zRetorno := ""

If Inclui .Or. FunName()=="MATA116"
	zRetorno := ""
ElseIf FunName()=="MATA410"
	zRetorno := Posicione("SB1",1,xFilial("SB1")+GdFieldGet("C6_PRODUTO",Len(aCols)),"B1_DESC")
ElseIf FunName() == "ALTCUST"	
	zRetorno := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")
Else
	zRetorno := Posicione("SB1",1,xFilial("SB1")+GdFieldGet("D1_COD",Len(aCols)),"B1_DESC")	
Endif

RestArea(aArea)

Return(zRetorno)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 06/12/18
// ********************************************************************************************************************************************** //
// ** Captura e incrementa o sequencial para processo de desmontagem.				 														   ** //
// ********************************************************************************************************************************************** //
User Function NumSqDes()

Local aArea := GetArea()
Public zSeqDesm := AllTrim(GetMv("MV_ZSEQDES"))

zProxSeq := SOMA1(zSeqDesm)
PutMv("MV_ZSEQDES",zProxSeq)

RestArea(aArea)

Return(zSeqDesm)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 06/12/18
// ********************************************************************************************************************************************** //
// ** Validação no sequencial do processo de desmontagem.				 														   			   ** //
// ********************************************************************************************************************************************** //
User Function VldSqDes()

Local aArea := GetArea()
Local lRet  := .T.

If CDOCUMENTO != zSeqDesm
	MsgAlert("Alteração não permitida.")
	lRet := .F.
Endif

RestArea(aArea)

Return(lRet)

// ********************************************************************************************************************************************** //
// ** Luis Brandini - 01/03/2021
// ********************************************************************************************************************************************** //
// ** Checagem se a contrapartida da transferência pertence ao armazém 14-ICL.													   			   ** //
// ********************************************************************************************************************************************** //

User Function TrfAr14(zCf)

Local aArea := GetArea()
Local lRetorno := .F.

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL = '"+SD3->D3_FILIAL+"' "
cQuery += " AND D3_COD = '"+SD3->D3_COD+"' "
cQuery += " AND D3_EMISSAO = '"+DtoS(SD3->D3_EMISSAO)+"' "
cQuery += " AND D3_NUMSEQ = '"+SD3->D3_NUMSEQ+"' "
cQuery += " AND D3_CF <> '"+zCf+"' "
cQuery += " AND D3_LOCAL = '14' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
lRetorno := (SQL3->SOMA > 0)
SQL3->(DbCloseArea())

RestArea(aArea)

Return(lRetorno)

// **************************************************************************** //
// ** Luis Brandini - 23/04/2021
// **************************************************************************** //
// ** Checagem se o documento fiscal é referente transferência entre filiais ** //
// **************************************************************************** //

User Function ChkNfTr(xTpNf,xFil,xDoc,xSer)

Local aArea := GetArea()
Local lRetX := .F.

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("NNT")
cQuery += " WHERE NNT_DOC = '"+xDoc+"' "
cQuery += " AND NNT_SERIE = '"+xSer+"' "
If xTpNf == "S"
	cQuery += " AND NNT_FILORI = '"+xFil+"' "
Else
	cQuery += " AND NNT_FILDES = '"+xFil+"' "
Endif
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
lRetX := ( SQLT->SOMA > 0 )
SQLT->(DbCloseArea())

RestArea(aArea)

Return(lRetX)
