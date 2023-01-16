cbm_k_setnam  .equ  $ffbd
cbm_k_setlfs  .equ  $ffba
cbm_k_close   .equ  $ffc3
cbm_k_load    .equ  $ffd5

.macro cbm_k_setnam_macro(fnptr)
  lda #<fnptr
  sta ptr1
  lda #>fnptr
  sta ptr1+1
  ldy #$ff
  @loop
    iny
    lda(ptr1),Y
  bne @loop
  tya  
  ldx ptr1
  ldy ptr1+1
  jsr cbm_k_setnam
.endmacro

.macro cbm_k_setlfs_macro(ln, dev, sa)
  lda #ln
  ldx #dev
  ldy #sa
  jsr cbm_k_setlfs
.endmacro

.macro cbm_k_close_macro(ln)
  lda #ln
  jsr cbm_k_close
.endmacro

.macro cbm_k_load_macro(result, operation, addr)
  lda operation  
  ldx #<addr
  ldy #>addr
  jsr cbm_k_setnam  
  sta result
.endmacro

