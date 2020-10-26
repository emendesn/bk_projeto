//Bibliotecas

#INCLUDE "TOPCONN.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 

//Vari�veis Est�ticas
Static cTitulo := "Alterar CC Doc Entrada"


/**************************************************************************
*** Programa: BKCOMA11   | Autor: Marcos Bispo Abrah�o | Data: 07/03/2018 *
***************************************************************************
*** Descricao: Fun��o para cadastro de Itens de Doc de Entrada (SD1),     *
***            exemplo de Modelo 1 em MVC                                 *
***                                                                       *
***       Obs: N�o se pode executar fun��o MVC dentro do f�rmulas,        *
***            exemplo de Modelo 1 em MVC                                 *
***************************************************************************
*** Parametros: <cPerg> -                                                 *
***************************************************************************
*** Retorno: <Nil>                                                        *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function BKCOMA11()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SD1")
 
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "!EMPTY(SD1->D1_PEDIDO)",  "GREEN",    "Com pedido" )
    oBrowse:AddLegend( "EMPTY(SD1->D1_PEDIDO)",   "RED",      "Sem pedido" )
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil


/**************************************************************************
*** Programa: MenuDef    | Autor: Daniel Atilio        | Data: 17/08/2015 *
***************************************************************************
*** Descricao: Cria��o do menu MVC                                        *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Array>                                                      *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 

/**************************************************************************
*** Programa: ModelDef   | Autor: Daniel Atilio        | Data: 17/08/2015 *
***************************************************************************
*** Descricao: Cria��o do modelo de dados MVC                             *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Objeto>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/ 
Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil
     
    //Cria��o da estrutura de dados utilizada na interface
    Local oStSD1 := FWFormStruct(1, "SD1")
     
    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zMVCMd1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
     
    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMSD1",/*cOwner*/,oStSD1)
     
    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'D1_FILIAL','D1_DOC','D1_SERIE'})
     
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMSD1"):SetDescription("Itens dos documentos de entrada "+cTitulo)
Return oModel


/**************************************************************************
*** Programa: ViewDef    | Autor: Daniel Atilio        | Data: 17/08/2015 *
***************************************************************************
*** Descricao: Cria��o da vis�o MVC                                       *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Objeto>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
Static Function ViewDef()
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("zMVCMd1")
     
    //Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSD1 := FWFormStruct(2, "SD1")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SD1_NOME|SD1_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_SD1", oStSD1, "FORMSD1")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_SD1', 'Dados do Grupo de Produtos' ) 
     
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_SD1","TELA")
Return oView


/**************************************************************************
*** Programa: zMVC01Leg  | Autor: Daniel Atilio        | Data: 17/08/2015 *
***************************************************************************
*** Descricao: Fun��o para mostrar a legenda das rotinas MVC com grupo de *
***            produtos                                                   *
***************************************************************************
*** Parametros:                                                           *
***************************************************************************
*** Retorno: <Objeto>                                                     *
***************************************************************************
*** Uso:                                                                  *
**************************************************************************/
User Function zMVC01Leg()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERDE",        "Original"  })
    AADD(aLegenda,{"BR_VERMELHO",    "N�o Original"})
     
    BrwLegenda("Grupo de Produtos", "Procedencia", aLegenda)
Return
