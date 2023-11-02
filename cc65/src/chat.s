; ################################################################################
; CONSTANTS

; uncomment BOTH lines to hardcode server hostname and port
;.define SERVER_HOSTNAME "localhost"
.define SERVER_HOSTNAME "127.0.0.1"
SERVER_PORT = 1234 ;8000

; ################################################################################
; ZEROPAGE + MISC

.pushseg
.zeropage

cursorPos:      .res 1  ; cursor position / index
cursorHoldCnt:  .res 1  ; cursor hold counter
textCursorPos:  .res 1  ; text cursor postion / index
separatorPos:   .res 1  ; separator position between username and actual message
usernameLength: .res 1  ; username length
messageLength:  .res 1  ; message length
messageEnd:     .res 1  ; message end index
NTaddress:      .res 2  ; NT VRAM address to update
chatState:      .res 1  ; chat state (HOSTNAME | PORT | USERNAME | CHAT)
connectedToServer:  .res 1

; chat-settings
username:       .res 8  ; username string, max  8 characters
hostname:       .res 32 ; hostname string, max 32 characters
hostnameLength: .res 1  ; hostname length
port:           .res 2  ; port (converted from string to 16bit hex)

CURSOR_TILE         = $1e
CURSOR_MAX_POS      = 90
CURSOR_HOLD_DELAY   = 30
TEXT_MAX_LENGTH     = 28

.enum CHAT_STATES
  HOSTNAME
  PORT
  USERNAME
  CHAT
.endenum

.popseg

; ################################################################################
; INCLUDES

.include "chat-settings.s"
.include "chat-connection.s"
.include "chat-message-handler.s"

; ################################################################################
; CODE

.proc startChat

  jsr chatInitView
.ifdef SERVER_PORT
  jsr setUsernameInit
.else
  jsr setHostnameInit
.endif
  jmp chatLoop

.endproc

.proc chatInitView

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
  jsr PPU::vram_unrle

  ; enable rendering
  jsr PPU::on

  ; return
  rts

.endproc

.proc chatInit

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
  ; length | TO_ESP::SERVER_SEND_MESSAGE | 0x01 (new msg opcode) | message / string ...
  ;lda #2
  ;sta RNBW::BUF_OUT+0    ; no need to set the length yet
  lda #RNBW::TO_ESP::SERVER_SEND_MESSAGE
  sta RNBW::BUF_OUT+1
  lda #1
  sta RNBW::BUF_OUT+2

  ; update chat state
  lda #CHAT_STATES::CHAT
  sta chatState

  ; return
  rts

.endproc

.proc chatLoop

  ; keep connection alive
  lda PPU::FRAME_CNT1
  bne :+
    jsr keepAlive
:

  ; check for incomming data from ESP
  bit RNBW::RX
  bpl :+
    jsr processData
:

  ; poll controller
  ldy #0
  jsr pad::read

  ; handle long press on LEFT / RIGHT / A

  lda pad::state
  and #PAD_LEFT
  beq skipLEFTstate
    lda cursorHoldCnt
    cmp #CURSOR_HOLD_DELAY
    bne :+
      dec cursorHoldCnt
      jmp decCursor
  :
    inc cursorHoldCnt
    jmp skipRIGHTstate
skipLEFTstate:

  lda pad::state
  and #PAD_RIGHT
  beq skipRIGHTstate
    lda cursorHoldCnt
    cmp #CURSOR_HOLD_DELAY
    bne :+
      dec cursorHoldCnt
      jmp incCursor
  :
    inc cursorHoldCnt
    jmp skipRIGHTstate
skipRIGHTstate:

  lda pad::state
  and #PAD_A
  beq skipAstate
    lda cursorHoldCnt
    cmp #CURSOR_HOLD_DELAY
    bne :+
      dec cursorHoldCnt
      jmp removeChar
  :
    inc cursorHoldCnt
skipAstate:

  ; handle long press release for RIGHT / LEFT / A

  lda pad::released
  and #PAD_RIGHT|PAD_LEFT|PAD_A
  beq skipLEFT_RIGHT_Areleased
    lda #0
    sta cursorHoldCnt
skipLEFT_RIGHT_Areleased:

  ; handle pressed button

  lda pad::pressed
  and #PAD_LEFT
  beq skipLEFTpressed
decCursor:
    ; decrement cursor position by one (1) if possible
    lda cursorPos
    beq skipLEFTpressed
    dec cursorPos
skipLEFTpressed:

  lda pad::pressed
  and #PAD_RIGHT
  beq skipRIGHTpressed
incCursor:
    ; increment cursor position by one (1) if possible
    lda cursorPos
    cmp #CURSOR_MAX_POS-1
    beq skipRIGHTpressed
    inc cursorPos
skipRIGHTpressed:

  lda pad::pressed
  and #PAD_UP
  beq skipUPpressed
    ; move cursor position to previous line if possible
    lda cursorPos
    sec
    sbc #30
    bcc skipUPpressed
    sta cursorPos
skipUPpressed:

  lda pad::pressed
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

  lda pad::pressed
  and #PAD_A
  beq skipApressed
removeChar:
    ; remove last character from text input
    jsr removeCharacter
skipApressed:

  lda pad::pressed
  and #PAD_B
  beq skipBpressed
    ; add a new character to text input
    lda cursorPos
    clc
    adc #$21
    jsr addCharacter
skipBpressed:

  lda pad::pressed
  and #PAD_SELECT
  beq skipSELECTpressed
    ; add SPACE to text input
    lda #$20
    jsr addCharacter
skipSELECTpressed:

  lda pad::pressed
  and #PAD_START
  beq skipSTARTpressed
    ; branch on chat state
    lda chatState
    cmp #CHAT_STATES::HOSTNAME
    bne :+
      jsr setHostname
      jmp skipSTARTpressed
  :
    cmp #CHAT_STATES::PORT
    bne :+
      jsr setPort
      jmp skipSTARTpressed
  :
    cmp #CHAT_STATES::USERNAME
    bne :+
      jsr setUsername
      jmp skipSTARTpressed
  :
    ; send message
    jsr sendMessage
skipSTARTpressed:

  ; update cursor on screen
  jsr updateCursor

  ; wait for NMI
  jsr PPU::waitNMI

  ; and loop...
  jmp chatLoop

.endproc

.proc updateCursor

  ldx cursorPos
  lda cursorPosX,x
  sta OAM_BUF+3
  lda cursorPosY,x
  sta OAM_BUF+0

  ; return
  rts

.endproc

.proc addCharacter

  ; Rainbow output buffer with new character
  sta $102
  ldx textCursorPos
  sta RNBW::BUF_OUT+3,x
  
  ; update NT VRAM address
  lda NTaddressHI,x
  sta $100
  lda NTaddressLO,x
  sta $101

  ; are we at the limit ?
  lda textCursorPos
  cmp #TEXT_MAX_LENGTH
  bne :+
    ; return
    rts
:

  ; update VRAM
  lda #<$100
  ldx #>$100
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; increment text index pos
  inc textCursorPos

  ; return
  rts
.endproc

.proc removeCharacter

  ; are we at the begining of the line ?
  lda textCursorPos
  bne :+
    ; return
    rts
:

  ; update NT and Rainbow output buffer with new character
  lda #$20
  sta $102

  ldx textCursorPos
  sta RNBW::BUF_OUT+3,x

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
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; return
  rts

.endproc

.proc sendMessage

  ; are we at the begining of the line ?
  lda textCursorPos
  bne :+
    ; return
    rts
:

  ; update message length
  lda #2
  clc
  adc textCursorPos
  sta RNBW::BUF_OUT+0

  ; update opcode
  lda #1
  sta RNBW::BUF_OUT+2

  ; send data using the Rainbow output buffer
  lda #<RNBW::BUF_OUT
  ldx #>RNBW::BUF_OUT
  sta RNBW::TX
  ; wait for message to be sent
:
  bit RNBW::TX
  bpl :-

  ; clear text input
  lda #<txtBlank
  ldx #>txtBlank
  jsr PPU::set_vram_update

  ; reset text cursor
  lda #0
  sta textCursorPos

  ; reset NT address
  lda #$62
  sta $101

  ; return
  rts

.endproc

.proc processData
  ; data available in RAM buffer (RNBW::BUF_IN)

  ; is it a message from server ?
  lda RNBW::BUF_IN+1
  cmp #RNBW::FROM_ESP::MESSAGE_FROM_SERVER
  beq :+
    ; if not, ignore the message for now...
    ; TODO...

    sta RNBW::RX  ; acknowledge received message

    ; return
    rts
:

  ; branch on server opcode
  lda RNBW::BUF_IN+2
  cmp #0
  bne :+
    jmp newUser
:
  cmp #1
  bne :+
    jmp newMessage
:
  ; unknown opcode, don't do anything...
  ; TODO...

  sta RNBW::RX  ; acknowledge received message

  ; return
  rts

.endproc

; ################################################################################
; DATA

chatNT:
  .incbin "gfx/chat.rle"

chatPAL:
  .byte $0c,$00,$10,$30,$0c,$00,$10,$0c,$0c,$17,$27,$37,$0c,$00,$19,$29
  .byte $0c,$00,$10,$30,$0c,$00,$10,$0c,$0c,$17,$27,$37,$0c,$00,$19,$29

cursorPosX:
  .repeat 3
    .repeat 30,I
      .byte 8*(I+1)
    .endrepeat
  .endrepeat

cursorPosY:
  .repeat 30
    .byte 184
  .endrepeat
  .repeat 30
    .byte 200
  .endrepeat
  .repeat 30
    .byte 216
  .endrepeat

txtBlank:
  .byte $22|NT_UPD_HORZ,$62,28
  .byte "                            "
  .byte NT_UPD_EOF

NTaddressHI:
.repeat TEXT_MAX_LENGTH,I
  .byte >($2262+I)
.endrepeat

NTaddressLO:
.repeat TEXT_MAX_LENGTH,I
  .byte <($2262+I)
.endrepeat
