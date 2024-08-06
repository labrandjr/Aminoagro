#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "totvs.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AMNBOL1   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao e Impressao de Boletos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AMNBOL1()

Local aArea 	:= GetArea()

Local _cFiltrSE1 := ""

Private cNumAlfa := " "
Private cPerg	 := PadR("BOLBCO",10)

If !Pergunte(cPerg,.T.)
	Return
Endif

// ----- Filtra Titulos -----------------------------------
DbSelectArea("SE1")
DbSetOrder(1)
SE1->(DbGotop())

_cFiltrSE1 := 'E1_FILIAL = "' + xFilial("SE1") + '" .And. '
If !Empty(AllTrim(mv_par01))
	_cFiltrSE1 += 'E1_PREFIXO = "' + mv_par01 + '" .And. '
Endif
If !Empty(AllTrim(mv_par02))
	_cFiltrSE1 += 'E1_NUM     = "' + mv_par02 + '" .And. '
Endif
If !Empty(AllTrim(mv_par03))
	_cFiltrSE1 += 'E1_PARCELA = "' + mv_par03 + '" .And. '
Endif
_cFiltrSE1 += 'E1_SALDO > 0 .And. '
_cFiltrSE1 += 'E1_NUMBOR >= "' + mv_par04 + '" .And. E1_NUMBOR <= "' + mv_par05 + '" .And. '
_cFiltrSE1 += 'Substr(E1_TIPO,3,1) != "' + "-" + '" '

Set Filter to &_cFiltrSE1         
Count to _nRecords

DbSelectArea("SE1")
DbSetOrder(1)
SE1->(DbGotop())

If SE1->(Eof())
	MsgAlert("Não foram encontrados registro para essa seleção! Verifique os parâmetros.")    
	Set Filter to
	Return
Endif

ProcRegua(_nRecords)

Processa( { |lEnd| MontaRel()} )

DbSelectArea("SE1")
DbSetOrder(1)
Set filter to

MS_FLUSH()

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MontaRel  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao e Impressao de Boletos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function MontaRel()

Local aDadosEmp  := {}
Local aDadosTit  := {}
Local aDatSacado := {}
Local aBolText   := {}
Local CB_RN_NN   := {}
Local nRec       := 0
Local _nVlrAbat  := 0

Private oFont06  := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
Private oFont07  := TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont07N := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
Private oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont09  := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Private oFont09N := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Private oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont12N := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont14  := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Private oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oFont16  := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
Private oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oFont18  := TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)
Private oFont18N := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
Private oFont20  := TFont():New("Arial",20,20,,.F.,,,,.T.,.F.)
Private oFont20N := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)
Private oPdf
Private aDadosBanco
Private zPathPDF := ""
Private zPdf     := ""

DbSelectArea("SE1")
DbGoTop()
While !EOF()
	nRec+=1
	dbSkip()
EndDo

DbSelectArea("SE1")
DbGoTop()
ProcRegua(nRec)
While !Eof()

	// ----- Posiciona SZI - Parametros Boletos -------------------------------------
	DbSelectArea("SZI")
	DbSetOrder(2) // Banco + Agência + Conta informados no Borderô
	If !DbSeek( xFilial("SZI") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA )
		MsgAlert("Parâmetros Boletos não cadastrado: "+AllTrim(SE1->E1_PORTADO)+"-"+AllTrim(SE1->E1_AGEDEP)+"-"+AllTrim(SE1->E1_CONTA))
		MsgAlert("O processo será interrompido.")
		Return
	Endif
	
	// ----- Posiciona SA6 - Bancos -------------------------------------------------
	DbSelectArea("SA6")
	DbSetOrder(1)
	If !DbSeek( xFilial("SA6") + SZI->ZI_BANCO + Padr(SZI->ZI_AGENCIA,5) + Padr(SZI->ZI_CONTA,10) )
		MsgAlert("Banco nao cadastrado: "+AllTrim(SE1->E1_PORTADO)+"-"+AllTrim(SE1->E1_AGEDEP)+"-"+AllTrim(SE1->E1_CONTA))    
		MsgAlert("O processo será interrompido.")
		Return
	Endif	    
	
	// ----- Posiciona SEE - Parametros Bancos -------------------------------------
	// Aminiagro: Subconta = EC (Envio Cobrança)
	DbSelectArea("SEE")
	DbSetOrder(1)
	If !DbSeek( xFilial("SEE") + SZI->ZI_BANCO + Padr(SZI->ZI_AGENCIA,5) + Padr(SZI->ZI_CONTA,10) + "EC" )
		MsgAlert("Parametros Bancos não cadastrado: "+AllTrim(SE1->E1_PORTADO)+"-"+AllTrim(SE1->E1_AGEDEP)+"-"+AllTrim(SE1->E1_CONTA))
		MsgAlert("O processo será interrompido.")
		Return
	Endif	

	If SZI->ZI_BANCO == "104"
		nRecSM0 := SM0->(Recno())
		DbSelectArea("SM0")
		DbSetOrder(1)
		DbSeek( "G1" + "0101" )
	Endif

	aDadosEmp := { SM0->M0_NOMECOM                                    							,; //[1]Nome da Empresa
	  			   SM0->M0_ENDCOB                                                            	,; //[2]Endereço
				   AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB 	,; //[3]Complemento
				   "CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             	,; //[4]CEP
				   "PABX/FAX: "+SM0->M0_TEL                                                  	,; //[5]Telefones
				   "CNPJ: " + STRZERO(VAL(SEE->EE_XCNPJ),14)     	         					,; //[6]CGC
				   "I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)} //[7]I.E

	If SZI->ZI_BANCO == "104"
		SM0->(DbGoto(nRecSM0))
	Endif

	// ----- Tratamento para Nosso Numero -------------------------------------------
	If Empty(SE1->E1_NUMBCO)

		_cNossoNum := 1 + Val(AllTrim(SEE->EE_FAXATU))
		cDigNN := ""

		If SZI->ZI_BANCO = "237" .And. !( AllTrim(SZI->ZI_NOME) == "BBM" )	// Bradesco
			_cNossoNum	:= StrZero(_cNossoNum,11)
			cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif AllTrim(SZI->ZI_NOME) == "BBM"	// BBM
			_cNossoNum	:= StrZero(_cNossoNum,11)
			cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "001"	// Brasil
			_cNossoNum	:= StrZero(_cNossoNum,10)
			cNumAlfa	:= _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "033"	// Santander
			_cNossoNum	:= StrZero(_cNossoNum,12)
			cNumAlfa	:= _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "212"	// ORIGINAL
			_cNossoNum	:= StrZero(_cNossoNum,10)
			cNumAlfa	:= StrZero(Val(SEE->EE_AGENCIA),4) + AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo10x(cNumAlfa))

		Elseif SZI->ZI_BANCO == "246"	// ABC
			_cNossoNum	:= StrZero(_cNossoNum,10)
			cNumAlfa	:= StrZero(Val(SEE->EE_AGENCIA),4) + AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo10x(cNumAlfa))

		Elseif SZI->ZI_BANCO == "341"	// Itau
			_cNossoNum	:= StrZero(_cNossoNum,8)
			cNumAlfa	:= StrZero(Val(SEE->EE_AGENCIA),4) + StrZero(Val(AllTrim(SEE->EE_CONTA)),5) + AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo10x(cNumAlfa))

		Elseif SZI->ZI_BANCO == "637"	// Sofisa
			_cNossoNum	:= StrZero(_cNossoNum,8)      
			cNumAlfa	:= StrZero(Val(SEE->EE_AGENCIA),4) + StrZero(Val(AllTrim(SEE->EE_CONTA)),5) + AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo10x(cNumAlfa))

		Elseif SZI->ZI_BANCO == "655"	// Votorantin
			_cNossoNum	:= StrZero(_cNossoNum,9)
			cNumAlfa	:= _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "707"	// Daycoval
			_cNossoNum	:= StrZero(_cNossoNum,10)      
			cNumAlfa	:= StrZero(Val(SEE->EE_AGENCIA),4) + SEE->EE_DVAGE + AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo10x(cNumAlfa))

		Elseif SZI->ZI_BANCO == "350" // Athena
			_cNossoNum	:= StrZero(_cNossoNum,11)
			cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "094" // RedAsset
			_cNossoNum	:= StrZero(_cNossoNum,11)
			cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "097" // KS
			_cNossoNum	:= StrZero(_cNossoNum,11)
			cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "611" // Sifra
			_cNossoNum	:= StrZero(_cNossoNum,11)
			cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(modulo11(cNumAlfa))

		Elseif SZI->ZI_BANCO == "104"	// Caixa
			_cNossoNum	:= StrZero(_cNossoNum,15)
			cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
			cDigNN		:= AllTrim(Modulo11x(cNumAlfa))

		Endif

		If Val(AllTrim(_cNossoNum)) > Val(AllTrim(SEE->EE_FAXFIM))
			MsgAlert("O nosso numero esta acima da faixa permitida. Favor rever a faixa no cadastro Parametros Bancos.")
			DbSelectArea("SE1")
			Set Filter to
			Return
		Endif

		RecLock("SEE",.F.)         
		SEE->EE_FAXATU := _cNossoNum
		MsUnlock("SEE")

		RecLock("SE1",.F.)         
		SE1->E1_NUMBCO  := _cNossoNum + cDigNN
		SE1->E1_ZBOLINT := "S"
		MsUnlock("SE1")

	Else	

		_lCorrige := .F.
    	_cNossoNum	:= Substr(SE1->E1_NUMBCO,1,Len(AllTrim(SE1->E1_NUMBCO))-1)

		If SZI->ZI_BANCO = "237" .And. !( AllTrim(SZI->ZI_NOME) == "BBM" )	// Bradesco
			If Len(AllTrim(SE1->E1_NUMBCO)) = 11
		    	_cNossoNum	:= AllTrim(SE1->E1_NUMBCO)
				cNumAlfa	:= AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
				cDigNN		:= AllTrim(modulo11(cNumAlfa))
				_lCorrige   := .T.
			Endif
			cNumAlfa := AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif AllTrim(SZI->ZI_NOME) == "BBM"	// BBM
			cNumAlfa := AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif SZI->ZI_BANCO == "001"	// Brasil
			cNumAlfa := _cNossoNum
		Elseif SZI->ZI_BANCO == "104"	// Caixa
			cNumAlfa := AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif SZI->ZI_BANCO == "033"	// Santander
			cNumAlfa := _cNossoNum
		Elseif SZI->ZI_BANCO == "212"	// ORIGINAL
			cNumAlfa := _cNossoNum
		Elseif SZI->ZI_BANCO == "246"	// ABC
			cNumAlfa := _cNossoNum
		Elseif SZI->ZI_BANCO == "341"	// Itau
			cNumAlfa := StrZero(Val(SEE->EE_AGENCIA),4) + StrZero(Val(AllTrim(SEE->EE_CONTA)),5) + AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif SZI->ZI_BANCO == "637"	// Sofisa
			cNumAlfa := StrZero(Val(SEE->EE_AGENCIA),4) + StrZero(Val(AllTrim(SEE->EE_CONTA)),5) + AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif SZI->ZI_BANCO == "655"	// Votorantin
			If Len(AllTrim(SE1->E1_NUMBCO)) = 9
		    	_cNossoNum	:= AllTrim(SE1->E1_NUMBCO)
				cNumAlfa	:= _cNossoNum
				cDigNN		:= AllTrim(modulo11(cNumAlfa))
				_lCorrige := .T.
			Endif
			cNumAlfa := _cNossoNum
		Elseif SZI->ZI_BANCO == "707"	// Daycoval - Itau
			cNumAlfa := _cNossoNum
		Elseif SZI->ZI_BANCO == "350"	// Athena
			cNumAlfa := AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif SZI->ZI_BANCO == "094"	// RedAsset
			cNumAlfa := AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif SZI->ZI_BANCO == "097"	// KS
			cNumAlfa := AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Elseif SZI->ZI_BANCO == "611"	// Sifra
			cNumAlfa := AllTrim(SZI->ZI_CARTEIR) + _cNossoNum
		Endif

		If _lCorrige
			RecLock("SE1",.F.)         
			SE1->E1_NUMBCO  := _cNossoNum + cDigNN
			SE1->E1_ZBOLINT := "S"
			MsUnlock("SE1")
		Endif

		cDigNN := Substr(SE1->E1_NUMBCO,Len(AllTrim(SE1->E1_NUMBCO)),1)

	Endif

	// ----- Posiciona Cliente ------------------------------------------------------
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)

	DbSelectArea("SE1")
	aDadosBanco  := {AllTrim(SZI->ZI_CODBOL)							,; // [1]Numero do Banco
  					 ""			   	           	                 	    ,; // [2]Nome do Banco
				 	 StrZero(Val(SEE->EE_AGENCIA),4)                  	,; // [3]Agência
	 			 	 AllTrim(SEE->EE_CONTA)								,; // [4]Conta Corrente
				 	 SA6->A6_DVCTA                                      ,; // [5]Dígito da conta corrente
		  		 	 IIF(SE1->E1_SITUACA <> "4","02","09")             	,; // [6]Codigo da Carteira
				 	 SA6->A6_DVAGE                                      ,; // [7]Digito da Agência
				 	 AllTrim(SZI->ZI_CEDENTE)                           ,; // [8]Cedente 
				 	 AllTrim(SZI->ZI_CARTEIR)}							   // [9]Carteira	

	If Empty(SA1->A1_ENDCOB)
       aDatSacado:={AllTrim(SA1->A1_NOME)                           	,; // [1]Razão Social
                    AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	,; // [2]Código
                    AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)	,; // [3]Endereço
                    AllTrim(SA1->A1_MUN )                            	,; // [4]Cidade
                    SA1->A1_EST                                      	,; // [5]Estado
                    SA1->A1_CEP                                      	,; // [6]CEP
                    SA1->A1_CGC}  										   // [7]CGC
	Else
       aDatSacado:={AllTrim(SA1->A1_NOME)                           	,; // [1]Razão Social
                    AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA             	,; // [2]Código
                    AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),; // [3]Endereço
                    AllTrim(SA1->A1_MUNC)	                            ,; // [4]Cidade
                    SA1->A1_ESTC	                                    ,; // [5]Estado
                    SA1->A1_CEPC                                        ,; // [6]CEP
                    SA1->A1_CGC}  										   // [7]CGC
	Endif                

	_nVlrTit	:= 	CalcAbat()
	_nVlrAbat   := 0
	
	// Calcula Codigo de Barras, Linha Digitavel e Nosso Numero
	CB_RN_NN    := Ret_cBarra( 	Substr(aDadosBanco[1],1,3),; // Numero do Banco (sem dígito)
								aDadosBanco[3],; // Agência (sem dígito)
								aDadosBanco[4],; // Conta Corrente
								aDadosBanco[5],; // Dígito da conta corrente
								If(Empty(_cNossoNum),SE1->E1_NUMBCO,_cNossoNum),; // NN
								(_nVlrTit + SE1->E1_ACRESC - SE1->E1_DECRESC),;   // Valor
								aDadosBanco[8],;          // Codigo Cedente
								cDigNN,;                  // Digito do NN
								AllTrim(aDadosBanco[9]) ) // Carteira

	aDadosTit    := {" "+AllTrim(E1_NUM)+" "+AllTrim(E1_PARCELA)			,;  // [1] Número do título
					E1_EMISSAO                              				,;  // [2] Data da emissão do título
					Date()                                  				,;  // [3] Data da impressão do boleto
					E1_VENCREA												,;  // [4] Data do vencimento					
					(_nVlrTit-E1_DECRESC)			                		,;  // [5] Valor do título
 					If(Empty(_cNossoNum),E1_NUMBCO,_cNossoNum) 				,;  // [6] Nosso número
					E1_PREFIXO		                         				,;  // [7] Prefixo da NF
					E1_TIPO	                               					,;  // [8] Tipo do Titulo	
					E1_IRRF		                               				,;  // [9] IRRF 
					E1_ISS	                             					,;  // [10] ISS 
					E1_INSS 	                               				,;  // [11] INSS 
					E1_PIS                                  				,;  // [12] PIS  
					E1_COFINS                               				,;  // [13] COFINS									
					E1_CSLL                               					,;  // [14] CSLL          	
					_nVlrAbat                               				,;  // [15] Abatimentos 
					Round(((_nVlrTit * 0.10)/100),2)						,;  // [16] Mora Diaria
					cDigNN}   													// [17] Digito NN
          
	aBolText := {}

	_vMulta:=((_nVlrTit)*0.001)
	_vMora:=((_nVlrTit)*0.0033)

	AAdd(aBolText, "Nao dispensar juros de mora apos o vencimento.")

	If SZI->ZI_BANCO == "350"
		AAdd(aBolText, "Após o vencimento, cobrar juros de 10,00% a.m.")
	ElseIf SZI->ZI_BANCO == "094"
		AAdd(aBolText, "Após o vencimento cobrar multa de 2,0% e juros de 8,00% a.m.")
	ElseIf SZI->ZI_BANCO == "097"
		AAdd(aBolText, "Após o vencimento, cobrar juros de 12,00% a.m.")
	ElseIf SZI->ZI_BANCO == "611"
		AAdd(aBolText, "Após o vencimento, cobrar juros de 6,00% a.m.")
	Else
		AAdd(aBolText, "Após o vencimento, cobrar juros de 2,5% a.m.")
	Endif	

	If SZI->ZI_BANCO == "637"
		AAdd(aBolText, "Se não pago, enviar para cartório 5 dias corridos após o vencimento.")
	ElseIf SZI->ZI_BANCO == "350"
		AAdd(aBolText, "Se não pago, enviar para cartório 10 dias corridos após o vencimento.")
		AAdd(aBolText, "Após vencimento acesse: www.bradesco.com.br para atualizar seu boleto.")
	ElseIf SZI->ZI_BANCO == "094"
		AAdd(aBolText, "")
		AAdd(aBolText, "Informamos que o titulo representado pelo presente boleto foi objeto de")
		AAdd(aBolText, "cessão entre o(a) <CEDENTE> e o <FUNDO>. Assim, V.Sa. devera efetuar o")
		AAdd(aBolText, "pagamento apenas ao <FUNDO> unico com poder para outorgar quitação ao titulo.")
		AAdd(aBolText, "Contato: (11)3038-5800.") 
		AAdd(aBolText, "")
	ElseIf SZI->ZI_BANCO == "097"
		AAdd(aBolText, "Se não pago, enviar para cartório 3 dias corridos após o vencimento.")
		AAdd(aBolText, "Após vencimento acesse: www.bradesco.com.br para atualizar seu boleto.")
	ElseIf SZI->ZI_BANCO == "611"
		AAdd(aBolText, "Negativar após 5 dias de vencido.")
	ElseIf SZI->ZI_BANCO == "104"
		AAdd(aBolText, "")
		AAdd(aBolText, "SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios).")
		AAdd(aBolText, "Para pessoas com deficiência auditiva ou de fala: 0800 726 2492.")
		AAdd(aBolText, "Ouvidoria: 0800 725 7474.")
		AAdd(aBolText, "caixa.gov.br.*")
	Endif

	If SE1->E1_DESCFIN > 0
		AAdd(aBolText, "Para pagamento até o vencimento conceder desconto no valor de R$ " + AllTrim(Transform(Round(((_nVlrTit * SE1->E1_DESCFIN)/100),2),"@E 999,999.99")))
	Endif

	zPathPDF := AllTrim(mv_par08) + "\"
	zNomeCli := AllTrim(aDatSacado[1])
	zNomeCli := StrTran(zNomeCli,".","")
	zNomeCli := StrTran(zNomeCli,";","")
	zNomeCli := StrTran(zNomeCli,"&","")
	zNomeCli := StrTran(zNomeCli,"/","")
	zNomeCli := StrTran(zNomeCli,"\","")
	zNomeCli := StrTran(zNomeCli,"(","")
	zNomeCli := StrTran(zNomeCli,")","")
	zNomeCli := StrTran(zNomeCli,"{","")
	zNomeCli := StrTran(zNomeCli,"}","")
	zNomeCli := StrTran(zNomeCli,"[","")
	zNomeCli := StrTran(zNomeCli,"]","")
	zNomeCli := StrTran(zNomeCli,"º","")
	zNomeCli := StrTran(zNomeCli,"@","")
	zNomeCli := StrTran(zNomeCli,"%","")
	zNomeCli := StrTran(zNomeCli,"$","")
	zNomeCli := StrTran(zNomeCli,"#","")
	zNomeCli := StrTran(zNomeCli,"!","")
	zNomeCli := StrTran(zNomeCli,"?","")
	zNomeCli := StrTran(zNomeCli,CHR(13),"")
	zNomeCli := StrTran(zNomeCli,CHR(10),"")
	zNomeBco := IIf(AllTrim(SZI->ZI_BANCO)=="637","SOFISA",AllTrim(SZI->ZI_NOME))
	zPdf     := Upper(AllTrim(StrTran(zNomeBco,".",""))) + "-" + SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA) + "-" + Upper(zNomeCli) + ".pdf" 

	oPdf:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@oPdf,,,,, (mv_par07==1) )

	oPdf:SetResolution(72)
	oPdf:SetPortrait()
	oPdf:SetPaperSize(DMPAPER_A4)
	oPdf:SetMargin(60,60,60,60)
	oPdf:cPathPDF := zPathPDF

	ImprPdf(oPdf,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

	oPdf:EndPage()

	cFilePrint := zPathPDF + zPdf

	If mv_par07 == 1
		oPdf:Preview()
	Else
		File2Printer( cFilePrint, "PDF" )
		oPdf:Preview()
	Endif	

	DbSelectArea("SE1")
	SE1->(dbSkip())

	IncProc()

Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ImprPdf   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao e Impressao de Boletos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦--¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ImprPdf(oPdf,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

Local nPosBase	:= 040
Local nBol		:= 1
Local nX
Local nB

oPdf:StartPage()

For nBol := 1 to 2

	If nBol == 2
		nPosBase := 340
		nX := 0
		For nX := 5 To 500 Step 5
			oPdf:Line(nPosBase,nX,nPosBase,nX+2)
		Next nX
		nPosBase := 370
	Endif

	// Logotipo do banco -----------
	aJpeg := GetSrvProfString("STARTPATH","") + "logobol\" + AllTrim(SZI->ZI_LOGO)
	If File(aJpeg)
		oPdf:SayBitmap(nPosBase-005,010,aJpeg,075,014)
	Endif
	// -----------------------------

	oPdf:Line(nPosBase+010,010,nPosBase+010,500)

	//verticais
	oPdf:Line(nPosBase-005,095,nPosBase+010,095)
	oPdf:Line(nPosBase-005,135,nPosBase+010,135)
	oPdf:Line(nPosBase+010,395,nPosBase+235,395)

	oPdf:Say(nPosBase+007,100,AllTrim(SZI->ZI_CODBOL),oFont14N)
	If nBol == 1
		If SZI->ZI_BANCO $ "001,104" // BB / Caixa
			oPdf:Say(nPosBase+007,150,CB_RN_NN[2],oFont10N)
		Endif
		oPdf:Say(nPosBase+007,400,"RECIBO DO PAGADOR",oFont10N)
	Else
		If SZI->ZI_BANCO = "611" // Sifra
			oPdf:Say(nPosBase+007,145,CB_RN_NN[2],oFont12N)
		Else
			oPdf:Say(nPosBase+007,240,CB_RN_NN[2],oFont12N)
		Endif	
	Endif

	oPdf:Say(nPosBase+020,010,"Local de Pagamento",oFont07)
	oPdf:Say(nPosBase+020,400,"Vencimento",oFont07)
	
	If !Empty(AllTrim(SZI->ZI_NOMEB))                                                     
		_cNomeBol := AllTrim(SZI->ZI_NOMEB)
	Else
		_cNomeBol := AllTrim(SZI->ZI_NOME)
	Endif
	
	If SZI->ZI_BANCO $ "212,655"
		oPdf:Say(nPosBase+030,010,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont08N)
	ElseIf SZI->ZI_BANCO $ "001"
		oPdf:Say(nPosBase+030,010,"PAGÁVEL EM QUALQUER BANCO",oFont08N)
	ElseIf SZI->ZI_BANCO $ "094,611"
		oPdf:Say(nPosBase+030,010,"PAGÁVEL PREFERENCIALMENTE NA REDE BRADESCO OU BRADESCO EXPRESSO",oFont08N)
	ElseIf SZI->ZI_BANCO $ "104"
		oPdf:Say(nPosBase+030,010,"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE",oFont08N)
 	Else
		oPdf:Say(nPosBase+030,010,"PAGAR PREFERENCIALMENTE EM AGÊNCIA " + _cNomeBol,oFont08N)
	Endif
	oPdf:Line(nPosBase+035,010,nPosBase+035,500)

	oPdf:Say(nPosBase+045,010,"Beneficiário",oFont07)
	oPdf:Say(nPosBase+045,400,"Agência/Código Beneficiário",oFont07)

	oPdf:Say(nPosBase+070,010,"Data do Documento",oFont07)
	oPdf:Say(nPosBase+070,100,"Número do Documento",oFont07)
	oPdf:Say(nPosBase+070,200,"Espécie Doc.",oFont07)
	oPdf:Say(nPosBase+070,250,"Aceite",oFont07)
	oPdf:Say(nPosBase+070,300,"Data Processamento",oFont07)
	oPdf:Say(nPosBase+070,400,"Nosso Número",oFont07)

	oPdf:Say(nPosBase+095,010,"Uso do Banco",oFont07)
	oPdf:Say(nPosBase+095,100,"Carteira",oFont07)
	oPdf:Say(nPosBase+095,150,"Espécie",oFont07)
	oPdf:Say(nPosBase+095,200,"Quantidade",oFont07)
	oPdf:Say(nPosBase+095,300,"Valor",oFont07)
	oPdf:Say(nPosBase+095,400,"(=)Valor do Documento",oFont07)

	oPdf:Say(nPosBase+120,010,"Mensagens / Instruções (Texto de responsabilidade do beneficiário)",oFont07)
	oPdf:Say(nPosBase+120,400,"(-)Desconto/Abatimento",oFont07)
	oPdf:Line(nPosBase+135,400,nPosBase+135,500)
	oPdf:Say(nPosBase+145,400,"(-)Outras Deduções",oFont07)
	oPdf:Line(nPosBase+160,400,nPosBase+160,500)
	oPdf:Say(nPosBase+170,400,"(+)Mora/Multa/Juros",oFont07)
	oPdf:Line(nPosBase+185,400,nPosBase+185,500)
	oPdf:Say(nPosBase+195,400,"(+)Outros Acréscimos",oFont07)
	oPdf:Line(nPosBase+210,400,nPosBase+210,500)
	oPdf:Say(nPosBase+220,400,"(=)Valor Cobrado",oFont07)

	oPdf:Line(nPosBase+235,010,nPosBase+235,500)
	oPdf:Say(nPosBase+245,010,"Pagador",oFont07)

	If nBol == 2
		oPdf:Say(nPosBase+245,400,"Ficha de Compensação",oFont07)
	Endif

	oPdf:Say(nPosBase+290,010,"Sacador/Avalista",oFont07)
	oPdf:Say(nPosBase+290,400,"Autenticação Mecânica",oFont07)
	oPdf:Line(nPosBase+295,010,nPosBase+295,500)

	// DADOS =======================================================================================
	oPdf:Say(nPosBase+030,400,Dtoc(aDadosTit[4]),oFont08N) // Vencimento

	If AllTrim(SZI->ZI_NOME) == "BBM"
		_cBenef1 := "Banco BOCOM BBM S/A - CNPJ: 15.114.366/0002-40"
		_cBenef2 := "Av. Barão de Tefé, nº 34 - 20º Andar - Bairro: Saúde - Rio de Janeiro - RJ - Cep: 20220-460"
	ElseIf SZI->ZI_BANCO == "350"
		_cBenef1 := "ATLANTA FUNDO INV EM DIR CRED N PAD - CNPJ: 11.468.186/0001-24"
		_cBenef2 := ""
	ElseIf SZI->ZI_BANCO == "094"
		_cBenef1 := "RED S.A – CNPJ 67.915.785/0001-01"
		_cBenef2 := "Av. Cidade Jardim 400 - 14 andar - São Paulo/SP"
	ElseIf SZI->ZI_BANCO == "097"
		_cBenef1 := "FIDC AURUM MULTISSETORIAL LP - CNPJ: 15.653.649/0001-89"
		_cBenef2 := ""
	ElseIf SZI->ZI_BANCO == "611"
		_cBenef1 := "Sifra S/A - CNPJ: 03.729.970/0001-10"
		_cBenef2 := "Rua Doutor Eduardo de Souza Aranha Sala 31, 153, Vila Nova Conceição - São Paulo/SP - Cep: 04543-904"
	Else
		_cBenef1 := AllTrim(aDadosEmp[1]) + "   " + aDadosEmp[6]
		_cBenef2 := AllTrim(aDadosEmp[2]) + " - " + aDadosEmp[3] + " - " + aDadosEmp[4]
	Endif	

	oPdf:Say(nPosBase+045,050,_cBenef1,oFont07N) // Beneficiário
	oPdf:Say(nPosBase+055,050,_cBenef2,oFont07N) // Beneficiário

	If SZI->ZI_BANCO $ "033"     // Santander
		oPdf:Say(nPosBase+055,400,aDadosBanco[3] + "/" + aDadosBanco[8],oFont08N) // Agência/Código Cedente

	ElseIf SZI->ZI_BANCO $ "104" // Caixa
		oPdf:Say(nPosBase+055,400,aDadosBanco[3] + "/" + aDadosBanco[8] + "-5" ,oFont08N) // Agência/Código Cedente

	Elseif SZI->ZI_BANCO = "001" // BB
		oPdf:Say(nPosBase+055,400,aDadosBanco[3] + "/" + aDadosBanco[4] + "-" + aDadosBanco[5],oFont08N) // Agência/Conta/Dg Conta

	Elseif SZI->ZI_BANCO = "655" // Votorantin
		oPdf:Say(nPosBase+055,400,aDadosBanco[8],oFont08N) // Codigo Convenio

	Elseif SZI->ZI_BANCO = "707" // Daycoval
		oPdf:Say(nPosBase+055,400,aDadosBanco[3] + "-" + aDadosBanco[7] + "/" + aDadosBanco[4] + "-" + aDadosBanco[5],oFont08N) // Agência/Dg Ag/Conta/Dg Conta

	Elseif SZI->ZI_BANCO = "611" // Sifra
		oPdf:Say(nPosBase+055,400,aDadosBanco[3] + "-" + aDadosBanco[7] + "/" + StrZero(Val(aDadosBanco[4]),7) + "-" + aDadosBanco[5],oFont08N) // Agência/Dg Ag/Conta/Dg Conta

	Else
		oPdf:Say(nPosBase+055,400,aDadosBanco[3] + "/" + aDadosBanco[4] + "-" + aDadosBanco[5],oFont08N) // Agência/Conta/Dg Conta
	Endif

	oPdf:Line(nPosBase+060,010,nPosBase+060,500)

	// Verticais -------
	oPdf:Line(nPosBase+060,095,nPosBase+110,095)
	oPdf:Line(nPosBase+085,145,nPosBase+110,145)
	oPdf:Line(nPosBase+060,195,nPosBase+110,195)
	oPdf:Line(nPosBase+060,245,nPosBase+085,245)
	oPdf:Line(nPosBase+060,295,nPosBase+110,295)
	// -----------------
	oPdf:Say(nPosBase+080,010,Dtoc(aDadosTit[2]),oFont08N) // Data Documento

	If SZI->ZI_BANCO == "707" // Daycoval
		oPdf:Say(nPosBase+080,100,aDadosTit[1],oFont08N) // Numero+Parcela (Exclusivo DAYCOVAL)
	ElseIf SZI->ZI_BANCO $("094,097,611") // RedAsset, KS, Sifra
		zNum := AllTrim(Substr(aDadosTit[1],1,10))
		zPar := AllTrim(Substr(aDadosTit[1],11))
		zDoc := AllTrim(PadL(Val(zNum),10,""))+"/"+zPar
		oPdf:Say(nPosBase+080,100,zDoc,oFont08N) 
	ElseIf SZI->ZI_BANCO == "350" // Athena
		zNum := AllTrim(Substr(aDadosTit[1],1,10))
		zPar := AllTrim(Substr(aDadosTit[1],11))
		zDoc := AllTrim(PadL(Val(zNum),10,""))+"/"+IIf(Empty(zPar),"01",zPar)
		oPdf:Say(nPosBase+080,100,zDoc,oFont08N) 
	ElseIf SZI->ZI_BANCO == "104" // Caixa
		zNum := AllTrim(Substr(aDadosTit[1],1,10))
		zPar := AllTrim(Substr(aDadosTit[1],11))
		zDoc := zNum + zPar
		oPdf:Say(nPosBase+080,100,zDoc,oFont08N) 
	Else
		oPdf:Say(nPosBase+080,100,(AllTrim(aDadosTit[7]))+aDadosTit[1],oFont08N) // Prefixo+Numero+Parcela
	Endif

	If SZI->ZI_BANCO $("350")
		oPdf:Say(nPosBase+080,200,"DMI",oFont08N) // Especie Doc
	Else
		oPdf:Say(nPosBase+080,200,"DM",oFont08N) // Especie Doc
	Endif

	oPdf:Say(nPosBase+080,250,"N",oFont08N) // Aceite
	oPdf:Say(nPosBase+080,300,Dtoc(aDadosTit[3]),oFont08N) // Data Processamento

	If SZI->ZI_BANCO == "237" .And. !(AllTrim(SZI->ZI_NOME) = "BBM")		// Bradesco
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,11) + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif AllTrim(SZI->ZI_NOME) == "BBM"	// BBM
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,11) + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "001"   // Brasil
		oPdf:Say(nPosBase+080,400, aDadosBanco[8] + aDadosTit[6],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "104"   // Caixa
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + aDadosTit[6] + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, "RG",oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "033"	// Santander
		oPdf:Say(nPosBase+080,400, aDadosTit[6] + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "212"   // ORIGINAL
		oPdf:Say(nPosBase+080,400, aDadosBanco[8] + "/" + aDadosTit[6] + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "246"   // ABC
		oPdf:Say(nPosBase+080,400, aDadosBanco[3] + "9" + "/" + aDadosBanco[9] + "/" + aDadosTit[6] + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "341"	// Itau
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,8) + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "637"	// Sofisa
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,12) + "-" + aDadosTit[17],oFont08N) // Nosso Numero   // Robson - 16/08/19   era tamanho 8
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "655"   // Votorantin
		oPdf:Say(nPosBase+080,400, aDadosTit[6] + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "707"	// Daycoval - Itau
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + aDadosTit[6] + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "350"	// Athena
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,11) + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "094"	// RedAsset
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,11) + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "097"	// KS
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,11) + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Elseif SZI->ZI_BANCO == "611"	// Sifra
		oPdf:Say(nPosBase+080,400, aDadosBanco[9] + "/" + Substr(aDadosTit[6],1,11) + "-" + aDadosTit[17],oFont08N) // Nosso Numero
		oPdf:Say(nPosBase+105,100, aDadosBanco[9],oFont08N) // Carteira

	Endif

	oPdf:Line(nPosBase+085,010,nPosBase+085,500)
	oPdf:Say(nPosBase+105,150,"R$",oFont08N) // Espécie

	oPdf:Say(nPosBase+105,400,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont08N) // Valor do Documento
	oPdf:Line(nPosBase+110,010,nPosBase+110,500)
                                               
	//Informacoes do Titulo
	nLinBol := 135
	For nB := 1 to Len(aBolText)
		oPdf:Say(nPosBase + nLinBol,010,aBolText[nB],oFont08)
		nLinBol += 10
	Next nB

	//Dados Sacado
	If AllTrim(SZI->ZI_NOME) == "BBM"
		oPdf:Say(nPosBase + nLinBol,010,"Crédito cedido ao Banco Bocom BBM S/A",oFont08)
		nLinBol += 10
		oPdf:Say(nPosBase + nLinBol,010,"O pagamento somente poderá ser feito por este boleto",oFont08)

		oPdf:Say(nPosBase+290,080,AllTrim(aDadosEmp[1]) + "   " + aDadosEmp[6],oFont07N)
	Endif

	If SZI->ZI_BANCO == "611" // Sifra
		oPdf:Say(nPosBase + nLinBol,010,"Título Cedido à Sifra S/A",oFont08)
	Endif

	If SZI->ZI_BANCO == "212" // Original
		oPdf:Say(nPosBase + nLinBol,010,"Credito Cedido Fiduc ao Banco Original",oFont08)
	Endif

	If SZI->ZI_BANCO == "246" // ABC
		oPdf:Say(nPosBase + nLinBol,010,"Título transferido a favor do Banco ABC Brasil",oFont08)
	Endif

	If SZI->ZI_BANCO == "350"
		oPdf:Say(nPosBase+290,080,AllTrim(aDadosEmp[1]) + "   " + aDadosEmp[6],oFont07N)
	Endif
	If SZI->ZI_BANCO == "094"
		oPdf:Say(nPosBase+290,080,AllTrim(aDadosEmp[1]) + "   " + aDadosEmp[6],oFont07N)
	Endif
	If SZI->ZI_BANCO == "097"
		oPdf:Say(nPosBase+290,080,AllTrim(aDadosEmp[1]) + "   " + aDadosEmp[6],oFont07N)
	Endif
	If SZI->ZI_BANCO == "611"
		oPdf:Say(nPosBase+290,080,AllTrim(aDadosEmp[1]) + "   " + aDadosEmp[6],oFont07N)
	Endif

	oPdf:Say(nPosBase+255,010,aDatSacado[1],oFont08N)
	If Len(AllTrim(aDatSacado[7])) == 14
		oPdf:Say(nPosBase+255,200,"CNPJ: "+Transform(aDatSacado[7],"@R 99.999.999/9999-99"),oFont08N) // CNPJ
	Else
		oPdf:Say(nPosBase+255,200,"CPF: "+Transform(aDatSacado[7],"@R 999.999.999-99"),oFont08N) // CPF
	EndIf
	oPdf:Say(nPosBase+265,010,aDatSacado[3],oFont08N) // 
	oPdf:Say(nPosBase+275,010,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont08N) // CEP CIDADE ESTADO

Next nBol

// Codigo de Barras - CB_RN_NN[1]
oPdf:Int25(nPosBase+300,10,CB_RN_NN[1],0.80,40,.F.,.F.) 

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Modulo10   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao e Impressao de Boletos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Modulo10(cData) // Modulo 10 Base 9

Local L,D,P := 0
Local B     := .F.
L := Len(cData)
B := .T.
D := 0
do while L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
EndDo

D := 10 - (Mod(D,10))

If D = 10
	D := 0
End

Return(D)
      
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Modulo11  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cálculo do módulo 11 com base 7.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Modulo11(cData)

Local L, D, P := 0

L := Len(cdata)
D := 0
P := 1      
DV:= ""

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P == 7   //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		P := 1
	Endif
	L := L - 1
Enddo                   

_nResto := mod(D,11)  //Resto da Divisao 

D := 11 - _nResto 
            
If _nResto == 1
	DV := "1"
	If !(SZI->ZI_BANCO $ "033/655")
		DV := "P"
	Endif
Elseif _nResto == 0
 	DV := "0"
Else
	DV := AllTrim(Str(D))
Endif

Return(DV)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Modulo11x ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cálculo do módulo 11 com base 9.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Modulo11x(cData)

Local L, D, P := 0

L := Len(cdata)
D := 0
P := 1      
DV:= ""

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P == 9   // Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		P := 1
	Endif
	L := L - 1
Enddo                   

_nResto := mod(D,11)  //Resto da Divisao 

D := 11 - _nResto 

If D > 9
	DV := "0"
Else
	DV := AllTrim(STR(D))
Endif        

Return(DV)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Modulo10x ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cálculo do módulo 10.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Modulo10x(cData)

Local L,D,P,_nResto := 0
Local B := .F.

L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		Endif
	Endif
	D := D + P
	L := L - 1
	B := !B
Enddo
             
_nResto := (Mod(D,10))

If _nResto = 0 
	D:= 0 
Else
	D := 10 - (Mod(D,10))
Endif

If D = 10
	D := 0
Endif
       
D := StrZero(D,1)

Return(D)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Mod11CB   ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cálculo do módulo 11 para código de barras.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Mod11CB(cData) // Modulo 11 com base 9

Local CBL, CBD, CBP := 0
CBL := Len(cdata)
CBD := 0
CBP := 1      

While CBL > 0
	CBP := CBP + 1
	CBD := CBD + (Val(SubStr(cData, CBL, 1)) * CBP)
	If CBP = 9 // Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		CBP := 1
	Endif
	CBL := CBL - 1
Enddo
                   
_nCBResto := mod(CBD,11) // Resto da Divisao 
CBD := 11 - _nCBResto 

If _nCBResto == 0 .Or. _nCBResto == 1 .Or. _nCBResto == 10
	CBD := 1
Endif         

Return(CBD)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ Ret_cBarra¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao e Impressao de Boletos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Retorna os strings para impressão do boleto
CB = String para o cód.barras, RN = String com o número digitável
Cobrança não identificada, número do boleto = Título + Parcela
/*/

Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,cCedente,cDigNN,cCarteira)

Local bldocnufinal := AllTrim(cNroDoc)
Local dvcb         := 0
Local dv           := 0
Local NN           := ''
Local RN           := ''
Local CB           := ''
Local dDtBase	   := CtoD("07/10/97")
Local cFatorVencto := ""

/*
	CB_RN_NN    := Ret_cBarra( 	Substr(aDadosBanco[1],1,3),; // Numero do Banco (sem dígito)
								aDadosBanco[3],; // Agência (sem dígito)
								aDadosBanco[4],; // Conta Corrente
								aDadosBanco[5],; // Dígito da conta corrente
								If(Empty(_cNossoNum),SE1->E1_NUMBCO,_cNossoNum),; // NN
								(_nVlrTit + SE1->E1_ACRESC - SE1->E1_DECRESC),;   // Valor
								aDadosBanco[8],;          // Codigo Cedente
								cDigNN,;                  // Digito do NN
								AllTrim(aDadosBanco[9]) ) // Carteira
*/

// ===== Fator de Vencimento do Boleto ==============================
cFatorVencto := Str(SE1->E1_VENCREA - dDtBase,4)

/*/ ===== BANCO DO BRASIL ===========================================
01 a 03 03 9(03) Código do Banco na Câmara de Compensação = '001'
04 a 04 01 9(01) Código da Moeda = 9 (Real)
05 a 05 01 9(01) Digito Verificador (DV) do código de Barras*
06 a 09 04 9(04) Fator de Vencimento **
10 a 19 10 9(08)V(2) Valor
20 a 44 03 9(03) Campo Livre ***
    Para Convênio de 7 posições
	20 a 25 06 9(6) Zeros
	26 a 42 17 9(17) Convênio e Nosso Número, sem o DV
		26 a 32 9(7) Número do Convênio fornecido pelo Banco (CCCCCCC)
		33 a 42 9(10) Complemento do Nosso-Número, sem DV (NNNNNNNNNN)
	43 a 44 02 9(2) Tipo de Carteira/Modalidade de Cobrança
/*/
// ===== BANCO DO BRASIL ===========================================
If SZI->ZI_BANCO == "001"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := "000000" + cCedente + AllTrim(NN) + cCarteira
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== CAIXA ECONÔMICA ===========================================
If SZI->ZI_BANCO == "104"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cCeden  := AllTrim(STR(Val(cCedente)))
	cDgCed  := AllTrim(Modulo11(cCeden))
	cLivr1  := cCeden + cDgCed + Substr(NN,1,3) + "1" + Substr(NN,4,3) + "4" + Substr(NN,7,9)
	cDgLiv  := AllTrim(Modulo11x(cLivr1))
	cLivre  := cLivr1 + cDgLiv
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO SANTANDER ===========================================
If SZI->ZI_BANCO == "033"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := "9" + cCedente + AllTrim(NN) + cDigNN + "0" + cCarteira
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO ORIGINAL ============================================
If SZI->ZI_BANCO == "212"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + cCedente + NN + cDigNN
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO BRADESCO ============================================
If SZI->ZI_BANCO == "237" .And. !(AllTrim(SZI->ZI_NOME) == "BBM")
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + NN + StrZero(Val(cConta),7) + "0"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)
Endif

// ===== BANCO ABC =================================================
If SZI->ZI_BANCO == "246"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + cCedente + AllTrim(NN) + cDigNN
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO BBM =================================================
If AllTrim(SZI->ZI_NOME) == "BBM"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + NN + StrZero(Val(cConta),7) + "0"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)
Endif

// ===== BANCO ITAU ================================================
If SZI->ZI_BANCO == "341"
	NN		:= bldocnufinal // Nosso Numero sem o digito
    cDac1	:= AllTrim(Str(Modulo10(cAgencia + StrZero(Val(cConta),5) + cCarteira + NN)))
    cDac2	:= AllTrim(Str(Modulo10(cAgencia + StrZero(Val(cConta),5))))
	cLivre  := cCarteira + AllTrim(NN) + cDac1 + cAgencia + StrZero(Val(cConta),5) + cDac2 + "000"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO SOFISA ==============================================
If SZI->ZI_BANCO == "637"
	NN		:= bldocnufinal // Nosso Numero sem o digito
    cDac1	:= AllTrim(Str(Modulo10(cAgencia + StrZero(Val(cConta),5) + cCarteira + NN)))
    cDac2	:= AllTrim(Str(Modulo10(cAgencia + StrZero(Val(cConta),5))))
	cLivre  := cCarteira + AllTrim(NN) + cDac1 + cAgencia + StrZero(Val(cConta),5) + cDac2 + "000"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO VOTORANTIN ==========================================
If SZI->ZI_BANCO == "655"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cCedente + "500" + AllTrim(NN) + cDigNN + "00"
	scb     := "655" + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO DAYCOVAL ============================================
If SZI->ZI_BANCO == "707"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + cCedente + NN + cDigNN
	scb     := "707" + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
Endif

// ===== BANCO ATHENA ==============================================
If SZI->ZI_BANCO == "350"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + NN + StrZero(Val(cConta),7) + "0"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)
Endif

// ===== BANCO REDASSET ============================================
If SZI->ZI_BANCO == "094"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + NN + StrZero(Val(cConta),7) + "0"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)
Endif

// ===== BANCO KS ==================================================
If SZI->ZI_BANCO == "097"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + NN + StrZero(Val(cConta),7) + "0"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)
Endif

// ===== BANCO SIFRA ===============================================
If SZI->ZI_BANCO == "611"
	NN		:= bldocnufinal // Nosso Numero sem o digito
	cLivre  := cAgencia + cCarteira + NN + StrZero(Val(cConta),7) + "0"
	scb     := cBanco + "9" + cFatorVencto + StrZero((nValor*100),10) + cLivre
	dvcb    := Mod11CB(scb)	// digito verificador do codigo de barras
	CB      := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)
Endif

// ===== MONTAGEM DA LINHA DIGITAVEL ================================
srn := cBanco + "9" + Substr(cLivre,1,5)
dv  := modulo10(srn)
RN  := Substr(srn,1,5) + '.' + Substr(srn,6,4)+ AllTrim(Str(dv))+' '

srn := Substr(cLivre,6,10)
dv  := modulo10(srn)      
RN  := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+' '

srn := Substr(cLivre,16,10)
dv  := modulo10(srn)
RN  := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '

RN  := RN + AllTrim(Str(dvcb))+' '      

RN  := RN + cFatorVencto + Strzero((nValor * 100),10)
// ==================================================================

Return({CB,RN,NN}) // Codigo de Barras, Linha Digitável e Nosso Número

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CalcAbat  ¦ Autor ¦  Fábrica ERP.BR   ¦   Data  ¦ 20/01/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Geracao e Impressao de Boletos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function CalcAbat()

_cAlias := Alias()
_nOrder := IndexOrd()
_nReg   := Recno()
_nVlTit := SE1->E1_SALDO

_nAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,Date(),SE1->E1_CLIENTE,SE1->E1_LOJA,xFilial("SE1",SE1->E1_FILORIG),Date(),SE1->E1_TIPO)
If _nAbat != 0
   _nVlTit := _nVlTit-_nAbat
EndIf

dbSetOrder(_nOrder)
DbGoto(_nReg)

Return(_nVlTit)
