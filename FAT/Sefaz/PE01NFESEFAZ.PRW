#include "protheus.ch"

User Function PE01NFESEFAZ()

Local aArea    := GetArea()
Local aRetorno := {}

//Altera as informações carregadas para o XML
aRetorno := U_InfoNFe(PARAMIXB[1],PARAMIXB[2],PARAMIXB[3],PARAMIXB[4],PARAMIXB[5],PARAMIXB[6],PARAMIXB[7],PARAMIXB[8],PARAMIXB[9],PARAMIXB[10],PARAMIXB[11],PARAMIXB[12],PARAMIXB[13],PARAMIXB[14],PARAMIXB[15],PARAMIXB[16],PARAMIXB[17],PARAMIXB[18])

RestArea(aArea)

Return(aRetorno)
