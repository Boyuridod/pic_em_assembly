;Modificar o programa contador de 0 a 9, para interface McLab1, para realizar as seguintes tarefas:
;- o bot�o RA1 reinicializa a sequ�ncia, ou seja, volta a indicar "zero" no display;
;- o bot�o RA2, contagem progressiva, a cada acionamento do bot�o;
;- o bot�o RA3, contagem regressiva, a cada acionamento do bot�o;
;- o bot�o RA1 tem prioridade sobre os outros, ou seja, se ele estiver pressionado o contador n�o conta para cima nem para baixo.
    
#include "p16f628a.inc"

; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF
 
;Defini��o das entradas
 #define    BOTAO_ZERA	    PORTA,1
 #define    BOTAO_PROG	    PORTA,2
 #define    BOTAO_REGR	    PORTA,3
 
;Defini��o de vari�veis
 CBLOCK	0X20
    COD_NUM_DISPLAY			;0X20
    FILTRO				;0X21
 ENDC
 
;Defini��o de sa�das
 #define    DISPLAY	    PORTB

RES_VECT  CODE    0x0000		; processor reset vector
    BSF	    STATUS,RP0			;Seleciona o banco 01
    MOVLW   B'00000000'			;W = B'00000000'
    MOVWF   TRISB			;Todas as portas B s�o sa�da
    BCF	    TRISA,0			;Define PORTA,0 como sa�da
    BCF	    STATUS,RP0			;Volta pro banco 00
    MOVLW   B'00000001'			;W = B'00000001'
    CLRF    COD_NUM_DISPLAY		;COD_NUM_DISPLAY = 1
    GOTO    ZERAR
    
MAIN
    BTFSS   BOTAO_PROG			;Testa se o bot�o foi apertado, se n�o ele pula
    GOTO    INCREMENTA			;Chama a fun��o para incrementar 1 no display
    BTFSS   BOTAO_REGR			;Testa se o bot�o foi apertado, se n�o ele pula
    GOTO    DECREMENTA			;Chama a fun��o para decrementar 1 no display
    BTFSS   BOTAO_ZERA			;Testa se o bot�o foi apertado, se n�o ele pula
    GOTO    ZERAR			;Chama a fun��o que zera o display
    
    GOTO    MAIN			;Volta pro loop
    
CANCELA_RUIDO_PROG    
    BTFSS   BOTAO_PROG			;Testa se o bot�o foi pressionado novamente
    MOVWF   FILTRO			;Se ele entendeu que foi pressionado, o filtro reseta
    
    BTFSS   BOTAO_ZERA			;Testa se o bot�o foi apertado, se n�o ele pula
    GOTO    ZERAR			;Se ele foi apertado, como o Zerar tem prioridade, ele zera
    
    DECFSZ  FILTRO,F			;Filtro--; se Filtro == 0 ele pula a instru��o
    GOTO    CANCELA_RUIDO_PROG		;Se n�o ele vai voltar e continuar o teste
    
    RETURN				;Volta para onde a subrotina foi chamada
    
INCREMENTA
    MOVLW   .100			;Coloca em W quantas vezes o filtro vai testar se o bot�o t� pressionado
    CALL    CANCELA_RUIDO_PROG		;Testa se os ruidos acabaram
    
    INCF    COD_NUM_DISPLAY,F		;COD_NUM_DISPLAY++
    MOVF    COD_NUM_DISPLAY,W		;W = COD_NUM_DISPLAY
    CALL    BUSCA_CODIGO		;Procura o n�mero que ser� exibido pelo c�digo
    MOVWF   DISPLAY			;Coloca o n�mero no display
    
    GOTO    MAIN			;Volta pro loop
    
CANCELA_RUIDO_REGR    
    BTFSS   BOTAO_REGR			;Testa se o bot�o foi pressionado novamente
    MOVWF   FILTRO			;Se ele entendeu que foi pressionado, o filtro reseta
    
    BTFSS   BOTAO_ZERA			;Testa se o bot�o foi apertado, se n�o ele pula
    GOTO    ZERAR			;Se ele foi apertado, como o Zerar tem prioridade, ele zera
    
    DECFSZ  FILTRO,F			;Filtro--; se Filtro == 0 ele pula a instru��o
    GOTO    CANCELA_RUIDO_REGR		;Se n�o ele vai voltar e continuar o teste
    
    RETURN				;Volta para onde a subrotina foi chamada
    
DECREMENTA
    MOVLW   .100			;Coloca em W quantas vezes o filtro vai testar se o bot�o t� pressionado
    CALL    CANCELA_RUIDO_REGR		;Testa se os ruidos acabaram
            
    DECF    COD_NUM_DISPLAY,F		;COD_NUM_DISPLAY--
    MOVF    COD_NUM_DISPLAY,W		;W = COD_NUM_DISPLAY
    CALL    BUSCA_CODIGO		;Procura o n�mero que ser� exibido pelo c�digo
    MOVWF   DISPLAY			;Coloca o n�mero no display
    
    GOTO    MAIN			;Volta pro loop
    
ZERAR
    MOVLW   B'11111110'			;W = B'11111110' || .254
    MOVWF   DISPLAY			;DISPLAY = W | Display mostrar� 0
    MOVLW   B'00000001'			;W = B'00000001'
    MOVWF   COD_NUM_DISPLAY		;COD_NUM_DISPLAY = W
    
    GOTO    MAIN			;Volta pro loop
    
MAXIMIZAR
    MOVLW   .10				;W = .10
    MOVWF   COD_NUM_DISPLAY		;COD_NUM_DISPLAY = W
    CALL    BUSCA_CODIGO		;Procura o n�mero que ser� exibido pelo c�digo
    MOVWF   DISPLAY			;DISPLAY = W | Display mostrar� 9
    
    GOTO    MAIN
    
BUSCA_CODIGO
    ADDWF   PCL,F			;Incrementa o PC (Program Counter)
    GOTO    MAXIMIZAR			;C�digo: 0  | Volta o Display para "9"
    RETLW   .254			;C�digo: 1  | Escreve "0" no display
    RETLW   .56				;C�digo: 2  | Escreve "1" no display
    RETLW   .221			;C�digo: 3  | Escreve "2" no display
    RETLW   .125			;C�digo: 4  | Escreve "3" no display
    RETLW   .59				;C�digo: 5  | Escreve "4" no display
    RETLW   .119			;C�digo: 6  | Escreve "5" no display
    RETLW   .247			;C�digo: 7  | Escreve "6" no display
    RETLW   .60				;C�digo: 8  | Escreve "7" no display
    RETLW   .255			;C�digo: 9  | Escreve "8" no display
    RETLW   .127			;C�digo: 10 | Escreve "9" no display
    GOTO    ZERAR			;C�digo: 11 | Volta o display para "0"

    END