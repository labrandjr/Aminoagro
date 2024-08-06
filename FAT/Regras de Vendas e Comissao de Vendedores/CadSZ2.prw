#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#Define CPOSCABEC "|Z2_CODIGO|Z2_DESC|Z2_VALID|Z2_ATIVO|"

//-------------------------------------------------------------------
/*/{Protheus.doc} CadSZ2

Cadastro de Faixas de Comissão - Vendedores

@author 	Augusto Krejci Bem-Haja
@since 		24/12/2015
@return		nil
/*/
//-------------------------------------------------------------------
User Function CadSZ2()
	Local oBrowse       
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SZ2')
	oBrowse:SetDescription('Cadastro de Faixas de Premiação - Vendedores')  

	oBrowse:AddLegend( "Z2_ATIVO=='S' .AND. Z2_VALID >= dDatabase", "GREEN", "Ativo" )
	oBrowse:AddLegend( "Z2_ATIVO=='N'", "RED"  , "Inativo" )
	oBrowse:AddLegend( "Z2_ATIVO=='S' .AND. Z2_VALID < dDatabase","YELLOW"  ,"Vencido")      

	oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'         OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CadSZ2' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CadSZ2' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CadSZ2' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CadSZ2' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CadSZ2' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CadSZ2' OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruZ2M := FWFormStruct( 1,'SZ2', {|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ2D := FWFormStruct( 1,'SZ2', {|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oModel
	Local aTrigger := {}

	oStruZ2M:SetProperty("Z2_CODIGO",	MODEL_FIELD_WHEN,{|| oModel:GetOperation() == 3 })
	aTrigger := FwStruTrigger("Z2_GRUPO","Z2_GRDESC",'Posicione("SBM",1,xFilial("SBM") + FwFldGet("Z2_GRUPO"),"BM_DESC")')
	oStruZ2D:addTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	oModel := MPFormModel():New('SZ2Mod')

	oModel:AddFields('SZ2MASTER',, oStruZ2M)
	oModel:AddGrid('SZ2DETAIL', 'SZ2MASTER', oStruZ2D)

    oModel:SetPrimaryKey({'Z2_FILIAL','Z2_CODIGO','Z2_ATIVO'})
	oModel:SetRelation ('SZ2DETAIL',{{'Z2_FILIAL','xFilial("SZ2")'},{'Z2_CODIGO','Z2_CODIGO'},{'Z2_ATIVO','Z2_ATIVO'}},SZ2->(IndexKey(2)))

	oModel:SetDescription('Modelo de Dados de Faixas de Premiação - Vendedores')
	oModel:GetModel('SZ2MASTER'):SetDescription( 'Dados de Faixas de Premiação - Vendedores')
	oModel:GetModel('SZ2DETAIL'):SetDescription( 'Dados de Premiação por Grupo')
	oModel:GetModel('SZ2DETAIL'):SetUniqueLine({'Z2_GRUPO'})
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('CadSZ2')
	Local oStruZ2M := FWFormStruct(2,'SZ2',{|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ2D := FWFormStruct(2,'SZ2',{|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oView  
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_Z2M', oStruZ2M, 'SZ2MASTER')
	oView:AddGrid ('VIEW_Z2D', oStruZ2D, 'SZ2DETAIL')
	
	oView:AddIncrementField('VIEW_Z2D','Z2_ITEM')
	
	oView:CreateHorizontalBox('SUPERIOR',15)
	oView:CreateHorizontalBox('INFERIOR',85)
	
    oView:SetCloseOnOk({||.T.})
	
	oView:SetOwnerView('VIEW_Z2M', 'SUPERIOR')
	oView:SetOwnerView('VIEW_Z2D', 'INFERIOR')
Return oView