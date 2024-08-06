#include "protheus.ch"
#include "totvs.ch"
#include "apvt100.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AACD01C   ¦ Autor ¦  Luis Brandini   ¦ Data  ¦ 06/06/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta saldo em estoque no coletor via TELNET.		  	  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AACD01C()

Local aTela
Private xOpcA   := Space(1) 
Private nMaxRow := 10
Private nMaxCol := 20

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.
	xOpcA := Space(1)
	VTCLEAR
	@ 00,01 VTSAY cUserName
	@ 02,01 VTSAY "1 - por Produto    "
	@ 03,01 VTSAY "2 - por Endereco   "
	@ 04,01 VTSAY "3 - por Lote       "
	@ 05,01 VTSAY "5 - Sair           "
	@ 07,01 VTSAY "Opcao:"
	@ 07,08 VTGET xOpcA Picture "@!" Valid(xOpcA$"1235")
	VTREAD
	If VTLASTKEY() == 27 .Or. xOpcA == "5"
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			VTDISCONNECT()
			Return .T.
		Endif
	Endif
	Do Case
		Case xOpcA == "1"
			AcdCPro()
		Case xOpcA == "2"
			AcdCEnd()
		Case xOpcA == "3"
			AcdCLot()
	Endcase
Enddo

Return .T.

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcdCPro   ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta estoque - por Produto.							  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AcdCPro()

Local aTela

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.

	VTCLEAR

	zProdut  := Space(15)
	zArmzIni := Space(2)
	zArmzFim := Space(2)
	
	@ 00,01 VTSAY "Produto:"
	@ 00,10 VTGET zProdut Valid u_VldProd(zProdut)
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	@ 01,01 VTSAY "Armz.Ini:"
	@ 01,10 VTGET zArmzIni
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	@ 02,01 VTSAY "Armz.Fim: "
	@ 02,10 VTGET zArmzFim
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	zFiltro := " BF_FILIAL == '"+xFilial("SBF")+"' .And. AllTrim(BF_PRODUTO) == '"+AllTrim(zProdut)+"' "
	zFiltro += " .And. BF_LOCAL >= '"+zArmzIni+"' .And. BF_LOCAL <= '"+zArmzFim+"' "
	DbSelectArea("SBF")
	DbSetOrder(1)
	Set Filter to &(zFiltro)
	SBF->(DbGotop())
	If Eof()
		VTCLEAR
		VTALERT("Produto sem saldo disponivel")
		VTCLEAR
		Exit
	Else
		While .T.
			VTCLEAR
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + SBF->BF_PRODUTO )
			xOpcB := Space(1)
			@ 01,01 VTSAY SBF->BF_LOCAL+"  "+SBF->BF_LOCALIZ
			@ 02,01 VTSAY AllTrim(SBF->BF_PRODUTO)
			@ 03,01 VTSAY Substr(SB1->B1_DESC,1,19)
			@ 04,01 VTSAY Substr(SB1->B1_DESC,20,19)
			@ 05,01 VTSAY "Lote.: "+SBF->BF_LOTECTL
			@ 06,01 VTSAY Transform(SBF->BF_QUANT,"@E 999,999.99")+"  "+SB1->B1_UM
			@ 07,01 VTSAY "-------------------"
			@ 08,01 VTSAY "4-Anter. | 6-Prox. "
			@ 09,01 VTSAY "Opcao:"
			@ 09,08 VTGET xOpcB Picture "@!" Valid(xOpcB$"46")
			VTREAD
			If VTLASTKEY() == 27
				VTCLEAR
				@ 03,01 VTSAY "Deseja encerrar ?  "
				@ 05,01 VTSAY "Tecle 9 para sair  "
				@ 06,01 VTSAY "ou <ENTER> para    "
				@ 07,01 VTSAY "continuar          "
				VTINKEY(0)
				If VTLASTKEY() == 57
					lSaida := .T.
					Exit
				Endif
			Endif
			Do Case
				Case xOpcB == "4"
					DbSelectArea("SBF")
					SBF->(DbSkip(-1))
					If Bof()
						VTCLEAR
						VTALERT("Primeiro registro")
						VTCLEAR
					Endif
				Case xOpcB == "6"
					DbSelectArea("SBF")
					nRecSbf := Recno()
					SBF->(DbSkip())
					If Eof()
						VTCLEAR
						VTALERT("Ultimo registro")
						VTCLEAR
						SBF->(DbGoto(nRecSbf))
					Endif
			Endcase
		Enddo
	Endif	
	DbSelectArea("SBF")
	DbSetOrder(1)
	Set Filter to
Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcdCEnd   ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta estoque - por Endereço.							  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AcdCEnd()

Local aTela

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.

	VTCLEAR

	zEndere  := Space(15)
	zArmzIni := Space(2)
	zArmzFim := Space(2)
	
	@ 00,01 VTSAY "End.:"
	@ 00,07 VTGET zEndere Picture "@!"
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	@ 01,01 VTSAY "Armz.Ini: "
	@ 01,10 VTGET zArmzIni
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	@ 02,01 VTSAY "Armz.Fim: "
	@ 02,10 VTGET zArmzFim
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	// Converte o códidgo digitado
	zEndere := Upper(zEndere)
	If Substr(zEndere,1,3) $("GEN,BOX,TRS,PAL,OBS,BLC")
		zRua := Substr(zEndere,1,4)
		zMod := Substr(zEndere,5,2)
		zNiv := Substr(zEndere,7,2)
		zPos := Substr(zEndere,9,2)
		zEnd := zRua+"-"+zMod+"-"+zNiv+"-"+zPos
	ElseIf Substr(zEndere,2,3) $("GEN,BOX,TRS,PAL,OBS,BLC")
		zGal := Substr(zEndere,1,1)
		zRua := Substr(zEndere,2,4)
		zMod := Substr(zEndere,6,2)
		zNiv := Substr(zEndere,8,2)
		zPos := Substr(zEndere,10,2)
		zEnd := zGal+"-"+zRua+"-"+zMod+"-"+zNiv+"-"+zPos
	ElseIf Substr(zEndere,1,3) $("RES,SLW")
		zRua := Substr(zEndere,1,3)
		zMod := Substr(zEndere,4,2)
		zNiv := Substr(zEndere,6,2)
		zPos := Substr(zEndere,8,2)
		zEnd := zRua+"-"+zMod+"-"+zNiv+"-"+zPos
	ElseIf Substr(zEndere,2,3) $("RES,SLW")
		zGal := Substr(zEndere,1,1)
		zRua := Substr(zEndere,2,3)
		zMod := Substr(zEndere,5,2)
		zNiv := Substr(zEndere,7,2)
		zPos := Substr(zEndere,9,2)
		zEnd := zGal+"-"+zRua+"-"+zMod+"-"+zNiv+"-"+zPos
	Else
		zGal := Substr(zEndere,1,1)
		zRua := Substr(zEndere,2,1)
		zMod := Substr(zEndere,3,2)
		zNiv := Substr(zEndere,5,2)
		zPos := Substr(zEndere,7,2)
		zEnd := zGal+"-"+zRua+"-"+zMod+"-"+zNiv+"-"+zPos
	Endif

	zFiltro := " BF_FILIAL == '"+xFilial("SBF")+"' .And. AllTrim(BF_LOCALIZ) == '"+AllTrim(zEnd)+"' "
	zFiltro += " .And. BF_LOCAL >= '"+zArmzIni+"' .And. BF_LOCAL <= '"+zArmzFim+"' "
	DbSelectArea("SBF")
	DbSetOrder(1)
	Set Filter to &(zFiltro)
	SBF->(DbGotop())
	If Eof()
		VTCLEAR
		VTALERT("Endereco "+zEnd+" sem saldo disponivel ou nao localizado")
		VTCLEAR
		Exit
	Else
		While .T.
			VTCLEAR
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + SBF->BF_PRODUTO )
			xOpcB := Space(1)
			@ 01,01 VTSAY SBF->BF_LOCAL+"  "+SBF->BF_LOCALIZ
			@ 02,01 VTSAY AllTrim(SBF->BF_PRODUTO)
			@ 03,01 VTSAY Substr(SB1->B1_DESC,1,19)
			@ 04,01 VTSAY Substr(SB1->B1_DESC,20,19)
			@ 05,01 VTSAY "Lote.: "+SBF->BF_LOTECTL
			@ 06,01 VTSAY Transform(SBF->BF_QUANT,"@E 999,999.99")+"  "+SB1->B1_UM
			@ 07,01 VTSAY "-------------------"
			@ 08,01 VTSAY "4-Anter. | 6-Prox. "
			@ 09,01 VTSAY "Opcao:"
			@ 09,08 VTGET xOpcB Picture "@!" Valid(xOpcB$"46")
			VTREAD
			If VTLASTKEY() == 27
				VTCLEAR
				@ 03,01 VTSAY "Deseja encerrar ?  "
				@ 05,01 VTSAY "Tecle 9 para sair  "
				@ 06,01 VTSAY "ou <ENTER> para    "
				@ 07,01 VTSAY "continuar          "
				VTINKEY(0)
				If VTLASTKEY() == 57
					lSaida := .T.
					Exit
				Endif
			Endif
			Do Case
				Case xOpcB == "4"
					DbSelectArea("SBF")
					SBF->(DbSkip(-1))
					If Bof()
						VTCLEAR
						VTALERT("Primeiro registro")
						VTCLEAR
					Endif
				Case xOpcB == "6"
					DbSelectArea("SBF")
					nRecSbf := Recno()
					SBF->(DbSkip())
					If Eof()
						VTCLEAR
						VTALERT("Ultimo registro")
						VTCLEAR
						SBF->(DbGoto(nRecSbf))
					Endif
			Endcase
		Enddo
	Endif	
	DbSelectArea("SBF")
	DbSetOrder(1)
	Set Filter to
Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcdCLot   ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Consulta estoque - por Lote.								  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AcdCLot()

Local aTela

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.

	VTCLEAR

	zLoteCtl := Space(10)
	zArmzIni := Space(2)
	zArmzFim := Space(2)
	
	@ 00,01 VTSAY "Lote: "
	@ 00,07 VTGET zLoteCtl
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	@ 01,01 VTSAY "Armz.Ini: "
	@ 01,10 VTGET zArmzIni
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	@ 02,01 VTSAY "Armz.Fim: "
	@ 02,10 VTGET zArmzFim
	VTREAD

	If VTLASTKEY() == 27
		VTCLEAR
		@ 03,01 VTSAY "Deseja encerrar ?  "
		@ 05,01 VTSAY "Tecle 9 para sair  "
		@ 06,01 VTSAY "ou <ENTER> para    "
		@ 07,01 VTSAY "continuar          "
		VTINKEY(0)
		If VTLASTKEY() == 57
			Exit
		Else
			VTCLEAR
			Loop
		Endif
	Endif

	zFiltro := " BF_FILIAL == '"+xFilial("SBF")+"' .And. AllTrim(BF_LOTECTL) == '"+AllTrim(zLoteCtl)+"' "
	zFiltro += " .And. BF_LOCAL >= '"+zArmzIni+"' .And. BF_LOCAL <= '"+zArmzFim+"' "
	DbSelectArea("SBF")
	DbSetOrder(1)
	Set Filter to &(zFiltro)
	SBF->(DbGotop())
	If Eof()
		VTCLEAR
		VTALERT("Lote sem saldo disponivel")
		VTCLEAR
		Exit
	Else
		While .T.
			VTCLEAR
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + SBF->BF_PRODUTO )
			xOpcB := Space(1)
			@ 01,01 VTSAY SBF->BF_LOCAL+"  "+SBF->BF_LOCALIZ
			@ 02,01 VTSAY AllTrim(SBF->BF_PRODUTO)
			@ 03,01 VTSAY Substr(SB1->B1_DESC,1,19)
			@ 04,01 VTSAY Substr(SB1->B1_DESC,20,19)
			@ 05,01 VTSAY "Lote.: "+SBF->BF_LOTECTL
			@ 06,01 VTSAY Transform(SBF->BF_QUANT,"@E 999,999.99")+"  "+SB1->B1_UM
			@ 07,01 VTSAY "-------------------"
			@ 08,01 VTSAY "4-Anter. | 6-Prox. "
			@ 09,01 VTSAY "Opcao:"
			@ 09,08 VTGET xOpcB Picture "@!" Valid(xOpcB$"46")
			VTREAD
			If VTLASTKEY() == 27
				VTCLEAR
				@ 03,01 VTSAY "Deseja encerrar ?  "
				@ 05,01 VTSAY "Tecle 9 para sair  "
				@ 06,01 VTSAY "ou <ENTER> para    "
				@ 07,01 VTSAY "continuar          "
				VTINKEY(0)
				If VTLASTKEY() == 57
					lSaida := .T.
					Exit
				Endif
			Endif
			Do Case
				Case xOpcB == "4"
					DbSelectArea("SBF")
					SBF->(DbSkip(-1))
					If Bof()
						VTCLEAR
						VTALERT("Primeiro registro")
						VTCLEAR
					Endif
				Case xOpcB == "6"
					DbSelectArea("SBF")
					nRecSbf := Recno()
					SBF->(DbSkip())
					If Eof()
						VTCLEAR
						VTALERT("Ultimo registro")
						VTCLEAR
						SBF->(DbGoto(nRecSbf))
					Endif
			Endcase
		Enddo
	Endif	
	DbSelectArea("SBF")
	DbSetOrder(1)
	Set Filter to
Enddo

Return
