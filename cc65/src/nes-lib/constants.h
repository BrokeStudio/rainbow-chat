; ####################################################################################################
; NES LIB CONSTANTS

.ifndef _NES_LIB_H_
  _NES_LIB_H_ = 1
  
  ;DEBUG = 1

  PPU_CTRL        = $2000
  PPU_MASK        = $2001
  PPU_STATUS      = $2002
  PPU_OAM_ADDR    = $2003
  PPU_OAM_DATA    = $2004
  PPU_SCROLL      = $2005
  PPU_ADDR        = $2006
  PPU_DATA        = $2007
  PPU_OAM_DMA     = $4014
  PPU_FRAMECNT    = $4017
  DMC_FREQ        = $4010
  CTRL_PORT1      = $4016
  CTRL_PORT2      = $4017

  OAM_BUF         = $0200
  PALETTE         = $0160 ;$01A0
  PAL_BUF         = $0180 ;$01C0

  ; #####

  PAD_A           = $01
  PAD_B           = $02
  PAD_SELECT      = $04
  PAD_START       = $08
  PAD_UP          = $10
  PAD_DOWN        = $20
  PAD_LEFT        = $40
  PAD_RIGHT       = $80

  OAM_FLIP_V      = $80
  OAM_FLIP_H      = $40
  OAM_BEHIND      = $20

  MASK_SPR        = $10
  MASK_BG         = $08
  MASK_EDGE_SPR   = $04
  MASK_EDGE_BG    = $02

  NAMETABLE_A     = $2000
  NAMETABLE_B     = $2400
  NAMETABLE_C     = $2800
  NAMETABLE_D     = $2C00

  ATTRIBUTE_A     = $23C0
  ATTRIBUTE_B     = $27C0
  ATTRIBUTE_C     = $2BC0
  ATTRIBUTE_D     = $2FC0

  NULL            = 0
  TRUE            = 1
  FALSE           = 0

  NT_UPD_HORZ     = $40
  NT_UPD_VERT     = $80
  NT_UPD_EOF      = $FF

.endif