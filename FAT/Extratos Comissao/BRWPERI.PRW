#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BRWPERI    ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 12/07/2022  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Períodos de Apuração PLR.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BRWPERI()

Private cCadastro := "Períodos de Apuração PLR"

Private aRotina   := {{"Pesquisar"  , "AxPesqui"  , 0 , 1 },;
            	      {"Visualizar" , "AxVisual"  , 0 , 2 },;
					  {"Incluir"    , "AxInclui"  , 0 , 3 },;
					  {"Alterar"    , "AxAltera"  , 0 , 4 },;
					  {"Excluir"    , "AxDeleta"  , 0 , 5 }}

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "ZZP" )
oMBrowse:SetDescription( cCadastro )

oMBrowse:Activate()

Return
