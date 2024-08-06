#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AGMTKAUT ¦ Autor ¦  Fábrica ERP.BR   ¦    Data  ¦ 10/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração Agrometrika - Autenticação p/Token.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AGMTKAUT(lJob)

Local cUrAgmtk    := AllTrim(GetMv("MV_XAGMURL")) // https://sistema.agrometrikaweb.com.br/APIv2
Local cIdAgmtk    := AllTrim(GetMv("MV_XAGRIDE")) // 64f9c1cb-f490-4375-b9e0-6f474abd738d
Local cChAgmtk    := AllTrim(GetMv("MV_XAGRCHV")) // EjuCYW9fUAk9UNPJyoVMhc74dQc7CZZyNb6SX2AB0a02ljVEKN773OwBmzyhUbM
Local cGetParms   := ""
Local cPostParms  := ' { "ID": "'+cIdAgmtk+'", "Chave": "'+cChAgmtk+'" } '
Local nTimeOut    := 200
Local aHeadStr    := {"Content-Type: application/json"}
Local cHeaderPost := ""
Local cRetorno    := ""
Local oObjJson    := Nil

cUrAgmtk += "/Autenticacao"
cRetorno := HttpPost(cUrAgmtk, cGetParms, cPostParms, nTimeOut, aHeadStr, @cHeaderPost)

If !FWJsonDeserialize(cRetorno, @oObjJson)
	If !lJob
		MsgStop("Erro no retorno HttpPost de autenticação para Token: falha no retorno.")
	Endif	
Else
	If oObjJson:AUTENTICADO
		cToken := oObjJson:TOKEN
		PutMv("MV_XAGMTOK",cToken)
		If __cUserId == "000000"
			If !lJob
				MsgInfo("Autenticação Ok !!"+CHR(13)+CHR(10)+"Novo token: "+cToken)
			Endif	
		Endif
	Else
		If !lJob
			MsgStop("Erro no retorno HttpPost de autenticação para Token: não autenticado.")
		Endif	
	Endif
Endif

Return

// HttpPost(  < cUrl >, [ cGetParms ] , [ cPostParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderGet ] )
