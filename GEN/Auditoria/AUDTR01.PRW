#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AUDTR01 � Autor � F�brica ERP.BR   � Data  �  31/08/2021   ���
��+----------+------------------------------------------------------------���
���Descricao � Log de execu��o da carga de dados auditada.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUDTR01()

Local oReport

oReport := ReportDef()

If oReport == Nil
	Return
Endif

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
Endif

oReport:PrintDialog()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportDef � Autor �  Luis Brandini   � Data  � 31/08/2021  ���
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
oReport := TReport():New("LOGEXEC","Log de execu��o","AUDTR01", {|oReport| ReportPrint(oReport), "Este relat�rio ir� imprimir as ocorr�ncias de execu��o na carga de dados auditada."})

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
���Programa  � ReportPrint � Autor � Luis Brandini  � Data  � 31/08/2021  ���
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

oReport:cRealTitle := "Log de execu��o | "+DtoC(mv_par01)+" - "+DtoC(mv_par02)+" |"
oReport:cTitle := "Log de execu��o | "+DtoC(mv_par01)+" - "+DtoC(mv_par02)+" |"

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("ZZM")
cQuery += " WHERE ZZM_FILIAL = '"+xFilial("ZZM")+"' "
cQuery += " AND ZZM_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
nTotSql := TRB->SOMA
TRB->(DbCloseArea())

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("ZZM")
cQuery += " WHERE ZZM_FILIAL = '"+xFilial("ZZM")+"' "
cQuery += " AND ZZM_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY ZZM_FILIAL, ZZM_DATA, ZZM_HORA, ZZM_USER, ZZM_ALIAS, ZZM_CAMPO "
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
