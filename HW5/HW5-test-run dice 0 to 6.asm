;*******************************************
;HW5-test-run dice 0 to 6.asm
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

		movlw	.7
		banksel CMCON
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB
		movlw	0x00
		movwf	TRISB		; Set PORTB as an output port
		banksel	PORTB
		
		clrf	PORTB
		clrf	temp
L1:
		movf	temp,w		;use [Temp] to call 'Table7seg'
		call	DICE_FACES
		movwf	PORTB		;Send the obtain 7 seg pattern to PORTB
		
		call	Delay500mS
		
		incf	temp,f		;[temp] = [temp] + 1
		
		movlw	.7		;
		subwf	temp,w		
		btfss	STATUS,Z	;check if temp=8?
							;we want to display total of 16 patterns
		goto	L1			;No, go back and do it again
		
		clrf	temp		;Yes, clear 'temp' back to zero
		goto	L1			;Repeat the infinite loop
		
;Loopup table for 7segments LED Patterns
DICE_FACES:
		addwf	PCL,F
		;RB 	  76543210
		retlw	B'00000000'		;Number0
		retlw	B'00001000'		;Number1
		retlw	B'00100010'		;Number2
		retlw	B'00101010'		;Number3
		retlw	B'01100011'		;Number4
		retlw	B'01101011'		;Number5
		retlw	B'01110111'		;Number6


DelaymS:
		movwf	count2
		incf	count2,f
		decfsz	count2,f
		goto	$+2
		goto	$+3
		call	Delay1mS
		goto	$-4
		return
		
Delay1mS:
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
		
Delay500mS:
		movlw .250;
		call  DelaymS;
		movlw .250;
		call  DelaymS;
		return
		
		END
