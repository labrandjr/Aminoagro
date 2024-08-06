#include "protheus.ch"
#include "rwmake.ch"        
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TLOCFAT  ¦ Autor ¦  Luis Brandini     ¦ Data ¦ 25/04/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Realocação do armazém de faturamento.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO									 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TLOCFAT()

Local oFnt
Local aCores   := {} 
Local aLegenda := {{"BR_VERDE","Liberado"},;
				   {"BR_PRETO","Bloqueio de Estoque" }}

Private cPerg     := "LIBAT2"
Private cCadastro := "Realocação do Armazém de Faturamento"
Private	cMarca    := GetMark()
Private lInverte  := .F.
Private nTotSql   := 0
Private aSize	  := {}
Private aObjects  := {}
Private aPosObj   := {}
Private aButton   := {}
Private cEOL      := CHR(13)+CHR(10)
Private aRotina	  := {}
Private nOpca     := 0
Private cLocFat   := Space(2)
Private cDLocal   := ""
Private zUsrReal  := AllTrim(GetMv("MV_XREALAR"))
Private oDlg1,cInd1TRB,oMark
Private oTempTable
Private aCampoTRB := {{ "TR_OKTLF"  , "C", 02, 0 },;
					  { "TR_PEDIDO" , "C", 06, 0 },;
					  { "TR_ITEM"   , "C", 02, 0 },;
					  { "TR_SEQUEN" , "C", 02, 0 },;
					  { "TR_BLEST"  , "C", 02, 0 },;
					  { "TR_PRODUTO", "C", 15, 0 },;
					  { "TR_ZZDESCR", "C", 40, 0 },;
					  { "TR_QTDLIB" , "N", 17, 5 },;
					  { "TR_LOCAL"  , "C", 02, 0 },;
					  { "TR_LOTECTL", "C", 10, 0 },;
					  { "TR_DATALIB", "D", 08, 0 },;
					  { "TR_CLIENTE", "C", 06, 0 },;
					  { "TR_NOMCLI" , "C", 40, 0 }}

If __cUserId != "000000"
	If !(__cUserId $ zUsrReal)
		MsgAlert("Usuário não autorizado. Contate o Administrador.")
		Return
	Endif
Endif

zUsoLft := AllTrim(GetMv("MV_ZUSOLFT"))
If !Empty(zUsoLft)
	If zUsoLft != AllTrim(cUserName)
		MsgAlert("O processo está sendo utilizado pelo usuário "+zUsoLft)
		Return
	Endif	
Else
	PutMv("MV_ZUSOLFT",cUserName)
Endif

AAdd(aRotina,{"Pesquisar" ,"AxPesqui",0,1,0,Nil})
AAdd(aRotina,{"Visualizar","AxVisual",0,2,0,Nil})
AAdd(aRotina,{"Incluir"   ,"AxInclui",0,3,0,Nil})
AAdd(aRotina,{"Alterar"   ,"AxAltera",0,4,0,Nil})
AAdd(aRotina,{"Excluir"   ,"AxDeleta",0,5,0,Nil})

DEFINE FONT oFnt1 NAME "Arial" SIZE 10,12 BOLD
DEFINE FONT oFnt2 NAME "Arial" SIZE 12,14 BOLD
	
If Pergunte(cPerg,.T.)

	If Select("TRB") > 0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	Endif

	oTempTable := FWTemporaryTable():New("TRB")
	oTemptable:SetFields(aCampoTRB)
	oTempTable:AddIndex("indice1", {"TR_PEDIDO", "TR_ITEM", "TR_SEQUEN"})
	oTempTable:Create()

//	cArqTRB := CriaTrab(aCampoTRB,.T.)
//	DbUseArea(.T.,,cArqTRB,"TRB",.F.)
//	cInd1TRB := CriaTrab(Nil,.F.)
//	IndRegua("TRB",cInd1TRB,"TR_PEDIDO+TR_ITEM+TR_SEQUEN",,,"Gerando arquivo de trabalho...")
//	DbSelectArea("TRB")
//	DbSetIndex(cInd1TRB + OrdBagExt())

	DbSelectArea("TRB")
	DbSetOrder(1)

	Processa( {|| _CargaDados()}, "Processando.." )

	// Monta o Browse
	aCampos := {}
	AAdd(aCampos,{"TR_OKTLF"  ,"",""          ,""  ,"02","00"})
	AAdd(aCampos,{"TR_PEDIDO" ,"","Pedido"    ,"@!","06","00"})
	AAdd(aCampos,{"TR_ITEM"   ,"","Item"      ,"@!","02","00"})
	AAdd(aCampos,{"TR_SEQUEN" ,"","Sequência" ,"@!","02","00"})
	AAdd(aCampos,{"TR_PRODUTO","","Produto"   ,"@!","15","00"})
	AAdd(aCampos,{"TR_ZZDESCR","","Descrição" ,"@!","40","00"})
	AAdd(aCampos,{"TR_QTDLIB" ,"","Qtd.Liberada" ,"@E 9,999,999.99","11","02"})
	AAdd(aCampos,{"TR_LOCAL"  ,"","Armazém"   ,"@!","02","00"})
	AAdd(aCampos,{"TR_LOTECTL","","Lote"      ,"@!","10","00"})
	AAdd(aCampos,{"TR_DATALIB","","Data Lib." ,""  ,"08","00"})
	AAdd(aCampos,{"TR_CLIENTE","","Cliente"   ,"@!","06","00"})
	AAdd(aCampos,{"TR_NOMCLI" ,"","Nome"      ,"@!","40","00"})

	DbSelectArea("TRB")
	TRB->(DbGotop())

	aSize := MsAdvSize()
	nOpca := 0

	DEFINE MSDIALOG oDlg1 TITLE "Realocação do Armazém de Faturamento" From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL

	oDlg1:lMaximized := .T.
		
	oPanel := TPanel():New(0,0,"",oDlg1,, .T., .T.,,,315,000,.T.,.T.)
	oPanel:Align := CONTROL_ALIGN_TOP

	AAdd(aCores, {"Empty(TRB->TR_BLEST)" ,"BR_VERDE"} )
	AAdd(aCores, {"!Empty(TRB->TR_BLEST)","BR_PRETO"} )  

	oMark := MsSelect():New("TRB","TR_OKTLF",,aCampos,@lInverte,@cMarca,{50,oDlg1:nLeft,oDlg1:nBottom,oDlg1:nRight},,,,,aCores)
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oMark:bMark := {|| _TrfDisp(cMarca,lInverte)}
	oMark:oBrowse:lhasMark = .T.
	oMark:oBrowse:lCanAllmark := .T.
	oMark:oBrowse:bAllMark := { || _TrfInverte(cMarca,lInverte) }
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	AAdd( aButton, { "S4WB011N", { || _Pesquisar(oMark)},"Pesquisar..(CTRL-P)","Pesquisar"} )
	AAdd( aButton, { "NOTE"    , { || BrwLegenda("Realocação de Armazém","Legenda",aLegenda) }, "Status", "Legenda" } )

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||_Question()},{||nOpca:= 2,oDlg1:End()},,aButton) CENTERED

	If nOpca == 1
		u_ProcTransf()
	Endif

	If Select("TRB") > 0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
		oTempTable:Delete()
	Endif

	PutMv("MV_ZUSOLFT","")

Else

	PutMv("MV_ZUSOLFT","")

Endif	

Return        

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ğ------------------Ğ---------------------------Ğ-------------+¦¦
¦¦¦Funcao    ¦ _CargaDados ¦ Autor ¦ Luis Brandini   ¦ Data ¦ 25/04/2018  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Carrega os dados no arquivo temporario.					  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO 		 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _CargaDados()

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SC9")+" SC9, "
cQuery += RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " AND F4_FILIAL = '"+xFilial("SF4")+"' "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND C9_FILIAL = C6_FILIAL "
cQuery += " AND C9_PEDIDO = C6_NUM "
cQuery += " AND C9_ITEM = C6_ITEM "
cQuery += " AND C6_TES = F4_CODIGO "
cQuery += " AND C9_CLIENTE = A1_COD "
cQuery += " AND C9_LOJA = A1_LOJA "
cQuery += " AND C9_PRODUTO = B1_COD "
cQuery += " AND C9_PEDIDO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += " AND C9_CLIENTE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND C9_DATENT BETWEEN '"+DtoS(mv_par05)+"' AND '"+DtoS(mv_par06)+"' "
cQuery += " AND C9_BLCRED = ' ' "
cQuery += " AND F4_ESTOQUE = 'S' "
cQuery += " AND C6_BLQ = ' ' "
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

cQuery := " SELECT C9_PEDIDO PEDIDO, C9_ITEM ITEM, C9_SEQUEN SEQUEN, C9_PRODUTO PRODUTO, B1_DESC DESCRI, C9_QTDLIB QTDLIB, "
cQuery += " C9_LOCAL ARMAZEM, C9_LOTECTL LOTECTL, C9_DATALIB DATALIB, C9_CLIENTE CLIENTE, A1_NOME NOMCLI, C9_BLEST BLEST "
cQuery += " FROM "+RetSqlName("SC9")+" SC9, "
cQuery += RetSqlName("SC6")+" SC6, "
cQuery += RetSqlName("SF4")+" SF4, "
cQuery += RetSqlName("SB1")+" SB1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " AND F4_FILIAL = '"+xFilial("SF4")+"' "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND C9_FILIAL = C6_FILIAL "
cQuery += " AND C9_PEDIDO = C6_NUM "
cQuery += " AND C9_ITEM = C6_ITEM "
cQuery += " AND C6_TES = F4_CODIGO "
cQuery += " AND C9_CLIENTE = A1_COD "
cQuery += " AND C9_LOJA = A1_LOJA "
cQuery += " AND C9_PRODUTO = B1_COD "
cQuery += " AND C9_PEDIDO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += " AND C9_CLIENTE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
cQuery += " AND C9_DATENT BETWEEN '"+DtoS(mv_par05)+"' AND '"+DtoS(mv_par06)+"' "
cQuery += " AND C9_BLCRED = ' ' "
cQuery += " AND F4_ESTOQUE = 'S' "
cQuery += " AND C6_BLQ = ' ' "
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
SQL->(DbGotop())
ProcRegua(nTotSql)
DbSelectArea("SQL")
While SQL->(!Eof())

	IncProc("Pedido "+SQL->PEDIDO)

	DbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->TR_OKTLF   := Space(2)
	TRB->TR_PEDIDO  := SQL->PEDIDO
	TRB->TR_ITEM    := SQL->ITEM
	TRB->TR_SEQUEN  := SQL->SEQUEN
	TRB->TR_BLEST   := SQL->BLEST
	TRB->TR_PRODUTO := SQL->PRODUTO
	TRB->TR_ZZDESCR := SQL->DESCRI
	TRB->TR_QTDLIB  := SQL->QTDLIB
	TRB->TR_LOCAL   := SQL->ARMAZEM
	TRB->TR_LOTECTL := SQL->LOTECTL
	TRB->TR_DATALIB := StoD(SQL->DATALIB)
	TRB->TR_CLIENTE := SQL->CLIENTE
	TRB->TR_NOMCLI  := SQL->NOMCLI
	MsUnLock()

	DbSelectArea("SQL")
	SQL->(DbSkip())

Enddo
SQL->(DbCloseArea())

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ğ------------------Ğ---------------------------Ğ-------------+¦¦
¦¦¦Funcao    ¦ _Pesquisar ¦ Autor ¦ Luis Brandini    ¦ Data ¦ 25/04/2018  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Pesquisa registro.										  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO 		 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Pesquisar(oMark)

Local oDlg1
Local oCbx
Local oBigGet
Local cOrd	 := ""
Local aOrd	 := {}
Local cCampo := Space(30)
Local lSeek	 := .F.
Local nOrdem := 1

AAdd(aOrd,"Pedido")
AAdd(aOrd,"Produto")

DEFINE MSDIALOG oDlg1 FROM 00,00 TO 100,490 PIXEL TITLE "Pesquisa"

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg1 FONT oDlg1:oFont ON CHANGE nOrdem := oCbx:nAt
@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg1 ENABLE ACTION (lSeek:=.T.,oDlg1:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg1 ENABLE ACTION oDlg1:End()

ACTIVATE MSDIALOG oDlg1 CENTERED

If lSeek

	If nOrdem == 1

		IndRegua("TRB",cInd1TRB,"TR_PEDIDO+TR_ITEM+TR_SEQUEN",,,"Gerando arquivo de trabalho...")
		DbSelectArea("TRB")
		DbSetIndex(cInd1TRB + OrdBagExt())
		cChave := PadR(AllTrim(cCampo),6)
		DbSeek(cChave,.T.)

	ElseIf nOrdem == 2

		IndRegua("TRB",cInd1TRB,"TR_PRODUTO+TR_PEDIDO+TR_ITEM+TR_SEQUEN",,,"Gerando arquivo de trabalho...")
		DbSelectArea("TRB")
		DbSetIndex(cInd1TRB + OrdBagExt())
		cChave := PadR(AllTrim(cCampo),15)
		DbSeek(cChave,.T.)

	Endif

Endif

oMark:oBrowse:Refresh(.T.)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ğ------------------Ğ---------------------------Ğ-------------+¦¦
¦¦¦Funcao    ¦ _TrfDisp   ¦ Autor ¦ Luis Brandini    ¦ Data ¦ 25/04/2018  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Atualiza variaveis na tela.								  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO 		 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _TrfDisp(cMarca,lInverte)

Local nRecTRB := TRB->(Recno())
Local zPedido := TRB->TR_PEDIDO
Local zItemPv := TRB->TR_ITEM

If IsMark("TR_OKTLF",cMarca,lInverte)
	zUpd := cMarca
Else
	zUpd := Space(2)
Endif

DbSelectArea("TRB")
TRB->(DbGotop())
While !Eof()
	If TRB->TR_PEDIDO == zPedido .And. TRB->TR_ITEM == zItemPv
		RecLock("TRB",.F.)
		TRB->TR_OKTLF := zUpd
		MsUnLock()
	Endif	
	TRB->(DbSkip())
Enddo
TRB->(DbGoto(nRecTRB))

oMark:oBrowse:Refresh(.T.)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ğ------------------Ğ---------------------------Ğ-------------+¦¦
¦¦¦Funcao    ¦ _TrfInverte ¦ Autor ¦ Luis Brandini   ¦ Data ¦ 25/04/2018  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Inverte a seleção dos registros.						  	  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo AMINOAGRO		 								  ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _TrfInverte(cMarca,lInverte)

Local nReg := TRB->(Recno())

DbSelectArea("TRB")
TRB->(DbGotop())
While !Eof()

	RecLock("TRB",.F.)
	If IsMark("TR_OKTLF",cMarca,lInverte) .Or. lInverte
		Replace TRB->TR_OKTLF With Space(2)
	Else
		Replace TRB->TR_OKTLF With cMarca
	Endif		
	MsUnLock()

	DbSelectArea("TRB")
	TRB->(DbSkip())

Enddo
TRB->(DbGoto(nReg))

oMark:oBrowse:Refresh(.T.)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ _Question ¦ Autor ¦  Luis Brandini   ¦ Data ¦ 25/04/2018   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Solicita confirmação do usuário antes do processamento.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO									 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Question()

Local aArea := GetArea()
Local lProc := .F.
Local lSele := .F.

Private nOpcRep := 0
Private bActOk  := {|| nOpcRep:=1,oDlgRep:End() }
Private bActCan := {|| nOpcRep:=0,oDlgRep:End() }
Private bOkRep  := {|| IIf( MsgYesNo("Confirma realocação?","Confirmar"), Eval(bActOk), .F.) }
Private bCanRep := {|| IIf( MsgYesNo("Abandona realocação?","Sair"), Eval(bActCan), .F.) }
Private oFnt2   := TFont():New("Tahoma",,12,,.T.)
Private oDlgRep, oSayLoc, oLocFat

DbSelectArea("TRB")
TRB->(DbGotop())
While !Eof()
	If IsMark("TR_OKTLF",cMarca,lInverte)
		lSele := .T.
		Exit
	Endif
	TRB->(DbSkip())
Enddo
TRB->(DbGotop())
If !lSele
	MsgInfo("Nenhum item selecionado.")
	Return
Endif

DEFINE MSDIALOG oDlgRep FROM 001,001 TO 200,650 TITLE "Selecione o Armazém" OF oDlgRep PIXEL
@ 052,050 SAY "Armazém" OF oDlgRep PIXEL SIZE 055,009
@ 050,095 MSGET oLocFat VAR cLocFat SIZE 010,010 OF oDlgRep PIXEL PICTURE "@!" F3 "NNR" VALID VldNNR()
@ 050,130 TO 062,265 LABEL "" OF oDlgRep PIXEL
oSayLoc:= TSay():New(053,133,{||""},oDlgRep,,oFnt2,,,,.T.,CLR_BLUE,CLR_WHITE,200,020)
oSayLoc:SetText( cDLocal )
oSayLoc:CtrlRefresh()
ACTIVATE MSDIALOG oDlgRep ON INIT EnchoiceBar(oDlgRep,bOkRep,bCanRep) CENTERED

If nOpcRep == 1
	lProc := .T.
Endif

If !lProc
	Return
Else
	nOpca := 1
	oDlg1:End()
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldNNR    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 27/04/2018   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do armazém.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldNNR()

Local lRetorno := ( ExistCpo("NNR") )

If lRetorno
	cDLocal := Posicione("NNR",1,xFilial("NNR")+cLocFat,"NNR_DESCRI")
	oSayLoc:SetText( cDLocal )
	oSayLoc:Refresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ProcTransf ¦ Autor ¦  Luis Brandini   ¦ Data ¦ 25/04/2018  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada para processamento principal.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO									 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcTransf()

Processa( {|| _Transferir()}, "Processando.." )  

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ _Transferir ¦ Autor ¦  Luis Brandini   ¦ Data ¦ 25/04/2018 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO									 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Transferir()

Local aArea := GetArea()
Local aTran := {}
Local _x

DbSelectArea("TRB")
DbSetOrder(1)
TRB->(DbGotop())
ProcRegua(RecCount())
While !Eof()

	IncProc("Processando... aguarde")
	
	If IsMark("TR_OKTLF",cMarca,lInverte)
		If TRB->TR_LOCAL != cLocFat
			lNew := .F.
			If Len(aTran) == 0
				lNew := .T.
			Else
				nPos := aScan(aTran, {|x| x[1] == TRB->TR_PEDIDO .And. x[2] == TRB->TR_ITEM })
				If nPos == 0
					lNew := .T.
				Else
					aTran[nPos][3] += TRB->TR_QTDLIB
				Endif
			Endif	
			If lNew
				AAdd(aTran,{TRB->TR_PEDIDO, TRB->TR_ITEM, TRB->TR_QTDLIB})
			Endif
		Endif		
	Endif

	DbSelectArea("TRB")
	TRB->(DbSkip())

Enddo

For _x := 1 to Len(aTran)

	Begin Transaction 

	zPedido := aTran[_x][1]
	zItemPv := aTran[_x][2]
	zQtdLib := aTran[_x][3]

	DbSelectArea("TRB")
	DbSetOrder(1)
	DbSeek( zPedido + zItemPv )

	zProdu := TRB->TR_PRODUTO 
	zLocal := TRB->TR_LOCAL

	While !Eof() .And. TRB->(TR_PEDIDO+TR_ITEM) == zPedido + zItemPv

		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek( xFilial("SC6") + TRB->TR_PEDIDO + TRB->TR_ITEM )
	
		DbSelectArea("SC9")
		DbSetOrder(1)
		DbSeek( xFilial("SC9") + TRB->TR_PEDIDO + TRB->TR_ITEM + TRB->TR_SEQUEN )

		a460Estorna()

		DbSelectArea("TRB")
		TRB->(DbSkip())
	Enddo

	// 2. Altera armazém
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( xFilial("SB2") + zProdu + zLocal )

	RecLock("SB2",.F.)
	SB2->B2_QPEDVEN -= SC6->(C6_QTDVEN-C6_QTDENT)
	MsUnLock()

	DbSelectArea("SB2")
	DbSetOrder(1)
	If !DbSeek( xFilial("SB2") + zProdu + cLocFat )
		RecLock("SB2",.T.)
		SB2->B2_FILIAL  := xFilial("SB2")
		SB2->B2_COD     := zProdu
		SB2->B2_LOCAL   := cLocFat
		SB2->B2_LOCALIZ := "PRODUTO ACABADO"
		SB2->B2_TIPO    := "1"
		MsUnLock()
	Endif

	RecLock("SB2",.F.)
	SB2->B2_QPEDVEN += SC6->(C6_QTDVEN-C6_QTDENT)
	MsUnLock()

	RecLock("SC6",.F.)
	SC6->C6_LOCAL := cLocFat
	MsUnLock()

	// 3. Liberação no novo armazém
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( xFilial("SC6") + zPedido + zItemPv )

	nRegSC6   := SC6->(Recno())
	nQtdaLib  := zQtdLib
	lCredito  := .T.
	lEstoque  := .T.
	lAvCred   := .F.
	lAvEst    := .T.
	lLibPar   := .F.
	lTrfLocal := .F.

//	MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,nVlrCred,nQtdalib2)
	MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal)

	End Transaction
	MsUnLockAll()

Next _x

MsgInfo("Processamento concluído !!")

RestArea(aArea)

Return

//Function A460Estorna(lMata410,lAtuEmp,nVlrCred,cTipLib)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a460Estorn³ Autor ³Eduardo Riera          ³ Data ³31.03.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o estorno da liberacao do pedido de venda            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se houve o estorno                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Indica se o programa chamador eh o MATA410           ³±±
±±³			 ³ExpL2: Indica se Atualizará Empenhos				          ³±±
±±³          ³ExpN3: Valor a ser adicionado ao limite de credito          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Deve estar numa transacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³16/05/2007³Norbert Waage  ³Bops 125161 - Atualizacao do status do orca-³±±
±±³          ³               ³mento no Televendas (SIGATMK) apos estorno. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Function MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,nVlrCred,nQtdalib2)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaLibDoFat³ Autor ³Eduardo Riera          ³ Data ³09.03.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Liberacao dos Itens de Pedido de Venda                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Quantidade Liberada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Transacao ³Nao possui controle de Transacao a rotina chamadora deve    ³±±
±±³          ³controlar a Transacao e os Locks                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Registro do SC6                                      ³±±
±±³          ³ExpN2: Quantidade a Liberar                                 ³±±
±±³          ³ExpL3: Bloqueio de Credito                                  ³±±
±±³          ³ExpL4: Bloqueio de Estoque                                  ³±±
±±³          ³ExpL5: Avaliacao de Credito                                 ³±±
±±³          ³ExpL6: Avaliacao de Estoque                                 ³±±
±±³          ³ExpL7: Permite Liberacao Parcial                            ³±±
±±³          ³ExpL8: Tranfere Locais automaticamente                      ³±±
±±³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³±±
±±³          ³       apenas avalia ).                                     ³±±
±±³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³±±
±±³          ³ExpAB: Array com Empenhos previamente escolhidos            ³±±
±±³          ³       (impede selecao dos empenhos pelas rotinas)          ³±±
±±³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³±±
±±³          ³ExpND: Valor a ser adicionado ao limite de credito          ³±±
±±³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Deve estar numa transacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
