;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stack Routines	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Push params before function call, pop params out inside the call
;
; If you're going to call functions recursively, push the existing 
; value of all local variables after popping params and pop the 
; values before returning
;
; Assume all functions destroy all registers
;
; Params can be:
;   A byte
;   A word
;   A dword
;
; Functions return:
;   A byte in A
;   A word in AX
;   A dword in AXYZ

.data

; Stack
STACK_SIZE  .equ $ff
sptr 		    .equ $2e
stack	      .equ $0400

.code
			
; Initialize the param stack			
.function initstack
	lda #STACK_SIZE
	sta sptr
.endfunction

; Push a
.function pushbyte
	ldy sptr
	sta stack,y
	dey
	sty sptr
.endfunction

; Pop a
.function popbyte
	ldy sptr
	iny
	lda stack,y
	sty sptr
.endfunction

; Push ax
.function pushword
	ldy sptr
	sta stack,y
	dey
	txa
	sta stack,y
	dey
	sty sptr
.endfunction	

; Pop xa
.function popword
	ldy sptr
	iny
	lda stack,y
	tax
	iny
	lda stack,y
	sty sptr
.endfunction

.macro returnax(value1)
  lda value1
  ldx value1+1
.endmacro

.macro returna(value1)
  lda value1  
.endmacro

.macro returnax_ptr(value1, ofs1)
	ldy #ofs1+1
	lda (value1),y
	tax
	dey          
	lda (value1),y  
.endmacro

.macro pushax (value1)  
  ldwax (value1)
  pushword()
.endmacro

.macro pushax_ptr (value1)    
  lda #(value1 & $00ff)
  ldx #(value1 & $ff00) >> 8  
  pushword()
.endmacro

.macro pushax_i (value1)    
  lda #(value1 & $00ff)
  ldx #(value1 & $ff00) >> 8  
  pushword()
.endmacro

.macro popax (value1)
  popword()
  sta value1
  stx value1+1
.endmacro

.macro pusha (value1)  
  lda value1
  pushbyte()
.endmacro

.macro pusha_i (value1)  
  lda #value1
  pushbyte()
.endmacro

.macro pusha_ofs (value1, ofs1)  
  ldy #ofs1
  lda(value1),y
  pushbyte()
.endmacro

.macro pushax_ofs (value1, ofs1)  
  ldy #ofs1+1
  lda(value1),y
  tax
  dey
  lda(value1),y
  pushword()
.endmacro

.macro popa (value1)  
  popbyte()
  sta value1
.endmacro