#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BRWEXCE    ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 12/07/2022  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Exceções de calculo PLR.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BRWEXCE()

Private cCadastro := "Exceções de Calculo PLR"

Private aRotina   := {{"Pesquisar"  , "AxPesqui"  , 0 , 1 },;
            	      {"Visualizar" , "AxVisual"  , 0 , 2 },;
					  {"Incluir"    , "AxInclui"  , 0 , 3 },;
					  {"Alterar"    , "AxAltera"  , 0 , 4 },;
					  {"Excluir"    , "AxDeleta"  , 0 , 5 }}

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "ZZQ" )
oMBrowse:SetDescription( cCadastro )

oMBrowse:Activate()

Return
