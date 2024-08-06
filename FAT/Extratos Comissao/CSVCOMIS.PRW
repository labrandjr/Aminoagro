#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CSVCOMIS  ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 20/02/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Alteração entidades comissões via arquivo CSV.		 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CSVCOMIS()

Local lOk        := .F.
Local cUsrHab    := AllTrim(GetMv("MV_ZUSCCOM"))+","+AllTrim(GetMv("MV_ZUSCCTL"))
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

If !( __cUserId $(cUsrHab) )
	MsgAlert("Usuário não autorizado.")
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

	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	If MsgYesNo("Confirma o processamento - ALTERAÇÃO ENTIDADES COMISSÕES ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp(cArquivo) }, "Alterando dados", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ 20/02/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp(cArquivo)

Local cEOL      := CHR(13)+CHR(10)
Local _aTmp     := {}
Local zAlias    := "LOG"
Private cUsrCom := AllTrim(GetMv("MV_ZUSCCOM"))
Private cUsrCtl := AllTrim(GetMv("MV_ZUSCCTL"))
Private nCountLin := 0
Private zIdForm, zIdOpca, zFilial, zDocume, zSerie, zCliFor, zVend1, zVend2, zVend3, zVend4, zGeren, zDiret
Private zComis1, zComis2, zComis3, zComis4, zCCusto, zUniNeg, zRegiao, zValNcc
Private cVend1, cVend2, cVend3, cVend4, cGeren, cDiret, nComis1, nComis2, nComis3, nComis4
Private cCCusto, cUniNeg, cRegiao

oTempTable := FWTemporaryTable():New( zAlias )
AAdd ( _aTmp, {"LOG_LIN" , "C", 006, 00} )
AAdd ( _aTmp, {"LOG_FRM" , "C", 020, 00} )
AAdd ( _aTmp, {"LOG_OPC" , "C", 020, 00} )
AAdd ( _aTmp, {"LOG_FIL" , "C", 008, 00} )
AAdd ( _aTmp, {"LOG_DOC" , "C", 010, 00} )
AAdd ( _aTmp, {"LOG_OKP" , "C", 001, 00} )
AAdd ( _aTmp, {"LOG_OBS" , "C", 200, 00} )
oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"LOG_LIN"})
oTempTable:Create()

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando arquivo csv..")

	// Fim de Arquivo
	If Len(cString) < 4
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
	// [01] - P=Pedido | S=Documento de Saída | D=Devolução de Venda | N=NCC
	// [02] - V=Vendedores | G=Ger/Dir | F=Faixas | C=Contábeis | N=Valor NCC
	// [03] - Filial
	// [04] - Documento	
	// [05] - Série
	// [06] - Fornecedor
	// [07] - Vendedor1
	// [08] - Vendedor2
	// [09] - Vendedor3
	// [10] - Vendedor4
	// [11] - Gerente 
	// [12] - Diretor
	// [13] - %Comissão1
	// [14] - %Comissão2
	// [15] - %Comissão3
	// [16] - %Comissão4
	// [17] - C.Custo
	// [18] - Unid.Negócio
	// [19] - Região
	// [20] - Valor NCC

	If Len(aLinha) > 1
		If Len(aLinha) == 19
			AAdd(aLinha,"")
		Endif
	Endif		

	If Len(aLinha) <> 20
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 20 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zIdForm := Upper(AllTrim(aLinha[1]))
		zIdOpca := Upper(AllTrim(aLinha[2]))
		zFilial := aLinha[3]
		zDocume := aLinha[4]
		zSerie  := aLinha[5]
		zCliFor := aLinha[6]
		zVend1  := aLinha[7]
		zVend2  := aLinha[8]
		zVend3  := aLinha[9]
		zVend4  := aLinha[10]
		zGeren  := aLinha[11]
		zDiret  := aLinha[12]
		If Empty(aLinha[13])
			zComis1 := -1
		Else
			zComis1 := StrTran(aLinha[13],".","")
			zComis1 := StrTran(zComis1,",",".")
			zComis1 := Val(zComis1)
		Endif
		If Empty(aLinha[14])
			zComis2 := -1
		Else
			zComis2 := StrTran(aLinha[14],".","")
			zComis2 := StrTran(zComis2,",",".")
			zComis2 := Val(zComis2)
		Endif
		If Empty(aLinha[15])
			zComis3 := -1
		Else
			zComis3 := StrTran(aLinha[15],".","")
			zComis3 := StrTran(zComis3,",",".")
			zComis3 := Val(zComis3)
		Endif
		If Empty(aLinha[16])
			zComis4 := -1
		Else
			zComis4 := StrTran(aLinha[16],".","")
			zComis4 := StrTran(zComis4,",",".")
			zComis4 := Val(zComis4)
		Endif
		zCCusto := aLinha[17]
		zUniNeg := aLinha[18]
		zRegiao := aLinha[19]
		zValNcc := StrTran(aLinha[20],".","")
		zValNcc := StrTran(zValNcc,",",".")
		zValNcc := Val(zValNcc)

		// ************************ //
		// ** Formulário e Opção ** //
		// ************************ //

		If !(zIdForm $("P,S,D,N"))
			zLog := "Tipo do formulário inválido: "+zIdForm
			InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
			Loop
		Endif

		If !(zIdOpca $("V,G,F,C,N"))
			zLog := "Tipo da opção inválida: "+zIdOpca
			InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
			Loop
		Endif

		If !FWFilExist("G1",zFilial)
			zLog := "Filial inválida: "+zFilial
			InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
			Loop
		Endif	

		// *************** //
		// ** Posiciona ** //
		// *************** //

		If zIdForm == "P"
			zPedido := PadR(AllTrim(zDocume),6)
			DbSelectArea("SC5")
			DbSetOrder(1)
			If !DbSeek( zFilial + zPedido )
				zLog := "Pedido não localizado: "+zFilial+"-"+zPedido
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif
		ElseIf zIdForm == "S"
			zNFiscal := PadR(AllTrim(zDocume),9)
			zSerieNf := PadR(AllTrim(IIf(Empty(zSerie),"4",zSerie)),3)
			DbSelectArea("SF2")
			DbSetOrder(1)
			If !DbSeek( zFilial + zNFiscal + zSerieNf )
				zLog := "Nota Fiscal de Venda não localizada: "+zFilial+"-"+zNFiscal+"-"+zSerieNf
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif
		ElseIf zIdForm == "D"
			zNFiscal := PadR(AllTrim(zDocume),9)
			zSerieNf := PadR(AllTrim(zSerie),3)
			zFornece := PadR(AllTrim(zCliFor),6)
			DbSelectArea("SF1")
			DbSetOrder(1)
			If !DbSeek( zFilial + zNFiscal + zSerieNf + zFornece + "01" + "D" )
				zLog := "Nota Fiscal de Devolução não localizada: "+zFilial+"-"+zNFiscal+"-"+zSerieNf+"-"+zFornece
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif
		ElseIf zIdForm == "N"
			zNFiscal := PadR(AllTrim(zDocume),9)
			zSerieNf := PadR(AllTrim(zSerie),3)
			cQuery := " SELECT R_E_C_N_O_ RECSE3 "
			cQuery += " FROM "+RetSqlName("SE3")
			cQuery += " WHERE E3_FILIAL = '"+zFilial+"' "
			cQuery += " AND E3_SERIE = '"+zSerieNf+"' "
			cQuery += " AND E3_NUM = '"+zNFiscal+"' "
			cQuery += " AND E3_TIPO = 'NCC' "
			cQuery += " AND E3_BAIEMI = 'E' "
			cQuery += " AND E3_ORIGEM = 'D'
			cQuery += " AND E3_ZZRTV = ' ' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
			SQL3->(DbGotop())
			If !Eof()
				DbSelectArea("SE3")
				SE3->(DbGoto(SQL3->RECSE3))
			Else
				zLog := "NCC não localizada: "+zFilial+"-"+zNFiscal+"-"+zSerieNf
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif
			SQL3->(DbCloseArea())
		Endif	

		// ******************* //
		// ** Executa opção ** //
		// ****************** //
		If zIdForm == "P" // Pedido
			If zIdOpca == "N" // Valor NCC
				zLog := "Opção não disponível para Pedidos."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif	
			If zIdOpca $("V,G,C") // Vendedor, Ger/Dir, Contábeis
				If !( __cUserId $(cUsrCom) )
					zLog := "Usuário não habilitado para alterações do perfil 'Comercial'."
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					Loop
				Endif
			Endif	
			If !u_ChkPedido()
				zLog := "Pedido sem saldo para faturar."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif
			// ************** //
			// ** Execução ** //
			// ************** //
			If zIdOpca == "V" // Vendedor
				cVend1 := IIf(Empty(zVend1),"",SC5->C5_VEND1)
				cVend2 := IIf(Empty(zVend2),"",SC5->C5_VEND2)
				cVend3 := IIf(Empty(zVend3),"",SC5->C5_VEND3)
				cVend4 := IIf(Empty(zVend4),"",SC5->C5_VEND4)
				If TokVend()
					u_UpdVenCm("P",cVend1,zVend1,cVend2,zVend2,cVend3,zVend3,cVend4,zVend4,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zVend1)," "+zVend1,"")
					zLog += IIf(!Empty(zVend2)," "+zVend2,"")
					zLog += IIf(!Empty(zVend3)," "+zVend3,"")
					zLog += IIf(!Empty(zVend4)," "+zVend4,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif	
			ElseIf zIdOpca == "G" // Ger / Dir
				cGeren := IIf(Empty(zGeren),"",SC5->C5_GEREN1)
				cDiret := IIf(Empty(zDiret),"",SC5->C5_SUPER1)
				If TokGrDr()
					u_UpdGdrCm("P",cGeren,zGeren,cDiret,zDiret,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zGeren)," "+zGeren,"")
					zLog += IIf(!Empty(zDiret)," "+zDiret,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif	
			ElseIf zIdOpca == "F" // Faixas
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek( SC5->(C5_FILIAL+C5_NUM) )
				nComis1 := IIf(zComis1<0,-1,SC6->C6_COMIS1)
				nComis2 := IIf(zComis2<0,-1,SC6->C6_COMIS2)
				nComis3 := IIf(zComis3<0,-1,SC6->C6_COMIS3)
				nComis4 := IIf(zComis4<0,-1,SC6->C6_COMIS4)
				If TokFaixa()
					u_UpdFaiCm("P",nComis1,zComis1,nComis2,zComis2,nComis3,zComis3,nComis4,zComis4,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(zComis1<>nComis1," %Cms1."+AllTrim(STR(zComis1))+"%","")
					zLog += IIf(zComis2<>nComis2," %Cms2."+AllTrim(STR(zComis2))+"%","")
					zLog += IIf(zComis3<>nComis3," %Cms3."+AllTrim(STR(zComis3))+"%","")
					zLog += IIf(zComis4<>nComis4," %Cms4."+AllTrim(STR(zComis4))+"%","")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif
			ElseIf zIdOpca == "C" // Contábeis
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek( SC5->(C5_FILIAL+C5_NUM) )
				cCCusto := IIf(Empty(zCCusto),"",SC6->C6_CCUSTO)
				cUniNeg := IIf(Empty(zUniNeg),"",SC6->C6_ZZITCTB)
				cRegiao := IIf(Empty(zRegiao),"",SC5->C5_ZZREGVE)
				If TokContab()
					u_UpdCtbCm("P",cCCusto,zCCusto,cUniNeg,zUniNeg,cRegiao,zRegiao,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zCCusto)," "+zCCusto,"")
					zLog += IIf(!Empty(zUniNeg)," "+zUniNeg,"")
					zLog += IIf(!Empty(zRegiao)," "+zRegiao,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif
			Endif
		ElseIf zIdForm == "S" // Documento de Saída
			If zIdOpca == "N" // Valor NCC
				zLog := "Opção não disponível para Documentos de Saída."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif	
			If zIdOpca $("V,G") // Vendedor, Ger/Dir
				If !( __cUserId $(cUsrCom) )
					zLog := "Usuário não habilitado para alterações do perfil 'Comercial'."
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					Loop
				Endif
			Endif	
			aChkDoc := u_ChkDocSai()
		/*	If !aChkDoc[1] .And. !aChkDoc[2] .And. !aChkDoc[3] .And. !aChkDoc[4]
				zLog := "Nota Fiscal já possui comissão paga."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif */
			If zIdOpca == "C" // Contábeis
				If !Empty(SF2->F2_DTLANC)
					If !( __cUserId $(cUsrCtl) )
						zLog := "Nf contabilizada. Usuário não habilitado para alterações do perfil 'Controladoria'."
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						Loop
					Endif
				Endif
			Endif	
			// ************** //
			// ** Execução ** //
			// ************** //
			If zIdOpca == "V" // Vendedor
				cVend1 := IIf(Empty(zVend1),"",SF2->F2_VEND1)
				cVend2 := IIf(Empty(zVend2),"",SF2->F2_VEND2)
				cVend3 := IIf(Empty(zVend3),"",SF2->F2_VEND3)
				cVend4 := IIf(Empty(zVend4),"",SF2->F2_VEND4)
				If TokVend()
					u_UpdVenCm("S",cVend1,zVend1,cVend2,zVend2,cVend3,zVend3,cVend4,zVend4,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zVend1)," "+zVend1,"")
					zLog += IIf(!Empty(zVend2)," "+zVend2,"")
					zLog += IIf(!Empty(zVend3)," "+zVend3,"")
					zLog += IIf(!Empty(zVend4)," "+zVend4,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif	
			ElseIf zIdOpca == "G" // Ger / Dir
				cGeren := IIf(Empty(zGeren),"",SF2->F2_GEREN1)
				cDiret := IIf(Empty(zDiret),"",SF2->F2_SUPER1)
				If TokGrDr()
					u_UpdGdrCm("S",cGeren,zGeren,cDiret,zDiret,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zGeren)," "+zGeren,"")
					zLog += IIf(!Empty(zDiret)," "+zDiret,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif	
			ElseIf zIdOpca == "F" // Faixas
				DbSelectArea("SD2")
				DbSetOrder(3)
				DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE) )
				nComis1 := IIf(zComis1<0,-1,SD2->D2_COMIS1)
				nComis2 := IIf(zComis2<0,-1,SD2->D2_COMIS2)
				nComis3 := IIf(zComis3<0,-1,SD2->D2_COMIS3)
				nComis4 := IIf(zComis4<0,-1,SD2->D2_COMIS4)
				If TokFaixa()
					u_UpdFaiCm("S",nComis1,zComis1,nComis2,zComis2,nComis3,zComis3,nComis4,zComis4,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(zComis1<>nComis1," %Cms1."+AllTrim(STR(zComis1))+"%","")
					zLog += IIf(zComis2<>nComis2," %Cms2."+AllTrim(STR(zComis2))+"%","")
					zLog += IIf(zComis3<>nComis3," %Cms3."+AllTrim(STR(zComis3))+"%","")
					zLog += IIf(zComis4<>nComis4," %Cms4."+AllTrim(STR(zComis4))+"%","")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif
			ElseIf zIdOpca == "C" // Contábeis
				DbSelectArea("SD2")
				DbSetOrder(3)
				DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE) )
				cCCusto := IIf(Empty(zCCusto),"",SD2->D2_CCUSTO)
				cUniNeg := IIf(Empty(zUniNeg),"",SD2->D2_ITEMCC)
				cRegiao := IIf(Empty(zRegiao),"",SF2->F2_ZZREGVE)
				If TokContab()
					u_UpdCtbCm("S",cCCusto,zCCusto,cUniNeg,zUniNeg,cRegiao,zRegiao,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zCCusto)," "+zCCusto,"")
					zLog += IIf(!Empty(zUniNeg)," "+zUniNeg,"")
					zLog += IIf(!Empty(zRegiao)," "+zRegiao,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
				Endif
			Endif
		ElseIf zIdForm == "D" // Devolução
			If zIdOpca $("V,G,F,N") // Vendedor, Ger/Dir, Faixas, Valor NCC
				zLog := "Opção não disponível para Devoluções."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif	
			If zIdOpca == "C" // Contábeis
				If !Empty(SF1->F1_DTLANC)
					If !( __cUserId $(cUsrCtl) )
						zLog := "Nf contabilizada. Usuário não habilitado para alterações do perfil 'Controladoria'."
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						Loop
					Endif
				Endif
			Endif	
			// ************** //
			// ** Execução ** //
			// ************** //
			DbSelectArea("SD1")
			DbSetOrder(1)
			DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
			cCCusto := IIf(Empty(zCCusto),"",SD1->D1_CC)
			cUniNeg := IIf(Empty(zCCusto),"",SD1->D1_ITEMCTA)
			cRegiao := ""
			If TokContab()
				u_UpdCtbCm("D",cCCusto,zCCusto,cUniNeg,zUniNeg,cRegiao,zRegiao,cArquivo)
				zLog := "Alterações realizadas com sucesso:"
				zLog += IIf(!Empty(zCCusto)," "+zCCusto,"")
				zLog += IIf(!Empty(zUniNeg)," "+zUniNeg,"")
				zLog += IIf(!Empty(zRegiao)," "+zRegiao,"")
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "S", zLog)
			Endif
		ElseIf zIdForm == "N" // NCC
			If zIdOpca $("F,C,N") // Faixas, contábeis, Valor NCC
				zLog := "Opção não disponível para NCC."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Loop
			Endif	
			// ************** //
			// ** Execução ** //
			// ************** //
			If zIdOpca == "V" // Vendedor
				cVend1 := IIf(Empty(zVend1),"",SE3->E3_VEND)
				cVend2 := ""
				cVend3 := ""
				cVend4 := ""
				If TokVend()
					u_UpdVenCm("N",cVend1,zVend1,cVend2,zVend2,cVend3,zVend3,cVend4,zVend4,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zVend1)," "+zVend1,"")
					zLog += IIf(!Empty(zVend2)," "+zVend2,"")
					zLog += IIf(!Empty(zVend3)," "+zVend3,"")
					zLog += IIf(!Empty(zVend4)," "+zVend4,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Endif	
			ElseIf zIdOpca == "G" // Ger/Dir
				cGeren := IIf(Empty(zGeren),"",SE3->E3_ZZGER)
				cDiret := IIf(Empty(zDiret),"",SE3->E3_ZZSUP)
				If TokGrDr()
					u_UpdGdrCm("N",cGeren,zGeren,cDiret,zDiret,cArquivo)
					zLog := "Alterações realizadas com sucesso:"
					zLog += IIf(!Empty(zGeren)," "+zGeren,"")
					zLog += IIf(!Empty(zDiret)," "+zDiret,"")
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				Endif	
			Endif
		Endif

	Endif
		
Enddo

// ************************** //
// ** Log de processamento ** //
// ************************** //
u_LogAltC()

DbSelectArea("LOG")
LOG->(DbCloseArea())
oTempTable:Delete()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  01/12/2020  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  01/12/2020  ¦¦¦
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
¦¦¦Função    ¦ TokVend   ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 20/02/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação vendedores.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function TokVend()

Local lRetOk := .T.
Local lAltOk := .F.
Local _x

For _x := 1 to 4
	vInc := &("cVend"+AllTrim(STR(_x)))
	vAlt := &("zVend"+AllTrim(STR(_x)))
	If !Empty(vAlt)
		If vInc <> vAlt
			lAltOk := .T.
			DbSelectArea("SA3")
			DbSetOrder(1)
			If DbSeek( xFilial("SA3") + vAlt )
				If SA3->A3_MSBLQL == "1"
					zLog := "Código bloqueado para uso: "+vAlt
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					lRetOk := .F.
					Loop
				Endif	
			Else
				zLog := "Código não cadastrado: "+vAlt
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				lRetOk := .F.
				Loop
			Endif
			If lRetOk
				If _x == 1 .Or. _x == 3
					If !(Substr(SA3->A3_COD,1,1) $("V,G"))
						zLog := "Código inválido para RTV: "+vAlt
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						lRetOk := .F.
						Loop
					Endif
				Else	
					If !(Substr(SA3->A3_COD,1,1) $("R"))
						zLog := "Código inválido para Revenda: "+vAlt
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						lRetOk := .F.
						Loop
					Endif
				Endif
			Endif
		Endif
	Endif
Next _x
If !lAltOk
	zLog := "Alterações não informadas."
	InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
	lRetOk := .F.
Endif

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ TokGrDr   ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 20/02/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação gerente de diretores.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function TokGrDr()

Local lRetOk := .T.
Local lAltOk := .F.
Local _x

For _x := 1 to 2
	vInc := IIf(_x==1,cGeren,cDiret)
	vAlt := IIf(_x==1,zGeren,zDiret)
	If !Empty(vAlt)
		If vInc <> vAlt
			lAltOk := .T.
			DbSelectArea("SA3")
			DbSetOrder(1)
			If DbSeek( xFilial("SA3") + vAlt )
				If SA3->A3_MSBLQL == "1"
					zLog := "Código bloqueado para uso: "+vAlt
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					lRetOk := .F.
					Loop
				Endif	
			Else
				zLog := "Código não cadastrado: "+vAlt
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				lRetOk := .F.
				Loop
			Endif
			If lRetOk
				If _x == 1
					If !(Substr(SA3->A3_COD,1,1) $("G"))
						zLog := "Código inválido para Gerente: "+vAlt
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						lRetOk := .F.
						Loop
					Endif
				Else	
					If !(Substr(SA3->A3_COD,1,1) $("D"))
						zLog := "Código inválido para Diretor: "+vAlt
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						lRetOk := .F.
						Loop
					Endif
				Endif
			Endif
		Endif
	Endif
Next _x
If !lAltOk
	zLog := "Alterações não informadas."
	InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
	lRetOk := .F.
Endif

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ TokFaixa  ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 20/02/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação faixas de comissão.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function TokFaixa()

Local lRetOk := .T.
Local lAltOk := .F.
Local _x

For _x := 1 to 4
	vInc := &("nComis"+AllTrim(STR(_x)))
	vAlt := &("zComis"+AllTrim(STR(_x)))
	If vInc <> vAlt .And. vAlt >= 0
		lAltOk := .T.
		If _x == 1 .Or. _x == 3
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SZ2")
			cQuery += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' "
			cQuery += " AND Z2_COMIS = "+AllTrim(STR(vAlt))+" "
			cQuery += " AND Z2_VALID >= '"+DtoS(Date())+"' "
			cQuery += " AND Z2_ATIVO = 'S' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ2", .F., .T.)
			lRetSz2 := ( TRZ2->SOMA > 0 )
			TRZ2->(DbCloseArea())
			If !lRetSz2
				zLog := "Faixa de comissão (Vendedor) não cadastrada ou inválida."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				lRetOk := .F.
			Endif
		Else
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SZ3")
			cQuery += " WHERE Z3_FILIAL = '"+xFilial("SZ3")+"' "
			cQuery += " AND Z3_COMIS = "+AllTrim(STR(vAlt))+" "
			cQuery += " AND Z3_VALID >= '"+DtoS(Date())+"' "
			cQuery += " AND Z3_ATIVO = 'S' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ3", .F., .T.)
			lRetSz3 := ( TRZ3->SOMA > 0 )
			TRZ3->(DbCloseArea())
			If !lRetSz3
				zLog := "Faixa de comissão (Revenda) não cadastrada ou inválida."
				InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
				lRetOk := .F.
			Endif
		Endif
		If lRetOk
			If vAlt > vInc
				If !( __cUserId $(cUsrCtl) )
					zLog := "%Comissão"+AllTrim(STR(_x))+" informada é maior que a original. Usuário não habilitado com perfil 'Controladoria'."
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					lRetOk := .F.
				Endif
			Endif
		Endif	
	Endif	
Next _x
If !lAltOk
	zLog := "Alterações não informadas."
	InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
	lRetOk := .F.
Endif

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ TokContab ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 20/02/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação dados contábeis.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function TokContab()

Local lRetOk := .T.
Local lAltOk := .F.
Local _x

For _x := 1 to 3
	If _x == 1 // C.Custo
		vInc := cCCusto
		vAlt := zCCusto
	ElseIf _x == 2 // Unid.Negócio
		vInc := cUniNeg
		vAlt := zUniNeg
	ElseIf _x == 3 // Região
		vInc := cRegiao
		vAlt := zRegiao
	Endif
	If !Empty(vAlt)
		If vInc <> vAlt
			lAltOk := .T.
			If _x == 1 // C.Custo
				DbSelectArea("CTT")
				DbSetOrder(1)
				If DbSeek( xFilial("CTT") + vAlt )
					If CTT->CTT_BLOQ == "1"
						zLog := "C.Custo bloqueado para uso: "+vAlt
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						lRetOk := .F.
					Endif	
				Else
					zLog := "C.Custo não cadastrado: "+vAlt
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					lRetOk := .F.
				Endif
			ElseIf _x == 2 // Unid.Negócio
				DbSelectArea("CTD")
				DbSetOrder(1)
				If DbSeek( xFilial("CTD") + vAlt )
					If CTD->CTD_BLOQ == "1"
						zLog := "Unid.Negócio bloqueada para uso: "+vAlt
						InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
						lRetOk := .F.
					Endif	
				Else
					zLog := "Unid.Negócio não cadastrada: "+vAlt
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					lRetOk := .F.
				Endif
			ElseIf _x == 3 // Região
				DbSelectArea("SX5")
				DbSetOrder(1)
				If !DbSeek( xFilial("SX5") + "A2" + PadR(vAlt,6) )
					zLog := "Região não cadastrada: "+vAlt
					InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
					lRetOk := .F.
				Endif
			Endif
		Endif
	Endif
Next _x
If !lAltOk
	zLog := "Alterações não informadas."
	InputLog(nCountLin, zIdForm, zIdOpca, zFilial, zDocume, "N", zLog)
	lRetOk := .F.
Endif

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ InputLog  ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 20/02/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Insere registro no log.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function InputLog(logLin, logFrm, logOpc, logFil, logDoc, logOkp, logObs)

xlog_Lin := AllTrim(STR(logLin))
xlog_Frm := "Inválido"
If logFrm == "P"
	xlog_Frm := "Pedido"
ElseIf logFrm == "S"
	xlog_Frm := "Documento de Saída"
ElseIf logFrm == "D"
	xlog_Frm := "Devolução de Venda"
ElseIf logFrm == "N"
	xlog_Frm := "NCC"
Endif	
xlog_Opc := "Inválido"
If logOpc == "V"
	xlog_Opc := "Vendedor"
ElseIf logOpc == "G"
	xlog_Opc := "Ger/Dir"
ElseIf logOpc == "F"
	xlog_Opc := "Faixa"
ElseIf logOpc == "C"
	xlog_Opc := "Contábeis"
ElseIf logOpc == "N"
	xlog_Opc := "Valor NCC"
Endif	
xlog_Fil := logFil
xlog_Doc := logDoc
xlog_Okp := logOkp
xlog_Obs := logObs

DbSelectArea("LOG")
RecLock("LOG",.T.)
LOG->LOG_LIN := xlog_Lin
LOG->LOG_FRM := xlog_Frm
LOG->LOG_OPC := xlog_Opc
LOG->LOG_FIL := xlog_Fil
LOG->LOG_DOC := xlog_Doc
LOG->LOG_OKP := xlog_Okp
LOG->LOG_OBS := xlog_Obs
MsUnLock()

Return
