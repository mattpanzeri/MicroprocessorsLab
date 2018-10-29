#include p18f87k22.inc

    global  ADC_Setup, ADC_Read, ADC_Convert
    extern  m8x24, m8x24_in, m8x24_out, m8x24_m ;external multiplication 8x24
    extern  m16x16, m16x16_xh, m16x16_xl, m16x16_yh, m16x16_yl
    extern  LCD_Hex_Nib, LCD_Send_Byte_D
    
ADC    code
    
ADC_Setup
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    movlw   0x01	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    return

ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    return
    
ADC_Convert
    movff   ADRESL, m16x16_xl
    movff   ADRESH, m16x16_xh
    movlw   0x8A
    movwf   m16x16_yl, ACCESS
    movlw   0x41
    movwf   m16x16_yh, ACCESS
    call    m16x16
    movf    POSTDEC2, W, ACCESS    
    call    LCD_Hex_Nib
    
    movlw   0x2E
    call    LCD_Send_Byte_D
    
    lfsr    FSR2, m8x24_out	    ;move 16x16_out to 8x24_in 
    lfsr    FSR1, m8x24_in
    movff   POSTINC2, POSTINC1
    movff   POSTINC2, POSTINC1
    movff   POSTINC2, POSTINC1
    
    movlw   0x0A
    movwf   m8x24_m, ACCESS
    call    m8x24
    movf    POSTDEC2, W, ACCESS    
    call    LCD_Hex_Nib
    
    lfsr    FSR2, m8x24_out	    ;move 16x16_out to 8x24_in 
    lfsr    FSR1, m8x24_in
    movff   POSTINC2, POSTINC1
    movff   POSTINC2, POSTINC1
    movff   POSTINC2, POSTINC1
    
    movlw   0x0A
    movwf   m8x24_m, ACCESS
    call    m8x24
    movf    POSTDEC2, W, ACCESS    
    call    LCD_Hex_Nib
    
    lfsr    FSR2, m8x24_out	    ;move 16x16_out to 8x24_in 
    lfsr    FSR1, m8x24_in
    movff   POSTINC2, POSTINC1
    movff   POSTINC2, POSTINC1
    movff   POSTINC2, POSTINC1
    
    movlw   0x0A
    movwf   m8x24_m, ACCESS
    call    m8x24
    movf    POSTDEC2, W, ACCESS    
    call    LCD_Hex_Nib
    
    movlw   0x20
    call    LCD_Send_Byte_D
    movlw   0x56
    call    LCD_Send_Byte_D
    return

    end