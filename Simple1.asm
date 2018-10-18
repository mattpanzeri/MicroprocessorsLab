	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	org 0x100		    ; Main code starts here at address 0x100
	
	; address 0x10, bit 0 is the memory read/write address
	; 0 is register 1 (CP1, OE1), 1 is register 2 (CP2, OE2)
	
start	;setup port D (control bus)
	clrf	TRISD, ACCESS	    ; Set PORTD to output
	setf	PORTD, ACCESS	    ; set control pins to HIGH
	
	;setup port E (data bus)
	banksel	PADCFG1		    ; compiler finds correct bank
	bsf	PADCFG1, REPU, BANKED	; activate PORTE pull up resistors 
	movlb	0x00		    ; set BSR back to 0
	setf	TRISE		    ; Tri-state PORTE
	
	;setup ouput ports F-G for visualizing  data
	movlw	0x00
	movwf	TRISH, ACCESS	    ; set PORTF to ouput
	movwf	TRISJ, ACCESS	    ; set PORTG to ouput
	
main	;write a byte to reg 1 and read into port H
	movlw	0xEE
	movwf	0x20, ACCESS	    ; want to write 0xF9
	bcf	0x10, 0, ACCESS	    ; set bit to 0, so write to 1st register
	call	write		    ; write byte
	call	read		    ; read from same register
	movff	0x21, PORTH	    ; display contents of register in PORTF
	
	;write a byte to reg 2 and read into port J
	movlw	0xAA
	movwf	0x20, ACCESS	    ; want to write 0xE5
	bsf	0x10, 0, ACCESS	    ; set bit to 1, so write to 2nd register
	call	write		    ; write byte
	call	read		    ; read from same register
	movff	0x21, PORTJ	    ; display contents of register in PORTJ
	GOTO	start		    ; loop back to start
	
	
	; writes data 0x20 to memory
write   movlw	0x00
	movwf	TRISE, ACCESS	    ; set PORTE to output
	movff	0x20, PORTE	    ; write data to bus
	btfss	0x10, 0, ACCESS	    ; check 0-bit of 0x10, skip if 1
	movlw	0xFE		    ; set CP1 to 0
	btfsc	0x10, 0 , ACCESS    ; check 0-bit of 0x10, skip if 0
	movlw	0xFB		    ; set CP2 to 0
	movwf	PORTD, ACCESS	    ; write to port D
	NOP			    ; wait
	movlw	0xFF
	movwf	PORTD, ACCESS	    ; reset control bus to high
	setf	TRISE		    ; Tri-state PORTE
	return	0
	
	
	; read data from memory into 0x21
read	movlw	0xFF
	movwf	TRISE, ACCESS	    ; set PORTE to input
	btfss	0x10, 0, ACCESS	    ; check 0-bit of 0x10, skip if 1
	movlw	0xFD		    ; set OE1 to 0
	btfsc	0x10, 0 , ACCESS    ; check 0-bit of 0x10, skip if 0
	movlw	0xF7		    ; set OE2 to 0
	movwf	PORTD, ACCESS	    ; write to port D
	NOP			    ; wait
	movff	PORTE, 0x21	    ; save to register 0x21
	movlw	0xFF
	movwf	PORTD, ACCESS	    ; reset control bus to HIGH
	setf	TRISE		    ; Tri-state PORTE
	return	0
	
	end
