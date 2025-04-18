#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � AMNC010   � Autor �  F�brica ERP.BR   �   Data  � 09/02/17 ���
��+----------+------------------------------------------------------------���
���Descricao � Calcula forma��o de pre�os dos produtos baseado no 	      ���
���          � processo padr�o STANDARD.PDV.							  ���
���          � Cria��o de planilha espec�fica AMINOAGR.PDV.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo AMINOAGRO 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AMNC010()

Local lOk    := .F.
Local lEnd	 := .F.
Local cPerg	 := Padr("AMNC010",10)
Local oFnt1  := TFont():New("Tahoma",,18,,.T.)
Local oFnt2  := TFont():New("Tahoma",,15,,.T.)
Local oFnt3  := TFont():New("Tahoma",,14,,.F.)
Private cEOL := CHR(13)+CHR(10)
Private oDlgUpd, oProcess

If !(__cUserId $ ( AllTrim(GetMv("MV_XGEREST")) )) // Administrador, Jefferson Costa, Paul Bergman
	MsgAlert("Usu�rio n�o autorizado. Contate o Administrador.")
	Return
Endif

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlgUpd FROM 001,001 TO 350,650 TITLE "Forma��o de Pre�os | Planilha AMINOAGR.PDV" OF oDlgUpd PIXEL

@ 005,005 TO 030,320 LABEL "" OF oDlgUpd PIXEL
oTitulo:= TSay():New(013,100,{||"CALCULO DA FORMA��O DE PRE�OS"},oDlgUpd,,oFnt1,,,,.T.,CLR_BLACK,CLR_WHITE,300,020)
oTitulo:CtrlRefresh()            

@ 045,005 TO 140,320 LABEL "" OF oDlgUpd PIXEL
oText1:= TSay():New(050,010,{||"Esta rotina tem como objetivo calcular a forma��o de pre�os dos produtos baseado"},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText1:CtrlRefresh()

oText2:= TSay():New(060,010,{||"no cadastro de estruturas, e na planilha 'aminoagr.pdv'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText2:CtrlRefresh()

oText3:= TSay():New(070,010,{||"O filtro desejado e filiais para processamento devem ser informados em 'Par�metros'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText3:CtrlRefresh()

oText4:= TSay():New(080,010,{||"A vis�o anal�tica do calculo encontra-se em 'Consultas/Forma��o de Pre�os'."},oDlgUpd,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,300,020)
oText4:CtrlRefresh()

@ 150,005 BUTTON "Processar"  SIZE 070,015 FONT oDlgUpd:oFont ACTION Preparar()          OF oDlgUpd PIXEL
@ 150,127 BUTTON "Cancelar"   SIZE 070,015 FONT oDlgUpd:oFont ACTION oDlgUpd:End()       OF oDlgUpd PIXEL
@ 150,250 BUTTON "Par�metros" SIZE 070,015 FONT oDlgUpd:oFont ACTION Pergunte(cPerg,.T.) OF oDlgUpd PIXEL

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � Preparar  � Autor � Fabrica ERPBR    � Data �  04/02/17	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Prepara o processamento principal.						  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Preparar()

If MsgYesNo("Confirma o processamento - FORMA��O DE PRE�OS ?","Aviso","INFO")
	oProcess := MsNewProcess():New( { | lEnd | lOk := u_ProcCalc() }, "Calculando forma��o de pre�os", "Aguarde, processando ...", .F. )
	oProcess:Activate()
	oDlgUpd:End()
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcCalc � Autor  � Fabrica ERPBR     � Data �  04/02/17	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento do calculo.								  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo AMINOAGRO										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ProcCalc(cProduto)

Local nRecSM0   := SM0->(Recno())
Local xFilOri   := cFilAnt
Local aArray	:= {}
Local aArray1	:= {}
Local aPar		:= Array(20)
Local aParC010	:= Array(20)
Local lFirstCb	:= .T.
Local nReg
Local nI, nX
Local cCondFiltr:= ""
Local nForFilial
Local aFilsCalc
Local lExclusiv := (cProduto != Nil)

//��������������������������������������������������������������Ŀ
//� Variaveis privadas exclusivas deste programa                 �
//����������������������������������������������������������������
Private cProg := "R430"  // Usada na funcao externa MontStru()

//����������������������������������������������������������������Ŀ
//� Custo a ser considerado nos calculos                           �
//� 1 = STANDARD    2 = MEDIO     3 = MOEDA2     4 = MOEDA3        �
//� 5 = MOEDA4      6 = MOEDA5    7 = ULTPRECO   8 = PLANILHA      �
//������������������������������������������������������������������
Private nQualCusto := 1

//��������������������������������������������������������������Ŀ
//� Vetor declarado para inversao do calculo do Valor Unitario   �
//� Utilizado no MATC010X -> M010Forma e CalcTot                 �
//����������������������������������������������������������������
Private aAuxCusto

//����������������������������������������������������������������Ŀ
//� Nome do arquivo que contem a memoria de calculo desta planilha �
//������������������������������������������������������������������
Private cArqMemo := "AMINOAGR"

//����������������������������������������������������������������Ŀ
//� Direcao do calculo .T. para baixo .F. para cima                �
//������������������������������������������������������������������
Private lDirecao := .T.

Private lConsNeg := .T. //(mv_par08 = 1)     // Esta variavel sera' usada na funcao MC010FORMA

// Inicializa vari�veis
If !lExclusiv
	cProdDe   := mv_par01
	cProdAte  := mv_par02
	cTipoDe   := mv_par03
	cTipoAte  := mv_par04
	cGrupoDe  := mv_par05
	cGrupoAte := mv_par06
	aFilsCalc := MatFilCalc( mv_par07 == 1 )
Else
	aFilsCalc := MatFilCalc( .F. )
Endif
// 

Pergunte("MTR430",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Produto inicial                              �
//� mv_par02     // Produto final                                �
//� mv_par03     // Nome da planilha utilizada                   �
//� mv_par04     // Imprime estrutura : Sim / Nao                �
//� mv_par05     // Moeda Secundaria  : 1 2 3 4 5                �
//� mv_par06     // Nivel de detalhamento da estrutura           �
//� mv_par07     // Qual a Quantidade Basica                     �
//� mv_par08     // Considera Qtde Neg na estrutura: Sim/Nao     �
//� mv_par09     // Considera Estrutura / Pre Estrutura          �
//� mv_par10     // Revisao da Estrutura 				         �
//����������������������������������������������������������������
//����������������������������������������������������������������Ŀ
//� Forca utilizacao da estrutura caso nao tenha SGG               �
//������������������������������������������������������������������
If Select("SGG") == 0
	mv_par09 := 1
Endif
//Salvar variaveis existentes
For ni := 1 to 20
	aPar[ni] := &("mv_par"+StrZero(ni,2))
Next ni

Pergunte("MTC010",.F.)
//����������������������������������������������������������������Ŀ
//� Forca utilizacao da estrutura caso nao tenha SGG               �
//������������������������������������������������������������������
If Select("SGG") == 0
	mv_par09 := 1
Endif
//Salvar variaveis existentes
For ni := 1 to 20
	aParC010[ni] := &("mv_par"+StrZero(ni,2))
Next ni
//Forca mesmo valor do relatorio na pergunta 09
mv_par09     := aPar[09]
aParC010[09] := aPar[09]

// Restaura parametros MTR430
For ni := 1 to 20
	&("mv_par"+StrZero(ni,2)) := aPar[ni]
Next ni

//��������������������������������������������������������������������������Ŀ
//� Inicializa o nome padrao da planilha com o nome selecionado pelo usuario � 
//����������������������������������������������������������������������������
cArqMemo := "AMINOAGR"

// Inicio do Processamento
For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[nForFilial][1]
	
		cFilAnt := AllTrim(aFilsCalc[nForFilial][2])
		cNomFil := AllTrim(aFilsCalc[nForFilial][3])

		cQuery := " SELECT COUNT(DISTINCT(G1_COD)) AS SOMA "
		cQuery += " FROM "+RetSqlName("SG1")+" SG1, "
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE G1_FILIAL = '"+cFilAnt+"'
		cQuery += " AND G1_COD = B1_COD "
		If !lExclusiv
			cQuery += " AND G1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' "
			cQuery += " AND B1_GRUPO BETWEEN '"+cGrupoDe+"' AND '"+cGrupoAte+"' "
			cQuery += " AND B1_TIPO BETWEEN '"+cTipoDe+"' AND '"+cTipoAte+"' "
		Else
			cQuery += " AND B1_COD = '"+cProduto+"' "
		Endif
		cQuery += " AND SG1.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		nTotSql := SQL->SOMA
		SQL->(DbCloseArea())

		If !lExclusiv
			oProcess:SetRegua1(nTotSql)
		Endif	

		cQuery := " SELECT DISTINCT(G1_COD) AS CODIGO "
		cQuery += " FROM "+RetSqlName("SG1")+" SG1, "
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE G1_FILIAL = '"+cFilAnt+"'
		cQuery += " AND G1_COD = B1_COD "
		If !lExclusiv
			cQuery += " AND G1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' "
			cQuery += " AND B1_GRUPO BETWEEN '"+cGrupoDe+"' AND '"+cGrupoAte+"' "
			cQuery += " AND B1_TIPO BETWEEN '"+cTipoDe+"' AND '"+cTipoAte+"' "
		Else
			cQuery += " AND B1_COD = '"+cProduto+"' "
		Endif
		cQuery += " AND SG1.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY G1_COD "
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

		DbSelectArea("SQL")
		SQL->(DbGotop())
		While !Eof()
		
			If !lExclusiv
				oProcess:IncRegua1("Processando Filial "+AllTrim(cFilAnt)+" - "+AllTrim(cNomFil))
			Endif	

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + SQL->CODIGO )
			
			// Restaura parametros MTC010
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aParc010[ni]
			Next ni
			
			aArray1 := MC010Forma("SB1",nReg,99,1/*apar[07]*/,,.F.,apar[10])
						
			// Restaura parametros MTR430
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aPar[ni]
			Next ni
			
			If Len(aArray1) > 0
				aArray := aClone(aArray1[2])
				//
				If !lExclusiv
					If AllTrim(SB1->B1_COD) == AllTrim(aArray[1][4])
						DbSelectArea("SZA")
						DbSetOrder(1)
						If !DbSeek( cFilAnt + SB1->B1_COD )  
							RecLock("SZA",.T.)
							SZA->ZA_FILIAL  := cFilAnt
							SZA->ZA_PRODUTO := SB1->B1_COD
							SZA->ZA_DESCRI  := SB1->B1_DESC
							SZA->ZA_TIPO    := SB1->B1_TIPO
							SZA->ZA_GRUPO   := SB1->B1_GRUPO
						Else
							RecLock("SZA",.F.)
						Endif
						SZA->ZA_CUSTOT := aArray[1][6]
						// (MP) Embalagem
						nPos := aScan(aArray, {|x| Substr(x[3],1,15) == "TOTAL DE MP (EM"})
						If nPos > 0
							SZA->ZA_CUSEMB := aArray[nPos][6]
							SZA->ZA_PEREMB := Round(aArray[nPos][7],2)
						Endif	
						// (MP) Solu��o
						nPos := aScan(aArray, {|x| Substr(x[3],1,15) == "TOTAL DE MP (SO"})
						If nPos > 0
							SZA->ZA_CUSSOL := aArray[nPos][6]
							SZA->ZA_PERSOL := Round(aArray[nPos][7],2)
						Endif	
						// (MO) M�o de Obra MOD
						nPos := aScan(aArray, {|x| Substr(x[3],1,12) == "TOTAL DE MOD"})
						If nPos > 0
							SZA->ZA_CUSMOD := aArray[nPos][6]
							SZA->ZA_PERMOD := Round(aArray[nPos][7],2)
						Endif	
						// (MO) M�o de Obra MOI (CIF)
						nPos := aScan(aArray, {|x| Substr(x[3],1,12) == "TOTAL DE MOI"})
						If nPos > 0					
							SZA->ZA_CUSMOI := aArray[nPos][6]
							SZA->ZA_PERMOI := Round(aArray[nPos][7],2)
						Endif	
						SZA->ZA_DATA := Date()
						SZA->ZA_USER := cUserName
						MsUnLock()
					Endif
				Endif	
				//
			Endif

			DbSelectArea("SQL")
			SQL->(DbSkip())

		Enddo
		SQL->(DbCloseArea())

	Endif	
	
Next nForFilial

SM0->(DbGoto(nRecSM0))
cFilAnt := xFilOri

If !lExclusiv
	MsgInfo("Processamento conclu�do!","Calculo da Forma��o de Pre�os")
Else
	Return(aArray)
Endif	

Return
