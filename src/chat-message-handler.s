; ################################################################################
; CODE

.proc newUser

  ; prepare the NT update buffer
  lda NTaddress+0
  ora #NT_UPD_HORZ
  sta $110
  lda NTaddress+1
  sta $111

  lda #'S'
  sta $113
  lda #'E'
  sta $114
  lda #'R'
  sta $115
  lda #'V'
  sta $116
  lda #'E'
  sta $117
  lda #'R'
  sta $118
  lda #':'
  sta $119

  ; fill NT buffer with blank tile
  lda #0
  ldx #0
:
  sta $11a,x
  inx
  cpx #21
  bne :-

  ; update VRAM
  lda #<$110
  ldx #>$110
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; update NT VRAM address
  lda #$20
  jsr updateChatNTaddress

  ; prepare the NT update buffer
  lda NTaddress+0
  ora #NT_UPD_HORZ
  sta $110
  lda NTaddress+1
  sta $111

  ; indent by adding a blank tile
  lda #0
  sta $113

  ; calculate message length
  lda RNBW::BUF_IN+0  ; get data length
  sec
  sbc #2
  sta messageLength

  ; copy message to NT update buffer
  tay
  ldx #0
:
  lda RNBW::BUF_IN+3,x
  sta $114,x
  inx
  dey
  bne :-

  ; don't need to fill with blank tiles here since we cleared it just before

  ; update VRAM
  lda #<$110
  ldx #>$110
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; update NT VRAM address
  lda #$40
  jsr updateChatNTaddress

  ; return
  rts

.endproc

.proc newMessage

  ; find separator between username and actual message
  ; let's start from 1 because username can't be empty
  ldx #1
:
  lda RNBW::BUF_IN+3,x ; +3 because we're ignoring data length and opcodes (2)
  beq :+
  inx
  jmp :-

:
  stx separatorPos
  stx usernameLength

  ; calculate message end index and message length
  lda RNBW::BUF_IN+0  ; get data length
  sec
  sbc #3              ; substract 3 (data length + 2 opcodes)
  sta messageEnd
  inc messageEnd      ; increment because of zero-indexing
  sbc usernameLength
  sta messageLength

  ; display username first

  ; prepare the NT update buffer
  lda NTaddress+0
  ora #NT_UPD_HORZ
  sta $110
  lda NTaddress+1
  sta $111

  ; copy username to NT update buffer
  ldy usernameLength
  ldx #0
:
  lda RNBW::BUF_IN+3,x
  sta $113,x
  inx
  dey
  bne :-

  ; add colon
  lda #':'
  sta $113,x
  inx

  ; fill with empty tile
  lda #0
:
  sta $113,x
  inx
  cpx #29
  bne :-

  ; update VRAM
  lda #<$110
  ldx #>$110
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; update NT VRAM address
  lda #$20
  jsr updateChatNTaddress

  ; display message

  ; prepare the NT update buffer
  lda NTaddress+0
  ora #NT_UPD_HORZ
  sta $110
  lda NTaddress+1
  sta $111

  ; indent by adding a blank tile
  lda #0
  sta $113

  ; copy message to NT update buffer
  ldy #0
  ldx separatorPos
  inx
:
  lda RNBW::BUF_IN+3,x
  sta $114,y
  iny
  inx
  cpx messageEnd
  bne :-

  cpy #28
  beq skipFillingMessage

  ; fill with empty tile
  lda #0
:
  sta $114,y
  iny
  cpy #28
  bne :-

skipFillingMessage:

  ; update VRAM
  lda #<$110
  ldx #>$110
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; update NT VRAM address
  lda #$40
  jsr updateChatNTaddress

  ; return
  rts
.endproc

.proc updateChatNTaddress
  ; A = increment value

  ; update address
  clc
  adc NTaddress+1
  sta NTaddress+1
  bcc :+
    inc NTaddress+0
:

  ; check if we need to wrap
  lda NTaddress+0
  cmp #$22
  bne :+

    ; reset NT VRAM address
    lda #$20
    sta NTaddress+0
    lda #$41
    sta NTaddress+1

:
  ; return
  rts

.endproc

/*
.proc clearLine
  ; A = MSB NT address
  ; X = LSB NT address
  ora #NT_UPD_HORZ
  sta $110
  stx $111
  ldx #0
  lda #0
:
  sta $113,x
  inx
  cpx #TEXT_MAX_LENGTH
  bne :-

  lda #NT_UPD_EOF
  sta $113,x

  ; update VRAM
  lda #<$110
  ldx #>$110
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; return
  rts

.endproc
*/