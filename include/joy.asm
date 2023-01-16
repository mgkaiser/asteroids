JOY_BTN_1_MASK  .equ  $80
JOY_BTN_2_MASK  .equ  $40
JOY_BTN_3_MASK  .equ  $20
JOY_BTN_4_MASK  .equ  $10
JOY_UP_MASK     .equ  $08
JOY_DOWN_MASK   .equ  $04
JOY_LEFT_MASK   .equ  $02
JOY_RIGHT_MASK  .equ  $01

joystick_scan .equ  $ff53
joystick_get  .equ  $ff56
.macro joy_read(result)
  jsr joystick_scan
  lda #$00
  jsr joystick_get
  resultw(result)
.endmacro