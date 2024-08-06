#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNF005   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 05/02/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação de dados da provisão de 13o. salario através	  ¦¦¦
¦¦¦          ¦ de arquivo extensão csv com layout pré-definido.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNF005()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("AMNF05",10)
Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.F.)
Private cArquivo       := Space(30)
Private lOkFile        := .F.
Private cEOL           := CHR(13)+CHR(10)
Private nBytes         := 0
Private nHandle        := 0
Private cTable         := Nil
Private cTabl2         := Nil
Private oDlgUpd, oProcess, cArqCtb
Private oTempTabl1
Private oTempTabl2

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Importação de Dados | Contabilização da Provisão de 13o.Salário" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,084,{||"CONTABILIZAÇÃO DA PROVISÃO DE 13o.SALÁRIO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo fazer a importação de dados contábeis da provisão de 13o.salário"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"de acordo com arquivo extensão 'csv' e layout definido."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"O lote contábil e data dos lançamentos devem ser informados em 'Parâmetros'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"Os lançamentos contábeis serão gerados a partir da configuração do LP 'X82'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Parâmetros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  05/02/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

lLctPadX82 := VerPadrao("X82")
If !lLctPadX82
	Alert("Lançamento padrão 'X82' não cadastrado. Contate o Administrador.")
	Return
Endif

If Empty(mv_par01)
	MsgInfo("Atenção, Lote contábil não informado. Verifique os parâmetros.")
	Return
Else
	If Len(AllTrim(mv_par01)) != 6
		Alert("Atenção, O lote contábil deve ser informado com 6 caracteres (zeros à esquerda). Verifique os parâmetros.")
		Return
	Endif
Endif

If Empty(mv_par02)
	MsgInfo("Atenção, Data dos lançamentos não informada. Verifique os parâmetros.")
	Return
Endif

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
	
    If Select("TRB") > 0
    	TRB->(DbCloseArea())
    Endif

    If Select("LOG") > 0
    	LOG->(DbCloseArea())
    Endif

	_CriaTrab()
	
	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	If MsgYesNo("Confirma o processamento - PROVISÃO DE 13o.SALÁRIO ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importando lançamentos contábeis PROVISÃO DE 13o.SALÁRIO", "Aguarde, processando ...", .F. )
		oProcess:Activate()
		oDlgUpd:End()
	Endif

	fClose(nHandle)
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif	
	oTempTabl1:Delete()
	
	If Select("LOG") > 0
		LOG->(DbCloseArea())
	Endif	
	oTempTabl2:Delete()

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  05/02/17	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nCountLin := 0
Local xEmpOri := SM0->M0_CODIGO 
Local nRecSM0 := SM0->(Recno())
Local xFilOri := cFilAnt
Local aCgcFil := {}
Local _x

// Carrega CNPJ das Filiais cadastradas
DbSelectArea("SM0")
DbSetOrder(1)
DbSeek( xEmpOri )
While !Eof() .And. SM0->M0_CODIGO == xEmpOri
	AAdd(aCgcFil,{SM0->M0_CGC,AllTrim(SM0->M0_CODFIL),.F.})
	SM0->(DbSkip())
Enddo

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/140)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando dados no arquivo csv..")

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
	// [01] - Filial
	// [02] - Centro Resultado
	// [03] - Total 13o.
	// [04] - INSS 13o.
	// [05] - FGTS 13o.
	// [06] - Total 13o. - Conta Débito
	// [07] - Total 13o. - Conta Crédito
	// [08] - INSS 13o.  - Conta Débito
	// [09] - INSS 13o.  - Conta Crédito
	// [10] - FGTS 13o.  - Conta Débito
	// [11] - FGTS 13o.  - Conta Crédito

	If Len(aLinha) != 11
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 11 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := Upper(aLinha[1]) // Filial
		cCentro := PadR(StrTran(Substr(aLinha[2],1,17),".",""),12) // C.Custo
		n13Sala := StrTran(aLinha[3],".","") // Total 13o.
		n13Sala := ABS(Val(StrTran(n13Sala,",","."))) // Total 13o.
		nINSS   := StrTran(aLinha[4],".","") // Total INSS
		nINSS   := ABS(Val(StrTran(nINSS,",","."))) // Total INSS
		nFGTS   := StrTran(aLinha[5],".","") // Total FGTS
		nFGTS   := ABS(Val(StrTran(nFGTS,",","."))) // Total FGTS
		c13sDeb := aLinha[06] // 13o. - Conta Débito
		c13sCrd := aLinha[07] // 13o. - Conta Crédito
		cInsDeb := aLinha[08] // INSS - Conta Débito
		cInsCrd := aLinha[09] // INSS - Conta Crédito
		cFgtDeb := aLinha[10] // FGTS - Conta Débito
		cFgtCrd := aLinha[11] // FGTS - Conta Crédito
		lTudoOk := .T.

		If !Empty(cCentro) .And. n13Sala > 0 .And. nINSS > 0 .And. nFGTS > 0

			DbSelectArea("CTT")
			DbSetOrder(1)
			If !DbSeek( xFilial("CTT") + cCentro )
				InputLog(AllTrim(STR(nCountLin)),"Centro de Custo não cadastrado |"+AllTrim(cCentro)+"|.")
				lTudoOk := .F.
			Endif
	
			cCodFil := ""
			If zFilial == "INDAIATUBA"
				cCodFil := "0101"
			ElseIf zFilial == "CIDADE OCIDENTAL"
				cCodFil := "0102"
//			ElseIf zFilial == "DIMICRON RS"
//				cCodFil := "0103"
//			ElseIf zFilial == "DIMICRON MT"
//				cCodFil := "0104"
			ElseIf zFilial == "CRUZ ALTA"
				cCodFil := "0106"
			ElseIf zFilial == "CUIABA"
				cCodFil := "0107"
//			ElseIf zFilial == "DIMICRON CUIABA"
//				cCodFil := "0108"
			ElseIf zFilial == "CONCHAL"
				cCodFil := "0109"
			ElseIf zFilial == "CRUZ ALTA CIT"
				cCodFil := "0110"
			Endif
			If Empty(cCodFil)
				InputLog(AllTrim(STR(nCountLin)),"Filial não cadastrada |"+AllTrim(zFilial)+"|.")
				lTudoOk := .F.
			Else												
				nPosCgc := aScan(aCgcFil, {|x| AllTrim(x[2]) == cCodFil})
				If nPosCgc == 0
					InputLog(AllTrim(STR(nCountLin)),"Filial não cadastrada |"+AllTrim(cCodFil)+"|.")
					lTudoOk := .F.
				Else
					aCgcFil[nPosCgc][3] := .T.
				Endif
			Endif	

			If lTudoOk
				InputLin(cCodFil,c13sDeb,c13sCrd,n13Sala,cInsDeb,cInsCrd,nINSS,cFgtDeb,cFgtCrd,nFGTS,cCentro)
			Endif

		Endif

	Endif
		
Enddo

DbSelectArea("LOG")
If LOG->(RecCount()) > 0
	MsgInfo("Foram encontradas inconsistências no arquivo 'csv'.")
	u_Rep005(cArquivo)
	Return
Endif

lLancOk := .T.
For _x := 1 to Len(aCgcFil)
	If aCgcFil[_x][3]
		lDuplic := _VerLctoCtb(aCgcFil[_x][2],mv_par01,mv_par02)
		If lDuplic
			MsgInfo("Atenção, Foram encontrados lançamentos contábeis:"+cEOL+"Filial "+aCgcFil[_x][2]+" | Lote "+mv_par01+" | Data "+DtoC(mv_par02)+".")
			lLancOk := .F.
		Endif
	Endif	
Next _x
If !lLancOk
	Return
Endif

Begin Transaction

// Geração dos Lançamentos Contábeis
DbSelectArea("TRB")
TRB->(DbGotop())
If !Eof()

	xFilAnt := ""
	lFiliOk := .F.
	oProcess:SetRegua2( TRB->(RecCount()) )

	DbSelectArea("TRB")
	TRB->(DbGotop())
	While !Eof()

		oProcess:IncRegua2("Gerando lançamentos contábeis..")

		If TRB->TF_CODFIL != xFilAnt
		
			If lFiliOk
			
				// Totaliza Filial
				If _nTotLan > 0
					RodaProva(_nHdlPrv,_nTotLan)
					cA100Incl(cArqCtb,_nHdlPrv,3,mv_par01,.T./*(__cUserid=="000000")*/,.F.,,mv_par02)
					//cMensagem := "Lançamentos contábeis gerados com sucesso | Filial "+cFilAnt+" | Lote "+mv_par01+" | Data "+DtoC(mv_par02)+" | "
					//MsgInfo(cMensagem)
				Endif
				
			Else
			
				lFiliOk := .T.
			
			Endif

			// Inicializa Filial
			xFilAnt := TRB->TF_CODFIL
			cFilAnt := TRB->TF_CODFIL

			_nHdlPrv := HeadProva(mv_par01,"AMNF005",__cUserId,@cArqCtb)
			_nTotLan := 0
		
		Endif
		
		// Lançamentos Filial - Total 13o.Salário
		CCTADEB := TRB->TF_13SDEB
		CCTACRD := TRB->TF_13SCRD
		CCCDEB  := TRB->TF_CC
		CCCCRD  := TRB->TF_CC
		CBUDEB  := TRB->TF_BU
		CBUCRD  := TRB->TF_BU
		CHISTOR := "PROV.13o.SAL. "+Substr(DtoS(mv_par02),5,2)+"/"+Substr(DtoS(mv_par02),1,4)
		NVLRLAN := TRB->TF_13SVLR
		_nTotLan += DetProva(_nHdlPrv,"X82","AMNF005",mv_par01)

		// Lançamentos Filial - Total INSS
		CCTADEB := TRB->TF_INSDEB
		CCTACRD := TRB->TF_INSCRD
		CCCDEB  := TRB->TF_CC
		CCCCRD  := TRB->TF_CC
		CBUDEB  := TRB->TF_BU
		CBUCRD  := TRB->TF_BU
		CHISTOR := "PROV.INSS 13o.SAL. "+Substr(DtoS(mv_par02),5,2)+"/"+Substr(DtoS(mv_par02),1,4)
		NVLRLAN := TRB->TF_INSVLR
		_nTotLan += DetProva(_nHdlPrv,"X82","AMNF005",mv_par01)

		// Lançamentos Filial - Total FGTS
		CCTADEB := TRB->TF_FGTDEB
		CCTACRD := TRB->TF_FGTCRD
		CCCDEB  := TRB->TF_CC
		CCCCRD  := TRB->TF_CC
		CBUDEB  := TRB->TF_BU
		CBUCRD  := TRB->TF_BU
		CHISTOR := "PROV.FGTS 13o.SAL. "+Substr(DtoS(mv_par02),5,2)+"/"+Substr(DtoS(mv_par02),1,4)
		NVLRLAN := TRB->TF_FGTVLR
		_nTotLan += DetProva(_nHdlPrv,"X82","AMNF005",mv_par01)
	
		DbSelectArea("TRB")
		TRB->(DbSkip())
		
		If Eof()

			// Totaliza Filial
			If _nTotLan > 0
				RodaProva(_nHdlPrv,_nTotLan)
				cA100Incl(cArqCtb,_nHdlPrv,3,mv_par01,.T./*(__cUserid=="000000")*/,.F.,,mv_par02)
				//cMensagem := "Lançamentos contábeis gerados com sucesso | Filial "+cFilAnt+" | Lote "+mv_par01+" | Data "+DtoC(mv_par02)+" | "
				//MsgInfo(cMensagem)
			Endif

		Endif

		DbSelectArea("TRB")
	Enddo	

Endif

End Transaction
MsUnLockAll()

u_Rep005(cArquivo)

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _VerLctoCtb ¦ Autor ¦ Fábrica ERPBR  ¦    Data  ¦ 05/02/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia duplicidade antes da geração dos lançamentos.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _VerLctoCtb(cCodFil,cLotLan,dDatLan)

Local aArea := GetArea()
Local lRetorno := .F. // Retorno Ok = Não existe lançamento.

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("CT2")
cQuery += " WHERE CT2_FILIAL = '"+cCodFil+"' "
cQuery += " AND CT2_LOTE = '"+cLotLan+"' "
cQuery += " AND CT2_DATA = '"+DtoS(dDatLan)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TCT2", .F., .T.)
TCT2->(DbGotop())
lRetorno := (TCT2->SOMA > 0) // .T. = Existem lançamentos.
TCT2->(DbCloseArea())

RestArea(aArea)

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _CriaTrab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 05/02/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _CriaTrab()

Local _aTmp   := {}
Local _aTm2   := {}
Local zAlias1 := "LOG"
Local zAlias2 := "TRB"

oTempTabl1 := FWTemporaryTable():New( zAlias1 )
AAdd ( _aTmp, {"LOG_LINLOG" , "C", 004, 00} )
AAdd ( _aTmp, {"LOG_LINARQ" , "C", 004, 00} )
AAdd ( _aTmp, {"LOG_OBSERV" , "C", 200, 00} )
oTemptabl1:SetFields( _aTmp )
oTempTabl1:AddIndex("indice1", {"LOG_LINLOG"})
oTempTabl1:Create()

oTempTabl2 := FWTemporaryTable():New( zAlias2 )
AAdd ( _aTm2, {"TF_CODFIL" , "C", 004, 00} )
AAdd ( _aTm2, {"TF_CC"     , "C", 012, 00} )
AAdd ( _aTm2, {"TF_BU"     , "C", 012, 00} )
AAdd ( _aTm2, {"TF_13SDEB" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_13SCRD" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_13SVLR" , "N", 014, 02} )
AAdd ( _aTm2, {"TF_INSDEB" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_INSCRD" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_INSVLR" , "N", 014, 02} )
AAdd ( _aTm2, {"TF_FGTDEB" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_FGTCRD" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_FGTVLR" , "N", 014, 02} )
oTemptabl2:SetFields( _aTm2 )
oTempTabl2:AddIndex("indice1", {"TF_CODFIL", "TF_CC"})
oTempTabl2:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ InputLog  ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 05/02/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Insere registro invalido.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function InputLog(xLinArq,xObserv)

cLinLog := StrZero((LOG->(RecCount())+1),4)

RecLock("LOG",.T.)
LOG->LOG_LINLOG := cLinLog
LOG->LOG_LINARQ := xLinArq
LOG->LOG_OBSERV := xObserv
MsUnLock()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ InputLin  ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 05/02/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Insere registro valido.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function InputLin(cCodFil,c13sDeb,c13sCrd,n13Sala,cInsDeb,cInsCrd,nINSS,cFgtDeb,cFgtCrd,nFGTS,cCentro)

DbSelectArea("TRB")
DbSetOrder(1)
If !DbSeek( cCodFil + cCentro )
	RecLock("TRB",.T.)
	TRB->TF_CODFIL := cCodFil
	TRB->TF_CC     := cCentro
	TRB->TF_BU     := Posicione("CTT",1,xFilial("CTT") + cCentro,"CTT_ZZITCT")
	TRB->TF_13SDEB := c13sDeb
	TRB->TF_13SCRD := c13sCrd
	TRB->TF_INSDEB := cInsDeb
	TRB->TF_INSCRD := cInsCrd
	TRB->TF_FGTDEB := cFgtDeb
	TRB->TF_FGTCRD := cFgtCrd
Else
	RecLock("TRB",.F.)	
Endif
TRB->TF_13SVLR += n13Sala
TRB->TF_INSVLR += nINSS
TRB->TF_FGTVLR += nFGTS
MsUnLock()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  05/02/17	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua a leitura do arquivo txt e retorna a linha lida.	  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  05/02/17	  ¦¦¦
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
¦¦¦Programa  ¦ Rep005  ¦ Autor ¦ Fábrica ERPBR   ¦   Data  ¦ 	05/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do log de ocorrências.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function Rep005(cArquivo)

Local oReport

oReport := ReportDef(cArquivo)

If oReport == Nil
	Return
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ReportDef ¦ Autor ¦  Luis Brandini   ¦   Data  ¦ 05/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa impressao do relatorio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReportDef(cArquivo)

Local oReport
Local oSection1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("AMNF005","Ocorrências do Arquivo CSV", , {|oReport| ReportPrint(oReport,cArquivo), "Este relatório irá imprimir as ocorrências da importação do arquivo CSV de dados da provisão de 13o.salário"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,"Ocorrências do Arquivo CSV",{"LOG"},,.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1, "LINLOG", "LOG", "Seq."       , "@!" , 010, , { || LOG->LOG_LINLOG } )
TRCell():New(oSection1, "LINARQ", "LOG", "No.Linha"   , "@!" , 010, , { || LOG->LOG_LINARQ } )
TRCell():New(oSection1, "OBSERV", "LOG", "Ocorrência" , "@!" , 200, , { || LOG->LOG_OBSERV } )

Return(oReport)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ReportPrint ¦ Autor ¦ Luis Brandini  ¦   Data  ¦ 05/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa impressao do relatorio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReportPrint(oReport,cArquivo)

Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Log de ocorrências da importação csv | Provisão de 13o.Salário | Arquivo "+cArquivo+"|"
oReport:cTitle := "Log de ocorrências da importação csv | Provisão de 13o.Salário | Arquivo "+cArquivo+"|"

DbSelectArea("LOG")
LOG->(DbGotop())
If Eof()
	RecLock("LOG",.T.)
	LOG->LOG_LINLOG := "0001"
	LOG->LOG_LINARQ := ""
	LOG->LOG_OBSERV := "Arquivo "+cArquivo+" importado com sucesso, sem ocorrência de erros."
	MsUnLock()
Endif

DbSelectArea("LOG")
LOG->(DbGotop())
oReport:SetMeter(LOG->(RecCount()))
oSection1:Init()
While !Eof()

	oReport:IncMeter()

	oSection1:PrintLine()

	DbSelectArea("LOG")
	LOG->(DbSkip())

	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif

	DbSelectArea("LOG")
Enddo

Return
