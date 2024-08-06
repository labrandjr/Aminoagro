#include "protheus.ch"
#include "topconn.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Função RetFtDA

Retorna os percentuais de frete e despesas administrativas, obtido a partir da UF do cadastro do cliente, e buscando na tabela personalizada SZ4. O parâmetro nOpcao indica qual percentual a funcao retornara.

@author 	Augusto Krejci Bem-Haja
@since 		04/01/2016
@return		Numérico
/*/
//-----------------

User Function RetFtDA(nOpcao)
Local aArea			:= GetArea()
Local cUF	 		:= ""
Local cUndNeg		:= M->C5_ZZITCTB
Local nPercentual 	:= 0
Local objQualy		:= LibQualyQuimica():New()

Private cAlias	:= ""

If objQualy:isSale()

	cUF := RetField("SA1",1,xFilial("SA1")+AllTrim(M->C5_CLIENTE),"A1_EST")
	cAlias := QryRgs(cUF,cUndNeg)
	(cAlias)->(dbGoTop())

	If !Empty(cUF)
		If (cAlias)->(Eof())
			MsgAlert("Atenção, faixa de Frete/Despesas ADM não cadastrada ou inválida, para a unidade de negócio "+cUndNeg+"!")
		Else
			If nOpcao == 1
				nPercentual := (cAlias)->Z4_PFRETE
			Else
				nPercentual := (cAlias)->Z4_PDA
			Endif
		Endif
	Else
		MsgAlert("Atenção, cliente não possui UF cadastrada.")
	Endif

	(cAlias)->(DbCloseArea())

Endif

freeObj(objQualy)
RestArea(aArea)
Return nPercentual

Static Function QryRgs(cUF,cUndNeg)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local cEol   := chr(10) + chr(13)
Local cData  := DtoS(dDatabase)

cQuery := " SELECT Z4_PFRETE, Z4_PDA FROM " +RetSqlName("SZ4") +" SZ4 "+ cEol
cQuery += " WHERE Z4_ESTADO = '" + cUF + "'"+ cEol
cQuery += " AND Z4_ATIVO = 'S'" + cEol
cQuery += " AND Z4_VALID >= '"+ cData + "'" + cEol
cQuery += " AND Z4_ITEMCTB = '"+ cUndNeg + "'" + cEol
cQuery += " AND D_E_L_E_T_ <> '*' " + cEol

TCQUERY cQuery NEW ALIAS &cAlias
Return cAlias
