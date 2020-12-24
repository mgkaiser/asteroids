.export _interrupt2
.export _interrupt

.import _s_splitcurr
.import _s_splitmax
.import _s0_x_reg
.import _s0_y_reg
.import _s0_color_reg
.import _s0_frame
.import _s1_x_reg
.import _s1_y_reg
.import _s1_color_reg
.import _s1_frame
.import _s2_x_reg
.import _s2_y_reg
.import _s2_color_reg
.import _s2_frame
.import _s3_x_reg
.import _s3_y_reg
.import _s3_color_reg
.import _s3_frame
.import _s4_x_reg
.import _s4_y_reg
.import _s4_color_reg
.import _s4_frame
.import _s5_x_reg
.import _s5_y_reg
.import _s5_color_reg
.import _s5_frame
.import _s6_x_reg
.import _s6_y_reg
.import _s6_color_reg
.import _s6_frame
.import _s7_x_reg
.import _s7_y_reg
.import _s7_color_reg
.import _s7_frame
.import _s_hix_reg
.import _s_next_interrupt
.import _frameTrigger

.import __s_splitcurr
.import __s_splitmax
.import __s0_x_reg
.import __s0_y_reg
.import __s0_color_reg
.import __s0_frame
.import __s1_x_reg
.import __s1_y_reg
.import __s1_color_reg
.import __s1_frame
.import __s2_x_reg
.import __s2_y_reg
.import __s2_color_reg
.import __s2_frame
.import __s3_x_reg
.import __s3_y_reg
.import __s3_color_reg
.import __s3_frame
.import __s4_x_reg
.import __s4_y_reg
.import __s4_color_reg
.import __s4_frame
.import __s5_x_reg
.import __s5_y_reg
.import __s5_color_reg
.import __s5_frame
.import __s6_x_reg
.import __s6_y_reg
.import __s6_color_reg
.import __s6_frame
.import __s7_x_reg
.import __s7_y_reg
.import __s7_color_reg
.import __s7_frame
.import __s_hix_reg
.import __s_next_interrupt
.import __frameTrigger

.code 

; Interrupt Handler
_interrupt2:
					
		; Set the index
		ldy     _s_splitcurr
		sty     $D020

		; Load y coordinates into registers		
		lda     _s0_y_reg,y
		sta     $D001
		lda     _s1_y_reg,y
		sta     $D003
		lda     _s2_y_reg,y
		sta     $D005
		lda     _s3_y_reg,y
		sta     $D007
		lda     _s4_y_reg,y
		sta     $D009
		lda     _s5_y_reg,y
		sta     $D00B
		lda     _s6_y_reg,y
		sta     $D00D
		lda     _s7_y_reg,y
		sta     $D00F

		; Load x coordinates into registers		
		lda     _s0_x_reg,y
		sta     $D000			
		lda     _s1_x_reg,y
		sta     $D002		
		lda     _s2_x_reg,y
		sta     $D004
		lda     _s3_x_reg,y
		sta     $D006	
		lda     _s4_x_reg,y
		sta     $D008		
		lda     _s5_x_reg,y
		sta     $D00A
		lda     _s6_x_reg,y
		sta     $D00C		
		lda     _s7_x_reg,y
		sta     $D00E
		
		; Load color into registers
		lda     _s0_color_reg,y
		sta     $D027
		lda     _s1_color_reg,y
		sta     $D028
		lda     _s2_color_reg,y
		sta     $D029
		lda     _s3_color_reg,y
		sta     $D02A
		lda     _s4_color_reg,y
		sta     $D02B
		lda     _s5_color_reg,y
		sta     $D02C
		lda     _s6_color_reg,y
		sta     $D02D
		lda     _s7_color_reg,y
		sta     $D02F
		lda     _s_hix_reg,y
		sta     $D010

		; Next interrupt
		lda     _s_next_interrupt,y
		sta     $D012
		
		; Load the sprite shapes
		lda     _s0_frame,y	
		sta     $bbf8 + 0	
		lda     _s1_frame,y
		sta     $bbf8 + 1		
		lda     _s2_frame,y
		sta     $bbf8 + 2
		lda     _s3_frame,y
		sta     $bbf8 + 3
		lda     _s4_frame,y
		sta     $bbf8 + 4
		lda     _s5_frame,y
		sta     $bbf8 + 5
		lda     _s6_frame,y
		sta     $bbf8 + 6
		lda     _s7_frame,y
		sta     $bbf8 + 7			

		; if (s_splitcurr == s_splitmax) frameTrigger = 1;
		lda     _s_splitcurr
		bne     L0126
		lda     #$01
		sta     _frameTrigger
		ldx 	#$00
.import _s_splitcurr
				
		; if (++s_splitcurr >= s_splitmax) s_splitcurr = 0;	and do the KERNEL interrupt
L0126:	inc     _s_splitcurr
		lda     _s_splitcurr
		cmp     _s_splitmax
		bcc     L0127
		lda     #$00
		sta     _s_splitcurr		
		inc     $D019
		jmp 	$ea31

		; otherwise just end the interrupt
L0127:	inc     $D019
		jmp 	$ea81

_interrupt:
					
		; Set the index
		ldy     __s_splitcurr
		sty     $D020

		; Load y coordinates into registers		
		lda     __s0_y_reg,y
		sta     $D001
		lda     __s1_y_reg,y
		sta     $D003
		lda     __s2_y_reg,y
		sta     $D005
		lda     __s3_y_reg,y
		sta     $D007
		lda     __s4_y_reg,y
		sta     $D009
		lda     __s5_y_reg,y
		sta     $D00B
		lda     __s6_y_reg,y
		sta     $D00D
		lda     __s7_y_reg,y
		sta     $D00F

		; Load x coordinates into registers		
		lda     __s0_x_reg,y
		sta     $D000			
		lda     __s1_x_reg,y
		sta     $D002		
		lda     __s2_x_reg,y
		sta     $D004
		lda     __s3_x_reg,y
		sta     $D006	
		lda     __s4_x_reg,y
		sta     $D008		
		lda     __s5_x_reg,y
		sta     $D00A
		lda     __s6_x_reg,y
		sta     $D00C		
		lda     __s7_x_reg,y
		sta     $D00E
		
		; Load color into registers
		lda     __s0_color_reg,y
		sta     $D027
		lda     __s1_color_reg,y
		sta     $D028
		lda     __s2_color_reg,y
		sta     $D029
		lda     __s3_color_reg,y
		sta     $D02A
		lda     __s4_color_reg,y
		sta     $D02B
		lda     __s5_color_reg,y
		sta     $D02C
		lda     __s6_color_reg,y
		sta     $D02D
		lda     __s7_color_reg,y
		sta     $D02F
		lda     __s_hix_reg,y
		sta     $D010

		; Next interrupt
		lda     __s_next_interrupt,y
		sta     $D012
		
		; Load the sprite shapes
		lda     __s0_frame,y	
		sta     $bbf8 + 0	
		lda     __s1_frame,y
		sta     $bbf8 + 1		
		lda     __s2_frame,y
		sta     $bbf8 + 2
		lda     __s3_frame,y
		sta     $bbf8 + 3
		lda     __s4_frame,y
		sta     $bbf8 + 4
		lda     __s5_frame,y
		sta     $bbf8 + 5
		lda     __s6_frame,y
		sta     $bbf8 + 6
		lda     __s7_frame,y
		sta     $bbf8 + 7			

		; if (s_splitcurr == s_splitmax) frameTrigger = 1;
		lda     __s_splitcurr
		bne     L0026
		lda     #$01
		sta     _frameTrigger
		ldx 	#$00
				
		; if (++s_splitcurr >= s_splitmax) s_splitcurr = 0;	and do the KERNEL interrupt
L0026:	inc     __s_splitcurr
		lda     __s_splitcurr
		cmp     __s_splitmax
		bcc     L0027
		lda     #$00
		sta     __s_splitcurr		
		inc     $D019
		jmp 	$ea31

		; otherwise just end the interrupt
L0027:	inc     $D019
		jmp 	$ea81