;!to "fsave.bin", cbm

;* = $1C20

;file_start = $FB      ; $FB-$FC
file_end   = $03E6      ; 998-999
;file_name  = $03E8      ; 1000 - 1001
;file_namelength = $03EA ; 1002

        LDA $03EA     ; length of filename
        LDX $03E8     ; filename address LB
        LDY $03E9     ; filename address HB
        JSR $FFBD     ; call SETNAM

        LDA #$02      ; filenumber 2
        LDX $BA       ; last used device number
        BNE +
        LDX #$08      ; default to device 8
+       LDY #$02      ; secondary address 2 
        JSR $FFBA     ; call SETLFS

        JSR $FFC0     ; call OPEN
        BCS .error    ; if carry set, the file could not be opened

        ; check drive error channel here to test for
        ; FILE EXISTS error etc.

        LDX #$02      ; filenumber 2
        JSR $FFC9     ; call CHKOUT (file 2 now used as output)

;        LDA $FB     ; start address of data LB
;        STA $AE
;        LDA $FC     ; start address of data HB
;        STA $AF

        LDY #$00
.loop   JSR $FFB7     ; call READST (read status byte)
        BNE .werror   ; write error

        LDA #$AE       ; store address to fetch into Acc (for INDFET)
;        LDX $03EB     ; bank for INDFET
;        JSR $FF74     ; call INDFET, get byte from memory
        JSR $FFD2     ; call CHROUT (write byte to file)

        INC $AE
        BNE +
        INC $AF
+
        LDA $AE
        CMP file_end
        LDA $AF
        SBC file_end+1
        BCC .loop     ; next byte
.close
        LDA #$02      ; filenumber 2
        JSR $FFC3     ; call CLOSE

        JSR $FFCC     ; call CLRCHN
        RTS
.error
        ; Akkumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)

        ;... error handling for open errors ...
        JMP .close    ; even if OPEN failed, the file has to be closed
.werror
        ; for further information, the drive error channel has to be read

        ;... error handling for write errors ...
        JMP .close
