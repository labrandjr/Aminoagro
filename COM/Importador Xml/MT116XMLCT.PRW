#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT116XMLCT ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 05/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Vincula pedidos de compras ao importar um documento.       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT116XMLCT()

Local aArea   := GetArea()
Local lImpXml := GetMv("MV_IMPXML")
Local oXml    := PARAMIXB[1]
Local zDoc    := PARAMIXB[2]
Local zSer    := PARAMIXB[3]
Local zFor    := PARAMIXB[4]
Local zLoj    := PARAMIXB[5]
//Local zTip  := PARAMIXB[6]
Local zOpc    := PARAMIXB[7] //PF - Produto Frete, PN - Produto na NF original
Local _x

If lImpXml

    If ValType(XmlChildEx(oXml:_InfCte:_VPrest,"_COMP")) $("A,O")
        aCompon := oXml:_InfCte:_VPrest:_Comp
        If ValType(aCompon) == "A"
            For _x := 1 to Len(aCompon)
                xNome := Upper(AllTrim(aCompon[_x]:_xNome:Text))
                If "PEDAGIO" $(xNome)
                    vComp := Val(aCompon[_x]:_vComp:Text)
                    If vComp > 0
                        RecLock("SDS",.F.)
                        SDS->DS_ZVALPED := vComp
                        MsUnLock()
                        Exit
                    Endif
                Endif
            Next _x
        Else
            xNome := Upper(AllTrim(aCompon:_xNome:Text))
            If "PEDAGIO" $(xNome)
                vComp := Val(aCompon:_vComp:Text)
                If vComp > 0
                    RecLock("SDS",.F.)
                    SDS->DS_ZVALPED := vComp
                    MsUnLock()
                Endif
            Endif
        Endif
    Endif

    If zOpc == "PF"

        DbSelectArea("ZZO")
        DbSetOrder(1)
        If DbSeek( xFilial("ZZO") + zDoc + zSer + zFor + zLoj )
            While !Eof() .And. ZZO->(ZZO_FILIAL+ZZO_DOCCTE+ZZO_SERCTE+ZZO_FORCTE+ZZO_LOJCTE) == xFilial("ZZO") + zDoc + zSer + zFor + zLoj
                RecLock("ZZO",.F.)
                ZZO->(DbDelete())
                ZZO->(MsUnLock())
                ZZO->(DbSkip())
            Enddo
        Endif

        If ValType(XmlChildEx(oXml:_InfCte,"_INFCTENORM")) $("A,O")
            If ValType(XmlChildEx(oXml:_InfCte:_InfCteNorm:_InfDoc,"_INFNFE")) $("A,O")
                aInfDoc := oXml:_InfCte:_InfCteNorm:_InfDoc:_INFNFE
                If ValType(aInfDoc) == "A"
                    For _x := 1 to Len(aInfDoc)
                        cChvNfe := AllTrim(aInfDoc[_x]:_Chave:Text)
                        //
                        RecLock("ZZO",.T.)
                        ZZO->ZZO_FILIAL := xFilial("SDT")
                        ZZO->ZZO_DOCCTE := zDoc
                        ZZO->ZZO_SERCTE := zSer
                        ZZO->ZZO_FORCTE := zFor
                        ZZO->ZZO_LOJCTE := zLoj
                        ZZO->ZZO_CHVNFE := cChvNfe
                        ZZO->(MsUnLock())
                        //
                        aDocNfe := u_GetDocChv(xFilial("ZZO"),zDoc,zSer,zFor,cChvNfe)
                        If Len(aDocNfe) > 0
                            u_GrvDocChv(zDoc,zSer,zFor,zLoj,cChvNfe,aDocNfe)
                        Endif
                    Next _x
                Else
                    cChvNfe := AllTrim(aInfDoc:_Chave:Text)
                    //
                    RecLock("ZZO",.T.)
                    ZZO->ZZO_FILIAL := xFilial("SDT")
                    ZZO->ZZO_DOCCTE := zDoc
                    ZZO->ZZO_SERCTE := zSer
                    ZZO->ZZO_FORCTE := zFor
                    ZZO->ZZO_LOJCTE := zLoj
                    ZZO->ZZO_CHVNFE := cChvNfe
                    ZZO->(MsUnLock())
                    //
                    aDocNfe := u_GetDocChv(xFilial("ZZO"),zDoc,zSer,zFor,cChvNfe)
                    If Len(aDocNfe) > 0
                        u_GrvDocChv(zDoc,zSer,zFor,zLoj,cChvNfe,aDocNfe)
                    Endif
                Endif
                u_RatDocCte(zDoc,zSer,zFor,zLoj)
            Endif
        Endif

    Endif

Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetDocChv  ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 27/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Localiza documento original pela chave Sefaz.              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GetDocChv(zFil,zDoc,zSer,zFor,cChvNfe)

Local aArea   := GetArea()
Local aRetX   := {}
Local cCtaFre := "41202007"
Local aTesCte := {}

cQry := " SELECT R_E_C_N_O_ "
cQry += " FROM "+RetSqlName("SF1")
cQry += " WHERE F1_CHVNFE = '"+cChvNfe+"' "
cQry += " AND D_E_L_E_T_ <> '*' "
cQry := ChangeQuery(cQry)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"TRB1", .T., .T.)

DbSelectArea("TRB1")
TRB1->(DbGotop())
If !Eof()

	DbSelectArea("SF1")
	SF1->(DbGoto(TRB1->R_E_C_N_O_))

    DbSelectArea("SD1")
    DbSetOrder(1)
    If DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
        If !Empty(SD1->D1_TES)
            zConta := POSICIONE("SF4",1,SD1->(D1_FILIAL+D1_TES),"F4_ZCTACTE")
            If Empty(zConta)
                lAdd := .F.
                If Len(aTesCte) == 0
                    lAdd := .T.
                Else
                    If aScan(aTesCte, {|x| x == SD1->D1_TES }) == 0
                        lAdd := .T.
                    Endif
                Endif	
                If lAdd
                    AAdd(aTesCte,SD1->D1_TES)
                Endif
                zConta := cCtaFre
            Endif
            AAdd(aRetX,"E")
            AAdd(aRetX,SF1->F1_FILIAL)
            AAdd(aRetX,SF1->F1_DOC)
            AAdd(aRetX,SF1->F1_SERIE)
            AAdd(aRetX,SF1->F1_FORNECE)
            AAdd(aRetX,SF1->F1_LOJA)
            AAdd(aRetX,SF1->F1_TIPO)
            AAdd(aRetX,SD1->D1_TES)
            AAdd(aRetX,zConta)
            AAdd(aRetX,SD1->D1_CC)
            AAdd(aRetX,SF1->F1_VALMERC)
        Endif            
    Endif

Endif
TRB1->(DbCloseArea())

If Len(aRetX) == 0

    cQry := " SELECT R_E_C_N_O_ "
    cQry += " FROM "+RetSqlName("SF2")
    cQry += " WHERE F2_CHVNFE = '"+cChvNfe+"' "
    cQry += " AND D_E_L_E_T_ <> '*' "
    cQry := ChangeQuery(cQry)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"TRB2", .T., .T.)

    DbSelectArea("TRB2")
    TRB2->(DbGotop())
    If !Eof()

        DbSelectArea("SF2")
        SF2->(DbGoto(TRB2->R_E_C_N_O_))

        DbSelectArea("SD2")
        DbSetOrder(3)
        If DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) )
            zConta := POSICIONE("SF4",1,SD2->(D2_FILIAL+D2_TES),"F4_ZCTACTE")
            If Empty(zConta)
                lAdd := .F.
                If Len(aTesCte) == 0
                    lAdd := .T.
                Else
                    If aScan(aTesCte, {|x| x == SD2->D2_TES }) == 0
                        lAdd := .T.
                    Endif
                Endif	
                If lAdd
                    AAdd(aTesCte,SD2->D2_TES)
                Endif
                zConta := cCtaFre
            Endif
            AAdd(aRetX,"S")
            AAdd(aRetX,SF2->F2_FILIAL)
            AAdd(aRetX,SF2->F2_DOC)
            AAdd(aRetX,SF2->F2_SERIE)
            AAdd(aRetX,SF2->F2_CLIENTE)
            AAdd(aRetX,SF2->F2_LOJA)
            AAdd(aRetX,SF2->F2_TIPO)
            AAdd(aRetX,SD2->D2_TES)
            AAdd(aRetX,zConta)
            AAdd(aRetX,SD2->D2_CCUSTO)
            AAdd(aRetX,SF2->F2_VALMERC)
        Endif

    Endif
    TRB2->(DbCloseArea())

Endif

If Len(aTesCte) > 0
    u_EmlCCte(zFil, zDoc, zSer, zFor, aTesCte)
Endif

RestArea(aArea)

Return(aRetX)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GrvDocChv  ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 27/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação do rateio Ct-e.                                   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GrvDocChv(zDoc,zSer,zFor,zLoj,cChvNfe,aDocNfe)

Local aArea := GetArea()

If aDocNfe[1] == "E"
    If aDocNfe[7] $("D,B")
        zNome := POSICIONE("SA1",1,xFilial("SA1")+aDocNfe[5]+aDocNfe[6],"A1_NOME")
    Else
        zNome := POSICIONE("SA2",1,xFilial("SA2")+aDocNfe[5]+aDocNfe[6],"A2_NOME")
    Endif
Else
    If aDocNfe[7] $("D,B")
        zNome := POSICIONE("SA2",1,xFilial("SA2")+aDocNfe[5]+aDocNfe[6],"A2_NOME")
    Else
        zNome := POSICIONE("SA1",1,xFilial("SA1")+aDocNfe[5]+aDocNfe[6],"A1_NOME")
    Endif
Endif

DbSelectArea("ZZO")
DbSetOrder(1)
If DbSeek( xFilial("ZZO") + zDoc + zSer + zFor + zLoj + cChvNfe )
    RecLock("ZZO",.F.)
    ZZO->ZZO_TIPCHV := aDocNfe[1]
    ZZO->ZZO_FILNFE := aDocNfe[2]
    ZZO->ZZO_DOCNFE := aDocNfe[3]
    ZZO->ZZO_SERNFE := aDocNfe[4]
    ZZO->ZZO_CLIFOR := aDocNfe[5]
    ZZO->ZZO_LOJNFE := aDocNfe[6]
    ZZO->ZZO_NOMNFE := zNome
    ZZO->ZZO_TIPNFE := aDocNfe[7]
    ZZO->ZZO_TESNFE := aDocNfe[8]
    ZZO->ZZO_CTANFE := aDocNfe[9]
    ZZO->ZZO_CCNFE  := aDocNfe[10]
    ZZO->ZZO_VALMER := aDocNfe[11]
    ZZO->(MsUnLock())
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RatDocCte  ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 27/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Rateia o frete conforme as chaves do Ct-e.                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function RatDocCte(zDoc,zSer,zFor,zLoj)

Local aArea := GetArea()

// Totaliza valor das NF-e
nTotMer := 0
nQtdDoc := 0
DbSelectArea("ZZO")
DbSetOrder(1)
If DbSeek( xFilial("ZZO") + zDoc + zSer + zFor + zLoj )
    While !Eof() .And. ZZO->(ZZO_FILIAL+ZZO_DOCCTE+ZZO_SERCTE+ZZO_FORCTE+ZZO_LOJCTE) == xFilial("ZZO") + zDoc + zSer + zFor + zLoj
        If ZZO->ZZO_VALMERC > 0
            nTotMer += ZZO->ZZO_VALMER
            nQtdDoc += 1
        Endif            
        ZZO->(DbSkip())
    Enddo
Endif

// Calcula o rateio do Ct-e
nFator := (SDS->DS_VALMERC / nTotMer)
nCount := 0
nValAc := 0
DbSelectArea("ZZO")
DbSetOrder(1)
If DbSeek( xFilial("ZZO") + zDoc + zSer + zFor + zLoj )
    While !Eof() .And. ZZO->(ZZO_FILIAL+ZZO_DOCCTE+ZZO_SERCTE+ZZO_FORCTE+ZZO_LOJCTE) == xFilial("ZZO") + zDoc + zSer + zFor + zLoj
        If ZZO->ZZO_VALMERC > 0
            nCount += 1
            nVlRat := Round((ZZO->ZZO_VALMER * nFator),2)
            RecLock("ZZO",.F.)
            If nCount == nQtdDoc
                ZZO->ZZO_VRAT := SDS->DS_VALMERC - nValAc
            Else
                ZZO->ZZO_VRAT := nVlRat
            Endif
            ZZO->(MsUnLock())
            nValAc += nVlRat
        Endif
        ZZO->(DbSkip())
    Enddo
Endif

RestArea(aArea)

Return
