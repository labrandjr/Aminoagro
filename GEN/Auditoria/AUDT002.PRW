#include "protheus.ch"
#Include "topconn.ch"
#include "msobject.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AUDT002   ¦ Autor ¦  Fábrica ERP.BR   ¦ Data ¦ 27/08/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Execução da carga de dados.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AUDT002()

Local oFnt1 := TFont():New("Tahoma",,18,,.T.)
Local oFnt2 := TFont():New("Tahoma",,15,,.T.)
Local oFnt3 := TFont():New("Tahoma",,14,,.T.)
Local oFnt4 := TFont():New("Tahoma",,16,,.T.)
Local bOkRat  := {|| nOpcRat:=1,oDlgDwn:End() }
Local bCanRat := {|| nOpcRat:=0,oDlgDwn:End() }
Private aLibAud := {}
Private cArqCsv := Space(200)
Private lOkFile := .F.
Private cEOL    := CHR(13)+CHR(10)
Private oDlgUpd, oProcess, oSayArq

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("ZZL")
cQuery += " WHERE ZZL_FILIAL = '"+xFilial("ZZL")+"' "
cQuery += " AND ZZL_USER = '"+__cUserId+"' "
cQuery += " AND ZZL_DATA = '"+DtoS(Date())+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TZZL", .F., .T.)
TZZL->(DbGotop())
While !Eof()
	AAdd(aLibAud,AllTrim(TZZL->ZZL_ALIAS)+"-"+AllTrim(TZZL->ZZL_DESCRI))
	TZZL->(DbSkip())
Enddo
TZZL->(DbCloseArea())

zAliasLib := ""
If Len(aLibAud) == 1
	zAliasLib := aLibAud[1]
Else
	DEFINE MSDIALOG oDlgDwn TITLE "Selecione a Tabela" FROM 180,180 TO 450,700 PIXEL
	nRadio := 1
	oRadio := TRadMenu():New(35,15,aLibAud,,oDlgDwn,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|IIf(PCount()==0,nRadio,nRadio:=u)}
	ACTIVATE DIALOG oDlgDwn ON INIT EnchoiceBar(oDlgDwn,bOkRat,bCanRat) CENTERED
	zAliasLib := Substr(aLibAud[nRadio],1,3)
Endif

DbSelectArea("ZZL")
DbSetOrder(1)
If !DbSeek( xFilial("ZZL") + __cUserId + DtoS(Date()) + zAliasLib )
	MsgAlert("Liberação não cadastrada para o usuário "+AllTrim(cUserName)+" em "+DtoC(Date()))
	Return
Endif

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Auditoria de Dados - Execução" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,085,{||"CARGA DE DADOS COM ARQUIVO DE APOIO"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,125,{||"< Liberação Cadastrada >"},oDlgUpd,,oFnt4,,,,.T.,CLR_RED,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(070,010,{||"Usuário: "+AllTrim(ZZL->ZZL_NOME)    },oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(080,010,{||"Data: "+DtoC(ZZL->ZZL_DATA)},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(090,010,{||"Tabela: "+ZZL->ZZL_ALIAS+" - "+AllTrim(ZZL->ZZL_DESCRI)},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 120,010 BUTTON "Arquivo" SIZE 042,011 FONT oDlgUpd:oFont ACTION SelecArq() OF oDlgUpd PIXEL

@ 119,060 TO 131,310 LABEL "" OF oDlgUpd PIXEL
oSayArq:= TSay():New(122,063,{||""},oDlgUpd,,oFnt3,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayArq:SetText( AllTrim(cArqCsv) )
oSayArq:CtrlRefresh()

@ 150,200 BUTTON "Executar" SIZE 050,011 FONT oDlgUpd:oFont ACTION Preparar()    OF oDlgUpd PIXEL
@ 150,270 BUTTON "Sair"     SIZE 050,011 FONT oDlgUpd:oFont ACTION oDlgUpd:End() OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ SelecArq  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 27/08/2021   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Seleciona o arquivo csv.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function SelecArq()

cArqCsv := cGetFile("Arquivos CSV|*.CSV|",OemToAnsi("Selecione o arquivo"))
cArqCsv := AllTrim(cArqCsv)

oSayArq:SetText( AllTrim(cArqCsv) )
oSayArq:CtrlRefresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 27/08/2021   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

Private nBytes  := 0
Private nHandle := 0

If Empty(cArqCsv)
	MsgAlert("Informe o arquivo csv para processamento.")
	Return
Endif

If !File(cArqCsv)
	MsgAlert("Arquivo não encontrado.")
	Return
Endif

nHandle := fOpen(cArqCsv,2)

If nHandle == -1
	MsgAlert("Problema na abertura do arquivo "+cArqCsv+".")
	Return
Endif

If MsgYesNo("Confirma a execução ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Atualizando dados", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

fClose(nHandle)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ 27/08/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local aChvLib := {}
Local aChvCsv := {}
Local aCpoCsv := {}
Local aDadCsv := {}
Local lChavOk := .T.
Local lCposOk := .T.
Local cCpoNao := ""
Local _aTmp   := {}
Local _x

// Chave liberada
nTamArq := 1
oProcess:SetRegua1(nTamArq)
While ( !Empty((cString := AllTrim(ZZL->ZZL_CHAVE) )) )
	
	oProcess:IncRegua1("Validando chave liberada")

	nPosic  := 0
	aChvLib := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT("+",cTxtLin)) > 0))
			AAdd(aChvLib,AllTrim(Substr(cTxtLin,1,nPosic-1)))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aChvLib,AllTrim(Substr(cTxtLin,1,Len(AllTrim(cTxtLin)))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo
	Exit

Enddo

// Chave no Csv
nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	oProcess:IncRegua1("Validando chave csv")

	nPosic  := 0
	aChvCsv := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT(";",cTxtLin)) > 0))
			AAdd(aChvCsv,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aChvCsv,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
		If Len(aChvCsv) == Len(aChvLib)
			Exit
		Endif
	Enddo
	Exit

Enddo

If Len(aChvLib) <> Len(aChvCsv)
	MsgAlert("Arquivo csv possui chave com tamanho diferente da liberada.")
	Return
Else
	For _x := 1 to Len(aChvLib)
		If (aChvCsv[_x] <> aChvLib[_x]) .Or. (aChvLib[_x] <> aChvCsv[_x] .Or. (Len(aChvLib) <> Len(aChvCsv)) )
			lChavOk := .F.
			Exit
		Endif
	Next _x
Endif
If !lChavOk
	MsgAlert("Arquivo csv possui chave imcompatível com a liberada.")
	Return
Endif

// Campos no Csv
nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	oProcess:IncRegua1("Validando campos csv")

	nPosic  := 0
	aCpoCsv := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT(";",cTxtLin)) > 0))
			cCpo := Substr(cTxtLin,1,nPosic-1)
			If aScan(aChvCsv, {|x| x == cCpo }) == 0			
				AAdd(aCpoCsv,cCpo)
			Endif	
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			cCpo := Substr(cTxtLin,1,Len(AllTrim(cTxtLin)))
			If aScan(aChvCsv, {|x| x == cCpo }) == 0			
				AAdd(aCpoCsv,cCpo)
			Endif	
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo
	Exit

Enddo
If Len(aCpoCsv) == 0
	MsgAlert("Campos para atualização não informados no arquivo csv.")
Else
	For _x := 1 to Len(aCpoCsv)
		If !(aCpoCsv[_x] $(AllTrim(ZZL->ZZL_CAMPOS)))
			lCposOk := .F.
			cCpoNao += IIf(!Empty(cCpoNao),", ","") + aCpoCsv[_x]
		Endif
	Next _x
Endif
If !lCposOk
	MsgAlert("Arquivo csv possui campos não liberados para atualização: "+cCpoNao)
	Return
Endif

oTempTable := FWTemporaryTable():New("LOG")
AAdd ( _aTmp, {"LOG_REG" , "C", 030, 00} )
AAdd ( _aTmp, {"LOG_CPO" , "C", 010, 00} )
AAdd ( _aTmp, {"LOG_TIT" , "C", 012, 00} )
AAdd ( _aTmp, {"LOG_OLD" , "C", 040, 00} )
AAdd ( _aTmp, {"LOG_NEW" , "C", 040, 00} )
AAdd ( _aTmp, {"LOG_UPD" , "C", 001, 00} )
AAdd ( _aTmp, {"LOG_OBS" , "C", 030, 00} )
oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"LOG_REG", "LOG_CPO"})
oTempTable:Create()

// Dados para atualização
nCountL := 0
nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountL += 1
	oProcess:IncRegua1("Leitura de dados csv")

	// Fim de Arquivo
	If Len(cString) < 3
		Exit
	Endif

	nPosic  := 0
	aDadCsv := {}
	cTxtLin := cString
	While (!Empty(cTxtLin))
		If (((nPosic := AT(";",cTxtLin)) > 0))
			AAdd(aDadCsv,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aDadCsv,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo

	If nCountL > 1
		nDif := (Len(aChvCsv)+Len(aCpoCsv)) - Len(aDadCsv)
		If nDif > 0
			AAdd(aDadCsv,"") // Prevendo conteúdo em branco na última posição
		Endif
		If Len(aDadCsv) > 0
			zCampos := ""
			zzWhere := ""
			zUpdate := ""
			zIdRegi := ""
			aUpdate := {}
			aLogExe := {}
			aLogPro := {}
			lUpdate := .F.
			For _x := 1 to Len(aDadCsv)
				If _x <= Len(aChvLib)
					cCpoSx3 := aChvLib[_x]
					cTipSx3 := FwSx3Util():GetFieldType(cCpoSx3)
					cConteu := IIf(Empty(aDadCsv[_x])," ",aDadCsv[_x])
					If cTipSx3 == "N"
						cConteu := StrTran(cConteu,".","")
						cConteu := StrTran(cConteu,",",".")
					Endif
					cConteu := IIf(cTipSx3=="D",DtoS(CtoD(cConteu)),IIf(cTipSx3=="N",AllTrim(STR(Val(cConteu))),cConteu))
					zzWhere += IIf(!Empty(zzWhere)," AND ","")+IIf(cTipSx3=="N",cCpoSx3+" = "+cConteu,cCpoSx3+" = '"+cConteu+"'")
					zIdRegi += cConteu
				Else
					cCpoSx3 := aCpoCsv[_x-Len(aChvLib)]
					cTipSx3 := FwSx3Util():GetFieldType(cCpoSx3)
					cConteu := IIf(Empty(aDadCsv[_x])," ",aDadCsv[_x])
					If cTipSx3 == "N"
						cConteu := StrTran(cConteu,".","")
						cConteu := StrTran(cConteu,",",".")
					Endif
					cConteu := IIf(cTipSx3=="D",DtoS(CtoD(cConteu)),IIf(cTipSx3=="N",AllTrim(STR(Val(cConteu))),cConteu))
					zCampos += IIf(!Empty(zCampos),", ","")+cCpoSx3
					cExpres := IIf(cTipSx3=="N",cCpoSx3+" = "+cConteu,cCpoSx3+" = '"+cConteu+"'")
					AAdd(aUpdate,{cCpoSx3, cConteu, cExpres, cTipSx3})
				Endif
			Next _x
			// Testa se o registro existe
			lOkReg := .F.
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName(ZZL->ZZL_ALIAS)
			cQuery += " WHERE "+zzWhere
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
			nTotReg := TRB->SOMA
			TRB->(DbCloseArea())
			If nTotReg == 0
				AAdd(aLogPro,{zIdRegi, "", "", "", "", "N", "Falha na identificação"})
			ElseIf nTotReg > 1
				AAdd(aLogPro,{zIdRegi, "", "", "", "", "N", "Identificação não exclusiva"})
			Else
				lOkReg := .T.
			Endif
			// Testa o filtro e as modificações
			If lOkReg
				cQuery := " SELECT "+zCampos+", R_E_C_N_O_"
				cQuery += " FROM "+RetSqlName(ZZL->ZZL_ALIAS)
				cQuery += " WHERE "+zzWhere
				If !Empty(ZZL->ZZL_COND)
					cQuery += " AND "+AllTrim(ZZL->ZZL_COND)
				Endif	
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
				If !Eof()
					DbSelectArea(ZZL->ZZL_ALIAS)
					DbGoto(TRB->R_E_C_N_O_)
					For _x := 1 to Len(aUpdate)
						zCpoX3 := aUpdate[_x][1]
						zVelhC := &("TRB->"+aUpdate[_x][1])
						If aUpdate[_x][4] == "N"
							zVelhC := AllTrim(STR(zVelhC))
						Endif
						zNovoC := aUpdate[_x][2]
						If zVelhC <> zNovoC
							lEmpty := IIf( aUpdate[_x][4] == "N", (zNovoC=="0"), (Empty(zNovoC)) )
							If lEmpty .And. ZZL->ZZL_BRANCO <> "S" // Checa se conteúdo em branco foi liberado
								AAdd(aLogPro,{zIdRegi, zCpoX3, FwX3Titulo(zCpoX3), IIf(cTipSx3=="D",DtoC(StoD(zVelhC)),zVelhC), IIf(cTipSx3=="D",DtoC(StoD(zNovoC)),zNovoC), "N", "Conteúdo vazio não permitido"})
							Else
								lUpdate := .T.
								zUpdate += IIf(!Empty(zUpdate),", ","")+zCpoX3+" = '"+zNovoC+"'"
								AAdd(aLogExe,{ZZL->ZZL_ALIAS, ZZL->ZZL_ORDEM, zIdRegi, zCpoX3, FwX3Titulo(zCpoX3), IIf(cTipSx3=="D",DtoC(StoD(zVelhC)),zVelhC), IIf(cTipSx3=="D",DtoC(StoD(zNovoC)),zNovoC), Date(), Substr(Time(),1,5), __cUserId, UsrRetName(__cUserId)})
								AAdd(aLogPro,{zIdRegi, zCpoX3, FwX3Titulo(zCpoX3), IIf(cTipSx3=="D",DtoC(StoD(zVelhC)),zVelhC), IIf(cTipSx3=="D",DtoC(StoD(zNovoC)),zNovoC), "S", "Execução Ok"})
							Endif	
						Else
							AAdd(aLogPro,{zIdRegi, zCpoX3, FwX3Titulo(zCpoX3), IIf(cTipSx3=="D",DtoC(StoD(zVelhC)),zVelhC), IIf(cTipSx3=="D",DtoC(StoD(zNovoC)),zNovoC), "N", "Conteúdo não modificado"})
						Endif
					Next _x
				Else
					AAdd(aLogPro,{zIdRegi, "", "", "", "", "N", "Não atende a condição liberada"})
				Endif
				TRB->(DbCloseArea())
			Endif	
			If lUpdate
				cQuery := " UPDATE "+RetSqlName(ZZL->ZZL_ALIAS)
				cQuery += " SET "+zUpdate
				cQuery += " WHERE "+zzWhere
				If !Empty(ZZL->ZZL_COND)
					cQuery += " AND "+AllTrim(ZZL->ZZL_COND)
				Endif	
				cQuery += " AND D_E_L_E_T_ <> '*' "
				TCSQLEXEC(cQuery)
				TCSQLEXEC("COMMIT")
				//
				GrvLogExec(aLogExe)
				//
				If Empty(ZZL->ZZL_STATUS)
					RecLock("ZZL",.F.)
					ZZL->ZZL_STATUS := "E"
					MsUnLock()
				Endif	
			Endif
			GrvLogProc(aLogPro)
		Endif	
	Endif
		
Enddo

// ************************** //
// ** Log de processamento ** //
// ************************** //
u_LogProcess()

DbSelectArea("LOG")
LOG->(DbCloseArea())
oTempTable:Delete()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GrvLogProc ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  28/08/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Grava log de processamento.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GrvLogProc(aLogPro)

Local _log

DbSelectArea("LOG")
For _log := 1 to Len(aLogPro)
	RecLock("LOG",.T.)
	LOG->LOG_REG := aLogPro[_log][1]
	LOG->LOG_CPO := aLogPro[_log][2]
	LOG->LOG_TIT := aLogPro[_log][3]
	LOG->LOG_OLD := aLogPro[_log][4]
	LOG->LOG_NEW := aLogPro[_log][5]
	LOG->LOG_UPD := aLogPro[_log][6]
	LOG->LOG_OBS := aLogPro[_log][7]
	MsUnLock()
Next _log

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GrvLogExec ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  28/08/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Grava log de execução.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GrvLogExec(aLogExe)

Local _exe

DbSelectArea("ZZM")
For _exe := 1 to Len(aLogExe)
	RecLock("ZZM",.T.)
	ZZM->ZZM_FILIAL := xFilial("ZZM")
	ZZM->ZZM_ALIAS  := aLogExe[_exe][1]
	ZZM->ZZM_ORDEM  := aLogExe[_exe][2]
	ZZM->ZZM_ID     := aLogExe[_exe][3]
	ZZM->ZZM_CAMPO  := aLogExe[_exe][4]
	ZZM->ZZM_TITULO := aLogExe[_exe][5]
	ZZM->ZZM_OLD    := aLogExe[_exe][6]
	ZZM->ZZM_NEW    := aLogExe[_exe][7]
	ZZM->ZZM_DATA   := aLogExe[_exe][8]
	ZZM->ZZM_HORA   := aLogExe[_exe][9]
	ZZM->ZZM_USER   := aLogExe[_exe][10]
	ZZM->ZZM_NOME   := aLogExe[_exe][11]
	MsUnLock()
Next _log

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  28/08/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua leitura do arquivo e retorna conteudo da linha.	  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  28/08/2021  ¦¦¦
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
¦¦¦Programa  ¦ LogProcess ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 29/08/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Log de processamento.							 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LogProcess()

Local oReport

oReport := ReportDef()

If oReport == Nil
	Return
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ReportDef ¦ Autor ¦  Luis Brandini   ¦ Data  ¦ 29/08/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa impressao do relatorio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReportDef()

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
oReport := TReport():New("LOGPROC","Log de processamento", , {|oReport| ReportPrint(oReport), "Este relatório irá imprimir as ocorrências de processamento na carga de dados auditada."})

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
oSection1 := TRSection():New(oReport,"Log de processamento",{"LOG"},,.F.,.F.)

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
TRCell():New(oSection1, "REG", "LOG", "Id Registro", "@!" , 030, , { || LOG->LOG_REG } )
TRCell():New(oSection1, "CPO", "LOG", "Campo"      , "@!" , 020, , { || LOG->LOG_CPO } )
TRCell():New(oSection1, "TIT", "LOG", "Título"     , "@!" , 020, , { || LOG->LOG_TIT } )
TRCell():New(oSection1, "OLD", "LOG", "Anterior"   , "@!" , 030, , { || LOG->LOG_OLD } )
TRCell():New(oSection1, "NEW", "LOG", "Novo"       , "@!" , 030, , { || LOG->LOG_NEW } )
TRCell():New(oSection1, "UPD", "LOG", "Atualizado" , "@!" , 001, , { || LOG->LOG_UPD } )
TRCell():New(oSection1, "OBS", "LOG", "Ocorrência" , "@!" , 200, , { || LOG->LOG_OBS } )

Return(oReport)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ReportPrint ¦ Autor ¦ Luis Brandini  ¦ Data  ¦ 29/08/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa impressao do relatorio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Log de processamento | "+ZZL->ZZL_ALIAS+" - "+AllTrim(ZZL->ZZL_DESCRI)+" |"
oReport:cTitle := "Log de processamento | "+ZZL->ZZL_ALIAS+" - "+AllTrim(ZZL->ZZL_DESCRI)+" |"

DbSelectArea("LOG")
LOG->(DbGotop())
oReport:SetMeter(LOG->(RecCount()))
oSection1:Init()
While !Eof()
	oReport:IncMeter()
	oSection1:PrintLine()
	LOG->(DbSkip())
	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif
Enddo

Return
