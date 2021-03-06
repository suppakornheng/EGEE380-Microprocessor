; **** USART Module : Polling Transmission
;================================================
; DEFINITIONS
;================================================
		PROCESSOR PIC16F628
		#include <P16F628.INC>
		__CONFIG _CP_OFF & _MCLRE_ON & INTRC_OSC_NOCLKOUT & _LVP_OFF &_WDT_OFF
#define	NL	0x0A	; New Line
#define	FF	0x0C	; Form feed
#define	CR	0x0D	; Carriage return
		
;================================================
; VARAIBLES
;================================================
		cblock	0x20
			count
			count0
			count1
			count2
			temp
			buffer
			index
		endc
;================================================
; RESET and INTERRUPT VECTORS
;================================================
		ORG 	0x00
		goto	main
		ORG		0x04
		goto	usart_RX_ISR
		
main:	call	init
		movlw	0x00
		movwf	index
		call	send_message
inf_loop:
		nop	
		goto	inf_loop

;Serial Comm Rx interrupt ISR
usart_RX_ISR:
EXT_INT:btfss	INTCON,INTF
		goto	serial_ISR
		bcf		INTCON,INTF
		movlw 	B'00000100'
		xorwf	PORTA,f
		goto	ISR_exit
serial_ISR:
		btfss	PIR1,RCIF
		goto	ISR_exit	; get out if not the receive interrupt
		movf	RCREG,w		; RCIF flag is cleared if RCREG is read
		movwf	buffer
LED0:	movlw	'0'
		subwf	buffer,w
		btfss	STATUS,Z
		goto	LED1
		movlw	0x00
		movwf	PORTA
		bsf		PORTA,0
		goto	ISR_exit
LED1:	movlw	'1'
		subwf	buffer,w
		btfss	STATUS,Z
		goto	LED2
		movlw	0x00
		movwf	PORTA
		bsf		PORTA,1
		goto	ISR_exit
LED2:	movlw	'2'
		subwf	buffer,w
		btfss	STATUS,Z
		goto	LED3
		movlw	0x00
		movwf	PORTA
		bsf		PORTA,2
		goto	ISR_exit
LED3:	movlw	'3'
		subwf	buffer,w
		btfss	STATUS,Z
		goto	ISR_exit
		movlw	0x00
		movwf	PORTA
		bsf		PORTA,3
ISR_exit:
		retfie

send_message:
		movf	index,w
		call	message		; get character from the message table
		movwf	buffer
		
		movlw	.100
		call	DelaymS
		
		movlw	0xFF
		subwf	buffer,w	; check if we are at the end of message?
		btfsc	STATUS,Z
		return
		incf	index,f
TX:		btfss	PIR1,TXIF	; TXIF='1' if the TXREG is empty
		goto	TX
		movf	buffer,w
		movwf	TXREG
		goto	send_message ; go back and do it again
	
message:
		addwf	PCL,f
		DT		FF,NL,"EGEE 380 Serial Communication Example",NL,CR
		DT		"at 2400 baud rate speed ...........:-)",NL,CR
		DT		"Press keys [0,1,2,3] to turn-on LEDs",NL,CR,0xFF
	
init:
		;Initialization of USART module
		banksel	CMCON
		movlw	.7
		movwf	CMCON	; disable analog comparator
		banksel	TRISA
		movlw	0x00
		movwf	TRISA
;++++++++++++++++++++++++++++++++++++
		banksel INTCON
		bsf		INTCON,INTE
		bcf		INTCON,INTF	; External interrupt clear
		
		banksel	OPTION_REG
		bsf		OPTION_REG,INTEDG
		
; Bits 1 and 2 of Port B are multiplexed as TX/CK and RX/DT for USART operation. 
; These bits must be set to input in the TRISB register.
		bsf		TRISB,2	; RB2 as input (Tx pin)
		bsf		TRISB,1	; RB1 as input (Rx pin)
		
; The asynchronous baud rate(ABR) is calculated as follows:
;	ABR = Fosc/{S*(x+1)}
; x is value in SPBRG register.
; S is 64 if high baud rate select bit(BRGH) in the TXSTA control register is clear (slow-speed baud rate).
; S is 16 if the  BRGH bit is set (high-speed baud rate).
; For setting to 9600 baud rate using a 4MHz oscillator at a high-speed baud rate the formula is:
; At high speed (BRGH=1)
; 9600 = 4,000,000/{16*(x+1)}
; x = 25.041 -> use x=25
; calculate baud rate from x=25 to find %error
; baud rate = 4,000,000/{16*(25+1)} = 9,615 (0.16% error)
; At slow speed (BRGH=0)
; baud rate = 4,000,000/{64*(25+1)} = 2,403.85 (0.16% error)
;

		banksel	SPBRG
		movlw	.25		; 2400 baud rate at 4MHz crystal
		movwf	SPBRG	; Place in baud rate generator
; TXSTA (Transmit Status and Control Register) bit map:
;	7	6	5	4	3	2	1	0	<== bits
;	|	|	|	|	|	|	|	|______ Tx9D 9nth data bit on
;	|	|	|	|	|	|	|			(used for parity)
;	|	|	|	|	|	|	|__________ TRMT Transmit Shift Register
;	|	|	|	|	|	|				1 = TSR empty
;	|	|	|	|	|	|			  * 0 = TSR full
;	|	|	|	|	|	|______________ BRGH High Speed Baud Rate
;	|	|	|	|	|					(Asynchronous mode only)
;	|	|	|	|	|					1 = high speed (*4)
;	|	|	|	|	|				  * 0 = low speed
;	|	|	|	|	|______________ NOT USED
;	|	|	|	|__________________ SYNC USART Mode Select
;	|	|	|					 	1 = synchronous mode
;	|	|	|					  * 0 = asynchronous mode
;	|	|	|______________________ TXEN Transmit Enable
;	|	|						  * 1 = transmit enable
;	|	|						    0 = transmit disable
;	|	|__________________________ TX9 Enable 9-bit Transmit
;	|							    1 = 9-bit transmission mode
;	|							  * 0 = 8-bit mode
;	|______________________________ CSRC Clock Source Select
;								 	Not used in asynchronous mode
;									Synchronous mode:
;									   1 = Master Mode (internal clock)
;									 * 0 = Slave Mode (external clock)
; Setup value = 0010 0000 = 0x20
		banksel	TXSTA	; TXEN = '1', BRGH = '0'
		movlw	0x20	; Enable transmission and low speed baud rate
		movwf	TXSTA
; RCSTA (Receive Status and Control Register) bit map:
;	7	6	5	4	3	2	1	0	<== bits
;	|	|	|	|	|	|	|	|______ RX9D 9th data bit received
;	|	|	|	|	|	|	|			(can be parity parity)
;	|	|	|	|	|	|	|__________ OERR Overrun error
;	|	|	|	|	|	|				1 = error clear by software
;	|	|	|	|	|	|______________ FERR Framing error
;	|	|	|	|	|					1 = error
;	|	|	|	|	|______________ NOT USED
;	|	|	|	|__________________ CREN Continuous Receive Enable
;	|	|	|							Asynchronous mode
;	|	|	|							 * 1 = Enable continuous receive
;	|	|	|					  		   0 = Disable continuous receive
;	|	|	|							Synchronous mode
;	|	|	|							   1 = Enables until CREN cleared
;	|	|	|					  		   0 = Disables continuous receive
;	|	|	|_______________________ SREN Single Receiver Enable
;	|	|						  		Asynchronous mode = don't care
;	|	|								Synchronous mode
;	|	|								   1 = Enables single receiver
;	|	|						  		   0 = Disables single receiver
;	|	|___________________________ RX9  9-bit Receive Enable
;	|							       1 = 9-bit reception
;	|							     * 0 = 8-bit reception
;	|_______________________________ SPEN Serial Port Enable
;									 * 1 = RX/DT and TX/CK are serial pins
;									   0 = Serial port disable
; Setput value: 1001 0000 = 0x90
		banksel	RCSTA	; Bank 0
		movlw	0x90	; Enable Serial port and continous reception
		movwf	RCSTA
; Setting up interrupt control registers
		banksel INTCON
		bsf		INTCON,PEIE	; Enable peripheral interrupt (serial port)
		bsf		INTCON,GIE	; Enable global interrupt
		
		banksel	PIE1
		bsf		PIE1,RCIE	; Enable only receiving interrupt
		
		banksel PIR1		; Bank 0
		bcf		PIR1,RCIF	; Clear receive interrupt flag
		
		movlw 	0x00
		movwf	PORTA		; Turn-off all LEDs
		return
		
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
;================================================		
		END