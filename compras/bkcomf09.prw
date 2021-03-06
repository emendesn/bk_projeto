#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
                                       
/**************************************************************************
*** Programa: BKCOMF09       | Autor: Adilson do Prado | Data: 03/02/2015 *
***************************************************************************
*** Descricao: Gerar Proximo numero produtos                              *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <String>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function BKCOMF09()

Local cQuery := ""
Local nReg 	 := 0 
Local cSubPdt:= ""
Local cCod	 := ""
Local nCod	 := 0
Local cPerg  := "BKCOMF09" 

If !MsgYesNo("Gerar Proximo numero?",cPerg)
	cCod := ""
	Return cCod 
EndIf

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	cCod := ""
	Return cCod
Endif
 
cSubPdt  	:= ALLTRIM(mv_par01)
 
IF EMPTY(cSubPdt)
	MSGINFO("O Grupo de Produto dever ser selecionado!!","BKCOMF09")
	cCod := ""
	Return cCod 
EndIf

nReg := 0

SM0->(DbGoTop())
While SM0->(!EoF())

	cQuery := " SELECT TOP 1 SUBSTRING(B1_COD,4,LEN(B1_COD)) AS B1_COD1 from SB1"+TRIM(SM0->M0_CODIGO)+"0 WHERE D_E_L_E_T_='' AND SUBSTRING(B1_COD,1,3)='"+cSubPdt+"' " 
	cQuery += " ORDER BY CAST(SUBSTRING(B1_COD,4,LEN(B1_COD)) AS INT) DESC "
	TCQUERY cQuery NEW ALIAS "QSB1"

	dbSelectArea("QSB1")	
	QSB1->(dbGoTop()) 
	
	IF VAL(QSB1->B1_COD1) > nCod
		nCod := VAL(QSB1->B1_COD1)
	ENDIF
	
	QSB1->(Dbclosearea())
	SM0->(dbSkip())
ENDDO
nCod++
cCod := cSubPdt+STRZERO(nCod,IIF(nCod>999,4,3))

Return cCod


/**************************************************************************
*** Programa: validperg      | Autor:                  | Data: 03/02/2015 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros: <cPerg>                                                   *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Procedure validperg( cPerg )

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Grupo Produtos de:","Grupo Produtos de:","Grupo Produtos de:","mv_ch1","C",04,0,0,"C","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SBM2","S","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return


