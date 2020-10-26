#INCLUDE "PROTHEUS.CH"


/**************************************************************************
*** Programa: NumSA2        | Autor:                   | Data: 14/05/2019 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Numerico>                                                   *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function NumSA2()

Local _nI := 1

  // Numero sequencial Fornecedor BK
  IF .not. SX6->(DBSEEK("  MV_XXNUMA2",.F.))
    RecLock("SX6",.T.)
    SX6->X6_VAR     := "MV_XXNUMA2"
    SX6->X6_TIPO    := "C"
    SX6->X6_DESCRIC := "Numero sequencial Fornecedor "
    SX6->X6_CONTEUD := STRZERO(_nI,6)
    SX6->(MsUnlock())
  ELSE
    RecLock("SX6",.F.)
    _nI := VAL(SX6->X6_CONTEUD)+1
    SX6->X6_CONTEUD := STRZERO(_nI,6)
    SX6->(MsUnlock())
  ENDIF

Return _nI