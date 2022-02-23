; ####################################################################################################
; ZEROPAGE

; PPU

.enum $0020

FRAME_CNT1          .dsb 1
FRAME_CNT2          .dsb 1

PPU_CTRL_VAR        .dsb 1
PPU_MASK_VAR        .dsb 1

tvSystem            .dsb 1

palUpdate           .dsb 1
PAL_BG_PTR          .dsb 2
PAL_SPR_PTR         .dsb 2

palBrightness       .dsb 1
palFadeTo           .dsb 1
palFadeDelay        .dsb 1
palFadeCounter      .dsb 1

PTR                 .dsb 2
LEN                 .dsb 1
VRAM_UPDATE         .dsb 1
NAME_UPD_ENABLE     .dsb 1
NAME_UPD_ADR        .dsb 2
; NAME_UPD_PTR        .dsb 2 ; not used for now

TEMP                EQU $00

; SYSTEM

; prng var
seed               .dsb 2  ; initialize 16-bit seed to any value except 0

; mult8x8 / mult16x8 / mult16x16

multNum1    EQU $00   ; word
multNum2    EQU $01   ; byte / word
product     EQU $03   ; double

; div16_16

divisor     EQU $00   ; word
dividend    EQU $01   ; word
remainder   EQU $03   ; word
result      EQU dividend  ; save memory by reusing dividend to store the result

; Binary2Decimal vars

tempBinary         .dsb 2
decimalResult      .dsb 5

; PAD

padStateOld        .dsb 1
padState           .dsb 1
padPressed         .dsb 1
padReleased        .dsb 1

.ende

.include "nes-lib/constants.asm"
.include "nes-lib/ppu.asm"
.include "nes-lib/system.asm"
.include "nes-lib/pad.asm"