.include "./files/utility.s"
.global _main
.data
 n:                 .byte 0
 arr:               .fill 16,2,0
.text
 _main:                 NOP
# --- Calcolo n ----------------------------------
                        CALL indecimal_byte
                        AND $0x0F, %AL
                        JZ fine
                        MOV %AL, n
# --- Tartaglia ----------------------------------
                        CALL newline
                        CALL newline
                        MOV $1, %ECX

                        LEA arr, %ESI
                        MOVw $1, (%ESI)

                        CMPb $1, n
                        JE stampa_fine
                        
                        INCb n
 loop_tart:             LEA arr, %ESI
                        CALL stampa

                        PUSH %ECX
                        MOVw (%ESI), %BX
 tart:                  MOV %BX, %AX
                        ADD $2, %ESI
                        MOVw (%ESI), %BX
                        ADD %BX, %AX
                        MOV %AX, (%ESI)
                        
                        DEC %CL
                        CMP $0, %CL
                        JNZ tart

                        POP %ECX
                        INC %CL
                        CMP %CL, n
                        JNE loop_tart
                        JMP fine

 stampa_fine:           CALL stampa
 fine:                  RET
# --- Funzioni -----------------------------------
 stampa:                PUSH %EBX
                        PUSH %EAX
                        LEA arr, %EBX
 # - Stampa uno spazio in più alla fine, che è anche nel file output.txt
 loopStampa:            CMPw $0, (%EBX)
                        JZ fineStampa
                        MOV (%EBX), %AX
                        CALL outdecimal_word
                        MOV $' ', %AL
                        CALL outchar
                        ADD $2, %EBX
                        JMP loopStampa
 
 fineStampa:            CALL newline
                        POP %EAX
                        POP %EBX
                        RET
