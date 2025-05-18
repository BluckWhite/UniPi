.include "./files/utility.s"
.global _main
.data
 arr:               .fill 50,1,0
 n:                 .byte 0
.text
 _main:                 NOP
                        CALL indecimal_byte
                        MOV %AL, n
                        LEA arr, %EBX               # - %EBX: Indirizzo array
                        MOVb $2, (%EBX)
                        INC %EBX
                        MOVb $3, (%EBX)
# --- Calcolo -----------------------------------------------------------------------------------------
                        MOV $2, %EDI                # - %EDI: Prossima locazione libera
                        XOR %EAX, %EAX
                        XOR %EBX, %EBX
                        MOV $4, %CL                 # - %ECX: Papabile numero primo
                        MOV $0, %ESI                # - %ESI: Indice array

 isPrime:               CMPb $0, arr(%ESI)
                        JZ Prime

                        XOR %EAX, %EAX
                        MOV %CL, %AL
                        MOV arr(%ESI), %BL
                        DIV %BL
                        CMP $0, %AH
                        JZ notPrime
                        INC %ESI
                        JMP isPrime

 Prime:                 MOV %CL, arr(%EDI)
                        INC %EDI
                        CMP n, %EDI
                        JE stampa

 notPrime:              INC %CL
                        MOV $0, %ESI
                        JMP isPrime
# --- Stampa -----------------------------------------------------------------------------------------
 stampa:                XOR %ESI, %ESI
                        CALL newline
 loop_s:                CMP $50, %ESI
                        JE fine
                        
                        CMPb $0, arr(%ESI)
                        JZ fine
                        MOVb arr(%ESI), %AL
                        CALL outdecimal_byte
                        MOV $' ', %AL
                        CALL outchar
                        INC %ESI
                        JMP loop_s

 fine:                  RET
