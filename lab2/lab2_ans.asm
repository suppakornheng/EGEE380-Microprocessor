;*******************************************
;**** lab2.asm  Running LEDS  ********
;*******************************************

		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_OFF & _HS_OSC & _LVP_OFF & _WDT_OFF

;****** Define general purpose registers for temporary variables
		cblock 	0x20
			temp
			count
			count0
			count1
			count2
		endc
;***********************************************************
		ORG	0x00		; Reset Vector
		goto	Mymain		; vector to main program
		
Mymain:					; Main program begins here

		call	Init
		
		clrf	PORTB
		bsf	PORTB,0
		clrf	temp
		bsf	temp,0

Inf_Loop:
		movlw	.7		; Setting the loop counter 'count'
		movwf	count
		
		
LeftLoop:				; Rotate LED pattern to the left
		rlf	temp,f
		;movf	temp,w
		comf	temp,w	; complement temp ดับ 1 วิ่ง ที่เหลือติด
		movwf	PORTB
		movlw	.100
		call	DelayMS
		decfsz	count,f		; repeat the loop 7 times
		goto	LeftLoop

		movlw	.7		; Setting the loop counter 'count'
		movwf	count
RightLoop:				; Rotate LED pattern to the right
		rrf	temp,f
		;movf	temp,w
		comf	temp,w	; complement temp ดับ 1 วิ่ง ที่เหลือติด
		movwf	PORTB
		movlw	.100
		call	DelayMS
		decfsz	count,f		; repeat the loop 7 times
		goto	RightLoop
		
		goto	Inf_Loop	; Go back and repeat this loop
	
;******************** Subroutines *****************************

;========================================================
;* Initialization subroutine 
;========================================================
Init:	
		movlw	.7
		banksel CMCON
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB
		movlw	0x00
		movwf	TRISB		; Set PORTB as an output port
		banksel	PORTB
		return

;=======================================================
;* Delay 2 Routine - Decrement delay loop in Milisecond*
;* 1 instruction cycle is 1 micro-second 
;* at 4 Mhz X'tal frequency, 1MS = 1000 uS = 100x10
;* where 100 iterations for inner loops, 10 iterations for
;* outter loops
;******************************************
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