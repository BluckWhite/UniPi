
# -- non funziona, manca implementazione per Interi

.INCLUDE "./files/utility.s"
.GLOBAL _main
.DATA

msg:			        .ASCII "NO DIV\r"

.TEXT
_main:			      NOP
			            XOR %EDX, %EDX
			            XOR %ECX, %ECX

punto_1:		      CALL inlong		# EAX
			            CALL newline



			            MOV %EAX, %EBX		# EBX = a
			            CALL inword		# AX
			            MOV %AX, %DX		# DX = b
                  # a = q * b + r

			            CMP %EDX, %EBX
			            JL noDiv
						      # se %EAX > %EDX => in eax è presente il resto dell'operazione e il contenuto di
						      # %ECX simboleggia il quoziente
calcolo_q:		    INC %ECX
			            SUB %EDX, %EBX

                  CMP %EDX, %EBX
			            JGE calcolo_q


punto_3:		      CALL newline
            			MOV %ECX, %EAX
            			CALL outlong
			            CALL newline
			            MOV %EBX, %EAX
			            CALL outlong

			            RET

noDiv:			      CALL newline
			            LEA msg, %EBX
			            CALL outline

			            RET

