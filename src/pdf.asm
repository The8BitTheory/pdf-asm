;https://blog.idrsolutions.com/make-your-own-pdf-file-part-1-pdf-objects-and-data-types/


buffer = $fb    ;and $fc

write_pdf
    ; create header
    ldx #0
    ldy #0

    stx buffer
    lda #$c0
    sta buffer+1
    

-   lda header,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf
    jsr print_lf

;create root object, pointing to object 2
    ;1 0 obj <</Type /Catalog /Pages 2 0 R>>
    ldx nrobjs
    inc nrobjs
    tya
    sta object_positions,x
    
    lda #$31
    jsr print_to_buffer
    jsr print_space
    lda #$30
    jsr print_to_buffer
    jsr print_space

    ldx #0
-   lda obj_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_space

    ;<<
    ldx #0
-   lda dict_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;/type
+   ldx #0
-   lda key_type,x
    beq +
    inx
    jsr print_to_buffer
    bne -
 
    ;/catalog
+   ldx #0
-   lda key_catalog,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ; /pages
+   ldx #0
-   lda key_pages,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ; 2 0 R
+   lda #$32
    jsr print_to_buffer
    jsr print_space

    lda #$30
    jsr print_to_buffer
    jsr print_space

    lda #$52    ;R
    jsr print_to_buffer

    ;>>
    ldx #0
-   lda dict_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf

    ;endobj
    ldx #0
-   lda obj_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf

; object 2
    ;2 0 obj <</Type /Pages /Kids [3 0 R] /Count 1>>
    ldx nrobjs
    inc nrobjs
    tya
    sta object_positions,x

    lda #$32
    jsr print_to_buffer
    jsr print_space
    lda #$30
    jsr print_to_buffer
    jsr print_space

    ldx #0
-   lda obj_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_space

    ;<<
    ldx #0
-   lda dict_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;/type
+   ldx #0
-   lda key_type,x
    beq +
    inx
    jsr print_to_buffer
    bne -
 
    ;/pages
+   ldx #0
-   lda key_pages,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ; /kids
+   ldx #0
-   lda key_kids,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   ldx #0
-   lda array_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ; 3 0 R
+   lda #$33
    jsr print_to_buffer
    jsr print_space

    lda #$30
    jsr print_to_buffer
    jsr print_space

    lda #$52    ;R
    jsr print_to_buffer

    ldx #0
-   lda array_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   ldx #0
-   lda key_count,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   lda #$31
    jsr print_to_buffer

    ;>>
    ldx #0
-   lda dict_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf

    ;endobj
    ldx #0
-   lda obj_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf

; object 3
    ;3 0 obj <</MediaBox [0 0 500 800]>>
    ldx nrobjs
    inc nrobjs
    tya
    sta object_positions,x

    lda #$33
    jsr print_to_buffer
    jsr print_space
    lda #$30
    jsr print_to_buffer
    jsr print_space

    ldx #0
-   lda obj_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_space

    ;<<
    ldx #0
-   lda dict_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   ldx #0
-   lda key_mediabox,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;[
+   ldx #0
-   lda array_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -
 
    ;0 0 500 800
+   lda #$30
    jsr print_to_buffer
    jsr print_space

    lda #$30
    jsr print_to_buffer
    jsr print_space

    lda #$35
    jsr print_to_buffer
    lda #$30
    jsr print_to_buffer
    lda #$30
    jsr print_to_buffer
    jsr print_space

    lda #$38
    jsr print_to_buffer
    lda #$30
    jsr print_to_buffer
    lda #$30
    jsr print_to_buffer

    ;]
    ldx #0
-   lda array_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;>>
+   ldx #0
-   lda dict_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf

    ;endobj
    ldx #0
-   lda obj_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf
;-----------------------
;          xref
; Cross Reference Table
;-----------------------
    sty xrefpos

    ldx #0
-   lda xref,x
    beq +
    inx
    jsr print_to_buffer
    bne -
+   jsr print_lf

    ; 0 2
    lda #$30
    jsr print_to_buffer
    jsr print_space

    lda nrobjs
    adc #$30
    jsr print_to_buffer
    jsr print_lf

    ; 0000000000 65535 f
    ldx #0
-   lda obj_0,x
    beq .xref_entries
    inx
    jsr print_to_buffer
    bne -

.xref_entries
;   print xref entries (starting with second one)
-   jsr print_xref
    lda nrobjs
    cmp curobj
    bpl -
    
;----------------
; trailer
;----------------
;trailer <</Size 2/Root 1 0 R>>
    ldx #0
-   lda trailer,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;<<
+   ldx #0
-   lda dict_start,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;/Size 2
+   ldx #0
-   lda key_size,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;nr objects for /Size 
+   tya
    pha
    lda nrobjs
    jsr a_to_dec
    pla
    tay

    lda digit_buffer+2
    cmp #$30
    beq +
    jsr print_to_buffer

+   lda digit_buffer+1
    cmp #$30
    beq +
    jsr print_to_buffer

+   lda digit_buffer
    jsr print_to_buffer

    ;/Root 1 0 R
    ldx #0
-   lda key_root,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ;1
+   lda #$31
    jsr print_to_buffer
    jsr print_space

    ;0
    lda #$30
    jsr print_to_buffer
    jsr print_space

    lda #$52    ;R
    jsr print_to_buffer

    ;>>
    ldx #0
-   lda dict_end,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf

    ldx #0
-   lda startxref,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_lf

    tya
    pha
    lda xrefpos
    jsr a_to_dec
    pla
    tay

    lda digit_buffer+2
    cmp #$30
    beq +
    jsr print_to_buffer

+   lda digit_buffer+1
    jsr print_to_buffer

+   lda digit_buffer
    jsr print_to_buffer

    jsr print_lf

    ldx #0
-   lda eof,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   rts

;--------------------------------
; end
;--------------------------------

print_xref
    ; 0000000010 00000 n
+   ldx #0
-   lda zero_7,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ; store y (will be used for hundrets)
+   tya
    pha
    ldx curobj
    lda object_positions,x
    inx
    stx curobj
    jsr a_to_dec
    ; restore y
    pla
    tay
    
    ; print hundrets
    lda digit_buffer+2
    jsr print_to_buffer

    ; print tens
    lda digit_buffer+1
    jsr print_to_buffer

    ; print ones
    lda digit_buffer
    jsr print_to_buffer
    
    jsr print_space

    ldx #0
-   lda zero_5,x
    beq +
    inx
    jsr print_to_buffer
    bne -

+   jsr print_space

    lda #$6e    ;n
    jsr print_to_buffer
    jsr print_lf

    rts

a_to_dec
    ldy #$2f
    ldx #$3a
    sec
-   iny
    sbc #100
    bcs -
-   dex
    adc #10
    bmi -
    adc #$2f

    sta digit_buffer
    stx digit_buffer+1
    sty digit_buffer+2

    rts

print_lf
    lda char_lf
    jmp print_to_buffer

print_space
    lda #$20

print_to_buffer
    sta (buffer),y
    iny
    bne +
    inc buffer+1
+   rts

char_lf             !byte $0a
xrefpos             !byte 0
nrobjs              !byte 1
curobj              !byte 1

header              !text "%PDF-1.3",0
eof                 !text "%%EOF",0
trailer             !text "trailer ",0
xref                !text "xref",0
startxref           !text "startxref",0

dict_start          !text "<<",0
dict_end            !text ">>",0
obj_start           !text "obj",0
obj_end             !text "endobj",0
array_start         !text "[ ",0
array_end           !text " ]",0
stream_start        !text "stream",0
stream_end          !text "endstream",0

key_basefont        !text "/BaseFont ",0
key_catalog         !text "/Catalog ",0
key_contents        !text "/Contents ",0
key_count           !text "/Count ",0
key_font            !text "/Font ",0
key_kids            !text "/Kids ",0
key_length          !text "/Length ",0
key_mediabox        !text "/MediaBox ",0
key_pages           !text "/Pages ",0
key_parent          !text "/Parent ",0
key_resources       !text "/Resources ",0
key_root            !text "/Root ",0
key_size            !text "/Size ",0
key_subtype         !text "/Subtype ",0
key_type            !text "/Type ",0
key_type1           !text "/Type1",0

font_timesroman     !text "/Times-Roman",0

obj_0               !text "0000000000 65535 f",$a,0
zero_5              !text "00000",0
zero_7              !text "0000000",0

digit_buffer        !byte 0,0,0


write_pos           !word 0     ; used for writing offset positions, mainly. write index itself is buffer + y
y_store             !byte 0     ; used to store y-reg

; object_positions must be the last byte, because it expands according to the number of objects
object_positions    !byte 0
