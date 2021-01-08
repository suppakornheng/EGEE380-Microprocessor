;Analog_Comparator_Interrupt.asm
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG _CP_OFF & _MCLRE_ON & INTRC_OSC_NOCLKOUT & _LVP_OFF &_WDT_OFF
		
		ORG 	0x00
		goto	main
		
		ORG		0x04
		goto	Analog_ISR
		
main:
		call 	init
inf_loop:
		nop
		nop
		goto 	inf_loop
Analog_ISR:
		bcf		PIR1,CMIF	; clear analog comparator interrupt flag
		btfss	CMCON,C2OUT
		goto	SET_HIGH
SET_LOW:
		bsf		PORTB,0
		bcf		PORTB,1
		goto	OVER
SET_HIGH:
		bcf		PORTB,0
		bsf		PORTB,1
OVER:
		retfie
		

		
init:
		banksel	TRISA		; Select Bank1
		movlw	B'00000110'	; RA1, RA2 are input pins
		movwf	TRISA
		clrw	
		movwf	TRISB		; Port B is output 
		banksel	PORTB		; select Bank0
		clrw
		movwf	PORTB
		movlw 	.5			; 5 = B'0000101' ;Analog comparator in mode 5 (single C2)
		movwf	CMCON
		movf	CMCON,w		; read CMCON register to clear glitch
		;interrupt setting for analog comparator
		bsf		INTCON,PEIE	; enable peripheral interrupt services
		banksel	PIE1		; PIE1 register is in bank1
		bsf		PIE1,CMIE	; enable analog comparator interrupt
		banksel	PORTB
		bcf		PIR1,CMIF	; clear interrupt flag
		bsf		INTCON,GIE	; enable global interrupt
		return
		
		END
		
		
		