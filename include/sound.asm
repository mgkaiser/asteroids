.data
  SOUND_PHASE_STOPPED .equ  $00
  SOUND_PHASE_RELEASE .equ  $01
  SOUND_PHASE_DELAY   .equ  $02
  SOUND_PHASE_RUNNING .equ  $ff

  sound_running       .equ  $00
  sound_phase         .equ  $01
  sound_release_count .equ  $02
  sound_frequency     .equ  $03
  sound_waveform      .equ  $05
  sound_volume        .equ  $06
  sound_vol_change    .equ  $08
  sound_freq_change   .equ  $0a
  sound_next_sample   .equ  $0c
  sound_delay         .equ  $0d

  sound_ptr_low
    sound_count .var  0
    .loop 16   
      .byte <(sound_data+(sound_count*16))
      sound_count=sound_count+1
    .endloop

  sound_ptr_high  
    sound_count = 0
    .loop 16   
      .byte >(sound_data+(sound_count*16))
      sound_count=sound_count+1
    .endloop

  sound_data        .storage $100, $00

  vera_data_store   .storage $04, $00
  
  sounds_envelopes
  ping_envelope		  .byte 100,199,9,160,0,63,161,0,0,0,0,0
  shoot_envelope    .byte 20,107,17,224,0,63,0,3,0,0,0,0
  zap_envelope  		.byte 37,232,10,96,0,63,179,1,100,0,0,0
  explode_envelope  .byte 20,125,5,224,0,63,10,0,0,0,0,0,0

  SOUND_PING        .equ  ping_envelope - sounds_envelopes
  SOUND_SHOOT       .equ  shoot_envelope - sounds_envelopes
  SOUND_ZAP         .equ  zap_envelope - sounds_envelopes
  SOUND_EXPLODE     .equ  explode_envelope - sounds_envelopes  

.code

.function doSound
  .namespace "doSound"
    .data      
    .code

      ; Save VERA registers
      lda VERA.address
      sta vera_data_store
      lda VERA.address+1
      sta vera_data_store+1
      lda VERA.address_hi
      sta vera_data_store+2
      lda VERA.control
      sta vera_data_store+3

      ; Loop through the channels
      ldx #$00      
      @doSound_Loop      

        ; Get pointer to channel
        lda sound_ptr_low,x
        sta int_ptr1
        lda sound_ptr_high,x
        sta int_ptr1+1        

        ; Dispatch the phase
        ldy #sound_phase
        lda (int_ptr1),y
        cmp #SOUND_PHASE_RUNNING
        beq @doSound_Play
        cmp #SOUND_PHASE_RELEASE
        beq @doSound_Release
        cmp #SOUND_PHASE_DELAY
        beq @doSound_Delay
        jmp @doSound_End

        ; Do the release
        @doSound_Release          

          ldy #sound_release_count
          lda (int_ptr1),y
          bne @doSound_ReleaseLoop            

            ; Set VERA Address to VOLUME (channel + 2) [(channel * 4) + $f9c2]
            ldbai (VERA.control , $00)    
            txa
            clc
            rol
            rol
            sta VERA.address
            lda #$00
            sta VERA.address+1
            adwai(VERA.address, $f9c2)
            ldbai (VERA.address_hi, $11)    

            ; Silence the sound
            lda #$00
            sta VERA.data0        
            
            ; If there is a next sample next phase is SOUND_PHASE_DELAY
            ldy #sound_next_sample
            lda (int_ptr1),y
            beq @doSound_Stopped            
              ldy #sound_phase
              lda #SOUND_PHASE_DELAY            
              sta (int_ptr1),y
              jmp @doSound_End

            ; Else next phase is SOUND_PHASE_STOPPED
            @doSound_Stopped
              ldy #sound_phase
              lda #SOUND_PHASE_STOPPED            
              sta (int_ptr1),y
              jmp @doSound_End        

          @doSound_ReleaseLoop

            ; Decrease 16 bit volume
            sec
            ldy #sound_volume
            lda (int_ptr1),y
            ldy #sound_vol_change
            sbc (int_ptr1),y
            ldy #sound_volume
            sta (int_ptr1),y
            ldy #sound_volume+1
            lda (int_ptr1),y
            ldy #sound_vol_change+1
            sbc (int_ptr1),y
            ldy #sound_volume+1
            sta (int_ptr1),y

            ; Decrease 16 bit frequency
            sec
            ldy #sound_frequency
            lda (int_ptr1),y
            ldy #sound_freq_change
            sbc (int_ptr1),y
            ldy #sound_frequency
            sta (int_ptr1),y
            ldy #sound_frequency+1
            lda (int_ptr1),y
            ldy #sound_freq_change+1
            sbc (int_ptr1),y
            ldy #sound_frequency+1
            sta (int_ptr1),y

            ; Set VERA Address to Channel [(channel * 4) + $f9c0]
            ldbai (VERA.control , $00)    
            txa
            clc
            rol
            rol
            sta VERA.address
            lda #$00
            sta VERA.address+1
            adwai(VERA.address, $f9c0)
            ldbai (VERA.address_hi, $11)          

            ; Set frequency
            ldy #sound_frequency
            lda (int_ptr1),y
            sta VERA.data0
            iny
            lda (int_ptr1),y
            sta VERA.data0

            ; Set volume
            ldy #sound_volume+1
            lda (int_ptr1),y
            ora #$c0
            sta VERA.data0

            ; Decrement release count
            ldy #sound_release_count
            lda (int_ptr1),y
            dec a
            sta (int_ptr1),y

        jmp @doSound_End        

        ;Do Play
        @doSound_Play              

          ; Set phase to release
          ldy #sound_phase
          lda #SOUND_PHASE_RELEASE
          sta(int_ptr1), y

          ; Set VERA Address to Channel [(channel * 4) + $f9c0]
          ldbai (VERA.control , $00)    
          txa
          clc
          rol
          rol
          sta VERA.address
          lda #$00
          sta VERA.address+1
          adwai(VERA.address, $f9c0)
          ldbai (VERA.address_hi, $11)          

          ; Set frequency
          ldy #sound_frequency
          lda (int_ptr1),y
          sta VERA.data0
          iny
          lda (int_ptr1),y
          sta VERA.data0

          ; Set volume
          ldy #sound_volume+1
          lda (int_ptr1),y
          ora #$c0
          sta VERA.data0

          ; Set waveform
          ldy #sound_waveform
          lda (int_ptr1),y
          sta VERA.data0
          jmp @doSound_End

        @doSound_Delay          

          ; Decrement Delay
          ldy #sound_delay
          lda(int_ptr1),y
          dec a
          sta(int_ptr1),y
          lda(int_ptr1),y
          cmp #$00
          bne @doSound_DelayNotDone

            ; When zero, enqueue next sound
            phx                               ; x into the stack
            ldy #sound_next_sample
            lda(int_ptr1),y
            ply                               ; x back out of the stack into y
            phy                               ; x back into the stack
            tax
            playSound()
            plx                               ; x back out of the stack

          @doSound_DelayNotDone

          jmp @doSound_End

        ; Do NotPlaying (or end of other stuff)
        @doSound_End

        ; Move on to next channel        
        inx        
        cpx #$10
      bne @doSound_Loop

      ; Restore VERA registers      
      lda vera_data_store
      sta VERA.address      
      lda vera_data_store+1
      sta VERA.address+1      
      lda vera_data_store+2
      sta VERA.address_hi      
      lda vera_data_store+3
      sta VERA.control

  .namespace
.endfunction
  
.macro playSound_macro(sample, channel)
  ldx #sample
  ldy #channel
  playSound()
.endmacro
; sound   in X
; channel in y
.function playSound
  .namespace "playSound"
    .data      
    .code

      ; Get pointer to channel
      lda sound_ptr_low,y
      sta reg00
      lda sound_ptr_high,y
      sta reg00+1

      ; Store the sound into the channel
    	ldy #sound_release_count
      @playSoundLoop
        lda sounds_envelopes,x
        sta (reg00),y
        inx
        iny
        cpy #$0e
      bne @playSoundLoop

      ; Start playing it
      ldy #sound_phase
      lda #SOUND_PHASE_RUNNING
      sta (reg00),y
  .namespace
.endfunction