#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MT100LOK  � Autor � Luis Brandini    �   Data  � 26/01/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��o de linha na digita��o da Nf Entrada.		  	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT100LOK()

Local aArea    := GetArea()
Local lRetorno := .T.
Local xNfOri   := GdFieldGet("D1_NFORI",n)
Local xSeriOri := GdFieldGet("D1_SERIORI",n)
Local xItemOri := Substr(GdFieldGet("D1_ITEMORI",n),1,2)
Local xProduto := GdFieldGet("D1_COD",n)
Local xXCusto  := GdFieldGet("D1_XCUSTO",n)
Local xTes     := GdFieldGet("D1_TES",n)
Local xCFO     := GdFieldGet("D1_CF",n)
Local xQuant   := GdFieldGet("D1_QUANT",n)
Local xLocal   := GdFieldGet("D1_LOCAL",n)
Local xNfFretE := GdFieldGet("D1_XNFFRE",n)
Local xNfFretS := GdFieldGet("D1_XNFFRS",n)
Local nPosItCt := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ITEMCTA"})
Local nPosLoca := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOCAL"})
Local nLoteCtl := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTECTL"})
Local nDtValid := aScan(aHeader,{|x|Alltrim(x[2])=="D1_DTVALID"})
Local xCC      := GdFieldGet("D1_CC",n)
Local xItemCta := GdFieldGet("D1_ITEMCTA",n)
Local lBaixaCq := (GetMv("MV_XBAIXCQ") == "S")
Local cTesTrc  := AllTrim(GetMv("MV_XTESTRC")) // TES para Troca
Local cTesTrFl := AllTrim(GetMv("MV_XTESTRF")) // TES Transfer�ncia entre Filiais
Local cTesDevB := AllTrim(GetMv("MV_XTESDVB")) // TES Devolu��o de Bonifica��o
Local cCfoBlq  := AllTrim(GetMv("MV_XCFOBLQ")) // CFOP bloqueados
Local cEOL     := CHR(13)+CHR(10)

If FunName() == "MATA920" .Or. FunName() == "RPC" .Or. FunName() == "SCHEDCOMCOL"
	Return(.T.)
Endif

If FunName() == "MATA311"
	If xTes $(cTesTrFl)
		aCols[n][nPosLoca] := AllTrim(GetMv("MV_ZARMTRF")) // "95"
	Endif
	//
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + xProduto )
	//
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + xTes )
	//
	If SB1->B1_TIPO == "MP" .And. SB1->B1_RASTRO == "L" .And. SF4->F4_ESTOQUE == "S"
		aCols[n][nLoteCtl] := CNFISCAL
		aCols[n][nDtValid] := Date()
	Endif
	//
	Return(.T.)
Endif

If !(aCols[n][Len(aHeader)+1])
	If lRetorno
		If xTes $(cTesTrc) // Processo de Troca
			CTIPO    := "B"
			If CTIPO != "B"
				MsgAlert("Aten��o, para opera��o de troca � necess�rio informar o TIPO da nota fiscal = 'Beneficiamento'.")
				lRetorno := .F.
			ElseIf Empty(xNfOri) .Or. Empty(xSeriOri) .Or. Empty(xItemOri) .Or. Empty(xXCusto)
				MsgAlert("Aten��o, para opera��o de troca � necess�rio informar os dados da Nota Fiscal origem, e o custo total do item.")
				lRetorno := .F.
			Else
				DbSelectArea("SD2")
				DbSetOrder(3)
				If !DbSeek( xFilial("SD2") + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
					If !MsgYesNo("Nota Fiscal origem n�o encontrada."+CHR(13)+CHR(10)+"Deseja prosseguir ?","Aviso","INFO")
						lRetorno := .F.
					Endif
				Endif
			Endif
		ElseIf xTes $(cTesDevB) // Devolu��o de Bonifica��o (082,083,212,264,265,266)
			If CTIPO != "D"
				MsgAlert("Aten��o, para opera��o de devolu��o de bonifica��o � necess�rio informar o TIPO da nota fiscal = 'Devolu��o' e associar os itens com a nota origem.")
				lRetorno := .F.
			Endif
		ElseIf xTes $("084") // Processo Armazenagem Galp�o
			If CTIPO != "N"
				MsgAlert("Aten��o, para opera��o de armazenagem galp�o � necess�rio informar o TIPO da nota fiscal = 'Normal'.")
				lRetorno := .F.
			ElseIf Empty(xNfOri) .Or. Empty(xSeriOri) .Or. Empty(xItemOri) .Or. Empty(xXCusto)
				MsgAlert("Aten��o, para opera��o de armazenagem galp�o � necess�rio informar os dados da Nota Fiscal origem, e o custo total do item.")
				lRetorno := .F.
			Else
				DbSelectArea("SD2")
				DbSetOrder(3)
				If !DbSeek( xFilial("SD2") + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
					If !MsgYesNo("Nota Fiscal origem n�o encontrada."+CHR(13)+CHR(10)+"Deseja prosseguir ?","Aviso","INFO")
						lRetorno := .F.
					Endif
				Endif
			Endif
		ElseIf !Empty(xTes) .And. CTIPO == "N" // Processo de Importa��o = Armaz�m 98 caso o TES atualize estoque.
			lEstoqu := (RetField("SF4",1,xFilial("SF4")+xTes,"F4_ESTOQUE") == "S")
			If lBaixaCq .And. lEstoqu
				xEstado := RetField("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_EST")
				If xEstado == "EX"
					If xLocal != "98" .And. xQuant > 0
						MsgAlert("Aten��o, para opera��o de importa��o o armaz�m deve ser '98'.")
						lRetorno := .F.
					Endif
				Endif
			Endif	
		ElseIf CTIPO $("B,D")
			DbSelectArea("SD2")
			DbSetOrder(3)
			If !DbSeek( xFilial("SD2") + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
				If !MsgYesNo("Nota Fiscal origem n�o encontrada."+CHR(13)+CHR(10)+;
							 "Acesse 'Outras A��es -> Origem' para selecionar os documentos de sa�da."+CHR(13)+CHR(10)+;
							 "Deseja prosseguir com a numera��o digitada ?","Aviso","INFO")
					lRetorno := .F.
				Endif
			Endif
		Endif
	Endif	
	//
	If AllTrim(xProduto) $ ("DESPFEL_0023,DESPESA_0055")
		If Empty(xNfFretE) .And. Empty(xNfFretS)
			MsgAlert("Aten��o, para compra de frete � obrigat�rio informar o Doc.Frete"+cEOL+"(sa�da ou entrada).")
			lRetorno := .F.
		ElseIf !Empty(xNfFretE) .And. !Empty(xNfFretS)
			MsgAlert("Aten��o, para compra de frete � obrigat�rio informar apenas 1 Doc.Frete"+cEOL+"(sa�da ou entrada).")
			lRetorno := .F.
		ElseIf AllTrim(xNfFretE) != "MANUAL" .And. !Empty(xNfFretE)
			DbSelectArea("SD1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SD1") + xNfFretE )
				MsgAlert("Aten��o, nota fiscal origem frete (Doc.Frete Entrada) n�o localizada.")
				lRetorno := .F.
			Endif
		ElseIf AllTrim(xNfFretS) != "MANUAL" .And. !Empty(xNfFretS)
			DbSelectArea("SD2")
			DbSetOrder(3)
			If !DbSeek( xFilial("SD2") + xNfFretS )
				MsgAlert("Aten��o, nota fiscal origem frete (Doc.Frete Sa�da) n�o localizada.")
				lRetorno := .F.
			Endif
		Endif
	Endif
	//
	If lRetorno
		If !Empty(xCC)
			If Empty(xItemCta)
				If CTIPO != "N"
                	aCols[n][nPosItCt] := RetField("CTT",1,xFilial("CTT")+xCC,"CTT_ZZITCT")
				Else
					MsgAlert("Aten��o, BU n�o informado.")
					lRetorno := .F.
				Endif
			Endif	
		Endif
	Endif
	//
	If lRetorno
		If !Empty(xCFO)
			If AllTrim(xCFO) $(cCfoBlq)
				MsgAlert("Aten��o, CFOP "+AllTrim(xCFO)+" bloqueado pela ger�ncia.")
				lRetorno := .F.
			Endif	
		Endif
	Endif
Endif

RestArea(aArea)

Return(lRetorno)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � XCUSD2    � Autor � Luis Brandini    �   Data  � 26/01/17  ���
��+----------+------------------------------------------------------------���
���Descricao � Busca o custo da nota fiscal de sa�da origem.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function XCUSD2(nCpo)

Local xNfOri   := IIf(nCpo == 1,M->D1_NFORI,GdFieldGet("D1_NFORI",n))
Local xSeriOri := IIf(nCpo == 2,M->D1_SERIORI,GdFieldGet("D1_SERIORI",n))
Local xItemOri := Substr(IIf(nCpo == 3,M->D1_ITEMORI,GdFieldGet("D1_ITEMORI",n)),1,2)
Local xProduto := GdFieldGet("D1_COD",n)
Local xTes     := GdFieldGet("D1_TES",n)
Local xQuant   := GdFieldGet("D1_QUANT",n)
Local cTesTrc  := AllTrim(GetMv("MV_XTESTRC")) // TES para Troca
Local nPosCC   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CC"})
Local nPosBU   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ITEMCTA"})
Local nPosLC   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOCAL"})
Local nPosLT   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTECTL"})
Local nPosDL   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_DTVALID"})
Local nRetorno := 0

If !(aCols[n][Len(aHeader)+1])
	If xTes $("084,"+cTesTrc) // Troca / Armazenagem Galp�o
		DbSelectArea("SD2")
		DbSetOrder(3)
		If DbSeek( xFilial("SD2") + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
			nRetorno := xQuant * (SD2->(D2_CUSTO1/D2_QUANT))
		Endif
	Else
		DbSelectArea("SD2")
		DbSetOrder(3)
		If !DbSeek( xFilial("SD2") + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
			lFoundNf := .F.
			If cFilAnt == "0108"
				zFilInc := "0104"
				If DbSeek( zFilInc + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
					lFoundNf := .T.
				Endif
			ElseIf cFilAnt == "0107"
				zFilInc := "0108"	
				If DbSeek( zFilInc + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
					lFoundNf := .T.
				Else
					zFilInc := "0104"
					If DbSeek( zFilInc + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
						lFoundNf := .T.
					Endif
				Endif
			ElseIf cFilAnt == "0106"
				zFilInc := "0103"	
				If DbSeek( zFilInc + xNfOri + xSeriOri + CA100FOR + CLOJA + xProduto + xItemOri )
					lFoundNf := .T.
				Endif
			Endif	
			If lFoundNf
				MsgInfo("Nota Fiscal localizada na filial origem de incorpora��o: "+zFilInc)
				nRetorno := xQuant * (SD2->(D2_CUSTO1/D2_QUANT))
				aCols[n][nPosCC] := SD2->D2_CCUSTO
				aCols[n][nPosBU] := SD2->D2_ITEMCC
				aCols[n][nPosLC] := SD2->D2_LOCAL
				aCols[n][nPosLT] := SD2->D2_LOTECTL
				aCols[n][nPosDL] := SD2->D2_DTVALID
			Endif
		Endif
	Endif
Endif

Return(nRetorno)
