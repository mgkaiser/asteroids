; Definition of List record
list_head   .equ 0
list_tail   .equ 2

; Definition of Node Record
node_next         .equ  0
node_prev         .equ  2
node_nodeType     .equ  4
node_originX      .equ  5
node_originY      .equ  7
node_theta        .equ  9
node_spriteImage  .equ  10
node_r            .equ  12
node_sprite       .equ  14
node_lastX        .equ  15
node_lastY        .equ  17
node_framesToLive .equ  19
node_thrustTheta  .equ  21
node_thrustR      .equ  22
node_frameDelay   .equ  24
node_frameReset   .equ  25
node_spriteAddr   .equ  26
node_spriteAttr   .equ  28
node_spriteWidth  .equ  29
node_spriteHeight .equ  30

; Node Types
PLAYER            .equ 0x00
PSHOT             .equ 0x01
LROCK             .equ 0x02
MROCK             .equ 0x03
SROCK             .equ 0x04
SALIEN            .equ 0x05
LALIEN            .equ 0x06
ASHOT             .equ 0x07

; Valid Height
SPRITEH8          .equ 0x00
SPRITEH16         .equ 0x40
SPRITEH32         .equ 0x80
SPRITEH64         .equ 0xc0

; Valid Width
SPRITEW8          .equ 0x00
SPRITEW16         .equ 0x10
SPRITEW32         .equ 0x20
SPRITEW64         .equ 0x30

; Definition of image sizes
SIZE32X32         .equ  ($0200>>5)&$ffff
SIZE16X16         .equ  ($0080>>5)&$ffff
SIZE8X8           .equ  ($0040>>5)&$ffff

; Definition of images
IMGLARGEROCK      .equ ($13000>>5)&$ffff
IMGMEDIUMROCK     .equ IMGLARGEROCK+SIZE32X32
IMGSMALLROCK      .equ IMGMEDIUMROCK+SIZE16X16
IMGPSHOT          .equ IMGSMALLROCK+SIZE8X8
IMGPLAYSHIP00     .equ IMGPSHOT+SIZE8X8
IMGPLAYSHIP01     .equ IMGPLAYSHIP00+SIZE16X16
IMGPLAYSHIP02     .equ IMGPLAYSHIP01+SIZE16X16
IMGPLAYSHIP03     .equ IMGPLAYSHIP02+SIZE16X16
IMGPLAYSHIP04     .equ IMGPLAYSHIP03+SIZE16X16
IMGPLAYSHIP05     .equ IMGPLAYSHIP04+SIZE16X16
IMGPLAYSHIP06     .equ IMGPLAYSHIP05+SIZE16X16
IMGPLAYSHIP07     .equ IMGPLAYSHIP06+SIZE16X16
IMGPLAYSHIP08     .equ IMGPLAYSHIP07+SIZE16X16
IMGPLAYSHIP09     .equ IMGPLAYSHIP08+SIZE16X16
IMGPLAYSHIP10     .equ IMGPLAYSHIP09+SIZE16X16
IMGPLAYSHIP11     .equ IMGPLAYSHIP10+SIZE16X16
IMGPLAYSHIP12     .equ IMGPLAYSHIP11+SIZE16X16
IMGPLAYSHIP13     .equ IMGPLAYSHIP12+SIZE16X16
IMGPLAYSHIP14     .equ IMGPLAYSHIP13+SIZE16X16
IMGPLAYSHIP15     .equ IMGPLAYSHIP14+SIZE16X16

; Definition of palettes
PALLARGEROCK      .equ 1
PALMEDIUMROCK     .equ 2
PALSMALLROCK      .equ 3
PALPSHOT          .equ 4
PALPLAYSHIP       .equ 5

; Define max frame rate for player
PLAYFRAMEMAX      .equ 10

; BAM for Sprite Allocation
spriteAllocated .storage $20, $00

.code

.macro setSprite(spriteAddr, spriteImage, xPos, yPos, spriteAttr)
  ldbai (VERA.control , $00)    
  ldwaa (VERA.address, spriteAddr)  
  ldbai (VERA.address_hi, $11)          
  ldbaa (VERA.data0, spriteImage)    
  ldbaa (VERA.data0, spriteImage+1)    
  ldbaa (VERA.data0, xPos)    
  ldbaa (VERA.data0, xPos+1)    
  ldbaa (VERA.data0, yPos)    
  ldbaa (VERA.data0, yPos+1)    
  ldbai (VERA.data0, $04)          
  ldbaa (VERA.data0, spriteAttr)      
.endmacro

.macro setSpriteImage(ptr, spriteImage)  
  ldbai (VERA.control , $00)      
  ldy #node_spriteAddr
  lda (ptr),y
  sta VERA.address
  iny
  lda (ptr),y
  sta VERA.address+1
  ldbai (VERA.control, $11)          
  ldbaa (VERA.data0, spriteImage)    
  ldbaa (VERA.data0, spriteImage+1)      
.endmacro

.macro clearSprite(ptr)  
  ldbai (VERA.control , $00)      
  ldy #node_spriteAddr
  lda (ptr),y
  sta VERA.address
  iny
  lda (ptr),y
  sta VERA.address+1
  adwai(VERA.address, $0006)
  ldbai (VERA.control, $11)          
  ldbaa (VERA.data0, $00)      
.endmacro

.macro moveSprite(ptr, xPos, yPos)
  ldbai (VERA.control , $00)      
  ldy #node_spriteAddr
  lda (ptr),y
  sta VERA.address
  iny
  lda (ptr),y
  sta VERA.address+1  
  adwai(VERA.address, $0002)
  ldbai (VERA.control, $11)            
  ldbaa (VERA.data0, xPos)    
  ldbaa (VERA.data0, xPos+1)    
  ldbaa (VERA.data0, yPos)    
  ldbaa (VERA.data0, yPos+1)      
.endmacro

.macro list_init_macro(pList)
  pushax_ptr(pList)      
  list_Init() 
.endmacro

.function list_Init
  .namespace "list_Init"
    .data         
    .code
      ; Unpack the parameters      
      popax(ptr1)  

      ; Initialize
      ldwpz (ptr1, list_head) 
      ldwpz (ptr1, list_tail) 
  .namespace
.endfunction

.macro list_AddLargeRock_Macro(result, pList, originX, originY, theta)    
  pusha_i(32)
  pusha_i(32)
  pushax_i(IMGLARGEROCK)
  pusha_i(SPRITEW32 + SPRITEH32 + PALLARGEROCK)  
  pushax_i($00)
  pusha(theta)
  pushax(originY)
  pushax(originX)
  pusha_i(LROCK)
  pushax_ptr(pList)      
  list_Add()
  resultw(result)
.endmacro

.macro list_AddMedRock_Macro(result, pList, originX, originY, theta)    
  pusha_i(16)
  pusha_i(16)
  pushax_i(IMGMEDIUMROCK)
  pusha_i(SPRITEW16 + SPRITEH16 + PALMEDIUMROCK)  
  pushax_i($00)
  pusha(theta)
  pushax(originY)
  pushax(originX)
  pusha_i(MROCK)
  pushax_ptr(pList)      
  list_Add()
  resultw(result)
.endmacro

.macro list_AddSmallRock_Macro(result, pList, originX, originY, theta)    
  pusha_i(8)
  pusha_i(8)
  pushax_i(IMGSMALLROCK)
  pusha_i(SPRITEW8 + SPRITEH8 + PALSMALLROCK)  
  pushax_i($00)
  pusha(theta)
  pushax(originY)
  pushax(originX)
  pusha_i(SROCK)
  pushax_ptr(pList)      
  list_Add()
  resultw(result)
.endmacro

.macro list_AddPShot_Macro(result, pList, originX, originY, theta)    
  pusha_i(8)
  pusha_i(8)
  pushax_i(IMGPSHOT)
  pusha_i(SPRITEW8 + SPRITEH8 + PALPSHOT)  
  pushax_i($00)
  pusha(theta)
  pushax(originY)
  pushax(originX)
  pusha_i(PSHOT)
  pushax_ptr(pList)      
  list_Add()
  resultw(result)
  ldwpi (ptr2, node_framesToLive, $0064) 
.endmacro

.macro list_AddPlayerShip_Macro(result, pList, originX, originY)  
  pusha_i(16)
  pusha_i(16)  
  pushax_i(IMGPLAYSHIP08)
  pusha_i(SPRITEW16 + SPRITEH16 + PALPLAYSHIP)  
  pushax_i($00)
  pusha_i($08)
  pushax(originY)
  pushax(originX)
  pusha_i(PLAYER)
  pushax_ptr(pList)      
  list_Add()
  resultw(result)  
.endmacro

; l -> *word to List
.macro list_Add_Macro(result, pList, nodeType, originX, originY, theta, r, width, height, palette, spriteImage, h, w)  
  pusha_i(w)
  pusha_i(h)
  pushax_i(spriteImage)
  pusha_i(height + width + palette)  
  pushax(r)
  pusha(theta)
  pushax(originY)
  pushax(originX)
  pusha_i(nodeType)
  pushax_ptr(pList)      
  list_Add()
  resultw(result)
.endmacro

.function list_Add
  .namespace "list_Add"
    .data   
      newNode     .word $0000
      nodeType    .byte $00 
      sprite      .byte $00      
      spriteAddr  .word $0000
      originX     .word $0000
      originY     .word $0000
      theta       .byte $00
      r           .word $0000
      attr        .byte $00      
      spriteImage .word $0000
      height      .byte $00
      width       .byte $00
    .code            
      ; Unpack the parameters      
      popax(ptr1)                   ; l
      popa(nodeType)
      popax(originX)                   
      popax(originY)                   
      popa(theta)
      popax(r)         
      popa(attr) 
      popax(spriteImage)
      popa(height) 
      popa(width) 
      
      ; ptr2 = new Node()
      mempool_alloc()               
      popa(sprite)
      popax(ptr2)
      popax(spriteAddr)
      
      ; Initialize new node
      ldwpz (ptr2, node_next) 
      ldwpz (ptr2, node_prev) 
      ldbpa (ptr2, node_nodeType, nodeType)        
      ldwpa (ptr2, node_originX, originX) 
      ldwpa (ptr2, node_originY, originY) 
      ldbpa (ptr2, node_theta, theta)     
      ldwpa (ptr2, node_r, r)    
      ldbpa (ptr2, node_spriteAttr, attr)      
      ldwpa (ptr2, node_spriteImage, spriteImage)   
      ldbpa (ptr2, node_spriteHeight, height)      
      ldbpa (ptr2, node_spriteWidth, width)      

      ; Defaults
      ldwpi (ptr2, node_lastX, $0000)    
      ldwpi (ptr2, node_lastY, $0000)    
      ldwpi (ptr2, node_framesToLive, $0000)    
      ldwpi (ptr2, node_thrustR, $0000)          
      ldbpa (ptr2, node_thrustTheta, theta)        
      ldbpi (ptr2, node_frameDelay, $0a)    
      ldbpi (ptr2, node_frameReset, $0a)    

      ; Allocate a sprite      
      sdbpr (ptr2, node_sprite)         
      ldbpa (ptr2, node_sprite, sprite) 
      ldwpa (ptr2, node_spriteAddr, spriteAddr)
      
      setSprite (spriteAddr, spriteImage, originX, originY, attr )

      ; if (ptr1->head != NULL)
      cpw_ptr_zero(ptr1, list_head)      
      beq @else1 
      
          ;ptr2->next = ptr1->head;
          ldwpp (ptr2, node_next, ptr1, list_head)            

          ; ptr3 = ptr1->head
          ldwap (ptr3, ptr1, list_head)              

          ;ptr3->prev = ptr2; 
          ldwpa (ptr3, node_prev, ptr2)           
          
          jmp @endif1
      ; else
      @else1

          ; ptr1->tail = ptr2;    
          ldwpa (ptr1, list_tail, ptr2)           

      ; endif
      @endif1

      ; ptr1->head = ptr2
      ldwpa (ptr1, list_head, ptr2)                       

      ; Return ptr2 (newNode) in AX
      returnax(ptr2)      
  .namespace
.endfunction

.macro list_First_macro(result, pList)
  pushax_ptr(pList)      
  list_First()   
  resultw(result)
.endmacro

.function list_First
  .namespace "list_First"
    .data    
    .code            
      ; Unpack the parameters            
      popax(ptr1)                 ; List

      ; Return ptr1->head as AX
      returnax_ptr(ptr1, list_head)         
  .namespace
.endfunction

.macro list_Next_macro(result, pNode)
  pushax(pNode)      
  list_Next()   
  resultw(result)
.endmacro

.function list_Next
  .namespace "list_Next"
    .data
    .code
      ; Unpack the parameters    
      popax(ptr1)                 ; CurrentNode

      ; Return ptr1->next as AX
      returnax_ptr(ptr1, node_next)      
  .namespace
.endfunction

.macro list_Last_macro(result, pList)
  pushax_ptr(pList)      
  list_Last()   
  resultw(result)
.endmacro

.function list_Last
  .namespace "list_Last"
    .data
    .code
      ; Unpack the parameters            
      popax(ptr1)                 ; List

      ; Return ptr1->head as AX
      returnax_ptr(ptr1, list_tail)            
  .namespace
.endfunction

.macro list_Prev_macro(result, pNode)
  pushax(pNode)      
  list_Prev()   
  resultw(result)
.endmacro

.function list_Prev
  .namespace "list_Prev"
    .data
    .code
      ; Unpack the parameters    
      popax(ptr1)                 ; CurrentNode

      ; Return ptr1->prev as AX
      returnax_ptr(ptr1, node_prev) 
      ldy #node_prev+1      
  .namespace
.endfunction

.macro list_Remove_macro(pList, pNode)
  pushax(pNode)    
  pushax_ptr(pList)    
  list_Remove()
.endmacro

.function list_Remove
  .namespace "list_Remove"
    .data
      
    .code
      ; Unpack the parameters          
      popax(ptr1)                 ; List      
      popax(ptr2)                 ; CurrentNode      

      ; if ptr2 == 0 skip everything
      cpw_zero(ptr2)
      beq @skipEverything  
        
        ; Unpack some stuff      
        ldwap (ptr3, ptr2, node_prev)   ; ptr3 = ptr2->prev      
        ldwap (ptr4, ptr2, node_next)   ; ptr4 = ptr2->next               
          
        ; if ptr3 == 0 AND ptr4 == 0    (It's the last remaining node, zero out the list)
        cpwx2_zero (ptr3, ptr4)    
        bne @skip1          
          ldwpz(ptr1, list_head)
          ldwpz(ptr1, list_tail)      
          jmp @endif

        ; if ptr3 == 0                  (It's the first node in the list)
        @skip1      
        cpw_zero(ptr3)      
        bne @skip2              
          ldwpa (ptr1, list_head, ptr4) 
          ldwpz (ptr4, node_prev) 
          jmp @endif

        ; if ptr4 == 0                  (It's the last node in the list)
        @skip2
        cpw_zero(ptr4)
        bne @skip3                       
          ldwpa (ptr1, list_tail, ptr3)
          ldwpz(ptr3, node_next) 
          jmp @endif

        ; Anthing else                  (It's somewhere in the middle of the list)
        @skip3          
          ldwpa (ptr3, node_next, ptr4)  
          ldwpa (ptr4, node_prev, ptr3)        

        @endif
        
        ; Cleanup associated data                  
        clearSprite(ptr2);                

        ; Free the memory for the node        
        pusha_ofs(ptr2, node_sprite)  
        mempool_free()      

      @skipEverything
      
  .namespace
.endfunction
