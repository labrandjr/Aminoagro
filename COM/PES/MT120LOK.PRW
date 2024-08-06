#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT120LOK ¦ Autor ¦ Fábrica ERP.BR   ¦  Data  ¦ 24/03/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações adicionais no Pedido de Compras.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT120LOK()

Local aArea   := GetArea()
Local cNumPed := CA120NUM
Local nPosItm := aScan(aHeader,{|x|Alltrim(x[2])=="C7_ITEM"})
Local nPosPrd := aScan(aHeader,{|x|Alltrim(x[2])=="C7_PRODUTO"})
Local nPosQtd := aScan(aHeader,{|x|Alltrim(x[2])=="C7_QUANT"})
Local nPosPrc := aScan(aHeader,{|x|Alltrim(x[2])=="C7_PRECO"})
Local nPosTot := aScan(aHeader,{|x|Alltrim(x[2])=="C7_TOTAL"})
Local nPosDel := Len(aHeader)+1
Local cEOL    := CHR(13)+CHR(10)
Local lRet    := .T.
Local lAlPcCl := GetMv("MV_ZALPCCL")

If Altera .And. lAlPcCl
    If !aCols[n][nPosDel]
        pItemPc := aCols[n][nPosItm]
        pProdut := aCols[n][nPosPrd]
        pQuant  := aCols[n][nPosQtd]
        pPreco  := aCols[n][nPosPrc]
        pTotal  := aCols[n][nPosTot]
        //
        DbSelectArea("SC7")
        DbSetOrder(1)
        DbSeek( xFilial("SC7") + cNumPed + pItemPc )
        //
        DbSelectArea("SD1")
        DbSetOrder(22)
        If DbSeek( xFilial("SD1") + cNumPed + pItemPc )
            If AllTrim(SC7->C7_PRODUTO) != AllTrim(pProdut) .Or.;
               SC7->C7_QUANT != pQuant .Or.;
               SC7->C7_PRECO != pPreco .Or.;
               SC7->C7_TOTAL != pTotal
                MsgAlert("Alteração não permitida:"+cEOL+;
                         "Item "+pItemPc+" já consta do Documento "+AllTrim(SD1->D1_DOC)+".")
                lRet := .F.
            Endif
        Endif
    Endif
Endif

RestArea(aArea)

Return(lRet)
