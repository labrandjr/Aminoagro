#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "xmlxfun.ch"
#include "apwebsrv.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � AUDT001  � Autor � Fabrica ERPBR    � Data  �  26/08/2021  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Cadastro para liberar execu��o em carga de dados.		  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDT001()

Local aCores := {}
Local nX

Private cUsrAudit := AllTrim(GetMv("MV_ZUSRAUD"))

Private cCadastro := "Auditoria de Dados"

Private aRotina := {{"Pesquisar"    , "AxPesqui"    , 0 , 1 },;
            	    {"Visualizar"   , "AxVisual"    , 0 , 2 },;
            	    {"Incluir"      , "U_AUDT01I()" , 0 , 3 },;
            	    {"Alterar"      , "U_AUDT01A()" , 0 , 4 },;
            	    {"Excluir"      , "U_AUDT01E()" , 0 , 5 },;
            	    {"Log Execu��o" , "U_AUDT01L()" , 0 , 6 },;
            	    {"Anexos"       , "MsDocument"  , 0 , 7 , 0 , Nil },;
            	    {"Legenda"      , "U_AUDT01G()" , 0 , 8 , 0 , .F.}}

aCores := {{"ZZL_STATUS == ' '", "GREEN" , "Pendente"  },;
		   {"ZZL_STATUS == 'E'", "RED"   , "Executado" }}

If !(__cUserId $(cUsrAudit))
	MsgAlert("Usu�rio n�o autorizado <MV_ZUSRAUD>. Contate o Administrador.")
	Return
Endif

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "ZZL" )			
oMBrowse:SetDescription( cCadastro )

For nX := 1 to Len(aCores)
	oMBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
Next nX

oMBrowse:SetTotalDefault("ZZL_FILIAL","COUNT","Total de Registros")		
oMBrowse:Activate()

DbSelectArea("ZZL")
DbSetOrder(1)
DbClearFilter()
		
Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � AUDT01I  � Autor � Fabrica ERPBR    � Data  �  25/04/2020  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Auditoria de Dados - Inclus�o.							  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDT01I()

nRet := AxInclui("ZZL",0,3)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � AUDT01A  � Autor � Fabrica ERPBR    � Data  �  25/04/2020  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Auditoria de Dados - Altera��o.							  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDT01A()

If !Empty(ZZL->ZZL_STATUS)
	MsgAlert("Carga de dados executada.")
	Return
Endif

Altera := .T.
nReg   := ZZL->(Recno())
nOpc   := AxAltera("ZZL",nReg,4)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � AUDT01E  � Autor � Fabrica ERPBR    � Data  �  25/04/2020  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Auditoria de Dados - Exclus�o.							  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDT01E()

If !Empty(ZZL->ZZL_STATUS)
	MsgAlert("Carga de dados executada.")
	Return
Endif

Exclui := .T.
nReg   := ZZL->(Recno())
nOpc   := AxDeleta("ZZL",nReg,5)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � AUDT01G  � Autor � Fabrica ERPBR    � Data  �  26/08/2021  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Auditoria de Dados - Legenda.							  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDT01G()

Local aCores := {}

aCores := {{"ENABLE"  , "Pendente"},;
		   {"DISABLE" , "Executado"}}

BrwLegenda(cCadastro,"Legenda",aCores)

Return                

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � AUDTSX2  � Autor � Fabrica ERPBR    � Data  �  26/08/2021  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Auditoria de Dados - Valida o alias da tabela.			  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDTSX2(cAlias)

Local aArea   := GetArea()
Local cNomTab := ""

cQuery := " SELECT X2_NOME "
cQuery += " FROM SX2G10 "
cQuery += " WHERE X2_CHAVE = '"+cAlias+"' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSX2", .F., .T.)

TSX2->(DbGotop())
If Eof()
	MsgAlert("Tabela "+cAlias+" n�o localizada.")
Else
	cNomTab := AllTrim(TSX2->X2_NOME)
Endif
TSX2->(DbCloseArea())

// Reinicia
M->ZZL_ORDEM := Space(1)
M->ZZL_CHAVE := Space(40)

RestArea(aArea)

Return(cNomTab)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � AUDTSIX  � Autor � Fabrica ERPBR    � Data  �  26/08/2021  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Auditoria de Dados - Valida o �ndice da tabela.			  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO.										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDTSIX(cOrdem)

Local aArea  := GetArea()
Local cChave := ""

cQuery := " SELECT CHAVE "
cQuery += " FROM SIXG10 "
cQuery += " WHERE INDICE = '"+M->ZZL_ALIAS+"' "
cQuery += " AND ORDEM = '"+cOrdem+"' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSIX", .F., .T.)

TSIX->(DbGotop())
If Eof()
	MsgAlert("Chave "+cOrdem+" n�o localizada para a tabela "+AllTrim(M->ZZL_ALIAS))
Else
	cChave := AllTrim(TSIX->CHAVE)
Endif
TSIX->(DbCloseArea())

RestArea(aArea)

Return(cChave)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AUDT01L � Autor � F�brica ERP.BR      � Data  � 30/08/2021 ���
��+----------+------------------------------------------------------------���
���Descricao � Log de execu��o.									 		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDT01L()

Local oReport

oReport := ReportDef()

If oReport == Nil
	Return
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportDef � Autor �  Luis Brandini   � Data  � 30/08/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef()

Local oReport
Local oSection1

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("LOGEXEC","Log de execu��o", , {|oReport| ReportPrint(oReport), "Este relat�rio ir� imprimir as ocorr�ncias de execu��o na carga de dados auditada."})

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1 := TRSection():New(oReport,"Log de execu��o",{"ZZM"},,.F.,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oSection1, "TAB", "ZZM", "Tabela"     , "@!" , 005, , { || TRB->ZZM_ALIAS } )
TRCell():New(oSection1, "ORD", "ZZM", "Chave"      , "@!" , 005, , { || TRB->ZZM_ORDEM } )
TRCell():New(oSection1, "REG", "ZZM", "Id Registro", "@!" , 100, , { || TRB->ZZM_ID } )
TRCell():New(oSection1, "CPO", "ZZM", "Campo"      , "@!" , 020, , { || TRB->ZZM_CAMPO } )
TRCell():New(oSection1, "TIT", "ZZM", "T�tulo"     , "@!" , 030, , { || TRB->ZZM_TITULO } )
TRCell():New(oSection1, "OLD", "ZZM", "Anterior"   , "@!" , 050, , { || TRB->ZZM_OLD } )
TRCell():New(oSection1, "NEW", "ZZM", "Novo"       , "@!" , 050, , { || TRB->ZZM_NEW } )
TRCell():New(oSection1, "DAT", "ZZM", "Data"       , "@!" , 010, , { || StoD(TRB->ZZM_DATA) } )
TRCell():New(oSection1, "HOR", "ZZM", "Hora"       , "@!" , 010, , { || TRB->ZZM_HORA } )
TRCell():New(oSection1, "USR", "ZZM", "C�digo"     , "@!" , 010, , { || TRB->ZZM_USER } )
TRCell():New(oSection1, "NOM", "ZZM", "Usu�rio"    , "@!" , 020, , { || TRB->ZZM_NOME } )

Return(oReport)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportPrint � Autor � Luis Brandini  � Data  � 29/08/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Log de execu��o | "+ZZL->ZZL_ALIAS+" - "+AllTrim(ZZL->ZZL_DESCRI)+" |"
oReport:cTitle := "Log de execu��o | "+ZZL->ZZL_ALIAS+" - "+AllTrim(ZZL->ZZL_DESCRI)+" |"

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("ZZM")
cQuery += " WHERE ZZM_FILIAL = '"+xFilial("ZZM")+"' "
cQuery += " AND ZZM_ALIAS = '"+ZZL->ZZL_ALIAS+"' "
cQuery += " AND ZZM_ORDEM = '"+ZZL->ZZL_ORDEM+"' "
cQuery += " AND ZZM_USER = '"+ZZL->ZZL_USER+"' "
cQuery += " AND ZZM_DATA = '"+DtoS(ZZL->ZZL_DATA)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
nTotSql := TRB->SOMA
TRB->(DbCloseArea())

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("ZZM")
cQuery += " WHERE ZZM_FILIAL = '"+xFilial("ZZM")+"' "
cQuery += " AND ZZM_ALIAS = '"+ZZL->ZZL_ALIAS+"' "
cQuery += " AND ZZM_ORDEM = '"+ZZL->ZZL_ORDEM+"' "
cQuery += " AND ZZM_USER = '"+ZZL->ZZL_USER+"' "
cQuery += " AND ZZM_DATA = '"+DtoS(ZZL->ZZL_DATA)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)

DbSelectArea("TRB")
TRB->(DbGotop())
oReport:SetMeter(nTotSql)
oSection1:Init()
While !Eof()
	oReport:IncMeter()
	oSection1:PrintLine()
	TRB->(DbSkip())
	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif
Enddo
TRB->(DbCloseArea())

Return
