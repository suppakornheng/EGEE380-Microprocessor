;*******************************************
;If condition มากกว่า น้อยกว่า เท่ากับ.asm
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
		
;Declare File register

;var1	EQU 0x30		
		CBLOCK	0x30 ; variable declaration แบบประกาศแค่ตัวแรก
			x
			y
		ENDC		; end cblock
		
		ORG	0x00	; reset vector
		GOTO START	; jump to start of the program
		
		ORG	0x04	; Interrupt vector
		
START:	; Start your program here
		; *** SUBLW K = K-W -> W
		; *** SUBWF f,d = F-W -> f(d=1), w(d=0)
		
		;					Carry Flag Bit		Zero Flag Bit
		;	operand>wreg		1					0
		;	operand==wreg		1					1
		;	operand<wreg		0					0
		;	operand = ตัวตั้ง
		;	wreg = ตัวลบ
		
;check if x=0?
		MOVF	x,F	;ถ้า x=0 zero flag จะเท่ากับ 1
		BTFSS	STATUS,Z ; x=0 -> z=1 ->BTFSS ข้ามบรรทัดถัดไป
		GOTO	NO_X_IS_NOT_ZERO
		GOTO	TRUE_X_IS_ZERO
;check if x=20?
		MOVF	x,W
		SUBLW	.20
		BTFSC	STATUS,Z	;BTFSC จะตรงข้ามกับ BTFSS
		GOTO	YES_X_IS_20
		GOTO	NO_X_IS_NOT_20
;check if x=y?
		MOVF	y,W	; do w=y
		SUBWF	x,W	; do w=x-w
		BTFSS	STATUS,Z
		GOTO	NO_X_NOT_EQ_Y
		GOTO	TRUE_X_EQ_Y
;check if x<y?
		MOVF	y,W	;w=y
		SUBWF	x,W	;w=x-w
		BTFSC	STATUS,Z	;z=1 มี case เดียวคือ x=y
		GOTO	NO ;หรือX_EQ_Y ;หรือ X_NOT_LT_Y	; LT=less than
		BTFSS	STATUS,C	; ถ้า carry=1 = x>y = ข้ามบรรทัดถัดไป
		GOTO	YES			; บรรทัดนี้ไม่ถูกข้าม ก็คือ x<y
		GOTO	NO
;check if x<=y?
		MOVF	y,W
		SUBWF	x,W
		BTFSC	STATUS,Z	
		GOTO	YES
		BTFSS	STATUS,C	
		GOTO	YES			
		GOTO	NO
;check if x>y? = if y<=x? 
		MOVF	x,W		; สลับ x กับ y
		SUBWF	y,W		; สลับ x กับ y
		BTFSC	STATUS,Z	
		GOTO	YES
		BTFSS	STATUS,C	
		GOTO	YES			
		GOTO	NO
;check if x>y? = if y<=x? ->เหมือนกันแต่ทำ y-x 
		MOVF	y,W
		SUBWF	x,W
		BTFSC	STATUS,Z	
		GOTO	NO
		BTFSC	STATUS,C	
		GOTO	YES			
		GOTO	NO
		
		END

		