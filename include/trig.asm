.data
  thetarand_table   .storage  $100, $00
  xrand_table_low   .storage  $100, $00
  xrand_table_high  .storage  $100, $00
  yrand_table       .storage  $100, $00
  
  sin_table_high  
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF
  
  sin_table_low 
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$01,	$01,	$01,	$01,	$01,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$00
    .byte $00,	$01,	$02,	$02,	$02,	$02,	$02,	$01,	$00,	$FF,	$FE,	$FE,	$FE,	$FE,	$FE,	$FF
    .byte $00,	$01,	$02,	$03,	$03,	$03,	$02,	$01,	$00,	$FF,	$FE,	$FD,	$FD,	$FD,	$FE,	$FF
    .byte $00,	$01,	$03,	$04,	$04,	$04,	$03,	$01,	$00,	$FF,	$FD,	$FC,	$FC,	$FC,	$FD,	$FF
    .byte $00,	$02,	$04,	$05,	$05,	$05,	$04,	$02,	$00,	$FE,	$FC,	$FB,	$FB,	$FB,	$FC,	$FE
    .byte $00,	$02,	$04,	$06,	$06,	$06,	$04,	$02,	$00,	$FE,	$FB,	$FA,	$FA,	$FA,	$FC,	$FE
    .byte $00,	$03,	$05,	$07,	$07,	$07,	$05,	$02,	$00,	$FD,	$FB,	$F9,	$F9,	$F9,	$FB,	$FE
    .byte $00,	$03,	$06,	$08,	$08,	$08,	$06,	$03,	$00,	$FD,	$FA,	$F8,	$F8,	$F8,	$FA,	$FD
    .byte $00,	$03,	$07,	$09,	$09,	$09,	$07,	$03,	$00,	$FD,	$F9,	$F7,	$F7,	$F7,	$FA,	$FD
    .byte $00,	$04,	$07,	$0A,	$0A,	$0A,	$07,	$04,	$00,	$FC,	$F9,	$F6,	$F6,	$F6,	$F9,	$FD
    .byte $00,	$04,	$08,	$0B,	$0B,	$0B,	$08,	$04,	$00,	$FC,	$F8,	$F5,	$F5,	$F6,	$F8,	$FC
    .byte $00,	$04,	$09,	$0C,	$0C,	$0B,	$09,	$04,	$00,	$FB,	$F7,	$F4,	$F4,	$F5,	$F8,	$FC
    .byte $00,	$05,	$09,	$0C,	$0D,	$0C,	$09,	$05,	$00,	$FB,	$F6,	$F3,	$F3,	$F4,	$F7,	$FB
    .byte $00,	$05,	$0A,	$0D,	$0E,	$0D,	$0A,	$05,	$00,	$FB,	$F6,	$F3,	$F2,	$F3,	$F6,	$FB
    .byte $00,	$06,	$0B,	$0E,	$0F,	$0E,	$0B,	$05,	$00,	$FA,	$F5,	$F2,	$F1,	$F2,	$F5,	$FB

  cos_table_high 
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
    .byte $00,	$00,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$00
                     
  cos_table_low   
    .byte $00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00
    .byte $01,	$01,	$01,	$00,	$00,	$00,	$FF,	$FF,	$FF,	$FF,	$FF,	$00,	$00,	$00,	$01,	$01
    .byte $02,	$02,	$02,	$01,	$00,	$FF,	$FE,	$FE,	$FE,	$FE,	$FE,	$FF,	$00,	$01,	$02,	$02
    .byte $03,	$03,	$02,	$01,	$00,	$FF,	$FE,	$FD,	$FD,	$FD,	$FE,	$FF,	$00,	$01,	$02,	$03
    .byte $04,	$04,	$03,	$01,	$00,	$FF,	$FD,	$FC,	$FC,	$FC,	$FD,	$FF,	$00,	$02,	$03,	$04
    .byte $05,	$05,	$04,	$02,	$00,	$FE,	$FC,	$FB,	$FB,	$FB,	$FC,	$FE,	$00,	$02,	$04,	$05
    .byte $06,	$06,	$04,	$02,	$00,	$FE,	$FC,	$FA,	$FA,	$FA,	$FC,	$FE,	$00,	$02,	$05,	$06
    .byte $07,	$07,	$05,	$03,	$00,	$FD,	$FB,	$F9,	$F9,	$F9,	$FB,	$FE,	$00,	$03,	$05,	$07
    .byte $08,	$08,	$06,	$03,	$00,	$FD,	$FA,	$F8,	$F8,	$F8,	$FA,	$FD,	$00,	$03,	$06,	$08
    .byte $09,	$09,	$07,	$03,	$00,	$FD,	$F9,	$F7,	$F7,	$F7,	$FA,	$FD,	$00,	$04,	$07,	$09
    .byte $0A,	$0A,	$07,	$04,	$00,	$FC,	$F9,	$F6,	$F6,	$F6,	$F9,	$FC,	$00,	$04,	$07,	$0A
    .byte $0B,	$0B,	$08,	$04,	$00,	$FC,	$F8,	$F5,	$F5,	$F5,	$F8,	$FC,	$00,	$04,	$08,	$0B
    .byte $0C,	$0C,	$09,	$04,	$00,	$FB,	$F7,	$F4,	$F4,	$F4,	$F7,	$FC,	$00,	$05,	$09,	$0C
    .byte $0D,	$0C,	$09,	$05,	$00,	$FB,	$F7,	$F4,	$F3,	$F4,	$F7,	$FB,	$00,	$05,	$0A,	$0D
    .byte $0E,	$0D,	$0A,	$05,	$00,	$FB,	$F6,	$F3,	$F2,	$F3,	$F6,	$FB,	$00,	$06,	$0A,	$0D
    .byte $0F,	$0E,	$0B,	$06,	$00,	$FA,	$F5,	$F2,	$F1,	$F2,	$F5,	$FB,	$00,	$06,	$0B,	$0E

  
         

  AYINT         .equ  $fe00 ; convert floating point to integer
  GIVAYF        .equ  $fe03 ; convert integer to floating point
  FOUT          .equ  $fe06 ; convert floating point to ASCII
  FADD	        .equ  $FE18	; MEM + FACC
  FMULT	        .equ  $FE1E	; MEM * FACC
  FDIV	        .equ  $FE24 ; MEM / FACC
  INT           .equ  $FE2D ; perform BASIC INT() on FACC
  COS           .equ  $FE3F	; compute COS of FACC
  SIN           .equ	$FE42 ; compute SIN of FACC
  FCOMP	        .equ  $FE54 ; compare FACC with MEM
  MOVFRM        .equ	$FE60 ; move RAM MEM to FACC
  MOVMF         .equ	$FE66 ; move FACC to MEM
  RND_0         .equ  $FE57 ; generate random floating point number
  entropy_get	  .equ  $FECF ; Misc	get 24 random bits

  .macro SETFPZERO_macro(VALUE)
    lda #$00
    sta VALUE+0
    sta VALUE+1
    sta VALUE+2
    sta VALUE+3
    sta VALUE+5
  .endmacro

  ; FACC = CONSTANT
  .macro GIVAYF_macro(CONSTANT)
    ldy #<CONSTANT
    lda #>CONSTANT    
    jsr GIVAYF        
  .endmacro

  .macro AYINT_macro(value)
    jsr AYINT             ; FACC -> integer @ $c7 LSB, $c6 MSB
    lda $c7
    sta value
    lda $c6
    sta value+1
  .endmacro

  .macro FOUT_macro(value)
    jsr FOUT
    sta value
    sty value+1
  .endmacro

  ; FACC = MEM + FACC
  .macro FADD_macro(MEM)
    lda #<MEM
    ldy #>MEM
    jsr FADD 
  .endmacro

  ; FACC = MEM * FACC
  .macro FMULT_macro(MEM)
    lda #<MEM
    ldy #>MEM
    jsr FMULT
  .endmacro

  ; FACC = MEM / FACC
  .macro FDIV_macro(MEM)
    lda #<MEM
    ldy #>MEM
    jsr FDIV
  .endmacro

  .macro FCOMP_macro(MEM)
    lda #<MEM
    ldy #>MEM
    jsr FCOMP         
  .endmacro

  ; FACC = MEM
  .macro MOVFRM_macro(MEM)
    lda #<MEM
    ldy #>MEM
    jsr MOVFRM        
  .endmacro

  ; MEM = FACC
  .macro MOVMF_macro(MEM)
    ldx #<MEM
    ldy #>MEM
    jsr MOVMF           
  .endmacro

  .macro RNDSEED_macro()
    ; Kernal ROM
    ;lda #$00
    ;sta $01

    ; Get Entropy
    lda #$00
    php
    JSR entropy_get ; KERNAL call to get entropy into .A/.X/.Y
    plp

    ; Math ROM
    ;lda #$04
    ;sta $01
  .endmacro

  .macro RND0_macro()        
    ; Get Random Number
    lda #$01
    jsr RND_0
  .endmacro

.code

  .function buildRandomNumbers()
    .namespace "buildRandomNumbers"
      .data   
        oldBank     .byte $00
        c_2         .byte $00,$00,$00,$00,$00,$00
        c_16        .byte $00,$00,$00,$00,$00,$00 
        c_40        .byte $00,$00,$00,$00,$00,$00
        c_100       .byte $00,$00,$00,$00,$00,$00
        c_140       .byte $00,$00,$00,$00,$00,$00
        c_196       .byte $00,$00,$00,$00,$00,$00
        c_276       .byte $00,$00,$00,$00,$00,$00
        randomTheta .word $0000
        randomX     .word $0000
        randomY     .word $0000 
        count       .byte $00
      .code      
        ; Bank the math ROM in
        sei
        lda $01
        sta oldBank
        lda #$04
        sta $01    

        ; Setup conatants   
        GIVAYF_macro(2)
        MOVMF_macro(c_2)          
        GIVAYF_macro(16)
        MOVMF_macro(c_16)      
        GIVAYF_macro(40)
        MOVMF_macro(c_40)       
        GIVAYF_macro(100)
        MOVMF_macro(c_100)
        GIVAYF_macro(140)
        MOVMF_macro(c_140)
        GIVAYF_macro(196)
        MOVMF_macro(c_196)       
        GIVAYF_macro(276)
        MOVMF_macro(c_276)               

        ; count = 0
        lda #$00
        sta count

        @loop      

          ; Pick a Random number between 0 and 15
          RND0_macro()              ; FACC = RND(0)
          FMULT_macro(c_16)         ; FACC = FACC * 16  
          jsr INT                   ; FACC = INT(FACC)      
          AYINT_macro(randomTheta)  ; FACC -> integer @ $67 LSB, $66 MSB
          ldx count
          lda randomTheta
          sta thetarand_table, x    ; thetarand_table[count] = randomTheta
          
          ; Random between 2 and 278.  Add 40 to > 140. Result = word
          RND0_macro()              ; FACC = RND(0)
          FMULT_macro(c_276)        ; FACC = FACC * 276
          jsr INT                   ; FACC = INT(FACC) 
          FADD_macro(c_2)           ; FACC += 2      
          FCOMP_macro(c_140)        ; Is it >= 140
          bmi @SkipAdd1     
            FADD_macro(c_40)        ; FACC += 40       
          @SkipAdd1
          AYINT_macro(randomX)      ; FACC -> integer @ $67 LSB, $66 MSB      
          ldx count
          lda randomX
          sta xrand_table_low, x    ; xrand_table_low[count] = randomX
          lda randomX+1
          sta xrand_table_high, x   ; xrand_table_high[count] = randomX+1

          ; Random between 2 and 198.  Add 40 to > 100. Result = byte
          RND0_macro()              ; FACC = RND(0)
          FMULT_macro(c_196)        ; FACC = FACC * 196
          jsr INT                   ; FACC = INT(FACC) 
          FADD_macro(c_2)           ; FACC += 2 
          FCOMP_macro(c_100)        ; Is it >= 100
          bmi @SkipAdd2
            FADD_macro(c_40)        ; FACC += 40
          @SkipAdd2
          AYINT_macro(randomY)      ; FACC -> integer @ $67 LSB, $66 MSB  
          ldx count
          lda randomY
          sta yrand_table, x        ; yrand_table[count] = randomY

          ; count ++
          inc count
        bne @Loop

        ; Bank the math ROM out      
        lda  oldBank
        sta $01
        cli
        
    .namespace
  .endfunction

  .macro polarToX_macro(result, origin, r, theta)
    pusha(theta)
    pusha(r)
    pushax(origin)
    polarToX()
    resultw(result)
  .endmacro

  .macro polarToX_ptr_macro(result, ptr, origin, r, theta)  
    pusha_ofs (ptr, theta)  
    pusha_ofs (ptr, r)  
    pushax_ofs (ptr, origin)    
    polarToX()
    resultw(result)
  .endmacro

  .function polarToX
    .namespace "polarToX"
      .data
        origin  .word $0000
        r       .byte $00
        theta   .byte $00  
        result  .word $0000      
      .code
        ; parameters
        popax(origin)
        popa(r)
        popa(theta)

        ; X = theta * 16 + r        
        lda r  
        clc      
        rol_n(4)        
        clc      
        adc theta            
        tax

        ; result = cos_table[x]
        lda sin_table_low,X
        sta result
        lda sin_table_high,X
        sta result+1
              
        ; result = result + origin
        adwaa (result, origin)

        ; result
        returnax(result)           
    .namespace
  .endfunction

  .macro polarToY_macro(result, origin, r, theta)
    pusha(theta)
    pusha(r)
    pushax(origin)
    polarToY()
    resultw(result)
  .endmacro

  .macro polarToY_ptr_macro(result, ptr, origin, r, theta)  
    pusha_ofs (ptr, theta)  
    pusha_ofs (ptr, r)  
    pushax_ofs (ptr, origin)    
    polarToY()
    resultw(result)
  .endmacro

  .function polarToY
    .namespace "polarToY"    
      .data
        origin  .word $0000
        r       .byte $00
        theta   .byte $00     
        result  .word $0000         
      .code
        ; parameters
        popax(origin)
        popa(r)
        popa(theta)
                          
        ; X = theta * 16 + r        
        lda r    
        clc    
        rol_n(4)        
        clc      
        adc theta            
        tax

        ; result = sin_table[x]
        lda cos_table_low,X
        sta result
        lda cos_table_high,X
        sta result+1
                    
        ; result = result + origin
        adwaa (result, origin)

        ; result
        returnax(result)
    .namespace
  .endfunction