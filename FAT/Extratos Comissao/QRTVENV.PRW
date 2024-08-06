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
¦¦¦Programa  ¦ QRTVENV   ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 02/02/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio do extrato via schedule - Modelo RTV.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QRTVENV(zzData,zzPar03,zzPar04)

Local zVenAnt  := ""
Local lKeyOk3  := .F.
Local aVenDet  := {}
Local aRanking := {}
Local aLista   := {}
Local lGrvLog  := .F.
Local aNccImp  := {}
Local lNccImp  := GetMv("MV_ZNCCDET")
Local dDatExt  := zzData
Local _env, _del, _ncc

Private zModAtra := AllTrim(GetMv("MV_ZMODATR")) // 1=Calcula pelo Vencto.Real | 2=Calcula pelo Vencto.Original
Private mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08, mv_par09, mv_par10, mv_par11, mv_par12, mv_par13, mv_par14, mv_par15, mv_par16, mv_par17

If Month(dDatExt) == 1 .Or. Month(dDatExt) == 7
	Return
ElseIf Month(dDatExt) < 7
	mv_par01 := StoD( Substr(DtoS(dDatExt),1,4) + "0101" )
Else
	mv_par01 := StoD( Substr(DtoS(dDatExt),1,4) + "0701" )
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
mv_par14 := 1  // Considera desc.atraso ? Sim
mv_par15 := 1  // Considera desc.meta ? Sim
mv_par16 := 1  // Considera quais ? A Pagar
mv_par17 := 3  // Status ? Todos

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

cQuery := " SELECT SE3.* "
cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
cQuery += RetSqlName("SA3")+" SA3 "
cQuery += " WHERE E3_FILIAL <> ' ' "
cQuery += " AND E3_VEND = A3_COD "
cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
cQuery += " AND E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+ "' "
cQuery += " AND SUBSTR(E3_VEND,1,1) IN('V','G','D') " // Somente Rtv | Ger e Dir (como Rtv)
cQuery += " AND E3_ZZRTV = ' ' " // Não considera apuração GER e DIR
If mv_par15 == 1 // A Pagar
	cQuery += " AND E3_DATA = ' ' "
ElseIf mv_par15 == 2 // Pagas
	cQuery += " AND E3_DATA <> ' ' "
Endif
If mv_par16 == 1 // Ativos
	cQuery += " AND A3_MSBLQL = '2' "
ElseIf mv_par16 == 2 // Inativos
	cQuery += " AND A3_MSBLQL = '1' "
Endif
cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E3_VEND, E3_CODCLI, E3_LOJA, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)

DbSelectArea("SQL3")
SQL3->(DbGotop())
While !Eof()

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek( xFilial("SA3") + SQL3->E3_VEND )
	
	If SQL3->E3_VEND != zVenAnt
		If lKeyOk3
			u_ExtrRtv(zVenAnt,aVenDet,aRanking,@aLista,zPer,aNccImp,lGrvLog,mv_par16)
			aVenDet  := {}
			aRanking := {}
			aNccImp  := {}
		Else
			lKeyOk3 := .T.
		Endif
		zVenAnt := SQL3->E3_VEND
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SQL3->E3_CODCLI + SQL3->E3_LOJA )

	DbSelectArea("SE1")
	DbSetOrder(2)
	DbSeek( SQL3->(E3_FILIAL+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO) )

	zCodCli  := SQL3->E3_CODCLI
	zNomCli  := AllTrim(SA1->A1_NOME)
	zNFiscal := SQL3->E3_NUM
	zParcela := IIf(!Empty(SQL3->E3_PARCELA),AllTrim(SQL3->E3_PARCELA),"U")
	zVencto  := IIf(SQL3->E3_TIPO == "NCC", StoD(SQL3->E3_EMISSAO), IIf(zModAtra == "2",DataValida(SE1->E1_VENCORI,.T.),SE1->E1_VENCREA))
	zPagto   := StoD(SQL3->E3_EMISSAO)
	zPedido  := IIf(SQL3->E3_TIPO == "NCC", u_PedNcc(), SQL3->E3_PEDIDO)
	zVlrTit  := IIf(SQL3->E3_TIPO == "NCC", SQL3->E3_BASE, SE1->E1_VALOR)
	zVlBase  := SQL3->E3_BASE
	zPercen  := SQL3->E3_PORC
	zVlPrem  := SQL3->E3_COMIS
	zVlOrig  := SQL3->E3_ZZCOMIS
	zAtraso  := SQL3->E3_ZZATRAS
	zPerDesc := SQL3->E3_ZZPDESC
	zVlrDesc := SQL3->E3_ZZVDESC
	zNrAcord := SQL3->E3_ZZACORD
	zSeqBaix := SQL3->E3_SEQ
	zVlPago  := SQL3->E3_ZVLPAGO
	zEmiTit  := IIf(SQL3->E3_TIPO == "NCC",StoD(SQL3->E3_EMISSAO),SE1->E1_EMISSAO)
	zDesMet  := IIf(SQL3->E3_MTCOMIS > 0, SQL3->(E3_MTCOMIS - E3_COMIS), 0)

	If mv_par14 == 1 // Modelo com atraso
		AAdd(aVenDet,{zCodCli, zNomCli, zNFiscal, zParcela, zVencto, zPagto, zPedido, zVlrTit, zVlBase, zPercen, zVlPrem, zVlOrig, zAtraso, zPerDesc, zVlrDesc, "", "", zNrAcord, zSeqBaix, zVlPago, zEmiTit, zDesMet })
	Else // Modelo padrão
		AAdd(aVenDet,{zCodCli, zNomCli, zNFiscal, zParcela, zVencto, zPagto, zPedido, zVlrTit, zVlBase, zPercen, zVlOrig, "", "", zNrAcord, zSeqBaix, zVlPago })
	Endif

	lAddRank := .F.
	If Len(aRanking) == 0
		lAddRank := .T.
	Else
		nPos := aScan(aRanking, {|x| x[1] == zCodCli})
		If nPos == 0
			lAddRank := .T.
		Else
			aRanking[nPos][3] += IIf(mv_par14 == 1,zVlPrem,zVlOrig)
		Endif
	Endif
	If lAddRank
		AAdd(aRanking,{zCodCli, zNomCli, IIf(mv_par14 == 1,zVlPrem,zVlOrig), ""})
	Endif

	If lNccImp
		If SQL3->E3_TIPO == "NCC" .And. SQL3->E3_EMISSAO >= "20210101"
			aNccNFis := u_NccNFis(SQL3->E3_FILIAL, SQL3->E3_NUM, SQL3->E3_SERIE, SQL3->E3_CODCLI, SQL3->E3_VEND, SQL3->R_E_C_N_O_)
			For _ncc := 1 to Len(aNccNFis)
				yVended := aNccNFis[_ncc][1]
				yClient := aNccNFis[_ncc][2]
				yNomCli := aNccNFis[_ncc][3]
				yFilial := aNccNFis[_ncc][4]
				yNumNcc := aNccNFis[_ncc][5]
				ySerNcc := aNccNFis[_ncc][6]
				yNccRec := aNccNFis[_ncc][7]
				yNfOrig := aNccNFis[_ncc][8]
				ySerOri := aNccNFis[_ncc][9]
				AAdd(aNccImp,{yVended, yClient, yNomCli, yFilial, yNumNcc, ySerNcc, yNccRec, yNfOrig, ySerOri})	
			Next _ncc
		Endif	
	Endif

	DbSelectArea("SQL3")
	SQL3->(DbSkip())
	If Eof()
		u_ExtrRtv(zVenAnt,aVenDet,aRanking,@aLista,zPer,aNccImp,lGrvLog,mv_par16)
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
		u_MMextrat(zCod,zNome,zEmail,zPdf,zOri,"RTV",zPer,lGrvLog)
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
¦¦¦Programa  ¦ QRTVSCH ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/02/2022      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QRTVSCH()

PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"

zzData  := Date()
zzPar03 := Space(6)
zzPar04 := "ZZZZZZ"
U_QRTVENV(zzData,zzPar03,zzPar04)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ QRTVMAN ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 14/02/2022      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via menu.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QRTVMAN()

If !MsgYesNo("Confirma envio do extrato modelo 'Projeção' para o código '"+SA3->A3_COD+"' ?","Aviso")
	Return
Endif

zzData  := dDatabase
zzPar03 := SA3->A3_COD
zzPar04 := SA3->A3_COD

MsgRun("Aguarde, enviando extrato...","Processando",{|| U_QRTVENV(zzData,zzPar03,zzPar04) })

MsgInfo("Envio concluído.")

Return
