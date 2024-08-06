#include "protheus.ch"
#include "totvs.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QDMSENV   ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 09/02/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio do extrato via schedule - Modelo DM.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QDMSENV(zzData,zzPar03,zzPar04)

Local zVenAnt  := ""
Local zPerDms  := 0
Local lKeyOk3  := .F.
Local aVenDet  := {}
Local aRanking := {}
Local aLista   := {}
Local lGrvLog  := .F.
Local dDatExt  := zzData
Local zPorcDM  := GetMv("ZZ_PERCDMS")
Local _env, _del
Private mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08, mv_par09, mv_par10, mv_par11, mv_par12, mv_par13, mv_par14, mv_par15

If Month(dDatExt) == 1
	Return
Else
	mv_par01 := StoD( Substr(DtoS(dDatExt),1,4) + "0101" )
Endif
mv_par02 := StoD( Substr(DtoS(dDatExt),1,4) + Substr(DtoS(dDatExt),5,2) + "01" )
mv_par03 := zzPar03 //Space(6)
mv_par04 := zzPar04 //"ZZZZZZ"
mv_par05 := 1  // Ordena detalhe por ? Ranking
mv_par06 := "\premiacao"
mv_par07 := 2  // Visualizar ? Não
mv_par08 := 1  // Enviar Email ? Sim
mv_par09 := "" // cc Email 1
mv_par10 := "" // cc Email 2
mv_par11 := "" // cc Email 3
mv_par12 := "" // cc Email 4
mv_par13 := 2  // Seleciona Filiais ? Não
mv_par14 := 1  // Considera quais ? A Pagar
mv_par15 := 3  // Status ? Todos

zMes := Month(mv_par02)
zAno := Year(mv_par02)
If zAno <= 2022
	If zMes <= 8
		If (zMes-1) == 0
			zMes := 12
			zAno -= 1
		Else
			zMes -= 1
		Endif
	Endif
Endif
zAfi := StoD(AllTrim(STR(zAno))+StrZero(zMes,2)+"01")
zIni := Upper(MesExtenso(mv_par01))
zFim := Upper(MesExtenso(zAfi))
zPer := zIni+" A "+zFim+" DE "+Year2Str(zAfi)
If Year(mv_par01) != zAno
	zPer := zIni+" "+Year2Str(mv_par01)+" A "+zFim+" "+Year2Str(zAfi)
Endif

zVenAnt  := ""
lKeyOk3  := .F.
aVenDet  := {}
aRanking := {}

cQuery := " SELECT SE3.* "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_FILIAL <> ' ' "
cQuery += " AND E3_ZZDM = A3_COD "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
cQuery += " AND E3_ZZDM BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND E3_ZZDM <> ' ' " // Somente DM
cQuery += " AND E3_ZZRTV = ' ' " // Não considera apuração --> Nesta rotina a apuração será feita em tempo real pois o período está em aberto.
If mv_par14 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par14 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par15 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par15 == 2 // Inativos
	cQuery += " AND A3_MSBLQL = '1' "
Endif
cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E3_ZZDM, E3_VEND, E3_CODCLI, E3_LOJA, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

DbSelectArea("SQL3")
SQL3->(DbGotop())
While !Eof()

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek( xFilial("SA3") + SQL3->E3_ZZDM )

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SQL3->E3_CODCLI + SQL3->E3_LOJA )

	If SQL3->E3_ZZDM != zVenAnt
		If lKeyOk3
			u_ExtrDms(zVenAnt,aVenDet,aRanking,zPerDms,@aLista,zPer,lGrvLog)
			aVenDet  := {}
			aRanking := {}
		Else
			lKeyOk3 := .T.
		Endif
		zVenAnt := SQL3->E3_ZZDM
		zPerDms := zPorcDM
	Endif

	zCodRtv  := SQL3->E3_VEND
	zNomRtv  := Substr(RetField("SA3",1,xFilial("SA3")+SQL3->E3_VEND,"A3_NOME"),1,25)
	zCodCli  := SQL3->E3_CODCLI
	zNomCli  := Substr(SA1->A1_NOME,1,30)
	zVlBase  := SQL3->E3_COMIS
	zPercen  := zPorcDM
	zVlPrem  := (zVlBase * (zPorcDM/100))

	If zVlPrem <> 0

		lAddDet := .F.
		If Len(aVenDet) == 0
			lAddDet := .T.
		Else
			nPos := aScan(aVenDet, {|x| x[1] == zCodRtv .And. x[3] == zCodCli})
			If nPos == 0
				lAddDet := .T.
			Else
				aVenDet[nPos][5] += zVlBase
				aVenDet[nPos][7] += zVlPrem
			Endif
		Endif	
		If lAddDet
			AAdd(aVenDet,{zCodRtv, zNomRtv, zCodCli, zNomCli, zVlBase, zPercen, zVlPrem, "", "" })
		Endif	

		lAddRank := .F.
		If Len(aRanking) == 0
			lAddRank := .T.
		Else
			nPos := aScan(aRanking, {|x| x[1] == zCodRtv})
			If nPos == 0
				lAddRank := .T.
			Else
				aRanking[nPos][3] += zVlPrem
			Endif
		Endif
		If lAddRank
			AAdd(aRanking,{zCodRtv, zNomRtv, zVlPrem, ""})
		Endif

	Endif

	DbSelectArea("SQL3")
	SQL3->(DbSkip())
	If Eof()
		u_ExtrDms(zVenAnt,aVenDet,aRanking,zPerDms,@aLista,zPer,lGrvLog)
	Endif

	DbSelectArea("SQL3")
Enddo
SQL3->(DbCloseArea())

If mv_par08 == 1 // Envio dos E-mails
	aEnvMail := aClone(aLista)
	For _env := 1 to Len(aEnvMail)
		zCod   := aEnvMail[_env][1]
		zNome  := aEnvMail[_env][2]
		zEmail := aEnvMail[_env][3]
		zPdf   := aEnvMail[_env][4]
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + zCod )
		zOri := Lower(PadR(SA3->A3_EMAIL,80))
		u_MMextrat(zCod,zNome,zEmail,zPdf,zOri,"DM",zPer,lGrvLog)
	Next _env
	// Apaga os arquivos do servidor
	For _del := 1 to Len(aLista)
		zPdf := "\premiacao\"+aLista[_del][4]
		fErase(zPdf)
	Next _del
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QDMSSCH ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/02/2022      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QDMSSCH()

PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"

zzData  := Date()
zzPar03 := Space(6)
zzPar04 := "ZZZZZZ"
U_QDMSENV(zzData,zzPar03,zzPar04)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QDMSMAN ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/02/2022      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via menu.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QDMSMAN()

If !MsgYesNo("Confirma envio do extrato modelo 'Projeção' para o código '"+SA3->A3_COD+"' ?","Aviso")
	Return
Endif

zzData  := dDatabase
zzPar03 := SA3->A3_COD
zzPar04 := SA3->A3_COD

MsgRun("Aguarde, enviando extrato...","Processando",{|| U_QDMSENV(zzData,zzPar03,zzPar04) })

MsgInfo("Envio concluído.")

Return
