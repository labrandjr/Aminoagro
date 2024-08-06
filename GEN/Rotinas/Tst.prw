#Include 'Protheus.ch'

User Function Tst()

	Local lStatus 	:= RPCSETENV("G1","0101")
	Local objQualy	:=Nil
	Local cRetorno	:= ""
	Local cNomeSB1	:= "B1_ZZMAPA"
	Local cNomeSBZ	:= "BZ_ZZMAPA"
	
	Local cNomeSB1	:= "B1_LOCPAD"
	Local cNomeSBZ	:= "BZ_LOCPAD"
	
	//Local cCodProd	:= "PI01"
	Local cCodProd	:= "PA01"
	
	DbSelectArea("SB1")
	objQualy:=LibQualyQuimica():New()
	cRetorno:=objQualy:GetSB1SBZ(cNomeSB1,cNomeSBZ,cCodProd)	

Return

