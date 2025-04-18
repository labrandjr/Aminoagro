#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MA235PC   � Autor � Luis Brandini    � Data  � 03/02/2021  ���
��+----------+------------------------------------------------------------���
���Descricao � Efetua pr�-valida��o antes do processamento.               ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA235PC()

Local aArea   := GetArea()
Local lRetOk  := .T.
Local cEOL    := CHR(13)+CHR(10)
Local cUsErPc := AllTrim(GetMv("MV_ZUSERPC"))

If !(__cUserId $(cUsErPc))
    MsgAlert("Usu�rio n�o autorizado. Contate o Administrador.")
    lRetOk := .F.
Endif

If lRetOk
    If Empty(mv_par04)
        MsgAlert("O par�metro 'Solic/Pedido de' n�o pode ser brancos.")
        lRetOk := .F.
    Endif
Endif

If lRetOk
    If Upper(AllTrim(mv_par05)) == "ZZZZZZ" .Or. Upper(AllTrim(mv_par05)) == "999999"
        MsgAlert("O par�metro 'Solic/Pedido at�' n�o pode ser ZZZZZZ ou 999999.")
        lRetOk := .F.
    Endif
Endif

If mv_par08 == 1
    cEntid := "Pedido Compra"
ElseIf mv_par08 == 2
    cEntid := "Aut. de Entrega"
ElseIf mv_par08 == 3
    cEntid := "Pedido/Aut.Ent."
ElseIf mv_par08 == 4
    cEntid := "Contr.Parceria"
ElseIf mv_par08 == 5
    cEntid := "Solic. Compras"
Endif

If lRetOk
    If !MsgYesNo("Confirma o processamento Eliminar Res�duos ?"+cEOL+;
                cEntid+" de "+AllTrim(mv_par04)+" at� "+AllTrim(mv_par05))
        lRetOk := .F.
    Endif
Endif

RestArea(aArea)

Return(lRetOk)
