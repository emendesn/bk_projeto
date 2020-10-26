#INCLUDE "rwmake.ch"


/**************************************************************************
*** Programa: CONTTOTAL      | Autor: Thiago Bassi     | Data: 08/10/2008 *
***************************************************************************
*** Descricao: Contabilizacao de Valores                                  *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <String>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function CONTTOTAL()

Local cValTot
        
    DbSelectArea("SE2")
    SE2->(dbSetOrder(1))
    SE2->(dbSeek( xFilial("SE2")+SE2->E2_PREFIXO+SD1->D1_DOC) )

    cValTot := SE2->E2_VALOR-SE2->E2_ISS

Return( cValTot )