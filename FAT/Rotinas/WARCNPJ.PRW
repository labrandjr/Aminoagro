#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � WARCNPJ   � Autor � F�brica ERPBR    �   Data  � 04/06/18  ���
��+----------+------------------------------------------------------------���
���Descricao � Atualiza��o de flag nas compras de mat�ria-prima. 		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function WARCNPJ()

Local cPerg	 := Padr("WARCNPJ",10)
Private cEOL := CHR(13)+CHR(10)
Private oProcess

If __cUserId != "000000"
	MsgInfo("Usu�rio n�o autorizado.")
	Return
Endif

If Pergunte(cPerg,.T.)
	Preparar()
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � Preparar  � Autor � Fabrica ERPBR    � Data �  14/06/18	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Prepara o processamento principal.						  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Enviando e-mails para alerta de altera��o do cnpj.", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	MsgBox("Processo conclu�do !!!","Aviso","INFO")
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data �  14/06/18	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da rotina.									  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo QUALYQUIMICA									  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

// Clientes
If mv_par01 == 1 .Or. mv_par01 == 3

	cAssunto := "Comunicado Qualyqu�mica - Mudan�a no Cnpj"

	oProcess:SetRegua1(2)
	
	oProcess:IncRegua1("Selecionando registros..")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SA1")
	cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += " AND A1_COD BETWEEN '"+mv_par02+"' AND '"+mv_par03+"' "
	cQuery += " AND A1_EMAIL <> ' ' "
	If mv_par06 == 1 // Reenvio = N�o
		cQuery += " AND A1_MAILCGC = ' ' "
	Endif
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	nTotSql := SQL1->SOMA
	SQL1->(DbCloseArea())

	oProcess:IncRegua1("Selecionando registros..")
	cQuery := " SELECT A1_COD, A1_LOJA "
	cQuery += " FROM "+RetSqlName("SA1")
	cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += " AND A1_COD BETWEEN '"+mv_par02+"' AND '"+mv_par03+"' "
	cQuery += " AND A1_EMAIL <> ' ' "
	If mv_par06 == 1 // Reenvio = N�o
		cQuery += " AND A1_MAILCGC = ' ' "
	Endif
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	
	oProcess:SetRegua1(nTotSql)
	DbSelectArea("SQL1")
	SQL1->(DbGotop())
	While !Eof()
		
		oProcess:IncRegua1("Processando...")
	
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SQL1->A1_COD + SQL1->A1_LOJA )

		aMensage := {}
		AAdd(aMensage, "Prezado(a) "+CapitalAce(SA1->A1_NOME))
		AAdd(aMensage, "")
		AAdd(aMensage, "Qualyqu�mica S.A., empresa com sede na Cidade de Indaiatuba/SP, a av. Presidente Kennedy, 1386,")
		AAdd(aMensage, "9�andar, inscrita no CNPJ/MF 08.909.993/0001-20, DECLARA para os devidos fins de Direito e em")
		AAdd(aMensage, "especial raz�o pelo recebimento de produtos e servi�os que a cia. contrata de diversos")
		AAdd(aMensage, "estabelecimentos do pa�s, informa as seguintes mudan�as em sua estrutura organizacional:")
		AAdd(aMensage, "")
		AAdd(aMensage, "MATRIZ")
		AAdd(aMensage, "Qualyqu�mica Ind�stria E Com�rcio de Produtos Qu�micos S.A.")
		AAdd(aMensage, "CNPJ/MF: 08.909.993/0001-20")
		AAdd(aMensage, "IE: 353.332.180.110")
		AAdd(aMensage, "Endere�o: Av.Presidente Kennedy, 1386, 9� andar - Indaiatuba - SP")
		AAdd(aMensage, "")
		AAdd(aMensage, "FILIAL")
		AAdd(aMensage, "Qualyqu�mica Ind�stria E Com�rcio de Produtos Qu�micos S.A.")
		AAdd(aMensage, "CNPJ/MF: 08.909.993/0002-01")
		AAdd(aMensage, "IE: 10.414.195-6")
		AAdd(aMensage, "Endere�o: Quadra 9, S/N - Lote 15 - Loteamento - Recreio Mossor� - Cidade Ocidental - GO")
		AAdd(aMensage, "")
		AAdd(aMensage, "Assim � que, tendo sido conclu�do todo o processo de transfer�ncia de endere�o e regulariza��o")
		AAdd(aMensage, "de documentos fiscais resultando na substitui��o acima mencionadas, solicitamos que efetuem as")
		AAdd(aMensage, "devidas altera��es em seus cadastros.")
		AAdd(aMensage, "")
		AAdd(aMensage, "Tal altera��o � resultante de an�lises e posi��o estrat�gica adotada pelo Grupo Econ�mico Qualyqu�mica.")
		AAdd(aMensage, "")
		AAdd(aMensage, "ATEN��O: NOTAS FISCAIS ENVIADAS COM DIVERG�NCIA EM ENDERE�O OU CNPJ, QUAIS N�O SEJAM CONFORME QUADRO ACIMA N�O SER�O RECEBIDAS.")
		AAdd(aMensage, "")
		AAdd(aMensage, "Sendo s� para o momento,")
		AAdd(aMensage, "Qualyqu�mica Ind. E Com. De Produtos Qu�micos S.A.")

		zEmail  := AllTrim(Lower(SA1->A1_EMAIL))
		zTitulo := "Mudan�a de CNPJ"
		zResult := U_TMailWar(zTitulo, zEmail, cAssunto, aMensage)

		RecLock("SA1",.F.)
		SA1->A1_MAILCGC := "S"
		MsUnLock()

		DbSelectArea("SQL1")
		SQL1->(DbSkip())		
	Enddo
	SQL1->(DbCloseArea())

Endif

// Fornecedores
If mv_par01 == 2 .Or. mv_par01 == 3

	cAssunto := "Comunicado Qualyqu�mica - Mudan�a no Cnpj"
	
	oProcess:SetRegua2(2)
	
	oProcess:IncRegua2("Selecionando registros..")
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SA2")
	cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
	cQuery += " AND A2_COD BETWEEN '"+mv_par04+"' AND '"+mv_par05+"' "
	cQuery += " AND A2_EMAIL <> ' ' "
	If mv_par06 == 1 // Reenvio = N�o
		cQuery += " AND A2_MAILCGC = ' ' "
	Endif
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	nTotSql := SQL1->SOMA
	SQL1->(DbCloseArea())

	oProcess:IncRegua2("Selecionando registros..")
	cQuery := " SELECT A2_COD, A2_LOJA "
	cQuery += " FROM "+RetSqlName("SA2")
	cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
	cQuery += " AND A2_COD BETWEEN '"+mv_par04+"' AND '"+mv_par05+"' "
	cQuery += " AND A2_EMAIL <> ' ' "
	If mv_par06 == 1 // Reenvio = N�o
		cQuery += " AND A2_MAILCGC = ' ' "
	Endif
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY A2_FILIAL, A2_COD, A2_LOJA "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

	oProcess:SetRegua2(nTotSql)
	DbSelectArea("SQL1")
	SQL1->(DbGotop())
	While !Eof()
		
		oProcess:IncRegua2("Processando...")
	
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SQL1->A2_COD + SQL1->A2_LOJA )

		aMensage := {}
		AAdd(aMensage, "Prezado(a) "+CapitalAce(SA2->A2_NOME))
		AAdd(aMensage, "")
		AAdd(aMensage, "Qualyqu�mica S.A., empresa com sede na Cidade de Indaiatuba/SP, a av. Presidente Kennedy, 1386,")
		AAdd(aMensage, "9�andar, inscrita no CNPJ/MF 08.909.993/0001-20, DECLARA para os devidos fins de Direito e em")
		AAdd(aMensage, "especial raz�o pelo recebimento de produtos e servi�os que a cia. contrata de diversos")
		AAdd(aMensage, "estabelecimentos do pa�s, informa as seguintes mudan�as em sua estrutura organizacional:")
		AAdd(aMensage, "")
		AAdd(aMensage, "MATRIZ")
		AAdd(aMensage, "Qualyqu�mica Ind�stria E Com�rcio de Produtos Qu�micos S.A.")
		AAdd(aMensage, "CNPJ/MF: 08.909.993/0001-20")
		AAdd(aMensage, "IE: 353.332.180.110")
		AAdd(aMensage, "Endere�o: Av.Presidente Kennedy, 1386, 9� andar - Indaiatuba - SP")
		AAdd(aMensage, "")
		AAdd(aMensage, "FILIAL")
		AAdd(aMensage, "Qualyqu�mica Ind�stria E Com�rcio de Produtos Qu�micos S.A.")
		AAdd(aMensage, "CNPJ/MF: 08.909.993/0002-01")
		AAdd(aMensage, "IE: 10.414.195-6")
		AAdd(aMensage, "Endere�o: Quadra 9, S/N - Lote 15 - Loteamento - Recreio Mossor� - Cidade Ocidental - GO")
		AAdd(aMensage, "")
		AAdd(aMensage, "Assim � que, tendo sido conclu�do todo o processo de transfer�ncia de endere�o e regulariza��o")
		AAdd(aMensage, "de documentos fiscais resultando na substitui��o acima mencionadas, solicitamos que efetuem as")
		AAdd(aMensage, "devidas altera��es em seus cadastros.")
		AAdd(aMensage, "")
		AAdd(aMensage, "Tal altera��o � resultante de an�lises e posi��o estrat�gica adotada pelo Grupo Econ�mico Qualyqu�mica.")
		AAdd(aMensage, "")
		AAdd(aMensage, "ATEN��O: NOTAS FISCAIS ENVIADAS COM DIVERG�NCIA EM ENDERE�O OU CNPJ, QUAIS N�O SEJAM CONFORME QUADRO ACIMA N�O SER�O RECEBIDAS.")
		AAdd(aMensage, "")
		AAdd(aMensage, "Sendo s� para o momento,")
		AAdd(aMensage, "Qualyqu�mica Ind. E Com. De Produtos Qu�micos S.A.")

		zEmail  := AllTrim(Lower(SA2->A2_EMAIL))
		zTitulo := "Mudan�a de CNPJ"
		zResult := U_TMailWar(zTitulo, zEmail, cAssunto, aMensage)

		RecLock("SA2",.F.)
		SA2->A2_MAILCGC := "S"
		MsUnLock()
	
		DbSelectArea("SQL1")
		SQL1->(DbSkip())		
	Enddo
	SQL1->(DbCloseArea())

Endif

Return
