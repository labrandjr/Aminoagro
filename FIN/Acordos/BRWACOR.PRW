#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ BRWACOR   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Browse principal do Módulo de Acordos.					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BRWACOR()

Private cCadastro := "Gestão de Acordos"

Private aCores := {{"Z01_STATUS == 'A'" , "BR_VERDE"    },;
				   {"Z01_STATUS == 'L'" , "BR_AZUL"     },;
				   {"Z01_STATUS == 'E'" , "BR_VERMELHO" }}

Private aCoresLeg := {{"BR_VERDE"	 , "Em Aberto"     },;
					  {"BR_AZUL"	 , "Em Liquidação" },;
					  {"BR_VERMELHO" , "Encerrado"     }}

Private aRotina := {{"Pesquisar"     , "AxPesqui"    , 0 , 1 },;
            	    {"Visualizar"    , "U_ACOR01V()" , 0 , 2 },;
            	    {"Incluir"       , "U_ACOR01I()" , 0 , 3 },;
            	    {"Parcelas"      , "U_ACOR01P()" , 0 , 4 },;
            	    {"Alterar"       , "U_ACOR01A()" , 0 , 5 },;
            	    {"Excluir"       , "U_ACOR01E()" , 0 , 6 },;
            	    {"Renegociar"    , "U_ACOR01R()" , 0 , 7 },;
            	    {"Movimentações" , "U_ACOR01M()" , 0 , 8 },;
					{"Legenda"       , "BrwLegenda(cCadastro,cLegenda,aCoresLeg)" , 0 , 10 }}

Private cEOL      := CHR(13)+CHR(10) 
Private cLegenda  := "Legenda"

u_UpdSldAco()

DbSelectArea("Z01")
DbSetOrder(1)
Z01->(DbGotop())
MBrowse(6,1,22,75,"Z01",,,,,,aCores)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR01V   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Visualiza o Acordo.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR01V()

U_AcUpdLeg(Z01->Z01_FILIAL,Z01->Z01_ACORDO)

U_ACOR020(Nil,"V")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR01I   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Inclusão do Acordo.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR01I()

U_ACOR010()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR01A   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Alteração do Acordo.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR01A()

U_AcUpdLeg(Z01->Z01_FILIAL,Z01->Z01_ACORDO)

DbSelectArea("SE5")
DbSetOrder(7)
If DbSeek( xFilial("SE5") + "ACO" + Z01->Z01_ACORDO )
	MsgAlert("Não é permitido alterar um acordo que possui movimentações.")
	Return
Endif

If Z01->Z01_STATUS == "E"
	MsgAlert("Não é permitido alterar um acordo encerrado.")
	Return
Endif

If Z01->Z01_STATUS == "L"
	MsgAlert("Não é permitido alterar um acordo em liquidação.")
	Return
Endif

U_ACOR020(Nil,"A")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR01E   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Exclusão do Acordo.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR01E()

U_AcUpdLeg(Z01->Z01_FILIAL,Z01->Z01_ACORDO)

DbSelectArea("SE5")
DbSetOrder(7)
If DbSeek( xFilial("SE5") + "ACO" + Z01->Z01_ACORDO )
	MsgAlert("Não é permitido excluir um acordo que possui movimentações.")
	Return
Endif

If Z01->Z01_STATUS == "E"
	MsgAlert("Não é permitido excluir um acordo encerrado.")
	Return
Endif

If Z01->Z01_STATUS == "L"
	MsgAlert("Não é permitido excluir um acordo em liquidação.")
	Return
Endif

U_ACOR020(Nil,"E")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR01R   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  09/10/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Renegociação do Acordo.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR01R()

Local aTitSel := {}
Private cAcordo := ""
Private cAcoRen := Z01->Z01_ACORDO
Private nValTit := 0

U_AcUpdLeg(Z01->Z01_FILIAL,Z01->Z01_ACORDO)

If Z01->Z01_STATUS == "E"
	MsgAlert("Não é permitido renegociar um acordo encerrado.")
	Return
Endif

zRecZ01 := Z01->(Recno())
DbSelectArea("Z01")
DbSetOrder(3)
If DbSeek( xFilial("Z01") + Z01->Z01_ACORDO )
	MsgAlert("Este acordo já foi renegociado (No. "+Z01->Z01_ACORDO+").")
	Return
Endif
Z01->(DbGoto(zRecZ01))

dUlMov := CtoD("")
DbSelectArea("SE5")
DbSetOrder(7)
If DbSeek( xFilial("SE5") + "ACO" + Z01->Z01_ACORDO )
	While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO) == xFilial("SE5") + "ACO" + Z01->Z01_ACORDO
		If SE5->E5_DATA > dUlMov
			dUlMov := SE5->E5_DATA
		Endif		
		SE5->(DbSkip())
	Enddo
Endif

If dDatabase < dUlMov
	MsgAlert("A emissão da renegociação não pode ser menor que a última movimentação ("+DtoC(dUlMov)+").")
	Return
Endif

cPrxNum := u_PrxAcor()
cAcordo := cPrxNum
nValTit := u_SdoAcor(Z01->Z01_ACORDO)

DbSelectArea("ZE1")
DbSetOrder(1)
If DbSeek( xFilial("ZE1") + Z01->Z01_ACORDO )
	While !Eof() .And. ZE1->ZE1_FILIAL == xFilial("ZE1") .And. ZE1->ZE1_ACORDO == Z01->Z01_ACORDO
		//
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek( ZE1->(ZE1_FILIAL+ZE1_PREFIX+ZE1_NUM+ZE1_PARCEL+ZE1_TIPO+ZE1_CLIENT) )
		AAdd(aTitSel,SE1->(Recno()))
        //
		ZE1->(DbSkip())
	Enddo
Else
	MsgAlert("Renegociação não permitida.")
Endif

U_ACOR020(aTitSel,"R")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR01P   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Parcelas do Acordo.									  	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR01P()

U_AcUpdLeg(Z01->Z01_FILIAL,Z01->Z01_ACORDO)

U_ACOR030()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ACOR01M   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  20/08/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Movimentações do acordo.				  					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ACOR01M()

U_AcUpdLeg(Z01->Z01_FILIAL,Z01->Z01_ACORDO)

DbSelectArea("SE5")
DbSetOrder(7)
If !DbSeek( xFilial("SE5") + "ACO" + Z01->Z01_ACORDO )
	MsgAlert("O acordo não possui movimentações.")
	Return
Endif

U_ACOR050("A")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ AcUpdLeg  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  05/10/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Atualização da legenda dos Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AcUpdLeg(zFilial,zAcordo)

Local aArea   := GetArea()
Local zStatus := "A"
Local e1Valor := 0
Local e1Saldo := 0
 
DbSelectArea("SE1")
DbSetOrder(1)
If DbSeek( zFilial + "ACO" + zAcordo )
	While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == zFilial + "ACO" + zAcordo
		e1Valor += SE1->(E1_VALOR+E1_ACRESC-E1_DECRESC)
		e1Saldo += SE1->(E1_SALDO+E1_SDACRES-E1_SDDECRE)
		SE1->(DbSkip())
	Enddo
	If e1Saldo == 0
		zStatus := "E"
	ElseIf e1Valor > e1Saldo
		zStatus := "L"
	Endif	
Else
	zStatus := "E"
Endif

DbSelectArea("Z01")
DbSetOrder(1)
If DbSeek( xFilial("Z01") + zAcordo )
	RecLock("Z01",.F.)
	Z01->Z01_SALDO  := e1Saldo
	Z01->Z01_STATUS := zStatus
	MsUnLock()
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ SdoAcor   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  05/10/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Calcula o saldo do acordo.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SdoAcor(zAcordo)

Local aArea   := GetArea()
Local e1Saldo := 0
 
DbSelectArea("SE1")
DbSetOrder(1)
If DbSeek( xFilial("SE1") + "ACO" + zAcordo )
	While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1") + "ACO" + zAcordo
		e1Saldo += SE1->(E1_SALDO+E1_SDACRES-E1_SDDECRE)
		SE1->(DbSkip())
	Enddo
Endif

RestArea(aArea)

Return(e1Saldo)


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ UpdSldAco ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  24/11/2018  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Atualiza o saldo e a legenda dos acordos baseado na 		  ¦¦¦
¦¦¦          ¦ movimentação dos últimos 90 dias.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Módulo de Acordos.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UpdSldAco()

Local aArea   := GetArea()
Local zDatMov := dDatabase-90
Local zFilBkp := cFilAnt

cQuery := " SELECT DISTINCT E5_FILORIG FILIAL, E5_PREFIXO PREFIXO, E5_NUMERO ACORDO "
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_DATA >= '"+DtoS(zDatMov)+"' "
cQuery += " AND E5_PREFIXO = 'ACO' "
cQuery += " AND E5_FILORIG <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY FILIAL, PREFIXO, ACORDO "
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TACO",.T.,.T.)
 
DbSelectArea("TACO")
TACO->(DbGotop())
While !Eof()
	cFilAnt := TACO->FILIAL
	U_AcUpdLeg(cFilAnt,TACO->ACORDO)
	DbSelectArea("TACO")
	TACO->(DbSkip())
Enddo
TACO->(DbCloseArea())

cFilAnt := zFilBkp
RestArea(aArea)

Return
