; ################################################################################
; CODE

.proc chatConnect

  ; enable ESP
  lda #1
  sta MAP_ESP_CONFIG
  nop

  ; don't need to clear the buffers here, at least for now
  ; also, after clearing buffers, you should send anything else right away
  ; you need to wait for xxxxx(?) cycles (TBD)
;  ; clear buffers
;  lda #1
;  sta MAP_ESP_DATA
;  lda #RNBW::TO_ESP::CLEAR_BUFFERS
;  sta MAP_ESP_DATA

  ; set server protocol
  lda #2
  sta MAP_ESP_DATA
  lda #RNBW::TO_ESP::SERVER_SET_PROTOCOL
  sta MAP_ESP_DATA
  lda #RNBW::SERVER_PROTOCOLS::WS
  sta MAP_ESP_DATA

  ; set server host name and port
.ifdef SERVER_PORT
  lda #( 3 + .strlen(SERVER_HOSTNAME) )
  sta MAP_ESP_DATA
  lda #RNBW::TO_ESP::SERVER_SET_SETTINGS
  sta MAP_ESP_DATA
  lda #>SERVER_PORT
  sta MAP_ESP_DATA
  lda #<SERVER_PORT
  sta MAP_ESP_DATA
  .repeat .strlen(SERVER_HOSTNAME),I
    lda #.strat(SERVER_HOSTNAME,I)
    sta MAP_ESP_DATA
  .endrepeat

.else

  ; set server host name and port
  lda #3
  clc
  adc hostnameLength
  sta MAP_ESP_DATA
 
  lda #RNBW::TO_ESP::SERVER_SET_SETTINGS
  sta MAP_ESP_DATA
  lda port+0
  sta MAP_ESP_DATA
  lda port+1
  sta MAP_ESP_DATA
  ldx #0
:
  lda hostname,x
  sta MAP_ESP_DATA
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
  sta MAP_ESP_DATA
  lda #RNBW::TO_ESP::SERVER_CONNECT
  sta MAP_ESP_DATA

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
  sta MAP_ESP_DATA
  lda #RNBW::TO_ESP::SERVER_GET_STATUS
  sta MAP_ESP_DATA

  ; wait for answer
:
  bit MAP_ESP_CONFIG
  bpl :-

  ; get data
  lda MAP_ESP_DATA ; dummy read
  nop
  lda MAP_ESP_DATA ; length (don't care)
  nop
  lda MAP_ESP_DATA ; command (don't care)
  nop
  lda MAP_ESP_DATA ; server status
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
  sta MAP_ESP_DATA
  lda #RNBW::TO_ESP::SERVER_SEND_MESSAGE
  sta MAP_ESP_DATA
  ldx #0
  stx MAP_ESP_DATA
:
  lda username,x
  sta MAP_ESP_DATA
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