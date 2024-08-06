#include "Protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCOA3105  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 22/03/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Scrip de processamento de lançamentos via Stored Prcedure. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PCOA3105()

Local cProcesso   := ParamIxb[1] //Codigo do processo de lancto
Local cItem       := ParamIxb[2] //item do processo de lancto
Local aRet        := ParamIxb[3] //parametros informados
Local cAliasEntid := ParamIxb[4] //entidade de origem
Local __cProcId   := ParamIxb[5] //nome da procedure de item do lote (AKD_ID)
Local cTipoDB     := Upper(Alltrim(TCGetDB()))
Local lOracle     := "ORACLE" $ cTipoDB
Local lPostgres   := "POSTGRES" $ cTipoDB
Local lDB2        := "DB2" $ cTipoDB
Local lInformix   := "INFORMIX" $ cTipoDB
Local cOpConcat   := IIf( lOracle .Or. lPostgres .Or. lDB2 .Or. lInformix, " || ", " + " )
Local cEOL        := CHR(13)+CHR(10)
Local cCodPla     := "GMD"+Substr(DtoS(dDatabase),1,4)
Local cVersao     := u_UltVerPla(cCodPla)
Local cCposAKD
Local cVarsAKD

ConOut(cProcesso+" | "+cItem+" | "+cAliasEntid)

MsgRun("Aguarde, marcando lançamentos contábeis a DÉBITO...","Processando" ,{|| UpdDebito(aRet) })
MsgRun("Aguarde, marcando lançamentos contábeis a CRÉDITO...","Processando",{|| UpdCredit(aRet) })

MsgInfo("Iniciando integração dos lançamentos via stored procedure."+cEOL+;
		"Aguarde até que o refresh da tela seja restaurado!!")

//----------------------------------------------------------------------------------------------------------------//
// VARIAVEIS DAS ENTIDADES DE ORIGEM SAO PRECEDIDAS DE @+TIPO
// EXEMPLO CAMPO CT2_DATA --> VARIAVEL @cCT2_DATA
//
// VARIAVEIS CARACTERS QUE PODEM SER UTILIZADAS POIS SAO PARAMETRO DA PROCEDURE
// @IN_ENTIDA - ENTIDADE ORIGEM
// @IN_PROCES - CODIGO DO PROCESSO DE LANCAMENTO
// @IN_ITEMPR - ITEM DO PROCESSO DE LANCAMENTO
// @IN_NUMLOTE - NUMERO DO LOTE
// @IN_DATAINI - DATA INICIAL
// @IN_DATAFIM - DATA FINAL
//
// variavel @cId recebe proximo item do lote
// A CADA INSERT DEVE SE COLOCAR A CHAMADA DA PROCEDURE PARA PROXIMO ITEM DO LOTE AKD_ID
// cPE3105 +=" EXEC "+__cProcID+"_"+cEmpAnt+" @IN_NUMLOTE, @cId OutPut "+CRLF
//
// SE POSSUIR 2 INSERTs NO SEGUNDO DEVE INCREMENTAR VARIAVEL @iRecno
// cPE3105 += " select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName("AKD") + CRLF
// cPE3105 += " select @iRecno = @iRecno + 1 "+ CRLF
//
// variavel inteira @nLinCount - controla numero de linhas por transacao MV_PCOLIMI
// SE POSSUIR 2 INSERTs NO SEGUNDO DEVE INCREMENTAR VARIAVEL @nLinCount quando for partida dobrada
// cQuery += " Select @nLinCount = @nLinCount + 1 "+ CRLF

//

//SEMPRE QUE UTILIZAR INSERT DEVE COLOCAR A DIRETIVA TRATARECNO antes do begin tran e colocar FIMTRATARECNO Apos commit tran

//cPE3105 += " ##TRATARECNO @iRecno\ "+ CRLF
//cPE3105 += " begin tran"+CRLF

//

//INSERT.........

//cPE3105 += " commit tran"+CRLF
//cPE3105 += " ##FIMTRATARECNO "+ CRLF
//----------------------------------------------------------------------------------------------------------------//

cPE3105 :=""
cPE3105 +=" select @cId = ' '"+CRLF

cPE3105 +=" if @IN_PROCES = '000082' begin "+CRLF

cCposAKD := "AKD_FILIAL,AKD_STATUS,AKD_LOTE,AKD_ID,AKD_DATA,AKD_CO,AKD_CLASSE,AKD_OPER,AKD_TIPO,AKD_TPSALD,AKD_HIST,AKD_IDREF,AKD_PROCES,AKD_CHAVE,AKD_ITEM,AKD_SEQ,AKD_USER,AKD_COSUP,AKD_VALOR1,AKD_VALOR2,AKD_VALOR3,AKD_VALOR4,AKD_VALOR5,AKD_CODPLA,AKD_VERSAO,AKD_CC,AKD_ITCTB,AKD_CLVLR,AKD_LCTBLQ,AKD_UNIORC,AKD_FILORI,D_E_L_E_T_,R_E_C_N_O_,R_E_C_D_E_L_"

//variaveis debito
//cVarsAKD := "@cFil_AKD,'1' ,@IN_NUMLOTE,@cId,@cCT2_DATA,"+IF(cTipoDB$"MSSQL7","RTRIM","TRIM")+"(@cCT2_DEBITO),'000001',' ','2','RE','CONTABILIDADE DEBITO PARA AKD',' ' ,@IN_PROCES,@cCT2_FILIAL"+cOpConcat+"@cCT2_DATA"+cOpConcat+"@cCT2_LOTE"+cOpConcat+"@cCT2_SBLOTE"+cOpConcat+"@cCT2_DOC"+cOpConcat+"@cCT2_LINHA"+cOpConcat+"@cCT2_TPSALD"+cOpConcat+"@cCT2_EMPORI"+cOpConcat+"@cCT2_FILORI"+cOpConcat+"@cCT2_MOEDLC,@IN_ITEMPR,'01','"+__cUserId+"',' ',@nCT2_VALOR,0,0,0,0,' ',' ',@cCT2_CCD,@cCT2_ITEMD,@cCT2_CLVLDB,' ',' ','"+cFilAnt+"',' ',@iRecno,0"
cVarsAKD := "@cFil_AKD,'1' ,@IN_NUMLOTE,@cId,@cCT2_DATA,"+IF(cTipoDB$"MSSQL7","RTRIM","TRIM")+"(@cCT2_DEBITO),'000001','1','1','RE',@cCT2_HIST,' ',@IN_PROCES,@cCT2_FILIAL"+cOpConcat+"@cCT2_DATA"+cOpConcat+"@cCT2_LOTE"+cOpConcat+"@cCT2_SBLOTE"+cOpConcat+"@cCT2_DOC"+cOpConcat+"@cCT2_LINHA"+cOpConcat+"@cCT2_TPSALD"+cOpConcat+"@cCT2_EMPORI"+cOpConcat+"@cCT2_FILORI"+cOpConcat+"@cCT2_MOEDLC,@IN_ITEMPR,'01','"+__cUserId+"',' ',@nCT2_VALOR,0,0,0,0,'"+cCodPla+"','"+cVersao+"',@cCT2_CCD,@cCT2_ITEMD,@cCT2_CLVLDB,' ','"+cFilAnt+"','"+cFilAnt+"',' ',@iRecno,0"  // Luis Brandini

cPE3105 +=" if @cCT2_DC = '3' OR @cCT2_DC = '1' begin "+CRLF
cPE3105 +=" if ( (SUBSTR(@cCT2_DEBITO,1,1) = '4') OR (@cCT2_DEBITO = '31199007') OR (@cCT2_DEBITO = '31199008') OR (@cCT2_DEBITO = '31199009') OR (@cCT2_DEBITO = '31199011') OR (@cCT2_DEBITO = '31199012') OR (@cCT2_DEBITO = '31199013') ) "+CRLF // Luis Brandini
cPE3105 +=" AND @cCT2_TPSALD = '1' AND @cCT2_ZPCOD = 'S' AND @cCT2_HP <> '999' AND SUBSTR(@cCT2_HIST,1,9) <> 'Zeramento' begin "+CRLF // Luis Brandini

cPE3105 += " select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName("AKD") + CRLF
cPE3105 += " select @iRecno = @iRecno + 1 "+ CRLF

cPE3105 +=" EXEC "+__cProcID+"_"+cEmpAnt+" @IN_NUMLOTE, @cId OutPut "+CRLF

cPE3105 += " ##TRATARECNO @iRecno\ "+ CRLF
cPE3105 += " begin tran"+CRLF

cPE3105 += " INSERT INTO "+RetSqlName("AKD") +" ("+cCposAKD+")"+ CRLF 
cPE3105 += " VALUES ("+cVarsAKD+")" + CRLF
cPE3105 += " commit tran"+CRLF
cPE3105 += " ##FIMTRATARECNO "+ CRLF
cPE3105 += " end "+ CRLF // if SUBSTR(@cCT2_DEBITO,1,1) = '4' AND @cCT2_TPSALD = '1' AND @cCT2_ZPCOD = 'S' 
cPE3105 += " end "+ CRLF // if @cCT2_DC = '3' OR @cCT2_DC = '1' 

cPE3105 +=" if @cCT2_DC = '3' OR @cCT2_DC = '2' begin "+CRLF
cPE3105 +=" if ( (SUBSTR(@cCT2_CREDIT,1,1) = '4') OR (@cCT2_CREDIT = '31199007') OR (@cCT2_CREDIT = '31199008') OR (@cCT2_CREDIT = '31199009') OR (@cCT2_CREDIT = '31199011') OR (@cCT2_CREDIT = '31199012') OR (@cCT2_CREDIT = '31199013') ) "+CRLF // Luis Brandini
cPE3105 +=" AND @cCT2_TPSALD = '1' AND @cCT2_ZPCOC = 'S' AND @cCT2_HP <> '999' AND SUBSTR(@cCT2_HIST,1,9) <> 'Zeramento' begin "+CRLF // Luis Brandini

cPE3105 += " if @cCT2_DC = '3' begin Select @nLinCount = @nLinCount + 1 end "+ CRLF

cPE3105 += " select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName("AKD") + CRLF
cPE3105 += " select @iRecno = @iRecno + 1 "+ CRLF

cPE3105 +=" EXEC "+__cProcID+"_"+cEmpAnt+" @IN_NUMLOTE, @cId OutPut "+CRLF

//variaveis credito
//cVarsAKD := "@cFil_AKD,'1' ,@IN_NUMLOTE,@cId,@cCT2_DATA,"+IF(cTipoDB$"MSSQL7","RTRIM","TRIM")+"(@cCT2_CREDIT),'000001',' ','1','RE','CONTABILIDADE CREDITO PARA AKD',' ' ,@IN_PROCES,@cCT2_FILIAL"+cOpConcat+"@cCT2_DATA"+cOpConcat+"@cCT2_LOTE"+cOpConcat+"@cCT2_SBLOTE"+cOpConcat+"@cCT2_DOC"+cOpConcat+"@cCT2_LINHA"+cOpConcat+"@cCT2_TPSALD"+cOpConcat+"@cCT2_EMPORI"+cOpConcat+"@cCT2_FILORI"+cOpConcat+"@cCT2_MOEDLC,@IN_ITEMPR,'01','"+__cUserId+"',' ',@nCT2_VALOR,0,0,0,0,' ',' ',@cCT2_CCC,@cCT2_ITEMC,@cCT2_CLVLCR,' ',' ','"+cFilAnt+"',' ',@iRecno,0"
cVarsAKD := "@cFil_AKD,'1' ,@IN_NUMLOTE,@cId,@cCT2_DATA,"+IF(cTipoDB$"MSSQL7","RTRIM","TRIM")+"(@cCT2_CREDIT),'000001','1','2','RE',@cCT2_HIST,' ' ,@IN_PROCES,@cCT2_FILIAL"+cOpConcat+"@cCT2_DATA"+cOpConcat+"@cCT2_LOTE"+cOpConcat+"@cCT2_SBLOTE"+cOpConcat+"@cCT2_DOC"+cOpConcat+"@cCT2_LINHA"+cOpConcat+"@cCT2_TPSALD"+cOpConcat+"@cCT2_EMPORI"+cOpConcat+"@cCT2_FILORI"+cOpConcat+"@cCT2_MOEDLC,@IN_ITEMPR,'01','"+__cUserId+"',' ',@nCT2_VALOR,0,0,0,0,'"+cCodPla+"','"+cVersao+"',@cCT2_CCC,@cCT2_ITEMC,@cCT2_CLVLCR,' ','"+cFilAnt+"','"+cFilAnt+"',' ',@iRecno,0" // Luis Brandini

cPE3105 += " ##TRATARECNO @iRecno\ "+ CRLF
cPE3105 += " begin tran"+CRLF

cPE3105 += " INSERT INTO "+RetSqlName("AKD")+" ("+cCposAKD+")"+ CRLF 
cPE3105 += " VALUES ("+cVarsAKD+")" + CRLF
cPE3105 += " commit tran"+CRLF
cPE3105 += " ##FIMTRATARECNO "+ CRLF

cPE3105 += " end "+ CRLF // if SUBSTR(@cCT2_CREDIT,1,1) = '4' AND @cCT2_TPSALD = '1' AND @cCT2_ZPCOC = 'S'
cPE3105 += " end "+ CRLF // if @cCT2_DC = '3' OR @cCT2_DC = '2' 

cPE3105 += " end "+ CRLF //finaliza if @IN_PROCES = '000082'

Return(cPe3105)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdDebito ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 11/04/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualiza lançamentos contábeis onde a conta débito está	  ¦¦¦
¦¦¦          ¦ relacionada no SIGAPCO - Contas Orçamentárias.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function UpdDebito(aRet)

cQuery := " UPDATE "+RetSqlName("CT2")
cQuery += " SET CT2_ZPCOD = 'S' "
cQuery += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
cQuery += " AND ( (SUBSTR(CT2_DEBITO,1,1) = '4') OR (CT2_DEBITO = '31199007') OR (CT2_DEBITO = '31199008') OR (CT2_DEBITO = '31199009') OR (CT2_DEBITO = '31199011') OR (CT2_DEBITO = '31199012') OR (CT2_DEBITO = '31199013') ) "
cQuery += " AND CT2_TPSALD = '1' "
cQuery += " AND CT2_ZPCOD = ' ' "
cQuery += " AND CT2_HP <> '999' "
cQuery += " AND SUBSTR(CT2_HIST,1,9) <> 'Zeramento' "
cQuery += " AND CT2_DATA BETWEEN '"+DtoS(aRet[4])+"' AND '"+DtoS(aRet[5])+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " AND CT2_DEBITO IN "
cQuery += " (SELECT AK5_CODIGO FROM "+RetSqlName("AK5")+" WHERE D_E_L_E_T_ <> '*') "
TCSQLEXEC(cQuery)

cQuery := " COMMIT "
TCSQLEXEC(cQuery)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UpdCredit ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ 11/04/19  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualiza lançamentos contábeis onde a conta crédito está	  ¦¦¦
¦¦¦          ¦ relacionada no SIGAPCO - Contas Orçamentárias.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function UpdCredit(aRet)

cQuery := " UPDATE "+RetSqlName("CT2")
cQuery += " SET CT2_ZPCOC = 'S' "
cQuery += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
cQuery += " AND ( (SUBSTR(CT2_CREDIT,1,1) = '4') OR (CT2_CREDIT = '31199007') OR (CT2_CREDIT = '31199008') OR (CT2_CREDIT = '31199009') OR (CT2_CREDIT = '31199011') OR (CT2_CREDIT = '31199012') OR (CT2_CREDIT = '31199013') ) "
cQuery += " AND CT2_TPSALD = '1' "
cQuery += " AND CT2_ZPCOC = ' ' "
cQuery += " AND CT2_HP <> '999' "
cQuery += " AND SUBSTR(CT2_HIST,1,9) <> 'Zeramento' "
cQuery += " AND CT2_DATA BETWEEN '"+DtoS(aRet[4])+"' AND '"+DtoS(aRet[5])+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " AND CT2_CREDIT IN "
cQuery += " (SELECT AK5_CODIGO FROM "+RetSqlName("AK5")+" WHERE D_E_L_E_T_ <> '*') "
TCSQLEXEC(cQuery)

cQuery := " COMMIT "
TCSQLEXEC(cQuery)

Return
