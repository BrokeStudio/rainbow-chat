; ################################################################################
; CONSTANTS

; uncomment this line to use hardcoded server hostname and port
; see chatConnect in chat-connections.asm file
localhost EQU 1

; ################################################################################
; ZEROPAGE + MISC

.enum $0050

cursorPos      .dsb 1  ; cursor position / index
cursorHoldCnt  .dsb 1  ; cursor hold counter
textCursorPos  .dsb 1  ; text cursor postion / index
separatorPos   .dsb 1  ; separator position between username and actual message
usernameLength .dsb 1  ; username length
messageLength  .dsb 1  ; message length
messageEnd     .dsb 1  ; message end index
NTaddress      .dsb 2  ; NT VRAM address to update
chatState      .dsb 1  ; chat state (HOSTNAME | PORT | USERNAME | CHAT)
connectedToServer .dsb 1

; chat-settings
username       .dsb 8  ; username string, max  8 characters
hostname       .dsb 32 ; hostname string, max 32 characters
hostnameLength .dsb 1  ; hostname length
port           .dsb 2  ; port (converted from string to 16bit hex)

.ende

CURSOR_TILE         EQU $1e
CURSOR_MAX_POS      EQU 90
CURSOR_HOLD_DELAY   EQU 30
TEXT_MAX_LENGTH     EQU 28

CHAT_STATES_HOSTNAME  EQU 0
CHAT_STATES_PORT      EQU 1
CHAT_STATES_USERNAME  EQU 2
CHAT_STATES_CHAT      EQU 3

; ################################################################################
; INCLUDES

.include "chat-settings.asm"
.include "chat-connection.asm"
.include "chat-message-handler.asm"

; ################################################################################
; CODE

startChat:

  jsr chatInitView
.ifdef localhost
  jsr setUsernameInit
.else
  jsr setHostnameInit
.endif
  jmp chatLoop



chatInitView:

  ; cursor tile
  lda #CURSOR_TILE
  sta OAM_BUF+1
  
  ; cursor attribute
  lda #2
  sta OAM_BUF+2

  ; prepare text field NT update
  lda #$22
  sta $100
  lda #$62
  sta $101
  lda #NT_UPD_EOF
  sta $103

  ; set VRAM address
  lda #$20
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR

  ; load NT data
  ldx #>chatNT
  lda #<chatNT
  jsr vram_unrle

  ; enable rendering
  jsr ppu_on_all

  ; return
  rts



chatInit:

  ; init vars
  lda #0
  sta cursorPos
  sta cursorHoldCnt
  sta textCursorPos
 
  ; init NT VRAM address
  lda #$20
  sta NTaddress+0
  lda #$41
  sta NTaddress+1

  ; we will always push 29 characters
  ; (28 message max + 1 for message indent)
  ; $112 is the NT buffer data length
  ; see ppu.s, proc flush_vram_update_nmi (line 693) for details
  lda #29
  sta $112
  ; end the EOF opcode will always be at the same place too
  lda #NT_UPD_EOF
  sta $130

  ; init Rainbow output buffer
  ; message format is:
  ; length | TOESP_SERVER_SEND_MSG | 0x01 (new msg opcode) | message / string ...
  ;lda #2
  ;sta RNBW_BUF_OUT+0    ; no need to set the length yet
  lda #TOESP_SERVER_SEND_MSG
  sta RNBW_BUF_OUT+1
  lda #1
  sta RNBW_BUF_OUT+2

  ; update chat state
  lda #CHAT_STATES_CHAT
  sta chatState

  ; return
  rts



chatLoop:

  ; keep connection alive
  lda FRAME_CNT1
  bne +
    jsr keepAlive
+

  ; check for incomming data from ESP
  bit RNBW_RX
  bpl +
    jsr processData
+

  ; poll controller
  ldy #0
  jsr padRead

  ; handle long press on LEFT / RIGHT / A

  lda padState
  and #PAD_LEFT
  beq skipLEFTstate
    lda cursorHoldCnt
    cmp #CURSOR_HOLD_DELAY
    bne +
      dec cursorHoldCnt
      jmp decCursor
  +
    inc cursorHoldCnt
    jmp skipRIGHTstate
skipLEFTstate:

  lda padState
  and #PAD_RIGHT
  beq skipRIGHTstate
    lda cursorHoldCnt
    cmp #CURSOR_HOLD_DELAY
    bne +
      dec cursorHoldCnt
      jmp incCursor
  +
    inc cursorHoldCnt
    jmp skipRIGHTstate
skipRIGHTstate:

  lda padState
  and #PAD_A
  beq skipAstate
    lda cursorHoldCnt
    cmp #CURSOR_HOLD_DELAY
    bne +
      dec cursorHoldCnt
      jmp removeChar
  +
    inc cursorHoldCnt
skipAstate:

  ; handle long press release for RIGHT / LEFT / A

  lda padReleased
  and #PAD_RIGHT|PAD_LEFT|PAD_A
  beq skipLEFT_RIGHT_Areleased
    lda #0
    sta cursorHoldCnt
skipLEFT_RIGHT_Areleased:

  ; handle pressed button

  lda padPressed
  and #PAD_LEFT
  beq skipLEFTpressed
decCursor:
    ; decrement cursor position by one (1) if possible
    lda cursorPos
    beq skipLEFTpressed
    dec cursorPos
skipLEFTpressed:

  lda padPressed
  and #PAD_RIGHT
  beq skipRIGHTpressed
incCursor:
    ; increment cursor position by one (1) if possible
    lda cursorPos
    cmp #CURSOR_MAX_POS-1
    beq skipRIGHTpressed
    inc cursorPos
skipRIGHTpressed:

  lda padPressed
  and #PAD_UP
  beq skipUPpressed
    ; move cursor position to previous line if possible
    lda cursorPos
    sec
    sbc #30
    bcc skipUPpressed
    sta cursorPos
skipUPpressed:

  lda padPressed
  and #PAD_DOWN
  beq skipDOWNpressed
    ; move cursor position to next line if possible
    lda cursorPos
    clc
    adc #30
    cmp #CURSOR_MAX_POS
    bcs skipDOWNpressed
    sta cursorPos
skipDOWNpressed:

  lda padPressed
  and #PAD_A
  beq skipApressed
removeChar:
    ; remove last character from text input
    jsr removeCharacter
skipApressed:

  lda padPressed
  and #PAD_B
  beq skipBpressed
    ; add a new character to text input
    lda cursorPos
    clc
    adc #$21
    jsr addCharacter
skipBpressed:

  lda padPressed
  and #PAD_SELECT
  beq skipSELECTpressed
    ; add SPACE to text input
    lda #$20
    jsr addCharacter
skipSELECTpressed:

  lda padPressed
  and #PAD_START
  beq skipSTARTpressed
    ; branch on chat state
    lda chatState
    cmp #CHAT_STATES_HOSTNAME
    bne +
      jsr setHostname
      jmp skipSTARTpressed
  +
    cmp #CHAT_STATES_PORT
    bne +
      jsr setPort
      jmp skipSTARTpressed
  +
    cmp #CHAT_STATES_USERNAME
    bne +
      jsr setUsername
      jmp skipSTARTpressed
  +
    ; send message
    jsr sendMessage
skipSTARTpressed:

  ; update cursor on screen
  jsr updateCursor

  ; wait for NMI
  jsr waitNMI

  ; and loop...
  jmp chatLoop



updateCursor:

  ldx cursorPos
  lda cursorPosX,x
  sta OAM_BUF+3
  lda cursorPosY,x
  sta OAM_BUF+0

  ; return
  rts



addCharacter:

  ; Rainbow output buffer with new character
  sta $102
  ldx textCursorPos
  sta RNBW_BUF_OUT+3,x
  
  ; update NT VRAM address
  lda NTaddressHI,x
  sta $100
  lda NTaddressLO,x
  sta $101

  ; are we at the limit ?
  lda textCursorPos
  cmp #TEXT_MAX_LENGTH
  bne +
    ; return
    rts
+

  ; update VRAM
  lda #<$100
  ldx #>$100
  jsr set_vram_update
  jsr waitNMI

  ; increment text index pos
  inc textCursorPos

  ; return
  rts


removeCharacter:

  ; are we at the begining of the line ?
  lda textCursorPos
  bne +
    ; return
    rts
+

  ; update NT and Rainbow output buffer with new character
  lda #$20
  sta $102

  ldx textCursorPos
  sta RNBW_BUF_OUT+3,x

  ; decrement text index pos
  dec textCursorPos

  ; update NT VRAM address
  ldx textCursorPos
  lda NTaddressHI,x
  sta $100
  lda NTaddressLO,x
  sta $101

  ; set VRAM update pointer
  lda #<$100
  ldx #>$100
  jsr set_vram_update
  jsr waitNMI

  ; return
  rts



sendMessage:

  ; are we at the begining of the line ?
  lda textCursorPos
  bne +
    ; return
    rts
+

  ; update message length
  lda #2
  clc
  adc textCursorPos
  sta RNBW_BUF_OUT+0

  ; update opcode
  lda #1
  sta RNBW_BUF_OUT+2

  ; send data using the Rainbow output buffer
  lda #<RNBW_BUF_OUT
  ldx #>RNBW_BUF_OUT
  sta RNBW_TX
  ; wait for message to be sent
-
  bit RNBW_TX
  bpl -

  ; clear text input
  lda #<txtBlank
  ldx #>txtBlank
  jsr set_vram_update

  ; reset text cursor
  lda #0
  sta textCursorPos

  ; reset NT address
  lda #$62
  sta $101

  ; return
  rts



processData:
  ; data available in RAM buffer (RNBW_BUF_IN)

  ; is it a message from server ?
  lda RNBW_BUF_IN+1
  cmp #FROMESP_MESSAGE_FROM_SERVER
  beq +
    ; if not, ignore the message for now...
    ; TODO...

    sta RNBW_RX  ; acknowledge received message

    ; return
    rts
+

  ; branch on server opcode
  lda RNBW_BUF_IN+2
  cmp #0
  bne +
    jmp newUser
+
  cmp #1
  bne +
    jmp newMessage
+
  ; unknown opcode, don't do anything...
  ; TODO...

  sta RNBW_RX  ; acknowledge received message

  ; return
  rts



; ################################################################################
; DATA

chatNT:
  .incbin "gfx/chat.rle"

chatPAL:
  .db $0c,$00,$10,$30,$0c,$00,$10,$0c,$0c,$17,$27,$37,$0c,$00,$19,$29
  .db $0c,$00,$10,$30,$0c,$00,$10,$0c,$0c,$17,$27,$37,$0c,$00,$19,$29

cursorPosX:
  I=0
  .rept 3
    .rept 30
      .db 8*(I+1)
      I=I+1
    .endr
    I=0
  .endr

cursorPosY:
  .rept 30
    .db 184
  .endr
  .rept 30
    .db 200
  .endr
  .rept 30
    .db 216
  .endr

txtBlank:
  .db $22|NT_UPD_HORZ,$62,28
  .db "                            "
  .db NT_UPD_EOF

NTaddressHI:
I=0
.rept TEXT_MAX_LENGTH
  .db >($2262+I)
  I=I+1
.endr

NTaddressLO:
I=0
.rept TEXT_MAX_LENGTH
  .db <($2262+I)
  I=I+1
.endr
