#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �BKFIN11   �Autor  � Marcos B. Abrah�o  � Data � 02/02/2012  ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro Codigo Fluxo de Caixa BK                          ���
�������������������������������������������������������������������������͹��
���Uso       �BK                                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������


/*/ 

User Function BKFINA11()
AxCadastro("SZE","Cadastro Codigo Fluxo de Caixa "+ALLTRIM(SM0->M0_NOME))
Return Nil