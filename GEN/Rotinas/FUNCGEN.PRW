#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � FUNCGEN   � Autor �  F�brica ERP.BR   � Data  � 08/06/2021 ���
��+----------+------------------------------------------------------------���
���Descricao � Fun��es Gen�ricas - Todos os m�dulos.					  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

// ********************************************************************************************************** //
// ** Luis Brandini - 08/06/2021
// ********************************************************************************************************** //
// ** Extra��o de detalhes das fun��es do reposit�rio de objetos.											  //
// ********************************************************************************************************** //
User Function ExVerFun()

Local aRet
Local nCount
// Para retornar a origem da fun��o: FULL, USER, PARTNER, PATCH, TEMPLATE ou NONE
Local aType
// Para retornar o nome do arquivo onde foi declarada a fun��o
Local aFile
// Para retornar o n�mero da linha no arquivo onde foi declarada a fun��o
Local aLine
// Para retornar a data da �ltima modifica��o do c�digo fonte compilado
Local aDate
// Para retornar a hora da �ltima modifica��o do c�digo fonte compilado
Local aTime
Local cMasc := "A*"
// Buscar informa��es de todas as fun��es contidas no APO
// tal que tenham a substring 'test' em algum lugar de seu nome
aRet := GetFuncArray(cMasc, aType, aFile, aLine, aDate,aTime)
for nCount := 1 To Len(aRet)
	conout("Funcao " + cValtoChar(nCount) + "= " + aRet[nCount])
	conout("Arquivo " + cValtoChar(nCount) + "= " + aFile[nCount])
	conout("Linha " + cValtoChar(nCount) + "= " + aLine[nCount])
	conout("Tipo " + cValtoChar(nCount) + "= " + aType[nCount])
	conout("Data " + cValtoChar(nCount) + "= " + DtoC(aDate[nCount]))
	conout("Hora " + cValtoChar(nCount) + "= " + aTime[nCount])
	If MsgYesNo("Aborta ?")
		Exit
	Endif
Next nCount

Return

// ********************************************************************************************************** //
// ** Luis Brandini - 08/06/2021
// ********************************************************************************************************** //
// ** Extra��o de detalhes dos fontes do reposit�rio de objetos.											  //
// ********************************************************************************************************** //
User Function ExVerFnt()

Local aFontes := {}
Local nI , nT

aFontes := GetSrcArray("*.PRW")

nT := len(aFontes)
If nT > 0  
	For nI := 1 to nT      
		conout("Fonte "+aFontes[nI]+" encontrado.")  
		If MsgYesNo("Aborta ?")
			Exit
		Endif
	Next nI
	MsgInfo("Fontes encontrados. Verifique log de console.")
Else  
	MsgStop("Nenhum fonte encontrado.")
Endif

// GetApoInfo(cFonte)

Return
