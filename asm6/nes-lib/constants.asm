; ####################################################################################################
; NES LIB CONSTANTS

  PPU_CTRL        EQU $2000
  PPU_MASK        EQU $2001
  PPU_STATUS      EQU $2002
  PPU_OAM_ADDR    EQU $2003
  PPU_OAM_DATA    EQU $2004
  PPU_SCROLL      EQU $2005
  PPU_ADDR        EQU $2006
  PPU_DATA        EQU $2007
  PPU_OAM_DMA     EQU $4014
  PPU_FRAMECNT    EQU $4017
  DMC_FREQ        EQU $4010
  CTRL_PORT1      EQU $4016
  CTRL_PORT2      EQU $4017

  OAM_BUF         EQU $0200
  PALETTE         EQU $0160 ;$01A0
  PAL_BUF         EQU $0180 ;$01C0

  ; #####

  PAD_A           EQU $01
  PAD_B           EQU $02
  PAD_SELECT      EQU $04
  PAD_START       EQU $08
  PAD_UP          EQU $10
  PAD_DOWN        EQU $20
  PAD_LEFT        EQU $40
  PAD_RIGHT       EQU $80

  OAM_FLIP_V      EQU $80
  OAM_FLIP_H      EQU $40
  OAM_BEHIND      EQU $20

  MASK_SPR        EQU $10
  MASK_BG         EQU $08
  MASK_EDGE_SPR   EQU $04
  MASK_EDGE_BG    EQU $02

  NAMETABLE_A     EQU $2000
  NAMETABLE_B     EQU $2400
  NAMETABLE_C     EQU $2800
  NAMETABLE_D     EQU $2C00

  ATTRIBUTE_A     EQU $23C0
  ATTRIBUTE_B     EQU $27C0
  ATTRIBUTE_C     EQU $2BC0
  ATTRIBUTE_D     EQU $2FC0

  NULL            EQU 0
  TRUE            EQU 1
  FALSE           EQU 0

  NT_UPD_HORZ     EQU $40
  NT_UPD_VERT     EQU $80
  NT_UPD_EOF      EQU $FF
