#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT120GRV ¦ Autor ¦ Fábrica ERP.BR   ¦  Data  ¦ 24/03/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações adicionais no Pedido de Compras.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Pacotes   ¦ 28/09/2021 - Projeto Workflow versão 2.0 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT120GRV()

Local aArea   := GetArea()
Local aAreaC7 := SC7->(GetArea())
Local aAreaD1 := SD1->(GetArea())
Local cNumPed := PARAMIXB[1]
Local lAltera := PARAMIXB[3]
Local cEOL    := CHR(13)+CHR(10)
Local lRetOk  := .T.
Local lAlPcCl := GetMv("MV_ZALPCCL")
Local lWfV2   := GetMv("MV_ZWFVER2")
Local lBlqSap := GetMv("MV_ZBLQSAP")
Local lAltExe := .F.
Local _ped

If lBlqSap
	MsgInfo("Bloqueio migração Sap !")
	Return(.F.)
Endif

If lAltera .And. lAlPcCl
    DbSelectArea("SC7")
    DbSetOrder(1)
    DbSeek( xFilial("SC7") + cNumPed )
    While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7") + cNumPed
        DbSelectArea("SD1")
        DbSetOrder(22)
        If DbSeek( xFilial("SD1") + SC7->(C7_NUM+C7_ITEM) )
            If SC7->C7_QTDACLA > 0
                MsgAlert("Alteração não concluída:"+cEOL+;
                         "Item "+SC7->C7_ITEM+" já consta do Documento "+AllTrim(SD1->D1_DOC)+".")
                lRetOk := .F.
                Exit
            Endif
        Endif
        DbSelectArea("SC7")
        SC7->(DbSkip())
    Enddo
Endif

If lAltera .And. lRetOk .And. lWfV2
    DbSelectArea("SC7")
    DbSetOrder(1)
    DbSeek( xFilial("SC7") + cNumPed )
    //
    If CCONDICAO <> SC7->C7_COND
        lAltExe := .T.
        u_GrvHistAlt(cNumPed, "XXXX", "6", SC7->C7_COND, CCONDICAO) // Condição    
    Endif
    If NMOEDAPED <> SC7->C7_MOEDA
        lAltExe := .T.
        u_GrvHistAlt(cNumPed, "XXXX", "7", SC7->C7_MOEDA, NMOEDAPED) // Moeda
    Endif
    If NTXMOEDA <> SC7->C7_TXMOEDA
        lAltExe := .T.
        u_GrvHistAlt(cNumPed, "XXXX", "8", SC7->C7_TXMOEDA, NTXMOEDA) // Taxa
    Endif
    //
    For _ped := 1 to Len(aCols)
        nPosItem := aScan(aHeader,{|x|Alltrim(x[2])=="C7_ITEM"})
        nPosProd := aScan(aHeader,{|x|Alltrim(x[2])=="C7_PRODUTO"})
        nPosQtde := aScan(aHeader,{|x|Alltrim(x[2])=="C7_QUANT"})
        nPosPrec := aScan(aHeader,{|x|Alltrim(x[2])=="C7_PRECO"})
        nPosDele := Len(aHeader)+1
        cPedItem := aCols[_ped][nPosItem]
        cPedProd := aCols[_ped][nPosProd]
        nPedQtde := aCols[_ped][nPosQtde]
        nPedPrec := aCols[_ped][nPosPrec]
        lExcluid := aCols[_ped][nPosDele]
        DbSelectArea("SC7")
        DbSetOrder(1)
        If DbSeek( xFilial("SC7") + cNumPed + cPedItem )
            If lExcluid
                lAltExe := .T.
                u_GrvHistAlt(cNumPed, cPedItem, "2", "", "") // Exclusão de Item
            Else
                If cPedProd <> SC7->C7_PRODUTO
                    lAltExe := .T.
                    u_GrvHistAlt(cNumPed, cPedItem, "3", SC7->C7_PRODUTO, cPedProd) // Produto
                Endif
                If nPedQtde <> SC7->C7_QUANT
                    lAltExe := .T.
                    u_GrvHistAlt(cNumPed, cPedItem, "4", SC7->C7_QUANT, nPedQtde) // Quantidade
                Endif
                If nPedPrec <> SC7->C7_PRECO
                    lAltExe := .T.
                    u_GrvHistAlt(cNumPed, cPedItem, "5", SC7->C7_PRECO, nPedPrec) // Preço
                Endif
            Endif
        Else
            lAltExe := .T.
            u_GrvHistAlt(cNumPed, cPedItem, "1", "", "") // 1=Novo Item
        Endif
    Next _ped
    If !lAltExe
        If !MsgYesNo("Alterações relevantes não encontradas."+cEOL+"Deseja prosseguir com a confirmação e reiniciar o processo de aprovação ?")
            lRetOk   := .F.
            cZZEnvWf := "Nao"
            cZZGoAlt := "Nao"
        Endif
    Endif
Endif

RestArea(aAreaC7)
RestArea(aAreaD1)
RestArea(aArea)

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ GrvHistAlt ¦ Autor ¦ Fábrica ERP.BR ¦  Data  ¦ 17/08/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação do histórico de alterações.     				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GrvHistAlt(cNumPed, cItemPc, cTipoAlt, cInfOld, cInfNew)

Local aArea    := GetArea()
Local cDescOld := ""
Local cDescNew := ""

// --------------------
// cTipoAlt
// --------------------
// 1 - Novo Item
// 2 - Exclusão de Item
// 3 - Produto
// 4 - Quantidade
// 5 - Preço
// 6 - Condição
// 7 - Moeda
// 8 - Taxa
// --------------------

If cTipoAlt == "3"
    cChavOld := PadR(AllTrim(cInfOld),15)
    cDescOld := RetField("SB1",1,xFilial("SB1")+cChavOld,"B1_DESC")
    cChavNew := PadR(AllTrim(cInfNew),15)
    cDescNew := RetField("SB1",1,xFilial("SB1")+cChavNew,"B1_DESC")
ElseIf cTipoAlt == "6"
    cChavOld := PadR(AllTrim(cInfOld),3)
    cDescOld := RetField("SE4",1,xFilial("SE4")+cChavOld,"E4_DESCRI")
    cChavNew := PadR(AllTrim(cInfNew),3)
    cDescNew := RetField("SE4",1,xFilial("SE4")+cChavNew,"E4_DESCRI")
ElseIf cTipoAlt == "7"
    cDescOld := AllTrim(GetMv("MV_MOEDA"+AllTrim(STR(cInfOld))))
    cDescNew := AllTrim(GetMv("MV_MOEDA"+AllTrim(STR(cInfNew))))
Endif

zzjOld := cInfOld
zzjNew := cInfNew
If cTipoAlt $("4,5")
    zzjOld := AllTrim(STR(cInfOld,17,5))
    zzjNew := AllTrim(STR(cInfNew,17,5))
ElseIf cTipoAlt == "7"
    zzjOld := AllTrim(STR(cInfOld))
    zzjNew := AllTrim(STR(cInfNew))
ElseIf cTipoAlt == "8"
    zzjOld := AllTrim(STR(cInfOld,11,4))
    zzjNew := AllTrim(STR(cInfNew,11,4))
Endif

DbSelectArea("ZZJ")
RecLock("ZZJ",.T.)
ZZJ->ZZJ_FILIAL := xFilial("ZZJ")
ZZJ->ZZJ_PEDIDO := cNumPed
ZZJ->ZZJ_ITEM   := citemPc
ZZJ->ZZJ_DATA   := Date()
ZZJ->ZZJ_HORA   := Substr(Time(),1,5)
ZZJ->ZZJ_TIPO   := cTipoAlt
ZZJ->ZZJ_OLD    := zzjOld
ZZJ->ZZJ_NEW    := zzjNew
ZZJ->ZZJ_DOLD   := cDescOld
ZZJ->ZZJ_DNEW   := cDescNew
MsUnLock()

RestArea(aArea)

Return
