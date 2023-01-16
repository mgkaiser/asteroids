.data
  asset_Rock2         .incbin "bin/ROCK2.BIN"
  size_Rock2          .equ    $0202
  asset_Rock2_Pal     .incbin "bin/ROCK2-PALETTE.BIN"
  size_Rock2_Pal      .equ    $0016
  
  asset_Rock3         .incbin "bin/ROCK3.BIN"
  size_Rock3          .equ    $0082
  asset_Rock3_Pal     .incbin "bin/ROCK3-PALETTE.BIN"
  size_Rock3_Pal      .equ    $0016
  
  asset_Rock4         .incbin "bin/ROCK4.BIN"
  size_Rock4          .equ    $0022
  asset_Rock4_Pal     .incbin "bin/ROCK4-PALETTE.BIN"
  size_Rock4_Pal      .equ    $0016
  
  asset_PShot         .incbin "bin/PSHOT.BIN"
  size_PShot          .equ    $0022
  asset_PShot_Pal     .incbin "bin/PSHOT-PALETTE.BIN"
  size_PShot_Pal      .equ    $001c

  asset_PlayShip      .incbin "bin/SHIP.BIN"
  size_PlayShip       .equ    $0802
  asset_PlayShip_Pal  .incbin "bin/SHIP-PALETTE.BIN"
  size_PlayShip_Pal   .equ    $0022

.code

.function load_assets
  .namespace "load_assets"
    .data
    .code
      copy_asset_macro(asset_Rock2, size_Rock2, (IMGLARGEROCK<<5))
      copy_asset_macro(asset_Rock2_Pal, size_Rock2_Pal, $1fa00+(PALLARGEROCK*$20))

      copy_asset_macro(asset_Rock3, size_Rock3, (IMGMEDIUMROCK<<5))
      copy_asset_macro(asset_Rock3_Pal, size_Rock3_Pal, $1fa00+(PALMEDIUMROCK*$20))

      copy_asset_macro(asset_Rock4, size_Rock4, (IMGSMALLROCK<<5))
      copy_asset_macro(asset_Rock4_Pal, size_Rock4_Pal, $1fa00+(PALSMALLROCK*$20))

      copy_asset_macro(asset_PShot, size_PShot, (IMGPSHOT<<5))
      copy_asset_macro(asset_PShot_Pal, size_PShot_Pal, $1fa00+(PALPSHOT*$20))

      copy_asset_macro(asset_PlayShip, size_PlayShip, (IMGPLAYSHIP00<<5))
      copy_asset_macro(asset_PlayShip_Pal, size_PlayShip_Pal, $1fa00+(PALPLAYSHIP*$20))
  .namespace
.endfunction

.macro copy_asset_macro(asset_ptr, asset_size, vram_addr)
  pushax_ptr(asset_ptr)
  pushax_i(asset_size)
  pushax_i(vram_addr & $ffff)
  pusha_i((vram_addr & $10000)>>16)
  copy_asset()
.endmacro

.function copy_asset
  .namespace "copy_asset"
    .data          
      asset_size  .word $0000
      vram_addr   .word $0000
      vram_bank   .byte $00
      asset_count .word $00
    .code

      ; Grab Params
      popa(vram_bank)
      popax(vram_addr)
      popax(asset_size)
      popax(ptr1)

      ; Burn 2 bytes
      ldwai (asset_count, $0002)  
      adwai(ptr1, $0002)

      ; Setup VRAM copy
      lda vram_bank
      ora #$10
      sta vram_bank
      ldbai (VERA.control , $00)    
      ldwaa (VERA.address, vram_addr)  
      ldbaa (VERA.address_hi, vram_bank)          
      ldy #$00

      @loop

        ; Copy byte to VRAM
        lda(ptr1),y
        sta VERA.data0        

        ; Increment counter        
        adwai(asset_count, $0001)
        adwai(ptr1, $0001)

        ; Compare to size
        cpwaa(asset_count, asset_size)

      bne @loop

  .namespace
.endfunction
