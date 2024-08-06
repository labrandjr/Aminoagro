#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TMailWar ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 14/06/18   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Objeto para envio de email.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TMailWar(zTitulo, zEmail, zAssunto, aMensage)

Local oServer
Local oMessage
Local zServer	:= "smtp.office365.com"
Local zAccount  := Alltrim(GetMv("MV_RELAUSR"))
Local zPassword := Alltrim(GetMv("MV_RELAPSW"))
Local zResult   := "E-mail enviado com sucesso."
Local zBody     := ""
Local zMsgFim   := "Por favor não responda essa mensagem. Esse é um e-mail automático."
Local nInd

zBody += '<DIV><FONT face=Arial size=2><IMG alt="" hspace=0 border=0></FONT></DIV>'
zBody += '<DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>'
zBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
zBody += 'size=3><STRONG>'+zTitulo+'</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 to Len(aMensage)
	zBody += '<DIV><FONT face=Verdana color=#000080 size=2><SPAN class=216593018-10022004>' + aMensage[nInd] + '</SPAN></FONT></DIV><p>'
Next nInd
zBody += '<DIV><FONT face=Verdana color=#ff0000 size=2><SPAN class=216593018-10022004>' + zMsgFim + '</SPAN></FONT></DIV><p>'

oMessage := TMailMessage():New()

oMessage:Clear()

oMessage:cFrom    := zAccount
oMessage:cTo      := zEmail
oMessage:cBcc     := ""
oMessage:cSubject := zAssunto
oMessage:cBody    := zBody

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
