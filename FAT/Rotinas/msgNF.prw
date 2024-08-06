#Include 'Protheus.ch'
/*/{Protheus.doc} Função MSGNF

.

@author 	Cassiano G. Ribeiro
@since 		11/03/2016
@return		Nil
/*/
user function msgNF(cTipNota)
	local aArea		:= getArea()
	local nPLiqui	:= 0
	local nPBruto	:= 0
	local nVolumes	:= 0
	local oTMsg
	
	if cTipNota == "SAIDA"
		oTMsg := FswTemplMsg():TemplMsg("S",SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
				
		calcPesoVol(@nPLiqui,@nPBruto,@nVolumes)
		
		SD2->(dbSetOrder(3))
		if SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
		
			SC5->(dbSetOrder(1))
			if SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
			
				aAdd(oTMsg:aCampos,{"F2_TRANSP" ,SC5->C5_TRANSP})
				aAdd(oTMsg:aCampos,{"F2_REDESP" ,SC5->C5_REDESP})
				aAdd(oTMsg:aCampos,{"F2_PLIQUI" ,nPLiqui})
				aAdd(oTMsg:aCampos,{"F2_PBRUTO" ,nPBruto})
				aAdd(oTMsg:aCampos,{"F2_VOLUME1",nVolumes})
				aAdd(oTMsg:aCampos,{"F2_ESPECI1","VOLUME(S)"})
				aAdd(oTMsg:aCampos,{"F2_ZZPLACA",getPlacaOMS()})
				aAdd(oTMsg:aCampos,{"F2_ZZUFPLA",getUFPlacaOMS()})
				
				oTMsg:Processa()
				
				RecLock("SC5",.F.)
				SC5->C5_TRANSP := SF2->F2_TRANSP
				SC5->C5_REDESP := SF2->F2_REDESP
				SC5->(MsUnlock())
			endIf
		endIf

		If !Empty(SF2->F2_ZZPLACA) .And. Empty(SF2->F2_VEICUL1)
			zPlaca := PadR(AllTrim(SF2->F2_ZZPLACA),8)
			DbSelectArea("DA3")
			DbSetOrder(3)
			If DbSeek( xFilial("DA3") + zPlaca )
				RecLock("SF2",.F.)
				SF2->F2_VEICUL1 := DA3->DA3_COD
				MsUnLock()
			Endif
		Endif
		
	elseif cTipNota == "ENTRADA"
	
		oTMsg  := FswTemplMsg():TemplMsg("E",SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)

		if SF1->F1_FORMUL == "S"
			aAdd(oTMsg:aCampos,{"F1_VOLUME1",CriaVar("F1_VOLUME1")})
			aAdd(oTMsg:aCampos,{"F1_ESPECI1",CriaVar("F1_ESPECI1")})
			aAdd(oTMsg:aCampos,{"F1_PLIQUI" ,CriaVar("F1_PLIQUI" )})
			aAdd(oTMsg:aCampos,{"F1_PBRUTO" ,CriaVar("F1_PBRUTO" )})
			aAdd(oTMsg:aCampos,{"F1_TRANSP" ,CriaVar("F1_TRANSP" )})
			aAdd(oTMsg:aCampos,{"F1_PLACA"  ,CriaVar("F1_PLACA"  )})
			aAdd(oTMsg:aCampos,{"F1_ZZUFPLA",CriaVar("F1_ZZUFPLA")})
			aAdd(oTMsg:aCampos,{"F1_ZZMARCA",CriaVar("F1_ZZMARCA")})

			aAdd(oTMsg:aCampos,{"F1_ZZLI"   ,CriaVar("F1_ZZLI")})
			aAdd(oTMsg:aCampos,{"F1_ZZDREMB",CriaVar("F1_ZZDREMB")})
			aAdd(oTMsg:aCampos,{"F1_ZZDCEMB",CriaVar("F1_ZZDCEMB")})
		
			oTMsg:Processa()
		endIf
	endIf
	
	RestArea(aArea)
return

static function calcPesoVol(nPLiqui,nPBruto,nVolumes)
	local aArea := GetArea()
	
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	Do While !SD2->(EOF()) .and. SD2->D2_FILIAL == xFilial("SD2") .and. SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		nPLiqui += SD2->D2_QUANT * Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESO")
		nPBruto += SD2->D2_QUANT * Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESBRU")
		nVolumes+= calcVol()	
		SD2->(dbSkip())
	Enddo
	
	RestArea(aArea)
return

static function calcVol()
	local nVolumes 	:= 0
	local nInteiro 	:= 0
	local nResto	:= 0
	
	If Substr(SD2->D2_COD,1,3) <> "TMS"
		nInteiro	:= Int(SD2->D2_QUANT / Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_ZZQEMB"))
		nResto 		:= SD2->D2_QUANT % Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_ZZQEMB")
		If nResto > 0
			nVolumes += nInteiro
			nVolumes ++
		Else
			nVolumes += nInteiro
		EndIf
	Endif	
return nVolumes   

static function getPlacaOMS()

	local cPlaca := CriaVar("F2_ZZPLACA")
	local aArea	 := DA3->(getArea()) 
	
	if !Empty(SF2->F2_VEICUL1)
		dbSelectArea("DA3")
		dbSetOrder(1)
		MsSeek(xFilial("DA3")+SF2->F2_VEICUL1)
		
		cPlaca := DA3->DA3_PLACA
	endIf
	restArea(aArea)
return cPlaca

static function getUFPlacaOMS()

	local cUFPlaca := CriaVar("F2_ZZUFPLA")
	local aArea	   := DA3->(getArea()) 
	
	if !Empty(SF2->F2_VEICUL1)
		dbSelectArea("DA3")
		dbSetOrder(1)
		MsSeek(xFilial("DA3")+SF2->F2_VEICUL1)
		
		cUFPlaca := DA3->DA3_ESTPLA
	endIf
	
	restArea(aArea)
	
return cUFPlaca
