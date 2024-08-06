#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT103FIM  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 19/02/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Abertura de processo workflow: tolerância no recebimento.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT103FIM()

Local aArea   := GetArea()
Local lWfNf   := ( AllTrim(GetMv("MV_WFNFINT")) == "S" )
Local lInclui := (PARAMIXB[1] == 3)
Local lSalvar := (PARAMIXB[2] == 1)
Local lExclui := (PARAMIXB[1] == 5)

If lInclui .And. lSalvar
	RecLock("SF1",.F.)
	SF1->F1_ZZUSER := __cUserID
	If SF1->F1_FORMUL == "S"
		SF1->F1_INDPRES := "0"
	Endif
	MsUnLock()
Endif

// Atualiza flag compra de MP
u_ChkNfMp()

If lWfNf .And. lInclui .And. lSalvar
	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek( xFilial("SCR") + "NF" + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
		cRotina := AllTrim(FunName())
		U_WFNF01(.F.,Nil,.T.,.F.,cRotina) // WFNF01(lJob,cNumNfe,lShow,lAsk,cRotina)
	Endif
Endif

// Alerta para exclusão de Documento de Transferência entre Filiais
If lExclui .And. lSalvar
	If GetMv("MV_ZEMNFTR")
		If u_ChkNfTr("E", SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE)
			u_EmlNfTr("E", SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE)
		Endif
	Endif
Endif

// Alerta para inclusão de Documento de Ct-e sem conta contábil
If lInclui .And. lSalvar .And. AllTrim(SF1->F1_ESPECIE) == "CTE"
	If GetMv("MV_ZEMCCTE")
		aTesCte := {}
		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
		While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			If !Empty(SD1->D1_XNFFRE) .And. AllTrim(SD1->D1_COD) $(AllTrim(GetMv("MV_ZPRDFRT")))
				zTes := POSICIONE("SD1",1,XFILIAL("SD1")+SD1->D1_XNFFRE,"D1_TES")
				zCta := POSICIONE("SF4",1,XFILIAL("SF4")+zTes,"F4_ZCTACTE")
				If !Empty(zTes) .And. Empty(zCta)
					lAdd := .F.
					If Len(aTesCte) == 0
						lAdd := .T.
					Else
						If aScan(aTesCte, {|x| x == zTes }) == 0
							lAdd := .T.
						Endif
					Endif	
					If lAdd
						AAdd(aTesCte,zTes)
					Endif
				Endif
			ElseIf !Empty(SD1->D1_XNFFRS) .And. AllTrim(SD1->D1_COD) $(AllTrim(GetMv("MV_ZPRDFRT")))
				zTes := POSICIONE("SD2",3,XFILIAL("SD2")+SD1->D1_XNFFRS,"D2_TES")
				zCta := POSICIONE("SF4",1,XFILIAL("SF4")+zTes,"F4_ZCTACTE")
				If !Empty(zTes) .And. Empty(zCta)
					lAdd := .F.
					If Len(aTesCte) == 0
						lAdd := .T.
					Else
						If aScan(aTesCte, {|x| x == zTes }) == 0
							lAdd := .T.
						Endif
					Endif	
					If lAdd
						AAdd(aTesCte,zTes)
					Endif
				Endif
			Endif
			DbSelectArea("SD1")
			SD1->(DbSkip())
		Enddo
		If Len(aTesCte) > 0
			u_EmlCCte(SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, aTesCte)
		Endif
	Endif
Endif

RestArea(aArea)

Return
