#Include 'Protheus.ch'

User Function F240ALMOD

Local cModelo := ParamIxb[1]

If cModelo == "91"  // Novo modelo

   // No caso deste modelo o segmento "O" Ã© gerado no arquivo remessa para pagamento de tributo -- Robson Assis - 19/02/2021

   cModelo := "13"  // Modelo 13 já existente

EndIf

Return cModelo 
