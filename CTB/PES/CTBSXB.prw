#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSXB    ºAutor  ³Donizete            º Data ³  03/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Por uma característica do sistema, pontos de entrada não   º±±
±±º          ³ são disparados quando o usuário cadastra um item a partir  º±±
±±º          ³ de um F3 (Cliente    por exemplo). Neste sentido temos que º±±
±±º          ³ intervir neste processamento e chamar as duas rotinas, ca- º±±
±±º          ³ dastro padrão AXINCLUI e o ponto de entrada. Este programa º±±
±±º          ³ deve ser colocado no SXB, no campo XB_CONTEM no XB_TIPO=3. º±±
±±º          ³ Sintaxe da chamada #U_SA1SXB(parametro)                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ No SXB, campo XB_CONTEM do registro XB_TIPO=="3".         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºData      ³ Alterações                                                 º±±
±±º31/08/07  ³ - Salvo e restaurado área de trabalho ativa.               º±±
±±º          ³                                                            º±±
±±º16/09/07  ³ - Unificado programa para tratar tanto o F3 do Cliente     º±±
±±º          ³quanto Fornecedor. O tratamento é feito através de parâmetroº±±
±±º          ³passado na função (1=Cliente  ou 2=Fornecedor).             º±±
±±º          ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function CTBSXB(_cTipo)

// Declaração das Variáveis.
Local _xArea := Getarea()
Local _xAreaX:= {}

If _cTipo=="1" .Or. _cTipo=="SA1" // Chamada para o cadastro de Clientes
	_xAreaX := SA1->(GetArea())
	If AxInclui("SA1",0,3) == 1 // O usuário incluiu o registro, neste caso o ponto de entrada deve ser executado.
		U_M030INC()
	EndIf
	RestArea(_xAreaX)
	
ElseIf _cTipo=="2" .Or. _cTipo=="SA2" // Chamada para o cadastro de Fornecedores
	_xAreaX := SA2->(GetArea())
	If AxInclui("SA2",0,3) == 1 // O usuário incluiu o registro, neste caso o ponto de entrada deve ser executado.
		U_M020INC()
	EndIf
	RestArea(_xAreaX)
Else
	MsgAlert("ATENÇÃO, parâmetro ref.criação de contas não informado! Conta contábil não será criada.","CTBSXB")
EndIf

// Restaura áreas de trabalho.
RestArea(_xArea)

Return