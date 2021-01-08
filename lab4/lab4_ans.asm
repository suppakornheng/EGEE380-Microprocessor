;*******************************************
;**** lab4 switch debounce *****************
;*******************************************

		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF

;****** Define general purpose registers for temporary variables
		cblock 	0x20
			temp
			temp1
			count
			count0
			count1
			count2
		endc
;***********************************************************
		ORG		0x00		; Reset Vector
		goto	main		; vector to main program
		
main:
		call	init		; calling initialization subroutine
		
L1:
		btfsc	PORTA,1
		goto	L2
		
		movlw	.10
		call	DelayMS
		
		btfsc	PORTA,1
		goto	L2
		
		bsf		PORTB,1

L2:		
		btfsc 	PORTA,0		; Check if the switch is pressed?
		goto 	L3			; No the switch is not pressed
		
		movlw	.10			; Yes the switch is pressed then delay for 10mS
		call 	DelayMS		; by calling the time delay subroutine
		
		btfsc	PORTA,0		; Check again if the switch is still pressed?
		goto	L3			; No then go back to check the switch again
		
		bsf		PORTB,0		; Yes the switch is still pressed
							; then turn on the LED
		
L3:
		btfss	PORTA,0		; Check if switch is released?
		goto	L4			; No the switch is still pressed
		
		bcf		PORTB,0		; Yes the switch is released	
							; then turn off the LED
							
L4:
		btfss	PORTA,1
		goto	L1
		
		bcf		PORTB,1
		goto	L1			; Go back and repeat the loop again
		
;************* Subroutine *******************

init:
		movlw	.7
		banksel	CMCON
		movwf	CMCON		; disable analog comparator
		banksel	TRISB
		movlw	0x00
		movwf	TRISB		; PORTB is output port
		movlw	0xFF
		movwf	TRISA		; PORTA is input port
		banksel	PORTB
		clrf	PORTB
		return
		
DelayMS:
		movwf	count2
		incf	count2,f
		decfsz	count2,f
		goto	$+2
		goto	$+3
		call	Delay1MS
		goto	$-4
		return
		
Delay1MS:
		movlw	.50			; 1 cyc
		movwf	count1		; 1 cyc
outterloop:
		movlw	.5			; 1 cyc * count1
		nop					; 1 cyc * count1
		movwf	count0		; 1 cyc * count1
innerloop:
		decfsz	count0,F   	; 1 cyc * count1 * count0
		goto	innerloop	; 2 cyc * count1 * count0
		decfsz	count1,F   	; 1 cyc * count1
		goto	outterloop	; 2 cyc * count1
		return				; 1 cyc
		; total = 3 + (6+3.count0).count1
		; count0 = 5 , count1 = 50, total = 1053 cyc ??

		END
	
		



















		