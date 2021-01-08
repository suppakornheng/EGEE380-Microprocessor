;*******************************************
;**** LAB3 delay time Program title:  Running LEDS  ********
;**** Programmer: Mr. Chatchai   ***********
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
		ORG	0x00		; Reset Vector
		
		banksel	TRISB	; Switch to bank1
		clrw
		movwf	TRISB	; Make PortB an output port
		banksel PORTB	; Switch back to bank0
		movwf	PORTB	; Turn-off all LEDS
		
Main_loop:			; Main loop begins here 
		movlw	0x00	; clear file register 'temp'
		movwf	temp
Again:					; repeat this loop 8 times
		movf	temp,w		; use 'temp' to get a LED pattern from  
		call	LED_PATTERN	; LED_PATTERN look-up table
		movwf	PORTB		; move the obtained LED pattern to PORTB
		call	Delay800mS	; Delay for 0.8 second
		
		incf	temp,f		; increment 'temp' by one
		
		movf	temp,w	
		sublw	.8		; check if [temp] == 8 ?
		btfss	STATUS,Z
		goto	Again		; if 'no' repeat this loop again
		goto	Main_loop	; if 'yes' clear 'temp' back to zero

	
;******************** Subroutines *****************************

;========================================================
;* Running LED patterns using a look-up table
;========================================================
LED_PATTERN:
		addwf	PCL,F
		retlw	B'00000000'		; Pattern 0
		retlw	B'10000001'		; Pattern 1
		retlw	B'01000010'
		retlw	B'00100100'
		retlw	B'00011000'
		retlw	B'00100100'
		retlw	B'01000010'
		retlw	B'10000001'		; Pattern 7

;========================================================
; Delay subroutine for 0.8 second = 800000uS = 800000 cycles
;========================================================
Delay800mS:
		movlw	.255			; 1 cyc
		movwf	count1			; 1 cyc
loop1:
		movlw	.241				; 1 cyc * count1
		movwf	count0			; 1 cyc * count1
loop2:
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		nop						; 1 cyc * count1 * count0
		decfsz	count0,F    	; 1 cyc * count1 * count0
		goto	loop2			; 2 cyc * count1 * count0
		decfsz	count1,F    	; 1 cyc * count1
		goto	loop1			; 2 cyc * count1
		return					; 1 cyc
		; total = 3 + 5*count1	+ 13*count1*count0
		; count1 = 255
		; 800,000 = 3+5*255+13*255*count0
		; count0 = 240.94 = 241
		; 10 nop

		
		
		END