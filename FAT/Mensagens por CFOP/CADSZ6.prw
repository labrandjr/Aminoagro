#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#Define CPOSCABEC "|Z6_TES|Z6_CFOP|"

//-------------------------------------------------------------------
/*/{Protheus.doc} CADSZ6

Cadastro de Mensagens por CFOP

@author 	Cassiano G. Ribeiro
@since 		13/03/2016
@return		nil
/*/
//-------------------------------------------------------------------
User Function CADSZ6()
	Local oBrowse       
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SZ6')
	oBrowse:SetDescription('Cadastro de Mensagens por CFOP')  

	oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CADSZ6' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CADSZ6' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CADSZ6' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CADSZ6' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CADSZ6' OPERATION 8 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruZ6M := FWFormStruct( 1,'SZ6', {|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ6D := FWFormStruct( 1,'SZ6', {|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oModel
	Local aTrigger := {}
	
	oModel := MPFormModel():New('SZ6Mod')
	
	oModel:AddFields('SZ6MASTER',, oStruZ6M)
	oModel:AddGrid('SZ6DETAIL', 'SZ6MASTER', oStruZ6D)

    oModel:SetPrimaryKey({'Z6_FILIAL','Z6_TES','Z6_CFOP'})
	oModel:SetRelation ('SZ6DETAIL',{{'Z6_FILIAL','xFilial("SZ6")'},{'Z6_TES','Z6_TES'},{'Z6_CFOP','Z6_CFOP'}},SZ6->(IndexKey(1)))

	oModel:SetDescription('Mensagens por CFOP - Dentro ou Fora do Estado')
	oModel:GetModel('SZ6MASTER'):SetDescription( 'TES e CFOP')
	oModel:GetModel('SZ6DETAIL'):SetDescription( 'Mensagens')
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('CADSZ6')
	Local oStruZ6M := FWFormStruct(2,'SZ6',{|cCampo| AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oStruZ6D := FWFormStruct(2,'SZ6',{|cCampo| !AllTrim(cCampo)	+ "|" $ CPOSCABEC})
	Local oView  
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_Z6M', oStruZ6M, 'SZ6MASTER')
	oView:AddGrid ('VIEW_Z6D', oStruZ6D, 'SZ6DETAIL')
	
	oView:AddIncrementField('VIEW_Z6D','Z6_ITEM')
	
	oView:CreateHorizontalBox('SUPERIOR',15)
	oView:CreateHorizontalBox('INFERIOR',85)
	
    oView:SetCloseOnOk({||.T.})
	
	oView:SetOwnerView('VIEW_Z6M', 'SUPERIOR')
	oView:SetOwnerView('VIEW_Z6D', 'INFERIOR')
	
	oView:EnableTitleView('VIEW_Z6M')
	oView:EnableTitleView('VIEW_Z6D')
Return oView