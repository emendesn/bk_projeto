#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/**************************************************************************
*** Programa: BKCTBA01       | Autor: Adilson do Prado | Data: 06/07/2020 *
***************************************************************************
*** Descricao: Integra��o Contabiliza��o - Folha Rubi                     *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function BKCTBA01()
Private cString   := "SZ5"
Private cCadastro := "Contabiliza��o - Folha "+ALLTRIM(SM0->M0_NOME)

Private aRotina

dbSelectArea("SZ5")
dbSetOrder(1)
DbGoTop()

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2},;
            {"Importar",  "U_BKCTB01()" ,0, 3},;
            {"Alterar"	,"AxAltera"		,0,	4}}

//	{"Excluir"   ,"AxDeleta"	,0, 5},;


mBrowse(6,1,22,75,cString)

Return


/**************************************************************************
*** Programa: BKCTB01        | Autor:                  | Data: 06/07/2020 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function BKCTB01()

Local aAreaIni := GetArea()

Private nStatus

// Verificar se h� Lan�amentos a importar
cQuery  := "SELECT COUNT(*) AS Z5STATUS " 
cQuery  += "FROM "+RETSQLNAME("SZ5")+" SZ5 WHERE Z5_STATUS = ' ' AND Z5_VALOR > 0 AND SZ5.D_E_L_E_T_ <> '*'"

TCQUERY cQuery NEW ALIAS "QSZ5"

DbSelectArea("QSZ5")
DbGoTop()
nStatus := QSZ5->Z5STATUS
QSZ5->(DbCloseArea())

IF nStatus > 0
   IF MsgYesNo("Confirma a importa��o de "+STRZERO(nStatus,6)+" lan�amentos ?")
      Processa( {|| RunCtb01() } )
      Return
   ENDIF
ELSE
   MsgStop("N�o h� lan�amentos para importar","Aten��o")    
ENDIF
RestArea(aAreaIni)

Return


/**************************************************************************
*** Programa: RunCtb01       | Autor:                  | Data: 06/07/2020 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Procedure RunCtb01()

Local aCab := {},aItens := {},aRecno:={}
Local aAreaIni := GetArea()
Local cQuery
Local nStatus := 0
Local nI := 0,dUDia,nMes,nAno
Local cDoc := ""
Local cEvento := ""

Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.
      
dbSelectArea("SZ5")
dbSetOrder(1)
dbGoTop()
IF BOF() .OR. EOF()
	MsgStop("N�o ha lan�amentos gerados", "Aten��o")
	RestArea(aAreaIni)
	Return
ENDIF

cQuery  := "SELECT Z5_FILIAL,Z5_ANOMES,Z5_CC,Z5_DEBITO,Z5_CREDITO,Z5_EVENTO,Z5_EVDESCR,Z5_VALOR,Z5_STATUS,R_E_C_N_O_ AS Z5RECNO " 
cQuery  += "FROM "+RETSQLNAME("SZ5")+" SZ5 "
cQuery  += "WHERE Z5_STATUS = ' ' AND SZ5.D_E_L_E_T_ <> '*' "
cQuery  += "AND Z5_VALOR > 0 "
//cQuery  += "GROUP BY Z5_FILIAL,Z5_ANOMES "
cQuery  += "ORDER BY Z5_FILIAL,Z5_ANOMES,Z5_EVENTO "

TCQUERY cQuery NEW ALIAS "QSZ5"
//TCSETFIELD("QSZ5","XX_DATAPGT","D",8,0)


// Marca os registros a serem importados
//cQuery := " UPDATE "+RetSqlName("SZ5")+" SET Z5_STATUS = 'X' WHERE Z5_STATUS = ' ' AND D_E_L_E_T_ <> '*' "
//TcSqlExec(cQuery)

lMsErroAuto := .F.

ProcRegua(nStatus)

DbSelectArea("QSZ5")
DbGoTop()
Do While !eof()
    nMes := VAL(SUBSTR(QSZ5->Z5_ANOMES,5,2))
    nAno := VAL(SUBSTR(QSZ5->Z5_ANOMES,1,4))
    nMes++
    IF nMes > 12
       nAno++
       nMes := 1
    ENDIF

    dUDia:= STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
    dUDia:= dUDia - 1
	If VAL(QSZ5->Z5_ANOMES) > 0
		cDoc := 'E'+ALLTRIM(SUBSTR(QSZ5->Z5_EVENTO,1,5))
	Else
		cDoc := '000001'	
	EndIf

	aCab := { {'DDATALANC', dUDia,     NIL},;
	          {'CLOTE',     QSZ5->Z5_ANOMES,  NIL},;
	          {'CSUBLOTE',  '001',     NIL},;
	          {'CPADRAO',   '',        NIL},;
	          {'NTOTINF',   0,         NIL},;
	          {'NTOTINFLOT',0,         NIL},;
	          {'CDOC',      cDoc      ,NIL} }

//NOPC,DDATALANC,CLOTE,CSUBLOTE,CDOC,LAGLUT,CSEQUENC,LCUSTO,LITEM,LCLVL,NTOTINF,CPROG,CPRELCTO,DREPROC,CEMPORI,CFILORI,@AFLAGCTB,@ACTKXCT2,@ATPSALDO,CMODOCLR,ASEQDIARIO,LMLTSLD,CSEQCORR		

	nLinha  := 1
    cFil    := QSZ5->Z5_FILIAL
    cAnoMes := QSZ5->Z5_ANOMES
	cEvento := QSZ5->Z5_EVENTO
    aItens  := {}
    aRecno  := {}
	Do While !eof() .AND. cFil == QSZ5->Z5_FILIAL .AND. cAnoMes == QSZ5->Z5_ANOMES .AND. cEvento == QSZ5->Z5_EVENTO
	
		IncProc("Importando lan�amentos...")
		//aAdd(aItens,{  {'CT2_FILIAL'  ,QSZ5->Z5_FILIAL,     NIL},;
		cCCD := ""
		cCCC := ""
		IF SUBSTR(QSZ5->Z5_DEBITO,1,1) == "3"
		   cCCD := QSZ5->Z5_CC
		ENDIF
		   
		IF SUBSTR(QSZ5->Z5_CREDITO,1,1) == "3"
		   cCCC := QSZ5->Z5_CC
		ENDIF
		
		aAdd(aItens,{  {'CT2_LINHA'  ,STRZERO(nLinha++,3), NIL},;
		               {'CT2_MOEDLC' ,'01',                NIL},;
		               {'CT2_DC'     ,'3',                 NIL},;
		               {'CT2_DEBITO' ,QSZ5->Z5_DEBITO,     NIL},;
		               {'CT2_CREDIT' ,QSZ5->Z5_CREDITO,    NIL},;
		               {'CT2_CCD'    ,cCCD,                NIL},;
		               {'CT2_CCC'    ,cCCC,                NIL},;
		               {'CT2_VALOR'  , QSZ5->Z5_VALOR,     NIL},;
		               {'CT2_ORIGEM' ,'BKCTBA01-'+QSZ5->Z5_EVENTO+'-'+SUBSTR(cUsuario,7,14)+'-'+QSZ5->Z5_ANOMES, NIL},;
		               {'CT2_HP'     ,'',                  NIL},;
		               {'CT2_HIST'   ,'FOLHA PGTO '+SUBSTR(QSZ5->Z5_ANOMES,5,2)+'/'+SUBSTR(QSZ5->Z5_ANOMES,1,4)+' - '+TRIM(QSZ5->Z5_EVDESCR), NIL} } )

		aAdd(aRecno,QSZ5->Z5RECNO)
		
		DbSelectArea("QSZ5")
		DbSkip()
		If nLinha > 999
		   Exit
		EndIf   
	Enddo
		
	Begin Transaction
	    cErro       := ""
		lMsErroAuto := .F.
	    MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
		
//		IF lMsErroAuto
//			MsgStop("N�o foi possivel importar todos os lan�amentos, contate o setor de T.I.", "Aten��o")
//	    	MostraErro()
//			DisarmTransaction()
//		ENDIF

		IF lMsErroAuto
			// Fun��o que retorna o evento de erro na forma de um array
			aAutoErro := GETAUTOGRLOG()
			// Fun��o especifica que converte o array aAutoErro em texto
			// cont�nuo, com a quantidade de caracteres desejada por linha
			// Fun��o espec�fica que efetua a grava��o do evento de erro no
			// arquivo previamente crado.
			cErro := (XCONVERRLOG(aAutoErro))
			DisarmTransaction()
		ENDIF


		
	End Transaction
	IF !EMPTY(cErro)
	   MsgStop(cErro)
	   Exit
	ENDIF   
    IF !lMsErroAuto
    	FOR nI := 1 TO LEN(aRecno)
       		dbSelectArea("SZ5")
       		dbGoTo(aRecno[nI])
	   		RecLock("SZ5",.F.)
	   		SZ5->Z5_STATUS := "P"
	   		MsUnlock()
	   	NEXT	
    
    ELSE
	   MsgStop("N�o foi possivel importar todos os lan�amentos, contate o setor de T.I.")
	   EXIT
	ENDIF
	DbSelectArea("QSZ5")
EndDo

// Cancelamento 

QSZ5->(DbCloseArea())

Return  


/**************************************************************************
*** Programa: xconverrlog    | Autor: Arnaldo R.Junior | Data: 06/07/2020 *
***************************************************************************
*** Descricao: Converte o Array aAutoErro em texto continuo               *
***************************************************************************
*** Parametros: <aAutoErro> -                                             *
***************************************************************************
*** Retorno: <String>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
STATIC FUNCTION xconverrlog( aAutoErro )

LOCAL cRet := ""
LOCAL nPos := 1

	FOR nPos := 1 to Len(aAutoErro)
		cRet += aAutoErro[ nPos ] + CHR(13)+CHR(10)
	NEXT

RETURN cRet