#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � PCOC3801  � Autor � F�brica ERPBR    �   Data  � 07/04/19  ���
��+----------+------------------------------------------------------------���
���Descricao � Filtro no browse Vis�o Gerencial - Proje��es por Per�odo.  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function PCOC3801()

Local aArea   := GetArea()
Local zFiltro := ""
Local aVisoes := {}

ChkFile("SZK")

DbSelectArea("SZK")
DbSetOrder(1)
If DbSeek( xFilial("SZK") + __cUserId )
	While !Eof() .And. SZK->ZK_FILIAL == xFilial("SZK") .And. SZK->ZK_USER == __cUserId
		AAdd(aVisoes,SZK->ZK_VISAO)	
		SZK->(DbSkip())
	Enddo 
Endif

If Len(aVisoes) > 0
	For _x := 1 to Len(aVisoes)
		If _x == 1
			zFiltro := "AKN_CODIGO == '"+aVisoes[_x]+"' "
		Else
			zFiltro += ".Or. AKN_CODIGO == '"+aVisoes[_x]+"' "
		Endif
	Next _x
	DbSelectArea("AKN")
	Set Filter to &(zFiltro)
Endif

RestArea(aArea)

Return(Nil)
