#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COMXPROC   ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 20/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação na geração de documentos.                        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COMXPROC()

Local lImpXml := GetMv("MV_IMPXML")
Local lRetDoc := .T.

If lImpXml
    If SDS->DS_ZCOMB == "S"
        lRetDoc := .F.
    ElseIf SDS->DS_ZCANC == "S"
        lRetDoc := .F.
        If SDS->DS_TIPO=="T"
            cMsgAlert := "Ct-e "+AllTrim(SDS->DS_DOC)+" cancelado na Sefaz."
        Else
            cMsgAlert := "Nf-e "+AllTrim(SDS->DS_DOC)+" cancelada na Sefaz."
        Endif            
        MsgAlert(cMsgAlert)
    ElseIf SDS->DS_TIPO == "T"
        DbSelectArea("SDT")
        DbSetOrder(1)
        If DbSeek( SDS->(DS_FILIAL+DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE) )
            If AllTrim(SDT->DT_COD) == AllTrim(GetMv("MV_XMLPFCT"))
                DbSelectArea("ZZO")
                DbSetOrder(1)
                If DbSeek( SDS->(DS_FILIAL + DS_DOC + DS_SERIE + DS_FORNEC + DS_LOJA) )
                    While !Eof() .And. ZZO->(ZZO_FILIAL+ZZO_DOCCTE+ZZO_SERCTE+ZZO_FORCTE+ZZO_LOJCTE) == SDS->(DS_FILIAL + DS_DOC + DS_SERIE + DS_FORNEC + DS_LOJA)
                        aDocNfe := u_GetDocChv(ZZO->ZZO_FILIAL, ZZO->ZZO_DOCCTE, ZZO->ZZO_SERCTE, ZZO->ZZO_FORCTE, ZZO->ZZO_CHVNFE)
                        If Len(aDocNfe) > 0
                            u_GrvDocChv(SDS->DS_DOC, SDS->DS_SERIE, SDS->DS_FORNEC, SDS->DS_LOJA, ZZO->ZZO_CHVNFE, aDocNfe)
                        Else
                            lRetDoc := .F.
                            cMsgAlert := "Ct-e "+AllTrim(SDS->DS_DOC)+" não possui a Nf-e transportada cadastrada (Chave "+ZZO->ZZO_CHVNFE+")."
                            MsgAlert(cMsgAlert)
                            Exit
                        Endif
                        DbSelectArea("ZZO")
                        ZZO->(DbSkip())
                    Enddo
                    If lRetDoc
                        u_RatDocCte(SDS->DS_DOC, SDS->DS_SERIE, SDS->DS_FORNEC, SDS->DS_LOJA)
                    Endif                        
                Endif
            Endif
        Endif
    Endif
Endif

Return(lRetDoc)
