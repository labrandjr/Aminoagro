#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TRNFINC   ¦ Autor ¦ Fábrica ERPBR    ¦   Data ¦ 23/03/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transferência Documento Fiscal Incorporação.		 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TRNFINC()

Local cPerg	  := Padr("TRNFINC",10)
Local zUsrFis := AllTrim(GetMv("ZZ_USERFIS"))
Private cEOL  := CHR(13)+CHR(10)
Private oProcess

If !(__cUserID $(zUsrFis))
	MsgAlert("Somente o Administrador ou usuários autorizados podem executar esta rotina.")
	Return
Endif   

If Pergunte(cPerg,.T.)
	Preparar()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Preparar  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  22/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Prepara o processamento principal.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Preparar()

Local lOk  := .F.
Local lEnd := .F.
Private cFilBkp := cFilAnt
Private cDocOri := mv_par02
Private cSerOri := mv_par03
Private cClfOri := mv_par04
Private cFilOri := mv_par05
Private cFilDes := mv_par06
Private lTudoOk := .T.

nRecSm0 := SM0->(Recno())
DbSelectArea("SM0")
DbSetOrder(1)
If !DbSeek( "G1" + PadR(cFilOri,12) )
	MsgAlert("Filial "+cFilOri+" não cadastrada.")
	SM0->(DbGoto(nRecSm0))
	Return
Endif
If !DbSeek( "G1" + PadR(cFilDes,12) )
	MsgAlert("Filial "+cFilDes+" não cadastrada.")
	SM0->(DbGoto(nRecSm0))
	Return
Endif
SM0->(DbGoto(nRecSm0))

If mv_par01 == 1 // Entrada
	DbSelectArea("SF1")
	DbSetOrder(1)
	If !DbSeek( cFilOri + cDocOri + cSerOri + cClfOri )
		MsgAlert("Documento de Entrada não localizado na Filial origem.")
		lTudoOk := .F.
	Else
		lTesOk := .F.
		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
		While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek( SD1->(D1_FILIAL+D1_TES) )
			If SF4->F4_ESTOQUE == "S"
				lTesOk := .T.
				Exit
			Endif
			DbSelectArea("SD1")
			SD1->(DbSkip())
		Enddo
		If !lTesOk
			MsgAlert("Documento de Entrada sem itens que atualizam estoque.")
			lTudoOk := .F.
		Endif
	Endif
	If lTudoOk
		If DbSeek( cFilDes + cDocOri + cSerOri + cClfOri )
			MsgAlert("Documento de Entrada já cadastrado na Filial destino.")
			lTudoOk := .F.
		Endif
	Endif	
Else // Saída
	DbSelectArea("SF2")
	DbSetOrder(1)
	If !DbSeek( cFilOri + cDocOri + cSerOri + cClfOri )
		MsgAlert("Documento de Saída não localizado na Filial origem.")
		lTudoOk := .F.
	Else
		lTesOk := .F.
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) )
		While !Eof() .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek( SD2->(D2_FILIAL+D2_TES) )
			If SF4->F4_ESTOQUE == "S"
				lTesOk := .T.
				Exit
			Endif
			DbSelectArea("SD2")
			SD2->(DbSkip())
		Enddo
		If !lTesOk
			MsgAlert("Documento de Saída sem itens que atualizam estoque.")
			lTudoOk := .F.
		Endif
	Endif
	If lTudoOk
		If DbSeek( cFilDes + cDocOri + cSerOri + cClfOri )
			MsgAlert("Documento de Saída já cadastrado na Filial destino.")
			lTudoOk := .F.
		Endif
	Endif	
Endif

If lTudoOk
	cFilAnt := cFilOri
	If MsgYesNo("Confirma o processamento ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Transferindo Documento Fiscal", "Aguarde, processando ...", .F. )
		oProcess:Activate()
		MsgBox("Processo concluído !!!","Aviso","INFO")
	Endif
Endif

SM0->(DbGoto(nRecSm0))
cFilAnt := cFilBkp

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦  23/03/2020 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da rotina.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local _xCampo, _x

If mv_par01 == 1 // Entrada

	Begin Transaction

	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek( cFilOri + cDocOri + cSerOri + cClfOri )

	nRecSf1 := SF1->(Recno())
	aStruct := SF1->(DbStruct())
	aItens  := {}

	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
	While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		AAdd(aItens,Recno())
		SD1->(DbSkip())
	Enddo

	oProcess:SetRegua1( Len(aItens)+1 )

	aCopia  := {}
	DbSelectArea("SF1")
	For _xCampo := 1 to ( Len(aStruct) )
		_xConteudo := &("SF1->"+aStruct[_xCampo][1])
		If aStruct[_xCampo][1] == "F1_FILIAL"
			_xConteudo := cFilDes
		ElseIf aStruct[_xCampo][1] == "F1_ORIGLAN"
			_xConteudo := "LF"
		Endif	
		AAdd(aCopia,{aStruct[_xCampo][1],_xConteudo})
	Next _xCampo

	oProcess:IncRegua1("Processando...")
	RecLock("SF1",.T.)
	For _xCampo := 1 to ( Len(aCopia) )
		&("SF1->"+aCopia[_xCampo,1]) := aCopia[_xCampo,2]
	Next _xCampo
	MsUnLock()

	aStruct := SD1->(DbStruct())
	For _x := 1 to Len(aItens)
		aCopia  := {}
		DbSelectArea("SD1")
		DbGoto(aItens[_x])
		For _xCampo := 1 to ( Len(aStruct) )
			_xConteudo := &("SD1->"+aStruct[_xCampo][1])
			If aStruct[_xCampo][1] == "D1_FILIAL"
				_xConteudo := cFilDes
			ElseIf aStruct[_xCampo][1] == "D1_ORIGLAN"
				_xConteudo := "LF"
			Endif	
			AAdd(aCopia,{aStruct[_xCampo][1],_xConteudo})
		Next _xCampo
	
		oProcess:IncRegua1("Processando...")
		RecLock("SD1",.T.)
		For _xCampo := 1 to ( Len(aCopia) )
			&("SD1->"+aCopia[_xCampo,1]) := aCopia[_xCampo,2]
		Next _xCampo
		MsUnLock()
	Next _x

	MsgRun("Aguarde, reprocessando livros fiscais...","Processando",{|| ReprocLf(SF1->F1_DTDIGIT) })

	End Transaction
	MsUnLockAll()

Else // Saída

	Begin Transaction

	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSeek( cFilOri + cDocOri + cSerOri + cClfOri )

	nRecSf2 := SF2->(Recno())
	aStruct := SF2->(DbStruct())
	aItens  := {}

	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) )
	While !Eof() .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		AAdd(aItens,Recno())
		SD2->(DbSkip())
	Enddo

	oProcess:SetRegua1( Len(aItens)+1 )

	aCopia  := {}
	DbSelectArea("SF2")
	For _xCampo := 1 to ( Len(aStruct) )
		_xConteudo := &("SF2->"+aStruct[_xCampo][1])
		If aStruct[_xCampo][1] == "F2_FILIAL"
			_xConteudo := cFilDes
		Endif	
		AAdd(aCopia,{aStruct[_xCampo][1],_xConteudo})
	Next _xCampo

	oProcess:IncRegua1("Processando...")
	RecLock("SF2",.T.)
	For _xCampo := 1 to ( Len(aCopia) )
		&("SF2->"+aCopia[_xCampo,1]) := aCopia[_xCampo,2]
	Next _xCampo
	MsUnLock()

	aStruct := SD2->(DbStruct())
	For _x := 1 to Len(aItens)
		aCopia  := {}
		DbSelectArea("SD2")
		DbGoto(aItens[_x])
		For _xCampo := 1 to ( Len(aStruct) )
			_xConteudo := &("SD2->"+aStruct[_xCampo][1])
			If aStruct[_xCampo][1] == "D2_FILIAL"
				_xConteudo := cFilDes
			ElseIf aStruct[_xCampo][1] == "D2_ORIGLAN"
				_xConteudo := "LF"
			Endif	
			AAdd(aCopia,{aStruct[_xCampo][1],_xConteudo})
		Next _xCampo
	
		oProcess:IncRegua1("Processando...")
		RecLock("SD2",.T.)
		For _xCampo := 1 to ( Len(aCopia) )
			&("SD2->"+aCopia[_xCampo,1]) := aCopia[_xCampo,2]
		Next _xCampo
		MsUnLock()
	Next _x

	MsgRun("Aguarde, reprocessando livros fiscais...","Processando",{|| ReprocLf(SF2->F2_EMISSAO) })

	End Transaction
	MsUnLockAll()

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ReprocLf  ¦ Autor ¦ Fábrica ERPBR    ¦   Data ¦ 23/03/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Reprocessamento livros fiscais.		 			 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo QUALYQUIMICA									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ReprocLf(zDataDoc)

lRotAut := .T.    
aParam  := Array(11)
cFilAnt := cFilDes
zDatFis := DtoS(GetMv("MV_DATAFIS"))

PutMv("MV_DATAFIS",StoD("20160101"))

aParam[1]  := DtoC(zDataDoc) //Data Inicial
aParam[2]  := DtoC(zDataDoc) //Data Final
aParam[3]  := mv_par01 //Livro De || 1-Entrada 2-Saída 3-Ambos
aParam[4]  := cDocOri //Nota Fiscal Inicial
aParam[5]  := cDocOri //Nota Fiscal Final
aParam[6]  := cSerOri //Série Inicial
aParam[7]  := cSerOri //Série Final
aParam[8]  := cClfOri //Cli/For Inicial
aParam[9]  := cClfOri //Cli/For Final
aParam[10] := "  "    //Loja Inicial
aParam[11] := "ZZ"    //Loja Final

MATA930(lRotAut,aParam)

cFilAnt := cFilDes
PutMv("MV_DATAFIS",StoD(zDatFis))

Return
