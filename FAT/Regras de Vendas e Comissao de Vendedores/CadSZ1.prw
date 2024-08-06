#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CadSZ1

Cadastro de Custo dos Produtos

@author 	Augusto Krejci Bem-Haja
@since 		23/12/2015
@return		nil
/*/
//-------------------------------------------------------------------
User Function CadSZ1()
	Local oBrowse       
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SZ1')
	oBrowse:SetDescription('Cadastro de Custo dos Produtos')  

	oBrowse:AddLegend("Z1_ATIVO=='S' .AND. Z1_VALID >= dDatabase","GREEN","Ativo")
	oBrowse:AddLegend("Z1_ATIVO=='N'","RED"  ,"Inativo")
	oBrowse:AddLegend("Z1_ATIVO=='S' .AND. Z1_VALID < dDatabase","YELLOW"  ,"Vencido")

	oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CadSZ1' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CadSZ1' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CadSZ1' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CadSZ1' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CadSZ1' OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Importação' ACTION 'U_ImpSZ1' 	  OPERATION 10 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruSZ1 := FWFormStruct(1,'SZ1')
	Local oModel
	
	oStruSZ1:SetProperty("Z1_CODIGO",	MODEL_FIELD_WHEN,{|| oModel:GetOperation() == 3 })
	                         
	oModel := MPFormModel():New('SZ1M')
	oModel:AddFields('SZ1MASTER',,oStruSZ1)

    oModel:SetPrimaryKey({'Z1_FILIAL','Z1_CODIGO','Z1_ATIVO'})
	oModel:SetDescription('Modelo de Dados de Custo dos Produtos')
	oModel:GetModel('SZ1MASTER'):SetDescription('Dados de Custo dos Produtos')
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('CadSZ1')
	Local oStruSZ1 := FWFormStruct(2,'SZ1')
	Local oView  

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_SZ1',oStruSZ1,'SZ1MASTER')

	oView:CreateHorizontalBox('TELA',100)
    oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView('VIEW_SZ1','TELA')
Return oView