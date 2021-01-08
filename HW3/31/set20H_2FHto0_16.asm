;*******************************************
;**** Program title: Running LED ***********
;**** Programmer: Mr. Chatchai   ***********
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
		
;Declare File register
counter	EQU	40H
value	EQU	41H

		ORG	0x00	; reset vector
		GOTO START	; jump to start of the program
		
		ORG	0x04	; Interrupt vector
		
START:	; Port Configuration
		BCF	STATUS,RP1	; or 'BCF 0x03,0x06'
		BSF	STATUS,RP0	; Select Bank1
		BSF	TRISA,1		; Port RA1 is an Input pin
		BCF	TRISB,0		; Port RB0 is an output pin
		BCF	STATUS,RP0	; Back to Bank0
		
		; Start your program here
		
		movlw	20H
		movwf	FSR
		clrw			; clrw = movlw 0H
		movwf	value	; set value = w = 0
		movlw	.16		; set w = 16
		movwf	counter	; set counter =16
		
AGAIN:  movf	value,w
		movwf	INDF
		incf	value,f
		incf	FSR,f
		decfsz	counter,f
		goto	AGAIN
		;done
				
		END