.include "./files/utility.s"
.global _main
.data

n:              .WORD 0
p:              .LONG 0

.text
 _main:             NOP
                    XOR %EBX, %EBX
                    XOR %EAX, %EAX
# --- Inserimento -----------------------------------
                    CALL indecimal_word
                    MOV %AX, n
                    CALL newline
                    CALL indecimal_word
                    MOV %AX, %CX
                    CALL newline
# --- Moltiplicazione -------------------------------
                    MOV n, %AX
 mulM:              ADD %EAX, %EBX
                    LOOP mulM

                    MOV %EBX, %EAX
                    CALL outdecimal_long
                    
 fine:              RET
