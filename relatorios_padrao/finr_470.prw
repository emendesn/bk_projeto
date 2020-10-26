#Include "FINR470.CH"
#include "PROTHEUS.CH"
#DEFINE REC_NAO_CONCILIADO 1
#DEFINE REC_CONCILIADO		2
#DEFINE PAG_NAO_CONCILIADO 3
#DEFINE PAG_CONCILIADO		4



 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR470  � Autor � Adrianne Furtado      � Data � 10/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extrato Banc�rio.		 					              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR470(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

USER Function FINR_470()
Private lTReport := .F.

If FindFunction("TRepInUse") .And. TRepInUse() 
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	lTReport := .T.
	oReport := ReportDef()
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf
	oReport:PrintDialog()
Else
    Return FinR470R3() // Executa vers�o anterior do fonte
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Adrianne Furtado      � Data �10/08/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport 
Local oBanco
Local oMovBanc           
//Local nTamChave := TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1] + 3

AjustaSX1()
Pergunte("FIN470",.F.)
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
//"EXTRATO BANCARIO"
//"Este programa ir� emitir o relat�rio de movimenta��es" "banc�rias em ordem de data. Poder� ser utilizado para""conferencia de extrato."
oReport := TReport():New("FINR470",STR0004,"FIN470", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002+" "+STR0003) 

oBanco := TRSection():New(oReport,STR0035,{"SA6"},/*[Ordem]*/ )//"Dados Bancarios"
TRCell():New(oBanco,"A6_COD" 		,"SA6",STR0008,,23,.F.)//"BANCO"             
TRCell():New(oBanco,"A6_AGENCIA"	,"SA6",STR0009) //"   AGENCIA "
TRCell():New(oBanco,"A6_NUMCON"	,"SA6",STR0010)//"   CONTA "
TRCell():New(oBanco,"SALDOINI"	,		,STR0034,,20,,)//"SALDO INICIAL"

oMovBanc := TRSection():New(oBanco,STR0036,{"SE5"})//"Movimentos Bancarios"
TRCell():New(oMovBanc,"E5_DTDISPO" ,"SE5",STR0025	,/*Picture*/,12/*Tamanho*/,/*lPixel*/,) //"DATA"
TRCell():New(oMovBanc,"E5_HISTOR"	,"SE5",STR0026	,,,,{|| SubStr(E5_HISTOR,1,TamSX3("E5_HISTOR")[1])},,.T.)//"OPERACAO"
TRCell():New(oMovBanc,"E5_NUMCHEQ"	,"SE5",STR0027	,,36,,{|| If(Len(Alltrim(E5_DOCUMEN)) + Len(Alltrim(E5_NUMCHEQ)) > 35,;  //"DOCUMENTO"
																		Alltrim(SUBSTR(E5_DOCUMEN,1,20)) + If(!empty(Alltrim(E5_DOCUMEN)),"-"," ") + Alltrim(E5_NUMCHEQ ),;
																		If(Empty(E5_NUMCHEQ),E5_DOCUMEN,E5_NUMCHEQ))}) 																												
TRCell():New(oMovBanc,"PREFIXO/TITULO"	,"SE5",STR0028	,,16,,{|| If(E5_TIPODOC="CH",ChecaTp(E5_NUMCHEQ+E5_BANCO+E5_AGENCIA+E5_CONTA),;
                                                                    E5_PREFIXO+If(Empty(E5_PREFIXO)," ","-")+E5_NUMERO+; //"PREFIXO/TITULO"
																	   	             If(Empty(E5_PARCELA)," ","-")+E5_PARCELA)})  


TRCell():New(oMovBanc,"E5_VALOR-ENTRAD","SE5",STR0029	,,20)//"ENTRADAS"
TRCell():New(oMovBanc,"E5_VALOR-SAIDA" ,"SE5",STR0030	,,20)//"SAIDAS"

TRCell():New(oMovBanc,"SALDO ATUAL"		,"SE5",STR0031	,,20,,{|| nSaldoAtu})//"SALDO ATUAL"
TRCell():New(oMovBanc,"TAXA"	,,STR0037,,12)//"CONCILIADOS"
TRCell():New(oMovBanc,"x-CONCILIADOS"	,"SE5",STR0016,,3)//"CONCILIADOS"

oTotal := TRSection():New(oMovBanc,STR0032,{"SE5"},/*[Ordem]*/ )//"Totais"

TRCell():New(oTotal,"DESCRICAO",,STR0033 ,,30,,)//"DESCRICAO"
TRCell():New(oTotal,"NAOCONC"  ,,STR0015 ,,20,,)//"NAO CONCILIADOS" 
TRCell():New(oTotal,"CONC"		 ,,STR0016 ,,20,,)//"CONCILIADOS"
TRCell():New(oTotal,"TOTAL" 	 ,,STR0017 ,,20,,)//"TOTAL"

oTotal:SetLeftMargin(35)

Return(oReport)

/*/
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ChecaTp    � Autor � Andrea Verissimo      � Data �14/12/2010���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Essa funcao retorna os dados do arquivo SEF para movimentos  ���
���          �bancarios do tipo CH.                                        ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �prefixo, titulo e parcela do arquivo SEF.                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros� campos Nro Cheque, Banco, Agencia e Conta do arquivo SE5.   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ChecaTp(cChaveTp)
Local cRetorno := ""
Local cChavSef := ""
Local aArea    := GetArea()
Local nSoma := 0

If(E5_TIPODOC="CH")	     
 cChavSef := (xFilial("SE5")+cChaveTp)
 dbSelectArea("SEF")
 SEF->(dbSetOrder(4))
 SEF->(Dbseek(cChavSef))
 While !EOF() .and. (xFilial("SEF")+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChavSef .and. nSoma <= 1
 	If !Empty(EF_TIPO)   
 	  nSoma++
      cRetorno := EF_PREFIXO+If(Empty(EF_PREFIXO)," ","-")+EF_TITULO+If(Empty(EF_PARCELA)," ","-")+EF_PARCELA
    Endif
	 SEF->(Dbskip())
 Enddo

	If nSoma > 1
	 cRetorno := "   "	
	 nSoma := 0
	Endif
	
 dbCloseArea()
 RestArea(aArea)
 nSoma := 0
EndIF
Return (cRetorno)
		
/*/
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Adrianne Furtado      � Data �27.06.2006���
��������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os  ���
���          �relatorios que poderao ser agendados pelo usuario.           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                   ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)

Local oBanco	:= oReport:Section(1)
Local oMovBanc	:= oReport:Section(1):Section(1)    
Local oTotal	:= oReport:Section(1):Section(1):Section(1)
Local cAlias
Local lAllFil	:= .F.
Local cChave	:= ""
Local cAliasSA6	:= "SA6"
Local cAliasSE5	:= "SE5"
Local cSql1:= cSql2	:= ""
Local nMoeda	:= GetMv("MV_CENT"+(IIF(mv_par06 > 1 , STR(mv_par06,1),"")))            
LOCAL lSpbInUse	:= SpbInUse()        
Local nSaldoAtu	:= 0    
Local cTabela14	:= ""   
//Local nCol		:= 0      
Local aRecon 	:= {}     
//Local nTotEnt	:= 0 
//Local nTotSaida	:= 0    
Local nLimCred	:= 0     
//Local nRecebNCon:= 0
//Local nRecebConc:= 0   
//Local cPictVlr	:=	tm(SE5->E5_VALOR,15,nMoeda)
Local nX
Local aTotais := {}
Local nLinReport 	:= 8
Local nLinPag		:= mv_par08 
Local cExpMda		:= ""
Local nCont 		:= 0
Local cCampos 		:= ""
Local nTaxa 		:= 0  
Local lMultSld    := (FindFunction( "FXMultSld" ) .AND. FXMultSld())   
Local lMsmMoeda   := .F.     
//Local lCxLoja := GetNewPar("MV_CXLJFIN",.F.)

#IFNDEF TOP
	Local cCondicao := ""
	Local cFiltSE5 := oReport:Section(1):GetAdvplExp("SE5")
#ENDIF                       

Private nTxMoedBc := 0
Private nMoedaBco := 1

Pergunte( "FIN470", .F. )
AAdd( aRecon, {0,0,0,0} )   

dbSelectArea("SA6")
dbSetOrder(1)
IF !(dbSeek(cFilial+mv_par01+mv_par02+mv_par03))
	Help(" ",1,"BCONOEXIST")
	Return
EndIF

nMoedaBco	:=	Max(A6_MOEDA,1)

// Carrega a tabela 14
cTabela14 := FR470Tab14() 

//��������������������������������������������������������������Ŀ
//� Saldo de Partida 											 �
//����������������������������������������������������������������
dbSelectArea("SE8")
dbSetOrder(1)			
dbSeek(xFilial("SE8")+mv_par01+mv_par02+mv_par03+Dtos(mv_par04),.T.)   // filial + banco + agencia + conta
dbSkip(-1)

IF E8_FILIAL != xFilial("SE8") .Or. E8_BANCO!=mv_par01 .or. E8_AGENCIA!=mv_par02 .or. E8_CONTA!=mv_par03 .or. BOF() .or. EOF()
	nSaldoAtu:=0
	nSaldoIni:=0
Else
	If mv_par07 == 1  //Todos
		nSaldoAtu:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	ElseIf mv_par07 == 2 //Conciliados
		nSaldoAtu:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	ElseIf mv_par07 == 3	//Nao Conciliados
		nSaldoAtu:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	Endif	
Endif

If Empty(xFilial( "SA6")) .and. !Empty(xFilial("SE5"))
	cChave	:= "DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA"
	lAllFil:= .T.
Else
	cChave  := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA"
EndIf
        
If ExistBlock("F470ALLF")
	lAllFil := ExecBlock("F470ALLF",.F.,.F.,{lAllFil})
EndIf
//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
#IFDEF TOP

	cAlias := GetNextAlias()

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �	
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)

	//������������������������Ŀ
	//�Query do relat�rio      �
	//��������������������������
	oBanco:BeginQuery()	     
	
	If	lAllFil
		cOrder  := "%E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ%"
	Else
		cSql1	:=	"E5_FILIAL = '" + xFilial("SE5") + "'" + " AND "
		If Empty(xFilial("SE5")) .and. !Empty(xFilial("SE8"))
			cSql1	+=	"E5_FILORIG = '" + xFilial("SE8") + "'" + " AND "
		Endif
		
		cOrder  := "%E5_FILIAL,E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ%"
	EndIf           
	If lSpbInuse	                                                
		cSql1	+=	" E5_DTDISPO >=  '"     + DTOS(mv_par04) + "' AND"
			cSql1	+=	" ((E5_DTDISPO <= '"+ DTOS(mv_par05) + "') OR "
		cSql1	+=	"  (E5_DTDISPO >= '"+ DTOS(mv_par05) + "' AND "
		cSql1	+=	"  (E5_DATA    >= '"+ DTOS(mv_par04) + "' AND " 
		cSql1	+=	"   E5_DATA    <= '"+ DTOS(mv_par05) + "'))) AND"			
	Else			                                  
		cSql1	+=	" E5_DTDISPO >= '" + DTOS(mv_par04) + "' AND"
		cSql1	+=	" E5_DTDISPO <= '" + DTOS(mv_par05) + "' AND"
	EndIf                           
	If mv_par07 == 2
		cSql1	+=	" E5_RECONC <> ' ' AND "
	ElseIf mv_par07 == 3
		cSql1	+=	" E5_RECONC = ' ' AND " 
	EndIf

	cSql1 := "%"+cSql1+"%"
	//cCampos := "E5_DTDISPO,	E5_HISTOR,E5_RECPAG, 	E5_VALOR, 	E5_MOEDA, 	E5_VLMOED2, E5_CLIFOR, 	E5_LOJA, 	E5_RECONC, E5_TIPO, E5_MOTBX, "
	cCampos := "E5_DTDISPO,"
	// *****  CUSTOMIZADO BK
	cCampos += " E5_HISTOR = CASE E5_CLIFOR"
	cCampos += " WHEN '' THEN SE5.E5_HISTOR" 
	cCampos += " ELSE( CASE E5_RECPAG"
 	cCampos += " WHEN 'P' THEN (SELECT 'Pgto Tit. '+E5_NUMERO+' '+A2_NOME FROM "+RETSQLNAME("SA2")+ " SA2 WHERE  A2_COD=E5_CLIFOR AND A2_LOJA=E5_LOJA AND SA2.D_E_L_E_T_=' ') "
 	cCampos += " WHEN 'R' THEN (SELECT 'Rec Tit. '+E5_NUMERO+' '+A1_NOME FROM "+RETSQLNAME("SA1")+ " SA1 WHERE  A1_COD=E5_CLIFOR AND A1_LOJA=E5_LOJA AND SA1.D_E_L_E_T_=' ')"  
 	cCampos += " END) END,"
	// *****  CUSTOMIZADO BK
    
    cCampos += "E5_NUMCHEQ,	E5_DOCUMEN, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPODOC, "
	cCampos += "E5_RECPAG, 	E5_VALOR, 	E5_MOEDA, 	E5_VLMOED2, E5_CLIFOR, 	E5_LOJA, 	E5_RECONC, E5_TIPO, E5_MOTBX, "
	
	//Necessario incluir alguns campos de acordo com a alteracao realizada para a exibicao no relatorio dos dados corretos 
	//de um titulo a pagar quando baixado como normal e com cheque. 
	cCampos += "E5_BANCO, E5_AGENCIA, E5_CONTA, "
	
	cCampos += "A6_FILIAL, 	A6_COD, 	A6_NREDUZ, 	A6_AGENCIA, A6_NUMCON, A6_LIMCRED"
	If SE5->( FieldPos("E5_TXMOEDA") > 0 )
		cCampos += ", E5_TXMOEDA "
	EndIf
	cCampos := "%"+cCampos+"%"	  
	
	cExpMda	:= "%E5_MOEDA NOT IN " + FormatIn(cTabela14+"/DO","/") + "%"
	
	BeginSql Alias cAlias  
	Select	%Exp:cCampos%
	FROM 	%table:SE5% SE5
			LEFT JOIN %table:SA6% SA6 ON
			(E5_BANCO 	= A6_COD AND
			E5_AGENCIA	= A6_AGENCIA AND
			E5_CONTA 	= A6_NUMCON) 
	WHERE 	%Exp:cSql1%     
			A6_FILIAL 	= %xFilial:SA6% AND
			E5_BANCO 	= %Exp:mv_par01% AND
			E5_AGENCIA 	= %Exp:mv_par02% AND
			E5_CONTA 	= %Exp:mv_par03% AND		
			E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','BA') AND 
			NOT (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ = '               ' AND (E5_TIPODOC NOT IN('TR','TE'))) AND	
			NOT (E5_TIPODOC IN ('TR','TE') AND ((E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') OR (E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' ))) AND
			NOT (E5_TIPODOC IN ('TR','TE') AND E5_NUMERO = '      ' AND %Exp:cExpMda% ) AND
			E5_SITUACA <> 'C' AND
			E5_VALOR   <> 0 AND
			NOT(E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') AND//NOT LIKE '*%' AND
			(E5_VENCTO <= %Exp:DTOS(mv_par05)% OR E5_VENCTO <= E5_DATA) AND 
			SE5.%notDel% AND
			SA6.%notDel%
	ORDER BY %exp:cOrder%			
	EndSql               
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//��������������������������������������������������������������������������
	oBanco:EndQuery(/*Array com os parametros do tipo Range*/)

	oMovBanc:SetParentQuery()

	cAliasSA6	:= cAlias
	cAliasSE5 	:= cAlias
#ELSE

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao Advpl                          �
	//��������������������������������������������������������������������������

	DbSelectArea("SE5")
	DbSetOrder(1)

	MakeAdvplExpr(oReport:uParam)
                   
	If	lAllFil
		cOrder  := "DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
	Else
		cOrder  := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
		cCondicao := 'E5_FILIAL == "' + xFilial("SE5")+'" .And.'
		If Empty(xFilial("SE5")) .and. !Empty(xFilial("SE8"))
			cCondicao += 'E5_FILORIG == "' + xFilial("SE8")+'" .And.'
		Endif
	EndIf           
	If lSpbInuse	                                                
		cCondicao	+=	" ((DTOS(E5_DTDISPO) <= '"+ DTOS(mv_par05) + "') .OR. "
		cCondicao	+=	"  (DTOS(E5_DTDISPO) >= '"+ DTOS(mv_par05) + "' .And. "
		cCondicao	+=	"  (DTOS(E5_DATA)    >= '"+ DTOS(mv_par04) + "' .And. " 
		cCondicao	+=	"   DTOS(E5_DATA)    <= '"+ DTOS(mv_par05) + "'))) .And. "			
	EndIf 
	cCondicao += 'DTOS(E5_DTDISPO) >= "' + DTOS(mv_par04) + '" .And. '
	cCondicao += 'DTOS(E5_DTDISPO) <= "' + DTOS(mv_par05) + '" .And. '
	cCondicao += 'E5_BANCO   == "' + mv_par01 + '" .And. '
	cCondicao += 'E5_AGENCIA == "' + mv_par02 + '" .And. '
	cCondicao += 'E5_CONTA   == "' + mv_par03 + '" .And. '
	cCondicao += 'E5_SITUACA <> "C" .And. '   //Cancelado
	cCondicao += 'E5_VALOR   <> 0 .And. '  			
	cCondicao += '!(E5_TIPODOC $ "DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL/BA") .And. ' 	
	cCondicao += '!(E5_MOEDA $ "C1/C2/C3/C4/C5/CH" .And. E5_NUMCHEQ = "               " .And. !(E5_TIPODOC $ "TR#TE")) .And.'
	cCondicao += '(DTOS(E5_VENCTO) <= "' + DTOS(mv_par05) + '".Or. E5_VENCTO <= E5_DATA)'
	
	//Adiciona filtro do usu�rio
	If !Empty(cFiltSE5)
		cCondicao += ' .And. ' + cFiltSE5
   EndIf
                    
	oMovBanc:SetFilter( cCondicao, cOrder )

	oMovBanc:SetRelation( {|| xFilial((cAliasSE5))+(cAliasSA6)->(A6_COD+A6_AGENCIA+A6_NUMCON)},cAliasSA6,1,.T.)
	oMovBanc:SetParentFilter( {|cParam| (cAliasSE5)->(E5_BANCO+E5_AGENCIA+E5_CONTA) == cParam}, { || (cAliasSA6)->(A6_COD+A6_AGENCIA+A6_NUMCON) } )
                               
#ENDIF		

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������

cMoeda := Upper(GetMv("MV_MOEDA"+LTrim(Str(mv_par06))))

nTxMoeda := If(nTxMoedBc > 1, nTxMoedBc,RecMoeda(iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06))

oReport:SetTitle(OemToAnsi(oReport:Title()+" ENTRE " +DTOC(mv_par04) + " e " +Dtoc(mv_par05)+" EM "+ cMoeda))//"EXTRATO BANCARIO ENTRE " 
oMovBanc:Cell("E5_VALOR-ENTRAD"	):SetPicture(tm(E5_VALOR,20,nMoeda))
oMovBanc:Cell("E5_VALOR-SAIDA"	):SetPicture(tm(E5_VALOR,20,nMoeda))    
oMovBanc:Cell("TAXA"	):SetPicture(tm(E5_VALOR,12,nMoeda))
oMovBanc:Cell("SALDO ATUAL"		):SetPicture(tm(E5_VALOR,20,nMoeda))

If lMultSld .And. !Empty((cAliasSE5)->E5_TXMOEDA)
	If (cAliasSE5)->E5_RECPAG == "P"
		lMsmMoeda := Posicione("SE2",1,xFilial("SE2")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E2_MOEDA") == mv_par06
	Else
		lMsmMoeda := Posicione("SE1",1,xFilial("SE1")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E1_MOEDA") == mv_par06
	EndIf
EndIf

oMovBanc:Cell("SALDO ATUAL"		):SetBlock({|| nSaldoAtu += Round(xMoeda(F470VlMoeda(cAliasSE5);
	,Iif((cPaisLoc <> "BRA" .And. ((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)) ,1, nMoedaBco );
	,mv_par06;
	,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
	,nMoeda + 1;
	,IIf(lMultSld, /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/	,	Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,1),nTxMoedBc)));
	,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoeda))));
	,nMoeda) * (If((cAliasSE5)->E5_RECPAG == 'R',1,-1)) })
	
oMovBanc:Cell("E5_VALOR-ENTRAD"	):SetHeaderAlign("RIGHT")           
oMovBanc:Cell("E5_VALOR-SAIDA"	):SetHeaderAlign("RIGHT")
oMovBanc:Cell("SALDO ATUAL"		):SetHeaderAlign("RIGHT")
oMovBanc:Cell("TAXA"		):SetHeaderAlign("CENTER")

// Se realiza controle de saldos em multiplas moedas
If lMultSld                      

	oMovBanc:Cell("E5_VALOR-ENTRAD"  ):SetBlock({|| If((cAliasSE5)->E5_RECPAG == "R", Round(xMoeda(F470VlMoeda(cAliasSE5),;
	nMoedaBco ,;
	mv_par06,;
	iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),;
	nMoeda,;
	IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ),;
	IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA)),nMoeda), nil)})

	oMovBanc:Cell("E5_VALOR-SAIDA"   ):SetBlock({|| ;	
		If((cAliasSE5)->E5_RECPAG == "P",;			
			Round(xMoeda(F470VlMoeda(cAliasSE5), ;
			nMoedaBco ,;
			mv_par06,;
			iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),;
			nMoeda,;
			IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ),;
			IIf(!lMsmMoeda, RecMoeda(E5_DTDISPO,mv_par06) , (cAliasSE5)->E5_TXMOEDA)),nMoeda),nil)})

Else
    
	oMovBanc:Cell("E5_VALOR-ENTRAD"  ):SetBlock({||If((cAliasSE5)->E5_RECPAG == "R", Round(xMoeda(F470VlMoeda(cAliasSE5);
		,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
		,mv_par06;
		,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
		,nMoeda+1;
		,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/,nTxMoedBc));
		,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoeda)));
		,nMoeda), nil)})

	oMovBanc:Cell("E5_VALOR-SAIDA"   ):SetBlock({||; 
		If((cAliasSE5)->E5_RECPAG == "P", ;
			Round(	xMoeda(F470VlMoeda(cAliasSE5),Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
							,mv_par06;
							,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
							,nMoeda+1;
							,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc));
			 				,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc,if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoeda));
		  			);
			,nMoeda);
	 	, nil);
  	})
     
EndIf

oMovBanc:Cell("x-CONCILIADOS"		):SetBlock({|| Iif(Empty((cAliasSE5)->E5_RECONC), " ", "x")})
oMovBanc:Cell("x-CONCILIADOS"		):SetTitle("")

If cPaisLoc <> "BRA"
    If cPaisLoc<>"ANG"
		If mv_par06 <> nMoedaBco .And. mv_par06 > 1
			oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(iif(MV_PAR09==1,dDataBase,E5_DTDISPO),mv_par06))})
		Else
			oMovBanc:Cell("TAXA"):Disable()
		EndIf
	Else    
	    If mv_par06 <> nMoedaBco
	        If nMoedaBco>1
				oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(E5_DTDISPO,nMoedaBco))})
			Else
				oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA))})
			EndIf
		Else
			oMovBanc:Cell("TAXA"):Disable()
		EndIf
	EndIf
Else
	oMovBanc:Cell("TAXA"):Disable()
EndIf	

oBanco:SetLineStyle()

nLimCred := (cAliasSA6)->(A6_LIMCRED)

oBanco:Init()         

oBanco:Cell("SALDOINI"):SetBlock( { || Transform(nSaldoIni,tm(nSaldoIni,16,nMoeda)) } )
oBanco:Cell("SALDOINI"):SetHeaderAlign("RIGHT")

oMovBanc:OnPrintLine( {|| F470LinPag(nLinPag, @nLinReport)})

(cAliasSE5)->(dbEval({|| nCont++}))
(cAliasSE5)->(dbGoTop())

If (cAliasSE5)->(Eof())  
	oBanco:Cell("A6_COD"):SetBlock( {|| SA6->A6_COD +" - "+AllTrim(SA6->A6_NREDUZ)} )
	oBanco:Cell("A6_AGENCIA"):SetBlock( {|| SA6->A6_AGENCIA } )
	oBanco:Cell("A6_NUMCON"):SetBlock( {|| SA6->A6_NUMCON } )
	oBanco:PrintLine()
	oMovBanc:Init()
	oMovBanc:PrintLine()
	oMovBanc:Finish()
Else
	oBanco:Cell("A6_COD"):SetBlock( {|| (cAliasSA6)->A6_COD +" - "+AllTrim((cAliasSA6)->A6_NREDUZ)} )
	oReport:OnPageBreak( { || oBanco:PrintLine() } )
EndIf	

oReport:SetMeter(nCont)

While !oReport:Cancel() .And. (cAliasSE5)->(!Eof())          					
     
	If oReport:Cancel()
		Exit
	EndIf	

	If oBanco:Cancel()
		Exit
	EndIf
	
	lFirst := .T.

	oMovBanc:Init()               
	While !oReport:Cancel() .And. !(cAliasSE5)->(Eof())
		If oReport:Cancel()
			Exit
		EndIf               

		oReport:IncMeter()		          

		#IFNDEF TOP            
		If (cAliasSE5)->E5_TIPODOC $ "TR/TE" .and. Empty((cAliasSE5)->E5_NUMERO)
			If !((cAliasSE5)->E5_MOEDA $ cTabela14)
				dbSkip()
				Loop
			Endif
		Endif
		If (cAliasSE5)->E5_TIPODOC $ "TR/TE" .and. (Substr((cAliasSE5)->E5_NUMCHEQ,1,1)=="*" .or. Substr((cAliasSE5)->E5_DOCUMEN,1,1) == "*" )
			dbSkip()
			Loop
		Endif
		If !Fr470Skip(mv_par01,mv_par02,mv_par03)
			(cAliasSE5)->(dbSkip())
			Loop
		EndIf	                                                  
		#ENDIF
        
		nTxMoedBc 	:= 0 
		
		If !Empty( (cAliasSE5)->E5_MOTBX )
			If !MovBcoBx( (cAliasSE5)->E5_MOTBX )
				dbSkip( )
				Loop
			EndIf
		EndIf
      //Inserido o mesmo tratamento existente no formato R3
        
		If cPaisloc<>"BRA"
			nTaxa := TxMoeda(cAliasSE5, nMoedaBco)
			If mv_par09 == 1
				nTxMoedBc := 0 //RecMoeda(dDatabase,nMoedaBco)
			Else
				nTxMoedBc := nTaxa
			Endif
		EndIf
					
		oMovBanc:PrintLine()          

		If Empty((cAliasSE5)->E5_RECONC) .AND. (cAliasSE5)->E5_RECPAG == "R"			
			aRecon[1][REC_NAO_CONCILIADO] += Round(xMoeda( F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
			,nMoeda+1;
			,IIf(lMultSld, /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoedBc))));
			,nMoeda)
		ElseIf E5_RECPAG == "R"			
			aRecon[1][REC_CONCILIADO] += Round(xMoeda(F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);                                                                          
			,nMoeda+1;
			,IIf(lMultSld,/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/ ,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoedBc))));
			,nMoeda)
		ElseIf Empty( E5_RECONC ) .AND. E5_RECPAG == "P"			
			aRecon[1][PAG_NAO_CONCILIADO] += Round(xMoeda(F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
			,nMoeda+1;
			,IIf(lMultSld,/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoeda))));
			,nMoeda)
		ElseIf E5_RECPAG == "P"			
			aRecon[1][PAG_CONCILIADO] += Round(xMoeda(F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
			,nMoeda+1;
			,IIf(lMultSld,/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoedBc))));
			,nMoeda)
		EndIf

		(cAliasSE5)->(dbSkip())
	EndDo       
	oMovBanc:Finish()        
	oReport:SkipLine()
EndDo
oBanco:Finish()    

AADD( aTotais ,{STR0014,,,nSaldoIni})//"SALDO INICIAL...........: "
AADD( aTotais ,{STR0018,aRecon[1][REC_NAO_CONCILIADO],aRecon[1][REC_CONCILIADO],aRecon[1][REC_NAO_CONCILIADO] +  aRecon[1][REC_CONCILIADO]})//"ENTRADAS NO PERIODO.....: "
AADD( aTotais ,{STR0019,aRecon[1][PAG_NAO_CONCILIADO],aRecon[1][PAG_CONCILIADO],aRecon[1][PAG_NAO_CONCILIADO] +  aRecon[1][PAG_CONCILIADO] })//"SAIDAS NO PERIODO ......: "
AADD( aTotais ,{STR0021,,,nLimCred})//"LIMITE DE CREDITO.......: "
AADD( aTotais ,{STR0020,,,nSaldoAtu += nLimCred})//"SALDO ATUAL ............: "

oTotal:Init()

oTotal:Cell("DESCRICAO"):HideHeader()
oTotal:Cell("NAOCONC"):SetHeaderAlign("CENTER")
oTotal:Cell("CONC"):SetHeaderAlign("CENTER")
oTotal:Cell("TOTAL"):SetHeaderAlign("CENTER")

For nX := 1 to 5
	oTotal:Cell("DESCRICAO"):SetBlock( { || aTotais[nX][1] } )
	oTotal:Cell("NAOCONC")	:SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][2],tm(aTotais[nX][2],16,nMoeda)),"")} )
	oTotal:Cell("CONC") 		:SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][3],tm(aTotais[nX][3],16,nMoeda)),"")} )
	oTotal:Cell("TOTAL")		:SetBlock( { || Transform(aTotais[nX][4],tm(aTotais[nX][4],16,nMoeda))} )
	If nX == 2 .Or. nX == 5
		oReport:SkipLine()
	EndIf
	oTotal:PrintLine()
Next

oReport:Title(STR0004) 
oTotal:Finish()
                                          
Return NIL          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | F470VlMoeda  �Autor � TOTVS            � Data � 09/06/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Retorno o campo de valor a ser utilizado para convers�o    ���
�������������������������������������������������������������������������͹��
���Parametros� cAliasSE5												  ���
�������������������������������������������������������������������������͹��
���Retorno   � nVlMoeda = Retorna o campo E5_VALOR ou E5_VLMOED2          ���
�������������������������������������������������������������������������͹��
���Uso       � FINR470                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F470VlMoeda(cAliasSE5)                                
Local nVlMoeda:=0
Local cMoeda    
Local lSpbInUse := SpbInUse()                 

cMoeda := Iif((cPaisLoc<>"BRA" .And. ((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .And. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco )

If cPaisLoc $ "ARG|MEX" //Grava�ao do SE5 nas rotina da argentina s�o diferentes
	If cMoeda <> 1 
	   If (mv_par06 == 1) .OR. (mv_par06 == cMoeda)
		    nVlMoeda := (cAliasSE5)->E5_VALOR
		Else 
			If (cAliasSE5)->E5_VLMOED2 > 0
			   nVlMoeda := (cAliasSE5)->E5_VLMOED2   
			Else
				nVlMoeda := (cAliasSE5)->E5_VALOR
			EndIf
		EndIf
	Else
		nVlMoeda := (cAliasSE5)->E5_VALOR
	EndIf

Else

	If lSpbInUse .And. !lTReport
   	cAliasSE5 := "TRB"
	EndIf
	
	If cMoeda <> 1 
		nVlMoeda := (cAliasSE5)->E5_VALOR
	   //***********************************************
	   // Bloco comentado pois a movimenta��o bancaria *
	   // � sempre feita na moeda do banco.            *
	   //***********************************************
	   /*If mv_par06 == 1 .and. (mv_par06 == cMoeda)
		    nVlMoeda := (cAliasSE5)->E5_VALOR
		Else  
			If (cAliasSE5)->E5_VLMOED2 > 0 .AND. !((cAliasSE5)->E5_TIPO $ MVRECANT ) // MOVIMENTO DE RA TEM COMPORTAMENTO DIFERENTE NA GRAVA��O DA SE5
			   nVlMoeda := (cAliasSE5)->E5_VLMOED2   
			Elseif (cAliasSE5)->E5_TIPO $ MVRECANT .and. (cAliasSE5)->E5_RECPAG == "P" // MOVIMENTO DE RA TEM COMPORTAMENTO DIFERENTE NA GRAVA��O DA SE5
			   nVlMoeda := (cAliasSE5)->E5_VLMOED2   
			Else
				nVlMoeda := (cAliasSE5)->E5_VALOR
			EndIf
		EndIf
		*/
	Else
		nVlMoeda := (cAliasSE5)->E5_VALOR
	EndIf

Endif	
Return (nVlMoeda)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | F470LinPag   �Autor � Marcio Menon	   � Data � 29/06/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Faz a quebra de pagina de acordo com o parametro "Linhas   ���
���          � por Pagina?" (mv_par08)                                    ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Numero maximo de linhas definido no relatorio      ���
���          � EXPL2 - Contador de linhas impressas no relatorio          ���
�������������������������������������������������������������������������͹��
���Retorno   � nil                                                        ���
�������������������������������������������������������������������������͹��
���Uso       � FINR470                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function F470LinPag(nLinPag, nLinReport)

nLinReport++

If nLinReport > (nLinPag + 8)
	oReport:EndPage()
	nLinReport := 9
EndIf

Return Nil


//------------------------------------------------------- R3 ------------------------------------------------------------------------




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINR470	� Autor � Wagner Xavier 		� Data � 20.10.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extrato Banc�rio. 										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR470(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC Function FinR470R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 														  �
//����������������������������������������������������������������
LOCAL wnrel
LOCAL cDesc1 := STR0001  //"Este programa ir� emitir o relat�rio de movimenta��es"
LOCAL cDesc2 := STR0002  //"banc�rias em ordem de data. Poder� ser utilizado para"
LOCAL cDesc3 := STR0003  //"conferencia de extrato."
LOCAL cString:="SE5"

PRIVATE Tamanho := "G" //P/M/G   
PRIVATE titulo:=OemToAnsi(STR0004)  //"Extrato Bancario"
PRIVATE cabec1
PRIVATE cabec2   
PRIVATE cabec3
PRIVATE aReturn := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog:="FINR470"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg	 :="FIN470"
PRIVATE aCabecAlt := FR470Alt(STR0011)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 								  �
//����������������������������������������������������������������
ajustasx1()                                                               
pergunte(cPerg,.F.)
//�������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros								 �
//� mv_par01				// Banco 										 �
//� mv_par02				// Agencia										 �
//� mv_par03				// Conta 										 �
//� mv_par04				// a partir de 								 �
//� mv_par05				// ate											 �
//� mv_par06				// Qual Moeda									 �
//� mv_par07				// Demonstra Todos/Conciliados/Nao Conc.�
//� mv_par08				// Linhas por Pagina  ?			    �
//� mv_par09				// Converte Valores pelas ?        
//���������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a fun��o SETPRINT 							  �
//����������������������������������������������������������������
wnrel := "FINR470"            //Nome Default do relatorio em Disco
WnRel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

//����������������������������������������������������������������Ŀ
//� Envia controle para a funcao REPORTINI substituir as variaveis.�
//������������������������������������������������������������������
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| Fa470Imp(@lEnd,wnRel,cString)},titulo)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FA470IMP � Autor � Wagner Xavier 		� Data � 20.10.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extrato Banc�rio. 										  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FA470Imp(lEnd,wnRel,cString)
LOCAL CbCont,CbTxt
LOCAL cBanco,cNomeBanco,cAgencia,cConta
LOCAL nSaldoAtu:=0,nTipo,nSaldoIni:=0
LOCAL cDOC
LOCAL cFil	  :=""
LOCAL cChave
LOCAL cIndex
LOCAL aRecon := {}
Local nTxMoeda := 1
Local nValor := 0
Local aStru 	:= SE5->(dbStruct())
Local nI	:= 0
Local nMoeda	:= GetMv("MV_CENT"+(IIF(mv_par06 > 1 , STR(mv_par06,1),"")))
LOCAL nSalIniStr := 0
LOCAL nSalIniCip := 0
LOCAL nSalIniComp := 0
LOCAL nSalStr := 0
LOCAL nSalCip := 0    
LOCAL nSalComp := 0
LOCAL lSpbInUse := SpbInUse()
Local cFilterUser
Local cTabela14 := ""
Local nLin	:= mv_par08
Local lCxLoja := GetNewPar("MV_CXLJFIN",.F.)
Local cAlias := "SE5"           
Local nTaxa:=0  
//Local lTaxa:=.F. 
Local lLayout := aReturn[4] == 1 .And. cPaisLoc == "BRA" //Retrato   
Local lMsmMoeda	:= .F.
Local cHistor	:= ""
Local aHistor	:= {}
lOCAL nTamHist	:= 50		//Quantidade maxima de caracteres para a coluna do historico. Quando o conteudo desse campos exceder este limite, devera ser impresso em varias linhas
Local cCposQry	:= ""
Local cFilQry	:= ""
//Local cFilSE5	:= xFilial("SE5")
Local lFxMultSld := FindFunction( "FXMultSld" )
Local aArea	     
Local cChSef := "" 
Local nSoma := 0
Local cChave2 := ""
AAdd( aRecon, {0,0,0,0} )

//��������������������������������������������������������������Ŀ
//� Variaveis privadas exclusivas deste programa                 �
//����������������������������������������������������������������
PRIVATE cCondWhile, lAllFil :=.F.
Private nMoedaBco := 1
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	  �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("SA6")
dbSetOrder(1)
IF !(dbSeek(cFilial+mv_par01+mv_par02+mv_par03))
	Help(" ",1,"BCONOEXIST")
	Return
EndIF
nLin		:=  mv_par08 + 9
cBanco		:= A6_COD
cNomeBanco	:= A6_NREDUZ
cAgencia	:= A6_AGENCIA
cConta		:= A6_NUMCON
nLimCred	:= A6_LIMCRED
nMoedaBco	:=	Max(A6_MOEDA,1)

// Carrega a tabela 14
cTabela14 := FR470Tab14() 

//��������������������������������������������������������������Ŀ
//� Defini��o dos cabe�alhos									 �
//����������������������������������������������������������������
cMoeda := Upper(GetMv("MV_MOEDA"+LTrim(Str(mv_par06))))
If cPaisLoc <> "BRA" 
	titulo := OemToAnsi(STR0007)+DTOC(mv_par04) + " e " +Dtoc(mv_par05)+" EN "+ cMoeda  //"EXTRATO BANCARIO ENTRE "
Else
	titulo := OemToAnsi(STR0007)+DTOC(mv_par04) + " e " +Dtoc(mv_par05)+" EM "+ cMoeda  //"EXTRATO BANCARIO ENTRE " 
EndIf
cabec2 := ""
cabec3 := OemToAnsi(STR0008)+ cBanco +" - " + ALLTRIM(cNomeBanco) + OemToAnsi(STR0009)+ cAgencia + OemToAnsi(STR0010)+ cConta  //"BANCO "###"   AGENCIA "###"   CONTA "
If cPaisLoc <> "BRA" .And. mv_par06 <> nMoedaBco  .And. nMoedaBco == 1
	cabec1 := OemToAnsi(STR0011) + Space(5) + Upper(OemToAnsi(STR0037))  //"DATA     OPERACAO                          DOCUMENTO         PREFIXO/TITULO          ENTRADAS           SAIDAS         SALDO ATUAL"
Else
	If !lLayout //Paisagem
		cabec1 := OemToAnsi(STR0011)  //"DATA     OPERACAO                          DOCUMENTO         PREFIXO/TITULO          ENTRADAS           SAIDAS         SALDO ATUAL"	
	Else
		cabec1 := aCabecAlt[1]  //DATA        DOCUMENTO                                          ENTRADAS          SALDO ATUAL
     	cabec2 := aCabecAlt[2]  //     OPERACAO                        PREFIXO/TITULO          SAIDAS
	EndIf		
EndIf

nTipo  :=IIF(aReturn[4]==1,15,18)
//Filtro do usuario
cFilterUser:=aReturn[7]
//��������������������������������������������������������������Ŀ
//� Saldo de Partida 											 �
//����������������������������������������������������������������
dbSelectArea("SE8")
dbSetOrder(1)
dbSeek( cFilial+cBanco+cAgencia+cConta+Dtos(mv_par04),.T.)
dbSkip(-1)

IF E8_FILIAL != xFilial("SE8") .Or. E8_BANCO!=cBanco .or. E8_AGENCIA!=cAgencia .or. E8_CONTA!=cConta .or. BOF() .or. EOF()
	nSaldoAtu:=0
	nSaldoIni:=0
Else
	If mv_par07 == 1  //Todos
		nSaldoAtu:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)	
	ElseIf mv_par07 == 2 //Conciliados
		nSaldoAtu:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	ElseIf mv_par07 == 3	//Nao Conciliados
		nSaldoAtu:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	Endif	
Endif
If lSpbInUse
	nSalIniStr := 0
	nSalIniCip := 0
	nSalIniComp := 0
Endif		

//��������������������������������������������������������������Ŀ
//� Filtra o arquivo por tipo e vencimento						 �
//����������������������������������������������������������������
If Empty(xFilial( "SA6")) .and. !Empty(xFilial("SE5"))
	cChave	:= "DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA"
	lAllFil:= .T.
Else
	cChave  := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA"
EndIf

If ExistBlock("F470ALLF")
	lAllFil := ExecBlock("F470ALLF",.F.,.F.,{lAllFil})
EndIf

#IFNDEF TOP	
	dbSelectArea("SE5")
	dbSetOrder(1)
	cIndex	:= GetNextAlias()
	dbSelectArea("SE5")
	IndRegua("SE5",cIndex,cChave,,Nil,OemToAnsi(STR0012))  //"Selecionando Registros..."
	nIndex	:= RetIndex("SE5")
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	cFil:= Iif(lAllFil,"",xFilial("SE5"))
	dbSeek(cFil+DtoS(mv_par04),.T.)
#ELSE
	If TcSrvType() == "AS/400"
		dbSelectArea("SE5")
		dbSetOrder(1)
		cIndex	:= GetNextAlias()
		dbSelectArea("SE5")
		IndRegua("SE5",cIndex,cChave,,Nil,OemToAnsi(STR0012))  //"Selecionando Registros..."
		nIndex	:= RetIndex("SE5")
		dbSetOrder(nIndex+1)
		cFil:= Iif(lAllFil,"",xFilial("SE5"))
		dbSeek(cFil+DtoS(mv_par04),.T.)
	EndIf	
#ENDIF

#IFNDEF TOP
	SetRegua(LastRec())
	If  lAllFil
		cCondWhile := "!Eof() .And. E5_DTDISPO <= mv_par05"
	Else
		If Empty(xFilial("SE5")) .and. !Empty(xFilial("SE8"))
			cCondWhile := "!Eof() .And. E5_FILIAL == xFilial('SE5') .And. E5_FILORIG == xFilial('SE8') .And. E5_DTDISPO <= mv_par05"
		Else
			cCondWhile := "!Eof() .And. E5_FILIAL == xFilial('SE5') .And. E5_DTDISPO <= mv_par05"		
		Endif

	EndIf
#ELSE
	If TcSrvType() != "AS/400"
		SetRegua(0)
		DbSelectArea("SE5")
		DbSetOrder(1)
		cCondWhile := " !Eof() "
		cAlias := If(lSpbInUse, "SE5", "SE5SQ")

		If	lAllFil
			cOrder	  := "E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ "
			cCposQry  := "E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, "
		Else
			cOrder    := "E5_FILIAL, E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ "
			cCposQry  := "E5_FILIAL, E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, "
		EndIf
	          
    	If cPaisloc == "BRA"
			cCposQry += "E5_TIPODOC, E5_MOEDA, E5_DOCUMEN, E5_VALOR, E5_SITUACA, E5_DATA, E5_RECPAG, E5_RECONC, E5_MODSPB, E5_TXMOEDA, E5_VENCTO, "
		Else
			cCposQry += "E5_TIPODOC, E5_MOEDA, E5_DOCUMEN, E5_VALOR, E5_SITUACA, E5_DATA, E5_RECPAG, E5_RECONC, E5_TXMOEDA, E5_VENCTO, " 
		Endif		
		cCposQry += "E5_HISTOR, E5_VLMOED2, E5_MOTBX, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR "

		//��������������������������������������������������������������Ŀ
		//� Converte filtro de usuario para clausula WHERE da Query      �
		//����������������������������������������������������������������
		If !Empty(cFilterUser)
			cFilQry := PcoParseFil(cFilterUser,"SE5")
			//��������������������������������������������������������������Ŀ
			//� Se nao conseguiu converter o filtro de usuario, traz todos   �
			//� os campos para executar o filtro dentro do loop em Advpl     �
			//����������������������������������������������������������������
			If Empty( cFilQry )
				cCposQry := "*"			
			EndIf
		EndIf
					
		cQuery := "SELECT " + cCposQry
		cQuery += " FROM " + RetSqlName("SE5") + " WHERE "
		If !lAllFil
			cQuery += "	E5_FILIAL = '" + xFilial("SE5") + "' AND " 
			If Empty(xFilial("SE5")) .and. !Empty(xFilial("SE8"))
				cQuery += "	E5_FILORIG = '" + xFilial("SE8") + "' AND " 
			Endif
		EndIf
		cQuery += " E5_DTDISPO >=  '"     + DTOS(mv_par04) + "'"
		If lSpbInuse
			cQuery += " AND ((E5_DTDISPO <=  '"+ DTOS(mv_par05) + "') OR "
			cQuery += " (E5_DTDISPO >=  '"     + DTOS(mv_par05) + "' AND "
 			cQuery += " (E5_DATA >=  '"  		  + DTOS(mv_par04) + "' AND " 
			cQuery += "  E5_DATA <=  '"     	  + DTOS(mv_par05) + "')))"			
		Else			
			cQuery += " AND E5_DTDISPO <=  '"     + DTOS(mv_par05) + "'"
		Endif
		cQuery += " AND E5_BANCO = '"   + cBanco   + "'"
		cQuery += " AND E5_AGENCIA = '" + cAgencia + "'"
		cQuery += " AND E5_CONTA = '"   + cConta   + "'"
		cQuery += " AND NOT ( E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ' ) "
		cQuery += " AND E5_SITUACA <> 'C' "
		cQuery += " AND E5_VALOR <> 0 "
		cQuery += " AND (E5_VENCTO <= '" + DTOS(mv_par05)  + "' OR E5_VENCTO <= E5_DATA) " 
		If mv_par07 == 2
			cQuery += " AND E5_RECONC <> ' ' "
		ElseIf mv_par07 == 3
			cQuery += " AND E5_RECONC = ' ' " 
		EndIf
		
		cQuery += " AND E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','BA') " 		
		cQuery += " AND NOT ( E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ = '               ' AND ( E5_TIPODOC NOT IN( 'TR', 'TE' ) ) ) "
		cQuery += " AND NOT ( E5_TIPODOC IN ('TR','TE') AND ( ( E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') OR (E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' ))) "
		cQuery += " AND NOT ( E5_TIPODOC IN ('TR','TE') AND E5_NUMERO = '" + Space( TamSX3( "E5_NUMERO" )[1] ) + "' AND E5_MOEDA NOT IN " + FormatIn(cTabela14+"/DO","/") + " ) "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		If !Empty(cFilterUser) .And. !Empty( cFilQry )
			cQuery += "AND (" + cFilQry + ") "
		EndIf
		cQuery += " ORDER BY " + cOrder
	
		cQuery := ChangeQuery(cQuery)

		dbSelectArea("SE5")
		dbCloseArea()

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
	
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField(cAlias, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
	Else		// Se TOP-AS400
		If lAllFil
			cCondWhile := "!Eof() .And. E5_DTDISPO <= mv_par05"
		Else
			cCondWhile := "!Eof() .And. E5_FILIAL == xFilial('SE5') .And. E5_DTDISPO <= mv_par05"
		EndIf
	EndIf
#ENDIF

// Monta arquivo de trabalho (apenas quando usa SPB)
/*
If lSpbInUse
	dbSelectArea("SE5")
	cNomeArq:= GetNextAlias()
	cIndex  := cNomeArq	
	AAdd( aStru, {"E5_BLOQ"	,"C", 01, 0} )
	dbCreate( cNomeArq, aStru )
	USE &cNomeArq	Alias Trb  NEW             
	dbSelectArea("TRB")
	IndRegua("TRB",cIndex,cChave,,,STR0012) //"Selecionando Registros..."		
	dbSetIndex( cNomeArq +OrdBagExt())
	Fr470SPB(cChave, aStru)
Endif
*/

//Filtro do usuario
cFilterUser:=aReturn[7]

If !lLayout//Paisagem
	While &(cCondWhile)

		If !Empty(E5_TXMOEDA) .And. ( lFxMultSld .AND. FXMultSld() ) 
			If E5_RECPAG == "P"
				lMsmMoeda := Posicione("SE2",1,xFilial("SE2")+(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E2_MOEDA") == mv_par06
			Else
				lMsmMoeda := Posicione("SE1",1,xFilial("SE1")+(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E1_MOEDA") == mv_par06
			EndIf
		EndIf
	
		IF lEnd
			@PROW()+1,0 PSAY OemToAnsi(STR0013)  //"Cancelado pelo operador"
			EXIT
		Endif
		
		#IFNDEF TOP
			IncRegua()
			If !Fr470Skip(cBanco,cAgencia,cConta)
				dbSkip()
				Loop
			EndIf	
			//��������������������������������������������������������������Ŀ
			//� Considera filtro do usuario                                  �
			//����������������������������������������������������������������
			If !Empty(cFilterUser).and.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
		#ELSE
			//��������������������������������������������������������������Ŀ
			//� Considera filtro do usuario                                  �
			//����������������������������������������������������������������
			If TcSrvType() == "AS/400"
				If !Fr470Skip(cBanco,cAgencia,cConta)
					dbSkip()
					Loop
				EndIf	
				If !Empty(cFilterUser).and.!(&cFilterUser)
					dbSkip()
					Loop
				Endif
			Else
				If !Empty(cFilterUser) .And. Empty( cFilQry ) 
					If !(&cFilterUser)
						dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf		
		#ENDIF		
	
		If !Empty( E5_MOTBX )
			If !MovBcoBx( E5_MOTBX )
				dbSkip( )
				Loop
			EndIf
		EndIf
	
		IF li > nLin
			cabec(@titulo,cabec1,cabec2,nomeprog,"G",nTipo)
			@ li, 00 PSAY cabec3
			@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
			li++
		EndIF
		
		If lSpbInUse	
			dbSelectArea("TRB")
		Else
			dbSelectArea(cAlias)
		Endif
	    
		If cPaisLoc<>"BRA" 
			nTaxa := TxMoeda(Iif(lSpbInUse,"TRB",cAlias),nMoedaBco)
			If mv_par09 == 1
				nTxMoedBc := 0 //RecMoeda(dDatabase,nMoedaBco)
			Else
				nTxMoedBc := nTaxa
			Endif
		EndIf
	
		@li, 0 PSAY E5_DTDISPO
		/*
		Imprimi a primeira linha do historico, de acordo com o limite da coluna e caso o tamanho desse campo exceda o limite, distribui em 
		quantas linhas forem necessarias */
		@li,11 PSAY Substr(E5_HISTOR,1,nTamHist)
		aHistor := {}
		cHistor := AllTrim(Substr(E5_HISTOR,nTamHist+1))
		While !Empty(cHistor)
			Aadd(aHistor,Substr(cHistor,1,nTamHist))
			cHistor := Substr(cHistor,nTamHist+1)
		Enddo
		
		cDoc := E5_NUMCHEQ
		
		IF Empty( cDoc )
			cDoc := E5_DOCUMEN
		Endif
		
		IF Len(Alltrim(SUBSTR(E5_DOCUMEN,1,35))) + Len(Alltrim(E5_NUMCHEQ)) > 50
			cDoc := Alltrim(SUBSTR(E5_DOCUMEN,1,35)) +if(!empty(Alltrim(E5_DOCUMEN)),"-"," ") + Alltrim(E5_NUMCHEQ )
		Endif
		
		If Substr( cDoc ,1, 1 ) == "*"
			/*
			Imprimi as demais linhas do historico, se o tamanho do campo excedeu limite da coluna*/
			If !Empty(aHistor)
				For nI := 1 To Len(aHistor)
					li++
					If li > nLin
						cabec(@titulo,cabec1,cabec2,nomeprog,"G",nTipo)
						@ li, 00 PSAY cabec3
						@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
						li++
					EndIf
					@li,12 PSAY aHistor[nI]
				Next
			Else
				li++
			Endif
			dbSkip( )
			Loop                                                       
		Endif
		
		@li,076 PSAY IIF(AllTrim(cDoc) == ""," ",AllTrim(cDoc))

		cChSef := ""
		//Caso seja um registro gerado de uma baixa de cheque tipo "CH" deve-se procurar em outro arquivo.
		If E5_TIPODOC = "CH"
	     cChSef := (xFilial("SE5")+E5_NUMCHEQ+E5_BANCO+E5_AGENCIA+E5_CONTA)
	     aArea	:= GetArea()	     
	     dbSelectArea("SEF")
	     SEF->(dbSetOrder(4))
		  SEF->(Dbseek(cChSef))
		  While !EOF() .and. (xFilial("SEF")+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChSef  .and. nSoma <= 1
		    If !Empty(EF_TIPO)
				nSoma++
				cChave2 := EF_PREFIXO+IIF(EMPTY(EF_PREFIXO)," ","-")+EF_TITULO+IIF(EMPTY(EF_PARCELA)," ","-")+EF_PARCELA		  
		    Endif
	    	
		    SEF->(Dbskip())
		    
		    
		  Enddo
			If nSoma = 1
	   		@li,094 PSAY cChave2
	   		nSoma := 0
			Endif
		  
		  	dbCloseArea()
         RestArea(aArea)
         nSoma := 0
		Else
		   @li,094 PSAY E5_PREFIXO+IIF(EMPTY(E5_PREFIXO)," ","-")+E5_NUMERO+;
		       					 IIF(EMPTY(E5_PARCELA)," ","-")+E5_PARCELA 		
		Endif
		
		
		//������������������������������������������������������������������Ŀ
		//�VerIfica se foi utilizada taxa contratada para moeda > 1          �
		//��������������������������������������������������������������������
		nTxMoedBc 	:= 0 
	
		If SE5->(FieldPos('E5_TXMOEDA')) > 0 .And.  E5_TXMOEDA > 0
			nTxMoedBc := E5_TXMOEDA	
		ElseIf Empty(E5_MOEDA) .Or. (!Empty(E5_MOEDA).And. Val(E5_MOEDA)==1)
			nTxMoedBc :=E5_VALOR/E5_VLMOED2
		Else
			nTxMoedBc :=E5_VLMOED2/E5_VALOR
		Endif   
			
	    If cPaisloc<>"BRA" 
			If mv_par09 == 1
				nTxMoedBc := 0 //RecMoeda(dDatabase,nMoedaBco)
			Else
				nTxMoedBc := nTaxa
			Endif
		EndIf
	
   	nTxMoeda := If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(iif(MV_PAR09==1,dDataBase,E5_DTDISPO),mv_par06))		
			
		// Se realiza controle de saldos em multiplas moedas
		If ( lFxMultSld .AND. FXMultSld() )

			nValor   := Round(xMoeda( F470VlMoeda(cAlias),;
												nMoedaBco,;
												mv_par06,;
												IIF(MV_PAR09==1,dDataBase,E5_DTDISPO),;
												nMoeda,;
												IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAlias, nMoedaBco)),;
												IIF(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),E5_TXMOEDA) ),nMoeda)

		Else
		
			nValor   := Round(xMoeda(E5_VALOR,;
									Iif((cPaisLoc<>"BRA".And.(E5_TIPODOC $ MVRECANT+"|ES") .and. Empty(E5_MOEDA)),1, nMoedaBco ),;
									mv_par06,;
									iif(MV_PAR09==1,dDataBase,E5_DTDISPO),;
									nMoeda+1,;
									Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",	IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ) , TxMoeda("SE5", nMoedaBco) ),nTxMoedBc)),;
									Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda(E5_DTDISPO,mv_par06),nTxMoeda))),nMoeda)
		EndIf

	/*                                                                                                                                                             
		nValor   := Round(xMoeda(E5_VALOR,Iif((cPaisLoc<>"BRA".And.(E5_TIPODOC $ MVRECANT+"|ES") .and. Empty(E5_MOEDA)),1,nMoedaBco),mv_par06,E5_DTDISPO,nMoeda+1,;
					if(cPaisLoc=="BRA",1,nTxMoedBc),if(cPaisLoc=="BRA",mv_par06,nTxMoedBc)),nMoeda)
	*/
		IF E5_RECPAG="R"
			@li,118 + Iif(cPaisLoc <> "BRA",2,0) PSAY  nValor	Picture tm(nValor,15,nMoeda) //ENTRADAS
			nSaldoAtu += nValor
			If Empty( E5_RECONC )
				aRecon[1][REC_NAO_CONCILIADO] += nValor
			Else
				aRecon[1][REC_CONCILIADO] += nValor
			EndIf
			If lSpbInUse
				//Adiantamentos sao sempre STR
				If E5_TIPO $ MVRECANT
						nSalSTR += nValor
				Else
					// Saldo STR ou transformados em STR
	  				If E5_MODSPB $ " 1" .or. (E5_MODSPB $ "2/3" .AND. Empty(E5_BLOQ))
						nSalSTR += nValor
	  				ElseIf E5_MODSPB == "2" //CIP
						nSalCIP += nValor
	  				ElseIf E5_MODSPB == "3" //COMP
						nSalCOMP += nValor
				   Endif
				Endif
			Endif	
		Else
			@li,137  + Iif(cPaisLoc <> "BRA",3,0) PSAY nValor  Picture tm(nValor,15,nMoeda) 
			nSaldoAtu -= nValor
			If Empty( E5_RECONC )
				aRecon[1][PAG_NAO_CONCILIADO] += nValor
			Else
				aRecon[1][PAG_CONCILIADO] += nValor
			EndIf
			If lSpbInUse
				//Adiantamentos sao sempre STR
				If E5_TIPO $ MVPAGANT
					nSalSTR -= nValor
				Else
					// Saldo STR ou transformados em STR
	  				If E5_MODSPB $ " 1" .or. (E5_MODSPB $ "2/3" .AND. Empty(E5_BLOQ))
						nSalSTR -= nValor
	  				ElseIf E5_MODSPB == "2" //CIP
						nSalCIP -= nValor
	  				ElseIf E5_MODSPB == "3" //COMP
						nSalCOMP -= nValor
				   Endif
				Endif
			Endif	
		Endif
		@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu Picture tm(nSaldoAtu,16,nMoeda) 
		If cPaisLoc <> "BRA" .And. mv_par06 <> nMoedaBco .And. mv_par06 > 1  
			If nTaxa == 0
				nTaxa := IIf(!lMsmMoeda,	IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAlias, nMoedaBco) ) ,E5_TXMOEDA)
			EndIf
			//@li,165  + Iif(cPaisLoc <> "BRA",4,0) PSAY nTaxa Picture tm(nSaldoAtu,16,nMoeda) 
			@li,165  + Iif(cPaisLoc <> "BRA",4,0) PSAY If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(iif(MV_PAR09==1,dDataBase,E5_DTDISPO),mv_par06)) Picture tm(nSaldoAtu,16,nMoeda) 
			
		EndIf	
	   If lSpbInUse
			If (E5_MODSPB $ "2/3" .AND. !Empty(E5_BLOQ))
				@li,pCol() + 1 PSAY E5_BLOQ 
			Endif	
		Endif    
		
		@li,pCol()+1 pSay Iif(Empty(E5_RECONC), " ", "x")
		
		/*
		Imprimi as demais linhas do historico, se o tamanho do campo excedeu limite da coluna*/
		If !Empty(aHistor)
			For nI := 1 To Len(aHistor)
				li++
				If li > nLin
					cabec(@titulo,cabec1,cabec2,nomeprog,"G",nTipo)
					@ li, 00 PSAY cabec3
					@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
					li++
				EndIf
				@li,115 PSAY aHistor[nI]
			Next
		Endif
		
		If lSpbInUse	
			dbSelectArea("TRB")
		Else
			dbSelectArea(cAlias)
		Endif
		li+=1
		dbSkip()
	EndDo 

	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li++
	Endif
	
	li+=2
	@li,051 + Iif(cPaisLoc <> "BRA",4,0) PSAY OemToAnsi(STR0014)  //"SALDO INICIAL...........: "
	@li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoIni Picture tm(nSaldoIni,16,nMoeda)
	
	li+=2
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li++
	Endif
	@li,118  + Iif(cPaisLoc <> "BRA",2,0) PSAY OemToAnsi(STR0015)  //"NAO CONCILIADOS"
	@li,140  + Iif(cPaisLoc <> "BRA",3,0) PSAY OemToAnsi(STR0016)  //"    CONCILIADOS"
	@li,164  + Iif(cPaisLoc <> "BRA",4,0) PSAY OemToAnsi(STR0017)  //"          TOTAL"
	
	li++
	@li,051  + Iif(cPaisLoc <> "BRA",4,0) PSAY OemToAnsi(STR0018)  //"ENTRADAS NO PERIODO.....: "
	@li,118  + Iif(cPaisLoc <> "BRA",2,0) PSAY aRecon[1][REC_NAO_CONCILIADO] PicTure tm(aRecon[1][1],15,nMoeda)
	@li,136  + Iif(cPaisLoc <> "BRA",3,0) PSAY aRecon[1][REC_CONCILIADO] PicTure tm(aRecon[1][2],15,nMoeda)
	@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY aRecon[1][REC_CONCILIADO] + aRecon[1][REC_NAO_CONCILIADO] PicTure tm((aRecon[1][1]+aRecon[1][2]),16,nMoeda)
	
	li++
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li++
	Endif
	@li,051  + Iif(cPaisLoc <> "BRA",4,0) PSAY OemToAnsi(STR0019)  //"SAIDAS NO PERIODO ......: "
	@li,118  + Iif(cPaisLoc <> "BRA",2,0) PSAY aRecon[1][PAG_NAO_CONCILIADO] PicTure tm(aRecon[1][3],15,nMoeda)
	@li,136  + Iif(cPaisLoc <> "BRA",3,0) PSAY aRecon[1][PAG_CONCILIADO] PicTure tm(aRecon[1][4],15,nMoeda)
	@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY aRecon[1][PAG_CONCILIADO] + aRecon[1][PAG_NAO_CONCILIADO] PicTure tm((aRecon[1][3]+aRecon[1][4]),16,nMoeda)
	
	If lSpbInUse
	
		nSalStr += nSaldoAtu - (nSalStr+nSalCIP+nSalCOMP)
		li+=2
		If li > nLin - 5 .And. nLin > 55
			cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			@ li, 00 PSAY cabec3
			@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
			li++
		Endif
		@li,051  + Iif(cPaisLoc <> "BRA",4,0) PSAY STR0022 //"SALDO DISPONIVEL........: "
		@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY nSalSTR	Picture tm(nSalSTR,16,nMoeda)
		
		li++
		@li,051  + Iif(cPaisLoc <> "BRA",4,0) PSAY STR0023 //"SALDO BLOQUEADO CIP (2).: "
		@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY nSalCIP	Picture tm(nSalCIP,16,nMoeda)
		
		li++
		@li,051  + Iif(cPaisLoc <> "BRA",4,0) PSAY STR0024 //"SALDO BLOQUEADO COMP (3):"
		@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY nSalCOMP	Picture tm(nSalCOMP,16,nMoeda)
	Endif
	
	li++
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li++
	Endif
	@li,051  + Iif(cPaisLoc <> "BRA",4,0) PSAY OemToAnsi(STR0021)  //"LIMITE DE CREDITO ......: "
	@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY nLimCred Picture tm(nLimCred,16,nMoeda)
	
	li+=2
	nSaldoAtu += nLimCred
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li,153 + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li++
	Endif
	@li,051  + Iif(cPaisLoc <> "BRA",4,0) PSAY OemToAnsi(STR0020)  //"SALDO ATUAL ............: "
	@li,153  + Iif(cPaisLoc <> "BRA",4,0) PSAY nSaldoAtu	Picture tm(nSaldoAtu,16,nMoeda)	   
	
Else //Retrato	
	Tamanho := "M"
	While &(cCondWhile)

		If !Empty(E5_TXMOEDA) .And. ( lFxMultSld .AND. FXMultSld() )
			If E5_RECPAG == "P"
				lMsmMoeda := Posicione("SE2",1,xFilial("SE2")+(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E2_MOEDA") == mv_par06
			Else
				lMsmMoeda := Posicione("SE1",1,xFilial("SE1")+(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E1_MOEDA") == mv_par06
			EndIf
		EndIf
	
		IF lEnd
			@PROW()+1,0 PSAY OemToAnsi(STR0013)  //"Cancelado pelo operador"
			EXIT
		Endif
		
		#IFNDEF TOP
			IncRegua()
			If !Fr470Skip(cBanco,cAgencia,cConta)
				dbSkip()
				Loop
			EndIf	
			//��������������������������������������������������������������Ŀ
			//� Considera filtro do usuario                                  �
			//����������������������������������������������������������������
			If !Empty(cFilterUser).and.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
		#ELSE
			//��������������������������������������������������������������Ŀ
			//� Considera filtro do usuario                                  �
			//����������������������������������������������������������������
			If TcSrvType() == "AS/400"
				If !Fr470Skip(cBanco,cAgencia,cConta)
					dbSkip()
					Loop
				EndIf	
				If !Empty(cFilterUser).and.!(&cFilterUser)
					dbSkip()
					Loop
				Endif
			Else
				If !Empty(cFilterUser) .And. Empty( cFilQry ) 
					If !(&cFilterUser)
						dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf		
		#ENDIF		
	
		If E5_MOEDA == "CH" .and. (E5_TIPODOC $ "TR/TE" .And. !lCxLoja .And. IsCaixaLoja(E5_BANCO) )		// Sangria
			dbSkip()
			Loop
		Endif
	
		If !Empty( E5_MOTBX )
			If !MovBcoBx( E5_MOTBX )
				dbSkip( )
				Loop
			EndIf
		EndIf
	
		IF li > nLin
			cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			@ li, 00 PSAY cabec3
			@ li, 099 PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
			li+=2
		EndIF
		
		If lSpbInUse	
			dbSelectArea("TRB")
		Else
			dbSelectArea(cAlias)
		Endif
	    
		If cPaisLoc<>"BRA"
			nTaxa := TxMoeda(Iif(lSpbInUse,"TRB",cAlias),nMoedaBco)
		EndIf
	
		cDoc := E5_NUMCHEQ
		
		IF Empty( cDoc )
			cDoc := E5_DOCUMEN
		Endif
		
		IF Len(Alltrim(SUBSTR(E5_DOCUMEN,1,35))) + Len(Alltrim(E5_NUMCHEQ)) > 50
			cDoc := Alltrim(SUBSTR(E5_DOCUMEN,1,35)) +if(!empty(Alltrim(E5_DOCUMEN)),"-"," ") + Alltrim(E5_NUMCHEQ )
		Endif
		
		If Substr( cDoc ,1, 1 ) == "*"
			li++
			dbSkip( )
			Loop
		Endif
		
		@li,0 PSAY E5_DTDISPO 
                                                                   
		@li,9 PSAY IIF(AllTrim(cDoc) == ""," ",AllTrim(cDoc))	      
		
		cChSef := ""
		//Caso seja um registro gerado de uma baixa de cheque tipo "CH" deve-se procurar em outro arquivo.
		If E5_TIPODOC = "CH"
	     cChSef := (xFilial("SE5")+E5_NUMCHEQ+E5_BANCO+E5_AGENCIA+E5_CONTA)
	     aArea	:= GetArea()	     
	     dbSelectArea("SEF")
	     dbSetOrder(4)
		  SEF->(Dbseek(cChSef))
		  While !EOF() .and. (xFilial("SEF")+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChSef
		    If !Empty(EF_TIPO)
            @li,37 PSAY EF_PREFIXO+IIF(EMPTY(EF_PREFIXO)," ","-")+EF_TITULO+;
		       					 IIF(EMPTY(EF_PARCELA)," ","-")+EF_PARCELA 		
		    Endif
		    SEF->(Dbskip())
		  Enddo
		  	dbCloseArea()
         RestArea(aArea)
		Else
		   @li,37 PSAY E5_PREFIXO+IIF(EMPTY(E5_PREFIXO)," ","-")+E5_NUMERO+;
		  					   IIF(EMPTY(E5_PARCELA)," ","-")+E5_PARCELA  	
		Endif									
		
		//������������������������������������������������������������������Ŀ
		//�VerIfica se foi utilizada taxa contratada para moeda > 1          �
		//��������������������������������������������������������������������
		nTxMoedBc 	:= 0 
		
	
		If SE5->(FieldPos('E5_TXMOEDA')) > 0 .And.  E5_TXMOEDA > 0
			nTxMoedBc := E5_TXMOEDA	
		ElseIf Empty(E5_MOEDA) .Or. (!Empty(E5_MOEDA).And. Val(E5_MOEDA)==1)
			nTxMoedBc :=E5_VALOR/E5_VLMOED2
		Else
			nTxMoedBc :=E5_VLMOED2/E5_VALOR
		Endif   
			
	    If cPaisloc<>"BRA" 
			nTxMoedBc := 0
		EndIf	                                                                                                 
		
		nTxMoeda := If(nTxMoedBc > 1, nTxMoedBc, IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda("SE5", nMoedaBco) ))		
			
		// Se realiza controle de saldos em multiplas moedas
		If ( lFxMultSld .AND. FXMultSld() )
			nValor   := Round(xMoeda(F470VlMoeda(cAlias),;
										 nMoedaBco ,;
										 mv_par06,;
										 iif(MV_PAR09==1,dDataBase,E5_DTDISPO),;
										 nMoeda,;
										 IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda("SE5", nMoedaBco) ),;
										 IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),E5_TXMOEDA)),nMoeda)
		Else
			nValor   := Round(xMoeda(E5_VALOR,;
										Iif((cPaisLoc<>"BRA".And.(E5_TIPODOC $ MVRECANT+"|ES") .and. Empty(E5_MOEDA)),1, nMoedaBco ),;
										mv_par06,;
										iif(MV_PAR09==1,dDataBase,E5_DTDISPO),;
										nMoeda+1;
										,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda("SE5", nMoedaBco) ),nTxMoedBc));
										,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda(E5_DTDISPO,mv_par06),nTxMoedBc))),nMoeda)	
		EndIf
	
		If E5_RECPAG == "P"
			@li,82 PSAY nValor Picture tm(nValor,15,nMoeda) 
			nSaldoAtu -= nValor
			If Empty( E5_RECONC )
				aRecon[1][PAG_NAO_CONCILIADO] += nValor
			Else
				aRecon[1][PAG_CONCILIADO] += nValor
			EndIf
			If lSpbInUse
				//Adiantamentos sao sempre STR
				If E5_TIPO $ MVPAGANT
					nSalSTR -= nValor
				Else
					// Saldo STR ou transformados em STR
	  				If E5_MODSPB $ " 1" .or. (E5_MODSPB $ "2/3" .AND. Empty(E5_BLOQ))
						nSalSTR -= nValor
	  				ElseIf E5_MODSPB == "2" //CIP
						nSalCIP -= nValor
	  				ElseIf E5_MODSPB == "3" //COMP
						nSalCOMP -= nValor
				   Endif
				Endif
			Endif	
		Else
			@li,65 PSAY nValor Picture tm(nValor,15,nMoeda) 
			nSaldoAtu += nValor
			If Empty( E5_RECONC )
				aRecon[1][REC_NAO_CONCILIADO] += nValor
			Else
				aRecon[1][REC_CONCILIADO] += nValor
			EndIf
			If lSpbInUse
				//Adiantamentos sao sempre STR
				If E5_TIPO $ MVRECANT
						nSalSTR += nValor
				Else
					// Saldo STR ou transformados em STR
	  				If E5_MODSPB $ " 1" .or. (E5_MODSPB $ "2/3" .AND. Empty(E5_BLOQ))
						nSalSTR += nValor
	  				ElseIf E5_MODSPB == "2" //CIP
						nSalCIP += nValor
	  				ElseIf E5_MODSPB == "3" //COMP
						nSalCOMP += nValor
				   Endif
				Endif
			Endif	      
		EndIf

		@li++,99 PSAY nSaldoAtu Picture tm(nSaldoAtu,16,nMoeda) 
		@pRow(),pCol()+1 pSay Iif(Empty(E5_RECONC), " ", "x")

		///////////////////////////
		//    Quebra de Linha    //
		///////////////////////////  
					
		@li,5 PSAY E5_HISTOR
			
 	    If lSpbInUse
			If (E5_MODSPB $ "2/3" .AND. !Empty(E5_BLOQ))
				@li,pCol() + 1 PSAY E5_BLOQ 
			Endif	
		Endif
		
		If lSpbInUse	
			dbSelectArea("TRB")
		Else
			dbSelectArea(cAlias)
		Endif
		li+=1
		dbSkip()
	EndDo

	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li, 99 PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li+=2
	Endif
	
	li+=2
	@li,010 PSAY OemToAnsi(STR0014)  //"SALDO INICIAL...........: "
	@li,099 PSAY nSaldoIni Picture tm(nSaldoIni,16,nMoeda)
	
	li+=2
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li, 99 PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li+=2
	Endif
	@li,079 PSAY OemToAnsi(STR0015)  //"NAO CONCILIADOS"
	@li,101 PSAY OemToAnsi(STR0016)  //"    CONCILIADOS"
	@li,125 PSAY OemToAnsi(STR0017)  //"          TOTAL"
	
	li++
	@li,010  PSAY OemToAnsi(STR0018)  //"ENTRADAS NO PERIODO.....: "
	@li,079  PSAY aRecon[1][REC_NAO_CONCILIADO] PicTure tm(aRecon[1][1],15,nMoeda)
	@li,097  PSAY aRecon[1][REC_CONCILIADO] PicTure tm(aRecon[1][2],15,nMoeda)
	@li,114  PSAY aRecon[1][REC_CONCILIADO] + aRecon[1][REC_NAO_CONCILIADO] PicTure tm((aRecon[1][1]+aRecon[1][2]),16,nMoeda)
	
	li++
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li, 99 PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li+=2
	Endif
	@li,010  PSAY OemToAnsi(STR0019)  //"SAIDAS NO PERIODO ......: "
	@li,079  PSAY aRecon[1][PAG_NAO_CONCILIADO] PicTure tm(aRecon[1][3],15,nMoeda)
	@li,097  PSAY aRecon[1][PAG_CONCILIADO] PicTure tm(aRecon[1][4],15,nMoeda)
	@li,114  PSAY aRecon[1][PAG_CONCILIADO] + aRecon[1][PAG_NAO_CONCILIADO] PicTure tm((aRecon[1][3]+aRecon[1][4]),16,nMoeda)
	
	If lSpbInUse
	
		nSalStr += nSaldoAtu - (nSalStr+nSalCIP+nSalCOMP)
		li+=2
		If li > nLin - 5 .And. nLin > 55
			cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			@ li, 00 PSAY cabec3
			@ li, 99 PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
			li+=2
		Endif
		@li,010  PSAY STR0022 //"SALDO DISPONIVEL........: "
		@li,114  PSAY nSalSTR	Picture tm(nSalSTR,16,nMoeda)
		
		li++
		@li,010  PSAY STR0023 //"SALDO BLOQUEADO CIP (2).: "
		@li,114  PSAY nSalCIP	Picture tm(nSalCIP,16,nMoeda)
		
		li++
		@li,010  PSAY STR0024 //"SALDO BLOQUEADO COMP (3):"
		@li,114  PSAY nSalCOMP	Picture tm(nSalCOMP,16,nMoeda)
	Endif
	
	li++
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li, 99 PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li+=2
	Endif
	@li,010  PSAY OemToAnsi(STR0021)  //"LIMITE DE CREDITO ......: "
	@li,114  PSAY nLimCred Picture tm(nLimCred,16,nMoeda)
	
	li+=2
	nSaldoAtu += nLimCred
	If li > nLin - 5 .And. nLin > 55
		cabec(@titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li, 00 PSAY cabec3
		@ li, 99 PSAY nSaldoAtu   Picture tm(nSaldoAtu,16,nMoeda) 
		li+=2
	Endif
	@li,010  PSAY OemToAnsi(STR0020)  //"SALDO ATUAL ............: "
	@li,099  PSAY nSaldoAtu	Picture tm(nSaldoAtu,16,nMoeda)
EndIf

IF li != 80
	roda(cbcont,cbtxt,Tamanho)
EndIF

Set Device To Screen

#IFNDEF TOP
	dbSelectArea("SE5")
	RetIndex( "SE5" )
	If !Empty(cIndex)
		FErase (cIndex+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
   If TcSrvType() != "AS/400"
		dbSelectArea(cAlias)
		dbCloseArea()
		ChKFile(cAlias)
   	dbSelectArea("SE5")
		dbSetOrder(1)
	Else
		dbSelectArea("SE5")
		RetIndex( "SE5" )
		If !Empty(cIndex)
			FErase (cIndex+OrdBagExt())
		Endif
		dbSetOrder(1)
	Endif
#ENDIF

If lSpbInUse
	dbSelectArea("TRB")
	dbCloseArea()
	Ferase(cNomeArq+GetDBExtension())
	Ferase(cNomeArq+OrdBagExt())
Endif
If aReturn[5] = 1
	Set Printer To
	dbCommit()
	ourspool(wnrel)
Endif

MS_FLUSH()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fr470Skip � Autor � Pilar S. Albaladejo	  � Data � 13.10.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pula registros de acordo com as condicoes (AS 400/CDX/ADS)  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINR470.PRX																  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fr470Skip(cBanco,cAgencia,cConta)
Local lRet := .T.
Local cTabela14	:= ""   
// Carrega a tabela 14
cTabela14 := FR470Tab14() 

IF E5_TIPODOC $ "BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL"  //Valores de Baixas
	lRet := .F.
ElseIF !(Alltrim(E5_BANCO+E5_AGENCIA+E5_CONTA)==Alltrim(cBanco+cAgencia+cConta))
	lRet := .F.
ElseIF E5_SITUACA = "C"    //Cancelado
	lRet := .F.
ElseIF E5_VALOR = 0
	lRet := .F.
ElseIF E5_VENCTO > mv_par05 .or. E5_VENCTO > E5_DATA
	lRet := .F.
ElseIf SubStr(E5_NUMCHEQ,1,1)=="*" 
	lRet := .F.
ElseIf (mv_par07 == 2 .and. Empty(E5_RECONC)) .or. (mv_par07 == 3 .and. !Empty(E5_RECONC))
	lRet := .F.
ElseIf E5_MOEDA $ "C1/C2/C3/C4/C5/CH" .and. Empty(E5_NUMCHEQ) .and. !(E5_TIPODOC $ "TR#TE")
	lRet := .F.
ElseIf E5_TIPODOC $ "TR/TE" .and. (Substr(E5_NUMCHEQ,1,1)=="*" .or. Substr(E5_DOCUMEN,1,1) == "*" )
	lRet := .F.
ElseIf E5_TIPODOC $ "TR/TE" .and. Empty(E5_NUMERO) .and. !(E5_MOEDA $ cTabela14+IIf(cPaisLoc=="BRA","","/$ "))
	//��������������������������������������������������������������Ŀ
	//� Na transferencia somente considera nestes numerarios 		 �
	//� No Fina100 � tratado desta forma.                    		 �
	//� As transferencias TR de titulos p/ Desconto/Cau��o (FINA060) �
	//� n�o sofrem mesmo tratamento dos TR bancarias do FINA100      �
    //� Aclaracao : Foi incluido o tipo $ para os movimentos en di-- �
    //� nheiro em QUALQUER moeda, pois o R$ nao e representativo     �
    //� fora do BRASIL. Bruno 07/12/2000 Paraguai                    �
    //����������������������������������������������������������������
	lRet := .F.
Endif

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fr470Spb  � Autor � Mauricio Pequim Jro	  � Data � 23.03.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta arquivo de tranbalho para SPB                      )  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINR470.PRX																  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
/*
Static Function Fr470SPB(cChave, aStruct)

Local cCondTrb := iiF(lAllFil, ".T.",'E5_FILIAL == xFilial("SE5")')
Local nX

DbselectArea("SE5")
While !Eof() .and. &(cCondTrb)
	If (E5_DATA >= mv_par04 .and. E5_DATA <= MV_PAR05 .AND.E5_DTDISPO > MV_PAR05) .OR. (E5_DTDISPO <= MV_PAR05)
		RecLock( "TRB", .T. )
		For nX := 1 to Len( aStruct )   // At� o campo anterior a TRB->E5_BLOQ
			If SE5->(FieldName(nx))<>"E5_BLOQ"
				dbSelectArea("SE5")
				xConteudo := FieldGet( nX )
				dbSelectArea("TRB")
				FieldPut( TRB->(FieldPos(SE5->(FieldName(nx)))),	xConteudo )
			EndIf
		Next nX
		If (E5_DATA <= MV_PAR05 .AND.E5_DTDISPO > MV_PAR05 ) .or. ;
			(E5_DATA <= MV_PAR05 .AND.E5_MODSPB == "2" .and. E5_DTDISPO == MV_PAR05 .AND.;
			(dDataBase == E5_DTDISPO .and. ;
			((E5_RECPAG == "R" .and. E5_TIPODOC != "ES") .or. (E5_RECPAG == "P" .and. E5_TIPODOC == "ES"))) )
			TRB->E5_DTDISPO	:= TRB->E5_DATA
			TRB->E5_BLOQ		:= SE5->E5_MODSPB
		Endif	
		msUnlock()
   Endif                                                     
   DbselectArea("SE5")
   DBsKIP()
Enddo
dbselectArea("TRB")
dbGotop()
Return
*/             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1 �Autor  �Nilton Pereira      � Data �27.04.2004   ���
�������������������������������������������������������������������������͹��
���Desc.     �Insere novas perguntas ao sx1                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FINA040                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aArea := GetArea()

Aadd( aHelpPor, "Informe o numero de linhas que serao "    )
Aadd( aHelpPor, "impressas .     "    )

Aadd( aHelpSpa, "Informe el numero de lineas que se "    )
Aadd( aHelpSpa, "imprimiran.      "    )

Aadd( aHelpEng, "Enter the number of lines to be "    )
Aadd( aHelpEng, "printed .  "    )

PutSx1( "FIN470", "08","Linhas por Pagina  ?","Lineas por Pagina  ?","Lines per Page  ?","mv_ch8","N",2,0,0,"G","","","","",;
	"mv_par08"," ","","","55","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

//Incluso pergunta para considerar a taxa contratada ou taxa da data base	
Aadd( aHelpPor, "Selecione qual a taxa sera utilizada "    )
Aadd( aHelpPor, "para a conversao do valores .     "    )
Aadd( aHelpSpa, "Seleccione la tasa que se utilisara "    )
Aadd( aHelpSpa, "para la conversion de los valores . "    )
Aadd( aHelpEng, "Select the rate to be used in order "    )
Aadd( aHelpEng, "to convert values  .  "    )

PutSx1( "FIN470", "09","Converte valores pela  ?","Conv. valores por la","Convert values by ?","mv_ch9","N",2,0,0,"C","","","","",;
	"mv_par09","Data Base","Tasa dia","Daily Rate","","Data Movimento","Tasa Movimiento","Movement Rate","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	

If cPaisLoc == "COL"
	DbSelectArea("SX1")
	dbSetOrder(1)
	If SX1->( MsSeek( PadR("FIN470", Len(SX1->X1_GRUPO) ) + "06" ) )//Dbseek(cteste) 
		RecLock("SX1",.F.)
		Replace  X1_VALID With "VerifMoeda(mv_par06)"
		MsUnlock()
	EndIf 	
ENDIF
RestArea(aArea)
Return
                                                                               	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TxMoeda  �Autor  � Microsiga          � Data �  31/10/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Retorna taxa da moeda do movimento de transferencia caso   ���
���          � tenha sido informada. Caso contrario retorna a taxa do     ���
���          � cadastro de moedas (SM2)									  ���
�������������������������������������������������������������������������͹��
���Retorno   � EXPN1 - Taxa da moeda do movimento ou SM2.                 ���
�������������������������������������������������������������������������͹��
���Uso       � FINR470                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TxMoeda( cAliasSE5, nMoedaBco )

Local aArea	:= GetArea()     
Local nTaxa	:= 0                
Local cNum	:= (cAliasSE5)->E5_NUMCHEQ

If !Empty(cNum)
	SE5->(dbSetOrder(10))
	SE5->(MsSeek(xFilial("SE5")+cNum))                                                     
	If MV_PAR09 == 1
	   nTaxa := RecMoeda(dDatabase,mv_par06)
	ElseIf (cAliasSE5)->(FieldPos("E5_TXMOEDA") > 0) .And. (cAliasSE5)->E5_TXMOEDA == 1 .And.;
	       (cAliasSE5)->(FieldPos("E5_MOEDA")   > 0) .And. Val((cAliasSE5)->E5_MOEDA) == 1
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06)		
	ElseIf (cAliasSE5)->(FieldPos("E5_TXMOEDA") > 0) .And. !Empty((cAliasSE5)->E5_TXMOEDA)
		nTaxa := (cAliasSE5)->E5_TXMOEDA  	
	Else
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06)		
	EndIf	
Else
	If MV_PAR09 == 1
	   nTaxa := RecMoeda(dDatabase,nMoedaBco)
	ElseIf (cAliasSE5)->( FieldPos("E5_TXMOEDA") > 0) .And. !Empty((cAliasSE5)->E5_TXMOEDA) .And. ( Val((cAliasSE5)->E5_MOEDA) == nMoedaBco .or. (cAliasSE5)->E5_TIPO $ MVPAGANT+MVRECANT ) // QUANDO � ADIANTAMENTO O CAMPO E5_MOEDA FICA EM BRANCO
		nTaxa := (cAliasSE5)->E5_TXMOEDA  	
	Elseif (cAliasSE5)->( FieldPos("E5_TXMOEDA") > 0) .And. !Empty((cAliasSE5)->E5_TXMOEDA) .And. ( nMoedaBco <> 1 .and. (cAliasSE5)->E5_TXMOEDA > 0)
		nTaxa := (cAliasSE5)->E5_TXMOEDA //Caso de moeda contratada. Ou seja, valor da taxa da moeda fornecido por exemplo em cta a receber ou movimento bancario a receber. 	
	Else
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,nMoedaBco)		
	EndIf	
EndIf	   	

RestArea( aArea )

Return( nTaxa )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FR470Alt  �Autor  �Pedro Pereira Lima  � Data �  22/04/10   ���
�������������������������������������������������������������������������͹ ��
���Desc.     �Ajusta o cabe�alho do relat�rio para emiss�o em modo RETRATO���
���          �com limite de 132 colunas                                   ���
�������������������������������������������������������������������������͹��
���Uso       � FINR470                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC Function FR470Alt(cConstCabec)

Local cCabFull := cConstCabec//"DATA|OPERACAO|DOCUMENTO|PREFIXO/TITULO|ENTRADAS|SAIDAS|SALDO ATUAL"
Local aCabecFull := {}

aAdd(aCabecFull,Substr(cCabFull,1,4) + Space(5) + Substr(cCabFull,44,9) + Space(46) + Substr(cCabFull,119,15) + Space(2) + Substr(cCabFull,140,15) + Space(8) + Substr(cCabFull,159,11))
aAdd(aCabecFull,Space(5) + Substr(cCabFull,13,8) + Space(24) + Substr(cCabFull,95,14))

Return aCabecFull



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINR470   �Autor  � Gustavo Henrique   � Data �  15/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega e retorna moedas da tabela 14                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FR470Tab14()

Local cTabela14 := ""

SX5->(DbSetOrder(1))
SX5->(MsSeek(xFilial("SX5")+"14"))
While SX5->(!Eof()) .And. SX5->X5_TABELA == "14"
	cTabela14 += (Alltrim(SX5->X5_CHAVE) + "/")
	SX5->(DbSkip())
End	
cTabela14 += If(cPaisLoc=="BRA","","/$ ")         
If cPaisLoc == "BRA"
	cTabela14 := SubStr( cTabela14, 1, Len(cTabela14) - 1 )
EndIf	         

Return cTabela14 
