#include "totvs.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#include "FWADAPTEREAI.CH"
#DEFINE _CRLF	Chr(13) + Chr(10)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LAN00007   ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out;2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta Chave		          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function LAN00007()

Local cPerg	:= "LAN0007"

If Pergunte(cPerg,.T.)

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("ZZG")
	cQuery += " WHERE ZZG_FILIAL = '"+xFilial("ZZG")+"' "
	cQuery += " AND ZZG_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cQuery += " AND ZZG_EMISSA >= '20190101' " // A partir de 2019
	cQuery += " AND ZZG_TIPO IN ('1','5') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TREG", .F., .T.)
	zTotReg := TREG->SOMA
	TREG->(DbCloseArea())
	
	If zTotReg == 0
		MsgAlert("Não foram encontrados XML para verificação. Revise os parâmetros.")
	Else
		lJob := .F.
		oProcess := MsNewProcess():New( { | lEnd | lOk := U_LAN10007(lJob,zTotReg) }, "Verificando XML cancelados.", "Aguarde, processando ...", .F. )
		oProcess:Activate()
		MsgInfo("Processo concluído.")
	Endif

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LAN10007   ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Out;2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta Chave		          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function LAN10007(lJob,zTotReg)

Local lRet	  	:= .F.
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt   	:= ""
Local cChaveNFe := ""
Local cCodRet	:= "Codigo de retorno: "
Local cMensRet  := "Mensagem de retorno: "
Local cProt		:= "Protocolo: "

Local lUsaGesEmp := .F.
Local lEnvCodEmp := .F.
Local aRetorno	 := {}
Local cCodRetSef := ""

Private oWS

If lJob
	ConOut("Função LAN10007: Xml Cancelados < Início > "+DtoC(Date())+" - "+Time())
	ConOut(cEmpAnt)
	ConOut(cFilAnt)
Endif

If !GetMv("MV_SCHDPRO")
	ConOut("Schedule não executado: Ambiente Teste.")
	Return
Endif

If !lJob
	oProcess:SetRegua1(zTotReg)
Endif	

If IsReady(cURL)
	
	cQuery := " SELECT ZZG_CHVNFE, R_E_C_N_O_ RECZZG "
	cQuery += " FROM "+RetSqlName("ZZG")
	cQuery += " WHERE ZZG_FILIAL = '"+xFilial("ZZG")+"' "
	If !lJob
		cQuery += " AND ZZG_EMISSA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
		cQuery += " AND ZZG_EMISSA >= '20190101' " // A partir de 2019
	Else
		cQuery += " AND ZZG_EMISSA >= '"+DtoS(Date()-10)+"' "
	Endif	
	cQuery += " AND ZZG_TIPO IN ('1','5') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TZZG", .F., .T.)
    
	DbSelectArea("TZZG")
	TZZG->(DbGotop())
	While !Eof()
		
		If !lJob
			oProcess:IncRegua1("Analisando XML cancelados...")
		Endif

		cChaveNFe	:= TZZG->ZZG_CHVNFE

		lEnvCodEmp	:= getNewPar("MV_ENVCDGE",.F.)
		lUsaGesEmp	:= iif(findFunction("FWFilialName") .And. findFunction("FWSizeFilial") .And. FWSizeFilial() >= 2,.T.,.F.)
		
		//Obtem o codigo da entidade
		oWS := WsSPEDAdm():New()
		oWS:cUSERTOKEN := "TOTVS"
		oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
		oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
		oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
		oWS:oWSEMPRESA:cFANTASIA   := iif(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
		oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
		oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
		oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
		oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
		oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
		oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
		oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
		oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
		oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
		oWS:oWSEMPRESA:cCEP_CP     := Nil
		oWS:oWSEMPRESA:cCP         := Nil
		oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
		oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
		oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
		oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
		oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
		oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
		oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cINDSITESP  := ""
		oWS:oWSEMPRESA:cID_MATRIZ  := ""
		
		If( lUsaGesEmp .and. lEnvCodEmp )
			oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
		Endif
		
		oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
		oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
		
		If oWs:ADMEMPRESAS()
			cIdEnt  := oWs:cADMEMPRESASRESULT
		Else
			If !lJob
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
			Endif	
		EndIf
		
		oWs:= WsNFeSBra():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		ows:cCHVNFE		 := cChaveNFe
		oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
		
		If oWs:ConsultaChaveNFE()
			If Type ("oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO") == "U" .OR. Empty (oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
				If AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "731" .or. AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "526"
/*					If !lJob
						If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
							cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
							"Verificar se o Ano-Mês da Chave de Acesso está com atraso"+CRLF+;
							"superior a 6 meses em relação ao Ano-Mês atual."+CRLF+CRLF+CRLF+;
							"Deseja inserir a chave mesmo assim?")
							lRet := .T.
						Else
							lRet := .F.
						Endif
					Else					
						lRet := .T.
					Endif	*/
				Else
					If !lJob
						MsgAlert("A chave digitada não foi encontrada na Sefaz, favor verificar")
					Endif	
					lRet := .F.
				Endif
			Else
				If !lJob .And. AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) != "100"
					MsgAlert(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
					cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
					cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
				Else
					ConOut(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
					cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
					cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
				Endif				
				lRet		:= .T.
				cCodRetSef	:= oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE
			Endif
		Else
			If !lJob
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
			Endif	
			If Len(Alltrim(cChaveNFe)) > 0 .and. Len(Alltrim(cChaveNFe)) < 44
				If GetRemoteType() == -1 //Job
					lRet := .T.
				Else
					If !lJob
						If MsgNoYes("A chave informada é menor que o permitido e impossibilita a consulta na Sefaz."+CRLF+CRLF+;
							"Deseja APAGAR o conteúdo do campo para inserir uma nova chave?")
							lRet := .F.  //Limpa o campo caso tenha uma chave menor
						Else
							lRet := .T.
						EndIf
					Else
						lRet := .F.
					Endif
				Endif
			Elseif !Empty(GetWscError(3)) //"Falha no retorno da SEFAZ"
				lRet := .F.
			Else
				lRet := .T.
			Endif
		Endif
		
		If lRet .And. cCodRetSef $ "101/102/151"
			DbSelectArea("ZZG")
			ZZG->(DbGoto(TZZG->RECZZG))
			RecLock("ZZG",.F.)
			ZZG->ZZG_TIPO := "7"
			MsUnLock()
			If lJob
				ConOut("Xml Cancelado: "+AllTrim(ZZG->ZZG_CHVNFE))
			Else
				MsgInfo("Xml Cancelado: "+AllTrim(ZZG->ZZG_CHVNFE))
			Endif
		Endif

		DbSelectArea("TZZG")
		TZZG->(DbSkip())	
	Enddo
	TZZG->(DbCloseArea())	
Else
	If !lJob
		Help(" ",1,"TSSINATIVO")
	Endif	
Endif

Aadd(aRetorno,lRet)
Aadd(aRetorno,cCodRetSef)

If lJob
	ConOut("Função LAN10007: Xml Cancelados < Fim > "+DtoC(Date())+" - "+Time())
	ConOut(cEmpAnt)
	ConOut(cFilAnt)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IsReady	   ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Mai2019 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta URL			          							  ¦¦¦
¦¦¦          ¦                                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function IsReady(cURLTss)

Local oWS
Local lRetorno := .F.

PutMV("MV_SPEDURL",cURLTss)

SuperGetMv() //Limpa o cache de parametros

DEFAULT cURLTss  := PadR(GetNewPar("MV_SPEDURL","http://"),250)

//=============================================================================
// Verifica se o servidor da Totvs esta no ar
//=============================================================================
oWs := WsSpedCfgNFe():New()
oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURLTss)+"/SPEDCFGNFe.apw"

If oWs:CFGCONNECT()
	lRetorno := .T.
EndIf

Return lRetorno

/*/
100 - Autorizado o uso da NF-e:  este retorno será apresentado, quando não houver nenhuma falha/erro nos dados informados na NF-e enviada, esta mensagem, é a confirmação da emissão da nota.
101 - Cancelamento de NF-e homologado: este retorno era apresentado para o cancelamento de uma NF-e, porém este tipo de cancelamento foi desativado, ficando em vigor, apenas o cancelamento por evento.
102 - Inutilização de número homologado: este retorno será apresentado quando for inutilizado com sucesso uma faixa de numeração.
103 - Lote recebido com sucesso: este retorno será apresentado quando a SEFAZ receber o lote de NF-e enviado e o Webservice estará processando o XML para verificar sua autenticidade.
104 - Lote processado: este retorno será apresentado quando o lote enviado já estiver sido processado, e a SEFAZ já terá um retorno sobre a respectiva nota.
105 - Lote em processamento: este retorno será apresentado quando for realizado uma consulta pelo número de recibo do lote e o Webservice ainda não terminou de processar o XML enviado.
106 - Lote não localizado: este retorno será apresentado quando estiver sendo realizado uma consulta pelo número do recibo, e não existir nenhum lote vinculado a este número.
108 - Serviço Paralisado Momentaneamente (curto prazo): este retorno será apresentado quando estiver sendo realizado algum tipo de comunicação com o Webservice e o mesmo estiver passando por alguma manutenção.
109 - Serviço Paralisado sem Previsão: este retorno será apresentado quando o Webservice estiver parado, para realizar alguma manutenção ou alteração, porém, irá levar um certo tempo para finalizar a manutenção, por este motivo, que é retornado sem previsão.
110 - Uso Denegado: este retorno será apresentado quando houver alguma situação dos casos informados abaixo, em relação a Inscrição Estadual (I.E):
I.E. Suspensa.
I.E. Cancelada.
I.E. Baixada.
I.E. Em Processo de Baixa.
111 - Consulta cadastro com uma ocorrência: este retorno será apresentado quando for realizado uma consulta de cadastro de algum contribuinte e o cadastro do mesmo conter uma ocorrência registrada.
112 - Consulta cadastro com mais de uma ocorrência: este retorno será apresentado quando for realizado uma consulta de cadastro de algum contribuinte e o cadastro do mesmo conter mais de uma ocorrência registrada.
/*/

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 06/05/2019      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function QLA0071()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_LAN10007(.T.)
Return

User Function QLA0072()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0102"
U_LAN10007(.T.)
Return

User Function QLA0073()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0103"
U_LAN10007(.T.)
Return

User Function QLA0076()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0106"
U_LAN10007(.T.)
Return

User Function QLA0077()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0107"
U_LAN10007(.T.)
Return

User Function QLA0078()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0108"
U_LAN10007(.T.)
Return

User Function QLA0079()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0109"
U_LAN10007(.T.)
Return

User Function QLA0710()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0110"
U_LAN10007(.T.)
Return
