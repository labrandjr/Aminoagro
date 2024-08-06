#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TMailMng ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 29/11/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Objeto para envio de email.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TMailMng(zEmail, zAssunto, aMensage, zAttach, zCopias, lGrvLog, zCopOcu)

Local oServer
Local oMessage
Local zServer	:= "smtp.office365.com" //Alltrim(GetMv("MV_RELSERV"))
Local zAccount  := AllTrim(GetMV("MV_ZCMSUSR")) // "rh.corporativo@fertilaqua.com" //Alltrim(GetMv("MV_RELAUSR"))
Local zPassword := AllTrim(GetMV("MV_ZCMSPSW")) // "Yoj96429" //Alltrim(GetMv("MV_RELAPSW"))
Local zResult   := "E-mail enviado com sucesso."
Local zBody     := ""
Local zMsgFim   := "Por favor não responda essa mensagem. Esse é um e-mail automático."
Local nInd

If lGrvLog
	zMsgFim += " Em caso de dúvidas, direcionar para rh.corporativo@icl-group.com"
Endif

zBody += '<DIV><FONT face=Arial size=2><IMG alt="" hspace=0 border=0></FONT></DIV>'
zBody += '<DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>'
zBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
zBody += 'size=3><STRONG>TOTVS12 - Serviço de envio de mensagens</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 to Len(aMensage)
	zBody += '<DIV><FONT face=Verdana color=#000080 size=2><SPAN class=216593018-10022004>' + aMensage[nInd] + '</SPAN></FONT></DIV><p>'
Next nInd
zBody += '<DIV><FONT face=Verdana color=#ff0000 size=2><SPAN class=216593018-10022004>' + zMsgFim + '</SPAN></FONT></DIV><p>'

oMessage := TMailMessage():New()

oMessage:Clear()

oMessage:cFrom    := zAccount
oMessage:cTo      := zEmail
oMessage:cCc      := zCopias
oMessage:cBcc     := zCopOcu
oMessage:cSubject := zAssunto
oMessage:cBody    := zBody

If oMessage:AttachFile(zAttach) < 0
	zMsgRet := "Erro ao atachar o arquivo."
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

oServer := TMailManager():New()

oServer:SetUseTLS(.T.)
  
oServer:Init("", zServer, zAccount, zPassword, 0, 587)

zRet := oServer:SetSmtpTimeOut(60)
If zRet != 0
	zMsgRet := "Falha ao setar o time out: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

zRet := oServer:SmtpConnect()
If zRet != 0
	zMsgRet := "Falha ao conectar no servidor de email: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

zRet := oServer:SmtpAuth(zAccount, zPassword)
If zRet != 0
	zMsgRet := "Falha na autenticação do servidor smtp: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif
  
zRet := oMessage:Send(oServer)
If zRet != 0
    zMsgRet := "Erro ao enviar o e-mail: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif
   
zRet := oServer:SmtpDisconnect()
If zRet != 0
	zMsgRet := "Erro ao disconectar do servidor smtp: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif
  
Return(zResult)
