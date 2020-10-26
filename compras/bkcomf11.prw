#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
                                       
/**************************************************************************
*** Programa: BKCOMF11       | Autor: Adilson do Prado | Data: 03/02/2015 *
***************************************************************************
*** Descricao: Gerar Proximo numero produtos                              *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <String>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function BKCOMF11()

Local cQuery := ""
Local nCod	 := 0
Local cCod	 := ""
Local aArea  := GetArea()


	cQuery := " SELECT TOP 1 A2_COD FROM "+RETSQLNAME("SA2")+" WHERE D_E_L_E_T_=''" 
	cQuery += " AND A2_COD>'000000' AND A2_COD<'999999' AND LEN(A2_COD)=6"
	cQuery += " ORDER BY A2_COD DESC"

	TCQUERY cQuery NEW ALIAS "QSA2"

	dbSelectArea("QSA2")	
	QSA2->(dbGoTop()) 
	nCod := VAL(QSA2->A2_COD)
	nCod++
	cCod := STRZERO(nCod,6)
	QSA2->(Dbclosearea())

RestArea(aArea)
	
Return cCod