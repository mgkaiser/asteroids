; Supports 255 records of 32 bytes each per pool
; Block 0 is the BAM

; The HEAP is 8k stored at #7f00, the top 8k of RAM
.bank 1, 8, $7F00
.segment "Heap", 1

  ; Stack
  MEM_POOL  .storage $2000, $00
            
.code

SPRITE_BASE .equ $fc00

; Init
.function mempool_init        

    ; Initialize the BAM
    ldx #$00
    lda #$00
    @loop
        sta MEM_POOL,x
        inx
        cpx #$20
    bne @loop

    ;  Block 0 is always used (it's the BAM)
    lda #$01
    sta MEM_POOL

.endfunction

; Mark block available
.function mempool_bamset
  .namespace "mempool_bamset"
    .data
      bitpos  .byte $00
      bytepos .byte $00
      bittbl  .byte $01 $02 $04 $08 $10 $20 $40 $80
    .code

      ; bytepos = A
      sta bytepos   

      ; bitpos = A AND $07
      and #$07
      sta bitpos

      ; bytepos = bytepos / (2^3)      
      lda bytepos
      lsr
      lsr
      lsr
      sta bytepos      

      ; MEM_POOL[bytepos] = MEM_POOL[bytepos] | bittbl[bitpos]
      ldx bytepos
      ldy bitpos
      lda MEM_POOL,x
      ora bittbl,y
      sta MEM_POOL,x
  
  .namespace
.endfunction

; Mark block unavailable
.function mempool_bamclear
  .namespace "mempool_bamclear"
    .data
      bitpos  .byte $00
      bytepos .byte $00
      bittbl  .byte $Fe $fd $fb $f7 $ef $df $bf $7f
    .code
      ; bytepos = A
      sta bytepos   

      ; bitpos = A AND $07
      and #$07
      sta bitpos

      ; bytepos = bytepos / (2^3)      
      lda bytepos
      lsr
      lsr
      lsr
      sta bytepos  
    
      ; MEM_POOL[bytepos] = MEM_POOL[bytepos] & bittbl[bitpos]
      ldx bytepos
      ldy bitpos
      lda MEM_POOL,x
      and bittbl,y
      sta MEM_POOL,x
  .namespace
.endfunction

; Find first free block
.function mempool_bamfind
  .namespace "mempool_bamfind"
    .data
      block   .byte $00
      bittbl  .byte $01 $02 $04 $08 $10 $20 $40 $80      
    .code
      
      ; block = $00
      lda #$00                        ; 2
      sta block                       ; 3

      ; for x = 0 to $19
      ldx #$00                        ; 2  
      @loop

        ; if MEM_POOL[x] != $ff
        lda MEM_POOL,x                ; 3
        cmp #$ff                      ; 2
        beq @skip1                    ; 2
        
          ; for y = 0 to $07   
          ldy#$00                     ; 2
          @innerLoop                  ; --> 16

            ; if (MEM_POOL[x] & bittbl[y]) == 0 break
            lda MEM_POOL,x            ; 3
            and bittbl,y              ; 3
            beq @Done                 ; 2

            ; block++
            inc block                 ; 3

            ;next y
            iny                       ; 1
            cpy #$08                  ; 2
          bne @innerLoop              ; 2

        ; else
        jmp @skip2                    ; 3
        @skip1

          ; block += 8
          addai(block, $08)           ; 9    

        ; endif
        @skip2

        ; next x
        inx                           ; 1
        cpx #$20                      ; 3
      bne @loop                       ; 2

      
      ; block = 0   -- If you got here, all of the memory is allocated
      lda #$00                        ; 2
      sta block                       ; 3

      @done
      lda block                       ; 3
    
  .namespace
.endfunction

; Allocate a block
.function mempool_alloc
  .namespace "mempool_alloc"
    .data      
      temp0 .byte $00
      temp1 .word $0000
      temp2 .word $0000
    .code
            
      ; Find a free block (Results returned in A)
      mempool_bamfind()
      sta temp0   
      
      ; Mark the block as user (param passed in A)
      mempool_bamset()

      ; temp1 = temp0; temp2 = temp0
      lda temp0
      sta temp1
      sta temp2
      lda #$00
      sta temp1+1
      sta temp2+1
    
      ; temp1 = temp1 * (2^5)
      lslwa(temp1, 5)

      ; temp1 = temp1 + MEM_POOL
      adwai(temp1, MEM_POOL)      

      ; temp2 = temp2 * (2^3)
      lslwa(temp2, 3)

      ; temp2 += SPRITE_BASE
      adwai(temp2, SPRITE_BASE)      
      
      ; Return values
      pushax(temp2)
      pushax(temp1)
      pusha(temp0)      
  .namespace
.endfunction

; Free a block
.function mempool_free
  .namespace "mempool_free"

    .data
      temp1 .byte $00
    .code
    
      ; Pop the parameters
      popa(temp1)

      
      ; Mark the block as free (Param passed in A)
      lda temp1
      mempool_bamclear()

  .namespace
.endfunction
