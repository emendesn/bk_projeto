#Include "Protheus.ch"


/**************************************************************************
*** Programa: X02WFPAR       | Autor: Thiago Menegocci | Data: 15/08/2008 *
***************************************************************************
*** Descricao: Rotina para manutencao dos paramentros.                    *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function X02WFPAR()

////////////
//DECLARA VARIAVEL
////////////  
Local oTELA01
Private cDPTOLB

////////////
//CARREGA VARIAVEIS CONFORME PARAMETROS
////////////  
cDPTOLB := AllTrim(GetMV("MV_TESPAG"))
cDPTOLC := AllTrim(GetMV("MV_TESREC"))

////////////
//MONTA TELA
////////////  
Define MsDialog oTELA01 Title "Parametros de Contabilidade - TES" From 000,000 To 155,410 Of oTELA01 Pixel
@010,004 Say "TES A PAGAR:" Size 050,025 Pixel Of oTELA01
@020,004 MsGet cDPTOLB Picture "@!" Size 040,007 Pixel Of oTELA01
@036,004 Say "TES A RECEBER:" Size 050,025 Pixel Of oTELA01
@046,004 MsGet cDPTOLC Picture "@!" Size 040,007 Pixel Of oTELA01
@056,004 Say "Exemplo: 103/104" Size 050,025 Pixel Of oTELA01
@025,110 Button "&Cancelar" Size 036,013 Pixel Action oTELA01:End()
@025,152 Button "&Ok" Size 036,013 Pixel Action (X02WFSX6(),oTELA01:End())
Activate MsDialog oTELA01 Centered

Return


/**************************************************************************
*** Programa: X02WFSX6       | Autor: Thiago Menegocci | Data: 15/08/2008 *
***************************************************************************
*** Descricao: Rotina de gravacao dos paramentros.                        *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Procedure X02WFSX6()

	DbSelectArea("SX6")                                     //SELECIONA TABELA DE PARAMENTROS
	SX6->(DbSetOrder(1))                                    //SELECIONA INDICE

	////////////
	//AJUSTA PARAMETROS
	////////////  
	If SX6->(DbSeek(Space(2)+"MV_TESPAG"))
		RecLock("SX6",.F.)
			SX6->X6_CONTEUD := AllTrim(cDPTOLB)
		Msunlock()
	EndIf

	If SX6->(DbSeek(Space(2)+"MV_TESREC"))
		RecLock("SX6",.F.)
			SX6->X6_CONTEUD := AllTrim(cDPTOLC)
		Msunlock()
	EndIf
                              
Return