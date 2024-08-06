#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CadX5ZZ - Regiões (Tabela ZZ)

Cadastro de Regiões

@author 	Augusto Krejci Bem-Haja
@since 		04/01/2016
@return		nil
/*/
//-------------------------------------------------------------------
User Function CadX5ZZ()
	Local oBrowse       
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SX5')
	oBrowse:SetDescription('Cadastro de Descontos de Pontualidade')  
	oBrowse:SetFilterDefault("X5_TABELA=='ZZ'")
	oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CadX5ZZ' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CadX5ZZ' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CadX5ZZ' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CadX5ZZ' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CadX5ZZ' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CadX5ZZ' OPERATION 9 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruSX5 := FWFormStruct(1,'SX5')
	Local oModel
	
	oStruSX5:SetProperty("X5_TABELA",	MODEL_FIELD_INIT,{|| "ZZ" })
	oStruSX5:SetProperty("X5_CHAVE",	MODEL_FIELD_INIT,{|| LoadValues() })
	
	oStruSX5:SetProperty("X5_TABELA",	MODEL_FIELD_WHEN,{|| .F. })
	oStruSX5:SetProperty("X5_CHAVE",	MODEL_FIELD_WHEN,{|| .F. })
	           
	oModel := MPFormModel():New('SX5M')
	oModel:AddFields('SX5MASTER',,oStruSX5)

    oModel:SetPrimaryKey({'X5_FILIAL','X5_TABELA','X5_CHAVE'})
	oModel:SetDescription('Modelo de Dados de Desconto de Pontualidade')
	oModel:GetModel('SX5MASTER'):SetDescription('Dados de Desconto de Pontualidade')
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('CadX5ZZ')
	Local oStruSX5 := FWFormStruct(2,'SX5')
	Local oView  

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_SX5',oStruSX5,'SX5MASTER')

	oView:CreateHorizontalBox('TELA',100)
    oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView('VIEW_SX5','TELA')
	//oView:bAfterViewActivate := {|| LoadValues() }
Return oView

Static Function LoadValues()	
	Local nProxChave := 0
	Local aAreaSX5   := SX5->(GetArea())
	
	aChave := FWGetSx5("ZZ")
	For _x := 1 to Len(aChave)
		nProxChave := Val(aChave[_x][3])
	Next _x

//	SX5->(DbSeek(xFilial("SX5")+"ZZ"))
//	While SX5->(!EOF()) .and. (SX5->X5_TABELA == 'ZZ')
//		nProxChave := Val(SX5->X5_CHAVE)
//		SX5-> (DbSkip())  
//	End
	nProxChave++
	
	RestArea(aAreaSX5)	
Return (StrZero(nProxChave,3))