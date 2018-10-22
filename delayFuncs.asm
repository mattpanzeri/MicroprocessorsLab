#include p18f87k22.inc
	
    global delay8, delay16, delay24

acs1	udata_acs
delay_cnt_8 res 1
delay_cnt_16 res 1
delay_cnt_24 res 1

DELAY	code

delay8	movwf	delay_cnt_8
loop_8	decfsz	delay_cnt_8, F	    ; decrement reg, skip if result is zero
	bra	loop_8		    ; loop
	return	0		    ; return to call
	
delay16	movwf	delay_cnt_16
	setf	delay_cnt_8
loop_16 decfsz	delay_cnt_8, F	    ; decrement reg 0x20, skip if zero
	bra	loop_16		    ; loop
	setf	delay_cnt_8
	decfsz	delay_cnt_16, F	    ; decrement upper byte
	bra	loop_16		    ; loop
	return	0		    ; return
	
delay24	movwf	delay_cnt_24
	setf	delay_cnt_16
	setf	delay_cnt_8
loop_24	decfsz	delay_cnt_8, F	    ; decrement reg 0x20, skip if zero
	bra	loop_24		    ; loop
	setf	delay_cnt_8
	decfsz	delay_cnt_16, F	    ; decrement upper byte
	bra	loop_24		    ; loop
	setf	delay_cnt_8
	setf	delay_cnt_16
	decfsz	delay_cnt_24, F
	bra	loop_24
	return	0		    ; return
	
end