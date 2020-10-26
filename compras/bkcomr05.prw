#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 

/**************************************************************************
*** Programa: BKCOR05        | Autor: Adilson do Prado | Data: 25/04/2014 *
***************************************************************************
*** Descricao: Relat�rio Avalia��o dos Fornecedores                       *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function BKCOR05()

Local aDbf 		    := {}
Local oTmpTb
Local titulo        := "Avalia��o dos Fornecedores"

Private cTitulo     := "Avalia��o dos Fornecedores"
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "BKCOR05" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "BKCOR05"
Private cbtxt        := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "BKCOR05" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "SD1"

PRIVATE dDataInicio := dDatabase
PRIVATE dDataFinal  := dDatabase
PRIVATE cSituac     := "05"
PRIVATE	cPict       := "@E 99,999,999,999.99"
PRIVATE nPeriodo    := 1
PRIVATE nPlan       := 1
Private aHeader	    := {}
PRIVATE aTitulos,aCampos,aCabs,aCampos2,aTotal
PRIVATE cGrupoPI  	:= ""
PRIVATE cGrupoPF  	:= ""
PRIVATE cSGrupoPI  	:= ""
PRIVATE cSGrupoPF  	:= ""
PRIVATE cProdI  	:= ""
PRIVATE cProdF  	:= ""
PRIVATE dDataI		:= dDatabase
PRIVATE dDataF  	:= dDatabase
PRIVATE cFornI  	:= ""
PRIVATE cLojaI  	:= ""
PRIVATE cFornF  	:= ""
PRIVATE cLojaF  	:= ""
PRIVATE cContraI  	:= ""
PRIVATE cContraF  	:= ""

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif
 
dDataI  	:= mv_par01
dDataF  	:= mv_par02

titulo   := "Avalia��o dos Fornecedores - Per�odo: "+DTOC(dDataI)+" at� "+DTOC(dDataF)
cTitulo  := titulo

aDbf    := {}
Aadd( aDbf, { 'XX_FORNEC', 	'C', 06,00 } )
Aadd( aDbf, { 'XX_LOJA',   	'C', 02,00 } ) 
Aadd( aDbf, { 'XX_FANTASI',	'C', 20,00 } ) 
Aadd( aDbf, { 'XX_NFORNEC',	'C', 80,00 } )
Aadd( aDbf, { 'XX_AVALC',	'C', 03,00 } )
Aadd( aDbf, { 'XX_QNTNF',	'N', 10,00 } ) 
Aadd( aDbf, { 'XX_MDAVAL',	'N', 10,00 } ) 


//cArqTmp := CriaTrab( aDbf, .t. )
//dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
//IndRegua("TRB",cArqTmp,"XX_FORNEC+XX_LOJA",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_FORNEC","XX_LOJA"} )
oTmpTb:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}
aTotal  := {}

aAdd(aTitulos,titulo)

aAdd(aCampos,"TRB->XX_FORNEC")
aAdd(aCabs  ,"Cod. Fornecedor")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Cod. Fornecedor","XX_FORNEC" ,"@!",06,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_LOJA")
aAdd(aCabs  ,"Loja Fornecedor")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Loja Fornecedor","XX_LOJA" ,"@!",02,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_FANTASI")
aAdd(aCabs  ,"Nome Fantasia")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Nome Fantasia","XX_FANTASI" ,"@!",20,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_NFORNEC")
aAdd(aCabs  ,"Raz�o Social")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Raz�o Social","XX_NFORNEC" ,"@!",80,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_AVALC")
aAdd(aCabs  ,"Avalia��o Cr�tica")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Avalia��o Cr�ica","XX_AVALC" ,"@!",03,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_QNTNF")
aAdd(aCabs  ,"Qtde NF's entregues")
aAdd(aTotal,.T.)
aAdd(aHeader,{"Qtde NF's entregues","XX_QNTNF" ,"@E 9999999999",10,00,"","","N","TRB","R"})

aAdd(aCampos,"TRB->XX_MDAVAL")
aAdd(aCabs  ,"M�dia da Avalia��o (IQF)")
aAdd(aTotal,.F.)
aAdd(aHeader,{"M�dia da Avalia��o (IQF)","XX_MDAVAL" ,"@E 9999999999",10,00,"","","N","TRB","R"})

Processa( {|| ProcBKCOR05() })

Processa( {|| MBrwBKCOR05() })

oTmpTb:Delete()

///TRB->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())                 
 
Return


/**************************************************************************
*** Programa: MBrwBKCOR05    | Autor:                  | Data: 25/04/2014 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Procedure MBrwBKCOR05()

Local 	cAlias 		:= "TRB"

Private cCadastro	:= "Relat�rio de Avalia��o dos Fornecedores"
Private aRotina		:= {}
Private aIndexSz  	:= {}

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
Private lRefresh:= .T.
Private aButton := {}
Private _oGetDbSint
Private _oDlgSint

AADD(aRotina,{"Exp. Excel"	,"U_CBKCOR05",0,6})
AADD(aRotina,{"Imprimir"    ,"",0,7})

dbSelectArea(cAlias)
dbSetOrder(1)
dbGoTop()
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aadd(aButton , { "BMPTABLE" , { || U_CBKCOR05(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_RBKCOR05(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Imprimir" } )
	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return


/**************************************************************************
*** Programa: LimpaBrw       | Autor:                  | Data: 25/04/2014 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros: <cAlias> -                                                *
***************************************************************************
*** Retorno: <Logico>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Function LimpaBrw(cAlias)

	DbSelectArea(cAlias)
	(cAlias)->(dbgotop())
	While (cAlias)->(!eof())
		RecLock(cAlias,.F.)
			(cAlias)->(dbDelete())
		(cAlias)->(MsUnlock())
		dbselectArea(cAlias)
		(cAlias)->(dbskip())
	ENDDO

Return (.T.) 


/**************************************************************************
*** Programa: CBKCOR05       | Autor:                  | Data: 25/04/2014 *
***************************************************************************
*** Descricao: Gera Excel                                                 *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Logico>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User FUNCTION CBKCOR05()

Local aPlans  := {}

//Processa( {|| U_GeraCSV("TRB",TRIM(cPerg),aTitulos,aCampos,aCabs,"","",aQuebra,.F.)})

aAdd(aPlans,{"TRB",TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, aTotal/*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.)

Return 


/**************************************************************************
*** Programa: ProcBKCOR05    | Autor:                  | Data: 25/04/2014 *
***************************************************************************
*** Descricao: Gera Excel                                                 *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Procedure ProcBKCOR05

Local cQuery
Local nReg := 0

LimpaBrw("TRB")

cQuery := "SELECT F1_FILIAL,	F1_DOC,	F1_SERIE,	F1_FORNECE,	F1_LOJA,F1_EMISSAO,F1_DTDIGIT,F1_XXAVALI , SA2.A2_NREDUZ, SA2.A2_NOME, SA2.A2_XXAVALC"
cQuery += " FROM "+RETSQLNAME("SF1")+" SF1"
cQuery += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON  SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SF1.F1_FORNECE=SA2.A2_COD AND SF1.F1_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''" 
cQuery += " WHERE SF1.D_E_L_E_T_='' AND SF1.F1_DTDIGIT>='"+DTOS(dDataI)+"' AND SF1.F1_DTDIGIT<='"+DTOS(dDataF)+"' AND SF1.F1_XXAVALI<>''"
 
TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F1_DTDIGIT","D",8,0)

ProcRegua(QTMP->(LASTREC()))

dbSelectArea("QTMP")
QTMP->(dbGoTop())
DO WHILE QTMP->(!EOF())
    nReg++
	IncProc("Consultando banco de dados...")
	dbSelectArea("TRB")
	IF dbSeek(QTMP->F1_FORNECE+QTMP->F1_LOJA,.F.)
		Reclock("TRB",.F.)
		TRB->XX_QNTNF   += 1
		TRB->XX_MDAVAL	+= 	IIF(SUBSTR(QTMP->F1_XXAVALI,1,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,2,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,3,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,4,1)='S',25,0)
 		TRB->(Msunlock())
	ELSE
		Reclock("TRB",.T.)
		TRB->XX_FORNEC	:= QTMP->F1_FORNECE
		TRB->XX_LOJA 	:= QTMP->F1_LOJA
		TRB->XX_FANTASI := QTMP->A2_NREDUZ
		TRB->XX_NFORNEC := QTMP->A2_NOME
		TRB->XX_AVALC   := IIF(QTMP->A2_XXAVALC=="S","SIM","NAO")
		TRB->XX_QNTNF   := 1
		TRB->XX_MDAVAL	:= IIF(SUBSTR(QTMP->F1_XXAVALI,1,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,2,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,3,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,4,1)='S',25,0)
 		TRB->(Msunlock())
	ENDIF
	dbSelectArea("QTMP")
	QTMP->(dbSkip())
ENDDO

IF nReg < 1
	Reclock("TRB",.T.)
	TRB->XX_FORNEC 	:= "Null"
 	TRB->(Msunlock())
ELSE
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	DO WHILE TRB->(!EOF())
		Reclock("TRB",.F.)
		TRB->XX_MDAVAL	:= TRB->XX_MDAVAL / TRB->XX_QNTNF
 		TRB->(Msunlock())
		dbSelectArea("TRB")
		TRB->(dbSkip())
	ENDDO
ENDIF

TRB->(dbGoTop())

QTMP->(dbCloseArea())

Return


/**************************************************************************
*** Programa: RBKCOR05       | Autor:                  | Data: 25/04/2014 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function RBKCOR05()

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local aOrd          := {}
Local titulo        := ""

titulo := "Avalia��o dos Fornecedores - Per�odo: "+DTOC(dDataI)+" at� "+DTOC(dDataF)


	//���������������������������������������������������������������������Ŀ
	//� Monta a interface padrao com o usuario...                           �
	//�����������������������������������������������������������������������
	
	wnrel := SetPrint(cString,"BKCOR05",cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.) 
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	            
	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
	//�����������������������������������������������������������������������
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	m_pag   := 01 
	
RETURN


/**************************************************************************
*** Programa: RunReport      | Autor:                  | Data: 08/04/2008 *
***************************************************************************
*** Descricao: Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS *
***            monta a janela com a regua de processamento.               *
***************************************************************************
*** Parametros: <Cabec1> -                                                *
***             <Cabec2> -                                                *
***             <Titulo> -                                                *
***               <nLin> -                                                *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Procedure RunReport(Cabec1,Cabec2,Titulo,nLin)

nEsp    := 2
cPicQ 	:= "@E 9999999999"
cPicV 	:= "@E 999,999,999.99"

Cabec1  += PAD("Fornec",LEN(TRB->XX_FORNEC)+nEsp)
Cabec1  += PAD("Lj",LEN(TRB->XX_LOJA)+nEsp)
Cabec1  += PAD("Nome Fantasia",LEN(TRB->XX_FANTASI)+nEsp)
Cabec1  += PAD("Raz�o Social",30+nEsp)
Cabec1  += PAD("Aval. Cr�tica",13+nEsp)
Cabec1  += PADL("Qtde NF's entregues",LEN(cPicQ)-1)+SPACE(nEsp)
Cabec1  += PADL("M�dia da Avalia��o (IQF)",LEN(cPicQ)-1)+SPACE(nEsp)

IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

Titulo   := TRIM(Titulo)

nomeprog := "BKCOR05/"+TRIM(SUBSTR(cUsuario,7,15))
   
Dbselectarea("TRB")
Dbgotop()
SetRegua(LastRec())

DO While !TRB->(EOF())

   IncRegua()
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If nLin > 75 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,nTipo,,.F.)
      nLin := 9
   Endif

   nPos := 0
   @ nLin,nPos PSAY TRB->XX_FORNEC 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_LOJA 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_FANTASI
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_NFORNEC,30) 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_AVALC
   nPos := PCOL()+10+nEsp

   @ nLin,nPos PSAY TRB->XX_QNTNF PICTURE cPicQ
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY TRB->XX_MDAVAL PICTURE cPicQ
   nPos := PCOL()+nEsp

   nLin++
  
   dbSkip()
EndDo


//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


/**************************************************************************
*** Programa: ValidPerg      | Autor:                  | Data: 25/04/2014 *
***************************************************************************
*** Descricao:                                                            *
***************************************************************************
*** Parametros: <cPerg> -                                                 *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Procedure ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local nPos
Local nCount

	dbSelectArea("SX1")
	SX1->( dbSetOrder(1) )
	cPerg := PADR(cPerg,10)

	AADD(aRegistros,{cPerg,"01","Data de Entrada de:"  ,"Data da Compra de:" ,"Data da Compra de:" ,"mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegistros,{cPerg,"02","Data de Entrada at�:"  ,"Data de Entrada at�:" ,"Data de Entrada at�:" ,"mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

	For nPos := 1 to Len(aRegistros)
		If .not. SX1->( dbSeek( cPerg + aRegistros[ nPos, 2 ] ) )
			RecLock("SX1",.T.)
				For nCount := 1 to FCount()
					If nCount <= Len(aRegistros[ nPos ] )
						FieldPut( nCount, aRegistros[ nPos, nCount ] )
					Endif
				Next
			MsUnlock()
		Endif
	Next

	RestArea(aArea)

Return