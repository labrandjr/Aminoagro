#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DESMAUT   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 07/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processo de automatização da rotina de Desmontagem.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DESMAUT(cProduto,nQtdOrig,oGet)

Local aArea      := GetArea()
Local aEstrutura := {}
Local i          := 0
Local nx         := 0
Local lContinua  := .T.      
Local nPosAliWt  := GDFieldPos("D3_ALI_WT")
Local nPosCod    := GDFieldPos("D3_COD")
Local lCtrWMS    := SB5->(FieldPos("B5_CTRWMS")) > 0
Local oProduto   := Nil	
Local lDesmAut   := ( AllTrim(GetMv("MV_DESMAUT")) == "S" )
Local lRateMod   := ( AllTrim(GetMv("MV_RATEMOD")) == "S" )
Local nModoRat   := GetMv("MV_MODORAT") // 1=Formação de Preços | 2=Último Apontamento
Private nEstru   := 0
Private aLastOp  := {} // Personalização %Rateio
Private aRateio  := {}
Private aHeadBk  := aClone(aHeader)

If !lDesmAut
	Return
Endif

A242Explod(cProduto,nQtdOrig,@aEstrutura)

// Se o produto tiver estrutura cria um novo aCols
If Len(aEstrutura) > 0
	aCols:={}
Else
	MsgInfo("Produto sem estrutura cadastrada.")
	Return
Endif

If nModoRat == 2 // Rateia pelo Último Apontamento de Produção
	aLastOp := u_LastOp(cProduto) // Personalização %Rateio
Endif	

If Len(aLastOp) == 0
	If __cUserId == "000000"
		MsgInfo("Serão utilizados os percentuais da Planilha de Formação de Preços (AMINOAGR.PDV)")
	Endif	
	aLastOp := _FormaPrc(cProduto)
Else
	If __cUserId == "000000"
		MsgInfo("Serão utilizados os percentuais do último Apontamento de Produção.")
	Endif	
Endif

// Custo total da Op
nCusTot := 0
nPosPr0 := aScan(aLastOp, {|x| x[2] == "PR0"})
If nPosPr0 > 0
	nCusTot := aLastOp[nPosPr0][3]
Endif
// Define o PI
cPrdPI := ""
nPosPI := aScan(aLastOp, {|x| AllTrim(x[4]) == "L" .And. x[2] != "PR0"})
If nPosPI > 0
	cPrdPI := aLastOp[nPosPI][1]
Endif

If nCusTot > 0 .And. !Empty(cPrdPI)
	For i:= 1 to Len(aEstrutura)
		cPrd := aEstrutura[i,3]
		nPer := 0
		xPer := 0
		nPos := aScan(aLastOp, {|x| x[1] == cPrd})
		If nPos > 0
			nPer := Round(((aLastOp[nPos][3] / nCusTot) * 100),2)
			xPer := ((aLastOp[nPos][3] / nCusTot) * 100)
		Endif
		If (Substr(cPrd,1,3) != "MOD") .Or. (Substr(cPrd,1,3) == "MOD" .And. lRateMod)
			AAdd(aRateio,{cPrd, nPer, xPer})
		Else
			// %MOD atribui para o PI
			nPosPI := aScan(aRateio, {|x| x[1] == cPrdPI})
			If nPosPI > 0
				aRateio[nPosPI][2] += nPer
				aRateio[nPosPI][3] += xPer
			Else
				AAdd(aRateio,{cPrdPI, nPer, xPer})
			Endif
		Endif	
	Next i
	// Valida 100%. Atribui diferença aos itens não usados na produção (caso hajam)
	nTotRat := 0
	nDivide := 0
	For i:= 1 to Len(aRateio)
		nTotRat += aRateio[i][2]
		nDivide += IIf(aRateio[i][3] == 0,1,0)
	Next i
	nTotDif := 100 - nTotRat
	If nTotDif < 0
		// Ajusta no PI
		nTotDif := ABS(nTotDif)
		nPosPI  := aScan(aRateio, {|x| x[1] == cPrdPI})
		If nPosPI > 0
			aRateio[nPosPI][2] -= nTotDif
			aRateio[nPosPI][3] -= nTotDif
		Else // Caso não haja PI, ajusta no 1o.item da estrutura
			aRateio[1][2] -= nTotDif
			aRateio[1][3] -= nTotDif
		Endif
	ElseIf nTotDif > 0
		If nDivide > 0
			If nTotDif == 0.01
				nResto := 0.01
			Else
				nResto := nTotDif / nDivide
			Endif	
			For i:= 1 to Len(aRateio)
				If aRateio[i][3] == 0
					aRateio[i][2] := nResto
					aRateio[i][3] := nResto
					nTotRat += nResto
					If nTotRat == 100
						Exit
					Endif
				Endif
			Next i
		Else
			// Ajusta no PI
			nPosPI := aScan(aRateio, {|x| x[1] == cPrdPI})
			If nPosPI > 0
				aRateio[nPosPI][2] += nTotDif
				aRateio[nPosPI][3] += nTotDif
			Else // Caso não haja PI, ajusta no 1o.item da estrutura
				aRateio[1][2] += nTotDif
				aRateio[1][3] += nTotDif
			Endif
		Endif
	Endif
Endif

// Le somente os itens de primeiro nivel
aHeader := aClone(aHeadBk)
For i:=1 to Len(aEstrutura)
	If Substr(aEstrutura[i,3],1,3) == "MOD" .And. !lRateMod
		Loop
	Endif
	// Adiciona item no acols
	AAdd(aCols,Array(Len(aHeader)+1))
	// Preenche conteudo do acols
	For nx := 1 to Len(aHeader)
		cCampo := Alltrim(aHeader[nx,2])
		If IsHeadRec(cCampo)
			aCols[Len(aCols)][nx] := 0
		ElseIf IsHeadAlias(cCampo)
			aCols[Len(aCols)][nx] := "SD3"
		Else
			aCols[Len(aCols)][nx] := CriaVar(cCampo,.F.)
		Endif
	Next nx
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	// Preenche campos especificos
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+aEstrutura[i,3]))
	GDFieldPut("D3_COD",aEstrutura[i,3],Len(aCols))
	GDFieldPut("D3_QUANT",aEstrutura[i,4],Len(aCols))
	GDFieldPut("D3_LOCAL",RetFldProd(SB1->B1_COD,"B1_LOCPAD"),Len(aCols))
	GDFieldPut("D3_QTSEGUM",ConvUm(aEstrutura[i,3],aEstrutura[i,4],0,2),Len(aCols))
	// Personalização %Rateio
	nRateio := 0
	nPosRat := aScan(aRateio, {|x| x[1] == aEstrutura[i,3]})
	If nPosRat > 0
		nRateio := aRateio[nPosRat][2]
	Endif
	GDFieldPut("D3_RATEIO",nRateio,Len(aCols))
	//	
Next i
oGet:ForceRefresh()

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LastOp    ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 15/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Captura dados da última OP (período fechado).			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LastOp(cProduto)

Local aRetorno := {}
Local cUlMes   := DtoS(GetMv("MV_ULMES"))

cQuery := " SELECT D3_OP "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += " AND D3_COD = '"+cProduto+"' "
cQuery += " AND D3_OP <> ' ' "
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_CF = 'PR0' "
cQuery += " AND D3_EMISSAO < '"+cUlMes+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D3_EMISSAO DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

DbSelectArea("SQL1")
SQL1->(DbGotop())
If !Eof()

	cOp := SQL1->D3_OP

	cQuery := " SELECT D3_COD, D3_CF, D3_CUSTO1, D3_UM "
	cQuery += " FROM "+RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	cQuery += " AND D3_OP = '"+cOp+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY D3_FILIAL, D3_CF "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

	DbSelectArea("SQL2")
	SQL2->(DbGotop())
	While !Eof()
		lAdd := .F.
		If Len(aRetorno) == 0
			lAdd := .T.
		Else
			nPos := aScan(aRetorno, {|x| x[1] == SQL2->D3_COD})
			If nPos > 0
				aRetorno[nPos][3] += SQL2->D3_CUSTO1
			Else
				lAdd := .T.
			Endif
		Endif	
		If lAdd
			AAdd(aRetorno,{SQL2->D3_COD, SQL2->D3_CF, SQL2->D3_CUSTO1, SQL2->D3_UM})
		Endif
		SQL2->(DbSkip())
	Enddo
	SQL2->(DbCloseArea())

Endif
SQL1->(DbCloseArea())

Return(aRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A242Explod³ Autor ³Anieli Rodrigues        ³ Data ³25.03.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao recursiva para localizar todos os componentes do 	   ³±±
±±³          ³ primeiro nivel da estrutura.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto Pai                               ³±±
±±³          ³ ExpN1 = Quantidade do produto Pai                           ³±±
±±³          ³ ExpA1 = aArray de retorno                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA242                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A242Explod(cProduto,nQuant,aNewStruct)
Local nX		     := 0
Local aAreaAnt	 := GetArea()
Local aArrayAux  := {}

Default cProduto := ""
Default nQuant	 := 0

nEstru := 0

aArrayAux := Estrut(cProduto,nQuant,.T.)

dbSelectArea("SB1")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Processa todos os componentes do 1 nivel da estrutura,  |
//| verificando a existencia de produtos fantasmas.         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aArrayAux)
	If MsSeek(xFilial("SB1")+aArrayAux[nx,3]) //Filial+Componente
		If RetFldProd(SB1->B1_COD,"B1_FANTASM") $ "S" // Projeto Implementeacao de campos MRP e FANTASM no SBZ
			A242Explod(aArrayAux[nx,3],aArrayAux[nx,4],aNewStruct) //Componente+Qtde
		Else
			aAdd(aNewStruct,aArrayAux[nx])
		EndIf
	EndIf
Next nX

RestArea(aAreaAnt)
Return Nil

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _FormaPrc ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 28/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calcula percentais baseado na Formação de Preços.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _FormaPrc(cProduto)

Local aArea  := GetArea()
Local aRetOk := {}
Local aArray := {}
Local _x

aArray := u_ProcCalc(cProduto)
If Len(aArray) > 0
	AAdd(aRetOk,{ cProduto, "PR0", 100, RetField("SB1",1,xFilial("SB1")+cProduto,"B1_UM") })
	For _x := 1 to Len(aArray)
		If AllTrim(aArray[_x][2]) == "2"
			cProduto := aArray[_x][4]
			nCustoFp := Round(aArray[_x][7],2)
			AAdd(aRetOk,{ cProduto, "RE1", nCustoFp, RetField("SB1",1,xFilial("SB1")+cProduto,"B1_UM") })
		Endif
	Next _x
Endif

RestArea(aArea)

Return(aRetOk)
