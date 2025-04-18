#include "Protheus.ch"
#include "TopConn.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o RetCom

Retorna a comiss�o de acordo com os par�metros passados.

@author 	Augusto Krejci Bem-Haja
@since 		30/12/2015
@return		Num�rico
/*/
//-------------------------------------------------------------------

User Function RetCom(cAliasSZ,cFaixa,cProduto)
	Local aArea		:= GetArea()
	Local cGrupo	:= RetField("SB1",1,xFilial("SB1")+AllTrim(cProduto),"B1_GRUPO")
	Local cTipoProd := RetField("SB1",1,xFilial("SB1")+AllTrim(cProduto),"B1_TIPO")
	Local cTipoPed	:= M->C5_TIPO
	Local nComissao := 0
	Local cPref	 	:= SubStr(cAliasSZ,2)
	Local cTipo		:= ""
	Local objQualy		:= LibQualyQuimica():New()
	Private cAlias	:= ""

	If objQualy:isSale() 
		If !Empty(cGrupo)	
			QryRgs(cAliasSZ,cPref,cFaixa,cGrupo)
			DbSelectArea("SQL1")
			SQL1->(DbGotop())
			If !Empty(cFaixa) 
				If SQL1->(Eof()) 
					If cAliasSZ == "SZ2"
						cTipo := "Vendedor"
					Else
						cTipo := "Revenda"
					Endif
					MsgAlert("Aten��o, faixa de premia��o "+cTipo+" n�o cadastrada ou inv�lida!")
				Else
					nComissao := SQL1->( &(cPref+"_COMIS") )
				Endif
			Endif
			SQL1->(DbCloseArea())
		Else	
			MsgAlert("Aten��o, produto n�o possui Grupo cadastrado.")
		Endif
	Endif
	
	freeObj(objQualy)
	RestArea(aArea)
Return (nComissao)

Static Function QryRgs(cAliasSZ,cPref,cFaixa,cGrupo) 

Local cQuery := ""
Local cData  := DtoS(dDatabase)

cQuery := " SELECT * FROM " +RetSqlName(cAliasSZ)
cQuery += " WHERE "+ cPref + "_CODIGO = '" + cFaixa + "'"
cQuery += " AND "+ cPref + "_GRUPO = '" + cGrupo + "'"
cQuery += " AND "+ cPref + "_ATIVO = 'S'"
cQuery += " AND "+ cPref + "_VALID >= '"+ cData +"'"
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
Return
