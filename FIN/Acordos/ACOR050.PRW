#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR050   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Movimentações do acordo.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR050(cModoVis)

Private yCadastro := cCadastro
Private yCores    := aCores
Private yCoresLeg := aCoresLeg
Private yRotina   := aRotina
Private yLegenda  := cLegenda
Private cEOL      := CHR(13)+CHR(10) 

Private cCadastro := "Movimentações do Acordo | "+Z01->Z01_ACORDO+" | "+Posicione("SA1",1,xFilial("SA1")+Z01->Z01_CLIENT,"A1_NOME")

Private aCores := {{"E5_TIPODOC <> 'ES'" , "BR_VERDE" },;
				   {"E5_TIPODOC == 'ES'" , "BR_PRETO" }}

Private aCoresLeg := {{"BR_VERDE" , "Recebido"  },;
					  {"BR_PRETO" , "Cancelado" }}

Private aRotina := {{"Visualizar" , "AxVisual" , 0 , 6 },;
					{"Legenda"    , "BrwLegenda(cCadastro,cLegenda,aCoresLeg)" , 0 , 10 }}

Private cLegenda  := "Legenda"

Private yCondicao := ""

If cModoVis == "A" // Visualiza todas as movimentações do acordo
	yCondicao := "E5_PREFIXO == 'ACO' .And. E5_NUMERO == '"+Z01->Z01_ACORDO+"' "
Else // Visualiza as movimentações da parcela do acordo
	yCondicao := "E5_PREFIXO == 'ACO' .And. E5_NUMERO == '"+SE1->E1_NUM+"' .And. E5_PARCELA == '"+SE1->E1_PARCELA+"' "
Endif

DbSelectArea("SE5")
DbSetOrder(1)
Set Filter to &yCondicao
SE5->(DbGotop())
MBrowse(6,1,22,75,"SE5",,,,,,aCores)

DbSelectArea("SE5")
DbSetOrder(1)
Set Filter to

cCadastro := yCadastro
aCores    := yCores
aCoresLeg := yCoresLeg
aRotina   := yRotina
cLegenda  := yLegenda

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR05E   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Chamada: exclusão da movimentação da parcela do acordo.	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR05E()
/* (Função Desativada)
nRecZ05 := Z05->(Recno())
z05Acor := Z05->Z05_ACORDO
z05Parc := Z05->Z05_PARC
z05Sequ := Z05->Z05_SEQ

Z05->(DbSetOrder(1))
lCancOk := ( Z05->(DbSeek( xFilial("Z05") + z05Acor + z05Parc + z05Sequ + "ES" )) )
Z05->(DbGoto(nRecZ05))

If Z05->Z05_TIPDOC == "ES"
	MsgAlert("Movimento de cancelamento não pode ser excluído.")
	Return
Endif

If lCancOk
	MsgAlert("Este movimento encontra-se cancelado.")
	Return
Endif

If Z05->Z05_DATA < GetMv("MV_DATAFIN")
	MsgAlert("Data limite p/ realização de operações financeiras: "+DtoC(GetMv("MV_DATAFIN")))
	lRetorno := .F.
Endif

If MsgYesNo("Confirma exclusão da movimentação selecionada ?","Aviso","INFO")
	MsgRun("Excluindo movimentações... aguarde","Processando",{|| _ExcBxAc() })
Endif
*/
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ _ExcBxAc  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Execução: exclusão da movimentação da parcela do acordo.	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _ExcBxAc()
/* (Função Desativada)
Private aDelZE5 := {}
Private lProcOk := .T.
Private lMsErroAuto := .F.

Begin Transaction

// 1. Exclui as movimentações nos títulos a receber pertencentes ao acordo - integração com módulo financeiro
DbSelectArea("ZE5")
DbSetOrder(1)
DbSeek( Z05->(Z05_FILIAL+Z05_ACORDO+Z05_PARC+Z05_SEQ) )
While !Eof() .And. ZE5->(ZE5_FILIAL+ZE5_ACORDO+ZE5_PARC+ZE5_SEQ) == Z05->(Z05_FILIAL+Z05_ACORDO+Z05_PARC+Z05_SEQ)

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( ZE5->(ZE5_FILIAL+ZE5_PREFIX+ZE5_NUMERO+ZE5_PARTIT+ZE5_TIPO+ZE5_CLIENT) )

	nSalvRec  := SE1->(Recno())
	nSaldo    := 0
    aBaixa    := {}
    aBaixaSE5 := {}
    aBaixa    := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,SE1->E1_TIPO,,,SE1->E1_CLIENTE,SE1->E1_LOJA,@nSaldo,,,)
    SE1->( DbGoto( nSalvRec ) )
	nQualBx := aScan(aBaixaSE5, {|x| x[9] == ZE5->ZE5_SEQSE5 })

	If nQualBx > 0

		aBaixa := { {"E1_PREFIXO"  , SE1->E1_PREFIXO , Nil},;
					{"E1_NUM"	   , SE1->E1_NUM     , Nil},; 
					{"E1_PARCELA"  , SE1->E1_PARCELA , Nil},;
					{"E1_TIPO"	   , SE1->E1_TIPO    , Nil},;
					{"E1_CLIENTE"  , SE1->E1_CLIENTE , Nil},;
					{"E1_LOJA"	   , SE1->E1_LOJA    , Nil} }

		lMsErroAuto := .F.
		MSExecAuto({|x,w,y,z| FINA070(x,w,y,z)},aBaixa,6,,nQualBx)

		If !lMsErroAuto
			AAdd(aDelZE5,ZE5->(Recno()))
		Else
			lProcOk := .F.
			DisarmTransaction()
			MostraErro()
			MsgAlert("Falha na exclusão da baixa:"+cEOL+;
			"Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+cEOL+;
			"O processo será interrompido e os dados restaurados na condição original.")
			Exit
		Endif

	Else

		MsgAlert("Sequência de baixa não localizada."+cEOL+;
				 "Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+" Seq."+ZE5->ZE5_SEQSE5+cEOL+;
				 "O processo será interrmpido.")
		lProcOk := .F.
		DisarmTransaction()
		Exit

	Endif

	DbSelectArea("ZE5")
	ZE5->(DbSkip())
Enddo

If lProcOk

	// 2. Atualiza saldo da parcela
	DbSelectArea("Z02")
	DbSetOrder(1)
	DbSeek( xFilial("Z02") + Z05->Z05_ACORDO + Z05->Z05_PARC )
	RecLock("Z02",.F.)
	Z02->Z02_SALDO += Z05->Z05_VALOR
	MsUnLock()

	// 3. Atualiza status do acordo
	DbSelectArea("Z01")
	DbSetOrder(1)
	DbSeek( xFilial("Z01") + Z05->Z05_ACORDO )
	RecLock("Z01",.F.)
	Z01->Z01_STATUS := IIf( u_MovAcor(Z01->Z01_ACORDO), "L", "A" )
	MsUnLock()

	// 4. Exclui relacionamentos da movimentação do acordo x sequências de baixa dos títulos
	For _x := 1 to Len(aDelZE5)
		DbSelectArea("ZE5")
		ZE5->(DbGoto( aDelZE5[_x] ))
		RecLock("ZE5",.F.)
		DbDelete()
		MsUnLock()
	Next _x

	// 5. Exclui movimentação do acordo
	DbSelectArea("Z05")
	RecLock("Z05",.F.)
	DbDelete()
	MsUnLock()

Endif

End Transaction
MsUnLockAll()
*/
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR05C   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Chamada: cancela a movimentação da parcela do acordo.	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR05C()
/* (Função Desativada)
nRecZ05 := Z05->(Recno())
z05Acor := Z05->Z05_ACORDO
z05Parc := Z05->Z05_PARC
z05Sequ := Z05->Z05_SEQ

Z05->(DbSetOrder(1))
lCancOk := ( Z05->(DbSeek( xFilial("Z05") + z05Acor + z05Parc + z05Sequ + "ES" )) )
Z05->(DbGoto(nRecZ05))

If Z05->Z05_TIPDOC == "ES"
	MsgAlert("Este é um movimento de cancelamento.")
	Return
Endif

If lCancOk
	MsgAlert("O movimento já encontra-se cancelado.")
	Return
Endif

If Z05->Z05_DATA < GetMv("MV_DATAFIN")
	MsgAlert("Data limite p/ realização de operações financeiras: "+DtoC(GetMv("MV_DATAFIN")))
	lRetorno := .F.
Endif

If MsgYesNo("Confirma cancelamento da movimentação selecionada ?","Aviso","INFO")
	MsgRun("Cancelando movimentações... aguarde","Processando",{|| _CanBxAc() })
Endif
*/
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ _CanBxAc  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Execução: cancela a movimentação da parcela do acordo.	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _CanBxAc()
/* (Função Desativada)
Private aCanZE5 := {}
Private lProcOk := .T.
Private lMsErroAuto := .F.

Begin Transaction

// 1. Gera movimentações de cancelamento nos títulos a receber pertencentes ao acordo - integração com módulo financeiro
DbSelectArea("ZE5")
DbSetOrder(1)
DbSeek( Z05->(Z05_FILIAL+Z05_ACORDO+Z05_PARC+Z05_SEQ) )
While !Eof() .And. ZE5->(ZE5_FILIAL+ZE5_ACORDO+ZE5_PARC+ZE5_SEQ) == Z05->(Z05_FILIAL+Z05_ACORDO+Z05_PARC+Z05_SEQ)

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek( ZE5->(ZE5_FILIAL+ZE5_PREFIX+ZE5_NUMERO+ZE5_PARTIT+ZE5_TIPO+ZE5_CLIENT) )

	nSalvRec  := SE1->(Recno())
	nSaldo    := 0
    aBaixa    := {}
    aBaixaSE5 := {}
    aBaixa    := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,SE1->E1_TIPO,,,SE1->E1_CLIENTE,SE1->E1_LOJA,@nSaldo,,,)
    SE1->( DbGoto( nSalvRec ) )
	nQualBx := aScan(aBaixaSE5, {|x| x[9] == ZE5->ZE5_SEQSE5 })

	If nQualBx > 0

		zHisCn := "Cancelamento da Baixa "+AllTrim(Z05->Z05_ACORDO)

		aBaixa := { {"E1_PREFIXO"  , SE1->E1_PREFIXO , Nil},;
					{"E1_NUM"	   , SE1->E1_NUM     , Nil},; 
					{"E1_PARCELA"  , SE1->E1_PARCELA , Nil},;
					{"E1_TIPO"	   , SE1->E1_TIPO    , Nil},;
					{"E1_CLIENTE"  , SE1->E1_CLIENTE , Nil},;
					{"E1_LOJA"	   , SE1->E1_LOJA    , Nil},;
					{"AUTHIST"	   , zHisCn          , Nil} }

		lMsErroAuto := .F.
		MSExecAuto({|x,w,y,z| FINA070(x,w,y,z)},aBaixa,5,,nQualBx)

		If !lMsErroAuto
			AAdd(aCanZE5,ZE5->(Recno()))
		Else
			lProcOk := .F.
			DisarmTransaction()
			MostraErro()
			MsgAlert("Falha no cancelamento da baixa:"+cEOL+;
			"Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+cEOL+;
			"O processo será interrompido e os dados restaurados na condição original.")
			Exit
		Endif

	Else

		MsgAlert("Sequência de baixa não localizada."+cEOL+;
				 "Título: "+AllTrim(SE1->E1_PREFIXO)+"-"+AllTrim(SE1->E1_NUM)+" Seq."+ZE5->ZE5_SEQSE5+cEOL+;
				 "O processo será interrmpido.")
		lProcOk := .F.
		DisarmTransaction()
		Exit

	Endif

	DbSelectArea("ZE5")
	ZE5->(DbSkip())
Enddo

If lProcOk

	// 2. Atualiza saldo da parcela
	DbSelectArea("Z02")
	DbSetOrder(1)
	DbSeek( xFilial("Z02") + Z05->Z05_ACORDO + Z05->Z05_PARC )
	RecLock("Z02",.F.)
	Z02->Z02_SALDO += Z05->Z05_VALOR
	MsUnLock()

	// 3. Atualiza status do acordo
	DbSelectArea("Z01")
	DbSetOrder(1)
	DbSeek( xFilial("Z01") + Z05->Z05_ACORDO )
	RecLock("Z01",.F.)
	Z01->Z01_STATUS := IIf( u_MovAcor(Z01->Z01_ACORDO), "L", "A" )
	MsUnLock()

	// 4. Grava data de cancelamento nos relacionamentos da movimentação do acordo x sequências de baixa dos títulos
	For _x := 1 to Len(aCanZE5)
		DbSelectArea("ZE5")
		ZE5->(DbGoto( aCanZE5[_x] ))
		RecLock("ZE5",.F.)
		ZE5->ZE5_DATCAN := dDatabase
		MsUnLock()
	Next _x

	// 5. Gera movimentação de cancelamento na parcela do acordo
	z05Acor := Z05->Z05_ACORDO
	z05Parc := Z05->Z05_PARC
	z05Banc := Z05->Z05_BANCO
	z05Agen := Z05->Z05_AGENCI
	z05Cont := Z05->Z05_CONTA
	z05Sequ := Z05->Z05_SEQ
	z05Valo := Z05->Z05_VALOR
	z05VlPr := Z05->Z05_VLPRIN
	z05VlAc := Z05->Z05_VLACRE
	z05VlJu := Z05->Z05_VLJURO
	z05Hist := Z05->Z05_HIST

	DbSelectArea("Z05")
	RecLock("Z05",.T.)
	Z05->Z05_FILIAL := xFilial("Z05")
	Z05->Z05_ACORDO := z05Acor
	Z05->Z05_PARC   := z05Parc
	Z05->Z05_BANCO  := z05Banc
	Z05->Z05_AGENCI := z05Agen
	Z05->Z05_CONTA  := z05Cont
	Z05->Z05_DATA   := dDatabase
	Z05->Z05_SEQ    := z05Sequ
	Z05->Z05_VALOR  := z05Valo
	Z05->Z05_VLPRIN := z05VlPr
	Z05->Z05_VLACRE := z05VlAc
	Z05->Z05_VLJURO := z05VlJu
	Z05->Z05_TIPDOC := "ES"
	Z05->Z05_HIST   := z05Hist
	Z05->Z05_USUARI := cUserName
	Z05->Z05_DTDIGI := Date()
	MsUnLock()

Endif

End Transaction
MsUnLockAll()
*/
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MovAcor  ¦ Autor ¦  Fabrica ERPBR ¦ Data  ¦ 20/08/2018	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verifica se o acordo possui movimentações.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MovAcor(zAcordo)

Local aArea  := GetArea()
Local lMovim := .F.

cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("Z02")
cQuery += " WHERE Z02_FILIAL = '"+xFilial("Z02")+"' "
cQuery += " AND Z02_ACORDO = '"+zAcordo+"' "
cQuery += " AND Z02_SALDO < (Z02_VALOR+Z02_ACRESC) "
cQuery += " AND D_E_L_E_T_ <> '*' "	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZ02",.T.,.T.)
lMovim := ( TZ02->SOMA > 0 )
TZ02->(DbCloseArea())

RestArea(aArea)

Return(lMovim)
