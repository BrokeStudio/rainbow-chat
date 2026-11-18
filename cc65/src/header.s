/*
                                                                                                   
                                                         88           88                           
                                      ,d                 ""           88                           
                                      88                              88                           
 ,adPPYba,  ,adPPYYba,  8b,dPPYba,  MM88MMM  8b,dPPYba,  88   ,adPPYb,88   ,adPPYb,d8   ,adPPYba,  
a8"     ""  ""     `Y8  88P'   "Y8    88     88P'   "Y8  88  a8"    `Y88  a8"    `Y88  a8P_____88  
8b          ,adPPPPP88  88            88     88          88  8b       88  8b       88  8PP"""""""  
"8a,   ,aa  88,    ,88  88            88,    88          88  "8a,   ,d88  "8a,   ,d88  "8b,   ,aa  
 `"Ybbd8"'  `"8bbdP"Y8  88            "Y888  88          88   `"8bbdP"Y8   `"YbbdP"Y8   `"Ybbd8"'  
                                                                           aa,    ,88              
                                                                            "Y8bbdP"               
*/

; change those values to your needs
PRG_ROM_SIZE    = 32    ; up to 8192
CHR_ROM_SIZE    = 0     ; up to 8192

PRG_RAM_SIZE    = 256   ; possible values: 0, 32, 128, 256
CHR_RAM_SIZE    = 32    ; possible values: 0, 32, 128, 256

BATTERY         = 0     ; 0: no | 1: yes

; do not change values below
MAPPER          = 682
PRG_ROM_BANKS   = PRG_ROM_SIZE / 16
CHR_ROM_BANKS   = CHR_ROM_SIZE / 8
BATTERY_FLAG    = BATTERY << 1

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

.byte "NES", $1A
.byte <PRG_ROM_BANKS
.byte <CHR_ROM_BANKS

.byte ((MAPPER & $0F) << 4) | BATTERY_FLAG
.byte ((MAPPER & $F0) | %00001000) ; iNES 2.0 flag
.byte (MAPPER & $F00) >> 8
.byte ((>CHR_ROM_BANKS) << 4) | >PRG_ROM_BANKS

; PRG-RAM
.if PRG_RAM_SIZE = 0
    .byte 0
.elseif PRG_RAM_SIZE = 32
    .byte 9
.elseif PRG_RAM_SIZE = 128
    .byte 11
.elseif PRG_RAM_SIZE = 256
    .byte 12
.else
    .error "PRG-RAM size unsupported"
.endif

; CHR-RAM
.if CHR_RAM_SIZE = 0
    .byte 0
.elseif CHR_RAM_SIZE = 32
    .byte 9
.elseif CHR_RAM_SIZE = 128
    .byte 11
.elseif CHR_RAM_SIZE = 256
    .byte 12
.else
    .error "CHR-RAM size unsupported"
.endif

.byte 0, 0, 0, 0    ; padding