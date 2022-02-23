; ####################################################################################################
; SYSTEM LIBRARY
.out    "# system library..."

.scope system

    ; ####################################################################################################
    ; ZEROPAGE
    .pushseg
    .zeropage

    ; prng var
    seed:               .res 2  ; initialize 16-bit seed to any value except 0

    ; mult8x8 / mult16x8 / mult16x16

    multNum1    = $00   ; word
    multNum2    = $01   ; byte / word
    product     = $03   ; double

    ; div16_16

    divisor     = $00   ; word
    dividend    = $01   ; word
    remainder   = $03   ; word
    result      = dividend  ; save memory by reusing dividend to store the result

    ; Binary2Decimal vars

    tempBinary:         .res 2
    decimalResult:      .res 5
    .popseg

    ; ####################################################################################################
    ; CODE

    .proc delayNMI
        ; X = number of NMIs
    :
        jsr PPU::waitNMI
        dex
        bne :-

        rts
    .endproc

    .proc delayFrame
        ; X = number of frames
    :
        jsr PPU::waitFrame
        dex
        bne :-

        rts
    .endproc

    .proc div16_16

    divide:
        lda #0          ;preset remainder to 0
        sta remainder
        sta remainder+1
        ldx #16         ;repeat for each bit: ...

    divloop:
        asl dividend    ;dividend lb & hb*2, msb -> Carry
        rol dividend+1  
        rol remainder   ;remainder lb & hb * 2 + msb from carry
        rol remainder+1
        lda remainder
        sec
        sbc divisor     ;substract divisor to see if it fits in
        tay             ;lb result -> Y, for we may need it later
        lda remainder+1
        sbc divisor+1
        bcc skip        ;if carry=0 then divisor didn't fit in yet

        sta remainder+1 ;else save substraction result as new remainder,
        sty remainder   
        inc result      ;and INCrement result cause divisor fit in 1 times

    skip:
        dex
        bne divloop

        rts

    .endproc

    ; prng
    ; 
    ; Returns a random 8-bit number in A (0-255), clobbers X (0).
    ; 
    ; Requires a 2-byte value on the zero page called "seed".
    ; Initialize seed to any value except 0 before the first call to prng.
    ; (A seed value of 0 will cause prng to always return 0.)
    ; 
    ; This is a 16-bit Galois linear feedback shift register with polynomial $002D.
    ; The sequence of numbers it generates will repeat after 65535 calls.
    ; 
    ; The value loaded in X controls the quality of randomness. Each iteration produces another bit worth of entropy.
    ; 8 bits will produce maximum entropy, but this value can be lowered to increase speed.
    ; Valid values are 8, 7, 4, 2, 1. (Avoid 6, 5 and 3, as they shorten the sequence by having common factors with 65535.)
    ; 
    ; Execution time is an average of 125 cycles (excluding jsr and rts)
    ; https://wiki.nesdev.com/w/index.php/Random_number_generator
    .proc prng
        ldx #8     ; iteration count: controls entropy quality (max 8,7,4,2,1 min)
        lda seed+0
    :
        asl        ; shift the register
        rol seed+1
        bcc :+
        eor #$2D   ; apply XOR feedback whenever a 1 bit is shifted out
    :
        dex
        bne :--
        sta seed+0
        cmp #0     ; reload flags
        rts
    .endproc

.endscope