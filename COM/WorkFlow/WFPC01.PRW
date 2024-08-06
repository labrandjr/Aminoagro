#include "rwmake.ch"
#include "protheus.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ WFPC01    ¦ Autor ¦ ERPBR            ¦   Data  ¦ Fev/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ WorkFlow para aprovacao de Pedido de Compras.         	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Pacotes   ¦ 28/09/2021 - Projeto Workflow versão 2.0 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function WFPC01(lJob,cNumPed,lShow,lAsk,cRotina,cModo)

Local aArea      := GetArea()
Local aAprovador := {}
Local lExecuta   := .T.
Local _cEnvMail	 := ""
Local nX

If lJob // Acionado via schedule ===============================================================================

	// ... Não desenvolvido em lote.

Else // Acionado manualmente ===================================================================================

	lEnvWf := (SC7->C7_ZZENVWF == "S")	
	If !lEnvWf	
		If lAsk
			MsgInfo("Envio do workflow desligado para o Pedido "+SC7->C7_NUM+".")
		Else
			ConOut("Envio do workflow desligado para o Pedido "+SC7->C7_NUM+".")
		Endif	
		lExecuta := .F.
	Endif	

	If lAsk .And. lExecuta
		cMsgSc7 := "Pedido de Compra "+SC7->C7_NUM+": confirma processamento do workflow ?"
		If !MsgYesNo(cMsgSc7,"Atencao","INFO")
			lExecuta := .F.
		Endif
	Endif	

	If lExecuta

		cPedido	:= Alltrim(SC7->C7_NUM)

		If SC7->C7_CONAPRO == "L"
			If lAsk
				MsgBox("Pedido "+cPedido+" já aprovado e liberado! Não será enviado e-mail para aprovação.", "Atenção", "ALERT")
			Else
				ConOut("Pedido "+cPedido+" já aprovado e liberado! Não será enviado e-mail para aprovação.")
			Endif	
			Return
		ElseIf SC7->C7_CONAPRO == "R"
			If lAsk
				MsgBox("Pedido "+cPedido+" rejeitado! Não será enviado e-mail para aprovação.", "Atenção", "ALERT")
			Else
				ConOut("Pedido "+cPedido+" rejeitado! Não será enviado e-mail para aprovação.")
			Endif	
			Return
		Endif

		// Checagem de aprovador substituto
		cQuery := " SELECT CR_APROV APROV, R_E_C_N_O_ RECSCR "
		cQuery += " FROM "+RetSqlName("SCR")
		cQuery += " WHERE CR_FILIAL = '"+xFilial("SCR")+"' "
		cQuery += " AND CR_TIPO = 'PC' "
		cQuery += " AND CR_NUM = '"+AllTrim(SC7->C7_NUM)+"' "
		cQuery += " AND CR_STATUS = '02' "
		cQuery += " AND CR_DATALIB = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLR", .F., .T.)
		SQLR->(DbGotop())
		If !Eof()
			If !Empty(SQLR->APROV)
				cQuery := " SELECT ZR_APRSUB APRSUB, ZR_USRSUB USRSUB, R_E_C_N_O_ RECSZR "
				cQuery += " FROM "+RetSqlName("SZR")
				cQuery += " WHERE ZR_FILIAL = '"+xFilial("SZR")+"' "
				cQuery += " AND ZR_APROV = '"+SQLR->APROV+"' "
				cQuery += " AND ZR_DATINI <= '"+DtoS(Date())+"' "
				cQuery += " AND ZR_DATFIM >= '"+DtoS(Date())+"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQSU", .F., .T.)
				SQSU->(DbGotop())
				If !Eof()
					If !Empty(SQSU->APRSUB)
						DbSelectArea("SAK")
						DbSetOrder(1)
						If DbSeek( xFilial("SAK") + SQLR->APROV )
							// Registra aprovador superior
							RecLock("SAK",.F.)
							SAK->AK_APROSUP := SQSU->APRSUB
							MsUnLock()
							// Transfere aprovação
							DbSelectArea("SCR")
							DbGoto(SQLR->RECSCR)
							RecLock("SCR",.F.)
							SCR->CR_USERORI := SCR->CR_USER
							SCR->CR_APRORI  := SCR->CR_APROV
							SCR->CR_USER    := SQSU->USRSUB 
							SCR->CR_APROV   := SQSU->APRSUB
							SCR->CR_OBS     := "Transferido por Ausencia de "+AllTrim(SAK->AK_NOME)
							MsUnLock()
							// Marca aprovador substituto = usado
							DbSelectArea("SZR")
							DbGoto(SQSU->RECSZR)
							RecLock("SZR",.F.)
							SZR->ZR_USADO := "S"
							MsUnLock()
							//
						Endif
					Endif
				Endif
				SQSU->(DbCloseArea())
			Endif
		Endif
		SQLR->(DbCloseArea())

		DbSelectArea("SCR")
		DbSetOrder(1)
		If DbSeek( xFilial("SCR") + "PC" + PadR(SC7->C7_NUM,50) )
			While !Eof() .And. SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == xFilial("SCR") + "PC" + PadR(SC7->C7_NUM,50)
				If SCR->CR_STATUS == "02" .And. Empty(SCR->CR_DATALIB)
					If Empty(SCR->CR_ENVMAIL) .Or. Upper(AllTrim(cRotina)) == "MANUAL"
						AAdd(aAprovador,{ SCR->CR_USER,;        	     // 1 Codigo do usuario
										  SCR->CR_APROV,;                // 2 Codigo do aprovador
										  UsrFullName(SCR->CR_USER),;    // 3 Nome do usuario
										  UsrRetMail(SCR->CR_USER),;     // 4 Email do usuario
										  UsrFullName(SCR->CR_USERORI)}) // 5 Nome do usuario substituído
					Endif						
				Endif
				SCR->(DbSkip())
			Enddo
		Endif
	
		If Len(aAprovador) > 0
		    cModo := CapitalAce(cModo)
			If lShow
				MsgRun("Processo Workflow do Pedido de Compra "+AllTrim(SC7->C7_FILIAL)+"-"+AllTrim(SC7->C7_NUM),"Processando",{|| WFAbertura(SC7->C7_NUM, aAprovador, lJob, lShow, cModo) })
				MsgBox("Processo de aprovacao do Pedido "+cPedido+" aberto com sucesso!", "Informação", "INFO")
			Else
				WFAbertura(SC7->C7_NUM, aAprovador, lJob, lShow, cModo)
				ConOut("Processo de aprovacao do Pedido "+cPedido+" aberto com sucesso!")
			Endif	
		Else
			If lShow
				MsgBox("Processo de aprovacao do Pedido "+cPedido+" não aberto. Verifique status de aprovações.", "Informação", "STOP")
			Else
				ConOut("Processo de aprovacao do Pedido "+cPedido+" não aberto. Verifique status de aprovações.")
			Endif	
		Endif

		DbSelectArea("SCR")
		DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
		For nX := 1 to Len(aAprovador)
			If DbSeek( xFilial("SCR") + "PC" + PadR(cPedido,50) + aAprovador[nX,1] + "02" )
				_cEnvMail := "2"
				If SCR->CR_ENVMAIL == "2"
					_cEnvMail := "3"
				Endif
				Reclock("SCR",.F.)
				SCR->CR_ENVMAIL := _cEnvMail
				MsUnLock()
			Endif
		Next nX

	Endif

Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ WFAbertura  ¦ Autor ¦ ERPBR          ¦   Data  ¦ Fev/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio do workflow para aprovacao.			         	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function WFAbertura(cPedido, aAprovador, lJob, lShow, cModo)

Local cNumero   := "" // Numero do Processo
Local cProcesso := ""
Local cTarefa   := ""
Local oProcesso := Nil
Local cHTML     := ""
Local cAssunto  := ""
Local lWfV2     := GetMv("MV_ZWFVER2")
Local nI

Private _cUrl := Alltrim(GetMv("MV_WFURL"))

If lShow
	ProcRegua(Len(aAprovador))
Endif

For nI := 1 to Len(aAprovador)

	ConOut("Fase 6 processo Aprovacao Pedido de Compra")

	If lShow
		IncProc("Processando WorkFlow...")
	Endif
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	If DbSeek( xFilial("SC7") + cPedido )
		
		cNumero   := "000001"
		cHTML     := "\workflow\HTML\pc_fertilaqua.html"
		cProcesso := OemToAnsi("Aprovacao de Pedido de Compra")
		cTarefa   := OemToAnsi("Aprovacao de Pedido de Compra")
		cAssunto  := "Aprovacao de Pedido de Compra "+cPedido+IIf(lWfV2," | "+cModo,"")
		
		// Dados do usuario
		oProcesso := TWFProcess():New(cNumero,cProcesso)
		oProcesso:NewTask(cTarefa,cHTML)
		oProcesso:cSubject := cAssunto
		oProcesso:bReturn := "U_WFReturn()"
		oProcesso:NewVersion(.T.)
		
		oHTML := oProcesso:oHTML
		
		ConOut("Fase 7 processo Aprovacao Pedido de Compra")

		// Preenche os dados
		zFilPed     := SC7->C7_FILIAL
		cPedido     := SC7->C7_NUM
		cIt         := SC7->C7_ITEM
		dEmissao    := SC7->C7_EMISSAO
		cFornecedor := SC7->C7_FORNECE
		cLoja       := SC7->C7_LOJA
		cNome       := ""
		cEndereco   := ""
		cEstado     := ""
		cCEP        := ""
		cCNPJ       := ""
		cIE         := ""
		cTelefone   := ""
		cFax        := ""
		cContato    := ""
		cEmail      := ""
		
		DbSelectArea("SA2")
		DbSetOrder(1)
		If DbSeek( xFilial("SA2") + cFornecedor + cLoja )
			cNome     := AllTrim(SA2->A2_NOME)
			cEndereco := AllTrim(SA2->A2_END) + ", " + " - " + Alltrim(SA2->A2_BAIRRO) + " - " + Alltrim(SA2->A2_MUN)
			cEstado   := SA2->A2_EST
			cCEP      := Transform(SA2->A2_CEP, "99999-999")
			cCNPJ     := AllTrim(SA2->A2_CGC)
			cIE       := AllTrim(SA2->A2_INSCR)
			cTelefone := IIf(!Empty(SA2->A2_DDD),"("+Alltrim(SA2->A2_DDD)+") ","") + Alltrim(SA2->A2_TEL)
			cFax      := IIf(!Empty(SA2->A2_DDD),"("+Alltrim(SA2->A2_DDD)+") ","") + Alltrim(SA2->A2_FAX)
			cContato  := AllTrim(SA2->A2_CONTATO)
			cEmail    := SA2->A2_EMAIL
			If Empty(cContato)
				cContato := AllTrim(SC7->C7_CONTATO)
			Endif
		Endif
		
		nRecnoSM0 := SM0->(Recno())

		DbSelectArea("SM0")
		DbSetOrder(1)
		SM0->( DbSeek( Substr(cNumEmp,1,2) + SC7->C7_FILENT) )
		cEntrega  := Alltrim(SM0->M0_ENDENT) + "  " + Alltrim(SM0->M0_CIDENT) + "  - " + SM0->M0_ESTENT + " - " + Transform(SM0->M0_CEPENT, "99999-999")
		cCobranca := Alltrim(SM0->M0_ENDCOB) + "  " + Alltrim(SM0->M0_CIDCOB) + "  - " + SM0->M0_ESTCOB + " - " + Transform(SM0->M0_CEPCOB, "99999-999")
		SM0->(DbGoto(nRecnoSM0))
		
		DbSelectArea("SC7")
		
		cObs         := ""
		nMercadorias := 0
		nFrete       := 0
		nDespesas    := 0
		nSeguro      := 0
		nICMS        := 0
		nIPI         := 0
		nTotal       := 0
		nDesconto    := 0
		cComprador   := IIf(!Empty(SC7->C7_APROV), UsrFullName(SC7->C7_USER), "Nenhum")
		nMoeda       := IIf(SC7->C7_MOEDA > 1, SC7->C7_MOEDA, 1)
		cMoeda       := AllTrim(GetMv("MV_SIMB"+AllTrim(STR(nMoeda))))
		nTxMoeda     := IIf(SC7->C7_MOEDA > 1, SC7->C7_TXMOEDA, 1)
		cPagamento   := AllTrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))+" - "+AllTrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_COND"))
		
		cAprovador := aAprovador[nI,2] + "-" + aAprovador[nI,3]
		
		oHTML:ValByName("PEDIDO", cPedido )
		oHTML:ValByName("EMISSAO", DtoC(dEmissao) )
		oHTML:ValByName("FORNECEDOR", cFornecedor + "/" + cLoja + " - " + cNome )
		oHTML:ValByName("CONTATO", cContato )
		oHTML:ValByName("ENDERECO", cEndereco )
		oHTML:ValByName("ESTADO", cEstado )
		oHTML:ValByName("CEP", cCEP )
		oHTML:ValByName("CNPJ", cCNPJ )
		oHTML:ValByName("IE", cIE )
		oHTML:ValByName("TELEFONE", cTelefone )
		oHTML:ValByName("LOCAL_ENTREGA", cEntrega )
		oHTML:ValByName("LOCAL_COBRANCA", cCobranca )
		oHTML:ValByName("MOEDA", cMoeda )
		oHTML:ValByName("TAXA_MOEDA", Transform(nTxMoeda, "@E 99,999.9999" ) )
		oHTML:ValByName("CONDICAO", cPagamento )
		
		DbSelectArea("SC7")		
		While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == xFilial("SC7") + cPedido
			
			cItem       := SC7->C7_ITEM
			cProduto    := Alltrim(SC7->C7_PRODUTO)
			cDescricao  := Alltrim(SC7->C7_DESCRI)
			cUM         := SC7->C7_UM
			nQuantidade := SC7->C7_QUANT
			nUnitario   := SC7->C7_PRECO
			dEntrega    := SC7->C7_DATPRF
			cCC         := AllTrim(SC7->C7_CC)
			cObs        += IIf( !Empty(SC7->C7_OBS), IIf(!Empty(cObs)," | ","") + Alltrim(SC7->C7_OBS), "")
			
			AAdd( oHTML:ValByName("itens.ITEM"), cItem )
			AAdd( oHTML:ValByName("itens.CODIGO"), cProduto )
			AAdd( oHTML:ValByName("itens.DESCRICAO"), cDescricao )
			AAdd( oHTML:ValByName("itens.UM"), cUM )
			AAdd( oHTML:ValByName("itens.QUANT"), Transform(nQuantidade, "@E 999,999,999.99") )
			AAdd( oHTML:ValByName("itens.UNIT"), Transform(nUnitario, "@E 999,999,999.999" ) )
			AAdd( oHTML:ValByName("itens.IPI"), Transform(SC7->C7_IPI, "@E 99,99") )
			AAdd( oHTML:ValByName("itens.TOTAL"), Transform(SC7->C7_TOTAL, "@E 999,999,999.99" ) )
			AAdd( oHTML:ValByName("itens.ENTREGA"), dEntrega  )
			AAdd( oHTML:ValByName("itens.CC"), cCC )
			
			nMercadorias += SC7->C7_TOTAL
			nFrete       += SC7->C7_VALFRE
			nDespesas    += SC7->C7_DESPESA
			nSeguro      += SC7->C7_SEGURO
			nICMS        += SC7->C7_VALICM
			nIPI         += SC7->C7_VALIPI
			nDesconto    += SC7->C7_VLDESC
			nTotal       += (SC7->(C7_TOTAL + C7_VALFRE + C7_DESPESA + C7_SEGURO + C7_VALIPI) - SC7->C7_VLDESC)
			
			DbSelectArea("SC7")
			SC7->(DbSkip())
		Enddo

		// Andamento das Aprovações
		lUsrApr := .F.
		DbSelectArea("SCR")
		DbSetOrder(1)
		If DbSeek( zFilPed + "PC" + PadR(cPedido,50) )
			While !Eof() .And. zFilPed + "PC" + Alltrim(cPedido) == SCR->(CR_FILIAL + CR_TIPO + AllTrim(CR_NUM))
				If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS == "03"
					AAdd( oHTML:ValByName("aprov.USR"), AllTrim(UsrFullName(SCR->CR_USER)) )
					AAdd( oHTML:ValByName("aprov.DAT"), DtoC(SCR->CR_DATALIB) )
					AAdd( oHTML:ValByName("aprov.OBS"), AllTrim(SCR->CR_OBS) )
					lUsrApr := .T.
				Endif
				SCR->(DbSkip())
			Enddo
		Endif
		If !lUsrApr
			AAdd( oHTML:ValByName("aprov.USR"), "" )
			AAdd( oHTML:ValByName("aprov.DAT"), "  /  /  " )
			AAdd( oHTML:ValByName("aprov.OBS"), "" )
		Endif	
		
		// Histórico de Alterações
		If lWfV2
			lHistAlt := .F.
			DbSelectArea("ZZJ")
			DbSetOrder(1)
			If DbSeek( zFilPed + cPedido )
				While !Eof() .And. zFilPed + cPedido == ZZJ->(ZZJ_FILIAL + ZZJ_PEDIDO)
					// --------------------
					// cTipoAlt
					// --------------------
					// 1 - Novo Item
					// 2 - Exclusão de Item
					// 3 - Produto
					// 4 - Quantidade
					// 5 - Preço
					// 6 - Condição
					// 7 - Moeda
					// 8 - Taxa
					// --------------------
					zzjTipo := "Item incluído"
					If ZZJ->ZZJ_TIPO == "2"
						zzjTipo := "Item excluído"
					ElseIf ZZJ->ZZJ_TIPO == "3"
						zzjTipo := "Produto"
					ElseIf ZZJ->ZZJ_TIPO == "4"
						zzjTipo := "Quantidade"
					ElseIf ZZJ->ZZJ_TIPO == "5"
						zzjTipo := "Preço"
					ElseIf ZZJ->ZZJ_TIPO == "6"
						zzjTipo := "Condição"
					ElseIf ZZJ->ZZJ_TIPO == "7"
						zzjTipo := "Moeda"
					ElseIf ZZJ->ZZJ_TIPO == "8"
						zzjTipo := "Taxa"
					Endif
					zzjOld := AllTrim(ZZJ->ZZJ_OLD)+IIf(!Empty(ZZJ->ZZJ_DOLD)," - "+AllTrim(ZZJ->ZZJ_DOLD),"")
					zzjNew := AllTrim(ZZJ->ZZJ_NEW)+IIf(!Empty(ZZJ->ZZJ_DNEW)," - "+AllTrim(ZZJ->ZZJ_DNEW),"")
					// --------------------
					AAdd( oHTML:ValByName("hist.ITE"), ZZJ->ZZJ_ITEM )
					AAdd( oHTML:ValByName("hist.DAT"), DtoC(ZZJ->ZZJ_DATA) )
					AAdd( oHTML:ValByName("hist.HOR"), ZZJ->ZZJ_HORA )
					AAdd( oHTML:ValByName("hist.TIP"), zzjTipo )
					AAdd( oHTML:ValByName("hist.OLD"), zzjOld )
					AAdd( oHTML:ValByName("hist.NEW"), zzjNew )
					lHistAlt := .T.
					ZZJ->(DbSkip())
				Enddo
			Endif
			If !lHistAlt
				AAdd( oHTML:ValByName("hist.ITE"), "" )
				AAdd( oHTML:ValByName("hist.DAT"), "  /  /  " )
				AAdd( oHTML:ValByName("hist.HOR"), " : " )
				AAdd( oHTML:ValByName("hist.TIP"), "" )
				AAdd( oHTML:ValByName("hist.OLD"), "" )
				AAdd( oHTML:ValByName("hist.NEW"), "" )
			Endif	
		Endif

		oHTML:ValByName("OBSERVACAO", cObs )
		oHTML:ValByName("TTL_MERC"	, Transform(nMercadorias, "@E 999,999,999.99" ) )
		oHTML:ValByName("VLR_FRET"	, Transform(nFrete, "@E 999,999,999.99" ) )
		oHTML:ValByName("VLR_DESP"	, Transform(nDespesas, "@E 999,999,999.99" ) )
		oHTML:ValByName("VLR_SEGU"	, Transform(nSeguro, "@E 999,999,999.99" ) )
		oHTML:ValByName("VLR_ICMS"	, Transform(nICMS, "@E 999,999,999.99" ) )
		oHTML:ValByName("VLR_IPI"	, Transform(nIPI, "@E 999,999,999.99" ) )
		oHTML:ValByName("VLR_DESC"	, Transform(nDesconto, "@E 999,999,999.99" ) )
		oHTML:ValByName("VLR_TTL"	, Transform(nTotal, "@E 999,999,999.99" ) )
		oHTML:ValByName("COMPRAD"	, cComprador )
		
		// Parametros de retorno
		AAdd( oProcesso:aParams, zFilPed)
		AAdd( oProcesso:aParams, cPedido)
		AAdd( oProcesso:aParams, aAprovador[nI,2])
		AAdd( oProcesso:aParams, aAprovador[nI,1])
		oProcesso:nEncodeMime := 0
		
		// Inicio do trecho que grava o HTML
		oProcesso:ClientName( "EXPLORER" )
		oProcesso:cTo := "pc_fertilaqua" // manda a pasta do processo
		oProcesso:UserSiga := __cUserID
		// Fim do trecho que grava o HTML
		
		ConOut("Fase 8 processo Aprovacao Pedido de Compra")
		cMailId := oProcesso:Start()
		
		// Html: T:\totvs\teste\protheus12_data\workflow\HTTP\messenger\empg1\pc_fertilaqua
		// Processo: T:\totvs\teste\protheus12_data\workflow\empg1\process
		
		ConOut("Fase 9 processo Aprovacao Pedido de Compra")

		_aMsg := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		zTitulo := IIf(lWfV2,cModo+" do ","")+"Pedido de Compra: "+cPedido+" | Filial: "+cFilAnt+"-"+AllTrim(zNomFil)
		
		AAdd(_aMsg, "")
		AAdd(_aMsg, zTitulo) 
		AAdd(_aMsg, "Aprovador: " + aAprovador[nI,2] + "-" + aAprovador[nI,3] )
		AAdd(_aMsg, "Abaixo segue o link para acesso." )
		AAdd(_aMsg, '<A href="http://' + _cUrl + '/HTTP/messenger/emp'+cEmpAnt+'/pc_fertilaqua/'+AllTrim(cMailId)+'.htm">clique aqui</A>' )

		cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), aAprovador[nI,4] )
		cAssunto := IIf( !Empty(GetMv("MV_WFEMTST")), cAssunto+" - "+aAprovador[nI,4], cAssunto )
		If !Empty(aAprovador[nI,5])
			cAssunto += " - Transferido por ausência de "+AllTrim(aAprovador[nI,5])
		Endif

		U_MailNotify(cEmailWf, cAssunto, _aMsg, .F.)
						
	Endif

Next nI

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ WFReturn	  ¦ Autor ¦ ERPBR          ¦   Data  ¦ Fev/2017   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Retorno do workflow para aprovação.			         	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function WFReturn(oProcesso)

Local cPedido      := ""
Local cResposta    := ""
Local cMotivo      := ""
Local cAprovador   := ""
Local lAprovado    := .F.
Local lWfV2        := GetMv("MV_ZWFVER2")

ChkFile("SCR")
ChkFile("SC7")
ChkFile("SX2")
ChkFile("WFA")

If oProcesso <> Nil

    zFilial	   := oProcesso:aParams[1]
	cPedido	   := oProcesso:aParams[2]
	cAprovador := oProcesso:aParams[3]
	cUsuario   := oProcesso:aParams[4]
	cResposta  := oProcesso:oHtml:RetByName("APROVA")
	cMotivo	   := Alltrim(oProcesso:oHtml:RetByName("MOTIVO"))
	lAprovado  := (cResposta = "Sim")

	ConOut(zFilial)
	ConOut(cPedido)
	ConOut(cAprovador)
	ConOut(cUsuario)
	ConOut(cResposta)

	If lWfV2
		DbselectArea("ZZK")
		DbSetOrder(1)
		If !DbSeek( zFilial + PadR(cPedido,50) + cAprovador  )
			RecLock("ZZK",.T.)
			ZZK->ZZK_FILIAL := zFilial
			ZZK->ZZK_NUMDOC := cPedido
			ZZK->ZZK_APROV  := cAprovador
			ZZK->ZZK_USER   := cUsuario
		Else
			RecLock("ZZK",.F.)
		Endif
		ZZK->ZZK_DATALB := Date()
		ZZK->ZZK_HORALB := Substr(Time(),1,5)
		ZZK->ZZK_RESP   := IIf(lAprovado,"S","N")
		ZZK->ZZK_OK     := ""
		ZZK->ZZK_TIPO   := "PC"
		ZZK->ZZK_MOTIVO := cMotivo
		MsUnLock()
	Endif

	oProcesso:Finish() // Finaliza o Processo
	
	ConOut("Retorno do WF: aprovacao do pedido de compra: " + cPedido + " " + IIf(lAprovado, "Aprovado", "Reprovado"))

	u_WfAprovPc(zFilial, cPedido, cAprovador, cUsuario, cMotivo, lAprovado)

Endif

SCR->(DbCloseArea())
SC7->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ WfAprovPc  ¦ Autor ¦ ERPBR          ¦   Data  ¦ Ago/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Execução do workflow para aprovação.			         	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function WfAprovPc(zFilial, cPedido, cAprovador, cUsuario, cMotivo, lAprovado)

Local lWfV2 := GetMv("MV_ZWFVER2")
Local cObs  := ""
Local _x

cFilAnt := zFilial

If lAprovado // Pedido Aprovado ---------------------------------------------------------------------------------------
	
	cTipo := "PC"

	ConOut("Retorno WorkFlow: Pedido Aprovado")

	DbSelectArea("SC7")
	DbSetOrder(1)
	If DbSeek( zFilial + cPedido )
		ConOut("Pedido localizado.")
	Else
		ConOut("Pedido não localizado!")
	Endif	
	nRecSC7 := Recno()

	cUsrLib := AllTrim(UsrFullName(cUsuario))
	DbSelectArea("SCR")
	DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
	If DbSeek( zFilial + "PC" + PadR(cPedido,50) + cUsuario + "02" )
		cObs := "Aprovado por " + cUsrLib + " via WF em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5)
		ConOut("Baixando saldo de aprovacao para o PC: "+cPedido+" | Aprovador: "+AllTrim(SCR->CR_APROV))
		lLibOk := A097Lock(Substr(SCR->CR_NUM,1,6),SCR->CR_TIPO)
		If lLibOk
			ConOut("A097Lock "+cPedido+" .T.")
		Else
			ConOut("A097Lock "+cPedido+" .F.")
		Endif
		If lLibOk
			lLibOk := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SC7->C7_APROV,,,,,cObs}, dDataBase, 4)
			If lLibOk
				ConOut("MaAlcDoc "+cPedido+" .T.")
			Else
				ConOut("MaAlcDoc "+cPedido+" .F.")
			Endif
		Endif
	Endif

	// Reposiciona e verifica se ja está totalmente liberado
	lAprovOk := .T.	
	DbSelectArea("SCR")
	DbSetOrder(1)
	DbSeek( zFilial + "PC" + PadR(cPedido,50) )
	While !Eof() .And. zFilial + "PC" + Alltrim(cPedido) == SCR->(CR_FILIAL + CR_TIPO + AllTrim(CR_NUM))
		If SCR->CR_STATUS != "03" .And. SCR->CR_STATUS != "05"
			lAprovOk := .F.
			Exit
		Endif
		SCR->(DbSkip())
	Enddo

	If lAprovOk

		ConOut("Liberando PC: " + cPedido)
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek( zFilial + cPedido )
			zRecSC7 := SC7->(Recno())
			While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == zFilial + cPedido
				RecLock("SC7", .F.)
				SC7->C7_CONAPRO := "L"
				MsUnLock()
				SC7->(DbSkip())
			Enddo
			SC7->(DbGoto(zRecSC7))
		Endif

		// Notificação de Aprovação -------------------------------------------------
		_aMsg   := {}
		zNomFil := FWFilialName(cEmpAnt,zFilial,1)
		zMensag := "Pedido de Compra: "+cPedido+" | Filial: "+zFilial+"-"+AllTrim(zNomFil)+" | A P R O V A D O |"

		AAdd(_aMsg, "")
		AAdd(_aMsg, zMensag)
		AAdd(_aMsg, "STATUS: APROVADO PELO GRUPO DE APROVAÇÃO" )

		SC7->(DbGoto(nRecSC7))
		cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SC7->C7_USER) )
		U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

		// E-mails complementares
		If Empty(GetMv("MV_WFEMTST"))
			zUsrParm := AllTrim(GetMv("MV_XEMLAPC"))
			zUsrMail := ""
			aUsrMail := {}
			If !Empty(zUsrParm)
				zUsrMail := zUsrParm
			Endif
			//
			If !Empty(zUsrMail)
				nPosic  := 0
				aLinha  := {}
				cTxtLin := zUsrMail
				While (!Empty(cTxtLin))
					If (((nPosic := AT(",",cTxtLin)) > 0))
						AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
						cTxtLin := Stuff(cTxtLin,1,nPosic,"")
					Else
						AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
						cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
					Endif	
				Enddo
				aUsrMail := aClone(aLinha)
			Endif	
			//
			For _x := 1 to Len(aUsrMail)
				If aUsrMail[_x] != SC7->C7_USER
					cEmailWf := UsrRetMail(aUsrMail[_x])
					If !Empty(cEmailWf)
						nPosic := AT("@",cEmailWf)
						If nPosic > 0
							U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)
						Endif
					Endif
				Endif	
			Next _x	
		Endif

	Else
		
		// ********************************************************* //
		// ** Abre novo processo WorkFlow para demais aprovadores ** //
		// ********************************************************* //
		cModo := ""
		If lWfV2
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("ZZJ")
			cQuery += " WHERE ZZJ_FILIAL = '"+zFilial+"' "
			cQuery += " AND ZZJ_PEDIDO = '"+cPedido+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)
			cModo := IIf(SQL7->SOMA == 0, "Inclusão", "Alteração")
			SQL7->(DbCloseArea())
		Endif
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( zFilial + cPedido )
		U_WFPC01(.F.,Nil,.F.,.F.,"Aprovação "+cUsrLib,cModo) // WFPC01(lJob,cNumPed,lShow,lAsk,cRotina,cModo)

	Endif
		
Else // Pedido Reprovado ----------------------------------------------------------------------------------------------

	cTipo := "PC"

	ConOut("Retorno WorkFlow: Pedido Reprovado")

	ConOut("Rejeitando PC: " + cPedido)
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( zFilial + cPedido )
	zRecSC7 := SC7->(Recno())
	While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == zFilial + cPedido
		RecLock("SC7", .F.)
		SC7->C7_CONAPRO := "R"
		MsUnLock()
		SC7->(DbSkip())
	Enddo
	SC7->(DbGoto(zRecSC7))

	DbSelectArea("SCR")
	DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
	If DbSeek( zFilial + "PC" + PadR(cPedido,50) + cUsuario + "02" )

		cObs := "Reprovado por " + AllTrim(UsrFullName(cUsuario)) + " via WF em: " + DtoC(dDatabase) + " as " + Substr(Time(),1,5) + IIf(!Empty(cMotivo)," | Motivo: " + cMotivo,"") // Motivo informado no template HTML
		Reclock("SCR",.F.)
		SCR->CR_STATUS  := "06"
		SCR->CR_DATALIB := dDatabase
		SCR->CR_USERLIB := SCR->CR_USER
		SCR->CR_LIBAPRO := SCR->CR_APROV
		SCR->CR_OBS	    := cObs
		MsUnLock()

		// Notificação de Reprovação ------------------------------------------------
		_aMsg   := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		zMensag := "Pedido de Compra: "+cPedido+" | Filial: "+cFilAnt+"-"+AllTrim(zNomFil)+" | R E P R O V A D O |"

		AAdd(_aMsg, "")
		AAdd(_aMsg, zMensag)
		AAdd(_aMsg, "STATUS: PEDIDO REPROVADO" )
		AAdd(_aMsg, AllTrim(cObs) )

		cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SC7->C7_USER) )
		U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

		// E-mails complementares
		If Empty(GetMv("MV_WFEMTST"))
			zUsrParm := AllTrim(GetMv("MV_XEMLAPC"))
			zUsrMail := ""
			aUsrMail := {}
			If !Empty(zUsrParm)
				zUsrMail := zUsrParm
			Endif
			//
			If !Empty(zUsrMail)
				nPosic  := 0
				aLinha  := {}
				cTxtLin := zUsrMail
				While (!Empty(cTxtLin))
					If (((nPosic := AT(",",cTxtLin)) > 0))
						AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
						cTxtLin := Stuff(cTxtLin,1,nPosic,"")
					Else
						AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
						cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
					Endif	
				Enddo
				aUsrMail := aClone(aLinha)
			Endif	
			//
			For _x := 1 to Len(aUsrMail)
				If aUsrMail[_x] != SC7->C7_USER
					cEmailWf := UsrRetMail(aUsrMail[_x])
					If !Empty(cEmailWf)
						nPosic := AT("@",cEmailWf)
						If nPosic > 0
							U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)
						Endif
					Endif
				Endif	
			Next _x	
		Endif

	Endif		

Endif

Return
