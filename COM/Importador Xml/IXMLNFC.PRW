#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IXMLNFC    ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 21/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geração de documento de entrada para combustíveis.         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IXMLNFC()

Local aArea    := GetArea()
Local lImpXml  := GetMv("MV_IMPXML")
Local cPerg	   := "LAN0003"
Local dDatPrz  := Date()-3
Local zFiliais := ""
Local nForFilial

If !lImpXml
    MsgAlert("Importador Xml não habilitado.")
    Return
Endif

aFilsCalc := MatFilCalc(.T.)
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

If Pergunte(cPerg,.T.)

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SDS")
	cQuery += " WHERE DS_FILIAL IN("+zFiliais+") "
	cQuery += " AND DS_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND DS_FORNEC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
	cQuery += " AND DS_DOC BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
	If !Empty(mv_par07)
		cQuery += " AND DS_CNPJ = '"+mv_par07+"' "
	Endif
	cQuery += " AND DS_EMISSA <= '"+DtoS(dDatPrz)+"' " // Emitidas a pelo menos 03 dias
	cQuery += " AND DS_ZCOMB = 'S' "
	cQuery += " AND DS_ZCANC <> 'S' "
    cQuery += " AND DS_STATUS = ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TREG", .F., .T.)
	zTotReg := TREG->SOMA
	TREG->(DbCloseArea())
	
	If zTotReg == 0
		MsgAlert("Não foram encontrados documentos de combustível para geração. Verifique os parâmetros.")
	Else
		MsgRun("Aguarde, gerando documentos de combustível...","Processando",{|| _NfeCombust(zFiliais) })
		MsgInfo("Processo concluído.")
	Endif

Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _NfeCombust ¦ Autor ¦ Fábrica ERP.BR   ¦ Data   ¦ Out/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _NfeCombust(zFiliais)

Local dDatPrz := Date()-3

cQuery := " SELECT R_E_C_N_O_ RECSDS "
cQuery += " FROM "+RetSqlName("SDS")
cQuery += " WHERE DS_FILIAL IN("+zFiliais+") "
cQuery += " AND DS_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND DS_FORNEC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND DS_DOC BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
If !Empty(mv_par07)
	cQuery += " AND DS_CNPJ = '"+mv_par07+"' "
Endif
cQuery += " AND DS_EMISSA <= '"+DtoS(dDatPrz)+"' " // Emitidas a pelo menos 03 dias
cQuery += " AND DS_ZCOMB = 'S' "
cQuery += " AND DS_ZCANC <> 'S' "
cQuery += " AND DS_STATUS = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY DS_FILIAL, DS_DOC, DS_SERIE, DS_FORNEC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSDS", .F., .T.)
    
DbSelectArea("TSDS")
TSDS->(DbGotop())
While !Eof()

	DbSelectArea("SDS")
	SDS->(DbGoto(TSDS->RECSDS))

	_lRetPre := U_NotaComb() // Gera NF Combustivel

	DbSelectArea("SDS")
	SDS->(DbGoto(TSDS->RECSDS))

	DbSelectArea("TSDS")
	TSDS->(DbSkip())	
Enddo
TSDS->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ NotaComb   ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Fev/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao de NF Combustiveis em Livros Fiscais				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/


User Function NotaComb()

Local aArea := GetArea()
Local cFilBkp  := cFilAnt
Local lRetorno := .F.
Private lPcNfe := GetMv("MV_PCNFE")
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

PutMV("MV_PCNFE",.F.) // Desliga pedido de compra obrigatório

cFilAnt := SDS->DS_FILIAL

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek( xFilial("SA2") + SDS->(DS_FORNEC + DS_LOJA) )
If SA2->A2_MSBLQL == "1"
	MsgAlert("O fornecedor ("+AllTrim(SA2->A2_CGC)+" - "+AllTrim(SA2->A2_NOME)+") está bloqueado para uso.")
	PutMV( "MV_PCNFE", lPcNfe )
    Return(lRetorno)
Endif

// Verifica se a Nota Fiscal ja existe
DbSelectArea("SF1")
DbSetOrder(1)
If DbSeek( xFilial("SF1") + SDS->(DS_DOC + DS_SERIE + DS_FORNEC + DS_LOJA) )
	MsgAlert("O Documento "+SDS->DS_DOC+"/"+AllTrim(SDS->DS_SERIE)+" do Fornecedor "+SA2->A2_COD+"-"+AllTrim(SA2->A2_NOME)+" já existe.")
	//
    RecLock("SDS",.F.)
    SDS->DS_STATUS := "P"
    MsUnLock()
    //
    PutMV("MV_PCNFE",lPcNfe)
	Return(lRetorno)
Endif

aCabec := {}
aItens := {}
cCondP := IIf(Empty(SA2->A2_COND),"007",SA2->A2_COND)
zItem  := "0000"

AAdd(aCabec,{"F1_TIPO"	  , "N"             , Nil , Nil})
AAdd(aCabec,{"F1_FORMUL"  , "N"             , Nil , Nil})
AAdd(aCabec,{"F1_DOC"	  , SDS->DS_DOC     , Nil , Nil})
AAdd(aCabec,{"F1_SERIE"	  , SDS->DS_SERIE   , Nil , Nil})
AAdd(aCabec,{"F1_DTDIGIT" , Date()          , Nil , Nil})
aadd(aCabec,{"F1_EMISSAO" , SDS->DS_EMISSA  , Nil , Nil})
aadd(aCabec,{"F1_FORNECE" , SDS->DS_FORNEC  , Nil , Nil})
aadd(aCabec,{"F1_LOJA"    , SDS->DS_LOJA    , Nil , Nil})
aadd(aCabec,{"F1_ESPECIE" , "SPED"          , Nil , Nil})
Aadd(aCabec,{"F1_CHVNFE"  , SDS->DS_CHAVENF , Nil , Nil})
AAdd(aCabec,{"F1_COND"	  , cCondP          , Nil , Nil})

DbSelectArea("SDT")
DbSetOrder(1)
DbSeek( SDS->(DS_FILIAL+DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE) )
While !Eof() .And. SDT->(DT_FILIAL+DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDS->(DS_FILIAL+DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)

    DbSelectArea("SB1")
    DbSetOrder(1)
    DbSeek( xFilial("SB1") + SDT->DT_COD )

	DbSelectArea("SF4")
	DbSetOrder(1)
    If DbSeek( SDT->DT_FILIAL + "222" )
	    _cCfopTes := SF4->F4_CF
    Else
        MsgAlert("TES '222' não cadastrado na Filial "+SDT->DT_FILIAL)
        aItens := {}
        Exit
    Endif        

	_cfop := SDT->DT_CODCFOP
	If Left(Alltrim(_cfop),1) == "5"
		_cfop := Stuff(_cCfopTes,1,1,"1")
	Else
		_cfop := Stuff(_cCfopTes,1,1,"2")
	Endif

	zItem  := Soma1(zItem)
	aLinha := {}

	AAdd(aLinha,{"D1_ITEM"    , zItem           , Nil , Nil})
	AAdd(aLinha,{"D1_COD"     , SB1->B1_COD     , Nil , Nil})
	AAdd(aLinha,{"D1_LOCAL"	  , SB1->B1_LOCPAD  , Nil , Nil})
	AAdd(aLinha,{"D1_QUANT"   , SDT->DT_QUANT   , Nil , Nil})
	AAdd(aLinha,{"D1_VUNIT"   , SDT->DT_VUNIT   , Nil , Nil})
	AAdd(aLinha,{"D1_TOTAL"   , SDT->DT_TOTAL   , Nil , Nil})
	AAdd(aLinha,{"D1_TES"     , "222"           , Nil , Nil})
	AAdd(aLinha,{"D1_CF"      , _cfop           , Nil , Nil})
	AAdd(aLinha,{"D1_VALDESC" , SDT->DT_VALDESC , Nil , Nil})
    AAdd(aItens,aLinha)

    DbSelectArea("SDT")
    SDT->(DbSkip())
Enddo

If Len(aItens) > 0

	PutMv("MV_CHVNFE",.F.)
	PutMv("MV_DCHVNFE",.F.)
	
	SB1->(DbSetOrder(1))
	SA2->(DbSetOrder(1))
	SF4->(DbSetOrder(1))
	
	MSExecAuto({ |x,y,z| MATA103(x,y,z) }, aCabec, aItens, 3)
	
	If lMsErroAuto
		MostraErro()
		lRetorno := .F.
	Else
		ConfirmSx8()
		RecLock("SF1",.F.)
        SF1->F1_XIMPXML	:= "S"
		MsUnlock()
        lRetorno := .T.
	Endif

	PutMv("MV_CHVNFE",.T.)
	PutMv("MV_DCHVNFE",.T.)

Endif

cFilAnt := cFilBkp

RestArea(aArea)

Return(lRetorno)
