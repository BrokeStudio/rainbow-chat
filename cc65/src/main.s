.feature c_comments
.feature force_range
.linecont +

/*
                                                                          
88                                            88                          
88                                            88                          
88                                            88                          
88,dPPYba,    ,adPPYba,  ,adPPYYba,   ,adPPYb,88   ,adPPYba,  8b,dPPYba,  
88P'    "8a  a8P_____88  ""     `Y8  a8"    `Y88  a8P_____88  88P'   "Y8  
88       88  8PP"""""""  ,adPPPPP88  8b       88  8PP"""""""  88          
88       88  "8b,   ,aa  88,    ,88  "8a,   ,d88  "8b,   ,aa  88          
88       88   `"Ybbd8"'  `"8bbdP"Y8   `"8bbdP"Y8   `"Ybbd8"'  88          
                                                                          
                                                                          
*/

.segment "HEADER"
.include "header.s"

/*
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
888888888   ,adPPYba,  8b,dPPYba,   ,adPPYba,   8b,dPPYba,   ,adPPYYba,   ,adPPYb,d8   ,adPPYba,  
     a8P"  a8P_____88  88P'   "Y8  a8"     "8a  88P'    "8a  ""     `Y8  a8"    `Y88  a8P_____88  
  ,d8P'    8PP"""""""  88          8b       d8  88       d8  ,adPPPPP88  8b       88  8PP"""""""  
,d8"       "8b,   ,aa  88          "8a,   ,a8"  88b,   ,a8"  88,    ,88  "8a,   ,d88  "8b,   ,aa  
888888888   `"Ybbd8"'  88           `"YbbdP"'   88`YbbdP"'   `"8bbdP"Y8   `"YbbdP"Y8   `"Ybbd8"'  
                                                88                        aa,    ,88              
                                                88                         "Y8bbdP"               
*/

.zeropage

zp0:                .res 1
zp1:                .res 1
zp2:                .res 1
zp3:                .res 1
zp4:                .res 1
zp5:                .res 1
zp6:                .res 1
zp7:                .res 1
zp8:                .res 1
zp9:                .res 1
zp10:               .res 1
zp11:               .res 1
zp12:               .res 1
zp13:               .res 1
zp14:               .res 1
zp15:               .res 1

zp16:               .res 1
zp17:               .res 1
zp18:               .res 1
zp19:               .res 1
zp20:               .res 1
zp21:               .res 1
zp22:               .res 1
zp23:               .res 1
zp24:               .res 1
zp25:               .res 1
zp26:               .res 1
zp27:               .res 1
zp28:               .res 1
zp29:               .res 1
zp30:               .res 1
zp31:               .res 1

/*
                                                                                  
88                           88                        88                         
""                           88                        88                         
                             88                        88                         
88  8b,dPPYba,    ,adPPYba,  88  88       88   ,adPPYb,88   ,adPPYba,  ,adPPYba,  
88  88P'   `"8a  a8"     ""  88  88       88  a8"    `Y88  a8P_____88  I8[    ""  
88  88       88  8b          88  88       88  8b       88  8PP"""""""   `"Y8ba,   
88  88       88  "8a,   ,aa  88  "8a,   ,a88  "8a,   ,d88  "8b,   ,aa  aa    ]8I  
88  88       88   `"Ybbd8"'  88   `"YbbdP'Y8   `"8bbdP"Y8   `"Ybbd8"'  `"YbbdP"'  
                                                                                  
                                                                                  
*/

; MAPPER REGISTERS
.include "mapper-registers.s"

; BUILD VERSION
.include "version.s"
.out .sprintf( "# version %s", STR_VERSION )
.out .sprintf( "# build %s", STR_BUILD )
.out ""

; NES LIB
; based on Shiru's code: https://shiru.untergrund.net/code.shtml
.segment "CODE"
.include "nes-lib/nes-lib.s"

; RAINBOW
; documentation: https://github.com/BrokeStudio/rainbow-lib
.segment "CODE"
.include "rainbow-lib/rainbow.s"

; CHAT
.segment "CODE"
.include "chat.s"

/*
                                                                               
                                                                               
             ,d                               ,d                               
             88                               88                               
,adPPYba,  MM88MMM  ,adPPYYba,  8b,dPPYba,  MM88MMM  88       88  8b,dPPYba,   
I8[    ""    88     ""     `Y8  88P'   "Y8    88     88       88  88P'    "8a  
 `"Y8ba,     88     ,adPPPPP88  88            88     88       88  88       d8  
aa    ]8I    88,    88,    ,88  88            88,    "8a,   ,a88  88b,   ,a8"  
`"YbbdP"'    "Y888  `"8bbdP"Y8  88            "Y888   `"YbbdP'Y8  88`YbbdP"'   
                                                                  88           
                                                                  88           
*/

.segment "CODE"
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
:
  sta $000,x
  sta $100,x
  sta $200,x
  sta $300,x
  sta $400,x
  sta $500,x
  sta $600,x
  sta $700,x
  inx
  bne :-

  jsr PPU::oam_clear

  lda #%10000000
  sta <PPU::CTRL_VAR
  sta PPU_CTRL        ; enable NMI
  lda #%00000110
  sta <PPU::MASK_VAR

waitSync3:
  lda PPU::FRAME_CNT1
:
  cmp PPU::FRAME_CNT1
  beq :-

  ; get TV system
  ; 0 : NTSC
  ; 1 : PAL
  ; 2 : dendy
  ; 3 : unknown
  jsr PPU::getTVSystem

  ; initialize sound APU
  ldx #$00
  txa
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
  lda #>RNBW::BUF_IN
  sta RNBW::RX_ADD
  lda #>RNBW::BUF_OUT
  sta RNBW::TX_ADD

  ; clear prg banks upper bits
  lda #0
  sta MAP_PRG_HI_6
  sta MAP_PRG_HI_7
  sta MAP_PRG_HI_9
  sta MAP_PRG_HI_A
  sta MAP_PRG_HI_B
  sta MAP_PRG_HI_C
  sta MAP_PRG_HI_D
  sta MAP_PRG_HI_F

  ; set PRG configuration
  lda #PRG_RAM_MODE_0|PRG_ROM_MODE_0
  sta MAP_PRG_CONTROL

  ; set CHR configuration
  lda #CHR_CHIP_RAM|CHR_MODE_0
  sta MAP_CHR_CONTROL

  ; select 8K CHR bank
  lda #0
  sta MAP_CHR_LO_0

  ; set palette brightness
  lda #4
  sta PPU::palBrightness
  jsr PPU::setPaletteBrightness

  ; set palette fade delay
  lda #2
  sta PPU::palFadeDelay

  ; load palette
  ldx #>chatPAL
  lda #<chatPAL
  jsr PPU::pal_all

  ; push palette updates
  jsr PPU::flushPalette

  ; set BG CHR page
  lda #0
  jsr PPU::setBG_bank

  ; set SPR CHR page
  lda #0
  jsr PPU::setSPR_bank

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
  jsr PPU::vram_unrle

  ; start chat
  jsr startChat

/*
                                     
                                 88  
                                 ""  
                                     
8b,dPPYba,   88,dPYba,,adPYba,   88  
88P'   `"8a  88P'   "88"    "8a  88  
88       88  88      88      88  88  
88       88  88      88      88  88  
88       88  88      88      88  88  
                                     
                                     
*/

.proc vector_nmi
  ; save stack
  pha
  txa
  pha
  tya
  pha

  ; if rendering is disabled, do not access the VRAM at all
  lda PPU::MASK_VAR
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
  lda <PPU::palUpdate
  beq updVRAM
  bmi fadePal
  jmp flushPal
fadePal:

  jsr PPU::fadePalette
  jmp updVRAM

flushPal:

  jsr PPU::flushPalette

updVRAM:

  lda PPU::VRAM_UPDATE
  beq skipUpd
  stx PPU::VRAM_UPDATE
  
  lda PPU::NAME_UPD_ENABLE
  beq skipUpd

  jsr PPU::flush_vram_update_nmi

skipUpd:

  lda #$00
  sta PPU_ADDR
  sta PPU_ADDR

  sta PPU_SCROLL
  sta PPU_SCROLL

skipAll:

  lda PPU::CTRL_VAR
  sta PPU_CTRL

  lda PPU::MASK_VAR
  sta PPU_MASK

skipClassicNMI:

  inc PPU::FRAME_CNT1
  inc PPU::FRAME_CNT2
  lda PPU::FRAME_CNT2
  cmp #$06
  bne skipNtsc
  lda #$00
  sta PPU::FRAME_CNT2

skipNtsc:

  ; restore stack
  pla
  tay
  pla
  tax
  pla

  ; return
  rti
.endproc

/*
                             
88                           
""                           
                             
88  8b,dPPYba,   ,adPPYb,d8  
88  88P'   "Y8  a8"    `Y88  
88  88          8b       88  
88  88          "8a    ,d88  
88  88           `"YbbdP'88  
                         88  
                         88  
*/

.proc vector_irq
  rti
.endproc

/*
                                              
         88                                   
         88                ,d                 
         88                88                 
 ,adPPYb,88  ,adPPYYba,  MM88MMM  ,adPPYYba,  
a8"    `Y88  ""     `Y8    88     ""     `Y8  
8b       88  ,adPPPPP88    88     ,adPPPPP88  
"8a,   ,d88  88,    ,88    88,    88,    ,88  
 `"8bbdP"Y8  `"8bbdP"Y8    "Y888  `"8bbdP"Y8  
                                              
                                              
*/

asciiCHR:
  .incbin "gfx/ascii.chr.rle"

/*
                                                                         
                                             88  88                      
                                             88  ""    ,d                
                                             88        88                
 ,adPPYba,  8b,dPPYba,   ,adPPYba,   ,adPPYb,88  88  MM88MMM  ,adPPYba,  
a8"     ""  88P'   "Y8  a8P_____88  a8"    `Y88  88    88     I8[    ""  
8b          88          8PP"""""""  8b       88  88    88      `"Y8ba,   
"8a,   ,aa  88          "8b,   ,aa  "8a,   ,d88  88    88,    aa    ]8I  
 `"Ybbd8"'  88           `"Ybbd8"'   `"8bbdP"Y8  88    "Y888  `"YbbdP"'  
                                                                         
                                                                         
*/

credits:
  .byte "/Rainbow Chat example v"
  version:
  .byte STR_VERSION
  .byte "b"
  build:
  .byte STR_BUILD
  .byte "/2020-2026 Broke Studio"
  .byte "/code Antoine Gohin"
  .byte "/thx Ludy<3/"

/*
                                                                                 
                                                                                 
                                       ,d                                        
                                       88                                        
8b       d8   ,adPPYba,   ,adPPYba,  MM88MMM  ,adPPYba,   8b,dPPYba,  ,adPPYba,  
`8b     d8'  a8P_____88  a8"     ""    88    a8"     "8a  88P'   "Y8  I8[    ""  
 `8b   d8'   8PP"""""""  8b            88    8b       d8  88           `"Y8ba,   
  `8b,d8'    "8b,   ,aa  "8a,   ,aa    88,   "8a,   ,a8"  88          aa    ]8I  
    "8"       `"Ybbd8"'   `"Ybbd8"'    "Y888  `"YbbdP"'   88          `"YbbdP"'  
                                                                                 
                                                                                 
*/

.segment "VECTORS"
  .word vector_nmi    ; $FFFA vblank nmi
  .word vector_reset  ; $FFFC reset
  .word vector_irq    ; $FFFE irq / brk
