#include p18f87k22.inc

    global	    m8x24, m8x24_in, m8x24_out, m8x24_m
    global	    m16x16, m16x16_xh, m16x16_xl, m16x16_yh, m16x16_yl
    
acs_mul	    udata_acs
m8x8_out    res 1   ;8x8 output byte
m8x8_car    res 1   ;8x8 carry	byte
m8x8_in	    res 1   ;8x8 input, other input in W    
m8x24_in    res 3   ;reserve 3 bytes for 8x24 input LITTLE ENDIAN
m8x24_m	    res 1   ;8x24 multiplicand
m8x24_out   res 4   ;reserve 4 bytes for 8x24 output LITTLE ENDIAN
		    ;use also for 16x16
m16x16_xh   res 1   ;high byte input
m16x16_xl   res 1   ;low byte input
m16x16_yh   res 1   ;high byte input
m16x16_yl   res 1   ;low byte input
   
Multiplication CODE

m8x24	    
    clrf    m8x8_car, ACCESS	    ;reset multiplication carry byte
    bcf	    STATUS, 0,ACCESS	    ;reset addition carry flag
    
    lfsr    FSR1, m8x24_in	    ;set FSR1 inputs
    lfsr    FSR2, m8x24_out	    ;set FSR2 outputs
    clrf    POSTINC2, ACCESS	    ;clear the outputs
    clrf    POSTINC2, ACCESS
    clrf    POSTINC2, ACCESS
    clrf    POSTINC2, ACCESS
    lfsr    FSR2, m8x24_out
    
    movf    m8x24_m, W, ACCESS	    ;move m into W
    movff   POSTINC1, m8x8_in	    ;get 1st input byte, postinc
    call    m8x8		    ;multiply
    movff   m8x8_out, POSTINC2	    ;write result, postinc
    
    movf    m8x24_m, W, ACCESS	    ;as above, for second byte
    movff   POSTINC1, m8x8_in
    call    m8x8
    movff   m8x8_out, POSTINC2
    
    movf    m8x24_m, W, ACCESS	    ;as above, for third byte
    movff   POSTINC1, m8x8_in
    call    m8x8
    movff   m8x8_out, POSTINC2
    
    movlw   0x00		    ;last carry byte is last output
    addwfc  m8x8_car, W, ACCESS	    ;(plus carry from previous addition)
    movwf   INDF2
    
    clrf    m8x8_car, ACCESS	    ;reset multiplication carry byte
    bcf	    STATUS, 0,ACCESS	    ;reset addition carry flag
    return
    
m16x16
    clrf    m8x8_car, ACCESS	    ;reset multiplication carry byte
    bcf	    STATUS, 0,ACCESS	    ;reset addition carry flag
    
    lfsr    FSR2, m8x24_out	    ;use same output as m8x24
    clrf    POSTINC2, ACCESS	    ;clear output
    clrf    POSTINC2, ACCESS
    clrf    POSTINC2, ACCESS
    clrf    POSTINC2, ACCESS
    lfsr    FSR2, m8x24_out
    
    movf    m16x16_yl, W, ACCESS    ;multiply x_l by y_l
    movff   m16x16_xl, m8x8_in
    call    m8x8
    movff   m8x8_out, POSTINC2	    ;move into output
    
    movf    m16x16_yl, W, ACCESS    ;multiply x_h by y_l
    movff   m16x16_xh, m8x8_in
    call    m8x8
    movff   m8x8_out, POSTINC2	    ;move low byte into output
    movlw   0x00
    addwfc  m8x8_car, F, ACCESS	    ;carry bit to left
    movff   m8x8_car, POSTINC2	    ;store in output
    addwfc  INDF2, W, ACCESS	    ;carry bit to left
    movwf   POSTDEC2, ACCESS	    ;move to output
    movf    POSTDEC2, W, ACCESS	    ;move back FSR2
    movff   INDF2, m8x8_car	    ;set carry byte for next multiplication
    
    movf    m16x16_yh, W, ACCESS
    movff   m16x16_xl, m8x8_in
    call    m8x8
    movff   m8x8_out, POSTINC2
    movf    m8x8_car, W, ACCESS
    addwfc  INDF2, F, ACCESS
    movff   POSTINC2, m8x8_car
    movlw   0x00
    addwfc  INDF2, W, ACCESS
    movwf   POSTDEC2, ACCESS
    
    movf    m16x16_yh, W, ACCESS
    movff   m16x16_xh, m8x8_in
    call    m8x8
    movff   m8x8_out, POSTINC2
    movf    m8x8_car, W, ACCESS
    addwfc  INDF2, F, ACCESS
    
    return
    
    
 
m8x8	    ;8x8 multipication, between W and m8x8_in
    mulwf   m8x8_in, ACCESS	    ;multiply input by W
    movf    PRODL, W, ACCESS	    ;low byte is added to high byte
    addwfc  m8x8_car, W		    ;from previous multiplication (carry byte)
    movwf   m8x8_out, ACCESS	    ;output low byte
    movff   PRODH, m8x8_car	    ;high byte is new carry
    return

    
    END


