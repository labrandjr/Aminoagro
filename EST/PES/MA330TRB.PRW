#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA330TRB ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 24/11/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Altera sequência de cálculo no custo médio.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA330TRB()

Local aArea    := GetArea()
Local aAreaTrb := TRB->(GetArea())

MsgRun("Aguarde, reordenando movimentos...","Processando",{|| U_AMN330() })

RestArea(aAreaTrb)
RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMN330   ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 04/01/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa processamento.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMN330()

DbSelectArea("TRB")
DbSetOrder(2)
TRB->(DbGotop())
While !Eof()

	If TRB->TRB_ALIAS == "SD1" .And. TRB->TRB_ORDEM == "500"
		If _ReqPer()
			RecLock("TRB",.F.)
			TRB->TRB_ORDEM := "200" // Caso haja devolução de vendas no mesmo período que requisições (RE4, RE7 ou RE0) trata
			MsUnLock()              // sequência como "200 - Entrada por Devolução de Vendas - Período Anterior".
		Else	
			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + Space(3) + TRB_SEQ) )
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := SZP->ZP_ORDEM // 200
				MsUnLock()
			Endif
		Endif
	ElseIf TRB->TRB_ALIAS == "SD1" .And. TRB->TRB_LOCAL == "98" .And. !Empty(TRB->TRB_TES) .And. TRB->TRB_ORDEM <> "100" // Tratamento para transferência de filiais com armazém 98
		DbSelectArea("SF4")
		DbSetOrder(1)
		If DbSeek( TRB->(TRB_FILIAL + TRB_TES) )
			If SF4->F4_TRANFIL == "1"
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM  := "100"
				TRB->TRB_NIVEL  := "" // 99
				TRB->TRB_NIVSD3 := "" // 5
				MsUnLock()
				// No padrão a ordem é 300, pois segue o conceito do custo da entrada ser o da saída origem. 
				// Porém no armazém destino, essa movimentação precisa vir primeiro, pois não estava valorizando os demais movimentos desse armazém provocando sobra de custo.
			Endif
		Endif
	ElseIf TRB->TRB_ALIAS == "SD1"
		DbSelectArea("SZP")
		DbSetOrder(1)
		If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + Space(3) + TRB_SEQ) )
			RecLock("TRB",.F.)
			TRB->TRB_ORDEM := SZP->ZP_ORDEM // 200
			MsUnLock()
		Endif
	ElseIf TRB->TRB_ALIAS == "SD2" .And. TRB->TRB_ORDEM == "150"
		DbSelectArea("SZP")
		DbSetOrder(1)
		If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + Space(3) + TRB_SEQ) )
			RecLock("TRB",.F.)
			TRB->TRB_ORDEM := SZP->ZP_ORDEM // 301
			MsUnLock()
		Endif
	ElseIf TRB->TRB_ALIAS == "SD3"
		// 1.Movimentos Internos Valorizados sem Quantidade
		If TRB->TRB_CF == "DE6"
			If TRB->TRB_TIPO != "T"
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := "291"
				MsUnLock()
			Endif	
		ElseIf TRB->TRB_CF == "RE6"
			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + "XE6" + TRB_SEQ) )
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := SZP->ZP_ORDEM // 293
				MsUnLock()
			Endif
		// 2.Ordem de Produção
		ElseIf TRB->TRB_CF $("RE0,RE1,PR0")
			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + "XPR" + TRB_SEQ) )
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := SZP->ZP_ORDEM // 292
				MsUnLock()
			Endif
		// 3.Transferência
		ElseIf TRB->TRB_CF $("DE4,RE4")
			lAltOrd := .T.
			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + "XE4" + TRB_SEQ) )
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := SZP->ZP_ORDEM // 293
				MsUnLock()
				lAltOrd := .F.
			Endif
			If lAltOrd
				If _De4Re7()
					RecLock("TRB",.F.)
					TRB->TRB_ORDEM := "293"
					MsUnLock()
				Endif
			Endif
		// 4.Desmontagem
		ElseIf TRB->TRB_CF $("DE7,RE7")
			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + "XE7" + TRB_SEQ) )
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := SZP->ZP_ORDEM // 293
				MsUnLock()
			Else
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := "294"
				MsUnLock()
			Endif	
		// 5.Inventário
		ElseIf TRB->TRB_CF $("DE0")
			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek( TRB->(TRB_FILIAL + TRB_ALIAS + "XE0" + TRB_SEQ) )
				RecLock("TRB",.F.)
				TRB->TRB_ORDEM := SZP->ZP_ORDEM // 291
				MsUnLock()
			Endif
		Endif
	Endif

	// ******************************* //
	// ** Grava arquivo de trabalho ** //
	// ******************************* //
	DbSelectArea("ZZC")
	RecLock("ZZC",.T.)
	ZZC->ZZC_FILIAL := TRB->TRB_FILIAL
	ZZC->ZZC_ALIAS  := TRB->TRB_ALIAS
	ZZC->ZZC_CHAVE  := TRB->TRB_CHAVE
	ZZC->ZZC_COD    := TRB->TRB_COD
	ZZC->ZZC_DTBASE := TRB->TRB_DTBASE
	ZZC->ZZC_SEQPRO := TRB->TRB_SEQPRO
	ZZC->ZZC_ORDEM  := TRB->TRB_ORDEM
	ZZC->ZZC_NIVEL  := TRB->TRB_NIVEL
	ZZC->ZZC_NIVSD3 := TRB->TRB_NIVSD3
	ZZC->ZZC_OP     := TRB->TRB_OP
	ZZC->ZZC_CF     := TRB->TRB_CF
	ZZC->ZZC_SEQ    := TRB->TRB_SEQ
	ZZC->ZZC_DTORIG := TRB->TRB_DTORIG
	ZZC->ZZC_TES    := TRB->TRB_TES
	ZZC->ZZC_DOC    := TRB->TRB_DOC
	ZZC->ZZC_TIPO   := TRB->TRB_TIPO
	ZZC->ZZC_LOCAL  := TRB->TRB_LOCAL
	MsUnLock()
	
	DbSelectArea("TRB")
	TRB->(DbSkip())

Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _De4Re7  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 18/09/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia se existe Transferência x Desmontagem no período.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _De4Re7()

Local aArea := GetArea()
Local lRetorno := .F.

// Verifica se não é Transferência de Lote
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL = '"+TRB->TRB_FILIAL+"' "
cQuery += " AND D3_DOC = '"+TRB->TRB_DOC+"' "
cQuery += " AND D3_NUMSEQ = '"+TRB->TRB_SEQ+"' "
cQuery += " AND D3_COD = '"+AllTrim(TRB->TRB_COD)+"' "
cQuery += " AND D3_LOCAL = '"+TRB->TRB_LOCAL+"' "
If TRB->TRB_CF == "DE4"
	cQuery += " AND D3_CF = 'RE4' "
ElseIf TRB->TRB_CF == "RE4"
	cQuery += " AND D3_CF = 'DE4' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
lTrfLote := (SQL1->SOMA > 0)
SQL1->(DbCloseArea())

If !lTrfLote
	cQuery := " SELECT D3_FILIAL, D3_COD, D3_LOCAL "
	cQuery += " FROM "+RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL = '"+TRB->TRB_FILIAL+"' "
	cQuery += " AND D3_DOC = '"+TRB->TRB_DOC+"' "
	cQuery += " AND D3_NUMSEQ = '"+TRB->TRB_SEQ+"' "
	cQuery += " AND D3_CF = 'DE4' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	SQL1->(DbGotop())
	If !Eof()
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+SQL1->D3_FILIAL+"' "
		cQuery += " AND D3_COD = '"+SQL1->D3_COD+"' "
		cQuery += " AND D3_LOCAL = '"+SQL1->D3_LOCAL+"' "
		cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(GetMv("MV_ULMES")+1)+"' AND '"+DtoS(TRB->TRB_DTBASE)+"' "
		cQuery += " AND D3_CF IN('RE7') "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
		lRetorno := (SQL2->SOMA > 0)
		SQL2->(DbCloseArea())
	Endif
	SQL1->(DbCloseArea())
Endif

RestArea(aArea)

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _ReqPer  ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 07/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia se existe Requisições no mesmo período.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _ReqPer()

Local aArea := GetArea()
Local lRetorno := .F.

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL = '"+TRB->TRB_FILIAL+"' "
cQuery += " AND D3_COD = '"+AllTrim(TRB->TRB_COD)+"' "
cQuery += " AND D3_LOCAL = '"+TRB->TRB_LOCAL+"' "
cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(GetMv("MV_ULMES")+1)+"' AND '"+DtoS(TRB->TRB_DTBASE)+"' "
cQuery += " AND D3_CF IN('RE4','RE7','RE0') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
lRetorno := (SQL2->SOMA > 0)
SQL2->(DbCloseArea())

RestArea(aArea)

Return(lRetorno)

/*
TRB_ALIAS
TRB_RECNO

TRB_CHAVE
TRB_COD

TRB_DTBASE
TRB_SEQPRO
TRB_ORDEM
TRB_NIVEL
TRB_NIVSD3

TRB_OP
TRB_CF
TRB_SEQ

TRB_DTORIG
TRB_RECSD1
TRB_TES
TRB_DOC
TRB_TIPO
TRB_LOCAL
TRB_RECSBD
TRB_RECTRB
TRB_TIPON

//-- Criando Arquivo Trabalho 3...
INDEX ON DTOS(TRB_DTBASE)+TRB_SEQPRO+TRB_ORDEM+TRB_NIVEL+TRB_NIVSD3+TRB_CHAVE+TRB_SEQ TO (cNomTrb3+".cdx")	

*/

/*
Sequência de Cálculo:
---------------------
http://tdn.totvs.com/display/public/mp/Ponto+de+Entrada+MA330TRB

/*
Parâmetro Thread:
MV_A330THR = 5
MV_M330THR = 5
