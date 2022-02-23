; ascii art font generator : http://patorjk.com/software/taag/#p=display&f=Small
.include "version.asm"

; ################################################################################
; HEADER

.enum $0000

NES_MAPPER    EQU 3872
NES_PRG_BANKS EQU 32
NES_CHR_BANKS EQU 0
NES_MIRRORING EQU 0

.ende

; NES 2.0 format
.db "NES", $1A      ; flags 0-3: ines magic
.db <NES_PRG_BANKS  ; flag 4
.db <NES_CHR_BANKS  ; flag 5
.db <(NES_MIRRORING|(NES_MAPPER&$0F)<<4) ; flag 6
.db <((NES_MAPPER&$F0)|%00001000) ; flag 7: upper nybble of mapper number + iNES 2.0
.db <((NES_MAPPER&$F00)>>8) ; flag 8
.db 0 ; flag 9
.db 0 ; flag 10: PRG-RAM shift counter - (64 << shift counter)
.db 9 ; flag 11: CHR-RAM shift counter - (64 << shift counter)
.db $00   ; flag 12
.db $00   ; flag 13
.db $00   ; flag 14
.db $00   ; flag 15

; ################################################################################
; ZEROPAGE

  .enum $0000

    zp0   .dsb 1
    zp1   .dsb 1
    zp2   .dsb 1
    zp3   .dsb 1
    zp4   .dsb 1
    zp5   .dsb 1
    zp6   .dsb 1
    zp7   .dsb 1
    zp8   .dsb 1
    zp9   .dsb 1
    zp10  .dsb 1
    zp11  .dsb 1
    zp12  .dsb 1
    zp13  .dsb 1
    zp14  .dsb 1
    zp15  .dsb 1

    zp16  .dsb 1
    zp17  .dsb 1
    zp18  .dsb 1
    zp19  .dsb 1
    zp20  .dsb 1
    zp21  .dsb 1
    zp22  .dsb 1
    zp23  .dsb 1
    zp24  .dsb 1
    zp25  .dsb 1
    zp26  .dsb 1
    zp27  .dsb 1
    zp28  .dsb 1
    zp29  .dsb 1
    zp30  .dsb 1
    zp31  .dsb 1

	.ende

; ################################################################################
; PADDING

  .rept 31
	.base $8000
	.org $c000
  .endr

  .base $c000
	.org $e000

; ################################################################################
; INCLUDES

.include "mapper-registers.asm"

; NES LIB
; based on Shiru's code: https://shiru.untergrund.net/code.shtml
.org $E000
.include "nes-lib/nes-lib.asm"

; RAINBOW
; documentation: https://github.com/BrokeStudio/rainbow-lib
.include "rainbow-lib/rainbow.asm"

; CHAT
.include "chat.asm"

; ################################################################################
; CONSTANTS

; ################################################################################
; CODE

  vector_reset:

  cld
  sei
  ldx #$FF
  txs

initPPU1:
  lda PPU_STATUS
  bpl initPPU1
initPPU2:
  lda PPU_STATUS
  bpl initPPU2

  ldx #$00
  stx PPU_MASK
  stx DMC_FREQ
  stx PPU_CTRL        ;no NMI

clearRAM:
  txa
-
  sta $000,x
  sta $100,x
  sta $200,x
  sta $300,x
  sta $400,x
  sta $500,x
  sta $600,x
  sta $700,x
  inx
  bne -

  jsr oam_clear

  lda #%10000000
  sta <PPU_CTRL_VAR
  sta PPU_CTRL        ; enable NMI
  lda #%00000110
  sta <PPU_MASK_VAR

waitSync3:
  lda FRAME_CNT1
-
  cmp FRAME_CNT1
  beq -

  ; get TV system
  ; 0 : NTSC
  ; 1 : PAL
  ; 2 : dendy
  ; 3 : unknown
  jsr getTVSystem

  ; initialize sound APU
  ldx #$00
apu_clear_loop:
  sta $4000, X            ; write 0 to most APU registers
  inx
  cpx #$13
  bne apu_clear_loop
  ldx #$00
  stx $4015               ; turn off square/noise/triangle/DPCM channels

  ; acknowledge/disable both APU IRQs
  ; (frame counter and DMC completion)
  lda #$40
  sta $4017  ; APU IRQ: OFF!
  lda $4015  ; APU IRQ: ACK!

  ; disable ESP for now
  lda #0
  sta MAP_RNBW_CONFIG

  ; init Rainbow RX/TX RAM addresses
  lda #>RNBW_BUF_IN
  sta RNBW_RX_ADD
  lda #>RNBW_BUF_OUT
  sta RNBW_TX_ADD

  ; mapper init
  lda #%00011100
  sta MAP_CONFIG

  ; select 8K CHR bank
  lda #0
  sta MAP_CHR_0

  ; set palette brightness
  lda #4
  sta palBrightness
  jsr setPaletteBrightness

  ; set palette fade delay
  lda #2
  sta palFadeDelay

  ; load palette
  ldx #>chatPAL
  lda #<chatPAL
  jsr pal_all

  ; push palette updates
  jsr flushPalette

  ; set BG CHR page
  lda #0
  jsr setBG_bank

  ; set SPR CHR page
  lda #0
  jsr setSPR_bank

  ; enable all channels but DPCM
  ;lda #$0F
  ;sta $4015

  ; set VRAM address
  lda #$00
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR

  ; load CHR data
  ldx #>asciiCHR
  lda #<asciiCHR
  jsr vram_unrle

  ; start chat
  jsr startChat

; ################################################################################
; NMI HANDLER

vector_nmi:
  ; save stack
  pha
  txa
  pha
  tya
  pha

  ; if rendering is disabled, do not access the VRAM at all
  lda PPU_MASK_VAR
  and #%00011000
  bne doUpdate
  jmp skipAll

doUpdate:

  ; update OAM
  ldx #$00
  stx PPU_OAM_ADDR
  lda #>OAM_BUF
  sta PPU_OAM_DMA

  ; update palette if needed
  lda <palUpdate
  beq updVRAM
  bmi fadePal
  jmp flushPal
fadePal:

  jsr fadePalette
  jmp updVRAM

flushPal:

  jsr flushPalette

updVRAM:

  lda VRAM_UPDATE
  beq skipUpd
  stx VRAM_UPDATE
  
  lda NAME_UPD_ENABLE
  beq skipUpd

  jsr flush_vram_update_nmi

skipUpd:

  lda #$00
  sta PPU_ADDR
  sta PPU_ADDR

  sta PPU_SCROLL
  sta PPU_SCROLL

skipAll:

  lda PPU_CTRL_VAR
  sta PPU_CTRL

  lda PPU_MASK_VAR
  sta PPU_MASK

skipClassicNMI:

  inc FRAME_CNT1
  inc FRAME_CNT2
  lda FRAME_CNT2
  cmp #$06
  bne skipNtsc
  lda #$00
  sta FRAME_CNT2

skipNtsc:

  ; restore stack
  pla
  tay
  pla
  tax
  pla

  ; return
  rti


; ################################################################################
; IRQ HANDLER

vector_irq:
  rti


; ################################################################################
; DATAS

asciiCHR:
  .incbin "gfx/ascii.chr.rle"

; ################################################################################
; CREDITS

credits:
  .db "/Rainbow Chat example v"
  version:
  .db STR_VERSION
  .db "b"
  build:
  .db STR_BUILD
  .db "/2020-2022 Broke Studio"
  .db "/code Antoine Gohin"
  .db "/thx Ludy<3/"

; ################################################################################
; VECTORS

  .org $FFFA
;.segment "VECTORS"
  .word vector_nmi    ; $FFFA vblank nmi
  .word vector_reset  ; $FFFC reset
  .word vector_irq    ; $FFFE irq / brk
