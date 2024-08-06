#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UGUNZIP ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 01/02/2020      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Descompacta arquivos com extensão gz.		  			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UGUNZIP()    
    
Local cDirSrv   
Local aArquivos
Local nI

If Empty(FunName())
    PREPARE ENVIRONMENT EMPRESA "G1" FILIAL "0101"
Endif

//Diretorio onde ficam os arquivos GZ
cDirSrv := "\xml\Manifesto\ArqXML"

If Empty(cDirSrv)
    ConOut("Diretório "+cDirSrv)
    Return
Endif

cDirSrv := Alltrim(cDirSrv) + "\"

//Monta um array com todos os arquivos GZ
aArquivos := Directory(cDirSrv + "*.gz") 
        
   //Percorre todos os arquivos descompactando
For nI := 1 to Len(aArquivos)

	//Pega o nome do arquivo com e sem extensao
    cArquivo   := aArquivos[nI][1]
    cArqSemExt := StrTran(Lower(cArquivo),".gz","")
    
    //Tenta descompactar o arquivo
    If GzDecomp( cDirSrv +  cArquivo, cDirSrv )
        If FRename( cDirSrv +  cArqSemExt, cDirSrv + cArqSemExt + ".xml" ) == 0
            FErase( cDirSrv +  cArqSemExt )
            FErase( cDirSrv +  cArquivo )
        Endif
    Endif

Next nI

Return
