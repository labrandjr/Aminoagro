#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SISPSX1  ¦ Autor ¦ Robson Assis      ¦    Data  ¦ 03/05/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Trazer os Dados de Banco para as Perguntas   			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo  AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNBCO()        
Local cRetBco := ""
cRetBco := "341"
Return(cRetBco) 

User Function AMNAGE()        
Local cRetAge := ""
cRetAge := IIf(cFilAnt=="0101","0542",IIf(cFilAnt=="0102","0542",IIf(cFilAnt=="0106","0542","1433")))
cRetAge := PadR(cRetAge,TamSx3("EE_AGENCIA")[1])
Return(cRetAge) 

User Function AMNCON()        
Local cRetCon:= ""
cRetCon := IIf(cFilAnt=="0101","57420",IIf(cFilAnt=="0102","57420",IIf(cFilAnt=="0106","16697","30900")))
cRetCon := PadR(cRetCon,TamSx3("EE_CONTA")[1])
Return(cRetCon) 

User Function AMNSUB()        
Local cRetSub:= ""
cRetSub := IIf(cFilAnt=="0101","002",IIf(cFilAnt=="0102","002",IIf(cFilAnt=="0106","002","002")))
cRetSub := PadR(cRetSub,TamSx3("EE_SUBCTA")[1])
Return(cRetSub) 
