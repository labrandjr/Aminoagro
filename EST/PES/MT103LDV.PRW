#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT103LDV  ¦ Autor ¦ Fábrica ERP.BR   ¦    Data  ¦ 11/07/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Tratamento complementar de dados no processo 'Retornar'.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT103LDV()

Local aArea   := GetArea()
Local aLinha  := PARAMIXB[1]
Local zXCusto := 0

pNotaOri := aScan( aLinha ,{|x| Alltrim(x[1])=="D1_NFORI"})
pSeriOri := aScan( aLinha ,{|x| Alltrim(x[1])=="D1_SERIORI"})
pItemOri := aScan( aLinha ,{|x| Alltrim(x[1])=="D1_ITEMORI"})
pProduto := aScan( aLinha ,{|x| Alltrim(x[1])=="D1_COD"})

zNotaOri := aLinha[pNotaOri][2] 
zSeriOri := aLinha[pSeriOri][2] 
zItemOri := aLinha[pItemOri][2]
zProduto := aLinha[pProduto][2]

DbSelectArea("SF2")
DbSetOrder(1)
If DbSeek( xFilial("SF2") + zNotaOri + zSeriOri )
	DbSelectArea("SD2")
	DbSetOrder(3)
	If DbSeek( xFilial("SD2") + zNotaOri + zSeriOri + SF2->F2_CLIENTE + SF2->F2_LOJA + zProduto + zItemOri )
		zXCusto := SD2->D2_CUSTO1
	Endif	
Endif

If zXCusto > 0
	AAdd( aLinha, { "D1_XCUSTO", zXCusto, Nil } )
Endif	

RestArea(aArea)

Return(aLinha)
