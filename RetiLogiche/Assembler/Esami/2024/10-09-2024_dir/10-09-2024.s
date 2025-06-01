.include "files/utility.s"
.global _main
.data
 x:             .BYTE 0
 y:             .BYTE 0
 msg_1:         .ASCIZ "= ERR\r"
.text
 _main:             NOP
# --- Inserimento -----------------------------
 ins_x:             CALL inchar
                    CMP $'+', %AL
                    JE pos_x
                    CMP $'-', %AL
                    JE neg_x
                    JMP ins_x
 neg_x:             CALL outchar
                    CALL indecimal_byte
                    NEG %AL
                    JMP nxt_x
 pos_x:             CALL outchar
                    CALL indecimal_byte
 nxt_x:             MOV %AL, x

                    MOV $' ', %AL 
                    CALL outchar
 # - Switch Op
 ins_op:            CALL inchar
                    CMP $'+', %AL
                    JE sumF
                    CMP $'-', %AL
                    JE subF
                    CMP $'*', %AL
                    JE mulF
                    CMP $'/', %AL
                    JE divF
                    JMP ins_op
 # --- Funzione ins_y -------------------------
  ins_yFun:         MOV $' ', %AL
                    CALL outchar
  ins_y:            CALL inchar
                    CMP $'+', %AL
                    JE pos_y
                    CMP $'-', %AL
                    JE neg_y
                    JMP ins_y
  neg_y:            CALL outchar
                    CALL indecimal_byte
                    NEG %AL
                    JMP nxt_y
  pos_y:            CALL outchar
                    CALL indecimal_byte
  nxt_y:            MOV %AL, y
                    RET
# --- Operazioni ------------------------------
 # [x+y]
 sumF:              CALL outchar
                    CALL ins_yFun
                    MOV x, %AL
                    CBW
                    MOV %AX, %DX
                    MOV y, %AL
                    CBW
                    ADD %AX, %DX
                    JMP stampa
 # [x-y]
 subF:              CALL outchar
                    CALL ins_yFun
                    MOV x, %AL
                    CBW
                    MOV %AX, %DX
                    MOV y, %AL
                    CBW
                    SUB %AX, %DX
                    JMP stampa
 # [x*y]
 mulF:              CALL outchar
                    CALL ins_yFun
                    MOV x, %AL
                    CBW
                    MOV %AX, %DX
                    MOV y, %AL
                    CBW
                    MUL %DX
                    MOV %AX, %DX
                    JMP stampa

 divF:              CALL outchar
                    CALL ins_yFun
                    MOV x, %AL
                    CBW
                    MOV y, %CL
                    CMP $0, %CL
                    JE fine
                    IDIV %CL
                    MOV %AX, %DX
                    JMP stampa
# --- Stampa ----------------------------------
 stampa:            CALL newline
                    MOV $'=', %AL
                    CALL outchar
                    MOV $' ', %AL
                    CALL outchar

                    CMP $0, %DX
                    JL neg_z
                    MOV $'+', %AL
                    JMP nxt_z
 neg_z:             NEG %DX
                    MOV $'-', %AL
 nxt_z:             CALL outchar
                    MOV %DX, %AX
                    CALL outdecimal_word
                    CALL newline
                    CALL newline
                    JMP ins_x
 
 fine:              CALL newline
                    LEA msg_1, %EBX
                    CALL outline
                    RET
