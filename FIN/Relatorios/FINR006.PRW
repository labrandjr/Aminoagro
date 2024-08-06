#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FINR006  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 31/07/2018      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de Títulos a Receber - Detalhes.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FINR006()

Local cPerg := "FINR06"
Private cPath := "c:\report\"
Private oTempTable

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pFinR06()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pFinR06   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 31/07/2018     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pFinR06()

Local oExcel   := FwMsExcel():New()
Local zFiliais := ""
Local nForFilial

Finr6Trab()

aFilsCalc := MatFilCalc( mv_par06 == 1 )
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial][1]
		zFiliais += IIf(!Empty(zFiliais),",","") + "'"+AllTrim(aFilsCalc[nForFilial][2])+"'"
	Endif	
Next nForFilial

If Empty(zFiliais)
	MsgInfo("Nenhuma filial selecionada.")
	Return
Endif

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE1") "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E1_VENCREA BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+"' "
If !Empty(mv_par05)
	cQuery += " AND E1_CLIENTE = '"+mv_par05+"' "
Endif
cQuery += " AND E1_TIPO NOT IN('RA','NCC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT E1_FILIAL FILIAL, E1_CLIENTE CLIENTE, E1_LOJA LOJA, E1_PREFIXO PREFIXO, E1_NUM NUMERO, E1_PARCELA PARCELA, E1_TIPO TIPO "
cQuery += " FROM "+RetSqlName("SE1") "
cQuery += " WHERE E1_FILIAL IN("+zFiliais+") "
cQuery += " AND E1_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND E1_VENCREA BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+"' "
If !Empty(mv_par05)
	cQuery += " AND E1_CLIENTE = '"+mv_par05+"' "
Endif
cQuery += " AND E1_TIPO NOT IN('RA','NCC') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, CLIENTE, LOJA, PREFIXO, NUMERO, PARCELA, TIPO "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
While !Eof()

	IncProc("Preparando arquivo...")

	DbSelectArea("SE1")
	DbSetOrder(2)
	If !DbSeek( SQL->(FILIAL+CLIENTE+LOJA+PREFIXO+NUMERO+PARCELA+TIPO) )
		DbSelectArea("SQL")
		SQL->(DbSkip())
		Loop
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE1->E1_CLIENTE )

	zBaixado := 0
	zRenegoc := 0
	zDescCom := 0
	zDescFin := 0
	zMultCom := 0
	zMultFin := 0
	zBDesPon := 0
	zBAcresc := 0
	zBxJuros := 0
	zBDecres := 0

	cQuery := " SELECT R_E_C_N_O_ RECSE5 "
	cQuery += " FROM "+RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '"+SE1->E1_FILIAL+"' "
	cQuery += " AND E5_PREFIXO = '"+SE1->E1_PREFIXO+"' "
	cQuery += " AND E5_NUMERO = '"+SE1->E1_NUM+"' "
	cQuery += " AND E5_PARCELA = '"+SE1->E1_PARCELA+"' "
	cQuery += " AND E5_TIPO = '"+SE1->E1_TIPO+"' "
	cQuery += " AND E5_CLIFOR = '"+SE1->E1_CLIENTE+"' "
	cQuery += " AND E5_LOJA = '"+SE1->E1_LOJA+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY E5_DATA, E5_SEQ "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
	DbSelectArea("SQL5")
	SQL5->(DbGotop())
	While !Eof()

		DbSelectArea("SE5")
		DbGoto(SQL5->RECSE5)
		
		If !(SE5->E5_TIPODOC $("DC,JR,MT,ES"))

			If !u__EstorSe5(SE5->E5_FILIAL, SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, SE5->E5_LOJA, SE5->E5_SEQ)

				zBaixado += SE5->E5_VALOR
				
				If SE5->E5_MOTBX == "LIQ" .And. SE5->E5_TIPODOC == "BA"
					zRenegoc += SE5->E5_VALOR // Baixado por Liquidação
				Endif

				If SE5->E5_VLACRES > 0 // Acréscimo na Baixa
					zBAcresc += SE5->E5_VLACRES // Acréscimo
				ElseIf SE5->E5_VLJUROS > 0
					zBxJuros += SE5->E5_VLJUROS // Juros
				Endif

				If SE5->E5_VLMULTA > 0 // Multa na Baixa
					If SE1->E1_XTPMULT == "1"
						zMultCom += SE5->E5_VLMULTA // Multa Comercial (ou variação cambial)
					Else
						zMultFin += SE5->E5_VLMULTA // Multa Financeira
					Endif	
				Endif

				If SE5->E5_VLDECRE > 0 // Decréscimo na Baixa
					zBDecres += SE5->E5_VLDECRE
				ElseIf SE5->E5_VLDESCO > 0 // Desconto na Baixa
					If SE1->E1_DESCFIN > 0
						zBDesPon := SE5->E5_VLDESCO // Desconto Pontualidade
					Else
						If SE1->E1_XTPDESC == "1"
							zDescCom += SE5->E5_VLDESCO // Desconto Comercial
						Else
							zDescFin += SE5->E5_VLDESCO // Desconto Financeiro
						Endif
					Endif
				Endif

			Endif

		Endif
	
		DbSelectArea("SQL5")
		SQL5->(DbSkip())
	Enddo
	SQL5->(DbCloseArea())

	zzStatus := "Em aberto"
	If SE1->E1_SALDO == 0
		zzStatus := "Baixado"
	ElseIf zBaixado > 0
		zzStatus := "Parcial"	
	Endif

	RecLock("TRB",.T.)
	TRB->TF_CLIENTE := SA1->A1_COD
	TRB->TF_NOMCLI  := SA1->A1_NOME
	TRB->TF_FILIAL  := SE1->E1_FILIAL
	TRB->TF_PREFIXO := SE1->E1_PREFIXO
	TRB->TF_NUM     := SE1->E1_NUM
	TRB->TF_PARCELA := SE1->E1_PARCELA
	TRB->TF_TIPO    := SE1->E1_TIPO
	TRB->TF_EMISSAO := SE1->E1_EMISSAO
	TRB->TF_VENCREA := SE1->E1_VENCREA
	TRB->TF_VALOR   := SE1->E1_VALOR
	TRB->TF_DESCPON := Round(SE1->(E1_VALOR * (E1_DESCFIN/100)),2)
	TRB->TF_ACRESC  := SE1->E1_ACRESC
	TRB->TF_DECRESC := SE1->E1_DECRESC
	TRB->TF_BAIXADO := (zBaixado - zRenegoc)
	TRB->TF_RENEGOC := zRenegoc
	TRB->TF_DESCCOM := zDescCom
	TRB->TF_DESCFIN := zDescFin
	TRB->TF_MULTCOM := zMultCom
	TRB->TF_MULTFIN := zMultFin
	TRB->TF_BXJUROS := zBxJuros
	TRB->TF_BDESPON := zBDesPon
	TRB->TF_BACRESC := zBAcresc
	TRB->TF_BDECRES := zBDecres
	TRB->TF_ZSTATUS := zzStatus
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())
	
Enddo
SQL->(DbCloseArea())

DbSelectArea("TRB")
ProcRegua(RecCount())
TRB->(DbGotop())
If !Eof()

	cNomePlan  := "SE1_FINR06"
	cNomeTable := "Títulos à Receber x Detalhes"
	If !Empty(mv_par05)
		cNomeTable += " - Cliente: "+Posicione("SA1",1,xFilial("SA1")+mv_par05,"A1_NOME")
	Endif
	cNomeTable += " | Emissão de "+DtoC(mv_par01)+" à "+DtoC(mv_par02)
	cNomeTable += " | Vencto. de "+DtoC(mv_par03)+" à "+DtoC(mv_par04)

	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Cliente",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Razão",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Filial",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Prefixo",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Número",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Parcela",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Tipo",1,1) 
	oExcel:AddColumn(cNomePlan,cNomeTable,"Emissão",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Vencto.Real",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Desconto Pontualidade (Cad)",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Acréscimo (Cad)",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Decréscimo (Cad)",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Recebido",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Renegociado",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Desconto Comercial",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Desconto Financeiro",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Multa Comercial",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Multa Financeira",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Valor Juros",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Desconto Pontualidade (Bx)",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Acréscimo (Bx)",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Decréscimo (Bx)",3,3)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Situação",3,3)

	While !Eof()

		IncProc("Gerando planilha...")

		oExcel:AddRow(cNomePlan, cNomeTable, {TRB->TF_CLIENTE, TRB->TF_NOMCLI, TRB->TF_FILIAL, TRB->TF_PREFIXO, TRB->TF_NUM, TRB->TF_PARCELA,;
		   									  TRB->TF_TIPO, TRB->TF_EMISSAO, TRB->TF_VENCREA, TRB->TF_VALOR, TRB->TF_DESCPON, TRB->TF_ACRESC,;
		   									  TRB->TF_DECRESC, TRB->TF_BAIXADO, TRB->TF_RENEGOC, TRB->TF_DESCCOM, TRB->TF_DESCFIN,;
		   									  TRB->TF_MULTCOM, TRB->TF_MULTFIN, TRB->TF_BXJUROS, TRB->TF_BDESPON, TRB->TF_BACRESC,;
		   									  TRB->TF_BDECRES, TRB->TF_ZSTATUS })

		DbSelectArea("TRB")
		TRB->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "SE1_FINR06-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
TRB->(DbCloseArea())
oTempTable:Delete()
	
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _EstorSe5 ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 31/07/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Avalia se o movimento bancário foi estornado.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function _EstorSe5(eFilial,ePrefixo,eNumero,eParcela,eTipo,eCliente,eLoja,eSeq)

Local aArea := GetArea()
Local lEsto := .F.

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+eFilial+"' "
cQuery += " AND E5_PREFIXO = '"+ePrefixo+"' "
cQuery += " AND E5_NUMERO = '"+eNumero+"' "
cQuery += " AND E5_PARCELA = '"+eParcela+"' "
cQuery += " AND E5_TIPO = '"+eTipo+"' "
cQuery += " AND E5_CLIFOR = '"+eCliente+"' "
cQuery += " AND E5_LOJA = '"+eLoja+"' "
cQuery += " AND E5_SEQ = '"+eSeq+"' "
cQuery += " AND E5_TIPODOC = 'ES' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLT", .F., .T.)
lEsto := (SQLT->SOMA > 0)
SQLT->(DbCloseArea())

RestArea(aArea)

Return(lEsto)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Finr6Trab ¦ Autor ¦ Fábrica ERPBR    ¦    Data  ¦ 31/07/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria arquivo temporario. 							   	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Finr6Trab()

Local _aTmp := {}
Local zAlias := "TRB"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TF_CLIENTE" , "C", 006, 00} )
AAdd ( _aTmp, {"TF_NOMCLI"  , "C", 040, 00} )
AAdd ( _aTmp, {"TF_FILIAL"  , "C", 004, 00} )
AAdd ( _aTmp, {"TF_PREFIXO" , "C", 003, 00} )
AAdd ( _aTmp, {"TF_NUM"     , "C", 009, 00} )
AAdd ( _aTmp, {"TF_PARCELA" , "C", 002, 00} )
AAdd ( _aTmp, {"TF_TIPO"    , "C", 003, 00} )
AAdd ( _aTmp, {"TF_EMISSAO" , "D", 008, 00} )
AAdd ( _aTmp, {"TF_VENCREA" , "D", 008, 00} )
AAdd ( _aTmp, {"TF_VALOR"   , "N", 017, 02} )
AAdd ( _aTmp, {"TF_DESCPON" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_ACRESC"  , "N", 017, 02} )
AAdd ( _aTmp, {"TF_DECRESC" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_BAIXADO" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_RENEGOC" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_DESCCOM" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_DESCFIN" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_MULTCOM" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_MULTFIN" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_BXJUROS" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_BDESPON" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_BACRESC" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_BDECRES" , "N", 017, 02} )
AAdd ( _aTmp, {"TF_ZSTATUS" , "C", 020, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TF_NOMCLI", "TF_FILIAL", "TF_PREFIXO", "TF_NUM", "TF_PARCELA"})
oTempTable:Create()

Return
