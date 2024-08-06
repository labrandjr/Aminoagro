#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA040VLD ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 14/02/2022 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validações na manutenção do Vendedor - Perfil Coml.|RH	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA040VLD()

Local nOpc   := PARAMIXB // 3- Inclusão | 4- Alteração | 5- Exclusão
Local lRet   := .T.
Local lUsuRH := ( __cUserId $ AllTrim(GetMv("MV_XUSPLRH")) )
 
If nOpc == 4
	If (lUsuRH .And. Substr(SA3->A3_COD,1,2) <> "CM") .Or. (!lUsuRH .And. Substr(SA3->A3_COD,1,2) == "CM")
		MsgAlert("Usuário não autorizado a efetuar alterações para este vendedor. Contate o Administrador.")
		lRet := .F.
	Endif		
ElseIf nOpc == 5
	If (lUsuRH .And. Substr(SA3->A3_COD,1,2) <> "CM") .Or. (!lUsuRH .And. Substr(SA3->A3_COD,1,2) == "CM")
		MsgAlert("Usuário não autorizado a efetuar exclusão deste vendedor. Contate o Administrador.")
		lRet := .F.
	Endif		
Endif
 
Return(lRet)
