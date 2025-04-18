#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MA040TOK � Autor � Luis Brandini   �    Data  � 08/05/2019 ���
��+----------+------------------------------------------------------------���
���Descricao � Valida��es ap�s confirma��o da grava��o do vendedor.		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA040TOK()

Local lRetOk := .T.
Local lUsuRH := ( __cUserId $ AllTrim(GetMv("MV_XUSPLRH")) )
 
If Inclui
	If (lUsuRH .And. Substr(M->A3_COD,1,2) <> "CM") .Or. (!lUsuRH .And. Substr(M->A3_COD,1,2) == "CM")
		MsgAlert("Usu�rio n�o autorizado a incluir vendedores com este c�digo. Contate o Administrador.")
		lRetOk := .F.
	Endif		
Endif

If lRetOk
	If !Empty(M->A3_SUPER)
		If Substr(M->A3_SUPER,1,1) != "D"
			MsgInfo("O c�digo do Diretor deve iniciar com a letra 'D'.")
			lRetOk := .F.
		Endif
	Endif
Endif

If lRetOk
	If !Empty(M->A3_GEREN)
		If Substr(M->A3_GEREN,1,1) != "G"
			MsgInfo("O c�digo do Gerente deve iniciar com a letra 'G'.")
			lRetOk := .F.
		Endif
	Endif
Endif
                                                                             
Return(lRetOk)
