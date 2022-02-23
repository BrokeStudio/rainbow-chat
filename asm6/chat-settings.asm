; ################################################################################
; CODE

setHostnameInit:

  ; display "enter host..." text
  lda #<txtServerHostname
  ldx #>txtServerHostname
  jsr set_vram_update

  ; update chat state
  lda #CHAT_STATES_HOSTNAME
  sta chatState

  ; return
  rts



setHostname:

  ; get hostname length
  lda textCursorPos
  bne +
    ; if string is empty, abort...
    rts
+
  sta hostnameLength

  ; copy hostname string
  ldx #0
-
  lda RNBW_BUF_OUT+3,x
  sta hostname,x
  inx
  cpx hostnameLength
  bne -

  jmp setPortInit



setPortInit:

  ; display "enter port..." text
  lda #<txtServerPort
  ldx #>txtServerPort
  jsr set_vram_update
  jsr waitNMI

  ; clear text input
  lda #<txtBlank
  ldx #>txtBlank
  jsr set_vram_update
  jsr waitNMI

  ; reset text cursor
  ldx #0
  stx textCursorPos
  
  ; update NT VRAM address
  lda NTaddressHI,x
  sta $100
  lda NTaddressLO,x
  sta $101

  ; update chat state
  lda #CHAT_STATES_PORT
  sta chatState

  ; return
  rts



setPort:

  strPort = $400

  ; reverse string and convert each digit to hex value
  ldx textCursorPos
  bne +
    ; string empty, abort...
    rts
+
  cpx #6
  bcc +
    ; string too long, abort...
    rts
+
  dex
  ldy #0
reverseLoop:
  lda RNBW_BUF_OUT+3,x
  and #%00001111
  cmp #10
  bcc +
    ; this is not a decimal character, abort...
    rts
+
  sta strPort,y
  iny
  dex
  bpl reverseLoop

  ; convert decimal to hex
  ldx #0
  stx port+0  ; MSB
  stx port+1  ; LSB
digitLoop:
  lda strPort,x
  beq skipDigit
  tay
multLoop:
  lda multiplicatorLO,x
  clc
  adc port+1
  sta port+1
  bcc +
    inc port+0 
+
  lda multiplicatorHI,x
  clc
  adc port+0
  sta port+0
  dey
  bne multLoop
skipDigit:
  inx
  cpx textCursorPos
  bne digitLoop

  jmp setUsernameInit



setUsernameInit:

  ; display "enter username..." text
  lda #<txtUsername
  ldx #>txtUsername
  jsr set_vram_update
  jsr waitNMI

  ; clear text input
  lda #<txtBlank
  ldx #>txtBlank
  jsr set_vram_update
  jsr waitNMI

  ; reset text cursor
  ldx #0
  stx textCursorPos
  
  ; update NT VRAM address
  lda NTaddressHI,x
  sta $100
  lda NTaddressLO,x
  sta $101

  ; update chat state
  lda #CHAT_STATES_USERNAME
  sta chatState

  ; return
  rts



setUsername:

  ; get username length
  lda textCursorPos
  bne +
    ; if string is empty, abort...
    rts
+
  cmp #9
  bcc +
    ; if string is too long, abort...
    rts
+
  sta usernameLength

  ; copy username string
  ldx #0
-
  lda RNBW_BUF_OUT+3,x
  sta username,x
  inx
  cpx usernameLength
  bne -

  ; clear text
  lda #<txtClear
  ldx #>txtClear
  jsr set_vram_update
  jsr waitNMI

  jmp chatConnect



; ################################################################################
; DATA

txtServerHostname:
  .db $22|NT_UPD_HORZ,$00,32
  .db "  Enter server IP / hostname    "
  .db NT_UPD_EOF

txtServerPort:
  .db $22|NT_UPD_HORZ,$00,32
  .db "  Enter server port             "
  .db NT_UPD_EOF

txtUsername:
  .db $22|NT_UPD_HORZ,$00,32
  .db "  Enter username (8 char. max)  "
  .db NT_UPD_EOF

txtClear:
  .db $22|NT_UPD_HORZ,$00,32
  .db "                                "
  .db NT_UPD_EOF

multiplicatorHI:
  .db >1, >10, >100, >1000, >10000

multiplicatorLO:
  .db <1, <10, <100, <1000, <10000