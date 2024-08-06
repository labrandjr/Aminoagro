#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA440MNU ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 08/03/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na rotina de Liberação de Pedidos.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA440MNU()

AAdd(aRotina,{"Cond.Pagamento","U_A440COND()", 0, 7, 0, Nil}) 
AAdd(aRotina,{"Histórico Cond","U_A440HIST()", 0, 7, 0, Nil}) 
                                                                             
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A440COND ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 08/03/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteração da condição de pagamento.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A440COND()

Local lLib := .F.
Local lAsk := .F.
Local lNew := .F.
Local lAlt := .T.
Local lFin := .F.

If (!Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK == "E")
	MsgInfo("Pedido encerrado.","Aviso")
	Return
Endif

If SC5->C5_TIPO != "N"
	MsgInfo("Recurso não disponível para Pedidos com Tipo # 'Normal'.","Aviso")
	Return
Endif

DbSelectArea("SC6")
DbSetOrder(1)
If DbSeek( xFilial("SC6") + SC5->C5_NUM )
	While !Eof() .And. SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6") + SC5->C5_NUM
		lFin := (RetField("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") == "S")
		If lFin
			Exit
		Endif
		DbSelectArea("SC6")
		SC6->(DbSkip())
	Enddo
Endif

If !lFin
	MsgInfo("O Pedido não possui itens com integração financeira.","Aviso")
	Return
Endif

DbSelectArea("SZG")
DbSetOrder(1)
If !DbSeek( xFilial("SZG") + SC5->C5_NUM + Space(9) )
	lNew := .T.
Endif

DbSelectArea("SC9")
DbSetOrder(1)
If DbSeek( xFilial("SC9") + SC5->C5_NUM )
	While !Eof() .And. SC9->(C9_FILIAL + C9_PEDIDO) == xFilial("SC9") + SC5->C5_NUM
		If SC9->C9_BLEST != "10"
			lLib := .T.
			Exit
		Endif
		SC9->(DbSkip())
	Enddo
Endif

If lNew .And. lLib
	MsgInfo("Estorne a liberação para configurar uma condição de pagamento exclusiva.","Aviso")
	Return
ElseIf lNew .And. !lLib
	lAsk := .T.
Endif

If lAsk
	If !MsgYesNo("Inserir nova Condição de Pagamento para o Pedido "+SC5->C5_NUM+" ?","Aviso")
		lAlt := .F.		
	Endif
Endif

If lAlt
	DbSelectArea("SZG")
	DbSetOrder(1)
	If !DbSeek( xFilial("SZG") + SC5->C5_NUM + Space(9) )
		RecLock("SZG",.T.)
		SZG->ZG_FILIAL  := xFilial("SZG")
		SZG->ZG_PEDIDO  := SC5->C5_NUM
		SZG->ZG_CONDPAG := SC5->C5_CONDPAG
		MsUnLock()
	Endif	
	U_AltCpLib()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AltCpLib ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 18/04/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Registra alteração na condição de pagamento.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AltCpLib()

Local aArea   := GetArea()
Local aRotBkp := aClone(aRotina)

Private aRotina := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	    {"Visualizar" , "AxVisual" , 0 , 2 },;
            	    {"Incluir"    , "AxInclui" , 0 , 3 },;
            	    {"Alterar"    , "AxAltera" , 0 , 4 },;
            	    {"Excluir"    , "AxDeleta" , 0 , 5 }}

DbSelectArea("SZG")
DbSetOrder(1)
If !DbSeek( xFilial("SZG") + SC5->C5_NUM + Space(9) )
	MsgInfo("Erro de sincronismo. Contate o Administrador.","Aviso")
	aRotina := aClone(aRotBkp)
	RestArea(aArea)
	Return	
Endif

If !(__cUserId $ AllTrim(GetMv("MV_USCPLIB")))
	MsgInfo("Usuário não autorizado. Contate o Administrador.","Aviso")
	Return
Endif

Altera := .T.
nReg   := SZG->(Recno())
aAcho  := {}
nOpc   := AxAltera("SZG", nReg, 4, aAcho,,,,"u_Cp440TOk()",)
//AxAltera( <cAlias>, <nReg>, <nOpc>, <aAcho>, <aCpos>, <nColMens>, <cMensagem>, <cTudoOk>, <cTransact>, <cFunc>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)

If nOpc == 1

	RecLock("SZG",.F.)
	SZG->ZG_USUARIO := cUserName
	SZG->ZG_DATA    := Date()
	SZG->ZG_HORA    := Time()
	MsUnLock()

	MsgInfo("Alteração concluída !!","Aviso")

Else
	
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + SZG->ZG_CONDPAG )
	If SE4->E4_TIPO == "9"
		If Empty(SZG->ZG_DATA1) .And. Empty(SZG->ZG_DATA2) .And. Empty(SZG->ZG_DATA3) .And. Empty(SZG->ZG_DATA4)
			RecLock("SZG",.F.)
			DbDelete()
			MsUnLock()
		Endif
	Endif

Endif

aRotina := aClone(aRotBkp)
RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Cp440TOk ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 18/04/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação na confirmação da tela.				  		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function Cp440TOk()

Local lRetOk := .T.
Local cEOL   := CHR(13)+CHR(10)
Local _v

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek( xFilial("SE4") + M->ZG_CONDPAG )
lRetOk := u_ChkCondPv(.T.)

If lRetOk

	lLibPv := .F.
	DbSelectArea("SC9")
	DbSetOrder(1)
	If DbSeek( xFilial("SC9") + SC5->C5_NUM )
		While !Eof() .And. SC9->(C9_FILIAL + C9_PEDIDO) == xFilial("SC9") + SC5->C5_NUM
			If SC9->C9_BLEST != "10"
				lLibPv := .T.
				Exit
			Endif
			SC9->(DbSkip())
		Enddo
	Endif

	If lLibPv // Se o pedido estiver liberado, deve obedecer os prazos máximos permitidos
	
		If !Empty(SC5->C5_ZZITCTB)
			If AllTrim(SC5->C5_ZZITCTB) == "BU4"
				zMxCp := GetMv("MV_PRZBLQX")
			Else
				zMxCp := GetMv("MV_PRZBLQ4")
			Endif
			//
			DbSelectArea("SE4")
			DbSetOrder(1)
			DbSeek( xFilial("SE4") + M->ZG_CONDPAG )
			If SE4->E4_TIPO == "9"
				If !Empty(M->ZG_DATA1)
					zDias := M->ZG_DATA1 - dDatabase
					If zDias > zMxCp
						lRetOk := .F.
					Endif
				ElseIf !Empty(M->ZG_DATA2)
					zDias := M->ZG_DATA2 - dDatabase
					If zDias > zMxCp
						lRetOk := .F.
					Endif
				ElseIf !Empty(M->ZG_DATA3)
					zDias := M->ZG_DATA3 - dDatabase
					If zDias > zMxCp
						lRetOk := .F.
					Endif
				ElseIf !Empty(M->ZG_DATA4)
					zDias := M->ZG_DATA4 - dDatabase
					If zDias > zMxCp
						lRetOk := .F.
					Endif
				Endif	
			Else
				aVenc := Condicao(10000, M->ZG_CONDPAG, 0, dDatabase, 0)
				For _v := 1 to Len(aVenc)
					zDias := aVenc[_v][1] - dDatabase
					If zDias > zMxCp
						lRetOk := .F.
						Exit
					Endif
				Next _v
			Endif
		Endif
		
		If !lRetOk
			MsgInfo("Condição de Pagamento ultrapassa "+AllTrim(STR(zMxCp))+" dias."+cEOL+;
					"Estorne a liberação para informar esta condição.","Aviso")
		Endif
		
	Endif

Endif

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChkCondPv ¦ Autor ¦ Luis Brandini  ¦    Data  ¦ 03/02/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checa integridade da condição exclusiva.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ChkCondPv(lPedido)

Local lRetOk := .T.

If lPedido
	If SE4->E4_TIPO == "9"
		If AllTrim(SE4->E4_COND) != "%" .And. M->ZG_CONDPAG != SC5->C5_CONDPAG
			MsgInfo("Condição de pagamento Tipo 9 deve ser % (percentual).","Aviso")
			lRetOk := .F.
		ElseIf AllTrim(SE4->E4_COND) == "%" .And. (M->ZG_PARC1 + M->ZG_PARC2 + M->ZG_PARC3 + M->ZG_PARC4) != 100
			MsgInfo("O total informado não atingiu 100%.","Aviso")
			lRetOk := .F.
		ElseIf AllTrim(SE4->E4_COND) == "0" .And. (M->ZG_PARC1 + M->ZG_PARC2 + M->ZG_PARC3 + M->ZG_PARC4) == 0
			MsgInfo("Valor das parcelas não informado.","Aviso")
			lRetOk := .F.
		ElseIf M->ZG_PARC1 > 0 .And. Empty(M->ZG_DATA1)
			MsgInfo("Vencimento 1 não informado.","Aviso")
			lRetOk := .F.
		ElseIf M->ZG_PARC2 > 0 .And. Empty(M->ZG_DATA2)
			MsgInfo("Vencimento 2 não informado.","Aviso")
			lRetOk := .F.
		ElseIf M->ZG_PARC3 > 0 .And. Empty(M->ZG_DATA3)
			MsgInfo("Vencimento 3 não informado.","Aviso")
			lRetOk := .F.
		ElseIf M->ZG_PARC4 > 0 .And. Empty(M->ZG_DATA4)
			MsgInfo("Vencimento 4 não informado.","Aviso")
			lRetOk := .F.
		ElseIf !Empty(M->ZG_DATA1) .And. M->ZG_PARC1 == 0
			MsgInfo("Parcela 1 não informada.","Aviso")
			lRetOk := .F.
		ElseIf !Empty(M->ZG_DATA2) .And. M->ZG_PARC2 == 0
			MsgInfo("Parcela 2 não informada.","Aviso")
			lRetOk := .F.
		ElseIf !Empty(M->ZG_DATA3) .And. M->ZG_PARC3 == 0
			MsgInfo("Parcela 3 não informada.","Aviso")
			lRetOk := .F.
		ElseIf !Empty(M->ZG_DATA4) .And. M->ZG_PARC4 == 0
			MsgInfo("Parcela 4 não informada.","Aviso")
			lRetOk := .F.
		Endif
	Endif
Else
	If SE4->E4_TIPO == "9"
		If AllTrim(SE4->E4_COND) != "%" .And. SZG->ZG_CONDPAG != SC5->C5_CONDPAG
			lRetOk := .F.
		ElseIf AllTrim(SE4->E4_COND) == "%" .And. (SZG->ZG_PARC1 + SZG->ZG_PARC2 + SZG->ZG_PARC3 + SZG->ZG_PARC4) != 100
			lRetOk := .F.
		ElseIf AllTrim(SE4->E4_COND) == "0" .And. (SZG->ZG_PARC1 + SZG->ZG_PARC2 + SZG->ZG_PARC3 + SZG->ZG_PARC4) == 0
			lRetOk := .F.
		ElseIf SZG->ZG_PARC1 > 0 .And. Empty(SZG->ZG_DATA1)
			lRetOk := .F.
		ElseIf SZG->ZG_PARC2 > 0 .And. Empty(SZG->ZG_DATA2)
			lRetOk := .F.
		ElseIf SZG->ZG_PARC3 > 0 .And. Empty(SZG->ZG_DATA3)
			lRetOk := .F.
		ElseIf SZG->ZG_PARC4 > 0 .And. Empty(SZG->ZG_DATA4)
			lRetOk := .F.
		ElseIf !Empty(SZG->ZG_DATA1) .And. SZG->ZG_PARC1 == 0
			lRetOk := .F.
		ElseIf !Empty(SZG->ZG_DATA2) .And. SZG->ZG_PARC2 == 0
			lRetOk := .F.
		ElseIf !Empty(SZG->ZG_DATA3) .And. SZG->ZG_PARC3 == 0
			lRetOk := .F.
		ElseIf !Empty(SZG->ZG_DATA4) .And. SZG->ZG_PARC4 == 0
			lRetOk := .F.
		Endif
	Endif
Endif

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A440HIST ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 08/03/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta histórico da condição de pagamento nas liberações.¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A440HIST()

Local aArea   := GetArea()
Local aRotBkp := aClone(aRotina)
Local cCadBkp := cCadastro

Private cCadastro := "Histórico Cond.Pagto."

Private aRotina := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	    {"Visualizar" , "AxVisual" , 0 , 2 }}

Private cFiltro   := " ZG_FILIAL == '"+xFilial("SZG")+"' .And. ZG_PEDIDO == '"+SC5->C5_NUM+"' "

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SZG" )			
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "SZG", , , "SZG_FILENT" )		 
oMBrowse:ExecuteFilter()

oMBrowse:Activate()

DbSelectArea("SZG")
DbSetOrder(1)
DbClearFilter()
		
cCadastro := cCadBkp
aRotina := aClone(aRotBkp)

RestArea(aArea)

Return
