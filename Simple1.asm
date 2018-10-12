	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start	movlw	0x00
	movwf	0x20, ACCESS	    ; set counter at 0x20
	movwf	TRISC, ACCESS	    ; set PORTC to output
	lfsr	FSR0, 0x300	    ; start from bank3 at 0x00
	lfsr	FSR1, 0x3FE	    ; second FSR
	movff	0x20, POSTINC0	    ; write 1st value
wloop	incf	0x20, F, ACCESS	    ; increment counter
	movff	0x20, POSTINC0	    ; write counter to FSR, with postincrement
	movlw	0xFF		    ; compare counter to 0xFF
	cpfseq	0x20, ACCESS	    ; if equal, skip ahead, if not, loop
	bra	wloop
	
	movlw	0x32		    ; modify register 0x367 to see if program exits
	movlb	0x03
	movwf	0x67, BANKED
	
rloop	decf	0x20, F, ACCESS	    ; decrement counter
	movf	POSTDEC1, W, ACCESS ; load FSR1 into W
	cpfseq	0x20, ACCESS	    ; compare counter to FSR1
	bra	err		    ; exit and write which address is wrong
	bra     rloop		    ; loop
err	movff	0x20, PORTC
	end

