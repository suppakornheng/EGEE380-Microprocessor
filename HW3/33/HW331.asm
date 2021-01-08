;*******************************************
;swap 20H with 2FH, 21F with 2EH, ....
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
		
;Declare File register
counter	EQU	40H
value	EQU	41H
source	EQU 42H
destination	EQU	43H
value2	EQU 44H
		ORG	0x00	; reset vector
		GOTO START	; jump to start of the program
		
		ORG	0x04	; Interrupt vector
		
START:
; SET 20-2F to 0-F
		movlw	20H
		movwf	FSR
		clrw			; clrw = movlw 0H
		movwf	value	; set value = w = 0
		movlw	.16		; set w = 16
		movwf	counter	; set counter =16
		
AGAIN1:  movf	value,w
		movwf	INDF
		incf	value,f
		incf	FSR,f
		decfsz	counter,f
		goto	AGAIN1
		
; HW331 SWITCH 20H and 2FH, 21H and 2EH and so on
; Method a=a+b >> b=a-b >> a=a-b ;can't because can't access a and b at the same time
; Method value=a >> a=b >> b=value ;can't because can't access a and b at the same time
; Method value=a >> value2=b >> b=value >> a= value2
		movlw	.8		; set w = 8
		movwf	counter	; set counter =8
		movlw	20H		; set w = 20H
		movwf	source	; set source = 20H
		movlw 	2FH		; set w = 2FH
		movwf 	destination	; set destination = 2FH
			
AGAIN2:  
		;value=a
			;read a
		movf	source,w	
		movwf	FSR
		movf	INDF,w	
			;value=a
		movwf	value	
		
		;value2=b
			;read b
		movf	destination,w
		movwf	FSR
		movf	INDF,w
			;value2=b
		movwf	value2
				
		;b=value
		movf	value,w
		movwf	INDF
		
		;a=value2
			;select a
		movf	source,w	
		movwf	FSR
			;a=value2
		movf	value2,w	
		movwf	INDF	
		
		incf	source,f		
		decf	destination,f	
		decfsz	counter,f		
		goto 	AGAIN2
		END
		