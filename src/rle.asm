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
series_start    = $f9       ; -$fa
data_length     = $334      ; -$335. value 8000 (=$1f40). 40x25 cells, 1x8 bytes each

comp_value      = $3fc      ; used to compare if repeating byte or single byte
series_length   = $3fd      ; how long is the current series?

y_read          = $336
y_write         = $337
zero_store      = $338      ;-$339

; store values of $f9,$fa for later restore when done with this method
    lda series_start
    sta zero_store
    lda series_start+1
    sta zero_store+1


    lda #$40
    sta data_length
    lda #$1f
    sta data_length+1

    ldy #0
    sty series_length
    sty y_read
    sty y_write

.repeated_bytes
    lda (source_address),y          ; read current value
    jsr .increase_read_offset       ; increase offset
    sta comp_value                  ; store current value
    jmp +

-   inc series_length
    lda series_length
    cmp #128
    beq .write_repeated_bytes

+   lda (source_address),y          ; read next value
    jsr .increase_read_offset
    bcs .end

    ;compare values
    cmp comp_value
    bne .write_repeated_bytes
    sta comp_value
    beq -


.write_repeated_bytes
    sty y_read
    ldy y_write

    pha
    lda series_length
    sta (target_address),y
    jsr .increase_write_offset

    pla
    sta (target_address),y
    jsr .increase_write_offset
    sty y_write

.literal_series
    lda #0
    sta series_length

    ldy source_address+1
    sty series_start+1
    ldy y_read
    sty series_start

    lda (source_address),y          ; read current value
    jsr .increase_read_offset       ; increase offset
    sta comp_value                  ; store current value
    jmp +

-   inc series_length
    lda series_length
    cmp #128
    beq .write_literal_series       ;values are equal, commit the literal series and switch to repeating series

+   lda (source_address),y          ; read next value
    jsr .increase_read_offset
    bcs .end

    ;compare values
    cmp comp_value
    beq .write_literal_series
    sta comp_value
    beq -

    rts

.end
    lda zero_store
    sta series_start
    lda zero_store+1
    sta series_start+1

    clc
    rts

.write_literal_series
    sty y_read

    ;write series length
    ldy y_write
    sta (target_address),y
    jsr .increase_write_offset
    sty y_write

    ;write literal values values
    ldy #0
    sty y_store

-   ldy y_store
    lda (series_start),y
    iny
    sty y_store                     ;use this as the series-related y read offset

    ldy y_write
    sta (target_address),y
    jsr .increase_write_offset
    sty y_write
    dec series_length
    bne -

    lda #0
    sta series_length
    jmp .repeated_bytes

.increase_write_offset
    iny
    bne +
    inc target_address+1

+   rts

.increase_read_offset
    clc
    iny
    bne +
    inc source_address+1

+   dec data_length
    bne +
    dec data_length+1
    bne +
    sec

+   rts


;---------------------
;variable space
;---------------------
run_start       !word 0
run_length      !byte 0