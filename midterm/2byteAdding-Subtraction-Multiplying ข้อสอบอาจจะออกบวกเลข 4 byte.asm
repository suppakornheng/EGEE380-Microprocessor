;*******************************************
;2byteAdding-Subtraction-Multiplying ข้อสอบอาจจะออกบวกเลข 4 byte.asm
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
		
;Declare File register

;var1	EQU 0x30		
		CBLOCK	0x30 ; variable declaration แบบประกาศแค่ตัวแรก
			xH
			xL
			yH
			yL
			mulA
			mulB
			resH
			resL
		ENDC		; end cblock
		
		ORG	0x00	; reset vector
		GOTO START	; jump to start of the program
		
		ORG	0x04	; Interrupt vector
		
START:	; Start your program here
		; *** SUBLW K = K-W -> W
		; *** SUBWF f,d = F-W -> f(d=1), w(d=0)
		; xH:xL = 3AH : 1BH = 3A1BH
		MOVLW 3AH
		MOVWF xH
		MOVLW 1BH
		MOVWF xL
		; yH:yK = 1000H
		MOVLW 10H
		MOVWF yH
		MOVLW 00
		MOVWF yL
		
		CALL add2b
		JMP	 START
		
add2b:
		MOVF yL,W
		ADDWF xL,File
		BTFSC STATUS,C	; check carry flag 
		INCF yH,F
		MOVF yH,w
		ADDWF xH,F
		RETURN
		
sub2b:
		MOVF	yL,W
		SUBWF	xL,F
		BTFSS	STATUS,C
		INCF	yH,F	; หรือจะใช้ DECF xH,F แทนก็ได้
		MOVF	yH,w
		SUBWF	xH,F
		RETURN
		
;		MOVLW	.100
;		MOVWF	mulA	; multiplicand
;		MOVLW	.22
;		MOVWF	mulB	; multiplier
;		call	mul1B	; multiplication result is resH:resL

mul1b:	;result is 2 byte = maximum = 65535 ;2^16 = 65536 = 0-65535
		CLRW	
		MOVWF	resH
		MOVWF	resL
mloop:
		MOVWF	mulA,W
		ADDWF	resL,F
		BTFSC	STATUS,C
		INCF	resH,F
		DECFSZ	mulB,F
		GOTO	mloop1
		RETURN
		
		END
		
		