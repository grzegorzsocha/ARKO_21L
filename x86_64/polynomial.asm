section .text
    global polynomial

; Params:
; rdi - pointer to first pixel
; rsi - width
; rdx - height
; rcx - current x pos
; xmm0 - A
; xmm1 - B
; xmm2 - C
; xmm3 - D
; xmm4 - S
; xmm5 - x (double)

polynomial:

    push rbp
    mov rbp, rsp

    ; set x to -256
    mov rcx, -256
    cvtsi2sd xmm5, rcx 

    ; set r10 to 0
    mov r10, 0

draw_y_axis:

    ; calculate pixel address
    mov r8, rsi
    imul r8, 3
    imul r8, r10
    mov r11, rsi
    sar r11, 1
    imul r11, 3
    add r8, r11
    lea r9, [rdi + r8]
    mov [r9], dword 0x00ffffff

    ; increase values
    add r10, 1
    cmp rdx, r10
    jne draw_y_axis

    ; save 0 to r10 to initiate value needed for x axis drawing
    mov r10, 0
    
draw_x_axis:

    ; calculate pixel address
    mov r8, rdx
    sar r8, 1
    imul r8, rsi
    imul r8, 3
    mov r11, r10
    imul r11, 3
    add r8, r11
    lea r9, [rdi + r8]
    mov [r9], dword 0x00ffffff

    ; increase values
    add r10, 1
    cmp rsi, r10
    jne draw_x_axis

get_y:

    ; calculate y value
    movsd xmm7, xmm5    ; xmm7 = Ax^3
    mulsd xmm7, xmm5
    mulsd xmm7, xmm5
    mulsd xmm7, xmm0

    movsd xmm8, xmm5    ; xmm8 = Bx^2
    mulsd xmm8, xmm5
    mulsd xmm8, xmm1

    addsd xmm7, xmm8    ; xmm7 = Ax^3 + Bx^2

    movsd xmm8, xmm5    ; xmm8 = Cx
    mulsd xmm8, xmm2

    addsd xmm7, xmm8    ; xmm7 = Ax^3 + Bx^2 + Cx + D
    addsd xmm7, xmm3
    cvtsd2si r8, xmm7

    ; check whether y is less or greater than zero
    cmp r8, 0
    jl y_less_than_zero

y_greater_than_zero:

    ; check whether y is out of range
    mov r13, r8
    sub r13, 256
    cmp r13, 0
    jg get_x

    ; if it is not jump to change_pixel
    jmp change_pixel

y_less_than_zero:

    ; check whether y is out of range
    mov r13, r8
    add r13, 256
    cmp r13, 0
    jl get_x

change_pixel:

    ;calculate pixel address
    add r8, 256
    imul r8, rdx
    mov r13, rcx
    add r13, 256
    add r8, r13
    imul r8, 3
    lea r8, [rdi + r8]

    ;change pixel
    mov [r8], dword 0x00ffffff

get_x:

    ; calculate derative and segment value to add to new x
    movsd xmm7, xmm5    ; xmm7 = 3Ax^2
    mulsd xmm7, xmm7
    mulsd xmm7, xmm0
    mov rax, 3
    cvtsi2sd xmm8, rax
    mulsd xmm7, xmm8

    movsd xmm8, xmm5    ; xmm8 = 2Bx
    mulsd xmm8, xmm1
    mov rax, 2
    cvtsi2sd xmm9, rax
    mulsd xmm8, xmm9

    addsd xmm7, xmm8    ; xmm7 = 3Ax^2 + 2Bx + C
    addsd xmm7, xmm2

    mov rax, 1          ; xmm9 = S / sqrt((3Ax^2 + 2Bx + C)^2 + 1)
    cvtsi2sd xmm9, rax
    mulsd xmm7, xmm7
    addsd xmm7, xmm9
    sqrtsd xmm7, xmm7
    movsd xmm9, xmm4
    divsd xmm9, xmm7

    ; update x by adding segment value and convert it to integer
    addsd xmm5, xmm9    ; xmm5 = x + S / sqrt((3Ax^2 + 2Bx + C)^2 + 1)
    cvtsd2si rcx, xmm5

    ; check whether x is out of range
    mov r11, rdx
    sar r11, 1
    cmp rcx, r11
    jl get_y

return:

    mov rsp, rbp	
	pop rbp
	ret
