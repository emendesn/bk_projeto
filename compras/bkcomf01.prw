#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


/**************************************************************************
*** Programa: BKCOMF01       | Autor: Adilson do Prado | Data: 06/02/2013 *
***************************************************************************
*** Descricao: Funcao para Gerar descri��o completa do Produto            *
***            SZI->ZI_XXDESC+SB1->B1_DESC                                *
***************************************************************************
*** Parametros: <cCodProd> -                                              *
***************************************************************************
*** Retorno: <String>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function BKCOMF01(cCodProd)

Local cDescProd  := ""
Local cCodSubPro := ""
Local cDesSubPro := ""

cDescProd := ALLTRIM(Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_DESC"))
cCodSubPro := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_XXSGRP")
cDesSubPro := ALLTRIM(Posicione("SZI",1,xFilial("SZI")+cCodSubPro,"ZI_DESC"))

IF ALLTRIM(cDescProd) $ ALLTRIM(cDesSubPro)
	cDescProd  := ALLTRIM(cDescProd)
ELSE
	cDescProd  := ALLTRIM(cDesSubPro+" "+cDescProd)
ENDIF

Return(cDescProd)