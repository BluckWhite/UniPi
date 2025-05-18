.include "./files/utility.s"
.global _main

.data

    msg_1:      .ASCIZ "colpito!\r"
    msg_2:      .ASCIZ "mancato!\r"
    msg_3:      .ASCIZ "vittoria!\r"

    arr:        .WORD 0
    x:          .BYTE 0
    y:          .BYTE 0

.text
    _main:          NOP
                    CALL inword
                    MOV %AX, arr                
                    CALL newline

                    CMP $0x00, %AX
                    JE win
//--- Inserimento Coordinate --------------------------------
                    XOR %EAX, %EAX

    insx:           CALL inchar
                    CMP $'a', %AL
                    JB insx
                    CMP $'d', %AL
                    JA insx

                    CALL outchar
                    SUB $'a', %AL
                    MOV %AL, x

    insy:           CALL inchar
                    CMP $'1', %AL
                    JB insy
                    CMP $'4', %AL
                    JA insy

                    CALL outchar
                    SUB $'1', %AL
                    MOV %AL, y

                    CALL newline
//--- ! ------------------------------------------------------
                    MOV arr, %DX

                    MOV y, %CL
                    SHL $2, %CL
                    ADD x, %CL

                    MOV $1, %AX
                    SHL %CL, %AX

                    AND %AX, %DX
                    JNZ hit
                    JMP miss

    win:            LEA msg_3, %EBX
                    CALL outline
                    RET

    hit:            LEA msg_1, %EBX
                    CALL outline
                    NOT %AX
                    AND %AX, arr
                    JZ win
                    JMP insx

    miss:           LEA msg_2, %EBX
                    CALL outline
                    JMP insx
