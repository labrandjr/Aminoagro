#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COLF1D1    ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 09/11/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona campos na SF1 e SD1 antes da geração do documento.¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COLF1D1()

Local lImpXml := GetMv("MV_IMPXML")
Local aCabec  := ParamIxb[1]
Local aItens  := ParamIxb[2]
Local aRetCpo := {}
Local _d

If lImpXml
    If SDS->DS_ZVALPED > 0
        nPos1 := aScan(aCabec, {|x| x[1] == "F1_ESPECIE"})
        If AllTrim(aCabec[nPos1][2]) == "CTE"
            nPos2 := aScan(aCabec, {|x| x[1] == "F1_ORIGEM"})
            If AllTrim(aCabec[nPos2][2]) == "COMXCOL"
                nPos3 := aScan(aItens[1], {|x| x[1] == "D1_COD"})
                If AllTrim(aItens[1][nPos3][2]) == AllTrim(GetMv("MV_XMLPFCT")) .Or. Len(aItens) == 1
                    nPosVunit := aScan(aItens[1], {|x| x[1] == "D1_VUNIT"})
                    nPosTotal := aScan(aItens[1], {|x| x[1] == "D1_TOTAL"})
                    aItens[1][nPosVunit][2] -= SDS->DS_ZVALPED
                    aItens[1][nPosTotal][2] -= SDS->DS_ZVALPED
                    AAdd(aCabec,{"F1_VALPEDG", SDS->DS_ZVALPED, Nil})
                Endif
            Endif
        Endif
    ElseIf SDS->DS_TIPO == "D"
        For _d := 1 to Len(aItens)
            nPosNfO := aScan(aItens[_d], {|x| x[1] == "D1_NFORI"})
            nPosSeO := aScan(aItens[_d], {|x| x[1] == "D1_SERIORI"})
            nPosItO := aScan(aItens[_d], {|x| x[1] == "D1_ITEMORI"})
            nPosPrd := aScan(aItens[_d], {|x| x[1] == "D1_COD"})
            nPosCCu := aScan(aItens[_d], {|x| x[1] == "D1_CC"})
            nPosUnd := aScan(aItens[_d], {|x| x[1] == "D1_ITEMCTA"})
            //
            If nPosNfO > 0 .And. nPosSeO > 0 .And. nPosItO > 0
                zNfOrig := aItens[_d][nPosNfO][2]
                zSeriOr := aItens[_d][nPosSeO][2]
                zItemOr := aItens[_d][nPosItO][2]
                zProdut := aItens[_d][nPosPrd][2]
                If !Empty(zNfOrig)
                    zCCusto := RetField("SD2",3,xFilial("SD2")+zNfOrig+zSeriOr+SDS->DS_FORNEC+SDS->DS_LOJA+zProdut+zItemOr,"D2_CCUSTO")
                    zItemCc := RetField("SD2",3,xFilial("SD2")+zNfOrig+zSeriOr+SDS->DS_FORNEC+SDS->DS_LOJA+zProdut+zItemOr,"D2_ITEMCC")
                    If nPosCCu > 0
                        aItens[_d][nPosCCu][2] := zCCusto
                    Else
                        AAdd(aItens[_d],{"D1_CC", zCCusto, Nil})
                    Endif
                    If nPosUnd > 0
                        aItens[_d][nPosUnd][2] := zItemCc
                    Else
                        AAdd(aItens[_d],{"D1_ITEMCTA", zItemCc, Nil})
                    Endif
                Endif
            Endif
        Next _d
    Endif
Endif    

aRetCpo := {aCabec,aItens}

Return(aRetCpo)

