#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AGMTKCLI ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 10/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração Agrometrika - Cliente por Cgc/Cpf.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AGMTKCLI(zCgcCli,lTodos)

Local cUrAgmtk   := AllTrim(GetMv("MV_XAGMURL")) // http://homologacao.agrometrikaweb.com.br/APIv2 | https://sistema.agrometrikaweb.com.br/APIv2
Local cTkAgmtk   := AllTrim(GetMv("MV_XAGMTOK")) // Último TOKEN registrado. Duração = 1 hora
Local cGetParms  := ""
Local nTimeOut   := 200
Local aHeadStr   := {"X-Authentication-Token: "+cTkAgmtk}
Local cHeaderGet := ""
Local cRetorno   := ""
Local aRetorno   := {}
Local oObjJson   := Nil

AAdd(aRetorno,0)
AAdd(aRetorno,CtoD(""))

zCgcCli  := IIf(zCgcCli == Nil,"01685057000487",zCgcCli)
cUrAgmtk += "/Cliente/Limite/"+zCgcCli
cRetorno := HttpGet(cUrAgmtk, cGetParms, nTimeOut, aHeadStr, @cHeaderGet)

ConOut("Integracao Agrometrika: "+zCgcCli)

If AT("ExceptionMessage",cRetorno) > 0
	If !lTodos
		MsgStop("Erro no retorno HttpGet de limite cliente:"+CHR(13)+CHR(10)+AllTrim(oObjJson:EXCEPTIONMESSAGE))
	Endif	
	Return
Endif
	
If !FWJsonDeserialize(cRetorno, @oObjJson)
	If !lTodos
		MsgStop("Erro no retorno HttpGet de limite cliente:"+CHR(13)+CHR(10)+"Falha no retorno.")
	Endif	
Else
	If oObjJson:SALVO
		zLimite := oObjJson:LIMITECLIENTE:VALLIMITE
		zVencLc := Substr(oObjJson:LIMITECLIENTE:DATVIGENCIA,1,4)+Substr(oObjJson:LIMITECLIENTE:DATVIGENCIA,6,2)+Substr(oObjJson:LIMITECLIENTE:DATVIGENCIA,9,2)
		zVencLc := StoD(zVencLc)
		aRetorno[1] := zLimite
		aRetorno[2] := zVencLc
		ConOut( "Retorno: Limite "+AllTrim(STR(zLimite,12,2))+" | Vencto.: "+DtoC(zVencLc) )
	Else
		zMsgErro := "Null"
		If ValType(oObjJson:ERROSREQUISICAO) == "A" 
			zMsgErro := AllTrim(oObjJson:ERROSREQUISICAO[1]:CODERRO)+" - "+AllTrim(oObjJson:ERROSREQUISICAO[1]:DESCRICAOERRO)
		Endif	
		If !lTodos
			MsgStop("Erro no retorno HttpGet de limite cliente:"+CHR(13)+CHR(10)+zMsgErro)
		Endif	
	Endif
Endif

Return(aRetorno)

// HttpPost( < cUrl >, [ cGetParms ] , [ cPostParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderGet ] )
// HttpGet(  < cUrl >, [ cGetParms ] , [ nTimeOut ], [ aHeadStr ], [ @cHeaderGet  ] )
// Cliente/Limite/12345678901

/*
Os demais recursos devem sempre levar em sua requisição um cabeçalho HTTP especial com o valor do Token recebido na resposta da autenticação: 
POSThttps://sistema.agrometrika.com.br/api/Cliente HTTP/1.1 
X-Authentication-Token: D4EDEDD9-5654-4835-87FE-34BDAF7DBDBE 
User-Agent: Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36 
Host: sistema.agrometrika.com.br
*/
