	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	org 0x100		    ; Main code starts here at address 0x100
	
	
start
	call    SPI_MasterInit  ; initialize SPI
	movlw   0xF0
	call    SPI_MasterTransmit ; send serial data
	setf    0x22, ACCESS	; set timer upper byte
	setf    0x21, ACCESS	; set timer high byte
	setf    0x20, ACCESS	; set timer low byte
	call    delay24		; delay
	movlw   0x0F		
	call    SPI_MasterTransmit	; send serial data
	setf    0x22, ACCESS	
	setf    0x21, ACCESS
	setf    0x20, ACCESS
	call    delay24		; delay
	goto    start
	
SPI_MasterInit	; Set Clock edge to positive
	bcf	    SSP2STAT, CKE
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw   (1<<SSPEN)|(1<<CKP)|(0x02)
	movwf   SSP2CON1
	; SDO2 output; SCK2 output
	bcf	    TRISD, SDO2
	bcf	    TRISD, SCK2
	return 

SPI_MasterTransmit  ; Start transmission of data (held in W)
	movwf 	SSP2BUF 
Wait_Transmit	; Wait for transmission to complete 
	btfss 	PIR2, SSP2IF
	bra 	Wait_Transmit
	bcf 	PIR2, SSP2IF	; clear interrupt flag
	return
    
delay24	decfsz	0x20, F, ACCESS	    ; decrement reg 0x20, skip if zero
	bra	delay24		    ; loop
	movlw	0xFF		    ; set 0x20 to 0xFF
	movwf	0x20, ACCESS
	decfsz	0x21, F, ACCESS	    ; decrement upper byte
	bra	delay24		    ; loop
	movlw	0xFF
	movwf	0x20, ACCESS
	movwf	0x21, ACCESS
	decfsz	0x22, F, ACCESS
	bra	delay24
	return	0		    ; return
	
    end
