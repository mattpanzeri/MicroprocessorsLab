	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message, LCD_Clear, LCD_DDRAM, LCD_Write_from_PM, LCD_Send_Byte_D	 ; external LCD subroutines
	extern	delay8, delay16, delay24	    ; external delay subroutines
	extern  m8x24, m8x24_in, m8x24_out, m8x24_m ;external multiplication 8x24
	extern	m16x16, m16x16_xh, m16x16_xl, m16x16_yh, m16x16_yl
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
temp	    res 1   ; reserve a byte
nibble_high res 1   ; read high nibble
nibble_low  res 1   ; read high nibble
 
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello World!!!!"	; message, plus carriage return
	constant    myTable_l=.15	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	
	; ******* Write bank 3 with OxFF *******************************
	clrf	counter
	lfsr	FSR0, 0x300	    ; start from bank3 at 0x00
	movlw	0xFF		    ; write 1st value
wloop	incf	counter, F, ACCESS	    ; increment counter
	movwf	POSTINC0	    ; write counter to FSR, with postincrement
	cpfseq	counter, ACCESS	    ; if equal, skip ahead, if not, loop
	bra	wloop
	movwf	POSTINC0
	
	call	create_lookup
	; ****** activate pull-up resistors PORTE, clear LATE
	banksel	PADCFG1		    ; compiler finds correct bank
	bsf	PADCFG1, REPU, BANKED	; activate PORTE pull up resistors 
	movlb	0x00		    ; set BSR back to 0
	clrf	LATE
	clrf	TRISH
	goto	start
	
	
	; ******* Main programme ****************************************	
start 	movlw	0x0A
	movwf	m8x24_m, ACCESS
	lfsr	FSR1, m8x24_in
	movlw	0x34
	movwf	POSTINC1, ACCESS
	movlw	0xEB
	movwf	POSTINC1, ACCESS
	movlw	0x3B
	movwf	POSTINC1, ACCESS
	
	call	m8x24
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	
	movlw	0xFF
	call	delay24
	call	LCD_Clear
	
	
	call	m16x16
	movlw	0x04
	movwf	m16x16_xh, ACCESS
	movlw	0xD2
	movwf	m16x16_xl, ACCESS
	movlw	0x41
	movwf	m16x16_yh, ACCESS
	movlw	0x8A
	movwf	m16x16_yl, ACCESS
	
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	movf	POSTDEC2, W, ACCESS
	call	LCD_Write_Hex
	
	movlw	0xFF
	call	delay24
	call	LCD_Clear
	
	goto	start
	
	
create_lookup
	movlb	0x03		    ; select bank 3
	movlw	0x31		    ; 1
	movwf	b'11101110', BANKED
	movlw	0x32		    ; 2
	movwf	b'11101101', BANKED
	movlw	0x33		    ; 3
	movwf	b'11101011', BANKED
	movlw	0x46		    ; F
	movwf	b'11100111', BANKED
	movlw	0x34		    ; 4
	movwf	b'11011110', BANKED
	movlw	0x35		    ; 5
	movwf	b'11011101', BANKED
	movlw	0x36		    ; 6
	movwf	b'11011011', BANKED
	movlw	0x45		    ; E
	movwf	b'11010111', BANKED
	movlw	0x37		    ; 7
	movwf	b'10111110', BANKED
	movlw	0x38		    ; 8
	movwf	b'10111101', BANKED
	movlw	0x39		    ; 9
	movwf	b'10111011', BANKED
	movlw	0x44		    ; D
	movwf	b'10110111', BANKED
	movlw	0x41		    ; A
	movwf	b'01111110', BANKED
	movlw	0x30		    ; 0
	movwf	b'01111101', BANKED
	movlw	0x42		    ; B
	movwf	b'01111011', BANKED
	movlw	0x43		    ; C
	movwf	b'01110111', BANKED
	movlb	0x00		    ; back to ACCESS RAM
	return
	end
