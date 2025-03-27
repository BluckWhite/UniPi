
# --- NON FINITO

.include "./files/utility.s"
.global _main

.DATA

x:			.BYTE
y:			.BYTE

.TEXT
_main:			NOP

			CALL inNumber
			MOV %AL, x
			MOV $' ', %AL
			CALL outchar

			JMP inOp
mainOp:			CALL outchar
			MOV %AL, %BL
			MOV $' ', %AL
			CALL outchar

			CALL inNumber
			MOV %AL, y

			JMP calcolo

# --------- Blocco inserimento x ; y ---------
inNumber:		
inSgn:			CALL inchar
			CMP $'-', %AL
			JE inNegValue
			CMP $'+', %AL
			JNE inSgn

inPosValue:		CALL outchar
			CALL indecimal_byte
			RET

inNegValue:		CALL outchar
			CALL indecimal_byte
			NEG %AL
			RET
# ------------------- Fine --------------------
# ------ Blocco inserimento operazione --------
inOp:			CALL inchar
			CMP $'+', %AL
			JE mainOp
			CMP $'-', %AL
			JE mainOp
			CMP $'*', %AL
			JE mainOp
			CMP $'/', %AL
			JE mainOp
			JMP inOp
# ------------------- Fine --------------------
# ------- Blocco esecuzione operazione --------
calcolo:		CMP $'+', %BL
			JE somma


somma:			MOVB x, %BL
			ADD %BL, y	
			CALL outchar
			
			RET


# ------------------- Fine --------------------

