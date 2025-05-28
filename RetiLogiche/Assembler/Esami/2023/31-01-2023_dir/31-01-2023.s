.include "./files/utility.s"
.global _main
.data
 arr:			.fill 16,1,0
 r:				.byte 0
 c:				.byte 0
 r_max:			.byte 0
 c_max:			.byte 0
.text
 _main:				NOP
# --- Inserimento ---------------------------
 ins_col:			CALL inchar
					CMP $'\r', %AL
					JE stampa_max
					CMP $'a', %AL
					JB ins_col
					CMP $'d', %AL
					JA ins_col
					CALL outchar
					SUB $'a', %AL
					MOV %AL, c

 ins_row:			CALL inchar
					CMP $'0', %AL
					JB ins_row
					CMP $'3', %AL
					JA ins_row
					CALL outchar
					SUB $'0', %AL
					MOV %AL, r
# --- Incremento ----------------------------
				# 4*row + col
					MOV $0, %EAX
					MOV $0, %EBX
					MOVb r, %AL
					MOVb c, %BL
					LEA arr(%EAX, %EBX, 4), %ECX
					INCb (%ECX)

					CALL newline
					JMP ins_col
# --- findMax -------------------------------
 stampa_max:		MOV $0, %DX
					MOV $0, %ECX

 loop_max:			CMPb %DL, arr(%ECX)
					JA newMax
					INC %ECX
					CMP $16, %ECX
					JE stampa
					JMP loop_max

 newMax:			MOV arr(%ECX), %DL
				# c_max
					PUSH %CX
					SHR $2, %CL
					MOV %CL, c_max
					POP %CX
				# r_max
					PUSH %CX
					AND $0x03, %CL
					MOV %CL, r_max
					POP %CX

					INC %ECX
					CMP $16, %ECX
					JE stampa
					JMP loop_max
# --- Stampa ---------------------------------
 stampa:			CALL newline
 					MOVb c_max, %AL
					ADD $'a', %AL
					CALL outchar
 					MOVb r_max, %AL
					ADD $'0', %AL
					CALL outchar

					RET
