#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MSE3440  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 06/06/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Complementa gravação após recalculo da comissão.           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MSE3440()

Local aArea    := GetArea()
Local zModAtra := AllTrim(GetMv("MV_ZMODATR")) // 1=Calcula pelo Vencto.Real | 2=Calcula pelo Vencto.Original
// ***************************************************************************** //
// *** Cálculo para Revendas - Tabela progressiva de %Desconto x Dias Atraso *** //
// ***************************************************************************** //
/*
E3_ZZCOMIS - Valor Original
E3_ZZATRAS - Dias Atraso
E3_ZZPDESC - % Desconto Atraso
E3_ZZVDESC - Valor Desconto Atraso
*/

// Inserido para corrigir erro no processo padrão da Totvs - 07/09/2021
// Gerando comissão para motivos de baixa configurados com COMISSÃO = Não, quando o título possui múltiplas baixas parciais no período processado, 
// sendo parte delas com Motivo de Baixa que GERA comissão, e parte delas com Motivo de Baixa que NÃO GERA comissão.
// A rotina gera para todos os movimentos indevidamente.
aAreaE5 := SE5->(GetArea())
nRecnE5 := SE5->(Recno())
DbSelectArea("SE5")
DbSetOrder(7)
If DbSeek( SE3->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_CODCLI+E3_LOJA+E3_SEQ) )
	If SE5->E5_MOTBX == "BON" .Or. SE5->E5_MOTBX == "ACO"
		RecLock("SE3",.F.)
		DbDelete()
		MsUnLock()
		Return
	Endif
Endif
SE5->(RestArea(aAreaE5))
SE5->(DbGoto(nRecnE5))

If SE3->E3_FILIAL == "0108" .And. SE3->E3_EMISSAO < StoD("20181201") // Implantação da Filial 0108 em 01/12/2018
	RecLock("SE3",.F.)
	DbDelete()
	MsUnLock()
	Return
Endif 

If SE3->E3_FILIAL $ "0106,0107" .And. SE3->E3_EMISSAO < StoD("20200201") // Implantação da Filial 0106 e 0107 em 01/02/2020
	RecLock("SE3",.F.)
	DbDelete()
	MsUnLock()
	Return
Endif 

RecLock("SE3",.F.)
SE3->E3_ZZCOMIS := SE3->E3_COMIS // Repete valor da comissão para todos, independente de haver desconto.
SE3->E3_VENCTO  := SE3->E3_EMISSAO // Garante vencimento da comissão idêntica à emissão (data do pagamento do título).
MsUnLock()

If SE3->E3_TIPO != "NCC"

	nRecSE5 := SE5->(Recno())
	lOkSE5  := .F.

	DbSelectArea("SE5")
	DbSetOrder(7)
	If DbSeek( SE3->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_CODCLI+E3_LOJA+E3_SEQ) )

		lOkSE5  := .T.

	Else

		cQuery := " SELECT R_E_C_N_O_ "
		cQuery += " FROM "+RetSqlName("SE5")
		cQuery += " WHERE E5_FILORIG = '"+SE3->E3_FILIAL+"' " // Se não acha pela FILIAL, localiza pela FILIAL ORIGEM
		cQuery += " AND E5_PREFIXO = '"+SE3->E3_PREFIXO+"' "
		cQuery += " AND E5_NUMERO = '"+SE3->E3_NUM+"' "
		cQuery += " AND E5_PARCELA = '"+SE3->E3_PARCELA+"' "
		cQuery += " AND E5_TIPO = '"+SE3->E3_TIPO+"' "
		cQuery += " AND E5_CLIFOR = '"+SE3->E3_CODCLI+"' "
		cQuery += " AND E5_LOJA = '"+SE3->E3_LOJA+"' "
		cQuery += " AND E5_SEQ = '"+SE3->E3_SEQ+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)

		DbSelectArea("SQL5")
		SQL5->(DbGotop())
		If !Eof()
			lOkSE5  := .T.
			DbSelectArea("SE5")
			SE5->(DbGoto(SQL5->R_E_C_N_O_))
		Endif
		SQL5->(DbCloseArea())

	Endif	

	If lOkSE5

		zAtraso := 0
		zFilInc := SE5->E5_FILORIG
		DbSelectArea("SE1")
		DbSetOrder(2)
		If DbSeek( SE5->(E5_FILORIG+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) )

			// ************************************************** //
			// *** Gravação do | GER | DIR | DM | no Vendedor *** //
			// ************************************************** //
			If (SE3->E3_VEND == SE1->E1_VEND1 .And. Substr(SE1->E1_VEND1,1,1) == "V") .Or.;
			   (SE3->E3_VEND == SE1->E1_VEND3 .And. Substr(SE1->E1_VEND3,1,1) == "V")
				RecLock("SE3",.F.)
				SE3->E3_ZZGER := SE1->E1_GEREN1
				SE3->E3_ZZSUP := SE1->E1_SUPER1
				SE3->E3_ZZDM  := SE1->E1_ZZDM
				MsUnLock()
			Endif

			If zModAtra == "2"
				zAtraso := SE5->E5_DATA - DataValida(SE1->E1_VENCORI,.T.)
			Else
				zAtraso := SE5->E5_DATA - SE1->E1_VENCREA
			Endif
			If !Empty(SE1->E1_ZFILINC)
				zFilInc := SE1->E1_ZFILINC
			Endif
		
		Endif

		zIcms := 0
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek( zFilInc + SE3->(E3_NUM + E3_PREFIXO + E3_CODCLI + E3_LOJA) )
			zIcms := ( SF2->(F2_VALICM / F2_VALBRUT) * 100 )
		Endif

		zPgCli  := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
		zValPg  := SE5->(E5_VALOR-(E5_VLJUROS+E5_VLMULTA)+E5_VLDESCO)
		zValIcm := (zValPg * (zIcms/100))
		If SF2->F2_EST == "EX"
			zPropPg := (zValPg / SF2->F2_VALFAT)
			zFrtSeg := SF2->(F2_FRETE+F2_SEGURO) * zPropPg
			zValPg  -= zFrtSeg
		Endif

		RecLock("SE3",.F.)
		SE3->E3_BASE    := zValPg - zValIcm
		SE3->E3_COMIS   := SE3->E3_BASE * (SE3->E3_PORC/100)
		SE3->E3_ZZCOMIS := SE3->E3_COMIS
		SE3->E3_ZVLPAGO := zPgCli
		SE3->E3_ZICMS   := zIcms
		SE3->E3_ZVALICM := zValIcm
		SE3->E3_ZFILINC := SE1->E1_ZFILINC
		MsUnLock()
		
		If zAtraso >= 9999
			zAtraso := 9999
		Endif

		If zAtraso > 0

			RecLock("SE3",.F.)
			SE3->E3_ZZATRAS := zAtraso
			MsUnLock()

			zPDescon := 0
			If Substr(SE3->E3_VEND,1,1) == "R" // Revenda
				If zAtraso > 60 // Acima de 60 dias de atraso NÃO RECEBE O PRÊMIO.
					zPDescon := 100
				ElseIf zAtraso > 30 // 31 a 60 dias de atraso = 50% do prêmio;
					zPDescon := 50
				ElseIf zAtraso > 15 // 16 a 30 dias de atraso = 80% do prêmio;
					zPDescon := 20
				Else // Até 15 dias de atraso = 90% do prêmio;
					zPDescon := 10	
				Endif
			Else // Todos exceto Revenda
				If zAtraso > GetMv("MV_DIATRTV") // Acima de N dias de atraso NÃO RECEBE O PRÊMIO.
					zPDescon := 100
				Endif
			Endif	

			If zPDescon > 0
				RecLock("SE3",.F.)
				SE3->E3_ZZPDESC := zPDescon
				If zPDescon == 100
					SE3->E3_ZZVDESC := SE3->E3_COMIS
					SE3->E3_COMIS   := 0.00
				Else
					SE3->E3_ZZVDESC := (SE3->E3_COMIS * (zPDescon/100))
					SE3->E3_COMIS   := SE3->E3_COMIS - SE3->E3_ZZVDESC
				Endif	
				MsUnLock()
			Endif

		Endif	

		// ** Início Metas ** //
		If Year(SE1->E1_EMISSAO) >= 2020
			zAno   := Substr(DtoS(SE1->E1_EMISSAO),1,4)
			zPMeta := u_GetPMeta(SE3->E3_VEND,zAno)
			//
			RecLock("SE3",.F.)
			SE3->E3_MTCOMIS := SE3->E3_COMIS // Armazena valor da comissão calculado antes de checar metas
			SE3->E3_MTPMETA := zPMeta
			SE3->E3_COMIS   := (SE3->E3_COMIS * (zPMeta/100))
			MsUnLock()
		Endif
		// ** Fim Metas ** //	

	Endif	
	SE5->(DbGoto(nRecSE5))
Endif

// *********************************************** //
// *** Gravação do GER e DIR no Vendedor - NCC *** //
// *********************************************** //
If SE3->E3_TIPO == "NCC"
	// Devoluções de Venda - GER e DIR nos Documentos de Saída origem
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek( xFilial("SF1") + SE3->(E3_NUM+E3_SERIE+E3_CODCLI+E3_LOJA) + "D" )
		//
		nRecSD1 := SD1->(Recno())
		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
		//
		While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
            //
            DbSelectArea("SF2")
            DbSetOrder(1)
            If DbSeek( xFilial("SF2") + SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA) )
				//
				If (SE3->E3_VEND == SF2->F2_VEND1 .And. Substr(SF2->F2_VEND1,1,1) == "V") .Or.;
				   (SE3->E3_VEND == SF2->F2_VEND3 .And. Substr(SF2->F2_VEND3,1,1) == "V")
					RecLock("SE3",.F.)
					SE3->E3_ZZGER := SF2->F2_GEREN1
					SE3->E3_ZZSUP := SF2->F2_SUPER1
					SE3->E3_ZZDM  := SF2->F2_ZZDM
					MsUnLock()
					Exit
				Endif
                //
            Endif
            //
			DbSelectArea("SD1")
			SD1->(DbSkip())
		Enddo
		SD1->(DbGoto(nRecSD1))
	Endif
Endif

RestArea(aArea)

Return
