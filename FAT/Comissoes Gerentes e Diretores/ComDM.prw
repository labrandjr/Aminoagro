#include "Protheus.ch"
#include "TopConn.ch"
#include "MsObject.ch"

#define LOGNONE 	0
#define LOGERROR 	1
#define LOGWARN 	2
#define LOGINFO 	3
#define LOGDEBUG 	4


/*/{Protheus.doc} Fun��o ComDM

Efetua o c�lculo da premia��o dos Desenvolvedores de Mercado

@author 	Luis Brandini
@since 		09/02/2022
@return		Nil
/*/
//----------------------------------------------------------------------  

User Function ComDM()
	Local aArea		 := GetArea()
	Local lPlrAdd    := GetMv("MV_ZPLRADD")
	Private aRet 	 := {}
	Private dDataDe	 := ""	
	Private dDataAte := ""
	Private lErro	 := .F.
	
	If !lPlrAdd
		MsgInfo("Processo n�o habilitado.")
		Return
	Endif

	If PedirParametros()
		lProcessa := .F.
		If ExisteProcessamento()
			MsgAlert("Aten��o, j� existe processamento de premia��o neste periodo, para o(s) DM(s) informado(s) no par�metro.")
			If MsgYesNo("Deseja reprocessar a premia��o para o(s) DM(s) neste per�odo ?","Aviso","INFO")
				If MsgYesNo("O processamento anterior ser� exclu�do. Confirma a opera��o ?","Aviso","INFO")
					lProcessa := .T.
					MsgRun("Aguarde, excluindo apura��o anterior para DM...","Processando",{|| ExcluiProcessamento() })
					MsgAlert("Apura��o do periodo exclu�da com sucesso para DM.")
				Endif
			Endif
		Else
			lProcessa := .T.
		Endif
		//
		If lProcessa
			nPercComissao := ObterPercentual()
			Processa({|| ObterBase() },"Processando AGUARDE....")
		Endif
	Endif
	
	RestArea(aArea)
Return

Static Function PedirParametros()
	Local aPergs   := {}
	Local aCombo1  := {"1o.Primeiro","2o.Segundo"}	
	Local lRetorno := .F.     
	
//	aAdd( aPergs ,{1,"Data de Apura��o de:"		,Ctod(Space(8)),"","","","",50,.T.})
//	aAdd( aPergs ,{1,"Data de Apura��o at�:"	,Ctod(Space(8)),"","","","",50,.T.})
	aAdd( aPergs ,{2,"Semestre:","1o.Primeiro",aCombo1,50,"",.F.})
	aAdd( aPergs ,{1,"Ano:"					,Space(4),"@R 9999","","","",50,.T.})
	aAdd( aPergs ,{1,"C�digo do DM de:"		,Space(6),"","","SA3","",50,.T.})
	aAdd( aPergs ,{1,"C�digo do DM at�:"	,Space(6),"","","SA3","",50,.T.})
	aAdd( aPergs ,{1,"Filial (exclusiva)"	,Space(4),"","","","",30,.F.})
	aAdd( aPergs ,{1,"T�tulo (exclusivo)"	,Space(9),"","","","",50,.F.})   
	
	If ParamBox(aPergs, "Gera Premia��o - DM",,,,,,,, "Apura��o de Premia��o - DM", .T., .T.)             
		nSemestr := IIf(mv_par01=="1o.Primeiro",1,2)
		DbSelectArea("ZZP")
		DbSetOrder(1)
		If !DbSeek( xFilial("ZZP") + AllTrim(STR(nSemestr)) + mv_par02 )
			MsgAlert("Per�odo n�o cadastrado.")
			lRetorno := .F.
		Else
			lRetorno := .T. 
			dDataDe	 := ZZP->ZZP_DINI
			dDataAte := ZZP->ZZP_DFIM
		Endif
//		lRetorno := .T. 
//		dDataDe	 := MV_PAR01
//		dDataAte := MV_PAR02
	Else
		lRetorno := .F.
	EndIf
Return lRetorno

Static Function ExisteProcessamento()
	Local lRetorno := .T.
				
	local cAliasEP := QueryExisteProcessamento()
	
	(cAliasEP)->(dbGoTop())                                         		
	
	If (cAliasEP)->(Eof())
		lRetorno := .F.		                              
	Endif
	
	(cAliasEP)->(dbCloseArea())
	
Return lRetorno

Static Function ObterPercentual()
	Local nPercComissao := 0
	Local cParComissao	:= "ZZ_PERCDMS" 
	
	nPercComissao := SuperGetMV(cParComissao,.T.,"0")	
Return nPercComissao 

Static Function ObterBase()
	local cAliasOB 		:= QueryObterBase()
	local nMascDest		:= GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_RETDIRECTORY
	local cTempo		:= SUBSTR(TIME(),1,2)+"-"+SUBSTR(TIME(),4,2)+"-"+SUBSTR(TIME(),7,2)
	local cFilOri		:= cFilAnt
	local cFolderLOG  	:= cGetFile("Pasta","Selecione a Pasta Destino Log",0,,.F.,nMascDest)
	local oLog			:= TIPLogger():New(cFolderLOG,"Apura��o de Premia��o - DM "+DtoS(Date()) +"-" + cTempo,LOGDEBUG)
	Private lApExDm     := SuperGetMv("MV_ZAPEXDM",.F.,.T.)
	Private oTempTable

	TrabResumo()

	// Totaliza apura��o de cada RTV para checar total negativo
	If lApExDm
		(cAliasOB)->(dbGoTop())
		ProcRegua((cAliasOB)->(RecCount()))
		While ( (cAliasOB)->(!Eof()) )
			incProc()
			GravaTOT(cAliasOB)
			(cAliasOB)->(dbSkip())
		Enddo
	Endif

	(cAliasOB)->(dbGoTop())
	ProcRegua((cAliasOB)->(RecCount()))
	While ( (cAliasOB)->(!Eof()) )
		incProc()
		cFilAnt := (cAliasOB)->E3_FILIAL
		GravaSE3(cAliasOB,@oLog)
		(cAliasOB)->(dbSkip())
	Enddo
	if lErro
		MsgAlert("Uma ou mais premia��es n�o foram geradas. Ser� gerado um relatorio de inconsist�ncias.")
		oLog:ViewRpt(.T.)
	else
		MsgInfo("Premia��o gerada com sucesso. Utilize a rotina 'Manuten��o de Comiss�es' para visualizar.")
	endIf
	(cAliasOB)->(dbCloseArea())	
	cFilAnt := cFilOri

	TRBT->(DbCloseArea())
	oTempTable:Delete()
Return

Static Function GravaTOT(cAliasOB)
	Local aAreaSE3 := SE3->(GetArea())

	zCodVen := (cAliasOB)->E3_ZZDM
	If Empty(zCodVen)
		RestArea(aAreaSE3)
		Return
	Endif

	lDescAtr := .T.
	lDescMet := .T.
	nSemestr := IIf(mv_par01=="1o.Primeiro",1,2)
	DbSelectArea("ZZQ")
	DbSetOrder(1)
	If DbSeek( xFilial("ZZQ") + (cAliasOB)->E3_VEND + AllTrim(STR(nSemestr)) + mv_par02 )
		lDescAtr := (ZZQ->ZZQ_ATRASO == "S")
		lDescMet := (ZZQ->ZZQ_META   == "S")
		lTotNega := (ZZQ->ZZQ_NEGAT  == "S")
	Endif

	zzBase := (cAliasOB)->E3_COMIS
	
	If !lDescAtr // Desliga desconto por atraso
		If (cAliasOB)->E3_ZZVDESC > 0
			zzBase := (cAliasOB)->E3_ZZCOMIS
		Endif
	Endif

	If !lDescMet // Desliga desconto por meta
		zDesMet  := IIf((cAliasOB)->E3_MTCOMIS > 0, (cAliasOB)->(E3_MTCOMIS - E3_COMIS), 0)
		If zDesMet > 0
			zzBase := (cAliasOB)->E3_ZZCOMIS
		Endif
	Endif

	DbSelectArea("TRBT")
	DbSetOrder(1)
	If !DbSeek( (cAliasOB)->E3_VEND )
		RecLock("TRBT",.T.)
		TRBT->TT_VEND := (cAliasOB)->E3_VEND
	Else
		RecLock("TRBT",.F.)
	Endif
	TRBT->TT_COMIS += zzBase
	MsUnLock()

	RestArea(aAreaSE3)
Return

Static Function GravaSE3(cAliasOB, oLog)
	Local aAreaSE3 := SE3->(GetArea())
	Local aComis   := {}
	Private lMSErroAuto	:= .F.

	// Checa registros bloqueados e desbloqueia temporariamente antes do ExecAuto
	zCodVen := (cAliasOB)->E3_ZZDM
	zCodCli := (cAliasOB)->E3_CODCLI
	zLojCli := (cAliasOB)->E3_LOJA
	lBlqVen := .F.
	lBlqCli := .F.

	If Empty(zCodVen)
		RestArea(aAreaSE3)
		Return
	Endif

	// Desbloqueia o registro - Vendedor
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek( xFilial("SA3") + zCodVen )
		If SA3->A3_MSBLQL == "1"
			lBlqVen := .T.
			RecLock("SA3",.F.)
			SA3->A3_MSBLQL := "2"
			MsUnLock()
		Endif
	Endif

	// Desbloqueia o registro - Cliente
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek( xFilial("SA1") + zCodCli + zLojCli )
		If SA1->A1_MSBLQL == "1"
			lBlqCli := .T.
			RecLock("SA1",.F.)
			SA1->A1_MSBLQL := "2"
			MsUnLock()
		Endif
	Endif

	zzBase := (cAliasOB)->E3_COMIS

	If lApExDm

		lDescAtr := .T.
		lDescMet := .T.
		lTotNega := .T.
		nSemestr := IIf(mv_par01=="1o.Primeiro",1,2)
		DbSelectArea("ZZQ")
		DbSetOrder(1)
		If DbSeek( xFilial("ZZQ") + (cAliasOB)->E3_VEND + AllTrim(STR(nSemestr)) + mv_par02 )
			lDescAtr := (ZZQ->ZZQ_ATRASO == "S")
			lDescMet := (ZZQ->ZZQ_META   == "S")
			lTotNega := (ZZQ->ZZQ_NEGAT  == "S")
		Endif
		
		If !lDescAtr // Desliga desconto por atraso
			If (cAliasOB)->E3_ZZVDESC > 0
				zzBase := (cAliasOB)->E3_ZZCOMIS
			Endif
		Endif

		If !lDescMet // Desliga desconto por meta
			zDesMet  := IIf((cAliasOB)->E3_MTCOMIS > 0, (cAliasOB)->(E3_MTCOMIS - E3_COMIS), 0)
			If zDesMet > 0
				zzBase := (cAliasOB)->E3_ZZCOMIS
			Endif
		Endif

		If !lTotNega
			DbSelectArea("TRBT")
			DbSetOrder(1)
			If DbSeek( (cAliasOB)->E3_VEND )
				If TRBT->TT_COMIS < 0
					zzBase := 0
				Endif
			Endif
		Endif

	Endif

	zzPorc := ObterPercentual()
	zzComs := (zzBase * (zzPorc/100))

	If zzComs <> 0
	
		aAdd(aComis,{"E3_FILIAL"   , (cAliasOB)->E3_FILIAL	     ,Nil})
		aAdd(aComis,{"E3_VEND"     , (cAliasOB)->E3_ZZDM	     ,Nil})
		aAdd(aComis,{"E3_NUM" 	   , (cAliasOB)->E3_NUM		     ,Nil})
		aAdd(aComis,{"E3_EMISSAO"  , StoD((cAliasOB)->E3_EMISSAO),Nil})
		aAdd(aComis,{"E3_SERIE"    , (cAliasOB)->E3_SERIE		 ,Nil})
		aAdd(aComis,{"E3_CODCLI"   , (cAliasOB)->E3_CODCLI    	 ,Nil})
		aAdd(aComis,{"E3_LOJA" 	   , (cAliasOB)->E3_LOJA    	 ,Nil})
		aAdd(aComis,{"E3_BASE" 	   , zzBase                 	 ,Nil})
		aAdd(aComis,{"E3_PORC" 	   , zzPorc			    	     ,Nil})
		aAdd(aComis,{"E3_COMIS"	   , zzComs				   	     ,Nil})
		aAdd(aComis,{"E3_PREFIXO"  , (cAliasOB)->E3_PREFIXO      ,Nil})
		aAdd(aComis,{"E3_PARCELA"  , (cAliasOB)->E3_PARCELA      ,Nil})
		aAdd(aComis,{"E3_TIPO" 	   , (cAliasOB)->E3_TIPO    	 ,Nil})
		aAdd(aComis,{"E3_PEDIDO"   , (cAliasOB)->E3_PEDIDO    	 ,Nil})
		aAdd(aComis,{"E3_VENCTO"   , StoD((cAliasOB)->E3_VENCTO) ,Nil})
		aAdd(aComis,{"E3_MOEDA"    , "01" 						 ,Nil})
		aAdd(aComis,{"E3_ZZDINI"   , dDataDe					 ,Nil})
		aAdd(aComis,{"E3_ZZDFIM"   , dDataAte					 ,Nil})
		aAdd(aComis,{"E3_ZZRTV"    , (cAliasOB)->E3_VEND		 ,Nil})
		
		MsExecAuto({|x,y| Mata490(x,y)},aComis,3)
		
		If lMsErroAuto
			oLog:AddErroMsAuto("Erro de Rotina Autom�tica: " + (cAliasOB)->E3_NUM + " - " + (cAliasOB)->E3_EMISSAO + " - " + (cAliasOB)->E3_VEND ,.T.)
			lErro := .T.
		Endif
		
	Endif

	// Retorna o bloqueio - Vendedor
	If lBlqVen
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek( xFilial("SA3") + zCodVen )
			RecLock("SA3",.F.)
			SA3->A3_MSBLQL := "1"
			MsUnLock()
		Endif
	Endif

	// Retorna o bloqueio - Cliente
	If lBlqCli
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek( xFilial("SA1") + zCodCli + zLojCli )
			RecLock("SA1",.F.)
			SA1->A1_MSBLQL := "1"
			MsUnLock()
		Endif
	Endif

	RestArea(aAreaSE3)
Return

Static Function QueryExisteProcessamento() 
	Local cQuery	:= ""
	local cAliasEP 	:= GetNextAlias()
	
	cQuery := " SELECT E3_VEND "
	cQuery += " FROM " + RetSqlName("SE3") + " SE3 "
	cQuery += " WHERE E3_VEND BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	cQuery += " AND SUBSTR(SE3.E3_VEND,1,1) = 'C' "
	cQuery += " AND SE3.E3_ZZRTV <> ' ' "
	cQuery += " AND (SE3.E3_ZZDINI BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+ "'"
	cQuery += " OR SE3.E3_ZZDFIM BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+ "') "
	cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
	If !Empty(mv_par05)
		cQuery += " AND E3_FILIAL = '"+mv_par05+"' "
	Endif
	If !Empty(mv_par06)
		cQuery += " AND E3_NUM = '"+mv_par06+"' "
	Endif
	
	TCQUERY cQuery NEW ALIAS &cAliasEP
Return cAliasEP


Static Function ExcluiProcessamento()
	Local cQuery	:= ""
	local cAliasOB 	:= GetNextAlias()
	
	cQuery := " SELECT SE3.E3_FILIAL, SE3.R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SE3") + " SE3 "
	cQuery += " WHERE E3_VEND BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	cQuery += " AND SUBSTR(SE3.E3_VEND,1,1) = 'C' "
	cQuery += " AND SE3.E3_ZZRTV <> ' ' "
	cQuery += " AND (SE3.E3_ZZDINI BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+ "'"
	cQuery += " OR SE3.E3_ZZDFIM BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+ "') "
	cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
	If !Empty(mv_par05)
		cQuery += " AND E3_FILIAL = '"+mv_par05+"' "
	Endif
	If !Empty(mv_par06)
		cQuery += " AND E3_NUM = '"+mv_par06+"' "
	Endif
	TCQUERY cQuery NEW ALIAS &cAliasOB

	(cAliasOB)->(dbGoTop())
	do while ( (cAliasOB)->(!Eof()) )
		cFilAnt := (cAliasOB)->E3_FILIAL		
		SE3->(DbGoto((cAliasOB)->R_E_C_N_O_))
		RecLock("SE3",.F.)
		SE3->(DbDelete())
		SE3->(MsUnLock())
		(cAliasOB)->(dbSkip())
	EndDo
	(cAliasOB)->(dbCloseArea())	
Return

Static Function QueryObterBase() 
	Local cQuery	:= ""
	local cAliasOB 	:= GetNextAlias()
	
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("SE3") + " SE3 "
	cQuery += " WHERE SE3.E3_ZZDM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	cQuery += " AND SUBSTR(SE3.E3_ZZDM,1,1) = 'C' "
	cQuery += " AND SUBSTR(SE3.E3_VEND,1,1) <> 'R' " // N�o apura DM vinculados a Revenda (erro de cadastro). Luis Brandini - 14/07/2017 - conforme Sandra/Kamila.
	cQuery += " AND SE3.E3_ZZRTV = ' ' "
	cQuery += " AND SE3.E3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+ "' "
	cQuery += " AND SE3.D_E_L_E_T_ <> '*' "
	If !Empty(mv_par05)
		cQuery += " AND E3_FILIAL = '"+mv_par05+"' "
	Endif
	If !Empty(mv_par06)
		cQuery += " AND E3_NUM = '"+mv_par06+"' "
	Endif
	TCQUERY cQuery NEW ALIAS &cAliasOB
Return cAliasOB

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � TrabResumo � Autor � F�brica ERPBR � Data  � 20/07/2022    ���
��+----------+------------------------------------------------------------���
���Descricao � Cria arquivo temporario. 							   	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function TrabResumo()

Local _aTmp := {}
Local zAlias := "TRBT"

If Select("TRBT") > 0
	TRBT->(DbCloseArea())
Endif

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TT_VEND"  , "C", 006, 00} )
AAdd ( _aTmp, {"TT_COMIS" , "N", 014, 02} )
	
oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TT_VEND"})
oTempTable:Create()

Return
