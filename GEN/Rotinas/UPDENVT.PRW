#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UPDENVT   ¦ Autor ¦  Fábrica ERP.BR   ¦ Data  ¦ 24/06/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Script de atualização dos ambientes de teste.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UPDENVT()

Local cPerg   := "UPDENVT"
Local cUsrAut := "000000,000163,000206"
Local cEnvAut := "CJXW4M_HOM,CJXW4M_DEV"

If !(__cUserId $(cUsrAut))
	MsgAlert("Usuário não autorizado.")
	Return
Endif

If !(GetEnvServer() $(cEnvAut))
	MsgAlert("Ambiente não autorizado.")
	Return
Endif

If Pergunte(cPerg,.T.)

	cEnvTst := IIf(mv_par01 == 1,"Homologação","Desenvolvimento")
	If MsgYesNo("Confirma atualização de parâmetros no ambiente de "+cEnvTst+" ?","Aviso","INFO")
		MsgRun("Aguarde, atualizando parâmetros...","Processando",{|| ProcUpd() })
	Endif	

	MsgInfo("Atualização concluída !!")
	// Ações complementares manuais:
	// -----------------------------
	// Appendar sx5 tabela 01
	// Alterar os ambientes Sefaz (parâmetros e eventos) para Homologação - por Filial
	// Wizards TAF

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcUpd   ¦ Autor ¦  Fábrica ERP.BR   ¦ Data  ¦ 24/06/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento da atualização.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcUpd()

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = 'http://qualyquimicaindustria"+IIf(mv_par01==1,"122912","124385")+".protheus.cloudtotvs.com.br:4050/rest' WHERE X6_VAR = 'MV_BACKEND' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = 'http://qualyquimicaindustria"+IIf(mv_par01==1,"122912","124385")+".protheus.cloudtotvs.com.br:9600' WHERE X6_VAR = 'MV_GCTPURL' "
TCSQLEXEC(cQuery)

//cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '000163' WHERE X6_VAR IN('MV_EMLPREM','MV_XEMBLCR','MV_XEMLDEV','MV_XEMLDE2','MV_XEMCCUS','MV_XEMLCOM','MV_XEMLAPC','MV_ZUSRPRT') "
//TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '163,206,276' WHERE X6_VAR IN('MV_XUSNFTR','MV_XUSCCTE') "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '.F.' WHERE X6_VAR IN('MV_SCHDPRO','MV_CHVNFE','MV_DCHVNFE') "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = 'qualyquimicaindustria"+IIf(mv_par01==1,"122912","124385")+".protheus.cloudtotvs.com.br:8800' WHERE X6_VAR = 'MV_WFURL' "
TCSQLEXEC(cQuery)

//cQuery := " UPDATE SX6G10 SET X6_CONTEUD = 'luis.brandini@erpbr.net' WHERE X6_VAR = 'MV_WFEMTST'
//TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '10.0.2."+IIf(mv_par01==1,"3","5")+":8800' WHERE X6_VAR = 'MV_WFBRWSR' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '\workflow\HTTP' WHERE X6_VAR = 'MV_WFDHTTP' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = 'http://10.0.2.7:9400' WHERE X6_VAR IN('MV_SPEDURL','MV_TAFSURL') "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '9=SPED;009=CTE;2=RPS;' WHERE X6_VAR = 'MV_ESPECIE' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '088' WHERE X6_VAR = 'MV_SERMAN' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '2' WHERE X6_VAR = 'MV_TAFAMBR' "
TCSQLEXEC(cQuery)

//cQuery := " UPDATE SX5G10 SET X6_DESCRI = '000163', X5_DESCSPA = '000163', X5_DESCENG = '000163' WHERE X5_TABELA IN('WA','WB','WC') "
//TCSQLEXEC(cQuery)

cQuery := " UPDATE SX5G10 SET D_E_L_E_T_ = '*' WHERE X5_TABELA = '01' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX5G10 SET X5_CHAVE = '088' WHERE X5_TABELA = 'PT' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE XX0 SET XX0_IP = '10.0.2."+IIf(mv_par01==1,"3","5")+"', XX0_PORTA = '6800', XX0_ENV = 'CJXW4M_"+IIf(mv_par01==1,"HOM","DEV")+"' WHERE D_E_L_E_T_ <> '*' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE XX1 SET XX1_ENV = 'CJXW4M_"+IIf(mv_par01==1,"HOM","DEV")+"' WHERE D_E_L_E_T_ <> '*' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE DUIG10 SET DUI_SERIE = '009' WHERE DUI_SERIE = '002' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = ' ' WHERE X6_VAR = 'MV_VAUTCON' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = 'CJXW4M_"+IIf(mv_par01==1,"122912","124385")+"_P' WHERE X6_VAR = 'MV_TAFTALI' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = 'ORACLE' WHERE X6_VAR = 'MV_TAFTDB' "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '.T.' WHERE X6_VAR IN('MV_TAFWIZ','MV_TAFINT','MV_TAFGST2','MV_IMPXML') "
TCSQLEXEC(cQuery)

cQuery := " UPDATE SX6G10 SET X6_CONTEUD = '7891' WHERE X6_VAR = 'MV_TAFPORT' "
TCSQLEXEC(cQuery)

Return
