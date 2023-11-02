; ################################################################################
; CODE

.proc chatConnect

  ; enable ESP
  lda #1
  sta RNBW::CONFIG

  ; set server protocol
  lda #2
  sta RNBW::BUF_OUT+0
  lda #RNBW::TO_ESP::SERVER_SET_PROTOCOL
  sta RNBW::BUF_OUT+1
  lda #RNBW::SERVER_PROTOCOLS::UDP
  sta RNBW::BUF_OUT+2
  sta RNBW::TX

  ; wait for message to be sent
:
  bit RNBW::TX
  bpl :-

  ; set server host name and port
.ifdef SERVER_PORT
  lda #( 4 + .strlen(SERVER_HOSTNAME) )
  sta RNBW::BUF_OUT+0
  lda #RNBW::TO_ESP::SERVER_SET_SETTINGS
  sta RNBW::BUF_OUT+1
  lda #>SERVER_PORT
  sta RNBW::BUF_OUT+2
  lda #<SERVER_PORT
  sta RNBW::BUF_OUT+3
  lda #.strlen(SERVER_HOSTNAME)
  sta RNBW::BUF_OUT+4
  .repeat .strlen(SERVER_HOSTNAME),I
    lda #.strat(SERVER_HOSTNAME,I)
    sta RNBW::BUF_OUT+5+I
  .endrepeat

.else

  ; set server host name and port
  lda #4
  clc
  adc hostnameLength
  sta RNBW::BUF_OUT+0
 
  lda #RNBW::TO_ESP::SERVER_SET_SETTINGS
  sta RNBW::BUF_OUT+1
  lda port+0
  sta RNBW::BUF_OUT+2
  lda port+1
  sta RNBW::BUF_OUT+3
  lda hostnameLength
  sta RNBW::BUF_OUT+4
  ldx #0
:
  lda hostname,x
  sta RNBW::BUF_OUT+5,x
  inx
  cpx hostnameLength
  bne :-

.endif

  ; send message
  sta RNBW::TX

  ; wait for message to be sent
:
  bit RNBW::TX
  bpl :-  

  ; connecting to server
  lda #<txtConnecting
  ldx #>txtConnecting
  jsr PPU::set_vram_update
  jsr PPU::waitNMI

  ; connect to server
connectToServer:

  ; send command
  lda #1
  sta RNBW::BUF_OUT+0
  lda #RNBW::TO_ESP::SERVER_CONNECT
  sta RNBW::BUF_OUT+1
  sta RNBW::TX

  ; wait for message to be sent
:
  bit RNBW::TX
  bpl :-

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
  sta RNBW::BUF_OUT+0
  lda #RNBW::TO_ESP::SERVER_GET_STATUS
  sta RNBW::BUF_OUT+1
  sta RNBW::TX

  ; wait for message to be sent
:
  bit RNBW::TX
  bpl :-
  
  ; wait for answer
:
  bit RNBW::RX
  bpl :-

  ; get data
  ; ignore message length and opcode/command
  lda RNBW::BUF_IN+2 ; server status
  sta RNBW::RX  ; acknowledge answer
  cmp #RNBW::SERVER_STATUS::CONNECTED
  beq connected

  dey
  bne wait2seconds
  jmp connectToServer

connected:

  inc connectedToServer

  ; register username
  lda #2
  clc
  adc usernameLength
  sta RNBW::BUF_OUT+0
  lda #RNBW::TO_ESP::SERVER_SEND_MESSAGE
  sta RNBW::BUF_OUT+1
  ldx #0
  stx RNBW::BUF_OUT+2
:
  lda username,x
  sta RNBW::BUF_OUT+3,x
  inx
  cpx usernameLength
  bne :-
  sta RNBW::TX
  ; wait for message to be sent
:
  bit RNBW::TX
  bpl :-

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