#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "xmlxfun.ch"
#include "apwebsrv.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UPDDMS1 ¦ Autor ¦ Fábrica ERP.BR  ¦   Data  ¦ 10/02/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização da entidade DM para cálculo do PLR.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UPDDMS1()

Local cPerg	:= Padr("UPDDMS1",10)
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, cArqCtb

If __cUserId != "000163"
	MsgAlert("Usuário não autorizado.")
	Return
Endif

If !Pergunte(cPerg,.T.)
	Return
Endif

If MsgYesNo("Confirma o processamento - ATUALIZAÇÃO DA ENTIDADE DM ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Processando atualização", "Aguarde, processando ...", .F. )
	oProcess:Activate()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ 10/02/2022  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento principal.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nForFilial
Local zFiliais := ""

aFilsCalc := MatFilCalc( mv_par04 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

If MsgYesNo("Processa Manut.Comissões ?")

	cQuery := " UPDATE "+RetSqlName("SE3")
	cQuery += " SET E3_ZZDM = ' ' "
	cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
	cQuery += " AND E3_ZZRTV = ' ' "
	cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
	cQuery += RetSqlName("SA3")+" SA3 "
	cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
	cQuery += " AND E3_VEND = A3_COD "
	cQuery += " AND E3_ZZRTV = ' ' "
	cQuery += " AND A3_ZZDM <> ' ' "
	cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
	cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
	cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	nTotSql := SQL5->SOMA
	SQL5->(DbCloseArea())

	cQuery := " SELECT SE3.R_E_C_N_O_ RECSE3, E3_FILIAL, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ, E3_ZZACORD, A3_COD VEND, A3_ZZDM ZZDM "
	cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
	cQuery += RetSqlName("SA3")+" SA3 "
	cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
	cQuery += " AND E3_VEND = A3_COD "
	cQuery += " AND E3_ZZRTV = ' ' "
	cQuery += " AND A3_ZZDM <> ' ' "
	cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
	cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
	cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY E3_FILIAL, E3_VEND, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ, E3_ZZACORD "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

	oProcess:SetRegua2(nTotSql)

	DbSelectArea("SQL5")
	SQL5->(DbGotop())
	While !Eof()
			
		oProcess:IncRegua2("Atualizando DM")

		DbSelectArea("SE3")
		SE3->(DbGoto(SQL5->RECSE3))

		RecLock("SE3",.F.)
		SE3->E3_ZZDM := SQL5->ZZDM
		MsUnLock()

		DbSelectArea("SQL5")
		SQL5->(DbSkip())
	Enddo
	SQL5->(DbCloseArea())

Endif

If MsgYesNo("Processa movimentos a partir do SE3 ?")

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
	cQuery += RetSqlName("SA3")+" SA3 "
	cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
	cQuery += " AND E3_VEND = A3_COD "
	cQuery += " AND A3_ZZDM <> ' ' "
	cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
	cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
	cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
	cQuery += " AND E3_NUM = '000032007' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	nTotSql := SQL5->SOMA
	SQL5->(DbCloseArea())

	cQuery := " SELECT SE3.R_E_C_N_O_ RECSE3, E3_FILIAL, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ, E3_ZZACORD, E3_VEND VEND, E3_ZZDM ZZDM "
	cQuery += " FROM "+RetSqlName("SE3")+" SE3, "
	cQuery += RetSqlName("SA3")+" SA3 "
	cQuery += " WHERE E3_FILIAL IN ("+zFiliais+") "
	cQuery += " AND E3_VEND = A3_COD "
	cQuery += " AND A3_ZZDM <> ' ' "
	cQuery += " AND E3_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
	cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
	cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
	cQuery += " AND E3_NUM = '000032007' "
	cQuery += " ORDER BY E3_FILIAL, E3_VEND, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_SEQ, E3_ZZACORD "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

	oProcess:SetRegua1(nTotSql)

	DbSelectArea("SQL5")
	SQL5->(DbGotop())
	While !Eof()
			
		oProcess:IncRegua1("Atualizando DM")

		DbSelectArea("SE3")
		SE3->(DbGoto(SQL5->RECSE3))

		DbSelectArea("SE1")
		DbSetOrder(1)
		If DbSeek( SE3->(E3_FILIAL + E3_PREFIXO + E3_NUM) )
			While !Eof() .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM) == SE3->(E3_FILIAL + E3_PREFIXO + E3_NUM)
				
				If Substr(SE3->E3_VEND,1,1) <> "R"
					RecLock("SE1",.F.)
					SE1->E1_ZZDM := SE3->E3_ZZDM
					MsUnLock()
				Endif	

				DbSelectArea("SE1")
				SE1->(DbSkip())
			Enddo

			DbSelectArea("SF2")
			DbSetOrder(1)
			If DbSeek( SE3->(E3_FILIAL + E3_NUM + E3_PREFIXO) )

				RecLock("SF2",.F.)
				SF2->F2_ZZDM := SE3->E3_ZZDM
				MsUnLock()

				If Empty(SE3->E3_ZFILINC)

					DbSelectArea("SD2")
					DbSetOrder(3)
					If DbSeek( SF2->(F2_FILIAL + F2_DOC + F2_SERIE) )

						DbSelectArea("SC5")
						DbSetOrder(1)
						If DbSeek( SD2->(D2_FILIAL + D2_PEDIDO) )

							RecLock("SC5",.F.)
							SC5->C5_ZZDM := SE3->E3_ZZDM
							MsUnLock()

						Endif

					Endif	

				Endif

			Endif	
		Endif

		If !Empty(SE3->E3_ZFILINC)

			DbSelectArea("SE1")
			DbSetOrder(1)
			If DbSeek( SE3->(E3_ZFILINC + E3_PREFIXO + E3_NUM) )
				While !Eof() .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM) == SE3->(E3_ZFILINC + E3_PREFIXO + E3_NUM)
					
					If Substr(SE3->E3_VEND,1,1) <> "R"
						RecLock("SE1",.F.)
						SE1->E1_ZZDM := SE3->E3_ZZDM
						MsUnLock()
					Endif	

					DbSelectArea("SE1")
					SE1->(DbSkip())
				Enddo

				DbSelectArea("SF2")
				DbSetOrder(1)
				If DbSeek( SE3->(E3_ZFILINC + E3_NUM + E3_PREFIXO) )

					RecLock("SF2",.F.)
					SF2->F2_ZZDM := SE3->E3_ZZDM
					MsUnLock()

				Endif	
			Endif

		Endif

		DbSelectArea("SQL5")
		SQL5->(DbSkip())
	Enddo
	SQL5->(DbCloseArea())

Endif

Return

/*
If MsgYesNo("Processa movimentos a partir do SC5 ?")

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "
	cQuery += RetSqlName("SA3")+" SA3 "
	cQuery += " WHERE C5_FILIAL IN ("+zFiliais+") "
	cQuery += " AND C5_VEND1 = A3_COD "
	cQuery += " AND C5_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
	cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
	cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	nTotSql := SQL5->SOMA
	SQL5->(DbCloseArea())

	cQuery := " SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO "
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "
	cQuery += RetSqlName("SA3")+" SA3 "
	cQuery += " WHERE C5_FILIAL IN ("+zFiliais+") "
	cQuery += " AND C5_VEND1 = A3_COD "
	cQuery += " AND C5_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+ "' "
	cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
	cQuery += " AND SA3.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY C5_FILIAL, C5_NUM "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

	oProcess:SetRegua1(nTotSql)

	DbSelectArea("SQL5")
	SQL5->(DbGotop())
	While !Eof()
			
		oProcess:IncRegua1("Atualizando DM")

		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek( SQL5->(FILIAL + PEDIDO) )
		
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek( xFilial("SA3") + SC5->C5_VEND1 )
			If !Empty(SA3->A3_ZZDM)

				If !Empty(mv_par03)
					If mv_par03 <> SA3->A3_ZZDM
						DbSelectArea("SQL5")
						SQL5->(DbSkip())
						Loop
					Endif
				Endif
				
				RecLock("SC5",.F.)
				SC5->C5_ZZDM := SA3->A3_ZZDM
				MsUnLock()

				DbSelectArea("SD2")
				DbSetOrder(8)
				If DbSeek( SC5->(C5_FILIAL + C5_NUM) )
					While !Eof() .And. SD2->(D2_FILIAL + D2_PEDIDO) == SC5->(C5_FILIAL + C5_NUM)

						DbSelectArea("SF2")
						DbSetOrder(1)
						DbSeek( SD2->(D2_FILIAL + D2_DOC + D2_SERIE) )
						If Empty(SF2->F2_ZZDM)

							RecLock("SF2",.F.)
							SF2->F2_ZZDM := SA3->A3_ZZDM
							MsUnLock()

							DbSelectArea("SE1")
							DbSetOrder(1)
							If DbSeek( SF2->(F2_FILIAL + F2_SERIE + F2_DOC) )
								While !Eof() .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM) == SF2->(F2_FILIAL + F2_SERIE + F2_DOC)
									
									RecLock("SE1",.F.)
									SE1->E1_ZZDM := SA3->A3_ZZDM
									MsUnLock()

									DbSelectArea("SE3")
									DbSetOrder(1)
									If DbSeek( SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA) )
										While !Eof() .And. SE3->(E3_FILIAL + E3_PREFIXO + E3_NUM + E3_PARCELA) == SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA)
										
											If Substr(SE3->E3_VEND,1,1) <> "R"
												RecLock("SE3",.F.)
												SE3->E3_ZZDM := SA3->A3_ZZDM
												MsUnLock()
											Endif	

											DbSelectArea("SE3")
											SE3->(DbSkip())
										Enddo
									Endif	

									DbSelectArea("SE1")
									SE1->(DbSkip())
								Enddo
							Endif

						Endif

						DbSelectArea("SD2")
						SD2->(DbSkip())
					Enddo
				Endif

			Endif
		Endif

		DbSelectArea("SQL5")
		SQL5->(DbSkip())
	Enddo
	SQL5->(DbCloseArea())

Endif
*/
