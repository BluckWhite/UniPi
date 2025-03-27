
# --- In scrittura ------------------------------------------------------ 

.include "./files/utility.s"
.global _main
.data
abs_a:              .long
abs_b:              .word
sgn_a:              .byte 0
sgn_b:              .byte 0

sgn_q:              .byte 0
sgn_r:              .byte 0
abs_q:              .long                           # ?
abs_r:              .word

mess:               .ASCIZ "NO DIV\r"

.text
_main:                NOP
# --- Inserimento -------------------------------------------------------
                      CALL inlong                   # %EAX
                      CMP $0, %EAX
                      JGE pos_a
                      MOVB $1, sgn_a
                      NEG %EAX
                      INC %EAX

pos_a:                MOV %EAX, abs_a

                      CALL newline
                      CALL inword                   # %AX
                      CMP $0, %AX
                      JGE pos_b
                      MOVB $1, sgn_b
                      NEG %AX
                      INC %AX

pos_b:                MOV %AX, abs_b

#!------------------------------------------------------------------------
# --- a = q * b + r ------------------------------------------------------
                      XOR %EBX, %EBX
                      XOR %ECX, %ECX
                      MOVL abs_a, %EAX
                      MOVW abs_b, %EBX

                      CMP %EBX, %EAX
                      JL loop_div
                      JMP nodiv

Idiv:                 CMP %EBX, %EAX
                      JG end_div

loop_div:             SUB %EBX, %EAX
                      INC %ECX                       # in %ECX calcolo q
                      JMP Idiv

end_div:              MOV %AX, abs_r








#!------------------------------------------------------------------------
# --- stampa -------------------------------------------------------------
nodiv:                CALL newline
                      LEA mess, %EBX
                      CALL outline                   # ? oppure outmess

                      RET

