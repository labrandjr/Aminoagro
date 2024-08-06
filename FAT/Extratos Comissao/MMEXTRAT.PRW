#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MMextrat ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 15/11/17   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ M-Messenger envia extrato de premiação por e-mail.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MMextrat(zCod,zNome,zEmail,zPdf,zOri,zTipo,zPer,lGrvLog)

Local aArea := GetArea()
Local cAssunto := IIf(Substr(zCod,1,1)=="R","Extrato de Premiação","Extrato de PLR")+" - "+CapitalAce(zNome)
Local aMensage := {}
Local aAttach  := {}
Local zAttach  := "\premiacao\"+zPdf
Local _x

AAdd(aAttach,"\premiacao\"+zPdf)

If !lGrvLog
	AAdd(aMensage, "Prezado(a)")
	AAdd(aMensage, "")
	AAdd(aMensage, "O presente extrato aqui apresentado possui caráter meramente indicativo, e deve ser utilizado pelo colaborador apenas para fins informativos e indicativos,")
	AAdd(aMensage, "sendo que, os valores poderão sofrer alterações em virtude das premissas estabelecidas no Acordo Coletivo de Trabalho - Programa de Participação nos")
	AAdd(aMensage, "Resultados vigente, que dispõe como critério de elegibilidade o atingimento mínimo de 70% (setenta por cento) da meta anual estabelecida, bem como o")
	AAdd(aMensage, "recebimento dos títulos dentro do prazo máximo de 360 (trezentos sessenta) dias a contar do vencimento origem. As informações não constituem qualquer")
	AAdd(aMensage, "tipo de direito líquido e certo em relação ao valor a ser recebido pelo colaborador, não devendo ser utilizadas com este propósito. O valor efetivo ao qual")
	AAdd(aMensage, "o colaborador terá direito ao recebimento serão confirmados nos períodos oficiais de apuração nos meses de janeiro e julho, momento em que receberá")
	AAdd(aMensage, "seu extrato definitivo com os respectivos valores.")
	AAdd(aMensage, "")
	AAdd(aMensage, "Equipe de Administração de Vendas.")
	AAdd(aMensage, "")
ElseIf zTipo != "REV"
	AAdd(aMensage, "Prezado(a) "+CapitalAce(zNome))
	AAdd(aMensage, "")
	AAdd(aMensage, "Anexo extrato de apuração de PLR referente aos recebíveis no período de "+Lower(zPer)+".")
	AAdd(aMensage, "O montante será pago através da folha de pagamento com as devidas retenções de impostos.")
	AAdd(aMensage, "Aproveitamos a oportunidade para expressar o agradecimento pelo trabalho realizado.")
	AAdd(aMensage, "Seu desempenho é sempre fundamental para conseguirmos atingir o resultado.")
	AAdd(aMensage, "")
	AAdd(aMensage, "Equipe de Administração de Vendas.")
	AAdd(aMensage, "")
Else
	AAdd(aMensage, "Prezado(a)")
	AAdd(aMensage, "")
	AAdd(aMensage, "Anexo extrato de apuração de premiação conforme solicitado.")
	AAdd(aMensage, "O pagamento será efetuado após envio da nota fiscal de serviços.")
	AAdd(aMensage, "")
	AAdd(aMensage, "Equipe de Administração de Vendas.")
	AAdd(aMensage, "")
Endif

zCopias := ""
If !Empty(mv_par09)
	zCopias += AllTrim(mv_par09)
Endif
If !Empty(mv_par10)
	zCopias += IIf(!Empty(zCopias),";","") + AllTrim(mv_par10)
Endif
If !Empty(mv_par11)
	zCopias += IIf(!Empty(zCopias),";","") + AllTrim(mv_par11)
Endif
If !Empty(mv_par12)
	zCopias += IIf(!Empty(zCopias),";","") + AllTrim(mv_par12)
Endif

If __cUserId $( AllTrim(GetMv("MV_EMLPREM")) )
	// Testes
	zEmail  := UsrRetMail(__cUserId)
	zCopOcu := ""
	zResult := U_TMailMng(zEmail, cAssunto, aMensage, zAttach, zCopias, lGrvLog, zCopOcu)
	If lGrvLog
		U_LogPremi(zCod, zNome, zPdf, Lower(PadR(zEmail,80)), zResult, zOri, "P")
	Endif	
Else
	// Producao
	zCopOcu := ""
	If zCod $("D00007,G00031,V00068")
		zUsrParm := AllTrim(GetMv("MV_XUSEMFT"))
		aUsrMail := {}
		zUsrMail := zUsrParm
		If !Empty(zUsrMail)
			nPosic  := 0
			aLinha  := {}
			cTxtLin := zUsrMail
			While (!Empty(cTxtLin))
				If (((nPosic := AT(",",cTxtLin)) > 0))
					AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
					cTxtLin := Stuff(cTxtLin,1,nPosic,"")
				Else
					AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
					cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
				Endif	
			Enddo
			aUsrMail := aClone(aLinha)
		Endif	
		For _x := 1 to Len(aUsrMail)
			zEmlCop := UsrRetMail(aUsrMail[_x])
			If !Empty(zEmlCop)
				nPosic := AT("@",zEmlCop)
				If nPosic > 0
					zCopOcu += IIf(!Empty(zCopOcu),";","") + AllTrim(zEmlCop)
				Endif
			Endif	
		Next _x
	Endif
	zResult := U_TMailMng(zEmail, cAssunto, aMensage, zAttach, zCopias, lGrvLog, zCopOcu)
	If lGrvLog
		U_LogPremi(zCod, zNome, zPdf, Lower(PadR(zEmail,80)), zResult, zOri, "P")
	Endif	
Endif

// ***************************************************** //
// ** Envia e-mail para as cópias informadas          ** //
// ***************************************************** //
If !Empty(mv_par09)
	zEmail := AllTrim(mv_par09)
	U_LogPremi(zCod, zNome, zPdf, Lower(PadR(zEmail,80)), zResult, Lower(PadR(zEmail,80)), "C")
Endif

If !Empty(mv_par10)
	zEmail := AllTrim(mv_par10)
	U_LogPremi(zCod, zNome, zPdf, Lower(PadR(zEmail,80)), zResult, Lower(PadR(zEmail,80)), "C")
Endif

If !Empty(mv_par11)
	zEmail := AllTrim(mv_par11)
	U_LogPremi(zCod, zNome, zPdf, Lower(PadR(zEmail,80)), zResult, Lower(PadR(zEmail,80)), "C")
Endif

If !Empty(mv_par12)
	zEmail := AllTrim(mv_par12)
	U_LogPremi(zCod, zNome, zPdf, Lower(PadR(zEmail,80)), zResult, Lower(PadR(zEmail,80)), "C")
Endif

RestArea(aArea)

Return
