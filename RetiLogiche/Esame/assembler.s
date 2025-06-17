# --- Nicholas Del Buono - M: 673120
.include "./files/utility.s"
.global _main
.data
 n:             .word 0                                 # - Un n_i generico può non stare su 8bit
 msg_1:         .asciz "Numero iterazioni (k):\r"
.text
_main:              NOP
                    XOR %CL, %CL                        # - Contatore k, inizializzato a 0
                    CALL indecimal_byte
                    XOR %AH, %AH                        # - Azzero AH
                    MOV %AX, n
# --- Ciclo -------------------------------------------------------------------------
loop_k:             CMP $1, %AX                         # - Se in input si riceve 1, si effettua 0 iterazioni
                    JE stampa_k
                    INC %CL
                    
                    CMP $0, %CL                         # - Se %CL supera 255 si entra in un loop infinito
                    JZ fine                             # - Controllo omettibile date le specifiche

                    AND $0x01, %AX                      # - Verifico la parità di n_i
                    JZ pari                             # - Se non è pari, non effettua il salto e procede in dispari
 # n_(i+1) = 3 * n_i + 1
dispari:            MOVw n, %AX
                    MOV $3, %BX
                    MUL %BX                             # - In %DX_%AX si ha %AX * %BX, ma sono rilevanti solo i primi 16 bit.
                    INC %AX
                    MOVw %AX, n
                    JMP stampa_n
 # n_(i+1) = n_i / 2
pari:               MOVw n, %AX
                    SHR %AX                             # - Divido per 2
                    MOV %AX, n
                    JMP stampa_n                        # - Inutile, lasciato per maggior leggibilità
# --- Stampa ------------------------------------------------------------------------
stampa_n:           CALL newline
                    CALL outdecimal_word
                    JMP loop_k

stampa_k:           CALL newline
                    LEA msg_1, %EBX
                    CALL outline
                    MOV %CL, %AL
                    CALL outdecimal_byte
                    CALL newline
fine:               RET

# fine file