/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTA120MNU �Autor  � Adilson do Prado  � Data �  02/12/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Localizado na rotina de Medi��o do Contrato, este ponto    ���
��� 		   de entrada tem por finalidade adicionar bot�es ao menu     ���
�������������������������������������������������������������������������͹��
���Uso       � BK                                                         ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  

User function CTA120MNU()

//Apontar para medicao de servico 
//Local cRtMed := aRotina[3,2]

aRotina[3,2] := "CN120Serv"
aRotina[3,6] := .F.

//AADD(aRotina,{OemToAnsi("Medi��o Z"),  cRtMed, 0, 2 })

//Aviso("CTA120MNU","Adiciona botoes de menu",{"OK"})

Return