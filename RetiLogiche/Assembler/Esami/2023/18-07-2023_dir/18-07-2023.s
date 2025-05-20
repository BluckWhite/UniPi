.include "./files/utility.s"
.global _main
.data
 n:                 .fill 6,1,0
 ris:               .long 0
.text
 _main:                 NOP
# --- Inserimento -------------------------------------------
                        MOV $0, %EBX
 ins_n:                 CALL inchar
                        CMP $'0', %AL
                        JB ins_n
                        CMP $'6', %AL
                        JA ins_n
                        CALL outchar
                        SUB $'0', %AL
                        MOV %AL, n(%EBX)
                        CMP $5, %BL
                        INC %BL
                        JB ins_n
# --- Conversione -------------------------------------------
                        MOV $0, %EAX
                        MOV $0, %EBX
                        MOV $5, %ECX
                        PUSH %ECX
                        MOV n(%EBX), %AL
 
 mul_7:                 MOV $7, %EDX
                        MUL %EDX
                        LOOP mul_7
                        
                        ADD %EAX, ris
                        INC %BL
                        MOV $0, %EAX
                        MOV n(%EBX), %AL
                        
                        POP %ECX
                        DEC %CL
                        CMP $0, %CL
                        JE stampa
                        PUSH %ECX
                        JMP mul_7
# --- Stampa ------------------------------------------------
 stampa:                ADD %EAX, ris
                        MOV ris, %EAX
                        CALL newline
                        CALL outdecimal_long
                        CALL newline

                        MOV $0, %EBX
                        MOVl $0, ris

                        CMP $0, %EAX
                        JZ fine
                        CALL newline
                        JMP ins_n

 fine:                  RET
