#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FI040ROT ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 20/10/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Inclusão de rotinas específicas em Títulos a Receber.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FI040ROT()

Local aRotina := PARAMIXB

AAdd(aRotina,{"Duplicata","U_D040DUP()",0,7}) 

Return(aRotina)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ D040DUP  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 20/10/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Prepara duplicata do título a receber posicionado.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function D040DUP()

Local aArea := GetArea()
Local cPerg	:= "D040DUP"

If AllTrim(SE1->E1_ORIGEM) != "MATA460"
	MsgInfo("Título a receber não proveniente da rotina MATA460.")
	Return
Endif

If Pergunte(cPerg,.T.)
	If mv_par02 == 2
		If Empty(mv_par03) .And. Empty(mv_par04) .And. Empty(mv_par05) .And. Empty(mv_par06)
			MsgAlert("Nenhum email informado.")
			Return
		Endif
	Endif
	lSched := .F.
	lExibe := (mv_par01 == 1)
	lEmail := (mv_par02 != 3)
	aEmail := {}
	If mv_par02 == 2
		If !Empty(mv_par03)
			AAdd(aEmail,AllTrim(mv_par03))
		Endif
		If !Empty(mv_par04)
			AAdd(aEmail,AllTrim(mv_par04))
		Endif
		If !Empty(mv_par05)
			AAdd(aEmail,AllTrim(mv_par05))
		Endif
		If !Empty(mv_par06)
			AAdd(aEmail,AllTrim(mv_par06))
		Endif
	Endif	
	U_QQDUPLIC(lSched,lExibe,lEmail,aEmail)
Endif

Pergunte("FIN040",.F.)
RestArea(aArea)

Return
