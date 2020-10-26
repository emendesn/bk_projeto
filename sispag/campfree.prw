// Marcos B. Abrah�o - 31/10/14
#include "rwmake.ch"        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CAMPFREE � Autor � Anderson Rais         � Data � 20/01/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Este Rdmake compoe as Rotinas de geracao do SISPAG, arquivo���
���          � 341REM.PAG e 341RET.PAG                                    ���
���          � Calcula o layout para o Campo Livre de Dados do Codigo de  ���
���          � Barras.                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Exclusivo para SANKYO PHARMA                               ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

User Function CAMPFREE()     

Local cCampFree

If     Len(Alltrim(SE2->E2_CODBAR)) == 44            
        cCampFree := Substr(SE2->E2_CODBAR,20,25)                                                                   
ElseIF Len(Alltrim(SE2->E2_CODBAR)) == 47
        cCampFree := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+Substr(SE2->E2_CODBAR,22,10)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 40
        cCampFree := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+Substr(SE2->E2_CODBAR,22,10)
Else
        cCampFree := Replicate("0",25)                                                                   
EndIf

Return(cCampFree)         
