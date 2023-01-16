; Stub basic program to start Assembly code
.segment"Code"

* = $0801

basicheader:
.byte $0b, $08, $0a, $00, $9e, $32, $30
.byte $36, $34, $00, $00, $00, $00, $00, $00

; Call the start function, then exit the program
start()
rts