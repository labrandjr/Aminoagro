#Include 'totvs.ch'
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{protheus.doc}FATA050

@author Gustavo Luiz
@since  
/*/
User Function FATA050()
	
	local aArea		:= getArea()
	local xRet		:= .T.
	local oObj		:= Paramixb[1]
	local IdPonto	:= Paramixb[2]
	local cIdModel	:= Paramixb[3]
	local aSaveLines:= FWSaveRows()
		
	if AllTrim(idPonto)=="BUTTONBAR"
		if INCLUI .or. ALTERA
			xRet := { {'Imp meta de venda', 'Imp meta de venda', { || u_QQFAT02() }, 'Realiza a importação' } }
		endIf
	endIf
		
	FWRestRows( aSaveLines )
	restArea(aArea)
	
Return xRet
