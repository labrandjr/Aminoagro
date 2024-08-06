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
¦¦¦Funcao    ¦ ALTCOMIS  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Alteração de dados nas entidades de comissões.			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ALTCOMIS()

Local nOpcDwn := 0
Local bOkDwn  := {|| nOpcDwn:=1,oDlgDwn:End() }
Local bCanDwn := {|| nOpcDwn:=0,oDlgDwn:End() }
Local nRadio1 := 1
Local lAltCms := GetMv("MV_ZALTCMS")
Local cUsrHab := AllTrim(GetMv("MV_ZUSCCOM"))+","+AllTrim(GetMv("MV_ZUSCCTL"))
Local oDlgDwn,oRadio1

If !lAltCms
	MsgAlert("Processo não habilitado.")
	Return
Endif

If !( __cUserId $(cUsrHab) )
	MsgAlert("Usuário não autorizado.")
	Return
Endif

nDlg1 := 001
nDlg2 := 001
nDlg3 := 170
nDlg4 := 376

DEFINE MSDIALOG oDlgDwn FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE " " OF oDlgDwn PIXEL
@ 032,065 RADIO oRadio1 VAR nRadio1 3D SIZE 70,11 PROMPT "Pedido de Venda","Documento de Saída","Devolução de Venda","NCC","Log de Alterações" OF oDlgDwn PIXEL
ACTIVATE MSDIALOG oDlgDwn ON INIT EnchoiceBar(oDlgDwn,bOkDwn,bCanDwn) CENTERED

If nOpcDwn == 1
	U_ACOMSUPD(nRadio1)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOMSUPD   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Execução das alterações.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOMSUPD(nRadio1)

If nRadio1 == 1 // Pedido de Venda
	u_BrCmsPed()
ElseIf nRadio1 == 2 // Documento de Saída
	u_BrCmsNfs()
ElseIf nRadio1 == 3 // Devolução de Venda
	u_BrCmsDev()
ElseIf nRadio1 == 4 // NCC
	u_BrCmsNcc()
ElseIf nRadio1 == 5 // Log de Alterações
	u_BrLogAlt()
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BrCmsPed   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Browse para alteração em Pedidos de Venda.				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BrCmsPed()

Private cCadastro := "Pedido de Venda"

Private aRotina   := {{"Pesquisar"    , "AxPesqui"       , 0 , 1 },;
            	      {"Conhecimento" , "MsDocument"     , 0 , 4 , 0 , Nil },;
            	      {"Vendedores"   , "U_ALTCVEN('P')" , 0 , 4 },;
					  {"Ger / Dir"    , "U_ALTCGDR('P')" , 0 , 4 },;
            	      {"Faixas"       , "U_ALTCFAI('P')" , 0 , 5 },;
            	      {"Contábeis"    , "U_ALTCCON('P')" , 0 , 6 },;
            	      {"Visualizar"   , "AxVisual"       , 0 , 2 }}

Private cFiltro   := " C5_TIPO == 'N' .And. Empty(C5_ZZTPBON) .And. !Empty(C5_VEND1) "

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SC5" )			
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "SC5", , , "SC5_FILENT" )		 
oMBrowse:ExecuteFilter()

oMBrowse:Activate()

DbSelectArea("SC5")
DbSetOrder(1)
DbClearFilter()
		
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BrCmsNfs   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Browse para alteração em Documentos de Saída.			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BrCmsNfs()

Private cCadastro := "Documento de Saída"

Private aRotina   := {{"Pesquisar"    , "AxPesqui"       , 0 , 1 },;
            	      {"Conhecimento" , "MsDocument"     , 0 , 4 , 0 , Nil },;
            	      {"Vendedores"   , "U_ALTCVEN('S')" , 0 , 4 },;
					  {"Ger / Dir"    , "U_ALTCGDR('S')" , 0 , 4 },;
            	      {"Faixas"       , "U_ALTCFAI('S')" , 0 , 5 },;
            	      {"Contábeis"    , "U_ALTCCON('S')" , 0 , 6 },;
            	      {"Visualizar"   , "AxVisual"       , 0 , 2 }}

Private cFiltro := " F2_TIPO == 'N' .And. !Empty(F2_VEND1) "

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SF2" )			
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "SF2", , , "SF2_FILENT" )		 
oMBrowse:ExecuteFilter()

oMBrowse:Activate()

DbSelectArea("SF2")
DbSetOrder(1)
DbClearFilter()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BrCmsDev   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Browse para alteração em Documentos de Entrada - Tipo D.	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BrCmsDev()

Private cCadastro := "Devolução de Venda"

Private aRotina   := {{"Pesquisar"    , "AxPesqui"       , 0 , 1 },;
            	      {"Conhecimento" , "MsDocument"     , 0 , 4 , 0 , Nil },;
            	      {"Vendedores"   , "U_ALTCVEN('D')" , 0 , 4 },;
					  {"Ger / Dir"    , "U_ALTCGDR('D')" , 0 , 4 },;
            	      {"Faixas"       , "U_ALTCFAI('D')" , 0 , 5 },;
            	      {"Contábeis"    , "U_ALTCCON('D')" , 0 , 6 },;
            	      {"Visualizar"   , "AxVisual"       , 0 , 2 }}

Private cFiltro := " F1_TIPO $('B,D') "
Private Inclui  := .F.

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SF1" )			
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "SF1", , , "SF1_FILENT" )		 
oMBrowse:ExecuteFilter()

oMBrowse:Activate()

DbSelectArea("SF1")
DbSetOrder(1)
DbClearFilter()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BrCmsNcc   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 20/02/2021  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Browse para alteração em NCC´s calculadas.				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BrCmsNcc()

Private cCadastro := "Notas de Crédito ao Cliente"

Private aRotina   := {{"Pesquisar"    , "AxPesqui"       , 0 , 1 },;
            	      {"Conhecimento" , "MsDocument"     , 0 , 4 , 0 , Nil },;
            	      {"Vendedores"   , "U_ALTCVEN('N')" , 0 , 4 },;
					  {"Ger / Dir"    , "U_ALTCGDR('N')" , 0 , 4 },;
            	      {"Faixas"       , "U_ALTCFAI('N')" , 0 , 5 },;
            	      {"Contábeis"    , "U_ALTCCON('N')" , 0 , 6 },;
            	      {"Visualizar"   , "AxVisual"       , 0 , 2 }}

Private cFiltro := " E3_TIPO == 'NCC' .And. Empty(E3_DATA) .And. Empty(E3_ZZRTV)"
Private Inclui  := .F.

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SE3" )			
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "SE3", , , "SE3_FILENT" )		 
oMBrowse:ExecuteFilter()

oMBrowse:Activate()

DbSelectArea("SE3")
DbSetOrder(1)
DbClearFilter()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BrLogAlt   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Browse para consulta dos logs de alteração.				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BrLogAlt()

Private cCadastro := "Log de Alterações"

Private aRotina   := {{"Pesquisar"  , "AxPesqui" , 0 , 1 },;
            	      {"Visualizar" , "AxVisual" , 0 , 2 }}

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SZQ" )			
oMBrowse:SetDescription( cCadastro )
oMBrowse:Activate()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ALTCVEN    ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Alteração dados Vendedores.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ALTCVEN(xModo)

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma alteração?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona alteração?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM
Private oSayVn1,oSayNm1,oSayAl1,oSayVn2,oSayNm2,oSayAl2,oSayVn3,oSayNm3,oSayAl3,oSayVn4,oSayNm4,oSayAl4
Private cVend1,cVend2,cVend3,cVend4
Private cValt1,cNalt1,cValt2,cNalt2,cValt3,cNalt3,cValt4,cNalt4
Private cUsrCom := AllTrim(GetMv("MV_ZUSCCOM"))
Private cUsrCtl := AllTrim(GetMv("MV_ZUSCCTL"))

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

If xModo == "P"
	If !( __cUserId $(cUsrCom) )
		MsgAlert("Usuário não habilitado para alterações do perfil 'Comercial'.")
		Return
	Endif
	aChkDoc := {}
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.T.)
	// Verifica se o Pedido tem saldo a faturar
	If !u_ChkPedido()
		MsgAlert("Pedido sem saldo para faturar.")
		Return
	Endif
	cTitAd := "Pedido "+SC5->C5_NUM
	cVend1 := SC5->C5_VEND1
	cVend2 := SC5->C5_VEND2
	cVend3 := SC5->C5_VEND3
	cVend4 := SC5->C5_VEND4
ElseIf xModo == "S"
	If !( __cUserId $(cUsrCom) )
		MsgAlert("Usuário não habilitado para alterações do perfil 'Comercial'.")
		Return
	Endif
	// Verifica se a comissão da nota fiscal ainda não foi paga
	aChkDoc := u_ChkDocSai()
	cTitAd := "Documento de Saída "+SF2->F2_DOC
	cVend1 := SF2->F2_VEND1
	cVend2 := SF2->F2_VEND2
	cVend3 := SF2->F2_VEND3
	cVend4 := SF2->F2_VEND4
ElseIf xModo == "D"
	MsgAlert("Opção não disponível para Devoluções.")
	Return
ElseIf xModo == "N"
	If !( __cUserId $(cUsrCom) )
		MsgAlert("Usuário não habilitado para alterações do perfil 'Comercial'.")
		Return
	Endif
	aChkDoc := {}
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.F.)
	AAdd(aChkDoc,.F.)
	AAdd(aChkDoc,.F.)
	//
	cTitAd := "NCC "+AllTrim(SE3->E3_NUM)+"-"+AllTrim(SE3->E3_PREFIXO)
	cVend1 := SE3->E3_VEND
	cVend2 := ""
	cVend3 := ""
	cVend4 := ""
Endif

cNomV1 := IIf(!Empty(cVend1),Posicione("SA3",1,xFilial("SA3")+cVend1,"A3_NOME"),"")
cNomV2 := IIf(!Empty(cVend2),Posicione("SA3",1,xFilial("SA3")+cVend2,"A3_NOME"),"")
cNomV3 := IIf(!Empty(cVend3),Posicione("SA3",1,xFilial("SA3")+cVend3,"A3_NOME"),"")
cNomV4 := IIf(!Empty(cVend4),Posicione("SA3",1,xFilial("SA3")+cVend4,"A3_NOME"),"")
                                                                   
nDlg1 := 001
nDlg2 := 001
nDlg3 := 260
nDlg4 := 900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Alteração de Vendedores - "+cTitAd,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 040,005 SAY "Vendedor1" OF oDlg410 PIXEL SIZE 055,009
@ 039,040 TO 051,085 LABEL "" OF oDlg410 PIXEL
oSayVn1:= TSay():New(042,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn1:SetText( AllTrim(cVend1) )
oSayVn1:CtrlRefresh()

@ 039,090 TO 051,230 LABEL "" OF oDlg410 PIXEL
oSayNm1:= TSay():New(042,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm1:SetText( AllTrim(cNomV1) )
oSayNm1:CtrlRefresh()

cValt1 := cVend1
cNalt1 := cNomV1
@ 039,250 MSGET oValt1 VAR cValt1 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN aChkDoc[1] F3 "SA3" VALID VldVe1()
@ 039,300 TO 051,440 LABEL "" OF oDlg410 PIXEL
oSayAl1:= TSay():New(042,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl1:SetText( AllTrim(cNalt1) )
oSayAl1:CtrlRefresh()

@ 060,005 SAY "Vendedor2" OF oDlg410 PIXEL SIZE 055,009
@ 059,040 TO 071,085 LABEL "" OF oDlg410 PIXEL
oSayVn2:= TSay():New(062,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn2:SetText( AllTrim(cVend2) )
oSayVn2:CtrlRefresh()

@ 059,090 TO 071,230 LABEL "" OF oDlg410 PIXEL
oSayNm2:= TSay():New(062,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm2:SetText( AllTrim(cNomV2) )
oSayNm2:CtrlRefresh()

cValt2 := cVend2
cNalt2 := cNomV2
@ 059,250 MSGET oValt2 VAR cValt2 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN aChkDoc[2] F3 "SA3" VALID VldVe2()
@ 059,300 TO 071,440 LABEL "" OF oDlg410 PIXEL
oSayAl2:= TSay():New(062,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl2:SetText( AllTrim(cNalt2) )
oSayAl2:CtrlRefresh()

@ 080,005 SAY "Vendedor3" OF oDlg410 PIXEL SIZE 055,009
@ 079,040 TO 091,085 LABEL "" OF oDlg410 PIXEL
oSayVn3:= TSay():New(082,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn3:SetText( AllTrim(cVend3) )
oSayVn3:CtrlRefresh()

@ 079,090 TO 091,230 LABEL "" OF oDlg410 PIXEL
oSayNm3:= TSay():New(082,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm3:SetText( AllTrim(cNomV3) )
oSayNm3:CtrlRefresh()

cValt3 := cVend3
cNalt3 := cNomV3
@ 079,250 MSGET oValt3 VAR cValt3 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN aChkDoc[3] F3 "SA3" VALID VldVe3()
@ 079,300 TO 091,440 LABEL "" OF oDlg410 PIXEL
oSayAl3:= TSay():New(082,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl3:SetText( AllTrim(cNalt3) )
oSayAl3:CtrlRefresh()

@ 100,005 SAY "Vendedor4" OF oDlg410 PIXEL SIZE 055,009
@ 099,040 TO 111,085 LABEL "" OF oDlg410 PIXEL
oSayVn4:= TSay():New(102,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn4:SetText( AllTrim(cVend4) )
oSayVn4:CtrlRefresh()

@ 099,090 TO 111,230 LABEL "" OF oDlg410 PIXEL
oSayNm4:= TSay():New(102,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm4:SetText( AllTrim(cNomV4) )
oSayNm4:CtrlRefresh()

cValt4 := cVend4
cNalt4 := cNomV4
@ 099,250 MSGET oValt4 VAR cValt4 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN aChkDoc[4] F3 "SA3" VALID VldVe4()
@ 099,300 TO 111,440 LABEL "" OF oDlg410 PIXEL
oSayAl4:= TSay():New(102,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl4:SetText( AllTrim(cNalt4) )
oSayAl4:CtrlRefresh()

oDlg410:Activate(,,,.T.,{|| ValidVen(xModo) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	u_UpdVenCm(xModo,cVend1,cValt1,cVend2,cValt2,cVend3,cValt3,cVend4,cValt4,"")
	MsgInfo("Alterações realizadas com sucesso !!")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ALTCGDR    ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Alteração dados Gerentes de Diretores.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ALTCGDR(xModo)

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma alteração?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona alteração?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM
Private oSayVn1,oSayNm1,oSayAl1,oSayVn2,oSayNm2,oSayAl2,oSayVn3,oSayNm3,oSayAl3,oSayVn4,oSayNm4,oSayAl4
Private cGeren,cSuper
Private cGcalt,cGnalt,cScalt,cSnalt
Private cUsrCom := AllTrim(GetMv("MV_ZUSCCOM"))
Private cUsrCtl := AllTrim(GetMv("MV_ZUSCCTL"))

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

If xModo == "P"
	If !( __cUserId $(cUsrCom) )
		MsgAlert("Usuário não habilitado para alterações do perfil 'Comercial'.")
		Return
	Endif
	aChkDoc := {}
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.T.)
	// Verifica se o Pedido tem saldo a faturar
	If !u_ChkPedido()
		MsgAlert("Pedido sem saldo para faturar.")
		Return
	Endif
	cTitAd := "Pedido "+SC5->C5_NUM
	cGeren := SC5->C5_GEREN1
	cSuper := SC5->C5_SUPER1
ElseIf xModo == "S"
	If !( __cUserId $(cUsrCom) )
		MsgAlert("Usuário não habilitado para alterações do perfil 'Comercial'.")
		Return
	Endif
	aChkDoc := {}
	AAdd(aChkDoc,(!Empty(SF2->F2_GEREN1)))
	AAdd(aChkDoc,(!Empty(SF2->F2_SUPER1)))
	cTitAd := "Documento de Saída "+SF2->F2_DOC
	cGeren := SF2->F2_GEREN1
	cSuper := SF2->F2_SUPER1
ElseIf xModo == "D"
	MsgAlert("Opção não disponível para Devoluções.")
	Return
ElseIf xModo == "N"
	If !( __cUserId $(cUsrCom) )
		MsgAlert("Usuário não habilitado para alterações do perfil 'Comercial'.")
		Return
	Endif
	aChkDoc := {}
	AAdd(aChkDoc,(!Empty(SE3->E3_ZZGER)))
	AAdd(aChkDoc,(!Empty(SE3->E3_ZZSUP)))
	cTitAd := "NCC "+AllTrim(SE3->E3_NUM)+"-"+AllTrim(SE3->E3_PREFIXO)
	cGeren := SE3->E3_ZZGER
	cSuper := SE3->E3_ZZSUP
Endif

cNomGr := Posicione("SA3",1,xFilial("SA3")+cGeren,"A3_NOME")
cNomDr := Posicione("SA3",1,xFilial("SA3")+cSuper,"A3_NOME")
                                                                   
nDlg1 := 001
nDlg2 := 001
nDlg3 := 260
nDlg4 := 900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Alteração de Gerentes de Diretores - "+cTitAd,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 040,005 SAY "Gerente" OF oDlg410 PIXEL SIZE 055,009
@ 039,040 TO 051,085 LABEL "" OF oDlg410 PIXEL
oSayVn1:= TSay():New(042,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn1:SetText( AllTrim(cGeren) )
oSayVn1:CtrlRefresh()

@ 039,090 TO 051,230 LABEL "" OF oDlg410 PIXEL
oSayNm1:= TSay():New(042,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm1:SetText( AllTrim(cNomGr) )
oSayNm1:CtrlRefresh()

cGcalt := cGeren
cGnalt := cNomGr
@ 039,250 MSGET oValt1 VAR cGcalt SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN aChkDoc[1] F3 "SA3" VALID VldGer()
@ 039,300 TO 051,440 LABEL "" OF oDlg410 PIXEL
oSayAl1:= TSay():New(042,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl1:SetText( AllTrim(cGnalt) )
oSayAl1:CtrlRefresh()

@ 060,005 SAY "Diretor" OF oDlg410 PIXEL SIZE 055,009
@ 059,040 TO 071,085 LABEL "" OF oDlg410 PIXEL
oSayVn2:= TSay():New(062,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn2:SetText( AllTrim(cSuper) )
oSayVn2:CtrlRefresh()

@ 059,090 TO 071,230 LABEL "" OF oDlg410 PIXEL
oSayNm2:= TSay():New(062,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm2:SetText( AllTrim(cNomDr) )
oSayNm2:CtrlRefresh()

cScalt := cSuper
cSnalt := cNomDr
@ 059,250 MSGET oValt2 VAR cScalt SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN aChkDoc[2] F3 "SA3" VALID VldSup()
@ 059,300 TO 071,440 LABEL "" OF oDlg410 PIXEL
oSayAl2:= TSay():New(062,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl2:SetText( AllTrim(cSnalt) )
oSayAl2:CtrlRefresh()

oDlg410:Activate(,,,.T.,{|| ValidGdr(xModo) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	u_UpdGdrCm(xModo,cGeren,cGcalt,cSuper,cScalt,"")
	MsgInfo("Alterações realizadas com sucesso !!")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ALTCFAI    ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Alteração dados Faixas de Comissão.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ALTCFAI(xModo)

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma alteração?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona alteração?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM
Private oSayVn1,oSayNm1,oSayCm1,oSayVn2,oSayNm2,oSayCm2,oSayVn3,oSayNm3,oSayCm3,oSayVn4,oSayNm4,oSayCm4
Private nComs1,nComs2,nComs3,nComs4
Private nCalt1,nCalt2,nCalt3,nCalt4
Private cUsrCom := AllTrim(GetMv("MV_ZUSCCOM"))
Private cUsrCtl := AllTrim(GetMv("MV_ZUSCCTL"))

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

If xModo == "P"
	aChkDoc := {}
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.T.)
	AAdd(aChkDoc,.T.)
	// Verifica se o Pedido tem saldo a faturar
	If !u_ChkPedido()
		MsgAlert("Pedido sem saldo para faturar.")
		Return
	Endif
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( SC5->(C5_FILIAL+C5_NUM) )
	//
	cTitAd := "Pedido "+SC5->C5_NUM
	cVend1 := SC5->C5_VEND1
	nComs1 := SC6->C6_COMIS1
	cVend2 := SC5->C5_VEND2
	nComs2 := SC6->C6_COMIS2
	cVend3 := SC5->C5_VEND3
	nComs3 := SC6->C6_COMIS3
	cVend4 := SC5->C5_VEND4
	nComs4 := SC6->C6_COMIS4
ElseIf xModo == "S"
	// Verifica se a comissão da nota fiscal ainda não foi paga
	aChkDoc := u_ChkDocSai()
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE) )
	//
	cTitAd := "Documento de Saída "+SF2->F2_DOC
	cVend1 := SF2->F2_VEND1
	nComs1 := SD2->D2_COMIS1
	cVend2 := SF2->F2_VEND2
	nComs2 := SD2->D2_COMIS2
	cVend3 := SF2->F2_VEND3
	nComs3 := SD2->D2_COMIS3
	cVend4 := SF2->F2_VEND4
	nComs4 := SD2->D2_COMIS4
ElseIf xModo == "D"
	MsgAlert("Opção não disponível para Devoluções.")
	Return
ElseIf xModo == "N"
	MsgAlert("Opção não disponível para NCC.")
	Return
Endif

cNomV1 := Posicione("SA3",1,xFilial("SA3")+cVend1,"A3_NOME")
cNomV2 := Posicione("SA3",1,xFilial("SA3")+cVend2,"A3_NOME")
cNomV3 := Posicione("SA3",1,xFilial("SA3")+cVend3,"A3_NOME")
cNomV4 := Posicione("SA3",1,xFilial("SA3")+cVend4,"A3_NOME")
                                                                   
nDlg1 := 001
nDlg2 := 001
nDlg3 := 260
nDlg4 := 900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Alteração de Faixas %Comissão - "+cTitAd,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 040,005 SAY "Vendedor1" OF oDlg410 PIXEL SIZE 055,009
@ 039,040 TO 051,085 LABEL "" OF oDlg410 PIXEL
oSayVn1:= TSay():New(042,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn1:SetText( AllTrim(cVend1) )
oSayVn1:CtrlRefresh()

@ 039,090 TO 051,230 LABEL "" OF oDlg410 PIXEL
oSayNm1:= TSay():New(042,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm1:SetText( AllTrim(cNomV1) )
oSayNm1:CtrlRefresh()

@ 040,250 SAY "%Comissão" OF oDlg410 PIXEL SIZE 055,009
@ 039,285 TO 051,330 LABEL "" OF oDlg410 PIXEL
oSayCm1:= TSay():New(042,300,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCm1:SetText( AllTrim(STR(nComs1,5,2)) )
oSayCm1:CtrlRefresh()

nCalt1 := nComs1
@ 039,350 MSGET oCalt1 VAR nCalt1 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 99.99" WHEN !Empty(cVend1) .And. aChkDoc[1] VALID VldCmsV(nCalt1)

@ 060,005 SAY "Vendedor2" OF oDlg410 PIXEL SIZE 055,009
@ 059,040 TO 071,085 LABEL "" OF oDlg410 PIXEL
oSayVn2:= TSay():New(062,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn2:SetText( AllTrim(cVend2) )
oSayVn2:CtrlRefresh()

@ 059,090 TO 071,230 LABEL "" OF oDlg410 PIXEL
oSayNm2:= TSay():New(062,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm2:SetText( AllTrim(cNomV2) )
oSayNm2:CtrlRefresh()

@ 060,250 SAY "%Comissão" OF oDlg410 PIXEL SIZE 055,009
@ 059,285 TO 071,330 LABEL "" OF oDlg410 PIXEL
oSayCm2:= TSay():New(062,300,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCm2:SetText( AllTrim(STR(nComs2,5,2)) )
oSayCm2:CtrlRefresh()

nCalt2 := nComs2
@ 059,350 MSGET oCalt2 VAR nCalt2 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 99.99" WHEN !Empty(cVend2) .And. aChkDoc[2] VALID VldCmsR(nCalt2)

@ 080,005 SAY "Vendedor3" OF oDlg410 PIXEL SIZE 055,009
@ 079,040 TO 091,085 LABEL "" OF oDlg410 PIXEL
oSayVn3:= TSay():New(082,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn3:SetText( AllTrim(cVend3) )
oSayVn3:CtrlRefresh()

@ 079,090 TO 091,230 LABEL "" OF oDlg410 PIXEL
oSayNm3:= TSay():New(082,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm3:SetText( AllTrim(cNomV3) )
oSayNm3:CtrlRefresh()

@ 080,250 SAY "%Comissão" OF oDlg410 PIXEL SIZE 055,009
@ 079,285 TO 091,330 LABEL "" OF oDlg410 PIXEL
oSayCm3:= TSay():New(082,300,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCm3:SetText( AllTrim(STR(nComs3,5,2)) )
oSayCm3:CtrlRefresh()

nCalt3 := nComs3
@ 079,350 MSGET oCalt3 VAR nCalt3 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 99.99" WHEN !Empty(cVend3) .And. aChkDoc[3] VALID VldCmsV(nCalt3)

@ 100,005 SAY "Vendedor4" OF oDlg410 PIXEL SIZE 055,009
@ 099,040 TO 111,085 LABEL "" OF oDlg410 PIXEL
oSayVn4:= TSay():New(102,050,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn4:SetText( AllTrim(cVend4) )
oSayVn4:CtrlRefresh()

@ 099,090 TO 111,230 LABEL "" OF oDlg410 PIXEL
oSayNm4:= TSay():New(102,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm4:SetText( AllTrim(cNomV4) )
oSayNm4:CtrlRefresh()

@ 100,250 SAY "%Comissão" OF oDlg410 PIXEL SIZE 055,009
@ 099,285 TO 111,330 LABEL "" OF oDlg410 PIXEL
oSayCm4:= TSay():New(102,300,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayCm4:SetText( AllTrim(STR(nComs4,5,2)) )
oSayCm4:CtrlRefresh()

nCalt4 := nComs4
@ 099,350 MSGET oCalt4 VAR nCalt4 SIZE 050,010 OF oDlg410 PIXEL PICTURE "@E 99.99" WHEN !Empty(cVend4) .And. aChkDoc[4] VALID VldCmsR(nCalt4)

oDlg410:Activate(,,,.T.,{|| ValidFai(xModo) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	u_UpdFaiCm(xModo,nComs1,nCalt1,nComs2,nCalt2,nComs3,nCalt3,nComs4,nCalt4,"")
	MsgInfo("Alterações realizadas com sucesso !!")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ALTCCON    ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Alteração dados Contábeis.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ALTCCON(xModo)

Local cEOL    := CHR(13)+CHR(10)
Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma alteração?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona alteração?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM
Private oSayVn1,oSayNm1,oSayCm1,oSayVn2,oSayNm2,oSayCm2,oSayVn3,oSayNm3,oSayCm3
Private cCCust,cUnidN,cRegVe
Private cCalt1,cCalt2,cCalt3
Private cUsrCom := AllTrim(GetMv("MV_ZUSCCOM"))
Private cUsrCtl := AllTrim(GetMv("MV_ZUSCCTL"))

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

If xModo == "P"
	If !( __cUserId $(cUsrCom) )
		MsgAlert("Usuário não habilitado para alterações do perfil 'Comercial'.")
		Return
	Endif
	// Verifica se o Pedido tem saldo a faturar
	If !u_ChkPedido()
		MsgAlert("Pedido sem saldo para faturar.")
		Return
	Endif
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( SC5->(C5_FILIAL+C5_NUM) )
	//
	cTitAd := "Pedido "+SC5->C5_NUM
	cCCust := SC6->C6_CCUSTO
	cUnidN := SC6->C6_ZZITCTB
	cRegVe := SC5->C5_ZZREGVE
ElseIf xModo == "S"
	// Verifica se a nota fiscal foi contabilizada
	If !Empty(SF2->F2_DTLANC)
		If !( __cUserId $(cUsrCtl) )
			MsgAlert("A nota fiscal já foi contabilizada."+cEOL+;
					 "Usuário não habilitado para alterações do perfil 'Controladoria'.")
			Return	
		Endif
	Endif
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE) )
	//
	cTitAd := "Documento de Saída "+SF2->F2_DOC
	cCCust := SD2->D2_CCUSTO
	cUnidN := SD2->D2_ITEMCC
	cRegVe := SF2->F2_ZZREGVE
ElseIf xModo == "D"
	// Verifica se a nota fiscal foi contabilizada
	If !Empty(SF1->F1_DTLANC)
		If !( __cUserId $(cUsrCtl) )
			MsgAlert("A nota fiscal já foi contabilizada."+cEOL+;
					 "Usuário não habilitado para alterações do perfil 'Controladoria'.")
			Return	
		Endif
	Endif
	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
	//
	cTitAd := "Documento de Entrada "+SF1->F1_DOC
	cCCust := SD1->D1_CC
	cUnidN := SD1->D1_ITEMCTA
	cRegVe := ""
ElseIf xModo == "N"
	MsgAlert("Opção não disponível para NCC.")
	Return
Endif

cDesCC := Posicione("CTT",1,xFilial("CTT")+cCCust,"CTT_DESC01")
cDesBU := Posicione("CTD",1,xFilial("CTD")+cUnidN,"CTD_DESC01")
cDesRG := Posicione("SX5",1,xFilial("SX5")+"A2"+PadR(cRegVe,6),"X5_DESCRI")
                                                                   
nDlg1 := 001
nDlg2 := 001
nDlg3 := 260
nDlg4 := 900

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Alteração de Dados Contábeis - "+cTitAd,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 040,005 SAY "C.Custo" OF oDlg410 PIXEL SIZE 055,009
@ 039,040 TO 051,085 LABEL "" OF oDlg410 PIXEL
oSayVn1:= TSay():New(042,042,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn1:SetText( AllTrim(cCCust) )
oSayVn1:CtrlRefresh()

@ 039,090 TO 051,230 LABEL "" OF oDlg410 PIXEL
oSayNm1:= TSay():New(042,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm1:SetText( AllTrim(cDesCC) )
oSayNm1:CtrlRefresh()

cCalt1 := cCCust
cDalt1 := cDesCC
@ 039,250 MSGET oValt1 VAR cCalt1 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "CTT" VALID VldCtt()
@ 039,300 TO 051,440 LABEL "" OF oDlg410 PIXEL
oSayAl1:= TSay():New(042,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl1:SetText( AllTrim(cDalt1) )
oSayAl1:CtrlRefresh()

@ 060,005 SAY "Unid.Neg." OF oDlg410 PIXEL SIZE 055,009
@ 059,040 TO 071,085 LABEL "" OF oDlg410 PIXEL
oSayVn2:= TSay():New(062,055,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn2:SetText( AllTrim(cUnidN) )
oSayVn2:CtrlRefresh()

@ 059,090 TO 071,230 LABEL "" OF oDlg410 PIXEL
oSayNm2:= TSay():New(062,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm2:SetText( AllTrim(cDesBU) )
oSayNm2:CtrlRefresh()

cCalt2 := cUnidN
cDalt2 := cDesBU
@ 059,250 MSGET oValt2 VAR cCalt2 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" F3 "CTD" VALID VldCtd()
@ 059,300 TO 071,440 LABEL "" OF oDlg410 PIXEL
oSayAl2:= TSay():New(062,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl2:SetText( AllTrim(cDalt2) )
oSayAl2:CtrlRefresh()

@ 080,005 SAY "Região" OF oDlg410 PIXEL SIZE 055,009
@ 079,040 TO 091,085 LABEL "" OF oDlg410 PIXEL
oSayVn3:= TSay():New(082,055,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayVn3:SetText( AllTrim(cRegVe) )
oSayVn3:CtrlRefresh()

@ 079,090 TO 091,230 LABEL "" OF oDlg410 PIXEL
oSayNm3:= TSay():New(082,093,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayNm3:SetText( AllTrim(cDesRG) )
oSayNm3:CtrlRefresh()

cCalt3 := cRegVe
cDalt3 := cDesRG
@ 079,250 MSGET oValt3 VAR cCalt3 SIZE 048,010 OF oDlg410 PIXEL PICTURE "@!" WHEN (xModo <> "D") F3 "A2" VALID VldReg()
@ 079,300 TO 091,440 LABEL "" OF oDlg410 PIXEL
oSayAl3:= TSay():New(082,303,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayAl3:SetText( AllTrim(cDalt3) )
oSayAl3:CtrlRefresh()

oDlg410:Activate(,,,.T.,{|| ValidCtb(xModo) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	u_UpdCtbCm(xModo,cCCust,cCalt1,cUnidN,cCalt2,cRegVe,cCalt3,"")
	MsgInfo("Alterações realizadas com sucesso !!")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValidVen   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validação dados Vendedores.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidVen(xModo)

Local lRet := .T.
Local lAlt := .F.

If cVend1 <> cValt1
	lAlt := .T.
Endif

If cVend2 <> cValt2
	lAlt := .T.
Endif

If cVend3 <> cValt3
	lAlt := .T.
Endif

If cVend4 <> cValt4
	lAlt := .T.
Endif

If !lAlt
	MsgAlert("Alterações não informadas.")
	lRet := .F.
Endif

If lRet

	If !Empty(cValt1) .And. !(Substr(cValt1,1,1) $("V,G"))
		MsgAlert("Vendedor1 deve ter o código iniciado com 'V' ou 'G'.")
		lRet := .F.
	Endif
	
	If !Empty(cValt2) .And. Substr(cValt2,1,1) <> "R"
		MsgAlert("Vendedor2 deve ter o código iniciado com 'R'.")
		lRet := .F.
	Endif
	
	If !Empty(cValt3) .And. !(Substr(cValt3,1,1) $("V,G"))
		MsgAlert("Vendedor3 deve ter o código iniciado com 'V' ou 'G'.")
		lRet := .F.
	Endif
	
	If !Empty(cValt4) .And. Substr(cValt4,1,1) <> "R"
		MsgAlert("Vendedor4 deve ter o código iniciado com 'R'.")
		lRet := .F.
	Endif

Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValidGdr   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validação dados Gerentes e Diretores.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidGdr(xModo)

Local lRet := .T.
Local lAlt := .F.

If cGeren <> cGcalt
	lAlt := .T.
Endif

If cSuper <> cScalt
	lAlt := .T.
Endif

If !lAlt
	MsgAlert("Alterações não informadas.")
	lRet := .F.
Endif

If lRet

	If !Empty(cGcalt) .And. Substr(cGcalt,1,1) <> "G"
		MsgAlert("Gerente deve ter o código iniciado com 'G'.")
		lRet := .F.
	Endif
	
	If !Empty(cScalt) .And. Substr(cScalt,1,1) <> "D"
		MsgAlert("Diretor deve ter o código iniciado com 'D'.")
		lRet := .F.
	Endif
	
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValidFai   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validação dados Faixas de Comissão.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidFai(xModo)

Local lRet := .T.
Local lAlt := .F.
Local cEOL := CHR(13)+CHR(10)

If nComs1 <> nCalt1
	lAlt := .T.
Endif

If nComs2 <> nCalt2
	lAlt := .T.
Endif

If nComs3 <> nCalt3
	lAlt := .T.
Endif

If nComs4 <> nCalt4
	lAlt := .T.
Endif

If !lAlt
	MsgAlert("Alterações não informadas.")
	lRet := .F.
Endif

If lRet

	If nComs1 <> nCalt1
		If nCalt1 > nComs1
			If !( __cUserId $(cUsrCtl) )
				MsgAlert("%Comissão1 informada é maior que a original."+cEOL+;
						 "Usuário não habilitado para alterações do perfil 'Controladoria'.")
				lRet := .F.	
			Endif
		Endif
	Endif
	
	If nComs2 <> nCalt2
		If nCalt2 > nComs2
			If !( __cUserId $(cUsrCtl) )
				MsgAlert("%Comissão2 informada é maior que a original."+cEOL+;
						 "Usuário não habilitado para alterações do perfil 'Controladoria'.")
				lRet := .F.	
			Endif
		Endif
	Endif

	If nComs3 <> nCalt3
		If nCalt3 > nComs3
			If !( __cUserId $(cUsrCtl) )
				MsgAlert("%Comissão3 informada é maior que a original."+cEOL+;
						 "Usuário não habilitado para alterações do perfil 'Controladoria'.")
				lRet := .F.	
			Endif
		Endif
	Endif

	If nComs4 <> nCalt4
		If nCalt4 > nComs4
			If !( __cUserId $(cUsrCtl) )
				MsgAlert("%Comissão4 informada é maior que a original."+cEOL+;
						 "Usuário não habilitado para alterações do perfil 'Controladoria'.")
				lRet := .F.	
			Endif
		Endif
	Endif

Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValidCtb   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 30/03/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validação dados contábeis.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidCtb(xModo)

Local lRet := .T.
Local lAlt := .F.

If cCCust <> cCalt1
	lAlt := .T.
Endif

If cUnidN <> cCalt2
	lAlt := .T.
Endif

If cRegVe <> cCalt3
	lAlt := .T.
Endif

If !lAlt
	MsgAlert("Alterações não informadas.")
	lRet := .F.
Endif

If lRet

Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldVe1    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Vendedor1.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldVe1()

Local lRetorno := .F.

If Empty(cValt1)
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
	lRetorno := .T.
	Return(lRetorno)
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cValt1 )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Código bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	If !(Substr(SA3->A3_COD,1,1) $("V,G"))
		MsgAlert("Código inválido para RTV.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cNalt1 := Posicione("SA3",1,xFilial("SA3")+cValt1,"A3_NOME")
	oSayAl1:SetText( AllTrim(cNalt1) )
	oSayAl1:CtrlRefresh()
Else
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldVe2    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Vendedor2.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldVe2()

Local lRetorno := .F.

If Empty(cValt2)
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
	lRetorno := .T.
	Return(lRetorno)
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cValt2 )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Código bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	If !(Substr(SA3->A3_COD,1,1) $("R"))
		MsgAlert("Código inválido para Revenda.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cNalt2 := Posicione("SA3",1,xFilial("SA3")+cValt2,"A3_NOME")
	oSayAl2:SetText( AllTrim(cNalt2) )
	oSayAl2:CtrlRefresh()
Else
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldVe3    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Vendedor3.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldVe3()

Local lRetorno := .F.

If Empty(cValt3)
	oSayAl3:SetText( "" )
	oSayAl3:CtrlRefresh()
	lRetorno := .T.
	Return(lRetorno)
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cValt3 )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Código bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	If !(Substr(SA3->A3_COD,1,1) $("V,G"))
		MsgAlert("Código inválido para RTV.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cNalt3 := Posicione("SA3",1,xFilial("SA3")+cValt3,"A3_NOME")
	oSayAl3:SetText( AllTrim(cNalt3) )
	oSayAl3:CtrlRefresh()
Else
	oSayAl3:SetText( "" )
	oSayAl3:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldVe4    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Vendedor4.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldVe4()

Local lRetorno := .F.

If Empty(cValt4)
	oSayAl4:SetText( "" )
	oSayAl4:CtrlRefresh()
	lRetorno := .T.
	Return(lRetorno)
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cValt4 )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Código bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	If !(Substr(SA3->A3_COD,1,1) $("R"))
		MsgAlert("Código inválido para Revenda.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cNalt4 := Posicione("SA3",1,xFilial("SA3")+cValt4,"A3_NOME")
	oSayAl4:SetText( AllTrim(cNalt4) )
	oSayAl4:CtrlRefresh()
Else
	oSayAl4:SetText( "" )
	oSayAl4:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldGer    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Gerente.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldGer()

Local lRetorno := .F.

If Empty(cGcalt)
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
	lRetorno := .T.
	Return(lRetorno)
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cGcalt )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Código bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	If !(Substr(SA3->A3_COD,1,1) $("G"))
		MsgAlert("Código inválido para Gerente.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cGnalt := Posicione("SA3",1,xFilial("SA3")+cGcalt,"A3_NOME")
	oSayAl1:SetText( AllTrim(cGnalt) )
	oSayAl1:CtrlRefresh()
Else
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldSup    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Diretor.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldSup()

Local lRetorno := .F.

If Empty(cScalt)
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
	lRetorno := .T.
	Return(lRetorno)
Endif

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek( xFilial("SA3") + cScalt )
	If SA3->A3_MSBLQL == "1"
		MsgAlert("Código bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	If !(Substr(SA3->A3_COD,1,1) $("D"))
		MsgAlert("Código inválido para Diretor.")
		lRetorno := .F.
	Endif
Endif

If lRetorno
	cSnalt := Posicione("SA3",1,xFilial("SA3")+cScalt,"A3_NOME")
	oSayAl2:SetText( AllTrim(cSnalt) )
	oSayAl2:CtrlRefresh()
Else
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCmsV   ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da Faixa de Comissão do Vendedor.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCmsV(nComsDig)

Local lRetorno := .T.

If nComsDig > 0
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SZ2")
	cQuery += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' "
	cQuery += " AND Z2_COMIS = "+AllTrim(STR(nComsDig))+" "
	cQuery += " AND Z2_VALID >= '"+DtoS(Date())+"' "
	cQuery += " AND Z2_ATIVO = 'S' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ2", .F., .T.)
	lRetorno := ( TRZ2->SOMA > 0 )
	TRZ2->(DbCloseArea())
Endif

If !lRetorno
	MsgAlert("Faixa de comissão (Vendedor) não cadastrada ou inválida.")
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCmsR   ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da Faixa de Comissão da Revenda.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCmsR(nComsDig)

Local lRetorno := .T.

If nComsDig > 0
	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SZ3")
	cQuery += " WHERE Z3_FILIAL = '"+xFilial("SZ3")+"' "
	cQuery += " AND Z3_COMIS = "+AllTrim(STR(nComsDig))+" "
	cQuery += " AND Z3_VALID >= '"+DtoS(Date())+"' "
	cQuery += " AND Z3_ATIVO = 'S' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ3", .F., .T.)
	lRetorno := ( TRZ3->SOMA > 0 )
	TRZ3->(DbCloseArea())
Endif

If !lRetorno
	MsgAlert("Faixa de comissão (Revenda) não cadastrada ou inválida.")
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCtt    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Centro de Custo.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCtt()

Local lRetorno := .F.

If Empty(cCalt1)
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("CTT")
DbSetOrder(1)
If DbSeek( xFilial("CTT") + cCalt1 )
	If CTT->CTT_BLOQ == "1"
		MsgAlert("C.Custo bloqueado para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cDalt1 := Posicione("CTT",1,xFilial("CTT")+cCalt1,"CTT_DESC01")
	oSayAl1:SetText( AllTrim(cDalt1) )
	oSayAl1:CtrlRefresh()
Else
	oSayAl1:SetText( "" )
	oSayAl1:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldCtd    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da Unidade de Negócio.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldCtd()

Local lRetorno := .F.

If Empty(cCalt2)
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("CTD")
DbSetOrder(1)
If DbSeek( xFilial("CTD") + cCalt2 )
	If CTD->CTD_BLOQ == "1"
		MsgAlert("Unid.Negócio bloqueada para uso.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cDalt2 := Posicione("CTD",1,xFilial("CTD")+cCalt2,"CTD_DESC01")
	oSayAl2:SetText( AllTrim(cDalt2) )
	oSayAl2:CtrlRefresh()
Else
	oSayAl2:SetText( "" )
	oSayAl2:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldReg    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação da Região do Vendedor.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldReg()

Local lRetorno := .F.

If Empty(cCalt3)
	oSayAl3:SetText( "" )
	oSayAl3:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

cDesRG := Posicione("SX5",1,xFilial("SX5")+"A2"+PadR(cRegVe,6),"X5_DESCRI")

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek( xFilial("SX5") + "A2" + PadR(cCalt3,6) )
	lRetorno := .T.
Else
	MsgAlert("Código não cadastrado.")
	lRetorno := .F.
Endif

If lRetorno
	cDalt3 := Posicione("SX5",1,xFilial("SX5")+"A2"+PadR(cCalt3,6),"X5_DESCRI")
	oSayAl3:SetText( AllTrim(cDalt3) )
	oSayAl3:CtrlRefresh()
Else
	oSayAl3:SetText( "" )
	oSayAl3:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetFxV    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Código da Faixa de comissão Vendedor.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetFxV(nComis)

Local cRetorno := ""

cQuery := " SELECT Z2_CODIGO CODIGO "
cQuery += " FROM "+RetSqlName("SZ2")
cQuery += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' "
cQuery += " AND Z2_COMIS = "+AllTrim(STR(nComis))+" "
cQuery += " AND Z2_VALID >= '"+DtoS(Date())+"' "
cQuery += " AND Z2_ATIVO = 'S' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ2", .F., .T.)
cRetorno := TRZ2->CODIGO
TRZ2->(DbCloseArea())

Return(cRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetFxR    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Código da Faixa de comissão Revenda.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetFxR(nComis)

Local cRetorno := ""

cQuery := " SELECT Z3_CODIGO CODIGO "
cQuery += " FROM "+RetSqlName("SZ3")
cQuery += " WHERE Z3_FILIAL = '"+xFilial("SZ3")+"' "
cQuery += " AND Z3_COMIS = "+AllTrim(STR(nComis))+" "
cQuery += " AND Z3_VALID >= '"+DtoS(Date())+"' "
cQuery += " AND Z3_ATIVO = 'S' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRZ3", .F., .T.)
cRetorno := TRZ3->CODIGO
TRZ3->(DbCloseArea())

Return(cRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChkPedido ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checagem do Pedido de Venda.	 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ChkPedido()

Local lRet := .T.

cQuery := " SELECT SUM(C6_QTDVEN-C6_QTDENT) AS SALDO "
cQuery += " FROM "+RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+SC5->C5_FILIAL+"' "
cQuery += " AND C6_NUM = '"+SC5->C5_NUM+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL6", .F., .T.)
lRet := (SQL6->SALDO > 0)
SQL6->(DbCloseArea())

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChkDocSai ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 10/03/2020   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checagem do Documento de Saída. 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ChkDocSai()

Local aRet := {}

AAdd(aRet,.F.)
AAdd(aRet,.F.)
AAdd(aRet,.F.)
AAdd(aRet,.F.)

If __cUserId == "000000" // Administrador permite alterações em documentos que possuam parcelas anteriores pagas
	aRet[1] := .T.
	aRet[2] := .T.
	aRet[3] := .T.
	aRet[4] := .T.
	Return(aRet)
Endif

If !Empty(SF2->F2_VEND1)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SE3")
	cQuery += " WHERE E3_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
	cQuery += " AND E3_VEND = '"+SF2->F2_VEND1+"' "
	cQuery += " AND E3_DATA <> ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	aRet[1] := (SQL3->SOMA == 0)
	SQL3->(DbCloseArea())
Endif

If !Empty(SF2->F2_VEND2)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SE3")
	cQuery += " WHERE E3_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
	cQuery += " AND E3_VEND = '"+SF2->F2_VEND2+"' "
	cQuery += " AND E3_DATA <> ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	aRet[2] := (SQL3->SOMA == 0)
	SQL3->(DbCloseArea())
Endif

If !Empty(SF2->F2_VEND3)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SE3")
	cQuery += " WHERE E3_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
	cQuery += " AND E3_VEND = '"+SF2->F2_VEND3+"' "
	cQuery += " AND E3_DATA <> ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	aRet[3] := (SQL3->SOMA == 0)
	SQL3->(DbCloseArea())
Endif

If !Empty(SF2->F2_VEND4)
	cQuery := " SELECT COUNT(*) AS SOMA "
	cQuery += " FROM "+RetSqlName("SE3")
	cQuery += " WHERE E3_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
	cQuery += " AND E3_VEND = '"+SF2->F2_VEND4+"' "
	cQuery += " AND E3_DATA <> ' ' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	aRet[4] := (SQL3->SOMA == 0)
	SQL3->(DbCloseArea())
Endif

Return(aRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdVenCm  ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 15/02/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação da alteração - Vendedores.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UpdVenCm(xModo,cVend1,cValt1,cVend2,cValt2,cVend3,cValt3,cVend4,cValt4,cArqCsv)

Local aArea := GetArea()

// Registra log de alteração
DbSelectArea("SZQ")
RecLock("SZQ",.T.)
SZQ->ZQ_FILIAL := IIf(xModo=="P",SC5->C5_FILIAL,IIf(xModo=="S",SF2->F2_FILIAL,SE3->E3_FILIAL))  
SZQ->ZQ_USER   := cUserName
SZQ->ZQ_DATA   := Date()
SZQ->ZQ_PEDIDO := IIf(xModo=="P",SC5->C5_NUM,"")
SZQ->ZQ_DOC    := IIf(xModo=="P","",IIf(xModo=="S",SF2->F2_DOC,SE3->E3_NUM))
SZQ->ZQ_SERIE  := IIf(xModo=="P","",IIf(xModo=="S",SF2->F2_SERIE,SE3->E3_SERIE))
SZQ->ZQ_TIPO   := IIf(xModo=="P","",IIf(xModo=="S",SF2->F2_TIPO,"D"))
If cVend1 <> cValt1
	SZQ->ZQ_V1OLD := cVend1
	SZQ->ZQ_V1NEW := cValt1
Endif	 
If cVend2 <> cValt2
	SZQ->ZQ_V2OLD := cVend2 
	SZQ->ZQ_V2NEW := cValt2
Endif		
If cVend3 <> cValt3
	SZQ->ZQ_V3OLD := cVend3 
	SZQ->ZQ_V3NEW := cValt3
Endif
If cVend4 <> cValt4
	SZQ->ZQ_V4OLD := cVend4 
	SZQ->ZQ_V4NEW := cValt4
Endif
SZQ->ZQ_ARQCSV := cArqCsv
MsUnLock()

// Grava alterações
If xModo == "P"
	// Pedido de Venda
	RecLock("SC5",.F.)
	If cVend1 <> cValt1
		SC5->C5_VEND1 := cValt1
	Endif	 
	If cVend2 <> cValt2
		SC5->C5_VEND2 := cValt2
	Endif		
	If cVend3 <> cValt3
		SC5->C5_VEND3 := cValt3
	Endif
	If cVend4 <> cValt4
		SC5->C5_VEND4 := cValt4
	Endif		
	MsUnLock()
ElseIf xModo == "S"
	// Documento de Saída
	RecLock("SF2",.F.)
	If cVend1 <> cValt1
		SF2->F2_VEND1 := cValt1
	Endif	 
	If cVend2 <> cValt2
		SF2->F2_VEND2 := cValt2
	Endif		
	If cVend3 <> cValt3
		SF2->F2_VEND3 := cValt3
	Endif
	If cVend4 <> cValt4
		SF2->F2_VEND4 := cValt4
	Endif		
	MsUnLock()
	// Contas a Receber
	lVirgu := .F.
	zFilis := "'"+SF2->F2_FILIAL+"'"
	If SF2->F2_FILIAL == "0103"
		zFilis := "'0103','0106'"
	ElseIf SF2->F2_FILIAL == "0108"
		zFilis := "'0108','0107'"
	Endif
	cQuery := " UPDATE "+RetSqlName("SE1")+" SET "
	If cVend1 <> cValt1
		cQuery += "E1_VEND1 = '"+cValt1+"'"
		lVirgu := .T.
	Endif
	If cVend2 <> cValt2
		cQuery += IIf(lVirgu,", ","")+"E1_VEND2 = '"+cValt2+"'"
		lVirgu := .T.
	Endif
	If cVend3 <> cValt3
		cQuery += IIf(lVirgu,", ","")+"E1_VEND3 = '"+cValt3+"'"
		lVirgu := .T.
	Endif
	If cVend4 <> cValt4
		cQuery += IIf(lVirgu,", ","")+"E1_VEND4 = '"+cValt4+"'"
	Endif
	cQuery += " WHERE E1_FILIAL IN ("+zFilis+") "
	cQuery += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' "
	cQuery += " AND E1_NUM = '"+SF2->F2_DOC+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)
	TCSQLEXEC("COMMIT")
	// Manutenção de Comissões
	If cVend1 <> cValt1
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cValt1+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+cVend1+"' "
		cQuery += " AND E3_ZZRTV = ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
		//		
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_ZZRTV = '"+cValt1+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_ZZRTV = '"+cVend1+"' "
		cQuery += " AND E3_ZZRTV <> ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
	If cVend2 <> cValt2
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cValt2+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+cVend2+"' "
		cQuery += " AND E3_ZZRTV = ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
		//		
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_ZZRTV = '"+cValt2+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_ZZRTV = '"+cVend2+"' "
		cQuery += " AND E3_ZZRTV <> ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
	If cVend3 <> cValt3
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cValt3+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+cVend3+"' "
		cQuery += " AND E3_ZZRTV = ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
		//		
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_ZZRTV = '"+cValt3+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_ZZRTV = '"+cVend3+"' "
		cQuery += " AND E3_ZZRTV <> ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
	If cVend4 <> cValt4
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cValt4+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+cVend4+"' "
		cQuery += " AND E3_ZZRTV = ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
		//		
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_ZZRTV = '"+cValt4+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_ZZRTV = '"+cVend4+"' "
		cQuery += " AND E3_ZZRTV <> ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
ElseIf xModo == "N"
	// NCC
	RecLock("SE3",.F.)
	If cVend1 <> cValt1
		SE3->E3_VEND := cValt1
	Endif	 
	MsUnLock()
	// Manutenção de Comissões - Ger e Dir associados
	If cVend1 <> cValt1
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_ZZRTV = '"+cValt1+"' "
		cQuery += " WHERE E3_FILIAL = '"+SE3->E3_FILIAL+"'
		cQuery += " AND E3_SERIE = '"+SE3->E3_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SE3->E3_NUM+"' "
		cQuery += " AND E3_ZZRTV = '"+cVend1+"' "
		cQuery += " AND E3_ZZRTV <> ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdGdrCm  ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 15/02/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação da alteração - Gerentes e Diretores.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UpdGdrCm(xModo,cGeren,cGcalt,cSuper,cScalt,cArqCsv)

Local aArea := GetArea()

// Registra log de alteração
DbSelectArea("SZQ")
RecLock("SZQ",.T.)
SZQ->ZQ_FILIAL := IIf(xModo=="P",SC5->C5_FILIAL,IIf(xModo=="S",SF2->F2_FILIAL,SE3->E3_FILIAL))  
SZQ->ZQ_USER   := cUserName
SZQ->ZQ_DATA   := Date()
SZQ->ZQ_PEDIDO := IIf(xModo=="P",SC5->C5_NUM,"")
SZQ->ZQ_DOC    := IIf(xModo=="P","",IIf(xModo=="S",SF2->F2_DOC,SE3->E3_NUM))
SZQ->ZQ_SERIE  := IIf(xModo=="P","",IIf(xModo=="S",SF2->F2_SERIE,SE3->E3_SERIE))
SZQ->ZQ_TIPO   := IIf(xModo=="P","",IIf(xModo=="S",SF2->F2_TIPO,"D"))
If cGeren <> cGcalt
	SZQ->ZQ_GROLD := cGeren
	SZQ->ZQ_GRNEW := cGcalt
Endif	 
If cSuper <> cScalt
	SZQ->ZQ_DROLD := cSuper
	SZQ->ZQ_DRNEW := cScalt
Endif
SZQ->ZQ_ARQCSV := cArqCsv
MsUnLock()

// Grava alterações
If xModo == "P"
	// Pedido de Venda
	RecLock("SC5",.F.)
	If cGeren <> cGcalt
		SC5->C5_GEREN1 := cGcalt
	Endif	 
	If cSuper <> cScalt
		SC5->C5_SUPER1 := cScalt
	Endif		
	MsUnLock()
ElseIf xModo == "S"
	// Documento de Saída
	RecLock("SF2",.F.)
	If cGeren <> cGcalt
		SF2->F2_GEREN1 := cGcalt
	Endif	 
	If cSuper <> cScalt
		SF2->F2_SUPER1 := cScalt
	Endif		
	MsUnLock()
	// Contas a Receber
	lVirgu := .F.
	zFilis := "'"+SF2->F2_FILIAL+"'"
	If SF2->F2_FILIAL == "0103"
		zFilis := "'0103','0106'"
	ElseIf SF2->F2_FILIAL == "0108"
		zFilis := "'0108','0107'"
	Endif
	cQuery := " UPDATE "+RetSqlName("SE1")+" SET "
	If cGeren <> cGcalt
		cQuery += "E1_GEREN1 = '"+cGcalt+"'"
		lVirgu := .T.
	Endif
	If cSuper <> cScalt
		cQuery += IIf(lVirgu,", ","")+"E1_SUPER1 = '"+cScalt+"'"
		lVirgu := .T.
	Endif
	cQuery += " WHERE E1_FILIAL IN ("+zFilis+") "
	cQuery += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' "
	cQuery += " AND E1_NUM = '"+SF2->F2_DOC+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)
	TCSQLEXEC("COMMIT")
	// Manutenção de Comissões
	If cGeren <> cGcalt
		If !Empty(cGcalt)
			cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cGcalt+"' "
			cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
			cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
			cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
			cQuery += " AND E3_VEND = '"+cGeren+"' "
			cQuery += " AND E3_ZZRTV <> ' ' " // Registro da apuração G/D
			cQuery += " AND E3_DATA = ' ' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TCSQLEXEC(cQuery)
			TCSQLEXEC("COMMIT")
		Else
			cQuery := " UPDATE "+RetSqlName("SE3")+" SET D_E_L_E_T_ = '*' "
			cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
			cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
			cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
			cQuery += " AND E3_VEND = '"+cGeren+"' "
			cQuery += " AND E3_ZZRTV <> ' ' " // Registro da apuração G/D
			cQuery += " AND E3_DATA = ' ' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TCSQLEXEC(cQuery)
			TCSQLEXEC("COMMIT")
		Endif	
		//		
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_ZZGER = '"+cGcalt+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_ZZGER = '"+cGeren+"' "
		cQuery += " AND E3_ZZRTV = ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
	If cSuper <> cScalt
		If !Empty(cScalt)
			cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cScalt+"' "
			cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
			cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
			cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
			cQuery += " AND E3_VEND = '"+cSuper+"' "
			cQuery += " AND E3_ZZRTV <> ' ' " // Registro da apuração G/D
			cQuery += " AND E3_DATA = ' ' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TCSQLEXEC(cQuery)
			TCSQLEXEC("COMMIT")
		Else
			cQuery := " UPDATE "+RetSqlName("SE3")+" SET D_E_L_E_T_ = '*' "
			cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
			cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
			cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
			cQuery += " AND E3_VEND = '"+cSuper+"' "
			cQuery += " AND E3_ZZRTV <> ' ' " // Registro da apuração G/D
			cQuery += " AND E3_DATA = ' ' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TCSQLEXEC(cQuery)
			TCSQLEXEC("COMMIT")
		Endif	
		//		
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_ZZSUP = '"+cScalt+"' "
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_ZZSUP = '"+cSuper+"' "
		cQuery += " AND E3_ZZRTV = ' ' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
ElseIf xModo == "N"
	// NCC
	RecLock("SE3",.F.)
	If cGeren <> cGcalt
		SE3->E3_ZZGER := cGcalt
	Endif	 
	If cSuper <> cScalt
		SE3->E3_ZZSUP := cScalt
	Endif		
	MsUnLock()
	// Manutenção de Comissões - Vendedor associado
	If cGeren <> cGcalt
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cGcalt+"' "
		cQuery += " WHERE E3_FILIAL = '"+SE3->E3_FILIAL+"' "
		cQuery += " AND E3_SERIE = '"+SE3->E3_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SE3->E3_NUM+"' "
		cQuery += " AND E3_VEND = '"+cGeren+"' "
		cQuery += " AND E3_ZZRTV <> ' ' " // Registro da apuração G/D
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
	If cSuper <> cScalt
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET E3_VEND = '"+cScalt+"' "
		cQuery += " WHERE E3_FILIAL = '"+SE3->E3_FILIAL+"' "
		cQuery += " AND E3_SERIE = '"+SE3->E3_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SE3->E3_NUM+"' "
		cQuery += " AND E3_VEND = '"+cSuper+"' "
		cQuery += " AND E3_ZZRTV <> ' ' " // Registro da apuração G/D
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif	
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdFaiCm  ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 15/02/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação da alteração - Faixas de comissão.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UpdFaiCm(xModo,nComs1,nCalt1,nComs2,nCalt2,nComs3,nCalt3,nComs4,nCalt4,cArqCsv)

Local aArea := GetArea()

// Registra log de alteração
DbSelectArea("SZQ")
RecLock("SZQ",.T.)
SZQ->ZQ_FILIAL := IIf(xModo=="P",SC5->C5_FILIAL,SF2->F2_FILIAL)  
SZQ->ZQ_USER   := cUserName
SZQ->ZQ_DATA   := Date()
SZQ->ZQ_PEDIDO := IIf(xModo=="P",SC5->C5_NUM,"")
SZQ->ZQ_DOC    := IIf(xModo=="P","",SF2->F2_DOC)
SZQ->ZQ_SERIE  := IIf(xModo=="P","",SF2->F2_SERIE)
SZQ->ZQ_TIPO   := IIf(xModo=="P","",SF2->F2_TIPO)
If nComs1 <> nCalt1
	SZQ->ZQ_P1OLD := nComs1
	SZQ->ZQ_P1NEW := nCalt1
Endif	 
If nComs2 <> nCalt2
	SZQ->ZQ_P2OLD := nComs2
	SZQ->ZQ_P2NEW := nCalt2
Endif		
If nComs3 <> nCalt3
	SZQ->ZQ_P3OLD := nComs3
	SZQ->ZQ_P3NEW := nCalt3
Endif
If nComs4 <> nCalt4
	SZQ->ZQ_P4OLD := nComs4
	SZQ->ZQ_P4NEW := nCalt4
Endif		
SZQ->ZQ_ARQCSV := cArqCsv
MsUnLock()

// Grava alterações
If xModo == "P"
	// Pedido de Venda
	RecLock("SC5",.F.)
	If nComs1 <> nCalt1
		SC5->C5_ZZCDFXV := GetFxV(nCalt1)
	Endif		
	If nComs2 <> nCalt2
		SC5->C5_ZZCDFXR := GetFxR(nCalt2)
	Endif		
	If nComs3 <> nCalt3
		SC5->C5_ZCDFXR3 := GetFxV(nCalt3)
	Endif		
	If nComs4 <> nCalt4
		SC5->C5_ZCDFXR4 := GetFxR(nCalt4)
	Endif		
	MsUnLock()
	//
	lVirgu := .F.
	cQuery := " UPDATE "+RetSqlName("SC6")+" SET "
	If nComs1 <> nCalt1
		cQuery += "C6_COMIS1 = "+AllTrim(STR(nCalt1))
		lVirgu := .T.
	Endif
	If nComs2 <> nCalt2
		cQuery += IIf(lVirgu,", ","")+"C6_COMIS2 = "+AllTrim(STR(nCalt2))
		lVirgu := .T.
	Endif
	If nComs3 <> nCalt3
		cQuery += IIf(lVirgu,", ","")+"C6_COMIS3 = "+AllTrim(STR(nCalt3))
		lVirgu := .T.
	Endif
	If nComs4 <> nCalt4
		cQuery += IIf(lVirgu,", ","")+"C6_COMIS4 = "+AllTrim(STR(nCalt4))
	Endif
	cQuery += " WHERE C6_FILIAL = '"+SC5->C5_FILIAL+"' "
	cQuery += " AND C6_NUM = '"+SC5->C5_NUM+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)
	TCSQLEXEC("COMMIT")
ElseIf xModo == "S"
	// Documento de Saída
	lVirgu := .F.
	cQuery := " UPDATE "+RetSqlName("SD2")+" SET "
	If nComs1 <> nCalt1
		cQuery += "D2_COMIS1 = "+AllTrim(STR(nCalt1))
		lVirgu := .T.
	Endif
	If nComs2 <> nCalt2
		cQuery += IIf(lVirgu,", ","")+"D2_COMIS2 = "+AllTrim(STR(nCalt2))
		lVirgu := .T.
	Endif
	If nComs3 <> nCalt3
		cQuery += IIf(lVirgu,", ","")+"D2_COMIS3 = "+AllTrim(STR(nCalt3))
		lVirgu := .T.
	Endif
	If nComs4 <> nCalt4
		cQuery += IIf(lVirgu,", ","")+"D2_COMIS4 = "+AllTrim(STR(nCalt4))
	Endif
	cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
	cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' "
	cQuery += " AND D2_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)
	TCSQLEXEC("COMMIT")
	// Contas a Receber
	lVirgu := .F.
	zFilis := "'"+SF2->F2_FILIAL+"'"
	If SF2->F2_FILIAL == "0103"
		zFilis := "'0103','0106'"
	ElseIf SF2->F2_FILIAL == "0108"
		zFilis := "'0108','0107'"
	Endif
	zFilMs := IIf(SF2->F2_FILIAL=="0103","0106",IIf(SF2->F2_FILIAL=="0108","0107",SF2->F2_FILIAL))
	cQuery := " UPDATE "+RetSqlName("SE1")+" SET "
	If nComs1 <> nCalt1
		cQuery += "E1_COMIS1 = "+AllTrim(STR(nCalt1))
		lVirgu := .T.
	Endif
	If nComs2 <> nCalt2
		cQuery += IIf(lVirgu,", ","")+"E1_COMIS2 = "+AllTrim(STR(nCalt2))
		lVirgu := .T.
	Endif
	If nComs3 <> nCalt3
		cQuery += IIf(lVirgu,", ","")+"E1_COMIS3 = "+AllTrim(STR(nCalt3))
		lVirgu := .T.
	Endif
	If nComs4 <> nCalt4
		cQuery += IIf(lVirgu,", ","")+"E1_COMIS4 = "+AllTrim(STR(nCalt4))
	Endif
	cQuery += " WHERE E1_FILIAL IN ("+zFilis+") "
	cQuery += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' "
	cQuery += " AND E1_NUM = '"+SF2->F2_DOC+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(cQuery)
	TCSQLEXEC("COMMIT")
	// Manutenção de Comissões
	If nComs1 <> nCalt1
		cQuery := " SELECT R_E_C_N_O_ AS RECSE3 "
		cQuery += " FROM "+RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+SF2->F2_VEND1+"' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
		SQL3->(DbGotop())
		While !Eof()
			SE3->(DbGoto(SQL3->RECSE3))
			UpdPerSe3(nCalt1)
			DbSelectArea("SQL3")
			SQL3->(DbSkip())
		Enddo
		SQL3->(DbCloseArea())
	Endif
	If nComs2 <> nCalt2
		cQuery := " SELECT R_E_C_N_O_ AS RECSE3 "
		cQuery += " FROM "+RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+SF2->F2_VEND2+"' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
		SQL3->(DbGotop())
		While !Eof()
			SE3->(DbGoto(SQL3->RECSE3))
			UpdPerSe3(nCalt2)
			DbSelectArea("SQL3")
			SQL3->(DbSkip())
		Enddo
		SQL3->(DbCloseArea())
	Endif
	If nComs3 <> nCalt3
		cQuery := " SELECT R_E_C_N_O_ AS RECSE3 "
		cQuery += " FROM "+RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+SF2->F2_VEND3+"' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
		SQL3->(DbGotop())
		While !Eof()
			SE3->(DbGoto(SQL3->RECSE3))
			UpdPerSe3(nCalt3)
			DbSelectArea("SQL3")
			SQL3->(DbSkip())
		Enddo
		SQL3->(DbCloseArea())
	Endif
	If nComs4 <> nCalt4
		cQuery := " SELECT R_E_C_N_O_ AS RECSE3 "
		cQuery += " FROM "+RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL IN ("+zFilis+") "
		cQuery += " AND E3_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND E3_NUM = '"+SF2->F2_DOC+"' "
		cQuery += " AND E3_VEND = '"+SF2->F2_VEND4+"' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
		SQL3->(DbGotop())
		While !Eof()
			SE3->(DbGoto(SQL3->RECSE3))
			UpdPerSe3(nCalt4)
			DbSelectArea("SQL3")
			SQL3->(DbSkip())
		Enddo
		SQL3->(DbCloseArea())
	Endif
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdCtbCm  ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 15/02/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação da alteração - Dados contábeis.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UpdCtbCm(xModo,cCCust,cCalt1,cUnidN,cCalt2,cRegVe,cCalt3,cArqCsv)

Local aArea := GetArea()

// Registra log de alteração
DbSelectArea("SZQ")
RecLock("SZQ",.T.)
SZQ->ZQ_FILIAL := IIf(xModo=="P",SC5->C5_FILIAL,IIf(xModo=="S",SF2->F2_FILIAL,SF1->F1_FILIAL))  
SZQ->ZQ_USER   := cUserName
SZQ->ZQ_DATA   := Date()
If xModo == "P"
	SZQ->ZQ_PEDIDO := SC5->C5_NUM
ElseIf xModo == "S"
	SZQ->ZQ_DOC    := SF2->F2_DOC
	SZQ->ZQ_SERIE  := SF2->F2_SERIE
	SZQ->ZQ_TIPO   := SF2->F2_TIPO
ElseIf xModo == "D"
	SZQ->ZQ_DOC    := SF1->F1_DOC
	SZQ->ZQ_SERIE  := SF1->F1_SERIE
	SZQ->ZQ_TIPO   := SF1->F1_TIPO
Endif
If cCCust <> cCalt1
	SZQ->ZQ_CCOLD  := cCCust
	SZQ->ZQ_CCNEW  := cCalt1
Endif	 
If cUnidN <> cCalt2
	SZQ->ZQ_BUOLD  := cUnidN
	SZQ->ZQ_BUNEW  := cCalt2
Endif		
If cRegVe <> cCalt3
	SZQ->ZQ_RGOLD  := cRegVe
	SZQ->ZQ_RGNEW  := cCalt3
Endif
SZQ->ZQ_ARQCSV := cArqCsv
MsUnLock()

// Grava alterações
If xModo == "P"
	// Pedido de Venda
	RecLock("SC5",.F.)
	If cUnidN <> cCalt2
		SC5->C5_ZZITCTB := cCalt2
	Endif		
	If cRegVe <> cCalt3
		SC5->C5_ZZREGVE := cCalt3
	Endif		
	MsUnLock()
	//
	If cCCust <> cCalt1
		cQuery := " UPDATE "+RetSqlName("SC6")+" SET "
		cQuery += " C6_CCUSTO = '"+cCalt1+"' "
		cQuery += " WHERE C6_FILIAL = '"+SC5->C5_FILIAL+"' "
		cQuery += " AND C6_NUM = '"+SC5->C5_NUM+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif
	If cUnidN <> cCalt2
		cQuery := " UPDATE "+RetSqlName("SC6")+" SET "
		cQuery += " C6_ZZITCTB = '"+cCalt2+"' "
		cQuery += " WHERE C6_FILIAL = '"+SC5->C5_FILIAL+"' "
		cQuery += " AND C6_NUM = '"+SC5->C5_NUM+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif		
ElseIf xModo == "S"
	// Documento de Saída
	RecLock("SF2",.F.)
	If cRegVe <> cCalt3
		SF2->F2_ZZREGVE := cCalt3
	Endif		
	MsUnLock()
	//
	If cCCust <> cCalt1
		cQuery := " UPDATE "+RetSqlName("SD2")+" SET "
		cQuery += " D2_CCUSTO = '"+cCalt1+"' "
		cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
		cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' "
		cQuery += " AND D2_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif
	If cUnidN <> cCalt2
		cQuery := " UPDATE "+RetSqlName("SD2")+" SET "
		cQuery += " D2_ITEMCC = '"+cCalt2+"' "
		cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
		cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' "
		cQuery += " AND D2_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif		
ElseIf xModo == "D"
	// Documento de Entrada
	If cCCust <> cCalt1
		cQuery := " UPDATE "+RetSqlName("SD1")+" SET "
		cQuery += " D1_CC = '"+cCalt1+"' "
		cQuery += " WHERE D1_FILIAL = '"+SF1->F1_FILIAL+"' "
		cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' "
		cQuery += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
		cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
		cQuery += " AND D1_LOJA = '"+SF1->F1_LOJA+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif
	If cUnidN <> cCalt2
		cQuery := " UPDATE "+RetSqlName("SD1")+" SET "
		cQuery += " D1_ITEMCTA = '"+cCalt2+"' "
		cQuery += " WHERE D1_FILIAL = '"+SF1->F1_FILIAL+"' "
		cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' "
		cQuery += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
		cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
		cQuery += " AND D1_LOJA = '"+SF1->F1_LOJA+"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif		
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdPerSe3  ¦ Autor ¦ Fabrica ERPBR ¦  Data  ¦ 15/02/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Recalcula comissões individualmente.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function UpdPerSe3(nPerc)

If nPerc == 0

	If !Empty(SE3->E3_ZZGER) .And. SE3->E3_COMIS != 0
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE E3_FILIAL = '"+SE3->E3_FILIAL+"' "
		cQuery += " AND E3_VEND = '"+SE3->E3_ZZGER+"' "
		cQuery += " AND E3_NUM = '"+SE3->E3_NUM+"' "
		cQuery += " AND E3_EMISSAO = '"+DtoS(SE3->E3_EMISSAO)+"' "
		cQuery += " AND E3_PREFIXO = '"+SE3->E3_PREFIXO+"' "
		cQuery += " AND E3_PARCELA = '"+SE3->E3_PARCELA+"' "
		cQuery += " AND E3_ZZRTV = '"+SE3->E3_VEND+"' "
		cQuery += " AND E3_DATA = ' ' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif
	If !Empty(SE3->E3_ZZSUP) .And. SE3->E3_COMIS != 0
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE E3_FILIAL = '"+SE3->E3_FILIAL+"' "
		cQuery += " AND E3_VEND = '"+SE3->E3_ZZSUP+"' "
		cQuery += " AND E3_NUM = '"+SE3->E3_NUM+"' "
		cQuery += " AND E3_EMISSAO = '"+DtoS(SE3->E3_EMISSAO)+"' "
		cQuery += " AND E3_PREFIXO = '"+SE3->E3_PREFIXO+"' "
		cQuery += " AND E3_PARCELA = '"+SE3->E3_PARCELA+"' "
		cQuery += " AND E3_ZZRTV = '"+SE3->E3_VEND+"' "
		cQuery += " AND E3_DATA = ' ' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif

	// Devolução de Venda | Ex.: 0106 - NCC 52365 x NF 000000488
	nRgSe3 := SE3->(Recno())
	yFilia := SE3->E3_FILIAL
	yVende := SE3->E3_VEND
	yGeren := SE3->E3_ZZGER
	yDiret := SE3->E3_ZZSUP
	cQuery := " SELECT DISTINCT D1_FILIAL FILIAL, D1_DOC DOC, D1_SERIE SERIE "
	cQuery += " FROM "+RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = '"+SE3->E3_FILIAL+"' "
	cQuery += " AND D1_NFORI = '"+SE3->E3_NUM+"' "
	cQuery += " AND D1_SERIORI = '"+SE3->E3_PREFIXO+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRD1", .F., .T.)
	TRD1->(DbGotop())
	While !Eof()
		cQuery := " SELECT R_E_C_N_O_ RECSE3 "
		cQuery += " FROM "+RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL = '"+TRD1->FILIAL+"'
		cQuery += " AND E3_NUM = '"+TRD1->DOC+"' "
		cQuery += " AND E3_PREFIXO = '"+TRD1->SERIE+"' "
		cQuery += " AND E3_VEND = '"+yVende+"' "
		cQuery += " AND E3_TIPO = 'NCC' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TE3D", .F., .T.)
		TE3D->(DbGotop())
		If !Eof()
			DbSelectArea("SE3")
			SE3->(DbGoto(TE3D->RECSE3))
			// Ajusta NCC do Vendedor
			RecLock("SE3",.F.)
			DbDelete()
			MsUnLock()
			// Ajusta Ger e Dir relacionadas a NCC
			If !Empty(yGeren)
				cQuery := " UPDATE "+RetSqlName("SE3")+" SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE E3_FILIAL = '"+yFilia+"' "
				cQuery += " AND E3_VEND = '"+yGeren+"' "
				cQuery += " AND E3_NUM = '"+TRD1->DOC+"' "
				cQuery += " AND E3_PREFIXO = '"+TRD1->SERIE+"' "
				cQuery += " AND E3_ZZRTV = '"+yVende+"' "
				cQuery += " AND E3_DATA = ' ' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				TCSQLEXEC(cQuery)
				TCSQLEXEC("COMMIT")
			Endif
			If !Empty(yDiret)
				cQuery := " UPDATE "+RetSqlName("SE3")+" SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE E3_FILIAL = '"+yFilia+"' "
				cQuery += " AND E3_VEND = '"+yDiret+"' "
				cQuery += " AND E3_NUM = '"+TRD1->DOC+"' "
				cQuery += " AND E3_PREFIXO = '"+TRD1->SERIE+"' "
				cQuery += " AND E3_ZZRTV = '"+yVende+"' "
				cQuery += " AND E3_DATA = ' ' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				TCSQLEXEC(cQuery)
				TCSQLEXEC("COMMIT")
			Endif
		Endif
		TE3D->(DbCloseArea())
		//
		DbSelectArea("TRD1")
		TRD1->(DbSkip())
	Enddo
	TRD1->(DbCloseArea())

	DbSelectArea("SE3")
	SE3->(DbGoto(nRgSe3))

	RecLock("SE3",.F.)
	DbDelete()
	MsUnLock()

Else

	nComis := (SE3->E3_BASE * (nPerc/100))
	RecLock("SE3",.F.)
	SE3->E3_ZZCOMIS := nComis
	SE3->E3_PORC    := nPerc
	// Atraso
	If SE3->E3_ZZPDESC == 100
		SE3->E3_ZZVDESC := nComis
		SE3->E3_COMIS   := 0.00
	Else
		SE3->E3_ZZVDESC := (nComis * (SE3->E3_ZZPDESC/100))
		SE3->E3_COMIS   := nComis - SE3->E3_ZZVDESC
	Endif	
	// Metas
	If SE3->E3_MTCOMIS > 0
		SE3->E3_MTCOMIS := SE3->E3_COMIS
	Endif	
	If SE3->E3_MTPMETA > 0
		SE3->E3_COMIS := (SE3->E3_COMIS * (SE3->E3_MTPMETA/100))
	Endif	
	MsUnLock()

	If !Empty(SE3->E3_ZZGER) .And. SE3->E3_COMIS != 0
		nPercG := SuperGetMv("ZZ_PERCGER",.T.,"0")	
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET "
		cQuery += " E3_BASE = "+AllTrim(STR(SE3->E3_COMIS))+", "
		cQuery += " E3_COMIS = "+AllTrim(STR(SE3->E3_COMIS*(nPercG/100)))+", "
		cQuery += " E3_ZZCOMIS = "+AllTrim(STR(SE3->E3_COMIS*(nPercG/100)))
		cQuery += " WHERE E3_FILIAL = '"+SE3->E3_FILIAL+"' "
		cQuery += " AND E3_VEND = '"+SE3->E3_ZZGER+"' "
		cQuery += " AND E3_NUM = '"+SE3->E3_NUM+"' "
		cQuery += " AND E3_EMISSAO = '"+DtoS(SE3->E3_EMISSAO)+"' "
		cQuery += " AND E3_PREFIXO = '"+SE3->E3_PREFIXO+"' "
		cQuery += " AND E3_PARCELA = '"+SE3->E3_PARCELA+"' "
		cQuery += " AND E3_ZZRTV = '"+SE3->E3_VEND+"' "
		cQuery += " AND E3_DATA = ' ' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif
	If !Empty(SE3->E3_ZZSUP) .And. SE3->E3_COMIS != 0
		nPercD := SuperGetMv("ZZ_PERCDIR",.T.,"0")	
		cQuery := " UPDATE "+RetSqlName("SE3")+" SET "
		cQuery += " E3_BASE = "+AllTrim(STR(SE3->E3_COMIS))+", "
		cQuery += " E3_COMIS = "+AllTrim(STR(SE3->E3_COMIS*(nPercD/100)))+", "
		cQuery += " E3_ZZCOMIS = "+AllTrim(STR(SE3->E3_COMIS*(nPercD/100)))
		cQuery += " WHERE E3_FILIAL = '"+SE3->E3_FILIAL+"' "
		cQuery += " AND E3_VEND = '"+SE3->E3_ZZSUP+"' "
		cQuery += " AND E3_NUM = '"+SE3->E3_NUM+"' "
		cQuery += " AND E3_EMISSAO = '"+DtoS(SE3->E3_EMISSAO)+"' "
		cQuery += " AND E3_PREFIXO = '"+SE3->E3_PREFIXO+"' "
		cQuery += " AND E3_PARCELA = '"+SE3->E3_PARCELA+"' "
		cQuery += " AND E3_ZZRTV = '"+SE3->E3_VEND+"' "
		cQuery += " AND E3_DATA = ' ' "
		TCSQLEXEC(cQuery)
		TCSQLEXEC("COMMIT")
	Endif

	// Devolução de Venda | Ex.: 0106 - NCC 52365 x NF 000000488
	nRgSe3 := SE3->(Recno())
	yFilia := SE3->E3_FILIAL
	yVende := SE3->E3_VEND
	yGeren := SE3->E3_ZZGER
	yDiret := SE3->E3_ZZSUP
	cQuery := " SELECT DISTINCT D1_FILIAL FILIAL, D1_DOC DOC, D1_SERIE SERIE "
	cQuery += " FROM "+RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = '"+SE3->E3_FILIAL+"' "
	cQuery += " AND D1_NFORI = '"+SE3->E3_NUM+"' "
	cQuery += " AND D1_SERIORI = '"+SE3->E3_PREFIXO+"' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRD1", .F., .T.)
	TRD1->(DbGotop())
	While !Eof()
		cQuery := " SELECT R_E_C_N_O_ RECSE3 "
		cQuery += " FROM "+RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL = '"+TRD1->FILIAL+"'
		cQuery += " AND E3_NUM = '"+TRD1->DOC+"' "
		cQuery += " AND E3_PREFIXO = '"+TRD1->SERIE+"' "
		cQuery += " AND E3_VEND = '"+yVende+"' "
		cQuery += " AND E3_TIPO = 'NCC' "
		cQuery += " AND E3_DATA = ' ' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TE3D", .F., .T.)
		TE3D->(DbGotop())
		If !Eof()
			DbSelectArea("SE3")
			SE3->(DbGoto(TE3D->RECSE3))
			// Ajusta NCC do Vendedor
			yComis := (SE3->E3_BASE * (nPerc/100))
			RecLock("SE3",.F.)
			SE3->E3_PORC    := nPerc
			SE3->E3_COMIS   := yComis
			SE3->E3_ZZCOMIS := yComis
			MsUnLock()
			// Ajusta Ger e Dir relacionadas a NCC
			If !Empty(yGeren)
				nPercG := SuperGetMv("ZZ_PERCGER",.T.,"0")	
				cQuery := " UPDATE "+RetSqlName("SE3")+" SET "
				cQuery += " E3_BASE = "+AllTrim(STR(yComis))+", "
				cQuery += " E3_COMIS = "+AllTrim(STR(yComis*(nPercG/100)))+", "
				cQuery += " E3_ZZCOMIS = "+AllTrim(STR(yComis*(nPercG/100)))
				cQuery += " WHERE E3_FILIAL = '"+yFilia+"' "
				cQuery += " AND E3_VEND = '"+yGeren+"' "
				cQuery += " AND E3_NUM = '"+TRD1->DOC+"' "
				cQuery += " AND E3_PREFIXO = '"+TRD1->SERIE+"' "
				cQuery += " AND E3_ZZRTV = '"+yVende+"' "
				cQuery += " AND E3_DATA = ' ' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				TCSQLEXEC(cQuery)
				TCSQLEXEC("COMMIT")
			Endif
			If !Empty(yDiret)
				nPercD := SuperGetMv("ZZ_PERCDIR",.T.,"0")	
				cQuery := " UPDATE "+RetSqlName("SE3")+" SET "
				cQuery += " E3_BASE = "+AllTrim(STR(yComis))+", "
				cQuery += " E3_COMIS = "+AllTrim(STR(yComis*(nPercD/100)))+", "
				cQuery += " E3_ZZCOMIS = "+AllTrim(STR(yComis*(nPercD/100)))
				cQuery += " WHERE E3_FILIAL = '"+yFilia+"' "
				cQuery += " AND E3_VEND = '"+yDiret+"' "
				cQuery += " AND E3_NUM = '"+TRD1->DOC+"' "
				cQuery += " AND E3_PREFIXO = '"+TRD1->SERIE+"' "
				cQuery += " AND E3_ZZRTV = '"+yVende+"' "
				cQuery += " AND E3_DATA = ' ' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				TCSQLEXEC(cQuery)
				TCSQLEXEC("COMMIT")
			Endif
		Endif
		TE3D->(DbCloseArea())
		//
		DbSelectArea("TRD1")
		TRD1->(DbSkip())
	Enddo
	TRD1->(DbCloseArea())

	DbSelectArea("SE3")
	SE3->(DbGoto(nRgSe3))

Endif

Return
