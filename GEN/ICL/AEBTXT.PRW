#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AEBTXT     ¦ Autor ¦ Fábrica ERPBR    ¦ Data ¦ 25/01/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geração de arquivo texto clientes e fornecedores.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AEBTXT(lJob)

If !lJob
	If MsgYesNo("Confirma geração do arquivo AEB.TXT ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | ProcExp(lJob) }, "Gerando arquivo", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif	
Else
	ProcExp(lJob)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcExp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ 25/01/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da exportação de dados.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcExp(lJob)

Private cPath := "\AEB\aeb.txt"
Private cDest := "C:\AEB\"
Private ENTER := CHR(13)+CHR(10)
Private nHdlAeb

If !lJob
	If !ExistDir(cDest)
		MakeDir(cDest)
	EndIf
Endif

nHdlAeb := fCreate(cPath)
If nHdlAeb < 0
	If !lJob
		MsgBox("Falha na criação do arquivo de log: "+AllTrim(cPath)+". Contate o Administrador.")
	Endif	
	Return
Endif

// 1. Cabeçalho do arquivo
cTime  := StrTran(Time(),":","")
cTexto := "HDR;AEB Compliance Screening;3.1;"+DtoS(Date())+" "+cTime+";FertilAqua;"+ENTER
fWrite(nHdlAeb,cTexto)

// 2. Clientes
If !lJob
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SA1")
	cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += " AND A1_CGC <> ' ' "
	cQuery += " AND A1_MSBLQL <> '1' "
	cQuery += " AND A1_COD NOT IN('000001','CLIGEN') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	nTotSql := SQL1->SOMA
	SQL1->(DbCloseArea())
Endif

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SA1")
cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND A1_CGC <> ' ' "
cQuery += " AND A1_MSBLQL <> '1' "
cQuery += " AND A1_COD NOT IN('000001','CLIGEN') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A1_COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

If !lJob
	oProcess:SetRegua1(nTotSql)
Endif	

DbSelectArea("SQL1")
SQL1->(DbGotop())
While !Eof()

	If !lJob
		oProcess:IncRegua1("Gerando dados clientes")
	Endif	

	DbSelectArea("SA1")
	SA1->(DbGoto(SQL1->R_E_C_N_O_))

	cPais := "BR"
	If SA1->A1_EST == "EX"
		DbSelectArea("SYA")
		DbSetOrder(1)
		If DbSeek( xFilial("SYA") + SA1->A1_PAIS )
			cPais := SYA->YA_PAISDUE
		Endif
	Endif

	GravaLin("ADR",;
			 "@"+SA1->A1_COD+"@",;
			 "@ERP_TOTVS Customer "+SA1->A1_COD+"@",;
			 "@"+IIf(SA1->A1_PESSOA=="J","company","individual")+"@",;
			 "@"+AllTrim(SA1->A1_NOME)+"@",;
			 "@"+AllTrim(SA1->A1_END)+"@",;
			 "@"+AllTrim(SA1->A1_CEP)+"@",;
			 "@"+AllTrim(SA1->A1_MUN)+"@",;
			 "@"+AllTrim(SA1->A1_BAIRRO)+"@",;
			 "@"+cPais+"@",;
			 "@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@")

	DbSelectArea("SQL1")
	SQL1->(DbSkip())
Enddo
SQL1->(DbCloseArea())

// 3. Fornecedores
If !lJob
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SA2")
	cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
	cQuery += " AND A2_CGC <> ' ' "
	cQuery += " AND A2_MSBLQL <> '1' "
	cQuery += " AND A2_COD NOT IN('FORSEG','INPS','MUNIC','UNIAO','VENDES') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
	nTotSql := SQL2->SOMA
	SQL2->(DbCloseArea())
Endif

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SA2")
cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
cQuery += " AND A2_CGC <> ' ' "
cQuery += " AND A2_MSBLQL <> '1' "
cQuery += " AND A2_COD NOT IN('FORSEG','INPS','MUNIC','UNIAO','VENDES') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A2_COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

If !lJob
	oProcess:SetRegua2(nTotSql)
Endif	

DbSelectArea("SQL2")
SQL2->(DbGotop())
While !Eof()

	If !lJob
		oProcess:IncRegua2("Gerando dados fornecedores")
	Endif	

	DbSelectArea("SA2")
	SA2->(DbGoto(SQL2->R_E_C_N_O_))

	If SA2->A2_TIPO == "X" .And. SA2->A2_PAIS == "994"
		DbSelectArea("SQL2")
		SQL2->(DbSkip())
		Loop
	Endif

	cPais := "BR"
	If SA2->A2_EST == "EX"
		DbSelectArea("SYA")
		DbSetOrder(1)
		If DbSeek( xFilial("SYA") + SA2->A2_PAIS )
			cPais := SYA->YA_PAISDUE
		Endif
	Endif

	GravaLin("ADR",;
			 "@"+SA2->A2_COD+"@",;
			 "@ERP_TOTVS Vendor "+SA2->A2_COD+"@",;
			 "@"+IIf(SA2->A2_TIPO$("J,X"),"company","individual")+"@",;
			 "@"+AllTrim(SA2->A2_NOME)+"@",;
			 "@"+AllTrim(SA2->A2_END)+"@",;
			 "@"+AllTrim(SA2->A2_CEP)+"@",;
			 "@"+AllTrim(SA2->A2_MUN)+"@",;
			 "@"+AllTrim(SA2->A2_BAIRRO)+"@",;
			 "@"+cPais+"@",;
			 "@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@;@@")

	DbSelectArea("SQL2")
	SQL2->(DbSkip())
Enddo
SQL2->(DbCloseArea())

fClose(nHdlAeb)

If !lJob
	CpyS2t(cPath, cDest)
	MsgAlert("Arquivo gerado com sucesso no diretório "+cDest+"aeb.txt")
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ GravaLin  ¦ Autor ¦ Fábrica ERPBR    ¦ Data  ¦ 25/01/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Grava linha do arquivo texto.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GravaLin(col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11)

cTexto := col1+";"+col2+";"+col3+";"+col4+";"+col5+";"+col6+";"+col7+";"+col8+";"+col9+";"+col10+";"+col11+ENTER
fWrite(nHdlAeb,cTexto)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MAEBTXT    ¦ Autor ¦ Fábrica ERPBR    ¦ Data ¦ 25/01/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada do processo manual.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MAEBTXT()
U_AEBTXT(.F.)
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ JAEBTXT    ¦ Autor ¦ Fábrica ERPBR    ¦ Data ¦ 25/01/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada do processo via schedule.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function JAEBTXT()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
ConOut("Função JAEBTXT: Geração de arquivo AEB TXT < Início > "+DtoC(Date())+" - "+Time())
U_AEBTXT(.T.)
ConOut("Função JAEBTXT: Geração de arquivo AEB TXT < Fim > "+DtoC(Date())+" - "+Time())
Return
