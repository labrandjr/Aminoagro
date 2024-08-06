#include 'rwmake.ch'

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT080GRV ¦ Autor ¦ Luis Brandini   ¦    Data  ¦ 03/10/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger na inclusão do Tipo de Entrada/Saída.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT080GRV(lCopia)

Local aArea    := GetArea()
Local zUsrMail := AllTrim(GetMv("MV_XEMCCUS"))
Local aUsrMail := {}
Local lInclusa := IIf(lCopia == Nil,Inclui,.T.)
Local _x

If !lInclusa
	Return
Endif

If !Empty(zUsrMail)
	nPosic  := 0
	aLinha  := {}
	cTxtLin := zUsrMail
	While (!Empty(cTxtLin))
		If (((nPosic := AT(",",cTxtLin)) > 0))
			AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
			cTxtLin := Stuff(cTxtLin,1,nPosic,"")
		Else
			AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
			cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
		Endif	
	Enddo
	aUsrMail := aClone(aLinha)
Endif

For _x := 1 to Len(aUsrMail)
	zEmail := UsrRetMail(aUsrMail[_x])
	If !Empty(zEmail)
		nPosic := AT("@",zEmail)
		If nPosic > 0
			cTipoTes := IIf(SF4->F4_CODIGO < "500","entrada","saída")
			cAssunto := "Inclusao de TES"
			//
			aMensage := {}
			AAdd(aMensage, "Evento X04 - O tipo de "+cTipoTes+" abaixo acaba de ser incluído no sistema pelo usuário "+AllTrim(cUserName))
			AAdd(aMensage, "")
			AAdd(aMensage, ">> Código: "+AllTrim(SF4->F4_CODIGO))
			AAdd(aMensage, ">> Txt Padrão: "+AllTrim(SF4->F4_TEXTO))
			AAdd(aMensage, ">> Finalidade: "+AllTrim(SF4->F4_FINALID))
			U_MailNotify(zEmail, cAssunto, aMensage, .F.)
		Endif
	Endif
Next _x	

// Replica para as demais filiais
zRecSM0 := SM0->(Recno())
zFilAnt := cFilAnt
zRecSF4 := SF4->(Recno())
zCodTes := SF4->F4_CODIGO
DbselectArea("SM0")
SM0->(DbGotop())
While !Eof()
	If AllTrim(SM0->M0_CODFIL) != AllTrim(zFilAnt) .And. AllTrim(SM0->M0_CODFIL) != "0105"
		zFilInc := AllTrim(SM0->M0_CODFIL)
		DbSelectArea("SF4")
		DbSetOrder(1)
		If !DbSeek( zFilInc + zCodTes )
			SF4->(DbGoto(zRecSF4))
			_InsereTes(zFilInc,zCodTes)
		Endif
		SF4->(DbGoto(zRecSF4))
	Endif
	DbselectArea("SM0")
	SM0->(DbSkip())
Enddo
SM0->(DbGoto(zRecSM0))
cFilAnt := zFilAnt
	
RestArea(aArea)

Return


Static Function _InsereTes(zFilInc,zCodTes)

Local aRegistro   := {}
Local nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le as informacoes do registro corrente                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx:=1 to FCount()
	AAdd(aRegistro,FieldGet(nx))
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a gravacao do novo registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("SF4",.T.)
For nx := 1 to fCount()
	nPosFil := FieldPos("F4_FILIAL")
	nPosCod := FieldPos("F4_CODIGO")
	If nPosFil == nx
		FieldPut(nx,zFilInc)
	ElseIf nPosCod == nx
		FieldPut(nx,zCodTes)
	Else
		FieldPut(nx,aRegistro[nx])
	Endif
Next nx
MsUnLock()

Return
