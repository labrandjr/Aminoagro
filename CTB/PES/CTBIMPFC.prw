#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTBIMPFC  � Autor � J.Donizete R.Silva    � Data �13/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descricao � Este programa se destina a clientes que ment�m uma conta   ���
���          � cont�bil para cada Cliente/Fornecedor. Este programa l� o  ���
���          � cadastro de Clientes e Fornecedores e cria as respectivas  ���
���          � contas com base em crit�rios definidos pelo contador da    ���
���          � empresa.                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� -                                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � -                                                          ���
�������������������������������������������������������������������������Ĵ��
���Aplicacao � -                                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Chamada atrav�s do menu em Miscel�nea.                     ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ��
���Donizete      �16/09/07�      � - Unificado parte da rotina que cria a ���
���              �  /  /  �      � conta cont�bil. A rotina � a mesma tan-���
���              �  /  /  �      � to para clientes quanto fornecedores.  ���
���              �  /  /  �      �                                        ���
���              �  /  /  �      � - Revis�o da montagem de contas sint�- ���
���              �  /  /  �      �ticas / anal�ticas.                     ���
���              �  /  /  �      �                                        ���
���Donizete      �09/02/08�      � - Corre��o de vari�veis, tratamento    ���
���              �  /  /  �      �correto do Otherwise, atualiza��o do    ���
���              �  /  /  �      �plano de contas com a raz�o social do   ���
���              �  /  /  �      �cadastro.                               ���
���              �  /  /  �      �                                        ���
���Donizete      �11/02/08�      � - Corre��o do programa para tratar cor-���
���              �  /  /  �      �retamente filiais e compartilhamento de ���
���              �  /  /  �      �arquivos. Corre��o de pequenos erros.   ���
���              �  /  /  �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

// implementado na Katoen Natie em 01/03/2011 por Ricardo Bataglia

User Function CTBIMPFC()

// Variaveis da fun��o
Private oRadioGrp1
Private _oDlg	// Dialog Principal

Public _nOP			:= 0

DEFINE MSDIALOG _oDlg TITLE "Carga de Clientes e Fornecedores no Plano de Contas" FROM C(247),C(330) TO C(401),C(662) PIXEL

// Cria Componentes Padroes do Sistema
@ C(004),C(004) TO C(058),C(165) LABEL "Op��es" PIXEL OF _oDlg
@ C(008),C(007) Radio oRadioGrp1 Var _nOp Items "Clientes","Fornecedores","Ambos" 3D Size C(090),C(010) PIXEL OF _oDlg
@ C(062),C(082) Button "Processar" Size C(037),C(012) PIXEL OF _oDlg Action(Processa({|| OkProc() },"Processando..."),_oDlg:End())
@ C(062),C(124) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())

ACTIVATE MSDIALOG _oDlg CENTERED

Return(.T.)


/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �OkProc   � Autores �                        � Data �13/10/2006���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel pelo processamento principal da rotina.   ���
���           �                                                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function OkProc()

// Verifica se o m�dulo em uso � o SIGACTB.
If Alltrim(GETMV("MV_MCONTAB")) <> "CTB"
	MsgStop("Esta rotina se aplica somente ao m�dulo cont�bil SIGACTB!")
	Return
EndIf

// Faz a chamada de processamento.
If _nOp=0
	MsgAlert("Nenhuma op��o escolhida!")
	Return
ElseIf _nOp=1 // Clientes
	ProcSA1()
ElseIf _nOp=2 // Fornecedores
	ProcSA2()
ElseIf _nOp=3 // Ambos
	ProcSA1() // Clientes
	ProcSA2() // Fornecedores
EndIf

MsgInfo("Carga dos dados efetuada!","CTBIMPFC")

Return

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �PROCSA1  � Autores � J.Donizete R.Silva     � Data �13/10/2006���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por criar as contas de clientes.          ���
���           �                                                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function ProcSA1()

// Abre o alias a processar.
dbSelectArea("SA1")
dbSetOrder(1)
ProcRegua(SA1->(RecCount()))
DbGotop()

// Processa o cadastro de clientes.
While !Eof()
	
	IncProc("Processando Filial/Cliente: " + SA1->A1_FILIAL+"/"+SA1->A1_COD)

	// Chama rotina comum ao SA1/SA2 para cria��o de contas.
	U_CTBINCFC("C")
	
	// Processa o pr�ximo cliente.
	dbSelectArea("SA1")
	dbSkip()

Enddo

Return

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �PROCSA2  � Autores � J.Donizete R.Silva     � Data �13/10/2006���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por criar as contas de fornecedores.      ���
���           �                                                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function ProcSA2()

// Abre o alias a processar.
dbSelectArea("SA2")
dbSetOrder(1)
ProcRegua(SA2->(RecCount()))
DbGotop()

// Processa o cadastro de fornecedores.
While !Eof()
	
	IncProc("Processando Filial/Fornecedor: " + SA2->A2_FILIAL+"/"+SA2->A2_COD)

	// Chama rotina comum ao SA1/SA2 para cria��o de contas.
	U_CTBINCFC("F")
	
	// Processa o pr�ximo fornecedor
	dbSelectArea("SA2")
	dbSkip()

EndDo

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRIACONTA �Autor  �Microsiga           � Data �  16/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para cria��o da conta cont�bil.                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaConta(_cTpCta)

// Inicializa vari�vel.
_cConta := _cCod

dbSelectArea("Ret")
dbSetOrder(1)

// Caso n�o encontre a conta no plano de contas, criar a mesma.
If DbSeek(_cFilial + _cConta)
	If CTD->CTD_DESC01 <> _cNome
		If RecLock("CTD",.f.) // Atualiza a raz�o social
			CTD->CTD_DESC01 := _cNome
			msunlock()
		EndIf
	EndIf
Else
	aAdd( _aCad , { "CTD_FILIAL"  , _cFilial       , Nil } )
	aAdd( _aCad , { "CTD_ITEM"   , _cConta        , Nil } )
	aAdd( _aCad , { "CTD_DESC01"  , _cNome         , Nil } )
	aAdd( _aCad , { "CTD_CLASSE"  , "2"            , Nil } )
	//aAdd( _aCad , { "CTD_NORMAL"  , _cTpCta        , Nil } )
	//aAdd( _aCad , { "CTD_RES"     , _cCod          , Nil } )
	//aAdd( _aCad , { "CTD_CTASUP"  , _cCta          , Nil } )
	//aAdd( _aCad , { "CTD_ACCUST"  , "2"            , Nil } )
	//aAdd( _aCad , { "CTD_ACITEM"  , "2"            , Nil } )
	//aAdd( _aCad , { "CTD_ACCLVL"  , "2"            , Nil } )
	//aAdd( _aCad , { "CTD_CCOBRG"  , "2"            , Nil } )
	//aAdd( _aCad , { "CTD_ITOBRG"  , "2"            , Nil } )
	//aAdd( _aCad , { "CTD_CLOBRG"  , "2"            , Nil } )
	//aAdd( _aCad , { "CTD_BOOK"    , "001/002/003/004/005"  , Nil } )
	//aAdd( _aCad , { "CTD_RGNV1"   , "N"            , Nil } )
	
	// Inclui a conta cont�bil atrav�s de rotina autom�tica.
	MSExecAuto({|x,y| CTBA020(x,y)},_aCad,3)
	If lMsErroAuto
		MostraErro()
		Alert("N�o foi poss�vel incluir registro.")
	Endif
EndIf

Return

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()   � Autores �                        � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//���������������������������Ŀ
//�Tratamento para tema "Flat"�
//�����������������������������
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)
