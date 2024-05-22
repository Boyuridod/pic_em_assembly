; Montar um programa em Assembly que acione um pisca pisca na saída RA0. Use o módulo McLab1.
; Ao iniciar o sistema, a saída RA0 deve estar apagada.
; Para acionar o pisca um dos botões devem ser acionado, RA1 ou RA2.
; O botão RA3 desliga os pisca-piscas.
; Somente pode ser acionado qualquer um dos piscas se estiver parado, isto é, se for acionado o pisca com frequência de 2HZ e desejar acionar o de 5Hz, é necessário desligar o pisca através do botão RA3 antes de acionar o botão da outra frequência.
; As frequências são:
; RA1 => 2Hz
; RA2 => 5Hz
; Clock: 4MHz
    
; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF
 
; Declaração de variáveis
 CBLOCK	    0X20
    BOOLEANO		; 0x20
    I			; 0x21
    J			; 0x22
    I_INICIAL		; 0x23
    J_INICIAL		; 0x24
    K			; 0x25
 ENDC
 
 #define    PISCOU	BOOLEANO,0
 
; Entradas
 #define    BTN_2HZ	PORTA,1
 #define    BTN_5HZ	PORTA,2
 #define    BTN_DESL	PORTA,3
 
; Saídas
 #define    LED		PORTA,0

RES_VECT  CODE    0x0000            ; processor reset vector
    BSF	    STATUS,RP0		    ; Acessa o banco 01
    BCF	    TRISA,0		    ; Define PORTA,0 como saída
    BCF	    STATUS,RP0		    ; Volta para o banco 00

INTERROMPE
    BCF	    LED			    ; Desliga o LED
    
MAIN
    BTFSS   BTN_2HZ		    ; Testa se o botão está apertado
    GOTO    PISCA_2HZ		    ; Vai para a função que liga o LED piscando em 2HZ
    BTFSS   BTN_5HZ		    ; Testa se o botão está apertado
    GOTO    PISCA_5HZ		    ; Vai para a função que liga o LED piscando em 5HZ
    
    GOTO    MAIN
    
PISCA_2HZ
    MOVLW   .50
    MOVWF   K
    MOVLW   .255	
    MOVWF   I_INICIAL
    MOVWF   J_INICIAL
    
    BTFSS   BTN_DESL
    GOTO    INTERROMPE
    
    CALL    LIGA
    
    CALL    DESLIGA
    
    GOTO    PISCA_2HZ
    
PISCA_5HZ
    
    GOTO PISCA_5HZ
    
LIGA
    BSF	    LED			    ; Liga o LED
    CALL    ESPERA
    
    RETURN
    
DESLIGA
    BCF	    LED			    ; Desliga o LED
    CALL    ESPERA
    
    RETURN
   
ESPERA
    DECFSZ  K,F
    CALL    ESPERA_MAIS_I
    
    RETURN
    
ESPERA_MAIS_I
    MOVF    I_INICIAL,W
    
    DECFSZ  I,F
    CALL    ESPERA_MAIS_J
    
    RETURN
    
ESPERA_MAIS_J
    DECFSZ  J,F
    GOTO    ESPERA_MAIS_J
    
    MOVFW   J_INICIAL
    MOVWF   J
    
    RETURN

    END