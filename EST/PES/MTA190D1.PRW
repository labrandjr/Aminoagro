#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MTA190D1  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 06/06/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Calculo do custo de entrada para notas fiscais de import.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MTA190D1()

Local aArea    := GetArea()
Local aRetorno := PARAMIXB[1]

If SF1->F1_FILIAL == "0102" .And. SF1->F1_EST == "EX" .And. SF4->F4_CREDICM == "S" .And. SF4->F4_ESTOQUE == "S"
//	aRetorno[1][1] := SD1->((D1_TOTAL-D1_VALICM)+D1_DESPESA)
	aRetorno[1][1] := SD1->(D1_TOTAL+D1_DESPESA) // Jefferson - 27/08/2019
ElseIf SF1->F1_FILIAL $("0103,0106") .And. SF1->F1_EST == "EX" .And. SF4->F4_CREDICM == "S" .And. SF4->F4_ESTOQUE == "S"
//	aRetorno[1][1] := SD1->((D1_TOTAL-D1_VALICM)+D1_DESPESA)
	aRetorno[1][1] := SD1->(D1_TOTAL+D1_DESPESA) // Jefferson - 27/08/2019
// *********************************************************************************************************
// Exceções abaixo...
ElseIf SF1->F1_FILIAL == "0102" .And. SF1->F1_EST == "EX" .And. SF1->F1_DOC == "000020091" // Exceção fechamento de novembro - Jefferson 06/12/2017
	aRetorno[1][1] := SD1->(D1_TOTAL-D1_VALICM)
ElseIf SF1->F1_FILIAL == "0102" .And. SF1->F1_EST == "EX" .And. SF1->F1_DOC == "000020104" // Exceção fechamento de novembro - Jefferson 06/12/2017
	aRetorno[1][1] := SD1->(D1_TOTAL-D1_VALICM)
ElseIf SF1->F1_FILIAL == "0102" .And. SF1->F1_EST == "EX" .And. SF1->F1_DOC == "000020248" // Exceção fechamento de novembro - Jefferson 06/12/2017
	aRetorno[1][1] := SD1->(D1_TOTAL-D1_VALICM)
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "1328" // Exceção fechamento de agosto/2018 - Jefferson
	aRetorno[1][1] := 9480
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "1329" // Exceção fechamento de agosto/2018 - Jefferson
	aRetorno[1][1] := 2022.40
ElseIf SF1->F1_FILIAL == "0103" .And. AllTrim(SF1->F1_DOC) == "233750" // Exceção fechamento de agosto/2018 - Jefferson
	aRetorno[1][1] := 19.53
	aRetorno[2][1] := 94.40
	aRetorno[3][1] := 202.32
	aRetorno[4][1] := 184.08
	aRetorno[5][1] := 386.40
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "8336" // Exceção fechamento de agosto/2018 - Jefferson
	aRetorno[1][1] := 1495.70
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "8448" // Exceção fechamento de outubro/2018 - Jefferson
	aRetorno[1][1] := 8676.00
	aRetorno[2][1] := 108.40
	aRetorno[3][1] := 634.79
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "8449" // Exceção fechamento de outubro/2018 - Jefferson
	aRetorno[1][1] := 578.40
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "8452" // Exceção fechamento de outubro/2018 - Jefferson
	aRetorno[1][1] := 285.00
ElseIf SF1->F1_FILIAL == "0103" .And. AllTrim(SF1->F1_DOC) == "102413" // Exceção fechamento de fevereiro/2019 - Jefferson
	aRetorno[1][1] := 418.20
	aRetorno[2][1] := 714.00
	aRetorno[3][1] := 89.10
	aRetorno[4][1] := 719.80
	aRetorno[5][1] := 1674.00
	aRetorno[6][1] := 3107.60
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "000002852" // Exceção fechamento de maio/2019 - Jefferson
	aRetorno[1][1] := 122.65
	aRetorno[2][1] := 855.80
	aRetorno[3][1] := 222.93
	aRetorno[4][1] := 872.60
	aRetorno[5][1] := 175.46
	aRetorno[6][1] := 140.45
	aRetorno[7][1] := 741.38
	aRetorno[8][1] := 115.07
	aRetorno[9][1] := 225.12
ElseIf SF1->F1_FILIAL == "0102" .And. AllTrim(SF1->F1_DOC) == "000006258" .And. AllTrim(SF1->F1_SERIE) == "4" // Exceção fechamento de fevereiro/2020 - Jefferson
	aRetorno[1][1] := 3091.85
Endif

RestArea(aArea)

Return(aRetorno)
