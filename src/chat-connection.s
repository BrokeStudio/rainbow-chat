; ################################################################################
; CODE

.proc chatConnect

  ; enable ESP
  lda #$01
  sta $5001

  ; don't need to clear the buffers here, at least for now
  ; also, after clearing buffers, you should send anything else right away
  ; you need to wait for xxxxx(?) cycles (TBD)
;  ; clear buffers
;  lda #1
;  sta $5000
;  lda #RNBW::N2E::CLEAR_BUFFERS
;  sta $5000

  ; set server protocol
  lda #2
  sta $5000
  lda #RNBW::N2E::SET_SERVER_PROTOCOL
  sta $5000
  lda #RNBW::SERVER_PROTOCOLS::WS
  sta $5000

  ; set server host name and port
.ifdef SERVER_PORT
  lda #( 3 + .strlen(SERVER_HOSTNAME) )
  sta $5000
  lda #RNBW::N2E::SET_SERVER_SETTINGS
  sta $5000
  lda #>SERVER_PORT
  sta $5000
  lda #<SERVER_PORT
  sta $5000
  .repeat .strlen(SERVER_HOSTNAME),I
    lda #.strat(SERVER_HOSTNAME,I)
    sta $5000
  .endrepeat

.else

  ; set server host name and port
  lda #3
  clc
  adc hostnameLength
  sta $5000
 
  lda #RNBW::N2E::SET_SERVER_SETTINGS
  sta $5000
  lda port+0
  sta $5000
  lda port+1
  sta $5000
  ldx #0
:
  lda hostname,x
  sta $5000
  inx
  cpx hostnameLength
  bne :-

.endif

  ; connecting to server
  lda #<txtConnecting
  ldx #>txtConnecting
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; connect to server
connectToServer:

  ; send command
  lda #1
  sta $5000
  lda #RNBW::N2E::CONNECT_SERVER
  sta $5000

  ; let's ask for server status every 2 seconds
  ; if we're still not connected after 20 seconds
  ; then try to connect again...
checkServerStatus:
  ldy #10
wait2seconds:
  ldx #120
:
  jsr PPU::waitNMI
  dex
  bne :-

  ; check server status
  lda #1
  sta $5000
  lda #RNBW::N2E::GET_SERVER_STATUS
  sta $5000

  ; wait for answer
:
  bit $5001
  bpl :-

  ; get data
  lda $5000 ; dummy read
  nop
  lda $5000 ; length (don't care)
  nop
  lda $5000 ; command (don't care)
  nop
  lda $5000 ; server status
  cmp #RNBW::SERVER_STATUS::CONNECTED
  beq connected

  dey
  bne wait2seconds
  jmp connectToServer

connected:

  ; register username
  lda #2
  clc
  adc usernameLength
  sta $5000
  lda #RNBW::N2E::SEND_MSG_TO_SERVER
  sta $5000
  ldx #0
  stx $5000
:
  lda username,x
  sta $5000
  inx
  cpx usernameLength
  bne :-

/*
  ; connected to server
  lda #<txtConnected
  ldx #>txtConnected
  jsr PPU::set_vram_update
:
  jsr PPU::waitNMI

  ; wait for user to press a button before clearing the message
  ldy #0
  jsr pad::read
  lda pad::pressed
  and #PAD_START
  beq :-
*/
  ; clear text
  lda #<txtBlank
  ldx #>txtBlank
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  jmp chatInit

.endproc

; ################################################################################
; DATA

txtConnecting:
  .byte $22|NT_UPD_HORZ,$62,28
  .byte "CONNECTING...               "
  .byte $ff
/*
txtConnected:
  .byte $22|NT_UPD_HORZ,$62,28
  .byte "CONNECTED...   (press START)"
  .byte $ff
*/