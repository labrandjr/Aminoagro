#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � COMXLEG    � Autor � F�brica ERP.BR  � Data  � 20/10/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Legenda Monitor do Importador de Xml.                      ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
���Altera��es� Projeto Importador de Xml - 07/12/2021                     ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function COMXLEG()

Local lImpXml := GetMv("MV_IMPXML")
Local aCoresNew := PARAMIXB[1]

If lImpXml
    AAdd(aCoresNew,{"BR_VERDE_ESCURO","Docto. de Combust�vel"})
Endif    

Return(aCoresNew)

