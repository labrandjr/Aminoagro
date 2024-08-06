#INCLUDE "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "ap5mail.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MailNotify ¦ Autor ¦ ERPBR           ¦   Data  ¦ Fev/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mail                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MailNotify(cTo,cSubject,aMsg,_lRet,aFiles)

Local nInd, cBody  

If GetEnvServer() $("CJXW4M_HOM,CJXW4M_DEV")
	cSubject += " - Ambiente de Teste"
Endif

ConOut(AllTrim(cTo)+" - "+AllTrim(cSubject))

If _lRet
	PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
Endif

If cTo == Nil 
	Return .F.
Endif

If cSubject == Nil 
	cSubject := ""
Endif 

If aMsg == Nil
	aMsg := {}
	AAdd(aMsg, "") 
Endif 

If aFiles == Nil
	aFiles := {}
Endif
       
cBody := ''
cBody += '<DIV><FONT face=Arial size=2><IMG alt="" hspace=0 border=0></FONT></DIV>'
cBody += '<DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>'
cBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
cBody += 'size=3><STRONG>TOTVS12 - Serviço de Envio de Mensagens</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 TO Len(aMsg)
	cBody += '<DIV><FONT face=Verdana color=#000080 size=2><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
Next nInd

zResult := U_GEnvMail(,,,,AllTrim(cTo),AllTrim(cSubject),cBody,aFiles,)

Return(zResult)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GEnvMail   ¦ Autor ¦ ERPBR           ¦   Data  ¦ Fev/2017  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Envio de e-mail                                      	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function GEnvMail(cAccount,cPassword,cServer,cFrom,cEmail,cAssunto,cMensagem,aAttach,cEvento)

Local _aArea 	:= GetArea()
Local lResult	:= .F.
Local zResult   := ""
Local _nCont 	:= 0
Local _aEmail	:= {}
Local _cEmail	:=  ""
Local lAuth 	:= SuperGetMv("MV_RELAUTH",.F.,.F.)
Local cMailMsg  := AllTrim(cEmail)

Default cAccount  := Alltrim(GetMv("MV_RELAUSR"))
Default cPassword := Alltrim(GetMv("MV_RELAPSW"))
Default cServer	  := Alltrim(GetMv("MV_RELSERV"))

Default cFrom	  := Alltrim(GetMv("MV_RELFROM"))
Default cEmail	  := ""
Default cAssunto  := "Servico de Mensagens Fertilaqua"
Default aAttach	  := {}
Default cEvento	  := ""

_lMail  := .F.
_cEmail := ""

For _nCont := 1 To Len(cEmail)
	If (Substr(cEmail,_nCont,1) $ ";,/ ") .Or. ((_nCont == Len(cEmail)) .And. (!Empty(cEmail)))
		If _nCont == Len(cEmail)
			_cEmail += Substr(cEmail,_nCont,1)
        Endif
		If !Empty(_cEmail)
			AAdd(_aEmail,_cEmail)
		Endif
		_cEmail := ""
	Else
		_cEmail += Substr(cEmail,_nCont,1)
	Endif
Next _nCont
	
If Len(_aEmail) > 0

	// Conecta ao Servidor SMTP
	ConOut("*** Envio de e-mail no servidor: " + Alltrim(cServer))
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	
	// Autentica Conta de e-mail caso necessario
	If lAuth
		lOk := MailAuth(cAccount,cPassWord)
	Endif
	
	If !lResult
		_cErro := MailGetErr()
		ConOut("*** Erro: " + _cErro)
		zResult := AllTrim(_cErro)
		DISCONNECT SMTP SERVER
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
		// Autentica conta de e-mail caso necessario
		If lAuth
			lOk := MailAuth(cAccount,cPassWord)
		Endif
	Endif
	
	// Verifica se conectou, caso contrario, exibe o erro e retorna
	If !lResult
		_cErro	:= MailGetErr()
		ConOut("*** Erro: " + _cErro )
		zResult := AllTrim(_cErro)
		DISCONNECT SMTP SERVER
		Return
	EndIf
	
	// Envia o email
	ConOut("*** Enviando E-Mail..: "+AllTrim(cAssunto)+" | Para..: "+cMailMsg)

	lResult := MailSend(cFrom, _aEmail, {" "}, {" "}, Alltrim(cAssunto), cMensagem, aAttach, .F.)	
	
	// Se apresentou erro ao enviar email, exibe-o
	If !lResult
		_cErro	:= MailGetErr()
		ConOut("*** Erro: " + _cErro)
		zResult := AllTrim(_cErro)
	Else
		ConOut("*** E-Mail enviado com sucesso.")
		zResult := "E-Mail enviado com sucesso."
	EndIf
	
	// Desconecta o servidor SMTP
	DISCONNECT SMTP SERVER

Else

	ConOut("*** Não existe lista de e-mails para envio. Contate o Administrador.")
	zResult := "Não existe lista de e-mails para envio."

Endif

RestArea(_aArea)

Return(zResult)
