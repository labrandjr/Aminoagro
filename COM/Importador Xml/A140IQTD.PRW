#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A140IQTD  ¦ Autor ¦ Fábrica ERP.BR  ¦  Data  ¦ 05/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ 3-Permite alterar quantidade e valor unitário.             ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A140IQTD()

Local aArea     := GetArea()
Local lImpXml   := GetMv("MV_IMPXML")
Local zProduto  := PARAMIXB[1]
Local zUM       := PARAMIXB[2]
//Local zSegum  := PARAMIXB[3]
Local zQtSegum  := PARAMIXB[4]
Local zQtdeIt   := PARAMIXB[5]
Local zPrcIt    := PARAMIXB[6]
Local zTotIt    := PARAMIXB[7]
//Local lConvUM := PARAMIXB[8]
Local zForn     := PARAMIXB[9]
Local zLoja     := PARAMIXB[10]
//Local zDoc    := PARAMIXB[11]
//Local zSerie  := PARAMIXB[12]
//Local zTipo   := PARAMIXB[13]
Local lA5A7     := PARAMIXB[14]
Local oXML      := PARAMIXB[15]
Local aRet      := Array(4)

If lImpXml
    DbSelectArea("SB1")
    DbSetOrder(1)
    If DbSeek( xFilial("SB1") + zProduto )
        cUmXml := GetUmXml(zForn,zLoja,zProduto,lA5A7,oXml,zUM)
        If AllTrim(cUmXml) == "GL" .And. SB1->B1_TIPO == "PA" .And. AllTrim(SB1->B1_UM) == "L"
            aRet[1] := zQtdeIt * SB1->B1_CONV
            aRet[2] := (zTotIt / aRet[1])
            aRet[3] := zTotIt
            aRet[4] := zQtdeIt
        Else
            aRet[1] := zQtdeIt
            aRet[2] := zPrcIt
            aRet[3] := zTotIt
            aRet[4] := zQtSegum
        Endif
    Endif
Endif

RestArea(aArea)

Return(aRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetUmXml  ¦ Autor ¦ Fábrica ERP.BR  ¦  Data  ¦ 05/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verifica a 1a.unidade de medida no Xml.                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetUmXml(zForn,zLoja,zProduto,lA5A7,oXml,zUM)

Local aArea   := GetArea()
Local cRetUM  := zUM
Local aDetXml := oXml:_InfNfe:_Det
Local cCodRef := ""
Local _x

If !lA5A7 // SA5 (Fornecedor)
    DbSelectArea("SA5")
    DbSetOrder(2)
    If DbSeek( xFilial("SA5") + zProduto + zForn + zLoja )
        cCodRef := AllTrim(SA5->A5_CODPRF) // C 020
    Endif
Else // SA7 (Cliente)
    DbSelectArea("SA7")
    DbSetOrder(2)
    If DbSeek( xFilial("SA7") + zProduto + zForn + zLoja )
        cCodRef := AllTrim(SA7->A7_CODCLI) // C 020
    Endif
Endif

If !Empty(cCodRef)
    If ValType(aDetXml) == "A"
        For _x := 1 to Len(aDetXml)
            cPrdXml := AllTrim(aDetXml[_x]:_Prod:_cProd:Text)
            If cPrdXml == cCodRef
                cRetUM := Upper(AllTrim(aDetXml[_x]:_Prod:_uCom:Text))
                Exit
            Endif
        Next _x
    Else
        cPrdXml := AllTrim(aDetXml:_Prod:_cProd:Text)
        If cPrdXml == cCodRef
            cRetUM := Upper(AllTrim(aDetXml:_Prod:_uCom:Text))
        Endif
    Endif
Endif

RestArea(aArea)

Return(cRetUM)
