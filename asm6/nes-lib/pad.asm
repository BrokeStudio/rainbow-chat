; ####################################################################################################
; PAD LIBRARY

; ####################################################################################################
; CODE

padRead:

; Y = controller # ( 0 | 1 )

	lda padState
	sta padStateOld         ; save previous joypad data
	lda #%01111111
	sta padState
	sta $4016
	asl A
	sta $4016
	-
	lda $4016,y
	and #$03                ; props to Disch for Famicon support
	cmp #$01
	ror padState            ; right, left, down, up, start, select, B, A
	bcs -

	lda #0
	sta $4016
	lda #1
	sta $4016

	lda padStateOld
	eor #$FF
	and padState
	sta padPressed          ; this tracks off-to-on transitions.

	lda padState
	eor #$FF
	and padStateOld
	sta padReleased         ; this tracks on-to-off transitions

	lda padState

	rts
