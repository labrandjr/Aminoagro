#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MRPNEC01  � Autor �  F�brica ERP.BR   � Data  � 10/06/2021 ���
��+----------+------------------------------------------------------------���
���Descricao � Imprime rela��o das necessidades geradas pelo Mrp. 		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MRPNEC01()

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
���Programa  � ReportDef � Autor �  Luis Brandini   � Data  � 10/06/2021 ���
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

Pergunte("MRPNEC01",.F.)

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
oReport := TReport():New("MRPNEC01","Necessidades do Mrp","MRPNEC01", {|oReport| ReportPrint(oReport), "Este relat�rio ir� imprimir as necessidades do mrp."})

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
oSection1 := TRSection():New(oReport,"Necessidades do Mrp",{"TMP"},,.F.,.F.)

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
TRCell():New(oSection1, "COD", "TMP", "C�digo"     , "@!" , 015, , { || TMP->MRP_COD } )
TRCell():New(oSection1, "DES", "TMP", "Descri��o"  , "@!" , 040, , { || TMP->MRP_DES } )
TRCell():New(oSection1, "TIP", "TMP", "Tipo"       , "@!" , 002, , { || TMP->MRP_TIP } )
TRCell():New(oSection1, "SLD", "TMP", "Saldo"      , "@E 999,999,999.99" , 020, , { || TMP->MRP_SLD } )
TRCell():New(oSection1, "CLA", "TMP", "� Endere�ar", "@E 999,999,999.99" , 020, , { || TMP->MRP_CLA } )
TRCell():New(oSection1, "SAI", "TMP", "Sa�das"     , "@E 999,999,999.99" , 020, , { || TMP->MRP_SAI } )
TRCell():New(oSection1, "ENT", "TMP", "Entradas"   , "@E 999,999,999.99" , 020, , { || TMP->MRP_ENT } )
TRCell():New(oSection1, "A01", "TMP", "Armaz�m 01" , "@E 999,999,999.99" , 020, , { || TMP->MRP_A01 } )
TRCell():New(oSection1, "A04", "TMP", "Armaz�m 04" , "@E 999,999,999.99" , 020, , { || TMP->MRP_A04 } )
TRCell():New(oSection1, "A14", "TMP", "Armaz�m 14" , "@E 999,999,999.99" , 020, , { || TMP->MRP_A14 } )
TRCell():New(oSection1, "A3O", "TMP", "Terceiros"  , "@E 999,999,999.99" , 020, , { || TMP->MRP_A3O } )
TRCell():New(oSection1, "COM", "TMP", "Comprar"    , "@E 999,999,999.99" , 020, , { || TMP->MRP_COM } )
TRCell():New(oSection1, "REQ", "TMP", "Requisi��o" , "@!" , 005, , { || TMP->MRP_REQ } )

Return(oReport)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ReportPrint � Autor � Luis Brandini  � Data  � 20/02/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Executa impressao do relatorio.							  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportPrint(oReport)

Local aTmp := {}
Local oSection1 := oReport:Section(1)

oReport:cRealTitle := "Necessidades do Mrp"
oReport:cTitle := "Necessidades do Mrp"

oTempTable := FWTemporaryTable():New("TMP")
AAdd ( aTmp, {"MRP_COD" , "C", 015, 00} )
AAdd ( aTmp, {"MRP_DES" , "C", 040, 00} )
AAdd ( aTmp, {"MRP_TIP" , "C", 002, 00} )
AAdd ( aTmp, {"MRP_SLD" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_CLA" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_SAI" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_ENT" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_A01" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_A04" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_A14" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_A3O" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_COM" , "N", 014, 02} )
AAdd ( aTmp, {"MRP_REQ" , "C", 003, 00} )
oTemptable:SetFields(aTmp)
oTempTable:AddIndex("indice1", {"MRP_COD"})
oTempTable:Create()

cQuery := " SELECT HF_PRODUTO COD, B1_DESC DESCR, B1_TIPO TIPO, HF_SALDO SLD, HF_SAIDAS SAI, HF_ENTRADA ENT "
cQuery += " FROM "+RetSqlName("SHF")+" SHF, "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += " WHERE HF_FILNEC = '"+xFilial("SB2")+"' "
cQuery += " AND HF_PRODUTO = B1_COD "
cQuery += " AND HF_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND HF_SAIDAS > 0 "
cQuery += " AND B1_TIPO IN('MP') "
cQuery += " AND SHF.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY HF_PRODUTO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSQL", .F., .T.)

DbSelectArea("TSQL")
TSQL->(DbGotop())
While !Eof()

	nClass := 0
	nSld01 := 0
	nSld04 := 0
	nSld14 := 0
	nSld3o := 0
	nCompr := 0

	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek( xFilial("SB2") + TSQL->COD + "01" )
		nSld01 := SB2->( B2_QATU - (B2_QEMP + B2_RESERVA) )
		nClass += SB2->B2_QACLASS
	Endif

	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek( xFilial("SB2") + TSQL->COD + "04" )
		nSld04 := SB2->( B2_QATU - (B2_QEMP + B2_RESERVA) )
		nClass += SB2->B2_QACLASS
	Endif

	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek( xFilial("SB2") + TSQL->COD + "14" )
		nSld14 := SB2->( B2_QATU - (B2_QEMP + B2_RESERVA) )
		nClass += SB2->B2_QACLASS
	Endif

	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek( xFilial("SB2") + TSQL->COD )
		While !Eof() .And. SB2->(B2_FILIAL+B2_COD) == xFilial("SB2") + TSQL->COD
			nSld3o += SB2->B2_QNPT
			SB2->(DbSkip())
		Enddo
	Endif

	lRequi := .F.
	nDispo := ((TSQL->SLD + nClass + TSQL->ENT) - TSQL->SAI)
	If nDispo < 0
		nCompr := ABS(nDispo)
	Endif
	If nSld01 < TSQL->SAI
		lRequi := .T.
	Endif

	RecLock("TMP",.T.)
	TMP->MRP_COD := TSQL->COD
	TMP->MRP_DES := TSQL->DESCR
	TMP->MRP_TIP := TSQL->TIPO
	TMP->MRP_SLD := TSQL->SLD + nClass
	TMP->MRP_CLA := nClass
	TMP->MRP_SAI := TSQL->SAI
	TMP->MRP_ENT := TSQL->ENT
	TMP->MRP_A01 := nSld01
	TMP->MRP_A04 := nSld04
	TMP->MRP_A14 := nSld14
	TMP->MRP_A3O := nSld3o
	TMP->MRP_COM := nCompr
	TMP->MRP_REQ := IIf(lRequi,"Sim","N�o")
	MsUnLock()

	DbSelectArea("TSQL")
	TSQL->(DbSkip())
Enddo
TSQL->(DbCloseArea())

DbSelectArea("TMP")
TMP->(DbGotop())
oReport:SetMeter(TMP->(RecCount()))
oSection1:Init()
While !Eof()
	oReport:IncMeter()
	If (mv_par03 == 1 .And. TMP->MRP_REQ == "Sim") .Or. (mv_par03 == 2)
		oSection1:PrintLine()
	Endif	
	TMP->(DbSkip())
	If Eof()
		oSection1:Finish()
		oReport:ThinLine()
	Endif
Enddo
TMP->(DbCloseArea())
oTempTable:Delete()

Return
