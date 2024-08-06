#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DL200BRW  ¦ Autor ¦ Luis Brandini    ¦    Data  ¦ 23/05/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar na montagem de carga.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function DL200BRW()

Local aArea := GetArea()
Local aRetn := PARAMIXB

If mv_par06 == 2 // por Item
	aRetn := {}
	AAdd(aRetn, PARAMIXB[01]) // PED_MARCA
	AAdd(aRetn, PARAMIXB[02]) // PED_ROTA
	AAdd(aRetn, PARAMIXB[03]) // PED_SEQROT
	AAdd(aRetn, PARAMIXB[04]) // PED_PEDIDO
	AAdd(aRetn, PARAMIXB[05]) // PED_ITEM
	AAdd(aRetn, PARAMIXB[09]) // PED_CODCLI
//	AAdd(aRetn, PARAMIXB[10]) // PED_LOJA
	AAdd(aRetn, PARAMIXB[11]) // PED_NOME
	AAdd(aRetn, PARAMIXB[07]) // PED_CODPRO
	AAdd(aRetn, PARAMIXB[08]) // PED_DESPRO
	AAdd(aRetn, PARAMIXB[18]) // PED_MUN
	AAdd(aRetn, PARAMIXB[17]) // PED_EST
	AAdd(aRetn, PARAMIXB[16]) // PED_QTDLIB
	AAdd(aRetn, PARAMIXB[13]) // PED_VOLUM
	AAdd(aRetn, PARAMIXB[14]) // PED_PESO
	AAdd(aRetn, PARAMIXB[12]) // PED_VALOR
	AAdd(aRetn, PARAMIXB[15]) // PED_CARGA
	AAdd(aRetn, PARAMIXB[19]) // PED_BAIRRO
	AAdd(aRetn, PARAMIXB[20]) // PED_CEP
	AAdd(aRetn, PARAMIXB[21]) // PED_ENDCLI
	AAdd(aRetn, PARAMIXB[06]) // PED_SEQLIB
Else
	aRetn := {}
	AAdd(aRetn, PARAMIXB[01]) // PED_MARCA
	AAdd(aRetn, PARAMIXB[02]) // PED_ROTA
	AAdd(aRetn, PARAMIXB[03]) // PED_SEQROT
	AAdd(aRetn, PARAMIXB[04]) // PED_PEDIDO
	AAdd(aRetn, PARAMIXB[05]) // PED_ITEM
	AAdd(aRetn, PARAMIXB[07]) // PED_CODCLI
//	AAdd(aRetn, PARAMIXB[08]) // PED_LOJA
	AAdd(aRetn, PARAMIXB[09]) // PED_NOME
	AAdd(aRetn, PARAMIXB[16]) // PED_MUN
	AAdd(aRetn, PARAMIXB[15]) // PED_EST
	AAdd(aRetn, PARAMIXB[14]) // PED_QTDLIB
	AAdd(aRetn, PARAMIXB[11]) // PED_VOLUM
	AAdd(aRetn, PARAMIXB[12]) // PED_PESO
	AAdd(aRetn, PARAMIXB[10]) // PED_VALOR
	AAdd(aRetn, PARAMIXB[13]) // PED_CARGA
	AAdd(aRetn, PARAMIXB[17]) // PED_BAIRRO
	AAdd(aRetn, PARAMIXB[18]) // PED_CEP
	AAdd(aRetn, PARAMIXB[19]) // PED_ENDCLI
	AAdd(aRetn, PARAMIXB[06]) // PED_SEQLIB
Endif

RestArea(aArea)

Return(aRetn)
