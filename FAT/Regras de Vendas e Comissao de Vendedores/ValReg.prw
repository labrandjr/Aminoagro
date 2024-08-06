#Include 'Protheus.ch'
#Include "TopConn.ch"
#Include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função ValReg

Função que avalia as regras de negócio do cliente, bloqueando o pedido por regra, caso não as atenda.

@author 	Augusto Krejci Bem-Haja
@since 		06/01/2016
@return		Nil
/*/
//-------------------------------------------------------------------

User Function ValReg()
	Local lRetorno := .T.
	Local aArea		:= GetArea()
	Local cCliente	:= M->C5_CLIENTE
	Local cFaixaV	:= M->C5_ZZCDFXV
	Local nEBIT		:= M->C5_ZZPEBIT
	Local cRegiao	:= RetField("SA1",1,xFilial("SA1")+cCliente,"A1_REGIAO")
	Local cMens		:= ""
	Local objQualy	:= LibQualyQuimica():New()
	Private cAlias	:= ""
	
	cAlias := QryRgs(cFaixaV,cRegiao)
	(cAlias)->(dbGoTop())

	If objQualy:isSale()
		If (cAlias)->(Eof())
			cMens := "Faixa de Aprovação por Região não cadastrada ou inválida."
			Bloqueia(cMens)
		Else
			If !(nEBIT >= (cAlias)->Z5_PRENT)  
				cMens := "Ebitda do pedido, inferior ao mínimo de "+ cValToChar((cAlias)->Z5_PRENT) +"% pré-aprovado."
				Bloqueia(cMens)
			Endif
		Endif
	Endif
	
	If !Empty(M->C5_ZZTPBON)
		cMens := "Pedido de Bonificação"
		Bloqueia(cMens)			
	Endif

	(cAlias)->(DbCloseArea())
	
	freeObj(objQualy)
	GrvUsrData()
	RestArea(aArea)
Return lRetorno

Static Function QryRgs(cFaixaV,cRegiao) 

Local cQuery := ""
Local cAlias := GetNextAlias()
Local cData  := DtoS(dDatabase)

cQuery := " SELECT Z5_PRENT FROM "+RetSqlName("SZ5")	
cQuery += " WHERE Z5_CODIGO = '" + cFaixaV + "' "
cQuery += " AND Z5_ATIVO = 'S' "
cQuery += " AND Z5_VALID >= '"+ cData +"' " 
cQuery += " AND D_E_L_E_T_ <> '*' "
		
TCQUERY cQuery NEW ALIAS &cAlias	

Return cAlias

Static Function Bloqueia(cMens)
	default cMens := ""
	If Inclui .Or. Altera
		If Empty(M->C5_ZARQCSV)
			cMens += CHR (13) + CHR (10) + CHR (13) + CHR (10)
			cMens += "Pedido será gravado, porém ficará bloqueado por Regras"
			MsgAlert(cMens)
		Endif	
		RecLock("SC5",.F.)
		SC5->C5_BLQ := "1"
		SC5->(MsUnLock())
	Endif	
Return

Static Function GrvUsrData()
	RecLock("SC5",.F.)				
	SC5->C5_ZZDTMOD := DATE()
	SC5->C5_ZZUSUAR := cUserName
	SC5->C5_TIPLIB  := "2"
	SC5->(MsUnLock())
Return
