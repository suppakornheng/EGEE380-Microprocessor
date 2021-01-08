;*******************************************
;**** Program title:  Simple Digital Clock  ***********
;**** Programmer:                           ***********
;******************************************

		PROCESSOR PIC16F627A
		#include <P16F627A.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
;                                                                             ^
;																			  |
;																culprit, why simulation
;                                                               didn't work (last lecture)
		
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
		goto	TMR0_ISR	; vector to interrup service routine

Mymain
		call	Init
Here
		goto	Here
		
		
;***** Timer0 Interrupt Service Routine *****************
TMR0_ISR
		;*** context saving ******
		;PUSH
		movlw	D'238'
		movwf	TMR0
		;*** TMR0 ISR begins here ****
		bcf		INTCON,T0IF
		comf	PORTB,f
		;*** context retrieving****
		;POP
		
		retfie
		
;***** Initialization subroutine ************************

Init	movlw	.7
		banksel CMCON
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB
		movlw	0x00
		movwf	TRISB		; PORTB are all output
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
		bank1
		movlw	b'00001000'	; yes RBPU, internal clock, PSA to WDT, 1:1
		movwf	OPTION_REG	; OPTION_REG is in the BANK1 *****
		bank0
		bcf		INTCON,T0IF
		bsf		INTCON,T0IE	; enable Timer0 interrupt
		bsf		INTCON,GIE	; enable global interrupt
		movlw	D'231'
		movwf	TMR0
		return
;******* Initialization subroutine **********************

		
		END