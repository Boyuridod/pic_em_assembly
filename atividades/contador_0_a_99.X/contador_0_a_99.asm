; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
#include "p16f628a.inc"
; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

#define BANK0	BCF STATUS,RP0
#define BANK1	BSF STATUS,RP0
 
;nomeando posição da memória RAM 
 CBLOCK	0x20
    FLAGS	;0x20
    CONTADOR2	;0x21
    UNIDADE	;0x22
    DEZENA	;0x23
    W_TEMP	;0x24
    STATUS_TEMP	;0x25
    CONTADOR	;0x26
 ENDC
 
;entradas
#define	    B_INICIAR	    PORTA,1
#define	    BOTAO_REVERSO   PORTA,2
#define	    B_PARAR	    PORTA,3
#define	    B_ZERAR	    PORTA,4
 
;saídas
#define	    DISPLAYS	    PORTB
#define	    QUAL_DISPLAY    PORTB,4
#define	    LED		    PORTA,0    
;variáveis
#define    JA_LI	    FLAGS,0
#define    INT_ATIVA	    FLAGS,1
#define    FIM_TEMPO	    FLAGS,2
#define    CONTANDO	    FLAGS,3
#define    FIM_LED	    FLAGS,4 

;constantes 
V_TMR0	    equ	    .6
V_FILTRO    equ	    .100
V_CONT	    equ	    .125    
V_CONT2	    equ	    .2
;=== programa ==============
RES_VECT    CODE    0x0000    ;vetor de reset, indica a posição inicial do programa na FLASH
    GOTO    INICIO

ISR	    CODE    0x0004	; interrupt vector location
    MOVWF   W_TEMP		;salva o conteúdo de W em W_TEMP	    
    MOVF    STATUS,W		;W = STATUS
    MOVWF   STATUS_TEMP		;salva o conteúdo de STATUS em STATUS_TEMP
    BTFSS   INTCON,T0IF		;testa se o indicador de interrupção por TMR0 está ativo
    GOTO    SAI_INTERRUPCAO	;se não estiver, pula para SAI_INTERRUPCAO
    BCF	    INTCON,T0IF		;zera o flag indicador de interrupção por TMR0
    MOVLW   V_TMR0		;W = V_TMR0
    ADDWF   TMR0,F		;TMR0 = TMR0 + V_TMR0
    BSF	    INT_ATIVA		;INT_ATIVA = 1
    DECFSZ  CONTADOR,F		;decrementa CONTADAOR e testa se é zero
    GOTO    SAI_INTERRUPCAO	;se não for zero, pula para SAI_INTERRUPCAO
    MOVLW   V_CONT		;W = V_CONT
    MOVWF   CONTADOR		;CONTADOR = V_CONT
    BSF	    FIM_LED		;FIM_LED
    DECFSZ  CONTADOR2,F		;decrementa CONTADOR2 e testa se é zero
    GOTO    SAI_INTERRUPCAO	;se não for zero, pula para SAI_INTERRUPCAO
    BSF	    FIM_TEMPO		;FIM_TEMPO = 1
    MOVLW   V_CONT2		;W = V_CONT2
    MOVWF   CONTADOR2		;CONTADOR2 = V_CONT2    
SAI_INTERRUPCAO
    MOVF    STATUS_TEMP,W	;W = STATUS_TEMP
    MOVWF   STATUS		;restaura o conteúdo de STATUS
    MOVF    W_TEMP,W		;restaura o conteúdo de W    	
    RETFIE    

INICIO  
    BANK1		    ;seleciona o banco 1 da memória RAM
    MOVLW   B'00000000'	    ;W =  B'11110000' (240)
    MOVWF   TRISB	    ;TRISB = B'11110000' (240)    
    BCF	    TRISA,0
    MOVLW   B'11010011'	    ;palavra de configuração do TMR0
    MOVWF   OPTION_REG	    ;carrega a palavra de configuração do TMR0 no OPTION_REG
    BANK0		    ;seleciona o banco 0 da memória RAM
    CLRF    UNIDADE	    ;UNIDADE = 0
    CLRF    DEZENA  	    ;DEZENA = 0
    BSF	    INTCON,T0IE	    ;permite atender interrupção por TMR0    
    BSF	    INTCON,GIE	    ;permite atender interrupções  
LACO_PRINCIPAL
    BTFSC   INT_ATIVA	    ;testa se o bit indicador de tempo 4ms está ativo
    CALL    TROCA_DISPLAY   ;se INT_ATIVA = 1, chama sub-rotina TROCA_DISPLAY
    BTFSS   CONTANDO	    ;testa se CONTANDO = 1
    GOTO    PARADO	    ;se não, pule para PARADO     
    BTFSS   B_PARAR	    ;testa se o botão B_PARAR está liberado	
    GOTO    B_PARAR_PRESS   ;se pressionado pule para B_PARAR_PRESS
    BTFSC   FIM_LED	    ;testa se o FIM_LED = 0
    CALL    TROCA_LED	    ;se FIM_LED = 1, chama a rotina de troca de estado do LED 
    BTFSS   FIM_TEMPO	    ;testa se o FIM_TEMPO = 1
    GOTO    LACO_PRINCIPAL  ;se FIM_TEMPO = 0, pula para  LACO_PRINCIPAL
    BCF	    FIM_TEMPO	    ;FIM_TEMPO = 0
    INCF    UNIDADE,F	    ;UNIDADE++
    MOVLW   .10		    ;W = 10 (B'00001010' ou 0x0A)
    SUBWF   UNIDADE,W	    ;W = UNIDADE - W
    BTFSS   STATUS,C	    ;testa se o resultado é positivo
    GOTO    LACO_PRINCIPAL  ;se resutado for negativo, pula para LACO_PRINCIPAL
    CLRF    UNIDADE	    ;UNIDADE = 0
    INCF    DEZENA,F	    ;DEZENA++
    MOVLW   .10		    ;W = 10 (B'00001010' ou 0x0A)
    SUBWF   DEZENA,W	    ;W = DEZENA - W
    BTFSC   STATUS,C	    ;testa se o resultado é negativo
    CLRF    DEZENA	    ;DEZENA = 0
    GOTO    LACO_PRINCIPAL  ;pula para LACO_PRINCIPAL  
  
B_PARAR_PRESS
    BCF	    CONTANDO	    ;CONTANDO = 0 
    BCF	    LED		    ;LED = 0
    GOTO    LACO_PRINCIPAL  ;pula para LACO_PRINCIPAL 
PARADO
    BTFSS   B_INICIAR	    ;testa se o botão B_INICIAR está liberado
    GOTO    B_INICIAR_PRESS ;se pressionado pule para B_INICIAR_PRESS
    BTFSC   B_ZERAR	    ;testa se o botão B_ZERAR está liberado
    GOTO    LACO_PRINCIPAL  ;se não pressionado pule para LACO_PRINCIPAL 
    CLRF    UNIDADE	    ;UNIDADE = 0  
    CLRF    DEZENA	    ;DEZENA = 0
    GOTO    LACO_PRINCIPAL  ;pula para LACO_PRINCIPAL
 
B_INICIAR_PRESS
    BSF	    CONTANDO	    ;CONTANDO = 1
    BCF	    FIM_TEMPO	    ;FIM_TEMPO = 0
    BCF	    FIM_LED	    ;FIM_LED = 0    
    MOVLW   V_CONT	    ;W = V_CONT
    MOVWF   CONTADOR	    ;CONTADOR = V_CONT
    MOVLW   V_CONT2	    ;W = V_CONT2
    MOVWF   CONTADOR2	    ;CONTADOR2 = V_CONT2
    BSF	    LED		    ;LED = 1
    GOTO    LACO_PRINCIPAL  ;pula para LACO_PRINCIPAL

BOTAO_REVERSO_PRESS
    BSF	    CONTANDO	    ;CONTANDO = 1
    BCF	    FIM_TEMPO	    ;FIM_TEMPO = 0
    BCF	    FIM_LED	    ;FIM_LED = 0    
    MOVLW   V_CONT	    ;W = V_CONT
    MOVWF   CONTADOR	    ;CONTADOR = V_CONT
    MOVLW   V_CONT2	    ;W = V_CONT2
    MOVWF   CONTADOR2	    ;CONTADOR2 = V_CONT2
    BSF	    LED		    ;LED = 1
    GOTO    LACO_PRINCIPAL  ;pula para LACO_PRINCIPAL
 
TROCA_LED
    BCF	    FIM_LED	    ;FIM_LED = 0
    BTFSS   LED		    ;testa se LED = 1
    GOTO    ACENDE_LED	    ;se LED = 0, pula para ACENDE_LED
    BCF	    LED		    ;se LED = 0, apaga o LED
    RETURN		    ;retorna da chamada de subrotina  
ACENDE_LED
    BSF	    LED		    ;LED = 1
    RETURN		    ;retorna da chamada de subrotina
    
TROCA_DISPLAY
    BCF	    INT_ATIVA	    ;INT_ATIVA = 0
    BTFSS   QUAL_DISPLAY    ;testa se o display da UNIDADE está acesso
    GOTO    ACENDE_UNIDADE  ;se DEZENA está acesa, pula para ACENDE_UNIDADE
ACENDE_DEZENA
    MOVF    DEZENA,W	    ;W = DEZENA
    CALL    BUSCA_CODIGO    ;chama a subrotina para buscar o código de 7 segmentos
    ANDLW   B'11101111'	    ;
    MOVWF   DISPLAYS	    ;DISPLAYS = W (código de 7 segmentos)
    RETURN		    ;retorna da chamada de subrotina
ACENDE_UNIDADE    
    MOVF    UNIDADE,W	    ;W = UNIDADE
    CALL    BUSCA_CODIGO    ;chama a subrotina para buscar o código de 7 segmentos
    MOVWF   DISPLAYS	    ;DISPLAYS = W (código de 7 segmentos)
    RETURN		    ;retorna da chamada de subrotina    
    
BUSCA_CODIGO
    ADDWF   PCL,F	    
    RETLW   B'11111110'	    ;254   
    RETLW   B'00111000'	    ;56
    RETLW   B'11011101'	    ;221
    RETLW   B'01111101'	    ;125
    RETLW   B'00111011'	    ;59
    RETLW   B'01110111'	    ;119
    RETLW   B'11110111'	    ;247
    RETLW   B'00111100'	    ;60
    RETLW   B'11111111'	    ;255
    RETLW   B'01111111'	    ;127
    
    END