#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MDeExpFil � Autor � F�brica ERP.BR   �    Data  � 18/02/20 ���
��+----------+------------------------------------------------------------���
���Descricao � Filtro na exporta��o do Xml - Manifesta��o do Destinat�rio.���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MDeExpFil()

Local cSqlFil := ""
Local cPerg   := "ADDEXPFIL1"
Local cDocIni := mv_par02
Local cDocFim := mv_par03

If Pergunte(cPerg,.T.)
	cSqlFil := "C00_FILIAL='"+xFilial("C00")+"' "
	cSqlFil += "AND C00_DTEMI BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cSqlFil += "AND C00_SERNFE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
	cSqlFil += "AND C00_NUMNFE BETWEEN '"+cDocIni+"' AND '"+cDocFim+"' "
	cSqlFil += "AND C00_STATUS IN('1','4') "
Endif

Return(cSqlFil)
