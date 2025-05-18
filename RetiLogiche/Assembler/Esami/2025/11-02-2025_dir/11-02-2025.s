
# -- FUNZIONANTE ma non ho seguito lo stesso ragionamento

.INCLUDE "./files/utility.s"
.GLOBAL _main

.DATA

.TEXT
_main:			NOP
			XOR %EAX, %EAX
			XOR %EBX, %EBX
			XOR %ECX, %ECX

			MOV $' ', %AL
			CALL outchar
# --- ins e conv
			MOV $6, %CL
insNum:			DEC %CL
insErr:			CALL inchar
			CMP $'0', %AL
			JB insErr
			CMP $'4', %AL
			JA insErr

			CALL outchar
			SUB $'0', %AL

			XOR %AH, %AH
			CALL esp
			ADD %AX, %BX

			CMP $0, %CL
			JNE insNum

			MOV %BX, %AX			
#			CALL newline
#			CALL outdecimal_word
#			CALL newline
# ---
			SHL %AX
# --- unconv e display

			MOV $7, %CX
			MOV $5, %BX

div_mod:		XOR %DX, %DX
			DIV %BX

#			CALL newline
#			CALL outdecimal_word

			PUSH %DX

#			CALL outdecimal_word

			DEC %CX
			CMP $0, %CX
			JNE div_mod

			CALL newline
			MOV $7, %CX
display:		POP %AX

			CALL outdecimal_byte

			DEC %CX
			CMP $0, %CX
			JNE display

			RET

# --------------- FUNZIONI ---------------
# moltiplica il contenuto di AL per 5 un numero di volte pari al contenuto di (CL - 1) e salva il risultato in EAX 

esp:			PUSH %ECX
			PUSH %EBX

			MOV $5, %BX
l_esp:			CMP $0, %ECX
			JE f_esp
			DEC %ECX
			MUL %BX
			JMP l_esp
			
f_esp:			POP %EBX
			POP %ECX
			RET
# ----------------------------------------
