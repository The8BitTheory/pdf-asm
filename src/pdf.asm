;https://blog.idrsolutions.com/make-your-own-pdf-file-part-1-pdf-objects-and-data-types/


buffer      = $fb   ;and $fc. that's where we assemble the source-text for the pdf
pointer     = $fd   ;and $fe
y_buffer    = $fa   ; usually contains HB pointer for rs232-output buffer
y_pointer   = $f9   ; usually contains LB pointer for rs232-output buffer

write_pdf
    ; create header
    ldx #0
    ldy #0

    sty y_buffer
    stx buffer
    lda #$c0
    sta buffer+1
    
    lda #<header
    sta pointer
    lda #>header
    sta pointer+1
    jsr pointer_to_buffer

    jsr print_lf
    jsr print_lf

;create root object, pointing to object 2
    ;1 0 obj <</Type /Catalog /Pages 2 0 R>>
    lda #1
    jsr print_obj_start_block

    ;/type
    jsr print_key_type
 
    ;/catalog
    jsr print_key_catalog

    ; /pages
    jsr print_key_pages

    ; 2 0 R
    lda #$32
    jsr print_to_buffer
    jsr print_space
    jsr print_zero_R

    ;>>
    jsr print_dict_end
    jsr print_lf

    ;endobj
    jsr print_obj_end
    jsr print_lf

; object 2
    ;2 0 obj <</Type /Pages /Kids [3 0 R] /Count 1>>
    lda #2
    jsr print_obj_start_block

    ;/type
    jsr print_key_type
 
    ;/pages
    jsr print_key_pages

    ;/kids
    jsr print_key_kids

    jsr print_array_start

    ; 3 0 R
    lda #$33
    jsr print_to_buffer
    jsr print_space
    jsr print_zero_R
    jsr print_array_end
    jsr print_key_count

    lda #$31
    jsr print_to_buffer

    ;>>
    jsr print_dict_end
    jsr print_lf

    ;endobj
    jsr print_obj_end
    jsr print_lf

; object 3
    ;3 0 obj <</MediaBox [0 0 500 800]>>
    lda #3
    jsr print_obj_start_block
    jsr print_key_mediabox

    ;[
    jsr print_array_start
 
    ;0 0 500 800
    lda #$30
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
    jsr print_array_end

    ;>>
    jsr print_dict_end
    jsr print_lf

    ;endobj
    jsr print_obj_end
    jsr print_lf
;-----------------------
;          xref
; Cross Reference Table
;-----------------------
    sty xrefpos

    lda #<xref
    sta pointer
    lda #>xref
    sta pointer+1
    jsr pointer_to_buffer

    jsr print_lf

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
-   jsr print_xref_block
    lda nrobjs
    cmp curobj
    bne -
    
;----------------
; trailer
;----------------
;trailer <</Size 2/Root 1 0 R>>
    lda #<trailer
    sta pointer
    lda #>trailer
    sta pointer+1
    jsr pointer_to_buffer

    ;<<
    jsr print_dict_start

    ;/Size 2
    jsr print_key_size

    ;nr objects for /Size 
    lda nrobjs
    jsr a_to_dec
    jsr print_digits

    ;/Root 1 0 R
    jsr print_key_root

    ;1
    lda #$31
    jsr print_to_buffer
    jsr print_space

    ;0
    jsr print_zero_R

    ;>>
    jsr print_dict_end
    jsr print_lf

    lda #<startxref
    sta pointer
    lda #>startxref
    sta pointer+1
    jsr pointer_to_buffer

    jsr print_lf

    lda xrefpos
    jsr a_to_dec

    jsr print_digits
    jsr print_lf
    
    lda #<eof
    sta pointer
    lda #>eof
    sta pointer+1
    jsr pointer_to_buffer

    rts

;--------------------------------
; end
;--------------------------------

print_xref_block
    ; 0000000010 00000 n
    ldx #0
-   lda zero_7,x
    beq +
    inx
    jsr print_to_buffer
    bne -

    ; store y (will be used for hundrets)
+   ldx curobj
    lda object_positions,x
    inx
    stx curobj
    jsr a_to_dec
    
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


pointer_to_buffer
    ldy #0
    sty y_pointer
-   ldy y_pointer
    lda (pointer),y
    beq +
    iny
    sty y_pointer
    jsr print_to_buffer
    bne -
+   rts

print_key_catalog
    lda #<key_catalog
    sta pointer
    lda #>key_catalog
    sta pointer+1
    jmp pointer_to_buffer

print_key_count
    lda #<key_count
    sta pointer
    lda #>key_count
    sta pointer+1
    jmp pointer_to_buffer

print_key_kids
    lda #<key_kids
    sta pointer
    lda #>key_kids
    sta pointer+1
    jmp pointer_to_buffer

print_key_mediabox
    lda #<key_mediabox
    sta pointer
    lda #>key_mediabox
    sta pointer+1
    jmp pointer_to_buffer

print_key_root
    lda #<key_root
    sta pointer
    lda #>key_root
    sta pointer+1
    jmp pointer_to_buffer

print_key_size
    lda #<key_size
    sta pointer
    lda #>key_size
    sta pointer+1
    jmp pointer_to_buffer

print_key_type
    lda #<key_type
    sta pointer
    lda #>key_type
    sta pointer+1
    jmp pointer_to_buffer

print_key_pages
    lda #<key_pages
    sta pointer
    lda #>key_pages
    sta pointer+1
    jmp pointer_to_buffer

print_array_start
    lda #<array_start
    sta pointer
    lda #>array_start
    sta pointer+1
    jmp pointer_to_buffer

print_array_end
    lda #<array_end
    sta pointer
    lda #>array_end
    sta pointer+1
    jmp pointer_to_buffer

print_dict_start
    lda #<dict_start
    sta pointer
    lda #>dict_start
    sta pointer+1
    jmp pointer_to_buffer

print_dict_end
    lda #<dict_end
    sta pointer
    lda #>dict_end
    sta pointer+1
    jmp pointer_to_buffer

print_obj_start
    lda #<obj_start
    sta pointer
    lda #>obj_start
    sta pointer+1
    jmp pointer_to_buffer

print_obj_end
    lda #<obj_end
    sta pointer
    lda #>obj_end
    sta pointer+1
    jmp pointer_to_buffer

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
    ldy y_buffer
    sta (buffer),y
    iny
    sty y_buffer
    bne +
    inc buffer+1
+   rts

print_obj_start_block
    pha ;save A for in a bit
    ldx nrobjs
    inc nrobjs
    tya
    sta object_positions,x
    pla ;restore A

    clc
    adc #$30
    jsr print_to_buffer
    jsr print_space
    lda #$30
    jsr print_to_buffer
    jsr print_space

    jsr print_obj_start
    jsr print_space

    ;<<
    jsr print_dict_start

    rts

print_digits
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

    rts

print_zero_R
    lda #$30
    jsr print_to_buffer
    jsr print_space

    lda #$52    ;R
    jsr print_to_buffer
    rts

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

; object_positions must be the last byte, because it expands according to the number of objects
object_positions    !byte 0
