;*******************************************
;interrupt_generates_square_wave_vary_duty_cycle.asm
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
;generates square wave, T=200uS, f=5KHz, duty 75%
;on 150uS -> 150 cycle -> TMR0 Rate 1:1 ->  Timer0 = 256-150 = 106
;off 50uS -> 50 cycle -> TMR0 Rate 1:1 -> Timer0 = 256-50 = 206

;if T=400uS, 2.5KHz -> need 1:2 prescaler, duty 75%
;on 300uS -> 300 cycle -> TMR0 Rate 1:2 ->  Timer0 = 256-(300/2) = 106
;off 100uS -> 300 cycle ->TMR0 Rate 1:2 -> Timer0 = 256-(100/2)= 206
;movlw B'0000 0000'
;movwf OPTION_REG

;exam may change clock frequency
;clock 8MHz, 1cycle=0.5uS
;generates square wave, T=200uS, f=5KHz, duty 75%
;on 150uS -> 300 cycle -> TMR0 Rate 1:1 ->  Timer0 = 256-300 = can't, need prescaler 1:2
;off 50uS -> 100 cycle -> TMR0 Rate 1:1 -> Timer0 = 256-100 = 156

;if T=200uS, 5KHz -> 1:2 prescaler, duty 75%
;on 150 -> 300 cycle -> TMR0 Rate 1:2 ->  Timer0 = 256-(300/2) = 106
;off 50uS -> 100 cycle ->TMR0 Rate 1:2 -> Timer0 = 256-(100/2)= 206
;movlw B'0000 0000'
;movwf OPTION_REG


TMR0_ISR:
		PUSH					; 8 cycles
		bcf		INTCON,T0IF		; clear Timer0 interrupt flag
;--------toggle long code for any% duty only-----------------
		btfss 	PORTB,7
		goto	set_hi
set_low:bcf		PORTB,7
		movlw 	.206			; 
		movwf	TMR0			; off period
		goto	set_done
set_hi: bsf		PORTB,7		
		movlw 	.106			;
		movwf	TMR0			; on period
set_done:			
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
		movlw	.106		; on period
		movwf	TMR0		; set TMR0 = 156
		bsf		INTCON,GIE	; enable global interrupt *enable GIE should be the last code line (dunno why)
		;---End Interrupt Config---
		;---Option Config---
		banksel	OPTION_REG
		movlw	B'00001000'	; TMR0 Rate 1:1
		;movlw	B'00000000'	; TMR0 Rate 1:2
		;movlw	B'00000001'	; TMR0 Rate 1:4
		;movlw	B'00000010'	; TMR0 Rate 1:8
		;movlw	B'00000011'	; TMR0 Rate 1:16
		;movlw	B'00000100'	; TMR0 Rate 1:32
		;movlw	B'00000101'	; TMR0 Rate 1:64
		;movlw	B'00000110'	; TMR0 Rate 1:128
		;movlw	B'00000111'	; TMR0 Rate 1:256
		movwf	OPTION_REG
		banksel PORTB
		;---End Option Config---
		clrf	PORTB
		return
		
		END
