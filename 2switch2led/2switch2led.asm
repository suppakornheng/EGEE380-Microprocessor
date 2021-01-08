;*******************************************
;2switch2led.asm กดติดปล่อยดับ
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
		
;Declare File register

		ORG	0x00	; reset vector
		GOTO START	; jump to start of the program
		
		ORG	0x04	; Interrupt vector
		
START:	; Port Configuration
		MOVLW	.7			
		MOVWF	CMCON		; CMCON=7 turn-off analog comparator inputs
		BCF		STATUS,RP1	; or 'BCF 0x03,0x06'
		BSF		STATUS,RP0	; Select Bank1
		BSF		TRISA,0		; Port RA0 is an Input pin
		BSF		TRISA,1		; Port RA1 is an Input pin
		BCF		TRISB,0		; Port RB0 is an output pin
		BCF		TRISB,1		; Port RB1 is an output pin
		BCF		STATUS,RP0	; Back to Bank0
		
		; Start your program here
Inf_loop:
		BTFSC	PORTA,1		; Test switch R1
		GOTO 	K1_PRESSED	; If R1 is pressed
		BTFSC 	PORTA,0		; Test switch K2
		GOTO	K2_PRESSED	; if R2 is pressed
		BSF		PORTB,0		; OFF LED2 = LED ACTIVE LOW >> off use BSF (if LED is active high use bcf)
		BSF		PORTB,1		; OFF LED1
		GOTO	Inf_loop
K1_PRESSED:
		BCF		PORTB,1		; ON LED1 = LED ACTIVE LOw >> on use BCF
		GOTO	Inf_loop
		
K2_PRESSED:
		BCF		PORTB,0		; ON LED 2
		GOTO	Inf_loop
		
		END
		
		
		
		