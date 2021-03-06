#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"


/**************************************************************************
*** Programa: NumSf1        | Autor:                   | Data: 14/05/2019 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Logico>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function NumSf1()

Local _nI := 1

// Numero sequencial DNF - BK (doc de entrada)
IF VAL(cNFiscal) == 0 .AND. cSerie == "DNF"
	IF !SX6->(DBSEEK("  MV_XXNUMF1",.F.))
	   RecLock("SX6",.T.)
	   SX6->X6_VAR     := "MV_XXNUMF1"
	   SX6->X6_TIPO    := "N"
	   SX6->X6_DESCRIC := "Numero sequencial DNF - "+ALLTRIM(SM0->M0_NOME)+" (doc de entrada)"
	   SX6->X6_CONTEUD := STRZERO(_nI,9)
	   SX6->(MsUnlock())
	ELSE
	  RecLock("SX6",.F.)
	  _nI := VAL(SX6->X6_CONTEUD)+1
	  SX6->X6_CONTEUD := STRZERO(_nI,9)
	  SX6->(MsUnlock())
	ENDIF
	cNFiscal := STRZERO(_nI,9)
ENDIF

Return .T.


/**************************************************************************
*** Programa: ExistNF        | Autor:                  | Data: 14/02/2017 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Logico>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function ExistNF()

Local lOk     := .T.
Local cQuery1 := ""
Local cXDOC    := ""
Local cXSerie  := ""
Local cXFORNECE:= ""
Local cXLoja   := ""


cXDOC     := CNFISCAL
cXSerie   := CSERIE
cXFORNECE := CA100FOR
cXLoja    := IIF(!EMPTY(CLOJA),CLOJA,"01")
                                                     
cQuery1 := "Select F1_DOC,F1_SERIE"
cQuery1 += " FROM "+RETSQLNAME("SF1")+" SF1" 
cQuery1 += " where SF1.D_E_L_E_T_='' AND SF1.F1_FILIAL='"+xFilial('SF1')+"'  AND SF1.F1_DOC='"+cXDOC+"' "
cQuery1 += " AND SF1.F1_FORNECE='"+cXFORNECE+"' AND SF1.F1_LOJA='"+cXLoja+"' AND SF1.F1_SERIE<>'"+cXSerie+"'"
        
        
TCQUERY cQuery1 NEW ALIAS "TMPSF1"

dbSelectArea("TMPSF1")
TMPSF1->(dbGoTop())
DO While !TMPSF1->(EOF())
	lOk := .F.
	cXSerie := TMPSF1->F1_SERIE
	TMPSF1->(dbskip())
Enddo
TMPSF1->(DbCloseArea())

IF !lOk
	IF MSGNOYES("J� existe NF lan�ada para este Fornecedor com a SERIE: "+cXSerie+"!! Incluir assim mesmo?")
		lOk := .T.
	ENDIF
ENDIF

Return lOk