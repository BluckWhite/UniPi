.include "./files/utility.s"
.global _main
.data

                # f(x) = x^2 - b*x - c 
                #
                # m = (l_i + r_i) / 2
                # f(m) == 0 ? ret :
                #   f < 0 -> [m, r_i]
                #   f > 0 -> [l_i, m]

 b:                 .word 0
 c:                 .word 0
 l:                 .byte 0
 r:                 .byte 0
 m:                 .byte 0

.text
 _main:                 NOP
# --- Inserimento ----------------------------------
                        CALL indecimal_word
                        MOV %AX, b
                        CALL newline

                        CALL indecimal_word
                        MOV %AX, c
                        CALL newline

                        CALL indecimal_byte
                        MOV %AL, l
                        CALL newline

                        CALL indecimal_byte
                        MOV %AL, r
                        CALL newline
# --- Algoritmo ------------------------------------
                        JMP out_interval
 find_x:                CALL find_m
                        MOVb m, %AL
                        MUL %AL

                        MOV $0, %ECX
                        MOV %AX, %CX        # %CX: m^2

                        MOV m, %BL
                        MOV $0, %BH
                        MOV b, %AX
                        IMUL %BX
                       # MOV $0, %EDX
                        SHL $8, %EDX
                        MOV %AX, %DX        # %EDX: b*m

                        MOV c, %AX
                        CWDE
                        ADD %EAX, %EDX      # %EDX: (b*m + c)
                        SUB %EDX, %ECX      # %ECX: f(m)
# --- Controlli ------------------------------------
                        CMP $0, %ECX
                        JZ out_m
                        JG change_r
                        MOV m, %AL
                        MOV %AL, l
                        JMP check
 
 change_r:              MOV m, %AL
                        MOV %AL, r
                        JMP check

 check:                 MOV l, %BL
                        MOV r, %AL

                        CMP %BL, %AL
                        JE out_m

                        JMP out_interval
# --- Stampa ---------------------------------------
 out_interval:          MOV $'[', %AL
                        CALL outchar
                        MOV l, %AL
                        CALL outdecimal_byte
                        MOV $',', %AL
                        CALL outchar
                        MOV $' ', %AL
                        CALL outchar
                        MOV r, %AL
                        CALL outdecimal_byte
                        MOV $']', %AL
                        CALL outchar

                        CALL newline

                        JMP find_x

 out_m:                 MOVb m, %AL
                        CALL outdecimal_byte
                        RET
# --- Metodi ---------------------------------------
                    # calcolo m su 16 bit perché l + r non è
                    # sempre rappresentabile su 8 bit
 find_m:                PUSH %EAX
                        PUSH %EBX

                        MOV l, %BL
                        MOV $0, %BH
                        MOV r, %AL
                        MOV $0, %AH
                        ADD %BX, %AX
                        SHR %AX
                        MOV %AL, m

                        POP %EBX
                        POP %EAX

                        RET
