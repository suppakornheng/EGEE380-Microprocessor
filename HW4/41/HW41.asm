;*******************************************
;HW41 ไฟวิ่งซ้ายไปขวา แล้วขวามาซ้าย
;*******************************************		
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_OFF & _HS_OSC & _LVP_OFF & _WDT_OFF

		cblock 	0x20
			temp
			count
			count0
			count1
			count2
		endc
		ORG 0x00
		;init
		movlw	.7
		banksel CMCON
		movwf	CMCON		; Disable analog comparator
		banksel	TRISB
		movlw	0x00                                                                                                                  
		movwf	TRISB		; Set PORTB as an output port
		banksel	PORTB	
		clrf	PORTB
		clrf	temp
		bsf	temp,0
Infloop:		
		movlw	.7		
		movwf	count	
LeftLoop:				
		rlf		temp,f
		;comf	temp,w	; the run led off, the left leds on
		movf	temp,w	; the run lef on, the left leds off
		movwf	PORTB
		call	Delay500mS
		decfsz	count,f		
		goto	LeftLoop	
		movlw	.7		
		movwf	count	
RightLoop:		
		rrf		temp,f
		;comf	temp,w	; the run led off, the left leds on		
		movf	temp,w	; the run lef on, the left leds off
		movwf	PORTB
		call	Delay500mS
		decfsz	count,f		
		goto	RightLoop
		goto 	Infloop


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

		
		