.data 
  petscii .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46
.code

.macro print1_macro(string1)	
    pushax_ptr(string1)
	pusha_i(1)
	print();  
.endmacro

.macro print1_macro(string1, string2)	
	pushax_ptr(string2)
    pushax_ptr(string1)
	pusha_i(2)
	print();  
.endmacro

.macro print2_macro(string1, string2)	
    pushax_ptr(string2)
    pushax_ptr(string1)
	pusha_i(3)
	print();  
.endmacro

.macro print3_macro(string1, string2, string3)
	pushax_ptr(string3)
    pushax_ptr(string2)
    pushax_ptr(string1)
	pusha_i(3)
	print();  
.endmacro

.macro print5_macro(string1, string2, string3, string4, string5)
	pushax_ptr(string5)
	pushax_ptr(string4)
	pushax_ptr(string3)
    pushax_ptr(string2)
    pushax_ptr(string1)
	pusha_i(5)
	print();  
.endmacro

; Make print take multiple params
.function print
	.namespace "print"
		.data
			ptrTemp    	.word $0000
			count 			.byte $00
		.code
			; preserve a, y, stack, and ptr1
			pha
			phy
			php
			ldwaa(ptrTemp, ptr1)			

			; Retrieve param count
			popa(count)

			@loop
			
				; Retrieve param into ptr1			
				popax(ptr1)

				ldy #$00
				@9002
						lda (ptr1),y
						cmp #$00
						beq @9001
						jsr $ffd2
						iny
				bne @9002
				@9001

				;count--
				dec count
			bne @loop
			
			;Restore a, y, stack, and ptr1
			ldwaa(ptr1, ptrTemp)			
			plp
			ply
			pla
	.namespace
.endfunction

.macro wordToString_macro(pString, value)
	pushax(value)
	pushax_ptr(pString)
    wordToString();
.endmacro

.function wordToString
	.namespace "wordToString"
		.data
			ptrTemp .word $0000
			value   .word $0000
		.code
		; preserve a, y, x, stack and ptr1
		pha
		phy
		phx
		php
		ldwaa(ptrTemp, ptr1)		
		
		; Retrieve param into ptr1
		popax(ptr1)
		popax(value)

		; First digit of high byte
		clc
		lda value + 1
		and #$f0
		clc
		ror
		ror
		ror
		ror
		tax
		ldy #$00
		lda petscii,x
		sta (ptr1),y

		; Second digit of high byte
		lda value + 1
		and #$0f   
		tax     
		iny
		lda petscii,x
		sta (ptr1),y

		; First digit of low byte
		lda value + 0
		and #$f0
		clc
		ror
		ror
		ror
		ror
		tax
		iny
		lda petscii,x
		sta (ptr1),y

		; Second digit of low byte
		lda value + 0
		and #$0f   
		tax
		iny
		lda petscii,x
		sta (ptr1),y

		; Trailing null
		lda #$00
		iny
		sta (ptr1),y        

		;Restore a, y, x, stack and ptr1
		ldwaa(ptr1, ptrTemp)		
		plp
		plx
		ply
		pla
	.namespace
.endfunction

.macro byteToString_macro(pString, value)
	pusha(value)
	pushax_ptr(pString)
    byteToString();
.endmacro

.macro byteToString_ofs_macro(pString, value, ofs)	
	pusha_ofs (value, ofs)  
	pushax_ptr(pString)
    byteToString();
.endmacro

.function byteToString
	.namespace "byteToString"
		.data
			ptrTemp .word $0000
			value   .byte $0000
		.code
		; preserve a, y, x, stack and ptr1
		pha
		phy
		phx
		php
		ldwaa(ptrTemp, ptr1)		
		
		; Retrieve param into ptr1
		popax(ptr1)
		popa(value)
		
		; First digit of low byte
		lda value 
		and #$f0
		clc
		ror
		ror
		ror
		ror
		tax
		ldy #$00
		lda petscii,x
		sta (ptr1),y

		; Second digit of low byte
		lda value 
		and #$0f   
		tax
		iny
		lda petscii,x
		sta (ptr1),y

		; Trailing null
		lda #$00
		iny
		sta (ptr1),y        

		;Restore a, y, x, stack and ptr1
		ldwaa(ptr1, ptrTemp)		
		plp
		plx
		ply
		pla
	.namespace
.endfunction

.function endLine
	.namespace "endLine"        
		.code
			; preserve a
			pha
			
			; Print CR
			lda #$0d
			jsr $ffd2

			;Restore a            
			pla
	.namespace
.endfunction