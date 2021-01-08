;*******************************************
;**** lab5 up down switch to 7 segment -> bounce
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
		endc
		
		ORG 0x00		;reset vector
		goto	main	;vector to main program

		
main:
		call	Init
		
L1:
		btfsc	PORTA,0		; is UP pressed?
		goto	L2
		
		incf	temp,f
		
L2:		btfsc	PORTA,1		; is DOWN pressed?
		goto	L3
		
		decf	temp,f
		
L3		movlw	.16
		subwf	temp,w		
		btfss	STATUS,Z	;check if temp=16?
		goto	L4		;No,check zero
		
		clrf	temp		;Yes, clear 'temp' back to zero
		goto	L5			;Repeat the infinite loop
		
L4:		
		movlw	.255
		subwf	temp,w		
		btfss	STATUS,Z	;check if temp=255?
		goto	L5			;No, go back and do it again
		
		movlw	.15
		movwf	temp		;yes, set temp = 16
		goto	L5			;Repeat the infinite loop		
		
		
L5:		movf	temp,w		;use [Temp] to call 'Table7seg'
		call	Table7seg
		movwf	PORTB		;Send the obtain 7 seg pattern to PORTB
		
		movlw	.250
		call 	DelayMS
		
		goto	L1
		
		
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
		movlw	.50				; 1 cyc
		movwf	count1			; 1 cyc
outterloop:
		movlw	.5				; 1 cyc * count1
		nop						; 1 cyc * count1
		movwf	count0			; 1 cyc * count1
innerloop:
		decfsz	count0,F    	; 1 cyc * count1 * count0
		goto	innerloop		; 2 cyc * count1 * count0
		decfsz	count1,F    	; 1 cyc * count1
		goto	outterloop		; 2 cyc * count1
		return					; 1 cyc
		; total = 3 + (6+3.count0).count1
		; count0 = 5 , count1 = 50, total = 1053 cyc

; Time delay subroutine for 1.[W] seconds by calling DelayMS subroutine
DelayS:
		movwf	temp1
delays_1:
		movlw	.250
		call	DelayMS
		movlw	.250
		call	DelayMS
		movlw	.250
		call	DelayMS
		movlw	.250
		call	DelayMS
		decfsz	temp1,f
		goto	delays_1
		return
		
Init:	
		movlw	.7
		banksel CMCON
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB
		movlw	0x00
		movwf	TRISB		; Set PORTB as output ports
		movlw	0xFF
		movwf	TRISA		; Set PORTA as input ports
		banksel	PORTB
		clrf	PORTB
		clrf	temp
		return
		
		END
		
		
		
		
		
		