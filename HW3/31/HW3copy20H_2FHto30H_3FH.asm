;*************************************************************
;**** Program title: HW3.1 COPY 20H-2FH to 30H-3FH ***********
;**** Programmer: SUPPAKORN HENGPRASITH 5913370    ***********
;*************************************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
		
;Declare File register
counter	EQU	40H
value	EQU	41H
source	EQU 42H
destination	EQU	43H
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
		
; HW3 Move 20-2F to 30-3F
		movlw	.16		; set w = 16
		movwf	counter	; set counter =16
		movlw	20H		; set w = 20H
		movwf	source	; set source = 20H
		movlw 	30H		; set w = 30H
		movwf 	destination	; set destination = 30H
			
AGAIN2:  
		movf	source,w	
		movwf	FSR	
		movf	INDF,w	
		movwf	value	
		movf	destination,w	
		movwf	FSR		
		movf 	value,w		
		movwf	INDF		
		incf	source,f		
		incf	destination,f	
		decfsz	counter,f		
		goto 	AGAIN2
		END
		