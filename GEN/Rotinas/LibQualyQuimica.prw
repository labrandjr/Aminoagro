#include 'totvs.ch'

/*/{Protheus.doc} LibQualyQuimica

Biblioteca QualyQuimica

@author Gustavo Luiz
@since 14/03/2016

/*/
CLASS LibQualyQuimica
	
	Data nomCampoSB1 	As String	//Nome do campo SB1
	Data nomCampoSBZ 	As String	//Nome do campo SBZ
	Data codigoProduto	AS String	//Código do Produto
	
	METHOD New() CONSTRUCTOR
	METHOD GetSB1SBZ(nomCampoSB1,nomCampoSBZ,codigoProduto)	//Obtém os campos SB1 e SBZ
	METHOD isSale()	//Verificar se é venda
	METHOD isEstq()	//Verificar se movimenta estoque
	METHOD GetConteudArquivo()
	
ENDCLASS

/****************************************************************************************************/
// Método	: New
// Desc.	: Construtor
METHOD New() CLASS LibQualyQuimica
	
	::nomCampoSB1	:= ""
	::nomCampoSBZ	:= ""
	::codigoProduto	:= ""
	
Return

METHOD GetConteudArquivo(oImpArq, nI, cCampo) CLASS LibQualyQuimica

	Local nPosicao	:= ""
	Local xValor	:= Nil
	nPosicao		:= aScan(oImpArq:aCabec,cCampo)
	
	If nPosicao>0
		xValor := oImpArq:aData[nI][nPosicao]
	Else
		xValor := ""
	EndIf
	
Return xValor

METHOD GetSB1SBZ(nomCampSB1,nomCampSBZ,codigoProduto) CLASS LibQualyQuimica
	
	Local cRegistro := ""
	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSBZ	:= SBZ->(GetArea())
	Local lSBZ		:= .F.
	Local lSB1		:= .F.
	
	lSBZ:=ExistField("SBZ",nomCampSBZ)
	lSB1:=ExistField("SB1",nomCampSB1)
	
	If lSBZ .AND. lSB1
	
	 SBZ->(dbSetOrder(1))
	 
	  if SBZ->(MsSeek(xFilial("SBZ")+codigoProduto))
	  	cRegistro:=&("SBZ->" + nomCampSBZ)
	  ElseiF SB1->(MsSeek(xFilial("SB1")+codigoProduto))
	  	cRegistro:=&("SB1->" + nomCampSB1)
	  Endif
		
	EndIf
	SBZ->(RestArea(aAreaSBZ))
	SB1->(RestArea(aAreaSB1))
	RestArea(aArea)
	
Return cRegistro

method isSale() class LibQualyQuimica
	
	local aArea		:= GetArea()
	local aAreaSB1	:= SB1->(GetArea())
	local aAreaSF4	:= SF4->(GetArea())
	local cTipoProd := ""
	local lVenda	:= .T.
	local lMovFin	:= .f.
	
	if funName() == 'MATA410'
		cTipoProd := RetField("SB1",1,xFilial("SB1")+AllTrim(aCols[1,GdFieldPos("C6_PRODUTO")]),"B1_TIPO")
		dbSelectArea("SF4")
		dbSetOrder(1)
		if SF4->(dbSeek(xFilial("SF4")+gdFieldGet("C6_TES")))
			if (SF4->F4_ESTOQUE == 'S' .and. SF4->F4_DUPLIC = 'S')
				lMOvFin := .T.
			endIf
		endIf
		lVenda	:= ( M->C5_TIPO == 'N' .And. cTipoProd != 'SV' .And. Empty(M->C5_ZZTPBON) .And. lMovFin )
	endIf
	
	restArea(aAreaSF4)
	restArea(aAreaSB1)
	restArea(aArea)
	
return lVenda 

method isEstq() class LibQualyQuimica
	
	local aArea		:= GetArea()
	local aAreaSF4	:= SF4->(GetArea())
	local lEstoq	:= .F.
	
	if funName() == 'MATA410'
		dbSelectArea("SF4")
		dbSetOrder(1)
		If SF4->(dbSeek(xFilial("SF4")+gdFieldGet("C6_TES")))
			if SF4->F4_ESTOQUE == 'S'
				lEstoq := .T.
			endIf
		endIf
	endIf
	
	restArea(aAreaSF4)
	restArea(aArea)
	
return lEstoq

/**
* Função para verificar se o campo existe
**/
Static Function ExistField(cAlias, cCampo)
	
	Local lExist := .F.
	lExist:= (cAlias)->(FieldPos(cCampo))>0
	
Return lExist
