.include "./files/utility.s"
.global _main
.DATA

xl:             .byte 0
xh:             .byte 0
yl:             .byte 0
yh:             .byte 0

ris:            .long 0

.TEXT
_main:          NOP
                XOR %EDX, %EDX
# --- Inserimento --------------------------------------
                CALL indecimal_word
                CALL newline
                MOV %AL, xl
                MOV %AH, xh
                CALL indecimal_word
                MOV %AL, yl
                MOV %AH, yh
                CALL newline
# --- Calcolo ------------------------------------------
                XOR %EAX, %EAX

                MOV yl, %AL
                MOV xl, %BL
                MUL %BL
                ADD %AX, ris

                MOV yh, %AL
                MOV xl, %BL
                MUL %BL
                SHL $8, %EAX
                ADD %EAX, ris
# ---
                XOR %EAX, %EAX

                MOV yl, %AL
                MOV xh, %BL
                MUL %BL
                SHL $8, %EAX
                ADD %EAX, ris

                ADD %AL, ris

                MOV yh, %AL
                MOV xh, %BL
                MUL %BL
                SHL $16, %EAX
                ADD %EAX, ris
# --- Stampa ------------------------------------------
                MOV ris, %EAX
                CALL outdecimal_long

                RET
