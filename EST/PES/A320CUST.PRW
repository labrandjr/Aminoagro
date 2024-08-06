#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A320CUST  ¦ Autor ¦ Luis Brandini    ¦   Data  ¦ 09/02/17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização do Custo Standard calculado pela rotina de     ¦¦¦
¦¦¦          ¦ Custo de Reposição, na tabela de Indicadores de Produtos.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A320CUST()

Local cCodProd := ParamIXB[1] // Codigo do Produto
Local nCusto   := ParamIXB[2] // Valor do novo custo gravado// Customizacoes do Usuario
Local cProc    := ParamIXB[3] // Define qual processamento sera realizado de acordo com a funcao

If cProc == "MA320LCust"
	/* Tipo de processamento / Function MA320LCust() - Função utilizada
	para atualizar o custo standard (B1_CUSTD) baseado no ultimo custo de NF de compra .
	*/
	If SB1->B1_MSBLQL != "1" // Não Bloqueado

		DbSelectArea("SBZ")
		DbSetOrder(1)
		If !DbSeek( cFilAnt + SB1->B1_COD )
	
			aCab := {}
	        lMsErroAuto := .F.
	        
	        AAdd(aCab,{"BZ_COD"     , SB1->B1_COD   , Nil})
	        AAdd(aCab,{"BZ_LOCPAD"  , SB1->B1_LOCPAD, Nil})
	        AAdd(aCab,{"BZ_ZZDESC"  , SB1->B1_DESC  , Nil})
	        AAdd(aCab,{"BZ_CUSTD"   , nCusto        , Nil})
	        AAdd(aCab,{"BZ_UCALSTD" , Date()        , Nil})
	
	        MsExecAuto({|v,x| MATA018(v,x)},aCab,3)
	        If !lMsErroAuto
	            ConOut("Sucesso na atualização de Indicadores: "+SB1->B1_COD)
	        Else
	            ConOut("Erro na atualização de Indicadores: "+SB1->B1_COD)
		        MostraErro()
	        Endif
	
		Else
	
			RecLock("SBZ",.F.)
			SBZ->BZ_CUSTD   := nCusto
			SBZ->BZ_UCALSTD := Date()
			MsUnLock()
	
		Endif
		
	Endif	

Else
	/*
	MA320Estru() - Calculo do custo standard pela estrutura.
	*/
Endif

Return
