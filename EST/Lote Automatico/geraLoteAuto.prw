#Include 'Protheus.ch'
#include "topconn.ch"
/*
* Rotina		:	Ponto de Entrada geraLoteAuto 
* Autor			:	Augusto Krejci Bem-Haja
* Data			:	17/12/2015
* Descricao		:	função para geração automática da numeração do lote dos produtos no apontamento de produção. 
*					A numeração segue a regra XXDDMMAA, sendo XX um número sequencial, seguido da data. O número
*					sequencial deve ser reiniciado a cada dia, e será gerado somente para produtos do tipo PI. No    
*					caso dos produtos tipo PA, o lote deve ser copiado do lote já selecinado na tabela de Requisição
*					de empenhos, do primeiro item da estrutura que controle rastro. Caso não haja um lote informado,
*					dá mensagem ao usuário e impede o apontamento.
* Observacoes	:	.
*/
User Function geraLoteAuto()
	Local cData
	Local nLote			:= 0
	Local lRetorno		:= ParamIXB //-- Validação do Sistema
	Local cOp			:= ""
	Local cProd			:= ""
	Local cTipo			:= ""
	Local cRastro		:= ""
	
	If lRetorno
		pegaDataLote(@nLote,@cData)
	
		carregaVariaveis(@cOp,@cProd,@cTipo,@cRastro)
	
		verTipoLote(@cTipo,@cRastro,@nLote,@cData,@cProd,@cOp,@lRetorno)
	Endif	
Return lRetorno

Static Function pegaDataLote(nLote,cData)
	Local aAreaSX6		:= SX6->(GetArea())
	Local cParametro	:= ""
	
	DbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	SX6->(DbSeek(cFilAnt+"MV_PRXLOTE"))
	cParametro 	:= AllTrim(X6Conteud())
	cData		:= SubStr(cParametro,3,6)
	nLote		:= Val(SubStr(cParametro,1,2))
	
	RestArea (aAreaSX6)
Return

Static Function carregaVariaveis(cOp,cProd,cTipo,cRastro)
	Local aAreaSB1		:= SB1->(GetArea())

	cOp    		:= M-> D3_OP
	cProd  		:= M-> D3_COD
	cTipo 		:= RetField("SB1",1,xFilial("SB1") + cProd,"B1_TIPO")
	cRastro 	:= RetField("SB1",1,xFilial("SB1") + cProd,"B1_RASTRO")
	
	RestArea (aAreaSB1)
Return

Static Function verTipoLote(cTipo,cRastro,nLote,cData,cProd,cOp,lRetorno)
	Do Case
		Case cTipo == 'PI' .and. cRastro == 'L'
			geraLotePI(@nLote,@cData)
		Case cTipo == 'PA' .and. cRastro == 'L'
			geraLotePA(@cProd,@cOp,@lRetorno)
	EndCase
Return

Static Function geraLotePI(nLote,cData)
	Local cNovoLote		:= ""
	Local cPrxLote		:= ""
	Local cDataSistema  := SubStr(DtoS(Date()),7,2)+SubStr(DtoS(Date()),5,2)+SubStr(DtoS(Date()),3,2)	

	If cData < cDataSistema
		nLote := 1
	Endif
	
	cNovoLote := StrZero(nLote,2,0) + cDataSistema
	
	If Empty(M->D3_LOTECTL)
		M->D3_LOTECTL := cNovoLote
	Endif	

	cPrxLote := StrZero(nLote+1,2,0) + cDataSistema
	PutMV("MV_PRXLOTE",cPrxLote)
Return

Static Function geraLotePA(cProd,cOp,lRetorno)
	Local cMensagem		:= ""
	Local cNovoLote		:= ""
	Local cProdEmp		:= ""
	
	verEstrut(@cProdEmp,cOp,@cProd,@cNovoLote)
	
	If Empty(cNovoLote)
		cMensagem += "Atenção, nenhum PI da estrutura possui Lote informado nos empenhos!" + CHR(10) + CHR(13)
		cMensagem += "Realize manutenção na rotina Ajuste de Empenhos, antes de prosseguir." 
		MsgAlert (cMensagem) 
		lRetorno := .F.
	Else
		If Empty(M->D3_LOTECTL)
			M->D3_LOTECTL := cNovoLote
		Endif	
	Endif
Return

Static Function verEstrut(cProdEmp,cOp,cProd,cNovoLote)
	Local aAreaSG1		:= SG1->(GetArea())

	DbSelectArea("SG1")
	SG1->(DbSetOrder(1))
	SG1->(DbSeek(xFilial("SG1")+cProd))

	While SG1->(!Eof()) .and. SG1->G1_COD == cProd
		cProdEmp := SG1->G1_COMP
		verRequis(cProdEmp,cOp,@cNovoLote)
		SG1->(DbSkip())
	End
	
	RestArea (aAreaSG1)
Return

Static Function verRequis(cProdEmp,cOp,cNovoLote)
	Local aAreaSD4		:= SD4->(GetArea())

	DbSelectArea("SD4")
	SD4->(DbSetOrder(2))
	SD4->(DbSeek(xFilial("SD4")+cOp+cProdEmp))

	While SD4->(!Eof()) .and. SD4->D4_OP == cOp .and. SD4->D4_COD == cProdEmp
		If !Empty(SD4->D4_LOTECTL)
			cNovoLote := SD4->D4_LOTECTL
			If Empty(M->D3_LOTECTL)
				M->D3_LOTECTL := cNovoLote
			Endif	
			Exit	
		Endif
		SD4->(DbSkip())
	End
	
	RestArea (aAreaSD4)
Return
