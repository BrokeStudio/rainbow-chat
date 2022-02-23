; ################################################################################
; CODE

chatConnect:

  ; enable ESP
  lda #1
  sta RNBW_CONFIG

  ; set server protocol
  lda #2
  sta RNBW_BUF_OUT+0
  lda #TOESP_SERVER_SET_PROTOCOL
  sta RNBW_BUF_OUT+1
  lda #RNBW_PROTOCOL_WEBSOCKET
  sta RNBW_BUF_OUT+2
  sta RNBW_TX

  ; wait for message to be sent
-
  bit RNBW_TX
  bpl -

  ; set server host name and port
.ifdef localhost

  SERVER_PORT EQU 8000

  lda #3 + 9  ; 9 = length of 127.0.0.1
  sta RNBW_BUF_OUT+0
  lda #TOESP_SERVER_SET_SETTINGS
  sta RNBW_BUF_OUT+1
  lda #>SERVER_PORT
  sta RNBW_BUF_OUT+2
  lda #<SERVER_PORT
  sta RNBW_BUF_OUT+3

  ; 127.0.0.1
  lda #'1'
  sta RNBW_BUF_OUT+4
  lda #'2'
  sta RNBW_BUF_OUT+5
  lda #'7'
  sta RNBW_BUF_OUT+6
  lda #'.'
  sta RNBW_BUF_OUT+7
  lda #'0'
  sta RNBW_BUF_OUT+8
  lda #'.'
  sta RNBW_BUF_OUT+9
  lda #'0'
  sta RNBW_BUF_OUT+10
  lda #'.'
  sta RNBW_BUF_OUT+11
  lda #'1'
  sta RNBW_BUF_OUT+12

.else

  ; set server host name and port
  lda #3
  clc
  adc hostnameLength
  sta RNBW_BUF_OUT+0
 
  lda #TOESP_SERVER_SET_SETTINGS
  sta RNBW_BUF_OUT+1
  lda port+0
  sta RNBW_BUF_OUT+2
  lda port+1
  sta RNBW_BUF_OUT+3
  ldx #0
-
  lda hostname,x
  sta RNBW_BUF_OUT+4,x
  inx
  cpx hostnameLength
  bne -

.endif

  ; send message
  sta RNBW_TX

  ; wait for message to be sent
-
  bit RNBW_TX
  bpl -

  ; connecting to server
  lda #<txtConnecting
  ldx #>txtConnecting
  jsr set_vram_update
  jsr waitNMI

  ; connect to server
connectToServer:

  ; send command
  lda #1
  sta RNBW_BUF_OUT+0
  lda #TOESP_SERVER_CONNECT
  sta RNBW_BUF_OUT+1
  sta RNBW_TX

  ; wait for message to be sent
-
  bit RNBW_TX
  bpl -

  ; let's ask for server status every 2 seconds
  ; if we're still not connected after 20 seconds
  ; then try to connect again...
checkServerStatus:
  ldy #10
wait2seconds:
  ldx #120
-
  jsr waitNMI
  dex
  bne -

  ; check server status
  lda #1
  sta RNBW_BUF_OUT+0
  lda #TOESP_SERVER_GET_STATUS
  sta RNBW_BUF_OUT+1
  sta RNBW_TX

  ; wait for message to be sent
-
  bit RNBW_TX
  bpl -
  
  ; wait for answer
-
  bit RNBW_RX
  bpl -

  ; get data
  ; ignore message length and opcode/command
  lda RNBW_BUF_IN+2 ; server status
  sta RNBW_RX  ; acknowledge answer
  cmp #RNBW_SERVER_CONNECTED
  beq connected

  dey
  bne wait2seconds
  jmp connectToServer

connected:

  ; register username
  lda #2
  clc
  adc usernameLength
  sta RNBW_BUF_OUT+0
  lda #TOESP_SERVER_SEND_MSG
  sta RNBW_BUF_OUT+1
  ldx #0
  stx RNBW_BUF_OUT+2
-
  lda username,x
  sta RNBW_BUF_OUT+3,x
  inx
  cpx usernameLength
  bne -
  sta RNBW_TX
  ; wait for message to be sent
-
  bit RNBW_TX
  bpl -


  ; connected to server
;  lda #<txtConnected
;  ldx #>txtConnected
;  jsr set_vram_update
;:
;  jsr waitNMI

  ; wait for user to press a button before clearing the message
;  ldy #0
;  jsr pad::read
;  lda pad::pressed
;  and #PAD_START
;  beq :-

  ; clear text
  lda #<txtBlank
  ldx #>txtBlank
  jsr set_vram_update
  jsr waitNMI

  jmp chatInit


; ################################################################################
; DATA

txtConnecting:
  .db $22|NT_UPD_HORZ,$62,28
  .db "CONNECTING...               "
  .db $ff

;txtConnected:
;  .db $22|NT_UPD_HORZ,$62,28
;  .db "CONNECTED...   (press START)"
;  .db $ff
