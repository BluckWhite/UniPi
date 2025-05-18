.include "./files/utility.s"
.global _main
.data
x:              .word 0
y:              .word 0

msg_1:          .asciz "dentro\r"
msg_2:          .asciz "fuori\r"
.text
_main:              NOP
                    XOR %EAX, %EAX
# --- Inserimento -------------------------------
 inse:               CALL inword
                    CALL abs                    
                    CMP $500, %AX
                    JA fine
                    MOV %AX, x
                    CALL newline

                    CALL inword
                    CALL abs
                    CMP $500, %AX
                    JA fine
                    MOV %AX, y
                    CALL newline

                    CMPb $0, x
                    JNZ isDentro
                    CMPb $0, y
                    JZ fine
#!-----------------------------------------------
 isDentro:          XOR %EDX, %EDX
                    ADD x, %DX
                    ADD y, %DX
                    CMP $128, %DX
                    JA fuori
                    CMP $64, %DX
                    JB fuori

 dentro:            LEA msg_1, %EBX
                    CALL outline
                    CALL newline
                    JMP inse

 fuori:             LEA msg_2, %EBX
                    CALL outline
                    CALL newline
                    JMP inse

 fine:              RET

#!-----------------------------------------------
# --- Funzioni ----------------------------------
 abs:               CMP $0, %AX
                    JL negativo                    
                    RET
 negativo:          NEG %AX
                    INC %AX          
                    RET
