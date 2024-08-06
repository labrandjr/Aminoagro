#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IMPLORC   ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 22/03/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação da Planilha Orçamentária.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IMPLORC()

Local lOk   := .F.
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private cPerg	 := "IMPLORC100"
Private cAnoPla	 := ""
Private oProcess

If !Pergunte(cPerg,.T.)
	Return
Endif
If mv_par01 < 2021
	MsgInfo("Ano inválido.")
	Return
Endif

cAnoPla := AllTrim(STR(mv_par01))
cArquivo := cGetFile("Arquivos CSV|*.CSV|",OemToAnsi("Selecione o arquivo"))
cArquivo := AllTrim(cArquivo)
If !Empty(cArquivo)
	If File(cArquivo)
		If MsgYesNo("Arquivo a ser processado: "+cEOL+cArquivo+"."+cEOL+"Deseja prosseguir ?","Aviso","INFO")
			lOkFile := .T.
		Endif
	Else
		MsgAlert("Arquivo não encontrado.")
	Endif
Else
	MsgAlert("Arquivo não selecionado.")
Endif

If lOkFile

	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	If mv_par02 == 1 // Planilha
		If MsgYesNo("Confirma o processamento - PLANILHA ORÇAMENTÁRIA GMD"+cAnoPla+" ?","Aviso","INFO")
			oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp(cAnoPla) }, "Processando planilha orçamentária", "Aguarde, processando ...", .F. )
			oProcess:Activate()
		Endif
	ElseIf mv_par02 == 2 // Lançamentos
		If MsgYesNo("Confirma o processamento - LANÇAMENTOS ORÇADOS DÉBITO GMD"+cAnoPla+" ?","Aviso","INFO")
			oProcess := MsNewProcess():New( { | lEnd | lOk := ProcDeb(cAnoPla) }, "Atualizando lançamentos a débito", "Aguarde, processando ...", .F. )
			oProcess:Activate()
		Endif
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  22/03/19	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp(cAnoPla)

Local nCountLin := 0
Local aFiliais  := {}
Local _x
Local _z

AAdd(aFiliais,"    ")

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(160)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando arquivo csv..")

	// Fim de Arquivo
	If Len(cString) < 3
		Exit
	Endif

	nPosic  := 0
	aLinha  := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT(";",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	// Estrutura de aLinha:
	// [01] - Conta Orçamentária
	// [02] - Valor Janeiro
	// [03] - Valor Fevereiro
	// [04] - Valor Março
	// [05] - Valor Abril
	// [06] - Valor Maio
	// [07] - Valor Junho
	// [08] - Valor Julho
	// [09] - Valor Agosto
	// [10] - Valor Setembro
	// [11] - Valor Outubro
	// [12] - Valor Novembro
	// [13] - Valor Dezembro

	If Len(aLinha) != 13
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 13 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zConta := PadR(aLinha[1],12)
		zPer01 := cAnoPla+"0101"
		zVlr01 := StrTran(aLinha[2],".","")
		zVlr01 := StrTran(zVlr01,",",".")
		zVlr01 := ABS(Val(zVlr01))
		zPer02 := cAnoPla+"0201"
		zVlr02 := StrTran(aLinha[3],".","")
		zVlr02 := StrTran(zVlr02,",",".")
		zVlr02 := ABS(Val(zVlr02))
		zPer03 := cAnoPla+"0301"
		zVlr03 := StrTran(aLinha[4],".","")
		zVlr03 := StrTran(zVlr03,",",".")
		zVlr03 := ABS(Val(zVlr03))
		zPer04 := cAnoPla+"0401"
		zVlr04 := StrTran(aLinha[5],".","")
		zVlr04 := StrTran(zVlr04,",",".")
		zVlr04 := ABS(Val(zVlr04))
		zPer05 := cAnoPla+"0501"
		zVlr05 := StrTran(aLinha[6],".","")
		zVlr05 := StrTran(zVlr05,",",".")
		zVlr05 := ABS(Val(zVlr05))
		zPer06 := cAnoPla+"0601"
		zVlr06 := StrTran(aLinha[7],".","")
		zVlr06 := StrTran(zVlr06,",",".")
		zVlr06 := ABS(Val(zVlr06))
		zPer07 := cAnoPla+"0701"
		zVlr07 := StrTran(aLinha[8],".","")
		zVlr07 := StrTran(zVlr07,",",".")
		zVlr07 := ABS(Val(zVlr07))
		zPer08 := cAnoPla+"0801"
		zVlr08 := StrTran(aLinha[9],".","")
		zVlr08 := StrTran(zVlr08,",",".")
		zVlr08 := ABS(Val(zVlr08))
		zPer09 := cAnoPla+"0901"
		zVlr09 := StrTran(aLinha[10],".","")
		zVlr09 := StrTran(zVlr09,",",".")
		zVlr09 := ABS(Val(zVlr09))
		zPer10 := cAnoPla+"1001"
		zVlr10 := StrTran(aLinha[11],".","")
		zVlr10 := StrTran(zVlr10,",",".")
		zVlr10 := ABS(Val(zVlr10))
		zPer11 := cAnoPla+"1101"
		zVlr11 := StrTran(aLinha[12],".","")
		zVlr11 := StrTran(zVlr11,",",".")
		zVlr11 := ABS(Val(zVlr11))
		zPer12 := cAnoPla+"1201"
		zVlr12 := StrTran(aLinha[13],".","")
		zVlr12 := StrTran(zVlr12,",",".")
		zVlr12 := ABS(Val(zVlr12))

		If Empty(zConta)
			Loop
		Endif

		If Substr(zConta,1,1) != "4"
			If !(AllTrim(zConta) $("31199007,31199008,31199009"))
				Loop
			Endif
		Endif

		DbSelectArea("AK5")
		DbSetOrder(1)
		If !DbSeek( xFilial("AK5") + zConta )
			Loop
		Else
			If AK5->AK5_TIPO <> "2" .Or. AK5->AK5_MSBLQL <> "2"
				Loop
			Endif
		Endif

		For _x := 1 to Len(aFiliais)

			cFilAnt := aFiliais[_x]
			zCodigo := PadR("GMD"+cAnoPla,15)
			zDescri := "GMD "+cAnoPla
			zVersao := u_UltVerPla(zCodigo)
			zCCusto := "101010101001"
			zItemCc := "BU9"
			zClasse := "000001"

			// Planilhas Orçamentárias
			DbSelectArea("AK1")
			DbSetOrder(1)
			If !DbSeek( cFilAnt + zCodigo + zVersao )
				RecLock("AK1",.T.)
				AK1->AK1_FILIAL := cFilAnt
				AK1->AK1_CODIGO := zCodigo
				AK1->AK1_VERSAO := zVersao
				AK1->AK1_DESCRI := zDescri
				AK1->AK1_NMAX   := 1
				AK1->AK1_TPPERI := "3"
				AK1->AK1_INIPER := StoD(cAnoPla+"0101")
				AK1->AK1_FIMPER := StoD(cAnoPla+"1231")
				AK1->AK1_TPREV  := "1"
				AK1->AK1_STATUS := "1"
				AK1->AK1_CTRUSR := "2"
				AK1->AK1_FASE   := "002"
				MsUnLock()
			Endif

			For _z := 1 to 12

				zSeq := StrZero(_z,2)
				zVal := &("zVlr"+zSeq)
				zPer := &("zPer"+zSeq)

				cQuery := " SELECT AK2_ID "
				cQuery += " FROM "+RetSQLName("AK2")
				cQuery += " WHERE AK2_FILIAL = '"+cFilAnt+"' "
				cQuery += " AND AK2_ORCAME = '"+zCodigo+"' "
				cQuery += " AND AK2_VERSAO = '"+zVersao+"' "
				cQuery += " AND AK2_CO = '"+zConta+"' "
				cQuery += " AND AK2_PERIOD = '"+zPer+"' "
				cQuery += " AND AK2_CC = '"+zCCusto+"' "
				cQuery += " AND AK2_ITCTB = '"+zItemCc+"' "
				cQuery += " AND AK2_CLASSE = '"+zClasse+"' "
				cQuery += " AND D_E_L_E_T_ = '' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
				SQL2->(DbGotop())
				If !Eof()
					cId := SQL2->AK2_ID
				Else
					cId := "0001"
				Endif
				SQL2->(DbCloseArea())

				// Itens do Orçamento
				DbSelectArea("AK2")
				DbSetOrder(1)
				If !DbSeek( cFilAnt + zCodigo + zVersao + zConta + zPer + cId )
					RecLock("AK2",.T.)
					AK2->AK2_FILIAL := cFilAnt
					AK2->AK2_ORCAME := zCodigo
					AK2->AK2_VERSAO := zVersao
					AK2->AK2_CO     := zConta
					AK2->AK2_PERIOD := StoD(zPer)
					AK2->AK2_ID     := cId
					AK2->AK2_CC     := zCCusto
					AK2->AK2_ITCTB  := zItemCc
					AK2->AK2_CLASSE := zClasse
					AK2->AK2_OPER   := "1"
					AK2->AK2_MOEDA  := 1
					AK2->AK2_DATAF  := U__DataFim(zPer)
					AK2->AK2_DATAI  := StoD(zPer)
				Else
					RecLock("AK2",.F.)
				Endif
				AK2->AK2_VALOR := (zVal/Len(aFiliais))
				MsUnLock()
			
			Next _z

			// Estrutura do Orçamento
			DbSelectArea("AK3")
			DbSetOrder(1)
			If !DbSeek( cFilAnt + zCodigo + zVersao + PadR(AllTrim(zCodigo),12) )
				RecLock("AK3",.T.)
				AK3->AK3_FILIAL := cFilAnt
				AK3->AK3_ORCAME := zCodigo
				AK3->AK3_VERSAO := zVersao
				AK3->AK3_CO     := zCodigo
				AK3->AK3_PAI    := ""
				AK3->AK3_TIPO   := ""
				AK3->AK3_NIVEL  := "001"
				AK3->AK3_DESCRI := zDescri
				MsUnLock()
			Endif

			// Sintético Nível 1
			zCtaSin := PadR(Substr(zConta,1,1),12)
			DbSelectArea("AK5")
			DbSetOrder(1)
			If DbSeek( xFilial("AK5") + zCtaSin )
				DbSelectArea("AK3")
				DbSetOrder(1)
				If !DbSeek( cFilAnt + zCodigo + zVersao + zCtaSin )
					RecLock("AK3",.T.)
					AK3->AK3_FILIAL := cFilAnt
					AK3->AK3_ORCAME := zCodigo
					AK3->AK3_VERSAO := zVersao
					AK3->AK3_CO     := zCtaSin
					AK3->AK3_PAI    := zCodigo
					AK3->AK3_TIPO   := AK5->AK5_TIPO
					AK3->AK3_NIVEL  := "002"
					AK3->AK3_DESCRI := AK5->AK5_DESCRI
					MsUnLock()
				Endif
			Endif

			// Sintético Nível 2
			zCtaSin := PadR(Substr(zConta,1,2),12)
			DbSelectArea("AK5")
			DbSetOrder(1)
			If DbSeek( xFilial("AK5") + zCtaSin )
				DbSelectArea("AK3")
				DbSetOrder(1)
				If !DbSeek( cFilAnt + zCodigo + zVersao + zCtaSin )
					RecLock("AK3",.T.)
					AK3->AK3_FILIAL := cFilAnt
					AK3->AK3_ORCAME := zCodigo
					AK3->AK3_VERSAO := zVersao
					AK3->AK3_CO     := zCtaSin
					AK3->AK3_PAI    := AK5->AK5_COSUP
					AK3->AK3_TIPO   := AK5->AK5_TIPO
					AK3->AK3_NIVEL  := "003"
					AK3->AK3_DESCRI := AK5->AK5_DESCRI
					MsUnLock()
				Endif
			Endif

			// Sintético Nível 3
			zCtaSin := PadR(Substr(zConta,1,3),12)
			DbSelectArea("AK5")
			DbSetOrder(1)
			If DbSeek( xFilial("AK5") + zCtaSin )
				DbSelectArea("AK3")
				DbSetOrder(1)
				If !DbSeek( cFilAnt + zCodigo + zVersao + zCtaSin )
					RecLock("AK3",.T.)
					AK3->AK3_FILIAL := cFilAnt
					AK3->AK3_ORCAME := zCodigo
					AK3->AK3_VERSAO := zVersao
					AK3->AK3_CO     := zCtaSin
					AK3->AK3_PAI    := AK5->AK5_COSUP
					AK3->AK3_TIPO   := AK5->AK5_TIPO
					AK3->AK3_NIVEL  := "004"
					AK3->AK3_DESCRI := AK5->AK5_DESCRI
					MsUnLock()
				Endif
			Endif

			// Sintético Nível 4
			zCtaSin := PadR(Substr(zConta,1,5),12)
			DbSelectArea("AK5")
			DbSetOrder(1)
			If DbSeek( xFilial("AK5") + zCtaSin )
				DbSelectArea("AK3")
				DbSetOrder(1)
				If !DbSeek( cFilAnt + zCodigo + zVersao + zCtaSin )
					RecLock("AK3",.T.)
					AK3->AK3_FILIAL := cFilAnt
					AK3->AK3_ORCAME := zCodigo
					AK3->AK3_VERSAO := zVersao
					AK3->AK3_CO     := zCtaSin
					AK3->AK3_PAI    := AK5->AK5_COSUP
					AK3->AK3_TIPO   := AK5->AK5_TIPO
					AK3->AK3_NIVEL  := "005"
					AK3->AK3_DESCRI := AK5->AK5_DESCRI
					MsUnLock()
				Endif
			Endif

			// Conta Analítica
			DbSelectArea("AK5")
			DbSetOrder(1)
			If DbSeek( xFilial("AK5") + zConta )
				DbSelectArea("AK3")
				DbSetOrder(1)
				If !DbSeek( cFilAnt + zCodigo + zVersao + zConta )
					RecLock("AK3",.T.)
					AK3->AK3_FILIAL := cFilAnt
					AK3->AK3_ORCAME := zCodigo
					AK3->AK3_VERSAO := zVersao
					AK3->AK3_CO     := zConta
					AK3->AK3_PAI    := AK5->AK5_COSUP
					AK3->AK3_TIPO   := AK5->AK5_TIPO
					AK3->AK3_NIVEL  := "006"
					AK3->AK3_DESCRI := AK5->AK5_DESCRI
					MsUnLock()
				Endif
			Endif

		Next _x

	Endif
		
Enddo

MsgInfo("Importação concluída com sucesso !!"+cEOL+;
		"Execute o reprocessamento de lançamentos do processo 000252-01.")
			
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcDeb  ¦ Autor  ¦ Fabrica ERPBR   ¦ Data ¦ 26/03/2021	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da alteração no tipo de lançamento. 		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcDeb(cAnoPla)

Local nCountLin := 0
Local aFiliais  := {}
Local _x
Local _z

AAdd(aFiliais,"    ")

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(160)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando arquivo csv..")

	// Fim de Arquivo
	If Len(cString) < 3
		Exit
	Endif

	nPosic  := 0
	aLinha  := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT(";",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	// Estrutura de aLinha:
	// [01] - Conta Orçamentária
	// [02] - Valor Janeiro
	// [03] - Valor Fevereiro
	// [04] - Valor Março
	// [05] - Valor Abril
	// [06] - Valor Maio
	// [07] - Valor Junho
	// [08] - Valor Julho
	// [09] - Valor Agosto
	// [10] - Valor Setembro
	// [11] - Valor Outubro
	// [12] - Valor Novembro
	// [13] - Valor Dezembro

	If Len(aLinha) != 13
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 13 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zConta := PadR(aLinha[1],12)
		zPer01 := cAnoPla+"0101"
		zVlr01 := StrTran(aLinha[2],".","")
		zVlr01 := StrTran(zVlr01,",",".")
		zVlr01 := Val(zVlr01)
		zPer02 := cAnoPla+"0201"
		zVlr02 := StrTran(aLinha[3],".","")
		zVlr02 := StrTran(zVlr02,",",".")
		zVlr02 := Val(zVlr02)
		zPer03 := cAnoPla+"0301"
		zVlr03 := StrTran(aLinha[4],".","")
		zVlr03 := StrTran(zVlr03,",",".")
		zVlr03 := Val(zVlr03)
		zPer04 := cAnoPla+"0401"
		zVlr04 := StrTran(aLinha[5],".","")
		zVlr04 := StrTran(zVlr04,",",".")
		zVlr04 := Val(zVlr04)
		zPer05 := cAnoPla+"0501"
		zVlr05 := StrTran(aLinha[6],".","")
		zVlr05 := StrTran(zVlr05,",",".")
		zVlr05 := Val(zVlr05)
		zPer06 := cAnoPla+"0601"
		zVlr06 := StrTran(aLinha[7],".","")
		zVlr06 := StrTran(zVlr06,",",".")
		zVlr06 := Val(zVlr06)
		zPer07 := cAnoPla+"0701"
		zVlr07 := StrTran(aLinha[8],".","")
		zVlr07 := StrTran(zVlr07,",",".")
		zVlr07 := Val(zVlr07)
		zPer08 := cAnoPla+"0801"
		zVlr08 := StrTran(aLinha[9],".","")
		zVlr08 := StrTran(zVlr08,",",".")
		zVlr08 := Val(zVlr08)
		zPer09 := cAnoPla+"0901"
		zVlr09 := StrTran(aLinha[10],".","")
		zVlr09 := StrTran(zVlr09,",",".")
		zVlr09 := Val(zVlr09)
		zPer10 := cAnoPla+"1001"
		zVlr10 := StrTran(aLinha[11],".","")
		zVlr10 := StrTran(zVlr10,",",".")
		zVlr10 := Val(zVlr10)
		zPer11 := cAnoPla+"1101"
		zVlr11 := StrTran(aLinha[12],".","")
		zVlr11 := StrTran(zVlr11,",",".")
		zVlr11 := Val(zVlr11)
		zPer12 := cAnoPla+"1201"
		zVlr12 := StrTran(aLinha[13],".","")
		zVlr12 := StrTran(zVlr12,",",".")
		zVlr12 := Val(zVlr12)

		If Empty(zConta)
			Loop
		Endif

		If Substr(zConta,1,1) != "4"
			Loop
		Endif

		For _x := 1 to Len(aFiliais)

			cFilAnt := aFiliais[_x]
			zCodigo := PadR("GMD"+cAnoPla,15)
			zDescri := "GMD "+cAnoPla
			zVersao := u_UltVerPla(zCodigo)
			zCCusto := "101010101001"
			zItemCc := "BU9"
			zClasse := "000001"

			For _z := 1 to 12

				zSeq := StrZero(_z,2)
				zVal := &("zVlr"+zSeq)
				zPer := &("zPer"+zSeq)

				If zVal > 0

					// Lançamentos
					cQuery := " SELECT R_E_C_N_O_ RECAKD "
					cQuery += " FROM "+RetSqlName("AKD")
					cQuery += " WHERE AKD_FILIAL = '"+cFilAnt+"' "
					cQuery += " AND AKD_CODPLA = '"+zCodigo+"' "
					cQuery += " AND AKD_VERSAO = '"+zVersao+"' "
					cQuery += " AND AKD_CO = '"+zConta+"' "
					cQuery += " AND AKD_DATA = '"+zPer+"' "
					cQuery += " AND AKD_CC = '"+zCCusto+"' "
					cQuery += " AND AKD_ITCTB = '"+zItemCc+"' "
					cQuery += " AND AKD_CLASSE = '"+zClasse+"' "
					cQuery += " AND AKD_PROCES = '000252' "
					cQuery += " AND D_E_L_E_T_ <> '*' "
					DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLD", .F., .T.)
					SQLD->(DbGotop())
					If !Eof()
						DbSelectArea("AKD")
						AKD->(DbGoto(SQLD->RECAKD))
						RecLock("AKD",.F.)
						AKD->AKD_TIPO := "2" // 2=Débito | Orçamento de despesas
						MsUnLock()
					Endif
					SQLD->(DbCloseArea())

				Endif

			Next _z

		Next _x

	Endif
		
Enddo

MsgInfo("Atualização concluída com sucesso !!"+cEOL+;
		"Execute o reprocessamento dos cubos gerenciais.")
			
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _DataFim ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  22/03/19	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula data final do período.					 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function _DataFim(xPeriodo)

Local dRetorno := CtoD("01/"+Substr(xPeriodo,5,2)+"/"+Substr(xPeriodo,3,2))
Local cDia     := ""
Local cMes     := Substr(xPeriodo,5,2)
Local cAno     := Substr(xPeriodo,3,2)

If cMes == "01"
	cDia := "31"
ElseIf cMes == "02"
	_lBis := .T.
	_nAno  := Val(cAno)
	If _nAno % 4 != 0
		_lBis := .F.
	ElseIf _nAno % 4 != 100
		_lBis := .T.
	ElseIf _nAno % 4 != 400
		_lBis := .F.
	Else
		_lBis := .T.
	Endif		
	If _lBis
		cDia := "29"
	Else
		cDia := "28"
	Endif
ElseIf cMes == "03"
	cDia := "31"
ElseIf cMes == "04"
	cDia := "30"
ElseIf cMes == "05"
	cDia := "31"
ElseIf cMes == "06"
	cDia := "30"
ElseIf cMes == "07"
	cDia := "31"
ElseIf cMes == "08"
	cDia := "31"
ElseIf cMes == "09"
	cDia := "30"
ElseIf cMes == "10"
	cDia := "31"
ElseIf cMes == "11"
	cDia := "30"
ElseIf cMes == "12"
	cDia := "31"
Endif

dRetorno := CtoD(cDia+"/"+cMes+"/"+cAno)

Return(dRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  22/03/19	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua leitura do arquivo e retorna conteudo da linhaa.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fReadFile(nHandle,xFileSize,xBytesRead,nBytes)

Local nBytesRead := IIf(!((xBytesRead == 0) .Or. (xBytesRead == Nil)),xBytesRead,IIf(xFileSize < 1536,xFileSize,1536)) // Indica o numero de bytes a serem lidos
Local cBuffer    := Space(nBytesread) // Guarda o conteudo lido
Local nPosition  := 0 // Posicao do caracter 13 (return)
Local nIncbytes  := Nil // Incremento de bytes 2 CHR(13) + CHR(10)
Local xReturn    := Nil // Retorno da funcao

If ( ((FREAD(nHandle,@cBuffer,nBytesRead) = nBytesRead) .Or. (!Empty(cBuffer))) )
	// Verifica se procura o caracter 13 para identificar o registro
	xReturn := Substr(cBuffer,1,IIf(((nPosition := AT(CHR(13),cBuffer)) > 0),(nPosition - 1),Len(cBuffer)))
	// Verifica se incrementa bytes
	nIncBytes := IIf(nPosition > 0,2,0)
	// Bytes ja lidos somando os caracteres especiais
	nBytes := (nBytes + (Len(xReturn) + nIncBytes))
	// Retorna o descritor se necessario
	FSEEK(nHandle,(-1 * ABS((Len(cBuffer) - (Len(xReturn) + nIncBytes)))),1)
Endif

Return(xReturn)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  22/03/19	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Obtem o tamanho do arquivo texto.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UltVerPla ¦ Autor ¦ Fabrica ERPBR ¦ Data ¦ 26/01/2021	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia última versão da planilha orçamentária.	 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UltVerPla(zCodPla)

Local zVersao := "0001"

DbSelectArea("AK1")
DbSetOrder()
If DbSeek( xFilial("AK1") + zCodPla )
	While !Eof() .And. AK1->(AK1_FILIAL+AK1_CODIGO) == xFilial("AK1") + zCodPla
		zVersao := AK1->AK1_VERSAO
		AK1->(DbSkip())
	Enddo
Endif

Return(zVersao)
