#include "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBINCFC � Autor � J.DONIZETE R.SILVA � Data �  14/02/08    ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para carga de clientes e fornecedores no plano de ���
���          � contas.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado pelos pontos de entrada M020INC/M030INC/Outros.    ���
�������������������������������������������������������������������������ͼ��
���Data      � Altera��es                                                 ���
���          �                                                             ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CTBINCFC(_cCad)

// Par�metros
//	_cCad
//		C = Clientes
//		F = Fornecedores

Local _xAreaCF 	:= IIf(_cCad=="C",SA1->(GetArea()),SA2->(GetArea()))
Local _cNome	:= IIf(_cCad=="C",SA1->A1_NOME,SA2->A2_NOME)
Local _cCod		:= IIf(_cCad=="C",_cCad+SA1->A1_COD+SA1->A1_LOJA,_cCad+SA2->A2_COD+SA2->A2_LOJA)
Local _cEst		:= IIf(_cCad=="C",SA1->A1_EST,SA2->A2_EST)
Local _cConta	:= ""
Local _cCtaSint	:= ""
Local _aCad		:= {}
Local _cAlias	:= IIf(_cCad=="C","SA1","SA2")
Local _cTipo	:= SubStr(IIf(_cCad=="C",SA1->A1_COD,SA2->A2_COD),1,1)
Local _cFilial	:= ""

Private lMsErroAuto   := .F.
Private lMsHelpAuto   := .T.

// N�o processa se n�o houver par�metros.
If !(_cCad $ ("C,F"))
	Return(.F.)
EndIf

// Processa somente se o m�dulo for SIGACTB e a op��o for de Inclus�o.
If Upper(Alltrim(GetMv("MV_MCONTAB"))) == "CTB"
	
	DbSelectArea(_cAlias)
	
	_cFilial := IIf(_cCad=="C",SA1->A1_FILIAL,SA2->A2_FILIAL)
	_cConta := _cCod
		
	DbSelectArea("CTH")
	DbSetOrder(1)
	If DbSeek( _cFilial + _cCod )
		If CTH->CTH_DESC01 <> _cNome
			If RecLock("CTH",.F.)
				CTH->CTH_DESC01 := _cNome
				MsUnLock()
			EndIf
		EndIf
	Else
		aAdd( _aCad , { "CTH_FILIAL" , _cFilial , Nil } )
		aAdd( _aCad , { "CTH_CLVL"   , _cCod    , Nil } )
		aAdd( _aCad , { "CTH_CLASSE" , "2"      , Nil } )
		aAdd( _aCad , { "CTH_DESC01" , _cNome   , Nil } )
		aAdd( _aCad , { "CTH_CRGNV1" , IIf(Left(_cCod,1)=="C","CLI","FOR"), Nil } )
		
		lMsErroAuto := .F.
		MSExecAuto({|x,y| CTBA060(x,y)},_aCad,3)
		If lMsErroAuto
			MostraErro()
			Alert("N�o foi poss�vel incluir registro.")
		Endif
	Endif
			
	If _cCad == "C"
		If Empty(SA1->A1_ZZCLASS)
			Reclock("SA1",.F.)
			SA1->A1_ZZCLASS := _cConta
			MsUnLock()
		Endif
	Else
		If Empty(SA2->A2_ZZCLASS)
			Reclock("SA2",.F.)
			SA2->A2_ZZCLASS := _cConta
			MsUnLock()
		EndIf
	Endif
	
	RestArea(_xAreaCF)
	
Endif

Return(.T.)
