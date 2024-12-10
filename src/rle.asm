; Does rle-encoding for being used in pdf streams with filter RunLengthDecode.
; We can't write this file to disk on-the-fly, because before writing this data,
;  we need to provide the length of the encoded stream, which is a result of this process.
;
; solution:
;  iterate over bytes, while not eof and not . if same byte, count.
;  if different bytes, keep start address of series change.
;  
;
; Parameters:
; - Source address
; - Target address
;
source_address  = $fb       ; -$fc
target_address  = $fd       ; -$fe
run_start       = $f9       ; -$fa. originally contains rs232-output buffer. is saved in zero_store
data_length     = $334      ; -$335. value 8000 (=$1f40). 40x25 cells, 1x8 bytes each

comp_value      = $3fc      ; used to compare if repeating byte or single byte
run_length      = $3fd      ; how long is the current series?

y_read          = $336
y_write         = $337
zero_store      = $338      ;-$339: pointer to rs232-output buffer

rle_encode
; store values of $f9,$fa for later restore when done with this method
    lda run_start
    sta zero_store
    lda run_start+1
    sta zero_store+1

;read from tape buffer
    lda #$3c
    sta source_address
    lda #$3
    sta source_address+1

;write to $2a7 (679) for the time being (free mem up to 767/$2ff)
    lda #$a7
    sta target_address
    lda #$2
    sta target_address+1

;clear target memory area. 64 bytes for now
    ldy #0
    lda (target_address),y
    beq +

    ldy #32
    lda #0
-   sta (target_address),y
    dey
    bpl -

+   lda #18
    sta data_length
    lda #0
    sta data_length+1
;    lda #$40
;    sta data_length
;    lda #$1f
;    sta data_length+1

    ldy #0
    sty y_read
    sty y_write

    lda (source_address),y          ; read current value
    jsr .increase_read_offset       ; increase offset
    sta comp_value                  ; store current value
    
    lda #$ff                        ;-1
    jmp +

.start
    lda #0
+   sta run_length

    lda source_address+1
    sta run_start+1
    lda source_address
    sta run_start

    ldy y_read
    sty y_store
    lda (source_address),y          ; read next value
    jsr .increase_read_offset
    bcs .end

    ;compare values
    cmp comp_value
    beq .repeated_bytes
    bne .literal_series

.repeated_bytes
-   sta comp_value
    inc run_length
    bmi .write_repeated_bytes       ; check if we reached the limit of 127 values. if so, write run to output

    lda (source_address),y          ; read next value
    jsr .increase_read_offset
    bcs .end

    cmp comp_value
    beq -

.write_repeated_bytes
    sty y_read
    ldy y_write

    pha                             ; store current value

    sec
    lda #0
    sbc run_length
    sta (target_address),y
    jsr .increase_write_offset

    lda comp_value
    sta (target_address),y
    jsr .increase_write_offset
    sty y_write

    pla
    sta comp_value
    jmp .start


.literal_series
    ;lda #0
    ;sta run_length

;set series start to current source address (HB from source address, LB=low byte from source address+y)
    ldy y_read

    jmp +

-   inc run_length
    bmi .write_literal_series       ;127 values reached. commit the literal series and jump to start

+   lda (source_address),y          ; read next value

    ;compare values
    cmp comp_value
    sta comp_value
    beq .write_literal_series       ; we found matching values. end the literal series
    
    jsr .increase_read_offset
    bcs .end
    jmp -

    rts

.end
    ;write terminating byte 
    lda #$80
    ldy y_write
    sta (target_address),y

    ;recover zero-page addresses
    lda zero_store
    sta run_start
    lda zero_store+1
    sta run_start+1

    clc
    rts

.write_literal_series
    sty y_read

    ;write series length
    lda run_length
    ldy y_write
    sta (target_address),y
    jsr .increase_write_offset
    sty y_write

    ;write literal values
-   ldy y_store
    lda (run_start),y
    iny
    sty y_store                     ;use this as the series-related y read offset

    ldy y_write
    sta (target_address),y
    jsr .increase_write_offset
    sty y_write
    dec run_length
    bpl -

    jmp .start

.increase_write_offset
    iny
    bne +
    inc target_address+1

+   rts

; increases read-offset, also decreases data_length to find out if we reached EOF
; carry-set means end of input is reached
.increase_read_offset
    clc         ; clear carry flag

    iny
    bne +
    inc source_address+1

+   dec data_length
    bne ++               ;LB not zero, we're not at EOF
    lda data_length+1
    bmi +                   ;HB is zero (and LB is, too), we're at EOF
    dec data_length+1
    jmp ++

+   sec
++  rts


;---------------------
;variable space
;---------------------
