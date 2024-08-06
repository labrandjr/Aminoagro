#include "protheus.ch"
#include "fwmvcdef.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CADSZ5   ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 06/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cadastro de Faixas de Aprovação.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CADSZ5()

Local oBrowse       
	
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SZ5")
oBrowse:SetDescription("Cadastro de Faixas de Aprovação")

oBrowse:AddLegend("Z5_ATIVO == 'S' .And. Z5_VALID >= dDatabase", "GREEN", "Ativo")
oBrowse:AddLegend("Z5_ATIVO == 'N'", "RED", "Inativo")
oBrowse:AddLegend("Z5_ATIVO == 'S' .And. Z5_VALID < dDatabase", "YELLOW", "Vencido")
	
oBrowse:Activate()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ MenuDef  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 06/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Definição das opções do menu.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function MenuDef()

Local aRotina := {}
	
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.CadSZ5" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.CadSZ5" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.CadSZ5" OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.CadSZ5" OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.CadSZ5" OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE "Copiar"     ACTION "VIEWDEF.CadSZ5" OPERATION 9 ACCESS 0

Return aRotina

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ModelDef ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 06/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Modelo de definição.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ModelDef()

Local oStruZ5 := FWFormStruct(1,"SZ5")
Local oModel
	
oStruZ5:SetProperty("Z5_CODIGO", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == 3 })

oModel := MPFormModel():New("SZ5Mod")
oModel:AddFields("SZ5MASTER",,oStruZ5)

oModel:SetPrimaryKey({"Z5_FILIAL","Z5_CODIGO","Z5_ATIVO","Z5_VALID"})
oModel:SetDescription("Faixas de Aprovação")
oModel:GetModel("SZ5MASTER"):SetDescription("Faixas de Aprovação")

Return oModel

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ViewDef  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 06/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Definição de visualização.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ViewDef()

Local oModel   := FWLoadModel("CadSZ5")
Local oStruSZ5 := FWFormStruct(2,"SZ5")
Local oView  
	
oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_SZ5", oStruSZ5, "SZ5MASTER")

oView:CreateHorizontalBox("TELA",100)
oView:SetCloseOnOk({||.T.})
oView:SetOwnerView("VIEW_SZ5","TELA")

Return oView

/*
#define CPOSCABEC "|Z5_CODIGO|Z5_DESC|Z5_VALID|Z5_ATIVO|"

//-------------------------------------------------------------------
//{Protheus.doc} CadSZ5

Cadastro de Faixas de Aprovação dos Pedidos por Região

@author 	Augusto Krejci Bem-Haja
@since 		28/12/2015
@return		nil
//-------------------------------------------------------------------

User Function CadSZ5()
	Local oBrowse       
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SZ5')
	oBrowse:SetDescription('Cadastro de Faixas de Aprovação - Região')  

	oBrowse:AddLegend( "Z5_ATIVO=='S' .AND. Z5_VALID >= dDatabase", "GREEN", "Ativo" )
	oBrowse:AddLegend( "Z5_ATIVO=='N'", "RED"  , "Inativo" )      
	oBrowse:AddLegend( "Z5_ATIVO=='S' .AND. Z5_VALID < dDatabase","YELLOW"  ,"Vencido")
	
	oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CadSZ5' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CadSZ5' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CadSZ5' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CadSZ5' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CadSZ5' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CadSZ5' OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruZ5M := FWFormStruct( 1,'SZ5', {|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ5D := FWFormStruct( 1,'SZ5', {|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oModel
	Local aTrigger := {}
	
	oStruZ5M:SetProperty("Z5_CODIGO",MODEL_FIELD_WHEN,{|| oModel:GetOperation() == 3 })
	aTrigger := FwStruTrigger("Z5_REGIAO","Z5_RGDESC",'Posicione("SX5",1,xFilial("SX5") + "A2" + FwFldGet("Z5_REGIAO"),"X5_DESCRI")')
	oStruZ5D:addTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	oModel := MPFormModel():New('SZ5Mod')

	oModel:AddFields('SZ5MASTER',, oStruZ5M)
	oModel:AddGrid('SZ5DETAIL', 'SZ5MASTER', oStruZ5D)

    oModel:SetPrimaryKey({'Z5_FILIAL','Z5_CODIGO','Z5_ATIVO','Z5_VALID'})
	oModel:SetRelation ('SZ5DETAIL',{{'Z5_FILIAL','xFilial("SZ5")'},{'Z5_CODIGO','Z5_CODIGO'},{'Z5_ATIVO','Z5_ATIVO'},{'Z5_VALID','Z5_VALID'}},SZ5->(IndexKey(2)))

	oModel:SetDescription('Dados das Faixas de Aprovação por Região')
	oModel:GetModel('SZ5MASTER'):SetDescription('Dados de Faixas de Aprovação por Região')
	oModel:GetModel('SZ5DETAIL'):SetDescription('Dados de Aprovação por Região')
	oModel:GetModel('SZ5DETAIL'):SetUniqueLine({'Z5_REGIAO'})
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('CadSZ5')
	Local oStruZ5M := FWFormStruct(2,'SZ5',{|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ5D := FWFormStruct(2,'SZ5',{|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oView  
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_Z5M', oStruZ5M, 'SZ5MASTER')
	oView:AddGrid ('VIEW_Z5D', oStruZ5D, 'SZ5DETAIL')
	
	oView:AddIncrementField('VIEW_Z5D','Z5_ITEM')
	
	oView:CreateHorizontalBox('SUPERIOR',15)
	oView:CreateHorizontalBox('INFERIOR',85)
	
    oView:SetCloseOnOk({||.T.})
	
	oView:SetOwnerView('VIEW_Z5M', 'SUPERIOR')
	oView:SetOwnerView('VIEW_Z5D', 'INFERIOR')
Return oView
*/
