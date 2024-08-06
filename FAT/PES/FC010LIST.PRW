#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ FC010LIST ¦ Autor ¦ Luis Brandini   ¦   Data  ¦ 22/08/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Posição de Clientes por CNPJ.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function FC010LIST()

Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aDados   := PARAMIXB
Local zCgcCli  := Substr(SA1->A1_CGC,1,8)
Local zAgrupCr := SA1->A1_ZZAGCRD
Local nMcusto  := Val(GetMv("MV_MCUSTO"))
Local dPRICOM  := CRIAVAR("A1_PRICOM",.F.) 
Local dULTCOM  := CRIAVAR("A1_ULTCOM",.F.) 
Local dDTULCHQ := CRIAVAR("A1_DTULCHQ",.F.)
Local dDTULTIT := CRIAVAR("A1_DTULTIT",.F.)
Local lhabili  := .F.          
Local cRISCO   := ""
Local nLC      := 0
Local nSALDUP  := 0
Local nSALDUPM := 0
Local nLCFIN   := 0
Local nMATR    := 0
Local nSALFIN  := 0
Local nSALFINM := 0
Local nMETR    := 0
Local nMCOMPRA := 0
Local nMSALDO  := 0          
Local nCHQDEVO := 0
Local nTITPROT := 0
Local lAgrpCrd := .F.
Local lAgrpCgc := .F.
Local cAgrupCr := ""
Local cCgcCli  := Substr(SA1->A1_CGC,1,8) // Base do Cgc da Matriz
Local lAgrpLim := (GetMv("MV_AGRPLIM") == "S")

If lAgrpLim // Agrupamento de Crédito = Habilitado

	If SA1->A1_COD == SA1->A1_ZZAGCRD // Agrupamento de Crédito: código do agrupamento preenchido na própria Matriz
		lAgrpCrd := .T.
		cAgrupCr := SA1->A1_ZZAGCRD
	Else
		If !Empty(SA1->A1_ZZAGCRD) // Agrupamento de Crédito: verifica se código do agrupamento preenchido na Filial está correto
			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1")+SA1->A1_ZZAGCRD)
				lAgrpCrd := .T.
				cAgrupCr := SA1->A1_COD
			Endif
		Else // Agrupamento de Crédito: verifica se código do cliente está sendo usado para agrupamento
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SA1")
			cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
			cQuery += " AND A1_ZZAGCRD = '"+SA1->A1_COD+"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL1",.T.,.T.)
			lAgrpCrd := (SQL1->SOMA > 0)
			SQL1->(DbCloseArea())
			If lAgrpCrd
				cAgrupCr := SA1->A1_COD
			Endif	
		Endif
	Endif
	// Se não for agrupamento de crédito, verifica se existe agrupamento pela Base do Cnpj
	If !lAgrpCrd
		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbSeek(xFilial("SA1")+cCgcCli+"0001")
			lAgrpCgc := .T.
		Endif
	Endif

	RestArea(aAreaSA1)

	cQuery := " SELECT A1_LC, A1_SALDUP, A1_SALDUPM, A1_LCFIN, A1_SALFIN, A1_SALFINM, A1_MCOMPRA, A1_MSALDO, A1_RISCO, A1_METR, A1_MATR, A1_ULTCOM, A1_PRICOM, "
	cQuery += " A1_CHQDEVO, A1_TITPROT, A1_DTULCHQ, A1_DTULTIT "
	cQuery += " FROM "+RetSqlName("SA1")
	cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	If lAgrpCrd
		cQuery += " AND ((A1_COD = '"+cAgrupCr+"') OR (A1_ZZAGCRD = '"+cAgrupCr+"')) "
	ElseIf lAgrpCgc
		cQuery += " AND SUBSTR(A1_CGC,1,8) = '"+cCgcCli+"' "
	Else
		cQuery += " AND A1_COD = '"+SA1->A1_COD+"' "
		cQuery += " AND A1_LOJA = '"+SA1->A1_LOJA+"' "
	Endif	
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	DbSelectArea("SQL")
	SQL->(DbGotop())
	While !Eof()
		//
		nLC      += SQL->A1_LC
		nSALDUP  += SQL->A1_SALDUP
		nSALDUPM += SQL->A1_SALDUPM
		nLCFIN   += SQL->A1_LCFIN
		nSALFIN  += SQL->A1_SALFIN
		nSALFINM += SQL->A1_SALFINM
		If nMCOMPRA < SQL->A1_MCOMPRA
			nMCOMPRA := SQL->A1_MCOMPRA
		Endif
		If nMSALDO < SQL->A1_MSALDO
			nMSALDO := SQL->A1_MSALDO
		Endif
		If cRISCO < SQL->A1_RISCO
			cRISCO := SQL->A1_RISCO
		Endif
		If nMETR < SQL->A1_METR
			nMETR := SQL->A1_METR
		Endif
		If nMATR < SQL->A1_MATR
			nMATR := SQL->A1_MATR
		Endif
		If dULTCOM < StoD(SQL->A1_ULTCOM)
			dULTCOM := StoD(SQL->A1_ULTCOM)
		Endif
		If Empty(dPRICOM) .Or. dPRICOM > StoD(SQL->A1_PRICOM)
			dPRICOM := StoD(SQL->A1_PRICOM)
		Endif
		nCHQDEVO += SQL->A1_CHQDEVO
		nTITPROT += SQL->A1_TITPROT
		If dDTULCHQ < StoD(SQL->A1_DTULCHQ)
			dDTULCHQ := StoD(SQL->A1_DTULCHQ)
		Endif
		If dDTULTIT < StoD(SQL->A1_DTULTIT)
			dDTULTIT := StoD(SQL->A1_DTULTIT)
		Endif
        //
		SQL->(DbSkip())
	Enddo
	SQL->(DbCloseArea())

	aDados[1][2] := Transform(Round(Noround(xMoeda(nLC, nMcusto, 1,dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LC",14,1))
	aDados[1][3] := Transform(nLC,PesqPict("SA1","A1_LC",14,nMCusto))
	aDados[1][6] := Space(07)+DtoC(dPRICOM)
	
	aDados[2][2] := Transform(nSALDUP,PesqPict("SA1","A1_SALDUP",14,1) )
	aDados[2][3] := Transform(nSALDUPM,PesqPict("SA1","A1_SALDUPM",14,nMcusto))
	aDados[2][6] := Space(07)+DtoC(dULTCOM)
	
	aDados[3][2] := Transform(Round(Noround(xMoeda(nLCFIN,nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1))
	aDados[3][3] := Transform(nLCFIN,PesqPict("SA1","A1_LCFIN",14,nMcusto))
	aDados[3][6] := Transform(nMATR,PesqPict("SA1","A1_MATR",14))
	
	aDados[4][2] := Transform(nSALFIN,PesqPict("SA1","A1_SALFIN",14,1))
	aDados[4][3] := Transform(nSALFINM,PesqPict("SA1","A1_SALFINM",14,nMcusto))
	aDados[4][6] := PadC(STR(nMETR,7,2),22)
	
	aDados[5][2] := Transform(Round(Noround(xMoeda(nMCOMPRA, nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1))
	aDados[5][3] := Transform(nMCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,nMcusto))
	aDados[5][6] := Space(25)+cRISCO
	
	aDados[6][2] := Transform(Round(Noround(xMoeda(nMSALDO, nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1))
	aDados[6][3] := Transform(nMSALDO,PesqPict("SA1","A1_MSALDO",14,nMcusto))

Endif

RestArea(aArea)

Return(aDados)

/*

PARAMIXB[1][2] - nLC
PARAMIXB[1][3] - nLC
PARAMIXB[1][6] - dPRICOM

PARAMIXB[2][2] - nSALDUP
PARAMIXB[2][3] - nSALDUPM
PARAMIXB[2][6] - dULTCOM

PARAMIXB[3][2] - nLCFIN
PARAMIXB[3][3] - nLCFIN
PARAMIXB[3][6] - nMATR

PARAMIXB[4][2] - nSALFIN
PARAMIXB[4][3] - nSALFINM
PARAMIXB[4][6] - nMETR

PARAMIXB[5][2] - nMCOMPRA
PARAMIXB[5][3] - nMCOMPRA
PARAMIXB[5][6] - cRISCO

PARAMIXB[6][2] - nMSALDO
PARAMIXB[6][3] - nMSALDO

//LIMITE DE CREDITO # PRIMEIRA COMPRA [1]
Aadd(aCols,{STR0014,TRansform(Round(Noround(xMoeda(nLC, nMcusto, 1,dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LC",14,1)),;
			TRansform(nLC,PesqPict("SA1","A1_LC",14,nMCusto)),;
			" ",if(lSigaGE,STR0111,STR0015),SPACE(07)+DtoC(dPRICOM)}) // LIMITE DE CREDITO # Primeira Parcela / Primeira Compra 

//SALDO # ULTIMA COMPRA [2]
Aadd(aCols,{if(lSigaGE,STR0109,STR0010),TRansform(nSALDUP,PesqPict("SA1","A1_SALDUP",14,1) ),;
            TRansform(nSALDUPM,PesqPict("SA1","A1_SALDUPM",14,nMcusto)),;
			" ",if(lSigaGE,STR0112,STR0016),SPACE(07)+DtoC(dULTCOM)}) // Valor Parcelas / Saldo  / Ultima Parcela / Ultima Compra

//Limite de credito secundario # MAIOR ATRASO [3]
Aadd(aCols,{cLcFin,TRansform(Round(Noround(xMoeda(nLCFIN,nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1)),;     
            TRansform(nLCFIN,PesqPict("SA1","A1_LCFIN",14,nMcusto)),;
            " ",STR0017,Transform(nMATR,PesqPict("SA1","A1_MATR",14))}) // Limite sec / Maior Atraso    

//SAldo do limite de credito secundario $ media de Atraso [4]
Aadd(aCols,{cSalFin,TRansform(nSALFIN,PesqPict("SA1","A1_SALFIN",14,1)),;
           TRansform(nSALFINM,PesqPict("SA1","A1_SALFINM",14,nMcusto)),;
           " ",STR0018,PADC(STR(nMETR,7,2),22)}) // Saldo em Cheque / Media de Atraso

//Maior Compra # Grau de risco [5]
Aadd(aCols,{if(lSigaGE,STR0110,STR0011),;
				TRansform(Round(Noround(xMoeda(nMCOMPRA, nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1) ) ,;
				TRansform(nMCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,nMcusto)),;
                " ",STR0019,SPACE(25)+cRISCO}) // Maior Compra / Grau de Risco

//MAior Saldo [6]
Aadd(aCols,{STR0012,;
			TRansform(Round(Noround(xMoeda(nMSALDO, nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1)),;
            TRansform(nMSALDO,PesqPict("SA1","A1_MSALDO",14,nMcusto)),;
            " "," ",""}) //Maior saldo

	nLC      += SA1->A1_LC
	nSALDUP  += SA1->A1_SALDUP
	nSALDUPM += SA1->A1_SALDUPM
	nLCFIN   += SA1->A1_LCFIN       
	nSALFIN  += SA1->A1_SALFIN  
	nSALFINM += SA1->A1_SALFINM              
	If nMCOMPRA < SA1->A1_MCOMPRA
		nMCOMPRA := SA1->A1_MCOMPRA        
	Endif
	If nMSALDO < SA1->A1_MSALDO
		nMSALDO := SA1->A1_MSALDO
	Endif       
	If cRISCO < SA1->A1_RISCO
		cRISCO := SA1->A1_RISCO
	Endif
	If nMETR < SA1->A1_METR 
		nMETR := SA1->A1_METR 
	Endif
	If nMATR < SA1->A1_MATR
		nMATR := SA1->A1_MATR
	Endif                 
   If dULTCOM < SA1->A1_ULTCOM       
		dULTCOM := SA1->A1_ULTCOM       
	Endif
   If Empty(dPRICOM) .Or. dPRICOM > SA1->A1_PRICOM
		dPRICOM :=SA1->A1_PRICOM
	Endif
  	nCHQDEVO += SA1->A1_CHQDEVO
  	nTITPROT += SA1->A1_TITPROT
   If dDTULCHQ < SA1->A1_DTULCHQ
   	dDTULCHQ := SA1->A1_DTULCHQ
   Endif
   If dDTULTIT < SA1->A1_DTULTIT
   	dDTULTIT := SA1->A1_DTULTIT
   Endif

*/
