#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ COMR003  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 27/11/2017      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Notas Fiscais de Entrada Por Usuário						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function COMR003()

Local cPerg      := "COMR003"
Private cPath    := "c:\report\"
Private aColunas := {}
Private oTempTable

If !(__cUserId $ ("000000,000163,000156,000098")) // Administrador, Luis Brandini, Camila Borçari, Paula Damásio
	MsgAlert("Usuário não autorizado. Contate o Administrador.")
	Return
Endif

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pTrab03()()})
		Processa({|| pAmnR03()})
		Processa({|| pImpR03()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ pTrab03   ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 01/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivos temporarios.							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pTrab03()

Local _aTmp  := {}
Local zAlias := "TRB"
Local cQuery

oTempTable := FWTemporaryTable():New( zAlias )

If mv_par04 == 1 // Analitico

	AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
	AAdd ( _aTmp, {"TF_DOC"     , "C", 009, 00} )
	AAdd ( _aTmp, {"TF_SERIE"   , "C", 003, 00} )
	AAdd ( _aTmp, {"TF_FORNECE" , "C", 006, 00} )
	AAdd ( _aTmp, {"TF_LOJA	"   , "C", 002, 00} )
	AAdd ( _aTmp, {"TF_NOME"    , "C", 050, 00} )
	AAdd ( _aTmp, {"TF_DTDIGIT" , "D", 008, 00} )
	AAdd ( _aTmp, {"TF_PERIOD"  , "C", 006, 00} )
	AAdd ( _aTmp, {"TF_EMISSAO" , "D", 008, 00} )
	AAdd ( _aTmp, {"TF_USER"    , "C", 044, 00} )

	oTemptable:SetFields( _aTmp )
	oTempTable:AddIndex("indice1", {"TF_FILIAL", "TF_USER", "TF_DTDIGIT"})

Else // Sintético

	AAdd ( _aTmp, {"TF_USER"  , "C", 044, 00} )
	AAdd ( _aTmp, {"TF_QUANT" , "N", 012, 00} )

	oTemptable:SetFields( _aTmp )
	oTempTable:AddIndex("indice1", {"TF_USER"})

Endif

oTempTable:Create()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pAmnR03   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 10/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.								 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pAmnR03()

Local nRecSM0 := SM0->(Recno())
Local xFilOri := cFilAnt
Local lSelFil := (mv_par03 == 1)
Local nForFilial
Local aFilsCalc

aFilsCalc := MatFilCalc( lSelFil )
For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[nForFilial][1]

		cFilAnt := aFilsCalc[nForFilial][2]

		ProcRegua(2)
		IncProc("Selecionando registros...")
		cQuery := " SELECT COUNT(*) AS SOMA "
		cQuery += " FROM " + RetSqlName("SE2")
		cQuery += " WHERE E2_FILIAL = '" + cFilAnt + "' " 
		cQuery += " AND E2_EMIS1 BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' "
		cQuery += " AND E2_ORIGEM = 'MATA100' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nTotSql := SQL->SOMA
		SQL->(DbCloseArea())
		
		IncProc("Selecionando registros...")
		cQuery := " SELECT DISTINCT E2_FILIAL, E2_NUM, E2_PREFIXO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_EMIS1, E2_USERLGI, R_E_C_N_O_ E2RECNO "
		cQuery += " FROM " + RetSqlName("SE2")
		cQuery += " WHERE E2_FILIAL = '" + cFilAnt + "' " 
		cQuery += " AND E2_EMIS1 BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' "
		cQuery += " AND E2_ORIGEM = 'MATA100' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY E2_FILIAL, E2_EMISSAO "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
		DbSelectArea("SQL")
		ProcRegua(nTotSql)
		SQL->(DbGotop())
		While !Eof()
	
			IncProc("Extraindo dados...")

			DbSelectArea("SD1")
			DbSetOrder(1)
			If DbSeek( SQL->(E2_FILIAL+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA) )

				DbSelectArea("SE2")
				SE2->(DbGoto(SQL->E2RECNO))		
				_aUserLgi := FWLeUserlg("E2_USERLGI")
	
				If !Empty(Alltrim(_aUserLgi))
					If mv_par04 == 1 // Analitico
						RecLock("TRB",.T.)
						TRB->TF_FILIAL  := cFilAnt
						TRB->TF_DOC     := SQL->E2_NUM
						TRB->TF_SERIE   := SQL->E2_PREFIXO
						TRB->TF_FORNECE := SQL->E2_FORNECE
						TRB->TF_LOJA    := SQL->E2_LOJA
						TRB->TF_NOME    := SQL->E2_NOMFOR
						TRB->TF_DTDIGIT := SD1->D1_DTDIGIT
						TRB->TF_PERIOD  := Substr(DtoS(SD1->D1_DTDIGIT),1,6)
						TRB->TF_EMISSAO := Stod(SQL->E2_EMISSAO)
						TRB->TF_USER    := _aUserLgi
						MsUnLock()
					Else // Sintético
						_aUserLgi := PadR(_aUserLgi,44)
						DbSelectArea("TRB")
						DbSetOrder(1)
						If !DbSeek( _aUserLgi )
							RecLock("TRB",.T.)
							TRB->TF_USER := _aUserLgi
						Else
							RecLock("TRB",.F.)
						Endif
						TRB->TF_QUANT += 1
						MsUnLock()
					Endif
				Endif	
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
¦¦¦Programa  ¦ pImpR03   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 10/11/2017     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do relatório.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pImpR03()

Local oExcel := FwMsExcel():New()
Local aDados := {}
Local nTotal := 0
Local cQuery, nx

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "USUARIOS"
	cNomeTable := "Usuarios x Documentos de Entrada - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)+" - "+IIf(mv_par04==1,"Analítico","Sintético")
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	If mv_par04 == 1 // Analítico

		oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Local",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Documento",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Série",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Fornecedor",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Loja",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Nome",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Digitação",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Período",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Usuario",1,1)
	
		DbSelectArea("TRB")
		While !Eof()
	
			IncProc("Gerando planilha...")
	
	        aArray := Array(11)
			aArray[1]  := TRB->TF_FILIAL
			aArray[2]  := FWFilialName(cEmpAnt,TRB->TF_FILIAL,1)
			aArray[3]  := TRB->TF_DOC
			aArray[4]  := TRB->TF_SERIE
			aArray[5]  := TRB->TF_FORNECE
			aArray[6]  := TRB->TF_LOJA
			aArray[7]  := TRB->TF_NOME
			aArray[8]  := TRB->TF_DTDIGIT
			aArray[9]  := TRB->TF_PERIOD
			aArray[10] := TRB->TF_EMISSAO
			aArray[11] := TRB->TF_USER
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
		cFile := "USRxDOC-ANALITICO"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"

	Else // Sintético

		oExcel:AddColumn(cNomePlan,cNomeTable,"Usuario",1,1)
		oExcel:AddColumn(cNomePlan,cNomeTable,"Qtde.Inclusões",3,1)
	
		DbSelectArea("TRB")
		While !Eof()
	
			IncProc("Gerando planilha...")
	
	        aArray := Array(2)
			aArray[1] := TRB->TF_USER
			aArray[2] := TRB->TF_QUANT
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
		cFile := "USRxDOC-SINTETICO"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	
	Endif

	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )	
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Endif

Return
