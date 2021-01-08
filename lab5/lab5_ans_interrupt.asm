;*******************************************
;**** lab5 up down switch to 7 segment -> interrupt
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_OFF & _HS_OSC & _LVP_OFF & _WDT_OFF

		cblock 	0x20
			temp
			INT_mS
			TESTTTT
			temp1
			count
			count0
			count1
			count2
			w_temp
			OPTION_REG_temp
			STATUS_temp
		endc
		
		ORG 0x00		;reset vector
		goto	main	;vector to main program

		ORG	0x04		;interrupt vector
		goto	ISR		;exit Interrupt Service Routine

		
main:
		call	Init
		goto	$

;---interrupt---	
;clock 4MHz, 1cycle=1uS
;ISR every 200mS -> 200,000 cycle
; 200,000/x < 256 -> x > 200,000/256
; 256-(1000/4)= 256-250 = 6

ISR:	
		bcf		INTCON,T0IF		; clear Timer0 interrupt flag
		movlw 	.6
		movwf	TMR0			; reload for another 100uS period

		incf	INT_mS,f
		movlw	.200
		subwf 	INT_mS,w
		btfsc	STATUS,Z	;check if INT_mS=200?
		call	L1			;yes

		RETFIE


L1:		incf	temp,f
		
		movlw	.16
		subwf	temp,w		
		btfsc	STATUS,Z	;check if temp=16?		
		clrf	temp		;Yes, clear 'temp' back to zero
				
		movf	temp,w		;use [Temp] to call 'Table7seg'
		call	Table7seg
		movwf	TESTTTT
		movwf	PORTB		;Send the obtain 7 seg pattern to PORTB
		clrf	INT_mS
		
		return
		
		
;Loopup table for 7segments LED Patterns
Table7seg:
		addwf	PCL,F
		;Segments	.GFEDBA
		retlw	B'00111111'		;Number0
		retlw	B'00000110'		;Number1
		retlw	B'01011011'		;Number2
		retlw	B'01001111'		;Number3
		retlw	B'01100110'		;Number4
		retlw	B'01101101'		;Number5
		retlw	B'01111101'		;Number6
		retlw	B'00000111'		;Number7
		retlw	B'01111111'		;Number8
		retlw	B'01101111'		;Number9
		retlw	B'01110111'		;A
		retlw	B'01111100'		;B
		;retlw	B'01011000'		;C little 
		retlw	B'00111001'		;C big
		retlw	B'01011110'		;D
		retlw	B'01111001'		;E
		retlw	B'01110001'		;F
		retlw	B'10000000'		;dot-point
		
		
Init:	;---Port Config---
		banksel	PORTB		; select Bank0
		movlw	.7
		banksel CMCON		; select Bank0 (CMCON อยู่ Bank0)
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB		; select Bank1
		clrf	TRISB		; 0=output, 1=input
		;---End Port Config---
		;---Option Config---
		banksel	OPTION_REG	;	select Bank1
		movlw	B'00000001'	;	prescaler to TMR0 at rate 1:4 
		movwf	OPTION_REG
		;---Interrupt Config---
		banksel PORTB		;	select Bank0
		bsf		INTCON,T0IE	; enable timer0 interrupt
		bcf		INTCON,T0IF	; clear timer0 interrupt flag
		bsf		INTCON,GIE	; enable global interrupt *enable GIE should be the last code line (dunno why)
		;---End Interrupt Config---
		;---End Option Config---
		movlw	.6		; reload value for 1mS interrupt period
		banksel	PORTA		; select Bank0 
		movwf	TMR0		; set TMR0 = 6
		clrf	PORTB
		clrf	temp
		clrf	INT_mS
		return
		
		END
		
		
		
		
		
		