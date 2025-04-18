#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � LogPrem   � Autor �  F�brica ERP.BR   �   Data  � 31/10/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Log de ocorr�ncias na emiss�o do extrato da premia��o.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function LogPrem()

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
���Programa  � ReportDef � Autor �  Luis Brandini   �   Data  � 31/10/17  ���
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
oReport := TReport():New("LOGPREM","Log extrato de premia��o", , {|oReport| ReportPrint(oReport), "Este relat�rio ir� imprimir as ocorr�ncias da emiss�o do extrato de premia��o."})

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
oSection1 := TRSection():New(oReport,"Log extrato de premia��o",{"LOG"},,.F.,.F.)

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
TRCell():New(oSection1, "COD", "LOG", "C�digo"      , "@!" , 015, , { || LOG->LOG_COD } )
TRCell():New(oSection1, "NOE", "LOG", "Nome"        , "@!" , 045, , { || LOG->LOG_NOM } )
TRCell():New(oSection1, "PDF", "LOG", "Arquivo Pdf" , "@!" , 100, , { || LOG->LOG_PDF } )
TRCell():New(oSection1, "EML", "LOG", "E-mail"      , "@X" , 100, , { || AllTrim(LOG->LOG_EML)+IIf(LOG->LOG_TIP=="C"," (cc)","") } )
TRCell():New(oSection1, "PDF", "LOG", "Observa��o"  , "@!" , 100, , { || LOG->LOG_OBS } )

Return(oReport)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportPrint � Autor � Luis Brandini  �   Data  � 31/10/17  ���
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

oReport:cRealTitle := "Log de ocorr�ncias | Extrato de Premia��o |"
oReport:cTitle := "Log de ocorr�ncias | Extrato de Premia��o |"

DbSelectArea("LOG")
LOG->(DbGotop())
oReport:SetMeter(LOG->(RecCount()))
oSection1:Init()
While !Eof()
	oReport:IncMeter()
	oSection1:PrintLine()
	LOG->(DbSkip())
	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif
Enddo

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � TrbPremi  � Autor � F�brica ERPBR    �    Data  � 31/10/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Cria arquivos temporarios.							   	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function TrbPremi()

Local _aTmp := {}
Local zAlias := "LOG"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"LOG_COD" , "C", 006, 00} )
AAdd ( _aTmp, {"LOG_ORI" , "C", 080, 00} )
AAdd ( _aTmp, {"LOG_TIP" , "C", 001, 00} )
AAdd ( _aTmp, {"LOG_NOM" , "C", 040, 00} )
AAdd ( _aTmp, {"LOG_PDF" , "C", 100, 00} )
AAdd ( _aTmp, {"LOG_EML" , "C", 080, 00} )
AAdd ( _aTmp, {"LOG_OBS" , "C", 100, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"LOG_COD", "LOG_ORI", "LOG_TIP"})
oTempTable:Create()

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � LogPremi  � Autor � F�brica ERPBR    �    Data  � 31/10/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Insere registro no log.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function LogPremi(a3Cod, a3Nom, a3Pdf, a3Eml, a3Obs, a3Ori, a3Tip)

DbSelectArea("LOG")
DbSetOrder(1)
If !DbSeek( a3Cod + a3Ori + a3Tip )
	RecLock("LOG",.T.)
	LOG->LOG_COD := a3Cod
	LOG->LOG_ORI := a3Ori
	LOG->LOG_TIP := a3Tip
	LOG->LOG_NOM := a3Nom
	LOG->LOG_PDF := a3Pdf
	LOG->LOG_EML := a3Eml
	LOG->LOG_OBS := "E-mail n�o enviado."
	MsUnLock()
Else
	If !Empty(a3Obs)
		RecLock("LOG",.F.)
		LOG->LOG_EML := a3Eml
		LOG->LOG_OBS := a3Obs
		MsUnLock()
	Endif
Endif

Return
