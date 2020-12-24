.export _sort;

.import _s_y
.import _s_index

.code 

_sort:
                ldx #$00
    sortloop:   ldy _s_index + 1, x
                lda _s_y, y
                ldy _s_index, x
                cmp _s_y, y
                bcs sortskip
                stx sortreload + 1
    sortswap:   lda _s_index + 1, x
                sta _s_index, x
                pha
                tya
                sta _s_index + 1, x
                pla
                cpx #$00
                beq sortreload
                dex
                ldy _s_index + 1, x
                lda _s_y, y
                ldy _s_index, x
                cmp _s_y, y
                bcc sortswap
    sortreload: ldx #$00
    sortskip:   inx
                cpx #$1F
                bcc sortloop
                rts