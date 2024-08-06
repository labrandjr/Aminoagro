#include "rwmake.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF240FIL   บAutor  ณRobson Assis        บ Data ณ  15/02/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada para execucao de filtro complementar na   บฑฑ
ฑฑบ          ณ geracao do bordero de pagamentos (FINA240)/(FINA241)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SISPAG     - ITAU                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function F240FIL()

Local _cRet := ""
Local aArea := GetArea()

If cEmpAnt == "G1"     //S๓ irแ ser executado na empresa Sucorrico - 60
	If cPort240 == "341"  //S๓ executarแ quando o bordero for Itau
		
		If cModPgto =="30"
			_cRet := "SUBSTR(E2_LINDIG,1,3)== '341'"  //Titulo com Boleto do Itau
		Elseif cModPgto =="31"
			_cRet := "SUBSTR(E2_LINDIG,1,3)<> '341'"  //Titulo com Boleto de outros bancos
			_cRet += " .AND. !EMPTY(E2_LINDIG)"
		Endif
		
		If cModPgto == "01" //Credito em conta Corrente - Titulo de Fornecedor sem codigo de barra e fornecedor com o mesmo banco
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') == " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			
		Elseif cModPgto =="03" //DOC Outro Titular - Titulo sem codigo de barras, fornecedor banco diferente e valor menor que R$1000,00
			
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') <> " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			//_cRet += " .AND. E2_VALOR < 1000"
			
		Elseif cModPgto =="41" //TED Outro Titular - Titulo sem codigo de barras, fornecedor banco diferente e valor Maior ou igual a R$1000,00
			
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') <> " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			//_cRet += " .AND. E2_VALOR >= 1000"
		Endif
	ElseIf cPort240 == "001"  //S๓ executarแ quando o bordero for Banco do Brasil
		
		If cModPgto =="30"
			_cRet := "SUBSTR(E2_LINDIG,1,3)== '001'"  //Titulo com Boleto do BB
		Elseif cModPgto =="31"
			_cRet := "SUBSTR(E2_LINDIG,1,3)<> '001'"  //Titulo com Boleto de outros bancos
			_cRet += " .AND. !EMPTY(E2_LINDIG)"
		Endif
		
		If cModPgto == "01" //Credito em conta Corrente - Titulo de Fornecedor sem codigo de barra e fornecedor com o mesmo banco
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') == " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			
		Elseif cModPgto == "03" //DOC Outro Titular - Titulo sem codigo de barras, fornecedor banco diferente e valor menor que R$1000,00
			
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') <> " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			//_cRet += " .AND. E2_VALOR < 1000"
			
		Elseif cModPgto == "41" //TED Outro Titular - Titulo sem codigo de barras, fornecedor banco diferente e valor Maior ou igual a R$1000,00
			
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') <> " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			//_cRet += " .AND. E2_VALOR >= 1000"
		Endif
	Endif
ElseIf cEmpAnt $ "G1"     //S๓ irแ ser executado na empresa PARA o Santander
	If cPort240 == "033"  //S๓ executarแ quando o bordero for Santander
		
		If cModPgto =="30"
			_cRet := "SUBSTR(E2_LINDIG,1,3)== '033'"  //Titulo com Boleto Santander
		Elseif cModPgto =="31"
			_cRet := "SUBSTR(E2_LINDIG,1,3)<> '033'"  //Titulo com Boleto de outros bancos
			_cRet += " .AND. !EMPTY(E2_LINDIG)"
		Endif
		
		If cModPgto =="01" //Credito em conta Corrente - Titulo de Fornecedor sem codigo de barra e fornecedor com o mesmo banco
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') == " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			
		Elseif cModPgto =="03" //ted/DOC
			_cRet := "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA,'A2_BANCO') <> " + "'"+ cPort240+"'"
			_cRet += " .AND. EMPTY(E2_LINDIG)"
			//_cRet += " .AND. E2_VALOR < 1000"
		Endif
		
		//FILTRO DE TITULOS DE TRIBUTO
		If cModPgto $ "11/13/16/17/19/21/22/23/24/25/26/27/45/47/91" 
			_cRet := " E2_FORMPAG == " + "'" + cModPgto + "'"
		Endif

	Endif
Endif

RestArea(aArea)

Return (_cRet)

