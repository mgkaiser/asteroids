.bank 2, 8, $5F00
.segment "MulTable", 2
  tab1      .storage $0800, $00
  tab2      .storage $0800, $00
  tab3      .storage $0800, $00
  tab4      .storage $0800, $00            
.code

; result = w / b
.macro divide_macro(result, w, b)
  pusha(b)
  pushax(w)
  divide()
  resultb(result)
.endmacro

; result = w / b(constant)
.macro divide_constant_macro(result, w, b)
  pusha_i(b)
  pushax(w)
  divide()
  resultb(result)
.endmacro

.function divide
  .namespace "divide"
    .data
      tlq .byte $00
      th  .byte $00
      b   .byte $00    

    .code

      ; Unpack the parameters    
      popax(tlq)                 
      popa(b)

      ;
      LDA TH
      LDX #8
      ASL TLQ
      @L1
        ROL
        BCS @L2
          CMP B
          BCC @L3
        @L2 
          SBC B
          SEC
        @L3 
        ROL TLQ
        DEX
      BNE @L1

      ; Return tlq
      returna(tlq)      
  .namespace
.endfunction

.macro multiply_macro(result, v1, v2)
  lda v2
  ldy v1
  multiply()  
  stx result
  sta result+1
.endmacro

.function multiply
  .namespace "multiply"
    .data      
    .code
      
    	STA mul1    ;set zp adresses
    	STA mul2
    	EOR #$ff
    	STA mul3
    	STA mul4

    	SEC
    	LDA (mul1),y
    	SBC (mul3),y
    	TAX         ;product lo in x
    	LDA (mul2),y
      SBC (mul4),y ;product hi in a
      
  .namespace
.endfunction

.function math_init
  .namespace "math_init"
    .data
      
    .code
      LDX #0      ;build square tables
    	STX tab3+$fe
    	STX tab4+$fe
    	LDY #$ff

      @loop1
        TXA
        LSR
        CLC
        ADC tab3+$fe,x
        STA tab1,x
        STA tab3+$ff,x
        STA tab3,y
        LDA #0
        ADC tab4+$fe,x
        STA tab2,x
        STA tab4+$ff,x
        STA tab4,y
        DEY
        INX
    	BNE @loop1

      @loop2  
        TXA
        SEC
        ROR
        CLC
        ADC tab1+$ff,x
        STA tab1+$100,x
        LDA #0
        ADC tab2+$ff,x
        STA tab2+$100,x
        INX
    	BNE @loop2

    	LDA #>tab1  ;init zp addresses
    	STA mul1+1
    	LDA #>tab2
    	STA mul2+1
    	LDA #>tab3
    	STA mul3+1
    	LDA #>tab4
    	STA mul4+1
      
  .namespace
.endfunction