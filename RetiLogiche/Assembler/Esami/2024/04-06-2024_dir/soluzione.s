.include "./files/utility.s"

.data
n:  .word 0 # nh, nl
m:  .word 0 # mh, ml
p:  .long 0 

.text

_main:
    nop

    call indecimal_word
    movw %ax, n
    call newline

    call indecimal_word
    movw %ax, m
    call newline

    mov $0, %eax
    movw n, %ax
    movw m, %bx
    # al = xl, bl = yl
    mul %bl     
    # eax = xl * yl
    addl %eax, p

    mov $0, %eax
    movw n, %ax
    movw m, %bx
    shr $8, %bx
    # al = xl, bl = yh
    mul %bl     
    shl $8, %eax
    # eax = xl * yh * 8
    addl %eax, p

    mov $0, %eax
    movw n, %ax
    shr $8, %ax
    movw m, %bx
    # al = xh, bl = yl
    mul %bl    
    shl $8, %eax
    # eax = xh * yl * 8
    addl %eax, p

    mov $0, %eax
    movw n, %ax
    shr $8, %ax
    movw m, %bx
    shr $8, %bx
    # al = xl, bl = yl
    mul %bl     
    shl $16, %eax
    # eax = xh * yh * 16
    addl %eax, p

    movl p, %eax
    call outdecimal_long
    call newline
    ret
