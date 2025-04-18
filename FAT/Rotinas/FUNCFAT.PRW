#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � FUNCFAT   � Autor �  F�brica ERP.BR   �   Data  � 11/04/18 ���
��+----------+------------------------------------------------------------���
���Descricao � Fun��es Gen�ricas - M�dulo Faturamento.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

// ********************************************************************************************************** //
// ** Luis Brandini - 11/04/18
// ********************************************************************************************************** //
// ** Valida��o na digita��o das datas de vencimento das parcelas no pedido - condi��o de pagamento tipo 9 ** //
// ********************************************************************************************************** //
User Function X410Venc()

Local aArea := GetArea()
Local cVar  := &(ReadVar())
Local lRet  := .T.

//������������������������������������������������������Ŀ
//�Somente obriga a digita�ao da data do vencimento      �
//�quando a condi��o de pagamento for tipo 9.            �
//��������������������������������������������������������
dbSelectArea("SE4")
dbSetOrder(1)
If dbSeek(xFilial()+m->c5_condpag)
	If SE4->E4_TIPO == "9"
		If DtoS(cVar) < DtoS(M->C5_EMISSAO) .And. !Empty(cVar)
			Help(" ",1,"A410VENC")
			lRet := .F.
		Endif		
	Endif
Endif

RestArea(aArea)

Return(lRet)

// Fun��o original com error.log no fonte MATV410
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a410Venc  �  Autor� Cristina Ogura        � Data � 18.09.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se os vencimentos digitados no pedido sao menores  ���
���          �que a data de emissao do pedido.                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
Function A410Venc()
Local cVar := &(ReadVar())
Local cAlias := Alias()
Local lRet   := .T.

//������������������������������������������������������Ŀ
//�Somente obriga a digita�ao da data do vencimento      �
//�quando a condi��o de pagamento for tipo 9.            �
//��������������������������������������������������������
dbSelectArea("SE4")
dbSetOrder(1)
If dbSeek(xFilial()+m->c5_condpag)
	If SE4->E4_TIPO == "9"
		If DtoS(cVar) < DtoS(M->C5_EMISSAO) .And. !Empty(cVar)
			Help(" ",1,"A410VENC")
			lRet := .F.
		Endif		
	Endif
Endif
dbSelectArea(cAlias)
Return lRet      
*/

// *************************************************************************************************************** //
// ** Luis Brandini - 19/07/18
// *************************************************************************************************************** //
// ** Fun��o para somar as movimenta��es banc�rias baseadas na sequ�ncia registrada em manuten��o de comiss�es. ** //
// *************************************************************************************************************** //
User Function E5SomaSeq(zPref,zNume,zParc,zTipo,zClie,zLoja,zSequ)

Local aArea := GetArea()
Local nRet  := 0

DbSelectArea("SE5")
DbSetOrder(7)
If DbSeek( xFilial("SE5") + zPref + zNume + zParc + zTipo + zClie + zLoja + zSequ )
	While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) == xFilial("SE5") + zPref + zNume + zParc + zTipo + zClie + zLoja + zSequ
		If !(SE5->E5_TIPODOC $("JR,MT,DC,ES"))
			nRet += SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
		Endif	
		SE5->(DbSkip())
	Enddo
Endif

RestArea(aArea)

/*
(RetField("SE5",7,xFilial("SE5")+CELL(AJ)+CELL(AK)+CELL(AL)+CELL(B4)+CELL(AO)+"01"+CELL(B2),"E5_VALOR") - (RetField("SE5",7,xFilial("SE5")+CELL(AJ)+CELL(AK)+CELL(AL)+CELL(B4)+CELL(AO)+"01"+CELL(B2),"E5_VLJUROS") + RetField("SE5",7,xFilial("SE5")+CELL(AJ)+CELL(AK)+CELL(AL)+CELL(B4)+CELL(AO)+"01"+CELL(B2),"E5_VLMULTA")) + RetField("SE5",7,xFilial("SE5")+CELL(AJ)+CELL(AK)+CELL(AL)+CELL(B4)+CELL(AO)+"01"+CELL(B2),"E5_VLDESCO"))
*/

Return(nRet)

// ****************************************************************** //
// ** Luis Brandini - 17/01/2020
// ****************************************************************** //
// ** Pesquisa e retorna chave da Nf-e a partir do Alias informado ** //
// ****************************************************************** //
User Function GetChvNfe(zAlias)

Local zChvNfe := Space(44)

If zAlias == "SE1"
	If !Empty(SE1->E1_ZFILINC)
		zFilNfs := SE1->E1_ZFILINC
	Else
		zFilNfs := xFilial("SF2")
	Endif	
	zChvNfe := Posicione("SF2",1,zFilNfs+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA),"F2_CHVNFE")
Endif

Return(zChvNfe)

// ****************************************************************** //
// ** Luis Brandini - 20/06/2020
// ****************************************************************** //
// ** Avalia se existe quantidade pendente de faturamento		   ** //
// ****************************************************************** //
User Function SaldoLib(zPedido)

Local aArea := GetArea()
Local lRetX := .F.

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SC9")
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND C9_PEDIDO = '"+zPedido+"' "
cQuery += " AND C9_NFISCAL = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL9", .F., .T.)
lRetX := (SQL9->SOMA > 0)
SQL9->(DbCloseArea())

RestArea(aArea)

Return(lRetX)
