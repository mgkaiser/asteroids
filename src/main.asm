.target "65C02"
.format "PRG"
.encoding "ascii","upper"

.setting "AfterBuild", "cmd /c copy {0} C:\\x16emu_win-r41\\drive\\ASTEROIDS\\ASTEROIDS"
.setting "HandleLongBranch", true

.include "16bit.asm"
.include "vera.asm"	
.include "zppointers.asm"	
.include "basicheader.asm"	
.include "sound.asm"
.include "joy.asm"
.include "print.asm"
.include "linkedlist.asm"
.include "trig.asm"           ; Pre-calculate tables in basic and store as assets
.include "assets.asm"
.include "memalloc.asm"
.include "stack.asm"

; ----------------------------------------
; TODO
; ----------------------------------------
; Aliens!!!
; Backround sound
; Extra guy at 10000
; Player can die - Remember thrustR to 0 when new player spawns

; ----------------------------------------
; Global data
; ----------------------------------------
.data
  oldIrq          .word     $0000
  frame           .byte     FALSE
  frameCounter    .byte     $00
  l               .storage  $0004, $00
  rockCount       .byte     $00
  score           .storage  $0003, $00
  level           .byte     $01
  rockResetCount  .byte     $00
  lives           .byte     $00
  joy             .word     $0000
  xPos            .word     $0000
  yPos            .word     $0000
  pShotCount      .byte     $00
  
; ----------------------------------------
; Code 
; ----------------------------------------
.code

interruptHandler:
  sei
  
  ; if (VERA.irq_flags & 0x01)
  lda VERA.irq_flags
  and #$01
  cmp #$01
  bne @irqend

    ; frame = TRUE
    ldbai (frame, TRUE)

    ; frameCounter++
    inc frameCounter

    ; Call the sound effect handler
    doSound()

    ; Change the border color
    ldbai (VERA.control, $00)
    ldbai (VERA.display.border, $00)
    ldbai (VERA.control, $02)
    ldbai (VERA.display.hstart, $04)
    ldbai (VERA.control, $00)  

    ; Ack the interrupt                      
    ldbai (VERA.irq_flags, $01)
    
  @irqend
  jmp (oldIrq)

; Main entry point
.function start 

  .namespace "start"

    .data
      count .word $0000
    .code

    ; Initialization
    initstack()           ; Setup the parameter stack
    mempool_init()        ; Setup the storage for the linked list      
    buildRandomNumbers()  ; Build random number tables
    load_assets()       

    ; Set screen to 40 col mode and clear to black $1dff
    lda #$03
    clc
    jsr $ff5d  
    ldbai (count, $00)    
    ldbai (VERA.control , $00)    
    ldwai (VERA.address, $b000)  
    ldbai (VERA.address_hi, $11)          
    @loop
      ldbai (VERA.data0, $00)    
      adwai (count, $0001)
      cpwai (count, $1dff)
    bne @loop
    
    ; Set the interrupt handler
    initInterrupt()

    ; Initialize Sprites
    initSprites();    
    
    ; Main loop of game
    initGame()
    mainLoop()

  .namespace
.endfunction

.function initGame

  ; Start on level 1
  lda #$01
  sta level    
  initRocks_macro(level);

  ; Set score to zero, in decimal mode
  sed
  lda #$00
  sta score
  sta score+1
  sta score+2
  cld

  ; Set Lives to 3
  lda #$03
  sta lives

.endfunction

.function initInterrupt
  .namespace "initInterrupt"
    .data
    .code
      sei
      ldwaa (oldIrq, $0314)
      ldwai ($0314, interruptHandler)              
      ldbai (VERA.irq_enable, $01)
      ldbai (VERA.irq_raster, 240)
      ldbai (frameCounter, $00)
      ldbai (frame, FALSE)
      cli
  .namespace
.endfunction

.function initSprites
  .namespace "initSprites"
    .data
      result    .word $0000
      originX   .word $00a0
      originY   .word $0064            
    .code

      ; Enable sprites      
      ldbai(VERA.control, $00)    
      ldbai(VERA.display.video, $61)

      list_AddPlayerShip_Macro(result, l, originX, originY)    
  .namespace
.endfunction

.macro initRocks_macro(numRocks)
  pusha(numRocks)
  initRocks()
.endmacro
.function initRocks
  .namespace "initRocks"
    .data
      numRocks  .byte $00
      random    .byte $00
      theta     .byte $00
      result    .word $0000      
    .code

      popa(numRocks)
      inc numRocks

      lda numRocks
      sta rockCount

      @loop

        ; Grab random numbers
        ldx random
        lda thetarand_table,x
        sta theta
        lda xrand_table_low,x
        sta xPos
        lda xrand_table_high,x
        sta xPos+1
        lda yrand_table,x
        sta yPos
        lda #$00
        sta yPos+1
        inc random

        ; Create the rock
        list_AddLargeRock_Macro(result, l, xPos, yPos, theta)    
        
        ; Next rock
        dec numRocks
      bne @loop
      
  .namespace
.endfunction

.function largeRockHit
  .namespace "largeRockHit"
    .data      
      theta     .byte $00
      xPos2     .word $0000
      yPos2     .word $0000
      result    .word $0000
    .code      

      ; Get coordinates
      ldy #node_lastX
      lda(ptr8),Y
      sta xPos2
      iny
      lda(ptr8),Y
      sta xPos2+1
      ldy #node_lastY
      lda(ptr8),Y
      sta yPos2
      iny
      lda(ptr8),Y
      sta yPos2+1
      
      ; Add Medium Rocks
      ldy #node_theta
      lda (ptr8),y
      inc a
      and #$0f      
      sta theta      
      list_AddMedRock_Macro(result, l, xPos2, yPos2, theta)    
      ldy #node_theta
      lda (ptr8),y
      dec a
      and #$0f      
      sta theta      
      list_AddMedRock_Macro(result, l, xPos2, yPos2, theta) 

      ; Remove large rock
      list_Remove_macro(l, ptr8)

      ; Update rock Count
      inc rockCount   

      ; Add to the score
      sed      
      clc
      lda score
      adc #$25
      sta score
      lda score+1
      adc #$00
      sta score+1
      lda score+2
      adc #$00
      sta score+2
      cld

  .namespace
.endFunction

.function mediumRockHit
  .namespace "mediumRockHit"
    .data      
      theta     .byte $00
      xPos2     .word $0000
      yPos2     .word $0000
      result    .word $0000
    .code
      
      ; Get coordinates
      ldy #node_lastX
      lda(ptr8),Y
      sta xPos2
      iny
      lda(ptr8),Y
      sta xPos2+1
      ldy #node_lastY
      lda(ptr8),Y
      sta yPos2
      iny
      lda(ptr8),Y
      sta yPos2+1
      
      ; Add Medium Rocks
      ldy #node_theta
      lda (ptr8),y
      inc a
      and #$0f      
      sta theta      
      list_AddSmallRock_Macro(result, l, xPos2, yPos2, theta)    
      ldy #node_theta
      lda (ptr8),y
      dec a
      and #$0f      
      sta theta      
      list_AddSmallRock_Macro(result, l, xPos2, yPos2, theta) 

      ; Remove large rock
      list_Remove_macro(l, ptr8)

      ; Update rock Count
      inc rockCount   

      ; Add to the score      
      sed      
      clc
      lda score
      adc #$50
      sta score
      lda score+1
      adc #$00
      sta score+1
      lda score+2
      adc #$00
      sta score+2
      cld      
      
  .namespace
.endFunction

.function smallRockHit
  .namespace "smallRockHit"
    .data      
    .code            

      ; Remove large rock
      list_Remove_macro(l, ptr8)

      ; Update rock Count
      dec rockCount   

      ; Add to the score
      sed      
      clc
      lda score
      adc #$00
      sta score
      lda score+1
      adc #$01
      sta score+1
      lda score+2
      adc #$00
      sta score+2
      cld
      
  .namespace
.endFunction

.macro displayDigits(variable, bytes)

.if bytes > 1
  ldx #bytes

  @loop

    ; Next Byte
    dex
  
    ; High Nybble
    lda variable,x
.endif    

.if bytes <= 1
    lda variable
.endif    
    pha
    and #$f0
    clc
    ror
    ror
    ror
    ror        
    tay
    lda digits,y
    sta VERA.data0
    lda #$01
    sta VERA.data0

    ; Low Nybble
    pla
    and #$0F
    tay
    lda digits,y
    sta VERA.data0
    lda #01
    sta VERA.data0

.if bytes > 1
    ; Is this zero?
    cpx #$00        

  bne @loop
.endif
.endmacro

.function displayScore
  .namespace "displayScore"
    .data      
      .encoding "screencodecommodore","upper"
      digits  .byte "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", $01, $02, $03, $04, $05, $06
      .encoding "ascii","upper"
      temp    .word $0000
    .code

      ; Setup VERA
      ldbai (VERA.control , $00)    
      ldwai (VERA.address, $b000)  
      ldbai (VERA.address_hi, $11)                    
      displayDigits(score, 3)      
      
      ; Setup VERA
      ldbai (VERA.control , $00)    
      ldwai (VERA.address, $b048)  
      ldbai (VERA.address_hi, $11) 
      displayDigits(lives, 1)

      ; Setup VERA
      ;ldbai (VERA.control , $00)    
      ;ldwai (VERA.address, $b100)  
      ;ldbai (VERA.address_hi, $11)       
      ;displayDigits(pShotCount, 1)

  .namespace
.endfunction

.macro decShotCount()
  lda pShotCount                          
  dec a
  cmp #$00
  bpl @shotFixElse
  cmp #pShotCountMax
  bmi @shotFixElse
  beq @shotFixElse
    ; Force it to 0
    lda #$00
  @shotFixElse
    ; Do Nothing because pShotCount >=0 and <=pShotCountMax
  @shotFixEndIf
  sta pShotCount
.endmacro

.macro incShotCount()
  lda pShotCount                          
  inc a
  cmp #$00
  bpl @shotFixElse
  cmp #pShotCountMax
  bmi @shotFixElse
  beq @shotFixElse
    ; Force it to 0
    lda #$00
  @shotFixElse
    ; Do Nothing because pShotCount >=0 and <=pShotCountMax
  @shotFixEndIf
  sta pShotCount
.endmacro

.function mainLoop
  .namespace "mainLoop"
    .data      
      playerImgTemp         .word $0000
      playerTurnCountdown   .byte $00
      buttonLatch           .byte FALSE
      buttonLatchCountdown  .byte $00
      shotX                 .word $0000
      shotY                 .word $0000
      shotTheta             .byte $00
      largeRockDelay        .byte largeRockDelayMax
      medRockDelay          .byte medRockDelayMax
      smallRockDelay        .byte smallRockDelayMax

      ; Constants for state machine
      buttonLatchCountdownMax .equ $03      
      pShotCountMax           .equ $04
      playerTurnReset         .equ $03
      largeRockDelayMax       .equ $03
      medRockDelayMax         .equ $02
      smallRockDelayMax       .equ $01

      ; Limits of screen
      xMin .equ $ffe0
      xMax .equ $013e
      yMin .equ $ffe0
      yMax .equ $00ee
    .code

    ; Do this forever
    @loop

      ; Poll the joystick
      joy_read(joy)      

      ; Reset the board if needed
      lda rockCount
      bne @skipRockReset
        inc rockResetCount
        lda rockResetCount
        cmp #100
        bne @skipRockReset
          inc level
          initRocks_macro(level)
          lda #00
          sta rockResetCount
      @skipRockReset

      ; Decrease the rock delay
      dec largeRockDelay
      dec medRockDelay
      dec smallRockDelay           

      ; Move First
      list_First_macro(ptr7, l)      
      cpwai(ptr7, $0000)
      beq @done      
      @nextLoop        
        
        ; Convert polar coordinates to cartisian corrdinates
        polarToX_ptr_macro(xPos, ptr7, node_originX, node_r, node_theta)  
        polarToY_ptr_macro(yPos, ptr7, node_originY, node_r, node_theta)  

        ; Is the node type PLAYER?
        cpwbi_ofs (ptr7, node_nodetype, PLAYER)
        bne @skipPlayer

          ; Display the score - Do this on the player node because the player node always exists and we can debug the player
          displayScore()

          ; if playerTurnCountdown == 0
          lda playerTurnCountdown
          bne @skipTurn

            ; Turn to the left, only turn if Player Turn Couner == 0
            lda joy
            and #JOY_LEFT_MASK
            bne @skipLeft
                                          
              ; ptr7->node_thrustTheta++, if ptr7->node_thrustTheta > $0f then ptr7->node_thrustTheta = $00
              ldy #node_thrustTheta
              lda (ptr7),y
              inc a
              and #$0f
              sta (ptr7),y

              ;setSpriteImage(temp->sprite,IMGPLAYSHIP00+((temp->entity.thrustTheta)*SIZE16X16));
              clc
              rol
              rol
              sta playerImgTemp                     ; playerImgTemp = ptr7->node_thrustTheta
              lda #$00
              sta playerImgTemp+1              
              adwai (playerImgTemp, IMGPLAYSHIP00)  ; playerImgTemp += IMGPLAYSHIP00
              setSpriteImage(ptr7, playerImgTemp)   ; set the image

            @skipLeft          

            ; Turn to the right, only turn if Player Turn Couner == 0
            lda joy
            and #JOY_RIGHT_MASK
            bne @skipRight
                            
              ; ptr7->node_thrustTheta--, if ptr7->node_thrustTheta < $00 then ptr7->node_thrustTheta = $0f
              ldy #node_thrustTheta
              lda (ptr7),y
              dec a
              and #$0f
              sta (ptr7),y

              ;setSpriteImage(temp->sprite,IMGPLAYSHIP00+((temp->entity.thrustTheta)*SIZE16X16));
              clc
              rol
              rol
              sta playerImgTemp                     ; playerImgTemp = ptr7->node_thrustTheta
              lda #$00
              sta playerImgTemp+1                            
              adwai (playerImgTemp, IMGPLAYSHIP00)  ; playerImgTemp += IMGPLAYSHIP00
              setSpriteImage(ptr7, playerImgTemp)   ; set the image                                      

            @skipRight

            ; Joystick up
            lda joy
            and #JOY_UP_MASK          
            bne @upEndIf

              ; Set thrustR to 1
              lda #$01
              ldy #node_thrustR
              sta (ptr7),y

              ; Do the thrust stuff
              ldy #node_thrustTheta
              lda (ptr7),y
              ldy #node_theta
              cmp (ptr7),y
              beq @thrustThetaElse   
                
                ; ptr7->node_theta = ptr7->node_thrustTheta               
                ldy #node_theta
                sta (ptr7),y
                
                ; Rebase to current position
                ldwpa (ptr7, node_originX, xPos) 
                ldwpa (ptr7, node_originY, yPos)                 
                ldbpi (ptr7, node_r, $00)                

                ; Set frame delay and frame reset to $0a
                ldbpi (ptr7, node_frameReset, $0a)                
                ldbpi (ptr7, node_frameDelay, $0a)                                

                jmp @thrustThetaEndIf

              @thrustThetaElse

                ; Accelerate TODO: Consider incrementing thrustR once frameReset == 0
                ldy #node_frameReset
                lda (ptr7),y
                cmp#$00
                bmi @decFrameResetElse
                beq @decFrameResetElse

                  ; Reduce FrameReset and Set Frame Delay to Frame Reset
                  dec                  
                  jmp @decFrameResetEndIf

                @decFrameResetElse

                  ; Set it to zero
                  lda #$00

                @decFrameResetEndIf

                sta (ptr7),y
                ldy #node_frameDelay
                sta (ptr7),y

              @thrustThetaEndIf

            @upEndIf

            ; playerTurnCountdown = playerTurnReset
            lda #playerTurnReset
            sta playerTurnCountdown

          @skipTurn

          ; Reset the ship counter
          ldy #node_frameDelay          
          lda (ptr7),y                  
          cmp #$00
          bmi @resetFrameDelayElse
          beq @resetFrameDelayElse          

            ; ptr7->frameDelay--
            dec  
            sta (ptr7),y                    
            jmp @resetFrameDelayEndIf

          @resetFrameDelayElse

            ; Time to move the ship
            ; ptr7->node_r += ptr7->node_thrustR
            ldy #node_r
            lda (ptr7),y
            ldy #node_thrustR
            clc
            adc (ptr7),y
            ldy #node_r
            sta (ptr7),y

            ; ptr7->frameDelay = ptr7->frameReset
            ldy #node_frameReset
            lda (ptr7),y
            ldy #node_frameDelay
            sta (ptr7),y                                      

          @resetFrameDelayEndIf

          ; playerTurnCountdown--
          dec playerTurnCountdown    

          ; ButtonPress
          lda joy
          and #JOY_BTN_1_MASK          
          bne @buttonElse           ; Button 1 is down

            lda buttonLatch         ; If latch is not pressed         
            bne @buttonEndIf

              lda pShotCount        ; If shotCount is less than max
              cmp #pShotCountMax
              bcs @buttonEndIf

                ; Increase sho count
                incShotCount()

                ; Add the shot
                ldwaa(shotX, xPos)                
                adwai(shotX, $0004)                                     ; shotX = xPos + 4
                ldwaa(shotY, yPos)
                adwai(shotY, $0004)                                     ; shotY = YPos + 4
                ldy #node_thrustTheta
                lda (ptr7),y
                sta shotTheta                                           ; shotTheta = ptr7->node_thrustTheta                                                
                list_AddPShot_Macro(tmp1, l, shotX, shotY, shotTheta)   ; Add Shot    
                lda #TRUE
                sta buttonLatch                                         ; Set the latch
                lda #buttonLatchCountdownMax
                sta buttonLatchCountdown                                ; Reset the countdown                

                ; make sound
                playSound_macro(SOUND_SHOOT, 0)                

            jmp @buttonEndif
          @buttonElse               ; Button 1 is up
            lda buttonLatchCountdown
            bne @buttonLatchElse        ; If buttonLatchCountdown == 0            
              lda #FALSE                  ; Release latch
              sta buttonLatch
              jmp @buttonLatchEndIf
            @buttonLatchElse            ; else
              dec buttonLatchCountdown    ; decrement latch
            @buttonLatchEndIf           ; endif
          @buttonEndIf                
          
          ; If no sprites are colliding
          lda VERA.irq_flags
          and #$f0
          bne @donePlayerCol
                  
          ; Check for collision
          list_First_macro(ptr8, l)      
          cpwai(ptr8, $0000)
          beq @donePlayerCol     
          @nextLoopPlayerCol

            ; Is it a Rock?
            ldy #node_nodetype
            lda (ptr8),y
            cmp #LROCK            
            beq @isARockPlayerCol
            cmp #MROCK
            beq @isARockPlayerCol
            cmp #SROCK
            beq @isARockPlayerCol
            jmp @continuePlayerCol

            ;It is a Rock
            @isARockPlayerCol
              
              ; Did we collide with it?
              objectsCollide()
              beq @NoCollidePlayerCol

                ; Remove the ship
                ; Decrement lives
                ; Set timer to replace ship
                
              @NoCollidePlayerCol
                        
            ; Move on to the next item, don't process
            @continuePlayerCol

            ; Move Next
            list_Next_macro(ptr8, ptr8)                      
            cpwai(ptr8, $0000)
            
          bne @nextLoopPlayerCol
          @donePlayerCol

        @skipPlayer
        
        ; Is the node type LROCK
        cpwbi_ofs (ptr7, node_nodetype, LROCK)
        bne @skipLRock

          ; Has the large rock delay counted down
          lda largeRockDelay
          bne @largeRockDelayEndIf

            ; Increment R
            ldy #node_r
            lda (ptr7),Y
            inc a
            sta (ptr7),Y            

          @largeRockDelayEndIf

        @skipLRock

        ; Is the node type MROCK
        cpwbi_ofs (ptr7, node_nodetype, MROCK)
        bne @skipMRock

          ; Has the medium rock delay counted down
          lda medRockDelay
          bne @mediumRockDelayEndIf

            ; Increment R
            ldy #node_r
            lda (ptr7),Y
            inc a
            sta (ptr7),Y
                        
          @mediumRockDelayEndIf

        @skipMRock

        ; Is the node type SROCK
        cpwbi_ofs (ptr7, node_nodetype, SROCK)
        bne @skipSRock

          ; Has the medium rock delay counted down
          lda smallRockDelay
          bne @smallRockDelayEndIf

            ; Increment R
            ldy #node_r
            lda (ptr7),Y
            inc a
            sta (ptr7),Y            

          @smallRockDelayEndIf

        @skipSRock

        ; Is the node type PSHOT
        cpwbi_ofs (ptr7, node_nodetype, PSHOT)
        bne @skipPShot          

          ; Check for TTL
          ldy #node_framesToLive
          lda (ptr7),y
          dec a
          sta (ptr7),y
          bne @ShotTTLElse
            decShotCount()
            list_Remove_macro(l, ptr7)
            jmp @continue
          @ShotTTLElse            
            ; Increment R * 2
            ldy #node_r
            lda (ptr7),Y
            inc a    
            inc a        
            sta (ptr7),Y
          @ShotTTLEndIf 

          ; No Sprites are colliding
          lda VERA.irq_flags
          and #$f0
          bne @doneShotCol 

          ; Check for collision
          list_First_macro(ptr8, l)      
          cpwai(ptr8, $0000)
          beq @doneShotCol     
          @nextLoopShotCol

            ; Is it a Rock?
            ldy #node_nodetype
            lda (ptr8),y
            cmp #LROCK            
            beq @isARockShotCol
            cmp #MROCK
            beq @isARockShotCol
            cmp #SROCK
            beq @isARockShotCol
            jmp @continueShotCol

            ;It is a Rock
            @isARockShotCol              

              ; Did we collide with it?
              objectsCollide()
              beq @NoCollideShotCol

                ; Remove the shot
                decShotCount()
                list_Remove_macro(l, ptr7)   

                ; make sound
                playSound_macro(SOUND_EXPLODE, 1)

                ; Which rock did we hit?
                ldy #node_nodetype
                lda (ptr8),y

                ; Hit a Large Rock                
                cmp #LROCK            
                bne @checkMedRock

                  ; Split the rock
                  largeRockHit()

                  jmp @DoneRocks                  
                
                ; Hit a Medium Rock
                @checkMedRock
                cmp #MROCK
                bne @checkSmallRock
                  
                  ; Split the rock  
                  mediumRockHit()                
            
                  jmp @DoneRocks
                
                ; Hit a Small Rock
                @checkSmallRock
                cmp #SROCK
                bne @DoneRocks

                  ; Split the rock
                  smallRockHit()

                @DoneRocks
                             
              @NoCollideShotCol
                        
            ; Move on to the next item, don't process
            @continueShotCol

            ; Move Next
            list_Next_macro(ptr8, ptr8)                      
            cpwai(ptr8, $0000)
            
          bne @nextLoopShotCol
          @doneShotCol

        @skipPShot  
        
        ; if xpos < xMin
        lda xPos+1
        cmp #>xMin
        bne @skipxlt2
        lda xPos
        cmp #<xMin      
        bcs @skipxlt2        
          ldwai (xPos, xMax)
          ldwpa (ptr7, node_originX, xPos) 
          ldwpa (ptr7, node_originY, yPos) 
          ldwpi (ptr7, node_r, $00)   
        @skipxlt2

        ; if xPos > xMax
        lda xPos+1
        cmp #>xMax
        bne @skipxgt318
        lda xPos
        cmp #<xMax        
        bcc @skipxgt318
        beq @skipxgt318
          ldwai (xPos, xMin)
          ldwpa (ptr7, node_originX, xPos) 
          ldwpa (ptr7, node_originY, yPos) 
          ldwpi (ptr7, node_r, $00)   
        @skipxgt318

        ; if ypos < yMin
        lda yPos+1
        cmp #>yMin
        bne @skipylt21
        lda yPos
        cmp #<yMin      
        bcs @skipylt21        
          ldwai (yPos, yMax)
          ldwpa (ptr7, node_originX, xPos) 
          ldwpa (ptr7, node_originY, yPos) 
          ldwpi (ptr7, node_r, $00)   
        @skipylt21

        ; if ypos > yMax
        lda yPos+1
        cmp #>yMax
        bne @skipygt238
        lda yPos 
        cmp #<yMax      
        bcc @skipygt238
        beq @skipygt238
          ldwai (yPos, yMin)
          ldwpa (ptr7, node_originX, xPos) 
          ldwpa (ptr7, node_originY, yPos) 
          ldwpi (ptr7, node_r, $00)   
        @skipygt238

        ; If r<16, rebase
        ldy #node_r
        lda (ptr7),Y
        cmp #$10
        bcc @skipRebase
          ldwpa (ptr7, node_originX, xPos) 
          ldwpa (ptr7, node_originY, yPos) 
          ldwpi (ptr7, node_r, $00)   
        @skipRebase

        ; Move the entity
        moveSprite(ptr7, xPos, yPos)  
        ldwpa (ptr7, node_lastX, xPos)    
        ldwpa (ptr7, node_lastY, yPos)    

        @continue        
                                
        ; Move Next
        list_Next_macro(ptr7, ptr7)                      
        cpwai(ptr7, $0000)
        
      bne @nextLoop
      @done

      ; Reset the rock delay
      lda largeRockDelay
      bne @skipLargeRockReset
        lda #largeRockDelayMax
        sta largeRockDelay
      @skipLargeRockReset
      lda medRockDelay
      bne @skipMedRockReset
        lda #medRockDelayMax
        sta medRockDelay
      @skipMedRockReset
      lda smallRockDelay
      bne @skipSmallRockReset
        lda #smallRockDelayMax
        sta smallRockDelay
      @skipSmallRockReset

      ; Change Border Color
      ldbai (VERA.control, $00)
      ldbai (VERA.display.border, $02)
      ldbai (VERA.control, $02)
      ldbai (VERA.display.hstart, $04)
      ldbai (VERA.control, $00)      

      ; Wait until frame is not false, then set false again.   Wait for frame to end
      @frameWait
        lda frame
        cmp #FALSE
        beq @frameWait
      ldbai(frame, FALSE)

    jmp @loop
  .namespace
.endfunction

.function objectsCollide
  .namespace "objectsCollide"
    .data
      o1x1  .word $0000
      o1y1  .word $0000
      o1x2  .word $0000
      o1y2  .word $0000
      o2x1  .word $0000
      o2y1  .word $0000
      o2x2  .word $0000
      o2y2  .word $0000
    .code

      ; o1x1 = ptr7->node_lastX
      ; o1x2 = ptr7->node_lastX
      ; o2x1 = ptr8->node_lastX
      ; o2x2 = ptr8->node_lastX
      ldy #node_lastX
      lda (ptr7),y
      sta o1x1
      sta o1x2
      lda (ptr8),Y
      sta o2x1
      sta o2x2
      iny
      lda (ptr7),y
      sta o1x1+1
      sta o1x2+1
      lda (ptr8),Y
      sta o2x1+1
      sta o2x2+1

      ; o1y1 = ptr7->node_lastY
      ; o1y2 = ptr7->node_lastY
      ; o2y1 = ptr8->node_lastY
      ; o2y2 = ptr8->node_lastY
      ldy #node_lastY
      lda (ptr7),y
      sta o1y1
      sta o1y2
      lda (ptr8),Y
      sta o2y1
      sta o2y2
      iny
      lda (ptr7),y
      sta o1y1+1
      sta o1y2+1
      lda (ptr8),Y
      sta o2y1+1
      sta o2y2+1

      ; o1x2 += ptr7->node_spriteWidth
      ; o2x2 += ptr8->node_spriteWidth
      adwaa_ofs_8 (o1x2, ptr7, node_spriteWidth)
      adwaa_ofs_8 (o2x2, ptr8, node_spriteWidth)

      ; o1y2 += ptr7->node_spriteHeight
      ; o2y2 += ptr8->node_spriteHeight
      adwaa_ofs_8 (o1y2, ptr7, node_spriteHeight)
      adwaa_ofs_8 (o2y2, ptr8, node_spriteHeight)

      ; if o1x1 > o2x2 then no collision
      lda o1x1+1
      cmp o2x2+1
      bne @noCollide
      lda o1x1
      cmp o2x2
      bcs @noCollide

      ; if o2x1 > o1x2 then no collision
      lda o2x1+1
      cmp o1x2+1
      bne @noCollide
      lda o2x1
      cmp o1x2
      bcs @noCollide

      ; if o1x1 > o2x2 then no collision
      lda o1y1+1
      cmp o2y2+1
      bne @noCollide
      lda o1y1
      cmp o2y2
      bcs @noCollide

      ; if o2x1 > o1x2 then no collision
      lda o2y1+1
      cmp o1y2+1
      bne @noCollide
      lda o2y1
      cmp o1y2
      bcs @noCollide

      ; A collision occured
      lda #TRUE
      rts

      ; No collision occurred
      @noCollide
      lda #FALSE
  .namespace
.endfunction


