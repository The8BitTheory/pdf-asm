; generate a pdf file from Hires-VIC-II data
;
; steps involved:
; - create the generic PDF data structure (plain-text)
; - RLE-Encode the VIC-II Hires data
; - write the PDF-File to disk

; code resides in $9000
; pdf-source resides in $c000
; $33c (tape buffer) is used for rle-encoding experiments right now

*= $9000    ;this is just for testing purposes. real tesa printer drivers start at $9000



;    lda #0
;    sta $AE
;    lda #90
;    sta $AF

    jsr write_pdf
    jsr rle_encode
    rts

;!source "src/pdf.asm"
;!source "src/rle.asm"

!source "pdf.asm"
!source "rle.asm"


 