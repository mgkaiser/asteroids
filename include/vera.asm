VERA            .equ    $9f20
VERA.address    .equ VERA + $00
VERA.address_hi .equ VERA + $02
VERA.data0      .equ VERA + $03
VERA.data1      .equ VERA + $04
VERA.control    .equ VERA + $05
VERA.irq_enable .equ VERA + $06
VERA.irq_flags  .equ VERA + $07
VERA.irq_raster .equ VERA + $08
; display 0
    VERA.display.video  .equ VERA + $09
    VERA.display.hscale .equ VERA + $0A
    VERA.display.vscale .equ VERA + $0B
    VERA.display.border .equ VERA + $0C
; display 1        
    VERA.display.hstart .equ VERA + $09
    VERA.display.hstop  .equ VERA + $0A
    VERA.display.vstart .equ VERA + $0B
    VERA.display.vstop  .equ VERA + $0C
; layer 0
; layer 1
; audio
; spi