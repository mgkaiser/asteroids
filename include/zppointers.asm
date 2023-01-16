; Reserve some space in zero page

; https://65site.de/downloads/c65_rom_memory_map_20201109.pdf

.segment "Data"

; Holding back some zeropage space as pointers 
reg00     .equ $02
reg01     .equ $04
reg02     .equ $06
reg03     .equ $08
reg04     .equ $0a
reg05     .equ $0c
reg06     .equ $0e
reg07     .equ $10
reg08     .equ $12
reg09     .equ $14
reg10     .equ $16
reg11     .equ $18
reg12     .equ $1a
reg13     .equ $1c
reg14     .equ $1e
reg15     .equ $20
ptr1      .equ $22  
ptr2      .equ $24  
ptr3      .equ $26  
ptr4      .equ $28  
ptr5      .equ $2a
ptr6      .equ $2c
tmp1      .equ $2e  
ptr7      .equ $30
ptr8      .equ $32
ptr9      .equ $34
ptr10     .equ $36
int_ptr1  .equ  $38
int_ptr2  .equ  $3a


