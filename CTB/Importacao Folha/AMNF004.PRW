#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNF004   � Autor �  F�brica ERP.BR   �   Data  � 05/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Importa��o de dados da provis�o de f�rias atrav�s   		  ���
���          � de arquivo extens�o csv com layout pr�-definido.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNF004()

Local lOk   := .F.
Local lEnd	:= .F.
Local cPerg	:= Padr("AMNF04",10)
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

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Importa��o de Dados | Contabiliza��o da Provis�o de F�rias" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,086,{||"CONTABILIZA��O DA PROVIS�O DE F�RIAS"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo fazer a importa��o de dados cont�beis da provis�o de f�rias"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"de acordo com arquivo extens�o 'csv' e layout definido."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"O lote cont�bil e data dos lan�amentos devem ser informados em 'Par�metros'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"Os lan�amentos cont�beis ser�o gerados a partir da configura��o do LP 'X81'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Par�metros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � Preparar  � Autor � Fabrica ERPBR    � Data �  05/02/17	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Prepara o processamento principal.						  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Preparar()

lLctPadX81 := VerPadrao("X81")
If !lLctPadX81
	Alert("Lan�amento padr�o 'X81' n�o cadastrado. Contate o Administrador.")
	Return
Endif

If Empty(mv_par01)
	MsgInfo("Aten��o, Lote cont�bil n�o informado. Verifique os par�metros.")
	Return
Else
	If Len(AllTrim(mv_par01)) != 6
		Alert("Aten��o, O lote cont�bil deve ser informado com 6 caracteres (zeros � esquerda). Verifique os par�metros.")
		Return
	Endif
Endif

If Empty(mv_par02)
	MsgInfo("Aten��o, Data dos lan�amentos n�o informada. Verifique os par�metros.")
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
		MsgAlert("Arquivo n�o encontrado.")
	Endif
Else
	MsgAlert("Arquivo n�o selecionado.")
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

	If MsgYesNo("Confirma o processamento - PROVIS�O DE F�RIAS ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importando lan�amentos cont�beis PROVIS�O DE F�RIAS", "Aguarde, processando ...", .F. )
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data �  05/02/17	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da importa��o.								  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	// [03] - Total F�rias
	// [04] - INSS F�rias
	// [05] - FGTS F�rias
	// [06] - Total F�rias - Conta D�bito
	// [07] - Total F�rias - Conta Cr�dito
	// [08] - INSS F�rias - Conta D�bito
	// [09] - INSS F�rias - Conta Cr�dito
	// [10] - FGTS F�rias - Conta D�bito
	// [11] - FGTS F�rias - Conta Cr�dito

	If Len(aLinha) != 11
		MsgInfo("Aten��o..., Estrutura do arquivo CSV inv�lida ("+AllTrim(STR(Len(aLinha)))+" posi��es)."+cEOL+"O layout deve conter 11 posi��es.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := Upper(aLinha[1]) // Filial
		cCentro := PadR(StrTran(Substr(aLinha[2],1,17),".",""),12) // C.Custo
		nFerias := StrTran(aLinha[3],".","") // Total F�rias
		nFerias := ABS(Val(StrTran(nFerias,",","."))) // Total F�rias
		nINSS   := StrTran(aLinha[4],".","") // Total INSS
		nINSS   := ABS(Val(StrTran(nINSS,",","."))) // Total INSS
		nFGTS   := StrTran(aLinha[5],".","") // Total FGTS
		nFGTS   := ABS(Val(StrTran(nFGTS,",","."))) // Total FGTS
		cFerDeb := aLinha[06] // F�rias - Conta D�bito
		cFerCrd := aLinha[07] // F�rias - Conta Cr�dito
		cInsDeb := aLinha[08] // INSS - Conta D�bito
		cInsCrd := aLinha[09] // INSS - Conta Cr�dito
		cFgtDeb := aLinha[10] // FGTS - Conta D�bito
		cFgtCrd := aLinha[11] // FGTS - Conta Cr�dito
		lTudoOk := .T.

		If !Empty(cCentro) .And. nFerias > 0 .And. nINSS > 0 .And. nFGTS > 0

			DbSelectArea("CTT")
			DbSetOrder(1)
			If !DbSeek( xFilial("CTT") + cCentro )
				InputLog(AllTrim(STR(nCountLin)),"Centro de Custo n�o cadastrado |"+AllTrim(cCentro)+"|.")
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
				InputLog(AllTrim(STR(nCountLin)),"Filial n�o cadastrada |"+AllTrim(zFilial)+"|.")
				lTudoOk := .F.
			Else												
				nPosCgc := aScan(aCgcFil, {|x| AllTrim(x[2]) == cCodFil})
				If nPosCgc == 0
					InputLog(AllTrim(STR(nCountLin)),"Filial n�o cadastrada |"+AllTrim(cCodFil)+"|.")
					lTudoOk := .F.
				Else
					aCgcFil[nPosCgc][3] := .T.
				Endif
			Endif	

			If lTudoOk
				InputLin(cCodFil,cFerDeb,cFerCrd,nFerias,cInsDeb,cInsCrd,nINSS,cFgtDeb,cFgtCrd,nFGTS,cCentro)
			Endif

		Endif

	Endif
		
Enddo

DbSelectArea("LOG")
If LOG->(RecCount()) > 0
	MsgInfo("Foram encontradas inconsist�ncias no arquivo 'csv'.")
	u_Rep004(cArquivo)
	Return
Endif

lLancOk := .T.
For _x := 1 to Len(aCgcFil)
	If aCgcFil[_x][3]
		lDuplic := _VerLctoCtb(aCgcFil[_x][2],mv_par01,mv_par02)
		If lDuplic
			MsgInfo("Aten��o, Foram encontrados lan�amentos cont�beis:"+cEOL+"Filial "+aCgcFil[_x][2]+" | Lote "+mv_par01+" | Data "+DtoC(mv_par02)+".")
			lLancOk := .F.
		Endif
	Endif	
Next _x
If !lLancOk
	Return
Endif

Begin Transaction

// Gera��o dos Lan�amentos Cont�beis
DbSelectArea("TRB")
TRB->(DbGotop())
If !Eof()

	xFilAnt := ""
	lFiliOk := .F.
	oProcess:SetRegua2( TRB->(RecCount()) )

	DbSelectArea("TRB")
	TRB->(DbGotop())
	While !Eof()

		oProcess:IncRegua2("Gerando lan�amentos cont�beis..")

		If TRB->TF_CODFIL != xFilAnt
		
			If lFiliOk
			
				// Totaliza Filial
				If _nTotLan > 0
					RodaProva(_nHdlPrv,_nTotLan)
					cA100Incl(cArqCtb,_nHdlPrv,3,mv_par01,.T./*(__cUserid=="000000")*/,.F.,,mv_par02)
					//cMensagem := "Lan�amentos cont�beis gerados com sucesso | Filial "+cFilAnt+" | Lote "+mv_par01+" | Data "+DtoC(mv_par02)+" | "
					//MsgInfo(cMensagem)
				Endif
				
			Else
			
				lFiliOk := .T.
			
			Endif

			// Inicializa Filial
			xFilAnt := TRB->TF_CODFIL
			cFilAnt := TRB->TF_CODFIL

			_nHdlPrv := HeadProva(mv_par01,"AMNF004",__cUserId,@cArqCtb)
			_nTotLan := 0
		
		Endif
		
		// Lan�amentos Filial - Total F�rias
		CCTADEB := TRB->TF_FERDEB
		CCTACRD := TRB->TF_FERCRD
		CCCDEB  := TRB->TF_CC
		CCCCRD  := TRB->TF_CC
		CBUDEB  := TRB->TF_BU
		CBUCRD  := TRB->TF_BU
		CHISTOR := "PROV.FERIAS "+Substr(DtoS(mv_par02),5,2)+"/"+Substr(DtoS(mv_par02),1,4)
		NVLRLAN := TRB->TF_FERVLR
		_nTotLan += DetProva(_nHdlPrv,"X81","AMNF004",mv_par01)

		// Lan�amentos Filial - Total INSS
		CCTADEB := TRB->TF_INSDEB
		CCTACRD := TRB->TF_INSCRD
		CCCDEB  := TRB->TF_CC
		CCCCRD  := TRB->TF_CC
		CBUDEB  := TRB->TF_BU
		CBUCRD  := TRB->TF_BU
		CHISTOR := "PROV.INSS FERIAS "+Substr(DtoS(mv_par02),5,2)+"/"+Substr(DtoS(mv_par02),1,4)
		NVLRLAN := TRB->TF_INSVLR
		_nTotLan += DetProva(_nHdlPrv,"X81","AMNF004",mv_par01)

		// Lan�amentos Filial - Total FGTS
		CCTADEB := TRB->TF_FGTDEB
		CCTACRD := TRB->TF_FGTCRD
		CCCDEB  := TRB->TF_CC
		CCCCRD  := TRB->TF_CC
		CBUDEB  := TRB->TF_BU
		CBUCRD  := TRB->TF_BU
		CHISTOR := "PROV.FGTS FERIAS "+Substr(DtoS(mv_par02),5,2)+"/"+Substr(DtoS(mv_par02),1,4)
		NVLRLAN := TRB->TF_FGTVLR
		_nTotLan += DetProva(_nHdlPrv,"X81","AMNF004",mv_par01)
	
		DbSelectArea("TRB")
		TRB->(DbSkip())
		
		If Eof()

			// Totaliza Filial
			If _nTotLan > 0
				RodaProva(_nHdlPrv,_nTotLan)
				cA100Incl(cArqCtb,_nHdlPrv,3,mv_par01,.T./*(__cUserid=="000000")*/,.F.,,mv_par02)
				//cMensagem := "Lan�amentos cont�beis gerados com sucesso | Filial "+cFilAnt+" | Lote "+mv_par01+" | Data "+DtoC(mv_par02)+" | "
				//MsgInfo(cMensagem)
			Endif

		Endif

		DbSelectArea("TRB")
	Enddo	

Endif

End Transaction
MsUnLockAll()

u_Rep004(cArquivo)

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � _VerLctoCtb � Autor � F�brica ERPBR  �    Data  � 05/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Avalia duplicidade antes da gera��o dos lan�amentos.		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function _VerLctoCtb(cCodFil,cLotLan,dDatLan)

Local aArea := GetArea()
Local lRetorno := .F. // Retorno Ok = N�o existe lan�amento.

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("CT2")
cQuery += " WHERE CT2_FILIAL = '"+cCodFil+"' "
cQuery += " AND CT2_LOTE = '"+cLotLan+"' "
cQuery += " AND CT2_DATA = '"+DtoS(dDatLan)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TCT2", .F., .T.)
TCT2->(DbGotop())
lRetorno := (TCT2->SOMA > 0) // .T. = Existem lan�amentos.
TCT2->(DbCloseArea())

RestArea(aArea)

Return(lRetorno)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � _CriaTrab � Autor � F�brica ERPBR    �    Data  � 05/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Cria arquivos temporarios.							   	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
AAdd ( _aTm2, {"TF_FERDEB" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_FERCRD" , "C", 020, 00} )
AAdd ( _aTm2, {"TF_FERVLR" , "N", 014, 02} )
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � InputLog  � Autor � F�brica ERPBR    �    Data  � 05/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Insere registro invalido.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � InputLin  � Autor � F�brica ERPBR    �    Data  � 05/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Insere registro valido.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function InputLin(cCodFil,cFerDeb,cFerCrd,nFerias,cInsDeb,cInsCrd,nINSS,cFgtDeb,cFgtCrd,nFGTS,cCentro)

DbSelectArea("TRB")
DbSetOrder(1)
If !DbSeek( cCodFil + cCentro )
	RecLock("TRB",.T.)
	TRB->TF_CODFIL := cCodFil
	TRB->TF_CC     := cCentro
	TRB->TF_BU     := Posicione("CTT",1,xFilial("CTT") + cCentro,"CTT_ZZITCT")
	TRB->TF_FERDEB := cFerDeb
	TRB->TF_FERCRD := cFerCrd
	TRB->TF_INSDEB := cInsDeb
	TRB->TF_INSCRD := cInsCrd
	TRB->TF_FGTDEB := cFgtDeb
	TRB->TF_FGTCRD := cFgtCrd
Else
	RecLock("TRB",.F.)	
Endif
TRB->TF_FERVLR += nFerias
TRB->TF_INSVLR += nINSS
TRB->TF_FGTVLR += nFGTS
MsUnLock()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fReadFile � Autor � Fabrica ERPBR � 	  Data �  05/02/17	  ���
��+----------+------------------------------------------------------------���
���Descricao � Efetua a leitura do arquivo txt e retorna a linha lida.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fFileSize � Autor � Fabrica ERPBR � 	  Data �  05/02/17	  ���
��+----------+------------------------------------------------------------���
���Descricao � Obtem o tamanho do arquivo texto.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � Rep004  � Autor � F�brica ERPBR   �   Data  � 	05/02/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Impress�o do log de ocorr�ncias.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function Rep004(cArquivo)

Local oReport

oReport := ReportDef(cArquivo)

If oReport == Nil
	Return
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportDef � Autor �  Luis Brandini   �   Data  � 05/02/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef(cArquivo)

Local oReport
Local oSection1

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("AMNF004","Ocorr�ncias do Arquivo CSV", , {|oReport| ReportPrint(oReport,cArquivo), "Este relat�rio ir� imprimir as ocorr�ncias da importa��o do arquivo CSV de dados da provis�o de f�rias"})

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1 := TRSection():New(oReport,"Ocorr�ncias do Arquivo CSV",{"LOG"},,.F.,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oSection1, "LINLOG", "LOG", "Seq."       , "@!" , 010, , { || LOG->LOG_LINLOG } )
TRCell():New(oSection1, "LINARQ", "LOG", "No.Linha"   , "@!" , 010, , { || LOG->LOG_LINARQ } )
TRCell():New(oSection1, "OBSERV", "LOG", "Ocorr�ncia" , "@!" , 200, , { || LOG->LOG_OBSERV } )

Return(oReport)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportPrint � Autor � Luis Brandini  �   Data  � 05/02/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportPrint(oReport,cArquivo)

Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Log de ocorr�ncias da importa��o csv | Provis�o de F�rias | Arquivo "+cArquivo+"|"
oReport:cTitle := "Log de ocorr�ncias da importa��o csv | Provis�o de F�rias | Arquivo "+cArquivo+"|"

DbSelectArea("LOG")
LOG->(DbGotop())
If Eof()
	RecLock("LOG",.T.)
	LOG->LOG_LINLOG := "0001"
	LOG->LOG_LINARQ := ""
	LOG->LOG_OBSERV := "Arquivo "+cArquivo+" importado com sucesso, sem ocorr�ncia de erros."
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
