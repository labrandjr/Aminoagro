#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � MMextrat �  Autor � Luis Brandini   �   Data  � 15/11/17   ���
��+----------+------------------------------------------------------------���
���Descricao � M-Messenger envia extrato de premia��o por e-mail.		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MMextrat(zCod,zNome,zEmail,zPdf,zOri,zTipo,zPer,lGrvLog)

Local aArea := GetArea()
Local cAssunto := IIf(Substr(zCod,1,1)=="R","Extrato de Premia��o","Extrato de PLR")+" - "+CapitalAce(zNome)
Local aMensage := {}
Local aAttach  := {}
Local zAttach  := "\premiacao\"+zPdf
Local _x

AAdd(aAttach,"\premiacao\"+zPdf)

If !lGrvLog
	AAdd(aMensage, "Prezado(a)")
	AAdd(aMensage, "")
	AAdd(aMensage, "O presente extrato aqui apresentado possui car�ter meramente indicativo, e deve ser utilizado pelo colaborador apenas para fins informativos e indicativos,")
	AAdd(aMensage, "sendo que, os valores poder�o sofrer altera��es em virtude das premissas estabelecidas no Acordo Coletivo de Trabalho - Programa de Participa��o nos")
	AAdd(aMensage, "Resultados vigente, que disp�e como crit�rio de elegibilidade o atingimento m�nimo de 70% (setenta por cento) da meta anual estabelecida, bem como o")
	AAdd(aMensage, "recebimento dos t�tulos dentro do prazo m�ximo de 360 (trezentos sessenta) dias a contar do vencimento origem. As informa��es n�o constituem qualquer")
	AAdd(aMensage, "tipo de direito l�quido e certo em rela��o ao valor a ser recebido pelo colaborador, n�o devendo ser utilizadas com este prop�sito. O valor efetivo ao qual")
	AAdd(aMensage, "o colaborador ter� direito ao recebimento ser�o confirmados nos per�odos oficiais de apura��o nos meses de janeiro e julho, momento em que receber�")
	AAdd(aMensage, "seu extrato definitivo com os respectivos valores.")
	AAdd(aMensage, "")
	AAdd(aMensage, "Equipe de Administra��o de Vendas.")
	AAdd(aMensage, "")
ElseIf zTipo != "REV"
	AAdd(aMensage, "Prezado(a) "+CapitalAce(zNome))
	AAdd(aMensage, "")
	AAdd(aMensage, "Anexo extrato de apura��o de PLR referente aos receb�veis no per�odo de "+Lower(zPer)+".")
	AAdd(aMensage, "O montante ser� pago atrav�s da folha de pagamento com as devidas reten��es de impostos.")
	AAdd(aMensage, "Aproveitamos a oportunidade para expressar o agradecimento pelo trabalho realizado.")
	AAdd(aMensage, "Seu desempenho � sempre fundamental para conseguirmos atingir o resultado.")
	AAdd(aMensage, "")
	AAdd(aMensage, "Equipe de Administra��o de Vendas.")
	AAdd(aMensage, "")
Else
	AAdd(aMensage, "Prezado(a)")
	AAdd(aMensage, "")
	AAdd(aMensage, "Anexo extrato de apura��o de premia��o conforme solicitado.")
	AAdd(aMensage, "O pagamento ser� efetuado ap�s envio da nota fiscal de servi�os.")
	AAdd(aMensage, "")
	AAdd(aMensage, "Equipe de Administra��o de Vendas.")
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
// ** Envia e-mail para as c�pias informadas          ** //
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
