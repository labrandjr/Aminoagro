#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ALOTINV   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Lote de Contagem do Inventário Rádio Frequência.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ALOTINV()

Private cCadastro := "Lote de Contagem do Inventário RF"

Private aCores := {{"ZM_ENCER == 'N' .And. ZM_TOTCON == 0" , "BR_VERDE"    },;
				   {"ZM_ENCER == 'N' .And. ZM_TOTCON > 0"  , "BR_AMARELO"  },;
				   {"ZM_ENCER == 'S'"                      , "BR_VERMELHO" }}

Private aCoresLeg := {{"BR_VERDE"	 , "Lote em aberto"   },;
					  {"BR_AMARELO"	 , "Lote em contagem" },;
					  {"BR_VERMELHO" , "Lote transferido" }}

Private aRotina   := {{"Pesquisar"  , "AxPesqui"    , 0 , 1 },;
            	      {"Monitorar"  , "U_LOTINVM()" , 0 , 2 },;
            	      {"Incluir"    , "U_LOTINVI()" , 0 , 3 },;
            	      {"Visualizar" , "AxVisual"    , 0 , 4 },;
            	      {"Excluir"    , "U_LOTINVE()" , 0 , 5 },;
            	      {"Importar"   , "U_LOTINVP()" , 0 , 3 },;
  					  {"Legenda"    , "BrwLegenda(cCadastro,cLegenda,aCoresLeg)" , 0 , 10 }}

Private cLegenda  := "Legenda"

If !(__cUserId $ ( AllTrim(GetMv("MV_XUSCOLE")) )) // Administrador, Leonardo Araujo, Pedro Santos
	MsgAlert("Usuário não autorizado. Contate o Administrador.")
	Return
Endif

DbSelectArea("SZM")
DbSetOrder(1)
SZM->(DbGotop())
MBrowse(6,1,22,75,"SZM",,,,,,aCores)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LOTINVI   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Inclusão - Lote de Contagem.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LOTINVI()

Local cTudoOk := "U_LINVIOK()"

nRet := AxInclui("SZM",0,3,,,,cTudoOk)

If nRet == 1
	MsgRun("Aguarde, criando sub-lotes de contagem...","Processando",{|| SubLotInv() })
	RecLock("SZM",.F.)
	SZM->ZM_UNICO := IIf(!Empty(SZM->ZM_LOCALIZ),"S","N")
	MsUnLock()
	MsgInfo("Processo concluído.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LINVIOK   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 26/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação cTudoOk na inclusão.				  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LINVIOK()

Local aArea := GetArea()
Local lRetorno := .T.

If Empty(M->ZM_LOCALIZ)
	If Empty(M->ZM_GALPAO) .Or. Empty(M->ZM_RUAI) .Or. Empty(M->ZM_RUAF) .Or. Empty(M->ZM_MODI) .Or. Empty(M->ZM_MODF) .Or. Empty(M->ZM_NIVI) .Or. Empty(M->ZM_NIVF)
		MsgAlert("Informe o código do endereço ou o intervalo completo da área de contagem.")
		lRetorno := .F.
	Endif
ElseIf !Empty(M->ZM_LOCALIZ)
	If !Empty(M->ZM_GALPAO) .Or. !Empty(M->ZM_RUAI) .Or. !Empty(M->ZM_RUAF) .Or. !Empty(M->ZM_MODI) .Or. !Empty(M->ZM_MODF) .Or. !Empty(M->ZM_NIVI) .Or. !Empty(M->ZM_NIVF)
		MsgAlert("Informe o código do endereço ou o intervalo completo da área de contagem.")
		lRetorno := .F.
	Endif
Else
	DbSelectArea("SBE")
	DbSetOrder(1)
	If !DbSeek( xFilial("SBE") + M->ZM_LOCAL + M->ZM_LOCALIZ )
		MsgAlert("Endereço inválido para o armazém informado.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	zUnico := IIf(!Empty(M->ZM_LOCALIZ),"S","N")
	cQuery := " SELECT ZM_ID "
	cQuery += " FROM "+RetSqlName("SZM")
	cQuery += " WHERE ZM_FILIAL = '"+xFilial("SZM")+"' "
	cQuery += " AND ZM_LOCAL = '"+M->ZM_LOCAL+"' "
	cQuery += " AND ZM_GALPAO = '"+M->ZM_GALPAO+"' "
	cQuery += " AND ZM_UNICO = '"+zUnico+"' "
	cQuery += " AND ZM_ENCER = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZM", .F., .T.)
	TSZM->(DbGotop())
	If !Eof()
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SZL")
		cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
		cQuery += " AND ZL_ID = '"+TSZM->ZM_ID+"' "
		cQuery += " AND ZL_TRANSF = 'N' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)
		lExiste := (TSZL->SOMA > 0)
		TSZL->(DbCloseArea())
		If lExiste
			MsgAlert("Existe lote de contagem não encerrado neste armazém/galpão.")
			lRetorno := .F.
		Endif
	Endif
	TSZM->(DbCloseArea())
Endif

RestArea(aArea)

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ SubLotInv ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Criação dos sub-lotes de contagem.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function SubLotInv()

If Empty(SZM->ZM_LOCALIZ)
	cQuery := " SELECT BE_LOCALIZ ENDERECO "
	cQuery += " FROM "+RetSqlName("SBE")
	cQuery += " WHERE BE_FILIAL = '"+xFilial("SBE")+"' "
	cQuery += " AND BE_LOCAL = '"+SZM->ZM_LOCAL+"' "
	cQuery += " AND SUBSTR(BE_LOCALIZ,1,1) = '"+SZM->ZM_GALPAO+"' "
	cQuery += " AND SUBSTR(BE_LOCALIZ,3,1) BETWEEN '"+SZM->ZM_RUAI+"' AND '"+SZM->ZM_RUAF+"' "
	cQuery += " AND SUBSTR(BE_LOCALIZ,5,2) BETWEEN '"+SZM->ZM_MODI+"' AND '"+SZM->ZM_MODF+"' "
	cQuery += " AND SUBSTR(BE_LOCALIZ,8,2) BETWEEN '"+SZM->ZM_NIVI+"' AND '"+SZM->ZM_NIVF+"' "
	cQuery += " AND BE_MSBLQL <> '1' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY ENDERECO "
Else
	cQuery := " SELECT BE_LOCALIZ ENDERECO "
	cQuery += " FROM "+RetSqlName("SBE")
	cQuery += " WHERE BE_FILIAL = '"+xFilial("SBE")+"' "
	cQuery += " AND BE_LOCAL = '"+SZM->ZM_LOCAL+"' "
	cQuery += " AND BE_LOCALIZ = '"+SZM->ZM_LOCALIZ+"' "
	cQuery += " AND BE_MSBLQL <> '1' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY ENDERECO "
Endif
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSBE", .F., .T.)

DbSelectArea("TSBE")
TSBE->(DbGotop())
While !Eof()

	DbSelectArea("SBF")
	DbSetOrder(1)
	If DbSeek( xFilial("SBF") + SZM->ZM_LOCAL + TSBE->ENDERECO )
		While !Eof() .And. SBF->(BF_FILIAL+BF_LOCAL+BF_LOCALIZ) == xFilial("SBF") + SZM->ZM_LOCAL + TSBE->ENDERECO
			If SBF->BF_QUANT > 0
				RecLock("SZL",.T.)
				SZL->ZL_FILIAL  := xFilial("SZL")
				SZL->ZL_ID      := SZM->ZM_ID
				SZL->ZL_LOCAL   := SZM->ZM_LOCAL
				SZL->ZL_LOCALIZ := TSBE->ENDERECO
				SZL->ZL_COD     := SBF->BF_PRODUTO
				SZL->ZL_LOTECTL := SBF->BF_LOTECTL
				SZL->ZL_CONF    := "N"
				SZL->ZL_SUBS    := "N"
				SZL->ZL_INCL    := "N"
				SZL->ZL_TRANSF  := "N"
				SZL->ZL_GRUPO   := Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_GRUPO")
				SZL->ZL_DESCRI  := Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_DESC")
				MsUnLock()
				//
				RecLock("SZM",.F.)
				SZM->ZM_TOTEND += 1
				MsUnLock()
			Endif
			//
			DbSelectArea("SBF")
			SBF->(DbSkip())
		Enddo
	Else	
		RecLock("SZL",.T.)
		SZL->ZL_FILIAL  := xFilial("SZL")
		SZL->ZL_ID      := SZM->ZM_ID
		SZL->ZL_LOCAL   := SZM->ZM_LOCAL
		SZL->ZL_LOCALIZ := TSBE->ENDERECO
		SZL->ZL_COD     := "VAZIO"
		SZL->ZL_LOTECTL := "VAZIO"
		SZL->ZL_CONF    := "N"
		SZL->ZL_SUBS    := "N"
		SZL->ZL_INCL    := "N"
		SZL->ZL_TRANSF  := "N"
		SZL->ZL_GRUPO   := ""
		SZL->ZL_DESCRI  := "VAZIO"
		MsUnLock()
		//
		RecLock("SZM",.F.)
		SZM->ZM_TOTEND += 1
		MsUnLock()
	Endif	

	DbSelectArea("TSBE")		
	TSBE->(DbSkip())
Enddo
TSBE->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LOTINVA   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteração - Lote de Contagem.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LOTINVA()
/*
Altera := .T.
nReg   := SZM->(Recno())
nOpc   := AxAltera("SZM",nReg,4)
*/
MsgAlert("Opção não disponível.")	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LOTINVE   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exclusão - Lote de Contagem.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LOTINVE()

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SZL")
cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
cQuery += " AND ZL_TRANSF = 'S' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)
lRet := (TSZL->SOMA == 0)
TSZL->(DbCloseArea())

If !lRet
	MsgAlert("O lote de contagem já foi transferido.")
	Return
Endif

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SZL")
cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
cQuery += " AND ZL_CONF = 'S' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)
lRet := (TSZL->SOMA == 0)
TSZL->(DbCloseArea())

If !lRet
	MsgAlert("O lote de contagem está em conferência.")
	Return
Endif

Exclui := .T.
nReg   := SZM->(Recno())
nOpc   := AxDeleta("SZM",nReg,5)

If nOpc == 2
	MsgRun("Aguarde, excluindo sub-lotes de contagem...","Processando",{|| ExcSubLot() })
	MsgInfo("Processo concluído.")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ExcSubLot ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exclusão dos sub-lotes de contagem.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ExcSubLot()

DbSelectArea("SZL")
DbSetOrder(1)
If DbSeek( xFilial("SZL") + SZM->ZM_ID )
	While !Eof() .And. SZL->(ZL_FILIAL+ZL_ID) == xFilial("SZL") + SZM->ZM_ID
		RecLock("SZL",.F.)
		DbDelete()
		MsUnLock()
		SZL->(DbSkip())
	Enddo
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LOTINVP   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação - Lote de Contagem.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LOTINVP()

Local lOk   := .F.
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

cArquivo := cGetFile("Arquivos CSV|*.CSV|",OemToAnsi("Selecione o arquivo"))
cArquivo := AllTrim(cArquivo)
If !Empty(cArquivo)
	If File(cArquivo)
		If MsgYesNo("Arquivo a ser processado: "+cEOL+cArquivo+"."+cEOL+"Deseja prosseguir ?","Aviso","INFO")
			lOkFile := .T.
		Endif
	Else
		MsgAlert("Arquivo não encontrado.")
	Endif
Else
	MsgAlert("Arquivo não selecionado.")
Endif

If lOkFile

	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	nPosic  := 0
	aLinha  := {}
	cTxtLin := cArquivo
	While (!Empty(cTxtLin))
		If (((nPosic := AT("\",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	lProcOk := .T.
	zArqCsv := Upper(aLinha[Len(aLinha)])
	nPosCsv := AT(".CSV",zArqCsv)
	zString := Substr(zArqCsv,1,nPosCsv-1)
    zDatInv := StoD(zString)
    If Empty(zDatInv)
		MsgAlert("O nome do arquivo deve ser uma data válida no formato AAAAMMDD.CSV")
    	lProcOk := .F.
    Endif
	zDatInv := zString
	
	If lProcOk
		If MsgYesNo("Confirma o processamento - IMPORTAR LOTE DE CONTAGEM ?","Aviso","INFO")
			oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp(zDatInv) }, "Importando lote de contagem", "Aguarde, processando ...", .F. )
			oProcess:Activate()
		Endif
	Endif
	
	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  27/06/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp(zDatInv)

Local nCountLin := 0
Local cEOL      := CHR(13)+CHR(10)
Local lProcOk   := .T.
Local aInvArq  := {}
Local _x
Local _y

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando arquivo csv..")

	// Fim de Arquivo
	If Len(cString) < 3
		Exit
	Endif

	nPosic  := 0
	aLinha  := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT(";",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	// Estrutura de aLinha:
	// [01] - Produto

	// Estrutura de aLinha:
	// [01] - Armazém
	// [02] - Endereço

	If Len(aLinha) < 2
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida."+cEOL+"O layout deve conter pelo menos 2 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		If Len(aLinha) == 1
			zProdut := PadR(aLinha[1],15)
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SB1") + zProdut )
				MsgInfo("Produto não localizado: "+AllTrim(zProdut))
				lProcOk := .F.
			Else
				AAdd(aInvArq,{"P",SB1->B1_COD})
			Endif
			If !lProcOk
				MsgAlert("O processo será interrompido.")
				Exit
			Endif
		Else
			zLocal := aLinha[1]
			zEnder := PadR(aLinha[2],15)
			DbSelectArea("NNR")
			DbSetOrder(1)
			If !DbSeek( xFilial("NNR") + zLocal )
				MsgInfo("Armazém não localizado: "+zLocal)
				lProcOk := .F.
			Endif
			If lProcOk
				DbSelectArea("SBE")
				DbSetOrder(1)
				If !DbSeek( xFilial("SBE") + zLocal + zEnder )
					MsgInfo("Endereço não localizado: "+zLocal+"-"+AllTrim(zEnder))
					lProcOk := .F.
				Else
					AAdd(aInvArq,{"E",SBE->BE_LOCAL,SBE->BE_LOCALIZ})
				Endif
			Endif
			If !lProcOk
				MsgAlert("O processo será interrompido.")
				Exit
			Endif
		Endif	

	Endif
		
Enddo

If lProcOk
	// Armazena os cabeçalhos dos lotes
	aCabLot := {}
	For _x := 1 to Len(aInvArq)
		zTipInv := aInvArq[_x][1]
		If zTipInv == "P"
			zProdut := aInvArq[_x][2]
			cQuery := " SELECT * "
			cQuery += " FROM "+RetSqlName("SBF")
			cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"' "
			cQuery += " AND BF_PRODUTO = '"+AllTrim(zProdut)+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY BF_FILIAL, BF_LOCAL, BF_LOCALIZ "
		Else
			zLocal := aInvArq[_x][2]
			zEnder := aInvArq[_x][3]
			cQuery := " SELECT * "
			cQuery += " FROM "+RetSqlName("SBF")
			cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"' "
			cQuery += " AND BF_LOCAL = '"+zLocal+"' "
			cQuery += " AND BF_LOCALIZ = '"+AllTrim(zEnder)+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY BF_FILIAL, BF_PRODUTO "
		Endif	
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBX", .F., .T.)
		TRBX->(DbGotop())
		While !Eof()
			If Substr(TRBX->BF_LOCALIZ,1,3) $("GEN,BOX,TRS,PAL,OBS,BLC,RES,SLW") .Or.;
			   Substr(TRBX->BF_LOCALIZ,3,3) $("GEN,BOX,TRS,PAL,OBS,BLC,RES,SLW")
				zUnico := "S"
			Else
				zUnico := "N"
			Endif
			zLocalz := IIf(zUnico=="S",TRBX->BF_LOCALIZ,Space(15))
			lAddCab := .F.
			If Len(aCabLot) == 0
				lAddCab := .T.
			Else
				nPos := aScan(aCabLot, {|x| x[1] == zDatInv .And. x[2] == TRBX->BF_LOCAL .And. x[3] == zUnico .And. x[4] == zLocalz})
				If nPos == 0
					lAddCab := .T.
				Endif
			Endif
			If lAddCab
				AAdd(aCabLot,{zDatInv, TRBX->BF_LOCAL, zUnico, zLocalz})
			Endif			
			DbSelectArea("TRBX")
			TRBX->(DbSkip())
		Enddo		
		TRBX->(DbCloseArea())
	Next _x
	// Valida os cabeçalhos dos lotes
	For _y := 1 to Len(aCabLot)
		//
		zArq := aCabLot[_y][1]
		zArm := aCabLot[_y][2]
		zUni := aCabLot[_y][3]
		zLoc := aCabLot[_y][4]
		//
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SZM")
		cQuery += " WHERE ZM_FILIAL = '"+xFilial("SZM")+"' "
		cQuery += " AND ZM_LOCAL = '"+zArm+"' "
		cQuery += " AND ZM_ENCER = 'N' "
		cQuery += " AND ZM_UNICO = '"+zUni+"' "
		cQuery += " AND ZM_ARQ = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZM", .F., .T.)
		lExiste := (TSZM->SOMA > 0)
		TSZM->(DbCloseArea())
		If lExiste
			MsgAlert("Existe lote de contagem não encerrado (Único = "+zUni+") no armazém "+zArm+". O processo será interrompido.")
			lProcOk := .F.
			Exit
		Endif
		//
		DbSelectArea("SZM")
		DbSetOrder(3)
		If DbSeek( xFilial("SZM") + zArq + zArm + zUni + zLoc )
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SZL")
			cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
			cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
			cQuery += " AND ZL_CONF = 'S' "
			cQuery += " AND ZL_TRANSF = 'N' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)
			lExiste := (TSZL->SOMA > 0)
			TSZL->(DbCloseArea())
			If lExiste
				MsgAlert("A importação "+zArq+" (Id = "+SZM->ZM_ID+") está em conferência no armazém "+SZM->ZM_LOCAL+". O processo será interrompido.")
				lProcOk := .F.
				Exit
			Endif
			//
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SZL")
			cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
			cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
			cQuery += " AND ZL_TRANSF = 'S' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)
			lExiste := (TSZL->SOMA > 0)
			TSZL->(DbCloseArea())
			If lExiste
				MsgAlert("A importação "+zArq+" (Id = "+SZM->ZM_ID+") já possui itens conferidos e transferidos ref. armazém "+SZM->ZM_LOCAL+". O processo será interrompido.")
				lProcOk := .F.
				Exit
			Endif
		Endif
		//
	Next _y
	// Executa a importação
	If lProcOk
		For _x := 1 to Len(aInvArq)

			zTipInv := aInvArq[_x][1]

			If zTipInv == "P"
				zProdut := aInvArq[_x][2]
				cQuery := " SELECT * "
				cQuery += " FROM "+RetSqlName("SBF")
				cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"' "
				cQuery += " AND BF_PRODUTO = '"+AllTrim(zProdut)+"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				cQuery += " ORDER BY BF_FILIAL, BF_LOCAL, BF_LOCALIZ "
			Else
				zLocal := aInvArq[_x][2]
				zEnder := aInvArq[_x][3]
				cQuery := " SELECT * "
				cQuery += " FROM "+RetSqlName("SBF")
				cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"' "
				cQuery += " AND BF_LOCAL = '"+zLocal+"' "
				cQuery += " AND BF_LOCALIZ = '"+AllTrim(zEnder)+"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				cQuery += " ORDER BY BF_FILIAL, BF_PRODUTO "
			Endif	
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBX", .F., .T.)

			DbSelectArea("TRBX")
			TRBX->(DbGotop())
			While !Eof()
				If Substr(TRBX->BF_LOCALIZ,1,3) $("GEN,BOX,TRS,PAL,OBS,BLC,RES,SLW") .Or.;
				   Substr(TRBX->BF_LOCALIZ,3,3) $("GEN,BOX,TRS,PAL,OBS,BLC,RES,SLW")
					zUnico := "S"
				Else
					zUnico := "N"
				Endif
				zArq := zDatInv
				zArm := TRBX->BF_LOCAL
				zUni := zUnico
				zLoc := IIf(zUnico=="S",TRBX->BF_LOCALIZ,Space(15))
				DbSelectArea("SZM")
				DbSetOrder(3)
				If !DbSeek( xFilial("SZM") + zArq + zArm + zUni + zLoc )

					zId := GetSXENum("SZM","ZM_ID")
					SZM->(DbSetOrder(1))		
					While SZM->(DbSeek(xFilial("SZM")+zId))			
						ConfirmSX8()			
						zId := GetSXENum("SZM","ZM_ID")
					Enddo
					ConfirmSX8()

					RecLock("SZM",.T.)
					SZM->ZM_FILIAL  := xFilial("SZM")
					SZM->ZM_ID      := zId
					SZM->ZM_DATA    := StoD(zDatInv)
					SZM->ZM_LOCAL   := zArm
					SZM->ZM_USUARIO := cUserName
					SZM->ZM_DATAAB  := Date()
					SZM->ZM_HORAAB  := Time()
					SZM->ZM_ENCER   := "N"
					SZM->ZM_LOCALIZ := zLoc
					SZM->ZM_UNICO   := zUnico
					SZM->ZM_ARQ     := zArq
					SZM->ZM_TPARQ   := zTipInv
					SZM->ZM_TPINV   := "R"
					MsUnLock()
				Endif
				//
				DbSelectArea("SZL")
				DbSetOrder(2)
				If !DbSeek( xFilial("SZL") + SZM->ZM_ID + SZM->ZM_LOCAL + TRBX->BF_LOCALIZ + TRBX->BF_PRODUTO + TRBX->BF_LOTECTL )
					RecLock("SZL",.T.)
					SZL->ZL_FILIAL  := xFilial("SZL")
					SZL->ZL_ID      := SZM->ZM_ID
					SZL->ZL_LOCAL   := SZM->ZM_LOCAL
					SZL->ZL_LOCALIZ := TRBX->BF_LOCALIZ
					SZL->ZL_COD     := TRBX->BF_PRODUTO
					SZL->ZL_LOTECTL := TRBX->BF_LOTECTL
					SZL->ZL_QUANT   := 0.00
					SZL->ZL_CONF    := "N"
					SZL->ZL_SUBS    := "N"
					SZL->ZL_INCL    := "N"
					SZL->ZL_TRANSF  := "N"
					SZL->ZL_USUARIO := ""
					SZL->ZL_USRFULL := ""
					SZL->ZL_OBS     := ""
					SZL->ZL_GRUPO   := Posicione("SB1",1,xFilial("SB1")+TRBX->BF_PRODUTO,"B1_GRUPO")
					SZL->ZL_DESCRI  := Posicione("SB1",1,xFilial("SB1")+TRBX->BF_PRODUTO,"B1_DESC")
					MsUnLock()
				Endif
				DbSelectArea("TRBX")
				TRBX->(DbSkip())
			Enddo		
			TRBX->(DbCloseArea())
		Next _x
		// Atualiza total de registros dos lotes de contagem
		For _y := 1 to Len(aCabLot)
			zArq := aCabLot[_y][1]
			zArm := aCabLot[_y][2]
			zUni := aCabLot[_y][3]
			zLoc := aCabLot[_y][4]
			//
			DbSelectArea("SZM")
			DbSetOrder(3)
			If DbSeek( xFilial("SZM") + zArq + zArm + zUni + zLoc )
				cQuery := " SELECT COUNT(*)AS SOMA "
				cQuery += " FROM "+RetSqlName("SZL")
				cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
				cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)
				nTotEnd := TSZL->SOMA
				TSZL->(DbCloseArea())
				//
				RecLock("SZM",.F.)
				SZM->ZM_TOTEND := nTotEnd
				MsUnLock()
			Endif
		Next _y
	Endif
Endif

If lProcOk
	MsgInfo("Processamento concluído.")
Endif
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  11/09/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua leitura do arquivo e retorna conteudo da linhaa.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fReadFile(nHandle,xFileSize,xBytesRead,nBytes)

Local nBytesRead := IIf(!((xBytesRead == 0) .Or. (xBytesRead == Nil)),xBytesRead,IIf(xFileSize < 1536,xFileSize,1536)) // Indica o numero de bytes a serem lidos
Local cBuffer    := Space(nBytesread) // Guarda o conteudo lido
Local nPosition  := 0 // Posicao do caracter 13 (return)
Local nIncbytes  := Nil // Incremento de bytes 2 CHR(13) + CHR(10)
Local xReturn    := Nil // Retorno da funcao

If ( ((FREAD(nHandle,@cBuffer,nBytesRead) = nBytesRead) .Or. (!Empty(cBuffer))) )
	// Verifica se procura o caracter 13 para identificar o registro
	xReturn := Substr(cBuffer,1,IIf(((nPosition := AT(CHR(13),cBuffer)) > 0),(nPosition - 1),Len(cBuffer)))
	// Verifica se incrementa bytes
	nIncBytes := IIf(nPosition > 0,2,0)
	// Bytes ja lidos somando os caracteres especiais
	nBytes := (nBytes + (Len(xReturn) + nIncBytes))
	// Retorna o descritor se necessario
	FSEEK(nHandle,(-1 * ABS((Len(cBuffer) - (Len(xReturn) + nIncBytes)))),1)
Endif

Return(xReturn)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  11/09/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Obtem o tamanho do arquivo texto.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)
