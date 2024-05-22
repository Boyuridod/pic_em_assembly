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
    DISPLAY	;0X20
 ENDC

RES_VECT  CODE    0x0000		; processor reset vector

    BSF	    STATUS,RP0			;Seleciona o banco 01
    MOVLW   B'00000000'			;W = B'00000000'
    MOVWF   TRISB			;Todas as portas B s�o sa�da
    BCF	    STATUS,RP0			;Volta pro banco 00
    
MAIN
    ;BTFSC   BOTAO_PROG			;Testa se o bot�o foi apertado, se n�o ele pula
    ;GOTO    INCREMENTA
    ;BTFSC   BOTAO_REGR			;Testa se o bot�o foi apertado, se n�o ele pula
    ;GOTO    BECREMENTA
    BTFSC   BOTAO_ZERA			;Testa se o bot�o foi apertado, se n�o ele pula
    GOTO    ZERAR
    
ZERAR
    MOVLW   B'11111110'			;W = B'11111110' || .254
    MOVWF   DISPLAY			;DISPLAY = W
    MOVWF   PORTB			;O display mostrar� o 0
    GOTO    MAIN
    
BUSCA_CODIGO
    ADDWF   PCL,F			;Incrementa o PC (Program Counter)
    RETLW   .254			;0
    RETLW   .56				;1
    RETLW   .221			;2
    RETLW   .125			;3
    RETLW   .59				;4
    RETLW   .119			;5
    RETLW   .247			;6
    RETLW   .60				;7
    RETLW   .255			;8
    RETLW   .127			;9

    END