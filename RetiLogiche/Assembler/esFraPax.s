/*
.INCLUDE "./files/utility.s"
.global _main

.DATA
array:      .FILL 95,1       # 95 byte -> 11 * 8 + 7

.TEXT
*/
/*
_main:          NOP
                MOV $0, %ESI
                MOV $11, %CH

ciclo:          MOV $8, %CL
                CALL inchar                     # inchar -> %AL 
                MOV %AL, array(%ESI)            
                DEC %CL
                JZ fine_parola

fine_parola:    DEC %CH
                JNZ ciclo


                RET
*/
# 3 cifre base 10 --> stampa n/3

/*
_main:          NOP
                MOV $3, %BL

while:          CALL inchar
                XOR %EAX, %EAX

                CMP $'0', %AL
                JB while
                CMP $'0', %AL
                JA while
                CALL outchar
                SUB $'0', %AL 

                DEC %BL
                JZ while


                DIV %BL
                CALL newline
                CALL outdecimal_byte
                RET                
*/

/*
    prendi un numero a 3 cifre in base 10, stampalo / 3
*/
.include "./files/utility.s"

.global _main

.data

.text
_main:
        nop
        mov $0, %eax
        mov $0, %ebx
        mov $0, %ecx

inse:   call inchar
        SUB $'0', %AL
        // se non inserisco un numero non lo stampo e devo inserire di nuovo
        cmp $0, %al
        jb inse
        cmp $9, %al
        ja inse

        call outdecimal_byte
        mov $0, %ah
        INC %CL

        // prima cifra
        cmp $1, %cl
        je _1
        // seconda cifra
        cmp $2, %cl
        je _2
        //terza cifra
        cmp $3, %cl
        je _3
        
        //stampa
stampa: mov %bx, %ax
        mov $3, %dl
        divb %dl
        call outdecimal_byte
        ret

_1:     mov $100, %dl
        mulb %dl
        mov %ax, %bx
        jmp inse

_2:     mov $10, %dl
        mulb %dl
        add %ax, %bx
        jmp inse

_3:     add %ax, %bx
        call newline
        jmp stampa
