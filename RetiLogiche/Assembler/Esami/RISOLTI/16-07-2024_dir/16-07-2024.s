
# --- FUNZIONA -----------------------------------------------

.include "./files/utility.s"
.global _main
.data 
x:                  .fill 8, 1, 0
y:                  .fill 8, 1, 0
z:                  .fill 8, 1, 0                   # z = x + y
.text
_main:                    NOP
start:                    XOR %EDX, %EDX
                          LEA x, %EBX
                          CALL inCiclo
                          CALL newline
                          LEA y, %EBX
                          MOV %DL, %DH
                          CALL inCiclo
                          CALL newline

                          AND %DL, %DH
                          JZ fine

                          JMP adder

fine:                     RET

# --- Somma --------------------------------------------------------
adder:                    XOR %EAX, %EAX                  # in %AL  c'è una cifra di x
                          XOR %EBX, %EBX                  # in %BL  c'è una cifra di y
                          XOR %EDX, %EDX                  # in %DL  c'è il carry
                          LEA x, %EDI                     # in %EDI c'è l'indirizzo di x
                          LEA y, %ESI                     # in %ESI c'è l'indirizzo di y
                          MOV $7, %ECX

rippleC:                  MOV (%EDI, %ECX), %AL
                          MOV (%ESI, %ECX), %BL
                          ADD %BL, %AL
                          ADD %DL, %AL
                          LEA z, %EBX
                          CMP $8, %AL
                          JAE setCarry

                          MOV %AL, (%EBX,%ECX)
                          XOR %DL, %DL

addedC:                   SUB $1, %CL
                          JC stampa
                          JMP rippleC

setCarry:                 MOVB $0, (%EBX, %ECX)
                          MOV $1, %DL
                          JMP addedC

#!------------------------------------------------------------------
# --- Stampa -------------------------------------------------------
stampa:                   XOR %ECX, %ECX                  # in %DL si aspetta il carry finale
                          LEA z, %ESI

loopS:                    MOV (%ESI, %ECX, 1), %AL
                          CALL outdecimal_byte
                          INC %CL
                          CMP $8, %CL
                          JNE loopS

                          MOV $' ', %AL
                          CALL outchar
                          MOV %DL, %AL
                          CALL outdecimal_byte
                          CALL newline
                          CALL newline
                          JMP start
#!------------------------------------------------------------------
# --- Inserimento --------------------------------------------------
inCifra:                  CALL inchar                     # modifica contenuto di %AL
                          CMP $'0', %AL 
                          JB inCifra
                          CMP $'7', %AL
                          JA inCifra
                          CALL outchar
                          SUB $'0', %AL
                          RET
#!------------------------------------------------------------------
inCiclo:                  PUSH %ECX                       # in %EBX si aspetta l'indirizzo di un array da 8 byte
                          XOR %ECX, %ECX                  # modifica contenuto di %AL %DL

ins:                      CALL inCifra
                          MOV %AL, (%EBX, %ECX, 1)
                          CMP $0, %AL
                          JE nxt
                          MOV $1, %DL                     # il primo valore != 0 annulla il controllo x == 0 o y == 0

nxt:                      INC %CL
                          CMP $8, %CL
                          JNE ins

                          POP %ECX
                          RET
#!------------------------------------------------------------------
