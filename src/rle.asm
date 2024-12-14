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
y_source        = $f7
y_target        = $f8
y_run           = $2        ; originally contains LB of RS232-input buffer       


data_length     = $334      ; -$335. value 8000 (=$1f40). 40x25 cells, 1x8 bytes each

comp_value      = $3fc      ; used to compare if repeating byte or single byte
run_length      = $3fd      ; how long is the current series?

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
    sty y_source
    sty y_target
    sty y_run
    lda (target_address),y
    beq +

    ldy #32
    lda #0
-   sta (target_address),y
    dey
    bpl -

+   lda #10
    sta data_length
    lda #0
    sta data_length+1
;    lda #$40
;    sta data_length
;    lda #$1f
;    sta data_length+1

.start
    lda #0
    sta run_length
    sta y_run
    
    ; set run_start to current read position
    lda source_address+1
    sta run_start+1    
    clc
    lda source_address
    adc y_source
    sta run_start
    bcc +
    inc source_address+1

+   ldy y_source
    lda (source_address),y          ; read current value
    jsr .increase_read_offset       ; increase offset
    sta comp_value                  ; store current value
    
    lda (source_address),y          ; read next value
    jsr .increase_read_offset
    bcs .end

    ;compare values
    cmp comp_value
    bne .literal_series
    ;beq .repeated_bytes            ; just fall through here

;.repeated_bytes
-   sta comp_value
    inc run_length
    bmi .write_repeated_bytes       ; check if we reached the limit of 127 values. if so, write run to output

    lda (source_address),y          ; read next value
    cmp comp_value
    bne .write_repeated_bytes
    jsr .increase_read_offset       ; only increase read offset when run goes on.
    bcs .end
    jmp -

.write_repeated_bytes
    ldy y_target

    sec
    lda #0
    sbc run_length
    sta (target_address),y
    jsr .increase_write_offset

    lda comp_value
    sta (target_address),y
    jsr .increase_write_offset

    jmp .start


.literal_series
    sta comp_value

-   inc run_length
    bmi .write_literal_series       ;127 values reached. commit the literal series and jump to start

    ;y is set to y_source, coming from the .start routine
    lda (source_address),y          ; read next value

    ;compare values
    cmp comp_value
    sta comp_value
    beq .write_literal_series       ; we found matching values. end the literal series
    
    jsr .increase_read_offset
    bcs .end
    jmp -


.end
    ;write terminating byte 
    lda #$80
    ldy y_target
    sta (target_address),y

    ;recover zero-page addresses
    lda zero_store
    sta run_start
    lda zero_store+1
    sta run_start+1

    clc
    rts

.write_literal_series
    ;write series length (run_length is reduced by 1)
    dec run_length
    lda run_length
    ldy y_target
    sta (target_address),y
    jsr .increase_write_offset

    ;write literal values
-   ldy y_run
    lda (run_start),y
    iny
    sty y_run                     ;use this as the series-related y read offset

    ldy y_target
    sta (target_address),y
    jsr .increase_write_offset
    dec run_length
    bpl -

    ; decrease read offset, because we need to go back one step
    dec y_source
    bpl +
    dec source_address+1

+   jmp .start

.increase_write_offset
    iny
    sty y_target
    bne +
    inc target_address+1

+   rts

; increases read-offset, also decreases data_length to find out if we reached EOF
; carry-set means end of input is reached
.increase_read_offset
    clc         ; clear carry flag

    iny
    sty y_source
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
