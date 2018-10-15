	#include p18f87k22.inc
	
	code
	org 0x0
	goto	init
	org 0x100		    ; Main code starts here at address 0x100
	
	; address 0x10, bit 0 is the memory read/write address
	; 0 is register 1 (CP1, OE1), 1 is register 2 (CP2, OE2)
	
init	;setup port D (control bus)
	movlw	0x00
	movwf	TRISD, ACCESS	    ; Set PORTD to output
	movlw	0xFF
	movwf	PORTD, ACCESS	    ; set control pins to HIGH
	;setup port E (data bus)
	banksel	PADCFG1		    ; compiler finds correct bank
	bsf	PADCFG1, REPU, BANKED	; activate PORTE pull up resistors 
	movlb	0x00		    ; set BSR back to 0
	setf	TRISE		    ; Tri-state PORTE

	; writes data 0x20 to memory
write   movlw	0x00
	movwf	TRISE, ACCESS	    ; set PORTE to output
	movff	0x20, TRISE	    ; write data to bus
	btfss	0x10, 0, ACCESS	    ; check 0-bit of 0x10, skip if 1
	movlw	0b11111110	    ; set CP1 to 0
	btfsc	0x10, 0 , ACCESS    ; check 0-bit of 0x10, skip if 0
	movlw	0b11111011	    ; set CP2 to 0
	movwf	PORTD, ACCESS	    ; write to port D
	NOP			    ; wait
	movlw	0xFF
	movwf	PORTD, ACCESS	    ; reset control bus to high
	setf	TRISE		    ; Tri-state PORTE
	
	; read data from memory into 0x21
read	movlw	0xFF
	movwf	TRISE, ACCESS	    ; set PORTE to input
	btfss	0x10, 0, ACCESS	    ; check 0-bit of 0x10, skip if 1
	movlw	0b11111101	    ; set OE1 to 0
	btfsc	0x10, 0 , ACCESS    ; check 0-bit of 0x10, skip if 0
	movlw	0b11110111	    ; set OE2 to 0
	movwf	PORTD, ACCESS	    ; write to port D
	NOP			    ; wait
	movff	PORTE, 0x21	    ; save to register 0x21
	movlw	0xFF
	movwf	PORTD, ACCESS	    ; reset control bus to HIGH
	setf	TRISE		    ; Tri-state PORTE
	
	end
