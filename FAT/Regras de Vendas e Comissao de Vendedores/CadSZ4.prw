#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CadSZ4

Cadastro de Fretes e Despesas Administrativas

@author 	Augusto Krejci Bem-Haja
@since 		24/12/2015
@return		nil
/*/
//-------------------------------------------------------------------
User Function CadSZ4()
	Local oBrowse       
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SZ4')
	oBrowse:SetDescription('Cadastro de Fretes e Despesas Administrativas')  

	oBrowse:AddLegend("Z4_ATIVO=='S' .AND. Z4_VALID >= dDatabase","GREEN","Ativo")
	oBrowse:AddLegend("Z4_ATIVO=='N'","RED"  ,"Inativo")
	oBrowse:AddLegend("Z4_ATIVO=='S' .AND. Z4_VALID < dDatabase","YELLOW"  ,"Vencido")	      

	oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CadSZ4' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CadSZ4' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CadSZ4' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CadSZ4' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CadSZ4' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CadSZ4' OPERATION 9 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruSZ4 := FWFormStruct(1,'SZ4')
	Local oModel
	
	oStruSZ4:SetProperty("Z4_ESTADO",	MODEL_FIELD_WHEN,{|| oModel:GetOperation() == 3 })
	                         
	oModel := MPFormModel():New('SZ4M')
	oModel:AddFields('SZ4MASTER',,oStruSZ4)

    oModel:SetPrimaryKey({'Z4_FILIAL','Z4_ESTADO','Z4_ATIVO'})
	oModel:SetDescription('Modelo de Dados de Fretes e Despesas Administrativas')
	oModel:GetModel('SZ4MASTER'):SetDescription('Dados de Cadastro de Fretes e Despesas Administrativas')
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('CadSZ4')
	Local oStruSZ4 := FWFormStruct(2,'SZ4')
	Local oView  

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_SZ4',oStruSZ4,'SZ4MASTER')

	oView:CreateHorizontalBox('TELA',100)
    oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView('VIEW_SZ4','TELA')
Return oView