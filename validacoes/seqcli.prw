#Include "Protheus.ch"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � SeqCli   � Autor � Thiago Menegocci    � Data � 15/08/2008  ���
��������������������������������������������������������������������������͹��
���Descricao � Rotina para manutencao dos paramentros                      ���
��������������������������������������������������������������������������͹��
���Uso       � BK                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function SeqCli()

Local _cNum1 := GetMv("MV_SeqCli")
		
//Thiago Bassi Menegocci
//******************************
//AJUSTA PARAMETRO "MV_SeqCli" *
//******************************
PutMV("MV_SeqCli",Soma1(_cNum1))
//******************************
// FIM DO AJUSTE DE PARAMETRO  *
//******************************        

RECLOCK("SA2",.T.)
SA2->A2_COD := _cNum1
MSUNLOCK()

Return(_cNum1)