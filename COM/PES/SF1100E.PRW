#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SF1100E   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 23/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Tratamentos específicos antes da exclusão do Doc.Entrada.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SF1100E()

Local aArea := GetArea()
Local oTMsg := FswTemplMsg():TemplMsg("E",SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)

If !Empty(SF1->F1_CHVNFE)
	//
	DbSelectArea("ZZG")
	DbSetOrder(1)
	If DbSeek( SF1->F1_CHVNFE )
		If ZZG->ZZG_TIPO == "2"
			RecLock("ZZG",.F.)
			ZZG->ZZG_TIPO := "1"
			MsUnLock()
		ElseIf ZZG->ZZG_TIPO == "6"
			RecLock("ZZG",.F.)
			ZZG->ZZG_TIPO := "5"
			MsUnLock()
		Endif
	Endif
	//
/*	DbSelectArea("SDS")
	DbSetOrder(2)
	If DbSeek( SF1->(F1_FILIAL + F1_CHVNFE) )
		RecLock("SDS",.F.)
		SDS->DS_STATUS  := ""
        SDS->DS_USERPRE := ""
        SDS->DS_DATAPRE := CtoD("")
        SDS->DS_HORAPRE := ""
		MsUnLock()
	Endif */
Endif

oTMsg:excMsg()

RestArea(aArea)

Return
