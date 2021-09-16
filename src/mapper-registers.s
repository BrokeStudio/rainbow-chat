; ################################################################################
; MAPPER REGISTERS

; ESP / WiFi
MAP_ESP_DATA        = $4100
MAP_ESP_CONFIG      = $4101

; Mapper configuration
MAP_CONFIG          = $4110
MAP_VERSION         = $4113

; PRG banking
MAP_PRG_8           = $4120
MAP_PRG_A           = $4121
MAP_PRG_C           = $4122
MAP_PRG_5           = $4123
MAP_PRG_6           = $4124

; CHR banking
MAP_CHR_0           = $4130
MAP_CHR_1           = $4131
MAP_CHR_2           = $4132
MAP_CHR_3           = $4133
MAP_CHR_4           = $4134
MAP_CHR_5           = $4135
MAP_CHR_6           = $4136
MAP_CHR_7           = $4137

MAP_CHR_BIT_0           = $4138 ;$4170
MAP_CHR_BIT_1           = $4138 ;$4171
MAP_CHR_BIT_2           = $4138 ;$4172
MAP_CHR_BIT_3           = $4138 ;$4173
MAP_CHR_BIT_4           = $4138 ;$4174
MAP_CHR_BIT_5           = $4138 ;$4175
MAP_CHR_BIT_6           = $4138 ;$4176
MAP_CHR_BIT_7           = $4138 ;$4177

MAP_CHR_UPPER_BIT   = $4138

; IRQ
MAP_IRQ_LATCH       = $4140
MAP_IRQ_RELOAD      = $4141
MAP_IRQ_DISABLE     = $4142
MAP_IRQ_ENABLE      = $4143

; Audio expansion
MAP_SND_P1_CTRL     = $4150
MAP_SND_P1_LOW      = $4151
MAP_SND_P1_HIGH     = $4152
MAP_SND_P2_CTRL     = $4153
MAP_SND_P2_LOW      = $4154
MAP_SND_P2_HIGH     = $4155
MAP_SND_SAW_ACC     = $4156
MAP_SND_SAW_LOW     = $4157
MAP_SND_SAW_HIGH    = $4158

; Multiplier

MAP_MUL_A           = $4160
MAP_MUL_B           = $4161

; ################################################################################
; MAPPER FLAGS / MASKS

PRG_MODE_16K_8K_8K    = %00000000 ; 16K + 8K + 8K fixed
PRG_MODE_8K_8K_8K_8K  = %00000001 ; 8K + 8K + 8K fixed
PRG_MODE_CLEAR        = %00000001^$ff

CHR_MODE_1K           = %00000000 ; 1K mode
CHR_MODE_2K           = %00000010 ; 2K mode
CHR_MODE_4K           = %00000100 ; 4K mode
CHR_MODE_8K           = %00000110 ; 8K mode
CHR_MODE_MASK         = %00000110
CHR_MODE_CLEAR        = CHR_MODE_MASK^$ff

CHR_CHIP_ROM          = %00000000 ; CHR-ROM
CHR_CHIP_RAM          = %00001000 ; CHR-RAM
CHR_CHIP_MASK         = %00001000
CHR_CHIP_CLEAR        = CHR_CHIP_MASK^$ff

MIRRORING_VERTICAL    = %00000000 ; VRAM
MIRRORING_HORIZONTAL  = %00010000 ; VRAM
MIRRORING_ONE_SCREEN  = %00100000 ; VRAM
MIRRORING_FOUR_SCREEN = %00110000 ; VRAM + CHR-RAM

MIRRORING_MASK        = %00110000
MIRRORING_CLEAR       = MIRRORING_MASK^$ff

CHR_SCREEN_SELECT_MASK  = %11000000
CHR_SCREEN_SELECT_CLEAR = CHR_SCREEN_SELECT_MASK^$ff

CHR_1_SCREEN_A        = %00000000
CHR_1_SCREEN_B        = %01000000
CHR_1_SCREEN_C        = %10000000
CHR_1_SCREEN_D        = %11000000

CHR_4_SCREEN_ABCD     = %00000000
CHR_4_SCREEN_EFGH     = %01000000
CHR_4_SCREEN_IJKL     = %10000000
CHR_4_SCREEN_MNOP     = %11000000
