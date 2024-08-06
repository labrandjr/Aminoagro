#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "xmlxfun.ch"
#include "apwebsrv.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ AUDT003  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  01/09/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ MBrowse histórico de fontes.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AUDT003()

Private cUsrAudit := AllTrim(GetMv("MV_ZUSRAUD"))

Private cCadastro := "Histórico de Fontes"

Private aRotina := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	    {"Visualizar" , "AxVisual" , 0 , 2 }}

If !(__cUserId $(cUsrAudit))
	MsgAlert("Usuário não autorizado <MV_ZUSRAUD>. Contate o Administrador.")
	Return
Endif

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "ZZN" )			
oMBrowse:SetDescription( cCadastro )

oMBrowse:SetTotalDefault("ZZN_FILIAL","COUNT","Total de Registros")		
oMBrowse:Activate()

DbSelectArea("ZZN")
DbSetOrder(1)
DbClearFilter()
		
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AUDT03X ¦ Autor ¦ Fábrica ERP.BR      ¦ Data  ¦ 01/09/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checagem e gravação dos fontes modificados.		 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AUDT03X()

Local aExtens := {}
Local aFontes := {}
Local _rpo, _fnt

AAdd(aExtens,"*.PRX")
AAdd(aExtens,"*.PRW")

For _rpo := 1 to Len(aExtens)

	cExtens := aExtens[_rpo]
	aFontes := GetSrcArray(cExtens)
	For _fnt := 1 to Len(aFontes)
		cFonte := aFontes[_fnt]
		aInfoF := GetApoInfo(cFonte)
		//
		cNomFn := PadR(aInfoF[1],50)
		cLinFn := aInfoF[2]
		cModFn := aInfoF[3]
		dDatFn := aInfoF[4]
		cHorFn := aInfoF[5]
		//
		DbSelectArea("ZZN")
		DbSetOrder(1)
		If !DbSeek( xFilial("ZZN") + cNomFn + DtoS(dDatFn) + cHorFn )
			RecLock("ZZN",.T.)
			ZZN->ZZN_FILIAL := xFilial("ZZN")
			ZZN->ZZN_FONTE  := cNomFn
			ZZN->ZZN_LINGU  := cLinFn
			ZZN->ZZN_MODOC  := cModFn
			ZZN->ZZN_DATA   := dDatFn
			ZZN->ZZN_HORA   := cHorFn
			MsUnLock()
		Endif
	Next _fnt

Next _rpo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHEDULE ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 24/08/2021      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamadas via schedule.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AUD03WF()
PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
U_AUDT03X()
Return
