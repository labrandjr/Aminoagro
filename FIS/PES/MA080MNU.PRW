#INCLUDE  "rwmake.ch"
#INCLUDE  "Topconn.ch"
#INCLUDE  "protheus.ch"
#INCLUDE  "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa �MA080MNU �Autor �Edson G. Barbosa    � Data � 10/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA080MNU()

Local aRotina := ParamIxb[1]
 
ADD OPTION aRotina TITLE "C�pia Mod.2" ACTION "U_MSGMATA080()" OPERATION 6 ACCESS 0
ADD OPTION aRotina TITLE "Conta Ct-e"  ACTION "U_CSVCCTE()"    OPERATION 7 ACCESS 0

Return(aRotina)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun+.o    �MSG080    � Autor �Rodrigo Sartorio       � Data � 04-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri+.o �Funcao que copia um registro do arquivo.                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function MSGMATA080()

nOpcA := 0
cNewTes:=Space(3)
cOldTes:=SF4->F4_CODIGO

@ 000,000 To 155,300 Dialog oDLGA Title "Copia de TES"
@ 00.5,00.5 To 004,018

@ 001,002 Say OemtoAnsi("Da   TES:   ") COLOR CLR_HBLUE
@ 001,005 Say SF4->F4_CODIGO+'-'+SF4->F4_TEXTO

@ 002,002 Say OemtoAnsi("Para TES:   ") COLOR CLR_HBLUE
@ 002,005 Get cNewTES Picture '999' Size 004,005 Valid ValTes(cOldTes,cNewTES)

@ C(050),C(030) BMPBUTTON TYPE 1 Action (CONFIRMA(),oDlga:End())
@ C(050),C(070) BMPBUTTON TYPE 2 Action oDlga:End()

Activate MsDialog oDlgA Center


Return

Static Function confirma()
Local aRegistro   := {}
Local nPosicao    := 0
Local nx

//�����������������������������������������������������������������Ŀ
//� Le as informacoes do registro corrente                          �
//�������������������������������������������������������������������
For nx:=1 to FCount()
	AADD(aRegistro,FieldGet(nx))
Next nx

//�����������������������������������������������������������������Ŀ
//� Efetua a gravacao do novo registro                             �
//�������������������������������������������������������������������
RecLock(Alias(),.T.)
For nx := 1 TO FCount()
	nPosicao:=FieldPos("F4_CODIGO")
	If nPosicao == nx
		FieldPut(nx,cNewTes)
	Else
		FieldPut(nx,aRegistro[nx])
	Endif
Next nx
MsUnlock()

// M-Messenger
U_MT080GRV(.T.)
//
MsgInfo("Tes copiada com Sucesso."+chr(10)+"Efetue as altera��es necessarias na nova Tes.")

Return

Static Function ValTes(cOldTes,cNewTES)
_lRet :=.t.
_AREA := GETAREA()
If SF4->(DbSeek(xFilial("SF4")+cNewTes))
	MsgBox("Tes Ja Cadastrada, escolha outra numera��o.")
	_lRet :=.f.
Endif
If cOldTes < '500' .and. cNewTes >= '500'
	MsgBox("Tes de Entrada deve ser menor que 500.")
	_lRet :=.f.
Endif
If cOldTes >= '500' .and. cNewTes < '500'
	MsgBox("Tes de Saida deve ser maior que 500.")
	_lRet :=.f.
Endif
RESTAREA(_AREA)
Return(_lRet)
