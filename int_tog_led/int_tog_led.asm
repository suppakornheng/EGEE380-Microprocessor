;*******************************************
;int_tog_led interrupt toggle led
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
		goto EXT_ISR		;exit Interrupt Service Routine

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

		POP	MACRO				
		SWAPF	STATUS_temp,w
		MOVWF	STATUS
		banksel	TRISA		;	select bank1
		swapf	OPTION_REG_temp,w
		movwf	OPTION_REG
		banksel	PORTA		;	select bank0
		swapf	w_temp,w
		ENDM		
;---end push pop---		

main:
		;---Port Config---
		movlw	.7
		banksel CMCON		; select Bank0 (CMCON อยู่ Bank0)
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB		; select Bank1
		bcf		TRISA,0		; Port RA0 is an output pin
		bsf		TRISB,0		; Port RB0 is an input pin
		banksel	PORTB		; select Bank0
		;---End Port Config---
		;---Interrupt Config---
		bsf		INTCON,GIE	; enable global interrupt
		bsf		INTCON,INTE	; enable external interrupt, INT = external interrupt, E=enable
		bcf		INTCON,INTF	; clear external interrupt flag , F = flag
		;; Or using movlw instead of bsf, bcf
		;;	 BIT: 7654 3219	
		;movlw	B'1001 0000'; GIE(bit7), INTE(bit4)
		;movwf	INTCON		;
		;---End Interrupt Config---
		;---Option Config---
		banksel	OPTION_REG
		bcf		OPTION_REG,INTEDG; INTEDG=0 interrupt on falling edge of RB0/INT pin
		;bsf	OPTION_REG,INTEDG; INTEDG=1 interrupt on rising edge of RB0/INT pin
		;---End Option Config---
		banksel	PORTA		; select Bank0 (can use CMCON instead of PORTA)
		
inf_loop:
		goto inf_loop
		

;---interrupt---	
EXT_ISR:
		PUSH
		bcf		INTCON,INTF
		btfss	PORTA,0
		goto	SET_ON
SET_OFF:
		bcf		PORTA,0
		goto	SET_DONE
SET_ON:	bsf		PORTA,0
SET_DONE:
		POP
		RETFIE
;---end interrupt---	



		END
