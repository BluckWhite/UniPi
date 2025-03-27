
# --- finito ------------------------------------------------- 

.INCLUDE "./files/utility.s"
.GLOBAL _main

.DATA

  array: 			.BYTE 0x1A, 0x47, 0x34, 0xC5, 0x9B, 0x02, 0x6D, 0x8E, 0x9B, 0x1D, 0x47, 0x60, 0x29, 0x3A, 0x9B, 0x11
n:    			.BYTE 16
msg_1:			.ASCIZ "Trovata occorrenza di\n\r"
msg_2:			.ASCIZ "Conteggio attuale:\n\r"
msg_3:			.ASCIZ "Scansione array terminata.\n\r"
msg_3b:			.ASCIZ "Totale:\n\r"
msg_4:			.ASCIZ "occorrenze di\n\r"

usr:	  		.BYTE 0


.TEXT
_main:            NOP
                  XOR %ECX, %ECX

switch:           CALL inchar
                  CMP $'f', %AL
			            JE fine
			            CMP $'s', %AL
			            JNE NOs

            			CALL outchar
			            MOV $' ', %AL
			            CALL outchar
			            CALL inbyte
			            MOV %AL, usr
			            JMP newSearch

NOs:			        CMP $'n', %AL
			            JE nxtElem

			            JMP switch

# --------------- newSearch ---------------
newSearch:		    XOR %ECX, %ECX
			            MOV n, %DL
			            LEA array, %EDI

search:			      CMP $0, %DL
		  	          JE fineSearch

#                  MOVB (%EDI), %AL
#                  CALL outbyte
#                  CALL newline

			            MOVB usr, %AH
			            CMPB %AH, (%EDI)
                  JE found
			            INC %EDI

#                  MOVB (%EDI), %AL
#                  CALL outbyte

			            DEC %DL
			            JMP search

found:			      INC %CL
                  INC %EDI
                  DEC %DL           # ???
			            LEA msg_1, %EBX
			            CALL newline
            			CALL outline			# trovata occorrenza di\n

                  MOVB %AH, %AL
            			CALL outbyte			# BYTE
            			CALL newline
            			LEA msg_2, %EBX
            			CALL outline			# conteggio attuale
            			MOV %CL, %AL
            			CALL outdecimal_byte  		# conto
	
            			CALL newline

            			JMP switch
#!-----------------------------------------
# ---------------- nxtElem ----------------
nxtElem:		      CMP $0, %CX
			            JE switch

            			CALL outchar

            			JMP search
 #!-----------------------------------------

fineSearch:		    LEA msg_3, %EBX
			            CALL newline
            			CALL outline			# scansione terminata
            			MOV %CL, %AL
            			LEA msg_3b, %EBX
            			CALL outline
            			CALL outdecimal_byte		# numOccorrenze
            			CALL newline
            			LEA msg_4, %EBX
            			CALL outline			# occorrenze di
            			MOVB usr, %AL
            			CALL outbyte
            			CALL newline

            			XOR %ECX, %ECX
            			JMP switch

fine:			        RET

