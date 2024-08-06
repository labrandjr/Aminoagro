#include "protheus.ch"
#include "restful.ch"

WSRESTFUL PEDIDO_COMPRA DESCRIPTION "Webservice Inclusão de Pedido de Compra" FORMAT APPLICATION_JSON
 
	WSMETHOD POST V1 DESCRIPTION "Inclui de pedido de compra" PATH "/v1" WSSYNTAX "/v1" TTALK "v1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE PEDIDO_COMPRA

Local lRet     := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local aCadEmp  := FwLoadSm0()
Local aLog 	   := {}
Local aCabec   := {}
Local aItem    := {}
Local aItens   := {}
Local i

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

self:SetContentType( "application/json" )

oJson:FromJson(cJson)

cBlzEmp := oJson["empresa"]
cBlzFil := oJson["filial"]
cCgcFor := oJson["cgcfor"]
dEmissa := StoD(oJson["emissao"])
cCondPg := oJson["condpg"]
cNrBlez := oJson["nr_blueez"]

// 1. Empresa e Filial
lEmpFil := .F.
For i := 1 to Len(aCadEmp)
	If cBlzEmp == aCadEmp[i][1] .And. cBlzFil == aCadEmp[i][2]
		lEmpFil := .T.
		cFilAnt := cBlzFil
	Endif
Next i
If !lEmpFil
	oJsonRet["sucess"] := .F.
	oJsonRet["msgerr"] := "Empresa/Filial nao localizada: "+cBlzEmp+"-"+cBlzFil
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 2. Emissão
If dEmissa < Date()
	oJsonRet["sucess"] := .F.
	oJsonRet["msgerr"] := "Data de emissao invalida: "+DtoC(dEmissa)
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 3. Fornecedor
DbSelectArea("SA2")
DbSetOrder(3)
If !DbSeek( xFilial("SA2") + cCgcFor )
	oJsonRet["sucess"] := .F.
	oJsonRet["msgerr"] := "Fornecedor nao cadastrado: "+cCgcFor
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 4. Condição de Pagamento
DbSelectArea("SE4")
DbSetOrder(1)
If !DbSeek( xFilial("SE4") + cCondPg )
	oJsonRet["sucess"] := .F.
	oJsonRet["msgerr"] := "Condicao de pagamento nao cadastrada: "+cCondPg
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 5. Itens
lItensOk := .T.
For i := 1 to Len(oJson["itens"])

	bProd := oJson["itens"][i]["prod"]
	bQtde := oJson["itens"][i]["quant"]
	bPrec := oJson["itens"][i]["preco"]
	bEntr := StoD(oJson["itens"][i]["dtentr"])

	// 5.1 - Produto
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek( xFilial("SB1") + bProd )
		oJsonRet["sucess"] := .F.
		oJsonRet["msgerr"] := "Produto nao cadastrado: "+bProd
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.2 - Quantidade
	If bQtde <= 0
		oJsonRet["sucess"] := .F.
		oJsonRet["msgerr"] := "Quantidade invalida: "+AllTrim(STR(bQtde))
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.3 - Preço
	If bPrec <= 0
		oJsonRet["sucess"] := .F.
		oJsonRet["msgerr"] := "Preco unitario invalida: "+AllTrim(STR(bPrec))
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.4 - Entrega
	If bEntr < Date()
		oJsonRet["sucess"] := .F.
		oJsonRet["msgerr"] := "Data de entrega invalida: "+DtoC(bEntr)
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

Next i
If !lItensOk
	Return(.F.)
Endif

cNumPed := GetNumSC7()
AAdd(aCabec,{ "C7_NUM"    , cNumPed        , Nil })
AAdd(aCabec,{ "C7_EMISSAO", dEmissa        , Nil })
AAdd(aCabec,{ "C7_FORNECE", SA2->A2_COD    , Nil })
AAdd(aCabec,{ "C7_LOJA"   , SA2->A2_LOJA   , Nil })
AAdd(aCabec,{ "C7_COND"   , SE4->E4_CODIGO , Nil })
AAdd(aCabec,{ "C7_CONTATO", SA2->A2_CONTATO, Nil })
AAdd(aCabec,{ "C7_FILENT" , cFilAnt        , Nil })			
AAdd(aCabec,{ "C7_USER"   , SC7->C7_USER   , Nil })			
AAdd(aCabec,{ "C7_ZFILINC", SC7->C7_FILIAL , Nil })
AAdd(aCabec,{ "C7_ZNUMINC", "000000"       , Nil })

For i := 1 to Len(oJson["itens"])

	aItem := {}
	bProd := oJson["itens"][i]["prod"]
	bQtde := oJson["itens"][i]["quant"]
	bPrec := oJson["itens"][i]["preco"]
	nVTot := oJson["itens"][i]["quant"] * oJson["itens"][i]["preco"]
	bEntr := StoD(oJson["itens"][i]["dtentr"])
	bObse := oJson["itens"][i]["observ"]

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + bProd )

	AAdd(aItem,{ "C7_PRODUTO", SB1->B1_COD    , Nil })
	AAdd(aItem,{ "C7_QUANT"  , bQtde          , Nil })
	AAdd(aItem,{ "C7_PRECO"  , bPrec          , Nil })
	AAdd(aItem,{ "C7_TOTAL"  , nVTot          , Nil })
	AAdd(aItem,{ "C7_DATPRF" , bEntr          , Nil })
	AAdd(aItem,{ "C7_CC"     , SB1->B1_CC     , Nil })
	AAdd(aItem,{ "C7_OBS"    , bObse          , Nil })
	AAdd(aItem,{ "C7_LOCAL"  , SB1->B1_LOCPAD , Nil })
	AAdd(aItem,{ "C7_DESCRI" , SB1->B1_DESC   , Nil })

	AAdd(aItens, aItem)

Next i

lMsErroAuto    := .F.
lMsHelpAuto    := .T.
lAutoErrNoFile := .T.

MSExecAuto({|x,y,z,w| MATA120(x,y,z,w)},1, aCabec, aItens, 3)
If !lMsErroAuto			
	oJsonRet["sucess"] := .T.
	oJsonRet["filial"] := SC7->C7_FILIAL
	oJsonRet["numero"] := SC7->C7_NUM
	lRet := .T.
	self:SetResponse( oJsonRet:toJson() )
Else
	aLog := GetAutoGRLog()
	bMsg := "Falha na inclusao do pedido."
	For i := 1 to Len(aLog)
		If AT("Erro -->",aLog[i])
			bMsg := AllTrim(Substr(aLog[i],9))
		Endif
	Next i

	oJsonRet["sucess"] := .F.
	oJsonRet["msgerr"] := bMsg
	lRet := .F.
	self:SetResponse( oJsonRet:toJson() )

	/*
	SetRestFault(2,;
				 "Falha na inclusão do pedido de compra.",;
				 .T.,;
				 400,;
				 "Houve uma falha na leitura dos dados no Json, efetue a correção.") */
Endif

Return(lRet)
 
// https://www.youtube.com/watch?v=fqXEVpG9vB8


/*
#include "rwmake.ch"
#include "tbiconn.ch"

User Function GravaErro()
Local nX     := 0
Local nCount := 0   
Local cLogFile := "" //nome do arquivo de log a ser gravado
Local aLog 	 := {}
Local aVetor := {}
Local nHandle
Local lRet := .F.   // variável de controle interno da rotina automatica que informa se houve erro durante o processamento

PRIVATE lMsErroAuto := .F. // variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
Private lMsHelpAuto	:= .T. // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile := .T. 

Prepare Environment Empresa "01" Filial "01" Modulo "FAT"
//+------------------------- -------------------------------------+//| Teste de Inclusao |//+------------------------------------- -------------------------+

For nCount := 1 To 3	
	aVetor:= {{"B1_COD"     ,"99"+Alltrim(Str(nCount)),Nil},; 			 
				{"B1_DESC"    ,"Teste"        ,Nil},;			 
				{"B1_UM"      ,"UN"           ,Nil},; 			 
				{"B1_LOCPAD"  ,"01"           ,Nil}}   	
				
	lMsErroAuto := .F.    	
	lRet := .F.	
	AutoGrLog("Teste de geração do arquivo de log "+Alltrim(Str(nCount)))	
	AutoGrLog("")		
	
	MSExecAuto( {|x,y| MATA010(x, y) }, aVetor, 3 )	
	
	AutoGrLog(Replicate("-", 20))	
	If lMsErroAuto		
		cLogFile := "C:\TESTE"+Alltrim(Str(nCount))+".LOG" //função que retorna as informações de erro ocorridos durante o processo da rotina automática		
		aLog := GetAutoGRLog() //efetua o tratamento para validar se o arquivo de log já existe		
		If !File(cLogFile)			
			If (nHandle := MSFCreate(cLogFile,0)) <> -1				
				lRet := .T.			
			EndIf		
		Else			
			If (nHandle := FOpen(cLogFile,2)) <> -1				
				FSeek(nHandle,0,2)				
				lRet := .T.			
			EndIf		
		EndIf		
		If	lRet //grava as informações de log no arquivo especificado			
			For nX := 1 To Len(aLog)				
				FWrite(nHandle,aLog[nX]+CHR(13)+CHR(10))			
			Next nX			
			FClose(nHandle)		
		EndIf	
	EndIf
Next
If !lMsErroAuto	
	ConOut("Incluido com sucesso! ") 
Else	
	ConOut("Erro na inclusao !")
EndIf

Return
*/
