#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � WFSUBST   � Autor � Fabrica ERPBR    � Data �  30/03/2020  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Cadastro de usu�rios substitutos para aprova��o Wf.		  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function WFSUBST()

Private cCadastro := "Aprovadores Substitutos Workflow"

Private cUsrHab   := AllTrim(GetMv("MV_ZUSAPRS"))

Private aRotina   := {{"Pesquisar"  , "AxPesqui"    , 0 , 1 },;
            	      {"Visualizar" , "AxVisual"    , 0 , 2 },;
            	      {"Incluir"    , "U_WFSUBSI()" , 0 , 3 },;
            	      {"Alterar"    , "U_WFSUBSA()" , 0 , 4 },;
            	      {"Excluir"    , "U_WFSUBSE()" , 0 , 5 }}

If !( __cUserId $(cUsrHab) )
	MsgAlert("Usu�rio n�o autorizado.")
	Return
Endif

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SZR" )			
oMBrowse:SetDescription( cCadastro )
oMBrowse:Activate()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � WFSUBSI   � Autor �  F�brica ERP.BR   � Data  � 13/04/2020 ���
��+----------+------------------------------------------------------------���
���Descricao � Inclus�o - Usu�rios substitutos workflow.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function WFSUBSI()

Local cTudoOk := "U_WFSUBOK()"

nRet := AxInclui("SZR",0,3,,,,cTudoOk)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � WFSUBSA   � Autor �  F�brica ERP.BR   � Data  � 13/04/2020 ���
��+----------+------------------------------------------------------------���
���Descricao � Altera��o - Usu�rios substitutos workflow.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function WFSUBSA()

Local cTudoOk := "U_WFSUBOK()"

Altera := .T.
nReg   := SZR->(Recno())
nOpc   := AxAltera("SZR",nReg,4,,,,,cTudoOk)

If nOpc == 1

Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � WFSUBSE   � Autor �  F�brica ERP.BR   � Data  � 13/04/2020 ���
��+----------+------------------------------------------------------------���
���Descricao � Exclus�o - Usu�rios substitutos workflow.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function WFSUBSE()

Local lContinua := .T.

If lContinua
	lContinua := VerLctoOk()
Endif

If lContinua

	Exclui := .T.
	nReg   := SZR->(Recno())
	nOpc   := AxDeleta("SZR",nReg,5)
	
	If nOpc == 2
		
	Endif

Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � WFSUBOK   � Autor �  F�brica ERP.BR   � Data  � 13/04/2020 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��o cTudoOk na inclus�o.				  			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function WFSUBOK()

Local aArea := GetArea()
Local lRetX := .T.

If Inclui
	If M->ZR_DATINI < Date()
		MsgAlert("Data in�cio � menor que atual.")
		lRetX := .F.
	Endif
Endif

If Inclui
	If lRetX
		If M->ZR_DATFIM < Date()
			MsgAlert("Data fim � menor que atual.")
			lRetX := .F.
		Endif
	Endif
Endif

If Inclui
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SZR")
	cQuery += " WHERE ZR_FILIAL = '"+xFilial("SZR")+"' "
	cQuery += " AND ZR_APROV = '"+M->ZR_APROV+"' "
	cQuery += " AND ZR_DATINI <= '"+DtoS(Date())+"' "
	cQuery += " AND ZR_DATFIM >= '"+DtoS(Date())+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLR", .F., .T.)
	lExiste := ( SQLR->SOMA > 0 )
	SQLR->(DbCloseArea())
	If lExiste
		MsgAlert("O Aprovador j� possui substituto cadastrado no per�odo vigente.")
		lRetX := .F.
	Endif
Endif

If lRetX
	If M->ZR_DATFIM < M->ZR_DATINI
		MsgAlert("Data fim � menor que a data in�cio.")
		lRetX := .F.
	Endif
Endif

If lRetX
	If M->ZR_APROV == M->ZR_APRSUB
		MsgAlert("Aprovador substituto deve ser diferente do aprovador titular.")
		lRetX := .F.
	Endif
Endif

RestArea(aArea)

Return(lRetX)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � VerLctoOk � Autor �  F�brica ERP.BR   � Data  � 13/04/2020 ���
��+----------+------------------------------------------------------------���
���Descricao � An�lise para permiss�o de altera��o/exclus�o.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function VerLctoOk()

Local aArea  := GetArea()
Local lRetOk := .T.

If !Empty(SZR->ZR_USADO)
	MsgAlert("Aten��o, substitui��o j� utilizada."+CHR(13)+CHR(10)+"Opera��o n�o permitida.")
	lRetOk := .F.
Endif

RestArea(aArea)

Return(lRetOk)

/*
AxInclui( <cAlias>, <nReg>, <nOpc>, <aAcho>, <cFunc>, <aCpos>, <cTudoOk>, <lF3>, <cTransact>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
AxAltera( <cAlias>, <nReg>, <nOpc>, <aAcho>, <aCpos>, <nColMens>, <cMensagem>, <cTudoOk>, <cTransact>, <cFunc>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
*/
