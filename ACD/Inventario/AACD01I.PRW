#include "protheus.ch"
#include "totvs.ch"
#include "apvt100.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AACD01I   ¦ Autor ¦  Luis Brandini   ¦ Data  ¦ 06/06/2019  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Inventário Físico no Coletor de Dados via TELNET.		  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AACD01I()

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
	@ 02,01 VTSAY "1 - Abrir          "
	@ 03,01 VTSAY "2 - Contar Sub-Lote"
	@ 04,01 VTSAY "3 - Contar Individ."
	@ 05,01 VTSAY "4 - Excluir        "
	@ 06,01 VTSAY "5 - Transferir     "
	@ 07,01 VTSAY "6 - Sair           "
	@ 09,01 VTSAY "Opcao:"
	@ 09,08 VTGET xOpcA Picture "@!" Valid(xOpcA$"123456")
	VTREAD
	If VTLASTKEY() == 27 .Or. xOpcA == "6"
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
			AcdAbrir()
		Case xOpcA == "2"
			AcdConta("A")
		Case xOpcA == "3"
			AcdConta("I")
		Case xOpcA == "4"
			AcdExclu()
		Case xOpcA == "5"
			AcdTrans()
	Endcase
Enddo

Return .T.

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcdAbrir  ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Abre sub-lote de contagem.								  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AcdAbrir()

Local aTela

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.

	VTCLEAR

	zLocal  := Space(02)
	zTpInve := Space(01)
	zGalpao := Space(01)
	zRuaIni := Space(01)
	zRuaFim := Space(01)
	zModIni := Space(02)
	zModFim := Space(02)
	zNivIni := Space(02)
	zNivFim := Space(02)
	zGrupo  := Space(04)
	
	@ 00,01 VTSAY "Armazem: "
	@ 00,10 VTGET zLocal Picture "@!" Valid u_VldArmz(zLocal)
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
		Endif
	Endif

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SZL")
	cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
	cQuery += " AND ZL_USUARIO = '"+cUserName+"' "
	cQuery += " AND ZL_TRANSF = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	lExiste := (SQL1->SOMA > 0)
	SQL1->(DbCloseArea())
	If lExiste
		VTCLEAR
		VTALERT("Usuario c/ sub-lote aberto e ainda nao transferido")
		VTCLEAR
		Exit
	Endif

	@ 01,01 VTSAY "Generico (S/N): "
	@ 01,17 VTGET zTpInve Picture "@!" Valid(zTpInve$"SN")
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
		Endif
	Endif

	If zTpInve == "N"

		@ 02,01 VTSAY "Galpao: "
		@ 02,10 VTGET zGalpao Picture "@!"
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
			Endif
		Endif

		@ 03,01 VTSAY "Rua Ini: "
		@ 03,10 VTGET zRuaIni Picture "@!"
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
			Endif
		Endif
	
		@ 04,01 VTSAY "Rua Fim: "
		@ 04,10 VTGET zRuaFim Picture "@!"
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
			Endif
		Endif
	
		@ 05,01 VTSAY "Mod Ini: "
		@ 05,10 VTGET zModIni Picture "@!"
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
			Endif
		Endif
	
		@ 06,01 VTSAY "Mod Fim: "
		@ 06,10 VTGET zModFim Picture "@!"
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
			Endif
		Endif
	
		@ 07,01 VTSAY "Niv Ini: "
		@ 07,10 VTGET zNivIni Picture "@!"
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
			Endif
		Endif
	
		@ 08,01 VTSAY "Niv Fim: "
		@ 08,10 VTGET zNivFim Picture "@!"
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
			Endif
		Endif

	Else

		xOpcG  := Space(1)
		@ 03,01 VTSAY "Selecione o Grupo"
		@ 04,01 VTSAY "-------------------"
		@ 05,01 VTSAY "3-Envase | 4-Embal."
		@ 06,01 VTSAY "5-Foliar | 6-Soluc."
		@ 07,01 VTSAY "7-Todos"
		@ 08,01 VTSAY "-------------------"
		@ 09,01 VTSAY "Opcao: "
		@ 09,08 VTGET xOpcG Picture "@!" Valid(xOpcG$"34567")
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
			Endif
		Endif
		If xOpcG < "7"
			zGrupo := StrZero(Val(xOpcG),4)
		Endif
		
	Endif

	DbSelectArea("SZL")
	DbSetOrder(1)

	DbSelectArea("SZM")
	DbSetOrder(2)
	If !DbSeek( xFilial("SZM") + zLocal + "N" + zTpInve )
		VTCLEAR
		VTALERT("Lote de contagem nao localizado")
		VTCLEAR
		Exit
	Else
		lFound := .F.
		While !Eof() .And. SZM->(ZM_FILIAL+ZM_LOCAL+ZM_ENCER+ZM_UNICO) == xFilial("SZM") + zLocal + "N" + zTpInve
			If SZM->ZM_GALPAO == zGalpao
				lFound := .T.
				Exit
			Endif 
			SZM->(DbSkip())
		Enddo
	Endif
	If !lFound
		VTCLEAR
		VTALERT("Lote de contagem galpao nao localizado")
		VTCLEAR
		Exit
	Else
		If SZM->ZM_UNICO == "S"
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SZL")
			cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
			cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
			cQuery += " AND ZL_LOCALIZ = '"+SZM->ZM_LOCALIZ+"' "
			If !Empty(zGrupo)
				cQuery += " AND ZL_GRUPO = '"+zGrupo+"' "
			Endif
			cQuery += " AND ZL_USUARIO <> ' ' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
		Else
			cQuery := " SELECT COUNT(*)AS SOMA "
			cQuery += " FROM "+RetSqlName("SZL")
			cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
			cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
			cQuery += " AND SUBSTR(ZL_LOCALIZ,3,1) BETWEEN '"+zRuaIni+"' AND '"+zRuaFim+"' "
			cQuery += " AND SUBSTR(ZL_LOCALIZ,5,2) BETWEEN '"+zModIni+"' AND '"+zModFim+"' "
			cQuery += " AND SUBSTR(ZL_LOCALIZ,8,2) BETWEEN '"+zNivIni+"' AND '"+zNivFim+"' "
			cQuery += " AND ZL_USUARIO <> ' ' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
		Endif
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)
		lExiste := (SQL2->SOMA > 0)
		SQL2->(DbCloseArea())
		If lExiste
			VTCLEAR
			VTALERT("A faixa de enderecos ja esta alocada")
			VTCLEAR
			Exit
		Else
			If SZM->ZM_UNICO == "S"
				cQuery := " SELECT R_E_C_N_O_ RECSZL "
				cQuery += " FROM "+RetSqlName("SZL")
				cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
				cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
				cQuery += " AND ZL_LOCALIZ = '"+SZM->ZM_LOCALIZ+"' "
				If !Empty(zGrupo)
					cQuery += " AND ZL_GRUPO = '"+zGrupo+"' "
				Endif
				cQuery += " AND ZL_USUARIO = ' ' "
				cQuery += " AND ZL_TRANSF = 'N' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
			Else
				cQuery := " SELECT R_E_C_N_O_ RECSZL "
				cQuery += " FROM "+RetSqlName("SZL")
				cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
				cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
				cQuery += " AND SUBSTR(ZL_LOCALIZ,3,1) BETWEEN '"+zRuaIni+"' AND '"+zRuaFim+"' "
				cQuery += " AND SUBSTR(ZL_LOCALIZ,5,2) BETWEEN '"+zModIni+"' AND '"+zModFim+"' "
				cQuery += " AND SUBSTR(ZL_LOCALIZ,8,2) BETWEEN '"+zNivIni+"' AND '"+zNivFim+"' "
				cQuery += " AND ZL_USUARIO = ' ' "
				cQuery += " AND ZL_TRANSF = 'N' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
			Endif
			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
			DbSelectArea("SQL3")
			SQL3->(DbGotop())
			If Eof()
				VTCLEAR
				VTALERT("Enderecos nao localizados ou nao disponiveis para contagem")
				VTCLEAR
				SQL3->(DbCloseArea())
				Exit
			Else
				zTime := Time()
				While !Eof()
					DbSelectArea("SZL")
					SZL->(DbGoto(SQL3->RECSZL))
					RecLock("SZL",.F.)
					SZL->ZL_USUARIO := cUserName
					SZL->ZL_USRFULL := UsrFullName(__cUserId)
					SZL->ZL_OBS     := "Início às "+zTime
					MsUnLock()
					DbSelectArea("SQL3")
					SQL3->(DbSkip())
				Enddo
				VTCLEAR
				VTALERT("Sub-lote aberto com sucesso!!")
				VTCLEAR
				SQL3->(DbCloseArea())
				Exit
			Endif
		Endif
	Endif

Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcdConta  ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Contagem do inventário - sub-lote completo.				  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AcdConta(zModo)

Local aTela

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.

	VTCLEAR

	zLocal := Space(02)
	
	@ 00,01 VTSAY "Armazem: "
	@ 00,10 VTGET zLocal Picture "@!" Valid u_VldArmz(zLocal)
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
		Endif
	Endif

	DbSelectArea("SZL")
	DbSetOrder(1)

	cQuery := " SELECT DISTINCT(ZL_ID) ZL_ID "
	cQuery += " FROM "+RetSqlName("SZL")
	cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
	cQuery += " AND ZL_LOCAL = '"+zLocal+"' "
	cQuery += " AND ZL_USUARIO = '"+cUserName+"' "
	cQuery += " AND ZL_TRANSF = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	zId := SQL1->ZL_ID
	SQL1->(DbCloseArea())
	If Empty(zId)
		VTCLEAR
		VTALERT("Sub-lote de contagem nao localizado para o usuario")
		VTCLEAR
		Exit
	Endif
	
	DbSelectArea("SZM")
	DbSetOrder(1)
	If !DbSeek( xFilial("SZM") + zId )
		VTCLEAR
		VTALERT("Lote de contagem nao cadastrado")
		VTCLEAR
		Exit
	Else
		zProdut  := Space(15)		
		zEndere  := Space(15)
		zLoteCtl := Space(10)
		If zModo == "I"
			xOpcZ := Space(1)
			VTCLEAR
			@ 00,01 VTSAY cUserName
			@ 02,01 VTSAY "1 - Produto        "
			@ 03,01 VTSAY "2 - Endereco       "
			@ 04,01 VTSAY "3 - Lote           "
			@ 05,01 VTSAY "5 - Sair           "
			@ 07,01 VTSAY "Opcao:"
			@ 07,08 VTGET xOpcZ Picture "@!" Valid(xOpcZ$"1235")
			VTREAD
			If VTLASTKEY() == 27 .Or. xOpcZ == "5"
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
				Case xOpcZ == "1"
					VTCLEAR
					@ 00,01 VTSAY "Produto: "
					@ 00,11 VTGET zProdut Picture "@!" Valid u_VldProd(zProdut)
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
						Endif
					Endif
				Case xOpcZ == "2"
					VTCLEAR
					@ 00,01 VTSAY "End.: "
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
					zEndere := zEnd
				Case xOpcZ == "3"
					VTCLEAR
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
						Endif
					Endif
			Endcase
		Endif
		zFiltro := " ZL_FILIAL == '"+xFilial("SZL")+"' .And. ZL_ID == '"+SZM->ZM_ID+"' .And. AllTrim(ZL_USUARIO) == '"+AllTrim(cUserName)+"'
		zFiltro += " .And. ZL_TRANSF == 'N' "
		If !Empty(zProdut)
			zFiltro += " .And. ZL_COD = '"+zProdut+"' "
		Endif
		If !Empty(zEndere)
			zFiltro += " .And. ZL_LOCALIZ = '"+zEndere+"' "
		Endif
		If !Empty(zLoteCtl)
			zFiltro += " .And. ZL_LOTECTL = '"+zLoteCtl+"' "
		Endif
		
		DbSelectArea("SZL")
		If SZM->ZM_UNICO == "S"
			DbSetOrder(3) // Id Contagem + Armazem + Descricao + Endereco + Lote
		Else
			DbSetOrder(1) // Id Contagem + Usuario + Armazem + Endereco + Produto + Lote
		Endif	
		Set Filter to &(zFiltro)
		SZL->(DbGotop())
		If Eof()
			VTCLEAR
			VTALERT("Sub-lote nao aberto p/ contagem ao usuario")
			VTCLEAR
			Exit
		Else
			DbSelectArea("SZL")
			If zModo != "I"
				// Inicia com o primeiro registro não conferido
				lResta := .F.
				While !Eof()
					If SZL->ZL_CONF=="S"
						SZL->(DbSkip())
						Loop
					Else
						lResta := .T.
						Exit
					Endif
				Enddo
				If !lResta
					SZL->(DbGotop()) // Caso todos conferidos, posiciona no primeiro registro
				Endif
			Endif	
			While !Eof()
				lSaida := .F.
				lFirst := .F.
				lLastR := .F.
				lSubst := .F.
				lInclu := .F.
				While .T.
					VTCLEAR
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek( xFilial("SB1") + SZL->ZL_COD )
					xOpcB := Space(1)
					zQtde := SZL->ZL_QUANT
					@ 00,01 VTSAY SZL->ZL_LOCAL + IIf(SZL->ZL_CONF=="S","      *Conferido*","")
					@ 01,01 VTSAY SZL->ZL_LOCALIZ+"  "+SB1->B1_UM
					@ 02,01 VTSAY AllTrim(SZL->ZL_COD)+"-"+Substr(SB1->B1_DESC,1,12)
					@ 03,01 VTSAY Substr(SB1->B1_DESC,13,18)
					@ 04,01 VTSAY "Lote.: "+SZL->ZL_LOTECTL
					@ 05,01 VTSAY "Qtde.: "
					@ 05,08 VTGET zQtde Picture "@E 999,999.99" Valid u_VldQtde(zQtde)
					@ 06,01 VTSAY "-------------------"
					@ 07,01 VTSAY "2-Gravar | 8-Subst."
					@ 08,01 VTSAY "4-Anter. | 6-Prox. "
					lOpcInc := ( SZM->ZM_UNICO=="S" .Or. !Empty(SZM->ZM_ARQ) )
					lIncEnd := ( !Empty(SZM->ZM_ARQ) )
					If !lOpcInc
						@ 09,01 VTSAY "Opcao:"
						@ 09,08 VTGET xOpcB Picture "@!" Valid(xOpcB$"2468")
					Else
						@ 09,01 VTSAY "1-Inclui | Opcao:"
						@ 09,19 VTGET xOpcB Picture "@!" Valid(xOpcB$"12468")
					Endif	
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
						Case xOpcB == "1"
							While .T.
								VTCLEAR
								lInclu := .T.
								zObsv := SZL->ZL_OBS
								zEnde := SZM->ZM_LOCALIZ
								@ 01,01 VTSAY "Ende.: "+SZM->ZM_LOCALIZ
								//
								If lIncEnd
									@ 01,08 VTGET zEnde Picture "@!" Valid _VldEnde(@zEnde)
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
								Endif
								//
								zProd := Space(15)
								@ 02,01 VTSAY "Prod.: "
								@ 02,08 VTGET zProd Picture "@!" Valid u_VldProd(zProd)
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
								//
								zLote := Space(10)
								@ 03,01 VTSAY "Lote.: "
								@ 03,08 VTGET zLote Picture "@!"
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
								//
								zQtde := 0
								@ 04,01 VTSAY "Qtde.: "
								@ 04,08 VTGET zQtde Picture "@E 999,999.99" Valid zQtde > 0
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
								// Verifica se já existe
								cQuery := " SELECT COUNT(*)AS SOMA "
								cQuery += " FROM "+RetSqlName("SZL")
								cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
								cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
								cQuery += " AND ZL_LOCAL = '"+SZM->ZM_LOCAL+"' "
								cQuery += " AND ZL_LOCALIZ = '"+zEnde+"' "
								cQuery += " AND ZL_COD = '"+zProd+"' "
								cQuery += " AND ZL_LOTECTL = '"+zLote+"' "
								cQuery += " AND D_E_L_E_T_ <> '*' "
								DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLL", .F., .T.)
								lExiste := (SQLL->SOMA > 0)								
								SQLL->(DbCloseArea())
								If lExiste
									VTCLEAR
									VTALERT("Dados ja cadastrados no lote de contagem")
									VTCLEAR
									Loop
								Endif	
								
								xOpcC := Space(1)
								@ 06,01 VTSAY "Tecle 2 para Gravar    "
								@ 07,01 VTSAY "ou 9 para Abandonar    "
								@ 08,01 VTSAY "Opcao:"
								@ 08,08 VTGET xOpcC Picture "@!" Valid(xOpcC$"29")
								VTREAD
	
								Do Case
									Case xOpcC == "2"
										RecLock("SZL",.T.)
										SZL->ZL_FILIAL  := xFilial("SZL")
										SZL->ZL_ID      := SZM->ZM_ID
										SZL->ZL_LOCAL   := SZM->ZM_LOCAL
										SZL->ZL_LOCALIZ := zEnde
										SZL->ZL_COD     := zProd
										SZL->ZL_LOTECTL := zLote
										SZL->ZL_QUANT   := zQtde
										SZL->ZL_CONF    := "S"
										SZL->ZL_SUBS    := "N"
										SZL->ZL_INCL    := "S"
										SZL->ZL_TRANSF  := "N"
										SZL->ZL_USUARIO := cUserName
										SZL->ZL_USRFULL := UsrFullName(__cUserId)
										SZL->ZL_OBS     := zObsv
										SZL->ZL_GRUPO   := Posicione("SB1",1,xFilial("SB1")+zProd,"B1_GRUPO")
										SZL->ZL_DESCRI  := Posicione("SB1",1,xFilial("SB1")+zProd,"B1_DESC")
										MsUnLock()
										//
										RecLock("SZM",.F.)
										SZM->ZM_TOTCON += 1
										SZM->ZM_TOTEND += 1
										MsUnLock()
										//	
										Exit
									Case xOpcC == "9"
										VTCLEAR
										Exit
								EndCase	
							Enddo	
						Case xOpcB == "2"
							If SZL->ZL_CONF == "N"
								RecLock("SZM",.F.)
								SZM->ZM_TOTCON += 1
								MsUnLock()
							Endif
							RecLock("SZL",.F.)
							SZL->ZL_QUANT := zQtde
							SZL->ZL_CONF  := "S"
							MsUnLock()
							Exit
						Case xOpcB == "4"
							DbSelectArea("SZL")
							SZL->(DbSkip(-2))
							If Bof()
								lFirst := .T.
								VTCLEAR
								VTALERT("Primeiro registro")
								VTCLEAR
							Endif
							Exit
						Case xOpcB == "6"
							DbSelectArea("SZL")
							SZL->(DbSkip())
							If Eof()
								lLastR := .T.
								VTCLEAR
								VTALERT("Ultimo registro")
								VTCLEAR
							Else
								SZL->(DbSkip(-1))
							Endif
							Exit
						Case xOpcB == "8"
							While .T.
								VTCLEAR
								lSubst := .T.
								zProd := Space(15)
								@ 01,01 VTSAY "Prod.: "+SZL->ZL_COD
								@ 02,01 VTSAY "Novo.: "
								@ 02,08 VTGET zProd Picture "@!" Valid u_VldProd(zProd)
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
								zLote := Space(10)
								@ 03,01 VTSAY "Lote.: "+SZL->ZL_LOTECTL
								@ 04,01 VTSAY "Novo.: "
								@ 04,08 VTGET zLote Picture "@!"
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

								xOpcC := Space(1)
								@ 06,01 VTSAY "Tecle 2 para Gravar    "
								@ 07,01 VTSAY "ou 9 para Abandonar    "
								@ 08,01 VTSAY "Opcao:"
								@ 08,08 VTGET xOpcC Picture "@!" Valid(xOpcC$"29")
								VTREAD
	
								Do Case
									Case xOpcC == "2"
										RecLock("SZL",.F.)
										SZL->ZL_COD     := zProd
										SZL->ZL_LOTECTL := zLote
										SZL->ZL_SUBS    := "S"
										SZL->ZL_GRUPO   := Posicione("SB1",1,xFilial("SB1")+zProd,"B1_GRUPO")
										SZL->ZL_DESCRI  := Posicione("SB1",1,xFilial("SB1")+zProd,"B1_DESC")
										MsUnLock()
										Exit
									Case xOpcC == "9"
										VTCLEAR
										Exit
								EndCase
							Enddo	

					Endcase
				Enddo
				If lSaida
					Exit
				Endif
				DbSelectArea("SZL")
				If !lFirst .And. !lLastR .And. !lSubst .And. !lInclu
					SZL->(DbSkip())
				Endif	
			Enddo
			lConf := .T.
			DbSelectArea("SZL")
			While !Eof()
				If SZL->ZL_CONF == "N"
					lConf := .F.
					Exit
				Endif
				SZL->(DbSkip())
			Enddo
			VTCLEAR
			If lConf
				VTALERT("Contagem finalizada!!")
			Else
				VTALERT("Existem registros pendentes de conferencia")
			Endif	
			VTCLEAR
			Exit
		Endif
		DbSelectArea("SZL")
		If SZM->ZM_UNICO == "S"
			DbSetOrder(3) // Id Contagem + Armazem + Descricao + Endereco + Lote
		Else
			DbSetOrder(1) // Id Contagem + Usuario + Armazem + Endereco + Produto + Lote
		Endif	
		Set Filter to
	Endif	

Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcdExclu  ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Exclui sub-lote de contagem.								  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AcdExclu()

Local aTela

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.

	VTCLEAR

	zLocal := Space(02)
	
	@ 00,01 VTSAY "Armazem: "
	@ 00,10 VTGET zLocal Picture "@!" Valid u_VldArmz(zLocal)
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
		Endif
	Endif

	DbSelectArea("SZL")
	DbSetOrder(1)

	cQuery := " SELECT COUNT(*)AS SOMA "
	cQuery += " FROM "+RetSqlName("SZL")
	cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
	cQuery += " AND ZL_LOCAL = '"+zLocal+"' "
	cQuery += " AND ZL_USUARIO = '"+cUserName+"' "
	cQuery += " AND ZL_TRANSF = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	lExiste := (SQL1->SOMA > 0)
	SQL1->(DbCloseArea())
	If !lExiste
		VTCLEAR
		VTALERT("Sub-lote nao disponivel para exclusao, nao vinculado ao usuario, nao localizado ou ja transferido")
		VTCLEAR
		Exit
	Endif
	
	cQuery := " SELECT R_E_C_N_O_ RECSZL "
	cQuery += " FROM "+RetSqlName("SZL")
	cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
	cQuery += " AND ZL_LOCAL = '"+zLocal+"' "
	cQuery += " AND ZL_USUARIO = '"+cUserName+"' "
	cQuery += " AND ZL_TRANSF = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL3", .F., .T.)
	DbSelectArea("SQL3")
	SQL3->(DbGotop())
	While !Eof()
		DbSelectArea("SZL")
		SZL->(DbGoto(SQL3->RECSZL))
		If SZL->ZL_INCL == "S"
			RecLock("SZL",.F.)
			DbDelete()
			MsUnLock()
			//
			RecLock("SZM",.F.)
			SZM->ZM_TOTCON -= 1
			SZM->ZM_TOTEND -= 1
			MsUnLock()
		Else
			If SZL->ZL_CONF == "S"
				RecLock("SZM",.F.)
				SZM->ZM_TOTCON -= 1
				MsUnLock()
			Endif
			RecLock("SZL",.F.)
			SZL->ZL_USUARIO := ""
			SZL->ZL_USRFULL := ""
			SZL->ZL_OBS     := ""
			SZL->ZL_QUANT   := 0
			SZL->ZL_CONF    := "N"
			SZL->ZL_SUBS    := "N"
			SZL->ZL_INCL    := "N"
			MsUnLock()
		Endif
		DbSelectArea("SQL3")
		SQL3->(DbSkip())
	Enddo
	VTCLEAR
	VTALERT("Sub-lote excluido com sucesso!!")
	VTCLEAR
	SQL3->(DbCloseArea())
	Exit

Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AcdTrans  ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transferência do inventário.								  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function AcdTrans()

Local aTela

VTSetSize(nMaxRow,nMaxCol)
VTCLEAR

While .T.

	VTCLEAR

	zLocal := Space(02)
	
	@ 00,01 VTSAY "Armazem: "
	@ 00,10 VTGET zLocal Picture "@!" Valid u_VldArmz(zLocal)
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
		Endif
	Endif

	DbSelectArea("SZL")
	DbSetOrder(1)

	cQuery := " SELECT DISTINCT(ZL_ID) ZL_ID "
	cQuery += " FROM "+RetSqlName("SZL")
	cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
	cQuery += " AND ZL_LOCAL = '"+zLocal+"' "
	cQuery += " AND ZL_USUARIO = '"+cUserName+"' "
	cQuery += " AND ZL_TRANSF = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
	zId := SQL1->ZL_ID
	SQL1->(DbCloseArea())
	If Empty(zId)
		VTCLEAR
		VTALERT("Sub-lote de contagem nao localizado para o usuario")
		VTCLEAR
		Exit
	Endif
	
	DbSelectArea("SZM")
	DbSetOrder(1)
	If !DbSeek( xFilial("SZM") + zId )
		VTCLEAR
		VTALERT("Lote de contagem nao cadastrado")
		VTCLEAR
		Exit
	Else
		cQuery := " SELECT COUNT(*)AS SOMA "
		cQuery += " FROM "+RetSqlName("SZL")
		cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
		cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
		cQuery += " AND ZL_USUARIO = '"+cUserName+"' "
		cQuery += " AND ZL_CONF = 'N' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)
		lNaoConf := (SQL1->SOMA > 0)
		SQL1->(DbCloseArea())
		If lNaoConf
			VTCLEAR
			VTALERT("Existem registros nao conferidos pelo usuario")
			VTCLEAR
			Exit
		Else		
			zFiltro := " ZL_FILIAL == '"+xFilial("SZL")+"' .And. ZL_ID == '"+SZM->ZM_ID+"' .And. AllTrim(ZL_USUARIO) == '"+AllTrim(cUserName)+"'
			zFiltro += " .And. ZL_CONF == 'S' .And. ZL_TRANSF == 'N'"
			DbSelectArea("SZL")
			DbSetOrder(1)
			Set Filter to &(zFiltro)
			SZL->(DbGotop())
			If Eof()
				VTCLEAR
				VTALERT("Nao localizado sub-lote completo do usuario para transferencia")
				VTCLEAR
				Exit
			Else
				zTime := Time()
				DbSelectArea("SZL")
				While !Eof()
					//
					RecLock("SZL",.F.)
					SZL->ZL_TRANSF := "S"
					SZL->ZL_OBS    := AllTrim(SZL->ZL_OBS)+"  |  Fim às "+zTime
					MsUnLock()
					//
					RecLock("SZM",.F.)
					SZM->ZM_TOTTRA += 1
					MsUnLock()
					//
					DbSelectArea("SB1")
					DbSetOrder(1)
					If !DbSeek( xFilial("SB1") + SZL->ZL_COD )
						DbSelectArea("SZL")
						SZL->(DbSkip())
						Loop
					Endif
					If SB1->B1_RASTRO == "L" .And. Empty(SZL->ZL_LOTECTL)
						DbSelectArea("SZL")
						SZL->(DbSkip())
						Loop
					Endif
					If AllTrim(SZL->ZL_LOTECTL) == "VAZIO"
						DbSelectArea("SZL")
						SZL->(DbSkip())
						Loop
					Endif
					//
					dDtValid := dDatabase+730
					zDocumen := ""
					DbSelectArea("SB8")
					DbSetOrder(3)
					If DbSeek( xFilial("SB8") + SZL->ZL_COD + SZL->ZL_LOCAL + SZL->ZL_LOTECTL )
						dDtValid := SB8->B8_DTVALID
						zDocumen := SB8->B8_DOC
					Endif
					//
					DbSelectArea("SB7")
					DbSetOrder(1)
					If !DbSeek( xFilial("SB7") + DtoS(SZM->ZM_DATA) + SZL->ZL_COD + SZL->ZL_LOCAL + SZL->ZL_LOCALIZ + Space(20) + SZL->ZL_LOTECTL )
						RecLock("SB7",.T.)
						SB7->B7_FILIAL  := xFilial("SB7")
						SB7->B7_COD     := SZL->ZL_COD
						SB7->B7_LOCAL   := SZL->ZL_LOCAL
						SB7->B7_TIPO    := SB1->B1_TIPO
						SB7->B7_DOC     := "INV"+Substr(DtoS(SZM->ZM_DATA),5,2)+Substr(DtoS(SZM->ZM_DATA),1,4)
						SB7->B7_DATA    := SZM->ZM_DATA
						SB7->B7_LOTECTL := SZL->ZL_LOTECTL
						SB7->B7_DTVALID := dDtValid
						SB7->B7_LOCALIZ := SZL->ZL_LOCALIZ
						SB7->B7_CONTAGE := "1"
						SB7->B7_NUMDOC  := zDocumen
						SB7->B7_STATUS  := "1"
						SB7->B7_ORIGEM  := "MATA270"
					Else
						RecLock("SB7",.F.)
					Endif
					SB7->B7_QUANT   := SZL->ZL_QUANT
					SB7->B7_QTSEGUM := ConvUm(SB1->B1_COD, SZL->ZL_QUANT, 0, 2)
					MsUnLock()		
					//
					DbSelectArea("SZL")
					SZL->(DbSkip())
				Enddo
				// Checa encerramento do lote de contagem
				cQuery := " SELECT COUNT(*)AS SOMA "
				cQuery += " FROM "+RetSqlName("SZL")
				cQuery += " WHERE ZL_FILIAL = '"+xFilial("SZL")+"' "
				cQuery += " AND ZL_ID = '"+SZM->ZM_ID+"' "
				cQuery += " AND ZL_TRANSF = 'N' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL5", .F., .T.)
				lEncerra := (SQL5->SOMA == 0)
				SQL5->(DbCloseArea())
				If lEncerra
					RecLock("SZM",.F.)
					SZM->ZM_ENCER := "S"
					MsUnLock()
				Endif
				//
				VTCLEAR
				VTALERT("Transferencia finalizada!!")
				VTCLEAR
				Exit
			Endif
			DbSelectArea("SZL")
			DbSetOrder(1)
			Set Filter to
		Endif
	Endif	

Enddo

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _VldEnde  ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida o código do endereço.								  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _VldEnde(zEnde)

Local lRet := .T.

// Converte o código digitado
zEnde := Upper(zEnde)
If Substr(zEnde,1,3) $("GEN,BOX,TRS,PAL,OBS,BLC")
	xRua := Substr(zEnde,1,4)
	xMod := Substr(zEnde,5,2)
	xNiv := Substr(zEnde,7,2)
	xPos := Substr(zEnde,9,2)
	xEnd := xRua+"-"+xMod+"-"+xNiv+"-"+xPos
ElseIf Substr(zEnde,2,3) $("GEN,BOX,TRS,PAL,OBS,BLC")
	xGal := Substr(zEnde,1,1)
	xRua := Substr(zEnde,2,4)
	xMod := Substr(zEnde,6,2)
	xNiv := Substr(zEnde,8,2)
	xPos := Substr(zEnde,10,2)
	xEnd := xGal+"-"+xRua+"-"+xMod+"-"+xNiv+"-"+xPos
ElseIf Substr(zEnde,1,3) $("RES,SLW")
	xRua := Substr(zEnde,1,3)
	xMod := Substr(zEnde,4,2)
	xNiv := Substr(zEnde,6,2)
	xPos := Substr(zEnde,8,2)
	xEnd := xRua+"-"+xMod+"-"+xNiv+"-"+xPos
ElseIf Substr(zEnde,2,3) $("RES,SLW")
	xGal := Substr(zEnde,1,1)
	xRua := Substr(zEnde,2,3)
	xMod := Substr(zEnde,5,2)
	xNiv := Substr(zEnde,7,2)
	xPos := Substr(zEnde,9,2)
	xEnd := xGal+"-"+xRua+"-"+xMod+"-"+xNiv+"-"+xPos
Else
	xGal := Substr(zEnde,1,1)
	xRua := Substr(zEnde,2,1)
	xMod := Substr(zEnde,3,2)
	xNiv := Substr(zEnde,5,2)
	xPos := Substr(zEnde,7,2)
	xEnd := xGal+"-"+xRua+"-"+xMod+"-"+xNiv+"-"+xPos
Endif
zEnde := PadR(xEnd,15)

DbSelectArea("SBE")
DbSetOrder(1)
If !DbSeek( xFilial("SBE") + SZM->ZM_LOCAL + zEnde )
	lRet  := .F.
	zEnde := Space(15)
Else
	VTCLEAR
	@ 01,01 VTSAY "Ende.: "+zEnde
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldProd   ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida o código do produto.								  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function VldProd(zProd)

Local lRet := .T.

DbSelectArea("SB1")
DbSetOrder(1)
If !DbSeek( xFilial("SB1") + zProd )
	If AllTrim(zProd) != "VAZIO"
		lRet := .F.
	Endif	
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldQtde   ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida a quantidade por embalagem.						  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function VldQtde(zQtde)

Local lRet  := .T.
Local nQEmb := SB1->B1_QB

If SB1->B1_TIPO == "PA"
	DbSelectArea("SBZ")
	DbSetOrder(1)
	If DbSeek( xFilial("SBZ") + SB1->B1_COD )
		nQEmb := SBZ->BZ_QB
	Endif
	If nQEmb > 0
		If Mod(zQtde,nQEmb) > 0
			lRet := .F.
		Endif
	Endif		
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldArmz   ¦ Autor ¦  Luis Brandini   ¦    Data  ¦ 08/06/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida o código do armazém.								  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function VldArmz(zLocal)

Local lRet := .T.

DbSelectArea("NNR")
DbSetOrder(1)
If !DbSeek( xFilial("NNR") + zLocal )
	lRet := .F.
Endif		

Return(lRet)
