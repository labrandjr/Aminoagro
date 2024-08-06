#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M320FIM   ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 09/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização das MOD na tabela de Indicadores de Produtos.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function M320FIM()

Local aArea   := GetArea()
Local xEmpOri := SM0->M0_CODIGO 
Local nRecSM0 := SM0->(Recno())
Local xFilOri := cFilAnt
Local aCgcFil := {}
Local _x

DbSelectArea("SM0")
DbSetOrder(1)
DbSeek( xEmpOri )
While !Eof() .And. SM0->M0_CODIGO == xEmpOri
	AAdd(aCgcFil,{SM0->M0_CGC,AllTrim(SM0->M0_CODFIL),.F.})
	SM0->(DbSkip())
Enddo

For _x := 1 to Len(aCgcFil)

	cFilAnt := aCgcFil[_x][2]
	cNomFil := FWFilialName(cEmpAnt,cFilAnt,1)

	MsgRun("Aguarde, atualizando Indicadores de MOD..."+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil),"Processando",{|| _IndicMOD(cFilAnt) })

Next _x

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _IndicMOD ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 09/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização das MOD na tabela de Indicadores de Produtos.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _IndicMOD(cFilAnt)

cQuery := " SELECT B2_COD, B2_LOCAL, B2_CM1 "
cQuery += " FROM "+RetSqlName("SB2")+" SB2, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE B2_FILIAL = '"+cFilAnt+"' "
cQuery += " AND B2_COD = B1_COD "
cQuery += " AND B2_LOCAL = B1_LOCPAD "
cQuery += " AND B1_TIPO = 'MO' "
cQuery += " AND B1_MSBLQL <> '1' "
cQuery += " AND B2_CM1 > 0 "
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY B2_COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSB2", .F., .T.)
TSB2->(DbGotop())
While !Eof()

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + TSB2->B2_COD )

	DbSelectArea("SBZ")
	DbSetOrder(1)
	If !DbSeek( cFilAnt + SB1->B1_COD )

		aCab := {}
        lMsErroAuto := .F.
        
        AAdd(aCab,{"BZ_COD"     , SB1->B1_COD   , Nil})
        AAdd(aCab,{"BZ_LOCPAD"  , SB1->B1_LOCPAD, Nil})
        AAdd(aCab,{"BZ_ZZDESC"  , SB1->B1_DESC  , Nil})
        AAdd(aCab,{"BZ_CUSTD"   , TSB2->B2_CM1  , Nil})
        AAdd(aCab,{"BZ_UCALSTD" , Date()        , Nil})

        MsExecAuto({|v,x| MATA018(v,x)},aCab,3)
        If !lMsErroAuto
            ConOut("Sucesso na atualização de Indicadores: "+SB1->B1_COD)
        Else
            ConOut("Erro na atualização de Indicadores: "+SB1->B1_COD)
	        MostraErro()
        Endif

	Else

		RecLock("SBZ",.F.)
		SBZ->BZ_CUSTD   := TSB2->B2_CM1
		SBZ->BZ_UCALSTD := Date()
		MsUnLock()

	Endif

	DbSelectArea("TSB2")
	TSB2->(DbSkip())	
Enddo
TSB2->(DbCloseArea())	

Return
