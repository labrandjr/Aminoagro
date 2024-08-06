#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Programa  ¦ SISPAG   ¦ Autor ¦ Robson Assis      ¦ Data ¦  20/02/2021  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Configura layout de Tributos - Sispag (Anexo C).			  ¦¦¦
¦¦¦          ¦ Posicao 018 a 195 - Dados da Identificacao do Tributo.	  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO -     								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/ 

User Function SisPag(cOpcao)

Local nReturn   := 0
Local cAgencia  := " "
Local cNumCC    :=" " 

//Local cDVAgencia:= " "
//Local cDVNumCC  := " "

If cOpcao == "1"    // obter numero de conta e agencia

    cAgencia :=  Alltrim(SA2->A2_AGENCIA)+Alltrim(SA2->A2_DVAGE)

//   If AT("-",cAgencia) > 0
//     cAgencia := Substr(cAgencia,1,AT("-",cAgencia)-1)
//   Endif

    cAgencia := STRTRAN(cAgencia,".","")

// Obtem o digito da agencia

//    cDVAgencia :=  Alltrim(SA2->A2_AGENCIA)
//   If AT("-",cDVAgencia) > 0
//     cDVAgencia := Substr(cDVAgencia,AT("-",cDVAgencia)+1,1)
//   Else
//     cDVAgencia := Space(1)
//   Endif

// Obtem o numero da conta corrente

   cNumCC :=  Alltrim(SA2->A2_NUMCON)
        
//   If AT("-",cNumCC) > 0
//     cNumCC := Substr(cNumCC,1,AT("-",cNumCC)-1)
//   Endif


// obtem o digito da conta corrente

//   cDVNumCC :=  Alltrim(SA2->A2_NUMCON)
//   If AT("-",cDVNumCC) > 0
//     cDVNumCC := Substr(cDVNumCC,AT("-",cDVNumCC)+1,2)
//   Else
//     cDVNumCC := Space(1)
//   Endif
	
	If SA2->A2_BANCO == "341" .OR. SA2->A2_BANCO == "409"  // se for o proprio Itau ou Unibanco- credito em C/C
		
		nReturn:= "0"+cAgencia+space(1)+Replicate("0",6)+strzero(val(cNumCC),6)+space(1)+Alltrim(SA2->A2_DVCTA)
		
	Else  // para os outros bancos - DOC
		
	   	nReturn:= strzero(val(SA2->A2_AGENCIA),5)+space(1)+strzero(val(SA2->A2_NUMCON),12)+space(1)+alltrim(SA2->A2_DVCTA)
		
	EndIf
	
ElseIf cOpcao == "2"  // valor a pagar
	
	_nVlTit:= SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC    
	
	nReturn := Strzero((_nVlTit * 100),15)
	
ElseIf  cOpcao == "3"  // Verifica o DV Geral
	
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,33,1)
	Else
		nReturn:= Substr(SE2->E2_CODBAR,5,1)
	EndIf
	
ElseIf  cOpcao == "4"       // FATOR DE VENCIMENTO
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,34,4)
	Else
		nReturn:= Substr(SE2->E2_CODBAR,6,4)
	EndIf
	
ElseIf  cOpcao == "5"       // Valor constante do codigo de barras
	
  If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nValor := Substr(SE2->E2_CODBAR,38,10)
	Else
		nValor := Substr(SE2->E2_CODBAR,10,10)
  EndIf
		
	nReturn := Strzero(Val(nValor),10)
	
ElseIf  cOpcao == "6"       // Campo Livre
	
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+;
		Substr(SE2->E2_CODBAR,22,10)
	Else
		nReturn := Substr(SE2->E2_CODBAR,20,25)
	EndIf
	
ElseIf cOpcao == "7"  // pagamento de tributos

	If SEA->EA_MODELO $ "16/18" //Darf Normal / Darf Simples

			cTributo	:= Iif(SEA->EA_MODELO=="16","02","03")					//018-019 - 02 = DARF Normal / 03 = DARF Simples
			cCodRec		:= SE2->E2_XCODPAG										//020-023					SE2->E2_CODRET
			cTpInscr 	:= "2"                     			 					//024-024 - 1 = CPF / 2 = CNPJ
			cCNPJ		:= STRZERO(VAL(SE2->E2_XCNPJTR),14)						//025-038	/// StrZero(Val(SM0->M0_CGC),14)
			dPeriodo	:= GravaData(SE2->E2_XPERIOD,.F.,5)						//039-046 - DDMMAAAA		SE2->E2_E_APUR
			cReferen	:= SE2->E2_XREFER										//047-063
			nValorPri	:= IIf(SE2->E2_XVLRPRI > 0, StrZero((SE2->E2_XVLRPRI*100),14), StrZero((SE2->E2_SALDO*100),14) )	//064-077
			nValorMult	:= StrZero((SE2->E2_XMULTA*100),14)						//078-091 - VALOR DA MULTA - 078 a 091 - 9(12)V9(02)					SE2->E2_E_JUROS
			nValorJuros	:= STRZERO(SE2->E2_XJUROS*100,14)						//092-105						E2_E_JUROS
			nValor		:= STRZERO((SE2->E2_SALDO+SE2->E2_ACRESC)*100,14)		//106-119
			dVencto		:= GravaData(SE2->E2_VENCREA,.F.,5)						//120-127 - DDMMAAAA
			dDtPagto	:= GravaData(SE2->E2_VENCREA,.F.,5)						//128-135 - DDMMAAAA
			cBrancos	:= space(30)											//136-165
			cContrib	:= Substr(SM0->M0_NOMECOM,1,30)							//166-195
			
			nReturn:= cTributo + cCodRec +  cTpInscr + (cCNPJ) + dPeriodo + cReferen + (nValorPri)+(nValorMult)+(nValorJuros)+;
							(nValor) + dVencto + dDtPagto + cBrancos + cContrib

	ElseIf SEA->EA_MODELO == "17" // GPS

			cTributo	:= "01"																//018-019 - 01 = GPS	IDENTIFICACAO DO TRIBUTO - 018 a 019 - 9(02)
			cCodRec		:= SE2->E2_XCODPAG													//020-023				CODIGO DE PAGAMENTO - 020 a 023 - 9(04) - NOTA 20
			dPeriodo	:= SE2->E2_XCOMPET													//024-029 			  	MES E ANO DA COMPETENCIA - 024 a 029 - 9(06) - MMAAAA
			cCNPJ		:= STRZERO(VAL(SE2->E2_XCNPJTR),14)	                				//030-043 				IDENTIF.CNPJ/CEI/NIT/PIS DO CONTRIBUINTE - 030 a 043 - 9(14)
			nVlrTri		:= IIf(SE2->E2_XVLRPRE > 0, StrZero((SE2->E2_XVLRPRE*100),14), StrZero((SE2->E2_SALDO*100),14) ) 	//044-057				VALOR PREVISTO DO PAGTO - 044 a 057 - 9(12)V9(02)
			nVlrEnt		:= STRZERO(SE2->E2_XOUTENT*100,14)									//058-071				VALOR DE OUTRAS ENTIDADES - 058 a 071 - 9(12)V9(02)
			nValorMult	:= STRZERO(SE2->E2_XATMONE*100,14)									//072-085				ATUALIZACAO MONETARIA - 072 a 085 - 9(12)V9(02)
			nVlrArrec	:= STRZERO((SE2->E2_SALDO+SE2->E2_ACRESC)*100,14)					//086-099				VALOR ARRECADADO - 086 a 099 - 9(12)V9(02)
			dDtPagto	:= GravaData(SE2->E2_VENCREA,.F.,5)									//100-107 				DATA DA ARRECADACAO/EFETIVACAO DO PAGTO. - 100 a 107 - 9(08) - DDMMAAAA
			cBrancos	:= space(8)															//108-115				COMPLEMENTO DE REGISTRO - 108 a 115 - X(08)
			cInfoComp	:= space(50)														//116-165				INFORMACOES COMPLEMENTARES - 116 a 165 - X(50) - NOTA 21
			cContrib	:= Substr(SM0->M0_NOMECOM,1,30)                    					//166-195				NOME DO CONTRIBUINTE - 166 a 195 - X(30) - NOTA 22

			nReturn:= cTributo + cCodRec + dPeriodo	+ cCNPJ	+ nVlrTri + nVlrEnt + nValorMult + nVlrArrec + dDtPagto	 + cBrancos	+ cInfoComp	+ cContrib

	ElseIf SEA->EA_MODELO == "22" // GARE 													-> Deve-se criar esse modelo 22 - GARE - SP ICMS na tabela 58 do SX5

			cTributo	:= "05"																//018-019 	 			05 = ICMS
			cCodRec		:= SE2->E2_XCODPAG													//020-023				CÓDIGO DA RECEITA
			cTpInscr 	:= "2"                     											//024-024 				1 = CPF / 2 = CNPJ
			cCNPJ		:= STRZERO(VAL(SE2->E2_XCNPJTR),14)									//025-038				CPF OU CNPJ DO CONTRIBUINTE
			aArrayFil   := FWArrFilAtu("G1",SE2->E2_FILIAL)
			cInscrFil   := Substr(aArrayFil[22], 16, AT("_",Substr(aArrayFil[22],16))-1)
			cInsEst		:= StrZero(Val(Substr(cInscrFil,1,12)),12)							//039-050				INSCRIÇÃO ESTADUAL
			cDivAtiv	:= StrZero(Val(SE2->E2_XETIQUE),13) 	 							//051-063     			DIVIDA ATIVA/No.ETIQUETA 		 
			dPeriodo	:= SE2->E2_XCOMPET													//064-069 				MÊS/ANO DE REFERÊNCIA - MMAAAA		STRZERO(MONTH(SE2->E2_XCOMPET),2)+STR(YEAR(SE2->E2_XCOMPET),4)
			cParcNot	:= StrZero(Val(Substr(SE2->E2_XNUMPAR,1,13)),13) 					//070-082    			NUMERO PARCELA/NOTIFICACAO  													
			nVlrRec		:= IIf(SE2->E2_XRECEIT > 0, StrZero((SE2->E2_XRECEIT*100),14), StrZero((SE2->E2_SALDO*100),14) ) 	//083-096				VALOR DA RECEITA	
			nValorJuros	:= STRZERO(SE2->E2_XJUROS*100,14)									//097-110				VALOR DOS JUROS
			nValorMult	:= StrZero((SE2->E2_XMULTA*100),14)									//111-124 				VALOR DA MULTA
			nValor		:= STRZERO((SE2->E2_SALDO*100),14)									//125-138				VALOR DO PAGAMENTO
			dVencto		:= GravaData(SE2->E2_VENCREA,.F.,5)									//139-146 				DATA DE VENCIMENTO - DDMMAAAA
			dDtPagto	:= GravaData(SE2->E2_VENCREA,.F.,5)									//147-154 				DATA DE PAGAMENTO - DDMMAAAA
			cBrancos	:= space(11)														//155-165				COMPLEMENTO DE REGISTRO
			cContrib	:= Substr(SM0->M0_NOMECOM,1,30)										//166-195				NOME DO CONTRIBUINTE
			
			nReturn:= cTributo + cCodRec +  cTpInscr + cCNPJ + cInsEst + cDivAtiv + dPeriodo + cParcNot + nVlrRec + nValorJuros + nValorMult +;
			nValor + dVencto + dDtPagto + cBrancos + cContrib
	Endif
	
	If SEA->EA_MODELO $ "25/27" //25-IPVA  //  27-DPVAT

			cTributo	:= Iif(SEA->EA_MODELO=="25","07","08")					//018-019 - 07 = IPVA   / 08 = DPVAT
			cBranco1	:= space(04)											//020-023 - COMPLEMENTO DE REGISTRO - BRANCOS
			cTpInscr 	:= IIF(SA2->A2_TIPO == "J", "2", "1")  					//024-024 - 1 = CPF / 2 = CNPJ
			cCNPJ		:= STRZERO(VAL(SA2->A2_CGC),14)							//025-038	CPF OU CNPJ DO CONTRIBUINTE
			dAnoBase	:= SUBSTR(DTOS(dDATABASE),1,4)	          				//039-042 - ANO BASE					
			cRenava9 	:= StrZero(SE2->(E2_XRENAV1),09)				   	   	//043-051 - CODIGO RENEVAN 9 DIGITOS
			cUfRenav 	:= SE2->E2_XUFRENA 										//052-053 - UF RENEVAN - (MG / SP)
			cCodMun 	:= IIF(EMPTY(SE2->E2_XCODMUN),PADR(SA2->A2_COD_MUN,05),PADR(SE2->E2_XCODMUN,05))	// SE2->E2_XMUNREN // 054-058 - COD.MUNICIPIO RENEVAN  
			cPlaca 		:= PADR(SE2->E2_XPLACA,07)								//059-065 - PLACA DO VEICULO
			cOpcPaga	:= SE2->E2_XOPCPAG										//066-066 - OPCAO DE PAGAMENTO
			nValorID	:= STRZERO(INT(SE2->E2_XVDIPVA*100),14) 				//067-080 - VALOR DO IPVA + MULTA + JUROS
			nValorDes   := STRZERO(INT(SE2->E2_XDESCON*100),14)					//081-094 - VALOR DO DESCONTO
			nValorPag	:= STRZERO(INT(((SE2->E2_XVLRPRI+SE2->E2_XMULTA+SE2->E2_XJUROS)-SE2->E2_XDESCONT)*100),14)	//095-108 - VALOR DO PAGAMENTO
			dDataVcto	:= GRAVADATA(SE2->E2_VENCREA,.F.,5) 					//109-116 - DATA DE VENCIMENTO
			dDataPago	:= GRAVADATA(SE2->E2_VENCREA,.F.,5) 					//117-124 - DATA DE PAGAMENTO 
			cBranco2 	:= SPACE(29) 								            //125-153 - COMPLEMENTO DE REGISTRO                           
			cRenav12 	:= StrZero(SE2->(E2_XRENAV2),12)						//154-165 - CÓDIGO RENAVAM COM 12 DÍGITOS
			cContrib	:= Substr(SA2->A2_NOME,1,30)							//166-195 - NOME DO CONTRIBUINTE 
			//cContrib += SUBSTR(SA2->A2_NOME,1,30)								//166-195 - NOME DO CONTRIBUINTE 	

			nReturn:= cTributo + cBranco1 +  cTpInscr + cCNPJ + dAnoBase + cRenava9 + cUfRenav + cCodMun+;
					 	cPlaca + cOpcPaga + nValorID + nValorDes + nValorPag + dDataVcto + dDataPago +;
						  cBranco2 + cRenav12 + cContrib

	ElseIf SEA->EA_MODELO == "35" // FGTS-GRF/GRRF/GRDE com código de barras 				-> Deve-se criar esse modelo 35 na tabela 58 do SX5

			cTributo	:= "11"																//018-019 - 11 = FGTS-GRF/GRRF/GRDE com código de barras
			cCodRec		:= SE2->E2_XCODPAG													//020-023 - CODIGO DA RECEITA		SE2->E2_CODRET
			cTpInscr 	:= "1"                     											//024-024 - 1 = CNPJ / 2 = CEI
			cCNPJ		:= FWArrFilAtu("G1",SE2->E2_FILIAL)[18]								//025-038 - CPF OU CNPJ DO CONTRIBUINTE
			cCodbac		:= SE2->E2_CODBAC													//039-086 - Codigo de Barra
			cBranco1	:= space(16)														//087-102 - IDENTIFICADOR DO FGTS
			cBranco2	:= space(9)															//103-111 - LACRE DE CONECTIVIDADE SOCIAL
			cBranco3	:= space(2)															//112-113 - DIGITO DO LACRE DE CONECTIVIDADE SOC.
			cContrib	:= Substr(SM0->M0_NOMECOM,1,30)										//114-143 - NOME DO CONTRIBUINTE
			dDtPagto	:= GravaData(SE2->E2_VENCREA,.F.,5)									//144-151 - DDMMAAAA PAGAMENTO
			nValor		:= STRZERO((SE2->E2_SALDO+SE2->E2_ACRESC)*100,14)					//152-165 - VALOR DO PAGAMENTO
			cBranco4	:= space(30)														//166-195 - COMPLEMENTO DE REGISTRO

					
			nReturn:= cTributo + cCodRec +  cTpInscr + cCNPJ + cCodbac + cBranco1 + cBranco2 + cBranco3 + cContrib + dDtPagto + nValor + cBranco4 

	Endif	

ElseIf  cOpcao == "8"       // Valor nominal
	
  If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nValor := Substr(SE2->E2_CODBAR,38,10)
	Else
		nValor := Substr(SE2->E2_CODBAR,10,10)
  EndIf
  
	If Val(nValor) > 0	
	   nReturn := Strzero(Val(nValor*100),15)
	Else 
		nReturn:= Strzero(SE2->E2_SALDO*100,15)   
    EndIf

ElseIf  cOpcao == "9"       // Fator de Vencimento e Valor pelo codigo de barras opcao 4 e 5 juntas

    //Fator de Vencimento
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,34,4)
	Else
		nReturn:= Substr(SE2->E2_CODBAR,6,4)
	EndIf
	
  //Valor codigo de barras
  If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nValor := Substr(SE2->E2_CODBAR,38,10)
	Else
		nValor := Substr(SE2->E2_CODBAR,10,10)
  EndIf
		
	nReturn := Strzero(Val(nReturn),4)+Strzero(Val(nValor)-0,10)   	                                //Robson  30/04/21
//  nReturn := Strzero(Val(nReturn),4)+Strzero(Val(nValor)-SE2->E2_ACRESC+SE2->E2_DECRESC,10)   	

EndIf

Return(nReturn)     

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Programa  ¦ SISPAG   ¦ Autor ¦ Robson Assis      ¦ Data ¦  20/02/2021  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Busca a virgula no campo de endereco						  ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO      								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/ 

User Function BuscEnd(nOpc)

Local cRet 		:= ""
Local nVirg		:= AT(",",SM0->M0_ENDCOB) 

If nOpc == 1	
	If nVirg > 0
		cRet := SubStr(SM0->M0_ENDCOB,1,nVirg-1)
	EndIf
ElseIf nOpc == 2
	If nVirg > 0
		cRet := Alltrim(SubStr(SM0->M0_ENDCOB,nVirg+1,5))
		cRet := StrZero(Val(cRet),5)
	EndIf
Endif

Return(cRet)     

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Programa  ¦ SISPAG   ¦ Autor ¦ Robson Assis      ¦ Data ¦  20/02/2021  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Busca DIGITO DE AGENCIA 									  ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO      								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/ 

User Function BuscDig(nOpc)

Local cRet 		:= ""
Local nDigAg	:= AT("-",SE2->E2_FAGEDV) 					//SE2->E2_AGE_F
Local nDigCc	:= AT("-",SE2->E2_FCTADV) 					//SE2->E2_CC_F

If nOpc == 1	
	If nDigAg > 0
		cRet := Alltrim(SubStr(SE2->E2_FAGEDV,nDigAg+1,5))			//SE2->E2_AGE_F
		cRet := StrZero(Val(cRet),5)
	EndIf
ElseIf nOpc == 2
	If nDigCc > 0
		cRet := Alltrim(SubStr(SE2->E2_FCTADV,nDigCc+1,5))				//SE2->E2_CC_F
		cRet := StrZero(Val(cRet),5)
	EndIf
Endif

Return(cRet)                         

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Programa  ¦ SISPAG   ¦ Autor ¦ Robson Assis      ¦ Data ¦  20/02/2021  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Busca DIGITO DE CONTA									  ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO      								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/ 

User Function DigSEE(nOpc)

Local cRet 		:= ""
Local cRetIni	:= ""
Local cRetCont	:= ""
Local nPontoCc	:= AT(".",SEE->EE_CONTA)
Local nDigCc	:= AT("-",SEE->EE_CONTA)

If nOpc == 1	
	If nPontoCc > 0
		cRetIni	 := Alltrim(SubStr(SEE->EE_CONTA,nPontoCc-2,2))
		cRetCont := Alltrim(SubStr(SEE->EE_CONTA,nPontoCc+1,3))
		cRet 	 := "0000000"+StrZero(Val(cRetIni+cRetCont),5)
	Else
		cRet := "0000000"+SUBST(SEE->EE_CONTA,1,5)
	EndIf
ElseIf nOpc == 2
	If nDigCc > 0
		cRet := Alltrim(SubStr(SEE->EE_CONTA,nDigCc+1,1))
	EndIf
Endif

Return(cRet)

/*/
____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Programa  ¦ SISPAG   ¦ Autor ¦ Robson Assis      ¦ Data ¦  20/02/2021  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Trailer de Lote - Segmento N - Layout de Tributos.		  ¦¦¦
¦¦¦          ¦ Posicao 024 a 037 - Soma Vlr.Principal dos Pagtos.do Lote. ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO         								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TPRINC()

Local aArea    := GetArea()
Local cRetorno := StrZero(0,14)

DbSelectArea("SE2")
DbSetOrder(1)
DbSeek( SEA->(EA_FILORIG + EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO + EA_FORNECE + EA_LOJA) )

If SE2->E2_XIDTRIB $("1,2,3,4,5,6,7") // TODOS TRIBUTOS
	If SE2->E2_XIDTRIB $("1")
		cQuery := " SELECT SUM(E2_XVLRPRE) AS TOT_TRIB "
		cQuery += " FROM "+RetSqlName("SE2")
		cQuery += " WHERE E2_NUMBOR = '"+SEA->EA_NUMBOR+"' "
		cQuery += " AND E2_XIDTRIB = '1' "
		cQuery += " AND E2_SALDO > 0 "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nSomaBor := SQL->TOT_TRIB
		SQL->(DbCloseArea())
	ElseIf SE2->E2_XIDTRIB $("5")
		cQuery := " SELECT SUM(E2_XRECEIT) AS TOT_TRIB "
		cQuery += " FROM "+RetSqlName("SE2")
		cQuery += " WHERE E2_NUMBOR = '"+SEA->EA_NUMBOR+"' "
		cQuery += " AND E2_XIDTRIB = '5' "
		cQuery += " AND E2_SALDO > 0 "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nSomaBor := SQL->TOT_TRIB
		SQL->(DbCloseArea())
	ElseIf SE2->E2_XIDTRIB $("2,3,4,6,7")	// DARF,DARF SIMPLES,DARJ,IPVA,DPVAT
		cQuery := " SELECT SUM(CASE WHEN E2_XVLRPRI > 0 THEN E2_XVLRPRI ELSE E2_VALOR END) AS TOT_TRIB "
		cQuery += " FROM "+RetSqlName("SE2")
		cQuery += " WHERE E2_NUMBOR = '"+SEA->EA_NUMBOR+"' "
		cQuery += " AND E2_XIDTRIB IN('2','3','4','6','7') "
		cQuery += " AND E2_SALDO > 0 "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nSomaBor := SQL->TOT_TRIB
		SQL->(DbCloseArea())
	Endif
	cRetorno := StrZero((nSomaBor*100),14)
Else
	cRetorno := StrZero(SomaValor(),14)
Endif	

/*
Local nRecSE2  := SE2->(Recno())
Local nOrder   := SE2->(IndexOrd())
Local cBordero := SE2->E2_NUMBOR
Local nSomaBor := 0

If SE2->E2_XIDTRIB $("1,2,3,4") // GPS,DARF,DARF SIMPLES,DARJ
	DbSelectArea("SE2")
	DbSetOrder(15)
	DbSeek( xFilial("SE2") + cBordero )
	While !Eof() .And. SE2->(E2_FILIAL+E2_NUMBOR) == xFilial("SE2") + cBordero
		If SE2->E2_XIDTRIB $("1")
			nSomaBor += SE2->E2_XVLRPRE
		ElseIf SE2->E2_XIDTRIB $("2,3,4")
			nSomaBor += IIf(SE2->E2_XVLRPRI > 0,SE2->E2_XVLRPRI,SE2->E2_VALOR)
		Endif	
		SE2->(DbSkip())
	Enddo
	cRetorno := StrZero((nSomaBor*100),14)
Endif

SE2->(DbGoto(nRecSE2))
SE2->(DbSetOrder(nOrder))
*/

RestArea(aArea)

Return(cRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Programa  ¦ SISPAG   ¦ Autor ¦ Robson Assis      ¦ Data ¦  20/02/2021  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Trailer de Lote - Segmento N - Layout de Tributos.		  ¦¦¦
¦¦¦          ¦ Posicao 038 a 051 - Soma Valores Outras Entidades do Lote. ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO      								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TENTID()

Local aArea    := GetArea()
Local cRetorno := StrZero(0,14)

DbSelectArea("SE2")
DbSetOrder(1)
DbSeek( SEA->(EA_FILORIG + EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO + EA_FORNECE + EA_LOJA) )

If SE2->E2_XIDTRIB == "1" // GPS
	cQuery := " SELECT SUM(E2_XOUTENT) AS TOT_TRIB "
	cQuery += " FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_NUMBOR = '"+SEA->EA_NUMBOR+"' "
	cQuery += " AND E2_XIDTRIB = '1' "
	cQuery += " AND E2_SALDO > 0 "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	nSomaBor := SQL->TOT_TRIB
	SQL->(DbCloseArea())
	cRetorno := StrZero((nSomaBor*100),14)
Endif	

/*
Local nRecSE2  := SE2->(Recno())
Local nOrder   := SE2->(IndexOrd())
Local cBordero := SE2->E2_NUMBOR
Local nSomaBor := 0

If SE2->E2_XIDTRIB == "1" // GPS
	DbSelectArea("SE2")
	DbSetOrder(15)
	DbSeek( xFilial("SE2") + cBordero )
	While !Eof() .And. SE2->(E2_FILIAL+E2_NUMBOR) == xFilial("SE2") + cBordero
		If SE2->E2_XIDTRIB $("1")
			nSomaBor += SE2->E2_XOUTENT
		Endif	
		SE2->(DbSkip())
	Enddo
	cRetorno := StrZero((nSomaBor*100),14)
Endif

SE2->(DbGoto(nRecSE2))
SE2->(DbSetOrder(nOrder))
*/

RestArea(aArea)

Return(cRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ð------------------Ð---------------------------Ð-------------+¦¦
¦¦¦Programa  ¦ SISPAG   ¦ Autor ¦ Robson Assis      ¦ Data ¦  20/02/2021  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Trailer de Lote - Segmento N - Layout de Tributos.		  ¦¦¦
¦¦¦          ¦ Posicao 052 a 065 - Soma Vlrs.Multa,Juros,At.Monet.do Lote.¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO      								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TACRES()

Local aArea    := GetArea()
Local cRetorno := StrZero(0,14)

cQuery := " SELECT SUM(E2_XMULTA+E2_XJUROS+E2_XATMONE) AS TOT_ACRE "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_NUMBOR = '"+SEA->EA_NUMBOR+"' "
cQuery += " AND E2_SALDO > 0 "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nSomaBor := SQL->TOT_ACRE
SQL->(DbCloseArea())
cRetorno := StrZero((nSomaBor*100),14)

/*
Local nRecSE2  := SE2->(Recno())
Local nOrder   := SE2->(IndexOrd())
Local cBordero := SE2->E2_NUMBOR
Local nSomaBor := 0

DbSelectArea("SE2")
DbSetOrder(15)
DbSeek( xFilial("SE2") + cBordero )
While !Eof() .And. SE2->(E2_FILIAL+E2_NUMBOR) == xFilial("SE2") + cBordero
	nSomaBor += (SE2->E2_XMULTA+SE2->E2_XJUROS+SE2->E2_XATMONE)
	SE2->(DbSkip())
Enddo
cRetorno := StrZero((nSomaBor*100),14)

SE2->(DbGoto(nRecSE2))
SE2->(DbSetOrder(nOrder))
*/

RestArea(aArea)

Return(cRetorno)

// ********************************************************************************** //
// Luis Brandini - 23/03/20
// ********************************************************************************** //
// ** Data do agendamentou ou vencimento real no CNAB do título a pagar.		   ** //
// ********************************************************************************** //
User Function VencE2Age()

cRet := IIf( !Empty(SE2->E2_DATAAGE), GRAVADATA(SE2->E2_DATAAGE,.F.,5), GRAVADATA(SE2->E2_VENCREA,.F.,5) )
    
Return(cRet)
