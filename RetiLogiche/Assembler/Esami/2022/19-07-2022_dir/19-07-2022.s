.include "./files/utility.s"
.global _main
.data
 mod_x:         .byte 0
 mod_y:         .byte 0
 sgn_x:         .byte 0    
 sgn_y:         .byte 0
.text
 _main:             NOP
# --- Inserimento ------------------------------                    
                    CALL indecimal_byte
                    CALL newline
                    CMP $100, %AL
                    JAE fine
                    CMP $50, %AL
                    JB pos_x
                    MOV %AL, %DL
                    MOV $99, %AL
                    SUB %DL, %AL
                    INC %AL
                    MOVb $1, sgn_x
 pos_x:             MOV %AL, mod_x
 
                    CALL indecimal_byte
                    CALL newline
                    CMP $100, %AL
                    JAE fine
                    CMP $50, %AL
                    JB pos_y
                    MOV %AL, %DL
                    MOV $99, %AL
                    SUB %DL, %AL
                    INC %AL
                    CALL outdecimal_byte
                    CALL newline
                    MOVb $1, sgn_y
 pos_y:             MOV %AL, mod_y
# --- Calcolo ----------------------------------
                    MOV mod_x, %BL
                    MOV mod_y, %AL
                    MUL %BL         # %AX -> ris
                    CMP $5000, %AX
                    JAE fine

                    MOV sgn_x, %CL
                    XORb sgn_y, %CL
                    JZ pos_r
                    
                    MOV %AX, %DX
                    MOV $9999, %AX
                    SUB %DX, %AX
                    INC %AX
 pos_r:             CALL outdecimal_word

 fine:              RET
