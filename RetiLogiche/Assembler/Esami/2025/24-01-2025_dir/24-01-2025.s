.include "files/utility.s"
.global _main
.data
 abs_a:			.LONG 0
 sgn_a:			.BYTE 0
 abs_b:			.WORD 0
 sgn_b:			.BYTE 0

 abs_q:			.WORD 0
 abs_r:			.WORD 0
 sgn_q:			.BYTE 0
 sgn_r:			.BYTE 0

 msg_1:			.ASCIZ "NO DIV\r"
.text
 _main:				NOP
# --- Inserimento -----------------------------
					CALL inlong
					PUSH %EAX
					AND $0x8000, %EAX
					JNZ neg_a
					POP %EAX
					MOV %EAX, abs_a
					JMP ins_b

 neg_a:				POP %EAX
 					MOVb $1, sgn_a
					NEG %EAX
					MOV %EAX, abs_a

 ins_b:				CALL newline
 					CALL inword
					CMP $0, %AX
					JZ no_div
					PUSH %AX
					AND $0x80, %AX
					JNZ neg_b
					POP %AX
					MOV %AX, abs_b
					JMP nxt

 neg_b:				POP %AX
 					MOVb $1, sgn_b
					NEG %AX
					MOV %AX, abs_b
# --- Divisione -------------------------------
				# - Ciclo divisione
 nxt:				XOR %EBX, %EBX
					MOV $0, %ECX
					MOVl abs_a, %EAX
 					MOVw abs_b, %BX
 ciclo_div:			CMP %EBX, %EAX
					JB fine_div
 					SUB %EBX, %EAX
					INC %ECX
					JMP ciclo_div
				# - %EAX: abs(r) - %ECX: abs(q)
 fine_div:			PUSH %ECX
 					AND $0xFFFF0000, %ECX
					JNZ no_div_pop
 					POP %ECX
					
					MOV %CX, abs_q
					MOV sgn_a, %DH
					MOV sgn_b, %DL
					XOR %DH, %DL
					MOV %DL, sgn_q
					MOV %DH, sgn_r
					MOV %AX, abs_r
					JMP stampa
# --- Stampa ----------------------------------
 stampa:			MOV sgn_q, %CL
					MOV abs_q, %AX

					PUSH %EAX			# -
					NEG %AX				# - Se il risultato della divisione è -(B^n-1)
					CMP $0x8000, %AX 	# - esso non ha corrispettivo per i naturali sullo
					JE no_div_pop		# - stesso numero di cifre
					POP %EAX			# -

					CMP $0, %CL
					JE pos_q
					CALL newline		
 pos_q:				CALL outword

					CALL newline
					MOV sgn_r, %CL
					MOV abs_r, %AX
					CMP $0, %CL
					JE pos_r
					NEG %AX
 pos_r:				CALL outword
 					RET

 no_div_pop:		POP %ECX
 no_div:			LEA msg_1, %EBX
					CALL newline
					CALL outline
					RET
