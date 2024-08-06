#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COMR002  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 10/11/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Extração dados Xml não cadastrados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COMR002()

Local cPerg      := "COMR002"
Private cPath    := "c:\report\"
Private aColunas := {}
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab02()()})
		Processa({|| pAmnR02()})
		Processa({|| pImpR02()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab02   ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 01/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab02()

Local _aTmp  := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_EMISSA"  , "D", 008, 00} )
AAdd ( _aTmp, {"TF_SERIE"   , "C", 003, 00} )
AAdd ( _aTmp, {"TF_DOC"     , "C", 009, 00} )
AAdd ( _aTmp, {"TF_MODELO"  , "C", 002, 00} )
AAdd ( _aTmp, {"TF_TOTAL"   , "N", 018, 02} )
AAdd ( _aTmp, {"TF_CHVNFE"  , "C", 044, 00} )
AAdd ( _aTmp, {"TF_CNPJ"    , "C", 014, 00} )
AAdd ( _aTmp, {"TF_FORNEC"  , "C", 050, 00} )
AAdd ( _aTmp, {"TF_CFOP"    , "C", 004, 00} )
AAdd ( _aTmp, {"TF_PRODUT"  , "C", 050, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 050, 00} )
AAdd ( _aTmp, {"TF_TELEF"   , "C", 020, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_EMISSA", "TF_SERIE", "TF_DOC"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR02   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 10/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR02()

Local nRecSM0 := SM0->(Recno())
Local xFilOri := cFilAnt
Local lSelFil := (mv_par03 == 1)
Local nForFilial
Local aFilsCalc

aFilsCalc := MatFilCalc( lSelFil )
ProcRegua(Len(aFilsCalc))
For nForFilial := 1 To Len(aFilsCalc)

	IncProc("Extraindo dados...")

	If aFilsCalc[nForFilial][1]

		cFilAnt := aFilsCalc[nForFilial][2]

		cQuery := " SELECT ZZG_CHVNFE CHVNFE "
		cQuery += " FROM "+RetSqlName("ZZG")
		cQuery += " WHERE ZZG_FILIAL = '"+cFilAnt+"' " 
		cQuery += " AND ZZG_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
		cQuery += " AND ZZG_TIPO IN('1','3','5','7') "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY ZZG_FILIAL, ZZG_EMISSA, ZZG_SERIE, ZZG_DOC "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()

			DbSelectArea("ZZG")
			DbSetOrder(1)
			If DbSeek( SQL->CHVNFE )

				zCfop  := ""
				zProd  := ""
				cAviso := ""
				cErro  := ""
				zTipo  := ""
				//
				If ZZG->ZZG_TIPO == "1"
					zTipo := "1-Nota Fiscal não cadastrada"
				ElseIf ZZG->ZZG_TIPO == "3"
					zTipo := "3-Nota Fiscal Inconsistente"
				ElseIf ZZG->ZZG_TIPO == "5"
					zTipo := "5-Nota Fiscal Combustível não cadastrada"
				ElseIf ZZG->ZZG_TIPO == "7"
					zTipo := "7-Nota Fiscal Cancelada"
				Endif
				//
				zXmlTx := AllTrim(ZZG->ZZG_ARQXML)
				oNfe   := XmlParser(zXmlTx, "_", @cAviso, @cErro)
				If Type("oNFe:_NfeProc") <> "U"
					oNF := oNFe:_NFeProc:_NFe
				Else
					oNF := oNFe:_NFe
				Endif
				oDet := oNF:_InfNfe:_Det
				oDet := IIf( ValType(oDet) == "O", {oDet}, oDet )
				If Len(oDet) > 0
					zCfop := oDet[1]:_PROD:_CFOP:TEXT
					zProd := oDet[1]:_PROD:_XPROD:TEXT
				Endif	
                //
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->TF_FILIAL := cFilAnt
				TRB->TF_EMISSA := ZZG->ZZG_EMISSA
				TRB->TF_SERIE  := ZZG->ZZG_SERIE
				TRB->TF_DOC    := ZZG->ZZG_DOC
				TRB->TF_MODELO := ZZG->ZZG_MODELO
				TRB->TF_TOTAL  := ZZG->ZZG_TOTAL
				TRB->TF_CHVNFE := ZZG->ZZG_CHVNFE
				TRB->TF_CNPJ   := ZZG->ZZG_CNPJ
				TRB->TF_FORNEC := ZZG->ZZG_NOME
				TRB->TF_CFOP   := zCfop
				TRB->TF_PRODUT := zProd
				TRB->TF_TIPO   := zTipo
				TRB->TF_TELEF  := ZZG->ZZG_TELEF
				MsUnLock()
			Endif	

			DbSelectArea("SQL")
			SQL->(DbSkip())
		Enddo
		SQL->(DbCloseArea())

	Endif	

Next nForFilial

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pImpR02   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 10/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR02()

Local oExcel := FwMsExcel():New()

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "ZZG_XML"
	cNomeTable := "Xml não Cadastrado"
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Modelo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Total",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Chave",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cnpj",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Cfop",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Produto",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Telefone",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Informações",1,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("ZZG")
		DbSetOrder(1)
		DbSeek( TRB->TF_CHVNFE )

		zInfor := AllTrim(ZZG->ZZG_INFOR)
		zInfor := StrTran(zInfor,",","")
		zInfor := StrTran(zInfor,";","")
		zInfor := StrTran(zInfor,"&","")
		zInfor := StrTran(zInfor,"|","")
		zInfor := StrTran(zInfor,":","")
		zInfor := StrTran(zInfor,"<","")
		zInfor := StrTran(zInfor,">","")
		zInfor := StrTran(zInfor,"{","")
		zInfor := StrTran(zInfor,"}","")
		zInfor := StrTran(zInfor,"=","")
		zInfor := StrTran(zInfor,"+","")
		
        aArray := Array(15)
		aArray[1]  := TRB->TF_FILIAL
		aArray[2]  := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
		aArray[3]  := TRB->TF_EMISSA
		aArray[4]  := TRB->TF_SERIE
		aArray[5]  := TRB->TF_DOC
		aArray[6]  := TRB->TF_MODELO
		aArray[7]  := TRB->TF_TOTAL
		aArray[8]  := TRB->TF_CHVNFE
		aArray[9]  := TRB->TF_CNPJ
		aArray[10] := TRB->TF_FORNEC
		aArray[11] := TRB->TF_CFOP
		aArray[12] := TRB->TF_PRODUT
		aArray[13] := TRB->TF_TIPO
		aArray[14] := TRB->TF_TELEF
		aArray[15] := zInfor
		//
		oExcel:AddRow(cNomePlan, cNomeTable, aArray)
		//		
		DbSelectArea("TRB")
		TRB->(DbSkip())

	Enddo
	TRB->(DbCloseArea())
	oTempTable:Delete() 
	
	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "ZZG_XML-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return
