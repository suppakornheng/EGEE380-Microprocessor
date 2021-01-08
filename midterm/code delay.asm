;*******************************************
;code delay.asm
;*******************************************
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG	_CP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF
		
;Declare File register

;var1	EQU 0x30		
		CBLOCK	0x30 ; variable declaration แบบประกาศแค่ตัวแรก
			counter
		ENDC		; end cblock
		
		ORG	0x00	; reset vector
		GOTO START	; jump to start of the program
		
		ORG	0x04	; Interrupt vector
		
START:	; Start your program here
		; *** SUBLW K = K-W -> W
		; *** SUBWF f,d = F-W -> f(d=1), w(d=0)
	
		; P16F628 CPU CLOCK f=4MHz t=0.25 uS 
		; 4 clock = 1 machine cycle (บางที่เรียก instruction cycle) = 1uS
		; instruction cycle = 4/Fosc
		; Delay Time = #cycles x clock cycle time(1uS)
		; 			 = #cycles x 4/Fosc (frequency of PIC crystal = 4MHz)
	
;delay function
delay:
		movlw	.200		; 1 cycle
		movwf	counter		; 1 cycle	
loop1:		
		nop					; 1 cycle x200 (คูณ 200 เพราะ counter=200)
		nop					; 1 cycle x200
		nop					; 1 cycle x200 
		nop					; 1 cycle x200 
		decfsz	counter,F	; 1 cycle เว้นตอนท้ายที่มัน skip จะใช้ 2 cycle = 1x200+1 อันนี้ตอนสอบประมาณเป็น x1 ทั้งหมดเลยก็ได้
 		goto	loop1		; 2 cycle x199 (ตอนสุดท้ายที่มัน skip ไม่นับ) ; อันนี้ตอนสอบประมาณเป็น x2 ทั้งหมดเลยก็ได้
		return				; 2 cycle

							; total 1+1+800+201+398+2 = 1403 cycle 
							; 1403 cycle x 1uS = 1.403mS
							
		; เขียนเป็นสมการได้  delay time = (4+7*x)*CycleTime 
		;PIC16F628, CycleTime = 1uS
		;เช่นให้สร้างโปรแกรม delay 200uS
		; 200uS = (4+7*x)*1uS
		; x = (200-4)/7 = 28

;delay nested loop function
delay_nested:
		movlw	.x			; 1 cycle
		movwf	counter1	; 1 cycle
outer_loop:
		movlw	.y			; 1 cycle x counter1
		movwf	counter2	; 1 cycle x counter1
inner_loop:					
		nop					; 1 cycle x counter1 x counter2
		nop					; 1 cycle x counter1 x counter2
		decfsz	counter2,F	; 1 cycle x counter1 x counter2
		goto 	inner_loop	; 2 cycle x counter1 x counter2
		decfsz	counter1	; 1 cycle x counter1
		goto	outer_loop	; 2 cycle x counter1
		return				; 2 cycle
		
		;ให้ x=counter1, y=counter2
		;เขียนเป็นสมการได้ delay time = (4+5*x+5*x*y)*CycleTime
		;สมการสองตัวแปรต้องใช้สองสมการในการแก้ ในกรณีนี้เราต้องสมมุติค่าตัวใด้ตัวนึงขึ้นมา
		;ตัวแปรมีขนาด 8 bit ค่าสูงสุดที่เก็บได้คือ 255 
		;เลขที่สุ่มต้องมีค่าไม่เกิน 255
		;โจทย์ ให้สร้าง delay time = 10mS, CycleTime = 1uS
		; assume x=100
		; 10mS = 10000uS = (4+5*x+5*x*y)*1uS
		; 10000uS = (4+5*100+5*100*y)*1uS
		; 10000 = 500y+504
		; y = 18.992
		; ใช้ y = 19
		
		END

		