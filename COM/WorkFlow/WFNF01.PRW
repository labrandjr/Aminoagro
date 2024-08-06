#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ WFNF01    ¦ Autor ¦ ERPBR            ¦   Data  ¦ Fev/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ WorkFlow para aprovacao de Tolerância no Recebimento.   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Pacotes   ¦ 28/09/2021 - Projeto Workflow versão 2.0 				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function WFNF01(lJob,cNumNfe,lShow,lAsk,cRotina)

Local aArea      := GetArea()
Local aAprovador := {}
Local lExecuta   := .T.
Local _cEnvMail	 := ""
Local nX

If lJob // Acionado via schedule ===============================================================================

	// ... Não desenvolvido em lote.
	
Else // Acionado manualmente ===================================================================================

	If lAsk
		If Empty(SF1->F1_APROV)
			MsgInfo("Documento não está em processo de aprovação workflow.")
			lExecuta := .F.
		Endif
	Endif

	If lAsk
		If Empty(SF1->F1_STATUS) .And. !Empty(SF1->F1_APROV)
			MsgInfo("Documento não possui processo de aprovação pendente.")
			lExecuta := .F.
		Endif
	Endif
	
	If lAsk .And. lExecuta
		cMsgSf1 := "Documento "+AllTrim(SF1->F1_SERIE)+" "+AllTrim(SF1->F1_DOC)+": confirma processamento do workflow ?"
		If !MsgYesNo(cMsgSf1,"Atencao","INFO")
			lExecuta := .F.
		Endif
	Endif	

	If lExecuta

		cDocume := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

		If Empty(SF1->F1_STATUS) .And. !Empty(SF1->F1_APROV)
			If lAsk
				MsgBox("Documento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" já aprovado e liberado! Não será enviado e-mail para aprovação.", "Atenção", "ALERT")
			Else
				ConOut("Documento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" já aprovado e liberado! Não será enviado e-mail para aprovação.")
			Endif	
			Return
		Endif

		// Checagem de aprovador substituto
		cQuery := " SELECT CR_APROV APROV, R_E_C_N_O_ RECSCR "
		cQuery += " FROM "+RetSqlName("SCR")
		cQuery += " WHERE CR_FILIAL = '"+xFilial("SCR")+"' "
		cQuery += " AND CR_TIPO = 'NF' "
		cQuery += " AND CR_NUM = '"+AllTrim(SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))+"' "
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
		If DbSeek( xFilial("SCR") + "NF" + PadR( SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA), 50) )
			While !Eof() .And. SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == xFilial("SCR") + "NF" + PadR( SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA), 50)
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
			//
			RecLock("SF1",.F.)
			SF1->F1_STATUS := "B"
			MsUnLock()
		    //
		    If lShow
				MsgRun("Processo Workflow do Documento "+AllTrim(SF1->F1_FILIAL)+"-"+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE),"Processando",{|| WFAbertura(cDocume, aAprovador, lJob, lShow) })
				MsgBox("Processo de aprovacao do Documento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" aberto com sucesso!", "Informação", "INFO")
			Else
				WFAbertura(SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA), aAprovador, lJob, lShow)
				ConOut("Processo de aprovacao do Documento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" aberto com sucesso!")
			Endif	
		Else
			If lShow
				MsgBox("Processo de aprovacao do Documento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" não aberto. Verifique status de aprovações.", "Informação", "STOP")
			Else
				ConOut("Processo de aprovacao do Documento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" não aberto. Verifique status de aprovações.")
			Endif	
		Endif

		DbSelectArea("SCR")
		DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
		For nX := 1 to Len(aAprovador)
			If DbSeek( xFilial("SCR") + "NF" + PadR(cDocume,50) + aAprovador[nX,1] + "02" )
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
¦¦¦Programa  ¦ WFAbertura  ¦ Autor ¦ ERPBR          ¦   Data  ¦ Fev/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio do workflow para aprovacao.			         	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function WFAbertura(cDocume, aAprovador, lJob, lShow)

Local cNumero   := "" // Numero do Processo
Local cProcesso := ""
Local cTarefa   := ""
Local oProcesso := Nil
Local cHTML     := ""
Local cAssunto  := ""
Local nI

Private _cUrl := Alltrim(GetMv("MV_WFURL"))

If lShow
	ProcRegua(Len(aAprovador))
Endif

For nI := 1 to Len(aAprovador)

	ConOut("Fase 6 processo Aprovacao Tolerância no Recebimento")

	If lShow
		IncProc("Processando WorkFlow...")
	Endif
	
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek( xFilial("SF1") + cDocume )
		
		cNumero   := "000002"
		cHTML     := "\workflow\HTML\nf_fertilaqua.html"
		cProcesso := OemToAnsi("Aprovacao de Tolerancia no Recebimento")
		cTarefa   := OemToAnsi("Aprovacao de Tolerancia no Recebimento")
		cAssunto  := "Aprovação de Tolerância no Recebimento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)
		
		// Dados do usuario
		oProcesso := TWFProcess():New(cNumero,cProcesso)
		oProcesso:NewTask(cTarefa,cHTML)
		oProcesso:cSubject := cAssunto
		oProcesso:bReturn := "U_WFRetNfe()"
		oProcesso:NewVersion(.T.)
		
		oHTML := oProcesso:oHTML
		
		ConOut("Fase 7 processo Aprovacao Tolerancia no Recebimento")

		// Preenche os dados
		zFilDoc     := SF1->F1_FILIAL
		zDocumen    := AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)
		dEmissao    := SF1->F1_EMISSAO
		cFornecedor := SF1->F1_FORNECE
		cLoja       := SF1->F1_LOJA
		cNome       := ""
		cEndereco   := ""
		cEstado     := ""
		cCEP        := ""
		cCNPJ       := ""
		cIE         := ""
		cTelefone   := ""
		cFax        := ""
		cReferencia := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
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
		SM0->( DbSeek( Substr(cNumEmp,1,2) + SF1->F1_FILIAL) )
		cEntrega  := Alltrim(SM0->M0_ENDENT) + "  " + Alltrim(SM0->M0_CIDENT) + "  - " + SM0->M0_ESTENT + " - " + Transform(SM0->M0_CEPENT, "99999-999")
		cCobranca := Alltrim(SM0->M0_ENDCOB) + "  " + Alltrim(SM0->M0_CIDCOB) + "  - " + SM0->M0_ESTCOB + " - " + Transform(SM0->M0_CEPCOB, "99999-999")
		SM0->(DbGoto(nRecnoSM0))
		
		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )

		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( xFilial("SC7") + SD1->D1_PEDIDO )

		DbSelectArea("SF1")
		
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
		cEmailCom    := ""
		nMoeda       := IIf(SF1->F1_MOEDA > 1, SF1->F1_MOEDA, 1)
		cMoeda       := AllTrim(GetMv("MV_SIMB"+AllTrim(STR(nMoeda))))
		nTxMoeda     := IIf(SF1->F1_MOEDA > 1, SF1->F1_TXMOEDA, 1)
		cPagamento   := AllTrim(Posicione("SE4",1,xFilial("SE4")+SF1->F1_COND,"E4_DESCRI"))+" - "+AllTrim(Posicione("SE4",1,xFilial("SE4")+SF1->F1_COND,"E4_COND"))
		
		DbSelectArea("SY1")
		DbSetOrder(3)
		If DbSeek( xFilial("SY1") + SC7->C7_USER )
			cEmailCom := SY1->Y1_EMAIL
		Endif
		
		cAprovador := aAprovador[nI,2] + "-" + aAprovador[nI,3]
		
		oHTML:ValByName("DOCUME", zDocumen )
		oHTML:ValByName("EMISSAO", DtoC(dEmissao) )
		oHTML:ValByName("FORNECEDOR", cFornecedor + "/" + cLoja + " - " + cNome )
		oHTML:ValByName("REFERENCIA", cReferencia )
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
		
		DbSelectArea("SD1")
		DbSetOrder(1)		
		DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
		While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1") +SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

			If !Empty(SD1->D1_PEDIDO)
			
				DbSelectArea("SC7")
				DbSetOrder(1)
				DbSeek( xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC )
	
				aTotItPc := u_TotItPc(SD1->D1_PEDIDO,SD1->D1_ITEMPC)
				If (aTotItPc[1] > SC7->C7_QUANT) .Or. (aTotItPc[2] > SC7->(C7_TOTAL+C7_VALIPI))
				
					cItem       := SD1->D1_ITEM
					cProduto    := Alltrim(SD1->D1_COD)
					cDescricao  := Alltrim(SC7->C7_DESCRI)
					cUM         := SD1->D1_UM
					nQtdRec     := aTotItPc[1]
					nVlrRec     := aTotItPc[2]
					nQtdApr     := SC7->C7_QUANT
					nVlrApr     := SC7->(C7_TOTAL+C7_VALIPI)
					zPedido     := SD1->D1_PEDIDO+"-"+SD1->D1_ITEMPC
					cCC         := AllTrim(SD1->D1_CC)
					cObs        += IIf( !Empty(SC7->C7_OBS), IIf(!Empty(cObs)," | ","") + Alltrim(SC7->C7_OBS), "")
					
					AAdd( oHTML:ValByName("itens.ITEM"), cItem )
					AAdd( oHTML:ValByName("itens.CODIGO"), cProduto )
					AAdd( oHTML:ValByName("itens.DESCRICAO"), cDescricao )
					AAdd( oHTML:ValByName("itens.UM"), cUM )
					AAdd( oHTML:ValByName("itens.QTDREC"), Transform(nQtdRec, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.VLRREC"), Transform(nVlrRec, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.QTDAPR"), Transform(nQtdApr, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.VLRAPR"), Transform(nVlrApr, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.PEDIDO"), zPedido  )
					AAdd( oHTML:ValByName("itens.CC"), cCC )
				
				ElseIf (SD1->D1_VUNIT > SC7->C7_PRECO) .And. (SD1->D1_QUANT <= SC7->C7_QUANT)
				
					cItem       := SD1->D1_ITEM
					cProduto    := Alltrim(SD1->D1_COD)
					cDescricao  := Alltrim(SC7->C7_DESCRI)
					cUM         := SD1->D1_UM
					nQtdRec     := SD1->D1_QUANT
					nVlrRec     := SD1->D1_TOTAL
					nQtdApr     := SD1->D1_QUANT
					nVlrApr     := SD1->D1_QUANT * SC7->C7_PRECO
					zPedido     := SD1->D1_PEDIDO+"-"+SD1->D1_ITEMPC
					cCC         := AllTrim(SD1->D1_CC)
					cObs        += IIf( !Empty(SC7->C7_OBS), IIf(!Empty(cObs)," | ","") + Alltrim(SC7->C7_OBS), "")
					
					AAdd( oHTML:ValByName("itens.ITEM"), cItem )
					AAdd( oHTML:ValByName("itens.CODIGO"), cProduto )
					AAdd( oHTML:ValByName("itens.DESCRICAO"), cDescricao )
					AAdd( oHTML:ValByName("itens.UM"), cUM )
					AAdd( oHTML:ValByName("itens.QTDREC"), Transform(nQtdRec, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.VLRREC"), Transform(nVlrRec, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.QTDAPR"), Transform(nQtdApr, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.VLRAPR"), Transform(nVlrApr, "@E 999,999,999.99") )
					AAdd( oHTML:ValByName("itens.PEDIDO"), zPedido  )
					AAdd( oHTML:ValByName("itens.CC"), cCC )
				
				Endif

			Endif		

			nMercadorias += SD1->D1_TOTAL
			nFrete       += SD1->D1_VALFRE
			nDespesas    += SD1->D1_DESPESA
			nSeguro      += SD1->D1_SEGURO
			nICMS        += SD1->D1_VALICM
			nIPI         += SD1->D1_VALIPI
			nDesconto    += SD1->D1_VALDESC
			nTotal       += (SD1->(D1_TOTAL + D1_VALFRE + D1_DESPESA + D1_SEGURO + D1_VALIPI) - SD1->D1_VALDESC)
			
			DbSelectArea("SD1")
			SD1->(DbSkip())
		Enddo

		cDocume := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		lUsrApr := .F.
		DbSelectArea("SCR")
		DbSetOrder(1)
		If DbSeek( zFilDoc + "NF" + PadR(cDocume,50) )
			While !Eof() .And. zFilDoc + "NF" + Alltrim(cDocume) == SCR->(CR_FILIAL + CR_TIPO + AllTrim(CR_NUM))
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
		AAdd( oProcesso:aParams, zFilDoc)
		AAdd( oProcesso:aParams, SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		AAdd( oProcesso:aParams, aAprovador[nI,2])
		AAdd( oProcesso:aParams, aAprovador[nI,1])
		oProcesso:nEncodeMime := 0
		
		// Inicio do trecho que grava o HTML
		oProcesso:ClientName( "EXPLORER" )
		oProcesso:cTo := "nf_fertilaqua" // manda a pasta do processo
		oProcesso:UserSiga := __cUserID
		// Fim do trecho que grava o HTML
		
		ConOut("Fase 8 processo Aprovacao Tolerancia no Recebimento")
		cMailId := oProcesso:Start()
		
		ConOut("Fase 9 processo Aprovacao Tolerancia no Recebimento")

		_aMsg := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		zTitulo := "Tolerancia no Recebimento: "+zDocumen+" | Filial: "+cFilAnt+"-"+AllTrim(zNomFil)
		
		AAdd(_aMsg, "")
		AAdd(_aMsg, zTitulo) 
		AAdd(_aMsg, "Aprovador: " + aAprovador[nI,2] + "-" + aAprovador[nI,3] )
		AAdd(_aMsg, "Abaixo segue o link para acesso." )
		AAdd(_aMsg, '<A href="http://' + _cUrl + '/HTTP/messenger/emp'+cEmpAnt+'/nf_fertilaqua/'+AllTrim(cMailId)+'.htm">clique aqui</A>' )

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
¦¦¦Programa  ¦ TotItPc	  ¦ Autor ¦ ERPBR          ¦   Data  ¦ Jan/2019   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula total recebido do Pedido+Item.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TotItPc(zPedido,zItemPc)

Local aArea := GetArea()
Local aRet  := {}

AAdd(aRet,0)
AAdd(aRet,0)

cQuery := " SELECT SUM(D1_QUANT) QUANT, SUM(D1_TOTAL) TOTAL, SUM(D1_VALIPI) VALIPI "
cQuery += " FROM " + RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
cQuery += " AND D1_PEDIDO = '"+zPedido+"' "
cQuery += " AND D1_ITEMPC = '"+zItemPc+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP1", .F., .T.)	  	
aRet[1] := TMP1->QUANT
aRet[2] := TMP1->TOTAL + TMP1->VALIPI
TMP1->(DbCloseArea())

RestArea(aArea)

Return(aRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ WFRetNfe	  ¦ Autor ¦ ERPBR          ¦   Data  ¦ Fev/2018   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Retorno do workflow para aprovação.			         	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function WFRetNfe(oProcesso)

Local cDocume    := ""
Local cResposta  := ""
Local cMotivo    := ""
Local cAprovador := ""
Local lAprovado  := .F.
Local lWfV2      := GetMv("MV_ZWFVER2")

ChkFile("SCR")
ChkFile("SF1")
ChkFile("SD1")
ChkFile("SX2")
ChkFile("WFA")

If oProcesso <> Nil

    zFilial	   := oProcesso:aParams[1]
	cDocume	   := oProcesso:aParams[2]
	cAprovador := oProcesso:aParams[3]
	cUsuario   := oProcesso:aParams[4]
	cResposta  := oProcesso:oHtml:RetByName("APROVA")
	cMotivo	   := Alltrim(oProcesso:oHtml:RetByName("MOTIVO"))
	lAprovado  := (cResposta = "Sim")

	ConOut(zFilial)
	ConOut(cDocume)
	ConOut(cAprovador)
	ConOut(cUsuario)
	ConOut(cResposta)

	If lWfV2
		DbselectArea("ZZK")
		DbSetOrder(1)
		If !DbSeek( zFilial + PadR(cDocume,50) + cAprovador  )
			RecLock("ZZK",.T.)
			ZZK->ZZK_FILIAL := zFilial
			ZZK->ZZK_NUMDOC := cDocume
			ZZK->ZZK_APROV  := cAprovador
			ZZK->ZZK_USER   := cUsuario
		Else
			RecLock("ZZK",.F.)
		Endif
		ZZK->ZZK_DATALB := Date()
		ZZK->ZZK_HORALB := Substr(Time(),1,5)
		ZZK->ZZK_RESP   := IIf(lAprovado,"S","N")
		ZZK->ZZK_OK     := ""
		ZZK->ZZK_TIPO   := "NF"
		ZZK->ZZK_MOTIVO := cMotivo
		MsUnLock()
	Endif

	oProcesso:Finish() // Finaliza o Processo
	
	ConOut("Retorno do WF: aprovacao do documento: " + cDocume + " " + IIf(lAprovado, "Aprovado", "Reprovado"))

	u_WfAprovNf(zFilial, cDocume, cAprovador, cUsuario, cMotivo, lAprovado)

Endif

SCR->(DbCloseArea())
SF1->(DbCloseArea())

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

User Function WfAprovNf(zFilial, cDocume, cAprovador, cUsuario, cMotivo, lAprovado)

Local cObs := ""
Local cEOL := CHR(13)+CHR(10)

cFilAnt := zFilial

If lAprovado // Documento Aprovado ---------------------------------------------------------------------------------------
	
	cTipo := "NF"

	ConOut("Retorno WorkFlow: Documento Aprovado")

	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek( zFilial + cDocume )
	nRecSF1 := Recno()

	cUsrLib := AllTrim(UsrFullName(cUsuario))
	DbSelectArea("SCR")
	DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
	If DbSeek( zFilial + "NF" + PadR(cDocume,50) + cUsuario + "02" )
		cObs := "Aprovado por " + cUsrLib + " via WF em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5)
		ConOut("Baixando saldo de aprovacao para a NF: "+cDocume+" | Aprovador: "+AllTrim(SCR->CR_APROV))
		lLibOk := A097Lock(Substr(SCR->CR_NUM,1,20),SCR->CR_TIPO)
		If lLibOk
			ConOut("A097Lock "+cDocume+" .T.")
		Else
			ConOut("A097Lock "+cDocume+" .F.")
		Endif
		If lLibOk
			lLibOk := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SF1->F1_APROV,,,,,cObs}, dDataBase, 4)
			If lLibOk
				ConOut("MaAlcDoc "+cDocume+" .T.")
			Else
				ConOut("MaAlcDoc "+cDocume+" .F.")
			Endif
		Endif
	Endif

	// Reposiciona e verifica se ja está totalmente liberado
	lAprovOk := .T.	
	DbSelectArea("SCR")
	DbSetOrder(1)
	DbSeek( zFilial + "NF" + PadR(cDocume,50) )
	While !Eof() .And. zFilial + "NF" + Alltrim(cDocume) == SCR->(CR_FILIAL + CR_TIPO + AllTrim(CR_NUM))
		If SCR->CR_STATUS != "03" .And. SCR->CR_STATUS != "05"
			lAprovOk := .F.
			Exit
		Endif
		SCR->(DbSkip())
	Enddo

	If lAprovOk

		ConOut("Liberando NF: " + cDocume)
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek( zFilial + cDocume )
			RecLock("SF1",.F.)
			SF1->F1_STATUS := ""
			MsUnLock()
		Endif

		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )

		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_PEDIDO) )

		// Notificação de Aprovação -------------------------------------------------
		_aMsg   := {}
		zNomFil := FWFilialName(cEmpAnt,zFilial,1)
		zMensag := "Documento: "+AllTrim(Substr(cDocume,1,9))+"-"+AllTrim(Substr(cDocume,10,3))+" | Filial: "+zFilial+"-"+AllTrim(zNomFil)+" | A P R O V A D O |"

		AAdd(_aMsg, "")
		AAdd(_aMsg, zMensag)
		AAdd(_aMsg, "STATUS: APROVADO PELO GRUPO DE APROVAÇÃO" )

		SF1->(DbGoto(nRecSF1))
		cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SF1->F1_ZZUSER) )
		U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

	Else
		
		// ********************************************************* //
		// ** Abre novo processo WorkFlow para demais aprovadores ** //
		// ********************************************************* //
		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek( zFilial + cDocume )
		U_WFNF01(.F.,Nil,.F.,.F.,"Aprovação "+cUsrLib) // WFNF01(lJob,cNumNfe,lShow,lAsk,cRotina)

	Endif
		
Else // Documento Reprovado ----------------------------------------------------------------------------------------------

	cTipo := "NF"

	ConOut("Retorno WorkFlow: Documento Reprovado")

	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek( zFilial + cDocume )

	DbSelectArea("SCR")
	DbSetOrder( IIf(Right(GetRPORelease(),3)=="027",4,5) )
	If DbSeek( zFilial + "NF" + PadR(cDocume,50) + cUsuario + "02" )

		If !Empty(SCR->CR_OBS)
			cAnt := AllTrim(SCR->CR_OBS)
			cObs := cAnt+cEOL+cObs
		Endif

		cObs := "Reprovado por " + AllTrim(UsrFullName(cUsuario)) + " via WF em " + DtoC(dDatabase) + " as " + Substr(Time(),1,5) + IIf(!Empty(cMotivo)," | Motivo: " + cMotivo,"") // Motivo informado no template HTML
		Reclock("SCR",.F.)
		SCR->CR_STATUS  := "06"
		SCR->CR_DATALIB := dDatabase
		SCR->CR_USERLIB := SCR->CR_USER
		SCR->CR_LIBAPRO := SCR->CR_APROV
		SCR->CR_OBS	    := cObs
		MsUnLock()

		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )

		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( SD1->(D1_FILIAL+D1_PEDIDO) )

		// Notificação de Reprovação ------------------------------------------------
		_aMsg   := {}
		zNomFil := FWFilialName(cEmpAnt,cFilAnt,1)
		zMensag := "Documento: "+AllTrim(Substr(cDocume,1,9))+"-"+AllTrim(Substr(cDocume,10,3))+" | Filial: "+cFilAnt+"-"+AllTrim(zNomFil)+" | R E P R O V A D O |"

		AAdd(_aMsg, "")
		AAdd(_aMsg, zMensag)
		AAdd(_aMsg, "STATUS: DOCUMENTO REPROVADO" )
		AAdd(_aMsg, AllTrim(cObs) )

		cEmailWf := IIf( !Empty(GetMv("MV_WFEMTST")), AllTrim(GetMv("MV_WFEMTST")), UsrRetMail(SF1->F1_ZZUSER) )
		U_MailNotify(cEmailWf, zMensag, _aMsg, .F.)

	Endif		

Endif

Return
