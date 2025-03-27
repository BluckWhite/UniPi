
# --- NON FUNZIONANTE

.include "files/utility.s"

.global _main

.DATA

#       0. segno_x ; 1. x ; 2. op ; 3. segno_y ; 4. y
vettI:                  .FILL 5,1,0 
messErr:		.ASCIZ "ERR"

.TEXT
_main:                  NOP
			XOR %EAX, %EAX
			XOR %EBX, %EBX
			XOR %ECX, %ECX
			XOR %EDX, %EDX
			LEA vettI, %ESI

insSgn:                 CMP $0, %ECX
			JE firstSgn
			INC %CX					#ECX: 3				

firstSgn:		CALL inchar
                        CMP $'-', %AL
                        JNE isPlus
			MOVB %AL, (%ESI,%ECX)
			CALL outchar
			JMP insNum

isPlus:                 CMP $'+', %AL
                        JNE insSgn
			MOVB %AL, (%ESI,%ECX)
			CALL outchar

insNum:			CALL inchar
			CMP $'0', %AL
			JB insNum
			CMP $'9', %AL
			JA insNum
			CALL outchar

			SUB $'0', %AL
			CMP $1, %CX
			JE insN_2
			CMP $4, %CX
			JE insN_2

			MOV $10, %DL
			MUL %DL
			MOV %AL, %BL
			INC %CX					#ECX: 1 - 4
			
			JMP insNum

insN_2:			ADD %BL, %AL
			MOVB %AL, (%ESI,%ECX)
			CMP $4, %CX
			JE insEnter

insSpace:		CALL inchar
			CMP $' ', %AL
			JNE insSpace
			CALL outchar
			CMP $2, %CX
			JE insSgn


insOper:		CALL inchar
			CMP $'+', %AL
			JE OperTrue
			CMP $'-', %AL
			JE OperTrue
			CMP $'*', %AL
			JE OperTrue
			CMP $'/', %AL
			JE OperTrue
			
			JMP insOper

OperTrue:		INC %CX					#ECX: 2
			MOVB %AL, (%ESI,%ECX)
			CALL outchar
			JMP insSpace

insEnter:		CALL inchar
			CMP $13, %AL				# 13: ritorno_carrello ? 
			JNE insEnter
			CALL outchar

# -------------------- OPERAZIONE --------------------

			CALL newline

			MOVB +2(%ESI), %AL
			CMP $'+', %AL
			JE opSomma
			CMP $'-', %AL
			JE opSott
			CMP $'*', %AL
			JE opMul

opDiv:			CMP $0, +4(%ESI)
			JE errCase
			



errCase:		LEA messErr, %EBX
			CALL outline
			JMP _main

			RET
















