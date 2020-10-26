#Include "FINR350.CH"
#Include "PROTHEUS.CH"
#Include "fwcommand.CH"

#Define I_CORRECAO_MONETARIA     1
#Define I_DESCONTO               2
#Define I_JUROS                  3
#Define I_MULTA                  4
#Define I_VALOR_RECEBIDO         5
#Define I_VALOR_PAGO             6
#Define I_RECEB_ANT              7
#Define I_PAGAM_ANT              8
#Define I_MOTBX                  9
#Define I_RECPAG_REAIS         	10
#Define I_LEI10925              12

Static lFWCodFil := FindFunction("FWCodFil")      

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FinR350  � Autor � Adrianne Furtado      � Data � 27/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posicao dos Fornecedores 					              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR530(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FinR350()

AjustaHLP()

If FindFunction("TRepInUse") .And. TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef()                         
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf
	oReport:PrintDialog()
Else
    Return U_FinR350R3() // Executa vers�o anterior do fonte
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Adrianne Furtado      � Data �27.06.2006���
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
Local oFornecedores
Local oTitsForn
//Local oCell

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
oReport := TReport():New("FINR350",STR0005,"FIN350", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002) //"Movimento Financeiro Diario"##"Este programa ir� emitir o resumo da Movimenta��o"##"Bancaria de um determinado dia."
oReport:SetTotalInLine(.F.)
oReport:SetLandScape()         

oFornecedores := TRSection():New(oReport,STR0016,{"SA2"},{OemToAnsi(STR0012),OemToAnsi(STR0013) })   //Por Codigo - Por Nome
TRCell():New(oFornecedores,"A2_COD" 	,"SA2",STR0009	)
TRCell():New(oFornecedores,"A2_NOME"	,"SA2",			)		//Substr(A1_NOME,1,40)
TRCell():New(oFornecedores,"A2_NREDUZ"	,"SA2",			)

oTitsForn := TRSection():New(oFornecedores,STR0017,{"SE2","SED"})	//"Titulos
//TRCell():New(oTitsForn,"E2_PREFIXO" 	,"SE2",STR0018,/*Picture*/,35 + SE2->(LEN(E2_PREFIXO)+LEN('-')+LEN(E2_NUM))/*Tamanho*/,/*lPixel*/,{|| E2_PREFIXO+'-'+E2_NUM }) //"Prf Numero"
TRCell():New(oTitsForn,"E2_PREFIXO" 	,"SE2",STR0018,/*Picture*/,17/*Tamanho*/,/*lPixel*/,{|| E2_PREFIXO+'-'+E2_NUM }) //"Prf Numero"
TRCell():New(oTitsForn,"E2_PARCELA"		,"SE2",STR0019 ,,	1) 		//"PC"
TRCell():New(oTitsForn,"E2_TIPO"    	,"SE2",STR0020 ,,	3) 		//"Tip"
TRCell():New(oTitsForn,STR0021      	, 	  ,STR0021	,,17) //"Valor Original"
TRCell():New(oTitsForn,STR0022  		,    ,STR0022   ,,10) //"Emissao"
TRCell():New(oTitsForn,"E2_VENCTO" 		,"SE2",STR0023	,,10) //"Vencimento"
TRCell():New(oTitsForn,STR0024			,	  ,STR0024	,,09)	//"Baixa"
TRCell():New(oTitsForn,STR0025    		,	  ,STR0025	,,13) //"Lei 10925"
TRCell():New(oTitsForn,STR0026    		,	  ,STR0026  ,,13) //"Descontos"
TRCell():New(oTitsForn,STR0027      	,	  ,STR0027  ,,13)	//"Abatimentos"
TRCell():New(oTitsForn,STR0028			,	  ,STR0028	,,13)	//"Juros"
TRCell():New(oTitsForn,STR0029			,	  ,STR0029 	,,13)	//"Multa"
TRCell():New(oTitsForn,STR0030      	,	  ,STR0030  ,,13) //"Corr. Monet"
TRCell():New(oTitsForn,STR0031     		,	  ,STR0031  ,,17)	//"Valor Pago"
TRCell():New(oTitsForn,STR0032        	,	  ,STR0032  ,,13)	//"Pagto.Antecip"
TRCell():New(oTitsForn,STR0033      	,	  ,STR0033  ,,17)	//"Saldo Atual"
TRCell():New(oTitsForn,STR0034 			,	  ,STR0034	,,) //"Motivo"

If cPaisLoc != "BRA"
	oTitsForn:Cell(STR0025):Hide()
	oTitsForn:Cell(STR0025):SetTitle("")	
EndIf

oTitsForn:Cell(STR0021):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0022):SetHeaderAlign("CENTER")
oTitsForn:Cell(STR0023):SetHeaderAlign("CENTER")
oTitsForn:Cell(STR0024):SetHeaderAlign("CENTER")
oTitsForn:Cell(STR0025):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0026):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0027):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0028):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0029):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0030):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0031):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0032):SetHeaderAlign("RIGHT")
oTitsForn:Cell(STR0033):SetHeaderAlign("RIGHT")

oTitsForn:Cell(STR0021):SetAlign("RIGHT")
oTitsForn:Cell(STR0022):SetAlign("CENTER")
oTitsForn:Cell(STR0023):SetAlign("CENTER")
oTitsForn:Cell(STR0024):SetAlign("CENTER")
oTitsForn:Cell(STR0025):SetAlign("RIGHT")
oTitsForn:Cell(STR0026):SetAlign("RIGHT")
oTitsForn:Cell(STR0027):SetAlign("RIGHT")
oTitsForn:Cell(STR0028):SetAlign("RIGHT")
oTitsForn:Cell(STR0029):SetAlign("RIGHT")
oTitsForn:Cell(STR0030):SetAlign("RIGHT")
oTitsForn:Cell(STR0031):SetAlign("RIGHT")
oTitsForn:Cell(STR0032):SetAlign("RIGHT")
oTitsForn:Cell(STR0033):SetAlign("RIGHT")

oTotaisForn := TRSection():New(oTitsForn,STR0038,{"SE2","SED"})	//"Total Fornecedor
//TRCell():New(oTotaisForn,"TXTTOTAL"		,    ,STR0010	,,35 + TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]) //
TRCell():New(oTotaisForn,"TXTTOTAL"		,    ,STR0010	,, 17) //
TRCell():New(oTotaisForn,"PC"      	, 	  ,"PC"	,,1) //"PC"
TRCell():New(oTotaisForn,"TIP"      	, 	  ,"TIP"	,,3) //"tip"
TRCell():New(oTotaisForn,STR0021      	, 	  ,STR0021	,,17) //"Valor Original"
TRCell():New(oTotaisForn,STR0022  		,     ,STR0022  ,,10) //"Emissao"
TRCell():New(oTotaisForn,STR0023    	,"SE2",STR0023	,,09) //"Vencimento"
TRCell():New(oTotaisForn,STR0024		,	  ,STR0024	,,09)	//"Baixa"
TRCell():New(oTotaisForn,STR0025    	,	  ,STR0025	,,13) //"Lei 10925"
TRCell():New(oTotaisForn,STR0026    	,	  ,STR0026  ,,13) //"Descontos"
TRCell():New(oTotaisForn,STR0027      	,	  ,STR0027  ,,13)	//"Abatimentos"
TRCell():New(oTotaisForn,STR0028		,	  ,STR0028	,,13)	//"Juros"
TRCell():New(oTotaisForn,STR0029		,	  ,STR0029 	,,13)	//"Multa"
TRCell():New(oTotaisForn,STR0030      	,	  ,STR0030  ,,13) //"Corr. Monet"
TRCell():New(oTotaisForn,STR0031     	,	  ,STR0031  ,,17)	//"Valor Pago"
TRCell():New(oTotaisForn,STR0032      	,	  ,STR0032  ,,13)	//"Pagto.Antecip"
TRCell():New(oTotaisForn,STR0033      	,	  ,STR0033  ,,17)	//"Saldo Atual"
TRCell():New(oTotaisForn,STR0034 		,	  ,STR0034	,,)     //"Motivo"      
oTotaisForn:SetHeaderSection(.F.)	//Nao imprime o cabe�alho da secao  

oTotaisForn:Cell(STR0022):Hide()
oTotaisForn:Cell(STR0023):Hide()
oTotaisForn:Cell(STR0024):Hide()

If cPaisLoc != "BRA"
	oTotaisForn:Cell(STR0025):Hide()
	oTotaisForn:Cell(STR0025):SetTitle("")
EndIf

oTotaisFilial := TRSection():New(oReport,STR0037)	//"Titulos
//TRCell():New(oTotaisFilial,"TXTTOTAL"	,    , STR0036	,,35 + TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]) //
TRCell():New(oTotaisFilial,"TXTTOTAL"	,    , STR0036	,, 17) //
TRCell():New(oTotaisFilial,"PC"      	, 	  ,"PC"	,,1) //"PC"
TRCell():New(oTotaisFilial,"TIP"      	, 	  ,"TIP"	,,3) //"tip"
TRCell():New(oTotaisFilial,STR0021    	, 	  ,STR0021	,,17) //"Valor Original"
TRCell():New(oTotaisFilial,STR0022  	,     ,STR0022  ,,10) //"Emissao"
TRCell():New(oTotaisFilial,STR0023     ,"SE2",STR0023	,,09) //"Vencimento"
TRCell():New(oTotaisFilial,STR0024		,	  ,STR0024	,,09)	//"Baixa"
TRCell():New(oTotaisFilial,STR0025    	,	  ,STR0025	,,13) //"Lei 10925"
TRCell():New(oTotaisFilial,STR0026    	,	  ,STR0026  ,,13) //"Descontos"
TRCell():New(oTotaisFilial,STR0027    	,	  ,STR0027  ,,13)	//"Abatimentos"
TRCell():New(oTotaisFilial,STR0028		,	  ,STR0028	,,13)	//"Juros"
TRCell():New(oTotaisFilial,STR0029		,	  ,STR0029 	,,13)	//"Multa"
TRCell():New(oTotaisFilial,STR0030    	,	  ,STR0030  ,,13) //"Corr. Monet"
TRCell():New(oTotaisFilial,STR0031    	,	  ,STR0031  ,,17)	//"Valor Pago"
TRCell():New(oTotaisFilial,STR0032    	,	  ,STR0032  ,,13)	//"Pagto.Antecip"
TRCell():New(oTotaisFilial,STR0033    	,	  ,STR0033  ,,17)	//"Saldo Atual"
TRCell():New(oTotaisFilial,STR0034 		,	  ,STR0034	,,)     //"Motivo"      
oTotaisFilial:SetHeaderSection(.F.)	//Nao imprime o cabe�alho da secao  

oTotaisFilial:Cell(STR0022):Hide()
oTotaisFilial:Cell(STR0023):Hide()
oTotaisFilial:Cell(STR0024):Hide()                                   

If cPaisLoc != "BRA"
	oTotaisFilial:Cell(STR0025):Hide()
	oTotaisFilial:Cell(STR0025):SetTitle("")
EndIf   

//Totalizador Geral
oTotalGeral := TRSection():New(oTitsForn,STR0038,{"SE2","SED"})	//"Total Geral
//TRCell():New(oTotalGeral,"TXTTOTAL"		,    ,STR0011	,,35 + TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]) //
TRCell():New(oTotalGeral,"TXTTOTAL"		,    ,STR0011	,, 17) //
TRCell():New(oTotalGeral,"PC"      	, 	  ,"PC"	,,1) //"PC"
TRCell():New(oTotalGeral,"TIP"      	, 	  ,"TIP"	,,3) //"PC"
TRCell():New(oTotalGeral,STR0021      	, 	  ,STR0021	,,) //"Valor Original"
TRCell():New(oTotalGeral,STR0022  		,     ,STR0022  ,,) //"Emissao"
TRCell():New(oTotalGeral,STR0023    	,"SE2",STR0023	,,09) //"Vencimento"
TRCell():New(oTotalGeral,STR0024		,	  ,STR0024	,,09)	//"Baixa"
TRCell():New(oTotalGeral,STR0025    	,	  ,STR0025	,,13) //"Lei 10925"
TRCell():New(oTotalGeral,STR0026    	,	  ,STR0026  ,,13) //"Descontos"
TRCell():New(oTotalGeral,STR0027      	,	  ,STR0027  ,,13)	//"Abatimentos"
TRCell():New(oTotalGeral,STR0028		,	  ,STR0028	,,13)	//"Juros"
TRCell():New(oTotalGeral,STR0029		,	  ,STR0029 	,,13)	//"Multa"
TRCell():New(oTotalGeral,STR0030      	,	  ,STR0030  ,,13) //"Corr. Monet"
TRCell():New(oTotalGeral,STR0031     	,	  ,STR0031  ,,17)	//"Valor Pago"
TRCell():New(oTotalGeral,STR0032      	,	  ,STR0032  ,,13)	//"Pagto.Antecip"
TRCell():New(oTotalGeral,STR0033      	,	  ,STR0033  ,,17)	//"Saldo Atual"
TRCell():New(oTotalGeral,STR0034 		,	  ,STR0034	,,)     //"Motivo"      
oTotalGeral:SetHeaderSection(.F.)	//Nao imprime o cabe�alho da secao  

oTotalGeral:Cell(STR0022):Hide()
oTotalGeral:Cell(STR0023):Hide()
oTotalGeral:Cell(STR0024):Hide()

If cPaisLoc != "BRA"
	oTotalGeral:Cell(STR0025):Hide()
	oTotalGeral:Cell(STR0025):SetTitle("")
EndIf

If TCSrvType() <> "AS/400"
	#IFNDEF TOP
		TRPosition():New ( oTitsForn, "SA2" , 1 ,{|| xfilial("SA2")+SE2->(E2_FORNECE+E2_LOJA) } , .T. ) 
		TRPosition():New ( oTitsForn, "SED" , 1 ,{|| xfilial("SED")+SE2->(E2_NATUREZ) } , .T. ) 
	#ENDIF
Endif

oFornecedores:SetColSpace(0)
oTitsForn:SetColSpace(0)
oTotaisForn:SetColSpace(0)
oTotaisFilial:SetColSpace(0)

Return(oReport)       

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
Local oFornecedores	:= oReport:Section(1)
Local oTitsForn		:= oReport:Section(1):Section(1)
Local oTotaisForn	:= oReport:Section(1):Section(1):Section(1)
Local oTotalGeral	:= oReport:Section(1):Section(1):Section(1)
Local oTotaisFilial	:= oReport:Section(2)
Local cAlias
Local cAliasSE2		:= "SE2"       
Local cAliasSA2 	:= "SA2"
Local cFornecedor               
Local cSql1, cSql2	:= ""
Local nDecs, nMoeda            
Local aValor 		:= {}        
Local nTotAbat              
Local bPosTit		:= { || }		// Posiciona a impressao dos titulos do fornecedor
//Local bWhile		:= { || }		// Condicao para impressao dos titulos do fornecedor
#IFNDEF TOP
Local cCondicao  := ""   
Local cCondicao2 := ""
#ENDIF                       
//Local cFiltSED		:=	oFornecedores:GetAdvplExp('SED')
//Local cFiltSE2		:=	oFornecedores:GetAdvplExp('SE2')
//Local cFiltSA2		:=	oFornecedores:GetAdvplExp('SA2')
Local lInitForn	:=	.T.
Local	lPrintForn	:=	.T.
Local cFilDe,cFilAte, cFilDeSA2,cFilAteSA2        
Local cFiliAnt:= cFiliAtu := ""  
Local cFornAnt:= cFornAtu := ""
Local nTotFil0:= nTotForn0:= nTotGeral0:=0
Local nTotFil1:= nTotForn1:= nTotGeral1:=0
Local nTotFil2:= nTotForn2:= nTotGeral2:=0
Local nTotFil3:= nTotForn3:= nTotGeral3:=0
Local nTotFil4:= nTotForn4:= nTotGeral4:=0
Local nTotFil5:= nTotForn5:= nTotGeral5:=0
Local nTotFil6:= nTotForn6:= nTotGeral6:=0
Local nTotFil7:= nTotForn7:= nTotGeral7:=0
Local nTotFil8:= nTotForn8:= nTotGeral8:=0
Local nTotFil9:= nTotForn9:= nTotGeral9:=0      
Local lProcSQL := .T.
Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"
Local nValorOrig := 0       
Local lPaBruto	:= GetNewPar("MV_PABRUTO","2") == "1"  //Indica se o PA ter� o valor dos impostos descontados do seu valor
Local lImpTit	:= .T.		// Indica se imprime o titulo a pagar (SE2)  
Local nInc		:= 0
Local aSM0		:= {}

//******************************************
// Utilizados pelo ponto de entrada F350MFIL
//******************************************
Local lMovFil	:= .T. //Default: Imprime todas as filiais
Local lImpMFil 	:= .T.     
Local nReg
//******************************************

Private nRegSM0		:= SM0->(Recno())
Private nAtuSM0 	:= SM0->(Recno())
                     
Pergunte( "FIN350", .F. )

aSM0	:= AdmAbreSM0()
nDecs 	:= Msdecimais(mv_par10)  
nMoeda 	:= mv_par10

oReport:SetMeter(LastRec())            

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If mv_par19 == 2
	cFilDe  := xFilial("SE2")
	If !Empty( xFilial("SE2") )
		cFilAte := xFilial("SE2")
	Else
		cFilAte := Replicate( "Z", TamSX3("E2_FILIAL")[1] )
	EndIf
Else
	If Empty(xFilial("SE2"))	
		cFilDe	:= ""
		cFilAte	:= Replicate( "Z", TamSX3("E2_FILIAL")[1] )
	Else
		cFilDe 	:= mv_par20	// Todas as filiais
		cFilAte	:= mv_par21                    
	Endif	
Endif

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If mv_par19 == 2 .or. xFilial("SA2") == ""
	cFilDeSA2  := xFilial("SA2")
	cFilAteSA2 := xFilial("SA2")
Else
	cFilDeSA2 := mv_par20	// Todas as filiais
	cFilAteSA2:= mv_par21                    
Endif

oFornecedores:Init()         
oTitsForn:Init()           

If ExistBlock("F350MFIL")
	lMovFil := ExecBlock("F350MFIL",.F.,.F.)			              
Endif
              
oFornecedores:SetTotalText("")
oFornecedores:SetHeaderSection(.F.)	
oFornecedores:SetTotalInLine(.T.)
oTitsForn:SetTotalInLine(.T.)
oTitsForn:SetHeaderPage(.T.)
For nInc := 1 To Len( aSM0 )
	If !Empty(cFilAte) .AND. aSM0[nInc][1] == cEmpAnt .AND. (aSM0[nInc][2] >= cFilDe .and. aSM0[nInc][2] <= cFilAte)
		cFilAnt := aSM0[nInc][2]

		nReg := 0 //Zera a contagem de registros impressos.
		//������������������������������������������������������������������������Ŀ
		//�Filtragem do relat�rio                                                  �
		//��������������������������������������������������������������������������
		#IFDEF TOP         
	
			If lProcSQL
				lProcSQL := .F.
				cAlias := GetNextAlias() 
			EndIf
	
			bPosTit 	:= { || cFornecedor := (cAliasSA2)->( A2_COD + A2_LOJA ) } 
			bCondTit	:= { || (cAliasSE2)->( E2_FORNECE + E2_LOJA ) == cFornecedor }
	
			If mv_par19 == 1 .and. !Empty(xFilial("SA2"))
				cSql0 := "A2_FILIAL = '"+ aSM0[nInc][2] +"' AND "  	
			Else
				cSql0 := "A2_FILIAL = '"+xFilial("SA2")+"' AND "  	
			Endif
			If mv_par19 == 1 .and. !Empty(xFilial("SE2"))
				cSql0 += "E2_FILIAL = '"+ aSM0[nInc][2] + "' AND"
			Else
				cSql0 += "E2_FILIAL = '"+xFilial("SE2")+"' AND"
			Endif 
			cSql0 := "%"+cSql0+"%"   		
					
			cSql1 := If(mv_par18 == 1,"E2_EMISSAO","E2_EMIS1") + " between '" + DTOS(mv_par05)+ "' AND '" + DTOS(mv_par06) + "' AND E2_TIPO NOT IN "+FormatIn(MVABATIM,"|")+" AND "
			cSql1 := "%"+cSql1+"%"  
			
			cSql2 := If(mv_par18 == 1,"E2_EMISSAO","E2_EMIS1") + "<= '"+DTOS(dDataBase)+"' AND "
			If mv_par09 == 2
				cSql2 += "E2_TIPO <> '"+MVPROVIS+"' AND "  
			EndIf
			If mv_par16 == 2
				cSql2 += "E2_TIPO <> 'PA ' AND "  
			EndIf
			If mv_par12 == 2
				If cpaisLOC =="BRA"
				  	cSql2 += "E2_FATURA IN('"+Space(Len(SE2->E2_FATURA))+"','NOTFAT') AND "
				Else  	         
			  	  	cSql2 += "E2_ORIGEM <>'FINA085A' AND "         
			  	EndIf  	
			Endif
		If mv_par13 == 2 
			cSQL2 += " E2_MOEDA = " + STR(mv_par10) +" AND "
		Endif
			cSql2 := "%"+cSql2+"%"   
			If oFornecedores:GetOrder() == 1
				cOrder := "A2_FILIAL,E2_FILIAL,A2_COD,A2_NOME,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"
				SA2->( dbSetOrder( 1 ) )
			Else
				cOrder := "A2_FILIAL,E2_FILIAL,A2_NOME,A2_COD,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"
				SA2->( dbSetOrder( 2 ) )
			EndIf
			cOrder := "%"+cOrder+"%"
		
			//������������������������������������������������������������������������Ŀ
			//�Transforma parametros Range em expressao SQL                            �	
			//��������������������������������������������������������������������������
			MakeSqlExpr(oReport:uParam)
	
			//������������������������Ŀ
			//�Query do relat�rio      �
			//��������������������������
			oFornecedores:BeginQuery()	
		
			BeginSql Alias cAlias
			SELECT  A2_FILIAL,A2_COD,A2_NOME,A2_NREDUZ,A2_LOJA,SE2.*
			FROM %table:SA2% SA2,%table:SE2% SE2   
				LEFT OUTER JOIN %table:SED% SED 
				ON	(	ED_FILIAL 	= 	%xFilial:SED% AND                                  
						ED_CODIGO 	=	E2_NATUREZ AND
						SED.%NotDel% )
			WHERE %exp:cSql0%		
				E2_FORNECE 	= A2_COD 		AND 
				E2_LOJA 	= A2_LOJA		AND
				E2_FORNECE 	between %Exp:mv_par01% AND %Exp:mv_par02% AND    
				E2_LOJA 	between %Exp:mv_par03% AND %Exp:mv_par04% AND    
				%exp:cSql1%		
				E2_VENCREA 	between %Exp:DTOS(mv_par07)% AND %Exp:DTOS(mv_par08)% AND    		
				%exp:cSql2%		
				SE2.%notDel% AND
				SA2.%notDel%		
	
			ORDER BY %exp:cOrder%
	
			EndSql 
			//������������������������������������������������������������������������Ŀ
			//�Metodo EndQuery ( Classe TRSection )                                    �
			//�Prepara o relat�rio para executar o Embedded SQL.                       �
			//�ExpA1 : Array com os parametros do tipo Range                           �
			//��������������������������������������������������������������������������
			oFornecedores:EndQuery(/*Array com os parametros do tipo Range*/)
	    	
			oTitsForn:SetParentQuery()
			oTitsForn:SetParentFilter({|cParam| (cAlias)->(E2_FORNECE+E2_LOJA) == cParam}, { || (cAlias)->(A2_COD+A2_LOJA) })
	
			cAliasSE2	:= cAlias
			cAliasSA2 	:= cAlias
		
			(cAlias)->( dbGoTop() )
			
		#ELSE
	
			If mv_par19 == 1 .and. !Empty(xFilial("SE2"))
				bPosTit 	:= { || (cAliasSE2)->( MsSeek( aSM0[nInc][2] + (cAliasSA2)->( A2_COD + A2_LOJA ) ) ) } 
			Else
				bPosTit 	:= { || (cAliasSE2)->( MsSeek( xFilial((cAliasSE2)) + (cAliasSA2)->( A2_COD + A2_LOJA ) ) ) } 
			Endif
	
			bCondTit	:= { || (cAliasSE2)->( E2_FORNECE + E2_LOJA ) == (cAliasSA2)->( A2_COD + A2_LOJA ) }
	    	
			//������������������������������������������������������������������������Ŀ
			//�Transforma parametros Range em expressao Advpl                          �
			//��������������������������������������������������������������������������
	
			DbSelectArea("SA2")
			DbSetOrder(1)
	
			MakeAdvplExpr(oReport:uParam)
			If mv_par19 == 1 .and. !Empty(xFilial("SA2"))
				cCondicao := 'SA2->A2_FILIAL == "'+ aSM0[nInc][2] +'" .And. '
			Else
				cCondicao := 'SA2->A2_FILIAL == "'+xFilial("SA2")+'" .And. '  	
			Endif
			cCondicao += 'SA2->A2_COD  >= "' + mv_par01 + '" .And. SA2->A2_COD  <= "' + mv_par02 + '" .And. '
			cCondicao += 'SA2->A2_LOJA >= "' + mv_par03 + '" .And. SA2->A2_LOJA <= "' + mv_par04+'"' 
			oFornecedores:SetFilter( cCondicao, Indexkey() )                     
	
			DbSelectArea("SE2")
			DbSetOrder(6)          
			If mv_par19 == 1 .and. !Empty(xFilial("SE2"))
				cCondicao := 'SE2->E2_FILIAL == "'+ aSM0[nInc][2] + '"'
			Else
				cCondicao := 'SE2->E2_FILIAL == "'+xFilial("SE2")+'"'
			Endif
			oTitsForn:SetFilter( cCondicao, Indexkey() )	
			
			oTitsForn:SetRelation( {|| xFilial((cAliasSE2))+(cAliasSA2)->(A2_COD+A2_LOJA)},cAliasSE2,6,.T.)
			oTitsForn:SetParentFilter( {|cParam| (cAliasSE2)->(E2_FORNECE+E2_LOJA) == cParam}, { || (cAliasSA2)->(A2_COD+A2_LOJA) } )
	    	                           
			oFornecedores:NoUserFilter()
		#ENDIF		
	
		//������������������������������������������������������������������������Ŀ
		//�Inicio da impressao do fluxo do relat�rio                               �
		//��������������������������������������������������������������������������
		oReport:SetTitle(STR0005 + " - " + GetMv("MV_MOEDA"+Str(nMoeda,1)))
	
		oReport:SetMeter((cAliasSE2)->(LastRec()))
	
		If mv_par15 == 1
			oFornecedores:Cell("A2_NREDUZ"):Disable()
		Else
			oFornecedores:Cell("A2_NOME"):Disable()
		EndIf
	
	
		//�����������������������������������������������������Ŀ
		//�Posicionamento do SE5 neste ponto que servira para   �
		//�pesquisa de descarte de registros geradores de       �
		//�desdobramento                                        �
		//�������������������������������������������������������
		dbSelectArea("SE5")
		SE5->(dbSetOrder(7))
		dbSelectArea("SE2")
		
		While !oReport:Cancel() .And. (cAliasSA2)->(!Eof())  
	    
			oReport:IncMeter()
	
			If oReport:Cancel()
				Exit
			EndIf	
		
			lFirst := .T.
	
			Eval( bPosTit )
		
			While !oReport:Cancel() .And. !(cAliasSE2)->(Eof()) .And. Eval( bCondTit )
	 	
				If oReport:Cancel()
					Exit
				EndIf
	
				//�����������������������������������������������������Ŀ
				//�Pesquisa de descarte de registros geradores de       �
				//�desdobramento                                        �
				//�������������������������������������������������������
				If SE5->(dbSeek(xFilial("SE5") + (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
					If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) == "DSD"
						(cAliasSE2)->(dbSkip())
						Loop
					Endif
				Endif					
	
				#IFNDEF TOP
					//��������������������������������������������������������������Ŀ
					//� Verifica condicoes dos parametros para o titulo posicionado  �
					//����������������������������������������������������������������
					lImpTit := Fr350Skip(cAlias)
	
					//��������������������������������������������������������������Ŀ
					//� Considera filtro do usuario - SE2                            �
					//����������������������������������������������������������������
					lImpTit := lImpTit .And. (Empty(cFiltSE2) .Or. (cAliasSE2)->(&(cFiltSE2)))	
	
					//��������������������������������������������������������������Ŀ
					//� Considera filtro do usuario - SED                            �
					//����������������������������������������������������������������
					If !Empty(cFiltSED)                       
						SED->(DbSetOrder(1))
						SED->(MsSeek(xFilial()+(cAliasSE2)->E2_NATUREZ)) 
						lImpTit := lImpTit .And. SED->(&(cFiltSED))
					Endif		
	
					//��������������������������������������������������������������Ŀ
					//� Considera filtro do usuario - SA2                            �
					//����������������������������������������������������������������
					If !Empty(cFiltSA2)                       
						SA2->(DbSetOrder(1))
						SA2->(MsSeek(xFilial()+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA)) 
						lImpTit := lImpTit .And. SA2->(&(cFiltSA2))
					Endif		
				#ELSE	
					//���������������������������������������������������������������������������������������������������Ŀ
					//� O alias SE2 eh utilizado nas funcoes Baixa() e SaldoTit() abaixo, por isso deve estar posicionado �
					//�����������������������������������������������������������������������������������������������������
					SE2->( dbSetOrder(1) )
					If mv_par19 == 1 .and. !Empty(xFilial("SE2"))
						lImpTit := SE2->( MsSeek( aSM0[nInc][2] +(cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA ) ) )
					Else
						lImpTit := SE2->( MsSeek( xFilial("SE2")+(cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA ) ) )
					EndIf	
				#ENDIF
	            
				//���������������������������������������������������������������������������Ŀ
				//� Imprime o titulo a pagar do fornecedor se passou nas condicoes de filtros �
				//�����������������������������������������������������������������������������
				If lImpTit 
				
					aValor :=Baixas((cAliasSE2)->E2_NATUREZA,(cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,;
					nMoeda,"P",(cAliasSE2)->E2_FORNECE,dDataBase,(cAliasSE2)->E2_LOJA)
						
				If mv_par14 == 1
					nSaldo :=SaldoTit((cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,;
									   (cAliasSE2)->E2_NATUREZA,"P",(cAliasSE2)->E2_FORNECE,nMoeda,;
							If(mv_par11==1,dDataBase,(cAliasSE2)->E2_VENCREA),,(cAliasSE2)->E2_LOJA,,If(mv_par17 == 1 ,(cAliasSE2)->E2_TXMOEDA,0))

				Else       	
					nSaldo := xMoeda(((cAliasSE2)->E2_SALDO+(cAliasSE2)->E2_SDACRES-(cAliasSE2)->E2_SDDECRE),(cAliasSE2)->E2_MOEDA,mv_par10,;
					If(mv_par17 == 1,If(mv_par18 == 1,(cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1),dDataBase),,If(mv_par17 == 1 .and. (cAliasSE2)->E2_TXMOEDA>0,(cAliasSE2)->E2_TXMOEDA, ))
				Endif  
	    	
				aValor[I_DESCONTO]+= (cAliasSE2)->E2_SDDECRE    
				aValor[I_JUROS]   += (cAliasSE2)->E2_SDACRES

				nTotAbat:=SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,mv_par10,"V",,SE2->E2_LOJA,If(mv_par18==1,"1","2"),mv_par05,mv_par06,;
								If(mv_par17 == 1,If(mv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1),dDataBase),If(mv_par17 == 1 .and. SE2->E2_TXMOEDA>0,SE2->E2_TXMOEDA,))  


				If !((cAliasSE2)->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. !( MV_PAR14 == 2 .And. nSaldo == 0 ) // nao deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
					nSaldo -= nTotAbat
				EndIf
				//��������������������������������������������������������������Ŀ
				//� Se foi gerada fatura, colocar Motbx == Faturado				  �
				//����������������������������������������������������������������
				If !Empty((cAliasSE2)->E2_DTFATUR) .and. (cAliasSE2)->E2_DTFATUR <= dDataBase
					aValor[I_MOTBX] := STR0015  //"Faturado"
					aValor[I_VALOR_PAGO] -= nTotAbat
				Endif
	    	
				If cPaisLoc == "BRA" .And. !lPaBruto  .And. alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG
					nValorOrig:=(cAliasSE2)->E2_VALOR+(cAliasSE2)->E2_COFINS+(cAliasSE2)->E2_PIS+(cAliasSE2)->E2_CSLL
				Else 
					nValorOrig:=(cAliasSE2)->E2_VALOR    	
				EndIf
				
				oTitsForn:Cell(STR0022	):SetBlock({|| If(mv_par18==1, (cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1)}) //"Emissao"
				oTitsForn:Cell(STR0021 	):SetBlock({||xMoeda(nValorOrig,(cAliasSE2)->E2_MOEDA,nMoeda,If(mv_par17 == 1,If(mv_par18 == 1,(cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1),dDataBase),,If(mv_par17 == 1 .and. (cAliasSE2)->E2_TXMOEDA>0,(cAliasSE2)->E2_TXMOEDA,))*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1)}) 


				oTitsForn:Cell(STR0024	):SetBlock({||IIf(dDataBase >= (cAliasSE2)->E2_BAIXA,IIF(!Empty((cAliasSE2)->E2_BAIXA),(cAliasSE2)->E2_BAIXA," "),"")})		          //"Baixa"	
				If cPaisLoc == "BRA"
					If lPCCBaixa
						// Calcula valor de PA com PCC
						If SE2->E2_TIPO $ MVPAGANT
							aValor[I_LEI10925] := (SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL)
							// Se nao for PA Bruto, abate valor de impostos do valor pago da PA, pois sera destacado na coluna "Lei 19925"
							If !lPaBruto
								aValor[I_VALOR_PAGO] -= aValor[I_LEI10925]
							EndIf
						EndIf	
						oTitsForn:Cell(STR0025	):SetBlock({||aValor[I_LEI10925]})  				//"Lei 10925"	
					Else
						aValor[I_LEI10925]:= (SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL)
						oTitsForn:Cell(STR0025	):SetBlock({||aValor[I_LEI10925]})  				//"Lei 10925"	
					Endif	
				EndIf			
				oTitsForn:Cell(STR0026	):SetBlock({||aValor[I_DESCONTO]})  				//"Descontos"	
				oTitsForn:Cell(STR0027	):SetBlock({||nTotAbat})  							//"Abatimentos"
				oTitsForn:Cell(STR0028	):SetBlock({||aValor[I_JUROS]})  					//"Juros"
				oTitsForn:Cell(STR0029	):SetBlock({||aValor[I_MULTA]})  					//"Multa"	
				oTitsForn:Cell(STR0030	):SetBlock({||aValor[I_CORRECAO_MONETARIA]})  		//"Corr. Monet"	
				oTitsForn:Cell(STR0031	):SetBlock({||aValor[I_VALOR_PAGO]})//SetBlock({||xMoeda(aValor[I_VALOR_PAGO],(cAliasSE2)->E2_MOEDA,nMoeda,If(mv_par18 == 1,(cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1),,If(mv_par17 == 1,(cAliasSE2)->E2_TXMOEDA,0))*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1) })
				oTitsForn:Cell(STR0032	):SetBlock({||aValor[I_PAGAM_ANT]})  				//"Pagto.Antecip"
				oTitsForn:Cell(STR0033	):SetBlock({||nSaldo*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1)})  //"Saldo Atual"
				oTitsForn:Cell(STR0034	):SetBlock({||aValor[I_MOTBX]})  					//"Motivo"		
	                                                     
				nTotForn0+=xMoeda(nValorOrig,(cAliasSE2)->E2_MOEDA,nMoeda,If(mv_par17 == 1,If(mv_par18 == 1,(cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1),dDataBase),,If(mv_par17 == 1 .and. (cAliasSE2)->E2_TXMOEDA>0,(cAliasSE2)->E2_TXMOEDA,))*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1) 
				nTotForn1+=aValor[I_LEI10925]
				nTotForn2+=aValor[I_DESCONTO]
				nTotForn3+=nTotAbat
				nTotForn4+=aValor[I_JUROS]
				nTotForn5+=aValor[I_MULTA]
				nTotForn6+=aValor[I_CORRECAO_MONETARIA]
				If ! ((cAliasSE2)->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG )										
					nTotForn7+=aValor[I_VALOR_PAGO]					
				Else					
					nTotForn7-=aValor[I_VALOR_PAGO]
					nTotForn8+=aValor[I_PAGAM_ANT]
				Endif											
				nTotForn9+=nSaldo*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1)
	
				nTotFil0+=xMoeda(nValorOrig,(cAliasSE2)->E2_MOEDA,nMoeda,If(mv_par17 == 1,If(mv_par18 == 1,(cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1),dDataBase),nDecs+1,If(mv_par17 == 1 .and. (cAliasSE2)->E2_TXMOEDA>0,(cAliasSE2)->E2_TXMOEDA,))*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1) 
				nTotFil1+=aValor[I_LEI10925]
				nTotFil2+=aValor[I_DESCONTO]
				nTotFil3+=nTotAbat
				nTotFil4+=aValor[I_JUROS]
				nTotFil5+=aValor[I_MULTA]
				nTotFil6+=aValor[I_CORRECAO_MONETARIA]
				nTotFil7+=xMoeda(aValor[I_VALOR_PAGO],(cAliasSE2)->E2_MOEDA,nMoeda,If(mv_par18 == 1,(cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1),,If(mv_par17 == 1,(cAliasSE2)->E2_TXMOEDA,0))*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1) 
				nTotFil8+=aValor[I_PAGAM_ANT]
				nTotFil9+=nSaldo*if(alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG,-1,1)
	            
	
				oTitsForn:Cell(STR0021	):SetPicture(Tm(nValorOrig,oTitsForn:Cell(STR0021	):nSize,nDecs))  	//"Valor original"
				oTitsForn:Cell(STR0025	):SetPicture(Tm(aValor[I_LEI10925],oTitsForn:Cell(STR0025	):nSize,nDecs))  	//"Lei 10925"
	   			oTitsForn:Cell(STR0026	):SetPicture(Tm(aValor[I_DESCONTO],oTitsForn:Cell(STR0026	):nSize,nDecs)) 	//"Descontos"    
	   			oTitsForn:Cell(STR0027	):SetPicture(Tm(nTotAbat,oTitsForn:Cell(STR0027	):nSize,nDecs))  	//"Abatimentos"  
	  			oTitsForn:Cell(STR0028	):SetPicture(Tm(aValor[I_JUROS],oTitsForn:Cell(STR0028	):nSize,nDecs)) 	//"Juros"   
				oTitsForn:Cell(STR0029	):SetPicture(Tm(aValor[I_MULTA],oTitsForn:Cell(STR0029	):nSize,nDecs)) 	//"Multa"   
				oTitsForn:Cell(STR0030	):SetPicture(Tm(aValor[I_CORRECAO_MONETARIA],oTitsForn:Cell(STR0030	):nSize,nDecs))  //"Corr. Monet"
				oTitsForn:Cell(STR0031 	):SetPicture(Tm(aValor[I_VALOR_PAGO],oTitsForn:Cell(STR0031	):nSize,nDecs))  //"Valor Pago"
				oTitsForn:Cell(STR0032	):SetPicture(Tm(aValor[I_PAGAM_ANT],oTitsForn:Cell(STR0032	):nSize,nDecs))  //"Pagto.Antecip"
				oTitsForn:Cell(STR0033	):SetPicture(PictParent(Tm(nSaldo,oTitsForn:Cell(STR0033	):nSize,nDecs))) 	//"SAldo atual"
				
				If lPrintForn
					oFornecedores:PrintLine()
					lPrintForn	:=	.F.
				Endif	
	    		oTitsForn:PrintLine()  
				oReport:IncMeter()		
				nReg++
				
				EndIf
				
				(cAliasSE2)->(dbSkip())     
				If !Eval( bCondTit )     
					oTotaisForn:Cell("TXTTOTAL"):SetBlock({||STR0010  }) //
					oTotaisForn:Cell(STR0021   ):SetBlock({||nTotForn0 }) 	//"Valor Original
					If cPaisLoc == "BRA"
						oTotaisForn:Cell(STR0025   ):SetBlock({||nTotForn1 })  	//"Lei 10925"
					EndIf
					oTotaisForn:Cell(STR0026   ):SetBlock({||nTotForn2 })  	//"Descontos"
					oTotaisForn:Cell(STR0027   ):SetBlock({||nTotForn3 })  	//"Abatimentos"
					oTotaisForn:Cell(STR0028   ):SetBlock({||nTotForn4 })  	//"Juros"
					oTotaisForn:Cell(STR0029   ):SetBlock({||nTotForn5 })  	//"Multa"	
					oTotaisForn:Cell(STR0030   ):SetBlock({||nTotForn6 })  	//"Corr. Monet"	
					oTotaisForn:Cell(STR0031   ):SetBlock({||nTotForn7 })  	//"Valor Pago"
					oTotaisForn:Cell(STR0032   ):SetBlock({||nTotForn8 })  	//"Pagto.Antecip"
					oTotaisForn:Cell(STR0033   ):SetBlock({||nTotForn9 })  	//"Saldo Atual"
	
					oTotaisForn:Cell(STR0021	):SetPicture(Tm(nTotForn0,oTitsForn:Cell(STR0021	):nSize,nDecs)) //"Valor original"
					oTotaisForn:Cell(STR0025	):SetPicture(Tm(nTotForn1,oTitsForn:Cell(STR0025	):nSize,nDecs)) //"Lei 10925"
					oTotaisForn:Cell(STR0026	):SetPicture(Tm(nTotForn2,oTitsForn:Cell(STR0026	):nSize,nDecs)) //"Descontos"    
					oTotaisForn:Cell(STR0027	):SetPicture(Tm(nTotForn3,oTitsForn:Cell(STR0027	):nSize,nDecs)) //"Abatimentos"  
					oTotaisForn:Cell(STR0028	):SetPicture(Tm(nTotForn4,oTitsForn:Cell(STR0028	):nSize,nDecs)) //"Juros"   
					oTotaisForn:Cell(STR0029	):SetPicture(Tm(nTotForn5,oTitsForn:Cell(STR0029	):nSize,nDecs)) //"Multa"   
					oTotaisForn:Cell(STR0030	):SetPicture(Tm(nTotForn6,oTitsForn:Cell(STR0030	):nSize,nDecs)) //"Corr. Monet"
					oTotaisForn:Cell(STR0031 	):SetPicture(Tm(nTotForn7,oTitsForn:Cell(STR0031	):nSize,nDecs)) //"Valor Pago
					oTotaisForn:Cell(STR0032	):SetPicture(Tm(nTotForn8,oTitsForn:Cell(STR0032	):nSize,nDecs)) //"Pagto.Antecip"
					oTotaisForn:Cell(STR0033	):SetPicture(PictParent(Tm(nTotForn9,oTitsForn:Cell(STR0033	):nSize,nDecs))) //"SAldo atual
	
					oTotaisForn:Init()
					oTotaisForn:PrintLine()
					oReport:ThinLine()
					oTotaisForn:Finish()
	
					nTotGeral0 += nTotForn0
					nTotGeral1 += nTotForn1
					nTotGeral2 += nTotForn2
					nTotGeral3 += nTotForn3
					nTotGeral4 += nTotForn4
					nTotGeral5 += nTotForn5
					nTotGeral6 += nTotForn6
					nTotGeral7 += nTotForn7
					nTotGeral8 += nTotForn8
					nTotGeral9 += nTotForn9
					
					nTotForn0:=	nTotForn1:=	nTotForn2:=	nTotForn3:=	nTotForn4:=	nTotForn5:=	nTotForn6:=	nTotForn7:=	nTotForn8:=	nTotForn9:=0

					lPrintForn	:=	.T.
				EndIf
			EndDo
	
			//imprime os totais por fornecedor
			#IFNDEF TOP
				(cAliasSA2)->(dbSkip())
			#ENDIF
		EndDo
		
		//Imprime ou n�o as filiais sem movimento - P.E. F350MFIL
		If !lMovFil
			lImpMFil := Iif(nReg != 0, .T., .F.)
		Endif
		
		If mv_par19 == 1 .and. Len( aSM0 ) > 1 .And. lImpMFil 
			oTotaisFilial:Cell("TXTTOTAL"):SetBlock({||AllTrim(STR0036) + " " + AllTrim( aSM0[nInc][2] ) + "-" + AllTrim(aSM0[nInc][7]) }) //
			oTotaisFilial:Cell(STR0021   ):SetBlock({||nTotFil0 }) 	//"Valor Original
			If cPaisLoc == "BRA"
				oTotaisFilial:Cell(STR0025   ):SetBlock({||nTotFil1 })  	//"Lei 10925"
			EndIf
			oTotaisFilial:Cell(STR0026   ):SetBlock({||nTotFil2 })  	//"Descontos"
			oTotaisFilial:Cell(STR0027   ):SetBlock({||nTotFil3 })  	//"Abatimentos"
			oTotaisFilial:Cell(STR0028   ):SetBlock({||nTotFil4 })  	//"Juros"
			oTotaisFilial:Cell(STR0029   ):SetBlock({||nTotFil5 })  	//"Multa"	
			oTotaisFilial:Cell(STR0030   ):SetBlock({||nTotFil6 })  	//"Corr. Monet"	
			oTotaisFilial:Cell(STR0031   ):SetBlock({||nTotFil7 })  	//"Valor Pago"
			oTotaisFilial:Cell(STR0032   ):SetBlock({||nTotFil8 })  	//"Pagto.Antecip"
			oTotaisFilial:Cell(STR0033   ):SetBlock({||nTotFil9 })  	//"Saldo Atual" 
			
			oTotaisFilial:Cell(STR0021	):SetPicture(Tm(nTotFil0,oTitsForn:Cell(STR0021	):nSize,nDecs)) //"Valor original"
			oTotaisFilial:Cell(STR0025	):SetPicture(Tm(nTotFil1,oTitsForn:Cell(STR0025	):nSize,nDecs)) //"Lei 10925"
			oTotaisFilial:Cell(STR0026	):SetPicture(Tm(nTotFil2,oTitsForn:Cell(STR0026	):nSize,nDecs)) //"Descontos"    
			oTotaisFilial:Cell(STR0027	):SetPicture(Tm(nTotFil3,oTitsForn:Cell(STR0027	):nSize,nDecs)) //"Abatimentos"  
			oTotaisFilial:Cell(STR0028	):SetPicture(Tm(nTotFil4,oTitsForn:Cell(STR0028	):nSize,nDecs)) //"Juros"   
			oTotaisFilial:Cell(STR0029	):SetPicture(Tm(nTotFil5,oTitsForn:Cell(STR0029	):nSize,nDecs)) //"Multa"   
			oTotaisFilial:Cell(STR0030	):SetPicture(Tm(nTotFil6,oTitsForn:Cell(STR0030	):nSize,nDecs)) //"Corr. Monet"
			oTotaisFilial:Cell(STR0031	):SetPicture(Tm(nTotFil7,oTitsForn:Cell(STR0031	):nSize,nDecs)) //"Valor Pago"
			oTotaisFilial:Cell(STR0032	):SetPicture(Tm(nTotFil8,oTitsForn:Cell(STR0032	):nSize,nDecs)) //"Pagto.Antecip"
			oTotaisFilial:Cell(STR0033	):SetPicture(PictParent(Tm(nTotFil9,oTitsForn:Cell(STR0033	):nSize,nDecs))) //"SAldo atual"
				
			oTotaisFilial:Init()      
			oTotaisFilial:PrintLine()      			
	  		oReport:ThinLine()			
			oTotaisFilial:Finish()    
			nTotFil0:= nTotFil1:= nTotFil2:= nTotFil3:= nTotFil4:= nTotFil5:= nTotFil6:= nTotFil7:= nTotFil8:= nTotFil9:=0		  			    			
		EndIf                     
		lInitForn := .T.
		If Empty(xFilial("SE2"))
			Exit
		Endif	
	EndIf
Next

//Imprime Total geral
oTotalGeral:Cell("TXTTOTAL"):SetBlock({||STR0011  }) //
oTotalGeral:Cell(STR0021   ):SetBlock({||nTotGeral0 }) 	//"Valor Original
If cPaisLoc == "BRA"
	oTotalGeral:Cell(STR0025   ):SetBlock({||nTotGeral1 })  	//"Lei 10925"
EndIf
oTotalGeral:Cell(STR0026   ):SetBlock({||nTotGeral2 })  	//"Descontos"
oTotalGeral:Cell(STR0027   ):SetBlock({||nTotGeral3 })  	//"Abatimentos"
oTotalGeral:Cell(STR0028   ):SetBlock({||nTotGeral4 })  	//"Juros"
oTotalGeral:Cell(STR0029   ):SetBlock({||nTotGeral5 })  	//"Multa"	
oTotalGeral:Cell(STR0030   ):SetBlock({||nTotGeral6 })  	//"Corr. Monet"	
oTotalGeral:Cell(STR0031   ):SetBlock({||nTotGeral7 })  	//"Valor Pago"
oTotalGeral:Cell(STR0032   ):SetBlock({||nTotGeral8 })  	//"Pagto.Antecip"
oTotalGeral:Cell(STR0033   ):SetBlock({||nTotGeral9 })  	//"Saldo Atual"

oTotalGeral:Cell(STR0021	):SetPicture(PictParent(Tm(nTotGeral0,oTitsForn:Cell(STR0021	):nSize,nDecs))) //"Valor original"
oTotalGeral:Cell(STR0025	):SetPicture(Tm(nTotGeral1,oTitsForn:Cell(STR0025	):nSize,nDecs)) //"Lei 10925"
oTotalGeral:Cell(STR0026	):SetPicture(Tm(nTotGeral2,oTitsForn:Cell(STR0026	):nSize,nDecs)) //"Descontos"    
oTotalGeral:Cell(STR0027	):SetPicture(Tm(nTotGeral3,oTitsForn:Cell(STR0027	):nSize,nDecs)) //"Abatimentos"  
oTotalGeral:Cell(STR0028	):SetPicture(Tm(nTotGeral4,oTitsForn:Cell(STR0028	):nSize,nDecs)) //"Juros"   
oTotalGeral:Cell(STR0029	):SetPicture(Tm(nTotGeral5,oTitsForn:Cell(STR0029	):nSize,nDecs)) //"Multa"   
oTotalGeral:Cell(STR0030	):SetPicture(Tm(nTotGeral6,oTitsForn:Cell(STR0030	):nSize,nDecs)) //"Corr. Monet"
oTotalGeral:Cell(STR0031 	):SetPicture(Tm(nTotGeral7,oTitsForn:Cell(STR0031	):nSize,nDecs)) //"Valor Pago"
oTotalGeral:Cell(STR0032	):SetPicture(Tm(nTotGeral8,oTitsForn:Cell(STR0032	):nSize,nDecs)) //"Pagto.Antecip"
oTotalGeral:Cell(STR0033	):SetPicture(PictParent(Tm(nTotGeral9,oTitsForn:Cell(STR0033	):nSize,nDecs))) //"SAldo atual"

oTotalGeral:Init()      
oTotalGeral:PrintLine()      			
oReport:ThinLine()			
oTotalGeral:Finish()    

oTitsForn:Finish() 		  						
oFornecedores:Finish()  

SM0->(dbGoTo(nRegSM0))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

Return NIL          

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR350  � Autor � Paulo Boschetti       � Data � 01.06.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posicao dos Fornecedores                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR350(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FinR350R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cDesc1 :=OemToAnsi(STR0001)  //"Este programa ir� emitir a posi��o dos fornecedores"
Local cDesc2 :=OemToAnsi(STR0002)  //"referente a data base do sistema."
Local cDesc3 :=""
Local cString:="SE2"
Local nMoeda

Private aLinha :={}
Private aReturn:={OemToAnsi(STR0003),1,OemToAnsi(STR0004),1,2,1,"",1}  //"Zebrado"###"Administracao"
Private cPerg  :="FIN350"
Private cabec1,cabec2,nLastKey:=0,titulo,wnrel,tamanho:="G"
Private nomeprog :="FINR350"
Private aOrd :={OemToAnsi(STR0012),OemToAnsi(STR0013) }  //"Por Codigo"###"Por Nome"

//��������������������������������������������������������������Ŀ
//� Definicao dos cabecalhos                                     �
//����������������������������������������������������������������

titulo:= OemToAnsi(STR0005)  //"Posicao dos Fornecedores "

cabec1:= OemToAnsi(STR0006)  //"Prf Numero       PC Tip Valor Original Emissao   Vencto   Baixa                          P  A  G  A  M  E  N  T  O  S                                                                                     "

If cPaisLoc == "BRA"
	cabec2:= OemToAnsi(STR0007)	//"                                                                           Lei 10925    Descontos   Abatimentos         Juros         Multa   Corr. Monet      Valor Pago  Pagto.Antecip.        Saldo Atual  Motivo"
Else
	cabec2:= OemToAnsi(STR0039)	//"                                                                                        Descontos   Abatimentos         Juros         Multa   Corr. Monet      Valor Pago  Pagto.Antecip.        Saldo Atual  Motivo"
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("FIN350",.F.)

//����������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                     �
//� mv_par01    // Do Fornecedor                     		 �
//� mv_par02    // Ate o Fornecedor                  		 �
//� mv_par03    // Da Loja                           		 �
//� mv_par04    // Ate a Loja                        		 �
//� mv_par05    // Da Emissao                        		 �
//� mv_par06    // Ate a Emissao                     		 �
//� mv_par07    // Do Vencimento                     		 �
//� mv_par08    // Ate o Vencimento                  		 �
//� mv_par09    // Imprime os t�tulos provis�rios    		 �
//� mv_par10    // Qual a moeda                      		 �
//� mv_par11    // Reajusta pela DataBase ou Vencto  		 �
//� mv_par12    // Considera Faturados               		 �
//� mv_par13    // Imprime Outras Moedas             		 �
//� mv_par14    // Considera Data Base               		 �
//� mv_par15    // Imprime Nome?(Raz.Social/N.Reduz.)		 �
//� mv_par16    // Imprime PA? Sim ou N�o            		 �
//� mv_par17    // Conv. val. pela Data de? Hoje ou Mov 	 �  
//| mv_par18	// Considera Data de Emissao:"Do Documento" ou "Do Sistema" 
//� mv_par19	// Consid Filiais  ?  						 �
//� mv_par20	// da filial								 �
//� mv_par21	// a flial 									 �
//������������������������������������������������������������
//����������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                    �
//������������������������������������������������������������
wnrel:="FINR350"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nMoeda := mv_par10
Titulo += " - " + GetMv("MV_MOEDA"+Str(nMoeda,1))

RptStatus({|lEnd| Fa350Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FA350Imp � Autor � Paulo Boschetti       � Data � 01.06.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posicao dos Fornecedores                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FA350Imp(lEnd,wnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - A��o do Codeblock                                ���
���          � wnRel   - T�tulo do relat�rio                              ���
���          � cString - Mensagem                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FA350Imp(lEnd,wnRel,cString)

Local CbTxt,cbCont
Local nOrdem,nTotAbat:=0
Local nTit1:=0,nTit2:=0,nTit3:=0,nTit4:=0,nTit5:=0,nTit6:=0,nTit7:=0,nTit8:=0,nTit9:=0,nTit10:=0
Local nTot1:=0,nTot2:=0,nTot3:=0,nTot4:=0,nTot5:=0,nTot6:=0,nTot7:=0,nTot8:=0,nTot9:=0,nTot10:=0
Local lContinua:=.T.,cForAnt:=Space(6),nSaldo:=0
Local aValor	:={0,0,0,0,0,0}
Local nMoeda	:=0
Local dDataMoeda
Local cCond1,cCond2,cChave,cIndex
#IFDEF TOP
	Local cOrder
	Local aStru := SE2->(dbStruct()), ni
#ENDIF	
Local cFilterUser := aReturn[7]
Local ndecs		:=Msdecimais(mv_par10)
Local cAliasSA2 := "SA2"
Local lImpPAPag	:= IiF(MV_PAR16=2, .T. ,.F.)  //Imprime PA Gerada pela Ordem de Pago.
//Local nConv		:= mv_par17    
Local cCpoEmis 	:= If(mv_par18 == 1,"E2_EMISSAO","E2_EMIS1")    
Local nTotFil1:=0
Local nTotFil2:=0
Local nTotFil3:=0
Local nTotFil4:=0
Local nTotFil5:=0
Local nTotFil6:=0
Local nTotFil7:=0
Local nTotFil8:=0
Local nTotFil9:=0
Local nTotFil10:=0
Local lPCCBaixa  := SuperGetMv("MV_BX10925",.T.,"2") == "1"
Local nAj        := iif(cPaisLoc == "BRA",0,9)
Local nValorOrig := 0
Local lPaBruto   := GetNewPar("MV_PABRUTO","2") == "1"  //Indica se o PA ter� o valor dos impostos descontados do seu valor
Local nInc       := 0
Local aSM0       := AdmAbreSM0()
Local nVlOriMoed := 0

//******************************************
// Utilizados pelo ponto de entrada F350MFIL
//******************************************
Local lMovFil	:= .T. //Default: Imprime todas as filiais
Local lImpMFil 	:= .T.     
Local nReg
//******************************************
Private nRegSM0 := SM0->(Recno())
Private nAtuSM0 := SM0->(Recno())
Private cFilNome	:= ""
PRIVATE cFilDe,cFilAte  

dDataMoeda:=dDataBase

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt :=Space(10)
cbcont:=00
li    :=80
m_pag :=01
nOrdem := aReturn[8]

nMoeda := mv_par10

SomaAbat("","","","P")

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If mv_par19 == 2
	cFilDe  := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	cFilAte := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
ELSE
	cFilDe := mv_par20	// Todas as filiais
	cFilAte:= mv_par21
Endif

If ExistBlock("F350MFIL")
	lMovFil := ExecBlock("F350MFIL",.F.,.F.)			              
Endif

For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. (aSM0[nInc][2] >= cFilDe .and. aSM0[nInc][2] <= cFilAte)
		nReg := 0 //Zera a contagem de registros impressos.

		dbSelectArea("SE2")
		cFilAnt := aSM0[nInc][2]
		cFilNome := aSM0[nInc][7]

		dbSelectArea("SE2")
		If nOrdem == 1
			dbSetOrder(6)
			cChave := IndexKey()
			dbSeek (cFilial+mv_par01+mv_par03,.t.)
			cCond1 :='SE2->E2_FORNECE+SE2->E2_LOJA <= mv_par02+mv_par04 .and. SE2->E2_FILIAL == xFilial("SE2")'
			cCond2 := "SE2->E2_FORNECE+SE2->E2_LOJA"
			#IFDEF TOP
				cOrder := SqlOrder(cChave)
			#ENDIF
		Else
			cChave  := "E2_FILIAL+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
			#IFDEF TOP
				If TCSrvType() == "AS/400"
					cIndex	:= GetNextAlias() 
					dbSelectArea("SE2")
					IndRegua("SE2",cIndex,cChave,,FR350FIL(),OemToAnsi(STR0014))  //"Selecionando Registros..."
					nIndex	:= RetIndex("SE2")
					dbSetOrder(nIndex+1)
				Else
					cOrder := SqlOrder(cChave)
				EndIf
			#ELSE
				cIndex	:= GetNextAlias()
				dbSelectArea("SE2")
				IndRegua("SE2",cIndex,cChave,,FR350FIL(),OemToAnsi(STR0014))  //"Selecionando Registros..."
				nIndex	:= RetIndex("SE2")
				dbSetIndex(cIndex+OrdBagExt())
				dbSetOrder(nIndex+1)
			#ENDIF
			cCond1 := ".T."
			cCond2 := "SE2->E2_FORNECE+SE2->E2_LOJA"
			SE2->( dbGoTop() )
		EndIf
		SetRegua(LastRec())
	
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				dbSelectArea("SE2")
				aStru := dbStruct()
				
				cQuery := "SELECT SE2.*,SA2.A2_COD,SA2.A2_NOME,SA2.A2_NREDUZ "
				cQuery += " FROM " + RetSqlName("SE2") +" SE2, "+ RetSqlName("SA2") +" SA2 "
				cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
				cQuery += " AND SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
				cQuery += " AND SE2.E2_FORNECE = SA2.A2_COD "
				cQuery += " AND SE2.E2_LOJA = SA2.A2_LOJA "
				cQuery += " AND SE2.E2_FORNECE between '" + mv_par01        + "' AND '" + mv_par02       + "'"
				cQuery += " AND SE2.E2_LOJA    between '" + mv_par03        + "' AND '" + mv_par04       + "'"
				cQuery += " AND SE2."+cCpoEmis+"  between '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
				cQuery += " AND SE2.E2_VENCREA between '" + DTOS(mv_par07)  + "' AND '" + DTOS(mv_par08) + "'"
				cQuery += " AND SE2.E2_TIPO NOT IN " + FormatIn(MVABATIM,"|")
				cQuery += " AND SE2."+cCpoEmis+"  <=  '"     + DTOS(dDataBase) + "'"
				If mv_par09 == 2
					cQuery += " AND SE2.E2_TIPO <> '"+MVPROVIS+"'"
				EndIf
				If mv_par12 == 2
					If cpaisLOC =="BRA"
					  	cQuery += "AND SE2.E2_FATURA IN('"+Space(Len(SE2->E2_FATURA))+"','NOTFAT')"
					Else  	         
				  	  	cQuery += "AND SE2.E2_ORIGEM <>'FINA085A'"         
					EndIf  	
				Endif
			If mv_par13 == 2 
				cQuery += " AND SE2.E2_MOEDA = " + STR(mv_par10)
			Endif
				cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
				cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
				cQuery += " ORDER BY " + cOrder
	
				cQuery := ChangeQuery(cQuery)
	    	
				dbSelectArea("SE2")	
				dbCloseArea()
	
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2', .T., .T.)
	
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C' .and. FieldPos(aStru[ni,1]) > 0
						TCSetField('SE2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
	
				cAliasSA2 := "SE2"
	
			EndIf
		#ENDIF
	                           
		//�����������������������������������������������������Ŀ
		//�Posicionamento do SE5 neste ponto que servira para   �
		//�pesquisa de descarte de registros geradores de       �
		//�desdobramento                                        �
		//�������������������������������������������������������
		dbSelectArea("SE5")
		SE5->(dbSetOrder(7))	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
		dbSelectArea("SE2")
	
		While !Eof() .And. lContinua .And. &cCond1
	
			dbSelectArea("SE2")
	
			IF lEnd
				@PROW()+1,001 PSAY OemToAnsi(STR0008)  //"CANCELADO PELO OPERADOR"
				Exit
			EndIF
	
			//��������������������������������������������������������������Ŀ
			//� Considera filtro do usuario                                  �
			//����������������������������������������������������������������
			If !Empty(cFilterUser).and.!(&cFilterUser)
				dbSelectArea("SE2")
				dbSkip()
				Loop
			Endif
	
			nCont:=1
			nTit1:=nTit2:=nTit3:=nTit4:=nTit5:=nTit6:=nTit7:=nTit8:=nTit9:=nTit10:=0
			cForAnt:= &cCond2
	
			While &cCond2 == cForAnt .And. lContinua .And. &cCond1 .And. !Eof()
				IF (ALLTRIM(SE2->E2_TIPO)$MV_CPNEG+","+MVPAGANT .Or. SUBSTR(SE2->E2_TIPO,3,1)=="-").and. Iif(cPaisLoc<> "BRA","FINA085" $ Upper( AllTrim( SE2->E2_ORIGEM)),.T.);
					.And. lImpPAPag // Nao imprime o PA qdo ele for gerado pela Ordem de Pago
					dbSelectArea("SE2")
					dbSkip()
					Loop
				Else
					IF lEnd
						@PROW()+1,001 PSAY OemToAnsi(STR0008)  //"CANCELADO PELO OPERADOR"
						lContinua := .F.
						Exit
					EndIF
	
					IncRegua()
					//��������������������������������������������������������������Ŀ
					//� Considera filtro do usuario                                  �
					//����������������������������������������������������������������
					If !Empty(cFilterUser).and.!(&cFilterUser)
						dbSelectArea("SE2")
						dbSkip()
						Loop
					Endif
	    	
					If !Fr350Skip()
						dbSelectArea("SE2")
						dbSkip()
						Loop
					EndIf
	
					//�����������������������������������������������������Ŀ
					//�Pesquisa de descarte de registros geradores de       �
					//�desdobramento                                        �
					//�������������������������������������������������������
					If SE5->(dbSeek(xFilial("SE5") + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
						If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) == "DSD"
							SE2->(dbSkip())
							Loop
						Endif
					Endif					
	
					#IFDEF TOP
						If TcSrvType() == "AS/400"	
							dbSelectArea(cAliasSA2)
							dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
						Endif
					#ELSE
						dbSelectArea(cAliasSA2)
						dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
					#ENDIF
	
					IF li > 58     
						nAtuSM0 := SM0->(Recno())
						SM0->(dbGoto(nRegSM0))
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
						SM0->(dbGoTo(nAtuSM0))
					EndIF
	
					If nCont = 1
						@li,0 PSAY OemToAnsi(STR0009)+(cAliasSA2)->A2_COD+" "+IIF(mv_par15 == 1,(cAliasSA2)->A2_NOME,(cAliasSA2)->A2_NREDUZ)  //"FORNECEDOR : "
						li+=2
						nCont++
					Endif
	
					dbSelectArea("SE2")
	
					IF mv_par11 == 1
						dDataMoeda	:=	dDataBase
					Else
						dDataMoeda	:=	SE1->E1_VENCREA
					Endif
	
					aValor:=Baixas( SE2->E2_NATUREZA,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,nMoeda,"P",SE2->E2_FORNECE,dDataBase,SE2->E2_LOJA)
	
					If mv_par14 == 1
						nSaldo :=SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZA,"P",SE2->E2_FORNECE,nMoeda,;
								If(mv_par11==1,dDataBase,SE2->E2_VENCREA),,SE2->E2_LOJA,,If(mv_par17 == 1 ,SE2->E2_TXMOEDA,0))
	
					Else       	
						nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,mv_par10,If(mv_par17 == 1,If(mv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1),dDataBase),nDecs+1,If(mv_par17 == 1 .and. SE2->E2_TXMOEDA>0,SE2->E2_TXMOEDA,))							
					Endif  
	            
					nTotAbat:=SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,mv_par10,"V",,SE2->E2_LOJA,If(mv_par18==1,"1","2"),mv_par05,mv_par06,;
								If(mv_par17 == 1,If(mv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1),dDataBase),If(mv_par17 == 1 .and. SE2->E2_TXMOEDA>0,SE2->E2_TXMOEDA,),If(mv_par17 == 1 .and. SE2->E2_TXMOEDA>0,1,))  
					
					aValor[I_JUROS] += SE2->E2_SDACRES
					aValor[I_DESCONTO] += SE2->E2_SDDECRE
	            	
					If ! (SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. ! ( MV_PAR14 == 2 .And. nSaldo == 0 ) // nao deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
						nSaldo -= nTotAbat
					EndIf  
	
					//��������������������������������������������������������������Ŀ
					//� Se foi gerada fatura, colocar Motbx == Faturado				  �
					//����������������������������������������������������������������
					If !Empty(SE2->E2_DTFATUR) .and. SE2->E2_DTFATUR <= dDataBase
						aValor[I_MOTBX] := STR0015  //"Faturado"
						aValor[I_VALOR_PAGO] -= nTotAbat
					Endif
	
					If cPaisLoc == "BRA" .And. !lPaBruto  .And. alltrim(SE2->E2_TIPO)$"PA ,"+MV_CPNEG
						nValorOrig:=SE2->E2_VALOR+SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL
					Else 
						nValorOrig:=SE2->E2_VALOR    	
					EndIf
	
					@li,00     PSAY SE2->E2_PREFIXO+"-"+SE2->E2_NUM
					@li,17+nAj PSAY SE2->E2_PARCELA
					@li,20+nAj PSAY SE2->E2_TIPO
	            	                          
            		nVlOriMoed := xMoeda(nValorOrig,SE2->E2_MOEDA,nMoeda,;
									IIf(mv_par17 == 1,IIf(mv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1),dDataBase),;
									nDecs+1,If(mv_par17 == 1 .and. SE2->E2_TXMOEDA>0,SE2->E2_TXMOEDA,))

					@li,24+nAj PSAY SayValor( nVlOriMoed, 15, ( SE2->E2_TIPO == "PA " ), nDecs ) 
	        	
					@li,41+nAj PSAY If(mv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1)
					@li,52+nAj PSAY SE2->E2_VENCREA
	        	
					IF dDataBase >= SE2->E2_BAIXA
						@li,63+nAj PSAY IIF(!Empty(SE2->E2_BAIXA),SE2->E2_BAIXA," ")
					End
	       
					If cPaisLoc == "BRA"
	    				If lPCCBaixa                            
							// Calcula valor de PA com PCC
							If SE2->E2_TIPO $ MVPAGANT
								aValor[I_LEI10925] := (SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL)
								// Se nao for PA Bruto, abate valor de impostos do valor pago da PA, pois sera destacado na coluna "Lei 19925"
								If !lPaBruto
									aValor[I_VALOR_PAGO] -= aValor[I_LEI10925]
								EndIf
							EndIf
							@li, 73 PSAY aValor[I_LEI10925] Picture Tm(aValor[I_LEI10925],11,nDecs)
						Else
							aValor[I_LEI10925]:= (SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL)           
							@li, 73 PSAY aValor[I_LEI10925] Picture Tm(aValor[I_LEI10925],11,nDecs)
						Endif	
					EndIf
					@li, 84 PSAY aValor[I_DESCONTO] 	Picture Tm(aValor[I_DESCONTO],13,nDecs)
					@li, 98 PSAY nTotAbat				Picture Tm(nTotAbat,13,nDecs)
					@li,112 PSAY aValor[I_JUROS]		Picture Tm(aValor[I_JUROS],13,nDecs)
					@li,126 PSAY aValor[I_MULTA]		Picture Tm(aValor[I_MULTA],13,nDecs)
					@li,140 PSAY aValor[I_CORRECAO_MONETARIA] Picture Tm(aValor[I_CORRECAO_MONETARIA],13,nDecs)
					@li,154 PSAY SayValor(aValor[I_VALOR_PAGO],15,.F.,nDecs)
					@li,170 PSAY aValor[I_PAGAM_ANT]	Picture Tm(aValor[I_PAGAM_ANT],15,nDecs)
	
					@li,188 PSAY SayValor(nSaldo,16,.F.,nDecs) 
					@li,206 PSAY aValor[I_MOTBX]
					If ! ( SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG )
						nTit1+= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,nMoeda,If(mv_par17 == 1,If(mv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1),dDataBase),nDecs+1,If(mv_par17 == 1 .and. SE2->E2_TXMOEDA>0,SE2->E2_TXMOEDA,))
						nTit7+=aValor[I_VALOR_PAGO]
						nTit9+=nSaldo 
					Else
						nTit1-= xMoeda(nValorOrig,SE2->E2_MOEDA,nMoeda,If(mv_par17 == 1,If(mv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1),dDataBase),nDecs+1,If(mv_par17 == 1 .and. SE2->E2_TXMOEDA>0,SE2->E2_TXMOEDA,))
						nTit7-=aValor[I_VALOR_PAGO]
						nTit9-=nSaldo 
					Endif
					
					nTit2+=aValor[I_DESCONTO]
					nTit3+=nTotAbat
					nTit4+=aValor[I_JUROS]
					nTit5+=aValor[I_MULTA]
					nTit6+=aValor[I_CORRECAO_MONETARIA]
					nTit8+=aValor[I_PAGAM_ANT]
					If cPaisLoc == "BRA"
						nTit10+=aValor[I_LEI10925]
		            EndIf
					dbSelectArea("SE2")
					dbSkip()
					li++
					nReg++
				Endif
			Enddo
			If ( ABS(nTit1)+ABS(nTit2)+ABS(nTit3)+ABS(nTit4)+ABS(nTit5)+ABS(nTit6)+ABS(nTit7)+ABS(nTit8)+ABS(nTit9)+ABS(nTit10) > 0 )
				ImpSubTot(nTit1,nTit2,nTit3,nTit4,nTit5,nTit6,nTit7,nTit8,nTit9,nTit10,nDecs)
				li++
			Endif
			nTot1+=nTit1
			nTot2+=nTit2
			nTot3+=nTit3
			nTot4+=nTit4
			nTot5+=nTit5
			nTot6+=nTit6
			nTot7+=nTit7
			nTot8+=nTit8
			nTot9+=nTit9
			nTot10+=nTit10
	
			nTotFil1 += nTit1
			nTotFil2 += nTit2
			nTotFil3 += nTit3
			nTotFil4 += nTit4
			nTotFil5 += nTit5
			nTotFil6 += nTit6
			nTotFil7 += nTit7
			nTotFil8 += nTit8			
			nTotFil9 += nTit9	  
			nTotFil10+= nTit10
		EndDO                    
	
		SE2->(DbCloseArea())		
	
		//Imprime ou n�o as filiais sem movimento - P.E. F350MFIL
		If !lMovFil
			lImpMFil := Iif(nReg != 0, .T., .F.)
		Endif
		//����������������������������������������Ŀ
		//� Imprimir TOTAL por filial somente quan-�
		//� do houver mais do que 1 filial.        �
		//������������������������������������������
		if mv_par19 == 1 .and. SM0->(LastRec()) > 1 .And. lImpMFil
			ImpFil350(nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFil5,nTotFil6,nTotFil7,nTotFil8,nTotFil9,nTotFil10,nDecs)	
		Endif
		Store 0 To nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFil5,nTotFil6,nTotFil7,nTotFil8,nTotFil9
		If Empty(xFilial("SE1"))
			Exit
		Endif	
	EndIf
Next

cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

IF li > 55 .and. li != 80
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIF

IF li != 80
	ImpTotG(nTot1,nTot2,nTot3,nTot4,nTot5,nTot6,nTot7,nTot8,nTot9,nTot10,nDecs)
	roda(cbcont,cbtxt,tamanho)
EndIF

Set Device To Screen

#IFNDEF TOP
	dbSelectArea("SE2")
	dbClearFil()
	RetIndex( "SE2" )
	If !Empty(cIndex)
		FErase (cIndex+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	if TcSrvType() != "AS/400"
		dbSelectArea("SE2")
		dbCloseArea()
		ChkFile("SE2")
		dbSelectArea("SE2")
		dbSetOrder(1)
	else
		dbSelectArea("SE2")
		dbClearFil()
		If Select("__SE2") <> 0
			__SE2->(dbCloseArea())
		Endif
		RetIndex( "SE2" )
		If !Empty(cIndex)
			FErase (cIndex+OrdBagExt())
		Endif
		dbSetOrder(1)
	endif
#ENDIF

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpSubTot � Autor � Paulo Boschetti       � Data � 01.06.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprimir linha de SubTotal do relatorio                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �ImpSubTot()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpSubTot(nTit1,nTit2,nTit3,nTit4,nTit5,nTit6,nTit7,nTit8,nTit9,nTit10,nDecs)
li++
@li,000 PSAY OemToAnsi(STR0010)  //"Totais : "
@li,022 PSAY nTit1  Picture Tm(nTit1,17,nDecs)
If cPaisLoc == "BRA"
	@li,071 PSAY nTit10 PicTure Tm(nTit10,13,nDecs)
EndIf
@li,084 PSAY nTit2  PicTure Tm(nTit2,13,nDecs)
@li,098 PSAY nTit3  PicTure Tm(nTit3,13,nDecs)
@li,112 PSAY nTit4  PicTure Tm(nTit4,13,nDecs)
@li,126 PSAY nTit5  PicTure Tm(nTit5,13,nDecs)
@li,140 PSAY nTit6  PicTure Tm(nTit6,13,nDecs)
@li,154 PSAY nTit7  PicTure Tm(nTit7,15,nDecs)
@li,170 PSAY nTit8  PicTure Tm(nTit8,15,nDecs)
@li,187 PSAY nTit9  PicTure Tm(nTit9,17,nDecs)
li++
@li,  0 PSAY REPLICATE("-",220)
li++
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpTotG  � Autor � Paulo Boschetti       � Data � 01.06.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir linha de Total do Relatorio                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ImpTotG()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpTotg(nTot1,nTot2,nTot3,nTot4,nTot5,nTot6,nTot7,nTot8,nTot9,nTot10,nDecs)
li++
@li,000 PSAY OemToAnsi(STR0011)  //"TOTAL GERAL ---->"
@li,022 PSAY nTot1  Picture Tm(nTot1,17,nDecs)
If cPaisLoc == "BRA"
	@li,071 PSAY nTot10 PicTure Tm(nTot10,13,nDecs)
EndIf
@li,084 PSAY nTot2  PicTure Tm(nTot2,13,nDecs)
@li,098 PSAY nTot3  PicTure Tm(nTot3,13,nDecs)
@li,112 PSAY nTot4  PicTure Tm(nTot4,13,nDecs)
@li,126 PSAY nTot5  PicTure Tm(nTot5,13,nDecs)
@li,140 PSAY nTot6  PicTure Tm(nTot6,13,nDecs)
@li,154 PSAY nTot7  PicTure Tm(nTot7,15,nDecs)
@li,170 PSAY nTot8  PicTure Tm(nTot8,15,nDecs)
@li,187 PSAY nTot9  PicTure Tm(nTot9,17,nDecs)
li++
Return(.t.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR350FIL  � Autor � Andreia          	    � Data � 12.01.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Indregua para impressao do relat�rio 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FR350FIL()
Local cString
Local cCpoEmis 	:= If(mv_par18 == 1,"E2_EMISSAO","E2_EMIS1")

cString := 'E2_FILIAL="'+xFilial("SE2")+'".And.'
cString += 'dtos('+cCpoEmis+'  )>="'+dtos(mv_par05)+'".and.dtos('+cCpoEmis+'  )<="'+dtos(mv_par06)+'".And.'
cString += 'dtos(E2_VENCREA)>="'+dtos(mv_par07)+'".and.dtos(E2_VENCREA)<="'+dtos(mv_par08)+'".And.'
cString += 'E2_FORNECE>="'+mv_par01+'".and.E2_FORNECE<="'+mv_par02+'".And.'
cString += 'E2_LOJA>="'+mv_par03+'".and.E2_LOJA<="'+mv_par04+'"'

Return cString

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � AndaTRB	� Autor � Emerson / Sandro      � Data � 20.09.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Movimenta area temporaria e reposiciona SE1 ou SE2 ou SE5  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �         																	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 																  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
/*
Static Function AndaTRB(xMyAlias)
#IFDEF TOP
Local cAlias:= Alias()
	If TcSrvType() != "AS/400"
		dbSelectArea(XMyAlias)
		dbSkip()
		(cAlias)->(dbGoTo((xMyAlias)->Recno))
		dbSelectArea(cAlias)
	Else
		dbSkip()
	Endif
#ELSE
	dbSkip()
#ENDIF

Return
*/


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fr350Skip � Autor � Pilar S. Albaladejo   |Data  � 13.10.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pula registros de acordo com as condicoes (AS 400/CDX/ADS)  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINR350.PRX												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fr350Skip(cAlias)
Local lRet := .T. 
Local cEmissao 
Default cAlias := "SE2"

cEmissao := If(mv_par18 == 1, (cAlias)->E2_EMISSAO, (cAlias)->E2_EMIS1)

//��������������������������������������������������������������Ŀ
//� Verifica se esta dentro dos parametros                       �
//����������������������������������������������������������������
IF (cAlias)->E2_FORNECE < mv_par01 .OR. (cAlias)->E2_FORNECE > mv_par02 .OR. ;
		(cAlias)->E2_LOJA    < mv_par03 .OR. (cAlias)->E2_LOJA    > mv_par04 .OR. ;
		cEmissao   < mv_par05 .OR. cEmissao   > mv_par06 .OR. ;
		(cAlias)->E2_VENCREA < mv_par07 .OR. (cAlias)->E2_VENCREA > mv_par08 .OR. ;
		(cAlias)->E2_TIPO $ MVABATIM
	lRet :=  .F.

	//��������������������������������������������������������������Ŀ
	//� Verifica se o t�tulo � provis�rio                            �
	//����������������������������������������������������������������
ElseIf ((cAlias)->E2_TIPO $ MVPROVIS .and. mv_par09==2)
	lRet := .F.

ElseIF cEmissao   > dDataBase
	lRet := .F.

	//����������������������������������������Ŀ
	//� Verifica se deve imprimir outras moedas�
	//������������������������������������������
Elseif mv_par13 == 2 .And. (cAlias)->E2_MOEDA != mv_par10 //verifica moeda do campo=moeda parametro
	lret := .F.
	//��������������������������������������������������������������Ŀ
	//� Verifica se o t�tulo foi aglutinado em uma fatura            �
	//����������������������������������������������������������������
ElseIf !Empty((cAlias)->E2_FATURA) .and. Substr((cAlias)->E2_FATURA,1,6)!="NOTFAT" .and. !Empty( (cAlias)->E2_DTFATUR ) .and. DtoS( (cAlias)->E2_DTFATUR ) <= DtoS( mv_par06 ).And.;
	mv_par12 <> 1
	lRet :=  .F. 	// Considera Faturados = mv_par12
Endif
Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �SayValor  � Autor � J�lio Wittwer    	  � Data � 24.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna String de valor entre () caso Valor < 0 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINR350.PRX																  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SayValor(nNum,nTam,lInvert,nDecs)
Local cPicture,cRetorno
nDecs := IIF(nDecs == NIL, 2, nDecs)

cPicture := tm(nNum,nTam,nDecs)
cRetorno := Transform(nNum,cPicture)
IF nNum<0 .or. lInvert
	cRetorno := "("+substr(cRetorno,2)+")"
Endif
Return cRetorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PictNeg	� Autor � Adrianne Furtado  	� Data � 03.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �TRansforme uma Picture em Picture com "()"parenteses para   ���
���          �valores negativos. 										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINR350.PRX												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PictParent(cPict)
Local cRet   
Local nAt := At("9",cPict)   
cRet := SubStr(cPict,1,nAt-2)+")"+SubStr(cPict,nAt-1,Len(cPict))
Return cRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � ImpFil350� Autor � Adrianne Furtado 	  	� Data � 27.10.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir total do relatorio										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ImpFil130()																  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�																				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso 	    � Generico																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpFil350(nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFil5,nTotFil6,nTotFil7,nTotFil8,nTotFil9,nTotFil10,nDecs)

DEFAULT nDecs := Msdecimais(mv_par15)

li--
IF li > 58
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
EndIF

@li,000 PSAY AllTrim(OemToAnsi(STR0035))+" "+Iif(mv_par19==1,cFilAnt+" - " + AllTrim(cFilNome),"")  //"T O T A L   F I L I A L ----> "
@li,050 PSAY nTotFil1        Picture TM(nTotFil1,14,nDecs)
If cPaisLoc == "BRA"
	@li,074 PSAY nTotFil10       Picture TM(nTotFil10,10,nDecs)
EndIf
@li,087 PSAY nTotFil2        Picture TM(nTotFil2,10,nDecs)
@li,101 PSAY nTotFil3        Picture TM(nTotFil3,10,nDecs)
@li,115 PSAY nTotFil4		  Picture TM(nTotFil4,10,nDecs)
@li,129 PSAY nTotFil5 		  Picture TM(nTotFil5,10,nDecs)
@li,143 PSAY nTotFil6        Picture TM(nTotFil6,10,nDecs)
@li,159 PSAY nTotFil7		  Picture TM(nTotFil7,10,nDecs)
@li,175 PSAY nTotFil8 		  Picture TM(nTotFil8,10,nDecs)    
@li,194 PSAY nTotFil9 		  Picture TM(nTotFil9,10,nDecs)    

li++
@li,000 PSAY Replicate("-",220)
li+=2
Return .T.                                                                        

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �AjustaHLP � Autor � Ana Paula       	    � Data � 14.05.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria help para perguma 15(compoe saldo)  					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINR350.PRX												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AjustaHLP()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

Aadd( aHelpPor, 'Selecione "SIM" para compor Saldo ')
Aadd( aHelpPor, 'Retroativo ou "Nao" para nao compor')

Aadd( aHelpEng, 'Select "YES" to make the retroactive')
Aadd( aHelpEng, 'balance, otherwise "No".')

Aadd( aHelpSpa, 'Selecione "SI" para formar el Saldo')
Aadd( aHelpSpa, 'Retroactivo o "No" en caso contrario.')
	
PutSX1Help("P.FIN35014.",aHelpPor,aHelpEng,aHelpSpa)

If cPaisLoc<>"BRA"
	aHelpEspP:=	{}
	aHelpPorP:=	{}
	aHelpEngP:=	{}

	dbSelectArea("SX1")
	dbSetOrder(1)
	If SX1->( MsSeek( PadR("FIN350", Len(SX1->X1_GRUPO) ) + "12" ) )//Dbseek(cteste) 
		RecLock("SX1")
		Replace  X1_PERGUNT	With "Considera Ord. Pagos" 
		Replace  X1_PERSPA	With "Considera Orden de Pago" 
		Replace  X1_PERENG	With "Consider Payment Order?"                                                  
		MsUnlock()
	EndIf 


	Aadd(aHelpEspP,"Seleccione 'S�' para que el informe considere los t�tulos")
	Aadd(aHelpEspP," generados por la orden de pago, de lo contrario, seleccione 'No'.")
	Aadd(aHelpPorP,"Selecione 'Sim' para que o relat�rio considere os t�tulos ")
	Aadd(aHelpPorP,"gerados pela ordem de pago ou 'N�o', caso contrario")
	Aadd(aHelpEngP,"Select 'Yes' so that the report considers the bills")
	Aadd(aHelpEngP," generated by the payment order, otherwise, select 'No'.")
	
	PutHelp("P.FIN35012.",aHelpPorP,aHelpEngP,aHelpEspP,.T.)
EndIf	

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AdmAbreSM0� Autor � Orizio                � Data � 22/01/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna um array com as informacoes das filias das empresas ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
	Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0
