#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SF1140I   ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 19/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Abertura de processo workflow: tolerância no recebimento.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Alterações¦ Projeto Importador de Xml - 07/12/2021                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SF1140I()

Local aArea   := GetArea()
Local lWfNf   := ( AllTrim(GetMv("MV_WFNFINT")) == "S" )
Local lImpXml := GetMv("MV_IMPXML")

If lWfNf .And. (Inclui .Or. Altera)
	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek( xFilial("SCR") + "NF" + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
		cRotina := AllTrim(FunName())
		U_WFNF01(.F.,Nil,.T.,.F.,cRotina) // WFNF01(lJob,cNumNfe,lShow,lAsk,cRotina)
	Endif
Endif

If lImpXml
	If SF1->F1_TIPO == "N" .And. AllTrim(SF1->F1_ESPECIE) == "CTE" .And. AllTrim(SF1->F1_ORIGEM) == "COMXCOL"
		zCtRatXml := AllTrim(GetMv("MV_ZXMLCTR"))
		zCcRatXml := AllTrim(GetMv("MV_ZXMLCCR"))
		If Empty(zCtRatXml)
			zCtRatXml := "61105006"
		Endif
		If Empty(zCcRatXml)
			zCcRatXml := "101010208001"
		Endif
		DbSelectArea("SD1")
		DbSetOrder(1)
		If DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
			If AllTrim(SD1->D1_COD) == AllTrim(GetMv("MV_XMLPFCT"))
				aRatCte := u_ChkRatCte()
				If Len(aRatCte) > 0
					If Len(aRatCte) == 1
						// Flag ct-e sem rateio
						RecLock("SF1",.F.)
						SF1->F1_XIMPXML := "1"
						MsUnLock()
						//
						RecLock("SD1",.F.)
						SD1->D1_CONTA   := aRatCte[1][1]
						SD1->D1_CC      := aRatCte[1][2]
						SD1->D1_ITEMCTA := Posicione("CTT",1,xFilial("CTT") + aRatCte[1][2],"CTT_ZZITCT")
						MsUnLock()
					Else
						// Flag ct-e a ratear SDE
						RecLock("SF1",.F.)
						SF1->F1_XIMPXML := "R"
						MsUnLock()
						//
						RecLock("SD1",.F.)
						SD1->D1_CONTA   := zCtRatXml
						SD1->D1_CC      := zCcRatXml
						SD1->D1_ITEMCTA := Posicione("CTT",1,xFilial("CTT")+zCcRatXml,"CTT_ZZITCT")
						MsUnLock()
					Endif
				Endif
			Endif
		Endif
	Endif
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChkRatCte ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 27/10/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Checagem de rateio no Ct-e. 								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ChkRatCte()

Local aArea   := GetArea()
Local aRatCte := {}

DbSelectArea("ZZO")
DbSetOrder(1)
If DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
	While !Eof() .And. ZZO->(ZZO_FILIAL+ZZO_DOCCTE+ZZO_SERCTE+ZZO_FORCTE+ZZO_LOJCTE) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		lAdd := .F.
		If Len(aRatCte) == 0
			lAdd := .T.
		Else
			nPos := aScan(aRatCte, {|x| x[1] == ZZO->ZZO_CTANFE .And. x[2] == ZZO->ZZO_CCNFE})
			If nPos == 0
				lAdd := .T.
			Else
				aRatCte[nPos][3] += ZZO->ZZO_VRAT
			Endif	
		Endif
		If lAdd
			AAdd(aRatCte,{ZZO->ZZO_CTANFE, ZZO->ZZO_CCNFE, ZZO->ZZO_VRAT})
		Endif
		DbSelectArea("ZZO")
		ZZO->(DbSkip())
	Enddo
Endif

RestArea(aArea)

Return(aRatCte)
