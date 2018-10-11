	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start
	movlw 	0x0
	movwf	TRISC, ACCESS	    ; Port C all outputs
	movwf	0x06, ACCESS	    ; reset 0x06
	bra 	test
loop	movlw	0xFF		    ; delay timer value
	movwf	0x20, ACCESS	    ; sets counter lower bit
	movwf	0x21, ACCESS	    ; sets uppper bit
	call	delay16
	movff 	0x06, PORTC
	incf 	0x06, F, ACCESS
test	movlw 	0x63		    ; test for end of loop condition
	cpfsgt 	0x06, ACCESS
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start
	
; 8-bit delay subroutine
delay8	decfsz	0x20, F, ACCESS	    ; decrement reg 0x20, skip if result is zero
	bra	delay8		    ; loop
	return	0		    ; return to call
	
delay16	decfsz	0x20, F, ACCESS	    ; decrement reg 0x20, skip if zero
	bra	delay16		    ; loop
	movlw	0xFF		    ; set 0x20 to 0xFF
	movwf	0x20, ACCESS
	decfsz	0x21, F, ACCESS	    ; decrement upper byte
	bra	delay16		    ; loop
	return	0		    ; return
	
	end
	
