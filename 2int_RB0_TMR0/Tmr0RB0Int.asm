;*******************************************
;**** Program title:  2 interrupt RB0 and TMR0
;******************************************

		PROCESSOR PIC16F627A
		#include <P16F627A.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF

;***** Variable Declaration (general purpose registers)

bank0 	macro
			bcf	STATUS,RP0
			bcf	STATUS,RP1
		endm
bank1 	macro
			bsf	STATUS,RP0
			bcf	STATUS,RP1
		endm

PUSH	macro
			movwf	W_TEMP
			swapf	W_TEMP,f
			bank1
			swapf	OPTION_REG,w
			movwf	OPTION_TEMP
			bank0
			swapf	STATUS,w
			movwf	STATUS_TEMP
		endm
		
POP		macro
			swapf	STATUS_TEMP,w
			movwf	STATUS
			bank1
			swapf	OPTION_TEMP,w
			movwf	OPTION_REG
			bank0
			swapf	W_TEMP,w
		endm
		
		cblock 	0x20
			STATUS_TEMP		; temporary variables
			W_TEMP
			OPTION_TEMP
			temp
			temp1
			count
			count0
			count1
			count2
		endc

		ORG		0x00		; Reset Vector
		goto	Mymain		; vector to main program


		ORG		0x04		; Interrupt Vector
		goto	ISR			; vector to interrupt service routine

Mymain
		call	Init
Here
		movf	TMR0,w
		goto	Here
		
		
;***** Timer0 and RB0/INT Interrupt Service Routine *****************
ISR
		;*** context saving ******
		PUSH
		
		btfsc	INTCON,INTF
		goto	RB0INT_ISR
		
		btfsc	INTCON,T0IF
		goto	TMR0_ISR
		
		goto	ISR_EXIT
		
RB0INT_ISR
		;*** RB0/INT ISR begins here ***
		bcf		INTCON,INTF
		btfss	PORTB,1
		goto	LED1_ON
LED1_OFF
		bcf		PORTB,1
		goto	DONE1
LED1_ON	
		bsf		PORTB,1
DONE1		
		goto 	ISR_EXIT
		

TMR0_ISR
		;*** TMR0 ISR begins here ****
		bcf		INTCON,T0IF
		bcf		INTCON,GIE		; disable global interrupt
		incf	count,f		; increment system tick every 65.536 ms
		

		movlw	.15
		subwf	count,w		; check sys_tick = 15? (15x65.536ms = 1S)
		btfss	STATUS,Z
		goto	ISR_EXIT
		;comf	PORTB,f
		btfss	PORTB,7
		goto	LED_ON
LED_OFF
		bcf		PORTB,7
		goto	DONE
LED_ON	
		bsf		PORTB,7
DONE
		
		clrw
		movwf	count
		
ISR_EXIT
		bsf		INTCON,GIE		; re-enable global interrupt

		;*** context retrieving****
		POP
		
		retfie
		
;***** Initialization subroutine ************************

Init	movlw	.7
		banksel CMCON
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB
		movlw	B'00000001'
		movwf	TRISB		; PORTB are all output except RB0
		banksel	PORTB
		;******************** clear all related registers ********
		clrf	PORTB
		clrf	PORTA
		movlw	0x20		; the beginning of the general purpose register files
		movwf	FSR
		clrf	INDF
		incf	FSR,f
		movlw	0x80
		subwf	FSR,w
		btfss	STATUS,Z	; are we at the end of bank0 RAM yet?
		goto	$-5
		
		;****************** Timer 0 Initialization **************
		movlw	b'10000111'	; no RBPU, internal clock, PSA to timer0, 1:256, RB0INT falling edge
		bank1
		movwf	OPTION_REG	; OPTION_REG is in the BANK1 *****
		bank0
		bcf		INTCON,T0IF
		bsf		INTCON,T0IE	; enable Timer0 interrupt
		
		bcf		INTCON,INTF
		bsf		INTCON,INTE	; enable RB0/INT interrupt
		
		bsf		INTCON,GIE	; enable global interrupt
		clrf	TMR0
		return
;******* Initialization subroutine **********************

		
		END