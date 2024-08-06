#Include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SF2520E  º Autor ³Deivid A. C. de Limaº Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Ponto de Entrada executado na exclusão da Nota Fiscal.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA520                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SF2520E() 

Local aArea   := GetArea()
Local aAreaD2 := SD2->(GetArea())
Local lRet    := .T.
Local oTMsg   := FswTemplMsg():TemplMsg("S",SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)

// Exclui mensagens da NF
oTMsg:excMsg()

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) )
	DbSelectArea("SZG")
	DbSetOrder(1)
	If DbSeek( xFilial("SZG") + SD2->D2_PEDIDO + Space(9) )
		While !Eof() .And. SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->ZG_PEDIDO == SD2->D2_PEDIDO .And. Empty(SZG->ZG_NFISCAL)
			RecLock("SZG",.F.)
			DbDelete()
			MsUnLock()
			SZG->(DbSkip())
		Enddo
	Endif
Endif

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek( xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) )
	DbSelectArea("SZG")
	DbSetOrder(1)
	If DbSeek( xFilial("SZG") + SD2->D2_PEDIDO + SF2->F2_DOC )
		RecLock("SZG",.F.)
		SZG->ZG_NFISCAL := ""
		MsUnLock()
	Endif
Endif

// Alerta quando é Documento de Transferência entre Filiais
If GetMv("MV_ZEMNFTR")
	If u_ChkNfTr("S", SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE)
		u_EmlNfTr("S", SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE)
	Endif
Endif

RestArea(aArea)
RestArea(aAreaD2)

Return(lRet)
