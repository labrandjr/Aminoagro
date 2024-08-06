#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA030ROT  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 20/09/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cadastro de Clientes - Integração Agrométrika.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA030ROT()

Local aRetorno := {}

AAdd(aRetorno, {"Agrometrika", "U_AGRMTK3(Nil,Nil)", 2, 0 })

Return(aRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AGRMTK3   ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 20/09/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração Agrométrika - filtro de usuário.			  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AGRMTK3(zModo,oObj)

Local oModel := Nil
Local oView  := Nil

If zModo == Nil
	If MsgYesNo("Deseja executar a integração Agrométrika para todos os clientes ?","Aviso","INFO")
		U_AGMTKAUT(.F.)
		Processa({|| AgExecAll(.F.)})
	Endif	
Else
	If M->A1_XAGMTK == "S"
		If MsgYesNo(AllTrim(M->A1_CGC)+" - "+AllTrim(M->A1_NOME)+CHR(13)+CHR(10)+"Confirma integração Agrométrika ?","Aviso","INFO")
			U_AGMTKAUT(.F.)
			aRet := U_AGMTKCLI(M->A1_CGC,.F.)
			If Len(aRet) > 0
				If aRet[1] > 0
					If oObj <> Nil
						oModel := FwModelActive()
						oView  := FwViewActive()
						oObj:SetValue("SA1MASTER", "A1_LC", aRet[1] )
						oObj:LoadValue("SA1MASTER", "A1_LC", aRet[1] )
						oObj:SetValue("SA1MASTER", "A1_VENCLC", aRet[2] )
						oObj:LoadValue("SA1MASTER", "A1_VENCLC", aRet[2] )
						oObj:lModify := .T.
						oModel:lModify := .T.
						oView:lModify := .T.
					Else
						M->A1_LC     := aRet[1]
						M->A1_VENCLC := aRet[2]
					Endif
					MsgInfo("Integração Ok !!")
				Else
					MsgInfo("Falha na integração.")
				Endif
			Endif
		Endif
	Else
		MsgInfo("Integração Agrométrika desligada para este cliente.")
	Endif	
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AGRSCHED  ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 18/01/18   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração Agrométrika - via Schedule.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AGRSCHED()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_AGMTKAUT(.T.)
AgExecAll(.T.)
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AgExecAll ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 10/10/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração agrométrica para todos os clientes.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AgExecAll(lJob)

Local cQuery := ""

If !lJob
	ProcRegua(2)
Endif	

If !lJob
	IncProc("Selecionando registros...")
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SA1")
	cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += " AND A1_MSBLQL <> '1' "
	cQuery += " AND A1_CGC <> ' ' "
	cQuery += " AND A1_XAGMTK = 'S' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	nTotSql := SQL->SOMA
	SQL->(DbCloseArea())
Endif

If !lJob
	IncProc("Selecionando registros...")
Endif	
cQuery := " SELECT A1_COD, A1_LOJA "
cQuery += " FROM "+RetSqlName("SA1")
cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND A1_MSBLQL <> '1' "
cQuery += " AND A1_CGC <> ' ' "
cQuery += " AND A1_XAGMTK = 'S' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A1_COD, A1_LOJA "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
If !lJob
	ProcRegua(nTotSql)
Endif	
SQL->(DbGotop())
While !Eof()

	If !lJob
		IncProc("Integrando Agrométrika...aguarde")
	Endif	

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SQL->A1_COD + SQL->A1_LOJA )

	aRet := U_AGMTKCLI(SA1->A1_CGC,.T.)
	If aRet[1] > 0
		RecLock("SA1",.F.)
		SA1->A1_LC     := aRet[1]
		SA1->A1_VENCLC := aRet[2]
		MsUnLock()
		If __cUserId == "000000"
			If !lJob
				MsgInfo(SA1->A1_COD+" - "+AllTrim(SA1->A1_NOME)+CHR(13)+CHR(10)+"Integração Ok !!")
			Endif	
		Endif
	Endif	
		
	DbSelectArea("SQL")
	SQL->(DbSkip())
		
Enddo
SQL->(DbCloseArea())

Return
