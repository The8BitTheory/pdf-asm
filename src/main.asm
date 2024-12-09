; generate a pdf file from Hires-VIC-II data
;
; steps involved:
; - create the generic PDF data structure (plain-text)
; - RLE-Encode the VIC-II Hires data
; - write the PDF-File to disk


*= $9000    ;this is just for testing purposes. real tesa printer drivers start at $9000

!source "src/pdf.asm"

    lda #0
    sta $AE
    lda #90
    sta $AF

!source "src/rle.asm"



rts 