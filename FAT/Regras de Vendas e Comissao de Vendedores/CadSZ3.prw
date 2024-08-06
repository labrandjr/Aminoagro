#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#Define CPOSCABEC "|Z3_CODIGO|Z3_DESC|Z3_VALID|Z3_ATIVO|"

//-------------------------------------------------------------------
/*/{Protheus.doc} CadSZ3

Cadastro de Faixas de Comissão - Revendas

@author 	Augusto Krejci Bem-Haja
@since 		24/12/2015
@return		nil
/*/
//-------------------------------------------------------------------
User Function CadSZ3()
	Local oBrowse       
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SZ3')
	oBrowse:SetDescription('Cadastro de Faixas de Premiação - Revendas')  

	oBrowse:AddLegend( "Z3_ATIVO=='S' .AND. Z3_VALID >= dDatabase", "GREEN", "Ativo" )
	oBrowse:AddLegend( "Z3_ATIVO=='N'", "RED"  , "Inativo" )
	oBrowse:AddLegend( "Z3_ATIVO=='S' .AND. Z3_VALID < dDatabase","YELLOW"  ,"Vencido")

	oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CadSZ3' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CadSZ3' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CadSZ3' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CadSZ3' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CadSZ3' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CadSZ3' OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruZ3M := FWFormStruct( 1,'SZ3', {|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ3D := FWFormStruct( 1,'SZ3', {|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oModel
	Local aTrigger := {}
	
	oStruZ3M:SetProperty("Z3_CODIGO",	MODEL_FIELD_WHEN,{|| oModel:GetOperation() == 3 })
	aTrigger := FwStruTrigger("Z3_GRUPO","Z3_GRDESC",'Posicione("SBM",1,xFilial("SBM") + FwFldGet("Z3_GRUPO"),"BM_DESC")')
	oStruZ3D:addTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	oModel := MPFormModel():New('SZ3Mod')

	oModel:AddFields('SZ3MASTER',, oStruZ3M)
	oModel:AddGrid('SZ3DETAIL', 'SZ3MASTER', oStruZ3D)

    oModel:SetPrimaryKey({'Z3_FILIAL','Z3_CODIGO','Z3_ATIVO'})
	oModel:SetRelation ('SZ3DETAIL',{{'Z3_FILIAL','xFilial("SZ3")'},{'Z3_CODIGO','Z3_CODIGO'},{'Z3_ATIVO','Z3_ATIVO'}},SZ3->(IndexKey(2)))

	oModel:SetDescription('Modelo de Dados de Faixas de Premiação - Revendas')
	oModel:GetModel('SZ3MASTER'):SetDescription( 'Dados de Faixas de Premiação - Revendas')
	oModel:GetModel('SZ3DETAIL'):SetDescription( 'Dados de Premiação por Grupo')
	oModel:GetModel('SZ3DETAIL'):SetUniqueLine({'Z3_GRUPO'})
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('CadSZ3')
	Local oStruZ3M := FWFormStruct(2,'SZ3',{|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ3D := FWFormStruct(2,'SZ3',{|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oView  
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_Z3M', oStruZ3M, 'SZ3MASTER')
	oView:AddGrid ('VIEW_Z3D', oStruZ3D, 'SZ3DETAIL')
	
	oView:AddIncrementField('VIEW_Z3D','Z3_ITEM')
	
	oView:CreateHorizontalBox('SUPERIOR',15)
	oView:CreateHorizontalBox('INFERIOR',85)
	
    oView:SetCloseOnOk({||.T.})
	
	oView:SetOwnerView('VIEW_Z3M', 'SUPERIOR')
	oView:SetOwnerView('VIEW_Z3D', 'INFERIOR')
Return oView