.macro stwa ( ptr, value )  
  lda value
  sta ptr        
  lda value+1
  sta ptr+1   
.endmacro

.macro stwi ( ptr, value )
  LL .var (value & $00ff)
  HH .var (value & $ff00) >> 8               
  lda #LL
  sta ptr
  .if LL != HH
  lda #HH
  .endif   
  sta ptr+1
.endmacro

.macro cpwbi_ofs (ptr, ofs, value2)
  ldy #ofs
  lda (ptr),Y
  cmp #value2
.endmacro

; Is value1 > value2 (constant)
.macro cpwai (value1, value2)
  LL .var (value2 & $00ff)
  HH .var (value2 & $ff00) >> 8  
  lda #HH
  cmp value1+1
  bne @1001
  lda #LL
  cmp value1
  @1001
.endmacro

; Is value1 > value2 
.macro cpwaa (value1, value2)  
  lda value2+1
  cmp value1+1
  bne @1002
  lda value2
  cmp value1
  @1002
.endmacro

; Is value1->ofs1 == zero
.macro cpw_ptr_zero (value1, ofs1)  
  ldy #ofs1
  lda (value1),y
  iny
  ora (value1),y
.endmacro

.macro cpw_zero (value1)    
  lda value1  
  ora value1+1
.endmacro

.macro cpwx2_zero (value1, value2)    
  lda value1  
  ora value1+1
  ora value2
  ora value2+1
.endmacro

; value1 = ax
.macro ldwax (value1)  
  lda value1
  ldx value1+1
.endmacro

; value1 = value2
.macro ldwaa (value1, value2)  
  lda value2  
  sta value1
  lda value2 + 1  
  sta value1 + 1
.endmacro

; value1->ofs1 = value2->ofs2
.macro ldwpp (value1, ofs1, value2, ofs2)  
  ldy #ofs2
  lda (value2),y
  ldy #ofs1
  sta (value1),y
  ldy #ofs2+1
  lda (value2),y
  ldy #ofs1+1
  sta (value1),y
.endmacro

; value1->ofs1 = value2 (constant)
.macro ldwpi (value1, ofs1, value2)  
  LL .var (value2 & $00ff)
  HH .var (value2 & $ff00) >> 8    
  lda #LL
  ldy #ofs1
  sta (value1),y
  .if LL != HH
  lda #HH
  .endif
  iny
  sta (value1),y
.endmacro

; value1->ofs1 = 0
.macro ldwpz (value1, ofs1)    
  ldy #ofs1
  lda #$00
  sta (value1),y  
  iny
  sta (value1),y
.endmacro

; value1->ofs1 = value2 
.macro ldwpa (value1, ofs1, value2)    
  lda value2
  ldy #ofs1
  sta (value1),y
  lda value2 +1
  iny
  sta (value1),y
.endmacro


; value1 = value2->ofs2 
.macro ldwap (value1, value2, ofs2)    
  ldy #ofs2
  lda (value2),y  
  sta value1  
  iny
  lda (value2),y
  sta value1+1
.endmacro

; value1->ofs1 = value2 
.macro ldbpa (value1, ofs1, value2)    
  lda value2
  ldy #ofs1
  sta (value1),y  
.endmacro

.macro sdbpr (value1, ofs1)      
  ldy #ofs1
  sta (value1),y  
.endmacro

.macro ldbpr (value1, ofs1)      
  ldy #ofs1
  sta (value1),y  
.endmacro

; value1 = value2 (constant)
.macro ldwai (value1, value2)  
  LL .var (value2 & $00ff)
  HH .var (value2 & $ff00) >> 8  
  lda #LL  
  sta value1
  .if LL != HH
  lda #HH
  .endif
  sta value1 + 1
.endmacro

; value1->ofs1 = value2 (constant)
.macro ldwpi (value1, ofs1, value2)    
  LL .var (value2 & $00ff)
  HH .var (value2 & $ff00) >> 8  
  lda #LL
  ldy #ofs1
  sta (value1),y
  lda #HH
  iny
  sta (value1),y
.endmacro

; value1->ofs1 = value2 (constant)
.macro ldbpi (value1, ofs1, value2)      
  lda #value2
  ldy #ofs1
  sta (value1),y  
.endmacro

; value1 = value2 (constant)
.macro ldbai (value1, value2)    
  lda #value2  
  sta value1  
.endmacro

; value1 = value2 
.macro ldbaa (value1, value2)    
  lda value2  
  sta value1  
.endmacro

; value1 = value1 + value2 
.macro adwaa (value1, value2)  ;22
  clc                 ; 2
  lda value1          ; 3
  adc value2          ; 4
  sta value1          ; 3
  lda value1 + 1      ; 3
  adc value2 + 1      ; 4
  sta value1 + 1      ; 3
.endmacro

; value1 = value1 (16 bit) + value2->ofs (8 bit)
.macro adwaa_ofs_8 (value1, value2, ofs)  ;22
  clc                 ; 2
  ldy #ofs
  lda value1          ; 3
  adc (value2),y      
  sta value1          ; 3  
  lda value1 + 1      ; 3
  adc #$00  
  sta value1 + 1      ; 3
.endmacro

; value1 = value1 + value2 (constant)
.macro adwai (value1, value2)
  LL .var (value2 & $00ff)
  HH .var (value2 & $ff00) >> 8  
  clc
  lda value1
  adc #ll
  sta value1
  lda value1 + 1
  adc #hh 
  sta value1 + 1
.endmacro

; value1 = value1 + value2 
.macro addaa (value1, value2)  ;22
  clc                 ; 2
  lda value1          ; 3
  adc value2          ; 4
  sta value1          ; 3  
.endmacro

; value1 = value1 + value2 (constant)
.macro addai (value1, value2)  
  clc
  lda value1
  adc #value2
  sta value1  
.endmacro

.macro lsrwa (value, repeat) ; 16/32
  .loop repeat 
    sec             ; 2
    lsr value+1     ; 6
    bcc @1001       ; 2 + 1
      lsr value     ; 6
      lda #$80      ; 4
      ora value     ; 4
      sta value     ; 4
      jmp @1002     ; 3
    @1001           
      lsr value     ; 6
    @1002
  .endloop
.endmacro

.macro lslwa (value, repeat) ; 12
  .loop repeat 
    clc
    asl value
    rol value + 1    
  .endloop
.endmacro

.macro rol_n (repeat) 
  .loop repeat 
    rol
  .endloop
.endmacro

.macro resultw(value)
  sta value
  stx value+1
.endmacro

.macro resultb(value)
  sta value  
.endmacro

