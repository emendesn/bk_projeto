#INCLUDE "PROTHEUS.CH"


/**************************************************************************
*** Programa: ApuConf       | Autor: Thiago Menegocci  | Data: 01/09/2008 *
***************************************************************************
*** Descricao: Funcao para calculo de apuracao de pis e cofins            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Numerico>                                                   *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function ApuConf()

Local nValor1 := 0
Local cParCof := Left(AllTrim(GetMV("MV_PARCOF")),4)

	If Upper(Funname()) == Upper("CTBANFE")
		If SD1->D1_TES $ AllTrim(GetMV("MV_TESPAG"))
			nValor1 := Round(SD1->D1_TOTAL*Val(cParCof)/100,2)
		EndIf
	EndIf

	If Upper(Funname()) == Upper("CTBANFS")
		If SD2->D2_TES $ AllTrim(GetMV("MV_TESREC"))
			nValor1 := Round(SD2->D2_TOTAL*Val(cParCof)/100,2)
		EndIf
	EndIf

Return(nValor1)