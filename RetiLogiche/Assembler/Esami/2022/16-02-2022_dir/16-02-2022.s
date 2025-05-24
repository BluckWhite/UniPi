.include "./files/utility.s"
.global _main
.data

 x:             .fill 8,1,0
 y:             .fill 8,1,0
 # - 'r' e 'z' in memoria sono consecutive
 r:             .byte 0
 z:             .fill 8,1,0

.text
 _main:             NOP
# --- Inserimento --------------------------------
 input:             MOV $1, %DL

                    MOV $8, %ECX
                    LEA x, %EBX
                    CALL ins_v

                    SHL $8, %DX
                    CALL newline
                    MOV $1, %DL

                    MOV $8, %ECX
                    LEA y, %EBX
                    CALL ins_v

                    OR %DH, %DL
                    JNZ fine                
                    CALL newline
# --- Calcolo ------------------------------------
                    LEA x, %ESI
                    ADD $7, %ESI
                    LEA y, %EDI
                    ADD $7, %EDI
                    LEA z, %EDX
                    ADD $7, %EDX

                    MOV $0, %ECX

 alg:               MOVb (%EDX), %BL
                    MOVb (%ESI), %AL
                    ADD %AL, %BL
                    MOVb (%EDI), %AL
                    ADD %AL, %BL
                    CMP $6, %BL
                    JAE riporto
 # - Niente Riporto
                    MOV %BL, (%EDX)
                    DEC %ESI
                    DEC %EDI
                    DEC %EDX
                    JMP isStampa

 riporto:           SUB $6, %BL
                    MOV %BL, (%EDX)
                    DEC %ESI
                    DEC %EDI
                    DEC %EDX
                    MOVb $1, (%EDX)

 isStampa:          INC %CX
                    CMP $8, %ECX
                    JE stampa
                    JMP alg
# --- Stampa -------------------------------------
 stampa:            MOV $8, %ECX
                    LEA z, %EDX
 loop_s:            MOV (%EDX), %AL
                    CALL outdecimal_byte
                    INC %EDX
                    LOOP loop_s
                    
                    MOV $' ', %AL
                    CALL outchar
                    MOV r, %AL
                    CALL outdecimal_byte
                    CALL newline
                    CALL newline
# --- Pulizia Memoria ----------------------------                    
                    MOVb $0, r
                    LEA z, %EDI
                    MOV $0, %AL
                    MOV $8, %ECX
                    REP STOSb

                    JMP input
# --- Funzioni -----------------------------------
 ins_v:             CALL inchar
                    CMP $'0', %AL
                    JB ins_v
                    CMP $'6', %AL
                    JAE ins_v
                    CALL outchar
                    SUB $'0', %AL

                    CMP $0, %AL
                    JZ nxt
                    MOV $0, %DL

 nxt:               MOV %AL, (%EBX)
                    INC %EBX
                    LOOP ins_v
                    RET

 fine:              RET
