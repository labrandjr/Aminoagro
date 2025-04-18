#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MA331FIM  � Autor �  F�brica ERP.BR   �   Data  � 28/12/16 ���
��+----------+------------------------------------------------------------���
���Descricao � Processamento complementar ap�s contabiliza��o do custo.   ���
���          � - Contabiliza��o do custo de an�lise de sementes.		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA331FIM()

Local aArea    := GetArea()
Local cFilBack := cFilAnt
Local _fil

For _fil := 1 to Len(aFilsCalc)

	If aFilsCalc[_fil][1]

		cFilAnt := aFilsCalc[_fil][2]
		cNomFil := aFilsCalc[_fil][3]
		dDtLanc := mv_par01
		lContab := (mv_par10 == 1)
		lExibir := (mv_par02 == 1)

		If lContab

			MsgRun("Aguarde, contabilizando custo LAB..."+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil),"Processando",{|| U_LABCTBX(cFilAnt,dDtLanc,lExibir) })

			MsgRun("Aguarde, contabilizando custo TROCAS..."+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil),"Processando",{|| U_DEVTROC(cFilAnt,dDtLanc,lExibir) })

		Endif	

	Endif

Next _fil

cFilAnt := cFilBack

RestArea(aArea)

Return
