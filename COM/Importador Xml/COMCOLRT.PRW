#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COMCOLRT   ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 20/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Novas rotinas no menu do Importador Xml.                   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COMCOLRT()

Local lImpXml := GetMv("MV_IMPXML")
Local aRotina := ParamIxb[1]

If lImpXml
    AAdd( aRotina, { "Gerar Docto - Comb","U_IXMLNFC()",0,4,0,NIL} )
    AAdd( aRotina, { "NF não Geradas"    ,"U_IXMLNNG()",0,4,0,NIL} )
    AAdd( aRotina, { "Rateio Ct-e"       ,"U_IXMLRCT('SDS')",0,4,0,NIL} )
    AAdd( aRotina, { "XML Cancelados"    ,"U_IXMLCANC()",0,4,0,NIL} )
Endif    

Return(aRotina)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IXMLRCT  ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 27/10/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta rateio Ct-e.                    				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IXMLRCT(xRot)

Local aArea   := GetArea()
Local aRotBkp := aClone(aRotina)
Local cCadBkp := cCadastro

Private cCadastro := "Rateio Ct-e"

Private aRotina := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	    {"Visualizar" , "AxVisual" , 0 , 2 }}

Private cFiltro := ""

cFiltro += " ZZO_FILIAL == '"+IIf(xRot=="SDS",SDS->DS_FILIAL,SF1->F1_FILIAL)+"' "
cFiltro += ".And. ZZO_DOCCTE == '"+IIf(xRot=="SDS",SDS->DS_DOC,SF1->F1_DOC)+"' "
cFiltro += ".And. ZZO_SERCTE == '"+IIf(xRot=="SDS",SDS->DS_SERIE,SF1->F1_SERIE)+"' "
cFiltro += ".And. ZZO_FORCTE == '"+IIf(xRot=="SDS",SDS->DS_FORNEC,SF1->F1_FORNECE)+"' "
cFiltro += ".And. ZZO_LOJCTE == '"+IIf(xRot=="SDS",SDS->DS_LOJA,SF1->F1_LOJA)+"' "

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "ZZO" )
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "ZZO", , , "ZZO_FILENT" )		 
oMBrowse:ExecuteFilter()

oMBrowse:Activate()

DbSelectArea("ZZO")
DbSetOrder(1)
DbClearFilter()
		
cCadastro := cCadBkp
aRotina := aClone(aRotBkp)

RestArea(aArea)

Return
