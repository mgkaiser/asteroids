.export _sprx
.export _spry
.export _sprc
.export _sprf
.export _numsprites
.export _sprupdateflag
.export _frameflag

.export _initsprites
.export _initraster

SPRBASE         = $bbf8
MAXSPR          = 32            ;Maximum number of sprites

_numsprites     = $02           ;Number of sprites that the main program wants
                                ;to pass to the sprite sorter
_sprupdateflag  = $fb           ;Main program must write a nonzero value here
                                ;when it wants new sprites to be displayed
IRQ1LINE        = $fc           ;This is the place on screen where the sorting
                                ;IRQ happens
IRQ2LINE        = $fd           ;This is where sprite displaying begins...

sortedsprites   = $fe           ;Number of sorted sprites for the raster
                                ;interrupt
tempvariable    = $52           ;Just a temp variable used by the raster
                                ;interrupt
sprirqcounter   = $a7           ;Sprite counter used by the interrupt

sortorder       = $a8           ;Order-table for sorting. Needs as many bytes
sortorderlast   = $aa           ;as there are sprites.

.code

        ;Start the raster interrupt
_initraster:    sei
                lda #<irq1
                sta $0314
                lda #>irq1
                sta $0315
                lda #$7f                    ;CIA interrupt off
                sta $dc0d
                lda #$01                    ;Raster interrupt on
                sta $d01a
                lda #27                     ;High bit of interrupt position = 0
                sta $d011
                lda #IRQ1LINE               ;Line where next IRQ happens
                sta $d012
                lda $dc0d                   ;Acknowledge IRQ (to be sure)
                cli
                rts

        ;Routine to init the sprite multiplexing system

_initsprites:   lda #$00
                sta sortedsprites
                sta _sprupdateflag
                ldx #MAXSPR-1                   ;Init the order table with a
is_orderlist:   txa                             ;0,1,2,3,4,5... order
                sta sortorder,x
                dex
                bpl is_orderlist
                rts

        ;Raster interrupt 1. This is where sorting happens.

irq1:           dec $d019                       ;Acknowledge raster interrupt
                lda #$ff                        ;Move all sprites
                sta $d001                       ;to the bottom to prevent
                sta $d003                       ;weird effects when sprite
                sta $d005                       ;moves lower than what it
                sta $d007                       ;previously was
                sta $d009
                sta $d00b
                sta $d00d
                sta $d00f

                lda #$01
                sta _frameflag

                lda _sprupdateflag               ;New sprites to be sorted?
                beq irq1_nonewsprites
                lda #$00
                sta _sprupdateflag
                lda _numsprites                  ;Take number of sprites given
                                                ;by the main program
                sta sortedsprites               ;If it? zero, don? need to
                bne irq1_beginsort              ;sort

irq1_nonewsprites:
                ldx sortedsprites
                cpx #$09
                bcc irq1_notmorethan8
                ldx #$08
irq1_notmorethan8:
                lda d015tbl,x                   ;Now put the right value to
                sta $d015                       ;$d015, based on number of
                beq irq1_nospritesatall         ;sprites
                                                ;Now init the sprite-counter
                lda #$00                        ;for the actual sprite display
                sta sprirqcounter               ;routine
                lda #<irq2                      ;Set up the sprite display IRQ
                sta $0314
                lda #>irq2
                sta $0315
                jmp irq2_direct                 ;Go directly; we might be late
irq1_nospritesatall:
                jmp $ea81

irq1_beginsort: ldx #MAXSPR
                dex
                cpx sortedsprites
                bcc irq1_cleardone
                lda #$ff                        ;Mark unused sprites with the
irq1_clearloop: sta _spry,x                      ;lowest Y-coordinate ($ff);
                dex                             ;these will "fall" to the
                cpx sortedsprites               ;bottom of the sorted table
                bcs irq1_clearloop
irq1_cleardone: ldx #$00
irq1_sortloop:  ldy sortorder+1,x               ;Sorting code. Algorithm
                lda _spry,y                      ;ripped from Dragon Breed :-)
                ldy sortorder,x
                cmp _spry,y
                bcs irq1_sortskip
                stx irq1_sortreload+1
irq1_sortswap:  lda sortorder+1,x
                sta sortorder,x
                sty sortorder+1,x
                cpx #$00
                beq irq1_sortreload
                dex
                ldy sortorder+1,x
                lda _spry,y
                ldy sortorder,x
                cmp _spry,y
                bcc irq1_sortswap
irq1_sortreload:ldx #$00
irq1_sortskip:  inx
                cpx #MAXSPR-1
                bcc irq1_sortloop
                ldx sortedsprites
                lda #$ff                       ;$ff is the endmark for the
                sta sortspry,x                 ;sprite interrupt routine
                ldx #$00
irq1_sortloop3: ldy sortorder,x                ;Final loop:
                lda _spry,y                     ;Now copy sprite variables to
                sta sortspry,x                 ;the sorted table
                lda _sprx,y
                sta sortsprx,x
                lda _sprf,y
                sta sortsprf,x
                lda _sprc,y
                sta sortsprc,x
                inx
                cpx sortedsprites
                bcc irq1_sortloop3                
                jmp irq1_nonewsprites

        ;Raster interrupt 2. This is where sprite displaying happens

irq2:           dec $d019                       ;Acknowledge raster interrupt
irq2_direct:    ldy sprirqcounter               ;Take next sorted sprite number
                lda sortspry,y                  ;Take Y-coord of first new sprite
                clc
                adc #$10                        ;16 lines down from there is
                bcc irq2_notover                ;the endpoint for this IRQ
                lda #$ff                        ;Endpoint can? be more than $ff
irq2_notover:   sta tempvariable
irq2_spriteloop:lda sortspry,y
                cmp tempvariable                ;End of this IRQ?
                bcs irq2_endspr
                ldx physicalsprtbl2,y           ;Physical sprite number x 2
                sta $d001,x                     ;for X & Y coordinate
                lda sortsprx,y
                asl
                sta $d000,x
                bcc irq2_lowmsb
                lda $d010
                ora ortbl,x
                sta $d010
                jmp irq2_msbok
irq2_lowmsb:    lda $d010
                and andtbl,x
                sta $d010
irq2_msbok:     ldx physicalsprtbl1,y           ;Physical sprite number x 1
                lda sortsprf,y
                sta SPRBASE,x                     ;for color & frame
                lda sortsprc,y
                sta $d027,x
                iny
                bne irq2_spriteloop
irq2_endspr:    cmp #$ff                        ;Was it the endmark?
                beq irq2_lastspr
                sty sprirqcounter
                sec                             ;That coordinate - $10 is the
                sbc #$10                        ;position for next interrupt
                cmp $d012                       ;Already late from that?
                bcc irq2_direct                 ;Then go directly to next IRQ
                sta $d012
                jmp $ea81
irq2_lastspr:   lda #<irq1                      ;Was the last sprite,
                sta $0314                       ;go back to irq1
                lda #>irq1                      ;(sorting interrupt)
                sta $0315
                lda #IRQ1LINE
                sta $d012
                jmp $ea81

_sprx:          .res MAXSPR, $00                ;Unsorted sprite table
_spry:          .res MAXSPR, $00
_sprc:          .res MAXSPR, $00
_sprf:          .res MAXSPR, $00

sortsprx:       .res MAXSPR, $00                ;Sorted sprite table
sortspry:       .res MAXSPR + 1, $00            ;Must be one byte extra for the
                                                ;$ff endmark
sortsprc:       .res MAXSPR, $00
sortsprf:       .res MAXSPR, $00

_frameflag:     .byte $00;

d015tbl:        .byte %00000000                 ;Table of sprites that are "on"
                .byte %00000001                 ;for $d015
                .byte %00000011
                .byte %00000111
                .byte %00001111
                .byte %00011111
                .byte %00111111
                .byte %01111111
                .byte %11111111

physicalsprtbl1:.byte 0,1,2,3,4,5,6,7            ;Indexes to frame & color
                .byte 0,1,2,3,4,5,6,7            ;registers
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7

physicalsprtbl2:.byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14

andtbl:         .byte 255-1
ortbl:          .byte 1
                .byte 255-2
                .byte 2
                .byte 255-4
                .byte 4
                .byte 255-8
                .byte 8
                .byte 255-16
                .byte 16
                .byte 255-32
                .byte 32
                .byte 255-64
                .byte 64
                .byte 255-128
                .byte 128

