; PIC16F877A Configuration Bit Settings
; Assembly source line config statements
#include "p16f877a.inc"
; CONFIG
; __config 0xFF71
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

#define BANK0	BCF STATUS,RP0
#define BANK1	BSF STATUS,RP0
 
;nomeando posição da memória RAM 
 CBLOCK	0x20
    FLAGS	;0x20
    CONTADOR	;0x21
    UNIDADE	;0x22
    DEZENA	;0x23
    CENTENA	;0x24
    MILHAR	;0x25
    VALOR_ADC_H	;0x26
    VALOR_ADC_L	;0x27    
    W_TEMP	;0x28
    STATUS_TEMP	;0x29
    X_H
    X_L
    Y_H
    Y_L
    R_H
    R_L 
 ENDC
 
;entradas
#define	    BTN0  	    PORTB,0
#define	    BTN1  	    PORTB,1 
#define	    BTN2  	    PORTB,2
#define	    BTN3  	    PORTB,3  
 
;saídas
#define	    DISPLAYS	    PORTD
#define	    D_UNIDADE	    PORTB,4
#define	    D_DEZENA	    PORTB,5
#define	    D_CENTENA	    PORTB,6
#define	    D_MILHAR	    PORTB,7
#define	    FAN		    PORTC,0
;#define	    FAN_VEL	    PORTC,1
#define	    HEATER	    PORTC,2
 
;variáveis
#define	    INT_ATIVA	    FLAGS,0
#define	    FIM_TEMPO	    FLAGS,1
#define	    EH_NEGATIVO	    FLAGS,2
#define	    QUAL_CANAL 	    FLAGS,3

;constantes 
V_TMR0	    equ	    .6
V_CONT	    equ	    .250  
	    
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
    BSF	    FIM_TEMPO		;FIM_TEMPO = 1  
SAI_INTERRUPCAO
    MOVF    STATUS_TEMP,W	;W = STATUS_TEMP
    MOVWF   STATUS		;restaura o conteúdo de STATUS
    MOVF    W_TEMP,W		;restaura o conteúdo de W    	
    RETFIE
    
BUSCA_CODIGO
    ADDWF   PCL,F	    
    RETLW   B'00111111'	    ;63   
    RETLW   B'00000110'	    ;6
    RETLW   B'01011011'	    ;91
    RETLW   B'01001111'	    ;79
    RETLW   B'01100110'	    ;102
    RETLW   B'01101101'	    ;109
    RETLW   B'01111101'	    ;125
    RETLW   B'00000111'	    ;7
    RETLW   B'01111111'	    ;127
    RETLW   B'01101111'	    ;111
    
INICIO  
    BANK1		    ;seleciona o banco 1 da memória RAM
    BCF	    TRISC,2	    ;configura a bit 2 do PORTC como saída
    MOVLW   B'00001111'	    ;W = 00001111
    MOVWF   TRISB	    ;TRISB = 00001111,configura os 4LSB como entrada e os 4MSB como saída
    CLRF    TRISD	    ;TRISD = 00000000,configura o PORTD como saída
    MOVLW   B'11010001'	    ;palavra de configuração do TMR0
    MOVWF   OPTION_REG	    ;carrega a palavra de configuração do TMR0 no OPTION_REG
    MOVLW   B'11000100'	    ;palavra de configuração do ADCON1
			    ;bit 7: justificado à direita = 1
			    ;bit 6: origem do clock do ADC - RC = 1 11
			    ;bit 5..4: não usado = 00
			    ;bit 3..0: PCFG3..0: seleção de entradas = 0100
    MOVWF   ADCON1	    ;carrega a configuração no ADCON1			
    BANK0		    ;seleciona o banco 0 da memória RAM
    MOVLW   B'11001001'	    ;palavra de configuração do ADCON0
			    ;bit 7..6: origem do clock do ADC - RC = 1 11
			    ;bit 5..3: seleção de canal a ser lido = 001
			    ;bit 2: inicia a conversão e avisa que acabou
			    ;bit 1: não usado
			    ;bit 0: ativa o conversor AD = 1
    MOVWF   ADCON0	    ;carrega a configuração no ADCON0    
    
DESLIGA_TUDO
    CLRF    UNIDADE	    ;UNIDADE = 0
    CLRF    DEZENA  	    ;DEZENA = 0
    CLRF    CENTENA	    ;CENTENA = 0
    CLRF    MILHAR  	    ;MILHAR = 0
    BCF	    QUAL_CANAL	    ;QUAL_CANAL = 0
    BCF	    HEATER	    ;HEATER = 0
    BCF	    FAN		    ;FAN = 0
    BCF	    D_UNIDADE	    ;apaga o display da UNIDADE
    BCF	    D_DEZENA	    ;apaga o display da DEZENA
    BCF	    D_CENTENA	    ;apaga o display da CENTENA
    BCF	    D_MILHAR	    ;apaga o display da MILHAR     
    BSF	    INTCON,T0IE	    ;permite atender interrupção por TMR0    
    BSF	    INTCON,GIE	    ;permite atender interrupções  
LACO_PRINCIPAL
    BTFSS   BTN0	    ;Testa se o Botão ON foi apertado
    GOTO    SISTEMA_ON	    ;Liga o sistema
    GOTO    LACO_PRINCIPAL  ;Se o sistema estiver desligado ele continua esperando ligar
    
SISTEMA_ON
    BTFSS   BTN1	    ;Testa se o Botão ON foi apertado
    GOTO    DESLIGA_TUDO    ;Volta para o Laço principal
    BTFSS   BTN2	    ;testa se a chave está acionada
    BCF	    QUAL_CANAL	    ;QUAL_CANAL = 0
    BTFSS   BTN3	    ;testa se a chave está acionada
    BSF	    QUAL_CANAL	    ;QUAL_CANAL = 1 
    
    BTFSC   INT_ATIVA	    ;testa se o bit indicador de tempo 4ms está ativo
    CALL    TROCA_DISPLAY   ;se INT_ATIVA = 1, chama sub-rotina TROCA_DISPLAY
    BTFSS   FIM_TEMPO	    ;testa se o FIM_TEMPO = 1
    GOTO    LACO_PRINCIPAL  ;se FIM_TEMPO = 0, pula para  LACO_PRINCIPAL
    ;lê a entrada analógica - AN1
    BCF	    FIM_TEMPO	    ;FIM_TEMPO = 0
    BTFSC   QUAL_CANAL	    ;verifica o canal que será lido
    GOTO    AJUSTA_CANAL0   ;se QUAL_CANAL = 1, pula para AJUSTA_CANAL0
    BSF	    ADCON0,3	    ;seta o bit4 para seleciona o canal 1
ATIVA_CONVERSAO   
    BSF	    ADCON0,GO	    ;inicia a conversão
TESTA_FIM    
    BTFSC   ADCON0,GO	    ;testa se finalizou a conversão
    GOTO    $-1		    ;mesma coisa de  GOTO TESTA_FIM
    MOVF    ADRESH,W	    ;lê os 8MSBs do resultado da conversão
    MOVWF   VALOR_ADC_H	    ;VALOR_ADC_H = ADRESH
    BANK1		    ;seleciona banco 1 da memória RAM
    MOVF    ADRESL,W	    ;lê os 8LSBs do resultado da conversão
    BANK0		    ;seleciona banco 0 da memória RAM
    MOVWF   VALOR_ADC_L	    ;VALOR_ADC_L = ADRESL
    CLRF    MILHAR	    ;MILHAR = 0
EXTRAI_MILHAR    
    MOVF    VALOR_ADC_H,W   ;W = VALOR_ADC_H
    MOVWF   X_H		    ;X_H = VALOR_ADC_H
    MOVF    VALOR_ADC_L,W   ;W = VALOR_ADC_L
    MOVWF   X_L		    ;X_L = VALOR_ADC_L  
    MOVLW   0x03	    ;W = 0x03
    MOVWF   Y_H		    ;Y_H = 0x03
    MOVLW   0xE8	    ;W = 0xE8
    MOVWF   Y_L		    ;Y_L = 0xE8 
    CALL    SUB_16_BITS	    ;chama rotina de subtração de 16 bits
    BTFSC   EH_NEGATIVO	    ;testa se o resultado da operação deu negativo
    GOTO    TRATA_CENTENA   ;se negativo pula para TRATA_CENTENA
    MOVF    R_H,W	    ;W = R_H
    MOVWF   VALOR_ADC_H	    ;VALOR_ADC_H = R_H
    MOVF    R_L,W	    ;W = R_L
    MOVWF   VALOR_ADC_L	    ;VALOR_ADC_L = R_L    
    INCF    MILHAR,F	    ;MILHAR++
    GOTO    EXTRAI_MILHAR   ;pula para EXTRAI_MILHAR
TRATA_CENTENA    
    CLRF    CENTENA	    ;CENTENA = 0
EXTRAI_CENTENA  
    MOVF    VALOR_ADC_H,W   ;W = VALOR_ADC_H
    MOVWF   X_H		    ;X_H = VALOR_ADC_H
    MOVF    VALOR_ADC_L,W   ;W = VALOR_ADC_L
    MOVWF   X_L		    ;X_L = VALOR_ADC_L  
    MOVLW   0x00	    ;W = 0x00
    MOVWF   Y_H		    ;Y_H = 0x03
    MOVLW   0x64	    ;W = 0x64
    MOVWF   Y_L		    ;Y_L = 0xE8 
    CALL    SUB_16_BITS	    ;chama rotina de subtração de 16 bits    
    BTFSC   EH_NEGATIVO	    ;testa se o resultado da operação deu negativo
    GOTO    TRATA_DEZENA    ;se negativo pula para TRATA_DEZENA    
    MOVF    R_H,W	    ;W = R_H
    MOVWF   VALOR_ADC_H	    ;VALOR_ADC_H = R_H
    MOVF    R_L,W	    ;W = R_L
    MOVWF   VALOR_ADC_L	    ;VALOR_ADC_L = R_L    
    INCF    CENTENA,F	    ;CENTENA++
    GOTO    EXTRAI_CENTENA  ;pula para EXTRAI_CENTENA    
TRATA_DEZENA
    CLRF    DEZENA	    ;DEZENA = 0
EXTRAI_DEZENA
    MOVLW   .10		    ;W = 10
    SUBWF   VALOR_ADC_L,W   ;W = VALOR_ADC_L - W
    BTFSS   STATUS,C	    ;testa se o resultado é negativo
    GOTO    TRATA_UNIDADE   ;se negativo, pula para verificar valor unidade
    MOVWF   VALOR_ADC_L	    ;VALOR_ADC_L = W = VALOR_ADC_L - 10
    INCF    DEZENA,F	    ;DEZENA++
    GOTO    EXTRAI_DEZENA   ;    
TRATA_UNIDADE
    MOVF    VALOR_ADC_L,W   ;W = VALOR_ADC_L
    MOVWF   UNIDADE	    ;UNIDADE = VALOR_ADC_L 
    GOTO    LACO_PRINCIPAL  ;pula para o LACO_PRINCIPAL
AJUSTA_CANAL0
    BCF	    ADCON0,3	    ;reseta o bit4 para seleciona o canal 0
    GOTO    ATIVA_CONVERSAO ;pula para ATIVA_CONVERSAO
    
    
    
TROCA_DISPLAY
    BCF	    INT_ATIVA	    ;INT_ATIVA = 0   
    BTFSS   D_UNIDADE	    ;testa se o display da UNIDADE está acesso
    GOTO    TESTA_DEZENA    ;se UNIDADE não estiver acesa, pula para TESTA_DEZENA
ACENDE_DEZENA
    BCF	    D_UNIDADE	    ;apaga o display da UNIDADE
    MOVF    DEZENA,W	    ;W = DEZENA
    CALL    BUSCA_CODIGO    ;chama a subrotina para buscar o código de 7 segmentos
    MOVWF   DISPLAYS	    ;DISPLAYS = W (código de 7 segmentos)
    BSF	    D_DEZENA	    ;ativa o display da DEZENA
    RETURN		    ;retorna da chamada de subrotina
TESTA_DEZENA
    BTFSS   D_DEZENA	    ;testa se o display da DEZENA está acesso
    GOTO    TESTA_CENTENA   ;se DEZENA não estiver acesa, pula para TESTA_CENTENA    
    BCF	    D_DEZENA	    ;apaga o display da DEZENA
    MOVF    CENTENA,W	    ;W = CENTENA
    CALL    BUSCA_CODIGO    ;chama a subrotina para buscar o código de 7 segmentos
    MOVWF   DISPLAYS	    ;DISPLAYS = W (código de 7 segmentos)
    BSF	    D_CENTENA	    ;ativa o display da CENTENA
    RETURN		    ;retorna da chamada de subrotina    
TESTA_CENTENA
    BTFSS   D_CENTENA	    ;testa se o display da CENTENA está acesso
    GOTO    TESTA_MILHAR    ;se CENTENA não estiver acesa, pula para TESTA_MILHAR    
    BCF	    D_CENTENA	    ;apaga o display da CENTENA
    MOVF    MILHAR,W	    ;W = MILHAR
    CALL    BUSCA_CODIGO    ;chama a subrotina para buscar o código de 7 segmentos
    MOVWF   DISPLAYS	    ;DISPLAYS = W (código de 7 segmentos)
    BSF	    D_MILHAR	    ;ativa o display da MILHAR
    RETURN		    ;retorna da chamada de subrotina     
TESTA_MILHAR    
    BCF	    D_MILHAR	    ;apaga o display da MILHAR
    MOVF    UNIDADE,W	    ;W = UNIDADE
    CALL    BUSCA_CODIGO    ;chama a subrotina para buscar o código de 7 segmentos
    MOVWF   DISPLAYS	    ;DISPLAYS = W (código de 7 segmentos)
    BSF	    D_UNIDADE	    ;ativa o display da UNIDADE
    RETURN		    ;retorna da chamada de subrotina
    
SUB_16_BITS
    BCF	    EH_NEGATIVO	    ;
    MOVF    Y_L,W	    ;W = Y_L
    SUBWF   X_L,W	    ;W = X_L - Y_L
    MOVWF   R_L		    ;R_L = X_L - Y_L
    BTFSS   STATUS,C	    ;testa se o resutado foi negativo
    BSF	    EH_NEGATIVO	    ;se negativo EH_NEGATIVO = 1
    MOVF    Y_H,W	    ;W = Y_H
    SUBWF   X_H,W	    ;W = X_H - Y_H
    MOVWF   R_H		    ;R_H = X_H - Y_H
    BTFSS   STATUS,C	    ;testa se o resutado foi negativo
    GOTO    RES_NEGATIVO    ;se negativo pula para RES_NEGATIVO
    BTFSS   EH_NEGATIVO	    ;testa se EH_NEGATIVO = 1
    RETURN		    ;se não está ativo retorna
    MOVLW   .1		    ;W = 1
    SUBWF   R_H,F	    ;RH = RH - 1
    BTFSS   STATUS,C	    ;testa se o resutado foi negativo
    RETURN		    ;se é negativo retorna
    BCF	    EH_NEGATIVO	    ;EH_NEGATIVO = 0
    RETURN		    ;retorna    
RES_NEGATIVO    
    BSF	    EH_NEGATIVO	    ;EH_NEGATIVO = 1
    RETURN		    ;retorna   
    
    END