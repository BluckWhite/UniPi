.include "./files/utility.s"
.global _main
.data
 # - Salvo la codifica ascii
 arr:           .fill 10,1,0

.text
_main:              NOP
# --- Inserimento --------------------------------------
                    LEA arr, %EBX
                    MOV $10, %ECX
 ins_arr:           CALL inchar
                    CMP $'0', %AL 
                    JB ins_arr
                    CMP $'9', %AL
                    JA ins_arr
                    CALL outchar
                    MOV %AL, (%EBX)
                    INC %EBX
                    LOOP ins_arr
# --- Input Comandi ------------------------------------
 ins_cmd:           CALL inchar
                    CMP $'q', %AL
                    JE ruota_SX
                    CMP $'w', %AL
                    JE ruota_DX
                    CMP $'e', %AL
                    JE scambio
                    CMP $'z', %AL
                    JE fine
                    JMP ins_cmd
# --- Stampa -------------------------------------------
 stampa:            CALL newline
                    LEA arr, %EBX
                    MOV $10, %ECX
 loop_s:            MOV (%EBX), %AL
                    CALL outchar
                    INC %EBX
                    LOOP loop_s
                    JMP ins_cmd
# --- Comandi ------------------------------------------
 ruota_SX:          MOV $0, %ECX
                    LEA arr, %EBX
                    LEA arr, %EDX
                    INC %EDX

                    MOV (%EBX), %AL
 loop_SX:           MOV (%EDX), %AH
                    MOV %AH, (%EBX)
                    
                    CMP $8, %ECX
                    JE end_SX
                    INC %EBX
                    INC %EDX
                    INC %ECX
                    JMP loop_SX

 end_SX:            INC %EBX
                    MOV %AL, (%EBX)
                    JMP stampa
 # ---
 ruota_DX:          MOV $0, %ECX
                    LEA arr, %EBX
                    ADD $9, %EBX
                    LEA arr, %EDX
                    ADD $8, %EDX

                    MOV (%EBX), %AL
 loop_DX:           MOV (%EDX), %AH
                    MOV %AH, (%EBX)
                    
                    CMP $8, %ECX
                    JE end_DX
                    DEC %EBX
                    DEC %EDX
                    INC %ECX
                    JMP loop_DX

 end_DX:            MOV %AL, arr
                    JMP stampa
 # ---
 scambio:           MOV $0, %ECX
                    LEA arr, %EBX
                    LEA arr, %EDX
                    ADD $5, %EDX

 loop_scambio:      MOV (%EBX), %AL
                    MOV (%EDX), %AH
                    MOV %AH, (%EBX)
                    MOV %AL, (%EDX)

                    CMP $4, %CL
                    JE stampa
                    INC %EBX
                    INC %EDX
                    INC %ECX
                    JMP loop_scambio

 fine:              RET
