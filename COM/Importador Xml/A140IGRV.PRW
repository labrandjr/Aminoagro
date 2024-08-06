#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A140IGRV  ¦ Autor ¦ Fábrica ERP.BR  ¦  Data  ¦ 05/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ 4-Manipular dados da SDS/SDT na importação de uma NFE.     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A140IGRV()

Local aArea   := GetArea()
Local lImpXml := GetMv("MV_IMPXML")
Local aParam  := PARAMIXB

If lImpXml

    zDoc := aParam[1]
    zSer := aParam[2]
    zFor := aParam[3]
    zLoj := aParam[4]
    oXml := aParam[5]

    // 1 - Associação com Pedido de Compra
    DbSelectArea("SDS")
    DbSetOrder(1)
    If DbSeek( xFilial("SDS") + zDoc + zSer + zFor + zLoj )
        If SDS->DS_TIPO == "N"
            DbSelectArea("SDT")
            DbSetOrder(8)
            If DbSeek( xFilial("SDT") + zFor + zLoj + zDoc + zSer )
                While !Eof() .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == xFilial("SDT") + zFor + zLoj + zDoc + zSer
                    If Empty(SDT->DT_PEDIDO)
                        aPedCom := GetPedCom(SDT->DT_FORNEC, SDT->DT_LOJA, SDT->DT_COD, SDT->DT_QUANT)
                        If Len(aPedCom) > 0
                            RecLock("SDT",.F.)
                            SDT->DT_PEDIDO := aPedCom[1]
                            SDT->DT_ITEMPC := aPedCom[2]
                            MsUnLock()
                        Endif
                    Endif
                    DbSelectArea("SDT")
                    SDT->(DbSkip())
                Enddo
            Endif
        Endif
    Endif        

    // 2 - Checagem da Tag combustíveis | Inicializa Flag cancelada
    lComb := .F.
    If ValType( XmlChildEx(oXml,"_INFNFE") ) == "O"
        oDet := oXml:_INFNFE:_DET
        If Type("oDet:_PROD:_COMB") <> "U"
            lComb = .T.
        Endif
        If Type("oDet") == "A"
            If Type("oDet[1]:_PROD:_COMB") <> "U"
                lComb = .T.
            Endif
        Endif
    Endif
    RecLock("SDS",.F.)
    SDS->DS_ZCOMB := IIf(lComb,"S","N")
    SDS->DS_ZCANC := "N"
    MsUnLock()

Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetPedCom ¦ Autor ¦ Fábrica ERP.BR  ¦  Data  ¦ 05/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Busca pedido de compra em aberto.                          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetPedCom(xFornec, xLoja, xProduto, xQuant)

Local aArea := GetArea()
Local aRetPed := {}
Local lLocPed := .F.

cQry := " SELECT C7_NUM, C7_ITEM "
cQry += " FROM "+RetSqlName("SC7")
cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
cQry += " AND C7_FORNECE = '"+xFornec+"' "
cQry += " AND C7_LOJA = '"+xLoja+"' "
cQry += " AND C7_PRODUTO = '"+xProduto+"' "
cQry += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) >= "+AllTrim(STR(xQuant))
cQry += " AND C7_ENCER <> 'E' "
cQry += " AND C7_RESIDUO <> 'S' "
cQry += " AND D_E_L_E_T_ <> '*' "
cQry += " ORDER BY C7_EMISSAO, C7_NUM, C7_ITEM "
cQry := ChangeQuery(cQry)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"PED", .T., .T.)

DbSelectArea("PED")
PED->(DbGotop())
If PED->(!Eof())
    lLocPed := .T.
    AAdd(aRetPed, PED->C7_NUM)
    AAdd(aRetPed, PED->C7_ITEM)
Endif
PED->(DbCloseArea())

// Tenta entrega por terceiros
If !lLocPed
    DbSelectArea("CPX")
    DbSetOrder(1)
    If DbSeek( xFilial("CPX") + xFornec + xLoja )
        While !Eof() .And. CPX->(CPX_FILIAL+CPX_CODIGO+CPX_LOJA) == xFilial("CPX") + xFornec + xLoja

            cQry := " SELECT C7_NUM, C7_ITEM "
            cQry += " FROM "+RetSqlName("SC7")
            cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
            cQry += " AND C7_FORNECE = '"+CPX->CPX_CODFOR+"' "
            cQry += " AND C7_LOJA = '"+CPX->CPX_LOJFOR+"' "
            cQry += " AND C7_PRODUTO = '"+xProduto+"' "
            cQry += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) >= "+AllTrim(STR(xQuant))
            cQry += " AND C7_ENCER <> 'E' "
            cQry += " AND C7_RESIDUO <> 'S' "
            cQry += " AND D_E_L_E_T_ <> '*' "
            cQry += " ORDER BY C7_EMISSAO, C7_NUM, C7_ITEM "
            cQry := ChangeQuery(cQry)
            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"PED", .T., .T.)

            DbSelectArea("PED")
            PED->(DbGotop())
            If PED->(!Eof())
                lLocPed := .T.
                AAdd(aRetPed, PED->C7_NUM)
                AAdd(aRetPed, PED->C7_ITEM)
            Endif
            PED->(DbCloseArea())

            If lLocPed
                Exit
            Endif

            DbSelectArea("CPX")
            CPX->(DbSkip())
        Enddo
    Endif
Endif

RestArea(aArea)

Return(aRetPed)
