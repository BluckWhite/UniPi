.INCLUDE "./files/utility.s"
.GLOBAL _main

.DATA

matrix:				.FILL 16,1,0
max:				.BYTE 0

#		       | a b c d
#		    ---+---------
#		     0 | 0 0 0 0
#		     1 | 0 0 0 0
#		     2 | 0 0 0 0
#		     3 | 0 0 0 0


.TEXT			
_main:			NOP
			XOR %EAX, %EAX
start:			CALL inchar
			CMP $13, %AL
			JE punto_4
			
			CMP $'a', %AL
			JB start
			CMP $'d', %AL
			JA start

			MOV %EAX, %ESI

			CALL outchar
insNum:			CALL inchar
			CMP $'0', %AL
			JB insNum
			CMP $'3', %AL
			JA insNum
			CALL outchar

			SUB $'0', %AL

			XOR %EBX, %EBX
			MOV %AL, %BL

			CALL newline

#			4*riga + colonna
			LEA matrix(%ESI, %EBX, 4), %EDX
			MOVB (%EDX), %AL

			INC %AL
			MOV %AL, matrix(%ESI, %EBX, 4)

#			CALL outdecimal_byte
#			CALL newline

			JMP start

punto_4:		CALL outchar
			CALL newline

			CALL findMax		# aggiorna max
			
			MOVB max, %AL
#			CALL outdecimal_byte

			MOV %AL, %BL

			CMP $4, %BL
			JL a
			CMP $8, %BL
			JL b
			CMP $12, %BL
			JL c
			JMP d

a:			MOV $'a', %AL
			JMP num
b:			MOV $'b', %AL
			JMP num
c:			MOV $'c', %AL
			JMP num
d:			MOV $'d', %AL
			JMP num

num:			CALL outchar
			AND $3, %BL
			MOV %BL, %AL

			CALL outdecimal_byte
			CALL newline

			JMP start

# -------------------- FUNZIONI ----------------------

findMax:		PUSH %EAX
			XOR %ECX, %ECX
			XOR %EAX, %EAX
			LEA matrix, %EDX

fm_2:			CMPB (%EDX), %AL 
			JA UNchange
			MOVB (%EDX), %AL
			MOV %CL, %AH

UNchange:		INC %ECX
			INC %EDX
			CMP $16, %ECX
			JNE fm_2

			DEC %ECX
			MOV %AH, max
			MOV %AH, %AL

			CALL outdecimal_byte

			POP %EAX
			RET

# ------------------------------------------------------

			RET

