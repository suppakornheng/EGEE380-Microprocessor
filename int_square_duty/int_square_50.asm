;*******************************************
;interrupt_generates_square_wave_50%_duty_cycle.asm
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_OFF & _HS_OSC & _LVP_OFF & _WDT_OFF

		cblock 	0x20
			temp
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
		goto main
	
		ORG	0x04		;interrupt vector
		goto TMR0_ISR		;exit Interrupt Service Routine

;---push pop---	
		PUSH 	MACRO
		movwf	w_temp		;	w_temp = w
		swapf	w_temp,f 	;	swap them, ใช้ swap เพราะ movf มีโอกาสที่จะไปเปลี่ยน zero flag ใน status register
		banksel	TRISA		;	select bank1
		swapf	OPTION_REG,w;	w= OPTION_REG
		movwf	OPTION_REG_temp;OPTION_REG_temp= w
		banksel	PORTA		;	select bank0
		swapf	STATUS,W	;	w= STATUS
		MOVWF	STATUS_temp	;	STATUS_temp= w
		ENDM
		;PUSH uses 8uS

		POP	MACRO				
		SWAPF	STATUS_temp,w
		MOVWF	STATUS
		banksel	TRISA		;	select bank1
		swapf	OPTION_REG_temp,w
		movwf	OPTION_REG
		banksel	PORTA		;	select bank0
		swapf	w_temp,w
		ENDM		
		;POP uses 7uS
		;push+pop = 15uS
;---end push pop---		

main:
		call init
foreground_task:
		nop
		nop
		nop
		goto foreground_task

;---interrupt---	
;clock 4MHz, 1cycle=1uS
;generates square wave, T=200uS, f=5KHz, duty 50%
;on 100uS, off 100uS -> Timer0 = 256-100 = 156


TMR0_ISR:
		PUSH					; 8 cycles
		bcf		INTCON,T0IF		; clear Timer0 interrupt flag
		movlw 	.156
		movwf	TMR0			; reload for another 100uS period
;--------toggle with xor for 50% duty only-----------------
		movlw	B'10000000'		; w='10000000'
		xorwf	PORTB,F			; xor=toggle
;--------end toggle with xor for 50% duty only------------------
;--------toggle with complement for 50% duty only------------------
		;comf	PORTB,F	
;--------end toggle with complement for 50% duty only------------------
;--------toggle long code for any% duty only-----------------
;		btfss 	PORTB,7
;		goto	set_hi
;set_low:bcf		PORTB,7
;		goto	set_done
;set_hi: bsf		PORTB,7		
;set_done:			
;--------end toggle long code for any% duty only-----------------		
		POP						; 7 cycles
		RETFIE
;---end interrupt---	



init:
		;---Port Config---
		;CMCON is not necessary if PORTA isn't used
		banksel	TRISB		; select Bank1
		bcf		TRISB,7		; Port RB0 is an output pin (bcf=0=output, bsf=1=input)
		banksel	PORTB		; select Bank0
		;---End Port Config---
		;---Interrupt Config---
		bsf		INTCON,T0IE	; enable timer0 interrupt
		bcf		INTCON,T0IF	; clear timer0 interrupt flag
		movlw	.156		; reload value for 100uS interrupt period
		movwf	TMR0		; set TMR0 = 156
		bsf		INTCON,GIE	; enable global interrupt *enable GIE should be the last code line (dunno why)
		;---End Interrupt Config---
		;---Option Config---
		banksel	OPTION_REG
		movlw	B'00001000'
		movwf	OPTION_REG
		banksel PORTB
		;---End Option Config---
		clrf	PORTB
		return
		
		END
