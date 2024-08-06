#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT100TOK  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 06/06/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação de inclusão de nota fiscal com FIN sem Pedido.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT100TOK()

Local aArea    := GetArea()
Local lRetorno := .T.
Local zTotNfis := 0
Local zTotImpo := 0
Local zTotIrrf := 0
Local zTotPcc  := 0
Local aTiposPr := {}
Local lDuplica := .F.
Local lErrPrc  := .F.
Local zServWms := aScan(aHeader,{|x|Alltrim(x[2])=="D1_SERVIC"})
Local zEndeIni := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ENDER"})
Local zTpEstru := aScan(aHeader,{|x|Alltrim(x[2])=="D1_TPESTR"})
Local zDsEstru := aScan(aHeader,{|x|Alltrim(x[2])=="D1_DESEST"})
Local zLoteCtl := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTECTL"})
Local zDtValid := aScan(aHeader,{|x|Alltrim(x[2])=="D1_DTVALID"})
Local lInteWms := GetMv("MV_INTWMS")
Local lRatCsv  := GetMv("MV_ZRATCSV")
Local cEOL     := CHR(13)+CHR(10)
Local zFunName := "TMSA050,MATA920,SPEDNFE,MATA311,COMXCOL"
Local aFilAtu  := FWArrFilAtu("G1")
Local lQualy   := ( Substr(aFilAtu[18],1,8) == "08909993" )
Local lCt1Rat  := CT1->(FieldPos("CT1_ZRATOB")) > 0 
Local _p
Local _z
Local _x

If FunName() $ zFunName
	Return(.T.)
Endif

zzNFiscal := RTrim(CNFISCAL)
For _p := 1 to Len(zzNFiscal)
	zChar := Substr(zzNFiscal,_p,1)
	If Empty(zChar)
		MsgInfo("O número do documento possui espaços em branco !!")
		Return(.F.)
	Endif
Next _p

zzSerieNf := RTrim(CSERIE)
For _p := 1 to Len(zzSerieNf)
	zChar := Substr(zzSerieNf,_p,1)
	If Empty(zChar)
		MsgInfo("A série do documento possui espaços em branco !!")
		Return(.F.)
	Endif
Next _p

If Empty(CESPECIE)
	MsgInfo("A Espécie do documento não foi informada !!")
	Return(.F.)
Endif

// Valida rateio
If lRatCsv .And. lCt1Rat
	lRatOk := .T.
	For _z := 1 to Len(aCols)
		If !(aCols[_z][Len(aHeader)+1])
			zItem  := GdFieldGet("D1_ITEM",_z)
			zConta := GdFieldGet("D1_CONTA",_z)
			lRatOb := Posicione("CT1",1,xFilial("CT1")+zConta,"CT1_ZRATOB")=="S"
			If lRatOb
				nPos := aScan(aBackColsSde, {|x| x[1] == zItem })
				If nPos == 0 .And. AllTrim(CESPECIE) != "CTE"
					If !MsgYesNo("Item "+AllTrim(zItem)+": rateio para a conta contábil "+AllTrim(zConta)+" não informado. Deseja prosseguir ?")
						lRatOk := .F.
						Exit
					Endif	
				Endif
			Endif
		Endif
	Next _z		
	If !lRatOk
		Return(.F.)
	Endif
Endif

// Preenche o lote nas matérias-primas
For _z := 1 to Len(aCols)
	If !(aCols[_z][Len(aHeader)+1])
		zProduto := GdFieldGet("D1_COD",_z)
		zTes     := GdFieldGet("D1_TES",_z)
		//	
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + zProduto )
		//
		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( xFilial("SF4") + zTes )
		//
		If SB1->B1_TIPO == "MP" .And. SB1->B1_RASTRO == "L" .And. SF4->F4_ESTOQUE == "S"
			aCols[_z][zLoteCtl] := CNFISCAL
			aCols[_z][zDtValid] := Date()
		Endif
	Endif
Next _z

If lInteWms // Integração Wms
	For _z := 1 to Len(aCols)
		If !(aCols[_z][Len(aHeader)+1])
			zProduto := GdFieldGet("D1_COD",_z)
			zArmazem := GdFieldGet("D1_LOCAL",_z)
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + zProduto )
			If (SB1->B1_TIPO == "MP" .And. zArmazem $("01")); // Compra de MP
			   .Or.;
			   (SB1->B1_TIPO == "PA" .And. zArmazem $("11")) // Troca de PA
				DbSelectArea("SBZ")
				DbSetOrder(1)
				If DbSeek( xFilial("SBZ") + zProduto )
					If SBZ->BZ_LOCALIZ == "S"
						aCols[_z][zServWms] := "003" // Serviço de Recebimento p/ Endereçamento automático no Wms
						aCols[_z][zEndeIni] := "BOX1-01-00-01" // Endereço Inicial p/ Endereçamento automático no Wms
						aCols[_z][zTpEstru] := "000006" // Estrutura Física p/ Endereçamento automático no Wms
						aCols[_z][zDsEstru] := "BOX E DOCA" // Descrição da Estrutura Física p/ Endereçamento automático no Wms
					Endif
				Endif
			Endif
		Endif
	Next _z
Endif

If lQualy .And. AllTrim(CESPECIE) != "CTE"
	lAliqOk := .T.
	For _z := 1 to Len(aCols)
		If !(aCols[_z][Len(aHeader)+1])
			xProdut := GdFieldGet("D1_COD",_z)
			xTipEnt := GdFieldGet("D1_TES",_z)
			DbSelectArea("SF4")
			DbSetOrder(1)
			If DbSeek( xFilial("SF4") + xTipEnt )
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek( xFilial("SB1") + xProdut )
				If SB1->B1_ZALQZER == "S" // Alíquota Zero = Sim
					If SF4->F4_PISCRED != "4" // 4 = Calcula (Alíquota Zero)
						MsgAlert("Produto "+AllTrim(xProdut)+" configurado com Alíquota Zero."+cEOL+;
						 		 "Verifique o código correto do TES a ser utilizado com Depto.Fiscal.")
						lAliqOk := .F.
						Exit
					Endif
				Endif
				If lAliqOk
					If SF4->F4_PISCRED == "4" // 4 = Calcula (Alíquota Zero)
						If SB1->B1_ZALQZER != "S" // Alíquota Zero # Sim
							MsgAlert("Produto "+AllTrim(xProdut)+" não configurado com Alíquota Zero."+cEOL+;
							 		 "Verifique o código correto do TES a ser utilizado com Depto.Fiscal.")
							lAliqOk := .F.
							Exit
						Endif
					Endif
				Endif
			Endif
		Endif		
	Next _z
	If !lAliqOk
		Return(.F.)
	Endif
Endif

If CTIPO == "N"
	//
	DbSelectArea("SA2")
	DbSetOrder(1)
	If DbSeek( xFilial("SA2") + CA100FOR + CLOJA )
		If SA2->A2_QUALI == "2"
			MsgAlert("Fornecedor desqualificado. Contate o depto. de compras.")
			Return(.F.)
		Endif
	Endif
    //
	For _z := 1 to Len(aCols)
		If !(aCols[_z][Len(aHeader)+1])
			xProdut := GdFieldGet("D1_COD",_z)
			xPedido := GdFieldGet("D1_PEDIDO",_z)
			xItemPc := GdFieldGet("D1_ITEMPC",_z)
			xVlUnit := GdFieldGet("D1_VUNIT",_z)
			xTipEnt := GdFieldGet("D1_TES",_z)
			xValIrr := GdFieldGet("D1_VALIRR",_z)
			xValPis := GdFieldGet("D1_VALPIS",_z)
			xValCof := GdFieldGet("D1_VALCOF",_z)
			xTipoPr := RetField("SB1",1,xFilial("SB1")+xProdut,"B1_TIPO")
			xDuplic := RetField("SF4",1,xFilial("SF4")+xTipEnt,"F4_DUPLIC")
			xEstoqu := RetField("SF4",1,xFilial("SF4")+xTipEnt,"F4_ESTOQUE")
			xEstado := RetField("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_EST")
			// Valida documento de entrada sem pedido de compras
			If DtoS(Date()) < AllTrim(GetMv("MV_XTOLEPC"))
				// Importação
				If xEstoqu == "S" .And. xEstado == "EX" .And. Empty(xPedido) .And. xTipoPr == "MP"
					zTotImpo += GdFieldGet("D1_TOTAL",_z)
				// Outras Compras
				ElseIf xDuplic == "S" .And. Empty(xPedido) .And. xTipoPr $("MP,AI")
					zTotNfis += GdFieldGet("D1_TOTAL",_z)
				Endif
			Else
				// Importação
				If xEstoqu == "S" .And. xEstado == "EX" .And. Empty(xPedido)
					zTotImpo += GdFieldGet("D1_TOTAL",_z)
				// Outras Compras
				ElseIf xDuplic == "S" .And. Empty(xPedido) //.And. xTipoPr $("MP,AI")
					zTotNfis += GdFieldGet("D1_TOTAL",_z)
				Endif
			Endif	
			// Valida documento de entrada sem código de retenção p/ DIRF - IRRF
			If xDuplic == "S" .And. xValIrr > 0
				zTotIrrf += xValIrr
			Endif
			// Valida documento de entrada sem código de retenção p/ DIRF - Pis/Cofins
			If xDuplic == "S" .And. (xValPis > 0 .Or. xValCof > 0)
				zTotPcc += (xValPis + xValCof)
			Endif
			// Valida preço unitário em R$ menor ou igual USD
			If !lErrPrc
				DbSelectArea("SC7")
				DbSetOrder(1)
				If DbSeek( xFilial("SC7") + xPedido + xItemPc )
					If SC7->C7_MOEDA > 1
						If Round(SC7->(C7_PRECO*C7_TXMOEDA),5) == xVlUnit
				 			lErrPrc := .T.			
						Endif
					Endif
				Endif
			Endif	
		Endif		
	Next _z
Endif

If DtoS(Date()) < AllTrim(GetMv("MV_XTOLEPC"))
	If zTotImpo > 0
		MsgAlert("Atenção, para importação de MP é obrigatório utilizar Pedido de Compra aprovado.")
		lRetorno := .F.
	ElseIf zTotNfis >= 2000
		MsgAlert("Atenção, para compras a partir de R$ 2.000,00 (produtos do tipo MP e AI) é obrigatório utilizar Pedido de Compra aprovado.")
		lRetorno := .F.
	Endif
Else
	If zTotImpo > 0
		MsgAlert("Atenção, para importação de MP é obrigatório utilizar Pedido de Compra aprovado.")
		lRetorno := .F.
	ElseIf zTotNfis > 0
		MsgAlert("Atenção, é obrigatório utilizar Pedido de Compra aprovado.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	If lErrPrc
		If !MsgYesNo("Atenção, revise o 'Vlr.Unitario' em R$ pois o Pedido de Compra associado foi inserido em outra Moeda."+cEOL+;
					 "Confirma PTAX idêntica ao Pedido ?","Aviso","INFO")
			lRetorno := .F.
		Endif	
	Endif
Endif

If lRetorno
	If zTotIrrf > 0
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SF1")
		cQuery += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' "
		cQuery += " AND F1_DOC = '"+CNFISCAL+"' "
		cQuery += " AND F1_SERIE = '"+CSERIE+"' "
		cQuery += " AND F1_STATUS <> ' ' "
		cQuery += " AND F1_VALIRF > 0 "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		lExNfIrf := ( SQL->SOMA > 0 )
		SQL->(DbCloseArea())
		If lExNfIrf
			MsgAlert("Atenção, Documento+Série com retenção de Ir já existe para outro fornecedor."+cEOL+;
					 "Modifique a 'Série' para prosseguir.")
			lRetorno := .F.
		Endif
	Endif
Endif

If lRetorno
	If zTotPcc > 0
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SF1")
		cQuery += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' "
		cQuery += " AND F1_DOC = '"+CNFISCAL+"' "
		cQuery += " AND F1_SERIE = '"+CSERIE+"' "
		cQuery += " AND F1_STATUS <> ' ' "
		cQuery += " AND ((F1_VALPIS > 0) OR (F1_VALCOFI > 0)) "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		lExNfPcc := ( SQL->SOMA > 0 )
		SQL->(DbCloseArea())
		If lExNfPcc
			MsgAlert("Atenção, Documento+Série com retenção de Pis/Cofins já existe para outro fornecedor."+cEOL+;
					 "Modifique a 'Série' para prosseguir.")
			lRetorno := .F.
		Endif
	Endif
Endif

If lRetorno
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SF1")
	cQuery += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' "
	cQuery += " AND F1_DOC = '"+CNFISCAL+"' "
	cQuery += " AND F1_FORNECE = '"+CA100FOR+"' "
	cQuery += " AND F1_STATUS = 'A' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	lExNfFor := ( SQL->SOMA > 0 )
	SQL->(DbCloseArea())
	If lExNfFor
		If !MsgYesNo("Atenção, já existe um documento de entrada '"+AllTrim(CNFISCAL)+"' para este fornecedor."+cEOL+;
					"Deseja prosseguir ?","Aviso","INFO")
			lRetorno := .F.
		Endif	
	Endif
Endif	

If lRetorno
	zChvNfe := aNfeDanfe[13]
	If !Empty(zChvNfe)
		cQuery := " SELECT F1_DOC DOC, F1_SERIE SERIE, F1_FORNECE FORNECE "
		cQuery += " FROM "+RetSqlName("SF1")
		cQuery += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' "
		cQuery += " AND F1_CHVNFE = '"+AllTrim(zChvNfe)+"' "
		cQuery += " AND F1_STATUS = 'A' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		SQL->(DbGotop())
		If !Eof()
			If !MsgYesNo("Atenção, já existe um documento de entrada com a mesma Chave NFE."+cEOL+;
						"Documento/Série: "+AllTrim(SQL->DOC)+" / "+AllTrim(SQL->SERIE)+cEOL+;
						"Fornecedor: "+SQL->FORNECE+"-"+AllTrim(RetField("SA2",1,xFilial("SA2")+SQL->FORNECE,"A2_NOME"))+cEOL+;
						"Deseja prosseguir ?","Aviso","INFO")
				lRetorno := .F.
			Endif	
		Endif
		SQL->(DbCloseArea())
	Endif	
Endif

If lRetorno
	If zTotIrrf > 0 .And. (CDIRF != "1" .Or. Empty(CCODRET))
		MsgAlert("Atenção, a nota fiscal possui retenção de IR e não foram informados dados para DIRF adequadamente (aba 'Impostos')."+cEOL+;
				 "Gera Dirf = Sim"+cEOL+;
				 "Cd. Retenção = Informe o código da retenção")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	If CTIPO $("N,C")
		For _z := 1 to Len(aCols)
			If !(aCols[_z][Len(aHeader)+1])
				xProdut := GdFieldGet("D1_COD",_z)
				xTipoPr := RetField("SB1",1,xFilial("SB1")+xProdut,"B1_TIPO")
				xTipEnt := GdFieldGet("D1_TES",_z)
				xDuplic := RetField("SF4",1,xFilial("SF4")+xTipEnt,"F4_DUPLIC")
				// Valida natureza financeira conforme tipo de produto
				If !lDuplica
					lDuplica := (xDuplic == "S")
				Endif
				If Len(aTiposPr) == 0
					AAdd(aTiposPr,xTipoPr)
				Else
					nPos := aScan(aTiposPr, {|x| x == xTipoPr })
					If nPos == 0
						AAdd(aTiposPr,xTipoPr)
					Endif
				Endif
			Endif		
		Next _z
		//
		If lDuplica
			For _x := 1 to Len(aTiposPr)
				zTipo := aTiposPr[_x]
				DbSelectArea("SZF")
				DbSetOrder(1)
				If DbSeek( xFilial("SZF") + zTipo )
					If !DbSeek( xFilial("SZF") + zTipo + SED->ED_CODIGO )
						MsgInfo("Atenção, a natureza informada não pode ser utilizada na entrada de produtos com Tipo = '"+zTipo+"'.")
						lRetorno := .F.
						Exit
					Endif
				Endif
			Next _x
		Endif
		//
	Endif
Endif

RestArea(aArea)

Return(lRetorno)
